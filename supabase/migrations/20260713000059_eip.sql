-- 20260713000059_eip.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  EIP — ENTERPRISE INTEGRATION PLATFORM (Vol 27) — o barramento corporativo║
-- ║  API Gateway/marketplace, conectores, EVENT BUS c/ fan-out p/ webhooks,   ║
-- ║  fila de mensagens c/ retry + Dead Letter Queue, fluxos ETL, chaves de API║
-- ║  + observabilidade. Nível MuleSoft/SAP Integration Suite/Boomi/Kafka.     ║
-- ║  eip_insights auto-descoberto LAIOS. Entrega real = Edge Function (nota). ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

insert into public.permissions (slug, resource, action, description)
select 'integration.' || a, 'integration', a, 'Permissão ' || a || ' em integration'
from unnest(array['read','create','update','delete','approve','publish']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'integration' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── API_ENDPOINTS (catálogo / marketplace de APIs) ──────────────────────────
create table public.api_endpoints (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, method text default 'GET', path text, protocol text default 'REST', api_version text default 'v1',
  auth_type text default 'jwt', rate_limit integer, status text default 'published', category text, description text, spec jsonb not null default '{}'::jsonb,
  calls_count bigint not null default 0, avg_latency_ms numeric(10,2),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── INTEGRATION_CONNECTORS ──────────────────────────────────────────────────
create table public.integration_connectors (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, connector_type text, direction text default 'bidirectional', status text default 'disconnected',
  config jsonb not null default '{}'::jsonb, last_sync_at timestamptz, error_message text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── WEBHOOKS (assinaturas de eventos) ───────────────────────────────────────
create table public.webhooks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, event_type text not null, target_url text not null, secret text, enabled boolean not null default true,
  max_attempts integer not null default 3, success_count bigint not null default 0, failure_count bigint not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_webhooks_event on public.webhooks (company_id, event_type) where deleted_at is null and enabled;

-- ── EVENT_BUS (fluxo de eventos corporativos) ───────────────────────────────
create table public.event_bus (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  event_type text not null, source_module text, payload jsonb not null default '{}'::jsonb, subscribers_notified integer not null default 0, occurred_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_event_bus_type on public.event_bus (company_id, event_type, occurred_at);

-- ── INTEGRATION_FLOWS (ETL / orquestração) ──────────────────────────────────
create table public.integration_flows (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, flow_type text default 'etl', source_ref text, target_ref text, schedule text, transform jsonb not null default '{}'::jsonb,
  status text default 'active', last_run_at timestamptz, runs_count integer not null default 0, records_processed bigint not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── INTEGRATION_MESSAGES (fila / entrega, com retry + DLQ) ──────────────────
create table public.integration_messages (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  webhook_id uuid references public.webhooks(id) on delete set null, event_id uuid references public.event_bus(id) on delete set null,
  channel text default 'webhook', target text, payload jsonb not null default '{}'::jsonb,
  status text not null default 'queued', attempts integer not null default 0, max_attempts integer not null default 3,
  next_retry_at timestamptz, delivered_at timestamptz, error text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_integration_messages_status on public.integration_messages (company_id, status) where deleted_at is null;

-- ── API_KEYS ────────────────────────────────────────────────────────────────
create table public.api_keys (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, key_prefix text, key_hash text, scopes text[], rate_limit integer, enabled boolean not null default true,
  expires_at date, last_used_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- EVENT BUS: publica um evento e faz FAN-OUT para os webhooks assinantes (fila)
create or replace function public.publish_event(p_company uuid, p_event_type text, p_payload jsonb default '{}'::jsonb, p_source text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_event uuid; w record; v_n int := 0;
begin
  if not (app.can_access_company(p_company) and app.has_permission('integration.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.event_bus (tenant_id, company_id, event_type, source_module, payload)
  values (v_tenant, p_company, p_event_type, p_source, coalesce(p_payload,'{}'::jsonb)) returning id into v_event;
  for w in select * from public.webhooks where company_id=p_company and enabled and deleted_at is null and (event_type=p_event_type or event_type='*') loop
    insert into public.integration_messages (tenant_id, company_id, webhook_id, event_id, channel, target, payload, status, max_attempts)
    values (v_tenant, p_company, w.id, v_event, 'webhook', w.target_url, coalesce(p_payload,'{}'::jsonb), 'queued', w.max_attempts);
    v_n := v_n + 1;
  end loop;
  update public.event_bus set subscribers_notified=v_n where id=v_event;
  return jsonb_build_object('event_id', v_event, 'event_type', p_event_type, 'subscribers_notified', v_n);
end;
$$;
grant execute on function public.publish_event(uuid, text, jsonb, text) to authenticated;

-- Entrega de uma mensagem (sucesso/falha); falha acumula tentativas → DLQ
create or replace function public.deliver_message(p_message uuid, p_success boolean default true, p_error text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare m record; v_status text; v_att int;
begin
  select * into m from public.integration_messages where id=p_message and deleted_at is null;
  if m.id is null then raise exception 'mensagem não encontrada'; end if;
  if not (app.can_access_company(m.company_id) and app.has_permission('integration.update', m.company_id)) then raise exception 'forbidden'; end if;
  v_att := m.attempts + 1;
  if p_success then
    update public.integration_messages set status='delivered', attempts=v_att, delivered_at=now(), error=null where id=p_message;
    update public.webhooks set success_count=success_count+1 where id=m.webhook_id;
    v_status := 'delivered';
  else
    if v_att >= m.max_attempts then v_status := 'dead_letter'; else v_status := 'failed'; end if;
    update public.integration_messages set status=v_status, attempts=v_att, error=p_error, next_retry_at = case when v_status='failed' then now() + (power(2,v_att)||' minutes')::interval else null end where id=p_message;
    update public.webhooks set failure_count=failure_count+1 where id=m.webhook_id;
  end if;
  return jsonb_build_object('message', p_message, 'status', v_status, 'attempts', v_att);
end;
$$;
grant execute on function public.deliver_message(uuid, boolean, text) to authenticated;

-- Processa a fila (simula entrega; em produção a Edge Function faz o POST real)
create or replace function public.process_queue(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare m record; v_ok int := 0;
begin
  if not (app.can_access_company(p_company) and app.has_permission('integration.update', p_company)) then raise exception 'forbidden'; end if;
  for m in select id from public.integration_messages where company_id=p_company and status in ('queued','failed') and (next_retry_at is null or next_retry_at <= now()) and deleted_at is null limit 200 loop
    perform public.deliver_message(m.id, true, null);
    v_ok := v_ok + 1;
  end loop;
  return jsonb_build_object('processed', v_ok);
end;
$$;
grant execute on function public.process_queue(uuid) to authenticated;

-- Executa um fluxo de ETL (registra execução)
create or replace function public.run_integration_flow(p_flow uuid, p_records int default 0)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare f record;
begin
  select * into f from public.integration_flows where id=p_flow and deleted_at is null;
  if f.id is null then raise exception 'fluxo não encontrado'; end if;
  if not (app.can_access_company(f.company_id) and app.has_permission('integration.update', f.company_id)) then raise exception 'forbidden'; end if;
  update public.integration_flows set last_run_at=now(), runs_count=runs_count+1, records_processed=records_processed+coalesce(p_records,0) where id=p_flow;
  return jsonb_build_object('flow', f.name, 'runs', f.runs_count+1);
end;
$$;
grant execute on function public.run_integration_flow(uuid, int) to authenticated;

-- Gera uma chave de API (retorna o segredo UMA vez; guarda só hash+prefixo)
create or replace function public.generate_api_key(p_company uuid, p_name text, p_scopes text[] default array['read'])
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_plain text; v_prefix text;
begin
  if not (app.can_access_company(p_company) and app.has_permission('integration.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  v_plain := 'ak_live_' || replace(gen_random_uuid()::text,'-','') || replace(gen_random_uuid()::text,'-','');
  v_prefix := left(v_plain, 16);
  insert into public.api_keys (tenant_id, company_id, name, key_prefix, key_hash, scopes)
  values (v_tenant, p_company, p_name, v_prefix, md5(v_plain), p_scopes);
  return jsonb_build_object('name', p_name, 'api_key', v_plain, 'prefix', v_prefix, 'note', 'Guarde agora — não será exibida novamente.');
end;
$$;
grant execute on function public.generate_api_key(uuid, text, text[]) to authenticated;

create or replace function public.eip_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'apis', (select count(*) from public.api_endpoints where company_id=p_company and status='published' and deleted_at is null),
    'connectors', (select count(*) from public.integration_connectors where company_id=p_company and deleted_at is null),
    'connectors_connected', (select count(*) from public.integration_connectors where company_id=p_company and status='connected' and deleted_at is null),
    'webhooks', (select count(*) from public.webhooks where company_id=p_company and enabled and deleted_at is null),
    'events_today', (select count(*) from public.event_bus where company_id=p_company and occurred_at::date=now()::date and deleted_at is null),
    'events_total', (select count(*) from public.event_bus where company_id=p_company and deleted_at is null),
    'msg_queued', (select count(*) from public.integration_messages where company_id=p_company and status in ('queued','failed') and deleted_at is null),
    'msg_delivered', (select count(*) from public.integration_messages where company_id=p_company and status='delivered' and deleted_at is null),
    'msg_dlq', (select count(*) from public.integration_messages where company_id=p_company and status='dead_letter' and deleted_at is null),
    'flows', (select count(*) from public.integration_flows where company_id=p_company and deleted_at is null),
    'api_keys', (select count(*) from public.api_keys where company_id=p_company and enabled and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.eip_dashboard(uuid) to authenticated;

create or replace function public.eip_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_dlq int; v_conn int; v_fail int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Integração%' and deleted_at is null;

  select count(*) into v_dlq from public.integration_messages where company_id=p_company and status='dead_letter' and deleted_at is null;
  if v_dlq > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'critical', 'Integração: mensagens na Dead Letter Queue', v_dlq||' mensagem(ns) falharam após todas as tentativas.', 'Investigar o endpoint de destino e reprocessar.', 90);
    v_c := v_c + 1;
  end if;
  select count(*) into v_conn from public.integration_connectors where company_id=p_company and status='error' and deleted_at is null;
  if v_conn > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'supplier_risk', 'warning', 'Integração: conectores com erro', v_conn||' conector(es) fora do ar.', 'Revisar credenciais/endpoint do conector.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_fail from public.integration_messages where company_id=p_company and status='failed' and deleted_at is null and attempts >= 2;
  if v_fail > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'Integração: entregas com repetidas falhas', v_fail||' mensagem(ns) reprocessando sem sucesso.', 'Verificar disponibilidade do destino antes do DLQ.', 78);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.eip_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'integration') ────
do $do$
declare t text; specs text[] := array['api_endpoints','integration_connectors','webhooks','event_bus','integration_flows','integration_messages','api_keys'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'integration.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'integration.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: APIs no marketplace + conectores + webhook + fluxo ══
do $do$
declare c record;
  apis jsonb := '[
    {"n":"Criar Pedido","m":"POST","p":"/api/v1/orders","cat":"Comercial","d":"Cria pedido de venda (OMS)"},
    {"n":"Consultar Estoque (ATP)","m":"GET","p":"/api/v1/stock/atp","cat":"Operacao","d":"Disponibilidade de produto"},
    {"n":"Rastrear Pedido","m":"GET","p":"/api/v1/tracking/{code}","cat":"Logistica","d":"Status de entrega (público)"},
    {"n":"Emitir NF-e","m":"POST","p":"/api/v1/fiscal/nfe","cat":"Fiscal","d":"Emissão de documento fiscal"},
    {"n":"Webhook de Eventos","m":"POST","p":"/api/v1/events","cat":"Plataforma","d":"Assinatura de eventos"}
  ]'::jsonb;
  conns jsonb := '[
    {"n":"Correios","t":"logistics","s":"connected"},
    {"n":"WhatsApp Business API","t":"messaging","s":"connected"},
    {"n":"Mercado Livre","t":"marketplace","s":"disconnected"},
    {"n":"SEFAZ / NF-e","t":"fiscal","s":"connected"},
    {"n":"Open Finance (Banco)","t":"banking","s":"disconnected"},
    {"n":"Power BI","t":"analytics","s":"connected"}
  ]'::jsonb;
  x jsonb; v_wh uuid;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    for x in select value from jsonb_array_elements(apis) loop
      if not exists (select 1 from public.api_endpoints where company_id=c.id and path=(x->>'p') and deleted_at is null) then
        insert into public.api_endpoints (tenant_id, company_id, name, method, path, category, description)
        values (c.tenant_id, c.id, x->>'n', x->>'m', x->>'p', x->>'cat', x->>'d');
      end if;
    end loop;
    for x in select value from jsonb_array_elements(conns) loop
      if not exists (select 1 from public.integration_connectors where company_id=c.id and name=(x->>'n') and deleted_at is null) then
        insert into public.integration_connectors (tenant_id, company_id, name, connector_type, status, last_sync_at)
        values (c.tenant_id, c.id, x->>'n', x->>'t', x->>'s', case when (x->>'s')='connected' then now() else null end);
      end if;
    end loop;
    if not exists (select 1 from public.webhooks where company_id=c.id and name='Notificar ERP externo' and deleted_at is null) then
      insert into public.webhooks (tenant_id, company_id, name, event_type, target_url)
      values (c.tenant_id, c.id, 'Notificar ERP externo', 'order.created', 'https://exemplo.com/webhooks/erp');
    end if;
    if not exists (select 1 from public.integration_flows where company_id=c.id and name='Sincronizar catálogo → Marketplace' and deleted_at is null) then
      insert into public.integration_flows (tenant_id, company_id, name, flow_type, source_ref, target_ref, schedule)
      values (c.tenant_id, c.id, 'Sincronizar catálogo → Marketplace', 'etl', 'products', 'mercadolivre', '0 */6 * * *');
    end if;
  end loop;
end $do$;

notify pgrst, 'reload schema';
