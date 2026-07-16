-- ════════════════════════════════════════════════════════════════════════════
-- Store Hub — RECEPTOR DE POSTBACK/WEBHOOK (Braip, Hotmart, Kiwify, AppMax…)
-- ════════════════════════════════════════════════════════════════════════════
-- A maioria dos checkouts BR de infoproduto NÃO tem "pull" — eles fazem um POST
-- (postback) na SUA URL quando há venda. Esse POST é anônimo: a autenticação é um
-- TOKEN compartilhado, não um usuário logado. Por isso o ingest_store_webhook
-- (guardado por has_permission) não serve para o postback.
--
-- Aqui: (1) extraímos o núcleo de ingestão para app._store_ingest_core (sem o
-- guard de permissão), (2) ingest_store_webhook passa a só validar permissão e
-- delegar, e (3) criamos ingest_store_postback — validado pelo TOKEN do conector
-- (o segredo é a auth) — exposto a anon para receber o POST da plataforma.
-- ════════════════════════════════════════════════════════════════════════════

-- 1) Núcleo compartilhado (sem guard) — schema app, não concedido a ninguém.
create or replace function app._store_ingest_core(
  p_company uuid, p_connector uuid, p_event_type text, p_sale_number text, p_raw jsonb,
  p_signature_valid boolean default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_plat text; v_prod text; v_key text; v_evt uuid; v_existing uuid; v_order uuid;
  v_state text; v_new_state text; v_val numeric; v_dup boolean := false;
begin
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
      buyer_name, buyer_doc, buyer_email, buyer_phone, dest_zip, dest_street, dest_number, dest_district, dest_city, dest_uf, product_name, plan_ref, sku, value, state)
    values (v_tenant, p_company, p_connector, v_plat, v_prod, p_sale_number,
      p_raw->>'buyer_name', p_raw->>'buyer_doc', p_raw->>'buyer_email', p_raw->>'buyer_phone',
      p_raw->>'dest_zip', p_raw->>'dest_street', p_raw->>'dest_number', p_raw->>'dest_district', p_raw->>'dest_city', p_raw->>'dest_uf',
      p_raw->>'product_name', p_raw->>'plan_ref', p_raw->>'sku', v_val,
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

-- 2) ingest_store_webhook (autenticado) passa a guardar permissão e delegar ao núcleo.
create or replace function public.ingest_store_webhook(
  p_company uuid, p_connector uuid, p_event_type text, p_sale_number text, p_raw jsonb,
  p_signature_valid boolean default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
begin
  if not (app.can_access_company(p_company) and app.has_permission('integration.create', p_company)) then raise exception 'forbidden'; end if;
  return app._store_ingest_core(p_company, p_connector, p_event_type, p_sale_number, p_raw, p_signature_valid);
end; $$;
grant execute on function public.ingest_store_webhook(uuid,uuid,text,text,jsonb,boolean) to authenticated;

-- 3) ingest_store_postback — receptor PÚBLICO validado pelo TOKEN do conector.
--    A URL carrega o connector_id (uuid, não adivinhável) e o token é o segredo.
--    Não expõe dado nenhum: retorna só {duplicate, order_id, state}.
create or replace function public.ingest_store_postback(
  p_connector uuid, p_token text, p_event_type text, p_sale_number text, p_raw jsonb)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_token text; v_deleted timestamptz;
begin
  select company_id, webhook_token, deleted_at into v_company, v_token, v_deleted
    from public.store_connectors where id = p_connector;
  if v_company is null or v_deleted is not null then
    raise exception 'connector not found';
  end if;
  -- token é a autenticação do postback: precisa existir e bater exatamente
  if v_token is null or length(v_token) < 8 or p_token is null or p_token <> v_token then
    raise exception 'invalid token';
  end if;
  if coalesce(p_sale_number,'') = '' then
    raise exception 'sale_number required';
  end if;
  return app._store_ingest_core(
    v_company, p_connector,
    coalesce(nullif(p_event_type,''), 'paid'),
    p_sale_number,
    coalesce(p_raw, '{}'::jsonb),
    true);
end; $$;
-- postback é anônimo (a plataforma chama sem sessão) → concedido a anon.
grant execute on function public.ingest_store_postback(uuid,text,text,text,jsonb) to anon, authenticated;

-- índice p/ lookup por chave de idempotência (se ainda não existir)
create index if not exists idx_store_webhook_events_key on public.store_webhook_events (company_id, event_key) where deleted_at is null;
