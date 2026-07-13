-- 20260713000002_master_data.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 02 — CADASTRO MESTRE                                               ║
-- ║  Produtos/SKU · categorias · fornecedores · almoxarifados ·               ║
-- ║  endereçamento (zonas + posições/bins) · lotes/validade · séries ·        ║
-- ║  embalagens/UoM (un→caixa→pallet) · kits/BOM simples.                      ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- ── Enums ────────────────────────────────────────────────────────────────────
create type public.product_type          as enum ('finished_good','raw_material','component','packaging','consumable','kit','service','other');
create type public.abc_class             as enum ('A','B','C','none');
create type public.uom_kind              as enum ('count','weight','volume','length','area','time');
create type public.uom_level             as enum ('base','inner','case','pallet');
create type public.storage_zone_type     as enum ('receiving','storage','picking','packing','shipping','quarantine','returns','production','transit');
create type public.storage_location_type as enum ('bin','floor','staging','dock','transit','virtual');
create type public.storage_location_status as enum ('available','blocked','full','maintenance');
create type public.serial_status         as enum ('in_stock','reserved','sold','consumed','in_transit','defective','returned','scrapped');

-- ── PRODUCT_CATEGORIES (hierárquica) ─────────────────────────────────────────
create table public.product_categories (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  parent_id uuid references public.product_categories(id) on delete set null,
  code text, name text not null,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_product_categories_parent on public.product_categories (parent_id);
create unique index uq_product_categories_name on public.product_categories (company_id, lower(name)) where deleted_at is null;

-- ── UNITS_OF_MEASURE (catálogo por empresa) ──────────────────────────────────
create table public.units_of_measure (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null, name text not null, uom_kind public.uom_kind not null default 'count',
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_uom_code on public.units_of_measure (company_id, lower(code)) where deleted_at is null;

-- ── SUPPLIERS (fornecedores) ─────────────────────────────────────────────────
create table public.suppliers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, name text not null, legal_name text, document text,
  contact_name text, phone text, email text, address text,
  lead_time_days integer, rating numeric(3,1), notes text,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_suppliers_name_trgm on public.suppliers using gin (name gin_trgm_ops);
create unique index uq_suppliers_document on public.suppliers (company_id, document) where document is not null and deleted_at is null;

-- ── WAREHOUSES (armazéns / CDs) ──────────────────────────────────────────────
create table public.warehouses (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, name text not null, warehouse_type text not null default 'distribution', -- distribution, factory, transit, 3pl
  address text, latitude numeric(10,7), longitude numeric(10,7), notes text,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_warehouses_name on public.warehouses (company_id, lower(name)) where deleted_at is null;

-- ── PRODUCTS (SKU) ───────────────────────────────────────────────────────────
create table public.products (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  category_id uuid references public.product_categories(id) on delete set null,
  supplier_id uuid references public.suppliers(id) on delete set null,
  code text, sku text, barcode text, name text not null, description text,
  product_type public.product_type not null default 'finished_good',
  base_uom_code text not null default 'un',
  ncm text, cest text, origin text,                     -- fiscal
  weight_g numeric(14,3), length_mm numeric(12,2), width_mm numeric(12,2), height_mm numeric(12,2),
  cost_price numeric(14,4), sale_price numeric(14,2),
  min_stock numeric(16,3) not null default 0, max_stock numeric(16,3),
  reorder_point numeric(16,3), safety_stock numeric(16,3), lead_time_days integer,
  abc_class public.abc_class not null default 'none',
  shelf_life_days integer,
  requires_lot boolean not null default false, requires_validity boolean not null default false,
  requires_serial boolean not null default false, is_kit boolean not null default false,
  is_purchasable boolean not null default true, is_sellable boolean not null default true,
  is_manufactured boolean not null default false,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_products_sku on public.products (company_id, sku) where sku is not null and deleted_at is null;
create unique index uq_products_code on public.products (company_id, code) where code is not null and deleted_at is null;
create index idx_products_category on public.products (category_id);
create index idx_products_supplier on public.products (supplier_id);
create index idx_products_barcode  on public.products (barcode);
create index idx_products_name_trgm on public.products using gin (name gin_trgm_ops);

-- ── PRODUCT_PACKAGINGS (embalagens/conversão: un→caixa→pallet) ───────────────
create table public.product_packagings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  uom_id uuid references public.units_of_measure(id) on delete set null,
  uom_code text not null, level public.uom_level not null default 'base',
  factor_to_base numeric(16,4) not null default 1,     -- unidades-base neste nível
  barcode text, gross_weight_g numeric(14,3),
  length_mm numeric(12,2), width_mm numeric(12,2), height_mm numeric(12,2),
  is_default_purchase boolean not null default false, is_default_sale boolean not null default false,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_product_packagings_product on public.product_packagings (product_id);
create unique index uq_product_packagings_level on public.product_packagings (product_id, level) where deleted_at is null;
create unique index uq_product_packagings_barcode on public.product_packagings (company_id, barcode) where barcode is not null and deleted_at is null;

-- ── PRODUCT_LOTS (lotes + validade) ──────────────────────────────────────────
create table public.product_lots (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  supplier_id uuid references public.suppliers(id) on delete set null,
  lot_number text not null, manufacture_date date, expiry_date date,
  cost numeric(14,4), received_quantity numeric(16,3), quality_status text not null default 'released', -- released, quarantine, blocked
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_product_lots_product on public.product_lots (product_id);
create index idx_product_lots_expiry on public.product_lots (company_id, expiry_date) where deleted_at is null;
create unique index uq_product_lots_number on public.product_lots (product_id, lot_number) where deleted_at is null;

-- ── STORAGE_ZONES (zonas do armazém) ─────────────────────────────────────────
create table public.storage_zones (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid not null references public.warehouses(id) on delete cascade,
  code text not null, name text not null, zone_type public.storage_zone_type not null default 'storage',
  temperature_controlled boolean not null default false,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_storage_zones_warehouse on public.storage_zones (warehouse_id);
create unique index uq_storage_zones_code on public.storage_zones (warehouse_id, lower(code)) where deleted_at is null;

-- ── STORAGE_LOCATIONS (posições/bins endereçáveis) ───────────────────────────
create table public.storage_locations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid not null references public.warehouses(id) on delete cascade,
  zone_id uuid references public.storage_zones(id) on delete set null,
  code text not null, location_type public.storage_location_type not null default 'bin',
  status public.storage_location_status not null default 'available',
  aisle text, rack text, level text, position text, pick_sequence integer,
  max_weight_g numeric(16,3), max_volume_cm3 numeric(16,3), max_units numeric(16,3),
  allow_mixed_products boolean not null default true, allow_mixed_lots boolean not null default true,
  is_pickable boolean not null default true, is_putawayable boolean not null default true,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_storage_locations_warehouse on public.storage_locations (warehouse_id);
create index idx_storage_locations_zone on public.storage_locations (zone_id);
create index idx_storage_locations_pickseq on public.storage_locations (warehouse_id, pick_sequence) where deleted_at is null;
create unique index uq_storage_locations_code on public.storage_locations (warehouse_id, lower(code)) where deleted_at is null;

-- endereço-padrão de armazenagem do produto (sugestão de putaway)
alter table public.products add column default_location_id uuid references public.storage_locations(id) on delete set null;
create index idx_products_default_location on public.products (default_location_id);

-- ── PRODUCT_SERIALS (rastreio unitário) ──────────────────────────────────────
create table public.product_serials (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  lot_id uuid references public.product_lots(id) on delete set null,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  location_id uuid references public.storage_locations(id) on delete set null,
  serial_number text not null, status public.serial_status not null default 'in_stock',
  reference_type text, reference_id uuid,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_product_serials_product on public.product_serials (product_id);
create index idx_product_serials_location on public.product_serials (location_id);
create unique index uq_product_serials_number on public.product_serials (product_id, serial_number) where deleted_at is null;

-- ── KIT_ITEMS (composição de kit / BOM simples) ──────────────────────────────
create table public.kit_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  kit_product_id uuid not null references public.products(id) on delete cascade,
  component_product_id uuid not null references public.products(id) on delete cascade,
  quantity numeric(16,4) not null default 1,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_kit_items_kit on public.kit_items (kit_product_id);

-- ── RLS + triggers + policies + índice company_id (padrão via loop) ──────────
do $do$
declare spec text; t text; ins_perm text; upd_perm text;
  specs text[] := array[
    'product_categories|master_data.create|master_data.update',
    'units_of_measure|master_data.create|master_data.update',
    'suppliers|master_data.create|master_data.update',
    'warehouses|master_data.create|master_data.update',
    'products|master_data.create|master_data.update',
    'product_packagings|master_data.create|master_data.update',
    'product_lots|inventory.create|inventory.update',
    'storage_zones|wms.create|wms.update',
    'storage_locations|wms.create|wms.update',
    'product_serials|inventory.create|inventory.update',
    'kit_items|master_data.create|master_data.update'
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
