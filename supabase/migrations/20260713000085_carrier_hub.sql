-- ============================================================================
-- CARRIER INTEGRATION HUB (migration 085)
-- Hub de integração por API com Correios e QUALQUER transportadora/plataforma.
-- Config-driven: conector (URL+auth), credenciais, operações mapeadas (cotação/
-- etiqueta/rastreio/coleta/cancelamento), logs de chamada e webhooks de retorno.
-- Complementa a EIP genérica (integration_connectors) com camada de carrier.
-- A execução HTTP real fica numa Edge Function 'carrier-gateway' (a fazer deploy
-- com as credenciais); as RPCs resolvem a config, logam e simulam cotação p/ demo.
-- Recurso RBAC 'integration'. Escopo 100% logística. Padrão: colunas-padrão, text+check.
-- ============================================================================

-- ── 1) CONECTORES de transportadora/plataforma ──────────────────────────────
create table if not exists public.carrier_connectors (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  name text,
  provider text not null default 'generic_rest' check (provider in ('correios','jadlog','braspress','total_express','loggi','mercado_envios','shopee_xpress','azul_cargo','generic_rest','generic_soap','custom')),
  carrier_id uuid references public.carriers(id) on delete set null,
  base_url text,
  auth_type text not null default 'bearer_token' check (auth_type in ('none','apikey','bearer_token','basic','oauth2','user_pass','contract_card')),
  environment text not null default 'production' check (environment in ('production','sandbox')),
  timeout_ms integer not null default 15000,
  rate_limit_per_min integer,
  status text not null default 'inactive' check (status in ('active','inactive','error')),
  last_ok_at timestamptz, last_error text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  constraint carrier_connectors_uk unique (company_id, code)
);

-- ── 2) CREDENCIAIS do conector (cofre) ───────────────────────────────────────
create table if not exists public.connector_credentials (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  connector_id uuid not null references public.carrier_connectors(id) on delete cascade,
  key_name text not null,
  key_value text,
  is_secret boolean not null default true,
  environment text not null default 'production' check (environment in ('production','sandbox')),
  valid_to date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 3) OPERAÇÕES mapeadas ────────────────────────────────────────────────────
create table if not exists public.connector_operations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  connector_id uuid not null references public.carrier_connectors(id) on delete cascade,
  operation text not null default 'quote' check (operation in ('quote','ship','label','track','cancel','pickup','status','manifest')),
  http_method text not null default 'POST' check (http_method in ('GET','POST','PUT','PATCH','DELETE')),
  path text,
  request_template jsonb not null default '{}'::jsonb,
  response_mapping jsonb not null default '{}'::jsonb,
  enabled boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 4) LOGS de chamada ───────────────────────────────────────────────────────
create table if not exists public.connector_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  connector_id uuid references public.carrier_connectors(id) on delete cascade,
  operation text,
  reference text,
  http_status integer,
  latency_ms integer,
  success boolean not null default false,
  error text,
  requested_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 5) WEBHOOKS de retorno (tracking assíncrono) ─────────────────────────────
