-- ============================================================================
-- VOLUME 40 · LMDP — LAST MILE DELIVERY PLATFORM (migration 074)
-- Complementa a base de entregas já existente (deliveries/routes/delivery_attempts/
-- dispatches/last_known_positions das migs 004/013) com a inteligência de última
-- milha nível Amazon/Bringg/Onfleet: PARADAS sequenciadas, OTIMIZAÇÃO de rota
-- (nearest-neighbor + ETA), PROVA DE ENTREGA (POD), GEOCERCAS, janelas + SLA
-- OTIF/OTD. Reusa o recurso RBAC 'distribution'. Escopo 100% logística.
-- Padrão: colunas-padrão, text+check, grant por-tabela.
-- ============================================================================

-- helper de distância (Haversine, km) no schema interno app
create or replace function app.haversine_km(lat1 numeric, lng1 numeric, lat2 numeric, lng2 numeric)
returns numeric language sql immutable as $$
  select case when lat1 is null or lat2 is null or lng1 is null or lng2 is null then null else
    (2 * 6371 * asin(least(1, sqrt(
      power(sin(radians(lat2 - lat1) / 2), 2) +
      cos(radians(lat1)) * cos(radians(lat2)) * power(sin(radians(lng2 - lng1) / 2), 2)
    ))))::numeric end;
$$;

-- ── 1) PARADAS DE ROTA (route_stops) ─────────────────────────────────────────
create table if not exists public.route_stops (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  route_id uuid not null references public.routes(id) on delete cascade,
  delivery_id uuid references public.deliveries(id) on delete set null,
  sequence integer,
  stop_type text not null default 'delivery' check (stop_type in ('depot','pickup','delivery')),
  address text,
  lat numeric(9,6),
  lng numeric(9,6),
  window_start timestamptz,
  window_end timestamptz,
  planned_eta timestamptz,
  arrived_at timestamptz,
  completed_at timestamptz,
  status text not null default 'pending' check (status in ('pending','en_route','arrived','completed','failed')),
  service_min integer not null default 5,
  notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 2) PROVA DE ENTREGA (proof_of_delivery / POD) ────────────────────────────
create table if not exists public.proof_of_delivery (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  delivery_id uuid not null references public.deliveries(id) on delete cascade,
  route_stop_id uuid references public.route_stops(id) on delete set null,
  pod_type text not null default 'signature' check (pod_type in ('signature','photo','code','biometric')),
  recipient_name text,
  recipient_document text,
  signature_ref text,
  photo_url text,
  lat numeric(9,6),
  lng numeric(9,6),
  confirmation_code text,
  delivered_at timestamptz not null default now(),
  notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 3) GEOCERCAS (geofences) ─────────────────────────────────────────────────
