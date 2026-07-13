-- 20260713000003_wms.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 03 — WMS (Warehouse Management System)                             ║
-- ║  Ledger de estoque (saldo por bin + kardex + reservas) · recebimento ·    ║
-- ║  tarefas de armazém (putaway/pick/move/replenish/count) · ondas · packing.║
-- ║  RPC-cérebro register_stock_movement() sincroniza saldo a cada movimento. ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- ── Enums ────────────────────────────────────────────────────────────────────
create type public.stock_movement_type as enum (
  'receipt_in','putaway','pick','pack','ship_out',
  'transfer_in','transfer_out','adjustment_in','adjustment_out',
  'loss','return_in','return_out','production_in','production_out','count_adjust');
create type public.receipt_status  as enum ('expected','arrived','receiving','received','put_away','canceled');
create type public.wh_task_type    as enum ('putaway','pick','replenish','move','count','pack','load');
create type public.wh_task_status  as enum ('pending','assigned','in_progress','done','canceled');
create type public.wave_status     as enum ('planned','released','picking','picked','packed','closed','canceled');
create type public.package_status  as enum ('open','packed','shipped','delivered','returned','canceled');

-- ── STOCK_BALANCES (saldo por produto/armazém/bin/lote) ──────────────────────
create table public.stock_balances (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  warehouse_id uuid not null references public.warehouses(id) on delete cascade,
  location_id uuid references public.storage_locations(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  quantity numeric(18,3) not null default 0,
  reserved_quantity numeric(18,3) not null default 0,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
-- chave única tolerante a NULL (sentinela para location/lot)
create unique index uq_stock_balances_key on public.stock_balances (
  product_id, warehouse_id,
  coalesce(location_id,'00000000-0000-0000-0000-000000000000'::uuid),
  coalesce(lot_id,'00000000-0000-0000-0000-000000000000'::uuid));
create index idx_stock_balances_warehouse on public.stock_balances (warehouse_id);
create index idx_stock_balances_location on public.stock_balances (location_id);
create index idx_stock_balances_product on public.stock_balances (product_id);

-- ── STOCK_MOVEMENTS (kardex / ledger imutável) ───────────────────────────────
create table public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete restrict,
  warehouse_id uuid not null references public.warehouses(id) on delete restrict,
  location_id uuid references public.storage_locations(id) on delete set null,
  to_location_id uuid references public.storage_locations(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  movement_type public.stock_movement_type not null,
  quantity numeric(18,3) not null,                  -- sempre positivo; direção vem do tipo
  signed_quantity numeric(18,3) not null,           -- +entrada / −saída
  unit_cost numeric(14,4), total_cost numeric(18,4),
  reference_type text, reference_id uuid,
  balance_after numeric(18,3), occurred_at timestamptz not null default now(), notes text,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_stock_movements_product on public.stock_movements (product_id, occurred_at desc);
create index idx_stock_movements_warehouse on public.stock_movements (warehouse_id);
create index idx_stock_movements_reference on public.stock_movements (reference_type, reference_id);

-- ── STOCK_RESERVATIONS ───────────────────────────────────────────────────────
create table public.stock_reservations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  location_id uuid references public.storage_locations(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  quantity numeric(18,3) not null,
  reference_type text, reference_id uuid,
  status text not null default 'active',            -- active, consumed, released, expired
  expires_at timestamptz,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_stock_reservations_product on public.stock_reservations (product_id);

-- ── INBOUND_RECEIPTS + itens (recebimento / doca de entrada) ─────────────────
create table public.inbound_receipts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  supplier_id uuid references public.suppliers(id) on delete set null,
  code text, status public.receipt_status not null default 'expected',
  reference_type text, reference_id uuid,            -- purchase_order, transfer...
  carrier_name text, vehicle_plate text, driver_name text,
  expected_at timestamptz, arrived_at timestamptz, finished_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_inbound_receipts_warehouse on public.inbound_receipts (warehouse_id);
create index idx_inbound_receipts_status on public.inbound_receipts (company_id, status) where deleted_at is null;

create table public.inbound_receipt_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  receipt_id uuid not null references public.inbound_receipts(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  expected_quantity numeric(18,3) not null default 0,
  received_quantity numeric(18,3) not null default 0,
  rejected_quantity numeric(18,3) not null default 0,
  unit_cost numeric(14,4), to_location_id uuid references public.storage_locations(id) on delete set null,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_inbound_receipt_items_receipt on public.inbound_receipt_items (receipt_id);

-- ── PICK_WAVES (ondas de separação) ──────────────────────────────────────────
create table public.pick_waves (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  code text, status public.wave_status not null default 'planned',
  strategy text default 'discrete',                 -- discrete, batch, zone, cluster
  released_at timestamptz, closed_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_pick_waves_status on public.pick_waves (company_id, status) where deleted_at is null;

-- ── WAREHOUSE_TASKS (tarefas unificadas: putaway/pick/move/replenish/count) ──
create table public.warehouse_tasks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid not null references public.warehouses(id) on delete cascade,
  wave_id uuid references public.pick_waves(id) on delete set null,
  task_type public.wh_task_type not null,
  status public.wh_task_status not null default 'pending',
  product_id uuid references public.products(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  from_location_id uuid references public.storage_locations(id) on delete set null,
  to_location_id uuid references public.storage_locations(id) on delete set null,
  quantity numeric(18,3), picked_quantity numeric(18,3) not null default 0,
  priority integer not null default 5, sequence integer,
  assignee_id uuid references auth.users(id) on delete set null,
  reference_type text, reference_id uuid,
  started_at timestamptz, finished_at timestamptz,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_warehouse_tasks_wh_status on public.warehouse_tasks (warehouse_id, status) where deleted_at is null;
create index idx_warehouse_tasks_assignee on public.warehouse_tasks (assignee_id) where deleted_at is null;
create index idx_warehouse_tasks_wave on public.warehouse_tasks (wave_id);

-- ── PACKAGES + itens (embalagem/volumes) ─────────────────────────────────────
create table public.packages (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  wave_id uuid references public.pick_waves(id) on delete set null,
  code text, tracking_code text, status public.package_status not null default 'open',
  reference_type text, reference_id uuid,
  weight_g numeric(16,3), length_mm numeric(12,2), width_mm numeric(12,2), height_mm numeric(12,2),
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_packages_status on public.packages (company_id, status) where deleted_at is null;

create table public.package_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  package_id uuid not null references public.packages(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  serial_id uuid references public.product_serials(id) on delete set null,
  quantity numeric(18,3) not null default 1,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_package_items_package on public.package_items (package_id);

-- ── RPC-CÉREBRO: register_stock_movement — insere movimento e sincroniza saldo ─
create or replace function public.register_stock_movement(
  p_product uuid, p_warehouse uuid, p_movement_type public.stock_movement_type, p_quantity numeric,
  p_location uuid default null, p_to_location uuid default null, p_lot uuid default null,
  p_unit_cost numeric default null, p_reference_type text default null,
  p_reference_id uuid default null, p_notes text default null
) returns uuid
language plpgsql security definer set search_path = public, app as $$
declare
  v_company uuid; v_tenant uuid; v_branch uuid;
  v_dir int; v_signed numeric; v_new_bal numeric; v_mov uuid;
  v_inbound public.stock_movement_type[] := array[
    'receipt_in','transfer_in','adjustment_in','return_in','production_in']::public.stock_movement_type[];
begin
  select tenant_id, company_id, branch_id into v_tenant, v_company, v_branch
  from public.products where id = p_product;
  if v_company is null then raise exception 'product % not found', p_product; end if;
  if not app.can_access_company(v_company) then raise exception 'forbidden'; end if;

  -- direção: putaway/pick/pack/ship_out/…out são saídas do bin de origem
  v_dir := case when p_movement_type = any(v_inbound) then 1 else -1 end;
  v_signed := v_dir * abs(p_quantity);

  -- upsert do saldo no bin/lote de origem
  insert into public.stock_balances (tenant_id, company_id, branch_id, product_id, warehouse_id, location_id, lot_id, quantity)
  values (v_tenant, v_company, v_branch, p_product, p_warehouse, p_location, p_lot, v_signed)
  on conflict (product_id, warehouse_id,
    coalesce(location_id,'00000000-0000-0000-0000-000000000000'::uuid),
    coalesce(lot_id,'00000000-0000-0000-0000-000000000000'::uuid))
  do update set quantity = public.stock_balances.quantity + v_signed
  returning quantity into v_new_bal;

  -- movimento tipo 'move'/putaway com destino: credita o bin de destino
  if p_to_location is not null and p_to_location <> coalesce(p_location,'00000000-0000-0000-0000-000000000000'::uuid) then
    insert into public.stock_balances (tenant_id, company_id, branch_id, product_id, warehouse_id, location_id, lot_id, quantity)
    values (v_tenant, v_company, v_branch, p_product, p_warehouse, p_to_location, p_lot, abs(p_quantity))
    on conflict (product_id, warehouse_id,
      coalesce(location_id,'00000000-0000-0000-0000-000000000000'::uuid),
      coalesce(lot_id,'00000000-0000-0000-0000-000000000000'::uuid))
    do update set quantity = public.stock_balances.quantity + abs(p_quantity);
  end if;

  insert into public.stock_movements (
    tenant_id, company_id, branch_id, product_id, warehouse_id, location_id, to_location_id, lot_id,
    movement_type, quantity, signed_quantity, unit_cost, total_cost, reference_type, reference_id, balance_after, notes)
  values (
    v_tenant, v_company, v_branch, p_product, p_warehouse, p_location, p_to_location, p_lot,
    p_movement_type, abs(p_quantity), v_signed, p_unit_cost,
    case when p_unit_cost is not null then p_unit_cost * abs(p_quantity) end,
    p_reference_type, p_reference_id, v_new_bal, p_notes)
  returning id into v_mov;

  return v_mov;
end;
$$;
grant execute on function public.register_stock_movement(uuid,uuid,public.stock_movement_type,numeric,uuid,uuid,uuid,numeric,text,uuid,text) to authenticated;

-- ── RLS + triggers + policies (padrão via loop) ──────────────────────────────
do $do$
declare spec text; t text; ins_perm text; upd_perm text;
  specs text[] := array[
    'stock_balances|inventory.create|inventory.update',
    'stock_movements|inventory.create|inventory.update',
    'stock_reservations|inventory.create|inventory.update',
    'inbound_receipts|wms.create|wms.update',
    'inbound_receipt_items|wms.create|wms.update',
    'pick_waves|wms.create|wms.update',
    'warehouse_tasks|wms.create|wms.update',
    'packages|wms.create|wms.update',
    'package_items|wms.create|wms.update'
  ];
begin
  foreach spec in array specs loop
    t := split_part(spec,'|',1); ins_perm := split_part(spec,'|',2); upd_perm := split_part(spec,'|',3);
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, ins_perm);
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, upd_perm);
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;

grant select, insert, update, delete on all tables in schema public to authenticated;
