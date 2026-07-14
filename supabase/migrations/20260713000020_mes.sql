-- 20260713000020_mes.sql
-- VOLUME 06 · MES (Manufacturing Execution System) — execução do chão de fábrica.
-- Elo entre o PCP (production_orders) e a operação: equipamentos, apontamentos,
-- paradas (perdas), leituras de processo. OEE é calculado a partir destes dados.
-- Reusa o recurso RBAC 'production' (MES = execução da produção) — sem nova permissão.

-- ── ENUMS ────────────────────────────────────────────────────────────────────
create type public.equipment_status as enum ('operational','running','idle','setup','down','maintenance','inactive');
create type public.downtime_reason  as enum ('setup','cleaning','breakdown','adjustment','material_shortage','quality','changeover','waiting','other');

-- ── EQUIPMENT (máquinas / recursos físicos) ─────────────────────────────────
create table public.equipment (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  work_center_id uuid references public.work_centers(id) on delete set null,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  code text, name text not null, equipment_type text, manufacturer text, model text, serial_number text,
  capacity_per_hour numeric(14,4),               -- unidades/hora (para Performance do OEE)
  status public.equipment_status not null default 'operational',
  hour_meter numeric(14,2), notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_equipment_work_center on public.equipment (work_center_id);
create unique index uq_equipment_code on public.equipment (company_id, lower(code)) where code is not null and deleted_at is null;

-- ── PRODUCTION_APPOINTMENTS (apontamentos de produção) ──────────────────────
create table public.production_appointments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  production_order_id uuid references public.production_orders(id) on delete set null,
  operation_id uuid references public.production_operations(id) on delete set null,
  equipment_id uuid references public.equipment(id) on delete set null,
  operator_id uuid references auth.users(id),
  shift text,
  produced_quantity numeric(18,3) not null default 0,
  scrap_quantity numeric(18,3) not null default 0,
  rework_quantity numeric(18,3) not null default 0,
  started_at timestamptz, ended_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_prod_appts_order on public.production_appointments (production_order_id);
create index idx_prod_appts_equipment on public.production_appointments (equipment_id, started_at desc);

-- ── PRODUCTION_DOWNTIMES (paradas / perdas de tempo) ────────────────────────
create table public.production_downtimes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  equipment_id uuid references public.equipment(id) on delete set null,
  production_order_id uuid references public.production_orders(id) on delete set null,
  reason public.downtime_reason not null default 'other',
  started_at timestamptz, ended_at timestamptz,
  minutes numeric(12,2), notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_prod_downtimes_equipment on public.production_downtimes (equipment_id, started_at desc);

-- ── PROCESS_READINGS (parâmetros de processo c/ limites) ────────────────────
create table public.process_readings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  equipment_id uuid references public.equipment(id) on delete set null,
  production_order_id uuid references public.production_orders(id) on delete set null,
  parameter text not null,                        -- temperatura, ph, peso, umidade…
  value numeric(18,4) not null, unit text,
  min_limit numeric(18,4), max_limit numeric(18,4),
  out_of_range boolean generated always as (
    (min_limit is not null and value < min_limit) or (max_limit is not null and value > max_limit)
  ) stored,
  recorded_at timestamptz not null default now(), notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_process_readings_equipment on public.process_readings (equipment_id, recorded_at desc);
create index idx_process_readings_oor on public.process_readings (company_id) where out_of_range = true and deleted_at is null;

-- ── RLS + triggers (reusa recurso 'production') ─────────────────────────────
do $do$
declare t text; specs text[] := array['equipment','production_appointments','production_downtimes','process_readings'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'production.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'production.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on all tables in schema public to authenticated;

-- ── RPC: OEE por equipamento num período (Disponibilidade × Performance × Qualidade) ─
create or replace function public.equipment_oee(p_equipment uuid, p_from timestamptz, p_to timestamptz)
returns jsonb
language plpgsql stable security definer set search_path = public, app as $$
declare
  v_company uuid; v_cap numeric; v_run_min numeric; v_down_min numeric;
  v_produced numeric; v_scrap numeric; v_rework numeric;
  v_avail numeric; v_perf numeric; v_qual numeric;
begin
  select company_id, capacity_per_hour into v_company, v_cap from public.equipment where id = p_equipment;
  if v_company is null then raise exception 'equipment % not found', p_equipment; end if;
  if not app.can_access_company(v_company) then raise exception 'forbidden'; end if;

  -- tempo produtivo (min) a partir dos apontamentos com início/fim no período
  select coalesce(sum(extract(epoch from (coalesce(ended_at, now()) - started_at))/60.0),0),
         coalesce(sum(produced_quantity),0), coalesce(sum(scrap_quantity),0), coalesce(sum(rework_quantity),0)
    into v_run_min, v_produced, v_scrap, v_rework
  from public.production_appointments
  where equipment_id = p_equipment and deleted_at is null and started_at >= p_from and started_at <= p_to;

  -- tempo parado (min)
  select coalesce(sum(coalesce(minutes, extract(epoch from (coalesce(ended_at, now()) - started_at))/60.0)),0)
    into v_down_min
  from public.production_downtimes
  where equipment_id = p_equipment and deleted_at is null and started_at >= p_from and started_at <= p_to;

  -- Disponibilidade = produtivo / (produtivo + parado)
  v_avail := case when (v_run_min + v_down_min) > 0 then v_run_min / (v_run_min + v_down_min) else 0 end;
  -- Performance = produzido / (capacidade × horas produtivas)
  v_perf := case when v_cap is not null and v_run_min > 0 then least(v_produced / (v_cap * (v_run_min/60.0)), 1) else 0 end;
  -- Qualidade = bons / total
  v_qual := case when (v_produced + v_scrap + v_rework) > 0 then v_produced / (v_produced + v_scrap + v_rework) else 0 end;

  return jsonb_build_object(
    'availability', round(v_avail,4), 'performance', round(v_perf,4), 'quality', round(v_qual,4),
    'oee', round(v_avail * v_perf * v_qual, 4),
    'run_minutes', round(v_run_min,1), 'down_minutes', round(v_down_min,1),
    'produced', v_produced, 'scrap', v_scrap, 'rework', v_rework
  );
end;
$$;
grant execute on function public.equipment_oee(uuid,timestamptz,timestamptz) to authenticated;
