-- ============================================================================
-- VOLUME 43 · CCLMS — COLD CHAIN LOGISTICS MANAGEMENT SYSTEM (migration 077)
-- Cadeia fria: categorias térmicas, sensores IoT, leituras ambientais com
-- detecção de quebra, alarmes, equipamentos refrigerados, integridade + SLA.
-- Nível DHL Life Sciences/UPS Healthcare/Sensitech/Emerson. Integra com
-- shipments/vehicles/containers. Recurso RBAC 'quality'. Escopo 100% logística.
-- Padrão: colunas-padrão, text+check, grant por-tabela.
-- ============================================================================

-- ── 1) CATEGORIAS térmicas + faixas ──────────────────────────────────────────
create table if not exists public.cold_categories (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  name text,
  category_kind text not null default 'chilled' check (category_kind in ('frozen','chilled','vaccine','biological','food','chemical','cosmetic','lab','other')),
  min_temp numeric(6,2),
  max_temp numeric(6,2),
  ideal_temp numeric(6,2),
  tolerance_c numeric(5,2) not null default 0,
  max_minutes_out integer not null default 60,
  humidity_min numeric(5,2),
  humidity_max numeric(5,2),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 2) SENSORES / data loggers IoT ───────────────────────────────────────────
create table if not exists public.cold_sensors (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  sensor_type text not null default 'data_logger' check (sensor_type in ('data_logger','bluetooth','lorawan','nbiot','gsm','rfid_tag','gateway')),
  device_id text,
  assigned_to_type text check (assigned_to_type in ('vehicle','container','cold_room','shipment','equipment')),
  assigned_to_id uuid,
  status text not null default 'active' check (status in ('active','offline','faulty','maintenance')),
  last_reading_at timestamptz,
  last_calibrated_at date,
  next_calibration date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 3) EQUIPAMENTOS refrigerados ─────────────────────────────────────────────
create table if not exists public.cold_equipment (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  name text,
  equip_type text not null default 'reefer_truck' check (equip_type in ('reefer_truck','reefer_container','cold_room','freezer','refrigerator','refrig_unit','generator')),
  temp_setpoint numeric(6,2),
  status text not null default 'available' check (status in ('available','in_use','maintenance','faulty')),
  last_maintenance date,
  next_maintenance date,
  last_calibration date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 4) REMESSAS DE CADEIA FRIA (instância monitorada) ────────────────────────
create table if not exists public.cold_shipments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  shipment_id uuid references public.shipments(id) on delete set null,
  cold_category_id uuid references public.cold_categories(id) on delete set null,
  vehicle_id uuid references public.vehicles(id) on delete set null,
  container_id uuid references public.containers(id) on delete set null,
  sensor_id uuid references public.cold_sensors(id) on delete set null,
  equipment_id uuid references public.cold_equipment(id) on delete set null,
  origin text, destination text,
  started_at timestamptz, ended_at timestamptz,
  minutes_out_of_range integer not null default 0,
  integrity_status text not null default 'intact' check (integrity_status in ('intact','at_risk','broken')),
  status text not null default 'in_transit' check (status in ('planned','in_transit','delivered','canceled')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 5) LEITURAS AMBIENTAIS (breach como coluna GERADA) ───────────────────────
create table if not exists public.environmental_readings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  cold_shipment_id uuid references public.cold_shipments(id) on delete cascade,
  sensor_id uuid references public.cold_sensors(id) on delete set null,
  temperature numeric(6,2),
  humidity numeric(5,2),
  pressure numeric(8,2),
  light_lux numeric(8,2),
  vibration numeric(6,2),
  door_open boolean not null default false,
  min_temp numeric(6,2),
  max_temp numeric(6,2),
  breach boolean generated always as (
    (min_temp is not null and temperature is not null and temperature < min_temp)
    or (max_temp is not null and temperature is not null and temperature > max_temp)
  ) stored,
  reading_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 6) ALARMES térmicos / cadeia fria ────────────────────────────────────────