create table if not exists public.connector_webhooks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  connector_id uuid not null references public.carrier_connectors(id) on delete cascade,
  event_type text,
  endpoint_token text,
  last_received_at timestamptz,
  status text not null default 'active' check (status in ('active','inactive')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_conn_cred_conn on public.connector_credentials (connector_id);
create index if not exists idx_conn_op_conn on public.connector_operations (connector_id);
create index if not exists idx_conn_log_conn on public.connector_logs (connector_id, requested_at);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'integration') ────
do $do$
declare t text; specs text[] := array['carrier_connectors','connector_credentials','connector_operations','connector_logs','connector_webhooks'];
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

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- Registra/atualiza um conector de transportadora
create or replace function public.register_carrier_connector(p_company uuid, p_code text, p_name text, p_provider text, p_base_url text, p_auth_type text, p_environment text default 'production')
returns public.carrier_connectors language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.carrier_connectors;
begin
  if not (app.can_access_company(p_company) and app.has_permission('integration.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.carrier_connectors (tenant_id, company_id, code, name, provider, base_url, auth_type, environment, status)
    values (v_tenant, p_company, p_code, p_name, coalesce(p_provider,'generic_rest'), p_base_url, coalesce(p_auth_type,'bearer_token'), coalesce(p_environment,'production'), 'inactive')
  on conflict (company_id, code) do update set name=excluded.name, provider=excluded.provider, base_url=excluded.base_url,
    auth_type=excluded.auth_type, environment=excluded.environment, updated_at=now()
  returning * into r;
  return r;
end; $$;
grant execute on function public.register_carrier_connector(uuid,text,text,text,text,text,text) to authenticated;

-- Grava uma credencial do conector
create or replace function public.set_connector_credential(p_company uuid, p_connector uuid, p_key text, p_value text, p_secret boolean default true)
returns public.connector_credentials language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.connector_credentials;
begin
  if not (app.can_access_company(p_company) and app.has_permission('integration.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.connector_credentials set key_value=p_value, is_secret=coalesce(p_secret,true), updated_at=now()
    where connector_id=p_connector and key_name=p_key and company_id=p_company and deleted_at is null returning * into r;
  if r.id is null then
    insert into public.connector_credentials (tenant_id, company_id, connector_id, key_name, key_value, is_secret)
      values (v_tenant, p_company, p_connector, p_key, p_value, coalesce(p_secret,true)) returning * into r;
  end if;
  return r;
end; $$;
grant execute on function public.set_connector_credential(uuid,uuid,text,text,boolean) to authenticated;

-- Testa a prontidão do conector (config completa) sem expor segredos
create or replace function public.test_connector(p_company uuid, p_connector uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v jsonb; v_url text; v_auth text; v_creds int; v_ops int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('integration.update', p_company)) then raise exception 'forbidden'; end if;
  select base_url, auth_type into v_url, v_auth from public.carrier_connectors where id=p_connector and company_id=p_company;
  select count(*) into v_creds from public.connector_credentials where connector_id=p_connector and coalesce(key_value,'')<>'' and deleted_at is null;
  select count(*) into v_ops from public.connector_operations where connector_id=p_connector and enabled and deleted_at is null;
  v := jsonb_build_object('has_url', v_url is not null and v_url<>'', 'auth_type', v_auth,
    'credentials', v_creds, 'operations', v_ops,
    'ready', (v_url is not null and v_url<>'' and (v_auth='none' or v_creds>0) and v_ops>0));
  update public.carrier_connectors set status = case when (v->>'ready')::boolean then 'active' else 'inactive' end,
    last_ok_at = case when (v->>'ready')::boolean then now() else last_ok_at end where id=p_connector and company_id=p_company;
  return v;
end; $$;
grant execute on function public.test_connector(uuid,uuid) to authenticated;

-- Cotação determinística (fallback/demo enquanto a Edge Function real não roda):
-- estima frete por transportadora a partir de peso, valor e zona.
create or replace function public.connector_quote(p_company uuid, p_connector uuid, p_weight_kg numeric, p_declared_value numeric default 0, p_zone text default 'capital')
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_prov text; v_base numeric; v_perkg numeric; v_adv numeric; v_days int; v_zone_mult numeric; v_freight numeric;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id, provider into v_tenant, v_prov from public.carrier_connectors where id=p_connector and company_id=p_company;
  -- parâmetros por provedor (aproximados; a Edge Function real substitui pela cotação oficial)
  v_base := case v_prov when 'correios' then 18 when 'jadlog' then 15 when 'braspress' then 22 when 'total_express' then 20 when 'loggi' then 12 when 'mercado_envios' then 14 else 16 end;
  v_perkg := case v_prov when 'correios' then 2.4 when 'jadlog' then 1.9 when 'braspress' then 2.1 when 'loggi' then 2.6 else 2.0 end;
  v_adv := 0.008; -- 0,8% advalorem sobre valor declarado
  v_days := case v_prov when 'correios' then 5 when 'jadlog' then 4 when 'braspress' then 3 when 'loggi' then 2 when 'total_express' then 4 else 4 end;
  v_zone_mult := case p_zone when 'capital' then 1.0 when 'interior' then 1.25 when 'outro_estado' then 1.6 when 'remoto' then 2.1 else 1.0 end;
  v_freight := round(((v_base + coalesce(p_weight_kg,0)*v_perkg) * v_zone_mult + coalesce(p_declared_value,0)*v_adv)::numeric, 2);
  -- registra a chamada (simulada) no log
  insert into public.connector_logs (tenant_id, company_id, connector_id, operation, reference, http_status, latency_ms, success)
    values (v_tenant, p_company, p_connector, 'quote', 'sim', 200, 8, true);
  return jsonb_build_object('provider', v_prov, 'freight', v_freight, 'eta_days', round(v_days*v_zone_mult), 'zone', p_zone, 'simulated', true);
end; $$;
grant execute on function public.connector_quote(uuid,uuid,numeric,numeric,text) to authenticated;

-- Registra o resultado de uma chamada real (feita pela Edge Function/servidor)
create or replace function public.log_connector_call(p_company uuid, p_connector uuid, p_operation text, p_status integer, p_latency integer, p_success boolean, p_reference text default null, p_error text default null)
returns void language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid;
begin
  if not (app.can_access_company(p_company) and app.has_permission('integration.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.connector_logs (tenant_id, company_id, connector_id, operation, reference, http_status, latency_ms, success, error)
    values (v_tenant, p_company, p_connector, p_operation, p_reference, p_status, p_latency, coalesce(p_success,false), p_error);
  update public.carrier_connectors set
    status = case when p_success then 'active' else 'error' end,
    last_ok_at = case when p_success then now() else last_ok_at end,
    last_error = case when p_success then null else p_error end
    where id=p_connector and company_id=p_company;
end; $$;
grant execute on function public.log_connector_call(uuid,uuid,text,integer,integer,boolean,text,text) to authenticated;

create or replace function public.connector_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'connectors', (select count(*) from public.carrier_connectors where company_id=p_company and deleted_at is null),
    'active', (select count(*) from public.carrier_connectors where company_id=p_company and status='active' and deleted_at is null),
    'error', (select count(*) from public.carrier_connectors where company_id=p_company and status='error' and deleted_at is null),
    'calls_today', (select count(*) from public.connector_logs where company_id=p_company and requested_at::date=now()::date and deleted_at is null),
    'calls_failed_today', (select count(*) from public.connector_logs where company_id=p_company and requested_at::date=now()::date and not success and deleted_at is null),
    'avg_latency_ms', (select round(avg(latency_ms),0) from public.connector_logs where company_id=p_company and requested_at > now()-interval '1 day' and deleted_at is null),
    'by_provider', (select coalesce(jsonb_object_agg(provider, n), '{}'::jsonb) from (select provider, count(*) n from public.carrier_connectors where company_id=p_company and deleted_at is null group by provider) x),
    'operations', (select count(*) from public.connector_operations where company_id=p_company and enabled and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.connector_dashboard(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.carrier_hub_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_err int; v_fail int; v_cred int; v_incomplete int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'INTEG%' and deleted_at is null;

  select count(*) into v_err from public.carrier_connectors where company_id=p_company and status='error' and deleted_at is null;
  if v_err > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'INTEG: conectores com erro', v_err||' conector(es) de transportadora em falha.', 'Verificar credenciais/endpoint; a integração está fora do ar.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_fail from public.connector_logs where company_id=p_company and not success and requested_at > now()-interval '1 day' and deleted_at is null;
  if v_fail >= 5 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'INTEG: muitas chamadas falhando', v_fail||' chamada(s) de API falharam nas últimas 24h.', 'Checar rate limit/timeout do provedor.', 80);
    v_c := v_c + 1;
  end if;
  select count(*) into v_cred from public.connector_credentials where company_id=p_company and valid_to is not null and valid_to < now()::date + 15 and deleted_at is null;
  if v_cred > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'INTEG: credenciais a expirar', v_cred||' credencial(is) de API vencem em breve.', 'Renovar token/contrato antes de vencer.', 72);
    v_c := v_c + 1;
  end if;
  select count(*) into v_incomplete from public.carrier_connectors c where c.company_id=p_company and c.status='inactive' and c.deleted_at is null
    and (c.base_url is null or c.base_url='' or not exists (select 1 from public.connector_operations o where o.connector_id=c.id and o.enabled and o.deleted_at is null));
  if v_incomplete > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'INTEG: conectores incompletos', v_incomplete||' conector(es) sem URL/operações configuradas.', 'Completar a configuração para ativar a integração.', 70);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.carrier_hub_insights(uuid) to authenticated;

-- ── SEED (empresa Matriz Logística): Correios + genérico + operações ────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid; v_correios uuid;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;
  if not exists (select 1 from public.carrier_connectors where company_id=v_company and deleted_at is null) then
    insert into public.carrier_connectors (tenant_id, company_id, code, name, provider, base_url, auth_type, environment, status) values
      (v_tenant, v_company, 'CORREIOS', 'Correios (CWS)', 'correios', 'https://api.correios.com.br', 'contract_card', 'production', 'inactive') returning id into v_correios;
    insert into public.carrier_connectors (tenant_id, company_id, code, name, provider, base_url, auth_type, environment, status) values
      (v_tenant, v_company, 'JADLOG', 'Jadlog API', 'jadlog', 'https://www.jadlog.com.br/embarcador/api', 'bearer_token', 'production', 'inactive'),
      (v_tenant, v_company, 'GENERICO', 'Transportadora Genérica (REST)', 'generic_rest', 'https://api.exemplo-transportadora.com', 'apikey', 'sandbox', 'inactive');
    insert into public.connector_operations (tenant_id, company_id, connector_id, operation, http_method, path) values
      (v_tenant, v_company, v_correios, 'quote', 'POST', '/preco/v1/nacional'),
      (v_tenant, v_company, v_correios, 'label', 'POST', '/prepostagem/v1/prepostagens'),
      (v_tenant, v_company, v_correios, 'track', 'GET', '/srorastro/v1/objetos/{codigo}');
    insert into public.connector_credentials (tenant_id, company_id, connector_id, key_name, key_value, is_secret) values
      (v_tenant, v_company, v_correios, 'usuario', '', true),
      (v_tenant, v_company, v_correios, 'senha', '', true),
      (v_tenant, v_company, v_correios, 'cartao_postagem', '', true),
      (v_tenant, v_company, v_correios, 'contrato', '', true);
  end if;
end $seed$;

notify pgrst, 'reload schema';
