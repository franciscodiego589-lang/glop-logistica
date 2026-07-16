-- ═══════════════════════════════════════════════════════════════════
-- IMPORTAÇÃO LOGÍSTICA RODRIGO → GLOP (migrations 090–102, M0–M12)
-- Cole TUDO isto no SQL Editor do Supabase e clique RUN (uma vez).
-- Validado: aplica 100% sem erro (69 tabelas, 10 enums, 276 policies, 345 triggers).
-- ═══════════════════════════════════════════════════════════════════

-- ══════════ 20260713000090_import_rodrigo_m0_fundacao.sql ══════════
-- ════════════════════════════════════════════════════════════════════════════
-- IMPORTAÇÃO "Logística Rodrigo" (lemonlog) → GLOP  ·  M0 — FUNDAÇÃO
-- ════════════════════════════════════════════════════════════════════════════
-- Porta enums + produtores + vínculo user↔produtor + roles + API keys do produtor.
-- Fiel ao original (todas as colunas) + padrão GLOP por cima: tenant_id/company_id,
-- colunas de auditoria, RLS por company (app.*) e triggers touch/audit.
-- produtor = entidade de negócio sob company. Preserva produtor_id como dimensão.
-- Ver docs/rodrigo-import/PLANO-IMPORTACAO.md.  Nada removido; melhorias = padrão GLOP.
-- ════════════════════════════════════════════════════════════════════════════

-- ── Enums de negócio ────────────────────────────────────────────────────────
do $$ begin
  create type public.app_role as enum ('admin','user','produtor','estoque_user');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.status_logistico_enum as enum
    ('pre_postado','postado','em_transito','saiu_para_entrega','entregue',
     'atraso','problema_na_entrega','devolucao','cancelado','erro');
exception when duplicate_object then null; end $$;

