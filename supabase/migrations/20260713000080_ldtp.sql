-- ============================================================================
-- VOLUME 46 · LDTP — LOGISTICS DIGITAL TWIN PLATFORM (migration 080)
-- Réplica digital VIVA da operação: objetos digitais sincronizados das tabelas
-- físicas (docks/yard/hubs/warehouses/fleet), detecção automática de gargalos,
-- simulação what-if determinística (cenários), snapshots p/ reprodução histórica.
-- Nível Siemens Digital Twin/Azure Digital Twins/AnyLogic. Recurso 'controltower'.
-- Padrão: colunas-padrão, text+check, coluna gerada imutável, grant por-tabela.
-- ============================================================================

-- ── 1) OBJETOS DIGITAIS (réplica) ────────────────────────────────────────────
create table if not exists public.twin_objects (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  object_type text not null default 'dc' check (object_type in ('dc','warehouse','dock','yard','fleet','vehicle','hub','route','carrier','network')),
  ref_id uuid,
  code text not null,
  name text,
  capacity numeric(14,2),
  current_load numeric(14,2) not null default 0,
  utilization_pct numeric(6,2) generated always as (
    case when capacity is not null and capacity > 0 then round((100.0 * current_load / capacity)::numeric, 2) else null end
  ) stored,
  status text not null default 'ok' check (status in ('ok','warning','critical','offline')),
  state jsonb not null default '{}'::jsonb,
  last_synced_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  constraint twin_objects_uk unique (company_id, code)
);

-- ── 2) GARGALOS detectados ───────────────────────────────────────────────────
create table if not exists public.twin_bottlenecks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  twin_object_id uuid references public.twin_objects(id) on delete cascade,
  bottleneck_type text not null default 'congestion' check (bottleneck_type in ('congestion','queue','capacity_exceeded','critical_route','overloaded_equipment','dock_unavailable','vehicle_shortage')),
  severity text not null default 'medium' check (severity in ('low','medium','high','critical')),
  value numeric(14,2), threshold numeric(14,2),
  detected_at timestamptz not null default now(),
  status text not null default 'open' check (status in ('open','resolved')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 3) SIMULAÇÕES what-if ────────────────────────────────────────────────────
create table if not exists public.twin_simulations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  scenario_name text not null,
  scenario_type text not null default 'demand_increase' check (scenario_type in ('new_carrier','new_dc','new_hub','close_unit','demand_increase','route_change','modal_change','strike','roadblock','weather','accident','disruption')),
  assumptions jsonb not null default '{}'::jsonb,
  baseline jsonb,
  result jsonb,
  delta jsonb,
  status text not null default 'draft' check (status in ('draft','completed')),
  run_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 4) SNAPSHOTS (reprodução histórica) ──────────────────────────────────────
create table if not exists public.twin_snapshots (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  captured_at timestamptz not null default now(),
  object_count integer not null default 0,
  avg_utilization numeric(6,2),
  bottlenecks integer not null default 0,
  kpis jsonb not null default '{}'::jsonb,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_twin_obj_type on public.twin_objects (company_id, object_type);
create index if not exists idx_twin_bott_obj on public.twin_bottlenecks (twin_object_id);
create index if not exists idx_twin_snap_at on public.twin_snapshots (company_id, captured_at);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'controltower') ────
do $do$
declare t text; specs text[] := array['twin_objects','twin_bottlenecks','twin_simulations','twin_snapshots'];
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

-- ── helper de upsert de objeto digital ───────────────────────────────────────
create or replace function app.twin_upsert(p_tenant uuid, p_company uuid, p_type text, p_ref uuid, p_code text, p_name text, p_cap numeric, p_load numeric, p_state jsonb)
returns void language sql as $$
  insert into public.twin_objects (tenant_id, company_id, object_type, ref_id, code, name, capacity, current_load, state, status, last_synced_at)
  values (p_tenant, p_company, p_type, p_ref, p_code, p_name, p_cap, p_load, coalesce(p_state,'{}'::jsonb),
    case when p_cap is not null and p_cap>0 and p_load/p_cap >= 0.9 then 'critical'
         when p_cap is not null and p_cap>0 and p_load/p_cap >= 0.75 then 'warning' else 'ok' end, now())
  on conflict (company_id, code) do update set
    current_load=excluded.current_load, capacity=excluded.capacity, state=excluded.state,
    status=excluded.status, last_synced_at=now(), ref_id=excluded.ref_id, name=excluded.name;
