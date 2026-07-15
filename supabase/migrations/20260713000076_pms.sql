-- ============================================================================
-- VOLUME 42 · PMS — PARCEL MANAGEMENT SYSTEM (migration 076)
-- Gestão de CADA volume individual na jornada logística, sobre a tabela
-- `volumes` (recurso 'ldm', da mig 071) + tracking_points. Nível UPS/FedEx/DHL:
-- LPN/etiquetas, scan events granulares, hubs/centros de triagem, lockers,
-- consolidação/desconsolidação. Reusa recurso RBAC 'ldm'. Escopo 100% logística.
-- volumes.status é TEXT (livre). Padrão: colunas-padrão, text+check, grant p/tabela.
-- ============================================================================

-- ── volumes: identificação individual (ADD, não destrutivo) ─────────────────
alter table public.volumes add column if not exists lpn text;
alter table public.volumes add column if not exists barcode text;
alter table public.volumes add column if not exists qr_code text;
alter table public.volumes add column if not exists rfid text;
alter table public.volumes add column if not exists seal_number text;
alter table public.volumes add column if not exists current_hub_id uuid;
alter table public.volumes add column if not exists consolidation_id uuid;

-- ── 1) HUBS / centros de triagem ─────────────────────────────────────────────
create table if not exists public.hubs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  name text,
  hub_type text not null default 'hub' check (hub_type in ('sorting_center','distribution_center','hub','mini_hub','locker_station','pickup_point','agency','cross_dock')),
  address text, city text, state text,
  capacity integer,
  status text not null default 'active' check (status in ('active','congested','inactive')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 2) ETIQUETAS / LPN ───────────────────────────────────────────────────────
create table if not exists public.parcel_labels (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  volume_id uuid not null references public.volumes(id) on delete cascade,
  lpn text,
  barcode text,
  qr_code text,
  carrier_id uuid references public.carriers(id) on delete set null,
  layout text,
  status text not null default 'active' check (status in ('active','reprinted','canceled')),
  printed_at timestamptz not null default now(),
  reprint_count integer not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 3) SCAN EVENTS granulares ────────────────────────────────────────────────
create table if not exists public.scan_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  volume_id uuid not null references public.volumes(id) on delete cascade,
  scan_type text not null default 'entry' check (scan_type in ('entry','exit','transfer','check','sortation','load','unload','delivery','pickup')),
  hub_id uuid references public.hubs(id) on delete set null,
  operator_id uuid references auth.users(id),
  scanned_at timestamptz not null default now(),
  location text,
  notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 4) LOCKERS + atribuições ─────────────────────────────────────────────────
