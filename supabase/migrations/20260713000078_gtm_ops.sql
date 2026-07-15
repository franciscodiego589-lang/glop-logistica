-- ============================================================================
-- VOLUME 44 · GTM OPERACIONAL — Global Trade Management (migration 078)
-- Camada OPERACIONAL de comércio exterior sobre o /comex existente (mig 042,
-- foco em custo/simulador; recurso 'gtm'). Freight forwarding nível SAP GTS/
-- CargoWise/Descartes: embarques internacionais multimodais, bookings, agentes
-- logísticos, incoterms, eventos internacionais (timeline), rotas, containers.
-- NÃO é fiscal/aduaneiro. Reusa recurso RBAC 'gtm'. Escopo 100% logística.
-- Padrão: colunas-padrão, text+check, grant por-tabela.
-- ============================================================================

-- ── 1) AGENTES LOGÍSTICOS internacionais ─────────────────────────────────────
create table if not exists public.shipping_agents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  name text,
  agent_type text not null default 'freight_forwarder' check (agent_type in ('freight_forwarder','nvocc','carrier_ocean','airline','rail_operator','customs_broker','cargo_agent','consolidator','deconsolidator')),
  modal text,
  scac_code text,
  country text,
  contact text,
  rating numeric(4,1),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 2) INCOTERMS (catálogo) ──────────────────────────────────────────────────
create table if not exists public.incoterms (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  name text,
  description text,
  transfer_point text,
  edition text not null default '2020',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 3) EMBARQUES INTERNACIONAIS ──────────────────────────────────────────────
create table if not exists public.intl_shipments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  direction text not null default 'import' check (direction in ('import','export','cross_trade','transshipment','cabotage')),
  modal text not null default 'ocean' check (modal in ('road','rail','ocean','air','inland_water','multimodal','intermodal')),
  operation_type text,
  trade_process_id uuid references public.trade_processes(id) on delete set null,
  agent_id uuid references public.shipping_agents(id) on delete set null,
  incoterm text,
  origin_country text, dest_country text,
  origin_location text, dest_location text,
  vessel_voyage text,
  conveyance_ref text,
  etd timestamptz, eta timestamptz, atd timestamptz, ata timestamptz,
  transit_days integer,
  status text not null default 'planned' check (status in ('planned','booked','in_transit','at_port','discharged','released','delivered','canceled')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 4) BOOKINGS ──────────────────────────────────────────────────────────────
create table if not exists public.trade_bookings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  intl_shipment_id uuid references public.intl_shipments(id) on delete cascade,
  agent_id uuid references public.shipping_agents(id) on delete set null,
  booking_number text,
  carrier text,
  vessel_voyage text,
  cutoff_date timestamptz,
  containers_count integer not null default 0,
  teu numeric(8,2),
  status text not null default 'requested' check (status in ('requested','confirmed','rolled','canceled')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 5) EVENTOS INTERNACIONAIS (timeline) ─────────────────────────────────────
create table if not exists public.trade_shipment_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  intl_shipment_id uuid not null references public.intl_shipments(id) on delete cascade,
  event_type text not null default 'booking' check (event_type in ('booking','booking_confirmed','empty_container','loaded','factory_out','port_arrival','loading','departure','transshipment','discharge','released','final_delivery','delay','rolled','route_change')),
  location text,
  planned_at timestamptz,
  event_at timestamptz not null default now(),
  is_actual boolean not null default true,
  notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 6) ROTAS / pernas (legs) ─────────────────────────────────────────────────
create table if not exists public.trade_routes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  intl_shipment_id uuid not null references public.intl_shipments(id) on delete cascade,
  leg_seq integer not null default 1,
  modal text,
  from_location text,
  to_location text,
  transshipment_point text,
  transit_days integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- containers: liga ao embarque internacional (ADD, não destrutivo)
alter table public.containers add column if not exists intl_shipment_id uuid;

