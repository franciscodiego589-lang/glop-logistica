-- 20260713000016_bi_dashboards.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 16 — DASHBOARDS EXECUTIVOS & BI                                    ║
-- ║  Dashboards persistidos · widgets · relatórios salvos ·                   ║
-- ║  RPC executive_dashboard (visão única cross-módulo em tempo real).        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create table public.dashboards (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, owner_id uuid references auth.users(id), is_shared boolean not null default false,
  layout jsonb not null default '[]'::jsonb,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_dashboards_owner on public.dashboards (owner_id);

create table public.dashboard_widgets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  dashboard_id uuid not null references public.dashboards(id) on delete cascade,
  widget_type text not null,                          -- kpi, bar, line, donut, table, map
  title text, data_source text, config jsonb not null default '{}'::jsonb, position integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_dashboard_widgets_dashboard on public.dashboard_widgets (dashboard_id);

create table public.saved_reports (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, report_type text, filters jsonb not null default '{}'::jsonb, schedule text,
  owner_id uuid references auth.users(id), last_run_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── RPC: dashboard executivo (agrega KPIs de todos os módulos) ───────────────
create or replace function public.executive_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select jsonb_build_object(
    'inventory',     public.inventory_kpis(p_company),
    'control_tower', public.control_tower_kpis(p_company),
    'orders', jsonb_build_object(
      'outbound_open',    (select count(*) from public.outbound_orders where company_id=p_company and status not in ('delivered','canceled') and deleted_at is null),
      'shipped_today',    (select count(*) from public.outbound_orders where company_id=p_company and shipped_at::date = now()::date and deleted_at is null),
      'purchase_open',    (select count(*) from public.purchase_orders where company_id=p_company and status in ('draft','sent','confirmed','partial') and deleted_at is null)
    ),
    'production', jsonb_build_object(
      'orders_open',      (select count(*) from public.production_orders where company_id=p_company and status in ('planned','released','in_progress') and deleted_at is null),
      'produced_month',   (select coalesce(sum(produced_quantity),0) from public.production_orders where company_id=p_company and finished_at >= date_trunc('month', now()) and deleted_at is null)
    ),
    'logia', jsonb_build_object(
      'new_insights',     (select count(*) from public.logia_insights where company_id=p_company and status='new' and deleted_at is null),
      'critical',         (select count(*) from public.logia_insights where company_id=p_company and status='new' and severity='critical' and deleted_at is null)
    ),
    'generated_at', now()
  ) where app.can_access_company(p_company);
$$;
grant execute on function public.executive_dashboard(uuid) to authenticated;

do $do$
declare t text; specs text[] := array['dashboards','dashboard_widgets','saved_reports'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'bi.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'bi.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on all tables in schema public to authenticated;
