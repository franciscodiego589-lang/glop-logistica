-- ============================================================================
-- VOLUME 35 · EGRC COMPLEMENT (migration 068)
-- Fecha o escopo do Master Prompt Vol 35: Governança corporativa (comitês/
-- conselhos/delegação de autoridade), Indicadores de Risco (KRIs), Calendário
-- unificado de Obrigações, Evidências ↔ ECM/GED, e integração das Não
-- Conformidades/CAPA já existentes no QMS (Vol 08). Reusa o recurso RBAC 'grc'.
-- Padrão: text+check (evita cast de enum), grant por-tabela, gerado só imutável.
-- ============================================================================

-- ── 1) GOVERNANÇA CORPORATIVA ───────────────────────────────────────────────
create table if not exists public.governance_bodies (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text,
  name text not null,
  body_type text not null default 'committee' check (body_type in ('board','committee','council','forum')),
  purpose text,
  charter text,
  chair_id uuid references auth.users(id),
  members jsonb not null default '[]'::jsonb,
  meeting_frequency text,
  parent_body_id uuid references public.governance_bodies(id) on delete set null,
  status text not null default 'active' check (status in ('active','inactive','dissolved')),
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create table if not exists public.authority_delegations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text,
  title text not null,
  delegator_id uuid references auth.users(id),
  delegate_id uuid references auth.users(id),
  scope text,
  authority_type text not null default 'approve_generic',
  limit_amount numeric(18,2),
  valid_from date not null default now()::date,
  valid_to date,
  status text not null default 'active' check (status in ('active','revoked','expired')),
  reason text,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 2) INDICADORES-CHAVE DE RISCO (KRIs) ────────────────────────────────────
create table if not exists public.key_risk_indicators (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text,
  name text not null,
  risk_id uuid references public.grc_risks(id) on delete set null,
  metric text,
  unit text,
  direction text not null default 'up_bad' check (direction in ('up_bad','down_bad')),
  threshold_amber numeric(18,4),
  threshold_red numeric(18,4),
  current_value numeric(18,4),
  target_value numeric(18,4),
  frequency text,
  owner_id uuid references auth.users(id),
  last_measured_at timestamptz,
  status text generated always as (
    case
      when current_value is null then 'unknown'
      when direction = 'down_bad' then
        case when threshold_red is not null and current_value <= threshold_red then 'red'
             when threshold_amber is not null and current_value <= threshold_amber then 'amber'
             else 'green' end
      else
        case when threshold_red is not null and current_value >= threshold_red then 'red'
             when threshold_amber is not null and current_value >= threshold_amber then 'amber'
             else 'green' end
    end
  ) stored,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 3) CALENDÁRIO UNIFICADO DE OBRIGAÇÕES ───────────────────────────────────
create table if not exists public.compliance_obligations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text,
  title text not null,
  obligation_kind text not null default 'other' check (obligation_kind in ('audit','control_test','policy_review','training','renewal','certification','regulatory','other')),
  framework text,
  responsible_id uuid references auth.users(id),
  due_date date not null,
  recurrence text not null default 'once' check (recurrence in ('once','monthly','quarterly','semiannual','annual')),
  status text not null default 'pending' check (status in ('pending','done','overdue','waived')),
  last_done_date date,
  next_due_date date,
  source_type text,
  source_id uuid,
  evidence_required boolean not null default false,
  notes text,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 4) EVIDÊNCIAS ↔ ECM/GED ─────────────────────────────────────────────────