create index if not exists idx_intl_ship_agent on public.intl_shipments (agent_id);
create index if not exists idx_intl_ship_process on public.intl_shipments (trade_process_id);
create index if not exists idx_bookings_ship on public.trade_bookings (intl_shipment_id);
create index if not exists idx_trade_events_ship on public.trade_shipment_events (intl_shipment_id, event_at);
create index if not exists idx_trade_routes_ship on public.trade_routes (intl_shipment_id);
create index if not exists idx_containers_intl on public.containers (intl_shipment_id);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'gtm') ────────────
do $do$
declare t text; specs text[] := array['shipping_agents','incoterms','intl_shipments','trade_bookings','trade_shipment_events','trade_routes'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'gtm.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'gtm.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- Cria/confirma booking + evento na timeline
create or replace function public.book_shipment(p_company uuid, p_shipment uuid, p_agent uuid, p_booking text, p_carrier text, p_vessel text, p_cutoff timestamptz, p_containers integer default 0)
returns public.trade_bookings language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.trade_bookings;
begin
  if not (app.can_access_company(p_company) and app.has_permission('gtm.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.trade_bookings (tenant_id, company_id, intl_shipment_id, agent_id, booking_number, carrier, vessel_voyage, cutoff_date, containers_count, status)
    values (v_tenant, p_company, p_shipment, p_agent, p_booking, p_carrier, p_vessel, p_cutoff, coalesce(p_containers,0), 'confirmed') returning * into r;
  update public.intl_shipments set status = case when status='planned' then 'booked' else status end,
    vessel_voyage = coalesce(p_vessel, vessel_voyage), agent_id = coalesce(p_agent, agent_id) where id=p_shipment and company_id=p_company;
  insert into public.trade_shipment_events (tenant_id, company_id, intl_shipment_id, event_type, notes)
    values (v_tenant, p_company, p_shipment, 'booking_confirmed', 'Booking '||coalesce(p_booking,''));
  return r;
end; $$;
grant execute on function public.book_shipment(uuid,uuid,uuid,text,text,text,timestamptz,integer) to authenticated;

-- Registra evento internacional e atualiza ATD/ATA/status do embarque
create or replace function public.add_trade_event(p_company uuid, p_shipment uuid, p_event_type text, p_location text default null, p_at timestamptz default null, p_planned timestamptz default null)
returns public.trade_shipment_events language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.trade_shipment_events; v_when timestamptz;
begin
  if not (app.can_access_company(p_company) and app.has_permission('gtm.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  v_when := coalesce(p_at, now());
  insert into public.trade_shipment_events (tenant_id, company_id, intl_shipment_id, event_type, location, event_at, planned_at)
    values (v_tenant, p_company, p_shipment, p_event_type, p_location, v_when, p_planned) returning * into r;
  -- reflexos no embarque
  if p_event_type = 'departure' then
    update public.intl_shipments set atd=v_when, status = case when status in ('planned','booked') then 'in_transit' else status end where id=p_shipment and company_id=p_company;
  elsif p_event_type = 'port_arrival' then
    update public.intl_shipments set ata=v_when, status='at_port' where id=p_shipment and company_id=p_company;
  elsif p_event_type = 'discharge' then
    update public.intl_shipments set status='discharged' where id=p_shipment and company_id=p_company;
  elsif p_event_type = 'released' then
    update public.intl_shipments set status='released' where id=p_shipment and company_id=p_company;
  elsif p_event_type = 'final_delivery' then
    update public.intl_shipments set status='delivered' where id=p_shipment and company_id=p_company;
  elsif p_event_type = 'rolled' then
    update public.trade_bookings set status='rolled' where intl_shipment_id=p_shipment and company_id=p_company and status='confirmed';
  end if;
  -- transit_days = ata - atd quando ambos existem
  update public.intl_shipments set transit_days = greatest(0, (extract(epoch from (ata - atd))/86400.0)::int)
    where id=p_shipment and company_id=p_company and atd is not null and ata is not null;
  return r;
end; $$;
grant execute on function public.add_trade_event(uuid,uuid,text,text,timestamptz,timestamptz) to authenticated;

create or replace function public.intl_shipment_tracking(p_company uuid, p_shipment uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'shipment', (select jsonb_build_object('code',code,'direction',direction,'modal',modal,'status',status,'etd',etd,'eta',eta,'atd',atd,'ata',ata,'transit_days',transit_days,'origin',origin_location,'dest',dest_location) from public.intl_shipments where id=p_shipment and company_id=p_company),
    'events', (select coalesce(jsonb_agg(jsonb_build_object('event_type',event_type,'location',location,'event_at',event_at,'is_actual',is_actual) order by event_at), '[]'::jsonb) from public.trade_shipment_events where intl_shipment_id=p_shipment and deleted_at is null),
    'bookings', (select count(*) from public.trade_bookings where intl_shipment_id=p_shipment and deleted_at is null),
    'containers', (select count(*) from public.containers where intl_shipment_id=p_shipment and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.intl_shipment_tracking(uuid,uuid) to authenticated;

create or replace function public.gtm_ops_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'shipments', (select count(*) from public.intl_shipments where company_id=p_company and deleted_at is null),
    'imports', (select count(*) from public.intl_shipments where company_id=p_company and direction='import' and deleted_at is null),
    'exports', (select count(*) from public.intl_shipments where company_id=p_company and direction='export' and deleted_at is null),
    'in_transit', (select count(*) from public.intl_shipments where company_id=p_company and status='in_transit' and deleted_at is null),
    'at_port', (select count(*) from public.intl_shipments where company_id=p_company and status='at_port' and deleted_at is null),
    'delayed', (select count(*) from public.intl_shipments where company_id=p_company and eta is not null and eta < now() and status not in ('delivered','released','discharged','canceled') and deleted_at is null),
    'delivered', (select count(*) from public.intl_shipments where company_id=p_company and status='delivered' and deleted_at is null),
    'avg_transit_days', (select round(avg(transit_days),1) from public.intl_shipments where company_id=p_company and transit_days is not null and deleted_at is null),
    'bookings_open', (select count(*) from public.trade_bookings where company_id=p_company and status in ('requested','confirmed') and deleted_at is null),
    'agents', (select count(*) from public.shipping_agents where company_id=p_company and deleted_at is null),
    'containers', (select count(*) from public.containers where company_id=p_company and intl_shipment_id is not null and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.gtm_ops_dashboard(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.gtm_ops_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_cut int; v_delay int; v_roll int; v_stuck int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'GTMOPS%' and deleted_at is null;

  select count(*) into v_cut from public.trade_bookings where company_id=p_company and status='confirmed' and cutoff_date is not null and cutoff_date <= now() + interval '48 hours' and cutoff_date > now() and deleted_at is null;
  if v_cut > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'GTMOPS: cutoff de booking próximo', v_cut||' booking(s) com cutoff em até 48h.', 'Garantir entrega da carga/documentos antes do cutoff.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_delay from public.intl_shipments where company_id=p_company and eta is not null and eta < now() and status not in ('delivered','released','discharged','canceled') and deleted_at is null;
  if v_delay > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'GTMOPS: embarques atrasados', v_delay||' embarque(s) com ETA vencido sem chegada.', 'Cobrar update do agente/armador e revisar ETA.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_roll from public.trade_bookings where company_id=p_company and status='rolled' and deleted_at is null;
  if v_roll > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'GTMOPS: cargas roladas', v_roll||' booking(s) rolado(s) para outro navio/voo.', 'Reprogramar e avaliar impacto no lead time e SLA.', 80);
    v_c := v_c + 1;
  end if;
  select count(*) into v_stuck from public.intl_shipments s where s.company_id=p_company and s.status='at_port' and s.deleted_at is null
    and not exists (select 1 from public.trade_shipment_events e where e.intl_shipment_id=s.id and e.event_at > now()-interval '5 days' and e.event_type in ('released','discharge','final_delivery') and e.deleted_at is null)
    and s.ata is not null and s.ata < now()-interval '5 days';
  if v_stuck > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'GTMOPS: containers parados no porto', v_stuck||' embarque(s) há mais de 5 dias no porto sem liberação.', 'Acelerar liberação para evitar demurrage/detention.', 76);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.gtm_ops_insights(uuid) to authenticated;

-- ── SEED (empresa Matriz Logística) ─────────────────────────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid; v_agent uuid; v_ship uuid;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;

  if not exists (select 1 from public.incoterms where company_id=v_company and deleted_at is null) then
    insert into public.incoterms (tenant_id, company_id, code, name, transfer_point) values
      (v_tenant, v_company, 'EXW', 'Ex Works', 'Fábrica do vendedor'),
      (v_tenant, v_company, 'FCA', 'Free Carrier', 'Transportador indicado'),
      (v_tenant, v_company, 'FOB', 'Free On Board', 'A bordo no porto de origem'),
      (v_tenant, v_company, 'CFR', 'Cost and Freight', 'Porto de destino (frete pago)'),
      (v_tenant, v_company, 'CIF', 'Cost, Insurance and Freight', 'Porto de destino (frete+seguro)'),
      (v_tenant, v_company, 'CPT', 'Carriage Paid To', 'Destino (frete pago)'),
      (v_tenant, v_company, 'CIP', 'Carriage and Insurance Paid To', 'Destino (frete+seguro)'),
      (v_tenant, v_company, 'DAP', 'Delivered At Place', 'Local de destino'),
      (v_tenant, v_company, 'DPU', 'Delivered At Place Unloaded', 'Destino descarregado'),
      (v_tenant, v_company, 'DDP', 'Delivered Duty Paid', 'Destino com impostos pagos');
  end if;

  if not exists (select 1 from public.shipping_agents where company_id=v_company and deleted_at is null) then
    insert into public.shipping_agents (tenant_id, company_id, code, name, agent_type, modal, scac_code, country)
      values (v_tenant, v_company, 'FF-01', 'Global Freight Forwarders', 'freight_forwarder', 'ocean', 'GFFW', 'BR') returning id into v_agent;
    insert into public.intl_shipments (tenant_id, company_id, code, direction, modal, agent_id, incoterm, origin_country, dest_country, origin_location, dest_location, vessel_voyage, etd, eta, status)
      values (v_tenant, v_company, 'IMP-0001', 'import', 'ocean', v_agent, 'FOB', 'CN', 'BR', 'Shanghai', 'Santos', 'MSC ISABELLA / V123', now()+interval '2 days', now()+interval '32 days', 'booked') returning id into v_ship;
    insert into public.trade_bookings (tenant_id, company_id, intl_shipment_id, agent_id, booking_number, carrier, vessel_voyage, cutoff_date, containers_count, status)
      values (v_tenant, v_company, v_ship, v_agent, 'BK-778812', 'MSC', 'MSC ISABELLA / V123', now()+interval '1 day', 2, 'confirmed');
    insert into public.trade_shipment_events (tenant_id, company_id, intl_shipment_id, event_type, location, event_at) values
      (v_tenant, v_company, v_ship, 'booking', 'Shanghai', now()),
      (v_tenant, v_company, v_ship, 'booking_confirmed', 'Shanghai', now());
  end if;
end $seed$;

notify pgrst, 'reload schema';
