-- ════════════════════════════════════════════════════════════════════════════
-- IMPORTAÇÃO "Logística Rodrigo" (lemonlog) → GLOP  ·  M2 — PEDIDOS & VENDAS
-- ════════════════════════════════════════════════════════════════════════════
-- Porta o núcleo transacional do Rodrigo: pedidos logísticos, importações de
-- pedidos (manual/xls), logs de avaliação de regra logística, e as vendas de
-- cada plataforma (Monetizze webhook, Braip xls, Mercado Livre) + tokens ML.
--
-- Fiel ao original: TODAS as colunas, tipos e defaults preservados, nomes em
-- português mantidos. Melhorias = padrão GLOP por cima (tenant_id/company_id,
-- auditoria, RLS por company via app.*, triggers touch/audit, índices).
--
-- IDs numéricos originais (bigint/integer) são preservados fielmente; onde havia
-- sequence own, migramos para IDENTITY (mesma semântica, adaptação GLOP).
-- produtor_id vira FK real → public.produtores_integracao(id) onde a coluna existe.
-- produtores_integracao/produtor_usuarios/user_roles já vêm do M0 — só referenciados.
-- Ver docs/rodrigo-import/PLANO-IMPORTACAO.md.  Nada removido; melhorias = padrão GLOP.
-- ════════════════════════════════════════════════════════════════════════════

-- ── Enum de negócio (já criado no M0; garantido aqui de forma idempotente) ────
do $$ begin
  create type public.status_logistico_enum as enum
    ('pre_postado','postado','em_transito','saiu_para_entrega','entregue',
     'atraso','problema_na_entrega','devolucao','cancelado','erro');
exception when duplicate_object then null; end $$;

-- ════════════════════════════════════════════════════════════════════════════
-- pedido_regra_logs — auditoria de avaliação de regra/contrato logístico
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists public.pedido_regra_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  produtor_id uuid references public.produtores_integracao(id),
  pedido_id uuid,
  regra_logistica_id uuid,
  contrato_logistico_id uuid,
  origem text not null,
  payload_avaliacao jsonb,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists pedido_regra_logs_company_idx on public.pedido_regra_logs(company_id) where deleted_at is null;
create index if not exists pedido_regra_logs_produtor_idx on public.pedido_regra_logs(produtor_id);
create index if not exists pedido_regra_logs_pedido_idx on public.pedido_regra_logs(pedido_id);
create index if not exists pedido_regra_logs_regra_idx on public.pedido_regra_logs(regra_logistica_id);
create index if not exists pedido_regra_logs_contrato_idx on public.pedido_regra_logs(contrato_logistico_id);

-- ════════════════════════════════════════════════════════════════════════════
-- pedidos — pedido logístico (rastreio Correios / transportadora externa)
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists public.pedidos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  produtor_id uuid references public.produtores_integracao(id),
  cliente_nome text,
  cliente_documento text,
  produto_nome text,
  codigo_rastreio text,
  id_prepostagem text,
  status_logistico public.status_logistico_enum not null default 'pre_postado'::public.status_logistico_enum,
  data_prepostagem timestamptz,
  data_postagem timestamptz,
  data_em_transito timestamptz,
  data_saiu_para_entrega timestamptz,
  data_entrega timestamptz,
  data_ultima_atualizacao timestamptz,
  previsao_entrega timestamptz,
  cidade_destino text,
  uf_destino text,
  servico_correios text,
  venda_id bigint,
  plataforma text,
  cliente_email text,
  cliente_telefone text,
  valor_venda numeric,
  codigo_venda text,
  plano_nome text,
  data_venda timestamptz,
  contrato_logistico_id uuid,
  regra_logistica_id uuid,
  origem_regra_logistica text,
  nome_contrato_logistico text,
  agf_origem text,
  transportadora_aplicada text,
  transportadora_externa text,
  transportadora_externa_id text,
  transportadora_externa_status text,
  transportadora_externa_erro text,
  transportadora_externa_enviado_em timestamptz,
  transportadora_externa_payload jsonb,
  transportadora_externa_resposta jsonb,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
alter table public.pedidos replica identity full;  -- original: REPLICA IDENTITY FULL (realtime)
create index if not exists pedidos_company_idx on public.pedidos(company_id) where deleted_at is null;
create index if not exists pedidos_produtor_idx on public.pedidos(produtor_id);
create index if not exists pedidos_codigo_rastreio_idx on public.pedidos(codigo_rastreio);
create index if not exists pedidos_venda_id_idx on public.pedidos(venda_id);
create index if not exists pedidos_status_idx on public.pedidos(status_logistico);
create index if not exists pedidos_contrato_idx on public.pedidos(contrato_logistico_id);
create index if not exists pedidos_regra_idx on public.pedidos(regra_logistica_id);

