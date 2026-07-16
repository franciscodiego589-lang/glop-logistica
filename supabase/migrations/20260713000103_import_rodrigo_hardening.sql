-- ════════════════════════════════════════════════════════════════════════════
-- IMPORT RODRIGO — HARDENING (correções do audit de bugs & segurança)
-- ════════════════════════════════════════════════════════════════════════════
-- Corrige achados de integridade multi-tenant nas tabelas importadas (090–102).
-- As tabelas são recém-criadas e VAZIAS, então as conversões são seguras (sem
-- perda de dado). Migration aditiva — não reescreve as anteriores (já aplicadas).
--   #10/#11/#12/#13  singletons globais (id integer=1 + CHECK) → uuid PK + único por company
--   #8/#9/#16        VHSYS usava id externo (bigint) como PK global → uuid PK + único por company
--   #19             produtor_api_keys.key_hash sem índice único (auth por API key precisa)
--   #23             índice duplicado em vhsys_estoque_movimentos.produtor_id
-- ════════════════════════════════════════════════════════════════════════════

-- ── Singletons globais → um registro POR COMPANY (uuid PK) ───────────────────
do $$
declare t text; c record;
begin
  foreach t in array array[
    'ml_tokens','coproducao_configuracoes','remetente_config',
    'email_template_rastreio','whatsapp_template','whatsapp_template_carteiro'
  ] loop
    if to_regclass('public.'||t) is null then continue; end if;
    -- remove CHECKs de singleton (id=1) e a PK atual (id integer)
    for c in select conname from pg_constraint where conrelid=('public.'||t)::regclass and contype in ('c','p') loop
      execute format('alter table public.%I drop constraint %I', t, c.conname);
    end loop;
    -- troca id integer por uuid
    execute format('alter table public.%I drop column if exists id', t);
    execute format('alter table public.%I add column id uuid primary key default gen_random_uuid()', t);
    -- garante 1 registro ativo por company
    execute format('create unique index if not exists %I on public.%I(company_id) where deleted_at is null', t||'_company_uidx', t);
  end loop;
end $$;

-- ── VHSYS: id externo (bigint) deixa de ser PK global → uuid PK + único/company ─
do $$
declare c record;
begin
  if to_regclass('public.vhsys_estoque_saldos') is not null then
    for c in select conname from pg_constraint where conrelid='public.vhsys_estoque_saldos'::regclass and contype='p' loop
      execute format('alter table public.vhsys_estoque_saldos drop constraint %I', c.conname);
    end loop;
    alter table public.vhsys_estoque_saldos add column if not exists id uuid primary key default gen_random_uuid();
    create unique index if not exists vhsys_saldos_company_prod_uidx on public.vhsys_estoque_saldos(company_id, produto_vhsys_id) where deleted_at is null;
  end if;
  if to_regclass('public.vhsys_locais_estoque') is not null then
    for c in select conname from pg_constraint where conrelid='public.vhsys_locais_estoque'::regclass and contype='p' loop
      execute format('alter table public.vhsys_locais_estoque drop constraint %I', c.conname);
    end loop;
    alter table public.vhsys_locais_estoque add column if not exists id uuid primary key default gen_random_uuid();
    create unique index if not exists vhsys_locais_company_uidx on public.vhsys_locais_estoque(company_id, id_local_estoque) where deleted_at is null;
  end if;
end $$;

-- ── produtor_api_keys.key_hash: índice único (auth por API key) ──────────────
create unique index if not exists produtor_api_keys_key_hash_uidx on public.produtor_api_keys(key_hash);

-- ── índice duplicado em vhsys_estoque_movimentos.produtor_id ─────────────────
drop index if exists public.idx_vhsys_estoque_movimentos_produtor;
