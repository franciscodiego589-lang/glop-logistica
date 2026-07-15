-- ============================================================================
-- STORE INTEGRATION HUB (migration 087)
-- Integração por API/webhook com QUALQUER loja/checkout (Monetizze, Hotmart,
-- Kiwify, Yampi, Shopify, Mercado Livre, WooCommerce...). Par do Carrier Hub (085):
-- lá são as transportadoras, aqui são as lojas. Núcleo do blueprint de expedição:
-- IDEMPOTÊNCIA por chave natural (plataforma+nº venda+evento), evento BRUTO
-- imutável, normalização ("PedidoNormalizado") e MÁQUINA DE ESTADOS com trilha.
-- Multi-produtor nativo. Recurso RBAC 'integration'. Padrão: colunas-padrão, text+check.
-- ============================================================================

-- ── 1) CONECTORES de loja/plataforma ─────────────────────────────────────────
create table if not exists public.store_connectors (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  name text,
  platform text not null default 'generic' check (platform in ('monetizze','hotmart','kiwify','yampi','shopify','mercado_livre','woocommerce','nuvemshop','tray','cartpanda','braip','eduzz','perfectpay','generic')),
  producer_ref text,                         -- multi-produtor (ex.: OZEMPHARMA)
  api_base_url text,
  auth_type text not null default 'webhook_token' check (auth_type in ('none','apikey','bearer_token','basic','oauth2','webhook_token','hmac_signature')),
  webhook_token text,
  environment text not null default 'production' check (environment in ('production','sandbox')),
  status text not null default 'inactive' check (status in ('active','inactive','error')),
  last_event_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  constraint store_connectors_uk unique (company_id, code)
);

-- ── 2) EVENTOS DE WEBHOOK (bruto imutável + idempotência) ────────────────────
create table if not exists public.store_webhook_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  connector_id uuid references public.store_connectors(id) on delete set null,
  platform text,
  sale_number text,
  event_type text not null default 'paid' check (event_type in ('paid','completed','pending','canceled','refund','chargeback','dispute','other')),
  event_key text not null,                   -- plataforma:venda:evento (idempotência)
  raw jsonb not null default '{}'::jsonb,     -- payload BRUTO imutável
  signature_valid boolean,
  received_at timestamptz not null default now(),
  processed_at timestamptz,
  result text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  constraint store_webhook_events_uk unique (company_id, event_key)
);

-- ── 3) PEDIDOS NORMALIZADOS + máquina de estados ─────────────────────────────
create table if not exists public.store_orders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  connector_id uuid references public.store_connectors(id) on delete set null,
  platform text,
  producer_ref text,
  sale_number text,
  buyer_name text, buyer_doc text, buyer_email text, buyer_phone text,
  dest_zip text, dest_street text, dest_number text, dest_district text, dest_city text, dest_uf text,
  product_name text, plan_ref text, sku text,
  weight_kg numeric(14,3), cubage_m3 numeric(14,4),
  value numeric(16,2),
  state text not null default 'recebido' check (state in ('recebido','importado','pronto_despacho','pre_postado','etiquetado','postado','em_transito','saiu_entrega','entregue','sem_plano','endereco_invalido','bloqueado_reembolso','cancelado','devolvido','extraviado')),
  tracking_code text,
  blocked_reason text,
  promoted_order_id uuid references public.logistics_orders(id) on delete set null,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  constraint store_orders_uk unique (company_id, connector_id, sale_number)
);

-- ── 4) TRILHA de transições (auditoria da máquina de estados) ────────────────
create table if not exists public.store_order_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  store_order_id uuid not null references public.store_orders(id) on delete cascade,
  from_state text, to_state text,
  actor text,                                -- usuário/sistema
  reason text,
  occurred_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 5) REGRAS de mapeamento de plano (fila SEM PLANO) ────────────────────────
create table if not exists public.store_plan_rules (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  producer_ref text,
  match_product text,                        -- ILIKE sobre nome do produto/plano
  match_value_min numeric(16,2), match_value_max numeric(16,2),
  plan_ref text, sku text,
  weight_kg numeric(14,3), cubage_m3 numeric(14,4),
  priority integer not null default 100,
  enabled boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_store_evt_conn on public.store_webhook_events (connector_id, received_at);
create index if not exists idx_store_evt_unproc on public.store_webhook_events (company_id, processed_at);
create index if not exists idx_store_orders_state on public.store_orders (company_id, state);
create index if not exists idx_store_ord_evt on public.store_order_events (store_order_id);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'integration') ────
do $do$
declare t text; specs text[] := array['store_connectors','store_webhook_events','store_orders','store_order_events','store_plan_rules'];
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