-- ════════════════════════════════════════════════════════════════════════════
-- pedidos_importados — importação manual/planilha simples de envios
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists public.pedidos_importados (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  data_envio date,
  nome text not null,
  cep text,
  uf text,
  peso numeric,
  codigo_rastreio text,
  valor numeric,
  servico text,
  arquivo_origem text,
  email text,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists pedidos_importados_company_idx on public.pedidos_importados(company_id) where deleted_at is null;
create index if not exists pedidos_importados_rastreio_idx on public.pedidos_importados(codigo_rastreio);

-- ════════════════════════════════════════════════════════════════════════════
-- pedidos_xls — importação de pedidos via planilha (id bigint original)
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists public.pedidos_xls (
  id bigint generated by default as identity primary key,  -- original: bigint + sequence own
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  id_nf_e text,
  id_logistica text,
  id_redespacho text,
  integracao text,
  data_criacao text,
  cliente text,
  valor_frete numeric,
  valor_nota numeric,
  rastreio text,
  novo_rastreio text,
  etiqueta text,
  protocolo text,
  status text,
  logistica text,
  venda text,
  motivo_status text,
  arquivo_origem text,
  ultimo_status text,
  ultimo_status_detalhe text,
  ultimo_status_local text,
  ultimo_status_data timestamptz,
  ultima_consulta timestamptz,
  eventos_rastreio jsonb,
  regra_id bigint,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists pedidos_xls_company_idx on public.pedidos_xls(company_id) where deleted_at is null;
create index if not exists pedidos_xls_rastreio_idx on public.pedidos_xls(rastreio);
create index if not exists pedidos_xls_regra_idx on public.pedidos_xls(regra_id);

-- ════════════════════════════════════════════════════════════════════════════
-- monetizze_vendas — vendas recebidas via webhook Monetizze (id bigint original)
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists public.monetizze_vendas (
  id bigint generated by default as identity primary key,  -- original: bigint + sequence own
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  codigo_venda text,
  codigo_transacao text,
  status text,
  tipo_evento text,
  produto_codigo text,
  produto_nome text,
  plano_codigo text,
  plano_nome text,
  comprador_nome text,
  comprador_email text,
  comprador_telefone text,
  comprador_cpf text,
  comprador_cep text,
  comprador_endereco text,
  comprador_numero text,
  comprador_complemento text,
  comprador_bairro text,
  comprador_cidade text,
  comprador_estado text,
  valor numeric,
  valor_comissao numeric,
  forma_pagamento text,
  parcelas integer,
  data_inicio timestamptz,
  data_finalizada timestamptz,
  assinatura_codigo text,
  assinatura_status text,
  codigo_rastreio text,
  payload_completo jsonb not null,
  ip_origem text,
  produtor_id uuid references public.produtores_integracao(id),
  transacao_invalida boolean not null default false,
  notazz_document_id text,
  plataforma text not null default 'monetizze'::text,
  origem_webhook boolean not null default false,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
alter table public.monetizze_vendas replica identity full;  -- original: REPLICA IDENTITY FULL (realtime)
create index if not exists monetizze_vendas_company_idx on public.monetizze_vendas(company_id) where deleted_at is null;
create index if not exists monetizze_vendas_produtor_idx on public.monetizze_vendas(produtor_id);
create index if not exists monetizze_vendas_codigo_venda_idx on public.monetizze_vendas(codigo_venda);
create index if not exists monetizze_vendas_codigo_transacao_idx on public.monetizze_vendas(codigo_transacao);
create index if not exists monetizze_vendas_rastreio_idx on public.monetizze_vendas(codigo_rastreio);

-- ════════════════════════════════════════════════════════════════════════════
-- braip_vendas_xls — vendas Braip importadas via planilha (id bigint original)
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists public.braip_vendas_xls (
  id bigint generated by default as identity primary key,  -- original: bigint + sequence own
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  chave text,
  produtor text,
  produto text,
  plano text,
  comprador text,
  email text,
  telefone text,
  cep text,
  endereco text,
  numero text,
  complemento text,
  bairro text,
  cidade text,
  estado text,
  documento text,
  parcelamento integer,
  pagamento text,
  status text,
  valor numeric,
  valor_pago numeric,
  comissao numeric,
  data_venda timestamptz,
  data_pagamento timestamptz,
  afiliado text,
  afiliado_email text,
  tipo_frete text,
  valor_frete numeric,
  pagamento_na_entrega text,
  codigo_rastreio text,
  arquivo_origem text,
  ultimo_status text,
  ultimo_status_local text,
  ultimo_status_data timestamptz,
  ultima_consulta timestamptz,
  eventos_rastreio jsonb,
  erro_consulta text,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists braip_vendas_xls_company_idx on public.braip_vendas_xls(company_id) where deleted_at is null;
create index if not exists braip_vendas_xls_chave_idx on public.braip_vendas_xls(chave);
create index if not exists braip_vendas_xls_rastreio_idx on public.braip_vendas_xls(codigo_rastreio);

-- ════════════════════════════════════════════════════════════════════════════
-- vendas_ml — vendas Mercado Livre (id bigint original; mantém criado_em original)
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists public.vendas_ml (
  id bigint generated by default as identity primary key,  -- original: bigint + sequence own
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  ml_order_id bigint not null,
  status text,
  total numeric,
  comprador text,
  itens jsonb,
  pago_em timestamptz,
  raw jsonb,
  criado_em timestamptz not null default now(),
  nome_completo text,
  email text,
  telefone text,
  cpf_cnpj text,
  endereco jsonb,
  shipping_id bigint,
  shipping_raw jsonb,
  billing_raw jsonb,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists vendas_ml_company_idx on public.vendas_ml(company_id) where deleted_at is null;
create index if not exists vendas_ml_order_id_idx on public.vendas_ml(ml_order_id);
create index if not exists vendas_ml_shipping_id_idx on public.vendas_ml(shipping_id);

-- ════════════════════════════════════════════════════════════════════════════
-- ml_tokens — tokens OAuth Mercado Livre (linha única por integração no original)
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists public.ml_tokens (
  id integer not null default 1,  -- original: integer default 1
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  access_token text,
  refresh_token text,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  constraint ml_tokens_single_row check (id = 1),  -- original: CHECK (id = 1)
  primary key (id)
);
create index if not exists ml_tokens_company_idx on public.ml_tokens(company_id) where deleted_at is null;

-- ── Triggers touch/audit (padrão GLOP) ───────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array['pedido_regra_logs','pedidos','pedidos_importados','pedidos_xls',
                           'monetizze_vendas','braip_vendas_xls','vendas_ml','ml_tokens'] loop
    execute format('drop trigger if exists trg_%s_touch on public.%s', t, t);
    execute format('create trigger trg_%s_touch before insert or update on public.%s for each row execute function app.tg_touch_row()', t, t);
    execute format('drop trigger if exists trg_%s_audit on public.%s', t, t);
    execute format('create trigger trg_%s_audit after insert or update or delete on public.%s for each row execute function app.tg_write_audit()', t, t);
  end loop;
end $$;

-- ── RLS por company (padrão GLOP) — resource por tabela ──────────────────────
--   pedidos/importações/vendas/tokens → 'integration' (webhooks/pedidos)
--   pedido_regra_logs → 'shipping' (regra/contrato logístico)
do $$
declare
  arr text[][] := array[
    ['pedido_regra_logs','shipping'],
    ['pedidos','integration'],
    ['pedidos_importados','integration'],
    ['pedidos_xls','integration'],
    ['monetizze_vendas','integration'],
    ['braip_vendas_xls','integration'],
    ['vendas_ml','integration'],
    ['ml_tokens','integration']
  ];
  i int; t text; r text;
begin
  for i in 1 .. array_length(arr,1) loop
    t := arr[i][1]; r := arr[i][2];
    execute format('alter table public.%s enable row level security', t);
    execute format($f$create policy %1$s_select on public.%1$s for select to authenticated
      using (app.is_superadmin() or company_id in (select app.user_company_ids()))$f$, t);
    execute format($f$create policy %1$s_insert on public.%1$s for insert to authenticated
      with check (app.can_access_company(company_id) and app.has_permission('%2$s.create', company_id))$f$, t, r);
    execute format($f$create policy %1$s_update on public.%1$s for update to authenticated
      using (app.can_access_company(company_id) and app.has_permission('%2$s.update', company_id))
      with check (app.can_access_company(company_id))$f$, t, r);
    execute format($f$create policy %1$s_delete on public.%1$s for delete to authenticated
      using (app.is_superadmin())$f$, t);
  end loop;
exception when duplicate_object then null;
end $$;
