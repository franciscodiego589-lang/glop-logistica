-- 20260713000036_clx.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  CLX — CUSTOMER LOGISTICS EXPERIENCE (Vol 8) — Portal do Cliente/Pós-venda ║
-- ║  Rastreio público, ocorrências do cliente, NPS/CSAT, notificações,        ║
-- ║  comprovante de entrega. Reusa deliveries/shipments/shipment_events/rma.  ║
-- ║  Recurso RBAC 'shipping'. public_track é ANON (rastreio sem login).        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.cust_occurrence_status as enum ('open','in_progress','resolved','closed');

-- comprovante de entrega: deliveries já tem pod_url/receiver/geo; falta assinatura
alter table public.deliveries add column if not exists signature_url text;

-- ── CUSTOMER_OCCURRENCES (ocorrências abertas pelo cliente) ──────────────────
create table public.customer_occurrences (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  customer_id uuid references public.customers(id) on delete set null,
  outbound_order_id uuid references public.outbound_orders(id) on delete set null,
  shipment_id uuid references public.shipments(id) on delete set null,
  occurrence_type text not null, description text, priority text default 'normal',
  status public.cust_occurrence_status not null default 'open',
  photos jsonb not null default '[]'::jsonb, contact text,
  opened_at timestamptz not null default now(), resolved_at timestamptz, resolution text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_customer_occurrences_status on public.customer_occurrences (company_id, status) where deleted_at is null;

-- ── SATISFACTION_SURVEYS (NPS/CSAT pós-entrega) ─────────────────────────────
create table public.satisfaction_surveys (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  customer_id uuid references public.customers(id) on delete set null,
  reference_type text, reference_id uuid,
  nps integer, csat integer, on_time boolean, intact boolean, comment text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_satisfaction_surveys_customer on public.satisfaction_surveys (customer_id);

-- ── CUSTOMER_NOTIFICATIONS (log de comunicações) ────────────────────────────
create table public.customer_notifications (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  customer_id uuid references public.customers(id) on delete set null,
  channel text not null default 'whatsapp', event text, message text,
  reference_type text, reference_id uuid, status text not null default 'sent', sent_at timestamptz default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_customer_notifications_customer on public.customer_notifications (customer_id);

-- ── RPC PÚBLICO: rastreio por código (SEM login — cliente final) ────────────
create or replace function public.public_track(p_code text)
returns jsonb
language plpgsql stable security definer set search_path = public, app as $$
declare v_s record; v_events jsonb; v_o record;
begin
  if p_code is null or length(trim(p_code)) < 3 then return jsonb_build_object('found', false); end if;

  -- 1) embarque (TMS)
  select id, status::text st, estimated_delivery, last_location, dest_city, dest_uf, delivered_at
    into v_s from public.shipments where tracking_code = trim(p_code) and deleted_at is null limit 1;
  if v_s.id is not null then
    select coalesce(jsonb_agg(jsonb_build_object('type', event_type, 'description', description, 'location', location_text, 'at', occurred_at) order by occurred_at), '[]'::jsonb)
      into v_events from public.shipment_events where shipment_id = v_s.id and deleted_at is null;
    return jsonb_build_object('found', true, 'kind', 'shipment', 'status', v_s.st,
      'city', v_s.dest_city, 'uf', v_s.dest_uf, 'eta', v_s.estimated_delivery, 'delivered_at', v_s.delivered_at,
      'last_location', v_s.last_location, 'events', v_events);
  end if;

  -- 2) objeto postal (Correios)
  select id, status::text st, dest_city, dest_uf, delivered_at, last_event_at
    into v_o from public.postal_objects where tracking_code = trim(p_code) and deleted_at is null limit 1;
  if v_o.id is not null then
    select coalesce(jsonb_agg(jsonb_build_object('type', event_type, 'description', description, 'location', location_text, 'at', occurred_at) order by occurred_at), '[]'::jsonb)
      into v_events from public.postal_events where postal_object_id = v_o.id and deleted_at is null;
    return jsonb_build_object('found', true, 'kind', 'postal', 'status', v_o.st,
      'city', v_o.dest_city, 'uf', v_o.dest_uf, 'delivered_at', v_o.delivered_at, 'events', v_events);
  end if;

  return jsonb_build_object('found', false);
end;
$$;
grant execute on function public.public_track(text) to anon, authenticated;

-- ── RPC: NPS (promotores − detratores) ──────────────────────────────────────
create or replace function public.compute_nps(p_company uuid)
returns numeric
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then (
    select round(
      100.0 * count(*) filter (where nps >= 9) / nullif(count(*) filter (where nps is not null),0)
    - 100.0 * count(*) filter (where nps <= 6) / nullif(count(*) filter (where nps is not null),0), 0)
    from public.satisfaction_surveys where company_id=p_company and deleted_at is null
  ) else null end;
$$;
grant execute on function public.compute_nps(uuid) to authenticated;

-- ── RPC: dashboard CLX (pós-venda) ──────────────────────────────────────────
create or replace function public.clx_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'occurrences_open', (select count(*) from public.customer_occurrences where company_id=p_company and status not in ('resolved','closed') and deleted_at is null),
    'occurrences_resolved', (select count(*) from public.customer_occurrences where company_id=p_company and status in ('resolved','closed') and deleted_at is null),
    'avg_resolution_hours', (select round(avg(extract(epoch from (resolved_at - opened_at))/3600),1) from public.customer_occurrences where company_id=p_company and resolved_at is not null and deleted_at is null),
    'nps', public.compute_nps(p_company),
    'csat', (select round(avg(csat),1) from public.satisfaction_surveys where company_id=p_company and csat is not null and deleted_at is null),
    'surveys', (select count(*) from public.satisfaction_surveys where company_id=p_company and deleted_at is null),
    'on_time_pct', (select round(100.0*count(*) filter (where on_time)/nullif(count(*) filter (where on_time is not null),0),0) from public.satisfaction_surveys where company_id=p_company and deleted_at is null),
    'returns_open', (select count(*) from public.rma_requests where company_id=p_company and status not in ('closed','canceled') and deleted_at is null),
    'notifications_today', (select count(*) from public.customer_notifications where company_id=p_company and sent_at::date=now()::date and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.clx_dashboard(uuid) to authenticated;

-- ── RPC: IA — clientes em risco de churn → insights ─────────────────────────
create or replace function public.clx_insights(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_r record;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and kind='opportunity' and status='new' and title like 'Cliente%' and deleted_at is null;

  for v_r in
    select c.id, c.name, count(*) c_occ from public.customer_occurrences o join public.customers c on c.id=o.customer_id
    where o.company_id=p_company and o.deleted_at is null group by c.id, c.name having count(*) >= 2 order by count(*) desc limit 10
  loop
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'opportunity', 'warning', 'Cliente em risco: '||v_r.name,
      v_r.c_occ||' ocorrência(s) do cliente "'||v_r.name||'" — risco de churn.',
      'Acionar o SAC/Comercial para recuperar o cliente.', 78);
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.clx_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela ────────────────────────────
do $do$
declare t text; specs text[] := array['customer_occurrences','satisfaction_surveys','customer_notifications'];
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
