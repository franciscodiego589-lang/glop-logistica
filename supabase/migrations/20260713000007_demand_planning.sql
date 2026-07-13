-- 20260713000007_demand_planning.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 07 — DEMAND PLANNING (Planejamento da Demanda / S&OP)              ║
-- ║  Histórico de demanda · previsões (métodos) · plano de vendas/operações.  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.forecast_method as enum ('manual','moving_average','exp_smoothing','linear_trend','seasonal','ai_logia');

create table public.demand_history (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  period_month date not null,                         -- 1º dia do mês
  channel text, quantity numeric(18,3) not null default 0, revenue numeric(16,2),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_demand_history_product on public.demand_history (product_id, period_month);
create unique index uq_demand_history_key on public.demand_history (product_id, warehouse_id, period_month, coalesce(channel,''));

create table public.demand_forecasts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid not null references public.products(id) on delete cascade,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  period_month date not null, method public.forecast_method not null default 'moving_average',
  forecast_quantity numeric(18,3) not null default 0, actual_quantity numeric(18,3),
  accuracy_percent numeric(6,2), model_version text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_demand_forecasts_product on public.demand_forecasts (product_id, period_month);
create unique index uq_demand_forecasts_key on public.demand_forecasts (product_id, warehouse_id, period_month, method);

create table public.demand_plans (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, period_start date, period_end date, status text not null default 'draft', notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create table public.demand_plan_lines (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  plan_id uuid not null references public.demand_plans(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  period_month date not null, planned_quantity numeric(18,3) not null default 0, consensus_quantity numeric(18,3),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_demand_plan_lines_plan on public.demand_plan_lines (plan_id);

-- ── RPC: previsão por média móvel a partir do histórico ──────────────────────
create or replace function public.forecast_moving_average(p_product uuid, p_warehouse uuid, p_window int default 3, p_horizon int default 6)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_tenant uuid; v_avg numeric; v_last date; v_i int; v_count int := 0;
begin
  select tenant_id, company_id into v_tenant, v_company from public.products where id = p_product;
  if not app.can_access_company(v_company) then raise exception 'forbidden'; end if;

  select avg(quantity) into v_avg from (
    select quantity from public.demand_history
    where product_id = p_product and (p_warehouse is null or warehouse_id = p_warehouse) and deleted_at is null
    order by period_month desc limit p_window
  ) s;
  select max(period_month) into v_last from public.demand_history
    where product_id = p_product and (p_warehouse is null or warehouse_id = p_warehouse) and deleted_at is null;
  v_avg := coalesce(v_avg, 0); v_last := coalesce(v_last, date_trunc('month', now())::date);

  for v_i in 1..p_horizon loop
    insert into public.demand_forecasts (tenant_id, company_id, product_id, warehouse_id, period_month, method, forecast_quantity, model_version)
    values (v_tenant, v_company, p_product, p_warehouse, (v_last + (v_i || ' month')::interval)::date, 'moving_average', round(v_avg,3), 'ma'||p_window)
    on conflict (product_id, warehouse_id, period_month, method)
    do update set forecast_quantity = excluded.forecast_quantity, updated_at = now();
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.forecast_moving_average(uuid,uuid,int,int) to authenticated;

do $do$
declare t text; specs text[] := array['demand_history','demand_forecasts','demand_plans','demand_plan_lines'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'demand.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'demand.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on all tables in schema public to authenticated;