-- ── produtores_integracao (mestre do produtor + chaves de integração/fiscal) ──
create table if not exists public.produtores_integracao (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  nome text not null,
  plataforma text not null default 'monetizze',
  webhook_token text not null default (gen_random_uuid())::text,
  ativo boolean not null default true,
  consumer_key text not null default (gen_random_uuid())::text,
  monetizze_api_key text,
  monetizze_logistica_key text,
  monetizze_ativa boolean not null default true,
  braip_api_token text,
  braip_webhook_secret text default (gen_random_uuid())::text,
  braip_ativa boolean not null default false,
  correios_webhook_secret text default (gen_random_uuid())::text,
  vhsys_cliente_id text,
  vhsys_id_almoxarifado integer,
  vhsys_produtos jsonb not null default '[]'::jsonb,
  vhsys_id_local_estoque integer,
  sislog_ativa boolean not null default false,
  sislog_cnpj_embarcador text,
  sislog_ufs text[] not null default '{}'::text[],
  aceitar_vendas_sem_plano boolean not null default false,
  -- fiscal / emitente
  cnpj text, razao_social text, inscricao_estadual text,
  endereco text, endereco_numero text, endereco_complemento text, endereco_bairro text,
  endereco_cidade text, endereco_estado text, endereco_cep text,
  email_fiscal text, telefone_fiscal text,
  emissao_nfe_ativa boolean not null default false,
  nfe_obs_complementar text, nfe_natureza_operacao text, nfe_cfop text,
  nfe_frete_por_conta smallint, nfe_chave_referenciada text,
  -- armazém
  armazem_nome text, armazem_cnpj text, armazem_inscricao_est text,
  armazem_endereco text, armazem_endereco_numero text, armazem_endereco_complemento text,
  armazem_endereco_bairro text, armazem_endereco_cidade text, armazem_endereco_estado text,
  armazem_endereco_cep text,
  valor_frete numeric not null default 0,
  peso_produto numeric not null default 0,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists produtores_integracao_company_idx on public.produtores_integracao(company_id) where deleted_at is null;
create index if not exists produtores_integracao_consumer_key_idx on public.produtores_integracao(consumer_key);

-- ── produtor_usuarios (vínculo user ↔ produtor) ──────────────────────────────
create table if not exists public.produtor_usuarios (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  user_id uuid not null references auth.users(id) on delete cascade,
  produtor_id uuid not null references public.produtores_integracao(id) on delete cascade,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists produtor_usuarios_user_idx on public.produtor_usuarios(user_id);
create index if not exists produtor_usuarios_produtor_idx on public.produtor_usuarios(produtor_id);

-- ── produtor_api_keys (chaves de API do produtor, com hash) ───────────────────
create table if not exists public.produtor_api_keys (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  produtor_id uuid not null references public.produtores_integracao(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  nome text not null,
  key_prefix text not null,
  key_hash text not null,
  escopos text[] not null default array['vendas:read','pedidos:read'],
  ativo boolean not null default true,
  last_used_at timestamptz, revoked_at timestamptz,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists produtor_api_keys_produtor_idx on public.produtor_api_keys(produtor_id);
create index if not exists produtor_api_keys_prefix_idx on public.produtor_api_keys(key_prefix);

-- ── user_roles (RBAC simples do lemonlog, preservado) ────────────────────────
create table if not exists public.user_roles (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.app_role not null,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  unique (user_id, role)
);
create index if not exists user_roles_user_idx on public.user_roles(user_id);

-- ── Funções preservadas (adaptadas ao padrão de segurança) ───────────────────
create or replace function public.current_produtor_id()
returns uuid language sql stable security definer set search_path = public as $$
  select produtor_id from public.produtor_usuarios
   where user_id = auth.uid() and deleted_at is null limit 1
$$;

create or replace function public.has_role(_user_id uuid, _role public.app_role)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.user_roles
                  where user_id = _user_id and role = _role and deleted_at is null)
$$;

-- ── Triggers touch/audit (padrão GLOP) ───────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array['produtores_integracao','produtor_usuarios','produtor_api_keys','user_roles'] loop
    execute format('drop trigger if exists trg_%s_touch on public.%s', t, t);
    execute format('create trigger trg_%s_touch before insert or update on public.%s for each row execute function app.tg_touch_row()', t, t);
    execute format('drop trigger if exists trg_%s_audit on public.%s', t, t);
    execute format('create trigger trg_%s_audit after insert or update or delete on public.%s for each row execute function app.tg_write_audit()', t, t);
  end loop;
end $$;

-- ── RLS por company (padrão GLOP) ────────────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array['produtores_integracao','produtor_usuarios','produtor_api_keys','user_roles'] loop
    execute format('alter table public.%s enable row level security', t);
    execute format($f$create policy %1$s_select on public.%1$s for select to authenticated
      using (app.is_superadmin() or company_id in (select app.user_company_ids()))$f$, t);
    execute format($f$create policy %1$s_insert on public.%1$s for insert to authenticated
      with check (app.can_access_company(company_id) and app.has_permission('admin.create', company_id))$f$, t);
    execute format($f$create policy %1$s_update on public.%1$s for update to authenticated
      using (app.can_access_company(company_id) and app.has_permission('admin.update', company_id))
      with check (app.can_access_company(company_id))$f$, t);
    execute format($f$create policy %1$s_delete on public.%1$s for delete to authenticated
      using (app.is_superadmin())$f$, t);
  end loop;
exception when duplicate_object then null;
end $$;

-- ══════════ 20260713000091_import_rodrigo_m1_planos_precos.sql ══════════
-- ════════════════════════════════════════════════════════════════════════════
-- IMPORTAÇÃO "Logística Rodrigo" (lemonlog) → GLOP  ·  M1 — PLANOS & PREÇOS
-- ════════════════════════════════════════════════════════════════════════════
-- Porta as regras de produto (peso/dimensões/faixas), planos por plataforma,
-- tabelas de preço (por produtor e por produto) e as faixas de frete/peso.
-- Fiel ao original (todas as colunas, tipos, defaults, checks e comentários)
-- + padrão GLOP por cima: tenant_id/company_id/branch_id, colunas de auditoria,
-- RLS por company (app.*) e triggers touch/audit.
-- produtor_id uuid references public.produtores_integracao(id) (mestre no M0).
-- Nada removido; melhorias = padrão GLOP. Ver docs/rodrigo-import/PLANO-IMPORTACAO.md.
-- ════════════════════════════════════════════════════════════════════════════

-- ── Enums de negócio ─────────────────────────────────────────────────────────
-- (Este módulo não introduz enums próprios — plataforma/plano_codigo são text no
--  original e mantidos como text por fidelidade.)

-- ── produto_regras (catálogo global de regras de embalagem/prepostagem) ───────
-- Original SEM produtor_id (tabela global) e com id BIGINT (referenciado por
-- produtor_planos.regra_id como bigint). Preservamos o tipo bigint para não
-- quebrar a FK; usamos identity no lugar da sequence owned original.
create table if not exists public.produto_regras (
  -- id original (bigint, PK) — mantido por fidelidade e por causa da FK regra_id
  id bigint generated by default as identity primary key,
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  nome text not null,
  palavras_chave text[] not null default '{}'::text[],
  peso_unitario_g numeric not null default 0,
  altura_cm numeric not null default 2,
  largura_cm numeric not null default 11,
  comprimento_cm numeric not null default 16,
  valor_declarado_padrao numeric,
  faixas jsonb not null default '[]'::jsonb,
  ativo boolean not null default true,
  is_fallback boolean not null default false,
  itens_planos jsonb not null default '[]'::jsonb,
  enviar_sislogica boolean not null default true,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
comment on column public.produto_regras.enviar_sislogica is 'Quando false, produtos que casarem com esta regra não serão enviados para a SisLogica (automático e manual).';
create index if not exists produto_regras_company_idx on public.produto_regras(company_id) where deleted_at is null;

-- ── produtor_planos (planos por produtor/plataforma → regra + prepostagem) ────
create table if not exists public.produtor_planos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  produtor_id uuid not null references public.produtores_integracao(id),
  -- campos originais (fiéis)
  plano_codigo text not null,
  plano_nome_amigavel text,
  regra_id bigint references public.produto_regras(id),
  gerar_prepostagem_auto boolean not null default false,
  ativo boolean not null default true,
  plataforma text not null default 'monetizze'::text,
  atualizar_rastreio_auto boolean not null default false,
  contrato_logistico_padrao_id uuid,
  unidades integer not null default 1,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
comment on column public.produtor_planos.unidades is 'Quantos frascos/itens este plano representa. Usado para somar quantidades de upsells/order bumps em uma mesma venda.';
create index if not exists produtor_planos_company_idx on public.produtor_planos(company_id) where deleted_at is null;
create index if not exists produtor_planos_produtor_idx on public.produtor_planos(produtor_id);
create index if not exists produtor_planos_regra_idx on public.produtor_planos(regra_id);

-- ── produtor_produto_precos (preço unitário por código de produto do produtor) ─
create table if not exists public.produtor_produto_precos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  produtor_id uuid not null references public.produtores_integracao(id),
  -- campos originais (fiéis)
  produto_codigo text not null,
  produto_nome text,
  valor_unitario numeric not null,
  ativo boolean not null default true,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists produtor_produto_precos_company_idx on public.produtor_produto_precos(company_id) where deleted_at is null;
create index if not exists produtor_produto_precos_produtor_idx on public.produtor_produto_precos(produtor_id);

-- ── produto_precos (tabela de preço por faixa de quantidade + link Asaas) ─────
create table if not exists public.produto_precos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  produtor_id uuid not null references public.produtores_integracao(id),
  -- campos originais (fiéis)
  produto_nome text not null,
  quantidade_min integer not null default 1,
  quantidade_max integer not null default 1,
  preco_unitario numeric not null,
  link_asaas text,
  ativo boolean not null default true,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists produto_precos_company_idx on public.produto_precos(company_id) where deleted_at is null;
create index if not exists produto_precos_produtor_idx on public.produto_precos(produtor_id);

-- ── produtor_frete_faixas (valor de frete por faixa de quantidade) ────────────
create table if not exists public.produtor_frete_faixas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  produtor_id uuid not null references public.produtores_integracao(id),
  -- campos originais (fiéis)
  qtd_min integer not null,
  qtd_max integer not null,
  valor numeric(10,2) not null,
  observacao text,
  ativo boolean not null default true,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  -- checks originais preservados
  constraint produtor_frete_faixas_check check (qtd_max >= qtd_min),
  constraint produtor_frete_faixas_qtd_min_check check (qtd_min >= 1),
  constraint produtor_frete_faixas_valor_check check (valor >= (0)::numeric)
);
create index if not exists produtor_frete_faixas_company_idx on public.produtor_frete_faixas(company_id) where deleted_at is null;
create index if not exists produtor_frete_faixas_produtor_idx on public.produtor_frete_faixas(produtor_id);

-- ── produtor_peso_faixas (peso total por faixa de quantidade) ─────────────────
create table if not exists public.produtor_peso_faixas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  produtor_id uuid not null references public.produtores_integracao(id),
  -- campos originais (fiéis)
  qtd_min integer not null,
  qtd_max integer not null,
  peso_total numeric(10,3) not null,
  observacao text,
  ativo boolean not null default true,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  -- checks originais preservados
  constraint produtor_peso_faixas_check check (qtd_max >= qtd_min),
  constraint produtor_peso_faixas_peso_total_check check (peso_total >= (0)::numeric),
  constraint produtor_peso_faixas_qtd_max_check check (qtd_max >= 1),
  constraint produtor_peso_faixas_qtd_min_check check (qtd_min >= 1)
);
create index if not exists produtor_peso_faixas_company_idx on public.produtor_peso_faixas(company_id) where deleted_at is null;
create index if not exists produtor_peso_faixas_produtor_idx on public.produtor_peso_faixas(produtor_id);

-- ── Triggers touch/audit (padrão GLOP) ───────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array[
    'produto_regras','produtor_planos','produtor_produto_precos',
    'produto_precos','produtor_frete_faixas','produtor_peso_faixas'
  ] loop
    execute format('drop trigger if exists trg_%s_touch on public.%s', t, t);
    execute format('create trigger trg_%s_touch before insert or update on public.%s for each row execute function app.tg_touch_row()', t, t);
    execute format('drop trigger if exists trg_%s_audit on public.%s', t, t);
    execute format('create trigger trg_%s_audit after insert or update or delete on public.%s for each row execute function app.tg_write_audit()', t, t);
  end loop;
end $$;

-- ── RLS por company (padrão GLOP) ────────────────────────────────────────────
-- Recurso por tabela: preços/planos de logística = 'shipping' (correios/frete/peso/
-- prepostagem); planos e tabelas de preço puro sem afinidade específica = 'admin'.
do $$ declare rec text; t text; res text;
begin
  foreach rec in array array[
    'produto_regras:shipping',
    'produtor_planos:shipping',
    'produtor_frete_faixas:shipping',
    'produtor_peso_faixas:shipping',
    'produtor_produto_precos:admin',
    'produto_precos:admin'
  ] loop
    t   := split_part(rec, ':', 1);
    res := split_part(rec, ':', 2);
    execute format('alter table public.%s enable row level security', t);
    execute format($f$create policy %1$s_select on public.%1$s for select to authenticated
      using (app.is_superadmin() or company_id in (select app.user_company_ids()))$f$, t);
    execute format($f$create policy %1$s_insert on public.%1$s for insert to authenticated
      with check (app.can_access_company(company_id) and app.has_permission('%2$s.create', company_id))$f$, t, res);
    execute format($f$create policy %1$s_update on public.%1$s for update to authenticated
      using (app.can_access_company(company_id) and app.has_permission('%2$s.update', company_id))
      with check (app.can_access_company(company_id))$f$, t, res);
    execute format($f$create policy %1$s_delete on public.%1$s for delete to authenticated
      using (app.is_superadmin())$f$, t);
  end loop;
exception when duplicate_object then null;
end $$;

-- ══════════ 20260713000092_import_rodrigo_m2_pedidos_vendas.sql ══════════
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

-- ══════════ 20260713000093_import_rodrigo_m3_coproducao_split.sql ══════════
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

-- ══════════ 20260713000094_import_rodrigo_m4_correios_prepostagem.sql ══════════
-- ════════════════════════════════════════════════════════════════════════════
-- IMPORTAÇÃO "Logística Rodrigo" (lemonlog) → GLOP  ·  M4 — CORREIOS / PRÉ-POSTAGEM
-- ════════════════════════════════════════════════════════════════════════════
-- Porta o ciclo de pré-postagem e integração com os Correios: prepostagens (+ PPN),
-- logs de automação, prepostagem em massa, conferência de postagem, logs de API,
-- cache de token dos Correios e logs de correção de CEP.
-- Fiel ao original (TODAS as colunas, tipos e defaults) + padrão GLOP por cima:
-- tenant_id/company_id/branch_id, colunas de auditoria, RLS por company (app.*)
-- e triggers touch/audit. PKs originais preservadas (bigint/integer/uuid).
-- produtor_id → FK public.produtores_integracao(id) quando existir na origem.
-- Sem enums neste módulo (campos status/etapa são text livre no original).
-- Módulo classificado como resource 'shipping' (logística/correios/envios).
-- Ver docs/rodrigo-import/PLANO-IMPORTACAO.md. Nada removido; melhorias = padrão GLOP.
-- ════════════════════════════════════════════════════════════════════════════

-- ── prepostagens (pré-postagem gerada p/ os Correios + snapshot de rastreio) ──
create table if not exists public.prepostagens (
  id bigint generated by default as identity primary key,
  -- campos originais (fiéis)
  venda_id bigint,
  regra_id bigint,
  quantidade integer not null default 1,
  servico_codigo text not null,
  servico_nome text,
  peso_g numeric not null,
  altura_cm numeric not null,
  largura_cm numeric not null,
  comprimento_cm numeric not null,
  valor_declarado numeric,
  destinatario_nome text,
  destinatario_cep text,
  destinatario_endereco text,
  destinatario_cidade text,
  destinatario_estado text,
  codigo_objeto text,
  id_prepostagem text,
  etiqueta_pdf_base64 text,
  status text not null default 'pendente',
  erro text,
  payload_request jsonb,
  payload_response jsonb,
  ultimo_status text,
  ultimo_status_data timestamptz,
  ultimo_status_local text,
  ultima_consulta timestamptz,
  eventos_rastreio jsonb,
  -- colunas-padrão GLOP
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  deleted_by uuid references auth.users(id),
  reason_deleted text,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id)
);
alter table public.prepostagens replica identity full;
create index if not exists prepostagens_company_idx on public.prepostagens(company_id) where deleted_at is null;
create index if not exists prepostagens_venda_idx on public.prepostagens(venda_id);
create index if not exists prepostagens_codigo_objeto_idx on public.prepostagens(codigo_objeto);
create index if not exists prepostagens_status_idx on public.prepostagens(status);

-- ── prepostagens_ppn (espelho da Plataforma Pré-Postagem Nacional / PPN) ──────
create table if not exists public.prepostagens_ppn (
  id bigint generated by default as identity primary key,
  -- campos originais (fiéis)
  id_prepostagem text not null,
  codigo_objeto text,
  destinatario_nome text,
  data_postagem timestamptz,
  data_criacao timestamptz,
  data_expiracao timestamptz,
  status text not null,
  servico_codigo text,
  servico_nome text,
  destinatario_cidade text,
  destinatario_estado text,
  destinatario_cep text,
  valor_total numeric,
  payload_completo jsonb,
  ultima_sincronizacao timestamptz not null default now(),
  ultimo_status text,
  ultimo_status_data timestamptz,
  ultimo_status_local text,
  ultima_consulta_sro timestamptz,
  eventos_rastreio jsonb,
  -- colunas-padrão GLOP
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  deleted_by uuid references auth.users(id),
  reason_deleted text,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id)
);
alter table public.prepostagens_ppn replica identity full;
create index if not exists prepostagens_ppn_company_idx on public.prepostagens_ppn(company_id) where deleted_at is null;
create index if not exists prepostagens_ppn_id_prepostagem_idx on public.prepostagens_ppn(id_prepostagem);
create index if not exists prepostagens_ppn_codigo_objeto_idx on public.prepostagens_ppn(codigo_objeto);

