-- 20260713000039_wms_enterprise.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  WMS ENTERPRISE (Vol 11) — nível SAP EWM / Manhattan / Blue Yonder.        ║
-- ║  Estende o WMS base (zonas/bins/saldos/tarefas/ondas).                     ║
-- ║  Slotting inteligente, putaway por IA, reabastecimento automático,        ║
-- ║  LMS (produtividade), sustentabilidade/ESG, congestão. Recurso 'wms'.     ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- ── SLOTTING_RECOMMENDATIONS (IA de posicionamento) ─────────────────────────
create table public.slotting_recommendations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid references public.products(id) on delete cascade,
  current_location_id uuid references public.storage_locations(id) on delete set null,
  suggested_location_id uuid references public.storage_locations(id) on delete set null,
  reason text, estimated_gain text, status text not null default 'open',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_slotting_recommendations_status on public.slotting_recommendations (company_id, status) where deleted_at is null;

-- ── LABOR_SHIFTS (LMS — produtividade de mão de obra) ───────────────────────
create table public.labor_shifts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  operator_id uuid references auth.users(id) on delete set null, operator_name text,
  shift_date date, hours numeric(6,2), lines_target integer, lines_done integer, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_labor_shifts_date on public.labor_shifts (company_id, shift_date);

-- ── WAREHOUSE_UTILITIES (sustentabilidade / ESG) ────────────────────────────
create table public.warehouse_utilities (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  utility_type text not null default 'energy',    -- energy, water, gas, waste, recycling
  value numeric(18,3), unit text, co2_kg numeric(18,3), period_month date default date_trunc('month', now())::date, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_warehouse_utilities_period on public.warehouse_utilities (company_id, period_month);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Putaway por IA: melhor posição livre (zona de armazenagem, endereçável)
create or replace function public.suggest_putaway(p_company uuid, p_product uuid default null)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_build_object('location_id', l.id, 'code', l.code, 'zone', z.name)
    from public.storage_locations l
    left join public.storage_zones z on z.id = l.zone_id
    where l.company_id = p_company and l.deleted_at is null and l.is_putawayable
      and l.status = 'available'
      and (z.zone_type is null or z.zone_type in ('storage','picking'))
    order by (z.zone_type = 'storage') desc, l.pick_sequence nulls last, l.code
    limit 1
  ), jsonb_build_object('location_id', null, 'message', 'Sem posição livre — cadastre bins no WMS.')) else '{}'::jsonb end;
$$;
grant execute on function public.suggest_putaway(uuid, uuid) to authenticated;

