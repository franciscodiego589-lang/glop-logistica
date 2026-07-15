-- 20260713000053_hcm.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  HCM — HUMAN CAPITAL MANAGEMENT (Vol 21) — 3ª camada: Capital Humano      ║
-- ║  Colaboradores, organograma, recrutamento, férias/ausências, desempenho,  ║
-- ║  treinamentos (certificações BPF), competências, benefícios. People       ║
-- ║  Analytics + IA de RH. Nível SAP SuccessFactors / Workday / Oracle HCM.   ║
-- ║  hr_trainings/hr_training_records (trainings já existe no QMS).           ║
-- ║  hcm_insights auto-descoberto pelo cérebro LAIOS.                        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

do $e$ begin
  if not exists (select 1 from pg_type where typname='employee_status') then
    create type public.employee_status as enum ('active','on_leave','vacation','terminated'); end if;
  if not exists (select 1 from pg_type where typname='time_off_type') then
    create type public.time_off_type as enum ('vacation','sick','maternity','paternity','unpaid','other'); end if;
  if not exists (select 1 from pg_type where typname='time_off_status') then
    create type public.time_off_status as enum ('requested','approved','rejected','canceled'); end if;
  if not exists (select 1 from pg_type where typname='candidate_stage') then
    create type public.candidate_stage as enum ('applied','screening','interview','test','offer','hired','rejected'); end if;
end $e$;

