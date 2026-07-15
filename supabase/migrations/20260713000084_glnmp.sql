-- ============================================================================
-- VOLUME 50 · GLNMP — GLOBAL LOGISTICS NETWORK MANAGEMENT PLATFORM (migration 084)
-- ÚLTIMO volume da arquitetura principal. Modela/planeja/otimiza a MALHA logística:
-- nós (instalações), lanes (conexões), fluxos, capacidade, cobertura e simulação
-- estratégica de rede. Nível Amazon Logistics Network/DHL Supply Chain/Kinaxis.
-- Sincroniza a topologia das instalações físicas (warehouses/hubs/customs_zones).
-- Recurso 'controltower'. Escopo 100% logística. Padrão: colunas-padrão, text+check.
-- ============================================================================

-- ── 1) NÓS DA REDE (instalações) ─────────────────────────────────────────────
create table if not exists public.glnmp_nodes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  node_code text not null,
  node_type text not null default 'dc' check (node_type in ('dc','warehouse','mini_hub','cross_dock','dark_warehouse','road_terminal','rail_terminal','seaport','airport','bonded_zone','consolidation','deconsolidation','locker','pickup_point','base')),
  ref_id uuid,
  name text,
  region text, country text,
  lat numeric(9,6), lng numeric(9,6),
  capacity numeric(16,2),
  current_load numeric(16,2) not null default 0,
  utilization_pct numeric(6,2) generated always as (
    case when capacity is not null and capacity > 0 then round((100.0 * current_load / capacity)::numeric, 2) else null end
  ) stored,
  cost_per_unit numeric(12,4),
  status text not null default 'active' check (status in ('active','saturated','inactive','planned')),
  last_synced_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  constraint glnmp_nodes_uk unique (company_id, node_code)
);

-- ── 2) LANES (conexões entre nós) ────────────────────────────────────────────
create table if not exists public.glnmp_lanes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text,
  from_node_id uuid references public.glnmp_nodes(id) on delete cascade,
  to_node_id uuid references public.glnmp_nodes(id) on delete cascade,
  lane_type text not null default 'cd_hub' check (lane_type in ('cd_cd','cd_hub','hub_hub','hub_client','supplier_cd','port_cd','airport_hub','terminal_port','multimodal')),
  modal text,
  distance_km numeric(12,2),
  transit_days numeric(6,2),
  cost_per_trip numeric(14,2),
  capacity numeric(16,2),
  current_flow numeric(16,2) not null default 0,
  status text not null default 'active' check (status in ('active','congested','inactive','planned')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 3) FLUXOS logísticos ─────────────────────────────────────────────────────
create table if not exists public.glnmp_flows (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  lane_id uuid references public.glnmp_lanes(id) on delete set null,
  flow_type text not null default 'distribution' check (flow_type in ('inbound','outbound','transfer','cross_dock','milk_run','distribution','last_mile','middle_mile','first_mile','reverse','international')),
  volume numeric(16,2),
  period_year integer, period_month integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 4) CENÁRIOS de rede (network design) ─────────────────────────────────────
create table if not exists public.glnmp_scenarios (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null,
  scenario_type text not null default 'new_dc' check (scenario_type in ('new_dc','close_unit','new_hub','new_lane','new_carrier','new_region','demand_increase','crisis','weather','rebalance')),
  assumptions jsonb not null default '{}'::jsonb,
  baseline jsonb, result jsonb, delta jsonb,
  status text not null default 'draft' check (status in ('draft','completed')),
  run_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_glnmp_nodes_region on public.glnmp_nodes (company_id, region);
create index if not exists idx_glnmp_lanes_from on public.glnmp_lanes (from_node_id);
create index if not exists idx_glnmp_lanes_to on public.glnmp_lanes (to_node_id);
create index if not exists idx_glnmp_flows_lane on public.glnmp_flows (lane_id);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'controltower') ────
do $do$
declare t text; specs text[] := array['glnmp_nodes','glnmp_lanes','glnmp_flows','glnmp_scenarios'];
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

-- helper de upsert de nó
create or replace function app.glnmp_upsert(p_tenant uuid, p_company uuid, p_type text, p_ref uuid, p_code text, p_name text, p_region text, p_cap numeric, p_load numeric)
returns void language sql as $$
  insert into public.glnmp_nodes (tenant_id, company_id, node_type, ref_id, node_code, name, region, capacity, current_load, status, last_synced_at)
  values (p_tenant, p_company, p_type, p_ref, p_code, p_name, p_region, p_cap, p_load,
    case when p_cap is not null and p_cap>0 and p_load/p_cap >= 0.9 then 'saturated' else 'active' end, now())
  on conflict (company_id, node_code) do update set
    current_load=excluded.current_load, capacity=excluded.capacity, name=excluded.name, region=excluded.region,
    status=excluded.status, last_synced_at=now();
