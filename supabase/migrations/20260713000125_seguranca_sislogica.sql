-- Blindagem: sislogica_webhook_tokens.token é segredo (não expor ao cliente).
revoke select on public.sislogica_webhook_tokens from authenticated, anon;
grant select (id,tenant_id,company_id,branch_id,descricao,criado_por,revogado,ultimo_uso_em,
  active,version,metadata,created_at,updated_at,deleted_at,deleted_by,reason_deleted,created_by,updated_by)
  on public.sislogica_webhook_tokens to authenticated;
