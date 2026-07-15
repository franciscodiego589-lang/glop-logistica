-- ============================================================================
-- VOLUME 48 · SCVP — SUPPLY CHAIN VISIBILITY PLATFORM (migration 082)
-- Visibilidade ponta a ponta: entidade unificada de rastreio que consolida a
-- jornada (eventos normalizados de todos os módulos), posições GPS, ETA
-- INTELIGENTE (baseada no progresso real), detecção de exceções e
-- compartilhamento seguro. Nível project44/FourKites/Shippeo. Distinto da Torre
-- (que decide) — aqui é coleta/consolidação/visibilidade. Recurso 'controltower'.
-- Padrão: colunas-padrão, text+check, coluna gerada imutável, grant por-tabela.
-- ============================================================================

-- ── 1) RASTREIO UNIFICADO (visibility shipment) ──────────────────────────────
create table if not exists public.scv_shipments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  ref_type text check (ref_type in ('order','shipment','intl_shipment','parcel','delivery')),
  ref_id uuid,
  modal text,
  carrier_ref text,
  origin text, destination text,
  dest_lat numeric(9,6), dest_lng numeric(9,6),
  current_status text not null default 'created',
  current_location text,
  current_lat numeric(9,6), current_lng numeric(9,6),
  pct_complete numeric(5,2) not null default 0,
  planned_eta timestamptz, predicted_eta timestamptz, eta_confidence integer,
  atd timestamptz, ata timestamptz,
  last_event_at timestamptz,
  health text not null default 'on_track' check (health in ('on_track','at_risk','delayed','exception','delivered')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 2) EVENTOS NORMALIZADOS (event stream) ───────────────────────────────────
create table if not exists public.scv_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  scv_shipment_id uuid not null references public.scv_shipments(id) on delete cascade,
  source_module text,
  event_code text not null default 'in_transit' check (event_code in ('created','picked_up','at_warehouse','at_hub','departed','in_transit','arrived','customs','out_for_delivery','delivered','returned','exception')),
  raw_type text,
  location text, lat numeric(9,6), lng numeric(9,6),
  event_at timestamptz not null default now(),
  is_milestone boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 3) POSIÇÕES GPS ──────────────────────────────────────────────────────────
create table if not exists public.scv_positions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  scv_shipment_id uuid not null references public.scv_shipments(id) on delete cascade,
  lat numeric(9,6), lng numeric(9,6),
  speed_kmh numeric(6,2), heading numeric(6,2),
  source text not null default 'gps' check (source in ('gps','rfid','api','telematics','manual')),
  recorded_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 4) EXCEÇÕES detectadas ───────────────────────────────────────────────────
create table if not exists public.scv_exceptions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  scv_shipment_id uuid not null references public.scv_shipments(id) on delete cascade,
  exception_type text not null default 'delay' check (exception_type in ('delay','stop','deviation','lost','signal_loss','eta_change','weather','incident')),
  severity text not null default 'medium' check (severity in ('low','medium','high','critical')),
  details text,
  detected_at timestamptz not null default now(),
  status text not null default 'open' check (status in ('open','resolved')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 5) COMPARTILHAMENTO seguro ───────────────────────────────────────────────
