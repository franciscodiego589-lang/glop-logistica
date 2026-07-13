-- 20260713000013_distribution.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 13 — DISTRIBUIÇÃO · CROSS-DOCKING · LAST MILE                      ║
-- ║  Transferências entre CDs · cross-dock · entregas last-mile · tentativas ·║
-- ║  comprovante de entrega (POD).                                            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.transfer_status  as enum ('draft','in_transit','received','canceled');
create type public.delivery_status  as enum ('pending','out_for_delivery','delivered','failed','returned','canceled');

-- ── STOCK_TRANSFERS (transferência entre armazéns/CDs) ───────────────────────
create table public.stock_transfers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  from_warehouse_id uuid not null references public.warehouses(id) on delete restrict,
  to_warehouse_id uuid not null references public.warehouses(id) on delete restrict,
  code text, status public.transfer_status not null default 'draft', is_cross_dock boolean not null default false,
  shipped_at timestamptz, received_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_stock_transfers_status on public.stock_transfers (company_id, status) where deleted_at is null;

create table public.stock_transfer_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  transfer_id uuid not null references public.stock_transfers(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  quantity numeric(18,3) not null default 1, received_quantity numeric(18,3) not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_stock_transfer_items_transfer on public.stock_transfer_items (transfer_id);

-- ── DELIVERIES (last-mile) + tentativas ──────────────────────────────────────
create table public.deliveries (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  shipment_id uuid references public.shipments(id) on delete set null,
  outbound_order_id uuid references public.outbound_orders(id) on delete set null,
  route_id uuid references public.routes(id) on delete set null,
  customer_id uuid references public.customers(id) on delete set null,
  code text, status public.delivery_status not null default 'pending', stop_sequence integer,
  address text, city text, uf text, latitude numeric(10,7), longitude numeric(10,7),
  scheduled_date date, window_start timestamptz, window_end timestamptz,
  delivered_at timestamptz, receiver_name text, receiver_document text, pod_url text,
  attempts integer not null default 0, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_deliveries_status on public.deliveries (company_id, status) where deleted_at is null;
create index idx_deliveries_route on public.deliveries (route_id, stop_sequence);

create table public.delivery_attempts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  delivery_id uuid not null references public.deliveries(id) on delete cascade,
  attempt_number integer not null default 1, result public.delivery_status not null default 'failed',
  reason text, latitude numeric(10,7), longitude numeric(10,7), occurred_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_delivery_attempts_delivery on public.delivery_attempts (delivery_id);

-- ── RPC: recebe transferência — dá saída na origem e entrada no destino ──────
create or replace function public.receive_stock_transfer(p_transfer uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_from uuid; v_to uuid; v_it record; v_count int := 0;
begin
  select company_id, from_warehouse_id, to_warehouse_id into v_company, v_from, v_to
  from public.stock_transfers where id = p_transfer;
  if v_company is null then raise exception 'transfer % not found', p_transfer; end if;
  if not app.has_permission('distribution.update', v_company) then raise exception 'forbidden'; end if;

  for v_it in select id, product_id, lot_id, quantity from public.stock_transfer_items
              where transfer_id = p_transfer and deleted_at is null and product_id is not null
  loop
    perform public.register_stock_movement(v_it.product_id, v_from, 'transfer_out'::public.stock_movement_type,
      v_it.quantity, null, null, v_it.lot_id, null, 'stock_transfer', p_transfer, 'Saída transferência');
    perform public.register_stock_movement(v_it.product_id, v_to, 'transfer_in'::public.stock_movement_type,
      v_it.quantity, null, null, v_it.lot_id, null, 'stock_transfer', p_transfer, 'Entrada transferência');
    update public.stock_transfer_items set received_quantity = quantity where id = v_it.id;
    v_count := v_count + 1;
  end loop;

  update public.stock_transfers set status = 'received', received_at = now() where id = p_transfer;
  return v_count;
end;
$$;
grant execute on function public.receive_stock_transfer(uuid) to authenticated;

do $do$
declare t text; specs text[] := array[
  'stock_transfers','stock_transfer_items','deliveries','delivery_attempts'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'distribution.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'distribution.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on all tables in schema public to authenticated;