$$;

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- Sincroniza a topologia da rede a partir das instalações físicas
create or replace function public.sync_network(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_n int := 0; rec record;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;

  for rec in select id, code, name from public.warehouses where company_id=p_company and deleted_at is null loop
    perform app.glnmp_upsert(v_tenant, p_company, 'dc', rec.id, 'DC:'||rec.code, coalesce(rec.name, rec.code), null, null, 0);
    v_n := v_n + 1;
  end loop;
  for rec in select id, code, name, hub_type, city, capacity, status from public.hubs where company_id=p_company and deleted_at is null loop
    perform app.glnmp_upsert(v_tenant, p_company,
      case rec.hub_type when 'sorting_center' then 'cross_dock' when 'distribution_center' then 'dc' when 'mini_hub' then 'mini_hub'
        when 'locker_station' then 'locker' when 'pickup_point' then 'pickup_point' when 'agency' then 'base' when 'cross_dock' then 'cross_dock' else 'mini_hub' end,
      rec.id, 'HUB:'||rec.code, coalesce(rec.name, rec.code), rec.city, rec.capacity,
      case when rec.status='congested' then coalesce(rec.capacity,100)*0.95 else coalesce(rec.capacity,100)*0.4 end);
    v_n := v_n + 1;
  end loop;
  for rec in select id, code, name, zone_type, city from public.customs_zones where company_id=p_company and deleted_at is null loop
    perform app.glnmp_upsert(v_tenant, p_company,
      case rec.zone_type when 'seaport' then 'seaport' when 'airport' then 'airport' when 'dry_port' then 'bonded_zone'
        when 'terminal' then 'road_terminal' when 'eadi' then 'bonded_zone' else 'bonded_zone' end,
      rec.id, 'CZ:'||rec.code, coalesce(rec.name, rec.code), rec.city, null, 0);
    v_n := v_n + 1;
  end loop;
  return v_n;
end; $$;
grant execute on function public.sync_network(uuid) to authenticated;

-- Análise de cobertura da malha
create or replace function public.network_coverage(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'nodes', (select count(*) from public.glnmp_nodes where company_id=p_company and deleted_at is null),
    'regions_covered', (select count(distinct region) from public.glnmp_nodes where company_id=p_company and region is not null and deleted_at is null),
    'saturated_nodes', (select count(*) from public.glnmp_nodes where company_id=p_company and status='saturated' and deleted_at is null),
    'avg_utilization', (select round(avg(utilization_pct),1) from public.glnmp_nodes where company_id=p_company and utilization_pct is not null and deleted_at is null),
    'by_region', (select coalesce(jsonb_object_agg(region, n), '{}'::jsonb) from (select coalesce(region,'(sem região)') region, count(*) n from public.glnmp_nodes where company_id=p_company and deleted_at is null group by region) x),
    'by_type', (select coalesce(jsonb_object_agg(node_type, n), '{}'::jsonb) from (select node_type, count(*) n from public.glnmp_nodes where company_id=p_company and deleted_at is null group by node_type) x),
    'lanes', (select count(*) from public.glnmp_lanes where company_id=p_company and deleted_at is null),
    'lanes_congested', (select count(*) from public.glnmp_lanes where company_id=p_company and status='congested' and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.network_coverage(uuid) to authenticated;

-- Balanceamento: identifica nós saturados e sugere alívio pelos ociosos
create or replace function public.balance_network(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'overloaded', (select coalesce(jsonb_agg(jsonb_build_object('node',node_code,'name',name,'utilization',utilization_pct) order by utilization_pct desc), '[]'::jsonb)
                   from public.glnmp_nodes where company_id=p_company and utilization_pct is not null and utilization_pct >= 85 and deleted_at is null),
    'underused', (select coalesce(jsonb_agg(jsonb_build_object('node',node_code,'name',name,'utilization',utilization_pct) order by utilization_pct asc), '[]'::jsonb)
                  from public.glnmp_nodes where company_id=p_company and utilization_pct is not null and utilization_pct < 50 and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.balance_network(uuid) to authenticated;

-- Simulação de rede (network design what-if determinístico)
create or replace function public.run_network_scenario(p_company uuid, p_name text, p_scenario_type text, p_assumptions jsonb default '{}'::jsonb)
returns public.glnmp_scenarios language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.glnmp_scenarios;
  v_nodes int; v_util numeric; v_cov int; v_cost numeric := 100; v_lead numeric := 5; v_p numeric;
  b jsonb; res jsonb; f_util numeric:=1; f_cost numeric:=1; f_lead numeric:=1; d_cov int:=0;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  v_p := coalesce((p_assumptions->>'pct')::numeric, 20);
  select count(*), round(coalesce(avg(utilization_pct),50),1), count(distinct region)
    into v_nodes, v_util, v_cov from public.glnmp_nodes where company_id=p_company and deleted_at is null;

  case p_scenario_type
    when 'new_dc' then f_util:=0.80; f_cost:=1.08; f_lead:=0.82; d_cov:=1;
    when 'new_hub' then f_util:=0.88; f_cost:=1.04; f_lead:=0.90; d_cov:=1;
    when 'new_region' then f_util:=0.92; f_cost:=1.12; d_cov:=1;
    when 'new_lane' then f_lead:=0.92; f_cost:=1.03;
    when 'new_carrier' then f_cost:=0.93;
    when 'close_unit' then f_util:=1.25; f_lead:=1.12; f_cost:=0.92; d_cov:=-1;
    when 'demand_increase' then f_util:=1+v_p/100; f_cost:=1+v_p/200; f_lead:=1+v_p/200;
    when 'rebalance' then f_util:=0.90; f_lead:=0.95;
    when 'crisis' then f_util:=1.20; f_lead:=1.35; f_cost:=1.18;
    else f_util:=1.10; f_lead:=1.20; f_cost:=1.08; -- weather/genérico
  end case;

  b := jsonb_build_object('nodes', v_nodes, 'avg_utilization', v_util, 'regions', v_cov, 'cost_index', v_cost, 'lead_time_days', v_lead);
  res := jsonb_build_object(
    'nodes', v_nodes + greatest(0, d_cov),
    'avg_utilization', least(100, round(v_util*f_util,1)),
    'regions', greatest(0, v_cov + d_cov),
    'cost_index', round(v_cost*f_cost,1),
    'lead_time_days', round(v_lead*f_lead,1));
  insert into public.glnmp_scenarios (tenant_id, company_id, name, scenario_type, assumptions, baseline, result, delta, status, run_at)
    values (v_tenant, p_company, p_name, p_scenario_type, coalesce(p_assumptions,'{}'::jsonb), b, res,
      jsonb_build_object('avg_utilization', round(v_util*f_util - v_util,1), 'cost_index', round(v_cost*f_cost - v_cost,1),
        'lead_time_days', round(v_lead*f_lead - v_lead,1), 'regions', d_cov),
      'completed', now()) returning * into r;
  return r;
end; $$;
grant execute on function public.run_network_scenario(uuid,text,text,jsonb) to authenticated;

create or replace function public.glnmp_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'nodes', (select count(*) from public.glnmp_nodes where company_id=p_company and deleted_at is null),
    'active_nodes', (select count(*) from public.glnmp_nodes where company_id=p_company and status='active' and deleted_at is null),
    'saturated', (select count(*) from public.glnmp_nodes where company_id=p_company and status='saturated' and deleted_at is null),
    'lanes', (select count(*) from public.glnmp_lanes where company_id=p_company and deleted_at is null),
    'avg_utilization', (select round(avg(utilization_pct),1) from public.glnmp_nodes where company_id=p_company and utilization_pct is not null and deleted_at is null),
    'regions', (select count(distinct region) from public.glnmp_nodes where company_id=p_company and region is not null and deleted_at is null),
    'flows', (select count(*) from public.glnmp_flows where company_id=p_company and deleted_at is null),
    'scenarios', (select count(*) from public.glnmp_scenarios where company_id=p_company and deleted_at is null),
    'total_capacity', (select coalesce(round(sum(capacity),0),0) from public.glnmp_nodes where company_id=p_company and capacity is not null and deleted_at is null),
    'last_sync', (select max(last_synced_at) from public.glnmp_nodes where company_id=p_company and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.glnmp_dashboard(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.glnmp_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_sat int; v_cong int; v_stale int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'GLNMP%' and deleted_at is null;

  select count(*) into v_sat from public.glnmp_nodes where company_id=p_company and status='saturated' and deleted_at is null;
  if v_sat > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'GLNMP: nós saturados na rede', v_sat||' instalação(ões) com capacidade no limite.', 'Redistribuir carga ou expandir capacidade; rodar cenário de rede.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_cong from public.glnmp_lanes where company_id=p_company and status='congested' and deleted_at is null;
  if v_cong > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'GLNMP: conexões congestionadas', v_cong||' lane(s) acima da capacidade de fluxo.', 'Abrir rota alternativa ou balancear o fluxo.', 80);
    v_c := v_c + 1;
  end if;
  select case when max(last_synced_at) is null or max(last_synced_at) < now()-interval '7 days' then 1 else 0 end into v_stale
    from public.glnmp_nodes where company_id=p_company and deleted_at is null;
  if v_stale = 1 and exists (select 1 from public.glnmp_nodes where company_id=p_company and deleted_at is null) then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'info', 'GLNMP: topologia da rede desatualizada', 'A malha não é sincronizada há mais de 7 dias.', 'Rodar sync_network para refletir as instalações atuais.', 70);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.glnmp_insights(uuid) to authenticated;

notify pgrst, 'reload schema';