create table if not exists public.scv_shares (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  scv_shipment_id uuid not null references public.scv_shipments(id) on delete cascade,
  party_type text not null default 'customer' check (party_type in ('customer','carrier','3pl','supplier','partner','branch')),
  party_ref text,
  share_token text,
  can_see_position boolean not null default true,
  expires_at timestamptz,
  status text not null default 'active' check (status in ('active','revoked','expired')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_scv_evt_ship on public.scv_events (scv_shipment_id, event_at);
create index if not exists idx_scv_pos_ship on public.scv_positions (scv_shipment_id, recorded_at);
create index if not exists idx_scv_exc_ship on public.scv_exceptions (scv_shipment_id);
create index if not exists idx_scv_ship_health on public.scv_shipments (company_id, health);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'controltower') ────
do $do$
declare t text; specs text[] := array['scv_shipments','scv_events','scv_positions','scv_exceptions','scv_shares'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'controltower.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'controltower.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ── helper: % de progresso por milestone (imutável) ──────────────────────────
create or replace function app.scv_milestone_pct(p_code text)
returns numeric language sql immutable as $$
  select case p_code
    when 'created' then 0 when 'picked_up' then 10 when 'at_warehouse' then 20
    when 'at_hub' then 35 when 'departed' then 45 when 'in_transit' then 60
    when 'arrived' then 75 when 'customs' then 82 when 'out_for_delivery' then 90
    when 'delivered' then 100 when 'returned' then 100 else 0 end::numeric;
$$;

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- Ingestão normalizada de evento + recálculo de progresso, ETA inteligente e saúde
create or replace function public.ingest_scv_event(p_company uuid, p_scv uuid, p_event_code text, p_source text default null, p_location text default null, p_lat numeric default null, p_lng numeric default null, p_at timestamptz default null)
returns public.scv_shipments language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.scv_shipments; v_when timestamptz; v_pct numeric; v_start timestamptz;
  v_elapsed numeric; v_total numeric; v_pred timestamptz; v_conf int; v_health text;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  v_when := coalesce(p_at, now());
  v_pct := app.scv_milestone_pct(p_event_code);

  insert into public.scv_events (tenant_id, company_id, scv_shipment_id, source_module, event_code, location, lat, lng, event_at)
    values (v_tenant, p_company, p_scv, p_source, p_event_code, p_location, p_lat, p_lng, v_when);

  select * into r from public.scv_shipments where id=p_scv and company_id=p_company;
  if r.id is null then raise exception 'Rastreio não encontrado'; end if;

  -- só avança o progresso (não retrocede, exceto returned)
  if p_event_code = 'returned' then v_pct := 100;
  elsif v_pct < r.pct_complete then v_pct := r.pct_complete; end if;

  -- ETA inteligente: extrapola pelo ritmo real de progresso
  v_start := coalesce(r.atd, r.created_at);
  v_pred := r.planned_eta; v_conf := 50;
  if p_event_code in ('delivered','returned') then
    v_pred := v_when; v_conf := 100;
  elsif v_pct > 0 and v_pct < 100 then
    v_elapsed := extract(epoch from (v_when - v_start))/60.0;
    if v_elapsed > 0 then
      v_total := v_elapsed / (v_pct/100.0);
      v_pred := v_start + make_interval(mins => v_total::int);
      v_conf := least(95, greatest(40, (v_pct)::int)); -- confiança cresce com o progresso
    end if;
  end if;

  v_health := case
    when p_event_code in ('delivered') then 'delivered'
    when exists (select 1 from public.scv_exceptions e where e.scv_shipment_id=p_scv and e.status='open' and e.deleted_at is null) then 'exception'
    when r.planned_eta is not null and v_pred is not null and v_pred > r.planned_eta + interval '2 hours' then 'delayed'
    when r.planned_eta is not null and v_pred is not null and v_pred > r.planned_eta then 'at_risk'
    else 'on_track' end;

  update public.scv_shipments set
    current_status = p_event_code, pct_complete = v_pct,
    current_location = coalesce(p_location, current_location),
    current_lat = coalesce(p_lat, current_lat), current_lng = coalesce(p_lng, current_lng),
    last_event_at = v_when, predicted_eta = v_pred, eta_confidence = v_conf, health = v_health,
    atd = case when p_event_code='departed' and atd is null then v_when else atd end,
    ata = case when p_event_code in ('delivered','arrived') and ata is null then v_when else ata end
    where id=p_scv and company_id=p_company returning * into r;
  return r;
end; $$;
grant execute on function public.ingest_scv_event(uuid,uuid,text,text,text,numeric,numeric,timestamptz) to authenticated;

create or replace function public.record_position(p_company uuid, p_scv uuid, p_lat numeric, p_lng numeric, p_speed numeric default null, p_source text default 'gps')
returns void language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.scv_positions (tenant_id, company_id, scv_shipment_id, lat, lng, speed_kmh, source)
    values (v_tenant, p_company, p_scv, p_lat, p_lng, p_speed, coalesce(p_source,'gps'));
  update public.scv_shipments set current_lat=p_lat, current_lng=p_lng, last_event_at=now() where id=p_scv and company_id=p_company;
end; $$;
grant execute on function public.record_position(uuid,uuid,numeric,numeric,numeric,text) to authenticated;

-- Detecta exceções na visibilidade (perda de sinal, atraso, ETA estourado)
create or replace function public.detect_scv_exceptions(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_n int := 0; rec record;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.scv_exceptions set status='resolved' where company_id=p_company and status='open' and exception_type in ('signal_loss','delay','eta_change');

  for rec in select * from public.scv_shipments where company_id=p_company and health<>'delivered' and deleted_at is null loop
    -- perda de sinal: sem evento há mais de 12h
    if rec.last_event_at is not null and rec.last_event_at < now()-interval '12 hours' then
      insert into public.scv_exceptions (tenant_id, company_id, scv_shipment_id, exception_type, severity, details)
      values (v_tenant, p_company, rec.id, 'signal_loss', 'high', 'Sem atualização há mais de 12h');
      v_n := v_n + 1;
    end if;
    -- atraso: ETA previsto estoura o planejado
    if rec.planned_eta is not null and rec.predicted_eta is not null and rec.predicted_eta > rec.planned_eta + interval '2 hours' then
      insert into public.scv_exceptions (tenant_id, company_id, scv_shipment_id, exception_type, severity, details)
      values (v_tenant, p_company, rec.id, 'delay', 'medium', 'ETA previsto excede o planejado');
      v_n := v_n + 1;
    end if;
  end loop;
  return v_n;
end; $$;
grant execute on function public.detect_scv_exceptions(uuid) to authenticated;

create or replace function public.create_scv_share(p_company uuid, p_scv uuid, p_party_type text, p_party_ref text, p_hours integer default 168)
returns public.scv_shares language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.scv_shares;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.scv_shares (tenant_id, company_id, scv_shipment_id, party_type, party_ref, share_token, expires_at)
    values (v_tenant, p_company, p_scv, coalesce(p_party_type,'customer'), p_party_ref,
      'trk_'||replace(gen_random_uuid()::text,'-',''), now() + make_interval(hours => coalesce(p_hours,168))) returning * into r;
  return r;
end; $$;
grant execute on function public.create_scv_share(uuid,uuid,text,text,integer) to authenticated;

create or replace function public.scv_timeline(p_company uuid, p_scv uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'shipment', (select jsonb_build_object('code',code,'status',current_status,'pct',pct_complete,'health',health,'origin',origin,'destination',destination,'planned_eta',planned_eta,'predicted_eta',predicted_eta,'eta_confidence',eta_confidence,'location',current_location) from public.scv_shipments where id=p_scv and company_id=p_company),
    'events', (select coalesce(jsonb_agg(jsonb_build_object('event_code',event_code,'location',location,'event_at',event_at,'source',source_module) order by event_at), '[]'::jsonb) from public.scv_events where scv_shipment_id=p_scv and deleted_at is null),
    'positions', (select count(*) from public.scv_positions where scv_shipment_id=p_scv and deleted_at is null),
    'exceptions', (select count(*) from public.scv_exceptions where scv_shipment_id=p_scv and status='open' and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.scv_timeline(uuid,uuid) to authenticated;

create or replace function public.scvp_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb; v_tot int; v_track int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select count(*) into v_tot from public.scv_shipments where company_id=p_company and deleted_at is null;
  select count(*) into v_track from public.scv_shipments where company_id=p_company and health='on_track' and deleted_at is null;
  select jsonb_build_object(
    'shipments', v_tot,
    'on_track', v_track,
    'at_risk', (select count(*) from public.scv_shipments where company_id=p_company and health='at_risk' and deleted_at is null),
    'delayed', (select count(*) from public.scv_shipments where company_id=p_company and health='delayed' and deleted_at is null),
    'exceptions_health', (select count(*) from public.scv_shipments where company_id=p_company and health='exception' and deleted_at is null),
    'delivered', (select count(*) from public.scv_shipments where company_id=p_company and health='delivered' and deleted_at is null),
    'visibility_pct', case when v_tot>0 then round(100.0*v_track/v_tot,1) else null end,
    'events_captured', (select count(*) from public.scv_events where company_id=p_company and deleted_at is null),
    'positions', (select count(*) from public.scv_positions where company_id=p_company and deleted_at is null),
    'exceptions_open', (select count(*) from public.scv_exceptions where company_id=p_company and status='open' and deleted_at is null),
    'shares', (select count(*) from public.scv_shares where company_id=p_company and status='active' and deleted_at is null),
    'avg_eta_confidence', (select round(avg(eta_confidence),0) from public.scv_shipments where company_id=p_company and eta_confidence is not null and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.scvp_dashboard(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.scvp_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_del int; v_exc int; v_lost int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'SCVP%' and deleted_at is null;

  select count(*) into v_del from public.scv_shipments where company_id=p_company and health='delayed' and deleted_at is null;
  if v_del > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'warning', 'SCVP: remessas atrasadas', v_del||' remessa(s) com ETA previsto estourado.', 'Avisar o cliente e replanejar; possível impacto no SLA.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_lost from public.scv_exceptions where company_id=p_company and exception_type='signal_loss' and status='open' and deleted_at is null;
  if v_lost > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'SCVP: perda de sinal', v_lost||' remessa(s) sem atualização (ponto cego).', 'Contatar transportadora/motorista para restabelecer o tracking.', 80);
    v_c := v_c + 1;
  end if;
  select count(*) into v_exc from public.scv_exceptions where company_id=p_company and status='open' and severity in ('high','critical') and deleted_at is null;
  if v_exc > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'SCVP: exceções graves de visibilidade', v_exc||' exceção(ões) grave(s) aberta(s).', 'Tratar na Torre de Controle; risco à entrega.', 78);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.scvp_insights(uuid) to authenticated;

-- ── SEED (empresa Matriz Logística) ─────────────────────────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;
  if not exists (select 1 from public.scv_shipments where company_id=v_company and deleted_at is null) then
    insert into public.scv_shipments (tenant_id, company_id, code, ref_type, modal, origin, destination, dest_lat, dest_lng, planned_eta, atd, current_status)
      values (v_tenant, v_company, 'TRK-0001', 'shipment', 'road', 'CD São Paulo', 'Cliente Rio de Janeiro', -22.9068, -43.1729, now()+interval '8 hours', now()-interval '2 hours', 'departed');
  end if;
end $seed$;

notify pgrst, 'reload schema';
