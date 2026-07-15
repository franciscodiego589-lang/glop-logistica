-- 20260713000045_gl.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  GL — ENTERPRISE GENERAL LEDGER (Vol 13) — Contabilidade Geral            ║
-- ║  Plano de contas, partidas dobradas, MOTOR DE CONTABILIZAÇÃO por evento,  ║
-- ║  razão/balancete, DRE, Balanço, fechamento de período, conciliações e     ║
-- ║  IA contábil. Nível SAP FI-GL / Oracle Financials / Dynamics 365 Finance. ║
-- ║  gl_insights é auto-descoberto pelo cérebro LAIOS (roda 24/7).            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

do $e$ begin
  if not exists (select 1 from pg_type where typname='gl_account_type') then create type public.gl_account_type as enum ('asset','liability','equity','revenue','cost','expense'); end if;
  if not exists (select 1 from pg_type where typname='gl_nature') then create type public.gl_nature as enum ('debit','credit'); end if;
  if not exists (select 1 from pg_type where typname='gl_entry_type') then create type public.gl_entry_type as enum ('auto','manual','recurring','reversal','adjustment','reclass','opening'); end if;
  if not exists (select 1 from pg_type where typname='gl_entry_status') then create type public.gl_entry_status as enum ('draft','posted','reversed'); end if;
end $e$;