-- ── prepostagem_auto_logs (trilha da automação de pré-postagem por etapa) ─────
create table if not exists public.prepostagem_auto_logs (
  id bigint generated by default as identity primary key,
  -- campos originais (fiéis)
  produtor_id uuid references public.produtores_integracao(id),
  venda_id bigint,
  plataforma text,
  plano_codigo text,
  plano_id uuid,
  etapa text not null,
  status text not null,
  mensagem text,
  prepostagem_id bigint,
  codigo_objeto text,
  payload jsonb,
  -- colunas-padrão GLOP
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  deleted_by uuid references auth.users(id),
  reason_deleted text,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id)
);
create index if not exists prepostagem_auto_logs_company_idx on public.prepostagem_auto_logs(company_id) where deleted_at is null;
create index if not exists prepostagem_auto_logs_produtor_idx on public.prepostagem_auto_logs(produtor_id);
create index if not exists prepostagem_auto_logs_venda_idx on public.prepostagem_auto_logs(venda_id);
create index if not exists prepostagem_auto_logs_prepostagem_idx on public.prepostagem_auto_logs(prepostagem_id);

-- ── prep_massa_logs (log da geração de pré-postagens em massa por run_id) ──────
create table if not exists public.prep_massa_logs (
  id bigint generated by default as identity primary key,
  -- campos originais (fiéis)
  run_id uuid not null,
  produtor_id uuid references public.produtores_integracao(id),
  user_id uuid,
  venda_id bigint,
  codigo_venda text,
  comprador_nome text,
  servico_codigo text,
  servico_nome text,
  quantidade integer,
  valor_declarado numeric,
  peso_g numeric,
  altura_cm numeric,
  largura_cm numeric,
  comprimento_cm numeric,
  status text not null,
  mensagem text,
  detalhes jsonb,
  -- colunas-padrão GLOP
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  deleted_by uuid references auth.users(id),
  reason_deleted text,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id)
);
create index if not exists prep_massa_logs_company_idx on public.prep_massa_logs(company_id) where deleted_at is null;
create index if not exists prep_massa_logs_produtor_idx on public.prep_massa_logs(produtor_id);
create index if not exists prep_massa_logs_run_idx on public.prep_massa_logs(run_id);
create index if not exists prep_massa_logs_venda_idx on public.prep_massa_logs(venda_id);

-- ── conferencias_postagem (conferência planilha × PDF de postados) ────────────
create table if not exists public.conferencias_postagem (
  id uuid primary key default gen_random_uuid(),
  -- campos originais (fiéis)
  user_id uuid not null,
  produtor_id uuid references public.produtores_integracao(id),
  planilha_nome text,
  pdf_nome text,
  total_planilha integer not null default 0,
  total_postados integer not null default 0,
  total_nao_encontrados integer not null default 0,
  total_possiveis integer not null default 0,
  resultado jsonb not null default '[]'::jsonb,
  paginas_resumo jsonb not null default '[]'::jsonb,
  -- colunas-padrão GLOP
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  deleted_by uuid references auth.users(id),
  reason_deleted text,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id)
);
create index if not exists conferencias_postagem_company_idx on public.conferencias_postagem(company_id) where deleted_at is null;
create index if not exists conferencias_postagem_produtor_idx on public.conferencias_postagem(produtor_id);
create index if not exists conferencias_postagem_user_idx on public.conferencias_postagem(user_id);