create table if not exists public.cold_alarms (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  cold_shipment_id uuid references public.cold_shipments(id) on delete cascade,
  sensor_id uuid references public.cold_sensors(id) on delete set null,
  alarm_type text not null default 'high_temp' check (alarm_type in ('high_temp','low_temp','sensor_fail','comm_loss','door_open','excessive_stop','chain_break','param_violation')),
  severity text not null default 'high' check (severity in ('low','medium','high','critical')),
  value numeric(8,2),
  threshold numeric(8,2),
  triggered_at timestamptz not null default now(),
  resolved_at timestamptz,
  action_plan text,
  status text not null default 'open' check (status in ('open','acknowledged','resolved')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_cold_sensors_assign on public.cold_sensors (assigned_to_type, assigned_to_id);
create index if not exists idx_cold_ship_category on public.cold_shipments (cold_category_id);
create index if not exists idx_env_readings_ship on public.environmental_readings (cold_shipment_id, reading_at);
create index if not exists idx_cold_alarms_ship on public.cold_alarms (cold_shipment_id);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'quality') ────────
do $do$
declare t text; specs text[] := array['cold_categories','cold_sensors','cold_equipment','cold_shipments','environmental_readings','cold_alarms'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'quality.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'quality.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- Ingestão IoT: registra leitura, detecta quebra vs faixa da categoria, gera alarme,
-- acumula tempo fora da faixa e atualiza a integridade da cadeia.
create or replace function public.record_environmental_reading(
  p_company uuid, p_shipment uuid, p_temp numeric, p_humidity numeric default null,
  p_door_open boolean default false, p_pressure numeric default null, p_light numeric default null, p_vibration numeric default null)
returns public.environmental_readings language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.environmental_readings; v_min numeric; v_max numeric; v_tol numeric; v_maxout int;
  v_sensor uuid; v_last timestamptz; v_gap int; v_out int; v_new_status text;
begin
  if not (app.can_access_company(p_company) and app.has_permission('quality.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select cc.min_temp, cc.max_temp, coalesce(cc.tolerance_c,0), coalesce(cc.max_minutes_out,60), cs.sensor_id, cs.minutes_out_of_range
    into v_min, v_max, v_tol, v_maxout, v_sensor, v_out
  from public.cold_shipments cs left join public.cold_categories cc on cc.id=cs.cold_category_id
  where cs.id=p_shipment and cs.company_id=p_company;

  insert into public.environmental_readings (tenant_id, company_id, cold_shipment_id, sensor_id, temperature, humidity,
    pressure, light_lux, vibration, door_open, min_temp, max_temp)
  values (v_tenant, p_company, p_shipment, v_sensor, p_temp, p_humidity, p_pressure, p_light, p_vibration, p_door_open,
    v_min - v_tol, v_max + v_tol) returning * into r;

  if v_sensor is not null then update public.cold_sensors set last_reading_at=now(), status='active' where id=v_sensor; end if;

  if r.breach then
    -- gap desde a última leitura (default 5 min)
    select max(reading_at) into v_last from public.environmental_readings
      where cold_shipment_id=p_shipment and id<>r.id and deleted_at is null;
    v_gap := case when v_last is not null then greatest(1, (extract(epoch from (r.reading_at - v_last))/60.0)::int) else 5 end;
    v_out := coalesce(v_out,0) + v_gap;
    v_new_status := case when v_out >= v_maxout then 'broken' else 'at_risk' end;
    update public.cold_shipments set minutes_out_of_range=v_out, integrity_status=v_new_status where id=p_shipment;
    insert into public.cold_alarms (tenant_id, company_id, cold_shipment_id, sensor_id, alarm_type, severity, value, threshold, triggered_at)
    values (v_tenant, p_company, p_shipment, v_sensor,
      case when p_temp > (v_max + v_tol) then 'high_temp' else 'low_temp' end,
      case when v_new_status='broken' then 'critical' else 'high' end,
      p_temp, case when p_temp > (v_max + v_tol) then v_max else v_min end, now());
  end if;
  if p_door_open then
    insert into public.cold_alarms (tenant_id, company_id, cold_shipment_id, sensor_id, alarm_type, severity, triggered_at)
    values (v_tenant, p_company, p_shipment, v_sensor, 'door_open', 'medium', now());
  end if;
  return r;
end; $$;
grant execute on function public.record_environmental_reading(uuid,uuid,numeric,numeric,boolean,numeric,numeric,numeric) to authenticated;

create or replace function public.resolve_cold_alarm(p_company uuid, p_alarm uuid)
returns public.cold_alarms language plpgsql security definer set search_path = public, app as $$
declare r public.cold_alarms;
begin
  if not (app.can_access_company(p_company) and app.has_permission('quality.update', p_company)) then raise exception 'forbidden'; end if;
  update public.cold_alarms set status='resolved', resolved_at=now() where id=p_alarm and company_id=p_company returning * into r;
  if r.id is null then raise exception 'Alarme não encontrado'; end if;
  return r;
end; $$;
grant execute on function public.resolve_cold_alarm(uuid,uuid) to authenticated;

-- Relatório de conformidade térmica de uma remessa
create or replace function public.cold_chain_report(p_company uuid, p_shipment uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'readings', (select count(*) from public.environmental_readings where cold_shipment_id=p_shipment and deleted_at is null),
    'breaches', (select count(*) from public.environmental_readings where cold_shipment_id=p_shipment and breach and deleted_at is null),
    'min_temp_seen', (select min(temperature) from public.environmental_readings where cold_shipment_id=p_shipment and deleted_at is null),
    'max_temp_seen', (select max(temperature) from public.environmental_readings where cold_shipment_id=p_shipment and deleted_at is null),
    'avg_temp', (select round(avg(temperature),2) from public.environmental_readings where cold_shipment_id=p_shipment and deleted_at is null),
    'minutes_out_of_range', (select minutes_out_of_range from public.cold_shipments where id=p_shipment),
    'integrity', (select integrity_status from public.cold_shipments where id=p_shipment),
    'alarms', (select count(*) from public.cold_alarms where cold_shipment_id=p_shipment and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.cold_chain_report(uuid,uuid) to authenticated;

create or replace function public.cclms_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb; v_ship int; v_ok int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select count(*) into v_ship from public.cold_shipments where company_id=p_company and deleted_at is null;
  select count(*) into v_ok from public.cold_shipments where company_id=p_company and integrity_status='intact' and deleted_at is null;
  select jsonb_build_object(
    'cold_shipments', v_ship,
    'integrity_pct', case when v_ship>0 then round(100.0*v_ok/v_ship,1) else null end,
    'at_risk', (select count(*) from public.cold_shipments where company_id=p_company and integrity_status='at_risk' and deleted_at is null),
    'broken', (select count(*) from public.cold_shipments where company_id=p_company and integrity_status='broken' and deleted_at is null),
    'sensors_active', (select count(*) from public.cold_sensors where company_id=p_company and status='active' and deleted_at is null),
    'sensors_offline', (select count(*) from public.cold_sensors where company_id=p_company and status in ('offline','faulty') and deleted_at is null),
    'alarms_open', (select count(*) from public.cold_alarms where company_id=p_company and status='open' and deleted_at is null),
    'equipment_available', (select count(*) from public.cold_equipment where company_id=p_company and status='available' and deleted_at is null),
    'calibration_due', (select count(*) from public.cold_sensors where company_id=p_company and next_calibration is not null and next_calibration <= now()::date + 15 and deleted_at is null),
    'readings_today', (select count(*) from public.environmental_readings where company_id=p_company and reading_at::date=now()::date and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.cclms_dashboard(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.cclms_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_broken int; v_off int; v_alarm int; v_cal int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'CCLMS%' and deleted_at is null;

  select count(*) into v_broken from public.cold_shipments where company_id=p_company and integrity_status='broken' and deleted_at is null;
  if v_broken > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'critical', 'CCLMS: cadeia fria rompida', v_broken||' remessa(s) com cadeia fria rompida.', 'Segregar a carga e avaliar descarte/laudo; acionar contingência.', 92);
    v_c := v_c + 1;
  end if;
  select count(*) into v_off from public.cold_sensors where company_id=p_company and status in ('offline','faulty') and deleted_at is null;
  if v_off > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'CCLMS: sensores sem comunicação', v_off||' sensor(es) offline/com falha.', 'Verificar bateria/comunicação — risco de ponto cego térmico.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_alarm from public.cold_alarms where company_id=p_company and status='open' and severity in ('high','critical') and deleted_at is null;
  if v_alarm > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'CCLMS: alarmes térmicos abertos', v_alarm||' alarme(s) grave(s) sem resolução.', 'Tratar imediatamente para conter desvio térmico.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_cal from public.cold_sensors where company_id=p_company and next_calibration is not null and next_calibration < now()::date and deleted_at is null;
  if v_cal > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'info', 'CCLMS: calibração de sensores vencida', v_cal||' sensor(es) com calibração vencida.', 'Recalibrar para manter a validade metrológica das medições.', 74);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.cclms_insights(uuid) to authenticated;

-- ── SEED (empresa Matriz Logística) ─────────────────────────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid; v_cat uuid; v_sensor uuid;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;
  if not exists (select 1 from public.cold_categories where company_id=v_company and deleted_at is null) then
    insert into public.cold_categories (tenant_id, company_id, code, name, category_kind, min_temp, max_temp, ideal_temp, tolerance_c, max_minutes_out) values
      (v_tenant, v_company, 'VAC', 'Vacinas', 'vaccine', 2, 8, 5, 0.5, 30),
      (v_tenant, v_company, 'CONG', 'Congelados', 'frozen', -25, -18, -20, 1, 60),
      (v_tenant, v_company, 'RESF', 'Resfriados', 'chilled', 0, 10, 4, 1, 90)
      ;
    select id into v_cat from public.cold_categories where company_id=v_company and code='VAC';
    insert into public.cold_sensors (tenant_id, company_id, code, sensor_type, device_id, status, next_calibration)
      values (v_tenant, v_company, 'SENS-01', 'lorawan', 'LORA-AA11', 'active', (now()::date + interval '3 months')::date) returning id into v_sensor;
    insert into public.cold_equipment (tenant_id, company_id, code, name, equip_type, temp_setpoint, status)
      values (v_tenant, v_company, 'REEFER-01', 'Baú Refrigerado 01', 'reefer_truck', 4, 'available');
    insert into public.cold_shipments (tenant_id, company_id, code, cold_category_id, sensor_id, origin, destination, started_at, status)
      values (v_tenant, v_company, 'CC-0001', v_cat, v_sensor, 'CD São Paulo', 'Hospital RJ', now(), 'in_transit');
  end if;
end $seed$;

notify pgrst, 'reload schema';
