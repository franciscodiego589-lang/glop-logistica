-- ════════════════════════════════════════════════════════════════════════════
-- IMPORTAÇÃO "Logística Rodrigo" (lemonlog) → GLOP  ·  M12 — WEBHOOKS & INTEGRAÇÕES
-- ════════════════════════════════════════════════════════════════════════════
-- Porta webhooks do produtor + entregas, logs SisLógica (envios/webhooks/tokens),
-- logs de API e de webhook, e perfis de usuário (profiles).
-- Fiel ao original (todas as colunas/tipos/defaults) + padrão GLOP por cima:
-- tenant_id/company_id/branch_id, colunas de auditoria, RLS por company (app.*),
-- triggers touch/audit. FK produtor_id → public.produtores_integracao(id) (M0).
-- Nada removido; melhorias = padrão GLOP.
-- Tabelas: produtor_webhooks, produtor_webhook_entregas, sislogica_envios_log,
--          sislogica_webhook_recebidos, sislogica_webhook_tokens, api_logs,
--          webhook_logs, profiles.
-- Sem enums de negócio próprios neste módulo.
-- Ver docs/rodrigo-import/PLANO-IMPORTACAO.md.
-- ════════════════════════════════════════════════════════════════════════════

-- ── produtor_webhooks (webhooks de saída configurados pelo produtor) ──────────
create table if not exists public.produtor_webhooks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  user_id uuid not null references auth.users(id) on delete cascade,
  produtor_id uuid references public.produtores_integracao(id),
  nome text not null,
  url text not null,
  eventos text[] not null default array['venda.criada'::text],
  ativo boolean not null default true,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists produtor_webhooks_company_idx on public.produtor_webhooks(company_id) where deleted_at is null;
create index if not exists produtor_webhooks_produtor_idx on public.produtor_webhooks(produtor_id);
create index if not exists produtor_webhooks_user_idx on public.produtor_webhooks(user_id);

-- ── produtor_webhook_entregas (log de entregas/disparos de cada webhook) ──────
create table if not exists public.produtor_webhook_entregas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  webhook_id uuid not null references public.produtor_webhooks(id) on delete cascade,
  evento text not null,
  payload jsonb not null,
  status_http integer,
  resposta text,
  erro text,
  duracao_ms integer,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists produtor_webhook_entregas_company_idx on public.produtor_webhook_entregas(company_id) where deleted_at is null;
create index if not exists produtor_webhook_entregas_webhook_idx on public.produtor_webhook_entregas(webhook_id);

