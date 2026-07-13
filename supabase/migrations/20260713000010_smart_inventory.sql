-- 20260713000010_smart_inventory.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 10 — ESTOQUE INTELIGENTE                                           ║
-- ║  Snapshots · sugestões de ressuprimento · curva ABC · KPIs · cobertura.   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create table public.stock_snapshots (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  snapshot_date date not null, quantity numeric(18,3) not null default 0, value numeric(18,4),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_stock_snapshots_product on public.stock_snapshots (product_id, snapshot_date);
create unique index uq_stock_snapshots_key on public.stock_snapshots (product_id, warehouse_id, snapshot_date);

create table public.reorder_suggestions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  on_hand numeric(18,3), reorder_point numeric(18,3), suggested_quantity numeric(18,3),
  reason text, status text not null default 'open',   -- open, ordered, dismissed
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_reorder_suggestions_status on public.reorder_suggestions (company_id, status) where deleted_at is null;

-- ── Materialized view: saldo consolidado por produto (relatório pesado) ──────
create materialized view public.mv_stock_on_hand as
select b.company_id, b.tenant_id, b.product_id,
       sum(b.quantity) as on_hand, sum(b.reserved_quantity) as reserved,
       sum(b.quantity * coalesce(p.cost_price,0)) as stock_value
from public.stock_balances b
join public.products p on p.id = b.product_id
where b.deleted_at is null
group by b.company_id, b.tenant_id, b.product_id;
create unique index uq_mv_stock_on_hand on public.mv_stock_on_hand (company_id, product_id);
-- MV não tem RLS → revoga acesso direto para evitar vazamento cross-tenant
revoke all on public.mv_stock_on_hand from anon, authenticated;

-- ── RPC: curva ABC (classifica produtos por valor de consumo 90d) ───────────
create or replace function public.calculate_abc(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_count int := 0;
begin
  if not app.has_permission('inventory.update', p_company) then raise exception 'forbidden'; end if;
  with consumption as (
    select m.product_id, sum(abs(m.signed_quantity) * coalesce(m.unit_cost, p.cost_price, 0)) as val
    from public.stock_movements m join public.products p on p.id = m.product_id
    where m.company_id = p_company and m.signed_quantity < 0
      and m.occurred_at > now() - interval '90 days' and m.deleted_at is null
    group by m.product_id
  ), ranked as (
    select product_id, val,
           sum(val) over (order by val desc) / nullif(sum(val) over (),0) as cum_pct
    from consumption
  )
  update public.products p set abc_class = case
      when r.cum_pct <= 0.8 then 'A' when r.cum_pct <= 0.95 then 'B' else 'C' end::public.abc_class
  from ranked r where p.id = r.product_id and p.company_id = p_company;
  get diagnostics v_count = row_count;
  return v_count;
end;
$$;
grant execute on function public.calculate_abc(uuid) to authenticated;

-- ── RPC: gera sugestões de ressuprimento (on_hand < reorder_point) ──────────
create or replace function public.generate_reorder_suggestions(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_p record; v_onhand numeric;
begin
  if not app.has_permission('inventory.create', p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id = p_company;

  for v_p in select id, reorder_point, max_stock, min_stock from public.products
             where company_id = p_company and active and deleted_at is null and reorder_point is not null
  loop
    select coalesce(sum(quantity),0) into v_onhand from public.stock_balances
      where product_id = v_p.id and deleted_at is null;
    if v_onhand < v_p.reorder_point then
      insert into public.reorder_suggestions (tenant_id, company_id, product_id, on_hand, reorder_point, suggested_quantity, reason)
      values (v_tenant, p_company, v_p.id, v_onhand, v_p.reorder_point,
              greatest(coalesce(v_p.max_stock, v_p.reorder_point*2) - v_onhand, 0),
              'Saldo abaixo do ponto de pedido');
      v_count := v_count + 1;
    end if;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.generate_reorder_suggestions(uuid) to authenticated;

-- ── RPC: KPIs de estoque (cartões do dashboard) ─────────────────────────────
create or replace function public.inventory_kpis(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select jsonb_build_object(
    'skus_active',      (select count(*) from public.products where company_id = p_company and active and deleted_at is null),
    'stock_value',      (select coalesce(sum(b.quantity*coalesce(p.cost_price,0)),0) from public.stock_balances b join public.products p on p.id=b.product_id where b.company_id=p_company and b.deleted_at is null),
    'below_reorder',    (select count(*) from public.reorder_suggestions where company_id=p_company and status='open' and deleted_at is null),
    'expiring_30d',     (select count(*) from public.product_lots where company_id=p_company and expiry_date between now()::date and (now()+interval '30 days')::date and deleted_at is null),
    'open_receipts',    (select count(*) from public.inbound_receipts where company_id=p_company and status in ('expected','arrived','receiving') and deleted_at is null),
    'pending_tasks',    (select count(*) from public.warehouse_tasks where company_id=p_company and status in ('pending','assigned','in_progress') and deleted_at is null)
  ) where app.can_access_company(p_company);
$$;
grant execute on function public.inventory_kpis(uuid) to authenticated;

do $do$
declare t text; specs text[] := array['stock_snapshots','reorder_suggestions'];
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
-- IMPORTANTE: o grant acima inclui MVs → revogar de novo para não vazar cross-tenant
revoke all on public.mv_stock_on_hand from anon, authenticated;
