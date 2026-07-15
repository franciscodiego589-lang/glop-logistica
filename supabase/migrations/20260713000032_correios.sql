-- 20260713000032_correios.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  CORREIOS MANAGEMENT SYSTEM (CMS) — Gestão Enterprise dos Correios         ║
-- ║  Contratos/cartão de postagem · serviços · PLP (pré-lista) · objetos ·    ║
-- ║  SRO (eventos) · auditoria de fretes (peso/tarifa) · simulador · SLA por  ║
-- ║  agência. Comporta o ERP como grande embarcador. Recurso RBAC 'shipping'. ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.postal_object_status as enum (
  'created','pre_posted','manifested','collected','posted','accepted','in_transit',
  'out_for_delivery','delivered','delivery_failed','awaiting_pickup','returned','lost','damaged','canceled');
create type public.plp_status       as enum ('open','closed','collected','posted','canceled');
create type public.divergence_status as enum ('open','contested','resolved','dismissed');

-- ── POSTAL_CONTRACTS (contratos / cartões de postagem) ──────────────────────
create table public.postal_contracts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  contract_number text, admin_code text, posting_card text, operational_center text,
  name text, valid_from date, valid_to date, insurance boolean not null default false, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── POSTAL_SERVICES (catálogo: SEDEX/PAC/... com preço p/ simulador) ────────
