-- 20260713000062_eaaf.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  EAAF — ENTERPRISE AI & AUTOMATION FRAMEWORK (Vol 30) — o volume FINAL    ║
-- ║  Camada de IA DESACOPLADA, OPCIONAL e MULTI-PROVEDOR: registro de         ║
-- ║  provedores/modelos (OpenAI/Anthropic/Google/Azure/local), biblioteca de  ║
-- ║  prompts, registro de ferramentas, automações, monitoramento de custo +   ║
-- ║  assistente GROUNDED determinístico (ai_ask) que funciona SEM IA externa. ║
-- ║  Zero coupling — o ERP roda 100% sem IA. (SEM ISIS — fora deste projeto.) ║
-- ║  eaaf_insights auto-descoberto pelo cérebro LAIOS.                        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- reusa recurso RBAC 'aios' (camada de IA); garante slugs
insert into public.permissions (slug, resource, action, description)
select 'aios.' || a, 'aios', a, 'Permissão ' || a || ' em aios'
from unnest(array['read','create','update','delete','approve','execute','configure']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'aios' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── AI_PROVIDERS (multi-provedor, plugável) ─────────────────────────────────
create table public.ai_providers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, provider_type text, base_url text, is_default boolean not null default false, enabled boolean not null default false,
  api_key_ref text, config jsonb not null default '{}'::jsonb, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── AI_MODELS ───────────────────────────────────────────────────────────────
create table public.ai_models (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  provider_id uuid references public.ai_providers(id) on delete cascade,
  model_key text not null, name text, model_type text default 'llm', context_window integer, cost_in numeric(12,6) default 0, cost_out numeric(12,6) default 0, enabled boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── AI_PROMPTS (biblioteca de prompts, versionada) ──────────────────────────
create table public.ai_prompts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  prompt_key text not null, name text, category text, template text, variables text[], model_hint text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── AI_TOOLS (ferramentas que os agentes podem chamar) ──────────────────────
create table public.ai_tools (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  tool_key text not null, name text, description text, target_rpc text, module text, input_schema jsonb not null default '{}'::jsonb, requires_approval boolean not null default false, enabled boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── AI_AUTOMATIONS ──────────────────────────────────────────────────────────
create table public.ai_automations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, trigger_kind text default 'schedule', trigger_ref text, agent_key text, action jsonb not null default '{}'::jsonb, enabled boolean not null default true, run_count integer not null default 0, last_run_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── AI_USAGE_LOGS (monitoramento de tokens/custo/latência) ──────────────────
create table public.ai_usage_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  provider text, model text, agent_key text, feature text, tokens_in integer default 0, tokens_out integer default 0, cost numeric(14,6) default 0, latency_ms integer, success boolean default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_ai_usage_logs on public.ai_usage_logs (company_id, created_at);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- ASSISTENTE GROUNDED (determinístico): responde sobre os dados REAIS do ERP
-- SEM depender de provedor de IA externo — princípio "AI optional".
create or replace function public.ai_ask(p_company uuid, p_question text, p_conversation uuid default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare
  v_tenant uuid; v_q text; v_answer text; v_val numeric; v_conv uuid; v_intent text; v_brief jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  v_q := lower(coalesce(p_question,''));

  if v_q ~ 'receita|faturamento|vend(a|eu)' and v_q ~ 'receita|faturamento' then
    v_val := public.compute_kpi(p_company,'revenue_12m'); v_intent := 'revenue_12m';
    v_answer := 'A receita dos últimos 12 meses é R$ '||to_char(v_val,'FM999G999G990D00')||'.';
  elsif v_q ~ 'lucro|resultado|ebitda' then
    v_val := public.compute_kpi(p_company,'net_income_month'); v_intent := 'net_income';
    v_answer := 'O resultado do mês corrente é R$ '||to_char(v_val,'FM999G999G990D00')||'.';
  elsif v_q ~ 'pipeline|oportunidade|funil' then
    v_val := public.compute_kpi(p_company,'pipeline_value'); v_intent := 'pipeline';
    v_answer := 'O pipeline comercial em aberto soma R$ '||to_char(v_val,'FM999G999G990D00')||'.';
  elsif v_q ~ 'estoque' then
    v_val := public.compute_kpi(p_company,'stock_value'); v_intent := 'stock_value';
    v_answer := 'O valor total em estoque é R$ '||to_char(v_val,'FM999G999G990D00')||'.';
  elsif v_q ~ 'funcion|colaborad|headcount|pessoa|equipe' then
    v_val := public.compute_kpi(p_company,'headcount'); v_intent := 'headcount';
    v_answer := 'O headcount atual é de '||v_val::int||' colaborador(es).';
  elsif v_q ~ 'folha|sal[aá]rio|payroll' then
    v_val := public.compute_kpi(p_company,'payroll_cost'); v_intent := 'payroll';
    v_answer := 'A base salarial mensal (folha) é R$ '||to_char(v_val,'FM999G999G990D00')||'.';
  elsif v_q ~ 'pedido' then
    v_val := public.compute_kpi(p_company,'orders_open'); v_intent := 'orders_open';
    v_answer := 'Há '||v_val::int||' pedido(s) em aberto no momento.';
  elsif v_q ~ 'tributo|imposto|fiscal' then
    v_val := public.compute_kpi(p_company,'tax_payable'); v_intent := 'tax_payable';
    v_answer := 'Há R$ '||to_char(v_val,'FM999G999G990D00')||' em tributos apurados a recolher.';
  elsif v_q ~ 'problema|risco|gargalo|preocup|urgente|cr[ií]tico' then
    v_brief := public.laios_executive_brief(p_company); v_intent := 'top_problems';
    v_answer := coalesce((select 'Seus principais pontos de atenção: ' || string_agg(x->>'title', '; ') from jsonb_array_elements(v_brief->'top_problems') x), 'Nenhum problema crítico aberto no momento. Operação saudável.');
  else
    v_intent := 'help';
    v_answer := 'Posso responder sobre: receita, resultado/EBITDA, pipeline comercial, valor em estoque, headcount, folha, pedidos em aberto, tributos a recolher e seus maiores problemas. Como este ERP é AI-opcional, esta resposta vem direto dos dados — sem provedor externo.';
  end if;

  v_conv := p_conversation;
  if v_conv is null then
    insert into public.ai_conversations (tenant_id, company_id, agent_key, channel, title)
    values (v_tenant, p_company, 'central', 'web', left(p_question, 60)) returning id into v_conv;
  end if;
  insert into public.ai_messages (tenant_id, company_id, conversation_id, role, content) values (v_tenant, p_company, v_conv, 'user', p_question);
  insert into public.ai_messages (tenant_id, company_id, conversation_id, role, agent_key, content) values (v_tenant, p_company, v_conv, 'assistant', 'central', v_answer);
  insert into public.ai_usage_logs (tenant_id, company_id, provider, model, feature, tokens_in, tokens_out, cost, latency_ms)
  values (v_tenant, p_company, 'builtin', 'grounded-rules', 'ai_ask', length(p_question)/4, length(v_answer)/4, 0, 5);

  return jsonb_build_object('conversation_id', v_conv, 'intent', v_intent, 'answer', v_answer, 'value', v_val, 'provider', 'builtin (sem custo)');
end;
$$;
grant execute on function public.ai_ask(uuid, text, uuid) to authenticated;

-- Registrar uso de um provedor externo (custo por tokens do modelo)
create or replace function public.register_ai_usage(p_company uuid, p_provider text, p_model text, p_tokens_in int, p_tokens_out int, p_latency int default null, p_agent text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_ci numeric; v_co numeric; v_cost numeric;
begin
  if not (app.can_access_company(p_company) and app.has_permission('aios.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select cost_in, cost_out into v_ci, v_co from public.ai_models where company_id=p_company and model_key=p_model and deleted_at is null limit 1;
  v_cost := round(coalesce(p_tokens_in,0)/1000.0*coalesce(v_ci,0) + coalesce(p_tokens_out,0)/1000.0*coalesce(v_co,0), 6);
  insert into public.ai_usage_logs (tenant_id, company_id, provider, model, agent_key, feature, tokens_in, tokens_out, cost, latency_ms)
  values (v_tenant, p_company, p_provider, p_model, p_agent, 'external', p_tokens_in, p_tokens_out, v_cost, p_latency);
  return jsonb_build_object('cost', v_cost, 'model', p_model);
end;
$$;
grant execute on function public.register_ai_usage(uuid, text, text, int, int, int, text) to authenticated;

-- Definir provedor padrão (multi-provedor)
create or replace function public.set_default_provider(p_provider uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare p record;
begin
  select * into p from public.ai_providers where id=p_provider and deleted_at is null;
  if p.id is null then raise exception 'provedor não encontrado'; end if;
  if not (app.can_access_company(p.company_id) and app.has_permission('aios.update', p.company_id)) then raise exception 'forbidden'; end if;
  update public.ai_providers set is_default=false where company_id=p.company_id;
  update public.ai_providers set is_default=true, enabled=true where id=p_provider;
  return jsonb_build_object('provider', p.name, 'is_default', true);
end;
$$;
grant execute on function public.set_default_provider(uuid) to authenticated;

create or replace function public.eaaf_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'providers', (select count(*) from public.ai_providers where company_id=p_company and deleted_at is null),
    'providers_enabled', (select count(*) from public.ai_providers where company_id=p_company and enabled and deleted_at is null),
    'default_provider', (select name from public.ai_providers where company_id=p_company and is_default and deleted_at is null limit 1),
    'models', (select count(*) from public.ai_models where company_id=p_company and enabled and deleted_at is null),
    'agents', (select count(*) from public.ai_agents where company_id=p_company and deleted_at is null),
    'prompts', (select count(*) from public.ai_prompts where company_id=p_company and deleted_at is null),
    'tools', (select count(*) from public.ai_tools where company_id=p_company and enabled and deleted_at is null),
    'automations', (select count(*) from public.ai_automations where company_id=p_company and enabled and deleted_at is null),
    'calls_30d', (select count(*) from public.ai_usage_logs where company_id=p_company and created_at > now() - interval '30 days'),
    'tokens_30d', (select coalesce(sum(tokens_in+tokens_out),0) from public.ai_usage_logs where company_id=p_company and created_at > now() - interval '30 days'),
    'cost_30d', (select coalesce(round(sum(cost),2),0) from public.ai_usage_logs where company_id=p_company and created_at > now() - interval '30 days'),
    'avg_latency', (select coalesce(round(avg(latency_ms)),0) from public.ai_usage_logs where company_id=p_company and created_at > now() - interval '30 days')
  ) else '{}'::jsonb end;
$$;
grant execute on function public.eaaf_dashboard(uuid) to authenticated;

create or replace function public.eaaf_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_cost numeric; v_prov int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'IA:%' and deleted_at is null;

  select coalesce(sum(cost),0) into v_cost from public.ai_usage_logs where company_id=p_company and created_at > now() - interval '30 days';
  if v_cost > 5000 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, impact_value, confidence)
    values (v_tenant, p_company, 'cost_saving', 'warning', 'IA: custo elevado de tokens', 'Gasto de IA nos últimos 30 dias: R$ '||to_char(v_cost,'FM999G990D00')||'.', 'Rever modelos/prompts, usar modelos menores onde possível.', v_cost, 78);
    v_c := v_c + 1;
  end if;
  select count(*) into v_prov from public.ai_providers where company_id=p_company and is_default and enabled and deleted_at is null;
  if v_prov = 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'opportunity', 'info', 'IA: sem provedor externo ativo', 'O ERP opera no modo AI-opcional (respostas determinísticas dos dados).', 'Habilite um provedor (OpenAI/Anthropic/Google/local) para IA generativa.', 60);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.eaaf_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'aios') ───────────
do $do$
declare t text; specs text[] := array['ai_providers','ai_models','ai_prompts','ai_tools','ai_automations','ai_usage_logs'];
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

-- ══ SEED: provedores + modelos + prompts + ferramentas + automação ══
do $do$
declare c record; v_prov uuid;
  provs jsonb := '[
    {"n":"Built-in (determinístico)","t":"builtin","def":true,"en":true,"note":"Respostas dos dados do ERP, sem custo e sem IA externa"},
    {"n":"Anthropic (Claude)","t":"anthropic","def":false,"en":false,"note":"Requer ANTHROPIC_API_KEY"},
    {"n":"OpenAI (GPT)","t":"openai","def":false,"en":false,"note":"Requer OPENAI_API_KEY"},
    {"n":"Google (Gemini)","t":"google","def":false,"en":false,"note":"Requer GOOGLE_API_KEY"},
    {"n":"Azure OpenAI","t":"azure","def":false,"en":false,"note":"Requer endpoint + key"},
    {"n":"Local (Ollama/vLLM)","t":"local","def":false,"en":false,"note":"Modelos locais on-premise"}
  ]'::jsonb;
  models jsonb := '[
    {"pt":"anthropic","k":"claude-sonnet","n":"Claude Sonnet","ci":0.003,"co":0.015,"cw":200000},
    {"pt":"openai","k":"gpt-4o","n":"GPT-4o","ci":0.005,"co":0.015,"cw":128000},
    {"pt":"openai","k":"text-embedding-3","n":"Embeddings 3","ci":0.0001,"co":0,"cw":8191,"ty":"embedding"},
    {"pt":"google","k":"gemini-1.5","n":"Gemini 1.5","ci":0.0035,"co":0.0105,"cw":1000000},
    {"pt":"local","k":"llama-3","n":"Llama 3 (local)","ci":0,"co":0,"cw":8192}
  ]'::jsonb;
  prompts jsonb := '[
    {"k":"summarize_doc","n":"Resumir documento","cat":"generativa","t":"Resuma o documento a seguir em até 5 tópicos: {{content}}"},
    {"k":"classify_ticket","n":"Classificar chamado","cat":"atendimento","t":"Classifique o chamado em categoria e prioridade: {{ticket}}"},
    {"k":"explain_kpi","n":"Explicar indicador","cat":"analytics","t":"Explique o indicador {{kpi}} = {{value}} e o que fazer."}
  ]'::jsonb;
  tools jsonb := '[
    {"k":"get_kpi","n":"Consultar KPI","rpc":"compute_kpi","mod":"BI"},
    {"k":"executive_brief","n":"Resumo executivo","rpc":"laios_executive_brief","mod":"LAIOS"},
    {"k":"check_atp","n":"Disponibilidade de estoque","rpc":"check_atp","mod":"OMS"},
    {"k":"trial_balance","n":"Balancete","rpc":"trial_balance","mod":"Contabilidade","appr":true}
  ]'::jsonb;
  x jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    for x in select value from jsonb_array_elements(provs) loop
      if not exists (select 1 from public.ai_providers where company_id=c.id and name=(x->>'n') and deleted_at is null) then
        insert into public.ai_providers (tenant_id, company_id, name, provider_type, is_default, enabled, notes) values (c.tenant_id, c.id, x->>'n', x->>'t', (x->>'def')::boolean, (x->>'en')::boolean, x->>'note');
      end if;
    end loop;
    for x in select value from jsonb_array_elements(models) loop
      select id into v_prov from public.ai_providers where company_id=c.id and provider_type=(x->>'pt') and deleted_at is null limit 1;
      if v_prov is not null and not exists (select 1 from public.ai_models where company_id=c.id and model_key=(x->>'k') and deleted_at is null) then
        insert into public.ai_models (tenant_id, company_id, provider_id, model_key, name, model_type, context_window, cost_in, cost_out)
        values (c.tenant_id, c.id, v_prov, x->>'k', x->>'n', coalesce(x->>'ty','llm'), (x->>'cw')::int, (x->>'ci')::numeric, (x->>'co')::numeric);
      end if;
    end loop;
    for x in select value from jsonb_array_elements(prompts) loop
      if not exists (select 1 from public.ai_prompts where company_id=c.id and prompt_key=(x->>'k') and deleted_at is null) then
        insert into public.ai_prompts (tenant_id, company_id, prompt_key, name, category, template) values (c.tenant_id, c.id, x->>'k', x->>'n', x->>'cat', x->>'t');
      end if;
    end loop;
    for x in select value from jsonb_array_elements(tools) loop
      if not exists (select 1 from public.ai_tools where company_id=c.id and tool_key=(x->>'k') and deleted_at is null) then
        insert into public.ai_tools (tenant_id, company_id, tool_key, name, target_rpc, module, requires_approval) values (c.tenant_id, c.id, x->>'k', x->>'n', x->>'rpc', x->>'mod', coalesce((x->>'appr')::boolean,false));
      end if;
    end loop;
    if not exists (select 1 from public.ai_automations where company_id=c.id and name='Varredura LAIOS 24/7' and deleted_at is null) then
      insert into public.ai_automations (tenant_id, company_id, name, trigger_kind, trigger_ref, agent_key, action)
      values (c.tenant_id, c.id, 'Varredura LAIOS 24/7', 'schedule', '*/15 * * * *', 'central', '{"rpc":"app.laios_run"}'::jsonb);
    end if;
  end loop;
end $do$;

notify pgrst, 'reload schema';
