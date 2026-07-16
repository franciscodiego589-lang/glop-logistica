-- ════════════════════════════════════════════════════════════════════════════
-- IMPORTAÇÃO "Logística Rodrigo" (lemonlog) → GLOP  ·  M5 — ENVIOS & RASTREAMENTO
-- ════════════════════════════════════════════════════════════════════════════
-- Porta: envios · tracking_events · clientes_envio · notificacoes_carteiro_ausente.
-- Fiel ao original (todas as colunas/tipos/defaults) + padrão GLOP por cima:
-- tenant_id/company_id/branch_id, colunas de auditoria, RLS por company (app.*)
-- e triggers touch/audit. Nomes em português preservados (fidelidade).
--
-- Adaptações GLOP (documentadas, nada removido):
--  · PK: GLOP exige `id uuid`. As tabelas de origem envios/clientes_envio/
--    notificacoes_carteiro_ausente usavam `id bigint` (sequence). Preservamos o
--    identificador numérico original em `id_origem bigint` e adotamos `id uuid`.
--    tracking_events já usava uuid → mapeia direto.
--  · produtor_id só existia em tracking_events → mantido como FK →
--    public.produtores_integracao(id). Não foi inventado nas demais tabelas.
--  · pedido_id (tracking_events) preservado como uuid simples (a tabela pedidos
--    não pertence a este módulo/M0) — apenas indexado.
--  · Colunas `status`/`ultimo_status`/`origem` mantidas como text livre (fiéis).
-- Ver docs/rodrigo-import/PLANO-IMPORTACAO.md. M0 (produtores_integracao) já existe.
-- Resource RLS: 'shipping' (logística/correios/envios/rastreamento).
-- ════════════════════════════════════════════════════════════════════════════

-- ── envios (remessas postadas + último status consolidado) ───────────────────
create table if not exists public.envios (
  id uuid primary key default gen_random_uuid(),
  id_origem bigint,                         -- id bigint original (sequence lemonlog)
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  data_envio text,
  nome text not null,
  cep text,
  uf text,
  peso text,
  formato text,
  codigo_interno text,
  codigo_rastreio text,
  valor_declarado numeric(12,2),
  valor_pago numeric(12,2),
  pdf_nome text,
  linha_bruta text,
  ultimo_status text,
  ultimo_status_detalhe text,
  ultimo_status_local text,
  ultimo_status_data timestamp with time zone,
  ultima_consulta timestamp with time zone,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists envios_company_idx on public.envios(company_id) where deleted_at is null;
create index if not exists envios_codigo_rastreio_idx on public.envios(codigo_rastreio);
create index if not exists envios_codigo_interno_idx on public.envios(codigo_interno);
create index if not exists envios_id_origem_idx on public.envios(id_origem);

-- ── tracking_events (eventos de rastreamento — Correios/webhook) ─────────────
create table if not exists public.tracking_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  pedido_id uuid,
  produtor_id uuid references public.produtores_integracao(id),
  codigo_rastreio text,
  status text,
  descricao_evento text,
  data_evento timestamp with time zone,
  local_evento text,
  cidade_evento text,
  uf_evento text,
  payload_original jsonb,
  origem text not null default 'webhook'::text,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
alter table public.tracking_events replica identity full;  -- preservado do original
create index if not exists tracking_events_company_idx on public.tracking_events(company_id) where deleted_at is null;
create index if not exists tracking_events_produtor_idx on public.tracking_events(produtor_id);
create index if not exists tracking_events_pedido_idx on public.tracking_events(pedido_id);
create index if not exists tracking_events_codigo_rastreio_idx on public.tracking_events(codigo_rastreio);

-- ── clientes_envio (destinatários importados de planilha/CSV) ────────────────
create table if not exists public.clientes_envio (
  id uuid primary key default gen_random_uuid(),
  id_origem bigint,                         -- id bigint original (sequence lemonlog)
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  nome text not null,
  cpf text,
  codigo_rastreio text,
  cep text,
  endereco_completo text,
  nome_plano text,
  telefone text,
  csv_nome text,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists clientes_envio_company_idx on public.clientes_envio(company_id) where deleted_at is null;
create index if not exists clientes_envio_codigo_rastreio_idx on public.clientes_envio(codigo_rastreio);
create index if not exists clientes_envio_cpf_idx on public.clientes_envio(cpf);
create index if not exists clientes_envio_id_origem_idx on public.clientes_envio(id_origem);

-- ── notificacoes_carteiro_ausente (avisos de tentativa/carteiro ausente) ─────
create table if not exists public.notificacoes_carteiro_ausente (
  id uuid primary key default gen_random_uuid(),
  id_origem bigint,                         -- id bigint original (sequence lemonlog)
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  codigo_objeto text not null,
  evento_descricao text,
  evento_data timestamp with time zone,
  evento_local text,
  telefone text,
  nome text,
  status text not null default 'enviado'::text,
  erro text,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists notif_carteiro_company_idx on public.notificacoes_carteiro_ausente(company_id) where deleted_at is null;
create index if not exists notif_carteiro_codigo_objeto_idx on public.notificacoes_carteiro_ausente(codigo_objeto);
create index if not exists notif_carteiro_id_origem_idx on public.notificacoes_carteiro_ausente(id_origem);

-- ── Triggers touch/audit (padrão GLOP) ───────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array['envios','tracking_events','clientes_envio','notificacoes_carteiro_ausente'] loop
    execute format('drop trigger if exists trg_%s_touch on public.%s', t, t);
    execute format('create trigger trg_%s_touch before insert or update on public.%s for each row execute function app.tg_touch_row()', t, t);
    execute format('drop trigger if exists trg_%s_audit on public.%s', t, t);
    execute format('create trigger trg_%s_audit after insert or update or delete on public.%s for each row execute function app.tg_write_audit()', t, t);
  end loop;
end $$;

-- ── RLS por company (padrão GLOP, resource 'shipping') ───────────────────────
do $$ declare t text;
begin
  foreach t in array array['envios','tracking_events','clientes_envio','notificacoes_carteiro_ausente'] loop
    execute format('alter table public.%s enable row level security', t);
    execute format($f$create policy %1$s_select on public.%1$s for select to authenticated
      using (app.is_superadmin() or company_id in (select app.user_company_ids()))$f$, t);
    execute format($f$create policy %1$s_insert on public.%1$s for insert to authenticated
      with check (app.can_access_company(company_id) and app.has_permission('shipping.create', company_id))$f$, t);
    execute format($f$create policy %1$s_update on public.%1$s for update to authenticated
      using (app.can_access_company(company_id) and app.has_permission('shipping.update', company_id))
      with check (app.can_access_company(company_id))$f$, t);
    execute format($f$create policy %1$s_delete on public.%1$s for delete to authenticated
      using (app.is_superadmin())$f$, t);
  end loop;
exception when duplicate_object then null;
end $$;
