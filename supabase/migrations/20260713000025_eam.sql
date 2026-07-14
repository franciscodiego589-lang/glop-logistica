-- 20260713000025_eam.sql
-- VOLUME 10 · EAM / CMMS — Gestão de Ativos e Manutenção.
-- Ativos (com hierarquia) → planos preventivos → ordens de serviço → peças/falhas/leituras.
-- Reusa recurso RBAC 'production' (roadmap: recurso 'maintenance' dedicado).
-- grant POR-TABELA (nunca "on all tables" — reexpõe MVs sem RLS).

-- ── ENUMS ────────────────────────────────────────────────────────────────────
create type public.asset_status    as enum ('operational','standby','down','maintenance','retired');
create type public.wo_type         as enum ('preventive','corrective','predictive','detective','emergency','calibration','inspection','lubrication');
create type public.wo_status       as enum ('open','planned','assigned','in_progress','on_hold','done','canceled');
create type public.wo_priority     as enum ('low','medium','high','critical');
create type public.maint_trigger   as enum ('calendar','hours','production','cycles','km','condition');
create type public.failure_severity as enum ('low','medium','high','critical');

-- ── ASSETS (ativos, hierárquicos) ───────────────────────────────────────────
create table public.assets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  parent_id uuid references public.assets(id) on delete set null,       -- árvore: planta→área→linha→equipamento→componente
  equipment_id uuid references public.equipment(id) on delete set null,  -- liga ao equipamento do MES
  warehouse_id uuid references public.warehouses(id) on delete set null,
  code text, tag text, name text not null, asset_type text, criticality text default 'medium',
  status public.asset_status not null default 'operational',
  manufacturer text, model text, serial_number text, year integer,
  location text, cost_center text, responsible text,
  install_date date, warranty_until date, useful_life_years integer,
  acquisition_value numeric(16,2), residual_value numeric(16,2), manual_url text, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_assets_parent on public.assets (parent_id);
create index idx_assets_equipment on public.assets (equipment_id);
create unique index uq_assets_code on public.assets (company_id, lower(code)) where code is not null and deleted_at is null;

