-- ════════════════════════════════════════════════════════════════════════════
-- Blindagem de segredos (auditoria de segurança) — impede que colunas de segredo
-- sejam lidas por membros via RLS/PostgREST. Revoga SELECT da coluna secreta e
-- concede SELECT só nas colunas não sensíveis. Leituras server-side legítimas do
-- webhook_token passam a usar a função connector_secret (guardada por permissão).
-- ════════════════════════════════════════════════════════════════════════════

-- ── store_connectors.webhook_token (segredo da API da plataforma) ────────────
revoke select on public.store_connectors from authenticated, anon;
grant select (id,tenant_id,company_id,branch_id,code,name,platform,producer_ref,api_base_url,
  auth_type,environment,status,last_event_at,active,version,metadata,created_at,updated_at,
  deleted_at,deleted_by,reason_deleted,created_by,updated_by,categoria)
  on public.store_connectors to authenticated;

-- leitura server-side do segredo (rotas pull/tracking/test) — só com permissão
create or replace function public.connector_secret(p_connector uuid)
returns text language plpgsql security definer set search_path = public, app stable as $$
declare v_company uuid; v_token text;
begin
  select company_id, webhook_token into v_company, v_token
    from public.store_connectors where id = p_connector and deleted_at is null;
  if v_company is null then return null; end if;
  if not (app.can_access_company(v_company) and app.has_permission('integration.update', v_company)) then
    raise exception 'forbidden';
  end if;
  return v_token;
end $$;
grant execute on function public.connector_secret(uuid) to authenticated;

-- ── connector_credentials.key_value (cofre de credenciais de transportadora) ──
revoke select on public.connector_credentials from authenticated, anon;
grant select (id,tenant_id,company_id,branch_id,connector_id,key_name,is_secret,environment,
  valid_to,active,version,metadata,created_at,updated_at,deleted_at,deleted_by,reason_deleted,
  created_by,updated_by)
  on public.connector_credentials to authenticated;

-- ── webhooks.secret (chave HMAC de assinatura) ───────────────────────────────
revoke select on public.webhooks from authenticated, anon;
grant select (id,tenant_id,company_id,branch_id,name,event_type,target_url,enabled,max_attempts,
  success_count,failure_count,active,version,metadata,created_at,updated_at,deleted_at,deleted_by,
  reason_deleted,created_by,updated_by)
  on public.webhooks to authenticated;

-- ── api_keys.key_hash (hash da chave de API) ─────────────────────────────────
revoke select on public.api_keys from authenticated, anon;
grant select (id,tenant_id,company_id,branch_id,name,key_prefix,scopes,rate_limit,enabled,
  expires_at,last_used_at,active,version,metadata,created_at,updated_at,deleted_at,deleted_by,
  reason_deleted,created_by,updated_by)
  on public.api_keys to authenticated;

-- ── has_role: não pode ser executável por PUBLIC/anon (enumeração de papéis) ──
do $$ begin
  revoke execute on function public.has_role(uuid, public.app_role) from public;
  revoke execute on function public.has_role(uuid, public.app_role) from anon;
  grant execute on function public.has_role(uuid, public.app_role) to authenticated;
exception when undefined_function then null; end $$;

-- ── rastreio_publico: não vazar produto/cliente (dado sensível) + exigir código
--    no formato completo dos Correios (evita enumeração por códigos curtos) ────
create or replace function public.rastreio_publico(p_codigo text)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare o record; v_code text; v_status text;
begin
  v_code := upper(regexp_replace(coalesce(p_codigo,''), '\s', '', 'g'));
  if v_code !~ '^[A-Z]{2}[0-9]{9}[A-Z]{2}$' then return jsonb_build_object('found', false); end if;

  select so.state, so.tracking_code, so.dest_city, so.dest_uf, so.updated_at, so.created_at
    into o
  from public.store_orders so
  where upper(so.tracking_code) = v_code and so.deleted_at is null
  order by so.updated_at desc limit 1;

  if o.tracking_code is null then return jsonb_build_object('found', false); end if;

  v_status := case o.state
    when 'postado' then 'postado' when 'em_transito' then 'em_transito' when 'saiu_entrega' then 'saiu_entrega'
    when 'entregue' then 'entregue' when 'cancelado' then 'cancelado' when 'devolvido' then 'devolvido'
    else 'processando' end;

  return jsonb_build_object(
    'found', true,
    'codigo', o.tracking_code,
    'status', v_status,
    'destino', coalesce(o.dest_city,'') || case when o.dest_uf is not null then '/'||o.dest_uf else '' end,
    'criado_em', o.created_at,
    'atualizado_em', o.updated_at
  );
end $$;
grant execute on function public.rastreio_publico(text) to anon, authenticated;
