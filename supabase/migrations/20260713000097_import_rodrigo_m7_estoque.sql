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