-- ── correios_api_logs (trilha de chamadas à API dos Correios) ─────────────────
create table if not exists public.correios_api_logs (
  id bigint generated by default as identity primary key,
  -- campos originais (fiéis)
  prefixo text not null,
  acao text not null,
  status text not null,
  http_status integer,
  codigo_rastreio text,
  mensagem text,
  request_payload jsonb,
  response_payload jsonb,
  duracao_ms integer,
  -- colunas-padrão GLOP
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  deleted_by uuid references auth.users(id),
  reason_deleted text,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id)
);
create index if not exists correios_api_logs_company_idx on public.correios_api_logs(company_id) where deleted_at is null;
create index if not exists correios_api_logs_codigo_rastreio_idx on public.correios_api_logs(codigo_rastreio);
create index if not exists correios_api_logs_acao_idx on public.correios_api_logs(acao);

-- ── correios_token_cache (cache de tokens de autenticação dos Correios) ───────
create table if not exists public.correios_token_cache (
  id integer generated by default as identity primary key,
  -- campos originais (fiéis)
  tipo text not null,
  numero_cartao text,
  token text not null,
  expires_at timestamptz not null,
  refreshed_at timestamptz not null default now(),
  -- colunas-padrão GLOP
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  deleted_by uuid references auth.users(id),
  reason_deleted text,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id)
);
create index if not exists correios_token_cache_company_idx on public.correios_token_cache(company_id) where deleted_at is null;
create index if not exists correios_token_cache_tipo_idx on public.correios_token_cache(tipo);

-- ── cep_correcao_logs (auditoria de correção de CEP e envio ao SISLOG) ────────
create table if not exists public.cep_correcao_logs (
  id bigint generated by default as identity primary key,
  -- campos originais (fiéis)
  produtor_id uuid references public.produtores_integracao(id),
  venda_id bigint,
  pedido_id uuid,
  destino text,
  cep_original text,
  cep_corrigido text not null,
  fonte text,
  endereco_original jsonb,
  endereco_corrigido jsonb,
  enviado_sislog boolean not null default false,
  observacao text,
  -- colunas-padrão GLOP
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  deleted_by uuid references auth.users(id),
  reason_deleted text,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id)
);
create index if not exists cep_correcao_logs_company_idx on public.cep_correcao_logs(company_id) where deleted_at is null;
create index if not exists cep_correcao_logs_produtor_idx on public.cep_correcao_logs(produtor_id);
create index if not exists cep_correcao_logs_venda_idx on public.cep_correcao_logs(venda_id);
create index if not exists cep_correcao_logs_pedido_idx on public.cep_correcao_logs(pedido_id);

-- ── Triggers touch/audit (padrão GLOP) ───────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array[
    'prepostagens','prepostagens_ppn','prepostagem_auto_logs','prep_massa_logs',
    'conferencias_postagem','correios_api_logs','correios_token_cache','cep_correcao_logs'
  ] loop
    execute format('drop trigger if exists trg_%s_touch on public.%s', t, t);
    execute format('create trigger trg_%s_touch before insert or update on public.%s for each row execute function app.tg_touch_row()', t, t);
    execute format('drop trigger if exists trg_%s_audit on public.%s', t, t);
    execute format('create trigger trg_%s_audit after insert or update or delete on public.%s for each row execute function app.tg_write_audit()', t, t);
  end loop;
end $$;

-- ── RLS por company (padrão GLOP) — resource 'shipping' ───────────────────────
do $$ declare t text;
begin
  foreach t in array array[
    'prepostagens','prepostagens_ppn','prepostagem_auto_logs','prep_massa_logs',
    'conferencias_postagem','correios_api_logs','correios_token_cache','cep_correcao_logs'
  ] loop
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

-- ══════════ 20260713000095_import_rodrigo_m5_envios_rastreamento.sql ══════════
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

-- ══════════ 20260713000096_import_rodrigo_m6_reenvios.sql ══════════
-- ════════════════════════════════════════════════════════════════════════════
-- IMPORTAÇÃO "Logística Rodrigo" (lemonlog) → GLOP  ·  M6 — REENVIOS
-- ════════════════════════════════════════════════════════════════════════════
-- Porta reenvios (reenvio de objetos/postagens) + reenvio_pagamentos (cobrança
-- de reenvio via link Asaas). Fiel ao original (todas as colunas, tipos e
-- defaults) + padrão GLOP por cima: tenant_id/company_id/branch_id, colunas de
-- auditoria, RLS por company (app.*) e triggers touch/audit.
-- produtor_id preservado como dimensão -> public.produtores_integracao(id) (M0).
-- reenvios.id permanece bigint (identity) e reenvio_pagamentos.id permanece uuid
-- — fidelidade aos tipos de PK originais. Recurso RLS: 'shipping' (envios/reenvios).
-- Nada removido; melhorias = padrão GLOP. Ver docs/rodrigo-import/PLANO-IMPORTACAO.md.
-- ════════════════════════════════════════════════════════════════════════════

