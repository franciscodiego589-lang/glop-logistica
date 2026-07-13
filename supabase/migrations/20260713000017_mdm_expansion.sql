-- 20260713000017_mdm_expansion.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 02 · MÓDULO 01 — CADASTRO MESTRE (MDM) — EXPANSÃO                  ║
-- ║  Aprofunda o master data conforme a Constituição: marcas, multi-fornecedor║
-- ║  por produto, custos, tributos, mídias/documentos, atributos extras,      ║
-- ║  score de qualidade de dados (Data Quality) e dashboard MDM.              ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.xyz_class         as enum ('X','Y','Z','none');
create type public.product_media_kind as enum ('main','technical','commercial','packaging','pallet','logistics','image360','model3d','video','manual');
create type public.product_cost_kind  as enum ('average','last','standard','replacement','import','freight','financial');
create type public.product_tax_kind   as enum ('IPI','ICMS','ICMS_ST','PIS','COFINS','ISS','II','IPI_ENTRADA');

-- ── PRODUCT_BRANDS (marcas) ──────────────────────────────────────────────────
create table public.product_brands (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, name text not null, manufacturer text, country text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_product_brands_name on public.product_brands (company_id, lower(name)) where deleted_at is null;

-- ── Atributos extras no PRODUCTS (identificação, classificação, dimensões) ──
alter table public.products
  add column short_description text,
  add column technical_description text,
  add column commercial_description text,
  add column slug text,
  add column keywords text[],
  add column gtin text, add column dun text, add column upc text, add column rfid_tag text,
  add column brand_id uuid references public.product_brands(id) on delete set null,
  add column model text, add column version_label text, add column segment text,
  add column xyz_class public.xyz_class not null default 'none',
  add column cfop_default text, add column tax_origin text, add column tax_type text,
  add column net_weight_g numeric(14,3), add column gross_weight_g numeric(14,3),
  add column taxable_weight_g numeric(14,3), add column cubage_m3 numeric(14,4),
  add column area_cm2 numeric(14,3), add column stack_max integer,
  add column is_perishable boolean not null default false,
  add column is_hazardous boolean not null default false,
  add column is_controlled boolean not null default false,
  add column data_quality_score numeric(5,2) not null default 0;
create index idx_products_brand on public.products (brand_id);

-- ── PRODUCT_SUPPLIERS (multi-fornecedor por produto) ────────────────────────
create table public.product_suppliers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  supplier_id uuid not null references public.suppliers(id) on delete cascade,
  is_primary boolean not null default false,
  supplier_sku text, lead_time_days integer, moq numeric(18,3),
  last_price numeric(14,4), last_purchase_date date, sla_score numeric(5,2), ranking integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_product_suppliers_product on public.product_suppliers (product_id);
create unique index uq_product_suppliers on public.product_suppliers (product_id, supplier_id) where deleted_at is null;

-- ── PRODUCT_CUSTOMERS (clientes autorizados/exclusivos/bloqueados) ──────────
create table public.product_customers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  customer_id uuid not null references public.customers(id) on delete cascade,
  relation text not null default 'authorized',    -- authorized, exclusive, blocked
  special_price numeric(14,4), price_table text, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_product_customers_product on public.product_customers (product_id);

-- ── PRODUCT_COSTS (histórico de custos por tipo) ─────────────────────────────
create table public.product_costs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  cost_kind public.product_cost_kind not null, amount numeric(16,4) not null default 0,
  currency text not null default 'BRL', effective_date date not null default now(),
  markup_percent numeric(8,3), margin_percent numeric(8,3),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_product_costs_product on public.product_costs (product_id, effective_date desc);

-- ── PRODUCT_TAXES (tributação por imposto) ───────────────────────────────────
create table public.product_taxes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  tax_kind public.product_tax_kind not null, rate numeric(8,4), cst text, reduction_percent numeric(8,4),
  benefit text, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_product_taxes_product on public.product_taxes (product_id);

-- ── PRODUCT_MEDIA (fotos/vídeos/3D/360) ──────────────────────────────────────
create table public.product_media (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  media_kind public.product_media_kind not null default 'main',
  url text, storage_path text, title text, position integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_product_media_product on public.product_media (product_id);

-- ── PRODUCT_DOCUMENTS (ficha técnica, POP, laudos, FISPQ, certificados) ─────
create table public.product_documents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  doc_type text not null,                          -- datasheet, pop, spec, report, fispq, manual, iso, anvisa, mapa, inmetro
  title text, url text, storage_path text, issued_at date, expires_at date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_product_documents_product on public.product_documents (product_id);

-- ── RPC: Data Quality Score (completude cadastral 0–100) ────────────────────
create or replace function public.compute_data_quality(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_count int;
begin
  if not app.has_permission('master_data.update', p_company) then raise exception 'forbidden'; end if;
  with score as (
    select p.id,
      ( (case when p.sku is not null then 1 else 0 end)
      + (case when p.ncm is not null then 1 else 0 end)
      + (case when p.category_id is not null then 1 else 0 end)
      + (case when p.brand_id is not null then 1 else 0 end)
      + (case when coalesce(p.gross_weight_g,p.weight_g) is not null then 1 else 0 end)
      + (case when p.length_mm is not null and p.width_mm is not null and p.height_mm is not null then 1 else 0 end)
      + (case when p.cost_price is not null then 1 else 0 end)
      + (case when p.barcode is not null or p.gtin is not null then 1 else 0 end)
      + (case when exists(select 1 from public.product_suppliers s where s.product_id=p.id and s.deleted_at is null) then 1 else 0 end)
      + (case when exists(select 1 from public.product_media m where m.product_id=p.id and m.deleted_at is null) then 1 else 0 end)
      )::numeric / 10 * 100 as q
    from public.products p where p.company_id=p_company and p.deleted_at is null
  )
  update public.products p set data_quality_score = round(s.q,2) from score s where s.id=p.id;
  get diagnostics v_count = row_count;
  return v_count;
end;
$$;
grant execute on function public.compute_data_quality(uuid) to authenticated;

-- ── RPC: Dashboard MDM (cartões de qualidade cadastral) ─────────────────────
create or replace function public.mdm_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select jsonb_build_object(
    'total',            (select count(*) from public.products where company_id=p_company and deleted_at is null),
    'active',           (select count(*) from public.products where company_id=p_company and active and deleted_at is null),
    'blocked',          (select count(*) from public.products where company_id=p_company and not active and deleted_at is null),
    'no_photo',         (select count(*) from public.products p where p.company_id=p_company and p.deleted_at is null and not exists(select 1 from public.product_media m where m.product_id=p.id and m.deleted_at is null)),
    'no_supplier',      (select count(*) from public.products p where p.company_id=p_company and p.deleted_at is null and not exists(select 1 from public.product_suppliers s where s.product_id=p.id and s.deleted_at is null)),
    'no_tax',           (select count(*) from public.products where company_id=p_company and deleted_at is null and ncm is null),
    'no_dimensions',    (select count(*) from public.products where company_id=p_company and deleted_at is null and (length_mm is null or width_mm is null or height_mm is null)),
    'no_location',      (select count(*) from public.products where company_id=p_company and deleted_at is null and default_location_id is null),
    'brands',           (select count(*) from public.product_brands where company_id=p_company and deleted_at is null),
    'categories',       (select count(*) from public.product_categories where company_id=p_company and deleted_at is null),
    'abc_a',            (select count(*) from public.products where company_id=p_company and abc_class='A' and deleted_at is null),
    'data_quality_avg', (select round(coalesce(avg(data_quality_score),0),1) from public.products where company_id=p_company and deleted_at is null)
  ) where app.can_access_company(p_company);
$$;
grant execute on function public.mdm_dashboard(uuid) to authenticated;

do $do$
declare t text; specs text[] := array[
  'product_brands','product_suppliers','product_customers','product_costs','product_taxes','product_media','product_documents'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'master_data.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'master_data.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on all tables in schema public to authenticated;
