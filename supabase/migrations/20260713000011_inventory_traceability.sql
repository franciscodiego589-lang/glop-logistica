-- 20260713000011_inventory_traceability.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 11 — INVENTÁRIO, AUDITORIA & RASTREABILIDADE                       ║
-- ║  Contagens cíclicas · ajuste automático · genealogia de lote (lote pai →  ║
-- ║  lote filho na produção) · rastreio full.                                 ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.count_status as enum ('open','counting','review','closed','canceled');

create table public.inventory_counts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  zone_id uuid references public.storage_zones(id) on delete set null,
  code text, status public.count_status not null default 'open',
  count_type text not null default 'cycle',            -- cycle, full, spot
  count_date date, closed_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_inventory_counts_status on public.inventory_counts (company_id, status) where deleted_at is null;

create table public.inventory_count_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  count_id uuid not null references public.inventory_counts(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  location_id uuid references public.storage_locations(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  system_quantity numeric(18,3), counted_quantity numeric(18,3),
  difference numeric(18,3) generated always as (coalesce(counted_quantity,0) - coalesce(system_quantity,0)) stored,
  adjusted boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_inventory_count_items_count on public.inventory_count_items (count_id);

-- ── LOT_GENEALOGY (rastreabilidade: lote pai → lote filho) ───────────────────
create table public.lot_genealogy (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  parent_lot_id uuid not null references public.product_lots(id) on delete cascade,
  child_lot_id uuid not null references public.product_lots(id) on delete cascade,
  production_order_id uuid references public.production_orders(id) on delete set null,
  quantity numeric(18,3),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_lot_genealogy_parent on public.lot_genealogy (parent_lot_id);
create index idx_lot_genealogy_child on public.lot_genealogy (child_lot_id);

-- ── RPC: aplica contagem (gera movimentos count_adjust das diferenças) ───────
create or replace function public.apply_inventory_count(p_count uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_wh uuid; v_it record; v_type public.stock_movement_type; v_count int := 0;
begin
  select company_id, warehouse_id into v_company, v_wh from public.inventory_counts where id = p_count;
  if v_company is null then raise exception 'count % not found', p_count; end if;
  if not app.has_permission('inventory.update', v_company) then raise exception 'forbidden'; end if;

  for v_it in select id, product_id, lot_id, difference from public.inventory_count_items
              where count_id = p_count and adjusted = false and product_id is not null
                and difference <> 0 and deleted_at is null
  loop
    v_type := case when v_it.difference > 0 then 'adjustment_in' else 'adjustment_out' end::public.stock_movement_type;
    perform public.register_stock_movement(
      v_it.product_id, v_wh, v_type, abs(v_it.difference),
      null, null, v_it.lot_id, null, 'inventory_count', p_count, 'Ajuste de inventário');
    update public.inventory_count_items set adjusted = true where id = v_it.id;
    v_count := v_count + 1;
  end loop;

  update public.inventory_counts set status = 'closed', closed_at = now() where id = p_count;
  return v_count;
end;
$$;
grant execute on function public.apply_inventory_count(uuid) to authenticated;

do $do$
declare t text; specs text[] := array['inventory_counts','inventory_count_items','lot_genealogy'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'inventory.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'inventory.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on all tables in schema public to authenticated;
