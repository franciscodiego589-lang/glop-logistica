-- ════════════════════════════════════════════════════════════════════════════
-- IMPORTAÇÃO "Logística Rodrigo" (lemonlog) → GLOP  ·  M3 — COPRODUÇÃO & SPLIT
-- ════════════════════════════════════════════════════════════════════════════
-- Porta o módulo de COPRODUÇÃO (coprodutores, configuração singleton, regras de
-- comissão, vendas apuradas, repasses/lotes + itens, auditoria, webhook logs) e o
-- SPLIT Appmax (config OAuth + logs de conciliação de frete).
-- Fiel ao original (TODAS as colunas, tipos, defaults e CHECKs) + padrão GLOP por
-- cima: tenant_id/company_id/branch_id, colunas de auditoria, RLS por company
-- (app.*) e triggers touch/audit. Nomes preservados em português (fidelidade).
-- produtores_integracao/produtor_usuarios/user_roles já vêm do M0 — só referência.
-- Ver docs/rodrigo-import/PLANO-IMPORTACAO.md.  Nada removido; melhorias = padrão GLOP.
-- ════════════════════════════════════════════════════════════════════════════

-- ── Enums de negócio (fiéis ao original) ─────────────────────────────────────
do $$ begin
  create type public.coproducao_frete_destino as enum
    ('empresa_principal','dividir_proporcional','ignorar');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.coproducao_modo_operacao as enum
    ('controle_interno','split_real_api','hibrido');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.coproducao_origem as enum
    ('yampi','appmax','manual');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.coproducao_status_coprodutor as enum
    ('ativo','inativo');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.coproducao_status_repasse as enum
    ('pendente','aprovado','pago','cancelado','estornado','chargeback','sem_coprodutor');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.coproducao_status_repasse_lote as enum
    ('aberto','conferido','aprovado','pago','cancelado');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.coproducao_tipo_base as enum
    ('produtos_sem_frete','produtos_sem_frete_sem_desconto','valor_liquido_produtos');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.coproducao_tipo_pessoa as enum
    ('pessoa_fisica','pessoa_juridica');
exception when duplicate_object then null; end $$;