create table if not exists public.lockers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  hub_id uuid references public.hubs(id) on delete set null,
  total_compartments integer not null default 20,
  available_compartments integer not null default 20,
  status text not null default 'active' check (status in ('active','full','inactive')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create table if not exists public.locker_assignments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  locker_id uuid not null references public.lockers(id) on delete cascade,
  volume_id uuid references public.volumes(id) on delete set null,
  compartment_no integer,
  pickup_code text,
  assigned_at timestamptz not null default now(),
  expires_at timestamptz,
  picked_up_at timestamptz,
  attempts integer not null default 0,
  status text not null default 'awaiting_pickup' check (status in ('reserved','awaiting_pickup','picked_up','expired','returned')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 5) CONSOLIDAÇÃO / DESCONSOLIDAÇÃO ────────────────────────────────────────
create table if not exists public.parcel_consolidations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  master_code text not null,
  consolidation_type text not null default 'consolidation' check (consolidation_type in ('consolidation','deconsolidation')),
  hub_id uuid references public.hubs(id) on delete set null,
  volume_count integer not null default 0,
  status text not null default 'open' check (status in ('open','closed')),
  closed_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_labels_volume on public.parcel_labels (volume_id);
create index if not exists idx_scan_volume on public.scan_events (volume_id);
create index if not exists idx_scan_hub on public.scan_events (hub_id);
create index if not exists idx_locker_assign_locker on public.locker_assignments (locker_id);
create index if not exists idx_volumes_consolidation on public.volumes (consolidation_id);
create index if not exists idx_volumes_hub on public.volumes (current_hub_id);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'ldm') ────────────
do $do$
declare t text; specs text[] := array['hubs','parcel_labels','scan_events','lockers','locker_assignments','parcel_consolidations'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'ldm.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'ldm.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- Gera LPN + código de barras + etiqueta para um volume
create or replace function public.generate_lpn(p_company uuid, p_volume uuid)
returns public.volumes language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.volumes; v_lpn text; v_bar text;
begin
  if not (app.can_access_company(p_company) and app.has_permission('ldm.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  v_lpn := 'LPN'||upper(substr(md5(gen_random_uuid()::text),1,10));
  v_bar := translate(substr(md5(v_lpn),1,12), 'abcdef', '012345'); -- 12 dígitos numéricos
  update public.volumes set lpn=v_lpn, barcode=v_bar, qr_code=v_lpn where id=p_volume and company_id=p_company returning * into r;
  if r.id is null then raise exception 'Volume não encontrado'; end if;
  insert into public.parcel_labels (tenant_id, company_id, volume_id, lpn, barcode, qr_code, carrier_id)
    values (v_tenant, p_company, p_volume, v_lpn, v_bar, v_lpn, r.carrier_id);
  return r;
end; $$;
grant execute on function public.generate_lpn(uuid,uuid) to authenticated;

-- Registra um scan e atualiza status/hub do volume + ponto de rastreio
create or replace function public.scan_parcel(p_company uuid, p_volume uuid, p_scan_type text, p_hub uuid default null, p_location text default null, p_notes text default null)
returns public.scan_events language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.scan_events; v_status text; v_hubname text;
begin
  if not (app.can_access_company(p_company) and app.has_permission('ldm.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.scan_events (tenant_id, company_id, volume_id, scan_type, hub_id, operator_id, location, notes)
    values (v_tenant, p_company, p_volume, p_scan_type, p_hub, auth.uid(), p_location, p_notes) returning * into r;
  -- volumes.status é restrito a (open,packed,shipped,delivered,returned); jornada fina fica nos scan_events
  v_status := case p_scan_type
    when 'entry' then 'open'
    when 'sortation' then 'shipped' when 'unload' then 'shipped' when 'load' then 'shipped'
    when 'transfer' then 'shipped' when 'exit' then 'shipped'
    when 'delivery' then 'delivered' when 'pickup' then 'delivered' else null end;
  if v_status is not null then
    update public.volumes set status=v_status, current_hub_id=coalesce(p_hub, current_hub_id) where id=p_volume and company_id=p_company;
  elsif p_hub is not null then
    update public.volumes set current_hub_id=p_hub where id=p_volume and company_id=p_company;
  end if;
  -- integra com o tracking: adiciona ponto textual
  select name into v_hubname from public.hubs where id=p_hub;
  begin
    insert into public.tracking_points (tenant_id, company_id, volume_id, event, city, occurred_at)
      values (v_tenant, p_company, p_volume, p_scan_type||coalesce(' @ '||v_hubname,''), v_hubname, now());
  exception when others then null; -- tracking_points é best-effort (schema pode diferir)
  end;
  return r;
end; $$;
grant execute on function public.scan_parcel(uuid,uuid,text,uuid,text,text) to authenticated;

-- Consolida volumes num master (ou desconsolida)
create or replace function public.consolidate_volumes(p_company uuid, p_master text, p_hub uuid, p_volumes uuid[], p_type text default 'consolidation')
returns public.parcel_consolidations language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.parcel_consolidations; v_n int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('ldm.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.parcel_consolidations (tenant_id, company_id, master_code, consolidation_type, hub_id, volume_count)
    values (v_tenant, p_company, p_master, coalesce(p_type,'consolidation'), p_hub, coalesce(array_length(p_volumes,1),0)) returning * into r;
  if p_type = 'deconsolidation' then
    update public.volumes set consolidation_id=null where consolidation_id=(select id from public.parcel_consolidations where master_code=p_master and company_id=p_company order by created_at limit 1) and company_id=p_company;
  else
    update public.volumes set consolidation_id=r.id where id = any(p_volumes) and company_id=p_company;
  end if;
  select count(*) into v_n from public.volumes where consolidation_id=r.id;
  update public.parcel_consolidations set volume_count=v_n where id=r.id;
  return r;
end; $$;
grant execute on function public.consolidate_volumes(uuid,text,uuid,uuid[],text) to authenticated;

-- Atribui um volume a um locker (gera código de retirada + validade)
create or replace function public.assign_locker(p_company uuid, p_volume uuid, p_locker uuid, p_hours integer default 72)
returns public.locker_assignments language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.locker_assignments; v_avail int; v_comp int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('ldm.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select available_compartments into v_avail from public.lockers where id=p_locker and company_id=p_company for update;
  if coalesce(v_avail,0) <= 0 then raise exception 'Locker sem compartimento disponível'; end if;
  v_comp := (select total_compartments from public.lockers where id=p_locker) - v_avail + 1;
  insert into public.locker_assignments (tenant_id, company_id, locker_id, volume_id, compartment_no, pickup_code, expires_at)
    values (v_tenant, p_company, p_locker, p_volume, v_comp, upper(substr(md5(gen_random_uuid()::text),1,6)), now() + make_interval(hours => coalesce(p_hours,72))) returning * into r;
  update public.lockers set available_compartments = available_compartments - 1,
    status = case when available_compartments - 1 <= 0 then 'full' else status end where id=p_locker;
  return r;
end; $$;
grant execute on function public.assign_locker(uuid,uuid,uuid,integer) to authenticated;

create or replace function public.pms_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'volumes', (select count(*) from public.volumes where company_id=p_company and deleted_at is null),
    'in_transit', (select count(*) from public.volumes where company_id=p_company and status='shipped' and deleted_at is null),
    'at_hub', (select count(*) from public.volumes where company_id=p_company and status in ('open','packed') and deleted_at is null),
    'delivered', (select count(*) from public.volumes where company_id=p_company and status='delivered' and deleted_at is null),
    'returned', (select count(*) from public.volumes where company_id=p_company and status='returned' and deleted_at is null),
    'hubs', (select count(*) from public.hubs where company_id=p_company and deleted_at is null),
    'hubs_congested', (select count(*) from public.hubs where company_id=p_company and status='congested' and deleted_at is null),
    'scans_today', (select count(*) from public.scan_events where company_id=p_company and scanned_at::date=now()::date and deleted_at is null),
    'lockers_awaiting', (select count(*) from public.locker_assignments where company_id=p_company and status='awaiting_pickup' and deleted_at is null),
    'labels', (select count(*) from public.parcel_labels where company_id=p_company and deleted_at is null),
    'consolidations_open', (select count(*) from public.parcel_consolidations where company_id=p_company and status='open' and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.pms_dashboard(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.pms_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_stuck int; v_lost int; v_lexp int; v_cong int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'PMS%' and deleted_at is null;

  -- volumes parados: sem scan há 48h e não entregues/cancelados
  select count(*) into v_stuck from public.volumes v where v.company_id=p_company and v.deleted_at is null
    and coalesce(v.status,'') not in ('delivered','collected','canceled','returned')
    and not exists (select 1 from public.scan_events s where s.volume_id=v.id and s.scanned_at > now()-interval '48 hours' and s.deleted_at is null)
    and v.created_at < now()-interval '48 hours';
  if v_stuck > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'PMS: volumes parados', v_stuck||' volume(s) sem leitura há mais de 48h.', 'Localizar e reprocessar; possível extravio.', 84);
    v_c := v_c + 1;
  end if;
  -- leituras duplicadas (mesmo volume+scan em <10 min) — possível erro de bipagem
  select count(*) into v_lost from (
    select volume_id from public.scan_events
    where company_id=p_company and deleted_at is null and scanned_at > now()-interval '10 minutes'
    group by volume_id, scan_type having count(*) > 1) x;
  if v_lost > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'PMS: leituras duplicadas', v_lost||' volume(s) com leitura duplicada recente.', 'Verificar bipagem/etiqueta duplicada no hub.', 78);
    v_c := v_c + 1;
  end if;
  select count(*) into v_lexp from public.locker_assignments where company_id=p_company and status='awaiting_pickup' and expires_at is not null and expires_at < now() and deleted_at is null;
  if v_lexp > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'PMS: lockers expirados', v_lexp||' retirada(s) de locker expirada(s).', 'Reverter à logística reversa e liberar o compartimento.', 74);
    v_c := v_c + 1;
  end if;
  select count(*) into v_cong from public.hubs where company_id=p_company and status='congested' and deleted_at is null;
  if v_cong > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'PMS: hubs congestionados', v_cong||' hub(s) em congestionamento.', 'Redistribuir fluxo ou reforçar equipe de triagem.', 80);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.pms_insights(uuid) to authenticated;

-- ── SEED (empresa Matriz Logística) ─────────────────────────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;
  if not exists (select 1 from public.hubs where company_id=v_company and deleted_at is null) then
    insert into public.hubs (tenant_id, company_id, code, name, hub_type, city, state, capacity, status) values
      (v_tenant, v_company, 'HUB-SP', 'Centro de Triagem SP', 'sorting_center', 'São Paulo', 'SP', 50000, 'active'),
      (v_tenant, v_company, 'HUB-RJ', 'Hub Rio', 'hub', 'Rio de Janeiro', 'RJ', 20000, 'congested'),
      (v_tenant, v_company, 'LKR-01', 'Locker Station Centro', 'locker_station', 'São Paulo', 'SP', 40, 'active');
    insert into public.lockers (tenant_id, company_id, code, hub_id, total_compartments, available_compartments)
      values (v_tenant, v_company, 'LOCKER-A', (select id from public.hubs where code='LKR-01' and company_id=v_company), 20, 20);
  end if;
end $seed$;

notify pgrst, 'reload schema';
