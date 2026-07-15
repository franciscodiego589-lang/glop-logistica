-- 20260713000041_rams.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  RAMS — RETURNABLE ASSET MANAGEMENT SYSTEM (Vol 13)                        ║
-- ║  Pallets (PBR/CHEP), containers, IBCs, racks, gaiolas, caixas retornáveis:║
-- ║  ciclo de vida, empréstimos, cobrança por retenção, manutenção, perdas    ║
-- ║  (IA), ESG, TCO. Nível CHEP/Brambles. Recurso RBAC 'inventory'.           ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.asset_loan_status as enum ('open','partial','returned','overdue','written_off');

-- ── RETURNABLE_ASSET_TYPES (tipos/pool de ativos) ──────────────────────────
create table public.returnable_asset_types (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, name text not null, asset_class text default 'pallet',
  manufacturer text, unit_value numeric(14,2), useful_life_years integer,
  weight_g numeric(14,3), capacity_kg numeric(14,3), material text,
  total_quantity numeric(16,2) not null default 0, daily_retention_fee numeric(12,2) not null default 0,
  reuses integer not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── ASSET_LOANS (empréstimo/saída de ativos por detentor) ───────────────────
create table public.asset_loans (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  asset_type_id uuid not null references public.returnable_asset_types(id) on delete cascade,
  holder_type text not null default 'customer',   -- customer, carrier, branch, supplier
  customer_id uuid references public.customers(id) on delete set null,
  carrier_id uuid references public.carriers(id) on delete set null,
  holder_name text, quantity numeric(16,2) not null default 0, returned_quantity numeric(16,2) not null default 0,
  loan_date date default current_date, due_date date, daily_fee numeric(12,2), status public.asset_loan_status not null default 'open',
  reference_type text, reference_id uuid, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_asset_loans_status on public.asset_loans (company_id, status) where deleted_at is null;
create index idx_asset_loans_type on public.asset_loans (asset_type_id);

-- ── ASSET_MAINTENANCE (manutenção de ativos) ────────────────────────────────
create table public.asset_maintenance (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  asset_type_id uuid references public.returnable_asset_types(id) on delete cascade,
  maintenance_type text default 'repair', quantity numeric(16,2), description text, cost numeric(14,2), service_date date default current_date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_asset_maintenance_type on public.asset_maintenance (asset_type_id);

-- ── ASSET_CHARGES (cobrança por retenção) ───────────────────────────────────
create table public.asset_charges (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  loan_id uuid references public.asset_loans(id) on delete cascade,
  days_overdue integer, quantity numeric(16,2), amount numeric(14,2), status text not null default 'open',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_asset_charges_status on public.asset_charges (company_id, status) where deleted_at is null;

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Registra devolução de ativos (atualiza saldo do empréstimo)
create or replace function public.return_asset_loan(p_loan uuid, p_quantity numeric)
returns void
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_qty numeric; v_ret numeric; v_type uuid;
begin
  select company_id, quantity, returned_quantity, asset_type_id into v_company, v_qty, v_ret, v_type from public.asset_loans where id=p_loan;
  if v_company is null then raise exception 'empréstimo não encontrado'; end if;
  if not app.has_permission('inventory.update', v_company) then raise exception 'forbidden'; end if;
  update public.asset_loans
     set returned_quantity = least(v_qty, v_ret + p_quantity),
         status = case when v_ret + p_quantity >= v_qty then 'returned' else 'partial' end
   where id=p_loan;
  update public.returnable_asset_types set reuses = reuses + 1 where id = v_type;
end;
$$;
grant execute on function public.return_asset_loan(uuid, numeric) to authenticated;

-- Gera cobranças por retenção (empréstimos vencidos não devolvidos)
create or replace function public.generate_retention_charges(p_company uuid)
returns jsonb
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_total numeric := 0; v_l record; v_days int; v_out numeric; v_fee numeric; v_amt numeric;
begin
  if not app.has_permission('inventory.create', p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;

  for v_l in
    select l.*, t.daily_retention_fee from public.asset_loans l join public.returnable_asset_types t on t.id=l.asset_type_id
    where l.company_id=p_company and l.deleted_at is null and l.due_date < current_date and l.returned_quantity < l.quantity
      and not exists (select 1 from public.asset_charges c where c.loan_id=l.id and c.status='open' and c.deleted_at is null)
  loop
    v_days := (current_date - v_l.due_date);
    v_out := v_l.quantity - v_l.returned_quantity;
    v_fee := coalesce(v_l.daily_fee, v_l.daily_retention_fee, 0);
    v_amt := round(v_days * v_out * v_fee, 2);
    if v_amt > 0 then
      insert into public.asset_charges (tenant_id, company_id, loan_id, days_overdue, quantity, amount)
      values (v_tenant, p_company, v_l.id, v_days, v_out, v_amt);
      update public.asset_loans set status='overdue' where id=v_l.id;
      v_count := v_count + 1; v_total := v_total + v_amt;
    end if;
  end loop;
  return jsonb_build_object('charges', v_count, 'total', v_total);
end;
$$;
grant execute on function public.generate_retention_charges(uuid) to authenticated;

-- Dashboard RAMS (saldos, empréstimos, retenção, ESG)
create or replace function public.rams_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'asset_types', (select count(*) from public.returnable_asset_types where company_id=p_company and deleted_at is null),
    'total_assets', (select coalesce(sum(total_quantity),0) from public.returnable_asset_types where company_id=p_company and deleted_at is null),
    'on_loan', (select coalesce(sum(quantity-returned_quantity),0) from public.asset_loans where company_id=p_company and status in ('open','partial','overdue') and deleted_at is null),
    'available', (select coalesce(sum(total_quantity),0) from public.returnable_asset_types where company_id=p_company and deleted_at is null)
              - (select coalesce(sum(quantity-returned_quantity),0) from public.asset_loans where company_id=p_company and status in ('open','partial','overdue') and deleted_at is null),
    'overdue_loans', (select count(*) from public.asset_loans where company_id=p_company and status='overdue' and deleted_at is null),
    'charges_open', (select coalesce(sum(amount),0) from public.asset_charges where company_id=p_company and status='open' and deleted_at is null),
    'maintenance_cost', (select coalesce(sum(cost),0) from public.asset_maintenance where company_id=p_company and deleted_at is null),
    'reuses', (select coalesce(sum(reuses),0) from public.returnable_asset_types where company_id=p_company and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.rams_dashboard(uuid) to authenticated;

-- ESG dos ativos retornáveis (reutilização evita descartáveis)
create or replace function public.asset_esg(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then (
    select jsonb_build_object(
      'reuses', coalesce(sum(reuses),0),
      'savings_vs_disposable', round(coalesce(sum(reuses * unit_value * 0.7),0),2),
      'co2_avoided_kg', round(coalesce(sum(reuses * 2.5),0),1)   -- ~2,5kg CO2 evitado por reutilização
    ) from public.returnable_asset_types where company_id=p_company and deleted_at is null
  ) else '{}'::jsonb end;
$$;
grant execute on function public.asset_esg(uuid) to authenticated;

-- IA: retenção por detentor / ativos parados → insights
create or replace function public.rams_insights(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_r record;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and kind='supplier_risk' and status='new' and title like 'Ativos%' and deleted_at is null;

  for v_r in
    select coalesce(holder_name, 'detentor') hn, count(*) c, sum(quantity-returned_quantity) q from public.asset_loans
    where company_id=p_company and deleted_at is null and status in ('overdue','partial') and due_date < current_date
    group by holder_name having sum(quantity-returned_quantity) > 0 order by sum(quantity-returned_quantity) desc limit 10
  loop
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'supplier_risk', 'warning', 'Ativos retidos: '||v_r.hn,
      v_r.q||' ativo(s) retido(s) por "'||v_r.hn||'" após o prazo.', 'Cobrar/recolher os ativos.', 84);
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.rams_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela ────────────────────────────
do $do$
declare t text; specs text[] := array['returnable_asset_types','asset_loans','asset_maintenance','asset_charges'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'inventory.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'inventory.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

notify pgrst, 'reload schema';