-- ── MAINTENANCE_PLANS (planos preventivos) ──────────────────────────────────
create table public.maintenance_plans (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  asset_id uuid references public.assets(id) on delete cascade,
  code text, name text not null, wo_type public.wo_type not null default 'preventive',
  trigger public.maint_trigger not null default 'calendar', interval_value numeric(12,2),
  task text, checklist jsonb not null default '[]'::jsonb,
  responsible text, last_done date, next_due date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_maint_plans_asset on public.maintenance_plans (asset_id);
create index idx_maint_plans_due on public.maintenance_plans (company_id, next_due) where deleted_at is null and active;

-- ── WORK_ORDERS (ordens de serviço) ─────────────────────────────────────────
create table public.work_orders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  asset_id uuid references public.assets(id) on delete set null,
  plan_id uuid references public.maintenance_plans(id) on delete set null,
  code text, wo_type public.wo_type not null default 'corrective',
  status public.wo_status not null default 'open', priority public.wo_priority not null default 'medium',
  description text, checklist jsonb not null default '[]'::jsonb,
  requested_by text, assignee text,
  opened_at timestamptz not null default now(), due_date date, started_at timestamptz, completed_at timestamptz,
  downtime_minutes numeric(12,2), labor_hours numeric(12,2), cost numeric(16,2), notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_work_orders_status on public.work_orders (company_id, status) where deleted_at is null;
create index idx_work_orders_asset on public.work_orders (asset_id);

-- ── WO_PARTS (peças consumidas na OS) ───────────────────────────────────────
create table public.wo_parts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  work_order_id uuid not null references public.work_orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  quantity numeric(18,3) not null default 1, unit_cost numeric(14,4), total numeric(16,2),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_wo_parts_wo on public.wo_parts (work_order_id);

-- ── ASSET_FAILURES (falhas + RCA) ───────────────────────────────────────────
create table public.asset_failures (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  asset_id uuid references public.assets(id) on delete set null,
  work_order_id uuid references public.work_orders(id) on delete set null,
  failure_type text, severity public.failure_severity not null default 'medium',
  cause text, root_cause text, rca_method text, downtime_minutes numeric(12,2),
  occurred_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_asset_failures_asset on public.asset_failures (asset_id, occurred_at desc);

-- ── ASSET_READINGS (leituras preditivas / IIoT) ────────────────────────────
create table public.asset_readings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  asset_id uuid references public.assets(id) on delete cascade,
  parameter text not null, value numeric(18,4) not null, unit text,
  min_limit numeric(18,4), max_limit numeric(18,4),
  out_of_range boolean generated always as (
    (min_limit is not null and value < min_limit) or (max_limit is not null and value > max_limit)
  ) stored,
  recorded_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_asset_readings_asset on public.asset_readings (asset_id, recorded_at desc);

-- ── RLS + triggers (recurso 'production') ───────────────────────────────────
do $do$
declare t text; specs text[] := array['assets','maintenance_plans','work_orders','wo_parts','asset_failures','asset_readings'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'production.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'production.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on
  public.assets, public.maintenance_plans, public.work_orders,
  public.wo_parts, public.asset_failures, public.asset_readings to authenticated;

-- ── RPC: gera OS preventivas dos planos vencidos ────────────────────────────
create or replace function public.generate_preventive_wos(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_p record; v_count int := 0;
begin
  if not app.has_permission('production.create', p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id = p_company;
  for v_p in select * from public.maintenance_plans
            where company_id = p_company and active and deleted_at is null and next_due is not null and next_due <= current_date
  loop
    if not exists (select 1 from public.work_orders
      where plan_id = v_p.id and status in ('open','planned','assigned','in_progress','on_hold') and deleted_at is null) then
      insert into public.work_orders (tenant_id, company_id, asset_id, plan_id, wo_type, status, priority, description, checklist, due_date)
      values (v_tenant, p_company, v_p.asset_id, v_p.id, v_p.wo_type, 'open', 'medium',
              coalesce(v_p.name,'Preventiva')||coalesce(' — '||v_p.task,''), v_p.checklist, v_p.next_due);
      v_count := v_count + 1;
    end if;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.generate_preventive_wos(uuid) to authenticated;

-- ── RPC: conclui OS — fecha, normaliza ativo e reprograma o plano ───────────
create or replace function public.complete_work_order(p_wo uuid, p_downtime numeric default null, p_cost numeric default null, p_note text default null)
returns void
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_asset uuid; v_plan uuid; v_iv numeric;
begin
  select company_id, asset_id, plan_id into v_company, v_asset, v_plan from public.work_orders where id = p_wo;
  if v_company is null then raise exception 'WO % not found', p_wo; end if;
  if not app.has_permission('production.update', v_company) then raise exception 'forbidden'; end if;

  update public.work_orders
    set status = 'done', completed_at = now(),
        downtime_minutes = coalesce(p_downtime, downtime_minutes),
        cost = coalesce(p_cost, cost), notes = coalesce(p_note, notes)
  where id = p_wo;

  if v_asset is not null then update public.assets set status = 'operational' where id = v_asset and status in ('down','maintenance'); end if;

  if v_plan is not null then
    select coalesce(interval_value, 30) into v_iv from public.maintenance_plans where id = v_plan;
    update public.maintenance_plans
      set last_done = current_date, next_due = current_date + (v_iv || ' days')::interval
    where id = v_plan;
  end if;
end;
$$;
grant execute on function public.complete_work_order(uuid,numeric,numeric,text) to authenticated;

-- ── RPC: KPIs de manutenção ─────────────────────────────────────────────────
create or replace function public.maintenance_kpis(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select jsonb_build_object(
    'assets',          (select count(*) from public.assets where company_id=p_company and deleted_at is null),
    'assets_down',     (select count(*) from public.assets where company_id=p_company and status in ('down','maintenance') and deleted_at is null),
    'open_wos',        (select count(*) from public.work_orders where company_id=p_company and status not in ('done','canceled') and deleted_at is null),
    'overdue_wos',     (select count(*) from public.work_orders where company_id=p_company and status not in ('done','canceled') and due_date < current_date and deleted_at is null),
    'preventive_wos',  (select count(*) from public.work_orders where company_id=p_company and wo_type='preventive' and deleted_at is null),
    'corrective_wos',  (select count(*) from public.work_orders where company_id=p_company and wo_type='corrective' and deleted_at is null),
    'mttr_minutes',    (select coalesce(round(avg(downtime_minutes),1),0) from public.work_orders where company_id=p_company and status='done' and downtime_minutes is not null and deleted_at is null),
    'failures',        (select count(*) from public.asset_failures where company_id=p_company and deleted_at is null),
    'maintenance_cost',(select coalesce(sum(cost),0) from public.work_orders where company_id=p_company and deleted_at is null)
  ) where app.can_access_company(p_company);
$$;
grant execute on function public.maintenance_kpis(uuid) to authenticated;