$$;

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- Motor de sincronização: espelha o estado físico nos objetos digitais
create or replace function public.sync_twin(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_n int := 0; rec record;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;

  -- DOCAS: capacidade 1 cada, carga = 1 se ocupada
  for rec in select id, code, status from public.docks where company_id=p_company and deleted_at is null loop
    perform app.twin_upsert(v_tenant, p_company, 'dock', rec.id, 'DOCK:'||rec.code, 'Doca '||rec.code, 1,
      case when rec.status in ('occupied','busy') then 1 else 0 end,
      jsonb_build_object('dock_status', rec.status));
    v_n := v_n + 1;
  end loop;

  -- PÁTIO (zonas): capacidade = nº de vagas, carga = vagas ocupadas
  for rec in select z.id, z.code, z.name,
      (select count(*) from public.yard_slots s where s.yard_zone_id=z.id and s.deleted_at is null) cap,
      (select count(*) from public.yard_slots s where s.yard_zone_id=z.id and s.status='occupied' and s.deleted_at is null) occ
    from public.yard_zones z where z.company_id=p_company and z.deleted_at is null loop
    perform app.twin_upsert(v_tenant, p_company, 'yard', rec.id, 'YARD:'||rec.code, coalesce(rec.name, rec.code), nullif(rec.cap,0)::numeric, rec.occ::numeric,
      jsonb_build_object('slots', rec.cap, 'occupied', rec.occ));
    v_n := v_n + 1;
  end loop;

  -- HUBS: capacidade informada, status congested marca carga alta
  for rec in select id, code, name, capacity, status from public.hubs where company_id=p_company and deleted_at is null loop
    perform app.twin_upsert(v_tenant, p_company, 'hub', rec.id, 'HUB:'||rec.code, coalesce(rec.name, rec.code), rec.capacity,
      case when rec.status='congested' then coalesce(rec.capacity,100)*0.95 else coalesce(rec.capacity,100)*0.4 end,
      jsonb_build_object('hub_status', rec.status));
    v_n := v_n + 1;
  end loop;

  -- FROTA (agregado): capacidade = total veículos, carga = em uso
  -- frota "em uso" = veículos alocados a rotas ativas (started_at, sem status na tabela vehicles)
  perform app.twin_upsert(v_tenant, p_company, 'fleet', null, 'FLEET:ALL', 'Frota',
    (select count(*)::numeric from public.vehicles where company_id=p_company and deleted_at is null),
    (select count(distinct r.vehicle_id)::numeric from public.routes r where r.company_id=p_company and r.vehicle_id is not null and r.started_at is not null and r.deleted_at is null),
    jsonb_build_object('total', (select count(*) from public.vehicles where company_id=p_company and deleted_at is null)));
  v_n := v_n + 1;

  -- CDs (warehouses)
  for rec in select id, code, name from public.warehouses where company_id=p_company and deleted_at is null loop
    perform app.twin_upsert(v_tenant, p_company, 'dc', rec.id, 'DC:'||rec.code, coalesce(rec.name, rec.code), null, 0, '{}'::jsonb);
    v_n := v_n + 1;
  end loop;

  return v_n;
end; $$;
grant execute on function public.sync_twin(uuid) to authenticated;

-- Detecta gargalos a partir do estado digital
create or replace function public.detect_bottlenecks(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_n int := 0; rec record;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  -- fecha gargalos antigos abertos (serão recriados se persistirem)
  update public.twin_bottlenecks set status='resolved' where company_id=p_company and status='open';
  for rec in select id, object_type, code, utilization_pct from public.twin_objects
    where company_id=p_company and deleted_at is null and utilization_pct is not null and utilization_pct >= 85 loop
    insert into public.twin_bottlenecks (tenant_id, company_id, twin_object_id, bottleneck_type, severity, value, threshold)
    values (v_tenant, p_company, rec.id,
      case rec.object_type when 'dock' then 'dock_unavailable' when 'yard' then 'congestion' when 'fleet' then 'vehicle_shortage' when 'hub' then 'capacity_exceeded' else 'capacity_exceeded' end,
      case when rec.utilization_pct >= 95 then 'critical' else 'high' end, rec.utilization_pct, 85);
    v_n := v_n + 1;
  end loop;
  return v_n;
end; $$;
grant execute on function public.detect_bottlenecks(uuid) to authenticated;

-- Simulação what-if determinística: baseline (dados vivos) + efeitos do cenário
create or replace function public.run_simulation(p_company uuid, p_name text, p_scenario_type text, p_assumptions jsonb default '{}'::jsonb)
returns public.twin_simulations language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.twin_simulations;
  v_util numeric; v_lead numeric; v_cost numeric := 100; v_sla numeric := 92; v_otif numeric := 90; v_p numeric;
  b jsonb; res jsonb;
  f_cost numeric := 1; f_lead numeric := 1; f_util numeric := 1; f_sla numeric := 1; f_otif numeric := 1;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  v_p := coalesce((p_assumptions->>'pct')::numeric, 20);
  select round(coalesce(avg(utilization_pct),50),1) into v_util from public.twin_objects where company_id=p_company and utilization_pct is not null and deleted_at is null;
  select round(coalesce(avg(transit_days),5),1) into v_lead from public.intl_shipments where company_id=p_company and transit_days is not null and deleted_at is null;
  if v_lead is null or v_lead=0 then v_lead := 5; end if;

  case p_scenario_type
    when 'demand_increase' then f_util:=1+v_p/100; f_cost:=1+v_p/200; f_lead:=1+v_p/150; f_sla:=1-v_p/500; f_otif:=1-v_p/400;
    when 'new_dc' then f_lead:=0.85; f_cost:=1.10; f_util:=0.80; f_sla:=1.03;
    when 'new_hub' then f_lead:=0.92; f_util:=0.90; f_cost:=1.05;
    when 'new_carrier' then f_cost:=0.92; f_otif:=1.05; f_sla:=1.02;
    when 'close_unit' then f_util:=1.25; f_lead:=1.10; f_sla:=0.95;
    when 'route_change' then f_lead:=0.95; f_cost:=0.97;
    when 'modal_change' then f_lead:=1.20; f_cost:=0.80;
    when 'strike' then f_sla:=0.70; f_lead:=1.40; f_cost:=1.15; f_otif:=0.75;
    when 'roadblock' then f_sla:=0.80; f_lead:=1.30; f_cost:=1.10; f_otif:=0.85;
    when 'weather' then f_sla:=0.85; f_lead:=1.25; f_otif:=0.88;
    when 'accident' then f_sla:=0.82; f_lead:=1.28; f_cost:=1.08;
    else f_lead:=1.15; f_sla:=0.85; f_cost:=1.10; f_otif:=0.85; -- disruption genérica
  end case;

  b := jsonb_build_object('cost_index', v_cost, 'lead_time_days', v_lead, 'utilization_pct', v_util, 'sla_pct', v_sla, 'otif_pct', v_otif);
  res := jsonb_build_object(
    'cost_index', round(v_cost*f_cost,1),
    'lead_time_days', round(v_lead*f_lead,1),
    'utilization_pct', least(100, round(v_util*f_util,1)),
    'sla_pct', least(100, round(v_sla*f_sla,1)),
    'otif_pct', least(100, round(v_otif*f_otif,1)));
  insert into public.twin_simulations (tenant_id, company_id, scenario_name, scenario_type, assumptions, baseline, result,
    delta, status, run_at)
  values (v_tenant, p_company, p_name, p_scenario_type, coalesce(p_assumptions,'{}'::jsonb), b, res,
    jsonb_build_object(
      'cost_index', round((v_cost*f_cost)-v_cost,1),
      'lead_time_days', round((v_lead*f_lead)-v_lead,1),
      'utilization_pct', round((v_util*f_util)-v_util,1),
      'sla_pct', round((v_sla*f_sla)-v_sla,1),
      'otif_pct', round((v_otif*f_otif)-v_otif,1)),
    'completed', now()) returning * into r;
  return r;
end; $$;
grant execute on function public.run_simulation(uuid,text,text,jsonb) to authenticated;

-- Captura snapshot do estado atual (reprodução histórica)
create or replace function public.capture_twin_snapshot(p_company uuid)
returns public.twin_snapshots language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.twin_snapshots; v_cnt int; v_util numeric; v_bot int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select count(*), round(coalesce(avg(utilization_pct),0),1) into v_cnt, v_util from public.twin_objects where company_id=p_company and deleted_at is null;
  select count(*) into v_bot from public.twin_bottlenecks where company_id=p_company and status='open' and deleted_at is null;
  insert into public.twin_snapshots (tenant_id, company_id, object_count, avg_utilization, bottlenecks, kpis)
    values (v_tenant, p_company, v_cnt, v_util, v_bot, jsonb_build_object('objects', v_cnt, 'avg_utilization', v_util, 'bottlenecks', v_bot))
    returning * into r;
  return r;
end; $$;
grant execute on function public.capture_twin_snapshot(uuid) to authenticated;

create or replace function public.ldtp_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'objects', (select count(*) from public.twin_objects where company_id=p_company and deleted_at is null),
    'avg_utilization', (select round(avg(utilization_pct),1) from public.twin_objects where company_id=p_company and utilization_pct is not null and deleted_at is null),
    'critical_objects', (select count(*) from public.twin_objects where company_id=p_company and status='critical' and deleted_at is null),
    'bottlenecks_open', (select count(*) from public.twin_bottlenecks where company_id=p_company and status='open' and deleted_at is null),
    'simulations', (select count(*) from public.twin_simulations where company_id=p_company and deleted_at is null),
    'snapshots', (select count(*) from public.twin_snapshots where company_id=p_company and deleted_at is null),
    'last_sync', (select max(last_synced_at) from public.twin_objects where company_id=p_company and deleted_at is null),
    'by_type', (select coalesce(jsonb_object_agg(object_type, n), '{}'::jsonb) from (select object_type, count(*) n from public.twin_objects where company_id=p_company and deleted_at is null group by object_type) x)
  ) into v;
  return v;
end; $$;
grant execute on function public.ldtp_dashboard(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.ldtp_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_bot int; v_crit int; v_stale int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'LDTP%' and deleted_at is null;

  select count(*) into v_bot from public.twin_bottlenecks where company_id=p_company and status='open' and severity in ('high','critical') and deleted_at is null;
  if v_bot > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'LDTP: gargalos detectados no gêmeo digital', v_bot||' gargalo(s) grave(s) na réplica.', 'Rebalancear recursos ou rodar simulação de alívio.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_crit from public.twin_objects where company_id=p_company and status='critical' and deleted_at is null;
  if v_crit > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'LDTP: capacidade no limite', v_crit||' objeto(s) com utilização crítica (>=90%).', 'Expandir capacidade ou redistribuir carga.', 82);
    v_c := v_c + 1;
  end if;
  select case when max(last_synced_at) is null or max(last_synced_at) < now()-interval '24 hours' then 1 else 0 end into v_stale
    from public.twin_objects where company_id=p_company and deleted_at is null;
  if v_stale = 1 and exists (select 1 from public.twin_objects where company_id=p_company and deleted_at is null) then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'info', 'LDTP: gêmeo digital desatualizado', 'A réplica não é sincronizada há mais de 24h.', 'Rodar sync_twin para refletir a operação atual.', 70);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.ldtp_insights(uuid) to authenticated;

notify pgrst, 'reload schema';
