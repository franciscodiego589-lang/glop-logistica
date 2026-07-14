-- 20260713000026_finance.sql
-- VOLUME 11 · ENTERPRISE FINANCE — Tesouraria, Contas a Pagar/Receber, Fluxo de Caixa.
-- Diferencial: títulos NASCEM das operações (payables de purchase_orders, receivables de outbound_orders).
-- Reusa recurso RBAC 'admin' (finance = privilegiado; roadmap: recurso 'finance' dedicado c/ segregação SOX).
-- grant POR-TABELA (nunca "on all tables").

-- ── ENUMS ────────────────────────────────────────────────────────────────────
create type public.fin_doc_status  as enum ('open','partial','paid','overdue','canceled');
create type public.fin_pay_method  as enum ('pix','ted','doc','boleto','card','cash','transfer','other');
create type public.bank_acct_type  as enum ('checking','savings','digital','cash','investment');

-- ── COST_CENTERS (centros de custo, hierárquicos) ───────────────────────────
create table public.cost_centers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  parent_id uuid references public.cost_centers(id) on delete set null,
  code text, name text not null, cc_type text default 'department',   -- factory, department, project, branch, line
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_cost_centers_code on public.cost_centers (company_id, lower(code)) where code is not null and deleted_at is null;

-- ── BANK_ACCOUNTS (tesouraria) ──────────────────────────────────────────────
create table public.bank_accounts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, bank_name text, bank_code text, agency text, account_number text,
  account_type public.bank_acct_type not null default 'checking', currency text not null default 'BRL',
  pix_key text, current_balance numeric(18,2) not null default 0, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── BANK_TRANSACTIONS (movimentos / extrato / conciliação) ──────────────────
create table public.bank_transactions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  bank_account_id uuid references public.bank_accounts(id) on delete set null,
  txn_date date not null default current_date, amount numeric(18,2) not null,   -- + entrada / − saída
  description text, txn_type text, reconciled boolean not null default false,
  reference_type text, reference_id uuid,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_bank_txn_account on public.bank_transactions (bank_account_id, txn_date desc);

