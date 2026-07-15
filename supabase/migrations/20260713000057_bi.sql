-- 20260713000057_bi.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  EBIP — ENTERPRISE BI PLATFORM (Vol 25) — BI + Data Warehouse + Analytics ║
-- ║  Catálogo de KPIs (motor compute_kpi sobre dados REAIS de todos os        ║
-- ║  módulos) + snapshots (tendências) + Cockpit Executivo cross-módulo +     ║
-- ║  self-service dashboards + alertas + catálogo/governança de dados.        ║
-- ║  Nível Power BI/Tableau/SAP SAC. bi_insights auto-descoberto LAIOS.       ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- recurso 'bi' já existe na fundação; garante slugs
insert into public.permissions (slug, resource, action, description)
select 'bi.' || a, 'bi', a, 'Permissão ' || a || ' em bi'
from unnest(array['read','create','update','delete','approve','export']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'bi' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── KPI_DEFINITIONS (catálogo corporativo de indicadores) ───────────────────
create table public.kpi_definitions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  kpi_key text not null, name text not null, module text, unit text default 'num',
  target_value numeric(18,2), direction text default 'higher_better', format text default 'number', enabled boolean not null default true, sort integer default 100,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_kpi_def_key on public.kpi_definitions (company_id, kpi_key) where deleted_at is null;

-- ── KPI_SNAPSHOTS (série histórica p/ tendências) ───────────────────────────
create table public.kpi_snapshots (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  kpi_key text not null, value numeric(20,4), captured_at timestamptz not null default now(), period text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_kpi_snapshots on public.kpi_snapshots (company_id, kpi_key, captured_at);

-- ── BI_DASHBOARDS + WIDGETS (self-service) ──────────────────────────────────
create table public.bi_dashboards (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, audience text default 'gestao', layout jsonb not null default '[]'::jsonb, is_default boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.bi_widgets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  dashboard_id uuid not null references public.bi_dashboards(id) on delete cascade,
  title text, widget_type text default 'kpi', kpi_key text, config jsonb not null default '{}'::jsonb, sort integer default 100,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── BI_ALERTS (limites) + DATA_CATALOG (governança) ─────────────────────────
create table public.bi_alerts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  kpi_key text not null, name text, operator text default '>', threshold numeric(18,2), channel text default 'portal', enabled boolean not null default true, last_triggered_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.data_catalog (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, description text, domain text, source_table text, owner text, classification text default 'internal', quality_score integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ MOTOR DE KPI: computa indicadores sobre os dados REAIS de cada módulo ═══
create or replace function public.compute_kpi(p_company uuid, p_key text)
returns numeric language plpgsql stable security definer set search_path = public, app as $$
declare v numeric := 0;
begin
  if not app.can_access_company(p_company) then return null; end if;
  v := case p_key
    when 'headcount' then (select count(*) from public.employees where company_id=p_company and status<>'terminated' and deleted_at is null)
    when 'payroll_cost' then (select coalesce(sum(salary),0) from public.employees where company_id=p_company and status<>'terminated' and deleted_at is null)
    when 'orders_open' then (select count(*) from public.sales_orders where company_id=p_company and status in ('new','approved','reserved','awaiting_production','picking') and deleted_at is null)
    when 'ecom_revenue' then (select coalesce(sum(total_amount),0) from public.sales_orders where company_id=p_company and channel='ecommerce' and deleted_at is null)
    when 'pipeline_value' then (select coalesce(sum(amount),0) from public.crm_opportunities where company_id=p_company and status='open' and deleted_at is null)
    when 'won_ytd' then (select coalesce(sum(amount),0) from public.crm_opportunities where company_id=p_company and status='won' and deleted_at is null and extract(year from coalesce(won_at,updated_at))=extract(year from now()))
    when 'stock_value' then (select coalesce(sum(b.quantity * coalesce(pr.cost_price,0)),0) from public.stock_balances b join public.products pr on pr.id=b.product_id where b.company_id=p_company and b.deleted_at is null)
    when 'revenue_12m' then (select coalesce(sum(l.credit-l.debit),0) from public.journal_entry_lines l join public.journal_entries e on e.id=l.entry_id and e.status='posted' and e.deleted_at is null join public.chart_of_accounts a on a.id=l.account_id and a.account_type='revenue' where e.company_id=p_company and e.competence_date >= (now()::date - interval '12 months'))
    when 'net_income_month' then coalesce(((public.income_statement(p_company, date_trunc('month',now())::date, now()::date))->>'net_income')::numeric, 0)
    when 'tax_payable' then (select coalesce(sum(balance),0) from public.tax_assessments where company_id=p_company and balance>0 and status='calculated' and deleted_at is null)
    when 'docs_pending_sign' then (select count(*) from public.document_signatures where company_id=p_company and status='pending' and deleted_at is null)
    when 'tasks_pending' then (select count(*) from public.process_tasks where company_id=p_company and status='pending' and deleted_at is null)
    when 'tickets_open' then (select count(*) from public.support_tickets where company_id=p_company and status in ('open','in_progress','waiting_customer') and deleted_at is null)
    when 'accounts' then (select count(*) from public.crm_accounts where company_id=p_company and deleted_at is null)
    else 0 end;
  return coalesce(v, 0);
end;
$$;
grant execute on function public.compute_kpi(uuid, text) to authenticated;

-- Captura snapshots de todos os KPIs do catálogo (trend / cron)
create or replace function public.snapshot_kpis(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; k record; v numeric; v_c int := 0;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  for k in select kpi_key from public.kpi_definitions where company_id=p_company and enabled and deleted_at is null loop
    v := public.compute_kpi(p_company, k.kpi_key);
    insert into public.kpi_snapshots (tenant_id, company_id, kpi_key, value, period)
    values (v_tenant, p_company, k.kpi_key, v, to_char(now(),'YYYY-MM-DD'));
    v_c := v_c + 1;
  end loop;
  return v_c;
end;
$$;
grant execute on function public.snapshot_kpis(uuid) to authenticated;

-- COCKPIT EXECUTIVO: todos os KPIs do catálogo com valor real, meta e status
create or replace function public.bi_overview(p_company uuid)
returns jsonb language plpgsql stable security definer set search_path = public, app as $$
declare k record; v numeric; v_status text; arr jsonb := '[]'::jsonb;
begin
  if not app.can_access_company(p_company) then return '{}'::jsonb; end if;
  for k in select * from public.kpi_definitions where company_id=p_company and enabled and deleted_at is null order by module, sort loop
    v := public.compute_kpi(p_company, k.kpi_key);
    v_status := case
      when k.target_value is null then 'neutral'
      when k.direction='higher_better' and v >= k.target_value then 'ok'
      when k.direction='lower_better' and v <= k.target_value then 'ok'
      else 'warn' end;
    arr := arr || jsonb_build_object('key', k.kpi_key, 'name', k.name, 'module', k.module, 'value', v,
      'unit', k.unit, 'format', k.format, 'target', k.target_value, 'direction', k.direction, 'status', v_status);
  end loop;
  return jsonb_build_object('kpis', arr, 'as_of', now());
end;
$$;
grant execute on function public.bi_overview(uuid) to authenticated;

-- Tendência de um KPI (série de snapshots)
create or replace function public.kpi_trend(p_company uuid, p_key text, p_limit int default 30)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(jsonb_build_object('at', captured_at, 'value', value) order by captured_at)
    from (select captured_at, value from public.kpi_snapshots where company_id=p_company and kpi_key=p_key and deleted_at is null order by captured_at desc limit p_limit) s
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.kpi_trend(uuid, text, int) to authenticated;

-- IA analítica: avalia alertas de limite → LOGIA
create or replace function public.bi_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; a record; v numeric; breached boolean;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'BI:%' and deleted_at is null;

  for a in select * from public.bi_alerts where company_id=p_company and enabled and deleted_at is null loop
    v := public.compute_kpi(p_company, a.kpi_key);
    breached := case a.operator when '>' then v > a.threshold when '>=' then v >= a.threshold when '<' then v < a.threshold when '<=' then v <= a.threshold else false end;
    if breached then
      insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, impact_value, confidence)
      values (v_tenant, p_company, 'demand_shift', 'warning', 'BI: '||coalesce(a.name, a.kpi_key)||' fora do limite',
        'KPI '||a.kpi_key||' = '||round(v,2)||' (limite '||a.operator||' '||a.threshold||').', 'Analisar causa e agir sobre o indicador.', v, 80);
      update public.bi_alerts set last_triggered_at=now() where id=a.id;
      v_c := v_c + 1;
    end if;
  end loop;
  return v_c;
end;
$$;
grant execute on function public.bi_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'bi') ─────────────
do $do$
declare t text; specs text[] := array['kpi_definitions','kpi_snapshots','bi_dashboards','bi_widgets','bi_alerts','data_catalog'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'bi.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'bi.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: catálogo de KPIs + alerta + catálogo de dados ══
do $do$
declare c record;
  kpis jsonb := '[
    {"k":"revenue_12m","n":"Receita (12m)","m":"Financeiro","u":"R$","fmt":"currency","t":1000000,"d":"higher_better","s":10},
    {"k":"net_income_month","n":"Resultado do mês","m":"Financeiro","u":"R$","fmt":"currency","t":0,"d":"higher_better","s":20},
    {"k":"tax_payable","n":"Tributos a recolher","m":"Financeiro","u":"R$","fmt":"currency","t":50000,"d":"lower_better","s":30},
    {"k":"pipeline_value","n":"Pipeline comercial","m":"Comercial","u":"R$","fmt":"currency","t":100000,"d":"higher_better","s":10},
    {"k":"won_ytd","n":"Vendas ganhas (ano)","m":"Comercial","u":"R$","fmt":"currency","t":500000,"d":"higher_better","s":20},
    {"k":"ecom_revenue","n":"Receita e-commerce","m":"Comercial","u":"R$","fmt":"currency","t":10000,"d":"higher_better","s":30},
    {"k":"accounts","n":"Clientes ativos","m":"Comercial","u":"num","fmt":"number","t":100,"d":"higher_better","s":40},
    {"k":"orders_open","n":"Pedidos em aberto","m":"Operacao","u":"num","fmt":"number","t":50,"d":"lower_better","s":10},
    {"k":"stock_value","n":"Valor em estoque","m":"Operacao","u":"R$","fmt":"currency","t":500000,"d":"lower_better","s":20},
    {"k":"headcount","n":"Headcount","m":"Pessoas","u":"num","fmt":"number","t":50,"d":"higher_better","s":10},
    {"k":"payroll_cost","n":"Custo de folha","m":"Pessoas","u":"R$","fmt":"currency","t":100000,"d":"lower_better","s":20},
    {"k":"tickets_open","n":"Chamados abertos","m":"Governanca","u":"num","fmt":"number","t":20,"d":"lower_better","s":10},
    {"k":"tasks_pending","n":"Aprovacoes pendentes","m":"Governanca","u":"num","fmt":"number","t":15,"d":"lower_better","s":20},
    {"k":"docs_pending_sign","n":"Assinaturas pendentes","m":"Governanca","u":"num","fmt":"number","t":10,"d":"lower_better","s":30}
  ]'::jsonb;
  cat jsonb := '[
    {"n":"Vendas (Fato)","d":"Fato de vendas por pedido/cliente/canal","dm":"Comercial","st":"sales_orders","cl":"internal","q":92},
    {"n":"Razao Contabil (Fato)","d":"Lancamentos contabeis","dm":"Financeiro","st":"journal_entry_lines","cl":"confidential","q":98},
    {"n":"Colaboradores (Dim)","d":"Dimensao de pessoas","dm":"Pessoas","st":"employees","cl":"confidential","q":95},
    {"n":"Produtos (Dim)","d":"Dimensao de produtos/SKU","dm":"Operacao","st":"products","cl":"internal","q":90}
  ]'::jsonb;
  x jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    for x in select value from jsonb_array_elements(kpis) loop
      if not exists (select 1 from public.kpi_definitions where company_id=c.id and kpi_key=(x->>'k') and deleted_at is null) then
        insert into public.kpi_definitions (tenant_id, company_id, kpi_key, name, module, unit, format, target_value, direction, sort)
        values (c.tenant_id, c.id, x->>'k', x->>'n', x->>'m', x->>'u', x->>'fmt', (x->>'t')::numeric, x->>'d', (x->>'s')::int);
      end if;
    end loop;
    for x in select value from jsonb_array_elements(cat) loop
      if not exists (select 1 from public.data_catalog where company_id=c.id and name=(x->>'n') and deleted_at is null) then
        insert into public.data_catalog (tenant_id, company_id, name, description, domain, source_table, classification, quality_score)
        values (c.tenant_id, c.id, x->>'n', x->>'d', x->>'dm', x->>'st', x->>'cl', (x->>'q')::int);
      end if;
    end loop;
    if not exists (select 1 from public.bi_alerts where company_id=c.id and kpi_key='tax_payable' and deleted_at is null) then
      insert into public.bi_alerts (tenant_id, company_id, kpi_key, name, operator, threshold)
      values (c.tenant_id, c.id, 'tax_payable', 'Tributos a recolher altos', '>', 100000),
             (c.tenant_id, c.id, 'orders_open', 'Muitos pedidos em aberto', '>', 100);
    end if;
  end loop;
end $do$;

notify pgrst, 'reload schema';
