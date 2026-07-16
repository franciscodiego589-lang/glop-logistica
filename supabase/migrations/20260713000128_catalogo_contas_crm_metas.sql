-- ════════════════════════════════════════════════════════════════════════════
-- Onda 6 — 4 módulos: Catálogo de Produtos · Contas (pagar/receber) · CRM · Metas
-- ════════════════════════════════════════════════════════════════════════════

-- ── Catálogo de produtos ────────────────────────────────────────────────────
create table if not exists public.catalogo_produtos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  sku text, nome text not null, descricao text, categoria text,
  preco numeric(14,2) not null default 0, custo numeric(14,2) not null default 0,
  peso_g numeric(14,3) not null default 0, altura_cm numeric(10,2) not null default 0,
  largura_cm numeric(10,2) not null default 0, comprimento_cm numeric(10,2) not null default 0,
  estoque_atual numeric(14,3) not null default 0, estoque_minimo numeric(14,3) not null default 0,
  foto_url text, tipo text not null default 'simples' check (tipo in ('simples','kit')),
  ativo boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_catalogo_company on public.catalogo_produtos (company_id) where deleted_at is null;

create table if not exists public.catalogo_kit_itens (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  kit_sku text not null, produto_sku text not null, quantidade numeric(14,3) not null default 1,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── Contas a pagar / receber ────────────────────────────────────────────────
create table if not exists public.financeiro_contas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  tipo text not null default 'pagar' check (tipo in ('pagar','receber')),
  descricao text not null, categoria text, valor numeric(14,2) not null default 0,
  vencimento date not null default current_date, pago boolean not null default false, pago_em date,
  forma_pagamento text, observacoes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_contas_company on public.financeiro_contas (company_id, vencimento) where deleted_at is null;

-- ── CRM de compradores (anotações/tags por titular) ─────────────────────────
create table if not exists public.crm_compradores (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  buyer_doc text, nome text, email text, telefone text,
  segmento text, tags text, observacoes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_crm_company on public.crm_compradores (company_id) where deleted_at is null;

-- ── Metas ───────────────────────────────────────────────────────────────────
create table if not exists public.metas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  nome text not null, tipo text not null default 'receita' check (tipo in ('receita','pedidos','entregues','ticket','comissao')),
  competencia date not null default date_trunc('month', now())::date, valor_meta numeric(14,2) not null default 0,
  observacoes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_metas_company on public.metas (company_id, competencia) where deleted_at is null;

-- triggers + RLS
do $$ declare t text;
begin
  foreach t in array array['catalogo_produtos','catalogo_kit_itens','financeiro_contas','crm_compradores','metas'] loop
    execute format('create trigger trg_%s_touch before insert or update on public.%I for each row execute function app.tg_touch_row();', t, t);
    execute format('create trigger trg_%s_audit after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', t, t);
    execute format('alter table public.%I enable row level security;', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
exception when duplicate_object then null; end $$;

do $$ begin
  -- catálogo + kits + crm: master_data
  create policy cat_sel on public.catalogo_produtos for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));
  create policy cat_ins on public.catalogo_produtos for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission('master_data.create', company_id));
  create policy cat_upd on public.catalogo_produtos for update to authenticated using (app.can_access_company(company_id) and app.has_permission('master_data.update', company_id)) with check (app.can_access_company(company_id));
  create policy cat_del on public.catalogo_produtos for delete to authenticated using (app.is_superadmin());
  create policy kit_sel on public.catalogo_kit_itens for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));
  create policy kit_ins on public.catalogo_kit_itens for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission('master_data.create', company_id));
  create policy kit_upd on public.catalogo_kit_itens for update to authenticated using (app.can_access_company(company_id) and app.has_permission('master_data.update', company_id)) with check (app.can_access_company(company_id));
  create policy kit_del on public.catalogo_kit_itens for delete to authenticated using (app.is_superadmin());
  create policy crm_sel on public.crm_compradores for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));
  create policy crm_ins on public.crm_compradores for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission('master_data.create', company_id));
  create policy crm_upd on public.crm_compradores for update to authenticated using (app.can_access_company(company_id) and app.has_permission('master_data.update', company_id)) with check (app.can_access_company(company_id));
  create policy crm_del on public.crm_compradores for delete to authenticated using (app.is_superadmin());
  -- contas: purchasing
  create policy contas_sel on public.financeiro_contas for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));
  create policy contas_ins on public.financeiro_contas for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission('purchasing.create', company_id));
  create policy contas_upd on public.financeiro_contas for update to authenticated using (app.can_access_company(company_id) and app.has_permission('purchasing.update', company_id)) with check (app.can_access_company(company_id));
  create policy contas_del on public.financeiro_contas for delete to authenticated using (app.is_superadmin());
  -- metas: bi
  create policy metas_sel on public.metas for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));
  create policy metas_ins on public.metas for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission('bi.create', company_id));
  create policy metas_upd on public.metas for update to authenticated using (app.can_access_company(company_id) and app.has_permission('bi.update', company_id)) with check (app.can_access_company(company_id));
  create policy metas_del on public.metas for delete to authenticated using (app.is_superadmin());
exception when duplicate_object then null; end $$;