-- ── helper: registra transição de estado (trilha) ───────────────────────────
create or replace function app.store_log_transition(p_tenant uuid, p_company uuid, p_order uuid, p_from text, p_to text, p_actor text, p_reason text)
returns void language sql as $$
  insert into public.store_order_events (tenant_id, company_id, store_order_id, from_state, to_state, actor, reason)
  values (p_tenant, p_company, p_order, p_from, p_to, coalesce(p_actor,'sistema'), p_reason);
$$;

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- INGESTÃO IDEMPOTENTE de webhook: mesma chave natural NUNCA duplica pedido.
-- Trata todos os eventos (pago/pendente/cancelado/reembolso/chargeback) com efeito na máquina de estados.
create or replace function public.ingest_store_webhook(
  p_company uuid, p_connector uuid, p_event_type text, p_sale_number text, p_raw jsonb,
  p_signature_valid boolean default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_plat text; v_prod text; v_key text; v_evt uuid; v_existing uuid; v_order uuid;
  v_state text; v_new_state text; v_val numeric; v_dup boolean := false;
begin
  if not (app.can_access_company(p_company) and app.has_permission('integration.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select platform, producer_ref into v_plat, v_prod from public.store_connectors where id=p_connector and company_id=p_company;
  v_key := coalesce(v_plat,'?')||':'||coalesce(p_sale_number,'?')||':'||coalesce(p_event_type,'?');

  -- IDEMPOTÊNCIA: se a chave já existe, não reprocessa (reentrega/replay seguro)
  select id into v_existing from public.store_webhook_events where company_id=p_company and event_key=v_key and deleted_at is null;
  if v_existing is not null then
    return jsonb_build_object('duplicate', true, 'event_id', v_existing, 'message', 'Evento já recebido (idempotente).');
  end if;

  insert into public.store_webhook_events (tenant_id, company_id, connector_id, platform, sale_number, event_type, event_key, raw, signature_valid, processed_at)
    values (v_tenant, p_company, p_connector, v_plat, p_sale_number, p_event_type, v_key, coalesce(p_raw,'{}'::jsonb), p_signature_valid, now())
    returning id into v_evt;
  update public.store_connectors set last_event_at=now(), status='active' where id=p_connector and company_id=p_company;

  v_val := (p_raw->>'value')::numeric;
  -- upsert do pedido normalizado
  select id, state into v_order, v_state from public.store_orders where company_id=p_company and connector_id=p_connector and sale_number=p_sale_number and deleted_at is null;
  if v_order is null then
    insert into public.store_orders (tenant_id, company_id, connector_id, platform, producer_ref, sale_number,
      buyer_name, buyer_doc, buyer_email, buyer_phone, dest_zip, dest_city, dest_uf, product_name, value, state)
    values (v_tenant, p_company, p_connector, v_plat, v_prod, p_sale_number,
      p_raw->>'buyer_name', p_raw->>'buyer_doc', p_raw->>'buyer_email', p_raw->>'buyer_phone',
      p_raw->>'dest_zip', p_raw->>'dest_city', p_raw->>'dest_uf', p_raw->>'product_name', v_val,
      case when p_event_type in ('paid','completed') then 'recebido' when p_event_type='pending' then 'recebido' else 'recebido' end)
    returning id, state into v_order, v_state;
    perform app.store_log_transition(v_tenant, p_company, v_order, null, v_state, 'webhook:'||p_event_type, 'Pedido criado');
  end if;

  -- efeitos por tipo de evento (máquina de estados + bloqueios)
  v_new_state := v_state;
  if p_event_type in ('canceled') and v_state not in ('postado','em_transito','saiu_entrega','entregue') then
    v_new_state := 'cancelado';
  elsif p_event_type in ('refund','chargeback','dispute') then
    if v_state in ('postado','em_transito','saiu_entrega','entregue') then
      -- JÁ POSTADO: não muda estado, mas marca alerta vermelho p/ reversa/contestação
      update public.store_orders set blocked_reason='REEMBOLSO PÓS-POSTAGEM — acionar reversa/contestação' where id=v_order;
      perform app.store_log_transition(v_tenant, p_company, v_order, v_state, v_state, 'webhook:'||p_event_type, 'Reembolso após postagem (alerta)');
    else
      v_new_state := 'bloqueado_reembolso';
    end if;
  end if;
  if v_new_state <> v_state then
    update public.store_orders set state=v_new_state,
      blocked_reason = case when v_new_state='bloqueado_reembolso' then 'Bloqueado por '||p_event_type else blocked_reason end
      where id=v_order;
    perform app.store_log_transition(v_tenant, p_company, v_order, v_state, v_new_state, 'webhook:'||p_event_type, 'Transição automática por evento');
  end if;

  return jsonb_build_object('duplicate', false, 'event_id', v_evt, 'order_id', v_order, 'state', coalesce(v_new_state,v_state));
end; $$;
grant execute on function public.ingest_store_webhook(uuid,uuid,text,text,jsonb,boolean) to authenticated;

-- Resolve o plano de um pedido SEM PLANO por similaridade (nome + faixa de valor)
create or replace function public.resolve_store_plan(p_company uuid, p_order uuid)
returns public.store_orders language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; o public.store_orders; rule public.store_plan_rules;
begin
  if not (app.can_access_company(p_company) and app.has_permission('integration.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select * into o from public.store_orders where id=p_order and company_id=p_company;
  if o.id is null then raise exception 'Pedido não encontrado'; end if;
  select * into rule from public.store_plan_rules
    where company_id=p_company and enabled and deleted_at is null
      and (match_product is null or o.product_name ilike '%'||match_product||'%')
      and (match_value_min is null or coalesce(o.value,0) >= match_value_min)
      and (match_value_max is null or coalesce(o.value,0) <= match_value_max)
    order by priority limit 1;
  if rule.id is not null then
    update public.store_orders set plan_ref=rule.plan_ref, sku=rule.sku, weight_kg=rule.weight_kg, cubage_m3=rule.cubage_m3,
      state = case when state='sem_plano' then 'recebido' else state end where id=p_order returning * into o;
    perform app.store_log_transition(v_tenant, p_company, p_order, 'sem_plano', o.state, 'sistema', 'Plano resolvido: '||coalesce(rule.plan_ref,''));
  end if;
  return o;
end; $$;
grant execute on function public.resolve_store_plan(uuid,uuid) to authenticated;

-- Transição manual de estado (com trilha + guarda de reembolso)
create or replace function public.transition_store_order(p_company uuid, p_order uuid, p_to_state text, p_reason text default null)
returns public.store_orders language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; o public.store_orders;
begin
  if not (app.can_access_company(p_company) and app.has_permission('integration.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select * into o from public.store_orders where id=p_order and company_id=p_company;
  if o.id is null then raise exception 'Pedido não encontrado'; end if;
  if o.state='bloqueado_reembolso' and p_to_state in ('pre_postado','etiquetado','postado') then
    raise exception 'Bloqueado por reembolso — não pode despachar';
  end if;
  update public.store_orders set state=p_to_state,
    tracking_code = coalesce((select tracking_code from public.store_orders where id=p_order), tracking_code)
    where id=p_order returning * into o;
  perform app.store_log_transition(v_tenant, p_company, p_order, o.state, p_to_state, 'usuario', p_reason);
  return o;
end; $$;
grant execute on function public.transition_store_order(uuid,uuid,text,text) to authenticated;

create or replace function public.store_hub_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'connectors', (select count(*) from public.store_connectors where company_id=p_company and deleted_at is null),
    'orders', (select count(*) from public.store_orders where company_id=p_company and deleted_at is null),
    'recebido', (select count(*) from public.store_orders where company_id=p_company and state='recebido' and deleted_at is null),
    'sem_plano', (select count(*) from public.store_orders where company_id=p_company and state='sem_plano' and deleted_at is null),
    'sem_plano_valor', (select coalesce(round(sum(value),2),0) from public.store_orders where company_id=p_company and state='sem_plano' and deleted_at is null),
    'bloqueado_reembolso', (select count(*) from public.store_orders where company_id=p_company and state='bloqueado_reembolso' and deleted_at is null),
    'endereco_invalido', (select count(*) from public.store_orders where company_id=p_company and state='endereco_invalido' and deleted_at is null),
    'postado', (select count(*) from public.store_orders where company_id=p_company and state in ('postado','em_transito','saiu_entrega') and deleted_at is null),
    'entregue', (select count(*) from public.store_orders where company_id=p_company and state='entregue' and deleted_at is null),
    'eventos_hoje', (select count(*) from public.store_webhook_events where company_id=p_company and received_at::date=now()::date and deleted_at is null),
    'eventos_nao_processados', (select count(*) from public.store_webhook_events where company_id=p_company and processed_at is null and deleted_at is null),
    'by_platform', (select coalesce(jsonb_object_agg(platform, n), '{}'::jsonb) from (select platform, count(*) n from public.store_orders where company_id=p_company and deleted_at is null group by platform) x)
  ) into v;
  return v;
end; $$;
grant execute on function public.store_hub_dashboard(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.store_hub_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_sp int; v_spv numeric; v_ref int; v_addr int; v_unp int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'STORE%' and deleted_at is null;

  select count(*), coalesce(sum(value),0) into v_sp, v_spv from public.store_orders where company_id=p_company and state='sem_plano' and deleted_at is null;
  if v_sp > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'STORE: pedidos SEM PLANO travados', v_sp||' pedido(s) sem plano (R$ '||v_spv||' travados).', 'Mapear a variação e criar regra p/ nunca mais cair aqui.', 84);
    v_c := v_c + 1;
  end if;
  -- ALERTA VERMELHO: reembolso após já ter postado
  select count(*) into v_ref from public.store_orders where company_id=p_company and blocked_reason like 'REEMBOLSO PÓS-POSTAGEM%' and deleted_at is null;
  if v_ref > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'fraud_risk', 'critical', 'STORE: reembolso após postagem', v_ref||' pedido(s) reembolsados/chargeback JÁ postados.', 'Acionar logística reversa e contestação imediatamente.', 92);
    v_c := v_c + 1;
  end if;
  select count(*) into v_addr from public.store_orders where company_id=p_company and state='endereco_invalido' and deleted_at is null;
  if v_addr > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'STORE: endereços inválidos', v_addr||' pedido(s) com endereço inválido.', 'Contatar o cliente antes de gastar frete.', 80);
    v_c := v_c + 1;
  end if;
  select count(*) into v_unp from public.store_webhook_events where company_id=p_company and processed_at is null and received_at < now()-interval '1 hour' and deleted_at is null;
  if v_unp > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'STORE: eventos não processados', v_unp||' webhook(s) sem processar há mais de 1h.', 'Reprocessar a fila; possível falha de integração.', 82);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.store_hub_insights(uuid) to authenticated;

-- ── SEED: conectores de loja + regra de plano ──────────────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;
  if not exists (select 1 from public.store_connectors where company_id=v_company and deleted_at is null) then
    insert into public.store_connectors (tenant_id, company_id, code, name, platform, producer_ref, auth_type, environment, status) values
      (v_tenant, v_company, 'MONETIZZE-OZE', 'Monetizze — OZEMPHARMA', 'monetizze', 'OZEMPHARMA', 'webhook_token', 'production', 'active'),
      (v_tenant, v_company, 'HOTMART', 'Hotmart', 'hotmart', null, 'hmac_signature', 'production', 'inactive'),
      (v_tenant, v_company, 'KIWIFY', 'Kiwify', 'kiwify', null, 'webhook_token', 'production', 'inactive'),
      (v_tenant, v_company, 'SHOPIFY', 'Shopify', 'shopify', null, 'bearer_token', 'production', 'inactive');
    insert into public.store_plan_rules (tenant_id, company_id, producer_ref, match_product, match_value_min, match_value_max, plan_ref, sku, weight_kg) values
      (v_tenant, v_company, 'OZEMPHARMA', 'MOUNJAX', 0, 99999, 'MOUNJAX-GOTAS-1F', 'MJX-1F', 0.3);
  end if;
end $seed$;

notify pgrst, 'reload schema';
