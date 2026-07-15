-- 20260713000052_dcp.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  DCP — DIGITAL COMMERCE PLATFORM (Vol 20) — fecha o Núcleo Comercial      ║
-- ║  Lojas/marcas, catálogo, PRICING (lista por canal/cliente/volume),        ║
-- ║  promoções/cupons, carrinhos, assinaturas, marketplace, CMS/SEO.          ║
-- ║  A VENDA NASCE NA LOJA e desce p/ OMS→estoque→fiscal→contábil.            ║
-- ║  Vitrine pública anon (storefront_order). Nível VTEX/Shopify/commercetools.║
-- ╚══════════════════════════════════════════════════════════════════════════╝

do $e$ begin
  if not exists (select 1 from pg_type where typname='promotion_type') then
    create type public.promotion_type as enum ('percent','fixed','free_shipping','bxgy','gift'); end if;
  if not exists (select 1 from pg_type where typname='subscription_status') then
    create type public.subscription_status as enum ('active','paused','canceled'); end if;
end $e$;

insert into public.permissions (slug, resource, action, description)
select 'commerce.' || a, 'commerce', a, 'Permissão ' || a || ' em commerce'
from unnest(array['read','create','update','delete','approve','publish']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'commerce' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── STORES (lojas/marcas/domínios) ──────────────────────────────────────────
create table public.stores (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, slug text, domain text, channel_type text default 'b2c', currency text default 'BRL', locale text default 'pt-BR',
  is_active boolean not null default true, theme jsonb not null default '{}'::jsonb,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_stores_slug on public.stores (company_id, slug) where deleted_at is null;

-- ── PRICE_LISTS + ITEMS (pricing por canal/cliente/volume) ──────────────────
create table public.price_lists (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, channel text, account_id uuid references public.crm_accounts(id) on delete set null,
  currency text default 'BRL', priority integer not null default 1, enabled boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.price_list_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  price_list_id uuid not null references public.price_lists(id) on delete cascade,
  product_id uuid references public.products(id) on delete cascade,
  min_qty numeric(18,3) not null default 1, price numeric(18,4) not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_price_list_items on public.price_list_items (price_list_id, product_id);

-- ── PROMOTIONS (cupons / regras) ────────────────────────────────────────────
create table public.promotions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, code text, promo_type public.promotion_type not null default 'percent',
  value numeric(18,2) not null default 0, min_order numeric(18,2) not null default 0,
  starts_at date, ends_at date, usage_limit integer, used_count integer not null default 0, enabled boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_promotions_code on public.promotions (company_id, upper(code)) where deleted_at is null;

-- ── CARTS + ITEMS (persistente, abandono) ───────────────────────────────────
create table public.carts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  store_id uuid references public.stores(id) on delete set null, account_id uuid references public.crm_accounts(id) on delete set null,
  session_token text, customer_name text, email text, status text not null default 'open', total numeric(18,2) not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_carts_status on public.carts (company_id, status) where deleted_at is null;
create table public.cart_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  cart_id uuid not null references public.carts(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null, quantity numeric(18,3) not null default 1, unit_price numeric(18,4) not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── SUBSCRIPTIONS (assinaturas / recorrência) ───────────────────────────────
create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  account_id uuid references public.crm_accounts(id) on delete set null, product_id uuid references public.products(id) on delete set null,
  plan_name text, frequency text default 'monthly', amount numeric(18,2) not null default 0,
  status public.subscription_status not null default 'active', next_charge date, started_at date default now()::date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_subscriptions_next on public.subscriptions (company_id, next_charge) where deleted_at is null;

-- ── MARKETPLACE_LISTINGS + CMS_PAGES ────────────────────────────────────────
create table public.marketplace_listings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid references public.products(id) on delete cascade, marketplace text not null, external_id text,
  price numeric(18,2), status text default 'draft', synced_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.cms_pages (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  store_id uuid references public.stores(id) on delete set null,
  title text not null, slug text, page_type text default 'landing', content text, status text default 'draft',
  meta_title text, meta_description text, og_image text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Resolve o melhor preço (lista por canal/cliente/volume; senão sale_price)
create or replace function public.get_price(p_company uuid, p_product uuid, p_channel text default null, p_qty numeric default 1, p_account uuid default null)
returns numeric language sql stable security definer set search_path = public, app as $$
  select coalesce(
    (select pli.price from public.price_list_items pli
       join public.price_lists pl on pl.id=pli.price_list_id and pl.enabled and pl.deleted_at is null
       where pli.company_id=p_company and pli.product_id=p_product and pli.deleted_at is null
         and pli.min_qty <= coalesce(p_qty,1)
         and (pl.channel is null or pl.channel=p_channel)
         and (pl.account_id is null or pl.account_id=p_account)
       order by (case when pl.account_id is not null then 2 else 0 end) + (case when pl.channel is not null then 1 else 0 end) desc, pl.priority desc, pli.min_qty desc, pli.price asc
       limit 1),
    (select sale_price from public.products where id=p_product), 0);
$$;
grant execute on function public.get_price(uuid, uuid, text, numeric, uuid) to authenticated, anon;

-- Valida cupom e calcula desconto sobre um total
create or replace function public.apply_coupon(p_company uuid, p_code text, p_order_total numeric)
returns jsonb language plpgsql stable security definer set search_path = public, app as $$
declare pr record; v_disc numeric := 0;
begin
  select * into pr from public.promotions where company_id=p_company and upper(code)=upper(p_code) and enabled and deleted_at is null
    and (starts_at is null or starts_at <= now()::date) and (ends_at is null or ends_at >= now()::date)
    and (usage_limit is null or used_count < usage_limit) limit 1;
  if pr.id is null then return jsonb_build_object('valid', false, 'message', 'Cupom inválido ou expirado'); end if;
  if p_order_total < pr.min_order then return jsonb_build_object('valid', false, 'message', 'Pedido mínimo de R$ '||pr.min_order); end if;
  v_disc := case pr.promo_type when 'percent' then round(p_order_total * pr.value/100, 2) when 'fixed' then least(pr.value, p_order_total) else 0 end;
  return jsonb_build_object('valid', true, 'type', pr.promo_type, 'discount', v_disc, 'free_shipping', pr.promo_type='free_shipping', 'name', pr.name, 'promotion_id', pr.id);
end;
$$;
grant execute on function public.apply_coupon(uuid, text, numeric) to authenticated, anon;

-- CHECKOUT PÚBLICO (anon): a venda nasce na loja → cria pedido no OMS
create or replace function public.storefront_order(p_company uuid, p_store uuid, p_customer text, p_email text, p_items jsonb, p_coupon text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare
  v_tenant uuid; v_store record; v_order uuid; v_num int; v_it jsonb; v_prod record; v_price numeric; v_qty numeric;
  v_sub numeric := 0; v_disc numeric := 0; v_coupon jsonb;
begin
  if p_store is null then
    select * into v_store from public.stores where company_id=p_company and is_active and deleted_at is null order by created_at limit 1;
  else
    select * into v_store from public.stores where id=p_store and company_id=p_company and deleted_at is null;
  end if;
  if v_store.id is null then return jsonb_build_object('error','loja inválida'); end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then return jsonb_build_object('error','carrinho vazio'); end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select coalesce(max(order_number),0)+1 into v_num from public.sales_orders where company_id=p_company;

  insert into public.sales_orders (tenant_id, company_id, order_number, customer_name, channel, order_type, status, source, notes)
  values (v_tenant, p_company, v_num, p_customer, 'ecommerce', v_store.channel_type, 'new', v_store.name, 'Pedido via loja online')
  returning id into v_order;

  for v_it in select * from jsonb_array_elements(p_items) loop
    select id, sku, name into v_prod from public.products where id=(v_it->>'product_id')::uuid;
    v_qty := coalesce((v_it->>'quantity')::numeric, 1);
    v_price := public.get_price(p_company, v_prod.id, v_store.channel_type, v_qty, null);
    insert into public.sales_order_items (tenant_id, company_id, order_id, product_id, sku, description, quantity, unit_price, line_total)
    values (v_tenant, p_company, v_order, v_prod.id, v_prod.sku, v_prod.name, v_qty, v_price, round(v_qty*v_price,2));
    v_sub := v_sub + round(v_qty*v_price, 2);
  end loop;

  if p_coupon is not null then
    v_coupon := public.apply_coupon(p_company, p_coupon, v_sub);
    if (v_coupon->>'valid')::boolean then
      v_disc := coalesce((v_coupon->>'discount')::numeric, 0);
      update public.promotions set used_count = used_count + 1 where id = (v_coupon->>'promotion_id')::uuid;
    end if;
  end if;

  update public.sales_orders set subtotal=round(v_sub,2), discount_total=round(v_disc,2), total_amount=round(v_sub - v_disc,2) where id=v_order;
  insert into public.order_events (tenant_id, company_id, order_id, event_type, status_to, notes)
  values (v_tenant, p_company, v_order, 'created', 'new', 'Pedido criado na loja online '||v_store.name);
  return jsonb_build_object('order_number', v_num, 'subtotal', round(v_sub,2), 'discount', round(v_disc,2), 'total', round(v_sub - v_disc,2));
end;
$$;
grant execute on function public.storefront_order(uuid, uuid, text, text, jsonb, text) to anon, authenticated;

-- Catálogo público da loja (anon)
create or replace function public.commerce_catalog(p_company uuid, p_store uuid default null)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select coalesce((select jsonb_agg(jsonb_build_object(
      'id', p.id, 'name', p.name, 'sku', p.sku, 'description', coalesce(p.short_description, p.description),
      'price', public.get_price(p_company, p.id, 'b2c', 1, null),
      'category', (select name from public.product_categories c where c.id=p.category_id)) order by p.name)
    from public.products p
    where p.company_id=p_company and coalesce(p.is_sellable,true) and p.active and p.deleted_at is null limit 100), '[]'::jsonb);
$$;
grant execute on function public.commerce_catalog(uuid, uuid) to anon, authenticated;

-- Dashboard e-commerce
create or replace function public.dcp_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'stores', (select count(*) from public.stores where company_id=p_company and deleted_at is null),
    'promotions_active', (select count(*) from public.promotions where company_id=p_company and enabled and deleted_at is null and (ends_at is null or ends_at>=now()::date)),
    'carts_open', (select count(*) from public.carts where company_id=p_company and status='open' and deleted_at is null),
    'carts_abandoned', (select count(*) from public.carts where company_id=p_company and status='abandoned' and deleted_at is null),
    'subscriptions_active', (select count(*) from public.subscriptions where company_id=p_company and status='active' and deleted_at is null),
    'listings', (select count(*) from public.marketplace_listings where company_id=p_company and deleted_at is null),
    'ecom_orders', (select count(*) from public.sales_orders where company_id=p_company and channel='ecommerce' and deleted_at is null),
    'ecom_revenue', (select coalesce(sum(total_amount),0) from public.sales_orders where company_id=p_company and channel='ecommerce' and deleted_at is null),
    'ecom_aov', (select coalesce(round(avg(total_amount),2),0) from public.sales_orders where company_id=p_company and channel='ecommerce' and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.dcp_dashboard(uuid) to authenticated;

-- IA COMMERCE: carrinhos abandonados, promoções vencendo, assinaturas a renovar → LOGIA
create or replace function public.dcp_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_aband int; v_promo int; v_subs int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Loja%' and deleted_at is null;

  select count(*) into v_aband from public.carts where company_id=p_company and status='open' and deleted_at is null and updated_at < now() - interval '1 day' and total > 0;
  if v_aband > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'opportunity', 'warning', 'Loja: carrinhos abandonados', v_aband||' carrinho(s) parado(s) há +24h com itens.', 'Disparar recuperação (e-mail/WhatsApp) com cupom.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_promo from public.promotions where company_id=p_company and enabled and deleted_at is null and ends_at between now()::date and now()::date+3;
  if v_promo > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'demand_shift', 'info', 'Loja: promoções encerrando', v_promo||' promoção(ões) encerra(m) em 3 dias.', 'Avaliar prorrogação ou nova campanha.', 70);
    v_c := v_c + 1;
  end if;
  select count(*) into v_subs from public.subscriptions where company_id=p_company and status='active' and deleted_at is null and next_charge <= now()::date + 3;
  if v_subs > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'opportunity', 'info', 'Loja: assinaturas a renovar', v_subs||' assinatura(s) com cobrança nos próximos 3 dias.', 'Garantir meio de pagamento válido para evitar churn.', 76);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.dcp_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'commerce') ───────
do $do$
declare t text; specs text[] := array['stores','price_lists','price_list_items','promotions','carts','cart_items','subscriptions','marketplace_listings','cms_pages'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'commerce.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'commerce.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: loja padrão + promoções ══
do $do$
declare c record; v_store uuid;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    if not exists (select 1 from public.stores where company_id=c.id and slug='loja-oficial' and deleted_at is null) then
      insert into public.stores (tenant_id, company_id, name, slug, channel_type) values (c.tenant_id, c.id, 'Loja Oficial', 'loja-oficial', 'b2c') returning id into v_store;
    end if;
    if not exists (select 1 from public.promotions where company_id=c.id and code='BEMVINDO10' and deleted_at is null) then
      insert into public.promotions (tenant_id, company_id, name, code, promo_type, value, min_order)
      values (c.tenant_id, c.id, 'Bem-vindo 10%', 'BEMVINDO10', 'percent', 10, 0),
             (c.tenant_id, c.id, 'Frete grátis acima de 199', 'FRETEGRATIS', 'free_shipping', 0, 199);
    end if;
  end loop;
end $do$;

notify pgrst, 'reload schema';
