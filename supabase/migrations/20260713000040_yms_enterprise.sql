-- 20260713000040_yms_enterprise.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  YMS ENTERPRISE (Vol 12) — Pátio, portaria, docas, filas, containers.     ║
-- ║  Estende o YMS base (docks/dock_appointments/yard_zones/yard_visits).     ║
-- ║  Portaria/gate + OCR(campos), balanças, carga/descarga, containers,       ║
-- ║  lacres + AI Dock Scheduler + Yard Performance. Recurso 'yms'.            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.gate_direction as enum ('in','out');
create type public.seal_status    as enum ('intact','applied','violated','removed');

-- ── GATE_EVENTS (portaria) ──────────────────────────────────────────────────
create table public.gate_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  yard_visit_id uuid references public.yard_visits(id) on delete set null,
  carrier_id uuid references public.carriers(id) on delete set null,
  direction public.gate_direction not null default 'in', gate text,
  driver_name text, driver_document text, vehicle_plate text, container_number text,
  doc_type text, doc_number text, ocr_data jsonb not null default '{}'::jsonb, photos jsonb not null default '[]'::jsonb,
  occurred_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_gate_events_occurred on public.gate_events (company_id, occurred_at desc);

-- ── WEIGHINGS (balanças) ────────────────────────────────────────────────────
create table public.weighings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  yard_visit_id uuid references public.yard_visits(id) on delete set null,
  vehicle_plate text, gross_kg numeric(14,2), tare_kg numeric(14,2),
  net_kg numeric(14,2) generated always as (coalesce(gross_kg,0) - coalesce(tare_kg,0)) stored,
  occurred_at timestamptz not null default now(), notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_weighings_visit on public.weighings (yard_visit_id);

-- ── LOADING_OPERATIONS (carregamento / descarga) ────────────────────────────
create table public.loading_operations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  dock_id uuid references public.docks(id) on delete set null,
  yard_visit_id uuid references public.yard_visits(id) on delete set null,
  operation_type text not null default 'load', started_at timestamptz, finished_at timestamptz,
  team text, volumes integer, weight_kg numeric(14,2), seal_number text, checklist jsonb not null default '{}'::jsonb,
  status text not null default 'in_progress', notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_loading_operations_dock on public.loading_operations (dock_id);

-- ── CONTAINERS ──────────────────────────────────────────────────────────────
create table public.containers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  number text, iso_type text, container_type text default 'dry', weight_kg numeric(14,2),
  seal_number text, origin text, destination text, temperature numeric(6,2), status text not null default 'in_yard',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_containers_status on public.containers (company_id, status) where deleted_at is null;

-- ── SEALS (lacres) ──────────────────────────────────────────────────────────
create table public.seals (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  number text not null, seal_type text, status public.seal_status not null default 'intact',
  applied_to text, reference_type text, reference_id uuid, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_seals_status on public.seals (company_id, status) where deleted_at is null;

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- AI Dock Scheduler: melhor doca (disponível, direção compatível, menor fila)
create or replace function public.recommend_dock(p_company uuid, p_direction text default 'inbound')
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_build_object('dock_id', d.id, 'code', d.code, 'name', d.name,
      'queue', (select count(*) from public.dock_appointments a where a.dock_id=d.id and a.scheduled_start::date=now()::date and a.status not in ('completed','canceled','no_show') and a.deleted_at is null))
    from public.docks d
    where d.company_id=p_company and d.deleted_at is null and d.status='available'
      and (d.dock_type::text = p_direction or d.dock_type='both')
    order by (select count(*) from public.dock_appointments a where a.dock_id=d.id and a.scheduled_start::date=now()::date and a.status not in ('completed','canceled','no_show') and a.deleted_at is null) asc, d.code
    limit 1
  ), jsonb_build_object('dock_id', null, 'message', 'Nenhuma doca disponível — cadastre/libere docas.')) else '{}'::jsonb end;
$$;
grant execute on function public.recommend_dock(uuid, text) to authenticated;

-- Dashboard do pátio
create or replace function public.yard_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'in_yard', (select count(*) from public.yard_visits where company_id=p_company and status in ('in_yard','at_dock') and deleted_at is null),
    'at_gate', (select count(*) from public.yard_visits where company_id=p_company and status='at_gate' and deleted_at is null),
    'docks_total', (select count(*) from public.docks where company_id=p_company and deleted_at is null),
    'docks_occupied', (select count(*) from public.docks where company_id=p_company and status='occupied' and deleted_at is null),
    'docks_available', (select count(*) from public.docks where company_id=p_company and status='available' and deleted_at is null),
    'appointments_today', (select count(*) from public.dock_appointments where company_id=p_company and scheduled_start::date=now()::date and deleted_at is null),
    'loadings_today', (select count(*) from public.loading_operations where company_id=p_company and started_at::date=now()::date and deleted_at is null),
    'gate_events_today', (select count(*) from public.gate_events where company_id=p_company and occurred_at::date=now()::date and deleted_at is null),
    'avg_dwell_hours', (select round(avg(extract(epoch from (gate_out_at - gate_in_at))/3600),1) from public.yard_visits where company_id=p_company and gate_out_at is not null and gate_in_at is not null and deleted_at is null),
    'containers_in_yard', (select count(*) from public.containers where company_id=p_company and status='in_yard' and deleted_at is null),
    'violated_seals', (select count(*) from public.seals where company_id=p_company and status='violated' and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.yard_dashboard(uuid) to authenticated;

-- Yard Performance: tempo médio de permanência por transportadora
create or replace function public.yard_performance(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(jsonb_build_object('carrier', carrier, 'visits', n, 'avg_dwell_hours', avg_h) order by avg_h desc nulls last)
    from (
      select coalesce(c.name,'(sem transportadora)') carrier, count(*) n,
             round(avg(extract(epoch from (v.gate_out_at - v.gate_in_at))/3600),1) avg_h
      from public.yard_visits v left join public.carriers c on c.id=v.carrier_id
      where v.company_id=p_company and v.deleted_at is null and v.gate_out_at is not null and v.gate_in_at is not null
      group by c.name
    ) x
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.yard_performance(uuid) to authenticated;

-- IA de pátio: docas congestionadas / lacres violados → insights
create or replace function public.yms_insights(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_viol int; v_gate int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and kind='fraud_risk' and status='new' and title like 'Pátio%' and deleted_at is null;

  select count(*) into v_viol from public.seals where company_id=p_company and status='violated' and deleted_at is null;
  if v_viol > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'fraud_risk', 'critical', 'Pátio: lacres violados', v_viol||' lacre(s) violado(s) — risco de furto de carga.', 'Investigar e acionar segurança.', 90);
    v_count := v_count + 1;
  end if;
  select count(*) into v_gate from public.yard_visits where company_id=p_company and status='at_gate' and gate_in_at < now()-interval '2 hours' and deleted_at is null;
  if v_gate >= 3 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'Pátio: fila na portaria', v_gate||' veículo(s) na portaria há +2h.', 'Acelerar check-in / abrir mais docas.', 82);
    v_count := v_count + 1;
  end if;
  return v_count;
end;
$$;
grant execute on function public.yms_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela ────────────────────────────
do $do$
declare t text; specs text[] := array['gate_events','weighings','loading_operations','containers','seals'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'yms.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'yms.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;
