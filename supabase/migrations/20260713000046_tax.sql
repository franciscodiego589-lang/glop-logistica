-- 20260713000046_tax.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  ETP — ENTERPRISE TAX PLATFORM (Vol 14) — Fiscal & Tributário             ║
-- ║  MOTOR TRIBUTÁRIO parametrizável (país/UF/município/regime/operação/NCM,  ║
-- ║  com vigência+prioridade), documentos fiscais eletrônicos, cálculo de     ║
-- ║  tributos, apuração por período, obrigações acessórias, retenções e IA.   ║
-- ║  Núcleo GLOBAL + regras locais configuráveis. Nível SAP DRC/Vertex/Avalara.║
-- ║  fiscal_insights é auto-descoberto pelo cérebro LAIOS (roda 24/7).        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

do $e$ begin
  if not exists (select 1 from pg_type where typname='tax_kind') then
    create type public.tax_kind as enum ('icms','ipi','pis','cofins','iss','irrf','csll','inss','ii','difal','fcp','outros'); end if;
  if not exists (select 1 from pg_type where typname='fiscal_doc_type') then
    create type public.fiscal_doc_type as enum ('nfe','nfce','nfse','cte','mdfe','other'); end if;
  if not exists (select 1 from pg_type where typname='fiscal_direction') then
    create type public.fiscal_direction as enum ('issued','received'); end if;
  if not exists (select 1 from pg_type where typname='fiscal_doc_status') then
    create type public.fiscal_doc_status as enum ('draft','authorized','canceled','rejected','inutilized'); end if;
end $e$;

