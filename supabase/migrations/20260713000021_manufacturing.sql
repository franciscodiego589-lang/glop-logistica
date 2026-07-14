-- 20260713000021_manufacturing.sql
-- VOLUME 07 · MANUFACTURING (MFG) — camada de governança sobre a produção.
-- NÃO duplica /producao (ordens/consumo), /mrp (BOM) nem /mes (chão de fábrica):
-- adiciona o que faltava — aprovação/versionamento de receitas (GMP) e linhas de produção.
-- Reusa o recurso RBAC 'production'.

-- ── 1) Aprovação/versionamento de RECEITAS (bills_of_materials) ──────────────
alter table public.bills_of_materials
  add column if not exists status text not null default 'draft',   -- draft, approved, obsolete
  add column if not exists version_label text,
  add column if not exists approved_by uuid references auth.users(id),
  add column if not exists approved_at timestamptz;

-- histórico de revisões (snapshot dos componentes na aprovação)
create table if not exists public.bom_revisions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  bom_id uuid not null references public.bills_of_materials(id) on delete cascade,
  version_label text, status text, note text,
  components jsonb not null default '[]'::jsonb,   -- snapshot dos componentes
  approved_by uuid references auth.users(id), approved_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_bom_revisions_bom on public.bom_revisions (bom_id, created_at desc);

-- ── 2) LINHAS DE PRODUÇÃO (hierarquia de centro produtivo) ──────────────────
create table if not exists public.production_lines (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  work_center_id uuid references public.work_centers(id) on delete set null,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  code text, name text not null, line_type text,          -- discreta, continua, batelada, processo
  capacity_per_hour numeric(14,4), oee_target numeric(6,2), setup_minutes numeric(12,2),
  responsible text, shift_pattern text, calendar_notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_production_lines_wc on public.production_lines (work_center_id);
create unique index if not exists uq_production_lines_code on public.production_lines (company_id, lower(code)) where code is not null and deleted_at is null;

-- ── RLS + triggers (recurso 'production') ───────────────────────────────────
do $do$
declare t text; specs text[] := array['bom_revisions','production_lines'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'production.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'production.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on all tables in schema public to authenticated;

-- ── RPC: aprovar receita — snapshot dos componentes + marca aprovada ────────
create or replace function public.approve_bom(p_bom uuid, p_note text default null)
returns uuid
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_tenant uuid; v_ver text; v_snap jsonb; v_rev uuid;
begin
  select company_id, tenant_id, version_label into v_company, v_tenant, v_ver
  from public.bills_of_materials where id = p_bom;
  if v_company is null then raise exception 'BOM % not found', p_bom; end if;
  if not app.has_permission('production.update', v_company) then raise exception 'forbidden'; end if;

  select coalesce(jsonb_agg(jsonb_build_object(
           'component_product_id', component_product_id, 'quantity', quantity,
           'uom_code', uom_code, 'scrap_percent', scrap_percent)), '[]'::jsonb)
    into v_snap
  from public.bom_components where bom_id = p_bom and deleted_at is null;

  insert into public.bom_revisions (tenant_id, company_id, bom_id, version_label, status, note, components, approved_by, approved_at)
  values (v_tenant, v_company, p_bom, coalesce(v_ver, 'v'||to_char(now(),'YYYYMMDDHH24MI')), 'approved', p_note, v_snap, auth.uid(), now())
  returning id into v_rev;

  update public.bills_of_materials
    set status = 'approved', approved_by = auth.uid(), approved_at = now(),
        version_label = coalesce(version_label, 'v'||to_char(now(),'YYYYMMDDHH24MI'))
  where id = p_bom;

  return v_rev;
end;
$$;
grant execute on function public.approve_bom(uuid,text) to authenticated;
