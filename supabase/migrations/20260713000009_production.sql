-- 20260713000009_production.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 09 — PCP / PRODUÇÃO INTEGRADA (indústria de suplementos)           ║
-- ║  Ordens de produção · operações/apontamentos · consumo de componentes ·   ║
-- ║  saída de acabado (gera lote). Integra estoque via register_stock_movement.║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.production_status    as enum ('planned','released','in_progress','finished','closed','canceled');
create type public.prod_operation_status as enum ('pending','in_progress','done','skipped');

create table public.production_orders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete restrict,
  bom_id uuid references public.bills_of_materials(id) on delete set null,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  mrp_planned_order_id uuid references public.mrp_planned_orders(id) on delete set null,
  code text, status public.production_status not null default 'planned',
  planned_quantity numeric(18,3) not null default 0, produced_quantity numeric(18,3) not null default 0,
  scrap_quantity numeric(18,3) not null default 0,
  planned_start date, planned_end date, started_at timestamptz, finished_at timestamptz,
  output_lot_id uuid references public.product_lots(id) on delete set null, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_production_orders_status on public.production_orders (company_id, status) where deleted_at is null;
create index idx_production_orders_product on public.production_orders (product_id);

create table public.production_operations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  production_order_id uuid not null references public.production_orders(id) on delete cascade,
  work_center_id uuid references public.work_centers(id) on delete set null,
  operation_seq integer not null default 10, name text, status public.prod_operation_status not null default 'pending',
  planned_minutes numeric(12,3), actual_minutes numeric(12,3),
  operator_id uuid references auth.users(id), started_at timestamptz, finished_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_production_operations_order on public.production_operations (production_order_id);

create table public.production_consumptions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  production_order_id uuid not null references public.production_orders(id) on delete cascade,
  component_product_id uuid references public.products(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  planned_quantity numeric(18,3), consumed_quantity numeric(18,3) not null default 0,
  movement_id uuid references public.stock_movements(id) on delete set null,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_production_consumptions_order on public.production_consumptions (production_order_id);

-- ── RPC: finaliza OP — consome componentes (BOM) e dá entrada no acabado ─────
create or replace function public.finish_production_order(p_order uuid, p_produced numeric, p_lot_number text default null)
returns uuid
language plpgsql security definer set search_path = public, app as $$
declare
  v_company uuid; v_tenant uuid; v_prod uuid; v_bom uuid; v_wh uuid; v_lot uuid; v_c record; v_qty numeric;
begin
  select company_id, tenant_id, product_id, bom_id, warehouse_id
    into v_company, v_tenant, v_prod, v_bom, v_wh
  from public.production_orders where id = p_order;
  if v_company is null then raise exception 'OP % not found', p_order; end if;
  if not app.has_permission('production.update', v_company) then raise exception 'forbidden'; end if;

  -- consumo de componentes conforme BOM (proporcional ao produzido)
  if v_bom is not null then
    for v_c in select component_product_id, quantity, scrap_percent from public.bom_components
               where bom_id = v_bom and deleted_at is null
    loop
      v_qty := v_c.quantity * p_produced * (1 + coalesce(v_c.scrap_percent,0)/100.0);
      perform public.register_stock_movement(
        v_c.component_product_id, v_wh, 'production_out'::public.stock_movement_type, v_qty,
        null, null, null, null, 'production_order', p_order, 'Consumo OP');
      insert into public.production_consumptions (tenant_id, company_id, production_order_id, component_product_id, planned_quantity, consumed_quantity)
      values (v_tenant, v_company, p_order, v_c.component_product_id, v_qty, v_qty);
    end loop;
  end if;

  -- cria lote do acabado e dá entrada
  insert into public.product_lots (tenant_id, company_id, product_id, lot_number, manufacture_date, received_quantity)
  values (v_tenant, v_company, v_prod, coalesce(p_lot_number, 'OP-'||to_char(now(),'YYYYMMDDHH24MISS')), now()::date, p_produced)
  returning id into v_lot;

  perform public.register_stock_movement(
    v_prod, v_wh, 'production_in'::public.stock_movement_type, p_produced,
    null, null, v_lot, null, 'production_order', p_order, 'Entrada de acabado');

  update public.production_orders
    set status = 'finished', produced_quantity = produced_quantity + p_produced,
        output_lot_id = v_lot, finished_at = now()
  where id = p_order;

  return v_lot;
end;
$$;
grant execute on function public.finish_production_order(uuid,numeric,text) to authenticated;

do $do$
declare t text; specs text[] := array['production_orders','production_operations','production_consumptions'];
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
