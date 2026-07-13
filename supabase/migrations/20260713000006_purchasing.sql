-- 20260713000006_purchasing.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 06 — COMPRAS / PROCUREMENT                                         ║
-- ║  Requisição → RFQ/cotação → mapa comparativo → pedido → recebimento.      ║
-- ║  Recebimento reusa inbound_receipts (Vol 03). RPC de conversão RFQ→PO.    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.requisition_status as enum ('draft','submitted','approved','rejected','converted','canceled');
create type public.rfq_status         as enum ('draft','sent','quoted','awarded','canceled');
create type public.po_status          as enum ('draft','sent','confirmed','partial','received','invoiced','canceled');

-- ── PURCHASE_REQUISITIONS + itens ────────────────────────────────────────────
create table public.purchase_requisitions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  code text, status public.requisition_status not null default 'draft',
  needed_by date, justification text, requested_by uuid references auth.users(id),
  approved_by uuid references auth.users(id), approved_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_purchase_requisitions_status on public.purchase_requisitions (company_id, status) where deleted_at is null;

create table public.purchase_requisition_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  requisition_id uuid not null references public.purchase_requisitions(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  quantity numeric(18,3) not null default 1, uom_code text, estimated_cost numeric(14,4), notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_purchase_requisition_items_req on public.purchase_requisition_items (requisition_id);

-- ── RFQs (cotação) + itens + cotações de fornecedor ──────────────────────────
create table public.rfqs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  requisition_id uuid references public.purchase_requisitions(id) on delete set null,
  code text, status public.rfq_status not null default 'draft', due_date date, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_rfqs_status on public.rfqs (company_id, status) where deleted_at is null;

create table public.rfq_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  rfq_id uuid not null references public.rfqs(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  quantity numeric(18,3) not null default 1, uom_code text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_rfq_items_rfq on public.rfq_items (rfq_id);

create table public.supplier_quotes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  rfq_id uuid not null references public.rfqs(id) on delete cascade,
  supplier_id uuid references public.suppliers(id) on delete set null,
  total numeric(16,2), lead_time_days integer, payment_terms text, is_awarded boolean not null default false, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_supplier_quotes_rfq on public.supplier_quotes (rfq_id);

create table public.supplier_quote_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  supplier_quote_id uuid not null references public.supplier_quotes(id) on delete cascade,
  rfq_item_id uuid references public.rfq_items(id) on delete set null,
  product_id uuid references public.products(id) on delete set null,
  unit_price numeric(14,4), quantity numeric(18,3), total numeric(16,2),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_supplier_quote_items_quote on public.supplier_quote_items (supplier_quote_id);

-- ── PURCHASE_ORDERS + itens ──────────────────────────────────────────────────
create table public.purchase_orders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  supplier_id uuid references public.suppliers(id) on delete set null,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  rfq_id uuid references public.rfqs(id) on delete set null,
  code text, status public.po_status not null default 'draft',
  order_date date, expected_date date, subtotal numeric(16,2), freight numeric(14,2), taxes numeric(14,2),
  total numeric(16,2), payment_terms text, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_purchase_orders_code on public.purchase_orders (company_id, code) where code is not null and deleted_at is null;
create index idx_purchase_orders_status on public.purchase_orders (company_id, status) where deleted_at is null;
create index idx_purchase_orders_supplier on public.purchase_orders (supplier_id);

create table public.purchase_order_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  purchase_order_id uuid not null references public.purchase_orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  quantity numeric(18,3) not null default 1, uom_code text, unit_cost numeric(14,4), total numeric(16,2),
  received_quantity numeric(18,3) not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_purchase_order_items_po on public.purchase_order_items (purchase_order_id);

do $do$
declare t text; specs text[] := array[
  'purchase_requisitions','purchase_requisition_items','rfqs','rfq_items',
  'supplier_quotes','supplier_quote_items','purchase_orders','purchase_order_items'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'purchasing.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'purchasing.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;

-- ── RPC: converte pedido recebido em entrada de estoque (integração backbone) ─
create or replace function public.receive_purchase_order(p_po uuid, p_warehouse uuid default null)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_wh uuid; v_item record; v_count int := 0;
begin
  select company_id, coalesce(p_warehouse, warehouse_id) into v_company, v_wh
  from public.purchase_orders where id = p_po;
  if v_company is null then raise exception 'PO % not found', p_po; end if;
  if not app.has_permission('purchasing.approve', v_company) then raise exception 'forbidden'; end if;

  for v_item in
    select id, product_id, quantity, received_quantity, unit_cost
    from public.purchase_order_items where purchase_order_id = p_po and deleted_at is null
  loop
    if v_item.product_id is not null and (v_item.quantity - v_item.received_quantity) > 0 then
      perform public.register_stock_movement(
        v_item.product_id, v_wh, 'receipt_in'::public.stock_movement_type,
        v_item.quantity - v_item.received_quantity, null, null, null, v_item.unit_cost,
        'purchase_order', p_po, 'Recebimento de PO');
      update public.purchase_order_items set received_quantity = quantity where id = v_item.id;
      v_count := v_count + 1;
    end if;
  end loop;

  update public.purchase_orders set status = 'received' where id = p_po;
  return v_count;
end;
$$;
grant execute on function public.receive_purchase_order(uuid,uuid) to authenticated;

grant select, insert, update, delete on all tables in schema public to authenticated;
