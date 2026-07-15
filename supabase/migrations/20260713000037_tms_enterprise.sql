-- 20260713000037_tms_enterprise.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  TMS ENTERPRISE (Vol 9) — nível SAP TM / Oracle OTM / Manhattan.          ║
-- ║  Estende o TMS base (carriers/vehicles/drivers/routes/shipments).         ║
-- ║  Viagens + custos + combustível + manutenção de frota + procurement de    ║
-- ║  fretes (cotação/leilão) + contratos + pegada de carbono. Recurso 'tms'.  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.trip_status        as enum ('planned','in_progress','completed','canceled');
create type public.maintenance_type   as enum ('preventive','corrective','inspection','tire','oil');
create type public.freight_quote_status as enum ('open','quoted','awarded','canceled');

-- ── TRIPS (viagens) ─────────────────────────────────────────────────────────
create table public.trips (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  carrier_id uuid references public.carriers(id) on delete set null,
  vehicle_id uuid references public.vehicles(id) on delete set null,
  driver_id uuid references public.drivers(id) on delete set null,
  route_id uuid references public.routes(id) on delete set null,
  code text, status public.trip_status not null default 'planned', modal public.freight_modal not null default 'road',
  origin text, destination text, distance_km numeric(12,2),
  planned_start date, planned_end date, started_at timestamptz, finished_at timestamptz,
  total_cost numeric(16,2), cost_per_km numeric(12,4), notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_trips_status on public.trips (company_id, status) where deleted_at is null;

-- ── TRIP_EXPENSES (custos da viagem) ────────────────────────────────────────
create table public.trip_expenses (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  trip_id uuid not null references public.trips(id) on delete cascade,
  expense_type text not null default 'fuel', amount numeric(14,2) not null default 0, notes text, occurred_at date default current_date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_trip_expenses_trip on public.trip_expenses (trip_id);

-- ── FUEL_LOGS (abastecimentos) ──────────────────────────────────────────────
create table public.fuel_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  vehicle_id uuid references public.vehicles(id) on delete set null, trip_id uuid references public.trips(id) on delete set null,
  liters numeric(12,3), cost numeric(14,2), odometer numeric(14,1), fuel_type text, filled_at date default current_date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_fuel_logs_vehicle on public.fuel_logs (vehicle_id);

-- ── FLEET_MAINTENANCE (manutenção da frota) ─────────────────────────────────
create table public.fleet_maintenance (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  vehicle_id uuid references public.vehicles(id) on delete cascade,
  maintenance_type public.maintenance_type not null default 'preventive', description text,
  cost numeric(14,2), odometer numeric(14,1), service_date date, next_date date, status text not null default 'done',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_fleet_maintenance_vehicle on public.fleet_maintenance (vehicle_id);
create index idx_fleet_maintenance_next on public.fleet_maintenance (company_id, next_date) where deleted_at is null;

-- ── FREIGHT_QUOTE_REQUESTS + BIDS (procurement / leilão de fretes) ──────────
create table public.freight_quote_requests (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, origin_uf text, dest_uf text, weight_g numeric(14,3), cube_m3 numeric(14,4),
  deadline date, status public.freight_quote_status not null default 'open', awarded_bid_id uuid, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_freight_quote_requests_status on public.freight_quote_requests (company_id, status) where deleted_at is null;

create table public.freight_quote_bids (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  request_id uuid not null references public.freight_quote_requests(id) on delete cascade,
  carrier_id uuid references public.carriers(id) on delete set null,
  price numeric(14,2), sla_days integer, is_winner boolean not null default false, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_freight_quote_bids_request on public.freight_quote_bids (request_id);

-- ── FREIGHT_CONTRACTS (contratos com transportadoras) ───────────────────────
create table public.freight_contracts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  carrier_id uuid references public.carriers(id) on delete set null,
  code text, valid_from date, valid_to date, sla_days integer, penalty_percent numeric(8,3),
  adjustment_index text, status text not null default 'active', notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_freight_contracts_valid on public.freight_contracts (company_id, valid_to) where deleted_at is null;

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Custo consolidado da viagem (despesas + combustível) e custo/km
create or replace function public.trip_cost(p_trip uuid)
returns jsonb
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_exp numeric; v_fuel numeric; v_dist numeric; v_total numeric; v_cpk numeric;
begin
  select company_id, distance_km into v_company, v_dist from public.trips where id=p_trip;
  if v_company is null then raise exception 'viagem não encontrada'; end if;
  if not app.can_access_company(v_company) then raise exception 'forbidden'; end if;
  select coalesce(sum(amount),0) into v_exp from public.trip_expenses where trip_id=p_trip and deleted_at is null;
  select coalesce(sum(cost),0) into v_fuel from public.fuel_logs where trip_id=p_trip and deleted_at is null;
  v_total := v_exp + v_fuel;
  v_cpk := case when coalesce(v_dist,0) > 0 then round(v_total/v_dist,4) else null end;
  update public.trips set total_cost=v_total, cost_per_km=v_cpk where id=p_trip;
  return jsonb_build_object('total_cost', v_total, 'expenses', v_exp, 'fuel', v_fuel, 'distance_km', v_dist, 'cost_per_km', v_cpk);
end;
$$;
grant execute on function public.trip_cost(uuid) to authenticated;

-- Pegada de carbono (kg CO2) por modal, a partir das viagens
create or replace function public.compute_carbon_footprint(p_company uuid, p_days integer default 30)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then (
    select jsonb_build_object(
      'total_km', coalesce(sum(distance_km),0),
      'total_co2_kg', round(coalesce(sum(distance_km * case modal when 'road' then 0.12 when 'air' then 0.50 when 'sea' then 0.02 when 'rail' then 0.03 else 0.12 end),0),1),
      'by_modal', coalesce((select jsonb_object_agg(modal, km) from (select modal::text, round(sum(distance_km),0) km from public.trips where company_id=p_company and deleted_at is null and coalesce(planned_start, created_at::date) > now()::date - p_days group by modal) m), '{}'::jsonb)
    ) from public.trips where company_id=p_company and deleted_at is null and coalesce(planned_start, created_at::date) > now()::date - p_days
  ) else '{}'::jsonb end;
$$;
grant execute on function public.compute_carbon_footprint(uuid, integer) to authenticated;

-- Adjudicar cotação de frete (escolhe o lance vencedor)
create or replace function public.award_freight_quote(p_request uuid, p_bid uuid)
returns void
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid;
begin
  select company_id into v_company from public.freight_quote_requests where id=p_request;
  if v_company is null then raise exception 'cotação não encontrada'; end if;
  if not app.has_permission('tms.update', v_company) then raise exception 'forbidden'; end if;
  update public.freight_quote_bids set is_winner=false where request_id=p_request;
  update public.freight_quote_bids set is_winner=true where id=p_bid and request_id=p_request;
  update public.freight_quote_requests set status='awarded', awarded_bid_id=p_bid where id=p_request;
end;
$$;
grant execute on function public.award_freight_quote(uuid, uuid) to authenticated;

-- Dashboard do TMS Enterprise
create or replace function public.tms_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'trips_active', (select count(*) from public.trips where company_id=p_company and status='in_progress' and deleted_at is null),
    'trips_planned', (select count(*) from public.trips where company_id=p_company and status='planned' and deleted_at is null),
    'trips_completed_month', (select count(*) from public.trips where company_id=p_company and status='completed' and finished_at >= date_trunc('month',now()) and deleted_at is null),
    'vehicles', (select count(*) from public.vehicles where company_id=p_company and deleted_at is null),
    'drivers', (select count(*) from public.drivers where company_id=p_company and deleted_at is null),
    'trip_cost_month', (select coalesce(sum(total_cost),0) from public.trips where company_id=p_company and coalesce(finished_at, planned_start) >= date_trunc('month',now()) and deleted_at is null),
    'fuel_cost_month', (select coalesce(sum(cost),0) from public.fuel_logs where company_id=p_company and filled_at >= date_trunc('month',now())::date and deleted_at is null),
    'maintenance_due', (select count(*) from public.fleet_maintenance where company_id=p_company and next_date <= now()::date + 7 and deleted_at is null),
    'contracts_expiring', (select count(*) from public.freight_contracts where company_id=p_company and valid_to <= now()::date + 30 and status='active' and deleted_at is null),
    'open_quotes', (select count(*) from public.freight_quote_requests where company_id=p_company and status='open' and deleted_at is null),
    'avg_cost_per_km', (select round(avg(cost_per_km),2) from public.trips where company_id=p_company and cost_per_km is not null and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.tms_dashboard(uuid) to authenticated;

-- IA: manutenção vencendo / contratos a renovar → insights
create or replace function public.tms_insights(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_maint int; v_contr int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and kind='supplier_risk' and status='new' and title like 'Frota%' and deleted_at is null;

  select count(*) into v_maint from public.fleet_maintenance where company_id=p_company and next_date <= now()::date + 7 and deleted_at is null;
  if v_maint > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'supplier_risk', 'warning', 'Frota: manutenção vencendo', v_maint||' veículo(s) com manutenção prevista nos próximos 7 dias.', 'Agendar manutenção preventiva.', 85);
    v_count := v_count + 1;
  end if;
  select count(*) into v_contr from public.freight_contracts where company_id=p_company and valid_to <= now()::date + 30 and status='active' and deleted_at is null;
  if v_contr > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'supplier_risk', 'warning', 'Frota: contratos a renovar', v_contr||' contrato(s) de transporte vencem em 30 dias.', 'Renegociar/renovar contratos.', 82);
    v_count := v_count + 1;
  end if;
  return v_count;
end;
$$;
grant execute on function public.tms_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela ────────────────────────────
do $do$
declare t text; specs text[] := array['trips','trip_expenses','fuel_logs','fleet_maintenance','freight_quote_requests','freight_quote_bids','freight_contracts'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'tms.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'tms.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;