insert into public.permissions (slug, resource, action, description)
select 'hcm.' || a, 'hcm', a, 'Permissão ' || a || ' em hcm'
from unnest(array['read','create','update','delete','approve','payroll']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'hcm' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── DEPARTMENTS (organograma, parent_id) + POSITIONS (cargos) ───────────────
create table public.departments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, code text, parent_id uuid references public.departments(id) on delete set null,
  cost_center_id uuid references public.cost_centers(id) on delete set null, manager_name text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_departments_parent on public.departments (parent_id);

create table public.positions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  title text not null, level text, salary_min numeric(18,2), salary_max numeric(18,2), cbo text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── EMPLOYEES (colaboradores) ───────────────────────────────────────────────
create table public.employees (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  registration text, full_name text not null, document text, email text, phone text, birth_date date,
  position_id uuid references public.positions(id) on delete set null,
  department_id uuid references public.departments(id) on delete set null,
  manager_id uuid references public.employees(id) on delete set null,
  cost_center_id uuid references public.cost_centers(id) on delete set null,
  hire_date date, termination_date date, salary numeric(18,2), status public.employee_status not null default 'active',
  employment_type text default 'clt', education text, address text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_employees_status on public.employees (company_id, status) where deleted_at is null;
create index idx_employees_manager on public.employees (manager_id);
create index idx_employees_dept on public.employees (department_id);

-- ── RECRUTAMENTO: JOB_VACANCIES + CANDIDATES ────────────────────────────────
create table public.job_vacancies (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  title text not null, department_id uuid references public.departments(id) on delete set null,
  position_id uuid references public.positions(id) on delete set null,
  openings integer not null default 1, status text not null default 'open', requirements text, salary_range text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create table public.candidates (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  vacancy_id uuid references public.job_vacancies(id) on delete set null,
  full_name text not null, email text, phone text, source text, resume_url text,
  stage public.candidate_stage not null default 'applied', score integer, notes text, hired_employee_id uuid references public.employees(id) on delete set null,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_candidates_stage on public.candidates (company_id, stage) where deleted_at is null;

-- ── TIME_OFF (férias/licenças) + PERFORMANCE_REVIEWS ────────────────────────
create table public.time_off_requests (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  employee_id uuid not null references public.employees(id) on delete cascade,
  time_off_type public.time_off_type not null default 'vacation', start_date date not null, end_date date not null,
  days integer, status public.time_off_status not null default 'requested', approved_by uuid references auth.users(id), reason text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_time_off_status on public.time_off_requests (company_id, status) where deleted_at is null;

create table public.performance_reviews (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  employee_id uuid not null references public.employees(id) on delete cascade,
  review_type text default '360', period text, reviewer text, score numeric(5,2), status text not null default 'pending',
  strengths text, improvements text, pdi text, due_date date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── TREINAMENTOS (hr_*) + COMPETÊNCIAS + BENEFÍCIOS ─────────────────────────
create table public.hr_trainings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, category text, is_mandatory boolean not null default false, valid_months integer, workload_hours numeric(8,2),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.hr_training_records (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  training_id uuid references public.hr_trainings(id) on delete cascade,
  employee_id uuid references public.employees(id) on delete cascade,
  completed_at date, expires_at date, score numeric(5,2), certificate_url text, status text not null default 'completed',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_hr_training_records_emp on public.hr_training_records (employee_id, expires_at);

create table public.competencies (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, competency_type text default 'technical', description text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.employee_competencies (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  employee_id uuid references public.employees(id) on delete cascade,
  competency_id uuid references public.competencies(id) on delete cascade,
  level integer not null default 1, target_level integer, assessed_at date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_emp_comp on public.employee_competencies (employee_id);

create table public.employee_benefits (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  employee_id uuid references public.employees(id) on delete cascade,
  benefit_type text not null, provider text, monthly_value numeric(18,2), employee_share numeric(18,2), status text default 'active',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_emp_benefits on public.employee_benefits (employee_id);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

create or replace function public.request_time_off(p_employee uuid, p_type public.time_off_type, p_start date, p_end date, p_reason text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare e record; v_days int;
begin
  select * into e from public.employees where id=p_employee and deleted_at is null;
  if e.id is null then raise exception 'colaborador não encontrado'; end if;
  if not (app.can_access_company(e.company_id) and app.has_permission('hcm.create', e.company_id)) then raise exception 'forbidden'; end if;
  v_days := (p_end - p_start) + 1;
  if v_days <= 0 then raise exception 'período inválido'; end if;
  insert into public.time_off_requests (tenant_id, company_id, employee_id, time_off_type, start_date, end_date, days, status, reason)
  values (e.tenant_id, e.company_id, p_employee, p_type, p_start, p_end, v_days, 'requested', p_reason);
  return jsonb_build_object('employee', e.full_name, 'days', v_days, 'status', 'requested');
end;
$$;
grant execute on function public.request_time_off(uuid, public.time_off_type, date, date, text) to authenticated;

create or replace function public.decide_time_off(p_request uuid, p_approve boolean)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare r record;
begin
  select * into r from public.time_off_requests where id=p_request and deleted_at is null;
  if r.id is null then raise exception 'solicitação não encontrada'; end if;
  if not (app.can_access_company(r.company_id) and app.has_permission('hcm.approve', r.company_id)) then raise exception 'forbidden'; end if;
  update public.time_off_requests set status = case when p_approve then 'approved' else 'rejected' end::public.time_off_status, approved_by=auth.uid() where id=p_request;
  if p_approve and r.time_off_type='vacation' then
    update public.employees set status='vacation' where id=r.employee_id;
  end if;
  return jsonb_build_object('request', p_request, 'status', case when p_approve then 'approved' else 'rejected' end);
end;
$$;
grant execute on function public.decide_time_off(uuid, boolean) to authenticated;

-- Contratar candidato → cria colaborador
create or replace function public.hire_candidate(p_candidate uuid, p_position uuid, p_department uuid, p_salary numeric, p_hire_date date default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare c record; v_emp uuid; v_reg text;
begin
  select * into c from public.candidates where id=p_candidate and deleted_at is null;
  if c.id is null then raise exception 'candidato não encontrado'; end if;
  if not (app.can_access_company(c.company_id) and app.has_permission('hcm.create', c.company_id)) then raise exception 'forbidden'; end if;
  select 'EMP' || lpad((coalesce((select count(*) from public.employees where company_id=c.company_id),0)+1)::text, 5, '0') into v_reg;
  insert into public.employees (tenant_id, company_id, registration, full_name, email, phone, position_id, department_id, hire_date, salary, status)
  values (c.tenant_id, c.company_id, v_reg, c.full_name, c.email, c.phone, p_position, p_department, coalesce(p_hire_date, now()::date), p_salary, 'active')
  returning id into v_emp;
  update public.candidates set stage='hired', hired_employee_id=v_emp where id=p_candidate;
  return jsonb_build_object('employee_id', v_emp, 'registration', v_reg);
end;
$$;
grant execute on function public.hire_candidate(uuid, uuid, uuid, numeric, date) to authenticated;

-- Dashboard de RH (People Analytics)
create or replace function public.hcm_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'headcount', (select count(*) from public.employees where company_id=p_company and status<>'terminated' and deleted_at is null),
    'on_leave', (select count(*) from public.employees where company_id=p_company and status in ('on_leave','vacation') and deleted_at is null),
    'terminated_ytd', (select count(*) from public.employees where company_id=p_company and status='terminated' and extract(year from termination_date)=extract(year from now()) and deleted_at is null),
    'open_vacancies', (select count(*) from public.job_vacancies where company_id=p_company and status='open' and deleted_at is null),
    'candidates', (select count(*) from public.candidates where company_id=p_company and stage not in ('hired','rejected') and deleted_at is null),
    'time_off_pending', (select count(*) from public.time_off_requests where company_id=p_company and status='requested' and deleted_at is null),
    'reviews_pending', (select count(*) from public.performance_reviews where company_id=p_company and status='pending' and deleted_at is null),
    'payroll_monthly', (select coalesce(sum(salary),0) from public.employees where company_id=p_company and status<>'terminated' and deleted_at is null),
    'avg_tenure_years', (select coalesce(round((avg(now()::date - hire_date)/365.25)::numeric,1),0) from public.employees where company_id=p_company and status<>'terminated' and hire_date is not null and deleted_at is null),
    'by_department', (select coalesce(jsonb_object_agg(dname, cnt),'{}'::jsonb) from (
        select coalesce(d.name,'Sem depto') dname, count(*) cnt from public.employees e left join public.departments d on d.id=e.department_id
        where e.company_id=p_company and e.status<>'terminated' and e.deleted_at is null group by d.name) s)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.hcm_dashboard(uuid) to authenticated;

-- IA RH: treinamentos obrigatórios (BPF) vencidos/vencendo, férias pendentes, reviews atrasadas → LOGIA
create or replace function public.hcm_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_train int; v_off int; v_rev int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'RH%' and deleted_at is null;

  select count(*) into v_train from public.hr_training_records tr join public.hr_trainings t on t.id=tr.training_id
    where tr.company_id=p_company and t.is_mandatory and tr.deleted_at is null and tr.expires_at is not null and tr.expires_at <= now()::date + 30;
  if v_train > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'critical', 'RH: certificações obrigatórias (BPF) vencendo', v_train||' certificação(ões) obrigatória(s) vencida(s)/vencendo em 30 dias.', 'Agendar reciclagem — risco de não conformidade BPF/auditoria.', 90);
    v_c := v_c + 1;
  end if;
  select count(*) into v_off from public.time_off_requests where company_id=p_company and status='requested' and deleted_at is null;
  if v_off > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'RH: férias/ausências a aprovar', v_off||' solicitação(ões) aguardando aprovação.', 'Aprovar/rejeitar para o colaborador se planejar.', 78);
    v_c := v_c + 1;
  end if;
  select count(*) into v_rev from public.performance_reviews where company_id=p_company and status='pending' and deleted_at is null and due_date < now()::date;
  if v_rev > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'RH: avaliações de desempenho atrasadas', v_rev||' avaliação(ões) vencida(s).', 'Concluir os ciclos de avaliação pendentes.', 76);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.hcm_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'hcm') ────────────
do $do$
declare t text; specs text[] := array['departments','positions','employees','job_vacancies','candidates','time_off_requests','performance_reviews','hr_trainings','hr_training_records','competencies','employee_competencies','employee_benefits'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'hcm.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'hcm.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: departamentos + cargos + treinamentos BPF (por empresa) ══
do $do$
declare c record;
  depts text[] := array['Diretoria','Produção','Qualidade','Comercial','Administrativo/Financeiro','Logística','P&D'];
  poss jsonb := '[
    {"t":"Diretor","l":"executive"},{"t":"Gerente","l":"management"},{"t":"Coordenador","l":"coordination"},
    {"t":"Analista","l":"technical"},{"t":"Operador de Produção","l":"operational"},{"t":"Esteticista","l":"operational"},
    {"t":"Auxiliar","l":"operational"},{"t":"Vendedor","l":"commercial"}
  ]'::jsonb;
  trains jsonb := '[
    {"n":"Boas Práticas de Fabricação (BPF)","c":"qualidade","m":true,"v":12},
    {"n":"Segurança do Trabalho (NR)","c":"seguranca","m":true,"v":12},
    {"n":"Operação de Encapsuladora","c":"operacao","m":true,"v":24},
    {"n":"Atendimento e Vendas","c":"comercial","m":false,"v":null},
    {"n":"LGPD e Compliance","c":"compliance","m":true,"v":24}
  ]'::jsonb;
  d text; p jsonb; tr jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    foreach d in array depts loop
      if not exists (select 1 from public.departments where company_id=c.id and name=d and deleted_at is null) then
        insert into public.departments (tenant_id, company_id, name) values (c.tenant_id, c.id, d);
      end if;
    end loop;
    for p in select value from jsonb_array_elements(poss) loop
      if not exists (select 1 from public.positions where company_id=c.id and title=(p->>'t') and deleted_at is null) then
        insert into public.positions (tenant_id, company_id, title, level) values (c.tenant_id, c.id, p->>'t', p->>'l');
      end if;
    end loop;
    for tr in select value from jsonb_array_elements(trains) loop
      if not exists (select 1 from public.hr_trainings where company_id=c.id and name=(tr->>'n') and deleted_at is null) then
        insert into public.hr_trainings (tenant_id, company_id, name, category, is_mandatory, valid_months)
        values (c.tenant_id, c.id, tr->>'n', tr->>'c', (tr->>'m')::boolean, nullif(tr->>'v','null')::int);
      end if;
    end loop;
  end loop;
end $do$;

notify pgrst, 'reload schema';