create table if not exists public.geofences (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text,
  name text not null,
  geofence_type text not null default 'customer' check (geofence_type in ('distribution_center','customer','supplier','port','airport','yard','risk_area','mandatory_route')),
  center_lat numeric(9,6),
  center_lng numeric(9,6),
  radius_m numeric(10,1),
  polygon jsonb,
  status text not null default 'active' check (status in ('active','inactive')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── deliveries: campos de última milha (ADD colunas, não destrutivo) ─────────
alter table public.deliveries add column if not exists priority integer not null default 3;
alter table public.deliveries add column if not exists service_type text;
alter table public.deliveries add column if not exists window_start timestamptz;
alter table public.deliveries add column if not exists window_end timestamptz;
alter table public.deliveries add column if not exists promised_at timestamptz;
alter table public.deliveries add column if not exists lat numeric(9,6);
alter table public.deliveries add column if not exists lng numeric(9,6);
alter table public.deliveries add column if not exists recipient_name text;
alter table public.deliveries add column if not exists status text not null default 'pending';

create index if not exists idx_route_stops_route on public.route_stops (route_id);
create index if not exists idx_route_stops_delivery on public.route_stops (delivery_id);
create index if not exists idx_pod_delivery on public.proof_of_delivery (delivery_id);
create index if not exists idx_geofences_type on public.geofences (company_id, geofence_type);
create index if not exists idx_deliveries_status on public.deliveries (company_id, status);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'distribution') ────
do $do$
declare t text; specs text[] := array['route_stops','proof_of_delivery','geofences'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'distribution.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'distribution.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- Otimização de rota: nearest-neighbor sobre as paradas + ETA cumulativa (30 km/h)
create or replace function public.optimize_route(p_company uuid, p_route uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_seq int := 0; v_eta timestamptz; v_lat numeric; v_lng numeric; v_next record; v_km numeric;
begin
  if not (app.can_access_company(p_company) and app.has_permission('distribution.update', p_company)) then raise exception 'forbidden'; end if;
  select coalesce(started_at, planned_date::timestamptz, now()) into v_eta from public.routes where id=p_route and company_id=p_company;
  if v_eta is null then v_eta := now(); end if;
  update public.route_stops set sequence=null, planned_eta=null where route_id=p_route and company_id=p_company and deleted_at is null;
  -- ponto de partida: depósito, senão a parada mais ao norte (determinístico)
  select lat, lng into v_lat, v_lng from public.route_stops
    where route_id=p_route and company_id=p_company and deleted_at is null and lat is not null
    order by (stop_type='depot') desc, lat desc, lng asc limit 1;
  loop
    select * into v_next from public.route_stops
      where route_id=p_route and company_id=p_company and deleted_at is null and sequence is null
      order by (case when lat is null or v_lat is null then 1 else 0 end),
               app.haversine_km(v_lat, v_lng, lat, lng) nulls last, created_at
      limit 1;
    exit when v_next.id is null;
    v_seq := v_seq + 1;
    v_km := app.haversine_km(v_lat, v_lng, v_next.lat, v_next.lng);
    if v_km is not null then v_eta := v_eta + make_interval(mins => (v_km / 30.0 * 60.0)::int); end if;
    update public.route_stops set sequence=v_seq, planned_eta=v_eta where id=v_next.id;
    v_eta := v_eta + make_interval(mins => coalesce(v_next.service_min, 5));
    v_lat := coalesce(v_next.lat, v_lat); v_lng := coalesce(v_next.lng, v_lng);
  end loop;
  return v_seq;
end; $$;
grant execute on function public.optimize_route(uuid,uuid) to authenticated;

-- Registra prova de entrega e conclui a entrega + parada
create or replace function public.register_pod(p_company uuid, p_delivery uuid, p_recipient text, p_document text,
  p_signature text, p_photo text, p_lat numeric, p_lng numeric, p_code text, p_pod_type text default 'signature')
returns public.proof_of_delivery language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.proof_of_delivery; v_stop uuid;
begin
  if not (app.can_access_company(p_company) and app.has_permission('distribution.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select id into v_stop from public.route_stops where delivery_id=p_delivery and company_id=p_company and deleted_at is null order by sequence limit 1;
  insert into public.proof_of_delivery (tenant_id, company_id, delivery_id, route_stop_id, pod_type, recipient_name,
    recipient_document, signature_ref, photo_url, lat, lng, confirmation_code)
  values (v_tenant, p_company, p_delivery, v_stop, coalesce(p_pod_type,'signature'), p_recipient, p_document,
    p_signature, p_photo, p_lat, p_lng, p_code) returning * into r;
  update public.deliveries set status='delivered', delivered_at=now() where id=p_delivery and company_id=p_company;
  if v_stop is not null then update public.route_stops set status='completed', completed_at=now() where id=v_stop; end if;
  return r;
end; $$;
grant execute on function public.register_pod(uuid,uuid,text,text,text,text,numeric,numeric,text,text) to authenticated;

-- Registra tentativa de entrega falha (ocorrência)
create or replace function public.record_delivery_attempt(p_company uuid, p_delivery uuid, p_reason text)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_n int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('distribution.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select coalesce(max(attempt_number),0)+1 into v_n from public.delivery_attempts where delivery_id=p_delivery;
  insert into public.delivery_attempts (tenant_id, company_id, delivery_id, attempt_number, reason)
    values (v_tenant, p_company, p_delivery, v_n, p_reason);
  update public.deliveries set status='failed', attempts=v_n where id=p_delivery and company_id=p_company;
  return v_n;
end; $$;
grant execute on function public.record_delivery_attempt(uuid,uuid,text) to authenticated;

create or replace function public.lmdp_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb; v_total int; v_deliv int; v_ontime int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select count(*) into v_total from public.deliveries where company_id=p_company and deleted_at is null;
  select count(*) into v_deliv from public.deliveries where company_id=p_company and status='delivered' and deleted_at is null;
  select count(*) into v_ontime from public.deliveries where company_id=p_company and status='delivered' and deleted_at is null
    and (window_end is null or delivered_at <= window_end);
  select jsonb_build_object(
    'total', v_total,
    'delivered', v_deliv,
    'pending', (select count(*) from public.deliveries where company_id=p_company and status='pending' and deleted_at is null),
    'out_for_delivery', (select count(*) from public.deliveries where company_id=p_company and status='out_for_delivery' and deleted_at is null),
    'failed', (select count(*) from public.deliveries where company_id=p_company and status='failed' and deleted_at is null),
    'otd_pct', case when v_deliv>0 then round(100.0*v_ontime/v_deliv,1) else null end,
    'routes_active', (select count(*) from public.routes where company_id=p_company and started_at is not null and deleted_at is null),
    'stops_pending', (select count(*) from public.route_stops where company_id=p_company and status='pending' and deleted_at is null),
    'attempts_failed', (select count(*) from public.delivery_attempts da join public.deliveries d on d.id=da.delivery_id where d.company_id=p_company),
    'pods', (select count(*) from public.proof_of_delivery where company_id=p_company and deleted_at is null),
    'geofences', (select count(*) from public.geofences where company_id=p_company and status='active' and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.lmdp_dashboard(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.lmdp_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_late int; v_att int; v_nopod int; v_unopt int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'LMDP%' and deleted_at is null;

  select count(*) into v_late from public.deliveries where company_id=p_company and status not in ('delivered','failed')
    and window_end is not null and window_end < now() and deleted_at is null;
  if v_late > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'LMDP: entregas fora da janela', v_late||' entrega(s) com janela vencida e não concluídas.', 'Repriorizar/roteirizar ou avisar o cliente do atraso.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_att from public.deliveries where company_id=p_company and status='failed' and coalesce(attempts,0) >= 3 and deleted_at is null;
  if v_att > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'LMDP: entregas com 3+ tentativas', v_att||' entrega(s) falharam 3x ou mais.', 'Contatar cliente/validar endereço antes de nova tentativa.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_nopod from public.deliveries d where d.company_id=p_company and d.status='delivered' and d.deleted_at is null
    and not exists (select 1 from public.proof_of_delivery p where p.delivery_id=d.id and p.deleted_at is null);
  if v_nopod > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'info', 'LMDP: entregas sem POD', v_nopod||' entrega(s) concluída(s) sem prova de entrega.', 'Exigir assinatura/foto/código na baixa da entrega.', 74);
    v_c := v_c + 1;
  end if;
  select count(distinct route_id) into v_unopt from public.route_stops where company_id=p_company and sequence is null and status='pending' and deleted_at is null;
  if v_unopt > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'LMDP: rotas não otimizadas', v_unopt||' rota(s) com paradas sem sequenciamento.', 'Rodar a otimização de rota para reduzir km e tempo.', 70);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.lmdp_insights(uuid) to authenticated;

-- ── SEED (empresa Matriz Logística) ─────────────────────────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;
  if not exists (select 1 from public.geofences where company_id=v_company and deleted_at is null) then
    insert into public.geofences (tenant_id, company_id, code, name, geofence_type, center_lat, center_lng, radius_m) values
      (v_tenant, v_company, 'GEO-CD', 'CD Matriz', 'distribution_center', -23.5505, -46.6333, 500),
      (v_tenant, v_company, 'GEO-RISK', 'Zona de risco - Centro', 'risk_area', -23.5560, -46.6390, 800);
  end if;
end $seed$;

notify pgrst, 'reload schema';
