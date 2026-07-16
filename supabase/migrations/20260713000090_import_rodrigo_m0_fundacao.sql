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