-- ── coprodutores (mestre do coprodutor: dados bancários/pix + percentual) ─────
create table if not exists public.coprodutores (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  nome text not null,
  tipo_pessoa public.coproducao_tipo_pessoa not null default 'pessoa_fisica'::public.coproducao_tipo_pessoa,
  cpf_cnpj text,
  email text,
  telefone text,
  chave_pix text,
  banco text,
  agencia text,
  conta text,
  tipo_conta text,
  percentual_padrao numeric(5,2) not null default 0,
  status public.coproducao_status_coprodutor not null default 'ativo'::public.coproducao_status_coprodutor,
  observacoes text,
  constraint coprodutores_percentual_padrao_check
    check ((percentual_padrao >= (0)::numeric) and (percentual_padrao <= (100)::numeric)),
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists coprodutores_company_idx on public.coprodutores(company_id) where deleted_at is null;

-- ── coproducao_configuracoes (singleton id=1: parâmetros do módulo) ───────────
create table if not exists public.coproducao_configuracoes (
  -- campos originais (fiéis) — id mantém tipo integer + CHECK (id=1)
  id integer primary key default 1,
  ativar_modulo boolean not null default true,
  modo_operacao public.coproducao_modo_operacao not null default 'controle_interno'::public.coproducao_modo_operacao,
  base_calculo_padrao public.coproducao_tipo_base not null default 'produtos_sem_frete'::public.coproducao_tipo_base,
  frete_padrao public.coproducao_frete_destino not null default 'empresa_principal'::public.coproducao_frete_destino,
  permitir_comissao_sobre_frete boolean not null default false,
  bloquear_comissao_sobre_total_com_frete boolean not null default true,
  gerar_conta_pagar_automaticamente boolean not null default false,
  sistema_conta_pagar text not null default 'manual',
  status_minimo_para_gerar_comissao text not null default 'pago',
  prazo_liberacao_repasse_dias integer not null default 7,
  considerar_chargeback boolean not null default true,
  considerar_estorno boolean not null default true,
  constraint coproducao_configuracoes_id_check check ((id = 1)),
  -- colunas-padrão GLOP
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists coproducao_configuracoes_company_idx on public.coproducao_configuracoes(company_id) where deleted_at is null;

-- ── coproducao_regras (regras de comissão por produto/cupom/utm/metadata) ─────
create table if not exists public.coproducao_regras (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  coprodutor_id uuid not null references public.coprodutores(id),
  nome_regra text not null,
  produto_id text,
  produto_nome text,
  sku text,
  codigo_produto_yampi text,
  codigo_produto_appmax text,
  cupom text,
  utm_source text,
  utm_campaign text,
  metadata_coprodutor text,
  percentual_comissao numeric(5,2) not null,
  tipo_base_calculo public.coproducao_tipo_base not null default 'produtos_sem_frete'::public.coproducao_tipo_base,
  frete_para public.coproducao_frete_destino not null default 'empresa_principal'::public.coproducao_frete_destino,
  status public.coproducao_status_coprodutor not null default 'ativo'::public.coproducao_status_coprodutor,
  prioridade integer not null default 100,
  constraint coproducao_regras_percentual_comissao_check
    check ((percentual_comissao >= (0)::numeric) and (percentual_comissao <= (100)::numeric)),
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists coproducao_regras_company_idx on public.coproducao_regras(company_id) where deleted_at is null;
create index if not exists coproducao_regras_coprodutor_idx on public.coproducao_regras(coprodutor_id);

-- ── coproducao_vendas (vendas apuradas + base/valor de comissão calculado) ────
create table if not exists public.coproducao_vendas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  origem public.coproducao_origem not null,
  pedido_yampi_id text,
  pedido_appmax_id text,
  transacao_appmax_id text,
  codigo_venda text,
  cliente_nome text,
  cliente_email text,
  cliente_documento text,
  produto_nome text,
  sku text,
  quantidade integer not null default 1,
  valor_produtos numeric(12,2) not null default 0,
  valor_frete numeric(12,2) not null default 0,
  valor_desconto numeric(12,2) not null default 0,
  valor_total numeric(12,2) not null default 0,
  valor_pago numeric(12,2) not null default 0,
  forma_pagamento text,
  status_pagamento text,
  coprodutor_id uuid references public.coprodutores(id),
  regra_comissao_id uuid references public.coproducao_regras(id),
  percentual_comissao numeric(5,2),
  base_comissao numeric(12,2),
  valor_comissao numeric(12,2),
  valor_empresa numeric(12,2),
  frete_destinado_empresa numeric(12,2),
  status_repasse public.coproducao_status_repasse not null default 'pendente'::public.coproducao_status_repasse,
  data_venda timestamptz,
  data_pagamento timestamptz,
  data_repasse timestamptz,
  payload_original jsonb,
  observacoes text,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists coproducao_vendas_company_idx on public.coproducao_vendas(company_id) where deleted_at is null;
create index if not exists coproducao_vendas_coprodutor_idx on public.coproducao_vendas(coprodutor_id);
create index if not exists coproducao_vendas_regra_comissao_idx on public.coproducao_vendas(regra_comissao_id);

-- ── coproducao_repasses (lote de repasse por período/coprodutor) ──────────────
create table if not exists public.coproducao_repasses (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  coprodutor_id uuid not null references public.coprodutores(id),
  periodo_inicio date not null,
  periodo_fim date not null,
  total_vendas integer not null default 0,
  total_produtos numeric(12,2) not null default 0,
  total_frete numeric(12,2) not null default 0,
  total_comissao numeric(12,2) not null default 0,
  total_estornos numeric(12,2) not null default 0,
  total_chargebacks numeric(12,2) not null default 0,
  total_liquido_repassar numeric(12,2) not null default 0,
  status public.coproducao_status_repasse_lote not null default 'aberto'::public.coproducao_status_repasse_lote,
  data_aprovacao timestamptz,
  data_pagamento timestamptz,
  forma_pagamento text,
  comprovante_url text,
  observacoes text,
  -- colunas-padrão GLOP (created_by original preservado como coluna-padrão c/ FK auth.users)
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists coproducao_repasses_company_idx on public.coproducao_repasses(company_id) where deleted_at is null;
create index if not exists coproducao_repasses_coprodutor_idx on public.coproducao_repasses(coprodutor_id);

-- ── coproducao_repasse_itens (vendas que compõem cada lote de repasse) ────────
create table if not exists public.coproducao_repasse_itens (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  repasse_id uuid not null references public.coproducao_repasses(id),
  venda_id uuid not null references public.coproducao_vendas(id),
  valor_comissao numeric(12,2) not null,
  -- colunas-padrão GLOP (original só tinha created_at; updated_at add p/ padrão)
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists coproducao_repasse_itens_company_idx on public.coproducao_repasse_itens(company_id) where deleted_at is null;
create index if not exists coproducao_repasse_itens_repasse_idx on public.coproducao_repasse_itens(repasse_id);
create index if not exists coproducao_repasse_itens_venda_idx on public.coproducao_repasse_itens(venda_id);

-- ── coproducao_auditoria (trilha de auditoria do módulo de coprodução) ────────
create table if not exists public.coproducao_auditoria (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis) — usuario_id mantido como uuid livre (fidelidade)
  usuario_id uuid,
  acao text not null,
  entidade text,
  entidade_id text,
  dados_anteriores jsonb,
  dados_novos jsonb,
  -- colunas-padrão GLOP (original só tinha created_at; updated_at add p/ padrão)
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists coproducao_auditoria_company_idx on public.coproducao_auditoria(company_id) where deleted_at is null;

-- ── coproducao_webhook_logs (logs de webhooks yampi/appmax → integração) ──────
create table if not exists public.coproducao_webhook_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  origem public.coproducao_origem not null,
  evento text,
  pedido_id text,
  transacao_id text,
  status text not null default 'recebido',
  payload jsonb,
  processado boolean not null default false,
  erro text,
  tentativas integer not null default 0,
  venda_id uuid references public.coproducao_vendas(id),
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists coproducao_webhook_logs_company_idx on public.coproducao_webhook_logs(company_id) where deleted_at is null;
create index if not exists coproducao_webhook_logs_venda_idx on public.coproducao_webhook_logs(venda_id);

-- ── appmax_split_config (config OAuth do split real Appmax — singleton lógico) ─
create table if not exists public.appmax_split_config (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis) — active original preservado
  environment text not null default 'production',
  client_id text,
  client_secret text,
  logistics_recipient_id text,
  logistics_recipient_name text,
  logistics_recipient_document text,
  recipient_status text,
  active boolean not null default true,
  app_id text,
  redirect_uri text,
  oauth_access_token text,
  oauth_refresh_token text,
  oauth_token_expires_at timestamptz,
  oauth_state text,
  oauth_connected_at timestamptz,
  constraint appmax_split_config_environment_check
    check ((environment = any (array['sandbox'::text, 'production'::text]))),
  -- colunas-padrão GLOP (active já acima)
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists appmax_split_config_company_idx on public.appmax_split_config(company_id) where deleted_at is null;

-- ── appmax_split_logs (conciliação de frete/split por transação Appmax) ───────
create table if not exists public.appmax_split_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  environment text,
  event_type text,
  appmax_order_id text,
  codigo_venda text,
  valor_total numeric(12,2),
  valor_produto numeric(12,2),
  valor_frete numeric(12,2),
  logistics_recipient_id text,
  split_status text not null default 'pendente',
  divergence_reason text,
  payment_status text,
  payload_raw jsonb,
  error_message text,
  constraint appmax_split_logs_split_status_check
    check ((split_status = any (array['ok'::text, 'divergente'::text, 'sem_frete'::text, 'erro'::text, 'pendente'::text]))),
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists appmax_split_logs_company_idx on public.appmax_split_logs(company_id) where deleted_at is null;

-- ── Triggers touch/audit (padrão GLOP) ───────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array[
    'coprodutores','coproducao_configuracoes','coproducao_regras','coproducao_vendas',
    'coproducao_repasses','coproducao_repasse_itens','coproducao_auditoria',
    'coproducao_webhook_logs','appmax_split_config','appmax_split_logs'
  ] loop
    execute format('drop trigger if exists trg_%s_touch on public.%s', t, t);
    execute format('create trigger trg_%s_touch before insert or update on public.%s for each row execute function app.tg_touch_row()', t, t);
    execute format('drop trigger if exists trg_%s_audit on public.%s', t, t);
    execute format('create trigger trg_%s_audit after insert or update or delete on public.%s for each row execute function app.tg_write_audit()', t, t);
  end loop;
end $$;

-- ── RLS por company (padrão GLOP) — resource 'purchasing' (coprodução/split) ──
do $$ declare t text;
begin
  foreach t in array array[
    'coprodutores','coproducao_configuracoes','coproducao_regras','coproducao_vendas',
    'coproducao_repasses','coproducao_repasse_itens','coproducao_auditoria',
    'appmax_split_config','appmax_split_logs'
  ] loop
    execute format('alter table public.%s enable row level security', t);
    execute format($f$create policy %1$s_select on public.%1$s for select to authenticated
      using (app.is_superadmin() or company_id in (select app.user_company_ids()))$f$, t);
    execute format($f$create policy %1$s_insert on public.%1$s for insert to authenticated
      with check (app.can_access_company(company_id) and app.has_permission('purchasing.create', company_id))$f$, t);
    execute format($f$create policy %1$s_update on public.%1$s for update to authenticated
      using (app.can_access_company(company_id) and app.has_permission('purchasing.update', company_id))
      with check (app.can_access_company(company_id))$f$, t);
    execute format($f$create policy %1$s_delete on public.%1$s for delete to authenticated
      using (app.is_superadmin())$f$, t);
  end loop;
exception when duplicate_object then null;
end $$;

-- ── RLS por company — resource 'integration' (webhooks) ──────────────────────
do $$ declare t text;
begin
  foreach t in array array['coproducao_webhook_logs'] loop
    execute format('alter table public.%s enable row level security', t);
    execute format($f$create policy %1$s_select on public.%1$s for select to authenticated
      using (app.is_superadmin() or company_id in (select app.user_company_ids()))$f$, t);
    execute format($f$create policy %1$s_insert on public.%1$s for insert to authenticated
      with check (app.can_access_company(company_id) and app.has_permission('integration.create', company_id))$f$, t);
    execute format($f$create policy %1$s_update on public.%1$s for update to authenticated
      using (app.can_access_company(company_id) and app.has_permission('integration.update', company_id))
      with check (app.can_access_company(company_id))$f$, t);
    execute format($f$create policy %1$s_delete on public.%1$s for delete to authenticated
      using (app.is_superadmin())$f$, t);
  end loop;
exception when duplicate_object then null;
end $$;
