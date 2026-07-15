-- 20260713000055_bpm.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  BPM — ENTERPRISE BPM SUITE (Vol 23) — o MOTOR DE PROCESSOS do ERP        ║
-- ║  Workflow engine (definições versionadas → instâncias → tarefas/aprovações║
-- ║  → advance por steps), Business Rules Engine (DMN/tabelas de decisão),     ║
-- ║  SLA, event bus, automações. Nível Camunda/Appian/Pega/ServiceNow.        ║
-- ║  bpm_insights auto-descoberto pelo cérebro LAIOS.                        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

do $e$ begin
  if not exists (select 1 from pg_type where typname='process_instance_status') then
    create type public.process_instance_status as enum ('running','completed','rejected','canceled'); end if;
  if not exists (select 1 from pg_type where typname='process_task_status') then
    create type public.process_task_status as enum ('pending','approved','rejected','done','skipped'); end if;
end $e$;

insert into public.permissions (slug, resource, action, description)
select 'bpm.' || a, 'bpm', a, 'Permissão ' || a || ' em bpm'
from unnest(array['read','create','update','delete','approve','publish']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'bpm' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── PROCESS_DEFINITIONS (workflows versionados; steps em jsonb) ─────────────
create table public.process_definitions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  process_key text not null, name text not null, category text, version integer not null default 1,
  status text not null default 'published', definition jsonb not null default '{}'::jsonb, description text,
  active boolean not null default true, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_process_defs_key on public.process_definitions (company_id, process_key) where deleted_at is null;

-- ── PROCESS_INSTANCES ───────────────────────────────────────────────────────
create table public.process_instances (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  definition_id uuid references public.process_definitions(id) on delete set null,
  process_key text, business_key text, title text, current_step text,
  status public.process_instance_status not null default 'running', result text, context jsonb not null default '{}'::jsonb,
  started_by uuid references auth.users(id), started_at timestamptz not null default now(), ended_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_process_instances_status on public.process_instances (company_id, status) where deleted_at is null;

-- ── PROCESS_TASKS (tarefas / aprovações) ────────────────────────────────────
create table public.process_tasks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  instance_id uuid not null references public.process_instances(id) on delete cascade,
  step_key text, name text, task_type text default 'approval', assignee_role text, assignee uuid,
  status public.process_task_status not null default 'pending', sla_due timestamptz,
  decided_by uuid references auth.users(id), decided_at timestamptz, comment text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_process_tasks_pending on public.process_tasks (company_id, status) where deleted_at is null;

-- ── PROCESS_EVENTS (event bus + trilha) ─────────────────────────────────────
create table public.process_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  instance_id uuid references public.process_instances(id) on delete cascade,
  event_type text not null, step_key text, payload jsonb not null default '{}'::jsonb, actor uuid,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_process_events_instance on public.process_events (instance_id, created_at);

-- ── BUSINESS_RULES (DMN / tabelas de decisão) + AUTOMATION + FORMS ──────────
create table public.business_rules (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  rule_key text not null, name text not null, description text, rules jsonb not null default '[]'::jsonb, default_output jsonb, enabled boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_business_rules_key on public.business_rules (company_id, rule_key) where deleted_at is null;

create table public.automation_rules (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, trigger_event text not null, condition jsonb, action jsonb not null default '{}'::jsonb, enabled boolean not null default true, run_count integer not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.form_definitions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  form_key text not null, name text not null, fields jsonb not null default '[]'::jsonb,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ MOTOR DE WORKFLOW ══════════════════════════════════════════════════════
-- Avança a instância pelos steps até parar numa tarefa (espera) ou terminar.
create or replace function app.bpm_advance(p_instance uuid)
returns void language plpgsql security definer set search_path = public, app as $$
declare inst record; def jsonb; steps jsonb; step jsonb; v_key text; v_type text; guard int := 0;
begin
  select * into inst from public.process_instances where id=p_instance;
  select definition into def from public.process_definitions where id=inst.definition_id;
  steps := coalesce(def->'steps','[]'::jsonb);
  v_key := inst.current_step;
  loop
    guard := guard + 1; exit when guard > 100;
    select s into step from jsonb_array_elements(steps) s where s->>'key' = v_key limit 1;
    if step is null then
      update public.process_instances set status='completed', result='no_step', ended_at=now() where id=p_instance; return;
    end if;
    v_type := step->>'type';
    if v_type = 'end' then
      update public.process_instances set status = (case when (step->>'result')='rejected' then 'rejected' else 'completed' end)::public.process_instance_status,
        result = coalesce(step->>'result','completed'), current_step=v_key, ended_at=now() where id=p_instance;
      insert into public.process_events (tenant_id, company_id, instance_id, event_type, step_key) values (inst.tenant_id, inst.company_id, p_instance, 'process_ended', v_key);
      return;
    elsif v_type in ('approval','task') then
      update public.process_instances set current_step=v_key where id=p_instance;
      insert into public.process_tasks (tenant_id, company_id, instance_id, step_key, name, task_type, assignee_role, status, sla_due)
      values (inst.tenant_id, inst.company_id, p_instance, v_key, coalesce(step->>'name', v_key), v_type, step->>'role', 'pending',
        now() + (coalesce((step->>'sla_hours')::int, 24) || ' hours')::interval);
      insert into public.process_events (tenant_id, company_id, instance_id, event_type, step_key) values (inst.tenant_id, inst.company_id, p_instance, 'task_created', v_key);
      return;
    else -- start / automation / gateway → registra e segue
      insert into public.process_events (tenant_id, company_id, instance_id, event_type, step_key) values (inst.tenant_id, inst.company_id, p_instance, coalesce(v_type,'step'), v_key);
      v_key := step->>'next';
      if v_key is null then
        update public.process_instances set status='completed', result='completed', ended_at=now() where id=p_instance; return;
      end if;
    end if;
  end loop;
end;
$$;

-- Iniciar processo por chave
create or replace function public.start_process(p_company uuid, p_process_key text, p_title text, p_business_key text default null, p_context jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare def record; v_inst uuid; v_first text;
begin
  if not (app.can_access_company(p_company) and app.has_permission('bpm.create', p_company)) then raise exception 'forbidden'; end if;
  select * into def from public.process_definitions where company_id=p_company and process_key=p_process_key and status='published' and deleted_at is null order by version desc limit 1;
  if def.id is null then raise exception 'processo % não encontrado', p_process_key; end if;
  select s->>'key' into v_first from jsonb_array_elements(def.definition->'steps') s where s->>'type'='start' limit 1;
  if v_first is null then select (def.definition->'steps'->0->>'key') into v_first; end if;

  insert into public.process_instances (tenant_id, company_id, definition_id, process_key, business_key, title, current_step, status, context, started_by)
  values (def.tenant_id, p_company, def.id, p_process_key, p_business_key, p_title, v_first, 'running', coalesce(p_context,'{}'::jsonb), auth.uid())
  returning id into v_inst;
  insert into public.process_events (tenant_id, company_id, instance_id, event_type, step_key, actor) values (def.tenant_id, p_company, v_inst, 'process_started', v_first, auth.uid());
  perform app.bpm_advance(v_inst);
  return jsonb_build_object('instance_id', v_inst, 'process', def.name);
end;
$$;
grant execute on function public.start_process(uuid, text, text, text, jsonb) to authenticated;

-- Concluir tarefa (aprovar/rejeitar) → avança a instância
create or replace function public.complete_task(p_task uuid, p_decision text, p_comment text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare tk record; inst record; def jsonb; step jsonb; v_next text;
begin
  select * into tk from public.process_tasks where id=p_task and deleted_at is null;
  if tk.id is null then raise exception 'tarefa não encontrada'; end if;
  if not (app.can_access_company(tk.company_id) and app.has_permission('bpm.approve', tk.company_id)) then raise exception 'forbidden'; end if;
  if tk.status <> 'pending' then raise exception 'tarefa já concluída'; end if;

  update public.process_tasks set status = (case when p_decision='approve' then 'approved' when p_decision='reject' then 'rejected' else 'done' end)::public.process_task_status,
    decided_by=auth.uid(), decided_at=now(), comment=p_comment where id=p_task;

  select * into inst from public.process_instances where id=tk.instance_id;
  select definition into def from public.process_definitions where id=inst.definition_id;
  select s into step from jsonb_array_elements(def->'steps') s where s->>'key'=tk.step_key limit 1;
  v_next := case when p_decision='reject' then coalesce(step->>'reject', step->>'next') else step->>'next' end;

  insert into public.process_events (tenant_id, company_id, instance_id, event_type, step_key, actor, payload)
  values (tk.tenant_id, tk.company_id, tk.instance_id, 'task_'||p_decision, tk.step_key, auth.uid(), jsonb_build_object('comment', p_comment));

  if v_next is null then
    update public.process_instances set status='completed', result='completed', ended_at=now() where id=tk.instance_id;
  else
    update public.process_instances set current_step=v_next where id=tk.instance_id;
    perform app.bpm_advance(tk.instance_id);
  end if;
  select * into inst from public.process_instances where id=tk.instance_id;
  return jsonb_build_object('task', p_task, 'decision', p_decision, 'instance_status', inst.status, 'instance_result', inst.result);
end;
$$;
grant execute on function public.complete_task(uuid, text, text) to authenticated;

-- Business Rules Engine (DMN): avalia tabela de decisão e devolve o output
create or replace function public.evaluate_rule(p_company uuid, p_rule_key text, p_inputs jsonb)
returns jsonb language plpgsql stable security definer set search_path = public, app as $$
declare r record; rule jsonb; cond jsonb; ok boolean; f text; op text; val numeric; sval text; inv numeric;
begin
  if not app.can_access_company(p_company) then return '{}'::jsonb; end if;
  select * into r from public.business_rules where company_id=p_company and rule_key=p_rule_key and enabled and deleted_at is null order by version desc limit 1;
  if r.id is null then return jsonb_build_object('matched', false, 'error', 'regra não encontrada'); end if;
  for rule in select value from jsonb_array_elements(r.rules) loop
    ok := true;
    for cond in select value from jsonb_array_elements(coalesce(rule->'when','[]'::jsonb)) loop
      f := cond->>'field'; op := coalesce(cond->>'op','='); sval := cond->>'value';
      if (p_inputs ? f) then
        begin val := (p_inputs->>f)::numeric; inv := sval::numeric;
          ok := ok and case op when '>' then val>inv when '>=' then val>=inv when '<' then val<inv when '<=' then val<=inv when '=' then val=inv else false end;
        exception when others then ok := ok and ((p_inputs->>f) = sval); end;
      else ok := false; end if;
      exit when not ok;
    end loop;
    if ok then return jsonb_build_object('matched', true, 'output', rule->'then', 'rule', r.name); end if;
  end loop;
  return jsonb_build_object('matched', false, 'output', r.default_output);
end;
$$;
grant execute on function public.evaluate_rule(uuid, text, jsonb) to authenticated;

create or replace function public.bpm_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'definitions', (select count(*) from public.process_definitions where company_id=p_company and status='published' and deleted_at is null),
    'instances_active', (select count(*) from public.process_instances where company_id=p_company and status='running' and deleted_at is null),
    'instances_completed', (select count(*) from public.process_instances where company_id=p_company and status in ('completed','rejected') and deleted_at is null),
    'tasks_pending', (select count(*) from public.process_tasks where company_id=p_company and status='pending' and deleted_at is null),
    'tasks_overdue', (select count(*) from public.process_tasks where company_id=p_company and status='pending' and sla_due < now() and deleted_at is null),
    'rules', (select count(*) from public.business_rules where company_id=p_company and enabled and deleted_at is null),
    'automations', (select count(*) from public.automation_rules where company_id=p_company and enabled and deleted_at is null),
    'avg_cycle_h', (select coalesce(round(avg(extract(epoch from (ended_at-started_at))/3600)::numeric,1),0) from public.process_instances where company_id=p_company and ended_at is not null and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.bpm_dashboard(uuid) to authenticated;

create or replace function public.bpm_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_sla int; v_stuck int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Processos%' and deleted_at is null;

  select count(*) into v_sla from public.process_tasks where company_id=p_company and status='pending' and sla_due < now() and deleted_at is null;
  if v_sla > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'critical', 'Processos: tarefas com SLA vencido', v_sla||' tarefa(s)/aprovação(ões) fora do prazo.', 'Escalar aos responsáveis — processos travados.', 88);
    v_c := v_c + 1;
  end if;
  select count(*) into v_stuck from public.process_instances where company_id=p_company and status='running' and deleted_at is null and updated_at < now() - interval '3 days';
  if v_stuck > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'Processos: instâncias paradas', v_stuck||' processo(s) sem avanço há +3 dias.', 'Investigar gargalo (process mining) e destravar.', 80);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.bpm_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'bpm') ────────────
do $do$
declare t text; specs text[] := array['process_definitions','process_instances','process_tasks','process_events','business_rules','automation_rules','form_definitions'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'bpm.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'bpm.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: processos padrão + regra de alçada ══
do $do$
declare c record;
  proc_compra jsonb := '{"steps":[
    {"key":"start","type":"start","next":"aprov_gerente"},
    {"key":"aprov_gerente","type":"approval","name":"Aprovação do Gerente","role":"gerente","sla_hours":24,"next":"aprov_diretor","reject":"reprovado"},
    {"key":"aprov_diretor","type":"approval","name":"Aprovação do Diretor","role":"diretor","sla_hours":48,"next":"aprovado","reject":"reprovado"},
    {"key":"aprovado","type":"end","result":"approved"},
    {"key":"reprovado","type":"end","result":"rejected"}
  ]}'::jsonb;
  proc_lote jsonb := '{"steps":[
    {"key":"start","type":"start","next":"analise_qa"},
    {"key":"analise_qa","type":"approval","name":"Análise da Qualidade","role":"qualidade","sla_hours":48,"next":"liberacao","reject":"bloqueado"},
    {"key":"liberacao","type":"approval","name":"Liberação do Responsável Técnico","role":"rt","sla_hours":24,"next":"liberado","reject":"bloqueado"},
    {"key":"liberado","type":"end","result":"approved"},
    {"key":"bloqueado","type":"end","result":"rejected"}
  ]}'::jsonb;
  proc_orc jsonb := '{"steps":[
    {"key":"start","type":"start","next":"consentimento"},
    {"key":"consentimento","type":"approval","name":"Termo de Consentimento (paciente)","role":"paciente","sla_hours":72,"next":"aprov_clinica","reject":"cancelado"},
    {"key":"aprov_clinica","type":"approval","name":"Aprovação Clínica","role":"coordenacao","sla_hours":24,"next":"aprovado","reject":"cancelado"},
    {"key":"aprovado","type":"end","result":"approved"},
    {"key":"cancelado","type":"end","result":"rejected"}
  ]}'::jsonb;
  regra jsonb := '[
    {"when":[{"field":"value","op":">","value":"50000"}],"then":{"level":"diretoria","approvals":2}},
    {"when":[{"field":"value","op":">","value":"10000"}],"then":{"level":"gerencia","approvals":1}},
    {"when":[{"field":"value","op":">=","value":"0"}],"then":{"level":"coordenacao","approvals":1}}
  ]'::jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    if not exists (select 1 from public.process_definitions where company_id=c.id and process_key='purchase_approval' and deleted_at is null) then
      insert into public.process_definitions (tenant_id, company_id, process_key, name, category, definition) values
        (c.tenant_id, c.id, 'purchase_approval', 'Aprovação de Compra', 'Suprimentos', proc_compra),
        (c.tenant_id, c.id, 'batch_release', 'Liberação de Lote', 'Qualidade', proc_lote),
        (c.tenant_id, c.id, 'quote_approval', 'Aprovação de Orçamento (Clínica)', 'Comercial', proc_orc);
    end if;
    if not exists (select 1 from public.business_rules where company_id=c.id and rule_key='approval_matrix' and deleted_at is null) then
      insert into public.business_rules (tenant_id, company_id, rule_key, name, description, rules, default_output)
      values (c.tenant_id, c.id, 'approval_matrix', 'Matriz de Alçada de Aprovação', 'Define nível de aprovação por valor', regra, '{"level":"coordenacao","approvals":1}'::jsonb);
    end if;
  end loop;
end $do$;

notify pgrst, 'reload schema';