create table public.postal_services (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, name text not null, modality text default 'express', sla_days integer,
  base_price numeric(12,2) not null default 0, price_per_kg numeric(12,2) not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── PLPS (Pré-Lista de Postagem / manifesto) ────────────────────────────────
create table public.plps (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  contract_id uuid references public.postal_contracts(id) on delete set null,
  code text, status public.plp_status not null default 'open',
  volumes integer, total_weight_g numeric(16,3), closed_at timestamptz, collected_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_plps_status on public.plps (company_id, status) where deleted_at is null;

-- ── POSTAL_OBJECTS (objetos postais + campos de auditoria de frete) ─────────
create table public.postal_objects (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  plp_id uuid references public.plps(id) on delete set null,
  contract_id uuid references public.postal_contracts(id) on delete set null,
  service_id uuid references public.postal_services(id) on delete set null,
  outbound_order_id uuid references public.outbound_orders(id) on delete set null,
  dispatch_id uuid references public.dispatches(id) on delete set null,
  tracking_code text, invoice_number text,
  weight_g numeric(14,3), tariffed_weight_g numeric(14,3), cube_m3 numeric(14,4),
  length_mm numeric(12,2), width_mm numeric(12,2), height_mm numeric(12,2),
  declared_value numeric(14,2), ar boolean not null default false, own_hand boolean not null default false,
  dest_cep text, dest_uf text, dest_city text, agency text,
  status public.postal_object_status not null default 'created',
  freight_contracted numeric(14,2), freight_charged numeric(14,2),
  posted_at timestamptz, delivered_at timestamptz, last_event_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_postal_objects_status on public.postal_objects (company_id, status) where deleted_at is null;
create index idx_postal_objects_tracking on public.postal_objects (tracking_code);
create unique index uq_postal_objects_tracking on public.postal_objects (company_id, tracking_code) where tracking_code is not null and deleted_at is null;

-- ── POSTAL_EVENTS (SRO — rastreamento) ──────────────────────────────────────
create table public.postal_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  postal_object_id uuid not null references public.postal_objects(id) on delete cascade,
  event_code text, event_type text, description text, location_text text, uf text, city text,
  occurred_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_postal_events_object on public.postal_events (postal_object_id, occurred_at desc);

-- ── FREIGHT_DIVERGENCES (auditoria de fretes) ───────────────────────────────
create table public.freight_divergences (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  postal_object_id uuid references public.postal_objects(id) on delete cascade,
  divergence_type text not null, expected_value numeric(14,2), charged_value numeric(14,2),
  difference numeric(14,2), status public.divergence_status not null default 'open', notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_freight_divergences_status on public.freight_divergences (company_id, status) where deleted_at is null;

-- ── Trigger: evento SRO atualiza o objeto (last_event/status/entrega) ───────
create or replace function app.tg_postal_event_sync() returns trigger
language plpgsql security definer set search_path = public, app as $$
begin
  update public.postal_objects
     set last_event_at = new.occurred_at,
         status = case
           when new.event_type in ('delivered','BDE','entregue') then 'delivered'
           when new.event_type in ('returned','devolvido') then 'returned'
           when new.event_type in ('out_for_delivery','saiu_entrega') then 'out_for_delivery'
           when new.event_type in ('posted','postado') then 'posted'
           when new.event_type in ('in_transit','transito') and status in ('posted','accepted') then 'in_transit'
           else status end,
         delivered_at = case when new.event_type in ('delivered','BDE','entregue') then new.occurred_at else delivered_at end
   where id = new.postal_object_id;
  return null;
end;
$$;
drop trigger if exists trg_postal_events_sync on public.postal_events;
create trigger trg_postal_events_sync after insert on public.postal_events
  for each row execute function app.tg_postal_event_sync();

-- ── RPC: auditoria de fretes (contratado × cobrado, peso real × tarifado) ───
create or replace function public.audit_postal_freight(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_o record;
begin
  if not app.has_permission('shipping.update', p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.freight_divergences set status='dismissed' where company_id=p_company and status='open' and deleted_at is null;

  for v_o in select * from public.postal_objects where company_id=p_company and deleted_at is null loop
    -- cobrança maior que o contratado
    if v_o.freight_charged is not null and v_o.freight_contracted is not null and v_o.freight_charged - v_o.freight_contracted > 0.01 then
      insert into public.freight_divergences (tenant_id, company_id, postal_object_id, divergence_type, expected_value, charged_value, difference, status, notes)
      values (v_tenant, p_company, v_o.id, 'tariff', v_o.freight_contracted, v_o.freight_charged, v_o.freight_charged - v_o.freight_contracted, 'open', 'Frete cobrado acima do contratado.');
      v_count := v_count + 1;
    end if;
    -- peso tarifado maior que o real
    if v_o.tariffed_weight_g is not null and v_o.weight_g is not null and v_o.tariffed_weight_g - v_o.weight_g > 1 then
      insert into public.freight_divergences (tenant_id, company_id, postal_object_id, divergence_type, expected_value, charged_value, difference, status, notes)
      values (v_tenant, p_company, v_o.id, 'weight', v_o.weight_g, v_o.tariffed_weight_g, v_o.tariffed_weight_g - v_o.weight_g, 'open', 'Peso tarifado acima do peso real.');
      v_count := v_count + 1;
    end if;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.audit_postal_freight(uuid) to authenticated;

-- ── RPC: simulador de fretes (serviços disponíveis p/ um peso) ──────────────
create or replace function public.freight_simulator(p_company uuid, p_weight_g numeric, p_declared numeric default 0)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(jsonb_build_object(
      'service', name, 'code', code, 'sla_days', sla_days,
      'price', round(base_price + price_per_kg * (p_weight_g/1000.0) + coalesce(p_declared,0)*0.01, 2)
    ) order by base_price + price_per_kg * (p_weight_g/1000.0))
    from public.postal_services where company_id=p_company and active and deleted_at is null
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.freight_simulator(uuid, numeric, numeric) to authenticated;

-- ── RPC: dashboard dos Correios ─────────────────────────────────────────────
create or replace function public.correios_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'awaiting_post', (select count(*) from public.postal_objects where company_id=p_company and posted_at is null and status not in ('canceled','returned') and deleted_at is null),
    'in_transit',    (select count(*) from public.postal_objects where company_id=p_company and status in ('posted','accepted','in_transit','out_for_delivery') and deleted_at is null),
    'delivered',     (select count(*) from public.postal_objects where company_id=p_company and status='delivered' and deleted_at is null),
    'returned',      (select count(*) from public.postal_objects where company_id=p_company and status='returned' and deleted_at is null),
    'no_movement',   (select count(*) from public.postal_objects where company_id=p_company and posted_at is not null and last_event_at is null and deleted_at is null),
    'objects_total', (select count(*) from public.postal_objects where company_id=p_company and deleted_at is null),
    'freight_contracted', (select coalesce(sum(freight_contracted),0) from public.postal_objects where company_id=p_company and deleted_at is null),
    'freight_charged',    (select coalesce(sum(freight_charged),0) from public.postal_objects where company_id=p_company and deleted_at is null),
    'divergence_total',   (select coalesce(sum(difference),0) from public.freight_divergences where company_id=p_company and status='open' and deleted_at is null),
    'divergences_open',   (select count(*) from public.freight_divergences where company_id=p_company and status='open' and deleted_at is null),
    'open_plps',     (select count(*) from public.plps where company_id=p_company and status='open' and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.correios_dashboard(uuid) to authenticated;

-- ── RPC: IA — cobranças indevidas e objetos parados → insights ──────────────
create or replace function public.correios_insights(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_div numeric;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and kind='cost_saving' and status='new' and title like 'Correios%' and deleted_at is null;

  select coalesce(sum(difference),0) into v_div from public.freight_divergences where company_id=p_company and status='open' and deleted_at is null;
  if v_div > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, impact_value, confidence)
    values (v_tenant, p_company, 'cost_saving', 'warning', 'Correios: cobranças indevidas a contestar',
      'Divergências de frete somam R$ '||round(v_div,2)||' a recuperar.',
      'Abrir processo de contestação junto aos Correios.', v_div, 88);
    v_count := v_count + 1;
  end if;
  return v_count;
end;
$$;
grant execute on function public.correios_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'shipping') ───────
do $do$
declare t text; specs text[] := array['postal_contracts','postal_services','plps','postal_objects','postal_events','freight_divergences'];
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
