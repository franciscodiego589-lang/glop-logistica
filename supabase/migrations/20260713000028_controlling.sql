-- 20260713000028_controlling.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 12 — CONTROLADORIA & CUSTOS (CO)                                   ║
-- ║  Nível SAP CO + Oracle Cost Mgmt + Dynamics Finance + Infor LN.           ║
-- ║  Reusa cost_centers, allocation_rules/targets, financial_budgets,         ║
-- ║  compute_batch_cost (EFP). Adiciona: centros de lucro, objetos de custo,  ║
-- ║  lançamentos de custo (fact), custo padrão, simulações, settings de       ║
-- ║  custeio + RPCs de DRE gerencial, variações, margem e IA de controladoria.║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.profit_center_type as enum ('branch','brand','product','channel','franchise','project','unit');
create type public.cost_object_type   as enum ('product','lot','production_order','service','procedure','project','customer','contract');
create type public.costing_method     as enum ('absorption','variable','direct','abc','standard','real','target','kaizen');
create type public.cost_type          as enum ('material','packaging','direct_labor','indirect_labor','energy','water','gas','steam','compressed_air','depreciation','maintenance','loss','scrap','rework','overhead','service','freight','other');

-- recurso RBAC dedicado
insert into public.permissions (slug, resource, action, description)
select 'controlling.' || a, 'controlling', a, 'Permissão ' || a || ' em controlling'
from unnest(array['read','create','update','delete','approve','export']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'controlling' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── PROFIT_CENTERS (centros de lucro) ───────────────────────────────────────
create table public.profit_centers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  parent_id uuid references public.profit_centers(id) on delete set null,
  code text, name text not null, pc_type public.profit_center_type not null default 'unit',
  responsible text, status text not null default 'active',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_profit_centers_parent on public.profit_centers (parent_id);

-- ── COST_OBJECTS (objetos de custo) ─────────────────────────────────────────
create table public.cost_objects (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  object_type public.cost_object_type not null default 'product',
  product_id uuid references public.products(id) on delete set null,
  reference_type text, reference_id uuid, code text, name text not null, status text not null default 'open',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_cost_objects_product on public.cost_objects (product_id);

-- ── COST_ENTRIES (lançamentos de custo — tabela-fato) ───────────────────────
create table public.cost_entries (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  cost_center_id uuid references public.cost_centers(id) on delete set null,
  profit_center_id uuid references public.profit_centers(id) on delete set null,
  cost_object_id uuid references public.cost_objects(id) on delete set null,
  product_id uuid references public.products(id) on delete set null,
  cost_type public.cost_type not null default 'material',
  method public.costing_method not null default 'real',
  amount numeric(18,4) not null default 0, quantity numeric(18,4), unit text,
  period_month date not null default date_trunc('month', now())::date,
  is_planned boolean not null default false, reference_type text, reference_id uuid, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_cost_entries_period on public.cost_entries (company_id, period_month) where deleted_at is null;
create index idx_cost_entries_cc on public.cost_entries (cost_center_id);
create index idx_cost_entries_product on public.cost_entries (product_id);

-- ── STANDARD_COSTS (custo padrão por produto/tipo) ──────────────────────────
create table public.standard_costs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  cost_type public.cost_type not null default 'material',
  amount_per_unit numeric(18,6) not null default 0, effective_date date not null default current_date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_standard_costs_product on public.standard_costs (product_id);

-- ── COST_DRIVERS (ABC — direcionadores) ─────────────────────────────────────
create table public.cost_drivers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  cost_center_id uuid references public.cost_centers(id) on delete set null,
  activity text not null, driver_unit text, rate numeric(18,6), notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── COST_SIMULATIONS (cenários) ─────────────────────────────────────────────
create table public.cost_simulations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, scenario text, assumptions jsonb not null default '{}'::jsonb, results jsonb not null default '{}'::jsonb,
  status text not null default 'draft',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── DRE_ACCOUNTS (mapeamento categoria → grupo do DRE gerencial) ────────────
create table public.dre_accounts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  category text not null, dre_group text not null, sort_order integer, sign integer not null default 1,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Margem de um produto (preço − custo → contribuição e margem %)
create or replace function public.product_margin(p_product uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company((select company_id from public.products where id=p_product)) then
    (select jsonb_build_object(
      'product_id', p.id, 'name', p.name,
      'cost', coalesce(std.total, p.cost_price, 0), 'price', p.sale_price,
      'contribution', coalesce(p.sale_price,0) - coalesce(std.total, p.cost_price, 0),
      'margin_percent', case when coalesce(p.sale_price,0) > 0
        then round((coalesce(p.sale_price,0) - coalesce(std.total, p.cost_price, 0)) / p.sale_price * 100, 2) else null end
    )
    from public.products p
    left join (select product_id, sum(amount_per_unit) total from public.standard_costs where deleted_at is null group by product_id) std on std.product_id = p.id
    where p.id = p_product)
  else '{}'::jsonb end;
$$;
grant execute on function public.product_margin(uuid) to authenticated;

-- DRE gerencial do mês (receita − custos − despesas → margens/EBITDA)
create or replace function public.dre_managerial(p_company uuid, p_month date default null)
returns jsonb
language plpgsql stable security definer set search_path = public, app as $$
declare v_m date; v_revenue numeric; v_cogs numeric; v_opex numeric;
begin
  if not app.can_access_company(p_company) then return '{}'::jsonb; end if;
  v_m := coalesce(date_trunc('month', p_month)::date, date_trunc('month', now())::date);

  select coalesce(sum(amount),0) into v_revenue from public.receivables
    where company_id=p_company and deleted_at is null and date_trunc('month', issued_at)::date = v_m;

  select coalesce(sum(amount),0) into v_cogs from public.cost_entries
    where company_id=p_company and deleted_at is null and period_month = v_m and is_planned=false
      and cost_type in ('material','packaging','direct_labor','indirect_labor','energy','water','gas','steam','compressed_air','depreciation','maintenance','loss','scrap','rework','overhead');

  select coalesce(sum(amount-paid_amount+paid_amount),0) into v_opex from public.payables
    where company_id=p_company and deleted_at is null and date_trunc('month', issued_at)::date = v_m and category is distinct from 'cogs';

  return jsonb_build_object(
    'month', v_m,
    'revenue', v_revenue,
    'cogs', v_cogs,
    'gross_margin', v_revenue - v_cogs,
    'gross_margin_pct', case when v_revenue>0 then round((v_revenue-v_cogs)/v_revenue*100,1) else null end,
    'opex', v_opex,
    'ebitda', v_revenue - v_cogs - v_opex,
    'ebitda_pct', case when v_revenue>0 then round((v_revenue-v_cogs-v_opex)/v_revenue*100,1) else null end
  );
end;
$$;
grant execute on function public.dre_managerial(uuid, date) to authenticated;

-- Análise de variações: orçado × realizado (das linhas de orçamento)
create or replace function public.variance_analysis(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(jsonb_build_object(
      'category', coalesce(category,'(sem categoria)'),
      'planned', planned, 'actual', actual,
      'variance', actual - planned,
      'variance_pct', case when planned>0 then round((actual-planned)/planned*100,1) else null end
    ) order by (actual-planned) desc)
    from (
      select category, sum(planned_amount) planned, sum(actual_amount) actual
      from public.financial_budget_lines where company_id=p_company and deleted_at is null
      group by category
    ) v
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.variance_analysis(uuid) to authenticated;

-- Distribui um valor por regra de rateio e POSTA lançamentos de custo
create or replace function public.post_cost_allocation(p_rule uuid, p_amount numeric, p_cost_type public.cost_type default 'overhead', p_month date default null)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_tenant uuid; v_m date; v_dist jsonb; v_item jsonb; v_count int := 0;
begin
  select company_id, tenant_id into v_company, v_tenant from public.allocation_rules where id = p_rule;
  if v_company is null then raise exception 'regra não encontrada'; end if;
  if not app.has_permission('controlling.create', v_company) then raise exception 'forbidden'; end if;
  v_m := coalesce(date_trunc('month', p_month)::date, date_trunc('month', now())::date);

  v_dist := public.run_allocation(p_rule, p_amount);
  for v_item in select * from jsonb_array_elements(v_dist) loop
    insert into public.cost_entries (tenant_id, company_id, cost_center_id, cost_type, method, amount, period_month, reference_type, reference_id, notes)
    values (v_tenant, v_company, (v_item->>'cost_center_id')::uuid, p_cost_type, 'absorption', (v_item->>'amount')::numeric, v_m, 'allocation_rule', p_rule, 'Rateio automático');
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.post_cost_allocation(uuid, numeric, public.cost_type, date) to authenticated;

-- Dashboard de controladoria
create or replace function public.controlling_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'cost_month', (select coalesce(sum(amount),0) from public.cost_entries where company_id=p_company and period_month=date_trunc('month',now())::date and is_planned=false and deleted_at is null),
    'cost_centers', (select count(*) from public.cost_centers where company_id=p_company and deleted_at is null),
    'profit_centers', (select count(*) from public.profit_centers where company_id=p_company and deleted_at is null),
    'cost_objects', (select count(*) from public.cost_objects where company_id=p_company and deleted_at is null),
    'low_margin', (select count(*) from public.products p where p.company_id=p_company and p.deleted_at is null and p.sale_price>0 and (p.sale_price - coalesce(p.cost_price,0))/p.sale_price < 0.2),
    'avg_margin', (select round(avg(case when sale_price>0 then (sale_price-coalesce(cost_price,0))/sale_price*100 end),1) from public.products where company_id=p_company and deleted_at is null and sale_price>0),
    'budget_variance', (select coalesce(sum(actual_amount-planned_amount),0) from public.financial_budget_lines where company_id=p_company and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.controlling_dashboard(uuid) to authenticated;

-- IA de controladoria: produtos de baixa margem → insights (kind cost_saving)
create or replace function public.controlling_insights(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_p record; v_margin numeric;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and kind='cost_saving' and status='new' and deleted_at is null;

  for v_p in select id, name, sale_price, cost_price from public.products
             where company_id=p_company and deleted_at is null and sale_price > 0 and cost_price is not null loop
    v_margin := (v_p.sale_price - v_p.cost_price) / v_p.sale_price * 100;
    if v_margin < 15 then
      insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, impact_value, confidence)
      values (v_tenant, p_company, 'cost_saving', case when v_margin < 0 then 'critical' else 'warning' end,
        'Baixa margem: '||v_p.name||' ('||round(v_margin,1)||'%)',
        'Produto com margem de contribuição de '||round(v_margin,1)||'% (preço '||v_p.sale_price||' vs custo '||v_p.cost_price||').',
        'Rever preço, renegociar custo ou avaliar mix.', v_p.sale_price - v_p.cost_price, 85);
      v_count := v_count + 1;
    end if;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.controlling_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela ────────────────────────────
do $do$
declare t text; specs text[] := array[
  'profit_centers','cost_objects','cost_entries','standard_costs','cost_drivers','cost_simulations','dre_accounts'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'controlling.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'controlling.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;