-- Slotting: produtos curva A com endereço fora da zona de picking → recomenda
create or replace function public.recommend_slotting(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_p record; v_loc uuid; v_loc_code text;
begin
  if not app.has_permission('wms.create', p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.slotting_recommendations set status='dismissed' where company_id=p_company and status='open' and deleted_at is null;

  for v_p in
    select p.id, p.name, p.default_location_id from public.products p
    where p.company_id=p_company and p.abc_class='A' and p.active and p.deleted_at is null
    limit 50
  loop
    -- já está numa posição de picking?
    if v_p.default_location_id is not null and exists (
      select 1 from public.storage_locations l join public.storage_zones z on z.id=l.zone_id
      where l.id=v_p.default_location_id and z.zone_type='picking') then
      continue;
    end if;
    -- sugere uma posição de picking livre
    select l.id, l.code into v_loc, v_loc_code from public.storage_locations l join public.storage_zones z on z.id=l.zone_id
      where l.company_id=p_company and l.deleted_at is null and z.zone_type='picking' and l.is_pickable and l.status='available'
      order by l.pick_sequence nulls last limit 1;
    if v_loc is not null then
      insert into public.slotting_recommendations (tenant_id, company_id, product_id, current_location_id, suggested_location_id, reason, estimated_gain)
      values (v_tenant, p_company, v_p.id, v_p.default_location_id, v_loc,
        'Produto curva A deveria estar em zona de picking ('||v_loc_code||').', 'Reduz caminhada e tempo de separação.');
      v_count := v_count + 1;
    end if;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.recommend_slotting(uuid) to authenticated;

-- Reabastecimento: cria tarefas quando picking abaixo do mínimo e há reserva
create or replace function public.generate_replenishment_tasks(p_company uuid, p_warehouse uuid default null)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_p record; v_from uuid; v_to uuid;
begin
  if not app.has_permission('wms.create', p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;

  for v_p in
    select p.id, p.min_stock, p.name from public.products p
    where p.company_id=p_company and p.active and p.deleted_at is null and coalesce(p.min_stock,0) > 0
    limit 100
  loop
    -- saldo em posições de picking
    if (select coalesce(sum(b.quantity),0) from public.stock_balances b
        join public.storage_locations l on l.id=b.location_id
        join public.storage_zones z on z.id=l.zone_id
        where b.product_id=v_p.id and z.zone_type='picking' and b.deleted_at is null) < v_p.min_stock then
      -- origem: posição não-picking com saldo
      select b.location_id into v_from from public.stock_balances b
        join public.storage_locations l on l.id=b.location_id
        join public.storage_zones z on z.id=l.zone_id
        where b.product_id=v_p.id and z.zone_type <> 'picking' and b.quantity>0 and b.deleted_at is null limit 1;
      -- destino: posição de picking
      select l.id into v_to from public.storage_locations l join public.storage_zones z on z.id=l.zone_id
        where l.company_id=p_company and z.zone_type='picking' and l.is_pickable and l.deleted_at is null limit 1;
      if v_from is not null and v_to is not null and not exists (
        select 1 from public.warehouse_tasks t where t.product_id=v_p.id and t.task_type='replenish' and t.status in ('pending','assigned','in_progress') and t.deleted_at is null) then
        insert into public.warehouse_tasks (tenant_id, company_id, warehouse_id, task_type, status, product_id, from_location_id, to_location_id, quantity, priority)
        values (v_tenant, p_company, coalesce(p_warehouse,(select warehouse_id from public.storage_locations where id=v_to)), 'replenish', 'pending', v_p.id, v_from, v_to, v_p.min_stock, 3);
        v_count := v_count + 1;
      end if;
    end if;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.generate_replenishment_tasks(uuid, uuid) to authenticated;

-- Produtividade por operador (das tarefas de armazém)
create or replace function public.operator_productivity(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(jsonb_build_object('operator', coalesce(pr.full_name,'(operador)'), 'tasks', n, 'done', done) order by done desc)
    from (
      select assignee_id, count(*) n, count(*) filter (where status='done') done
      from public.warehouse_tasks where company_id=p_company and assignee_id is not null and deleted_at is null
      group by assignee_id
    ) x left join public.profiles pr on pr.user_id = x.assignee_id
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.operator_productivity(uuid) to authenticated;

-- ESG do armazém (energia/água/resíduos/CO2)
create or replace function public.warehouse_esg(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'energy', (select coalesce(sum(value),0) from public.warehouse_utilities where company_id=p_company and utility_type='energy' and deleted_at is null),
    'water', (select coalesce(sum(value),0) from public.warehouse_utilities where company_id=p_company and utility_type='water' and deleted_at is null),
    'waste', (select coalesce(sum(value),0) from public.warehouse_utilities where company_id=p_company and utility_type='waste' and deleted_at is null),
    'co2_kg', (select coalesce(sum(co2_kg),0) from public.warehouse_utilities where company_id=p_company and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.warehouse_esg(uuid) to authenticated;

-- Dashboard WMS Enterprise (ocupação, tarefas, acuracidade, congestão)
create or replace function public.wms_enterprise_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'locations_total', (select count(*) from public.storage_locations where company_id=p_company and deleted_at is null),
    'locations_used', (select count(distinct location_id) from public.stock_balances where company_id=p_company and location_id is not null and quantity>0 and deleted_at is null),
    'tasks_pending', (select count(*) from public.warehouse_tasks where company_id=p_company and status in ('pending','assigned','in_progress') and deleted_at is null),
    'tasks_done_today', (select count(*) from public.warehouse_tasks where company_id=p_company and status='done' and finished_at::date=now()::date and deleted_at is null),
    'waves_open', (select count(*) from public.pick_waves where company_id=p_company and status in ('planned','released','picking') and deleted_at is null),
    'slotting_open', (select count(*) from public.slotting_recommendations where company_id=p_company and status='open' and deleted_at is null),
    'inbound_open', (select count(*) from public.inbound_receipts where company_id=p_company and status in ('expected','arrived','receiving') and deleted_at is null),
    'aisle_congestion', (select coalesce(jsonb_agg(jsonb_build_object('zone', zn, 'tasks', c) order by c desc), '[]'::jsonb) from (
        select coalesce(z.name,'(sem zona)') zn, count(*) c from public.warehouse_tasks t
        left join public.storage_locations l on l.id=t.to_location_id
        left join public.storage_zones z on z.id=l.zone_id
        where t.company_id=p_company and t.status in ('pending','assigned','in_progress') and t.deleted_at is null
        group by z.name order by count(*) desc limit 5) g)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.wms_enterprise_dashboard(uuid) to authenticated;

-- IA WMS: slotting pendente / congestão → insights
create or replace function public.wms_insights(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_slot int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and kind='bottleneck' and status='new' and title like 'Armazém%' and deleted_at is null;
  perform public.recommend_slotting(p_company);
  select count(*) into v_slot from public.slotting_recommendations where company_id=p_company and status='open' and deleted_at is null;
  if v_slot > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'Armazém: '||v_slot||' oportunidade(s) de slotting', v_slot||' produto(s) curva A fora da zona de picking.', 'Reposicionar para reduzir tempo de separação.', 80);
    v_count := v_count + 1;
  end if;
  return v_count;
end;
$$;
grant execute on function public.wms_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela ────────────────────────────
do $do$
declare t text; specs text[] := array['slotting_recommendations','labor_shifts','warehouse_utilities'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'wms.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'wms.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;
