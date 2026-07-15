-- 20260713000054_pwm.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PWM — PAYROLL & WORKFORCE MANAGEMENT (Vol 22) — Folha & Força de Trabalho ║
-- ║  Cálculo de folha (INSS/IRRF/FGTS progressivos), ponto, escalas, banco de  ║
-- ║  horas, rescisões, rateio de custos. A folha aprovada POSTA NO GL          ║
-- ║  (D Despesa de Pessoal / C Salários a Pagar + Impostos a Recolher).       ║
-- ║  Nível SAP Payroll / Workday Payroll / ADP. pwm_insights auto LAIOS.      ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

do $e$ begin
  if not exists (select 1 from pg_type where typname='payroll_status') then
    create type public.payroll_status as enum ('draft','calculated','approved','paid'); end if;
end $e$;

insert into public.permissions (slug, resource, action, description)
select 'payroll.' || a, 'payroll', a, 'Permissão ' || a || ' em payroll'
from unnest(array['read','create','update','delete','approve','process']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'payroll' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── ESCALAS + PONTO + BANCO DE HORAS ────────────────────────────────────────
create table public.work_schedules (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, schedule_type text default '5x2', hours_per_day numeric(6,2) not null default 8, weekly_hours numeric(6,2) default 44, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.time_entries (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  employee_id uuid not null references public.employees(id) on delete cascade,
  entry_date date not null default now()::date, clock_in time, clock_out time,
  hours_worked numeric(6,2) not null default 0, overtime_hours numeric(6,2) not null default 0, source text default 'app', is_absence boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_time_entries_emp on public.time_entries (company_id, employee_id, entry_date);
create table public.time_bank_movements (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  employee_id uuid not null references public.employees(id) on delete cascade,
  movement_date date default now()::date, hours numeric(7,2) not null default 0, reason text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_time_bank_emp on public.time_bank_movements (company_id, employee_id);

-- ── FOLHA: RUNS + ITEMS + EVENT LINES ───────────────────────────────────────
create table public.payroll_runs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  fiscal_year integer not null, fiscal_month integer not null, run_type text default 'monthly',
  status public.payroll_status not null default 'draft',
  total_gross numeric(18,2) not null default 0, total_deductions numeric(18,2) not null default 0, total_net numeric(18,2) not null default 0,
  total_inss numeric(18,2) not null default 0, total_irrf numeric(18,2) not null default 0, total_fgts numeric(18,2) not null default 0, total_employer numeric(18,2) not null default 0,
  employees_count integer not null default 0, journal_ref uuid, processed_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_payroll_run on public.payroll_runs (company_id, fiscal_year, fiscal_month, run_type) where deleted_at is null;
create table public.payroll_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  run_id uuid not null references public.payroll_runs(id) on delete cascade,
  employee_id uuid references public.employees(id) on delete set null,
  gross numeric(18,2) not null default 0, inss numeric(18,2) not null default 0, irrf numeric(18,2) not null default 0,
  fgts numeric(18,2) not null default 0, other_deductions numeric(18,2) not null default 0, net numeric(18,2) not null default 0,
  cost_center_id uuid references public.cost_centers(id) on delete set null,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_payroll_items_run on public.payroll_items (run_id);
create table public.payroll_event_lines (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  item_id uuid not null references public.payroll_items(id) on delete cascade,
  event_code text not null, event_name text, event_type text default 'earning', amount numeric(18,2) not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_payroll_event_lines_item on public.payroll_event_lines (item_id);

-- ── RESCISÕES ───────────────────────────────────────────────────────────────
create table public.terminations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  employee_id uuid references public.employees(id) on delete set null,
  termination_date date not null default now()::date, reason text default 'dismissal_without_cause',
  salary_balance numeric(18,2) default 0, vacation_amount numeric(18,2) default 0, thirteenth_amount numeric(18,2) default 0,
  fgts_fine numeric(18,2) default 0, total_amount numeric(18,2) default 0, status text default 'calculated', notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ HELPERS: cálculo progressivo INSS / IRRF (parametrizável) ═══════════════
create or replace function app.calc_inss(p_salary numeric)
returns numeric language plpgsql immutable as $$
declare s numeric := p_salary; v numeric := 0;
begin
  -- faixas progressivas (base 2024) — parametrizável no futuro via tabela
  v := v + least(s, 1412.00) * 0.075;
  if s > 1412.00 then v := v + (least(s, 2666.68) - 1412.00) * 0.09; end if;
  if s > 2666.68 then v := v + (least(s, 4000.03) - 2666.68) * 0.12; end if;
  if s > 4000.03 then v := v + (least(s, 7786.02) - 4000.03) * 0.14; end if;
  return round(v, 2);
end;
$$;
create or replace function app.calc_irrf(p_base numeric)
returns numeric language sql immutable as $$
  select round(greatest(case
    when p_base <= 2259.20 then 0
    when p_base <= 2826.65 then p_base*0.075 - 169.44
    when p_base <= 3751.05 then p_base*0.15  - 381.44
    when p_base <= 4664.68 then p_base*0.225 - 662.77
    else p_base*0.275 - 896.00 end, 0), 2);
$$;

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Processar a folha do período: calcula INSS/IRRF/FGTS por colaborador
create or replace function public.run_payroll(p_company uuid, p_year int, p_month int)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare
  v_tenant uuid; v_run uuid; e record; v_item uuid;
  v_gross numeric; v_inss numeric; v_irrf numeric; v_fgts numeric; v_net numeric; v_base numeric;
  t_gross numeric := 0; t_inss numeric := 0; t_irrf numeric := 0; t_fgts numeric := 0; t_net numeric := 0; t_emp numeric := 0; v_count int := 0;
begin
  if not (app.can_access_company(p_company) and app.has_permission('payroll.process', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  if exists (select 1 from public.payroll_runs where company_id=p_company and fiscal_year=p_year and fiscal_month=p_month and run_type='monthly' and deleted_at is null) then
    raise exception 'folha do período % já existe', p_year||'/'||p_month;
  end if;

  insert into public.payroll_runs (tenant_id, company_id, fiscal_year, fiscal_month, status)
  values (v_tenant, p_company, p_year, p_month, 'calculated') returning id into v_run;

  for e in select * from public.employees where company_id=p_company and status<>'terminated' and deleted_at is null and coalesce(salary,0) > 0 loop
    v_gross := e.salary;
    v_inss  := app.calc_inss(v_gross);
    v_base  := v_gross - v_inss;
    v_irrf  := app.calc_irrf(v_base);
    v_fgts  := round(v_gross * 0.08, 2);
    v_net   := round(v_gross - v_inss - v_irrf, 2);

    insert into public.payroll_items (tenant_id, company_id, run_id, employee_id, gross, inss, irrf, fgts, net, cost_center_id)
    values (v_tenant, p_company, v_run, e.id, v_gross, v_inss, v_irrf, v_fgts, v_net, e.cost_center_id) returning id into v_item;
    insert into public.payroll_event_lines (tenant_id, company_id, item_id, event_code, event_name, event_type, amount) values
      (v_tenant, p_company, v_item, '001', 'Salário base', 'earning', v_gross),
      (v_tenant, p_company, v_item, '901', 'INSS', 'deduction', v_inss),
      (v_tenant, p_company, v_item, '902', 'IRRF', 'deduction', v_irrf),
      (v_tenant, p_company, v_item, '905', 'FGTS (informativo)', 'employer', v_fgts);

    t_gross := t_gross + v_gross; t_inss := t_inss + v_inss; t_irrf := t_irrf + v_irrf; t_fgts := t_fgts + v_fgts; t_net := t_net + v_net; v_count := v_count + 1;
  end loop;

  t_emp := round(t_fgts + t_gross * 0.20, 2);  -- encargos patronais (FGTS 8% + INSS patronal 20%)
  update public.payroll_runs set total_gross=round(t_gross,2), total_inss=round(t_inss,2), total_irrf=round(t_irrf,2),
    total_fgts=round(t_fgts,2), total_deductions=round(t_inss+t_irrf,2), total_net=round(t_net,2), total_employer=t_emp,
    employees_count=v_count, processed_at=now() where id=v_run;
  return jsonb_build_object('run_id', v_run, 'employees', v_count, 'gross', round(t_gross,2), 'net', round(t_net,2),
    'inss', round(t_inss,2), 'irrf', round(t_irrf,2), 'fgts', round(t_fgts,2), 'employer_charges', t_emp);
end;
$$;
grant execute on function public.run_payroll(uuid, int, int) to authenticated;

-- Aprovar folha → POSTA NO GL (partidas dobradas)
create or replace function public.approve_payroll(p_run uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare r record; v_exp uuid; v_pay uuid; v_tax uuid; v_lines jsonb; v_je jsonb; v_journal uuid;
begin
  select * into r from public.payroll_runs where id=p_run and deleted_at is null;
  if r.id is null then raise exception 'folha não encontrada'; end if;
  if not (app.can_access_company(r.company_id) and app.has_permission('payroll.approve', r.company_id)) then raise exception 'forbidden'; end if;
  if r.status = 'approved' then raise exception 'folha já aprovada'; end if;

  -- contas do plano (societário): despesa adm (proxy pessoal), salários a pagar, impostos a recolher
  select id into v_exp from public.chart_of_accounts where company_id=r.company_id and code='6.1.01' and plan_type='statutory' and deleted_at is null;
  select id into v_pay from public.chart_of_accounts where company_id=r.company_id and code='2.1.03' and plan_type='statutory' and deleted_at is null;
  select id into v_tax from public.chart_of_accounts where company_id=r.company_id and code='2.1.02' and plan_type='statutory' and deleted_at is null;

  if v_exp is not null and v_pay is not null and v_tax is not null and r.total_gross > 0 then
    v_lines := jsonb_build_array(
      jsonb_build_object('account_id', v_exp, 'debit', round(r.total_gross + r.total_employer, 2), 'credit', 0, 'description', 'Despesa de pessoal'),
      jsonb_build_object('account_id', v_pay, 'debit', 0, 'credit', round(r.total_net, 2), 'description', 'Salários a pagar'),
      jsonb_build_object('account_id', v_tax, 'debit', 0, 'credit', round(r.total_inss + r.total_irrf + r.total_employer, 2), 'description', 'Encargos e retenções a recolher')
    );
    begin
      v_je := public.create_journal_entry(r.company_id, now()::date, 'Folha de pagamento '||r.fiscal_year||'/'||lpad(r.fiscal_month::text,2,'0'), v_lines, 'auto', 'FOLHA-'||r.fiscal_year||lpad(r.fiscal_month::text,2,'0'), true);
      v_journal := (v_je->>'id')::uuid;
    exception when others then v_journal := null; end;
  end if;

  update public.payroll_runs set status='approved', journal_ref=v_journal where id=p_run;
  return jsonb_build_object('run_id', p_run, 'status', 'approved', 'gl_posted', v_journal is not null, 'journal_id', v_journal);
end;
$$;
grant execute on function public.approve_payroll(uuid) to authenticated;

-- Registrar ponto
create or replace function public.register_time(p_employee uuid, p_date date, p_hours numeric, p_overtime numeric default 0, p_source text default 'app', p_absence boolean default false)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare e record;
begin
  select * into e from public.employees where id=p_employee and deleted_at is null;
  if e.id is null then raise exception 'colaborador não encontrado'; end if;
  if not (app.can_access_company(e.company_id) and app.has_permission('payroll.create', e.company_id)) then raise exception 'forbidden'; end if;
  insert into public.time_entries (tenant_id, company_id, employee_id, entry_date, hours_worked, overtime_hours, source, is_absence)
  values (e.tenant_id, e.company_id, p_employee, p_date, p_hours, p_overtime, p_source, p_absence);
  if p_overtime <> 0 then
    insert into public.time_bank_movements (tenant_id, company_id, employee_id, movement_date, hours, reason)
    values (e.tenant_id, e.company_id, p_employee, p_date, p_overtime, 'Hora extra do ponto');
  end if;
  return jsonb_build_object('employee', e.full_name, 'hours', p_hours, 'overtime', p_overtime);
end;
$$;
grant execute on function public.register_time(uuid, date, numeric, numeric, text, boolean) to authenticated;

-- Rescisão (cálculo simplificado)
create or replace function public.compute_termination(p_employee uuid, p_reason text, p_date date default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare e record; v_tenant uuid; v_sal numeric; v_13 numeric; v_vac numeric; v_fine numeric; v_total numeric; v_date date;
begin
  select * into e from public.employees where id=p_employee and deleted_at is null;
  if e.id is null then raise exception 'colaborador não encontrado'; end if;
  if not (app.can_access_company(e.company_id) and app.has_permission('payroll.approve', e.company_id)) then raise exception 'forbidden'; end if;
  v_date := coalesce(p_date, now()::date);
  select tenant_id into v_tenant from public.companies where id=e.company_id;
  v_sal  := round(coalesce(e.salary,0) * (extract(day from v_date)/30.0), 2);           -- saldo de salário
  v_13   := round(coalesce(e.salary,0) * (extract(month from v_date)/12.0), 2);          -- 13º proporcional
  v_vac  := round(coalesce(e.salary,0) * (extract(month from v_date)/12.0) * 1.3333, 2); -- férias prop + 1/3
  v_fine := case when p_reason='dismissal_without_cause' then round(coalesce(e.salary,0) * 12 * 0.08 * 0.40, 2) else 0 end; -- multa 40% FGTS (aprox 1 ano)
  v_total := round(v_sal + v_13 + v_vac + v_fine, 2);
  insert into public.terminations (tenant_id, company_id, employee_id, termination_date, reason, salary_balance, thirteenth_amount, vacation_amount, fgts_fine, total_amount)
  values (v_tenant, e.company_id, p_employee, v_date, p_reason, v_sal, v_13, v_vac, v_fine, v_total);
  update public.employees set status='terminated', termination_date=v_date where id=p_employee;
  return jsonb_build_object('employee', e.full_name, 'salary_balance', v_sal, 'thirteenth', v_13, 'vacation', v_vac, 'fgts_fine', v_fine, 'total', v_total);
end;
$$;
grant execute on function public.compute_termination(uuid, text, date) to authenticated;

create or replace function public.pwm_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'headcount', (select count(*) from public.employees where company_id=p_company and status<>'terminated' and deleted_at is null),
    'payroll_base', (select coalesce(sum(salary),0) from public.employees where company_id=p_company and status<>'terminated' and deleted_at is null),
    'runs', (select count(*) from public.payroll_runs where company_id=p_company and deleted_at is null),
    'last_run', (select jsonb_build_object('period', fiscal_year||'/'||lpad(fiscal_month::text,2,'0'), 'status', status, 'gross', total_gross, 'net', total_net, 'employer', total_employer)
        from public.payroll_runs where company_id=p_company and deleted_at is null order by fiscal_year desc, fiscal_month desc limit 1),
    'overtime_month', (select coalesce(sum(overtime_hours),0) from public.time_entries where company_id=p_company and deleted_at is null and extract(year from entry_date)=extract(year from now()) and extract(month from entry_date)=extract(month from now())),
    'time_bank_balance', (select coalesce(sum(hours),0) from public.time_bank_movements where company_id=p_company and deleted_at is null),
    'schedules', (select count(*) from public.work_schedules where company_id=p_company and deleted_at is null),
    'terminations_ytd', (select count(*) from public.terminations where company_id=p_company and deleted_at is null and extract(year from termination_date)=extract(year from now()))
  ) else '{}'::jsonb end;
$$;
grant execute on function public.pwm_dashboard(uuid) to authenticated;

create or replace function public.pwm_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_norun int; v_ot numeric; v_tb int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Folha%' and deleted_at is null;

  if not exists (select 1 from public.payroll_runs where company_id=p_company and fiscal_year=extract(year from now())::int and fiscal_month=extract(month from now())::int and deleted_at is null)
     and exists (select 1 from public.employees where company_id=p_company and status<>'terminated' and deleted_at is null) then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'warning', 'Folha: competência atual não processada', 'A folha do mês corrente ainda não foi calculada.', 'Processar a folha antes do fechamento para refletir no financeiro/GL.', 82);
    v_c := v_c + 1;
  end if;
  select coalesce(sum(overtime_hours),0) into v_ot from public.time_entries where company_id=p_company and deleted_at is null and extract(month from entry_date)=extract(month from now());
  if v_ot > 100 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, impact_value, confidence)
    values (v_tenant, p_company, 'cost_saving', 'warning', 'Folha: excesso de horas extras', v_ot||'h de hora extra no mês.', 'Rever dimensionamento de equipe/escala — custo e risco trabalhista.', v_ot, 80);
    v_c := v_c + 1;
  end if;
  select count(*) into v_tb from (select employee_id, sum(hours) h from public.time_bank_movements where company_id=p_company and deleted_at is null group by employee_id having abs(sum(hours)) > 40) z;
  if v_tb > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'Folha: banco de horas acima do limite', v_tb||' colaborador(es) com saldo de banco de horas > 40h.', 'Programar compensação para não vencer/gerar passivo.', 74);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.pwm_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'payroll') ────────
do $do$
declare t text; specs text[] := array['work_schedules','time_entries','time_bank_movements','payroll_runs','payroll_items','payroll_event_lines','terminations'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'payroll.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'payroll.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: escalas padrão ══
do $do$
declare c record;
  scheds jsonb := '[
    {"n":"Comercial 5x2","t":"5x2","h":8,"w":44},
    {"n":"Industrial 6x1","t":"6x1","h":7.33,"w":44},
    {"n":"Plantão 12x36","t":"12x36","h":12,"w":36},
    {"n":"Turno Noturno","t":"turno","h":8,"w":44}
  ]'::jsonb;
  s jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    for s in select value from jsonb_array_elements(scheds) loop
      if not exists (select 1 from public.work_schedules where company_id=c.id and name=(s->>'n') and deleted_at is null) then
        insert into public.work_schedules (tenant_id, company_id, name, schedule_type, hours_per_day, weekly_hours)
        values (c.tenant_id, c.id, s->>'n', s->>'t', (s->>'h')::numeric, (s->>'w')::numeric);
      end if;
    end loop;
  end loop;
end $do$;

notify pgrst, 'reload schema';