-- recurso RBAC 'tax'
insert into public.permissions (slug, resource, action, description)
select 'tax.' || a, 'tax', a, 'Permissão ' || a || ' em tax'
from unnest(array['read','create','update','delete','approve','assess','export']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'tax' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── TAX_RULES (motor tributário parametrizável, versionado, com vigência) ────
create table public.tax_rules (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  tax_kind public.tax_kind not null, description text,
  country text default 'BR', state text, municipality text, regime text,
  operation_type text,               -- sale | purchase | service | import | export
  ncm_prefix text, service_code text,
  rate numeric(8,4) not null default 0, reduction_pct numeric(8,4) not null default 0,
  cst text, csosn text, is_withholding boolean not null default false,
  priority integer not null default 1, valid_from date not null default now()::date, valid_to date, enabled boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_tax_rules_lookup on public.tax_rules (company_id, tax_kind, operation_type) where deleted_at is null and enabled;

-- ── OPERATION_NATURES (naturezas de operação / CFOP) ────────────────────────
create table public.operation_natures (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null, name text not null, cfop text, direction text, operation_type text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── FISCAL_DOCUMENTS + TAXES (documentos fiscais eletrônicos) ───────────────
create table public.fiscal_documents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  doc_type public.fiscal_doc_type not null default 'nfe', direction public.fiscal_direction not null default 'issued',
  number text, series text, access_key text, partner_name text, partner_document text,
  operation_nature text, cfop text, status public.fiscal_doc_status not null default 'draft',
  total_amount numeric(18,2) not null default 0, tax_total numeric(18,2) not null default 0,
  issued_at date default now()::date, source_module text, source_id uuid, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_fiscal_docs on public.fiscal_documents (company_id, direction, status, issued_at) where deleted_at is null;

create table public.fiscal_document_taxes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  document_id uuid not null references public.fiscal_documents(id) on delete cascade,
  tax_kind public.tax_kind not null, base_amount numeric(18,2) not null default 0, rate numeric(8,4) not null default 0,
  tax_amount numeric(18,2) not null default 0, cst text, is_withholding boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_fiscal_doc_taxes on public.fiscal_document_taxes (document_id);
create index idx_fiscal_doc_taxes_kind on public.fiscal_document_taxes (company_id, tax_kind);

-- ── TAX_ASSESSMENTS (apuração por período) ──────────────────────────────────
create table public.tax_assessments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  tax_kind public.tax_kind not null, fiscal_year integer not null, fiscal_month integer not null,
  debit_total numeric(18,2) not null default 0, credit_total numeric(18,2) not null default 0,
  adjustments numeric(18,2) not null default 0,
  balance numeric(18,2) not null default 0, status text not null default 'calculated', computed_at timestamptz default now(), notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_tax_assessment on public.tax_assessments (company_id, tax_kind, fiscal_year, fiscal_month) where deleted_at is null;

-- ── FISCAL_OBLIGATIONS (obrigações acessórias — calendário) ─────────────────
create table public.fiscal_obligations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  obligation_code text not null, name text, periodicity text default 'monthly',
  reference_period text, due_date date, status text not null default 'pending', submitted_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_fiscal_obligations on public.fiscal_obligations (company_id, status, due_date) where deleted_at is null;

-- ══ MOTOR TRIBUTÁRIO ═══════════════════════════════════════════════════════
-- Resolve a MELHOR regra (mais específica + maior prioridade + vigente) e calcula o tributo.
create or replace function public.calculate_tax(
  p_company uuid, p_tax public.tax_kind, p_base numeric,
  p_state text default null, p_operation text default null, p_ncm text default null, p_regime text default null,
  p_on_date date default null)
returns jsonb language plpgsql stable security definer set search_path = public, app as $$
declare v_rule record; v_date date; v_base_eff numeric; v_amount numeric;
begin
  if not app.can_access_company(p_company) then return '{}'::jsonb; end if;
  v_date := coalesce(p_on_date, now()::date);
  select *,
    ( (case when state is not null then 1 else 0 end)
    + (case when operation_type is not null then 1 else 0 end)
    + (case when ncm_prefix is not null then 1 else 0 end)
    + (case when regime is not null then 1 else 0 end) ) as specificity
  into v_rule
  from public.tax_rules
  where company_id = p_company and tax_kind = p_tax and enabled and deleted_at is null
    and valid_from <= v_date and (valid_to is null or valid_to >= v_date)
    and (state is null or state = p_state)
    and (operation_type is null or operation_type = p_operation)
    and (regime is null or regime = p_regime)
    and (ncm_prefix is null or (p_ncm is not null and p_ncm like ncm_prefix || '%'))
  order by specificity desc, priority desc, valid_from desc
  limit 1;

  if v_rule.id is null then
    return jsonb_build_object('tax_kind', p_tax, 'base', round(p_base,2), 'rate', 0, 'tax_amount', 0, 'rule_found', false);
  end if;
  v_base_eff := round(p_base * (1 - coalesce(v_rule.reduction_pct,0)/100), 2);
  v_amount := round(v_base_eff * coalesce(v_rule.rate,0)/100, 2);
  return jsonb_build_object('tax_kind', p_tax, 'base', round(p_base,2), 'reduction_pct', v_rule.reduction_pct,
    'effective_base', v_base_eff, 'rate', v_rule.rate, 'tax_amount', v_amount, 'cst', v_rule.cst,
    'is_withholding', v_rule.is_withholding, 'rule_id', v_rule.id, 'rule', v_rule.description, 'rule_found', true);
end;
$$;
grant execute on function public.calculate_tax(uuid, public.tax_kind, numeric, text, text, text, text, date) to authenticated;

-- Cria documento fiscal + tributos (via motor se p_taxes vier vazio, aplica auto por operação)
create or replace function public.create_fiscal_document(
  p_company uuid, p_doc_type public.fiscal_doc_type, p_direction public.fiscal_direction,
  p_partner text, p_operation text, p_total numeric, p_taxes jsonb default null,
  p_state text default 'SP', p_status public.fiscal_doc_status default 'authorized')
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_doc uuid; v_num int; v_tax jsonb; v_kinds public.tax_kind[]; v_k public.tax_kind; v_calc jsonb; v_ttotal numeric := 0;
begin
  if not (app.can_access_company(p_company) and app.has_permission('tax.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id = p_company;
  select coalesce(max(number::int),0)+1 into v_num from public.fiscal_documents where company_id=p_company and number ~ '^[0-9]+$';

  insert into public.fiscal_documents (tenant_id, company_id, doc_type, direction, number, series, partner_name, operation_nature, status, total_amount, issued_at)
  values (v_tenant, p_company, p_doc_type, p_direction, v_num::text, '1', p_partner, p_operation, p_status, round(p_total,2), now()::date)
  returning id into v_doc;

  if p_taxes is not null and jsonb_typeof(p_taxes) = 'array' and jsonb_array_length(p_taxes) > 0 then
    -- tributos explícitos [{tax_kind, base?, rate}]
    for v_tax in select * from jsonb_array_elements(p_taxes) loop
      insert into public.fiscal_document_taxes (tenant_id, company_id, document_id, tax_kind, base_amount, rate, tax_amount, is_withholding)
      values (v_tenant, p_company, v_doc, (v_tax->>'tax_kind')::public.tax_kind,
        coalesce((v_tax->>'base')::numeric, p_total), coalesce((v_tax->>'rate')::numeric,0),
        round(coalesce((v_tax->>'base')::numeric, p_total) * coalesce((v_tax->>'rate')::numeric,0)/100, 2),
        coalesce((v_tax->>'is_withholding')::boolean, false));
    end loop;
  else
    -- automático: aplica o motor para os tributos típicos da operação
    if p_operation = 'service' then v_kinds := array['iss','irrf']::public.tax_kind[];
    else v_kinds := array['icms','ipi','pis','cofins']::public.tax_kind[]; end if;
    foreach v_k in array v_kinds loop
      v_calc := public.calculate_tax(p_company, v_k, p_total, p_state, p_operation, null, null, now()::date);
      if (v_calc->>'rule_found')::boolean then
        insert into public.fiscal_document_taxes (tenant_id, company_id, document_id, tax_kind, base_amount, rate, tax_amount, cst, is_withholding)
        values (v_tenant, p_company, v_doc, v_k, round(p_total,2), (v_calc->>'rate')::numeric, (v_calc->>'tax_amount')::numeric, v_calc->>'cst',
          coalesce((v_calc->>'is_withholding')::boolean,false));
      end if;
    end loop;
  end if;

  select coalesce(sum(tax_amount),0) into v_ttotal from public.fiscal_document_taxes where document_id = v_doc and not is_withholding;
  update public.fiscal_documents set tax_total = v_ttotal where id = v_doc;
  return jsonb_build_object('id', v_doc, 'number', v_num, 'tax_total', v_ttotal);
end;
$$;
grant execute on function public.create_fiscal_document(uuid, public.fiscal_doc_type, public.fiscal_direction, text, text, numeric, jsonb, text, public.fiscal_doc_status) to authenticated;

-- Apuração de um tributo no período (débito=saídas, crédito=entradas p/ não cumulativos)
create or replace function public.run_tax_assessment(p_company uuid, p_tax public.tax_kind, p_year int, p_month int)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_deb numeric; v_cred numeric; v_bal numeric; v_cumulative boolean;
begin
  if not (app.can_access_company(p_company) and app.has_permission('tax.assess', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  -- ISS/IRRF/INSS: cumulativos (sem crédito de entrada)
  v_cumulative := p_tax in ('iss','irrf','csll','inss');

  select coalesce(sum(t.tax_amount),0) into v_deb
  from public.fiscal_document_taxes t join public.fiscal_documents d on d.id=t.document_id
  where t.company_id=p_company and t.tax_kind=p_tax and not t.is_withholding and d.direction='issued'
    and d.status='authorized' and d.deleted_at is null
    and extract(year from d.issued_at)=p_year and extract(month from d.issued_at)=p_month;

  if v_cumulative then v_cred := 0; else
    select coalesce(sum(t.tax_amount),0) into v_cred
    from public.fiscal_document_taxes t join public.fiscal_documents d on d.id=t.document_id
    where t.company_id=p_company and t.tax_kind=p_tax and not t.is_withholding and d.direction='received'
      and d.status='authorized' and d.deleted_at is null
      and extract(year from d.issued_at)=p_year and extract(month from d.issued_at)=p_month;
  end if;

  v_bal := round(v_deb - v_cred, 2);
  insert into public.tax_assessments (tenant_id, company_id, tax_kind, fiscal_year, fiscal_month, debit_total, credit_total, balance, status, computed_at)
  values (v_tenant, p_company, p_tax, p_year, p_month, round(v_deb,2), round(v_cred,2), v_bal, 'calculated', now())
  on conflict (company_id, tax_kind, fiscal_year, fiscal_month) where deleted_at is null
  do update set debit_total=round(v_deb,2), credit_total=round(v_cred,2), balance=v_bal, status='calculated', computed_at=now();
  return jsonb_build_object('tax_kind', p_tax, 'period', p_year||'-'||lpad(p_month::text,2,'0'),
    'debit', round(v_deb,2), 'credit', round(v_cred,2), 'balance', v_bal, 'result', case when v_bal>0 then 'a recolher' when v_bal<0 then 'saldo credor' else 'zerado' end);
end;
$$;
grant execute on function public.run_tax_assessment(uuid, public.tax_kind, int, int) to authenticated;

-- Gera o calendário de obrigações acessórias de um período (parametrizável por metadata)
create or replace function public.generate_fiscal_obligations(p_company uuid, p_year int, p_month int)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_o record;
  obligations jsonb := '[
    {"code":"EFD-ICMS/IPI","name":"SPED Fiscal (EFD ICMS/IPI)","day":20,"per":"monthly"},
    {"code":"EFD-Contribuicoes","name":"SPED Contribuições (PIS/COFINS)","day":15,"per":"monthly"},
    {"code":"DCTFWeb","name":"DCTFWeb","day":15,"per":"monthly"},
    {"code":"GIA","name":"GIA (ICMS estadual)","day":16,"per":"monthly"},
    {"code":"DES-ISS","name":"Declaração de Serviços (ISS municipal)","day":10,"per":"monthly"}
  ]'::jsonb;
begin
  if not (app.can_access_company(p_company) and app.has_permission('tax.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  for v_o in select value as o from jsonb_array_elements(obligations) loop
    if not exists (select 1 from public.fiscal_obligations where company_id=p_company and obligation_code=(v_o.o->>'code')
        and reference_period=(p_year||'-'||lpad(p_month::text,2,'0')) and deleted_at is null) then
      insert into public.fiscal_obligations (tenant_id, company_id, obligation_code, name, periodicity, reference_period, due_date, status)
      values (v_tenant, p_company, v_o.o->>'code', v_o.o->>'name', v_o.o->>'per',
        p_year||'-'||lpad(p_month::text,2,'0'),
        (make_date(p_year, p_month, 1) + interval '1 month' + ((v_o.o->>'day')::int - 1) * interval '1 day')::date, 'pending');
      v_c := v_c + 1;
    end if;
  end loop;
  return v_c;
end;
$$;
grant execute on function public.generate_fiscal_obligations(uuid, int, int) to authenticated;

-- Dashboard fiscal
create or replace function public.fiscal_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'docs_issued', (select count(*) from public.fiscal_documents where company_id=p_company and direction='issued' and deleted_at is null),
    'docs_received', (select count(*) from public.fiscal_documents where company_id=p_company and direction='received' and deleted_at is null),
    'docs_authorized', (select count(*) from public.fiscal_documents where company_id=p_company and status='authorized' and deleted_at is null),
    'docs_pending', (select count(*) from public.fiscal_documents where company_id=p_company and status in ('draft','rejected') and deleted_at is null),
    'tax_rules', (select count(*) from public.tax_rules where company_id=p_company and enabled and deleted_at is null),
    'obligations_pending', (select count(*) from public.fiscal_obligations where company_id=p_company and status='pending' and deleted_at is null),
    'obligations_late', (select count(*) from public.fiscal_obligations where company_id=p_company and status='pending' and due_date < now()::date and deleted_at is null),
    'tax_payable_open', (select coalesce(sum(balance),0) from public.tax_assessments where company_id=p_company and balance>0 and status='calculated' and deleted_at is null),
    'tax_by_kind', (select coalesce(jsonb_object_agg(tax_kind, total),'{}'::jsonb) from (
        select t.tax_kind, round(sum(t.tax_amount),2) total from public.fiscal_document_taxes t
        join public.fiscal_documents d on d.id=t.document_id and d.direction='issued' and d.status='authorized' and d.deleted_at is null
        where t.company_id=p_company and t.deleted_at is null group by t.tax_kind) s)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.fiscal_dashboard(uuid) to authenticated;

-- IA FISCAL: obrigações atrasadas, documentos pendentes/rejeitados, tributo a recolher alto → LOGIA
create or replace function public.fiscal_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_late int; v_rej int; v_pay numeric;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Fiscal%' and deleted_at is null;

  select count(*) into v_late from public.fiscal_obligations where company_id=p_company and status='pending' and due_date < now()::date and deleted_at is null;
  if v_late > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'critical', 'Fiscal: obrigações acessórias em atraso',
      v_late||' obrigação(ões) vencida(s) e não entregue(s).', 'Transmitir imediatamente — risco de multa e malha fiscal.', 94);
    v_c := v_c + 1;
  end if;
  select count(*) into v_rej from public.fiscal_documents where company_id=p_company and status='rejected' and deleted_at is null;
  if v_rej > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'Fiscal: documentos rejeitados',
      v_rej||' documento(s) fiscal(is) rejeitado(s).', 'Corrigir e reprocessar para não travar o faturamento.', 85);
    v_c := v_c + 1;
  end if;
  select coalesce(sum(balance),0) into v_pay from public.tax_assessments where company_id=p_company and balance>0 and status='calculated' and deleted_at is null;
  if v_pay > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, impact_value, confidence)
    values (v_tenant, p_company, 'cost_saving', 'info', 'Fiscal: tributos a recolher apurados',
      'Há R$ '||to_char(v_pay,'FM999G999G990D00')||' em tributos apurados a recolher.', 'Revisar créditos e benefícios antes do pagamento.', v_pay, 70);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.fiscal_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'tax') ────────────
do $do$
declare t text; specs text[] := array['tax_rules','operation_natures','fiscal_documents','fiscal_document_taxes','tax_assessments','fiscal_obligations'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'tax.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'tax.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: regras tributárias BR + naturezas de operação (por empresa) ══
do $do$
declare c record;
  rules jsonb := '[
    {"k":"icms","d":"ICMS 18% (venda interna SP)","op":"sale","st":"SP","rate":18,"cst":"00"},
    {"k":"icms","d":"ICMS 12% (compra interestadual)","op":"purchase","rate":12,"cst":"00"},
    {"k":"ipi","d":"IPI 5% (produto industrializado)","op":"sale","rate":5,"cst":"50"},
    {"k":"pis","d":"PIS 1,65% (não cumulativo)","op":"sale","rate":1.65,"cst":"01"},
    {"k":"cofins","d":"COFINS 7,6% (não cumulativo)","op":"sale","rate":7.6,"cst":"01"},
    {"k":"pis","d":"PIS 1,65% crédito (compra)","op":"purchase","rate":1.65,"cst":"50"},
    {"k":"cofins","d":"COFINS 7,6% crédito (compra)","op":"purchase","rate":7.6,"cst":"50"},
    {"k":"iss","d":"ISS 5% (serviço)","op":"service","rate":5,"cst":null},
    {"k":"irrf","d":"IRRF 1,5% (serviço PJ) — retido","op":"service","rate":1.5,"cst":null,"wh":true}
  ]'::jsonb;
  natures jsonb := '[
    {"code":"5102","name":"Venda de mercadoria adquirida de terceiros","cfop":"5102","dir":"out","op":"sale"},
    {"code":"5101","name":"Venda de produção do estabelecimento","cfop":"5101","dir":"out","op":"sale"},
    {"code":"1102","name":"Compra para comercialização","cfop":"1102","dir":"in","op":"purchase"},
    {"code":"1101","name":"Compra para industrialização","cfop":"1101","dir":"in","op":"purchase"},
    {"code":"5933","name":"Prestação de serviço tributado pelo ISS","cfop":"5933","dir":"out","op":"service"}
  ]'::jsonb;
  r jsonb; n jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    for r in select value from jsonb_array_elements(rules) loop
      if not exists (select 1 from public.tax_rules where company_id=c.id and tax_kind=(r->>'k')::public.tax_kind and description=(r->>'d') and deleted_at is null) then
        insert into public.tax_rules (tenant_id, company_id, tax_kind, description, operation_type, state, rate, cst, is_withholding)
        values (c.tenant_id, c.id, (r->>'k')::public.tax_kind, r->>'d', r->>'op', r->>'st', (r->>'rate')::numeric, r->>'cst', coalesce((r->>'wh')::boolean,false));
      end if;
    end loop;
    for n in select value from jsonb_array_elements(natures) loop
      if not exists (select 1 from public.operation_natures where company_id=c.id and code=(n->>'code') and deleted_at is null) then
        insert into public.operation_natures (tenant_id, company_id, code, name, cfop, direction, operation_type)
        values (c.tenant_id, c.id, n->>'code', n->>'name', n->>'cfop', n->>'dir', n->>'op');
      end if;
    end loop;
  end loop;
end $do$;

notify pgrst, 'reload schema';
