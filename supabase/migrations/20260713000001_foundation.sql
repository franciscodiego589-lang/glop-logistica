-- 20260713000001_foundation.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 01 — FUNDAÇÃO GLOBAL DA LOGÍSTICA (Master / Cérebro Principal)     ║
-- ║  ERP Logístico Mundial — arquitetura Enterprise multi-tenant.             ║
-- ║  Extensões · schema app · funções/triggers padrão · auditoria ·          ║
-- ║  multi-tenant (tenant→company→branch) · RBAC · RLS · seed de permissões.  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- ── Extensões ────────────────────────────────────────────────────────────────
create extension if not exists pgcrypto;      -- gen_random_uuid()
create extension if not exists pg_trgm;       -- busca fuzzy (nomes/códigos)
create extension if not exists btree_gist;    -- exclusões / ranges (docas, agendas)
create extension if not exists vector;        -- pgvector p/ IA LOGIA (embeddings)

-- ── Schemas ──────────────────────────────────────────────────────────────────
create schema if not exists app;              -- funções internas (NÃO expostas na API)

-- ── Enums de núcleo ──────────────────────────────────────────────────────────
create type public.audit_action as enum ('insert','update','delete');

-- ── AUDIT_LOGS (precisa existir antes dos triggers de auditoria) ─────────────
create table public.audit_logs (
  id             bigint generated always as identity primary key,
  tenant_id      uuid,
  company_id     uuid,
  table_name     text not null,
  record_id      uuid,
  action         public.audit_action not null,
  actor_id       uuid,
  old_data       jsonb,
  new_data       jsonb,
  changed_fields text[],
  occurred_at    timestamptz not null default now()
);
create index idx_audit_logs_record on public.audit_logs (table_name, record_id);
create index idx_audit_logs_tenant on public.audit_logs (tenant_id, occurred_at desc);
create index idx_audit_logs_actor  on public.audit_logs (actor_id, occurred_at desc);

-- ── Trigger: preenche metadados de linha (created_by/updated_by/version/soft-del) ─
create or replace function app.tg_touch_row() returns trigger
language plpgsql as $$
begin
  if tg_op = 'INSERT' then
    new.created_at := coalesce(new.created_at, now());
    new.updated_at := now();
    new.created_by := coalesce(new.created_by, auth.uid());
    new.updated_by := coalesce(new.updated_by, auth.uid());
    new.version    := coalesce(new.version, 1);
  elsif tg_op = 'UPDATE' then
    new.updated_at := now();
    new.updated_by := coalesce(auth.uid(), new.updated_by);
    if new.version = old.version then
      new.version := old.version + 1;
    end if;
    -- marca quem fez o soft delete
    if new.deleted_at is not null and old.deleted_at is null then
      new.deleted_by := coalesce(new.deleted_by, auth.uid());
    end if;
  end if;
  return new;
end;
$$;

-- ── Trigger: grava auditoria (quem/quando/o quê/antes/depois/campos) ─────────
create or replace function app.tg_write_audit() returns trigger
language plpgsql security definer set search_path = public, app as $$
declare
  v_old jsonb; v_new jsonb; v_changed text[]; v_action public.audit_action;
  v_record uuid; v_tenant uuid; v_company uuid;
begin
  if tg_op = 'INSERT' then
    v_action := 'insert'; v_new := to_jsonb(new); v_old := null;
  elsif tg_op = 'UPDATE' then
    v_action := 'update'; v_new := to_jsonb(new); v_old := to_jsonb(old);
  else
    v_action := 'delete'; v_new := null; v_old := to_jsonb(old);
  end if;

  if tg_op = 'UPDATE' then
    select array_agg(k) into v_changed
    from jsonb_object_keys(v_new) k
    where (v_new -> k) is distinct from (v_old -> k)
      and k not in ('updated_at','version');
  end if;

  v_record  := coalesce((v_new->>'id')::uuid,         (v_old->>'id')::uuid);
  v_tenant  := coalesce((v_new->>'tenant_id')::uuid,  (v_old->>'tenant_id')::uuid);
  v_company := coalesce((v_new->>'company_id')::uuid, (v_old->>'company_id')::uuid);

  insert into public.audit_logs
    (tenant_id, company_id, table_name, record_id, action, actor_id, old_data, new_data, changed_fields)
  values
    (v_tenant, v_company, tg_table_name, v_record, v_action, auth.uid(), v_old, v_new, v_changed);
  return null;
