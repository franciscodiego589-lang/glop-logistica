-- 20260713000030_dispatch_tower.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  TORRE DE CONTROLE DE POSTAGENS (Correios + Transportadoras)              ║
-- ║  Monitora o ciclo etiqueta→manifesto→coleta→postagem→1ª movimentação.     ║
-- ║  Motor de verificação automática (detect_dispatch_issues) + SLA + IA.     ║
-- ║  Reusa outbound_orders, shipments, carriers. Recurso RBAC 'shipping'.     ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.dispatch_stage as enum (
  'pending','separated','checked','packed','weighed','cubed','labeled','manifested',
  'awaiting_pickup','picked_up','posted','first_movement','in_transit','delivered',
  'finalized','returned','canceled','error');
create type public.dispatch_issue_status as enum ('open','resolved','dismissed');

-- ── DISPATCHES (postagem por pedido) ────────────────────────────────────────
create table public.dispatches (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  outbound_order_id uuid references public.outbound_orders(id) on delete set null,
  shipment_id uuid references public.shipments(id) on delete set null,
  carrier_id uuid references public.carriers(id) on delete set null,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  code text, stage public.dispatch_stage not null default 'pending',
  service text, tracking_code text, invoice_number text,
  dest_cep text, dest_uf text, dest_city text, dest_address text,
  weight_g numeric(14,3), cube_m3 numeric(14,4), order_value numeric(18,2),
  sla_hours integer, priority integer not null default 5,
  label_created_at timestamptz, manifested_at timestamptz, pickup_at timestamptz,
  posted_at timestamptz, first_movement_at timestamptz, delivered_at timestamptz,
  operator_id uuid references auth.users(id), notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_dispatches_stage on public.dispatches (company_id, stage) where deleted_at is null;
create index idx_dispatches_carrier on public.dispatches (carrier_id);
create index idx_dispatches_posted on public.dispatches (company_id, posted_at);

-- ── DISPATCH_EVENTS (histórico de estágio/movimentação) ─────────────────────
create table public.dispatch_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  dispatch_id uuid not null references public.dispatches(id) on delete cascade,
  stage public.dispatch_stage, event_type text, description text, location_text text,
  occurred_at timestamptz not null default now(), source text default 'system',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_dispatch_events_dispatch on public.dispatch_events (dispatch_id, occurred_at desc);

-- ── DISPATCH_ISSUES (problemas detectados automaticamente) ──────────────────
create table public.dispatch_issues (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  dispatch_id uuid references public.dispatches(id) on delete cascade,
  issue_type text not null, severity public.event_severity not null default 'warning',
  status public.dispatch_issue_status not null default 'open',
  description text, suggestion text, detected_at timestamptz not null default now(),
  resolved_by uuid references auth.users(id), resolved_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_dispatch_issues_status on public.dispatch_issues (company_id, status) where deleted_at is null;
create index idx_dispatch_issues_dispatch on public.dispatch_issues (dispatch_id);

-- ── RPC: gera postagens a partir dos pedidos de saída (embarcados/confirmados) ─
create or replace function public.generate_dispatches(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_o record;
begin
  if not app.has_permission('shipping.create', p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  for v_o in
    select o.* from public.outbound_orders o
    where o.company_id=p_company and o.deleted_at is null
      and o.status in ('confirmed','allocated','picking','packed','shipped')
      and not exists (select 1 from public.dispatches d where d.outbound_order_id=o.id and d.deleted_at is null)
  loop
    insert into public.dispatches (tenant_id, company_id, branch_id, outbound_order_id, warehouse_id,
       stage, invoice_number, dest_cep, dest_uf, dest_city, order_value,
       label_created_at, posted_at)
    values (v_tenant, p_company, v_o.branch_id, v_o.id, v_o.warehouse_id,
       case when v_o.status='shipped' then 'posted' else 'labeled' end,
       null, v_o.metadata->>'ship_to_cep', v_o.ship_to_uf, v_o.ship_to_city, v_o.total,
       now(), case when v_o.status='shipped' then coalesce(v_o.shipped_at, now()) end);
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.generate_dispatches(uuid) to authenticated;

-- ── RPC-MOTOR: verificação automática de inconsistências ────────────────────
create or replace function public.detect_dispatch_issues(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_d record; v_type text; v_sev public.event_severity; v_desc text; v_sug text;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  -- limpa as issues abertas auto-detectadas para regenerar
  update public.dispatch_issues set status='dismissed'
    where company_id=p_company and status='open' and deleted_at is null;

  for v_d in
    select * from public.dispatches
    where company_id=p_company and deleted_at is null and stage not in ('delivered','finalized','canceled')
  loop
    v_type := null;
    if v_d.posted_at is not null and v_d.first_movement_at is null and v_d.posted_at < now() - interval '24 hours' then
      v_type := 'no_first_movement'; v_sev := 'critical';
      v_desc := 'Postado há mais de 24h sem primeira movimentação (possível extravio).';
      v_sug := 'Contatar a transportadora/agência e verificar o rastreio.';
    elsif v_d.stage in ('labeled','manifested','awaiting_pickup') and v_d.posted_at is null and coalesce(v_d.label_created_at, v_d.created_at) < now() - interval '6 hours' then
      v_type := 'awaiting_post_delay'; v_sev := 'warning';
      v_desc := 'Etiqueta criada há mais de 6h e ainda não postada.';
      v_sug := 'Priorizar a postagem ou solicitar coleta.';
    elsif v_d.stage in ('labeled','manifested','awaiting_pickup','posted') and v_d.weight_g is null then
      v_type := 'no_weight'; v_sev := 'warning';
      v_desc := 'Etiqueta sem peso informado.'; v_sug := 'Pesar o volume e atualizar.';
    elsif v_d.dest_cep is null or length(regexp_replace(coalesce(v_d.dest_cep,''),'\D','','g')) <> 8 then
      v_type := 'invalid_cep'; v_sev := 'critical';
      v_desc := 'CEP inválido ou ausente.'; v_sug := 'Corrigir o CEP do destinatário.';
    elsif v_d.stage='posted' and v_d.tracking_code is null then
      v_type := 'no_tracking'; v_sev := 'warning';
      v_desc := 'Objeto postado sem código de rastreio vinculado.'; v_sug := 'Vincular o código de rastreio.';
    end if;

    if v_type is not null then
      insert into public.dispatch_issues (tenant_id, company_id, branch_id, dispatch_id, issue_type, severity, status, description, suggestion)
      values (v_tenant, p_company, v_d.branch_id, v_d.id, v_type, v_sev, 'open', v_desc, v_sug);
      v_count := v_count + 1;
    end if;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.detect_dispatch_issues(uuid) to authenticated;

-- ── RPC: dashboard da torre de postagens ────────────────────────────────────
create or replace function public.dispatch_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'awaiting_post', (select count(*) from public.dispatches where company_id=p_company and posted_at is null and stage not in ('canceled','returned') and deleted_at is null),
    'posted_today',  (select count(*) from public.dispatches where company_id=p_company and posted_at::date=now()::date and deleted_at is null),
    'no_movement',   (select count(*) from public.dispatches where company_id=p_company and posted_at is not null and first_movement_at is null and deleted_at is null),
    'delivered',     (select count(*) from public.dispatches where company_id=p_company and stage='delivered' and deleted_at is null),
    'returned',      (select count(*) from public.dispatches where company_id=p_company and stage='returned' and deleted_at is null),
    'open_issues',   (select count(*) from public.dispatch_issues where company_id=p_company and status='open' and deleted_at is null),
    'critical_issues',(select count(*) from public.dispatch_issues where company_id=p_company and status='open' and severity='critical' and deleted_at is null),
    'total_value',   (select coalesce(sum(order_value),0) from public.dispatches where company_id=p_company and posted_at::date=now()::date and deleted_at is null),
    'total_weight_kg',(select round(coalesce(sum(weight_g),0)/1000.0,2) from public.dispatches where company_id=p_company and posted_at::date=now()::date and deleted_at is null),
    'avg_post_hours',(select round(avg(extract(epoch from (posted_at - label_created_at))/3600),1) from public.dispatches where company_id=p_company and posted_at is not null and label_created_at is not null and deleted_at is null),
    'avg_delivery_hours',(select round(avg(extract(epoch from (delivered_at - posted_at))/3600),1) from public.dispatches where company_id=p_company and delivered_at is not null and posted_at is not null and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.dispatch_dashboard(uuid) to authenticated;

-- ── RPC: IA — transportadoras/rotas abaixo do SLA → insights ────────────────
create or replace function public.dispatch_insights(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_r record;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and kind='sla_risk' and status='new' and deleted_at is null;

  -- objetos parados sem movimentação (agregado)
  for v_r in
    select coalesce(dest_uf,'?') uf, count(*) c from public.dispatches
    where company_id=p_company and posted_at is not null and first_movement_at is null
      and posted_at < now()-interval '24 hours' and deleted_at is null group by dest_uf having count(*) >= 1
  loop
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'critical', 'Objetos parados em '||v_r.uf,
      v_r.c||' objeto(s) postado(s) para '||v_r.uf||' sem 1ª movimentação há +24h.',
      'Acionar transportadora/Correios e considerar redistribuição de carga.', 85);
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.dispatch_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'shipping') ───────
do $do$
declare t text; specs text[] := array['dispatches','dispatch_events','dispatch_issues'];
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
