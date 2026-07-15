-- 20260713000035_ssc.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  SMART SHIPPING CENTER (SSC) — Vol 7 — o cérebro da Expedição              ║
-- ║  Reusa outbound_orders/pick_waves/docks/carriers/postal_services.         ║
-- ║  Adiciona: catálogo de caixas, cargas consolidadas + IA de escolha de     ║
-- ║  transportadora, otimização de embalagem, geração de ondas, gargalos.     ║
-- ║  Recurso RBAC 'shipping'.                                                  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.load_status as enum ('open','loading','dispatched','canceled');

-- ── PACKAGING_BOXES (catálogo de caixas para otimização) ────────────────────
create table public.packaging_boxes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, name text not null,
  length_mm numeric(12,2), width_mm numeric(12,2), height_mm numeric(12,2),
  max_weight_g numeric(14,3), cost numeric(12,2),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── SHIPPING_LOADS (consolidação de cargas: pallet/gaiola/caminhão) ─────────
create table public.shipping_loads (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  carrier_id uuid references public.carriers(id) on delete set null,
  vehicle_id uuid references public.vehicles(id) on delete set null,
  dock_id uuid references public.docks(id) on delete set null,
  code text, load_type text default 'truck', status public.load_status not null default 'open',
  total_weight_g numeric(16,3), volumes integer, notes text, dispatched_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_shipping_loads_status on public.shipping_loads (company_id, status) where deleted_at is null;

create table public.shipping_load_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  load_id uuid not null references public.shipping_loads(id) on delete cascade,
  outbound_order_id uuid references public.outbound_orders(id) on delete set null,
  package_id uuid references public.packages(id) on delete set null,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_shipping_load_items_load on public.shipping_load_items (load_id);

-- ── RPC: painel da central de expedição (pipeline por estágio) ──────────────
create or replace function public.shipping_center(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'confirmed', (select count(*) from public.outbound_orders where company_id=p_company and status='confirmed' and deleted_at is null),
    'allocated', (select count(*) from public.outbound_orders where company_id=p_company and status='allocated' and deleted_at is null),
    'picking',   (select count(*) from public.outbound_orders where company_id=p_company and status='picking' and deleted_at is null),
    'packed',    (select count(*) from public.outbound_orders where company_id=p_company and status='packed' and deleted_at is null),
    'shipped_today', (select count(*) from public.outbound_orders where company_id=p_company and shipped_at::date=now()::date and deleted_at is null),
    'waves_open', (select count(*) from public.pick_waves where company_id=p_company and status in ('planned','released','picking') and deleted_at is null),
    'tasks_pending', (select count(*) from public.warehouse_tasks where company_id=p_company and status in ('pending','assigned','in_progress') and deleted_at is null),
    'loads_open', (select count(*) from public.shipping_loads where company_id=p_company and status in ('open','loading') and deleted_at is null),
    'dock_appointments_today', (select count(*) from public.dock_appointments where company_id=p_company and scheduled_start::date=now()::date and deleted_at is null),
    'backlog', (select count(*) from public.outbound_orders where company_id=p_company and status in ('confirmed','allocated','picking','packed') and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.shipping_center(uuid) to authenticated;

-- ── RPC: IA de escolha de transportadora (custo × prazo × urgência) ─────────
create or replace function public.recommend_carrier(p_company uuid, p_weight_g numeric, p_urgency text default 'normal')
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(x order by x.score) from (
      select name as service, code, sla_days,
        round(base_price + price_per_kg * (p_weight_g/1000.0), 2) as price,
        round( (base_price + price_per_kg*(p_weight_g/1000.0)) * (case when p_urgency='high' then 0.3 else 1 end)
             + coalesce(sla_days,3) * (case when p_urgency='high' then 15 else 3 end), 2) as score
      from public.postal_services where company_id=p_company and active and deleted_at is null
    ) x
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.recommend_carrier(uuid, numeric, text) to authenticated;

-- ── RPC: otimização de embalagem (menor caixa que comporta) ─────────────────
create or replace function public.optimize_packing(p_company uuid, p_weight_g numeric, p_volume_cm3 numeric default 0)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_build_object('box', name, 'code', code, 'cost', cost,
        'inner_volume_cm3', round(length_mm*width_mm*height_mm/1000.0,0), 'max_weight_g', max_weight_g)
    from public.packaging_boxes
    where company_id=p_company and active and deleted_at is null
      and coalesce(max_weight_g, 1e12) >= coalesce(p_weight_g,0)
      and (length_mm*width_mm*height_mm/1000.0) >= coalesce(p_volume_cm3,0)
    order by (length_mm*width_mm*height_mm) asc
    limit 1
  ), jsonb_build_object('box', null, 'message', 'Nenhuma caixa comporta — cadastre uma maior.')) else '{}'::jsonb end;
$$;
grant execute on function public.optimize_packing(uuid, numeric, numeric) to authenticated;

-- ── RPC: gera ondas de expedição agrupando pedidos por região (UF) ──────────
create or replace function public.generate_shipping_waves(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_uf record; v_wave uuid;
begin
  if not app.has_permission('shipping.create', p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;

  for v_uf in
    select coalesce(ship_to_uf,'??') uf, count(*) n from public.outbound_orders
    where company_id=p_company and status in ('confirmed','allocated') and wave_id is null and deleted_at is null
    group by ship_to_uf
  loop
    insert into public.pick_waves (tenant_id, company_id, code, status, strategy, notes)
    values (v_tenant, p_company, 'WAVE-'||v_uf.uf||'-'||to_char(now(),'YYYYMMDDHH24MI'), 'planned', 'zone', 'Onda por região '||v_uf.uf||' ('||v_uf.n||' pedidos)')
    returning id into v_wave;
    update public.outbound_orders set wave_id=v_wave, status='picking'
      where company_id=p_company and status in ('confirmed','allocated') and wave_id is null and coalesce(ship_to_uf,'??')=v_uf.uf and deleted_at is null;
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.generate_shipping_waves(uuid) to authenticated;

-- ── RPC: IA — gargalos previstos → insights ─────────────────────────────────
create or replace function public.ssc_insights(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_backlog int; v_tasks int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and kind='bottleneck' and status='new' and title like 'Expedição%' and deleted_at is null;

  select count(*) into v_backlog from public.outbound_orders where company_id=p_company and status in ('confirmed','allocated','picking','packed') and deleted_at is null;
  select count(*) into v_tasks from public.warehouse_tasks where company_id=p_company and status in ('pending','assigned','in_progress') and deleted_at is null;
  if v_backlog >= 20 or v_tasks >= 30 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'Expedição: risco de gargalo',
      'Backlog de '||v_backlog||' pedidos e '||v_tasks||' tarefas pendentes na expedição.',
      'Reforçar equipe de separação/embalagem e liberar ondas.', 80);
    v_count := v_count + 1;
  end if;
  return v_count;
end;
$$;
grant execute on function public.ssc_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela ────────────────────────────
do $do$
declare t text; specs text[] := array['packaging_boxes','shipping_loads','shipping_load_items'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'shipping.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'shipping.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;
