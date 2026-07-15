-- 20260713000048_fpna.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  EPM / FP&A — FINANCIAL PLANNING & ANALYSIS (Vol 16)                      ║
-- ║  Camada ESTRATÉGICA: orçamento, forecast (regressão sobre o GL real),     ║
-- ║  cenários = DIGITAL TWIN financeiro (projeta DRE aplicando premissas),    ║
-- ║  metas/OKRs, análise de investimentos (VPL/TIR/payback/ROI) e IA.        ║
-- ║  Consome os dados reais do núcleo financeiro. Nível SAP SAC/Anaplan/EPM.  ║
-- ║  fpna_insights é auto-descoberto pelo cérebro LAIOS (roda 24/7).         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

do $e$ begin
  if not exists (select 1 from pg_type where typname='budget_status') then
    create type public.budget_status as enum ('draft','approved','active','closed'); end if;
  if not exists (select 1 from pg_type where typname='scenario_type') then
    create type public.scenario_type as enum ('conservative','realistic','aggressive','crisis','expansion','custom'); end if;
  if not exists (select 1 from pg_type where typname='goal_status') then
    create type public.goal_status as enum ('on_track','at_risk','off_track','done'); end if;
end $e$;

-- recurso RBAC 'planning'
insert into public.permissions (slug, resource, action, description)
select 'planning.' || a, 'planning', a, 'Permissão ' || a || ' em planning'
from unnest(array['read','create','update','delete','approve','simulate']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'planning' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── BUDGETS + LINES ─────────────────────────────────────────────────────────
create table public.budgets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, fiscal_year integer not null, scope_type text default 'company', scope_ref text,
  version integer not null default 1, status public.budget_status not null default 'draft', currency text default 'BRL', notes text,
  active boolean not null default true, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.budget_lines (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  budget_id uuid not null references public.budgets(id) on delete cascade,
  category text, kind text not null default 'expense',  -- revenue | expense
  fiscal_month integer not null default 1, amount numeric(18,2) not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_budget_lines_budget on public.budget_lines (budget_id);

-- ── PLANNING_SCENARIOS (Digital Twin financeiro) ────────────────────────────
create table public.planning_scenarios (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, scenario_type public.scenario_type not null default 'realistic',
  horizon_months integer not null default 12, assumptions jsonb not null default '{}'::jsonb,
  last_projection jsonb, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── GOALS / OKRs (objetivo pai + resultados-chave via parent_id) ────────────
create table public.goals (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  parent_id uuid references public.goals(id) on delete cascade,
  title text not null, level text default 'company', metric text, unit text,
  target_value numeric(18,2), current_value numeric(18,2) not null default 0,
  period text, owner text, status public.goal_status not null default 'on_track', due_date date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_goals_parent on public.goals (parent_id);

-- ── INVESTMENT_CASES (business cases: VPL/TIR/payback/ROI) ──────────────────
create table public.investment_cases (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, capex numeric(18,2) not null default 0, discount_rate numeric(8,4) not null default 12,
  cashflows jsonb not null default '[]'::jsonb,
  npv numeric(18,2), irr numeric(10,4), payback_periods numeric(10,2), roi numeric(10,2), notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ HELPERS ════════════════════════════════════════════════════════════════
-- VPL de um fluxo (capex em t0, fluxos periódicos) a uma taxa r (fração)
create or replace function app.inv_npv(p_capex numeric, p_cf numeric[], p_r numeric)
returns numeric language plpgsql immutable as $$
declare v numeric := -p_capex; i int;
begin
  for i in 1 .. coalesce(array_length(p_cf,1),0) loop
    v := v + p_cf[i] / power(1 + p_r, i);
  end loop;
  return v;
end;
$$;

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Análise de investimento: VPL, TIR (bisseção), payback e ROI
create or replace function public.evaluate_investment(p_capex numeric, p_cashflows jsonb, p_discount_rate numeric default 12)
returns jsonb language plpgsql immutable as $$
declare
  v_cf numeric[]; v_r numeric := coalesce(p_discount_rate,0)/100; v_npv numeric; v_sum numeric := 0;
  v_lo numeric := -0.9; v_hi numeric := 10; v_mid numeric; v_nlo numeric; v_nmid numeric; k int;
  v_cum numeric := 0; v_payback numeric := null; i int; v_irr numeric := null;
begin
  select array_agg(value::numeric order by ord) into v_cf from jsonb_array_elements_text(coalesce(p_cashflows,'[]'::jsonb)) with ordinality t(value, ord);
  if v_cf is null then return jsonb_build_object('npv',0,'irr',null,'payback',null,'roi',null); end if;

  v_npv := app.inv_npv(p_capex, v_cf, v_r);
  select coalesce(sum(x),0) into v_sum from unnest(v_cf) x;

  -- payback (períodos, com interpolação)
  for i in 1 .. array_length(v_cf,1) loop
    v_cum := v_cum + v_cf[i];
    if v_cum >= p_capex and v_payback is null then
      v_payback := (i - 1) + (p_capex - (v_cum - v_cf[i])) / nullif(v_cf[i],0);
    end if;
  end loop;

  -- TIR por bisseção (só se houver troca de sinal)
  v_nlo := app.inv_npv(p_capex, v_cf, v_lo);
  if sign(v_nlo) <> sign(app.inv_npv(p_capex, v_cf, v_hi)) then
    for k in 1 .. 200 loop
      v_mid := (v_lo + v_hi) / 2; v_nmid := app.inv_npv(p_capex, v_cf, v_mid);
      if abs(v_nmid) < 0.01 then exit; end if;
      if sign(v_nmid) = sign(v_nlo) then v_lo := v_mid; v_nlo := v_nmid; else v_hi := v_mid; end if;
    end loop;
    v_irr := round(v_mid * 100, 4);
  end if;

  return jsonb_build_object(
    'npv', round(v_npv,2), 'irr', v_irr, 'payback', round(v_payback,2),
    'roi', case when p_capex>0 then round((v_sum - p_capex)/p_capex*100, 2) else null end,
    'total_inflow', round(v_sum,2), 'discount_rate', p_discount_rate);
end;
$$;
grant execute on function public.evaluate_investment(numeric, jsonb, numeric) to authenticated;

-- Forecast: regressão linear (regr_*) sobre a receita/despesa mensal REAL do GL
create or replace function public.generate_forecast(p_company uuid, p_months int default 6)
returns jsonb language plpgsql stable security definer set search_path = public, app as $$
declare v_hist jsonb; v_sr numeric; v_ir numeric; v_se numeric; v_ie numeric; v_n int; k int; v_fc jsonb := '[]'::jsonb; v_rev numeric; v_exp numeric;
begin
  if not app.can_access_company(p_company) then return '{}'::jsonb; end if;
  with h as (
    select row_number() over (order by ym) idx, ym, revenue, expense from (
      select to_char(e.competence_date,'YYYY-MM') ym,
        round(sum(case when a.account_type='revenue' then l.credit-l.debit else 0 end),2) revenue,
        round(sum(case when a.account_type in ('cost','expense') then l.debit-l.credit else 0 end),2) expense
      from public.journal_entry_lines l
      join public.journal_entries e on e.id=l.entry_id and e.status='posted' and e.deleted_at is null
      join public.chart_of_accounts a on a.id=l.account_id
      where e.company_id=p_company and l.deleted_at is null and e.competence_date >= (now()::date - interval '12 months')
      group by 1
    ) t
  )
  select coalesce(jsonb_agg(jsonb_build_object('period',ym,'revenue',revenue,'expense',expense) order by idx),'[]'::jsonb),
         regr_slope(revenue, idx), regr_intercept(revenue, idx), regr_slope(expense, idx), regr_intercept(expense, idx), max(idx)
  into v_hist, v_sr, v_ir, v_se, v_ie, v_n from h;

  if coalesce(v_n,0) = 0 then return jsonb_build_object('history','[]'::jsonb,'forecast','[]'::jsonb,'method','sem histórico'); end if;

  for k in 1 .. greatest(p_months,1) loop
    v_rev := greatest(coalesce(v_ir,0) + coalesce(v_sr,0) * (v_n + k), 0);
    v_exp := greatest(coalesce(v_ie,0) + coalesce(v_se,0) * (v_n + k), 0);
    v_fc := v_fc || jsonb_build_object('period','+'||k, 'revenue', round(v_rev,2), 'expense', round(v_exp,2), 'net', round(v_rev - v_exp,2));
  end loop;
  return jsonb_build_object('history', v_hist, 'forecast', v_fc, 'method', case when v_n>=2 then 'regressão linear' else 'média' end);
end;
$$;
grant execute on function public.generate_forecast(uuid, int) to authenticated;

-- Digital Twin: projeta a DRE aplicando as premissas do cenário sobre a base real
create or replace function public.project_scenario(p_company uuid, p_scenario uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare
  s record; v_rev0 numeric; v_cost0 numeric; v_exp0 numeric; gr numeric; gc numeric; ge numeric;
  k int; v_series jsonb := '[]'::jsonb; v_rev numeric; v_cost numeric; v_exp numeric; v_ebitda numeric;
  tot_rev numeric := 0; tot_ebitda numeric := 0;
begin
  select * into s from public.planning_scenarios where id=p_scenario and company_id=p_company and deleted_at is null;
  if s.id is null then raise exception 'cenário não encontrado'; end if;
  if not (app.can_access_company(p_company) and app.has_permission('planning.simulate', p_company)) then raise exception 'forbidden'; end if;

  -- base = média mensal dos últimos 12 meses (real, do GL); premissas podem sobrepor
  select round(coalesce(sum(case when a.account_type='revenue' then l.credit-l.debit else 0 end),0)/12,2),
         round(coalesce(sum(case when a.account_type='cost' then l.debit-l.credit else 0 end),0)/12,2),
         round(coalesce(sum(case when a.account_type='expense' then l.debit-l.credit else 0 end),0)/12,2)
  into v_rev0, v_cost0, v_exp0
  from public.journal_entry_lines l
  join public.journal_entries e on e.id=l.entry_id and e.status='posted' and e.deleted_at is null
  join public.chart_of_accounts a on a.id=l.account_id
  where e.company_id=p_company and l.deleted_at is null and e.competence_date >= (now()::date - interval '12 months');

  v_rev0  := coalesce((s.assumptions->>'starting_revenue')::numeric, v_rev0, 0);
  v_cost0 := coalesce((s.assumptions->>'starting_cost')::numeric, v_cost0, 0);
  v_exp0  := coalesce((s.assumptions->>'starting_expense')::numeric, v_exp0, 0);
  gr := coalesce((s.assumptions->>'revenue_growth_pct')::numeric, 0)/100;
  gc := coalesce((s.assumptions->>'cost_growth_pct')::numeric, 0)/100;
  ge := coalesce((s.assumptions->>'expense_growth_pct')::numeric, 0)/100;

  for k in 1 .. greatest(s.horizon_months,1) loop
    v_rev  := round(v_rev0  * power(1+gr, k), 2);
    v_cost := round(v_cost0 * power(1+gc, k), 2);
    v_exp  := round(v_exp0  * power(1+ge, k), 2);
    v_ebitda := round(v_rev - v_cost - v_exp, 2);
    v_series := v_series || jsonb_build_object('month', k, 'revenue', v_rev, 'cost', v_cost, 'expense', v_exp, 'ebitda', v_ebitda);
    tot_rev := tot_rev + v_rev; tot_ebitda := tot_ebitda + v_ebitda;
  end loop;

  update public.planning_scenarios set last_projection = jsonb_build_object('series', v_series,
    'total_revenue', round(tot_rev,2), 'total_ebitda', round(tot_ebitda,2),
    'ebitda_margin', case when tot_rev>0 then round(tot_ebitda/tot_rev*100,1) else 0 end) where id=p_scenario;

  return jsonb_build_object('scenario', s.name, 'type', s.scenario_type, 'horizon', s.horizon_months,
    'base', jsonb_build_object('revenue', v_rev0, 'cost', v_cost0, 'expense', v_exp0),
    'series', v_series, 'total_revenue', round(tot_rev,2), 'total_ebitda', round(tot_ebitda,2),
    'ebitda_margin', case when tot_rev>0 then round(tot_ebitda/tot_rev*100,1) else 0 end);
end;
$$;
grant execute on function public.project_scenario(uuid, uuid) to authenticated;

-- Budget × Realizado por mês (orçado do budget_lines vs real do GL)
create or replace function public.budget_vs_actual(p_company uuid, p_year int)
returns jsonb language sql stable security definer set search_path = public, app as $$
  with bud as (
    select bl.fiscal_month m,
      coalesce(sum(bl.amount) filter (where bl.kind='revenue'),0) bud_rev,
      coalesce(sum(bl.amount) filter (where bl.kind='expense'),0) bud_exp
    from public.budget_lines bl join public.budgets b on b.id=bl.budget_id and b.fiscal_year=p_year and b.deleted_at is null
    where bl.company_id=p_company and bl.deleted_at is null group by bl.fiscal_month
  ),
  act as (
    select extract(month from e.competence_date)::int m,
      round(sum(case when a.account_type='revenue' then l.credit-l.debit else 0 end),2) act_rev,
      round(sum(case when a.account_type in ('cost','expense') then l.debit-l.credit else 0 end),2) act_exp
    from public.journal_entry_lines l
    join public.journal_entries e on e.id=l.entry_id and e.status='posted' and e.deleted_at is null
    join public.chart_of_accounts a on a.id=l.account_id
    where e.company_id=p_company and l.deleted_at is null and extract(year from e.competence_date)=p_year
    group by 1
  )
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(jsonb_build_object('month', m,
      'budget_revenue', coalesce(bud_rev,0), 'actual_revenue', coalesce(act_rev,0),
      'budget_expense', coalesce(bud_exp,0), 'actual_expense', coalesce(act_exp,0)) order by m)
    from (select coalesce(bud.m, act.m) m, bud.bud_rev, bud.bud_exp, act.act_rev, act.act_exp
          from bud full outer join act on bud.m=act.m) x
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.budget_vs_actual(uuid, int) to authenticated;

-- Dashboard FP&A
create or replace function public.fpna_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'budgets', (select count(*) from public.budgets where company_id=p_company and deleted_at is null),
    'scenarios', (select count(*) from public.planning_scenarios where company_id=p_company and deleted_at is null),
    'goals_total', (select count(*) from public.goals where company_id=p_company and deleted_at is null),
    'goals_at_risk', (select count(*) from public.goals where company_id=p_company and status in ('at_risk','off_track') and deleted_at is null),
    'goals_done', (select count(*) from public.goals where company_id=p_company and status='done' and deleted_at is null),
    'investments', (select count(*) from public.investment_cases where company_id=p_company and deleted_at is null),
    'best_npv', (select round(max(npv),2) from public.investment_cases where company_id=p_company and deleted_at is null),
    'revenue_12m', (select round(coalesce(sum(l.credit-l.debit),0),2) from public.journal_entry_lines l
        join public.journal_entries e on e.id=l.entry_id and e.status='posted' and e.deleted_at is null
        join public.chart_of_accounts a on a.id=l.account_id and a.account_type='revenue'
        where e.company_id=p_company and e.competence_date >= (now()::date - interval '12 months'))
  ) else '{}'::jsonb end;
$$;
grant execute on function public.fpna_dashboard(uuid) to authenticated;

-- IA FP&A: metas em risco, estouro de orçamento, cenário com EBITDA negativo → LOGIA
create or replace function public.fpna_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_risk int; v_over int; v_neg int; v_year int := extract(year from now())::int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Planejamento%' and deleted_at is null;

  select count(*) into v_risk from public.goals where company_id=p_company and status in ('at_risk','off_track') and deleted_at is null;
  if v_risk > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'Planejamento: metas em risco', v_risk||' meta(s)/OKR fora do trilho.', 'Revisar planos de ação com os responsáveis.', 80);
    v_c := v_c + 1;
  end if;

  select count(*) into v_over from (
    select bl.fiscal_month, sum(bl.amount) filter (where bl.kind='expense') bud
    from public.budget_lines bl join public.budgets b on b.id=bl.budget_id and b.fiscal_year=v_year and b.deleted_at is null
    where bl.company_id=p_company and bl.deleted_at is null group by bl.fiscal_month
    having sum(bl.amount) filter (where bl.kind='expense') > 0
    and sum(bl.amount) filter (where bl.kind='expense') < (
      select coalesce(sum(case when a.account_type in ('cost','expense') then l.debit-l.credit else 0 end),0)
      from public.journal_entry_lines l join public.journal_entries e on e.id=l.entry_id and e.status='posted' and e.deleted_at is null
      join public.chart_of_accounts a on a.id=l.account_id
      where e.company_id=p_company and extract(year from e.competence_date)=v_year and extract(month from e.competence_date)=bl.fiscal_month)
  ) z;
  if v_over > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'cost_saving', 'warning', 'Planejamento: estouro de orçamento', v_over||' mês(es) com despesa real acima do orçado.', 'Rever gastos e reforecast do período.', 78);
    v_c := v_c + 1;
  end if;

  select count(*) into v_neg from public.planning_scenarios where company_id=p_company and deleted_at is null and (last_projection->>'total_ebitda')::numeric < 0;
  if v_neg > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'demand_shift', 'critical', 'Planejamento: cenário com EBITDA negativo', v_neg||' cenário(s) projetam EBITDA negativo no horizonte.', 'Ajustar premissas de receita/custo ou plano de contingência.', 84);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.fpna_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'planning') ───────
do $do$
declare t text; specs text[] := array['budgets','budget_lines','planning_scenarios','goals','investment_cases'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'planning.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'planning.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: cenários padrão (por empresa) ══
do $do$
declare c record;
  scns jsonb := '[
    {"n":"Conservador","t":"conservative","h":12,"a":{"revenue_growth_pct":0.5,"cost_growth_pct":0.8,"expense_growth_pct":0.5}},
    {"n":"Realista","t":"realistic","h":12,"a":{"revenue_growth_pct":1.5,"cost_growth_pct":1.0,"expense_growth_pct":1.0}},
    {"n":"Agressivo (Expansão)","t":"aggressive","h":12,"a":{"revenue_growth_pct":4.0,"cost_growth_pct":2.5,"expense_growth_pct":3.0}},
    {"n":"Crise","t":"crisis","h":12,"a":{"revenue_growth_pct":-3.0,"cost_growth_pct":1.0,"expense_growth_pct":0.5}}
  ]'::jsonb;
  s jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    for s in select value from jsonb_array_elements(scns) loop
      if not exists (select 1 from public.planning_scenarios where company_id=c.id and name=(s->>'n') and deleted_at is null) then
        insert into public.planning_scenarios (tenant_id, company_id, name, scenario_type, horizon_months, assumptions)
        values (c.tenant_id, c.id, s->>'n', (s->>'t')::public.scenario_type, (s->>'h')::int, s->'a');
      end if;
    end loop;
  end loop;
end $do$;

notify pgrst, 'reload schema';
