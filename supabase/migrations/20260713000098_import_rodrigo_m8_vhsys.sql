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
