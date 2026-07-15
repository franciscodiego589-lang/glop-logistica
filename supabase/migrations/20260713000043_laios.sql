-- 20260713000043_laios.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  LAIOS — LOGISTICS AI OPERATING SYSTEM (Vol 15) — o CÉREBRO do ERP        ║
-- ║  IA central que orquestra agentes especialistas, roda os motores de       ║
-- ║  detecção de TODOS os módulos (24/7 via pg_cron), consolida em            ║
-- ║  logia_insights, PROPÕE decisões com aprovação humana e mantém memória    ║
-- ║  corporativa (RAG/pgvector) + auditoria imutável de tudo que a IA faz.    ║
-- ║  Nunca executa ação crítica sem aprovação. Nível OpenAI/Amazon/SAP.       ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- recurso RBAC dedicado 'aios'
insert into public.permissions (slug, resource, action, description)
select 'aios.' || a, 'aios', a, 'Permissão ' || a || ' em aios'
from unnest(array['read','create','update','delete','approve','execute']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'aios' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── AI_AGENTS (IA central + agentes especialistas) ──────────────────────────
create table public.ai_agents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  agent_key text not null, name text not null, role_title text, avatar text, language text default 'pt-BR',
  tone text default 'profissional', personality text, specialties text[],
  autonomy_level text not null default 'suggest',   -- observe | suggest | approve | autonomous
  enabled boolean not null default true, engines text[] default '{}',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_ai_agents_key on public.ai_agents (company_id, agent_key) where deleted_at is null;

-- ── AI_DECISIONS (Decision Intelligence Engine — proposta + aprovação) ───────
create table public.ai_decisions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  agent_key text not null default 'central', title text not null, category text,
  motivation text, expected_impact text, alternative_plan text,
  risk_level text default 'medium', estimated_saving numeric(18,2),
  data_used jsonb not null default '{}'::jsonb,
  status text not null default 'proposed',   -- proposed | approved | rejected | executed | expired
  reference_insight_id uuid references public.logia_insights(id) on delete set null,
  decided_by uuid references auth.users(id), decided_at timestamptz, decision_note text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_ai_decisions_status on public.ai_decisions (company_id, status) where deleted_at is null;

-- ── AI_CONVERSATIONS + AI_MESSAGES (auditoria imutável de Q&A / comandos) ────
create table public.ai_conversations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  agent_key text default 'central', channel text default 'web', title text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.ai_messages (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  conversation_id uuid references public.ai_conversations(id) on delete cascade,
  role text not null default 'user', agent_key text, content text, tokens integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_ai_messages_conv on public.ai_messages (conversation_id);

-- ── AI_KNOWLEDGE (Memória Corporativa / RAG com pgvector) ───────────────────
create table public.ai_knowledge (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  title text not null, kind text default 'note',  -- policy|procedure|iso|lgpd|contract|manual|report|note
  content text, source_url text, storage_path text, tags text[],
  embedding vector(1536),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_ai_knowledge_company on public.ai_knowledge (company_id) where deleted_at is null;

-- ── AI_WORKFLOWS (Autonomous Workflow Engine) ───────────────────────────────
create table public.ai_workflows (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, trigger_kind text default 'schedule', definition jsonb not null default '{}'::jsonb,
  enabled boolean not null default true, last_run_at timestamptz, runs_count integer not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── AI_RUNS (log de cada orquestração/execução — observabilidade) ───────────
create table public.ai_runs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  run_type text not null default 'orchestrate', agent_key text default 'central',
  status text not null default 'running', insights_created integer default 0, decisions_created integer default 0,
  summary jsonb not null default '{}'::jsonb, started_at timestamptz not null default now(), finished_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_ai_runs_company on public.ai_runs (company_id, started_at desc);

-- ══ NÚCLEO DO CÉREBRO ══════════════════════════════════════════════════════
-- app.laios_run: roda TODOS os motores de detecção descobertos dinamicamente,
-- consolida em logia_insights e propõe decisões. SEM guard (uso interno:
-- pg_cron / service_role). O schema 'app' não é exposto na API.
create or replace function app.laios_run(p_company uuid)
returns jsonb
language plpgsql security definer set search_path = public, app as $$
declare
  v_tenant uuid; v_run uuid; v_rec record; v_n int; v_total int := 0; v_engines int := 0;
  v_per jsonb := '[]'::jsonb; v_decisions int := 0;
begin
  select tenant_id into v_tenant from public.companies where id = p_company;
  if v_tenant is null then return jsonb_build_object('error','company not found'); end if;

  insert into public.ai_runs (tenant_id, company_id, run_type, agent_key, status)
  values (v_tenant, p_company, 'orchestrate', 'central', 'running') returning id into v_run;

  -- descobre e roda cada motor de insight (1 arg uuid, retorno integer)
  for v_rec in
    select p.proname from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.pronargs = 1 and format_type(p.proargtypes[0], null) = 'uuid'
      and format_type(p.prorettype, null) = 'integer'
      and (p.proname like '%\_insights' or p.proname like 'detect\_%' or p.proname like 'audit\_%'
           or p.proname in ('logia_scan','run_logistics_audit'))
    order by p.proname
  loop
    begin
      execute format('select public.%I($1)', v_rec.proname) into v_n using p_company;
      v_engines := v_engines + 1;
      v_total := v_total + coalesce(v_n, 0);
      v_per := v_per || jsonb_build_object('engine', v_rec.proname, 'insights', coalesce(v_n, 0));
    exception when others then
      v_per := v_per || jsonb_build_object('engine', v_rec.proname, 'error', left(sqlerrm, 140));
    end;
  end loop;

  -- Decision Engine: transforma insights novos (críticos/alerta) em decisões propostas
  for v_rec in
    select i.id, i.kind::text kind, i.severity::text sev, i.title, i.description, i.recommendation, i.impact_value
    from public.logia_insights i
    where i.company_id = p_company and i.status = 'new' and i.deleted_at is null
      and i.severity in ('critical','warning')
      and not exists (select 1 from public.ai_decisions d where d.reference_insight_id = i.id and d.deleted_at is null)
    order by i.severity desc, coalesce(i.impact_value, 0) desc
    limit 50
  loop
    insert into public.ai_decisions (tenant_id, company_id, agent_key, title, category, motivation, expected_impact,
        risk_level, estimated_saving, status, reference_insight_id, data_used)
    values (v_tenant, p_company, 'central', v_rec.title, v_rec.kind,
        coalesce(v_rec.recommendation, v_rec.description), v_rec.description,
        case when v_rec.sev = 'critical' then 'high' else 'medium' end,
        v_rec.impact_value, 'proposed', v_rec.id,
        jsonb_build_object('insight_kind', v_rec.kind, 'severity', v_rec.sev));
    v_decisions := v_decisions + 1;
  end loop;

  update public.ai_runs set status = 'done', finished_at = now(),
    insights_created = v_total, decisions_created = v_decisions,
    summary = jsonb_build_object('engines_ran', v_engines, 'insights', v_total, 'decisions', v_decisions, 'per_engine', v_per)
  where id = v_run;

  return jsonb_build_object('run_id', v_run, 'engines_ran', v_engines, 'insights', v_total,
    'decisions_proposed', v_decisions, 'per_engine', v_per);
end;
$$;

-- wrapper user-facing (guard: membro OU service_role)
create or replace function public.laios_orchestrate(p_company uuid)
returns jsonb
language plpgsql security definer set search_path = public, app as $$
declare v_is_service boolean;
begin
  v_is_service := coalesce((current_setting('request.jwt.claims', true))::jsonb ->> 'role', '') = 'service_role';
  if not (v_is_service or app.can_access_company(p_company)) then raise exception 'forbidden'; end if;
  return app.laios_run(p_company);
end;
$$;
grant execute on function public.laios_orchestrate(uuid) to authenticated, service_role;

-- Dashboard do Centro de Comando
create or replace function public.laios_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'agents_active', (select count(*) from public.ai_agents where company_id=p_company and enabled and deleted_at is null),
    'agents_total', (select count(*) from public.ai_agents where company_id=p_company and deleted_at is null),
    'decisions_open', (select count(*) from public.ai_decisions where company_id=p_company and status='proposed' and deleted_at is null),
    'insights_critical', (select count(*) from public.logia_insights where company_id=p_company and status='new' and severity='critical' and deleted_at is null),
    'insights_warning', (select count(*) from public.logia_insights where company_id=p_company and status='new' and severity='warning' and deleted_at is null),
    'insights_new', (select count(*) from public.logia_insights where company_id=p_company and status='new' and deleted_at is null),
    'runs_today', (select count(*) from public.ai_runs where company_id=p_company and started_at::date = now()::date),
    'knowledge_docs', (select count(*) from public.ai_knowledge where company_id=p_company and deleted_at is null),
    'last_run', (select max(finished_at) from public.ai_runs where company_id=p_company and status='done')
  ) else '{}'::jsonb end;
$$;
grant execute on function public.laios_dashboard(uuid) to authenticated;

-- IA Executiva: "o que aconteceu / meu maior problema / gargalos / oportunidades"
create or replace function public.laios_executive_brief(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'as_of', now(),
    'critical', (select count(*) from public.logia_insights where company_id=p_company and status='new' and severity='critical' and deleted_at is null),
    'warning', (select count(*) from public.logia_insights where company_id=p_company and status='new' and severity='warning' and deleted_at is null),
    'today', (select count(*) from public.logia_insights where company_id=p_company and created_at::date=now()::date and deleted_at is null),
    'open_decisions', (select count(*) from public.ai_decisions where company_id=p_company and status='proposed' and deleted_at is null),
    'top_problems', (select coalesce(jsonb_agg(x), '[]'::jsonb) from (
        select i.title, i.kind::text kind, i.severity::text severity, i.recommendation, i.impact_value
        from public.logia_insights i
        where i.company_id=p_company and i.status='new' and i.deleted_at is null
          and i.kind::text not in ('opportunity','cost_saving')
        order by i.severity desc, coalesce(i.impact_value,0) desc limit 6) x),
    'opportunities', (select coalesce(jsonb_agg(x), '[]'::jsonb) from (
        select i.title, i.kind::text kind, i.recommendation, i.impact_value
        from public.logia_insights i
        where i.company_id=p_company and i.status='new' and i.deleted_at is null
          and i.kind::text in ('opportunity','cost_saving')
        order by coalesce(i.impact_value,0) desc limit 6) x)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.laios_executive_brief(uuid) to authenticated;

-- Aprovar/rejeitar/executar decisão (governança — aprovação humana)
create or replace function public.decide_ai_action(p_decision uuid, p_action text, p_note text default null)
returns jsonb
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_insight uuid; v_status text;
begin
  select company_id, reference_insight_id into v_company, v_insight from public.ai_decisions where id = p_decision and deleted_at is null;
  if v_company is null then raise exception 'decision not found'; end if;
  if not (app.can_access_company(v_company) and app.has_permission('aios.approve', v_company)) then raise exception 'forbidden'; end if;
  v_status := case p_action when 'approve' then 'approved' when 'reject' then 'rejected' when 'execute' then 'executed' else null end;
  if v_status is null then raise exception 'invalid action'; end if;
  update public.ai_decisions set status = v_status, decided_by = auth.uid(), decided_at = now(), decision_note = p_note
  where id = p_decision;
  if v_status in ('approved','executed') and v_insight is not null then
    update public.logia_insights set status = 'acted' where id = v_insight and status = 'new';
  end if;
  return jsonb_build_object('id', p_decision, 'status', v_status);
end;
$$;
grant execute on function public.decide_ai_action(uuid, text, text) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'aios') ───────────
do $do$
declare t text; specs text[] := array['ai_agents','ai_decisions','ai_conversations','ai_messages','ai_knowledge','ai_workflows','ai_runs'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'aios.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'aios.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ── SEED: IA central + agentes especialistas (por empresa existente) ────────
do $do$
declare c record; a record;
  agents jsonb := '[
    {"key":"central","name":"NEXUS","title":"Cérebro Central (LAIOS)","avatar":"✦","autonomy":"approve","engines":[]},
    {"key":"wms","name":"Agente WMS","title":"Diretor de Armazém","avatar":"⌗","autonomy":"suggest","engines":["wms_insights"]},
    {"key":"tms","name":"Agente TMS","title":"Gerente de Transporte","avatar":"🚚","autonomy":"suggest","engines":["tms_insights","transport_insights","detect_transport_issues"]},
    {"key":"yms","name":"Agente YMS","title":"Gerente de Pátio","avatar":"🏗","autonomy":"suggest","engines":["yms_insights"]},
    {"key":"purchasing","name":"Agente Compras","title":"Diretor de Suprimentos","avatar":"🛒","autonomy":"suggest","engines":["ssc_insights"]},
    {"key":"finance","name":"Agente Financeiro","title":"CFO Virtual","avatar":"💰","autonomy":"suggest","engines":["controlling_insights","detect_financial_anomalies"]},
    {"key":"fiscal","name":"Agente Comex/Fiscal","title":"Especialista Aduaneiro","avatar":"🌍","autonomy":"suggest","engines":["gtm_insights"]},
    {"key":"dispatch","name":"Agente Expedição","title":"Gerente de Expedição","avatar":"📦","autonomy":"suggest","engines":["dispatch_insights","detect_dispatch_issues"]},
    {"key":"correios","name":"Agente Correios","title":"Especialista Postal","avatar":"📮","autonomy":"suggest","engines":["correios_insights","audit_postal_freight"]},
    {"key":"returns","name":"Agente Devoluções","title":"Gestor de Logística Reversa","avatar":"↩","autonomy":"suggest","engines":["rma_insights"]},
    {"key":"assets","name":"Agente Ativos","title":"Gestor de Retornáveis","avatar":"♻️","autonomy":"suggest","engines":["rams_insights"]},
    {"key":"network","name":"Agente Rede","title":"Engenheiro de Malha","avatar":"🗺","autonomy":"observe","engines":["lpnd_insights"]},
    {"key":"audit","name":"Agente Auditor","title":"Auditor Contínuo","avatar":"🔎","autonomy":"suggest","engines":["run_logistics_audit","detect_waste_opportunities","clx_insights"]}
  ]'::jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    for a in select value as e from jsonb_array_elements(agents) loop
      if not exists (select 1 from public.ai_agents where company_id=c.id and agent_key=(a.e->>'key') and deleted_at is null) then
        insert into public.ai_agents (tenant_id, company_id, agent_key, name, role_title, avatar, autonomy_level, engines)
        values (c.tenant_id, c.id, a.e->>'key', a.e->>'name', a.e->>'title', a.e->>'avatar', a.e->>'autonomy',
          array(select jsonb_array_elements_text(a.e->'engines')));
      end if;
    end loop;
  end loop;
end $do$;

-- ── AUTONOMIA 24/7 via pg_cron (roda o cérebro a cada 15 min p/ cada empresa) ─
do $do$
declare v_has boolean;
begin
  create extension if not exists pg_cron;
  select exists (select 1 from cron.job where jobname='laios-orchestrate-15min') into v_has;
  if v_has then perform cron.unschedule('laios-orchestrate-15min'); end if;
  perform cron.schedule('laios-orchestrate-15min', '*/15 * * * *',
    $cron$ select app.laios_run(id) from public.companies where active and deleted_at is null $cron$);
exception when others then
  raise notice 'pg_cron indisponível (%). O cérebro roda pelo botão/Edge Function.', sqlerrm;
end $do$;

notify pgrst, 'reload schema';