-- ── sislogica_envios_log (log de solicitações de envio à SisLógica) ───────────
create table if not exists public.sislogica_envios_log (
  id bigint generated always as identity primary key,
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  pedido_id uuid,
  produtor_id uuid references public.produtores_integracao(id),
  id_solicitacao_interno text,
  id_solicitacao_gerada text,
  codigo_rastreio text,
  status text not null,
  http_status integer,
  erro text,
  request_payload jsonb,
  response_payload jsonb,
  duracao_ms integer,
  venda_id bigint,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists sislogica_envios_log_company_idx on public.sislogica_envios_log(company_id) where deleted_at is null;
create index if not exists sislogica_envios_log_produtor_idx on public.sislogica_envios_log(produtor_id);
create index if not exists sislogica_envios_log_pedido_idx on public.sislogica_envios_log(pedido_id);

-- ── sislogica_webhook_recebidos (webhooks de status recebidos da SisLógica) ───
create table if not exists public.sislogica_webhook_recebidos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  payload jsonb not null default '{}'::jsonb,
  id_solicitacao text,
  id_solicitacao_interno text,
  codigo_rastreio text,
  status_recebido text,
  processado boolean not null default false,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists sislogica_webhook_recebidos_company_idx on public.sislogica_webhook_recebidos(company_id) where deleted_at is null;
create index if not exists sislogica_webhook_recebidos_rastreio_idx on public.sislogica_webhook_recebidos(codigo_rastreio);

-- ── sislogica_webhook_tokens (tokens de autenticação dos webhooks SisLógica) ──
create table if not exists public.sislogica_webhook_tokens (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  token text not null,
  descricao text,
  criado_por uuid,
  revogado boolean not null default false,
  ultimo_uso_em timestamptz,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists sislogica_webhook_tokens_company_idx on public.sislogica_webhook_tokens(company_id) where deleted_at is null;
create index if not exists sislogica_webhook_tokens_token_idx on public.sislogica_webhook_tokens(token);

-- ── api_logs (log genérico de chamadas de integração/API) ─────────────────────
create table if not exists public.api_logs (
  id bigint generated always as identity primary key,
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  tipo text not null,
  acao text not null,
  status text not null,
  http_status integer,
  referencia text,
  codigo_rastreio text,
  mensagem text,
  request_payload jsonb,
  response_payload jsonb,
  duracao_ms integer,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists api_logs_company_idx on public.api_logs(company_id) where deleted_at is null;
create index if not exists api_logs_referencia_idx on public.api_logs(referencia);

-- ── webhook_logs (log de webhooks recebidos das plataformas de venda) ─────────
create table if not exists public.webhook_logs (
  id bigint generated always as identity primary key,
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  produtor_id uuid references public.produtores_integracao(id),
  token_prefix text,
  status text not null,
  motivo text,
  plano_codigo text,
  produto_codigo text,
  comprador_nome text,
  valor numeric,
  venda_id bigint,
  ip_origem text,
  payload jsonb,
  codigo_venda text,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists webhook_logs_company_idx on public.webhook_logs(company_id) where deleted_at is null;
create index if not exists webhook_logs_produtor_idx on public.webhook_logs(produtor_id);

-- ── profiles (perfil de usuário do lemonlog) ──────────────────────────────────
-- NÃO recriado: o GLOP já tem public.profiles, e é um SUPERSET do do Rodrigo
-- (full_name≈nome, + email/phone/avatar_url/is_superadmin/tenant_id). Manter o
-- nosso (melhoria, sem perder nada). Mapeamento: Rodrigo.nome → GLOP.full_name.

-- ── Triggers touch/audit (padrão GLOP) ───────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array[
    'produtor_webhooks','produtor_webhook_entregas','sislogica_envios_log',
    'sislogica_webhook_recebidos','sislogica_webhook_tokens','api_logs',
    'webhook_logs'
  ] loop
    execute format('drop trigger if exists trg_%s_touch on public.%s', t, t);
    execute format('create trigger trg_%s_touch before insert or update on public.%s for each row execute function app.tg_touch_row()', t, t);
    execute format('drop trigger if exists trg_%s_audit on public.%s', t, t);
    execute format('create trigger trg_%s_audit after insert or update or delete on public.%s for each row execute function app.tg_write_audit()', t, t);
  end loop;
end $$;

-- ── RLS por company (padrão GLOP) ────────────────────────────────────────────
-- resource por tabela: shipping (envios), integration (webhooks/api/logs), admin (profiles)
do $$
  declare rec record;
begin
  for rec in
    select * from (values
      ('produtor_webhooks','integration'),
      ('produtor_webhook_entregas','integration'),
      ('sislogica_envios_log','shipping'),
      ('sislogica_webhook_recebidos','integration'),
      ('sislogica_webhook_tokens','integration'),
      ('api_logs','integration'),
      ('webhook_logs','integration')
    ) as x(t, res)
  loop
    execute format('alter table public.%s enable row level security', rec.t);
    execute format($f$create policy %1$s_select on public.%1$s for select to authenticated
      using (app.is_superadmin() or company_id in (select app.user_company_ids()))$f$, rec.t);
    execute format($f$create policy %1$s_insert on public.%1$s for insert to authenticated
      with check (app.can_access_company(company_id) and app.has_permission('%2$s.create', company_id))$f$, rec.t, rec.res);
    execute format($f$create policy %1$s_update on public.%1$s for update to authenticated
      using (app.can_access_company(company_id) and app.has_permission('%2$s.update', company_id))
      with check (app.can_access_company(company_id))$f$, rec.t, rec.res);
    execute format($f$create policy %1$s_delete on public.%1$s for delete to authenticated
      using (app.is_superadmin())$f$, rec.t);
  end loop;
exception when duplicate_object then null;
end $$;
