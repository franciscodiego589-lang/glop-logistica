-- 20260713000005_yms.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 05 — YMS (Yard Management System) — Pátio & Docas                  ║
-- ║  Docas · agendamento sem sobreposição (gist) · pátio/vagas · visitas.     ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.dock_type          as enum ('inbound','outbound','both');
create type public.dock_status        as enum ('available','occupied','blocked','maintenance');
create type public.appointment_status as enum ('scheduled','confirmed','arrived','in_service','completed','no_show','canceled');
create type public.yard_visit_status  as enum ('at_gate','in_yard','at_dock','departed','canceled');

-- ── DOCKS (docas) ────────────────────────────────────────────────────────────
create table public.docks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid not null references public.warehouses(id) on delete cascade,
  code text not null, name text, dock_type public.dock_type not null default 'both',
  status public.dock_status not null default 'available',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_docks_code on public.docks (warehouse_id, lower(code)) where deleted_at is null;

-- ── DOCK_APPOINTMENTS (agendamento; sem sobreposição por doca) ───────────────
create table public.dock_appointments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  dock_id uuid not null references public.docks(id) on delete cascade,
  carrier_id uuid references public.carriers(id) on delete set null,
  shipment_id uuid references public.shipments(id) on delete set null,
  receipt_id uuid references public.inbound_receipts(id) on delete set null,
  code text, direction public.dock_type not null default 'inbound',
  status public.appointment_status not null default 'scheduled',
  vehicle_plate text, driver_name text,
  scheduled_start timestamptz not null, scheduled_end timestamptz not null,
  arrived_at timestamptz, started_at timestamptz, finished_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  constraint dock_appt_time_ck check (scheduled_end > scheduled_start)
);
create index idx_dock_appointments_dock on public.dock_appointments (dock_id, scheduled_start);
-- impede duas janelas ativas na mesma doca se sobreporem
alter table public.dock_appointments
  add constraint dock_appt_no_overlap exclude using gist (
    dock_id with =, tstzrange(scheduled_start, scheduled_end) with &&
  ) where (deleted_at is null and status not in ('canceled','no_show'));

-- ── YARD_ZONES (vagas/áreas do pátio) ────────────────────────────────────────
create table public.yard_zones (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid references public.warehouses(id) on delete cascade,
  code text not null, name text, capacity integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_yard_zones_warehouse on public.yard_zones (warehouse_id);

-- ── YARD_VISITS (veículos no pátio / fila) ───────────────────────────────────
create table public.yard_visits (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  appointment_id uuid references public.dock_appointments(id) on delete set null,
  yard_zone_id uuid references public.yard_zones(id) on delete set null,
  dock_id uuid references public.docks(id) on delete set null,
  carrier_id uuid references public.carriers(id) on delete set null,
  status public.yard_visit_status not null default 'at_gate',
  vehicle_plate text, driver_name text, driver_document text,
  gate_in_at timestamptz, dock_in_at timestamptz, gate_out_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_yard_visits_status on public.yard_visits (company_id, status) where deleted_at is null;

do $do$
declare t text; specs text[] := array['docks','dock_appointments','yard_zones','yard_visits'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'yms.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'yms.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on all tables in schema public to authenticated;
