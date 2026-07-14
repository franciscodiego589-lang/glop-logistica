-- 20260713000027_finance_efp.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 11 — ENTERPRISE FINANCE PLATFORM (EFP) — EXPANSÃO                  ║
-- ║  Estende o Financeiro base (mig 026: payables/receivables/bancos/cashflow)║
-- ║  Nível SAP FI/TRM + Oracle Financials + Dynamics Finance + NetSuite.       ║
-- ║  Tesouraria (investimentos/empréstimos) · conciliação bancária (OFX) ·    ║
-- ║  crédito/cobrança · rateios · orçamento · intercompany/consolidação ·     ║
-- ║  IA financeira (forecast de caixa, anomalias/duplicidades) · custo por lote║
-- ║  Cria recurso RBAC 'finance' dedicado (segregação SOX).                    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.treasury_kind    as enum ('investment','loan','financing');
create type public.stmt_status      as enum ('imported','reconciling','reconciled');
create type public.alloc_basis      as enum ('percent','revenue','headcount','hours','production','consumption','area');

-- recurso RBAC dedicado (segregação de funções — SOX-ready)
insert into public.permissions (slug, resource, action, description)
select 'finance.' || a, 'finance', a, 'Permissão ' || a || ' em finance'
from unnest(array['read','create','update','delete','approve','export']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'finance' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── TREASURY_INVESTMENTS / LOANS (aplicações, empréstimos, financiamentos) ──
create table public.treasury_positions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  bank_account_id uuid references public.bank_accounts(id) on delete set null,
  kind public.treasury_kind not null default 'investment',
  code text, description text, institution text,
  principal numeric(18,2) not null default 0, rate_percent numeric(10,4), rate_index text,
  start_date date, maturity_date date, current_value numeric(18,2), outstanding numeric(18,2),
  installments integer, status text not null default 'active',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_treasury_positions_kind on public.treasury_positions (company_id, kind) where deleted_at is null;

-- ── BANK_STATEMENTS + LINES (conciliação bancária / OFX-CNAB) ───────────────
create table public.bank_statements (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  bank_account_id uuid references public.bank_accounts(id) on delete set null,
  code text, source text default 'ofx', status public.stmt_status not null default 'imported',
  period_start date, period_end date, opening_balance numeric(18,2), closing_balance numeric(18,2),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_bank_statements_account on public.bank_statements (bank_account_id);

create table public.bank_statement_lines (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  statement_id uuid not null references public.bank_statements(id) on delete cascade,
  posted_at date, description text, document text, amount numeric(18,2) not null default 0,
  matched boolean not null default false, matched_type text, matched_id uuid,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_bank_statement_lines_stmt on public.bank_statement_lines (statement_id);

-- ── CUSTOMER_CREDIT (limite, score, exposição, inadimplência) ───────────────
create table public.customer_credit (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  customer_id uuid not null references public.customers(id) on delete cascade,
  credit_limit numeric(18,2) not null default 0, score numeric(6,2), exposure numeric(18,2) not null default 0,
  overdue_amount numeric(18,2) not null default 0, blocked boolean not null default false, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_customer_credit on public.customer_credit (customer_id) where deleted_at is null;

-- ── DUNNING_RULES (régua de cobrança) ───────────────────────────────────────
create table public.dunning_rules (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, days_overdue integer not null default 0, channel text default 'email',
  action text, message_template text, sequence integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── ALLOCATION_RULES + entries (rateios de custo) ───────────────────────────
create table public.allocation_rules (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, basis public.alloc_basis not null default 'percent',
  source_cost_center_id uuid references public.cost_centers(id) on delete set null, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.allocation_targets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  rule_id uuid not null references public.allocation_rules(id) on delete cascade,
  cost_center_id uuid references public.cost_centers(id) on delete set null,
  weight numeric(12,4) not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_allocation_targets_rule on public.allocation_targets (rule_id);

-- ── FINANCIAL_BUDGETS + lines (orçamento) ───────────────────────────────────
create table public.financial_budgets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, year integer, period text default 'annual', status text not null default 'draft', notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.financial_budget_lines (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  budget_id uuid not null references public.financial_budgets(id) on delete cascade,
  cost_center_id uuid references public.cost_centers(id) on delete set null,
  category text, line_type text not null default 'expense', reference_month date,
  planned_amount numeric(18,2) not null default 0, actual_amount numeric(18,2) not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_financial_budget_lines_budget on public.financial_budget_lines (budget_id);

-- ── INTERCOMPANY_TRANSACTIONS (eliminações do grupo) ────────────────────────
create table public.intercompany_transactions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  counterparty_company_id uuid references public.companies(id) on delete set null,
  code text, description text, amount numeric(18,2) not null default 0, direction text default 'out',
  reference_type text, reference_id uuid, eliminated boolean not null default false, occurred_at date default current_date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_intercompany_company on public.intercompany_transactions (company_id);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Conciliação: casa linhas do extrato com payables/receivables por valor±data
create or replace function public.reconcile_bank_statement(p_statement uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_l record; v_match uuid; v_count int := 0;
begin
  select company_id into v_company from public.bank_statements where id = p_statement;
  if v_company is null then raise exception 'extrato não encontrado'; end if;
  if not app.has_permission('finance.update', v_company) then raise exception 'forbidden'; end if;

  for v_l in select * from public.bank_statement_lines where statement_id = p_statement and matched = false and deleted_at is null loop
    v_match := null;
    if v_l.amount < 0 then
      select id into v_match from public.payables
      where company_id = v_company and status <> 'canceled' and deleted_at is null
        and abs(amount - abs(v_l.amount)) < 0.01 and abs(coalesce(due_date, issued_at) - v_l.posted_at) <= 5
      order by abs(coalesce(due_date, issued_at) - v_l.posted_at) limit 1;
      if v_match is not null then update public.bank_statement_lines set matched=true, matched_type='payable', matched_id=v_match where id=v_l.id; v_count:=v_count+1; end if;
    else
      select id into v_match from public.receivables
      where company_id = v_company and status <> 'canceled' and deleted_at is null
        and abs(amount - v_l.amount) < 0.01 and abs(coalesce(due_date, issued_at) - v_l.posted_at) <= 5
      order by abs(coalesce(due_date, issued_at) - v_l.posted_at) limit 1;
      if v_match is not null then update public.bank_statement_lines set matched=true, matched_type='receivable', matched_id=v_match where id=v_l.id; v_count:=v_count+1; end if;
    end if;
  end loop;

  update public.bank_statements set status = case when exists(select 1 from public.bank_statement_lines where statement_id=p_statement and matched=false and deleted_at is null) then 'reconciling' else 'reconciled' end where id = p_statement;
  return v_count;
end;
$$;
grant execute on function public.reconcile_bank_statement(uuid) to authenticated;

-- Score de crédito do cliente (histórico de pagamento em dia vs atraso)
create or replace function public.compute_credit_score(p_customer uuid)
returns numeric
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_tenant uuid; v_total int; v_ontime int; v_open numeric; v_overdue numeric; v_score numeric;
begin
  select company_id, tenant_id into v_company, v_tenant from public.customers where id = p_customer;
  if v_company is null then raise exception 'cliente não encontrado'; end if;
  if not app.has_permission('finance.update', v_company) then raise exception 'forbidden'; end if;

  select count(*), count(*) filter (where received_at::date <= due_date)
    into v_total, v_ontime
  from public.receivables where customer_id = p_customer and status = 'paid' and deleted_at is null;

  select coalesce(sum(amount - received_amount) filter (where status <> 'paid'),0),
         coalesce(sum(amount - received_amount) filter (where status <> 'paid' and due_date < current_date),0)
    into v_open, v_overdue
  from public.receivables where customer_id = p_customer and deleted_at is null;

  v_score := case when v_total = 0 then 70 else round(50 + 50.0 * v_ontime / v_total, 2) end;
  if v_overdue > 0 then v_score := greatest(v_score - 25, 0); end if;

  insert into public.customer_credit (tenant_id, company_id, customer_id, score, exposure, overdue_amount, blocked)
  values (v_tenant, v_company, p_customer, v_score, coalesce(v_open,0), coalesce(v_overdue,0), coalesce(v_overdue,0) > 0)
  on conflict (customer_id) where deleted_at is null
  do update set score = excluded.score, exposure = excluded.exposure, overdue_amount = excluded.overdue_amount, blocked = excluded.blocked, updated_at = now();
  return v_score;
end;
$$;
grant execute on function public.compute_credit_score(uuid) to authenticated;

-- Rateio: distribui um valor pela regra entre centros de custo (retorna jsonb)
create or replace function public.run_allocation(p_rule uuid, p_amount numeric)
returns jsonb
language plpgsql stable security definer set search_path = public, app as $$
declare v_company uuid; v_wsum numeric; v_res jsonb;
begin
  select company_id into v_company from public.allocation_rules where id = p_rule;
  if v_company is null or not app.can_access_company(v_company) then return '[]'::jsonb; end if;
  select sum(weight) into v_wsum from public.allocation_targets where rule_id = p_rule and deleted_at is null;
  if coalesce(v_wsum,0) = 0 then return '[]'::jsonb; end if;
  select jsonb_agg(jsonb_build_object('cost_center_id', cost_center_id, 'amount', round(p_amount * weight / v_wsum, 2)))
    into v_res from public.allocation_targets where rule_id = p_rule and deleted_at is null;
  return coalesce(v_res, '[]'::jsonb);
end;
$$;
grant execute on function public.run_allocation(uuid, numeric) to authenticated;

-- Forecast de caixa: saldo projetado dia a dia (entradas AR − saídas AP) por N dias
create or replace function public.forecast_cashflow(p_company uuid, p_days integer default 30)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  with days as (
    select generate_series(current_date, current_date + (p_days || ' days')::interval, '1 day')::date d
  ),
  inflow as (
    select due_date d, sum(amount - received_amount) v from public.receivables
    where company_id = p_company and status <> 'paid' and status <> 'canceled' and deleted_at is null
      and due_date between current_date and current_date + (p_days||' days')::interval group by due_date
  ),
  outflow as (
    select due_date d, sum(amount - paid_amount) v from public.payables
    where company_id = p_company and status <> 'paid' and status <> 'canceled' and deleted_at is null
      and due_date between current_date and current_date + (p_days||' days')::interval group by due_date
  ),
  merged as (
    select days.d, coalesce(i.v,0) as inflow, coalesce(o.v,0) as outflow, coalesce(i.v,0) - coalesce(o.v,0) as net
    from days left join inflow i on i.d = days.d left join outflow o on o.d = days.d
  ),
  cum as (
    select d, inflow, outflow, net, sum(net) over (order by d) as cumulative from merged
  )
  select case when app.can_access_company(p_company) then jsonb_agg(jsonb_build_object(
      'date', d, 'inflow', inflow, 'outflow', outflow, 'net', net, 'cumulative', cumulative
    ) order by d) else '[]'::jsonb end
  from cum;
$$;
grant execute on function public.forecast_cashflow(uuid, integer) to authenticated;

-- IA: anomalias/duplicidades → insights (kind fraud_risk)
create or replace function public.detect_financial_anomalies(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_r record;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id = p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and kind='fraud_risk' and status='new' and deleted_at is null;

  -- pagamentos potencialmente duplicados (mesmo fornecedor+valor, vencimento próximo)
  for v_r in
    select supplier_id, amount, count(*) c from public.payables
    where company_id=p_company and deleted_at is null and supplier_id is not null
    group by supplier_id, amount, date_trunc('week', coalesce(due_date, issued_at)) having count(*) > 1
  loop
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, impact_value, confidence)
    values (v_tenant, p_company, 'fraud_risk', 'warning', 'Possível pagamento duplicado',
      v_r.c||' títulos do mesmo fornecedor com valor '||v_r.amount||' na mesma semana.',
      'Verificar duplicidade antes de pagar.', v_r.amount, 80);
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.detect_financial_anomalies(uuid) to authenticated;

-- Custo industrial por ordem de produção (rollup do BOM consumido)
create or replace function public.compute_batch_cost(p_order uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company((select company_id from public.production_orders where id=p_order))
    then jsonb_build_object(
      'production_order_id', p_order,
      'produced', (select produced_quantity from public.production_orders where id=p_order),
      'material_cost', coalesce((select sum(pc.consumed_quantity * coalesce(p.cost_price,0))
         from public.production_consumptions pc join public.products p on p.id=pc.component_product_id
         where pc.production_order_id=p_order and pc.deleted_at is null),0),
      'unit_cost', coalesce((select sum(pc.consumed_quantity * coalesce(p.cost_price,0))
         from public.production_consumptions pc join public.products p on p.id=pc.component_product_id
         where pc.production_order_id=p_order and pc.deleted_at is null)
        / nullif((select produced_quantity from public.production_orders where id=p_order),0),0)
    ) else '{}'::jsonb end;
$$;
grant execute on function public.compute_batch_cost(uuid) to authenticated;

-- Consolidação financeira do grupo (todas as empresas do tenant)
create or replace function public.consolidated_finance(p_tenant uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.is_superadmin() or p_tenant in (select app.user_tenant_ids()) then jsonb_build_object(
    'companies', (select count(*) from public.companies where tenant_id=p_tenant and deleted_at is null),
    'ap_open', (select coalesce(sum(amount-paid_amount),0) from public.payables where tenant_id=p_tenant and status<>'paid' and status<>'canceled' and deleted_at is null),
    'ar_open', (select coalesce(sum(amount-received_amount),0) from public.receivables where tenant_id=p_tenant and status<>'paid' and status<>'canceled' and deleted_at is null),
    'ap_overdue', (select coalesce(sum(amount-paid_amount),0) from public.payables where tenant_id=p_tenant and status<>'paid' and status<>'canceled' and due_date<current_date and deleted_at is null),
    'ar_overdue', (select coalesce(sum(amount-received_amount),0) from public.receivables where tenant_id=p_tenant and status<>'paid' and status<>'canceled' and due_date<current_date and deleted_at is null),
    'intercompany_pending', (select count(*) from public.intercompany_transactions where tenant_id=p_tenant and eliminated=false and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.consolidated_finance(uuid) to authenticated;

-- Dashboard financeiro rico (KPIs de tesouraria/AR/AP + DSO/DPO/CCC)
create or replace function public.finance_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'ap_open',    (select coalesce(sum(amount-paid_amount),0) from public.payables where company_id=p_company and status<>'paid' and status<>'canceled' and deleted_at is null),
    'ar_open',    (select coalesce(sum(amount-received_amount),0) from public.receivables where company_id=p_company and status<>'paid' and status<>'canceled' and deleted_at is null),
    'ap_overdue', (select coalesce(sum(amount-paid_amount),0) from public.payables where company_id=p_company and status<>'paid' and status<>'canceled' and due_date<current_date and deleted_at is null),
    'ar_overdue', (select coalesce(sum(amount-received_amount),0) from public.receivables where company_id=p_company and status<>'paid' and status<>'canceled' and due_date<current_date and deleted_at is null),
    'ap_due_30d', (select coalesce(sum(amount-paid_amount),0) from public.payables where company_id=p_company and status<>'paid' and status<>'canceled' and due_date between current_date and current_date+30 and deleted_at is null),
    'ar_due_30d', (select coalesce(sum(amount-received_amount),0) from public.receivables where company_id=p_company and status<>'paid' and status<>'canceled' and due_date between current_date and current_date+30 and deleted_at is null),
    'net_position', (select coalesce(sum(amount-received_amount),0) from public.receivables where company_id=p_company and status<>'paid' and status<>'canceled' and deleted_at is null)
                  - (select coalesce(sum(amount-paid_amount),0) from public.payables where company_id=p_company and status<>'paid' and status<>'canceled' and deleted_at is null),
    'dso', (select round(avg(received_at::date - issued_at),1) from public.receivables where company_id=p_company and status='paid' and received_at is not null and deleted_at is null),
    'dpo', (select round(avg(paid_at::date - issued_at),1) from public.payables where company_id=p_company and status='paid' and paid_at is not null and deleted_at is null),
    'investments', (select coalesce(sum(current_value),0) from public.treasury_positions where company_id=p_company and kind='investment' and status='active' and deleted_at is null),
    'debt', (select coalesce(sum(outstanding),0) from public.treasury_positions where company_id=p_company and kind in ('loan','financing') and status='active' and deleted_at is null),
    'anomalies', (select count(*) from public.logia_insights where company_id=p_company and kind='fraud_risk' and status='new' and deleted_at is null),
    'credit_blocked', (select count(*) from public.customer_credit where company_id=p_company and blocked=true and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.finance_dashboard(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'finance') ────────
do $do$
declare t text; specs text[] := array[
  'treasury_positions','bank_statements','bank_statement_lines','customer_credit','dunning_rules',
  'allocation_rules','allocation_targets','financial_budgets','financial_budget_lines','intercompany_transactions'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'finance.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'finance.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;