end;
$$;

-- ── MULTI-TENANT: tenants → companies → branches ─────────────────────────────
create table public.tenants (
  id             uuid primary key default gen_random_uuid(),
  name           text not null,
  slug           text unique,
  active         boolean not null default true,
  metadata       jsonb not null default '{}'::jsonb,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create table public.companies (
  id             uuid primary key default gen_random_uuid(),
  tenant_id      uuid not null references public.tenants(id) on delete restrict,
  name           text not null,
  legal_name     text,
  document       text,                            -- CNPJ
  tax_regime     text,                            -- simples/presumido/real
  address        text,
  active         boolean not null default true,
  version        integer not null default 1,
  metadata       jsonb not null default '{}'::jsonb,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz,
  deleted_by     uuid references auth.users(id),
  reason_deleted text,
  created_by     uuid references auth.users(id),
  updated_by     uuid references auth.users(id)
);
create index idx_companies_tenant on public.companies (tenant_id);

create table public.branches (
  id             uuid primary key default gen_random_uuid(),
  tenant_id      uuid not null references public.tenants(id)   on delete restrict,
  company_id     uuid not null references public.companies(id) on delete restrict,
  name           text not null,
  code           text,
  branch_type    text not null default 'operation', -- cd, warehouse, factory, office, store
  address        text,
  latitude       numeric(10,7),
  longitude      numeric(10,7),
  active         boolean not null default true,
  version        integer not null default 1,
  metadata       jsonb not null default '{}'::jsonb,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz,
  deleted_by     uuid references auth.users(id),
  reason_deleted text,
  created_by     uuid references auth.users(id),
  updated_by     uuid references auth.users(id)
);
create index idx_branches_company on public.branches (company_id);

-- ── USUÁRIOS + RBAC ──────────────────────────────────────────────────────────
create table public.profiles (
  user_id        uuid primary key references auth.users(id) on delete cascade,
  tenant_id      uuid references public.tenants(id) on delete set null,
  full_name      text,
  email          text,
  phone          text,
  avatar_url     text,
  is_superadmin  boolean not null default false,
  active         boolean not null default true,
  metadata       jsonb not null default '{}'::jsonb,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create table public.permissions (
  id             uuid primary key default gen_random_uuid(),
  slug           text not null unique,            -- ex.: wms.putaway.create
  resource       text not null,
  action         text not null,
  description    text,
  created_at     timestamptz not null default now()
);

create table public.roles (
  id             uuid primary key default gen_random_uuid(),
  tenant_id      uuid references public.tenants(id) on delete cascade,
  slug           text not null,
  name           text not null,
  is_system      boolean not null default false,
  active         boolean not null default true,
  version        integer not null default 1,
  metadata       jsonb not null default '{}'::jsonb,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz,
  deleted_by     uuid references auth.users(id),
  reason_deleted text,
  created_by     uuid references auth.users(id),
  updated_by     uuid references auth.users(id)
);
create unique index uq_roles_slug on public.roles (coalesce(tenant_id,'00000000-0000-0000-0000-000000000000'::uuid), slug);

create table public.role_permissions (
  role_id        uuid not null references public.roles(id)       on delete cascade,
  permission_id  uuid not null references public.permissions(id) on delete cascade,
  primary key (role_id, permission_id)
);

create table public.memberships (
  id             uuid primary key default gen_random_uuid(),
  tenant_id      uuid not null references public.tenants(id)   on delete cascade,
  company_id     uuid references public.companies(id)          on delete cascade,
  branch_id      uuid references public.branches(id)           on delete cascade,
  user_id        uuid not null references auth.users(id)       on delete cascade,
  role_id        uuid not null references public.roles(id)     on delete restrict,
  active         boolean not null default true,
  version        integer not null default 1,
  metadata       jsonb not null default '{}'::jsonb,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz,
  deleted_by     uuid references auth.users(id),
  reason_deleted text,
  created_by     uuid references auth.users(id),
  updated_by     uuid references auth.users(id)
);
create index idx_memberships_user    on public.memberships (user_id);
create index idx_memberships_company on public.memberships (company_id);
create index idx_memberships_tenant  on public.memberships (tenant_id);

-- ── Funções de autorização (schema app, security definer p/ furar RLS) ───────
create or replace function app.is_superadmin() returns boolean
language sql stable security definer set search_path = public, app as $$
  select coalesce((select is_superadmin from public.profiles where user_id = auth.uid()), false);
$$;

create or replace function app.user_tenant_ids() returns setof uuid
language sql stable security definer set search_path = public, app as $$
  select distinct tenant_id from public.memberships
  where user_id = auth.uid() and deleted_at is null;
$$;

create or replace function app.user_company_ids() returns setof uuid
language sql stable security definer set search_path = public, app as $$
  select distinct company_id from public.memberships
  where user_id = auth.uid() and deleted_at is null and company_id is not null;
$$;

create or replace function app.can_access_tenant(p_tenant uuid) returns boolean
language sql stable security definer set search_path = public, app as $$
  select app.is_superadmin() or exists(
    select 1 from public.memberships
    where user_id = auth.uid() and tenant_id = p_tenant and deleted_at is null
  );
$$;

create or replace function app.can_access_company(p_company uuid) returns boolean
language sql stable security definer set search_path = public, app as $$
  select app.is_superadmin() or exists(
    select 1 from public.memberships
    where user_id = auth.uid() and company_id = p_company and deleted_at is null
  );
$$;

create or replace function app.has_permission(p_perm text, p_company uuid) returns boolean
language sql stable security definer set search_path = public, app as $$
  select app.is_superadmin() or exists(
    select 1
    from public.memberships m
    join public.role_permissions rp on rp.role_id = m.role_id
    join public.permissions p       on p.id = rp.permission_id
    where m.user_id = auth.uid()
      and m.deleted_at is null
      and (m.company_id = p_company or m.company_id is null)
      and p.slug = p_perm
  );
$$;

grant usage on schema app to authenticated;
grant execute on all functions in schema app to authenticated;

-- ── Triggers nas tabelas de negócio do núcleo ────────────────────────────────
do $do$
declare t text;
  tables text[] := array['companies','branches','roles','memberships'];
begin
  foreach t in array tables loop
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
  end loop;
end $do$;

-- ── RLS ──────────────────────────────────────────────────────────────────────
alter table public.tenants          enable row level security;
alter table public.companies        enable row level security;
alter table public.branches         enable row level security;
alter table public.profiles         enable row level security;
alter table public.roles            enable row level security;
alter table public.permissions      enable row level security;
alter table public.role_permissions enable row level security;
alter table public.memberships      enable row level security;
alter table public.audit_logs       enable row level security;

create policy tenants_select on public.tenants for select to authenticated
  using (app.is_superadmin() or id in (select app.user_tenant_ids()));

create policy companies_select on public.companies for select to authenticated
  using (app.is_superadmin() or id in (select app.user_company_ids()));
create policy companies_write on public.companies for all to authenticated
  using (app.is_superadmin() or tenant_id in (select app.user_tenant_ids()))
  with check (app.is_superadmin() or tenant_id in (select app.user_tenant_ids()));

create policy branches_select on public.branches for select to authenticated
  using (app.is_superadmin() or company_id in (select app.user_company_ids()));
create policy branches_write on public.branches for all to authenticated
  using (app.can_access_company(company_id)) with check (app.can_access_company(company_id));

create policy profiles_select on public.profiles for select to authenticated
  using (app.is_superadmin() or user_id = auth.uid() or tenant_id in (select app.user_tenant_ids()));
create policy profiles_update on public.profiles for update to authenticated
  using (user_id = auth.uid() or app.is_superadmin());

create policy roles_select on public.roles for select to authenticated
  using (app.is_superadmin() or tenant_id is null or tenant_id in (select app.user_tenant_ids()));
create policy roles_write on public.roles for all to authenticated
  using (app.is_superadmin() or tenant_id in (select app.user_tenant_ids()))
  with check (app.is_superadmin() or tenant_id in (select app.user_tenant_ids()));

create policy permissions_select on public.permissions for select to authenticated using (true);

create policy role_permissions_select on public.role_permissions for select to authenticated using (true);
create policy role_permissions_write on public.role_permissions for all to authenticated
  using (app.is_superadmin() or role_id in (select id from public.roles where tenant_id in (select app.user_tenant_ids())))
  with check (app.is_superadmin() or role_id in (select id from public.roles where tenant_id in (select app.user_tenant_ids())));

create policy memberships_select on public.memberships for select to authenticated
  using (app.is_superadmin() or user_id = auth.uid() or company_id in (select app.user_company_ids()));
create policy memberships_write on public.memberships for all to authenticated
  using (app.is_superadmin() or tenant_id in (select app.user_tenant_ids()))
  with check (app.is_superadmin() or tenant_id in (select app.user_tenant_ids()));

create policy audit_logs_select on public.audit_logs for select to authenticated
  using (app.is_superadmin() or company_id in (select app.user_company_ids()));

-- ── SEED de permissões (catálogo global de recursos logísticos) ──────────────
-- Recursos = módulos do ERP logístico.  Ações = verbos de negócio.
insert into public.permissions (slug, resource, action, description)
select r.res || '.' || a.act, r.res, a.act,
       'Permissão ' || a.act || ' em ' || r.res
from (values
  ('master_data'),('inventory'),('wms'),('tms'),('yms'),('purchasing'),
  ('demand'),('mrp'),('production'),('shipping'),('distribution'),
  ('controltower'),('logia'),('bi'),('admin')
) as r(res)
cross join (values
  ('read'),('create'),('update'),('delete'),('approve'),('export')
) as a(act)
on conflict (slug) do nothing;

-- Papel de sistema "superadmin" (template global, tenant_id null).
insert into public.roles (id, tenant_id, slug, name, is_system)
values ('00000000-0000-0000-0000-0000000000ad', null, 'superadmin', 'Super Administrador', true)
on conflict do nothing;
insert into public.role_permissions (role_id, permission_id)
select '00000000-0000-0000-0000-0000000000ad', id from public.permissions
on conflict do nothing;

-- ── bootstrap_organization: cria tenant+company+branch+admin p/ novo signup ──
create or replace function public.bootstrap_organization(
  p_tenant_name text, p_company_name text, p_document text default null
) returns jsonb
language plpgsql security definer set search_path = public, app as $$
declare
  v_uid uuid := auth.uid();
  v_tenant uuid; v_company uuid; v_branch uuid; v_role uuid;
begin
  if v_uid is null then raise exception 'not authenticated'; end if;

  insert into public.tenants (name) values (p_tenant_name) returning id into v_tenant;
  insert into public.companies (tenant_id, name, document, created_by)
    values (v_tenant, p_company_name, p_document, v_uid) returning id into v_company;
  insert into public.branches (tenant_id, company_id, name, branch_type, created_by)
    values (v_tenant, v_company, 'Matriz', 'cd', v_uid) returning id into v_branch;

  insert into public.roles (tenant_id, slug, name, is_system, created_by)
    values (v_tenant, 'admin', 'Administrador', true, v_uid) returning id into v_role;
  insert into public.role_permissions (role_id, permission_id)
    select v_role, id from public.permissions;

  insert into public.memberships (tenant_id, company_id, branch_id, user_id, role_id, created_by)
    values (v_tenant, v_company, v_branch, v_uid, v_role, v_uid);

  update public.profiles set tenant_id = v_tenant where user_id = v_uid;

  return jsonb_build_object('tenant_id', v_tenant, 'company_id', v_company, 'branch_id', v_branch);
end;
$$;
grant execute on function public.bootstrap_organization(text,text,text) to authenticated;

-- ── Trigger: cria profile automaticamente ao criar auth.user ────────────────
create or replace function app.tg_handle_new_user() returns trigger
language plpgsql security definer set search_path = public, app as $$
begin
  insert into public.profiles (user_id, email, full_name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'full_name', new.email))
  on conflict (user_id) do nothing;
  return new;
end;
$$;
create trigger trg_on_auth_user_created after insert on auth.users
  for each row execute function app.tg_handle_new_user();

grant select, insert, update, delete on all tables in schema public to authenticated;