create table if not exists public.grc_evidence (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  entity_type text not null check (entity_type in ('risk','control','audit','obligation','nonconformity','action_plan','policy','sod','continuity')),
  entity_id uuid not null,
  document_id uuid references public.documents(id) on delete set null,
  evidence_type text default 'document',
  title text,
  external_url text,
  collected_by uuid references auth.users(id),
  collected_at timestamptz not null default now(),
  notes text,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- índices auxiliares
create index if not exists idx_kri_risk on public.key_risk_indicators (risk_id);
create index if not exists idx_oblig_due on public.compliance_obligations (company_id, due_date);
create index if not exists idx_oblig_source on public.compliance_obligations (source_type, source_id);
create index if not exists idx_evidence_entity on public.grc_evidence (entity_type, entity_id);
create index if not exists idx_evidence_doc on public.grc_evidence (document_id);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'grc') ────────────
do $do$
declare t text; specs text[] := array['governance_bodies','authority_delegations','key_risk_indicators','compliance_obligations','grc_evidence'];
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

-- ── RPCs ────────────────────────────────────────────────────────────────────
create or replace function public.record_kri(p_company uuid, p_kri uuid, p_value numeric)
returns public.key_risk_indicators language plpgsql security definer set search_path = public, app as $$
declare r public.key_risk_indicators;
begin
  if not (app.can_access_company(p_company) and app.has_permission('grc.update', p_company)) then raise exception 'forbidden'; end if;
  update public.key_risk_indicators set current_value = p_value, last_measured_at = now()
    where id = p_kri and company_id = p_company and deleted_at is null returning * into r;
  if r.id is null then raise exception 'KRI não encontrado'; end if;
  return r;
end; $$;
grant execute on function public.record_kri(uuid,uuid,numeric) to authenticated;

