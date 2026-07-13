-- 20260713000008_mrp_aps.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 08 — MRP · MRP II · APS                                            ║
-- ║  BOM multinível · centros de trabalho · roteiros · rodadas de MRP ·       ║
-- ║  ordens planejadas (compra/produção) · capacidade finita (APS).           ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.mrp_order_kind   as enum ('purchase','production','transfer');
create type public.mrp_run_status   as enum ('running','completed','failed','canceled');
create type public.planned_status   as enum ('planned','firmed','released','canceled');

-- ── BILLS_OF_MATERIALS (BOM multinível) ──────────────────────────────────────
create table public.bills_of_materials (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,   -- produto acabado
  code text, name text, output_quantity numeric(18,4) not null default 1, uom_code text,
  is_default boolean not null default true, revision text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_boms_product on public.bills_of_materials (product_id);

create table public.bom_components (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  bom_id uuid not null references public.bills_of_materials(id) on delete cascade,
  component_product_id uuid not null references public.products(id) on delete cascade,
  quantity numeric(18,6) not null default 1, uom_code text, scrap_percent numeric(6,3) not null default 0,
  operation_seq integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_bom_components_bom on public.bom_components (bom_id);
create index idx_bom_components_product on public.bom_components (component_product_id);

-- ── WORK_CENTERS (centros de trabalho / capacidade) ──────────────────────────
create table public.work_centers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, name text not null, capacity_per_hour numeric(14,4), hours_per_day numeric(6,2) default 8,
  cost_per_hour numeric(14,4), efficiency_percent numeric(6,2) default 100,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── ROUTINGS (roteiros de operação) ──────────────────────────────────────────
create table public.routing_operations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  bom_id uuid references public.bills_of_materials(id) on delete cascade,
  work_center_id uuid references public.work_centers(id) on delete set null,
  operation_seq integer not null default 10, name text not null,
  setup_minutes numeric(12,3) default 0, run_minutes_per_unit numeric(12,4) default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_routing_operations_bom on public.routing_operations (bom_id);

-- ── MRP_RUNS + planned_orders (necessidades planejadas) ──────────────────────
create table public.mrp_runs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, status public.mrp_run_status not null default 'running',
  horizon_start date, horizon_end date, params jsonb not null default '{}'::jsonb,
  orders_generated integer default 0, finished_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create table public.mrp_planned_orders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  mrp_run_id uuid references public.mrp_runs(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  order_kind public.mrp_order_kind not null, status public.planned_status not null default 'planned',
  quantity numeric(18,3) not null default 0, need_date date, release_date date,
  source_demand numeric(18,3), on_hand numeric(18,3), scheduled_receipts numeric(18,3), net_requirement numeric(18,3),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_mrp_planned_orders_run on public.mrp_planned_orders (mrp_run_id);
create index idx_mrp_planned_orders_product on public.mrp_planned_orders (product_id);

-- ── RPC: MRP simplificado (necessidade líquida = demanda − saldo − recebimentos) ─
create or replace function public.run_mrp(p_company uuid, p_horizon_days int default 90)
returns uuid
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_run uuid; v_p record; v_gen int := 0; v_onhand2 numeric; v_demand numeric; v_net numeric;
begin
  if not app.has_permission('mrp.create', p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id = p_company;

  insert into public.mrp_runs (tenant_id, company_id, status, horizon_start, horizon_end)
  values (v_tenant, p_company, 'running', now()::date, (now() + (p_horizon_days||' days')::interval)::date)
  returning id into v_run;

  for v_p in select id, reorder_point, safety_stock, is_manufactured from public.products
             where company_id = p_company and active = true and deleted_at is null
  loop
    select coalesce(sum(quantity),0) into v_onhand2 from public.stock_balances
      where product_id = v_p.id and deleted_at is null;
    select coalesce(sum(forecast_quantity),0) into v_demand from public.demand_forecasts
      where product_id = v_p.id and deleted_at is null
        and period_month between now()::date and (now() + (p_horizon_days||' days')::interval)::date;

    v_net := coalesce(v_demand,0) + coalesce(v_p.safety_stock,0) - coalesce(v_onhand2,0);
    if v_net > 0 then
      insert into public.mrp_planned_orders (tenant_id, company_id, mrp_run_id, product_id, order_kind, quantity, need_date, on_hand, source_demand, net_requirement)
      values (v_tenant, p_company, v_run, v_p.id,
        case when v_p.is_manufactured then 'production' else 'purchase' end::public.mrp_order_kind,
        round(v_net,3), (now() + (p_horizon_days||' days')::interval)::date, v_onhand2, v_demand, v_net);
      v_gen := v_gen + 1;
    end if;
  end loop;

  update public.mrp_runs set status = 'completed', orders_generated = v_gen, finished_at = now() where id = v_run;
  return v_run;
end;
$$;
grant execute on function public.run_mrp(uuid,int) to authenticated;

do $do$
declare t text; specs text[] := array[
  'bills_of_materials','bom_components','work_centers','routing_operations','mrp_runs','mrp_planned_orders'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'mrp.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'mrp.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on all tables in schema public to authenticated;