-- recurso RBAC dedicado 'accounting' (segregação de funções — SoD)
insert into public.permissions (slug, resource, action, description)
select 'accounting.' || a, 'accounting', a, 'Permissão ' || a || ' em accounting'
from unnest(array['read','create','update','delete','approve','close','export']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'accounting' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- profit_centers já existe (módulo Controladoria) — reutilizado via FK abaixo.

-- ── CHART_OF_ACCOUNTS (plano de contas — societário/gerencial/fiscal/ifrs) ──
create table public.chart_of_accounts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null, name text not null,
  account_type public.gl_account_type not null, nature public.gl_nature not null,
  parent_id uuid references public.chart_of_accounts(id) on delete restrict,
  is_postable boolean not null default true,  -- analítica (folha) recebe lançamento; sintética não
  plan_type text not null default 'statutory', default_history text, account_group text, account_subgroup text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_coa_code on public.chart_of_accounts (company_id, plan_type, code) where deleted_at is null;
create index idx_coa_parent on public.chart_of_accounts (parent_id);

-- ── ACCOUNTING_PERIODS (fechamento contábil) ────────────────────────────────
create table public.accounting_periods (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  fiscal_year integer not null, fiscal_month integer not null,
  status text not null default 'open',  -- open | closed | reopened
  closed_by uuid references auth.users(id), closed_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_period on public.accounting_periods (company_id, fiscal_year, fiscal_month) where deleted_at is null;

-- ── POSTING_RULES (motor de contabilização por evento) ──────────────────────
create table public.posting_rules (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  event_key text not null, description text,
  debit_account_id uuid references public.chart_of_accounts(id) on delete restrict,
  credit_account_id uuid references public.chart_of_accounts(id) on delete restrict,
  priority integer not null default 1, enabled boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_posting_rules_event on public.posting_rules (company_id, event_key) where deleted_at is null;

-- ── JOURNAL_ENTRIES (lançamentos — cabeçalho) + LINES (partidas) ────────────
create table public.journal_entries (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  entry_number integer, entry_date date not null default now()::date, competence_date date not null default now()::date,
  entry_type public.gl_entry_type not null default 'manual', status public.gl_entry_status not null default 'draft',
  description text, document_ref text, source_module text, source_id uuid,
  currency text default 'BRL', total_debit numeric(18,2) not null default 0, total_credit numeric(18,2) not null default 0,
  reverses_entry_id uuid references public.journal_entries(id) on delete set null,
  posted_by uuid references auth.users(id), posted_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_je_status on public.journal_entries (company_id, status, competence_date) where deleted_at is null;

create table public.journal_entry_lines (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  entry_id uuid not null references public.journal_entries(id) on delete cascade,
  line_no integer not null default 1,
  account_id uuid not null references public.chart_of_accounts(id) on delete restrict,
  debit numeric(18,2) not null default 0, credit numeric(18,2) not null default 0,
  cost_center_id uuid references public.cost_centers(id) on delete set null,
  profit_center_id uuid references public.profit_centers(id) on delete set null,
  project text, description text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_jel_entry on public.journal_entry_lines (entry_id);
create index idx_jel_account on public.journal_entry_lines (account_id);

-- ── RECONCILIATIONS (conciliações) ──────────────────────────────────────────
create table public.gl_reconciliations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  recon_type text not null default 'accounting', account_id uuid references public.chart_of_accounts(id) on delete set null,
  reference text, book_balance numeric(18,2) default 0, statement_balance numeric(18,2) default 0,
  difference numeric(18,2) generated always as (coalesce(book_balance,0) - coalesce(statement_balance,0)) stored,
  status text not null default 'open', reconciled_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ FUNÇÕES AUXILIARES + MOTOR ═════════════════════════════════════════════

-- período aberto? (bloqueia lançar em período fechado)
create or replace function app.gl_period_open(p_company uuid, p_date date)
returns boolean language sql stable security definer set search_path = public, app as $$
  select not exists (
    select 1 from public.accounting_periods
    where company_id = p_company and fiscal_year = extract(year from p_date)::int
      and fiscal_month = extract(month from p_date)::int and status = 'closed' and deleted_at is null
  );
$$;

-- Cria lançamento a partir de linhas jsonb [{account_id,debit,credit,cost_center_id?,profit_center_id?,description?}]
-- valida partidas dobradas (Σdébito = Σcrédito > 0) e período aberto. p_post=true já posta.
create or replace function public.create_journal_entry(
  p_company uuid, p_date date, p_description text, p_lines jsonb,
  p_type public.gl_entry_type default 'manual', p_document_ref text default null, p_post boolean default true)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare
  v_tenant uuid; v_entry uuid; v_num int; v_deb numeric := 0; v_cred numeric := 0; v_line jsonb; v_i int := 0;
begin
  if not (app.can_access_company(p_company) and app.has_permission('accounting.create', p_company)) then raise exception 'forbidden'; end if;
  if not app.gl_period_open(p_company, p_date) then raise exception 'período contábil fechado para %', p_date; end if;
  if jsonb_typeof(p_lines) <> 'array' or jsonb_array_length(p_lines) < 2 then raise exception 'informe ao menos 2 partidas'; end if;

  for v_line in select * from jsonb_array_elements(p_lines) loop
    v_deb  := v_deb  + coalesce((v_line->>'debit')::numeric, 0);
    v_cred := v_cred + coalesce((v_line->>'credit')::numeric, 0);
  end loop;
  if round(v_deb,2) <> round(v_cred,2) then raise exception 'partidas não batem: débito % ≠ crédito %', v_deb, v_cred; end if;
  if round(v_deb,2) <= 0 then raise exception 'lançamento sem valor'; end if;

  select tenant_id into v_tenant from public.companies where id = p_company;
  select coalesce(max(entry_number),0)+1 into v_num from public.journal_entries where company_id = p_company;

  insert into public.journal_entries (tenant_id, company_id, entry_number, entry_date, competence_date, entry_type, status,
      description, document_ref, currency, total_debit, total_credit, posted_by, posted_at)
  values (v_tenant, p_company, v_num, p_date, p_date, p_type, (case when p_post then 'posted' else 'draft' end)::public.gl_entry_status,
      p_description, p_document_ref, 'BRL', round(v_deb,2), round(v_cred,2),
      case when p_post then auth.uid() end, case when p_post then now() end)
  returning id into v_entry;

  for v_line in select * from jsonb_array_elements(p_lines) loop
    v_i := v_i + 1;
    insert into public.journal_entry_lines (tenant_id, company_id, entry_id, line_no, account_id, debit, credit,
        cost_center_id, profit_center_id, project, description)
    values (v_tenant, p_company, v_entry, v_i, (v_line->>'account_id')::uuid,
        coalesce((v_line->>'debit')::numeric,0), coalesce((v_line->>'credit')::numeric,0),
        nullif(v_line->>'cost_center_id','')::uuid, nullif(v_line->>'profit_center_id','')::uuid,
        v_line->>'project', v_line->>'description');
  end loop;

  return jsonb_build_object('id', v_entry, 'entry_number', v_num, 'debit', round(v_deb,2), 'credit', round(v_cred,2), 'posted', p_post);
end;
$$;
grant execute on function public.create_journal_entry(uuid, date, text, jsonb, public.gl_entry_type, text, boolean) to authenticated;

-- MOTOR DE CONTABILIZAÇÃO: gera lançamento automático a partir de um evento operacional.
-- Outros módulos chamam post_accounting_event('goods_receipt', valor, ...) e a contabilidade reflete sozinha.
create or replace function public.post_accounting_event(
  p_company uuid, p_event_key text, p_amount numeric, p_description text default null,
  p_document_ref text default null, p_source_module text default null, p_source_id uuid default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_rule record; v_lines jsonb; v_res jsonb; v_entry uuid;
begin
  if not (app.can_access_company(p_company) and app.has_permission('accounting.create', p_company)) then raise exception 'forbidden'; end if;
  if coalesce(p_amount,0) <= 0 then raise exception 'valor deve ser positivo'; end if;
  select * into v_rule from public.posting_rules
    where company_id = p_company and event_key = p_event_key and enabled and deleted_at is null
    order by priority limit 1;
  if v_rule.id is null then raise exception 'sem regra de contabilização para o evento %', p_event_key; end if;

  v_lines := jsonb_build_array(
    jsonb_build_object('account_id', v_rule.debit_account_id,  'debit', round(p_amount,2), 'credit', 0, 'description', coalesce(p_description, v_rule.description)),
    jsonb_build_object('account_id', v_rule.credit_account_id, 'debit', 0, 'credit', round(p_amount,2), 'description', coalesce(p_description, v_rule.description))
  );
  v_res := public.create_journal_entry(p_company, now()::date, coalesce(p_description, v_rule.description, p_event_key), v_lines, 'auto', p_document_ref, true);
  v_entry := (v_res->>'id')::uuid;
  update public.journal_entries set source_module = p_source_module, source_id = p_source_id where id = v_entry;
  return v_res;
end;
$$;
grant execute on function public.post_accounting_event(uuid, text, numeric, text, text, text, uuid) to authenticated;

-- Estorno: cria lançamento espelho (inverte débito/crédito) e marca o original como estornado.
create or replace function public.reverse_journal_entry(p_entry uuid, p_reason text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_tenant uuid; v_num int; v_new uuid; v_orig record; v_l record;
begin
  select * into v_orig from public.journal_entries where id = p_entry and deleted_at is null;
  if v_orig.id is null then raise exception 'lançamento não encontrado'; end if;
  if not (app.can_access_company(v_orig.company_id) and app.has_permission('accounting.approve', v_orig.company_id)) then raise exception 'forbidden'; end if;
  if v_orig.status <> 'posted' then raise exception 'só é possível estornar lançamento contabilizado'; end if;
  if not app.gl_period_open(v_orig.company_id, now()::date) then raise exception 'período fechado'; end if;

  select coalesce(max(entry_number),0)+1 into v_num from public.journal_entries where company_id = v_orig.company_id;
  insert into public.journal_entries (tenant_id, company_id, entry_number, entry_date, competence_date, entry_type, status,
      description, document_ref, currency, total_debit, total_credit, reverses_entry_id, posted_by, posted_at)
  values (v_orig.tenant_id, v_orig.company_id, v_num, now()::date, now()::date, 'reversal', 'posted',
      'Estorno #'||v_orig.entry_number||coalesce(' — '||p_reason,''), v_orig.document_ref, v_orig.currency,
      v_orig.total_credit, v_orig.total_debit, p_entry, auth.uid(), now())
  returning id into v_new;

  for v_l in select * from public.journal_entry_lines where entry_id = p_entry loop
    insert into public.journal_entry_lines (tenant_id, company_id, entry_id, line_no, account_id, debit, credit, cost_center_id, profit_center_id, description)
    values (v_l.tenant_id, v_l.company_id, v_new, v_l.line_no, v_l.account_id, v_l.credit, v_l.debit, v_l.cost_center_id, v_l.profit_center_id, 'Estorno: '||coalesce(v_l.description,''));
  end loop;

  update public.journal_entries set status = 'reversed' where id = p_entry;
  return jsonb_build_object('reversal_id', v_new, 'entry_number', v_num);
end;
$$;
grant execute on function public.reverse_journal_entry(uuid, text) to authenticated;

-- Balancete / Razão (saldos por conta analítica; só lançamentos contabilizados)
create or replace function public.trial_balance(p_company uuid, p_from date default null, p_to date default null)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(x order by (x->>'code')) from (
      select jsonb_build_object('code', a.code, 'name', a.name, 'type', a.account_type,
        'debit', round(coalesce(sum(l.debit),0),2), 'credit', round(coalesce(sum(l.credit),0),2),
        'balance', round(coalesce(sum(l.debit),0) - coalesce(sum(l.credit),0),2)) x
      from public.chart_of_accounts a
      join public.journal_entry_lines l on l.account_id = a.id and l.deleted_at is null
      join public.journal_entries e on e.id = l.entry_id and e.status = 'posted' and e.deleted_at is null
        and (p_from is null or e.competence_date >= p_from) and (p_to is null or e.competence_date <= p_to)
      where a.company_id = p_company and a.deleted_at is null
      group by a.id, a.code, a.name, a.account_type
      having coalesce(sum(l.debit),0) <> 0 or coalesce(sum(l.credit),0) <> 0
    ) s
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.trial_balance(uuid, date, date) to authenticated;

-- DRE (Demonstração do Resultado)
create or replace function public.income_statement(p_company uuid, p_from date, p_to date)
returns jsonb language sql stable security definer set search_path = public, app as $$
  with mov as (
    select a.account_type, a.code, a.name,
      round(coalesce(sum(l.credit),0) - coalesce(sum(l.debit),0),2) as credit_bal,
      round(coalesce(sum(l.debit),0) - coalesce(sum(l.credit),0),2) as debit_bal
    from public.chart_of_accounts a
    join public.journal_entry_lines l on l.account_id = a.id and l.deleted_at is null
    join public.journal_entries e on e.id = l.entry_id and e.status='posted' and e.deleted_at is null
      and e.competence_date between p_from and p_to
    where a.company_id = p_company and a.deleted_at is null and a.account_type in ('revenue','cost','expense')
    group by a.account_type, a.code, a.name
  )
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'revenue', (select coalesce(sum(credit_bal),0) from mov where account_type='revenue'),
    'cost',    (select coalesce(sum(debit_bal),0)  from mov where account_type='cost'),
    'expense', (select coalesce(sum(debit_bal),0)  from mov where account_type='expense'),
    'net_income', (select coalesce(sum(credit_bal),0) from mov where account_type='revenue')
                - (select coalesce(sum(debit_bal),0) from mov where account_type in ('cost','expense')),
    'lines', coalesce((select jsonb_agg(jsonb_build_object('type',account_type,'code',code,'name',name,
                'amount', case when account_type='revenue' then credit_bal else debit_bal end) order by code) from mov),'[]'::jsonb)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.income_statement(uuid, date, date) to authenticated;

-- Balanço Patrimonial (posição acumulada até a data)
create or replace function public.balance_sheet(p_company uuid, p_as_of date default null)
returns jsonb language sql stable security definer set search_path = public, app as $$
  with mov as (
    select a.account_type,
      round(coalesce(sum(l.debit),0) - coalesce(sum(l.credit),0),2) as debit_bal,
      round(coalesce(sum(l.credit),0) - coalesce(sum(l.debit),0),2) as credit_bal
    from public.chart_of_accounts a
    join public.journal_entry_lines l on l.account_id = a.id and l.deleted_at is null
    join public.journal_entries e on e.id = l.entry_id and e.status='posted' and e.deleted_at is null
      and (p_as_of is null or e.competence_date <= p_as_of)
    where a.company_id = p_company and a.deleted_at is null
    group by a.account_type
  )
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'assets',      (select coalesce(sum(debit_bal),0)  from mov where account_type='asset'),
    'liabilities', (select coalesce(sum(credit_bal),0) from mov where account_type='liability'),
    'equity',      (select coalesce(sum(credit_bal),0) from mov where account_type='equity'),
    'result',      (select coalesce(sum(credit_bal),0) from mov where account_type='revenue')
                 - (select coalesce(sum(debit_bal),0)  from mov where account_type in ('cost','expense'))
  ) else '{}'::jsonb end;
$$;
grant execute on function public.balance_sheet(uuid, date) to authenticated;

-- Fechamento de período (exige que não haja lançamentos em rascunho no mês)
create or replace function public.close_accounting_period(p_company uuid, p_year int, p_month int)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_drafts int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('accounting.close', p_company)) then raise exception 'forbidden'; end if;
  select count(*) into v_drafts from public.journal_entries
    where company_id=p_company and status='draft' and deleted_at is null
      and extract(year from competence_date)=p_year and extract(month from competence_date)=p_month;
  if v_drafts > 0 then raise exception 'existem % lançamento(s) em rascunho no período — contabilize ou exclua antes de fechar', v_drafts; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.accounting_periods (tenant_id, company_id, fiscal_year, fiscal_month, status, closed_by, closed_at)
  values (v_tenant, p_company, p_year, p_month, 'closed', auth.uid(), now())
  on conflict (company_id, fiscal_year, fiscal_month) where deleted_at is null
  do update set status='closed', closed_by=auth.uid(), closed_at=now();
  return jsonb_build_object('period', p_year||'-'||lpad(p_month::text,2,'0'), 'status', 'closed');
end;
$$;
grant execute on function public.close_accounting_period(uuid, int, int) to authenticated;

-- Dashboard contábil
create or replace function public.gl_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'accounts', (select count(*) from public.chart_of_accounts where company_id=p_company and deleted_at is null),
    'entries_draft', (select count(*) from public.journal_entries where company_id=p_company and status='draft' and deleted_at is null),
    'entries_posted', (select count(*) from public.journal_entries where company_id=p_company and status='posted' and deleted_at is null),
    'entries_auto', (select count(*) from public.journal_entries where company_id=p_company and entry_type='auto' and deleted_at is null),
    'entries_manual', (select count(*) from public.journal_entries where company_id=p_company and entry_type='manual' and deleted_at is null),
    'posting_rules', (select count(*) from public.posting_rules where company_id=p_company and enabled and deleted_at is null),
    'recon_open', (select count(*) from public.gl_reconciliations where company_id=p_company and status='open' and deleted_at is null),
    'periods_closed', (select count(*) from public.accounting_periods where company_id=p_company and status='closed' and deleted_at is null),
    'balance', (select public.balance_sheet(p_company, null))
  ) else '{}'::jsonb end;
$$;
grant execute on function public.gl_dashboard(uuid) to authenticated;

-- IA CONTÁBIL: lançamentos desbalanceados, em período fechado, valores atípicos → LOGIA
create or replace function public.gl_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_unbal int; v_draft_old int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed'
    where company_id=p_company and status='new' and title like 'Contabilidade%' and deleted_at is null;

  select count(*) into v_unbal from public.journal_entries
    where company_id=p_company and status='posted' and deleted_at is null and round(total_debit,2) <> round(total_credit,2);
  if v_unbal > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'fraud_risk', 'critical', 'Contabilidade: lançamentos desbalanceados',
      v_unbal||' lançamento(s) contabilizado(s) com débito ≠ crédito.', 'Auditar e estornar imediatamente — fere a partida dobrada.', 96);
    v_c := v_c + 1;
  end if;

  select count(*) into v_draft_old from public.journal_entries
    where company_id=p_company and status='draft' and deleted_at is null and created_at < now() - interval '15 days';
  if v_draft_old > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'Contabilidade: rascunhos antigos',
      v_draft_old||' lançamento(s) em rascunho há mais de 15 dias.', 'Contabilizar ou excluir para permitir o fechamento.', 80);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.gl_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'accounting') ─────
do $do$
declare t text; specs text[] := array['chart_of_accounts','accounting_periods','posting_rules','journal_entries','journal_entry_lines','gl_reconciliations'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'accounting.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'accounting.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: plano de contas padrão + regras de contabilização (por empresa) ══
do $do$
declare c record;
  accts jsonb := '[
    {"code":"1","name":"ATIVO","type":"asset","nature":"debit","post":false,"parent":null},
    {"code":"1.1","name":"Ativo Circulante","type":"asset","nature":"debit","post":false,"parent":"1"},
    {"code":"1.1.01","name":"Caixa","type":"asset","nature":"debit","post":true,"parent":"1.1"},
    {"code":"1.1.02","name":"Bancos","type":"asset","nature":"debit","post":true,"parent":"1.1"},
    {"code":"1.1.03","name":"Clientes a Receber","type":"asset","nature":"debit","post":true,"parent":"1.1"},
    {"code":"1.1.04","name":"Estoques","type":"asset","nature":"debit","post":true,"parent":"1.1"},
    {"code":"1.1.05","name":"Impostos a Recuperar","type":"asset","nature":"debit","post":true,"parent":"1.1"},
    {"code":"1.2","name":"Ativo Não Circulante","type":"asset","nature":"debit","post":false,"parent":"1"},
    {"code":"1.2.01","name":"Imobilizado","type":"asset","nature":"debit","post":true,"parent":"1.2"},
    {"code":"1.2.02","name":"(-) Depreciação Acumulada","type":"asset","nature":"credit","post":true,"parent":"1.2"},
    {"code":"2","name":"PASSIVO","type":"liability","nature":"credit","post":false,"parent":null},
    {"code":"2.1","name":"Passivo Circulante","type":"liability","nature":"credit","post":false,"parent":"2"},
    {"code":"2.1.01","name":"Fornecedores","type":"liability","nature":"credit","post":true,"parent":"2.1"},
    {"code":"2.1.02","name":"Impostos a Recolher","type":"liability","nature":"credit","post":true,"parent":"2.1"},
    {"code":"2.1.03","name":"Salários a Pagar","type":"liability","nature":"credit","post":true,"parent":"2.1"},
    {"code":"2.1.04","name":"Comissões a Pagar","type":"liability","nature":"credit","post":true,"parent":"2.1"},
    {"code":"3","name":"PATRIMÔNIO LÍQUIDO","type":"equity","nature":"credit","post":false,"parent":null},
    {"code":"3.1.01","name":"Capital Social","type":"equity","nature":"credit","post":true,"parent":"3"},
    {"code":"3.1.02","name":"Lucros/Prejuízos Acumulados","type":"equity","nature":"credit","post":true,"parent":"3"},
    {"code":"4","name":"RECEITAS","type":"revenue","nature":"credit","post":false,"parent":null},
    {"code":"4.1.01","name":"Receita de Venda de Produtos","type":"revenue","nature":"credit","post":true,"parent":"4"},
    {"code":"4.1.02","name":"Receita de Serviços","type":"revenue","nature":"credit","post":true,"parent":"4"},
    {"code":"5","name":"CUSTOS","type":"cost","nature":"debit","post":false,"parent":null},
    {"code":"5.1.01","name":"CMV - Custo Mercadoria Vendida","type":"cost","nature":"debit","post":true,"parent":"5"},
    {"code":"5.1.02","name":"Custo de Produção","type":"cost","nature":"debit","post":true,"parent":"5"},
    {"code":"6","name":"DESPESAS","type":"expense","nature":"debit","post":false,"parent":null},
    {"code":"6.1.01","name":"Despesas Administrativas","type":"expense","nature":"debit","post":true,"parent":"6"},
    {"code":"6.1.02","name":"Despesas Comerciais","type":"expense","nature":"debit","post":true,"parent":"6"},
    {"code":"6.1.03","name":"Despesas com Comissões","type":"expense","nature":"debit","post":true,"parent":"6"},
    {"code":"6.1.04","name":"Despesas com Depreciação","type":"expense","nature":"debit","post":true,"parent":"6"}
  ]'::jsonb;
  rules jsonb := '[
    {"ev":"goods_receipt","desc":"Recebimento de mercadoria","d":"1.1.04","c":"2.1.01"},
    {"ev":"sale_invoice","desc":"Emissão de NF de venda","d":"1.1.03","c":"4.1.01"},
    {"ev":"cogs","desc":"Baixa de estoque na venda (CMV)","d":"5.1.01","c":"1.1.04"},
    {"ev":"supplier_payment","desc":"Pagamento a fornecedor","d":"2.1.01","c":"1.1.02"},
    {"ev":"customer_receipt","desc":"Recebimento de cliente","d":"1.1.02","c":"1.1.03"},
    {"ev":"production_done","desc":"Produção concluída (entrada acabado)","d":"1.1.04","c":"5.1.02"},
    {"ev":"material_consumption","desc":"Consumo de matéria-prima","d":"5.1.02","c":"1.1.04"},
    {"ev":"depreciation","desc":"Depreciação do período","d":"6.1.04","c":"1.2.02"},
    {"ev":"service_rendered","desc":"Atendimento/procedimento (serviço)","d":"1.1.03","c":"4.1.02"},
    {"ev":"commission","desc":"Comissão/repasse a profissional","d":"6.1.03","c":"2.1.04"}
  ]'::jsonb;
  a jsonb; r jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    -- contas (insere achatado; resolve parent_id depois via código guardado no metadata)
    for a in select value from jsonb_array_elements(accts) loop
      if not exists (select 1 from public.chart_of_accounts where company_id=c.id and code=(a->>'code') and plan_type='statutory' and deleted_at is null) then
        insert into public.chart_of_accounts (tenant_id, company_id, code, name, account_type, nature, is_postable, plan_type, metadata)
        values (c.tenant_id, c.id, a->>'code', a->>'name', (a->>'type')::public.gl_account_type, (a->>'nature')::public.gl_nature,
          (a->>'post')::boolean, 'statutory', jsonb_build_object('parent_code', a->>'parent'));
      end if;
    end loop;
    update public.chart_of_accounts ch set parent_id = p.id
      from public.chart_of_accounts p
      where ch.company_id=c.id and p.company_id=c.id and ch.plan_type='statutory'
        and p.code = ch.metadata->>'parent_code' and ch.parent_id is null and ch.metadata->>'parent_code' is not null;
    -- regras de contabilização
    for r in select value from jsonb_array_elements(rules) loop
      if not exists (select 1 from public.posting_rules where company_id=c.id and event_key=(r->>'ev') and deleted_at is null) then
        insert into public.posting_rules (tenant_id, company_id, event_key, description, debit_account_id, credit_account_id)
        select c.tenant_id, c.id, r->>'ev', r->>'desc',
          (select id from public.chart_of_accounts where company_id=c.id and code=(r->>'d') and plan_type='statutory' and deleted_at is null),
          (select id from public.chart_of_accounts where company_id=c.id and code=(r->>'c') and plan_type='statutory' and deleted_at is null);
      end if;
    end loop;
  end loop;
end $do$;

notify pgrst, 'reload schema';