-- gera/atualiza o calendário de obrigações a partir de controles, políticas e auditorias
create or replace function public.generate_grc_obligations(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_n int := 0; v_row int := 0;
begin
  if not (app.can_access_company(p_company) and app.has_permission('grc.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id = p_company;

  insert into public.compliance_obligations (tenant_id, company_id, title, obligation_kind, framework, due_date, recurrence, status, source_type, source_id, evidence_required)
  select v_tenant, p_company, 'Teste de controle: '||c.name, 'control_test', null, c.next_test_date,
         case c.frequency when 'monthly' then 'monthly' when 'quarterly' then 'quarterly' when 'annual' then 'annual' else 'quarterly' end,
         case when c.next_test_date < now()::date then 'overdue' else 'pending' end, 'internal_control', c.id, true
  from public.internal_controls c
  where c.company_id = p_company and c.next_test_date is not null and c.deleted_at is null
    and not exists (select 1 from public.compliance_obligations o where o.source_type='internal_control' and o.source_id=c.id and o.deleted_at is null);
  get diagnostics v_n = row_count;

  insert into public.compliance_obligations (tenant_id, company_id, title, obligation_kind, framework, due_date, recurrence, status, source_type, source_id, evidence_required)
  select v_tenant, p_company, 'Revisão de política: '||p.name, 'policy_review', p.framework, p.review_date, 'annual',
         case when p.review_date < now()::date then 'overdue' else 'pending' end, 'grc_policy', p.id, false
  from public.grc_policies p
  where p.company_id = p_company and p.review_date is not null and p.deleted_at is null
    and not exists (select 1 from public.compliance_obligations o where o.source_type='grc_policy' and o.source_id=p.id and o.deleted_at is null);
  get diagnostics v_row = row_count; v_n := v_n + v_row;

  insert into public.compliance_obligations (tenant_id, company_id, title, obligation_kind, framework, due_date, recurrence, status, source_type, source_id, evidence_required)
  select v_tenant, p_company, 'Auditoria: '||a.name, 'audit', a.framework, a.planned_date, 'once',
         case when a.planned_date < now()::date then 'overdue' else 'pending' end, 'grc_audit', a.id, true
  from public.grc_audits a
  where a.company_id = p_company and a.planned_date is not null and a.deleted_at is null
    and not exists (select 1 from public.compliance_obligations o where o.source_type='grc_audit' and o.source_id=a.id and o.deleted_at is null);
  get diagnostics v_row = row_count; v_n := v_n + v_row;
  return v_n;
end; $$;
grant execute on function public.generate_grc_obligations(uuid) to authenticated;

create or replace function public.complete_obligation(p_company uuid, p_obligation uuid)
returns public.compliance_obligations language plpgsql security definer set search_path = public, app as $$
declare r public.compliance_obligations; v_next date;
begin
  if not (app.can_access_company(p_company) and app.has_permission('grc.update', p_company)) then raise exception 'forbidden'; end if;
  select * into r from public.compliance_obligations where id=p_obligation and company_id=p_company and deleted_at is null;
  if r.id is null then raise exception 'Obrigação não encontrada'; end if;
  v_next := case r.recurrence
    when 'monthly' then now()::date + interval '1 month'
    when 'quarterly' then now()::date + interval '3 months'
    when 'semiannual' then now()::date + interval '6 months'
    when 'annual' then now()::date + interval '1 year'
    else null end;
  if v_next is not null then
    update public.compliance_obligations set last_done_date = now()::date, next_due_date = v_next,
      due_date = v_next, status = 'pending' where id = p_obligation returning * into r;
  else
    update public.compliance_obligations set last_done_date = now()::date, status = 'done' where id = p_obligation returning * into r;
  end if;
  return r;
end; $$;
grant execute on function public.complete_obligation(uuid,uuid) to authenticated;

create or replace function public.attach_evidence(p_company uuid, p_entity_type text, p_entity_id uuid, p_document_id uuid, p_external_url text, p_title text, p_notes text)
returns public.grc_evidence language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.grc_evidence;
begin
  if not (app.can_access_company(p_company) and app.has_permission('grc.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id = p_company;
  insert into public.grc_evidence (tenant_id, company_id, entity_type, entity_id, document_id, external_url, title, notes,
    evidence_type, collected_by, collected_at)
  values (v_tenant, p_company, p_entity_type, p_entity_id, p_document_id, p_external_url, p_title, p_notes,
    case when p_document_id is not null then 'document' when p_external_url is not null then 'link' else 'note' end,
    auth.uid(), now()) returning * into r;
  return r;
end; $$;
grant execute on function public.attach_evidence(uuid,text,uuid,uuid,text,text,text) to authenticated;

create or replace function public.grc_kri_panel(p_company uuid)
returns table(id uuid, name text, metric text, unit text, direction text, current_value numeric, target_value numeric,
              threshold_amber numeric, threshold_red numeric, status text, risk_name text, last_measured_at timestamptz)
language sql security definer set search_path = public, app stable as $$
  select k.id, k.name, k.metric, k.unit, k.direction, k.current_value, k.target_value, k.threshold_amber, k.threshold_red,
         k.status, r.name, k.last_measured_at
  from public.key_risk_indicators k
  left join public.grc_risks r on r.id = k.risk_id
  where k.company_id = p_company and k.deleted_at is null and app.can_access_company(p_company)
  order by case k.status when 'red' then 0 when 'amber' then 1 when 'unknown' then 2 else 3 end, k.name;
$$;
grant execute on function public.grc_kri_panel(uuid) to authenticated;

create or replace function public.grc_obligations_calendar(p_company uuid, p_days integer default 120)
returns table(id uuid, title text, obligation_kind text, framework text, due_date date, recurrence text, status text,
              evidence_required boolean, days_left integer, has_evidence boolean)
language sql security definer set search_path = public, app stable as $$
  select o.id, o.title, o.obligation_kind, o.framework, o.due_date, o.recurrence,
         case when o.status = 'pending' and o.due_date < now()::date then 'overdue' else o.status end,
         o.evidence_required, (o.due_date - now()::date)::int,
         exists (select 1 from public.grc_evidence e where e.entity_type='obligation' and e.entity_id=o.id and e.deleted_at is null)
  from public.compliance_obligations o
  where o.company_id = p_company and o.deleted_at is null and app.can_access_company(p_company)
    and o.due_date <= now()::date + (p_days || ' days')::interval
  order by o.due_date;
$$;
grant execute on function public.grc_obligations_calendar(uuid,integer) to authenticated;

create or replace function public.governance_overview(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'bodies', (select count(*) from public.governance_bodies b where b.company_id=p_company and b.status='active' and b.deleted_at is null),
    'delegations_active', (select count(*) from public.authority_delegations d where d.company_id=p_company and d.status='active' and (d.valid_to is null or d.valid_to >= now()::date) and d.deleted_at is null),
    'delegations_expired', (select count(*) from public.authority_delegations d where d.company_id=p_company and d.status='active' and d.valid_to is not null and d.valid_to < now()::date and d.deleted_at is null),
    'kri_red', (select count(*) from public.key_risk_indicators k where k.company_id=p_company and k.status='red' and k.deleted_at is null),
    'kri_amber', (select count(*) from public.key_risk_indicators k where k.company_id=p_company and k.status='amber' and k.deleted_at is null),
    'kri_total', (select count(*) from public.key_risk_indicators k where k.company_id=p_company and k.deleted_at is null),
    'obligations_pending', (select count(*) from public.compliance_obligations o where o.company_id=p_company and o.status='pending' and o.deleted_at is null),
    'obligations_overdue', (select count(*) from public.compliance_obligations o where o.company_id=p_company and o.status='pending' and o.due_date < now()::date and o.deleted_at is null),
    'nonconformities_open', (select count(*) from public.nonconformities n where n.company_id=p_company and n.status::text not in ('closed','canceled','verified') and n.deleted_at is null),
    'capas_open', (select count(*) from public.capas c where c.company_id=p_company and c.status::text not in ('closed','completed','verified','canceled') and c.deleted_at is null),
    'evidence_count', (select count(*) from public.grc_evidence e where e.company_id=p_company and e.deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.governance_overview(uuid) to authenticated;

-- motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.egrc_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_kri int; v_obl int; v_del int; v_nc int; v_ev int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'EGRC%' and deleted_at is null;

  select count(*) into v_kri from public.key_risk_indicators where company_id=p_company and status='red' and deleted_at is null;
  if v_kri > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'fraud_risk', 'critical', 'EGRC: KRI em nível crítico', v_kri||' indicador(es) de risco no vermelho.', 'Acionar o plano de contingência do risco associado.', 86);
    v_c := v_c + 1;
  end if;
  select count(*) into v_obl from public.compliance_obligations where company_id=p_company and status='pending' and due_date < now()::date and deleted_at is null;
  if v_obl > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'EGRC: obrigações vencidas', v_obl||' obrigação(ões) de compliance em atraso.', 'Executar/renovar antes que vire não conformidade.', 80);
    v_c := v_c + 1;
  end if;
  select count(*) into v_del from public.authority_delegations where company_id=p_company and status='active' and valid_to is not null and valid_to < now()::date and deleted_at is null;
  if v_del > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'EGRC: delegações de autoridade expiradas', v_del||' delegação(ões) ativa(s) com validade vencida.', 'Revogar ou renovar a delegação de alçada.', 78);
    v_c := v_c + 1;
  end if;
  select count(*) into v_nc from public.nonconformities where company_id=p_company and status::text not in ('closed','canceled','verified') and created_at < now() - interval '30 days' and deleted_at is null;
  if v_nc > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'EGRC: não conformidades antigas em aberto', v_nc||' NC(s) aberta(s) há mais de 30 dias.', 'Tratar via CAPA e verificar eficácia.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_ev from public.compliance_obligations o where o.company_id=p_company and o.evidence_required and o.deleted_at is null
    and not exists (select 1 from public.grc_evidence e where e.entity_type='obligation' and e.entity_id=o.id and e.deleted_at is null)
    and o.due_date < now()::date + interval '15 days';
  if v_ev > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'EGRC: obrigações sem evidência', v_ev||' obrigação(ões) exigem evidência e ainda não têm.', 'Anexar comprovante/documento no GED.', 70);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.egrc_insights(uuid) to authenticated;

-- ── SEED (empresa Matriz Logística) ─────────────────────────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid; v_su uuid := '7a4f5e8c-1a64-49a9-8a2a-a56a78cde60c';
begin
  select tenant_id into v_tenant from public.companies where id = v_company;
  if v_tenant is null then return; end if;

  if not exists (select 1 from public.governance_bodies where company_id=v_company and deleted_at is null) then
    insert into public.governance_bodies (tenant_id, company_id, code, name, body_type, purpose, meeting_frequency, chair_id, members) values
      (v_tenant, v_company, 'GOV-001', 'Conselho de Administração', 'board', 'Governança estratégica e supervisão da diretoria.', 'quarterly', v_su, '[{"role":"Presidente"},{"role":"Conselheiro"},{"role":"Conselheiro Independente"}]'::jsonb),
      (v_tenant, v_company, 'GOV-002', 'Comitê de Auditoria', 'committee', 'Supervisão de controles internos, auditoria e integridade dos relatórios.', 'monthly', v_su, '[{"role":"Coordenador"},{"role":"Membro"}]'::jsonb),
      (v_tenant, v_company, 'GOV-003', 'Comitê de Riscos & Compliance', 'committee', 'Monitorar a matriz de risco, KRIs e o programa de conformidade.', 'monthly', v_su, '[{"role":"CRO"},{"role":"CCO"},{"role":"Jurídico"}]'::jsonb);

    insert into public.authority_delegations (tenant_id, company_id, code, title, delegator_id, delegate_id, scope, authority_type, limit_amount, valid_to, status) values
      (v_tenant, v_company, 'DEL-001', 'Aprovação de pagamentos até R$ 50.000', v_su, v_su, 'Financeiro / Tesouraria', 'approve_payment', 50000, (now()::date + interval '1 year')::date, 'active'),
      (v_tenant, v_company, 'DEL-002', 'Assinatura de contratos até R$ 100.000', v_su, v_su, 'Jurídico / Suprimentos', 'sign_contract', 100000, (now()::date - interval '10 days')::date, 'active'); -- vencida de propósito (dispara insight)

    insert into public.key_risk_indicators (tenant_id, company_id, code, name, risk_id, metric, unit, direction, threshold_amber, threshold_red, current_value, target_value, frequency, owner_id, last_measured_at) values
      (v_tenant, v_company, 'KRI-001', 'Índice de ruptura de estoque', (select id from public.grc_risks where company_id=v_company and deleted_at is null order by criticality desc limit 1), 'SKUs em ruptura / total', '%', 'up_bad', 5, 10, 12.5, 2, 'weekly', v_su, now()),
      (v_tenant, v_company, 'KRI-002', 'Reclamações de clientes', null, 'Reclamações / mês', 'un', 'up_bad', 8, 15, 6, 3, 'monthly', v_su, now()),
      (v_tenant, v_company, 'KRI-003', 'Desvios de qualidade (BPF)', null, 'Desvios / lote', 'un', 'up_bad', 2, 4, 3, 0, 'monthly', v_su, now()),
      (v_tenant, v_company, 'KRI-004', 'Tentativas de acesso não autorizado', null, 'Eventos / mês', 'un', 'up_bad', 10, 25, 4, 0, 'monthly', v_su, now());

    insert into public.compliance_obligations (tenant_id, company_id, code, title, obligation_kind, framework, due_date, recurrence, status, evidence_required, responsible_id) values
      (v_tenant, v_company, 'OBG-001', 'Treinamento anual de BPF (Boas Práticas de Fabricação)', 'training', 'BPF', (now()::date + interval '20 days')::date, 'annual', 'pending', true, v_su),
      (v_tenant, v_company, 'OBG-002', 'Renovação de certificação ISO 9001', 'certification', 'ISO 9001', (now()::date + interval '75 days')::date, 'annual', 'pending', true, v_su),
      (v_tenant, v_company, 'OBG-003', 'Relatório de tratamento de dados (LGPD)', 'regulatory', 'LGPD', (now()::date - interval '5 days')::date, 'semiannual', 'pending', false, v_su); -- vencida
  end if;
end $seed$;

notify pgrst, 'reload schema';
