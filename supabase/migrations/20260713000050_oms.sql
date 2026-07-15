-- 20260713000050_oms.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  OMS — ENTERPRISE ORDER MANAGEMENT SYSTEM (Vol 18) — o MAESTRO            ║
-- ║  Ciclo completo do pedido: receber → validar (crédito + ATP) → RESERVAR   ║
-- ║  estoque (reserved_quantity, FIFO) → orquestrar → expedir (baixa estoque) ║
-- ║  → FATURAR (NF-e no Fiscal + venda no GL). Timeline de eventos + IA.      ║
-- ║  Nível SAP OM / Sterling / Manhattan OMS. oms_insights auto-descoberto.   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

do $e$ begin
  if not exists (select 1 from pg_type where typname='oms_order_status') then
    create type public.oms_order_status as enum
      ('new','credit_hold','approved','reserved','awaiting_production','picking','shipped','delivered','invoiced','canceled','returned'); end if;
end $e$;

insert into public.permissions (slug, resource, action, description)
select 'oms.' || a, 'oms', a, 'Permissão ' || a || ' em oms'
from unnest(array['read','create','update','delete','approve','fulfill']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'oms' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── SALES_ORDERS + ITEMS + EVENTS + RESERVATIONS ────────────────────────────
create table public.sales_orders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  order_number integer, account_id uuid references public.crm_accounts(id) on delete set null,
  customer_name text, channel text default 'b2b', order_type text default 'b2b',
  warehouse_id uuid references public.warehouses(id) on delete set null,
  salesperson text, payment_terms text, currency text default 'BRL', priority integer not null default 3,
  status public.oms_order_status not null default 'new', credit_status text default 'ok',
  subtotal numeric(18,2) not null default 0, discount_total numeric(18,2) not null default 0, total_amount numeric(18,2) not null default 0,
  expected_ship date, shipped_at timestamptz, delivered_at timestamptz, invoiced_at timestamptz,
  source text, notes text, cancel_reason text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_sales_orders_status on public.sales_orders (company_id, status) where deleted_at is null;

create table public.sales_order_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  order_id uuid not null references public.sales_orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  sku text, description text, quantity numeric(18,3) not null default 0, unit_price numeric(18,4) not null default 0,
  discount numeric(18,2) not null default 0, line_total numeric(18,2) not null default 0,
  reserved_qty numeric(18,3) not null default 0, shipped_qty numeric(18,3) not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_soi_order on public.sales_order_items (order_id);

create table public.order_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  order_id uuid not null references public.sales_orders(id) on delete cascade,
  event_type text not null, status_from text, status_to text, notes text, actor uuid,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_order_events_order on public.order_events (order_id, created_at);

create table public.order_reservations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  order_item_id uuid not null references public.sales_order_items(id) on delete cascade,
  stock_balance_id uuid references public.stock_balances(id) on delete set null,
  quantity numeric(18,3) not null default 0, released boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_order_reservations_item on public.order_reservations (order_item_id) where not released;

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- ATP — Available to Promise: disponível = on-hand − reservado; promessa por lead time
create or replace function public.check_atp(p_company uuid, p_product uuid, p_qty numeric default 0)
returns jsonb language plpgsql stable security definer set search_path = public, app as $$
declare v_onhand numeric; v_reserved numeric; v_avail numeric; v_prod record;
begin
  if not app.can_access_company(p_company) then return '{}'::jsonb; end if;
  select coalesce(sum(quantity),0), coalesce(sum(reserved_quantity),0) into v_onhand, v_reserved
  from public.stock_balances where company_id=p_company and product_id=p_product and deleted_at is null;
  v_avail := v_onhand - v_reserved;
  select is_manufactured, lead_time_days, name into v_prod from public.products where id=p_product;
  return jsonb_build_object('product', v_prod.name, 'on_hand', v_onhand, 'reserved', v_reserved, 'available', v_avail,
    'can_promise', v_avail >= coalesce(p_qty,0), 'shortfall', greatest(coalesce(p_qty,0) - v_avail, 0),
    'source', case when v_avail >= coalesce(p_qty,0) then 'estoque' when v_prod.is_manufactured then 'produção (CTP)' else 'compra' end,
    'promise_date', case when v_avail >= coalesce(p_qty,0) then now()::date else (now()::date + (coalesce(v_prod.lead_time_days,7) || ' days')::interval)::date end);
end;
$$;
grant execute on function public.check_atp(uuid, uuid, numeric) to authenticated;

-- Cria pedido + itens (preço do cadastro se não informado) + valida limite de crédito
create or replace function public.create_sales_order(p_company uuid, p_header jsonb, p_items jsonb)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare
  v_tenant uuid; v_order uuid; v_num int; v_it jsonb; v_prod record; v_price numeric; v_qty numeric; v_disc numeric;
  v_line numeric; v_sub numeric := 0; v_disctot numeric := 0; v_acct uuid; v_limit numeric; v_exposure numeric; v_status public.oms_order_status;
begin
  if not (app.can_access_company(p_company) and app.has_permission('oms.create', p_company)) then raise exception 'forbidden'; end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then raise exception 'pedido sem itens'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select coalesce(max(order_number),0)+1 into v_num from public.sales_orders where company_id=p_company;
  v_acct := nullif(p_header->>'account_id','')::uuid;

  insert into public.sales_orders (tenant_id, company_id, order_number, account_id, customer_name, channel, order_type,
      warehouse_id, salesperson, payment_terms, priority, status, expected_ship, source, notes)
  values (v_tenant, p_company, v_num, v_acct, p_header->>'customer_name', coalesce(p_header->>'channel','b2b'), coalesce(p_header->>'order_type','b2b'),
      nullif(p_header->>'warehouse_id','')::uuid, p_header->>'salesperson', p_header->>'payment_terms', coalesce((p_header->>'priority')::int,3),
      'new', nullif(p_header->>'expected_ship','')::date, p_header->>'source', p_header->>'notes')
  returning id into v_order;

  for v_it in select * from jsonb_array_elements(p_items) loop
    select id, sku, name, sale_price into v_prod from public.products where id=(v_it->>'product_id')::uuid;
    v_qty := coalesce((v_it->>'quantity')::numeric, 1);
    v_price := coalesce((v_it->>'unit_price')::numeric, v_prod.sale_price, 0);
    v_disc := coalesce((v_it->>'discount')::numeric, 0);
    v_line := round(v_qty * v_price - v_disc, 2);
    insert into public.sales_order_items (tenant_id, company_id, order_id, product_id, sku, description, quantity, unit_price, discount, line_total)
    values (v_tenant, p_company, v_order, v_prod.id, v_prod.sku, v_prod.name, v_qty, v_price, v_disc, v_line);
    v_sub := v_sub + round(v_qty * v_price, 2); v_disctot := v_disctot + v_disc;
  end loop;

  -- validação de crédito
  v_status := 'approved';
  if v_acct is not null then
    select credit_limit into v_limit from public.crm_accounts where id=v_acct;
    if v_limit is not null then
      select coalesce(sum(total_amount),0) into v_exposure from public.sales_orders
        where account_id=v_acct and status not in ('canceled','invoiced','delivered') and deleted_at is null and id<>v_order;
      if v_exposure + (v_sub - v_disctot) > v_limit then v_status := 'credit_hold'; end if;
    end if;
  end if;

  update public.sales_orders set subtotal=round(v_sub,2), discount_total=round(v_disctot,2), total_amount=round(v_sub - v_disctot,2),
    status=v_status, credit_status=case when v_status='credit_hold' then 'blocked' else 'ok' end where id=v_order;
  insert into public.order_events (tenant_id, company_id, order_id, event_type, status_to, notes, actor)
  values (v_tenant, p_company, v_order, 'created', v_status::text, 'Pedido criado', auth.uid());
  return jsonb_build_object('id', v_order, 'order_number', v_num, 'total', round(v_sub - v_disctot,2), 'status', v_status);
end;
$$;
grant execute on function public.create_sales_order(uuid, jsonb, jsonb) to authenticated;

-- Reserva de estoque (FIFO) incrementando reserved_quantity; CTP quando falta
create or replace function public.reserve_order_stock(p_order uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare o record; it record; bal record; v_need numeric; v_take numeric; v_all_ok boolean := true; v_short boolean := false;
begin
  select * into o from public.sales_orders where id=p_order and deleted_at is null;
  if o.id is null then raise exception 'pedido não encontrado'; end if;
  if not (app.can_access_company(o.company_id) and app.has_permission('oms.fulfill', o.company_id)) then raise exception 'forbidden'; end if;
  if o.status = 'credit_hold' then raise exception 'pedido bloqueado por crédito'; end if;

  for it in select * from public.sales_order_items where order_id=p_order and deleted_at is null loop
    v_need := it.quantity - it.reserved_qty;
    if v_need <= 0 or it.product_id is null then continue; end if;
    for bal in select * from public.stock_balances where company_id=o.company_id and product_id=it.product_id
        and deleted_at is null and (quantity - reserved_quantity) > 0
        and (o.warehouse_id is null or warehouse_id=o.warehouse_id) order by created_at loop
      exit when v_need <= 0;
      v_take := least(bal.quantity - bal.reserved_quantity, v_need);
      update public.stock_balances set reserved_quantity = reserved_quantity + v_take where id=bal.id;
      insert into public.order_reservations (tenant_id, company_id, order_item_id, stock_balance_id, quantity)
      values (o.tenant_id, o.company_id, it.id, bal.id, v_take);
      v_need := v_need - v_take;
    end loop;
    update public.sales_order_items set reserved_qty = it.quantity - v_need where id=it.id;
    if v_need > 0 then v_all_ok := false; v_short := true; end if;
  end loop;

  update public.sales_orders set status = (case when v_all_ok then 'reserved' else 'awaiting_production' end)::public.oms_order_status where id=p_order;
  insert into public.order_events (tenant_id, company_id, order_id, event_type, status_to, notes, actor)
  values (o.tenant_id, o.company_id, p_order, 'reserved', case when v_all_ok then 'reserved' else 'awaiting_production' end,
    case when v_short then 'Reserva parcial — falta estoque (CTP: acionar produção/compra)' else 'Estoque reservado integralmente' end, auth.uid());
  return jsonb_build_object('order_id', p_order, 'fully_reserved', v_all_ok, 'status', case when v_all_ok then 'reserved' else 'awaiting_production' end);
end;
$$;
grant execute on function public.reserve_order_stock(uuid) to authenticated;

-- Avança o pedido no ciclo; dispara integrações (expedição baixa estoque; faturamento gera NF-e + GL)
create or replace function public.advance_order(p_order uuid, p_status public.oms_order_status)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare o record; r record; v_from text; v_fiscal jsonb; v_gl jsonb; v_doc text;
begin
  select * into o from public.sales_orders where id=p_order and deleted_at is null;
  if o.id is null then raise exception 'pedido não encontrado'; end if;
  if not (app.can_access_company(o.company_id) and app.has_permission('oms.fulfill', o.company_id)) then raise exception 'forbidden'; end if;
  v_from := o.status::text;

  -- EXPEDIÇÃO: consome o estoque reservado (baixa física)
  if p_status = 'shipped' then
    for r in select res.*, sb.id sbid from public.order_reservations res
      join public.stock_balances sb on sb.id=res.stock_balance_id
      where res.order_item_id in (select id from public.sales_order_items where order_id=p_order) and not res.released loop
      update public.stock_balances set quantity = quantity - r.quantity, reserved_quantity = greatest(reserved_quantity - r.quantity,0) where id=r.sbid;
      update public.order_reservations set released=true where id=r.id;
    end loop;
    update public.sales_order_items soi set shipped_qty = soi.reserved_qty where soi.order_id=p_order;
    update public.sales_orders set shipped_at=now() where id=p_order;
  end if;

  -- FATURAMENTO: gera NF-e (Fiscal) + lança venda no GL
  if p_status = 'invoiced' and o.total_amount > 0 then
    begin v_fiscal := public.create_fiscal_document(o.company_id, 'nfe', 'issued', coalesce(o.customer_name,'Cliente'), 'sale', o.total_amount, null, 'SP', 'authorized');
      v_doc := v_fiscal->>'number'; exception when others then v_fiscal := null; end;
    begin v_gl := public.post_accounting_event(o.company_id, 'sale_invoice', o.total_amount, 'Venda pedido #'||o.order_number, 'SO-'||o.order_number, 'oms', p_order);
      exception when others then v_gl := null; end;
    update public.sales_orders set invoiced_at=now(), metadata = metadata || jsonb_build_object('nfe_number', v_doc) where id=p_order;
  end if;

  if p_status = 'delivered' then update public.sales_orders set delivered_at=now() where id=p_order; end if;

  update public.sales_orders set status=p_status where id=p_order;
  insert into public.order_events (tenant_id, company_id, order_id, event_type, status_from, status_to, notes, actor)
  values (o.tenant_id, o.company_id, p_order, 'status_change', v_from, p_status::text,
    case when p_status='invoiced' then 'Faturado — NF-e '||coalesce(v_doc,'?')||' + lançamento contábil' when p_status='shipped' then 'Expedido — estoque baixado' else null end, auth.uid());
  return jsonb_build_object('order_id', p_order, 'status', p_status, 'nfe', v_doc, 'gl_posted', v_gl is not null);
end;
$$;
grant execute on function public.advance_order(uuid, public.oms_order_status) to authenticated;

-- Cancelar pedido: libera reservas de estoque
create or replace function public.cancel_order(p_order uuid, p_reason text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare o record; r record;
begin
  select * into o from public.sales_orders where id=p_order and deleted_at is null;
  if o.id is null then raise exception 'pedido não encontrado'; end if;
  if not (app.can_access_company(o.company_id) and app.has_permission('oms.approve', o.company_id)) then raise exception 'forbidden'; end if;
  if o.status in ('invoiced','delivered') then raise exception 'pedido já faturado/entregue não pode ser cancelado'; end if;

  for r in select res.*, sb.id sbid from public.order_reservations res
    join public.stock_balances sb on sb.id=res.stock_balance_id
    where res.order_item_id in (select id from public.sales_order_items where order_id=p_order) and not res.released loop
    update public.stock_balances set reserved_quantity = greatest(reserved_quantity - r.quantity,0) where id=r.sbid;
    update public.order_reservations set released=true where id=r.id;
  end loop;

  update public.sales_orders set status='canceled', cancel_reason=p_reason where id=p_order;
  insert into public.order_events (tenant_id, company_id, order_id, event_type, status_to, notes, actor)
  values (o.tenant_id, o.company_id, p_order, 'canceled', 'canceled', coalesce(p_reason,'Cancelado'), auth.uid());
  return jsonb_build_object('order_id', p_order, 'status', 'canceled', 'reservations_released', true);
end;
$$;
grant execute on function public.cancel_order(uuid, text) to authenticated;

-- Dashboard OMS
create or replace function public.oms_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'orders_total', (select count(*) from public.sales_orders where company_id=p_company and deleted_at is null),
    'open', (select count(*) from public.sales_orders where company_id=p_company and status in ('new','approved','reserved','awaiting_production','picking') and deleted_at is null),
    'credit_hold', (select count(*) from public.sales_orders where company_id=p_company and status='credit_hold' and deleted_at is null),
    'awaiting_production', (select count(*) from public.sales_orders where company_id=p_company and status='awaiting_production' and deleted_at is null),
    'shipped', (select count(*) from public.sales_orders where company_id=p_company and status in ('shipped','delivered','invoiced') and deleted_at is null),
    'canceled', (select count(*) from public.sales_orders where company_id=p_company and status='canceled' and deleted_at is null),
    'revenue_invoiced', (select coalesce(sum(total_amount),0) from public.sales_orders where company_id=p_company and status in ('invoiced','delivered') and deleted_at is null),
    'open_value', (select coalesce(sum(total_amount),0) from public.sales_orders where company_id=p_company and status in ('new','approved','reserved','awaiting_production','picking') and deleted_at is null),
    'by_status', (select coalesce(jsonb_object_agg(status, c),'{}'::jsonb) from (select status, count(*) c from public.sales_orders where company_id=p_company and deleted_at is null group by status) s)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.oms_dashboard(uuid) to authenticated;

-- IA OMS: pedidos travados por crédito, aguardando produção, parados → LOGIA
create or replace function public.oms_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_credit int; v_prod int; v_stuck int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Pedidos%' and deleted_at is null;

  select count(*) into v_credit from public.sales_orders where company_id=p_company and status='credit_hold' and deleted_at is null;
  if v_credit > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'warning', 'Pedidos: bloqueados por crédito', v_credit||' pedido(s) retido(s) por limite de crédito.', 'Analisar liberação ou renegociar limite/entrada.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_prod from public.sales_orders where company_id=p_company and status='awaiting_production' and deleted_at is null;
  if v_prod > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'rupture_risk', 'warning', 'Pedidos: aguardando produção (falta estoque)', v_prod||' pedido(s) sem estoque suficiente (CTP).', 'Acionar PCP/compras para não estourar o prazo de entrega.', 86);
    v_c := v_c + 1;
  end if;
  select count(*) into v_stuck from public.sales_orders where company_id=p_company and status in ('new','approved','reserved','picking') and deleted_at is null and updated_at < now() - interval '3 days';
  if v_stuck > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'Pedidos: parados no fluxo', v_stuck||' pedido(s) sem avanço há mais de 3 dias.', 'Revisar gargalo de separação/expedição.', 80);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.oms_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'oms') ────────────
do $do$
declare t text; specs text[] := array['sales_orders','sales_order_items','order_events','order_reservations'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'oms.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'oms.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

notify pgrst, 'reload schema';
