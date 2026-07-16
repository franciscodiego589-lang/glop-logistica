-- ════════════════════════════════════════════════════════════════════════════
-- Blindagem de segredos (parte 2) — varredura completa. Revoga SELECT das colunas
-- de segredo (tokens/keys/oauth) das tabelas importadas e concede SELECT só nas
-- colunas não sensíveis. Nenhuma rota server-side lê esses segredos (verificado).
-- ════════════════════════════════════════════════════════════════════════════

-- produtores_integracao — segredos: webhook_token, *_secret, monetizze_api_key,
--   consumer_key, monetizze_logistica_key, braip_api_token
revoke select on public.produtores_integracao from authenticated, anon;
grant select (id,tenant_id,company_id,branch_id,nome,plataforma,ativo,monetizze_ativa,braip_ativa,
  vhsys_cliente_id,vhsys_id_almoxarifado,vhsys_produtos,vhsys_id_local_estoque,sislog_ativa,
  sislog_cnpj_embarcador,sislog_ufs,aceitar_vendas_sem_plano,cnpj,razao_social,inscricao_estadual,
  endereco,endereco_numero,endereco_complemento,endereco_bairro,endereco_cidade,endereco_estado,
  endereco_cep,email_fiscal,telefone_fiscal,emissao_nfe_ativa,nfe_obs_complementar,nfe_natureza_operacao,
  nfe_cfop,nfe_frete_por_conta,nfe_chave_referenciada,armazem_nome,armazem_cnpj,armazem_inscricao_est,
  armazem_endereco,armazem_endereco_numero,armazem_endereco_complemento,armazem_endereco_bairro,
  armazem_endereco_cidade,armazem_endereco_estado,armazem_endereco_cep,valor_frete,peso_produto,
  active,version,metadata,created_at,updated_at,deleted_at,deleted_by,reason_deleted,created_by,updated_by)
  on public.produtores_integracao to authenticated;

-- appmax_split_config — segredos: client_secret, oauth_access_token, oauth_refresh_token
revoke select on public.appmax_split_config from authenticated, anon;
grant select (id,tenant_id,company_id,branch_id,environment,client_id,logistics_recipient_id,
  logistics_recipient_name,logistics_recipient_document,recipient_status,active,app_id,redirect_uri,
  oauth_token_expires_at,oauth_state,oauth_connected_at,version,metadata,created_at,updated_at,
  deleted_at,deleted_by,reason_deleted,created_by,updated_by)
  on public.appmax_split_config to authenticated;

-- ml_tokens — segredos: access_token, refresh_token
revoke select on public.ml_tokens from authenticated, anon;
grant select (id,tenant_id,company_id,branch_id,active,version,metadata,created_at,updated_at,
  deleted_at,deleted_by,reason_deleted,created_by,updated_by)
  on public.ml_tokens to authenticated;

-- portal_users — segredo: access_token
revoke select on public.portal_users from authenticated, anon;
grant select (id,tenant_id,company_id,branch_id,account_id,name,email,portal_role,last_login_at,
  active,version,metadata,created_at,updated_at,deleted_at,deleted_by,reason_deleted,created_by,updated_by)
  on public.portal_users to authenticated;

-- ai_providers — segredo: api_key_ref
revoke select on public.ai_providers from authenticated, anon;
grant select (id,tenant_id,company_id,branch_id,name,provider_type,base_url,is_default,enabled,config,
  notes,active,version,metadata,created_at,updated_at,deleted_at,deleted_by,reason_deleted,created_by,updated_by)
  on public.ai_providers to authenticated;

-- produtor_api_keys — segredo: key_hash
revoke select on public.produtor_api_keys from authenticated, anon;
grant select (id,tenant_id,company_id,produtor_id,user_id,nome,key_prefix,escopos,ativo,last_used_at,
  revoked_at,active,version,metadata,created_at,updated_at,deleted_at,deleted_by,reason_deleted,created_by,updated_by)
  on public.produtor_api_keys to authenticated;
