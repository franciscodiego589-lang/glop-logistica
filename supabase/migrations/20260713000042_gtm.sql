-- 20260713000042_gtm.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  GTM — GLOBAL TRADE MANAGEMENT (Vol 14) — Comércio Exterior                ║
-- ║  Importação/exportação, Incoterms, aduana, classificação NCM/HS, portos/  ║
-- ║  aeroportos, drawback, documentos + SIMULADOR de custo nacionalizado.     ║
-- ║  Nível SAP GTS / Oracle GTM / CargoWise. Novo recurso RBAC 'gtm'.         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.trade_direction as enum ('import','export');
create type public.trade_status    as enum ('negotiation','ordered','shipped','in_transit','customs','cleared','delivered','canceled');

-- recurso RBAC dedicado
insert into public.permissions (slug, resource, action, description)
select 'gtm.' || a, 'gtm', a, 'Permissão ' || a || ' em gtm'
from unnest(array['read','create','update','delete','approve','export']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'gtm' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── TRADE_PARTNERS (fornecedor int'l, trading, despachante, agente, armador) ─
create table public.trade_partners (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  partner_type text not null default 'supplier', name text not null, country text, document text,
  contact text, email text, phone text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── TRADE_LOCATIONS (portos, aeroportos, fronteiras, terminais) ─────────────
create table public.trade_locations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  location_type text not null default 'port', code text, name text not null, country text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── HS_CLASSIFICATIONS (NCM / HS Code + tributos) ───────────────────────────
create table public.hs_classifications (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid references public.products(id) on delete set null,
  ncm text, hs_code text, description text,
  ii_pct numeric(8,4), ipi_pct numeric(8,4), pis_pct numeric(8,4), cofins_pct numeric(8,4), icms_pct numeric(8,4),
  ex_tarifario text, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_hs_classifications_ncm on public.hs_classifications (company_id, ncm);

-- ── TRADE_PROCESSES (import/export) ─────────────────────────────────────────
create table public.trade_processes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  direction public.trade_direction not null default 'import',
  code text, incoterm text, partner_id uuid references public.trade_partners(id) on delete set null,
  origin_country text, dest_country text, location_id uuid references public.trade_locations(id) on delete set null,
  currency text default 'USD', exchange_rate numeric(12,4),
  fob_value numeric(18,2), freight_value numeric(18,2), insurance_value numeric(18,2),
  status public.trade_status not null default 'negotiation', channel text,
  invoice_number text, di_number text, duimp_number text, due_number text, bl_awb text,
  eta date, cleared_at date, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_trade_processes_status on public.trade_processes (company_id, direction, status) where deleted_at is null;

-- ── TRADE_DOCUMENTS (invoice/packing/BL/AWB/certificados/LPCO/DI/DU-E) ───────
create table public.trade_documents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  process_id uuid references public.trade_processes(id) on delete cascade,
  doc_type text not null, number text, url text, storage_path text, issued_at date, status text not null default 'pending',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_trade_documents_process on public.trade_documents (process_id);

-- ── DRAWBACK_ACTS (atos concessórios) ───────────────────────────────────────
create table public.drawback_acts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  act_number text, act_type text default 'suspension', total_value numeric(18,2), consumed_value numeric(18,2) not null default 0,
  balance numeric(18,2), valid_to date, status text not null default 'active', notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_drawback_acts_valid on public.drawback_acts (company_id, valid_to) where deleted_at is null;

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Simulador de custo de importação (CIF → tributos → custo nacionalizado)
create or replace function public.import_cost_simulator(
  p_company uuid, p_fob numeric, p_freight numeric default 0, p_insurance numeric default 0,
  p_ii_pct numeric default 0, p_ipi_pct numeric default 0, p_pis_pct numeric default 2.1,
  p_cofins_pct numeric default 9.65, p_icms_pct numeric default 18, p_expenses numeric default 0)
returns jsonb
language plpgsql stable security definer set search_path = public, app as $$
declare v_cif numeric; v_ii numeric; v_ipi numeric; v_pis numeric; v_cofins numeric; v_base_icms numeric; v_icms numeric; v_landed numeric;
begin
  if not app.can_access_company(p_company) then return '{}'::jsonb; end if;
  v_cif    := coalesce(p_fob,0) + coalesce(p_freight,0) + coalesce(p_insurance,0);
  v_ii     := round(v_cif * coalesce(p_ii_pct,0)/100, 2);
  v_ipi    := round((v_cif + v_ii) * coalesce(p_ipi_pct,0)/100, 2);
  v_pis    := round(v_cif * coalesce(p_pis_pct,0)/100, 2);
  v_cofins := round(v_cif * coalesce(p_cofins_pct,0)/100, 2);
  -- ICMS "por dentro": base = (CIF+II+IPI+PIS+COFINS+despesas)/(1 - aliq)
  v_base_icms := (v_cif + v_ii + v_ipi + v_pis + v_cofins + coalesce(p_expenses,0)) / nullif(1 - coalesce(p_icms_pct,0)/100, 0);
  v_icms   := round(coalesce(v_base_icms,0) * coalesce(p_icms_pct,0)/100, 2);
  v_landed := round(v_cif + v_ii + v_ipi + v_pis + v_cofins + v_icms + coalesce(p_expenses,0), 2);
  return jsonb_build_object(
    'cif', round(v_cif,2), 'ii', v_ii, 'ipi', v_ipi, 'pis', v_pis, 'cofins', v_cofins, 'icms', v_icms,
    'expenses', coalesce(p_expenses,0), 'total_taxes', round(v_ii+v_ipi+v_pis+v_cofins+v_icms,2),
    'landed_cost', v_landed, 'markup_over_fob', case when coalesce(p_fob,0)>0 then round((v_landed/p_fob-1)*100,1) else null end
  );
end;
$$;
grant execute on function public.import_cost_simulator(uuid,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric) to authenticated;

-- Dashboard GTM
create or replace function public.gtm_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'imports_open', (select count(*) from public.trade_processes where company_id=p_company and direction='import' and status not in ('delivered','canceled') and deleted_at is null),
    'exports_open', (select count(*) from public.trade_processes where company_id=p_company and direction='export' and status not in ('delivered','canceled') and deleted_at is null),
    'in_customs', (select count(*) from public.trade_processes where company_id=p_company and status='customs' and deleted_at is null),
    'fob_open', (select coalesce(sum(fob_value),0) from public.trade_processes where company_id=p_company and status not in ('delivered','canceled') and deleted_at is null),
    'partners', (select count(*) from public.trade_partners where company_id=p_company and deleted_at is null),
    'locations', (select count(*) from public.trade_locations where company_id=p_company and deleted_at is null),
    'drawback_balance', (select coalesce(sum(balance),0) from public.drawback_acts where company_id=p_company and status='active' and deleted_at is null),
    'drawback_expiring', (select count(*) from public.drawback_acts where company_id=p_company and status='active' and valid_to <= now()::date + 60 and deleted_at is null),
    'pending_docs', (select count(*) from public.trade_documents where company_id=p_company and status='pending' and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.gtm_dashboard(uuid) to authenticated;

-- IA GTM: processos parados na aduana / drawback vencendo → insights
create or replace function public.gtm_insights(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_cust int; v_draw int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and kind='sla_risk' and status='new' and title like 'Comex%' and deleted_at is null;

  select count(*) into v_cust from public.trade_processes where company_id=p_company and status='customs' and eta < now()::date and deleted_at is null;
  if v_cust > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'warning', 'Comex: processos parados na aduana', v_cust||' processo(s) na aduana além da previsão.', 'Acionar despachante — risco de demurrage.', 82);
    v_count := v_count + 1;
  end if;
  select count(*) into v_draw from public.drawback_acts where company_id=p_company and status='active' and valid_to <= now()::date + 60 and deleted_at is null;
  if v_draw > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'cost_saving', 'warning', 'Comex: drawback a vencer', v_draw||' ato(s) de drawback vencem em 60 dias.', 'Consumir/comprovar exportações antes do prazo.', 85);
    v_count := v_count + 1;
  end if;
  return v_count;
end;
$$;
grant execute on function public.gtm_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'gtm') ────────────
do $do$
declare t text; specs text[] := array['trade_partners','trade_locations','hs_classifications','trade_processes','trade_documents','drawback_acts'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'gtm.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'gtm.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

notify pgrst, 'reload schema';
