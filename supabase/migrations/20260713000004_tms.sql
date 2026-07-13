-- 20260713000004_tms.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 04 — TMS (Transportation Management System)                        ║
-- ║  Transportadoras · frota · motoristas · tabelas de frete · embarques/CT-e ║
-- ║  · roteirização · tracking/ocorrências.                                   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.freight_modal    as enum ('road','air','sea','rail','courier','pipeline');
create type public.freight_incoterm as enum ('CIF','FOB','other');
create type public.shipment_status  as enum ('draft','planned','dispatched','in_transit','delivered','returned','canceled');
create type public.route_status     as enum ('planned','released','in_progress','completed','canceled');
create type public.tracking_event   as enum ('created','picked_up','in_transit','out_for_delivery','delivered','delivery_failed','returned','exception');

-- ── CARRIERS (transportadoras) ───────────────────────────────────────────────
create table public.carriers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, name text not null, legal_name text, document text,
  modal public.freight_modal not null default 'road',
  contact_name text, phone text, email text, notes text, rating numeric(3,1),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_carriers_doc on public.carriers (company_id, document) where document is not null and deleted_at is null;

-- ── VEHICLES (frota) ─────────────────────────────────────────────────────────
create table public.vehicles (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  carrier_id uuid references public.carriers(id) on delete set null,
  plate text not null, vehicle_type text, brand text, model text,
  max_weight_kg numeric(12,2), max_volume_m3 numeric(12,3), max_pallets integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_vehicles_plate on public.vehicles (company_id, lower(plate)) where deleted_at is null;
create index idx_vehicles_carrier on public.vehicles (carrier_id);

-- ── DRIVERS (motoristas) ─────────────────────────────────────────────────────
create table public.drivers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  carrier_id uuid references public.carriers(id) on delete set null,
  name text not null, document text, license_number text, license_category text, phone text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_drivers_carrier on public.drivers (carrier_id);

-- ── FREIGHT_RATES (tabelas de frete por faixa) ───────────────────────────────
create table public.freight_rates (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  carrier_id uuid references public.carriers(id) on delete cascade,
  origin_uf text, dest_uf text, origin_city text, dest_city text,
  weight_from_kg numeric(12,2) default 0, weight_to_kg numeric(12,2),
  price_per_kg numeric(12,4), price_fixed numeric(12,2), gris_percent numeric(6,3), advalorem_percent numeric(6,3),
  lead_time_days integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_freight_rates_carrier on public.freight_rates (carrier_id);
create index idx_freight_rates_route on public.freight_rates (origin_uf, dest_uf);

-- ── ROUTES + stops (roteirização) ────────────────────────────────────────────
create table public.routes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  carrier_id uuid references public.carriers(id) on delete set null,
  vehicle_id uuid references public.vehicles(id) on delete set null,
  driver_id uuid references public.drivers(id) on delete set null,
  code text, status public.route_status not null default 'planned',
  planned_date date, total_distance_km numeric(12,2), total_weight_kg numeric(14,3),
  started_at timestamptz, finished_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_routes_status on public.routes (company_id, status) where deleted_at is null;

-- ── SHIPMENTS (embarques / cargas / CT-e) ────────────────────────────────────
create table public.shipments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  carrier_id uuid references public.carriers(id) on delete set null,
  vehicle_id uuid references public.vehicles(id) on delete set null,
  driver_id uuid references public.drivers(id) on delete set null,
  route_id uuid references public.routes(id) on delete set null,
  code text, tracking_code text, cte_number text, status public.shipment_status not null default 'draft',
  incoterm public.freight_incoterm not null default 'CIF', modal public.freight_modal not null default 'road',
  origin_address text, dest_address text, dest_uf text, dest_city text,
  freight_value numeric(14,2), insurance_value numeric(14,2), cargo_value numeric(14,2),
  total_weight_kg numeric(14,3), total_volume_m3 numeric(14,3), volumes_count integer,
  dispatched_at timestamptz, estimated_delivery date, delivered_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_shipments_status on public.shipments (company_id, status) where deleted_at is null;
create index idx_shipments_carrier on public.shipments (carrier_id);
create index idx_shipments_route on public.shipments (route_id);

-- ── SHIPMENT_ITEMS (volumes/pedidos embarcados) ──────────────────────────────
create table public.shipment_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  shipment_id uuid not null references public.shipments(id) on delete cascade,
  package_id uuid references public.packages(id) on delete set null,
  route_stop_seq integer, reference_type text, reference_id uuid,
  weight_kg numeric(14,3), declared_value numeric(14,2),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_shipment_items_shipment on public.shipment_items (shipment_id);

-- ── SHIPMENT_EVENTS (tracking / ocorrências) ─────────────────────────────────
create table public.shipment_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  shipment_id uuid not null references public.shipments(id) on delete cascade,
  event_type public.tracking_event not null, description text,
  location_text text, latitude numeric(10,7), longitude numeric(10,7),
  occurred_at timestamptz not null default now(), is_exception boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_shipment_events_shipment on public.shipment_events (shipment_id, occurred_at desc);

do $do$
declare t text; specs text[] := array[
    'carriers','vehicles','drivers','freight_rates','routes','shipments','shipment_items','shipment_events'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'tms.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'tms.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on all tables in schema public to authenticated;
