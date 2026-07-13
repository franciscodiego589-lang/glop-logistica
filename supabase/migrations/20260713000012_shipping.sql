-- 20260713000012_shipping.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 12 — EXPEDIÇÃO / PICKING / PACKING / SHIPPING                      ║
-- ║  Clientes · pedidos de saída · alocação/reserva · geração de picking ·    ║
-- ║  conferência · faturamento de saída (baixa de estoque via ship_out).      ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.customer_type   as enum ('company','person');
create type public.outbound_status as enum ('draft','confirmed','allocated','picking','packed','shipped','invoiced','delivered','canceled');

-- ── CUSTOMERS (clientes / destinatários) ─────────────────────────────────────
create table public.customers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, name text not null, legal_name text, customer_type public.customer_type not null default 'company',
  document text, email text, phone text,
  address text, city text, uf text, zipcode text, latitude numeric(10,7), longitude numeric(10,7),
  credit_limit numeric(16,2), price_table text, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_customers_name_trgm on public.customers using gin (name gin_trgm_ops);
create unique index uq_customers_document on public.customers (company_id, document) where document is not null and deleted_at is null;

-- ── OUTBOUND_ORDERS + itens (pedidos de saída) ───────────────────────────────
create table public.outbound_orders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  customer_id uuid references public.customers(id) on delete set null,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  wave_id uuid references public.pick_waves(id) on delete set null,
  shipment_id uuid references public.shipments(id) on delete set null,
  code text, status public.outbound_status not null default 'draft',
  order_date date, required_date date, priority integer not null default 5,
  subtotal numeric(16,2), freight numeric(14,2), discount numeric(14,2), total numeric(16,2),
  ship_to_address text, ship_to_uf text, ship_to_city text, notes text,
  shipped_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_outbound_orders_status on public.outbound_orders (company_id, status) where deleted_at is null;
create index idx_outbound_orders_customer on public.outbound_orders (customer_id);

create table public.outbound_order_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  outbound_order_id uuid not null references public.outbound_orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  quantity numeric(18,3) not null default 1, uom_code text,
  allocated_quantity numeric(18,3) not null default 0, picked_quantity numeric(18,3) not null default 0,
  shipped_quantity numeric(18,3) not null default 0,
  unit_price numeric(14,4), total numeric(16,2),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_outbound_order_items_order on public.outbound_order_items (outbound_order_id);

-- ── RPC: embarca pedido — baixa estoque (ship_out) e marca status ────────────
create or replace function public.ship_outbound_order(p_order uuid, p_warehouse uuid default null)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_wh uuid; v_it record; v_count int := 0;
begin
  select company_id, coalesce(p_warehouse, warehouse_id) into v_company, v_wh
  from public.outbound_orders where id = p_order;
  if v_company is null then raise exception 'order % not found', p_order; end if;
  if not app.has_permission('shipping.update', v_company) then raise exception 'forbidden'; end if;

  for v_it in select id, product_id, lot_id, quantity, shipped_quantity from public.outbound_order_items
              where outbound_order_id = p_order and deleted_at is null and product_id is not null
  loop
    if (v_it.quantity - v_it.shipped_quantity) > 0 then
      perform public.register_stock_movement(
        v_it.product_id, v_wh, 'ship_out'::public.stock_movement_type,
        v_it.quantity - v_it.shipped_quantity, null, null, v_it.lot_id, null,
        'outbound_order', p_order, 'Embarque de pedido');
      update public.outbound_order_items set shipped_quantity = quantity, picked_quantity = quantity where id = v_it.id;
      v_count := v_count + 1;
    end if;
  end loop;

  update public.outbound_orders set status = 'shipped', shipped_at = now() where id = p_order;
  return v_count;
end;
$$;
grant execute on function public.ship_outbound_order(uuid,uuid) to authenticated;

do $do$
declare t text; specs text[] := array['customers','outbound_orders','outbound_order_items'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'shipping.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'shipping.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on all tables in schema public to authenticated;