-- ── reenvios (reenvio de objeto: novo código de rastreio p/ uma venda) ────────
create table if not exists public.reenvios (
  -- PK original (bigint com sequence) preservada
  id bigint primary key generated by default as identity,
  -- colunas-padrão GLOP (multi-tenant)
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  produtor_id uuid not null references public.produtores_integracao(id),
  venda_id bigint,
  prepostagem_id bigint,
  codigo_objeto_original text,
  codigo_objeto_novo text,
  motivo text,
  status text not null default 'pendente'::text,
  observacao text,
  comprador_nome text,
  produto_nome text,
  destino_cidade text,
  destino_uf text,
  quantidade integer,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists reenvios_company_idx on public.reenvios(company_id) where deleted_at is null;
create index if not exists reenvios_produtor_idx on public.reenvios(produtor_id);
create index if not exists reenvios_venda_idx on public.reenvios(venda_id);
create index if not exists reenvios_prepostagem_idx on public.reenvios(prepostagem_id);

-- ── reenvio_pagamentos (cobrança de reenvio via link Asaas) ──────────────────
create table if not exists public.reenvio_pagamentos (
  -- PK original (uuid) preservada
  id uuid primary key default gen_random_uuid(),
  -- colunas-padrão GLOP (multi-tenant)
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  produtor_id uuid not null references public.produtores_integracao(id),
  reenvio_id bigint references public.reenvios(id),
  venda_id bigint,
  comprador_nome text,
  comprador_email text,
  quantidade integer not null,
  preco_total numeric not null,
  link_asaas text,
  status text not null default 'pendente'::text,
  email_enviado boolean not null default false,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists reenvio_pagamentos_company_idx on public.reenvio_pagamentos(company_id) where deleted_at is null;
create index if not exists reenvio_pagamentos_produtor_idx on public.reenvio_pagamentos(produtor_id);
create index if not exists reenvio_pagamentos_reenvio_idx on public.reenvio_pagamentos(reenvio_id);
create index if not exists reenvio_pagamentos_venda_idx on public.reenvio_pagamentos(venda_id);

-- ── Triggers touch/audit (padrão GLOP) ───────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array['reenvios','reenvio_pagamentos'] loop
    execute format('drop trigger if exists trg_%s_touch on public.%s', t, t);
    execute format('create trigger trg_%s_touch before insert or update on public.%s for each row execute function app.tg_touch_row()', t, t);
    execute format('drop trigger if exists trg_%s_audit on public.%s', t, t);
    execute format('create trigger trg_%s_audit after insert or update or delete on public.%s for each row execute function app.tg_write_audit()', t, t);
  end loop;
end $$;

-- ── RLS por company (padrão GLOP · recurso 'shipping') ───────────────────────
do $$ declare t text;
begin
  foreach t in array array['reenvios','reenvio_pagamentos'] loop
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

-- ══════════ 20260713000097_import_rodrigo_m7_estoque.sql ══════════
-- ════════════════════════════════════════════════════════════════════════════
-- IMPORTAÇÃO "Logística Rodrigo" (lemonlog) → GLOP  ·  M7 — ESTOQUE
-- ════════════════════════════════════════════════════════════════════════════
-- Porta o módulo de estoque próprio do Rodrigo: produtos, locais, movimentos,
-- config de baixa automática e o registro de estoque (conferência com IA/fotos).
-- Fiel ao original (todas as colunas, tipos e defaults) + padrão GLOP por cima:
-- tenant_id/company_id/branch_id, colunas de auditoria, RLS por company (app.*)
-- e triggers touch/audit. produtor_id preservado como dimensão de negócio,
-- referenciando public.produtores_integracao(id) já criado no M0.
-- Recurso RLS: 'inventory' (estoque).
-- Nada removido; melhorias = padrão GLOP. Ver docs/rodrigo-import/PLANO-IMPORTACAO.md.
-- ════════════════════════════════════════════════════════════════════════════

-- ── estoque_produtos (cadastro de produtos de estoque) ───────────────────────
create table if not exists public.estoque_produtos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  produtor_id uuid not null references public.produtores_integracao(id),
  nome text not null,
  codigo text,
  unidade text not null default 'UN'::text,
  categoria text,
  estoque_minimo numeric(14,3) not null default 0,
  valor_custo numeric(14,2),
  observacao text,
  ativo boolean not null default true,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists estoque_produtos_company_idx on public.estoque_produtos(company_id) where deleted_at is null;
create index if not exists estoque_produtos_produtor_idx on public.estoque_produtos(produtor_id);
create index if not exists estoque_produtos_codigo_idx on public.estoque_produtos(codigo);

-- ── estoque_locais (locais/almoxarifados de estoque) ─────────────────────────
create table if not exists public.estoque_locais (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  produtor_id uuid not null references public.produtores_integracao(id),
  nome text not null,
  descricao text,
  ativo boolean not null default true,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists estoque_locais_company_idx on public.estoque_locais(company_id) where deleted_at is null;
create index if not exists estoque_locais_produtor_idx on public.estoque_locais(produtor_id);

-- ── estoque_movimentos (movimentações de estoque) ────────────────────────────
create table if not exists public.estoque_movimentos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  produtor_id uuid not null references public.produtores_integracao(id),
  produto_id uuid not null references public.estoque_produtos(id),
  local_id uuid references public.estoque_locais(id),
  local_destino_id uuid references public.estoque_locais(id),
  tipo text not null,
  quantidade numeric(14,3) not null,
  valor_unitario numeric(14,2),
  observacao text,
  identificacao text,
  user_id uuid,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  -- constraints originais preservadas
  constraint estoque_movimentos_quantidade_check check ((quantidade > (0)::numeric)),
  constraint estoque_movimentos_tipo_check check ((tipo = any (array['entrada'::text, 'saida'::text, 'ajuste'::text, 'transferencia'::text])))
);
create index if not exists estoque_movimentos_company_idx on public.estoque_movimentos(company_id) where deleted_at is null;
create index if not exists estoque_movimentos_produtor_idx on public.estoque_movimentos(produtor_id);
create index if not exists estoque_movimentos_produto_idx on public.estoque_movimentos(produto_id);
create index if not exists estoque_movimentos_local_idx on public.estoque_movimentos(local_id);
create index if not exists estoque_movimentos_local_destino_idx on public.estoque_movimentos(local_destino_id);

-- ── estoque_baixa_config (config de baixa automática de estoque) ─────────────
-- Original sem PK; PK id adicionada como melhoria GLOP (obrigatória no padrão).
create table if not exists public.estoque_baixa_config (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  produtor_id uuid not null references public.produtores_integracao(id),
  ativo boolean not null default true,
  local_id uuid references public.estoque_locais(id),
  observacao text,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists estoque_baixa_config_company_idx on public.estoque_baixa_config(company_id) where deleted_at is null;
create index if not exists estoque_baixa_config_produtor_idx on public.estoque_baixa_config(produtor_id);
create index if not exists estoque_baixa_config_local_idx on public.estoque_baixa_config(local_id);

-- ── registro_estoque (conferência/registro de estoque com fotos + payload IA) ─
create table if not exists public.registro_estoque (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  produtor_id uuid not null references public.produtores_integracao(id),
  codigo_rastreio text,
  cliente_nome text,
  produto_nome text,
  quantidade integer,
  foto_etiqueta_url text,
  foto_declaracao_url text,
  pedido_id uuid,
  payload_ia jsonb,
  observacao text,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists registro_estoque_company_idx on public.registro_estoque(company_id) where deleted_at is null;
create index if not exists registro_estoque_produtor_idx on public.registro_estoque(produtor_id);
create index if not exists registro_estoque_pedido_idx on public.registro_estoque(pedido_id);
create index if not exists registro_estoque_rastreio_idx on public.registro_estoque(codigo_rastreio);

-- ── Triggers touch/audit (padrão GLOP) ───────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array['estoque_produtos','estoque_locais','estoque_movimentos','estoque_baixa_config','registro_estoque'] loop
    execute format('drop trigger if exists trg_%s_touch on public.%s', t, t);
    execute format('create trigger trg_%s_touch before insert or update on public.%s for each row execute function app.tg_touch_row()', t, t);
    execute format('drop trigger if exists trg_%s_audit on public.%s', t, t);
    execute format('create trigger trg_%s_audit after insert or update or delete on public.%s for each row execute function app.tg_write_audit()', t, t);
  end loop;
end $$;

-- ── RLS por company (padrão GLOP) — recurso 'inventory' ──────────────────────
do $$ declare t text;
begin
  foreach t in array array['estoque_produtos','estoque_locais','estoque_movimentos','estoque_baixa_config','registro_estoque'] loop
    execute format('alter table public.%s enable row level security', t);
    execute format($f$create policy %1$s_select on public.%1$s for select to authenticated
      using (app.is_superadmin() or company_id in (select app.user_company_ids()))$f$, t);
    execute format($f$create policy %1$s_insert on public.%1$s for insert to authenticated
      with check (app.can_access_company(company_id) and app.has_permission('inventory.create', company_id))$f$, t);
    execute format($f$create policy %1$s_update on public.%1$s for update to authenticated
      using (app.can_access_company(company_id) and app.has_permission('inventory.update', company_id))
      with check (app.can_access_company(company_id))$f$, t);
    execute format($f$create policy %1$s_delete on public.%1$s for delete to authenticated
      using (app.is_superadmin())$f$, t);
  end loop;
exception when duplicate_object then null;
end $$;

-- ══════════ 20260713000098_import_rodrigo_m8_vhsys.sql ══════════
-- ════════════════════════════════════════════════════════════════════════════
-- IMPORTAÇÃO "Logística Rodrigo" (lemonlog) → GLOP  ·  M8 — VHSYS / ESTOQUE
-- ════════════════════════════════════════════════════════════════════════════
-- Porta o subsistema de integração de estoque com a VHSYS:
--   vhsys_estoque_movimentos · vhsys_estoque_saldos · vhsys_locais_estoque
-- Fiel ao original (TODAS as colunas, tipos, defaults, PKs e CHECKs preservados)
-- + padrão GLOP por cima: tenant_id/company_id/branch_id, colunas de auditoria,
-- índices em company_id + FKs, RLS por company (app.*) e triggers touch/audit.
-- produtor_id preservado como dimensão → FK para public.produtores_integracao (M0).
-- Sem enums no módulo: o original usa CHECK constraints (tipo / tipo_item) — mantidos.
-- Ver docs/rodrigo-import/PLANO-IMPORTACAO.md. Nada removido; melhorias = padrão GLOP.
-- ════════════════════════════════════════════════════════════════════════════

-- ── Sequence do id bigint de movimentos (preservada do original) ─────────────
create sequence if not exists public.vhsys_estoque_movimentos_id_seq
  start with 1 increment by 1 no minvalue no maxvalue cache 1;

-- ── vhsys_estoque_movimentos (fila/log de movimentos de estoque na VHSYS) ─────
create table if not exists public.vhsys_estoque_movimentos (
  -- campos originais (fiéis)
  id bigint primary key default nextval('public.vhsys_estoque_movimentos_id_seq'::regclass),
  produto_vhsys_id bigint not null,
  produto_nome text,
  tipo text not null,
  quantidade numeric not null,
  valor_unitario numeric,
  observacao text,
  identificacao text,
  produtor_id uuid references public.produtores_integracao(id),
  user_id uuid references auth.users(id),
  vhsys_id_estoque bigint,
  status text not null default 'pendente'::text,
  erro text,
  payload_request jsonb,
  payload_response jsonb,
  created_at timestamptz not null default now(),
  -- colunas-padrão GLOP
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  -- CHECK original preservado
  constraint vhsys_estoque_movimentos_tipo_check
    check (tipo = any (array['Entrada'::text, 'Saida'::text]))
);
alter sequence public.vhsys_estoque_movimentos_id_seq owned by public.vhsys_estoque_movimentos.id;
create index if not exists vhsys_estoque_movimentos_company_idx on public.vhsys_estoque_movimentos(company_id) where deleted_at is null;
create index if not exists vhsys_estoque_movimentos_produtor_idx on public.vhsys_estoque_movimentos(produtor_id);
create index if not exists vhsys_estoque_movimentos_user_idx on public.vhsys_estoque_movimentos(user_id);
-- índices originais preservados
create index if not exists idx_vhsys_estoque_movimentos_created on public.vhsys_estoque_movimentos using btree (created_at desc);
create index if not exists idx_vhsys_estoque_movimentos_produto on public.vhsys_estoque_movimentos using btree (produto_vhsys_id);
create index if not exists idx_vhsys_estoque_movimentos_produtor on public.vhsys_estoque_movimentos using btree (produtor_id);

-- ── vhsys_estoque_saldos (saldo espelhado por produto/insumo na VHSYS) ────────
create table if not exists public.vhsys_estoque_saldos (
  -- campos originais (fiéis) — PK natural = produto_vhsys_id
  produto_vhsys_id bigint primary key,
  produto_nome text,
  produto_codigo text,
  saldo_atual numeric not null default 0,
  estoque_minimo numeric not null default 0,
  ultima_consulta timestamptz,
  payload jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  tipo_item text not null default 'produto'::text,
  -- colunas-padrão GLOP
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  -- CHECK original preservado
  constraint vhsys_estoque_saldos_tipo_item_check
    check (tipo_item = any (array['produto'::text, 'insumo'::text]))
);
create index if not exists vhsys_estoque_saldos_company_idx on public.vhsys_estoque_saldos(company_id) where deleted_at is null;
-- índice original preservado
create index if not exists vhsys_estoque_saldos_tipo_item_idx on public.vhsys_estoque_saldos using btree (tipo_item);

-- ── vhsys_locais_estoque (locais/almoxarifados de estoque da VHSYS) ───────────
create table if not exists public.vhsys_locais_estoque (
  -- campos originais (fiéis) — PK natural = id_local_estoque
  id_local_estoque bigint primary key,
  nome text not null,
  ativo boolean not null default true,
  observacao text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  -- colunas-padrão GLOP
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists vhsys_locais_estoque_company_idx on public.vhsys_locais_estoque(company_id) where deleted_at is null;

-- ── Triggers touch/audit (padrão GLOP) ───────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array['vhsys_estoque_movimentos','vhsys_estoque_saldos','vhsys_locais_estoque'] loop
    execute format('drop trigger if exists trg_%s_touch on public.%s', t, t);
    execute format('create trigger trg_%s_touch before insert or update on public.%s for each row execute function app.tg_touch_row()', t, t);
    execute format('drop trigger if exists trg_%s_audit on public.%s', t, t);
    execute format('create trigger trg_%s_audit after insert or update or delete on public.%s for each row execute function app.tg_write_audit()', t, t);
  end loop;
end $$;

-- ── RLS por company (padrão GLOP · resource 'inventory') ──────────────────────
do $$ declare t text;
begin
  foreach t in array array['vhsys_estoque_movimentos','vhsys_estoque_saldos','vhsys_locais_estoque'] loop
    execute format('alter table public.%s enable row level security', t);
    execute format($f$create policy %1$s_select on public.%1$s for select to authenticated
      using (app.is_superadmin() or company_id in (select app.user_company_ids()))$f$, t);
    execute format($f$create policy %1$s_insert on public.%1$s for insert to authenticated
      with check (app.can_access_company(company_id) and app.has_permission('inventory.create', company_id))$f$, t);
    execute format($f$create policy %1$s_update on public.%1$s for update to authenticated
      using (app.can_access_company(company_id) and app.has_permission('inventory.update', company_id))
      with check (app.can_access_company(company_id))$f$, t);
    execute format($f$create policy %1$s_delete on public.%1$s for delete to authenticated
      using (app.is_superadmin())$f$, t);
  end loop;
exception when duplicate_object then null;
end $$;

-- ══════════ 20260713000099_import_rodrigo_m9_nfe.sql ══════════
-- ════════════════════════════════════════════════════════════════════════════
-- IMPORTAÇÃO "Logística Rodrigo" (lemonlog) → GLOP  ·  M9 — NF-e (EMISSÃO FISCAL)
-- ════════════════════════════════════════════════════════════════════════════
-- Porta: nfe_emissoes (fila/histórico de emissão de NF-e via vhsys) e
-- nfe_baixa_estoque_config (mapeamento produto↔vhsys p/ baixa de estoque na NF-e).
-- Fiel ao original (todas as colunas, tipos e defaults) + padrão GLOP por cima:
-- tenant_id/company_id/branch_id, colunas de auditoria, RLS por company (app.*),
-- triggers touch/audit. produtor_id → FK public.produtores_integracao(id) (M0).
-- Resource RLS = 'inventory' (nfe/vhsys/estoque). Nada removido; melhorias = GLOP.
-- Ver docs/rodrigo-import/PLANO-IMPORTACAO.md.
-- ════════════════════════════════════════════════════════════════════════════

-- ── nfe_baixa_estoque_config (mapa produto→vhsys p/ baixa de estoque) ─────────
create table if not exists public.nfe_baixa_estoque_config (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  produtor_id uuid not null references public.produtores_integracao(id),
  produto_codigo text not null default ''::text,
  id_produto_vhsys text not null,
  id_local_estoque text,
  produto_descricao text,
  local_descricao text,
  ativo boolean not null default true,
  match_nome text,
  vincular_produto boolean not null default true,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists nfe_baixa_estoque_config_company_idx on public.nfe_baixa_estoque_config(company_id) where deleted_at is null;
create index if not exists nfe_baixa_estoque_config_produtor_idx on public.nfe_baixa_estoque_config(produtor_id);

-- ── nfe_emissoes (fila/histórico de emissão de NF-e) ─────────────────────────
-- Original: id bigint (sequence). Preservado como identity p/ fidelidade;
-- venda_id permanece bigint (referência à venda original).
create table if not exists public.nfe_emissoes (
  id bigint generated by default as identity primary key,
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  venda_id bigint,
  produtor_id uuid references public.produtores_integracao(id),
  status text not null default 'pendente'::text,
  vhsys_nfe_id text,
  chave text,
  protocolo text,
  ambiente text,
  danfe_url text,
  xml_url text,
  valor numeric,
  produto_codigo text,
  produto_nome text,
  plano_codigo text,
  plano_nome text,
  erro text,
  tentativas integer not null default 0,
  payload_request jsonb,
  payload_response jsonb,
  emitida_at timestamptz,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists nfe_emissoes_company_idx on public.nfe_emissoes(company_id) where deleted_at is null;
create index if not exists nfe_emissoes_produtor_idx on public.nfe_emissoes(produtor_id);
create index if not exists nfe_emissoes_venda_idx on public.nfe_emissoes(venda_id);
create index if not exists nfe_emissoes_status_idx on public.nfe_emissoes(status);

-- ── Triggers touch/audit (padrão GLOP) ───────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array['nfe_baixa_estoque_config','nfe_emissoes'] loop
    execute format('drop trigger if exists trg_%s_touch on public.%s', t, t);
    execute format('create trigger trg_%s_touch before insert or update on public.%s for each row execute function app.tg_touch_row()', t, t);
    execute format('drop trigger if exists trg_%s_audit on public.%s', t, t);
    execute format('create trigger trg_%s_audit after insert or update or delete on public.%s for each row execute function app.tg_write_audit()', t, t);
  end loop;
end $$;

-- ── RLS por company (padrão GLOP · resource 'inventory') ─────────────────────
do $$ declare t text;
begin
  foreach t in array array['nfe_baixa_estoque_config','nfe_emissoes'] loop
    execute format('alter table public.%s enable row level security', t);
    execute format($f$create policy %1$s_select on public.%1$s for select to authenticated
      using (app.is_superadmin() or company_id in (select app.user_company_ids()))$f$, t);
    execute format($f$create policy %1$s_insert on public.%1$s for insert to authenticated
      with check (app.can_access_company(company_id) and app.has_permission('inventory.create', company_id))$f$, t);
    execute format($f$create policy %1$s_update on public.%1$s for update to authenticated
      using (app.can_access_company(company_id) and app.has_permission('inventory.update', company_id))
      with check (app.can_access_company(company_id))$f$, t);
    execute format($f$create policy %1$s_delete on public.%1$s for delete to authenticated
      using (app.is_superadmin())$f$, t);
  end loop;
exception when duplicate_object then null;
end $$;

-- ══════════ 20260713000100_import_rodrigo_m10_comunicacao.sql ══════════
-- ════════════════════════════════════════════════════════════════════════════
-- IMPORTAÇÃO "Logística Rodrigo" (lemonlog) → GLOP  ·  M10 — COMUNICAÇÃO
-- ════════════════════════════════════════════════════════════════════════════
-- Porta o módulo de comunicação com o comprador: logs de envio de e-mail
-- (SendGrid) e de WhatsApp de rastreio, mais os templates editáveis (singleton)
-- de e-mail e WhatsApp (inclui o template do "carteiro").
-- Fiel ao original (todas as colunas, tipos, defaults e constraints) + padrão
-- GLOP por cima: tenant_id/company_id/branch_id, colunas de auditoria,
-- RLS por company (app.*) e triggers touch/audit.
-- PKs originais preservadas: bigint (identity) nos logs; integer singleton
-- (CHECK id = 1) nos templates. Nenhuma coluna removida.
-- Recurso RLS: 'shipping' (comunicação de envios/rastreio/Correios).
-- Observação: as tabelas de origem NÃO possuem produtor_id — a dimensão de
-- tenancy aqui é company_id (GLOP). Nenhum produtor_id foi inventado (fidelidade).
-- Ver docs/rodrigo-import/PLANO-IMPORTACAO.md. Melhorias = padrão GLOP.
-- ════════════════════════════════════════════════════════════════════════════

-- ── email_envios_log (log de envio de e-mail de rastreio via SendGrid) ───────
create table if not exists public.email_envios_log (
  -- PK original (bigint com sequence) preservada
  id bigint primary key generated by default as identity,
  -- colunas-padrão GLOP (multi-tenant)
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  pedido_id uuid,
  venda_id bigint,
  codigo_rastreio text,
  email text not null,
  nome text,
  status text not null default 'queued'::text,
  erro text,
  sendgrid_message_id text,
  assunto text,
  template_hash text,
  -- colunas-padrão GLOP (created_at original preservado)
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists email_envios_log_company_idx on public.email_envios_log(company_id) where deleted_at is null;
create index if not exists email_envios_log_pedido_idx on public.email_envios_log(pedido_id);
create index if not exists email_envios_log_venda_idx on public.email_envios_log(venda_id);
create index if not exists email_envios_log_rastreio_idx on public.email_envios_log(codigo_rastreio);
create index if not exists email_envios_log_status_idx on public.email_envios_log(status);

-- ── email_template_rastreio (template singleton do e-mail de rastreio) ───────
-- Singleton original preservado (id integer default 1 + CHECK id = 1).
create table if not exists public.email_template_rastreio (
  -- PK original (integer singleton) preservada
  id integer primary key not null default 1,
  -- colunas-padrão GLOP (multi-tenant)
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  assunto text not null default 'Seu código de rastreio - Pedido {{codigo}}'::text,
  html text not null default '<div style="font-family:Arial,sans-serif;max-width:560px;margin:0 auto;padding:20px;color:#222"><h2 style="margin:0 0 16px">Olá, {{nome}}!</h2><p>Seu pedido foi postado nos Correios. Veja abaixo o código de rastreio:</p><p style="font-size:18px;font-weight:bold;background:#f4f4f4;padding:12px;border-radius:6px;text-align:center;letter-spacing:1px">{{codigo}}</p><p>Você pode acompanhar a entrega clicando no link abaixo:</p><p style="text-align:center;margin:24px 0"><a href="{{link_rastreio}}" style="background:#0066cc;color:#fff;padding:12px 24px;text-decoration:none;border-radius:6px;display:inline-block">Rastrear pedido</a></p></div>'::text,
  -- colunas-padrão GLOP (updated_at original preservado)
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  -- constraint original preservada
  constraint email_template_rastreio_singleton check ((id = 1))
);
create index if not exists email_template_rastreio_company_idx on public.email_template_rastreio(company_id) where deleted_at is null;

-- ── whatsapp_envios_log (log de envio de WhatsApp) ───────────────────────────
create table if not exists public.whatsapp_envios_log (
  -- PK original (bigint com sequence) preservada
  id bigint primary key generated by default as identity,
  -- colunas-padrão GLOP (multi-tenant)
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  cliente_id bigint,
  telefone text not null,
  nome text,
  mensagem text not null,
  status text not null default 'pendente'::text,
  erro text,
  enviado_at timestamptz,
  -- colunas-padrão GLOP (created_at original preservado)
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists whatsapp_envios_log_company_idx on public.whatsapp_envios_log(company_id) where deleted_at is null;
create index if not exists whatsapp_envios_log_cliente_idx on public.whatsapp_envios_log(cliente_id);
create index if not exists whatsapp_envios_log_telefone_idx on public.whatsapp_envios_log(telefone);
create index if not exists whatsapp_envios_log_status_idx on public.whatsapp_envios_log(status);

-- ── whatsapp_template (template singleton da mensagem de WhatsApp) ───────────
-- Singleton original preservado (id integer default 1 + CHECK id = 1).
create table if not exists public.whatsapp_template (
  -- PK original (integer singleton) preservada
  id integer primary key not null default 1,
  -- colunas-padrão GLOP (multi-tenant)
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  mensagem text not null default 'Olá {nome}! 📦

Seu pedido do plano *{plano}* foi enviado pelos Correios.

🔎 Código de rastreio: *{codigo_rastreio}*

Acompanhe em:
https://rastreamento.correios.com.br/app/index.php

Qualquer dúvida estamos à disposição!'::text,
  -- colunas-padrão GLOP (updated_at original preservado)
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  -- constraint original preservada
  constraint single_row check ((id = 1))
);
create index if not exists whatsapp_template_company_idx on public.whatsapp_template(company_id) where deleted_at is null;

-- ── whatsapp_template_carteiro (template singleton "carteiro") ───────────────
-- Singleton original preservado (id integer default 1 + CHECK id = 1).
create table if not exists public.whatsapp_template_carteiro (
  -- PK original (integer singleton) preservada
  id integer primary key not null default 1,
  -- colunas-padrão GLOP (multi-tenant)
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  mensagem text not null,
  -- colunas-padrão GLOP (updated_at original preservado)
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  -- constraint original preservada
  constraint single_row_carteiro check ((id = 1))
);
create index if not exists whatsapp_template_carteiro_company_idx on public.whatsapp_template_carteiro(company_id) where deleted_at is null;

-- ── Triggers touch/audit (padrão GLOP) ───────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array['email_envios_log','email_template_rastreio','whatsapp_envios_log','whatsapp_template','whatsapp_template_carteiro'] loop
    execute format('drop trigger if exists trg_%s_touch on public.%s', t, t);
    execute format('create trigger trg_%s_touch before insert or update on public.%s for each row execute function app.tg_touch_row()', t, t);
    execute format('drop trigger if exists trg_%s_audit on public.%s', t, t);
    execute format('create trigger trg_%s_audit after insert or update or delete on public.%s for each row execute function app.tg_write_audit()', t, t);
  end loop;
end $$;

-- ── RLS por company (padrão GLOP) — recurso 'shipping' ───────────────────────
do $$ declare t text;
begin
  foreach t in array array['email_envios_log','email_template_rastreio','whatsapp_envios_log','whatsapp_template','whatsapp_template_carteiro'] loop
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

-- ══════════ 20260713000101_import_rodrigo_m11_regras_contratos.sql ══════════
-- ════════════════════════════════════════════════════════════════════════════
-- IMPORTAÇÃO "Logística Rodrigo" (lemonlog) → GLOP  ·  M11 — REGRAS & CONTRATOS
-- ════════════════════════════════════════════════════════════════════════════
-- Porta as tabelas de roteamento/contratação logística (Correios & transportadoras):
--   · regras_logisticas    — regras de roteamento venda→contrato/transportadora
--   · remetente_config      — config singleton do remetente (contrato/cartão Correios)
--   · contratos_logisticos  — contratos de postagem (Correios/transportadora)
--   · sislog_remetentes     — remetentes SisLogica por produtor (multi-remetente)
-- Fiel ao original (todas as colunas/tipos/defaults preservados, nomes em PT) +
-- padrão GLOP por cima: tenant_id/company_id/branch_id, colunas de auditoria,
-- RLS por company (app.*), triggers touch/audit. Resource = 'shipping'.
-- produtor_id referencia public.produtores_integracao(id) (M0, já existente).
-- Nada removido; melhorias = padrão GLOP. Ver docs/rodrigo-import/PLANO-IMPORTACAO.md.
-- ════════════════════════════════════════════════════════════════════════════

-- (sem enums de negócio neste módulo — 'transportadora' é texto livre no original)

-- ── contratos_logisticos (contratos de postagem Correios/transportadora) ──────
create table if not exists public.contratos_logisticos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  produtor_id uuid not null references public.produtores_integracao(id) on delete cascade,
  -- campos originais (fiéis)
  nome text not null,
  transportadora text not null default 'correios'::text,
  agf_nome text,
  cidade text,
  uf text,
  codigo_contrato text,
  cartao_postagem text,
  codigo_administrativo text,
  codigo_diretoria integer,
  numero_dr integer,
  correios_api_token text,
  observacao text,
  ativo boolean not null default true,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists contratos_logisticos_company_idx on public.contratos_logisticos(company_id) where deleted_at is null;
create index if not exists contratos_logisticos_produtor_idx on public.contratos_logisticos(produtor_id);

-- ── regras_logisticas (roteamento venda → contrato/transportadora) ────────────
create table if not exists public.regras_logisticas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  produtor_id uuid not null references public.produtores_integracao(id) on delete cascade,
  -- campos originais (fiéis)
  nome text not null,
  plano_id uuid,
  produto_nome text,
  transportadora text,
  contrato_logistico_id uuid not null references public.contratos_logisticos(id),
  uf text,
  cidade text,
  cep_inicial text,
  cep_final text,
  prioridade integer not null default 100,
  ativo boolean not null default true,
  enviar_sislogica boolean not null default true,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
comment on column public.regras_logisticas.enviar_sislogica is 'Quando false, vendas que casarem com esta regra NÃO são despachadas para a SisLogica (nem aparecem na aba SisLogica).';
create index if not exists regras_logisticas_company_idx on public.regras_logisticas(company_id) where deleted_at is null;
create index if not exists regras_logisticas_produtor_idx on public.regras_logisticas(produtor_id);
create index if not exists regras_logisticas_contrato_idx on public.regras_logisticas(contrato_logistico_id);

-- ── remetente_config (config singleton do remetente Correios — id=1 no original) ─
-- Fidelidade: mantém a PK inteira com CHECK(id=1) do original (singleton).
create table if not exists public.remetente_config (
  id integer primary key default 1,
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  nome text,
  documento text,
  email text,
  telefone text,
  cep text,
  endereco text,
  numero text,
  complemento text,
  bairro text,
  cidade text,
  estado text,
  numero_contrato text,
  numero_cartao_postagem text,
  numero_dr integer,
  codigo_diretoria integer,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  constraint remetente_config_id_check check (id = 1)
);
create index if not exists remetente_config_company_idx on public.remetente_config(company_id) where deleted_at is null;

-- ── sislog_remetentes (remetentes SisLogica por produtor, multi-remetente) ────
create table if not exists public.sislog_remetentes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  produtor_id uuid not null references public.produtores_integracao(id) on delete cascade,
  -- campos originais (fiéis)
  nome text not null,
  cnpj text,
  inscricao_estadual text,
  razao_social text,
  cep text,
  logradouro text,
  numero text,
  complemento text,
  bairro text,
  cidade text,
  estado text,
  telefone text,
  email text,
  ufs_atendidas text[] not null default '{}'::text[],
  is_default boolean not null default false,
  ativo boolean not null default true,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists sislog_remetentes_company_idx on public.sislog_remetentes(company_id) where deleted_at is null;
create index if not exists sislog_remetentes_produtor_idx on public.sislog_remetentes(produtor_id);

-- ── Triggers touch/audit (padrão GLOP) ───────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array['contratos_logisticos','regras_logisticas','remetente_config','sislog_remetentes'] loop
    execute format('drop trigger if exists trg_%s_touch on public.%s', t, t);
    execute format('create trigger trg_%s_touch before insert or update on public.%s for each row execute function app.tg_touch_row()', t, t);
    execute format('drop trigger if exists trg_%s_audit on public.%s', t, t);
    execute format('create trigger trg_%s_audit after insert or update or delete on public.%s for each row execute function app.tg_write_audit()', t, t);
  end loop;
end $$;

-- ── RLS por company (padrão GLOP) — resource 'shipping' ───────────────────────
do $$ declare t text;
begin
  foreach t in array array['contratos_logisticos','regras_logisticas','remetente_config','sislog_remetentes'] loop
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

-- ══════════ 20260713000102_import_rodrigo_m12_webhooks_integracoes.sql ══════════
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
create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  company_id uuid,
  branch_id uuid,
  -- campos originais (fiéis)
  user_id uuid not null references auth.users(id) on delete cascade,
  nome text,
  -- colunas-padrão GLOP
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists profiles_company_idx on public.profiles(company_id) where deleted_at is null;
create index if not exists profiles_user_idx on public.profiles(user_id);

-- ── Triggers touch/audit (padrão GLOP) ───────────────────────────────────────
do $$ declare t text;
begin
  foreach t in array array[
    'produtor_webhooks','produtor_webhook_entregas','sislogica_envios_log',
    'sislogica_webhook_recebidos','sislogica_webhook_tokens','api_logs',
    'webhook_logs','profiles'
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
      ('webhook_logs','integration'),
      ('profiles','admin')
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