-- ── PAYABLES (contas a pagar) ───────────────────────────────────────────────
create table public.payables (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  supplier_id uuid references public.suppliers(id) on delete set null,
  cost_center_id uuid references public.cost_centers(id) on delete set null,
  purchase_order_id uuid references public.purchase_orders(id) on delete set null,
  bank_account_id uuid references public.bank_accounts(id) on delete set null,
  code text, description text, category text,
  amount numeric(18,2) not null default 0, paid_amount numeric(18,2) not null default 0,
  status public.fin_doc_status not null default 'open', payment_method public.fin_pay_method,
  issued_at date default current_date, due_date date, paid_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_payables_status on public.payables (company_id, status) where deleted_at is null;
create index idx_payables_due on public.payables (company_id, due_date) where deleted_at is null;
create unique index uq_payables_po on public.payables (purchase_order_id) where purchase_order_id is not null and deleted_at is null;

-- ── RECEIVABLES (contas a receber) ──────────────────────────────────────────
create table public.receivables (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  customer_id uuid references public.customers(id) on delete set null,
  cost_center_id uuid references public.cost_centers(id) on delete set null,
  outbound_order_id uuid references public.outbound_orders(id) on delete set null,
  bank_account_id uuid references public.bank_accounts(id) on delete set null,
  code text, description text, category text,
  amount numeric(18,2) not null default 0, received_amount numeric(18,2) not null default 0,
  status public.fin_doc_status not null default 'open', payment_method public.fin_pay_method,
  issued_at date default current_date, due_date date, received_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_receivables_status on public.receivables (company_id, status) where deleted_at is null;
create index idx_receivables_due on public.receivables (company_id, due_date) where deleted_at is null;
create unique index uq_receivables_oo on public.receivables (outbound_order_id) where outbound_order_id is not null and deleted_at is null;

-- ── RLS + triggers (recurso 'admin') ────────────────────────────────────────
do $do$
declare t text; specs text[] := array['cost_centers','bank_accounts','bank_transactions','payables','receivables'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'admin.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'admin.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on
  public.cost_centers, public.bank_accounts, public.bank_transactions,
  public.payables, public.receivables to authenticated;

-- ── RPC: baixa de conta a pagar (registra pagamento + movimento bancário) ───
create or replace function public.pay_payable(p_payable uuid, p_amount numeric, p_bank_account uuid default null, p_method public.fin_pay_method default 'pix')
returns text
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_tenant uuid; v_amount numeric; v_paid numeric; v_new numeric; v_status public.fin_doc_status;
begin
  select company_id, tenant_id, amount, paid_amount into v_company, v_tenant, v_amount, v_paid from public.payables where id = p_payable;
  if v_company is null then raise exception 'payable % not found', p_payable; end if;
  if not app.has_permission('admin.update', v_company) then raise exception 'forbidden'; end if;
  v_new := coalesce(v_paid,0) + p_amount;
  v_status := case when v_new >= v_amount then 'paid' else 'partial' end;
  update public.payables set paid_amount = v_new, status = v_status, payment_method = p_method,
    bank_account_id = coalesce(p_bank_account, bank_account_id),
    paid_at = case when v_status = 'paid' then now() else paid_at end
  where id = p_payable;
  if p_bank_account is not null then
    insert into public.bank_transactions (tenant_id, company_id, bank_account_id, amount, description, txn_type, reference_type, reference_id)
    values (v_tenant, v_company, p_bank_account, -abs(p_amount), 'Pagamento a fornecedor', 'payable', 'payable', p_payable);
    update public.bank_accounts set current_balance = coalesce(current_balance,0) - abs(p_amount) where id = p_bank_account;
  end if;
  return v_status::text;
end;
$$;
grant execute on function public.pay_payable(uuid,numeric,uuid,public.fin_pay_method) to authenticated;

-- ── RPC: baixa de conta a receber ───────────────────────────────────────────
create or replace function public.receive_receivable(p_receivable uuid, p_amount numeric, p_bank_account uuid default null, p_method public.fin_pay_method default 'pix')
returns text
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_tenant uuid; v_amount numeric; v_recv numeric; v_new numeric; v_status public.fin_doc_status;
begin
  select company_id, tenant_id, amount, received_amount into v_company, v_tenant, v_amount, v_recv from public.receivables where id = p_receivable;
  if v_company is null then raise exception 'receivable % not found', p_receivable; end if;
  if not app.has_permission('admin.update', v_company) then raise exception 'forbidden'; end if;
  v_new := coalesce(v_recv,0) + p_amount;
  v_status := case when v_new >= v_amount then 'paid' else 'partial' end;
  update public.receivables set received_amount = v_new, status = v_status, payment_method = p_method,
    bank_account_id = coalesce(p_bank_account, bank_account_id),
    received_at = case when v_status = 'paid' then now() else received_at end
  where id = p_receivable;
  if p_bank_account is not null then
    insert into public.bank_transactions (tenant_id, company_id, bank_account_id, amount, description, txn_type, reference_type, reference_id)
    values (v_tenant, v_company, p_bank_account, abs(p_amount), 'Recebimento de cliente', 'receivable', 'receivable', p_receivable);
    update public.bank_accounts set current_balance = coalesce(current_balance,0) + abs(p_amount) where id = p_bank_account;
  end if;
  return v_status::text;
end;
$$;
grant execute on function public.receive_receivable(uuid,numeric,uuid,public.fin_pay_method) to authenticated;

-- ── RPC: gera títulos a partir das operações (compras → pagar, expedição → receber) ─
create or replace function public.sync_financial_documents(p_company uuid)
returns jsonb
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_po int := 0; v_oo int := 0; r record;
begin
  if not app.has_permission('admin.create', p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id = p_company;

  for r in select id, supplier_id, code, total, expected_date from public.purchase_orders
           where company_id = p_company and status in ('confirmed','received','invoiced') and coalesce(total,0) > 0 and deleted_at is null
             and not exists (select 1 from public.payables p where p.purchase_order_id = purchase_orders.id and p.deleted_at is null)
  loop
    insert into public.payables (tenant_id, company_id, supplier_id, purchase_order_id, code, description, amount, due_date)
    values (v_tenant, p_company, r.supplier_id, r.id, coalesce('AP-'||r.code, null), 'Pedido de compra '||coalesce(r.code,''), r.total, coalesce(r.expected_date, current_date + 30));
    v_po := v_po + 1;
  end loop;

  for r in select id, customer_id, code, total, required_date from public.outbound_orders
           where company_id = p_company and status in ('shipped','invoiced','delivered') and coalesce(total,0) > 0 and deleted_at is null
             and not exists (select 1 from public.receivables rc where rc.outbound_order_id = outbound_orders.id and rc.deleted_at is null)
  loop
    insert into public.receivables (tenant_id, company_id, customer_id, outbound_order_id, code, description, amount, due_date)
    values (v_tenant, p_company, r.customer_id, r.id, coalesce('AR-'||r.code, null), 'Pedido de venda '||coalesce(r.code,''), r.total, coalesce(r.required_date, current_date + 30));
    v_oo := v_oo + 1;
  end loop;

  return jsonb_build_object('payables_created', v_po, 'receivables_created', v_oo);
end;
$$;
grant execute on function public.sync_financial_documents(uuid) to authenticated;

-- ── RPC: KPIs financeiros ───────────────────────────────────────────────────
create or replace function public.finance_kpis(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select jsonb_build_object(
    'payable_open',      (select coalesce(sum(amount - paid_amount),0) from public.payables where company_id=p_company and status in ('open','partial','overdue') and deleted_at is null),
    'receivable_open',   (select coalesce(sum(amount - received_amount),0) from public.receivables where company_id=p_company and status in ('open','partial','overdue') and deleted_at is null),
    'payable_overdue',   (select coalesce(sum(amount - paid_amount),0) from public.payables where company_id=p_company and status in ('open','partial') and due_date < current_date and deleted_at is null),
    'receivable_overdue',(select coalesce(sum(amount - received_amount),0) from public.receivables where company_id=p_company and status in ('open','partial') and due_date < current_date and deleted_at is null),
    'cash_position',     (select coalesce(sum(current_balance),0) from public.bank_accounts where company_id=p_company and deleted_at is null),
    'bank_accounts',     (select count(*) from public.bank_accounts where company_id=p_company and deleted_at is null)
  ) where app.can_access_company(p_company);
$$;
grant execute on function public.finance_kpis(uuid) to authenticated;
