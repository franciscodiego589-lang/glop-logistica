-- Blindagem dos segredos Correios (não expor ao cliente). Nenhuma rota lê essas
-- colunas (o token vem de env CORREIOS_API_TOKEN_*), então revogar é seguro.

-- correios_token_cache.token (bearer cacheado)
revoke select on public.correios_token_cache from authenticated, anon;
grant select (id,tipo,numero_cartao,expires_at,refreshed_at,tenant_id,company_id,branch_id,
  active,version,metadata,created_at,updated_at,deleted_at,deleted_by,reason_deleted,created_by,updated_by)
  on public.correios_token_cache to authenticated;

-- contratos_logisticos.correios_api_token (credencial do contrato)
revoke select on public.contratos_logisticos from authenticated, anon;
grant select (id,tenant_id,company_id,branch_id,produtor_id,nome,transportadora,agf_nome,cidade,uf,
  codigo_contrato,cartao_postagem,codigo_administrativo,codigo_diretoria,numero_dr,observacao,ativo,
  active,version,metadata,created_at,updated_at,deleted_at,deleted_by,reason_deleted,created_by,updated_by)
  on public.contratos_logisticos to authenticated;
