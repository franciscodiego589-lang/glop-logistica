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
