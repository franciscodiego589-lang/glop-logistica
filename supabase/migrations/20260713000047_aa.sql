-- 20260713000047_aa.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  EAA — ENTERPRISE ASSET ACCOUNTING (Vol 15) — Patrimônio & Ativos Fixos   ║
-- ║  Camada CONTÁBIL/patrimonial (≠ EAM operacional Vol 10): cadastro         ║
-- ║  patrimonial, depreciação por método (posta no GL automaticamente),       ║
-- ║  reavaliação/impairment, transferências, seguros/garantias, inventário.   ║
-- ║  Nível SAP FI-AA / Oracle Fixed Assets. aa_insights auto-descoberto LAIOS.║
-- ╚══════════════════════════════════════════════════════════════════════════╝

do $e$ begin
  if not exists (select 1 from pg_type where typname='depreciation_method') then
    create type public.depreciation_method as enum ('linear','declining','units'); end if;
  if not exists (select 1 from pg_type where typname='fixed_asset_status') then
    create type public.fixed_asset_status as enum ('draft','active','idle','maintenance','disposed','written_off'); end if;
end $e$;

-- recurso RBAC 'fixed_assets'
insert into public.permissions (slug, resource, action, description)
select 'fixed_assets.' || a, 'fixed_assets', a, 'Permissão ' || a || ' em fixed_assets'
from unnest(array['read','create','update','delete','approve','depreciate']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'fixed_assets' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── ASSET_CATEGORIES (com política de depreciação padrão) ───────────────────
create table public.asset_categories (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, default_method public.depreciation_method not null default 'linear',
  useful_life_months integer not null default 60, residual_pct numeric(6,2) not null default 0, is_intangible boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── FIXED_ASSETS (ativos patrimoniais) ──────────────────────────────────────
create table public.fixed_assets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  asset_code text, name text not null, category_id uuid references public.asset_categories(id) on delete set null,
  serial_number text, manufacturer text, model text,
  acquisition_date date, acquisition_value numeric(18,2) not null default 0, residual_value numeric(18,2),
  useful_life_months integer, depreciation_method public.depreciation_method,
  in_service_date date, accumulated_depreciation numeric(18,2) not null default 0,
  cost_center_id uuid references public.cost_centers(id) on delete set null,
  profit_center_id uuid references public.profit_centers(id) on delete set null,
  location text, responsible text, condition text, status public.fixed_asset_status not null default 'active',
  warranty_until date, insured_value numeric(18,2), eam_asset_id uuid, last_inventory_at date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_fixed_assets_status on public.fixed_assets (company_id, status) where deleted_at is null;
create index idx_fixed_assets_category on public.fixed_assets (category_id);

-- ── DEPRECIATION_ENTRIES ────────────────────────────────────────────────────
create table public.depreciation_entries (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  asset_id uuid not null references public.fixed_assets(id) on delete cascade,
  fiscal_year integer not null, fiscal_month integer not null, method public.depreciation_method not null,
  base_value numeric(18,2) not null default 0, amount numeric(18,2) not null default 0,
  accumulated_after numeric(18,2) not null default 0, book_value_after numeric(18,2) not null default 0,
  posted boolean not null default false, journal_ref uuid,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_depr_entry on public.depreciation_entries (asset_id, fiscal_year, fiscal_month) where deleted_at is null;

-- ── ASSET_REVALUATIONS (reavaliação / impairment) ───────────────────────────
create table public.asset_revaluations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  asset_id uuid not null references public.fixed_assets(id) on delete cascade,
  reval_type text not null default 'revaluation_up', old_net numeric(18,2), new_net numeric(18,2),
  delta numeric(18,2) generated always as (coalesce(new_net,0) - coalesce(old_net,0)) stored,
  reval_date date default now()::date, reason text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── ASSET_TRANSFERS ─────────────────────────────────────────────────────────
create table public.asset_transfers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  asset_id uuid not null references public.fixed_assets(id) on delete cascade,
  from_location text, to_location text, from_responsible text, to_responsible text,
  from_cost_center_id uuid references public.cost_centers(id) on delete set null,
  to_cost_center_id uuid references public.cost_centers(id) on delete set null,
  transfer_date date default now()::date, reason text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── ASSET_INSURANCES (apólices + garantias) ─────────────────────────────────
create table public.asset_insurances (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  asset_id uuid references public.fixed_assets(id) on delete set null,
  policy_number text, insurer text, coverage text, insured_value numeric(18,2), deductible numeric(18,2),
  valid_from date, valid_to date, status text not null default 'active', notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_asset_insurances_valid on public.asset_insurances (company_id, valid_to) where deleted_at is null;

-- ── ASSET_INVENTORY_COUNTS (inventário patrimonial físico × sistema) ────────
create table public.asset_inventory_counts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  asset_id uuid references public.fixed_assets(id) on delete cascade,
  counted_at date default now()::date, found boolean not null default true,
  location_found text, condition text, divergence text, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Rodar depreciação do período: calcula por método, grava entries, atualiza
-- acumulada e POSTA no GL (evento 'depreciation'). Idempotente por ativo/período.
create or replace function public.run_depreciation(p_company uuid, p_year int, p_month int)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare
  v_tenant uuid; a record; v_method public.depreciation_method; v_useful int; v_residual numeric;
  v_depreciable numeric; v_amount numeric; v_remaining numeric; v_new_accum numeric;
  v_count int := 0; v_total numeric := 0; v_gl jsonb; v_journal uuid;
begin
  if not (app.can_access_company(p_company) and app.has_permission('fixed_assets.depreciate', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id = p_company;

  for a in
    select fa.*, c.default_method c_method, c.useful_life_months c_useful, c.residual_pct c_residual
    from public.fixed_assets fa left join public.asset_categories c on c.id = fa.category_id
    where fa.company_id = p_company and fa.status in ('active','idle') and fa.deleted_at is null
      and fa.in_service_date is not null and fa.acquisition_value > 0
  loop
    if exists (select 1 from public.depreciation_entries where asset_id=a.id and fiscal_year=p_year and fiscal_month=p_month and deleted_at is null) then continue; end if;
    v_method   := coalesce(a.depreciation_method, a.c_method, 'linear');
    v_useful   := coalesce(a.useful_life_months, a.c_useful, 60);
    v_residual := coalesce(a.residual_value, round(a.acquisition_value * coalesce(a.c_residual,0)/100, 2), 0);
    v_depreciable := a.acquisition_value - v_residual;
    if a.accumulated_depreciation >= v_depreciable then continue; end if;

    if v_method = 'declining' then
      v_amount := round((a.acquisition_value - a.accumulated_depreciation) * (2.0 / nullif(v_useful,0)), 2);
    else -- linear e fallback de 'units'
      v_amount := round(v_depreciable / nullif(v_useful,0), 2);
    end if;

    v_remaining := v_depreciable - a.accumulated_depreciation;
    if v_amount > v_remaining then v_amount := v_remaining; end if;
    if v_amount <= 0 then continue; end if;
    v_new_accum := a.accumulated_depreciation + v_amount;

    insert into public.depreciation_entries (tenant_id, company_id, asset_id, fiscal_year, fiscal_month, method, base_value, amount, accumulated_after, book_value_after, posted)
    values (v_tenant, p_company, a.id, p_year, p_month, v_method, v_depreciable, v_amount, v_new_accum, a.acquisition_value - v_new_accum, false);
    update public.fixed_assets set accumulated_depreciation = v_new_accum where id = a.id;
    v_total := v_total + v_amount; v_count := v_count + 1;
  end loop;

  -- posta o total no GL (não aborta a depreciação se faltar permissão contábil)
  if v_total > 0 then
    begin
      v_gl := public.post_accounting_event(p_company, 'depreciation', v_total, 'Depreciação '||p_year||'/'||lpad(p_month::text,2,'0'), 'AA-'||p_year||lpad(p_month::text,2,'0'), 'fixed_assets', null);
      v_journal := (v_gl->>'id')::uuid;
      update public.depreciation_entries set posted=true, journal_ref=v_journal
        where company_id=p_company and fiscal_year=p_year and fiscal_month=p_month and not posted and deleted_at is null;
    exception when others then null;
    end;
  end if;

  return jsonb_build_object('period', p_year||'-'||lpad(p_month::text,2,'0'), 'assets_depreciated', v_count,
    'total_depreciation', round(v_total,2), 'posted_to_gl', v_journal is not null, 'journal_id', v_journal);
end;
$$;
grant execute on function public.run_depreciation(uuid, int, int) to authenticated;

-- Reavaliação / impairment: ajusta o valor líquido para new_net (via acumulada) e registra histórico.
create or replace function public.revalue_asset(p_asset uuid, p_new_net numeric, p_type text default 'revaluation_up', p_reason text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare a record; v_old_net numeric; v_delta numeric;
begin
  select * into a from public.fixed_assets where id=p_asset and deleted_at is null;
  if a.id is null then raise exception 'ativo não encontrado'; end if;
  if not (app.can_access_company(a.company_id) and app.has_permission('fixed_assets.approve', a.company_id)) then raise exception 'forbidden'; end if;
  v_old_net := a.acquisition_value - a.accumulated_depreciation;
  v_delta := round(p_new_net - v_old_net, 2);
  -- ajusta a depreciação acumulada para que o líquido passe a ser new_net
  update public.fixed_assets set accumulated_depreciation = a.acquisition_value - round(p_new_net,2) where id=p_asset;
  insert into public.asset_revaluations (tenant_id, company_id, asset_id, reval_type, old_net, new_net, reason)
  values (a.tenant_id, a.company_id, p_asset, p_type, v_old_net, round(p_new_net,2), p_reason);
  return jsonb_build_object('asset_id', p_asset, 'old_net', v_old_net, 'new_net', round(p_new_net,2), 'delta', v_delta);
end;
$$;
grant execute on function public.revalue_asset(uuid, numeric, text, text) to authenticated;

-- Transferência de ativo (atualiza local/responsável/centro de custo + trilha)
create or replace function public.transfer_asset(p_asset uuid, p_to_location text default null, p_to_responsible text default null, p_to_cost_center uuid default null, p_reason text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare a record;
begin
  select * into a from public.fixed_assets where id=p_asset and deleted_at is null;
  if a.id is null then raise exception 'ativo não encontrado'; end if;
  if not (app.can_access_company(a.company_id) and app.has_permission('fixed_assets.update', a.company_id)) then raise exception 'forbidden'; end if;
  insert into public.asset_transfers (tenant_id, company_id, asset_id, from_location, to_location, from_responsible, to_responsible, from_cost_center_id, to_cost_center_id, reason)
  values (a.tenant_id, a.company_id, p_asset, a.location, coalesce(p_to_location, a.location), a.responsible, coalesce(p_to_responsible, a.responsible), a.cost_center_id, coalesce(p_to_cost_center, a.cost_center_id), p_reason);
  update public.fixed_assets set location=coalesce(p_to_location, location), responsible=coalesce(p_to_responsible, responsible), cost_center_id=coalesce(p_to_cost_center, cost_center_id) where id=p_asset;
  return jsonb_build_object('asset_id', p_asset, 'transferred', true);
end;
$$;
grant execute on function public.transfer_asset(uuid, text, text, uuid, text) to authenticated;

-- Dashboard patrimonial
create or replace function public.aa_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'assets_count', (select count(*) from public.fixed_assets where company_id=p_company and status<>'written_off' and deleted_at is null),
    'gross_value', (select coalesce(sum(acquisition_value),0) from public.fixed_assets where company_id=p_company and status<>'written_off' and deleted_at is null),
    'accumulated_depreciation', (select coalesce(sum(accumulated_depreciation),0) from public.fixed_assets where company_id=p_company and status<>'written_off' and deleted_at is null),
    'net_book_value', (select coalesce(sum(acquisition_value - accumulated_depreciation),0) from public.fixed_assets where company_id=p_company and status<>'written_off' and deleted_at is null),
    'idle', (select count(*) from public.fixed_assets where company_id=p_company and status='idle' and deleted_at is null),
    'uninsured', (select count(*) from public.fixed_assets where company_id=p_company and status in ('active','idle') and deleted_at is null and id not in (select asset_id from public.asset_insurances where company_id=p_company and asset_id is not null and status='active' and (valid_to is null or valid_to>=now()::date) and deleted_at is null)),
    'warranty_expiring', (select count(*) from public.fixed_assets where company_id=p_company and warranty_until is not null and warranty_until between now()::date and now()::date+90 and deleted_at is null),
    'fully_depreciated_active', (select count(*) from public.fixed_assets where company_id=p_company and status in ('active','idle') and deleted_at is null and accumulated_depreciation >= (acquisition_value - coalesce(residual_value,0)) and acquisition_value>0),
    'by_category', (select coalesce(jsonb_object_agg(cname, cnt),'{}'::jsonb) from (
        select coalesce(c.name,'Sem categoria') cname, count(*) cnt from public.fixed_assets fa left join public.asset_categories c on c.id=fa.category_id
        where fa.company_id=p_company and fa.status<>'written_off' and fa.deleted_at is null group by c.name) s)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.aa_dashboard(uuid) to authenticated;

-- IA PATRIMONIAL: ativos ociosos, sem seguro, garantia vencendo, 100% depreciados ativos → LOGIA
create or replace function public.aa_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_idle int; v_unins int; v_warr int; v_full int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Patrimônio%' and deleted_at is null;

  select count(*) into v_idle from public.fixed_assets where company_id=p_company and status='idle' and deleted_at is null;
  if v_idle > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'waste', 'warning', 'Patrimônio: ativos ociosos', v_idle||' ativo(s) parado(s)/ocioso(s).', 'Avaliar realocação, locação ou alienação para liberar capital.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_unins from public.fixed_assets where company_id=p_company and status in ('active','idle') and deleted_at is null
    and id not in (select asset_id from public.asset_insurances where company_id=p_company and asset_id is not null and status='active' and (valid_to is null or valid_to>=now()::date) and deleted_at is null);
  if v_unins > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'supplier_risk', 'warning', 'Patrimônio: ativos sem seguro', v_unins||' ativo(s) sem apólice vigente.', 'Contratar/renovar seguro — exposição a perda total sem cobertura.', 80);
    v_c := v_c + 1;
  end if;
  select count(*) into v_warr from public.fixed_assets where company_id=p_company and warranty_until is not null and warranty_until between now()::date and now()::date+90 and deleted_at is null;
  if v_warr > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'info', 'Patrimônio: garantias a vencer', v_warr||' garantia(s) vencem em 90 dias.', 'Acionar cobertura pendente ou renovar contrato de manutenção.', 75);
    v_c := v_c + 1;
  end if;
  select count(*) into v_full from public.fixed_assets where company_id=p_company and status in ('active','idle') and deleted_at is null and acquisition_value>0 and accumulated_depreciation >= (acquisition_value - coalesce(residual_value,0));
  if v_full > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'opportunity', 'info', 'Patrimônio: ativos 100% depreciados em uso', v_full||' ativo(s) totalmente depreciado(s) ainda em operação.', 'Planejar renovação/CAPEX; considerar reavaliação técnica.', 72);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.aa_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'fixed_assets') ───
do $do$
declare t text; specs text[] := array['asset_categories','fixed_assets','depreciation_entries','asset_revaluations','asset_transfers','asset_insurances','asset_inventory_counts'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'fixed_assets.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'fixed_assets.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: categorias patrimoniais (suplementos + clínica) ══
do $do$
declare c record;
  cats jsonb := '[
    {"n":"Máquinas Industriais","m":"linear","u":120,"r":10,"i":false},
    {"n":"Equipamentos Laboratoriais","m":"linear","u":120,"r":10,"i":false},
    {"n":"Equipamentos de Utilidades (HVAC/Câmara Fria)","m":"linear","u":120,"r":10,"i":false},
    {"n":"Equipamentos Estéticos (Laser/RF/Criolipólise)","m":"linear","u":60,"r":10,"i":false},
    {"n":"Veículos","m":"linear","u":60,"r":20,"i":false},
    {"n":"Móveis e Utensílios","m":"linear","u":120,"r":10,"i":false},
    {"n":"Computadores e TI","m":"linear","u":60,"r":0,"i":false},
    {"n":"Edificações / Imóveis","m":"linear","u":300,"r":0,"i":false},
    {"n":"Intangíveis (Software/Licenças/Marcas)","m":"linear","u":60,"r":0,"i":true}
  ]'::jsonb;
  a jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    for a in select value from jsonb_array_elements(cats) loop
      if not exists (select 1 from public.asset_categories where company_id=c.id and name=(a->>'n') and deleted_at is null) then
        insert into public.asset_categories (tenant_id, company_id, name, default_method, useful_life_months, residual_pct, is_intangible)
        values (c.tenant_id, c.id, a->>'n', (a->>'m')::public.depreciation_method, (a->>'u')::int, (a->>'r')::numeric, (a->>'i')::boolean);
      end if;
    end loop;
  end loop;
end $do$;

notify pgrst, 'reload schema';
