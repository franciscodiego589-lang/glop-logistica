-- 20260713000067_grc.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  EGRC — GOVERNANCE, RISK & COMPLIANCE (Vol 35) — fecha a Fase Enterprise+ ║
-- ║  Políticas, MATRIZ DE RISCO (prob×impacto), controles internos, SEGREGA-  ║
-- ║  ÇÃO DE FUNÇÕES (SoD c/ detecção), auditorias, requisitos de compliance   ║
-- ║  (LGPD/ISO/BPF), planos de ação e continuidade. Nível SAP GRC/ServiceNow  ║
-- ║  GRC/RSA Archer/OneTrust. grc_insights auto-descoberto LAIOS.            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

insert into public.permissions (slug, resource, action, description)
select 'grc.' || a, 'grc', a, 'Permissão ' || a || ' em grc'
from unnest(array['read','create','update','delete','approve','audit']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'grc' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── GRC_POLICIES ────────────────────────────────────────────────────────────
create table public.grc_policies (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, category text, framework text, policy_version text default '1.0', status text default 'active', owner text, effective_date date, review_date date, document_id uuid references public.documents(id) on delete set null,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── GRC_RISKS (registro + matriz de risco) ──────────────────────────────────
create table public.grc_risks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, name text not null, category text default 'operational', description text,
  probability integer not null default 3, impact integer not null default 3,
  criticality integer generated always as (probability * impact) stored,
  risk_level text generated always as (case when probability*impact >= 15 then 'critical' when probability*impact >= 8 then 'high' when probability*impact >= 4 then 'medium' else 'low' end) stored,
  treatment text, mitigation_plan text, contingency_plan text, owner text, status text default 'open', review_date date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_grc_risks on public.grc_risks (company_id, risk_level) where deleted_at is null;

-- ── INTERNAL_CONTROLS ───────────────────────────────────────────────────────
create table public.internal_controls (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, control_type text default 'preventive', frequency text default 'monthly', risk_id uuid references public.grc_risks(id) on delete set null,
  owner text, last_test_date date, next_test_date date, effectiveness text default 'not_tested', status text default 'active',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── SOD_RULES (segregação de funções) ───────────────────────────────────────
create table public.sod_rules (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, permission_a text, permission_b text, description text, severity text default 'high', enabled boolean not null default true, last_violations integer default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── GRC_AUDITS + COMPLIANCE_REQUIREMENTS + ACTION_PLANS + CONTINUITY ─────────
create table public.grc_audits (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, audit_type text default 'internal', scope text, framework text, planned_date date, status text default 'planned', findings_count integer default 0, auditor text, conclusion text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.compliance_requirements (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  framework text not null, requirement text not null, description text, status text default 'gap', evidence text, responsible text, due_date date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_compliance_req on public.compliance_requirements (company_id, framework) where deleted_at is null;
create table public.action_plans (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  title text not null, source text, source_ref uuid, owner text, priority text default 'medium', status text default 'open', due_date date, completed_at date, effectiveness_check text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_action_plans on public.action_plans (company_id, status) where deleted_at is null;
create table public.continuity_plans (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, scope text, rto_hours numeric(8,2), rpo_hours numeric(8,2), last_test_date date, status text default 'active', procedures text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Matriz de risco (para o heat map 5×5)
create or replace function public.grc_risk_matrix(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(jsonb_build_object('name', name, 'category', category, 'probability', probability, 'impact', impact, 'criticality', criticality, 'level', risk_level, 'owner', owner, 'status', status) order by criticality desc)
    from public.grc_risks where company_id=p_company and status<>'closed' and deleted_at is null
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.grc_risk_matrix(uuid) to authenticated;

-- Detecção de violações de SoD (usuário com as 2 permissões conflitantes)
create or replace function public.check_sod_violations(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare r record; v_viol int; v_total int := 0; v_rules int := 0;
begin
  if not (app.can_access_company(p_company) and app.has_permission('grc.audit', p_company)) then raise exception 'forbidden'; end if;
  for r in select * from public.sod_rules where company_id=p_company and enabled and deleted_at is null loop
    v_rules := v_rules + 1;
    -- usuários com membership que dá as duas permissões (via role_permissions)
    select count(distinct m.user_id) into v_viol
    from public.memberships m
    where m.company_id=p_company and m.deleted_at is null
      and exists (select 1 from public.role_permissions rp join public.permissions p on p.id=rp.permission_id where rp.role_id=m.role_id and p.slug=r.permission_a)
      and exists (select 1 from public.role_permissions rp join public.permissions p on p.id=rp.permission_id where rp.role_id=m.role_id and p.slug=r.permission_b);
    update public.sod_rules set last_violations=v_viol where id=r.id;
    v_total := v_total + v_viol;
  end loop;
  return jsonb_build_object('rules_checked', v_rules, 'total_violations', v_total);
end;
$$;
grant execute on function public.check_sod_violations(uuid) to authenticated;

-- Nível de conformidade por framework
create or replace function public.assess_compliance(p_company uuid, p_framework text default null)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(jsonb_build_object('framework', framework, 'total', total, 'compliant', compliant, 'level', case when total>0 then round(100.0*compliant/total) else 0 end) order by framework)
    from (
      select framework, count(*) total, count(*) filter (where status='compliant') compliant
      from public.compliance_requirements where company_id=p_company and deleted_at is null and (p_framework is null or framework=p_framework)
      group by framework
    ) s
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.assess_compliance(uuid, text) to authenticated;

create or replace function public.grc_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'risks', (select count(*) from public.grc_risks where company_id=p_company and status<>'closed' and deleted_at is null),
    'risks_critical', (select count(*) from public.grc_risks where company_id=p_company and risk_level='critical' and status<>'closed' and deleted_at is null),
    'risks_high', (select count(*) from public.grc_risks where company_id=p_company and risk_level='high' and status<>'closed' and deleted_at is null),
    'controls', (select count(*) from public.internal_controls where company_id=p_company and deleted_at is null),
    'controls_effective', (select count(*) from public.internal_controls where company_id=p_company and effectiveness='effective' and deleted_at is null),
    'policies', (select count(*) from public.grc_policies where company_id=p_company and deleted_at is null),
    'policies_expired', (select count(*) from public.grc_policies where company_id=p_company and review_date < now()::date and deleted_at is null),
    'audits', (select count(*) from public.grc_audits where company_id=p_company and deleted_at is null),
    'action_plans_open', (select count(*) from public.action_plans where company_id=p_company and status in ('open','in_progress') and deleted_at is null),
    'action_plans_overdue', (select count(*) from public.action_plans where company_id=p_company and status in ('open','in_progress') and due_date < now()::date and deleted_at is null),
    'sod_violations', (select coalesce(sum(last_violations),0) from public.sod_rules where company_id=p_company and deleted_at is null),
    'compliance', (select coalesce(round(avg(lvl)),0) from (select case when count(*)>0 then 100.0*count(*) filter (where status='compliant')/count(*) else 0 end lvl from public.compliance_requirements where company_id=p_company and deleted_at is null group by framework) s)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.grc_dashboard(uuid) to authenticated;

create or replace function public.grc_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_crit int; v_ctrl int; v_pol int; v_sod int; v_ap int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'GRC%' and deleted_at is null;

  select count(*) into v_crit from public.grc_risks where company_id=p_company and risk_level='critical' and status='open' and coalesce(mitigation_plan,'')='' and deleted_at is null;
  if v_crit > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'fraud_risk', 'critical', 'GRC: riscos críticos sem tratamento', v_crit||' risco(s) crítico(s) sem plano de mitigação.', 'Definir tratamento/contingência imediatamente.', 90);
    v_c := v_c + 1;
  end if;
  select coalesce(sum(last_violations),0) into v_sod from public.sod_rules where company_id=p_company and deleted_at is null;
  if v_sod > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'fraud_risk', 'critical', 'GRC: violações de segregação de funções', v_sod||' violação(ões) de SoD detectada(s).', 'Revisar concessões de acesso — risco de fraude/erro.', 88);
    v_c := v_c + 1;
  end if;
  select count(*) into v_ctrl from public.internal_controls where company_id=p_company and next_test_date < now()::date and deleted_at is null;
  if v_ctrl > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'GRC: controles internos vencidos', v_ctrl||' controle(s) com teste em atraso.', 'Executar os testes de controle para manter a efetividade.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_pol from public.grc_policies where company_id=p_company and review_date < now()::date and deleted_at is null;
  if v_pol > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'GRC: políticas a revisar', v_pol||' política(s) com revisão vencida.', 'Revisar e reaprovar as políticas corporativas.', 74);
    v_c := v_c + 1;
  end if;
  select count(*) into v_ap from public.action_plans where company_id=p_company and status in ('open','in_progress') and due_date < now()::date and deleted_at is null;
  if v_ap > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'GRC: planos de ação atrasados', v_ap||' plano(s) de ação vencido(s).', 'Cobrar os responsáveis e reavaliar prazos.', 78);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.grc_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'grc') ────────────
do $do$
declare t text; specs text[] := array['grc_policies','grc_risks','internal_controls','sod_rules','grc_audits','compliance_requirements','action_plans','continuity_plans'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'grc.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'grc.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: políticas + riscos + controles + SoD + compliance + auditorias ══
do $do$
declare c record;
  pols jsonb := '[
    {"n":"Código de Conduta e Ética","cat":"governanca","fw":"Interno"},
    {"n":"Política de Segurança da Informação","cat":"seguranca","fw":"ISO 27001"},
    {"n":"Política de Qualidade","cat":"qualidade","fw":"ISO 9001"},
    {"n":"Política de Privacidade e Proteção de Dados","cat":"privacidade","fw":"LGPD"},
    {"n":"Manual de Boas Práticas de Fabricação","cat":"qualidade","fw":"BPF"}
  ]'::jsonb;
  risks jsonb := '[
    {"n":"Ruptura de fornecedor crítico","cat":"supply","p":4,"i":4,"o":"Compras"},
    {"n":"Ataque cibernético / ransomware","cat":"ti","p":3,"i":5,"o":"TI/Segurança"},
    {"n":"Não conformidade em auditoria BPF","cat":"regulatorio","p":3,"i":5,"o":"Qualidade"},
    {"n":"Inadimplência de grandes clientes","cat":"financeiro","p":3,"i":4,"o":"Financeiro"},
    {"n":"Variação cambial (importação)","cat":"financeiro","p":4,"i":3,"o":"Comex"},
    {"n":"Acidente de trabalho","cat":"operacional","p":2,"i":4,"o":"SESMT"}
  ]'::jsonb;
  ctrls jsonb := '[
    {"n":"Conciliação bancária mensal","t":"detective","f":"monthly"},
    {"n":"Aprovação de compras por alçada","t":"preventive","f":"continuous"},
    {"n":"Backup diário + teste de restauração","t":"preventive","f":"daily"},
    {"n":"Revisão trimestral de acessos (IAM)","t":"detective","f":"quarterly"},
    {"n":"Liberação de lote pela Qualidade","t":"preventive","f":"per_batch"}
  ]'::jsonb;
  sods jsonb := '[
    {"n":"Comprador x Aprovação de pagamento","a":"purchasing.create","b":"finance.approve","d":"Quem compra não pode aprovar o próprio pagamento."},
    {"n":"Cadastro x Aprovação de fornecedor","a":"mdm.create","b":"mdm.approve","d":"Quem cadastra fornecedor não pode aprovar o cadastro."},
    {"n":"Lançamento x Aprovação contábil","a":"accounting.create","b":"accounting.approve","d":"Quem lança não aprova o lançamento."},
    {"n":"Admin x Auditoria de acessos","a":"iam.create","b":"iam.approve","d":"Administrador não audita os próprios acessos."}
  ]'::jsonb;
  reqs jsonb := '[
    {"fw":"LGPD","r":"Registro de bases legais de tratamento","s":"compliant"},
    {"fw":"LGPD","r":"Relatório de Impacto (RIPD)","s":"gap"},
    {"fw":"LGPD","r":"Canal de atendimento ao titular","s":"compliant"},
    {"fw":"ISO 27001","r":"Política de segurança aprovada","s":"compliant"},
    {"fw":"ISO 27001","r":"Gestão de acessos (RBAC/MFA)","s":"compliant"},
    {"fw":"ISO 27001","r":"Plano de continuidade testado","s":"gap"},
    {"fw":"BPF","r":"Registros de higienização","s":"compliant"},
    {"fw":"BPF","r":"Rastreabilidade de lote","s":"compliant"},
    {"fw":"BPF","r":"Treinamentos obrigatórios em dia","s":"gap"}
  ]'::jsonb;
  x jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    for x in select value from jsonb_array_elements(pols) loop
      if not exists (select 1 from public.grc_policies where company_id=c.id and name=(x->>'n') and deleted_at is null) then
        insert into public.grc_policies (tenant_id, company_id, name, category, framework, effective_date, review_date) values (c.tenant_id, c.id, x->>'n', x->>'cat', x->>'fw', now()::date, (now()::date + 365));
      end if;
    end loop;
    for x in select value from jsonb_array_elements(risks) loop
      if not exists (select 1 from public.grc_risks where company_id=c.id and name=(x->>'n') and deleted_at is null) then
        insert into public.grc_risks (tenant_id, company_id, name, category, probability, impact, owner, status) values (c.tenant_id, c.id, x->>'n', x->>'cat', (x->>'p')::int, (x->>'i')::int, x->>'o', 'open');
      end if;
    end loop;
    for x in select value from jsonb_array_elements(ctrls) loop
      if not exists (select 1 from public.internal_controls where company_id=c.id and name=(x->>'n') and deleted_at is null) then
        insert into public.internal_controls (tenant_id, company_id, name, control_type, frequency, effectiveness, next_test_date) values (c.tenant_id, c.id, x->>'n', x->>'t', x->>'f', 'effective', (now()::date + 30));
      end if;
    end loop;
    for x in select value from jsonb_array_elements(sods) loop
      if not exists (select 1 from public.sod_rules where company_id=c.id and name=(x->>'n') and deleted_at is null) then
        insert into public.sod_rules (tenant_id, company_id, name, permission_a, permission_b, description) values (c.tenant_id, c.id, x->>'n', x->>'a', x->>'b', x->>'d');
      end if;
    end loop;
    for x in select value from jsonb_array_elements(reqs) loop
      if not exists (select 1 from public.compliance_requirements where company_id=c.id and framework=(x->>'fw') and requirement=(x->>'r') and deleted_at is null) then
        insert into public.compliance_requirements (tenant_id, company_id, framework, requirement, status) values (c.tenant_id, c.id, x->>'fw', x->>'r', x->>'s');
      end if;
    end loop;
    if not exists (select 1 from public.grc_audits where company_id=c.id and name='Auditoria BPF anual' and deleted_at is null) then
      insert into public.grc_audits (tenant_id, company_id, name, audit_type, framework, planned_date, status) values
        (c.tenant_id, c.id, 'Auditoria BPF anual', 'regulatory', 'BPF', (now()::date + 90), 'planned'),
        (c.tenant_id, c.id, 'Auditoria ISO 27001', 'external', 'ISO 27001', (now()::date + 120), 'planned');
    end if;
    if not exists (select 1 from public.continuity_plans where company_id=c.id and name='Plano de Continuidade de TI' and deleted_at is null) then
      insert into public.continuity_plans (tenant_id, company_id, name, scope, rto_hours, rpo_hours) values (c.tenant_id, c.id, 'Plano de Continuidade de TI', 'ERP e banco de dados', 4, 1);
    end if;
  end loop;
end $do$;

notify pgrst, 'reload schema';
