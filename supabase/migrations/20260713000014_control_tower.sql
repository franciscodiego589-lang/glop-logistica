-- 20260713000014_control_tower.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 14 — TORRE DE CONTROLE LOGÍSTICA (Control Tower)                   ║
-- ║  Barramento de eventos · políticas de SLA · quebras · alertas · exceções. ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.event_severity  as enum ('info','warning','critical');
create type public.alert_status    as enum ('open','acknowledged','resolved','dismissed');
create type public.exception_status as enum ('open','in_progress','resolved','escalated','closed');

create table public.logistics_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  domain text not null,                               -- wms, tms, yms, production, inventory...
  event_type text not null, severity public.event_severity not null default 'info',
  title text, description text, reference_type text, reference_id uuid,
  occurred_at timestamptz not null default now(), payload jsonb not null default '{}'::jsonb,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_logistics_events_domain on public.logistics_events (company_id, domain, occurred_at desc);
create index idx_logistics_events_severity on public.logistics_events (company_id, severity) where deleted_at is null;

create table public.sla_policies (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, domain text not null, metric text not null,   -- ex.: dock_wait, order_cycle, delivery_time
  target_minutes numeric(14,2), threshold_percent numeric(6,2), notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create table public.sla_breaches (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  policy_id uuid references public.sla_policies(id) on delete set null,
  reference_type text, reference_id uuid, target_minutes numeric(14,2), actual_minutes numeric(14,2),
  breach_minutes numeric(14,2), occurred_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_sla_breaches_policy on public.sla_breaches (policy_id);

create table public.alerts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  domain text, severity public.event_severity not null default 'warning', status public.alert_status not null default 'open',
  title text not null, description text, reference_type text, reference_id uuid,
  assignee_id uuid references auth.users(id), acknowledged_at timestamptz, resolved_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_alerts_status on public.alerts (company_id, status) where deleted_at is null;

create table public.logistics_exceptions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  domain text, category text, status public.exception_status not null default 'open',
  title text not null, description text, reference_type text, reference_id uuid,
  owner_id uuid references auth.users(id), resolved_at timestamptz, resolution text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_logistics_exceptions_status on public.logistics_exceptions (company_id, status) where deleted_at is null;

-- ── RPC: KPIs da torre de controle (visão única em tempo real) ──────────────
create or replace function public.control_tower_kpis(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select jsonb_build_object(
    'open_alerts',       (select count(*) from public.alerts where company_id=p_company and status='open' and deleted_at is null),
    'critical_alerts',   (select count(*) from public.alerts where company_id=p_company and status='open' and severity='critical' and deleted_at is null),
    'open_exceptions',   (select count(*) from public.logistics_exceptions where company_id=p_company and status in ('open','in_progress') and deleted_at is null),
    'sla_breaches_24h',  (select count(*) from public.sla_breaches where company_id=p_company and occurred_at > now()-interval '24 hours' and deleted_at is null),
    'shipments_transit', (select count(*) from public.shipments where company_id=p_company and status='in_transit' and deleted_at is null),
    'deliveries_today',  (select count(*) from public.deliveries where company_id=p_company and scheduled_date = now()::date and deleted_at is null),
    'events_1h',         (select count(*) from public.logistics_events where company_id=p_company and occurred_at > now()-interval '1 hour')
  ) where app.can_access_company(p_company);
$$;
grant execute on function public.control_tower_kpis(uuid) to authenticated;

do $do$
declare t text; specs text[] := array[
  'logistics_events','sla_policies','sla_breaches','alerts','logistics_exceptions'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'controltower.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'controltower.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on all tables in schema public to authenticated;
