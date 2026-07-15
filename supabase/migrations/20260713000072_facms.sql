-- ============================================================================
-- GLOP · VOLUME 36 — FREIGHT AUDIT & COST MANAGEMENT SYSTEM (FACMS)
-- migration 072 · Auditoria de fretes, faturas de transporte, glosas, custos
-- logísticos e rentabilidade. 100% domínio logístico (só custos operacionais de
-- transporte/armazenagem/movimentação). Recurso RBAC 'facms'.
-- REUSA: carriers, shipments, freight_rates, freight_contracts (estendido).
-- Padrão: text+check, grant por-tabela, gerado só imutável.
-- ============================================================================

-- ── ESTENDE freight_contracts (037) em vez de recriar ────────────────────────
alter table public.freight_contracts add column if not exists valid_from date;
alter table public.freight_contracts add column if not exists valid_to date;
alter table public.freight_contracts add column if not exists gris_percent numeric(6,4) default 0;
alter table public.freight_contracts add column if not exists advalorem_percent numeric(6,4) default 0;
alter table public.freight_contracts add column if not exists status text default 'active';
alter table public.freight_contracts add column if not exists rules jsonb default '{}'::jsonb;

-- ── FATURAS DE TRANSPORTE (fatura + CT-e) ────────────────────────────────────
create table if not exists public.transport_invoices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text,
  carrier_id uuid references public.carriers(id),
  contract_id uuid references public.freight_contracts(id),
  invoice_number text,
  cte_number text,
  issue_date date,
  competence text,                       -- YYYY-MM
  total_charged numeric(16,2) not null default 0,
  total_expected numeric(16,2) not null default 0,
  total_divergence numeric(16,2) generated always as (total_charged - total_expected) stored,
  status text not null default 'pending' check (status in ('pending','audited','approved','disputed','paid','canceled')),
  audited_at timestamptz,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── COBRANÇAS DA FATURA (por tipo) ───────────────────────────────────────────
create table if not exists public.invoice_charges (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  invoice_id uuid not null references public.transport_invoices(id) on delete cascade,
  shipment_id uuid references public.shipments(id),
  charge_type text not null default 'freight_weight'
    check (charge_type in ('freight_weight','freight_value','freight_cubed','gris','advalorem','toll','restriction','interiorization','permanence','pickup','delivery','extra')),
  description text,
  amount_charged numeric(16,2) not null default 0,
  amount_expected numeric(16,2),
  divergence numeric(16,2) generated always as (amount_charged - coalesce(amount_expected,0)) stored,
  status text not null default 'pending' check (status in ('pending','ok','divergent','glosa')),
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── GLOSAS (contestações de cobrança) ────────────────────────────────────────
create table if not exists public.freight_glosas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text,
  invoice_id uuid references public.transport_invoices(id) on delete cascade,
  charge_id uuid references public.invoice_charges(id) on delete set null,
  reason text not null,
  amount numeric(16,2) not null default 0,
  status text not null default 'open' check (status in ('open','contested','accepted','rejected')),
  responsible_id uuid references auth.users(id),
  contested_at timestamptz,
  resolved_at timestamptz,
  resolution text,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── CUSTOS LOGÍSTICOS (por tipo/entidade) ────────────────────────────────────
create table if not exists public.logistics_costs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  cost_type text not null default 'freight'
    check (cost_type in ('freight','storage','handling','picking','packing','crossdock','lastmile','transfer','operational')),
  amount numeric(16,2) not null default 0,
  entity_type text check (entity_type in ('client','order','carrier','warehouse','route','contract','shipment')),
  entity_id uuid,
  competence text,                       -- YYYY-MM
  description text,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_tinv_carrier on public.transport_invoices (carrier_id);
create index if not exists idx_icharges_invoice on public.invoice_charges (invoice_id);
create index if not exists idx_glosas_invoice on public.freight_glosas (invoice_id);
create index if not exists idx_lcosts_type on public.logistics_costs (company_id, cost_type, competence);

-- ── RBAC 'facms' ─────────────────────────────────────────────────────────────
insert into public.permissions (slug, resource, action, description)
select 'facms.' || a, 'facms', a, 'Permissão ' || a || ' em facms'
from unnest(array['read','create','update','delete','approve']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'facms' and r.slug in ('admin','superadmin')
on conflict do nothing;

do $do$
declare t text; specs text[] := array['transport_invoices','invoice_charges','freight_glosas','logistics_costs'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'facms.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'facms.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

insert into public.event_types (slug, domain, stage_order, description) values
  ('invoice.audited', 'FACMS', null, 'Fatura de transporte auditada'),
  ('glosa.opened', 'FACMS', null, 'Glosa registrada'),
  ('glosa.resolved', 'FACMS', null, 'Glosa resolvida')
on conflict (slug) do nothing;

-- ── RPCs ─────────────────────────────────────────────────────────────────────
-- AUDITORIA AUTOMÁTICA: compara cobrado × esperado, marca divergências, gera glosa
create or replace function public.audit_transport_invoice(p_company uuid, p_invoice uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_charged numeric := 0; v_expected numeric := 0; v_div numeric; v_glosa_amt numeric := 0; v_glosa uuid;
begin
  if not (app.can_access_company(p_company) and app.has_permission('facms.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  if not exists (select 1 from public.transport_invoices where id=p_invoice and company_id=p_company and deleted_at is null) then
    raise exception 'fatura não encontrada'; end if;
  -- marca cada cobrança: divergente se cobrado > esperado (com tolerância de R$0,01)
  update public.invoice_charges set status = case
      when amount_expected is null then 'pending'
      when amount_charged > coalesce(amount_expected,0) + 0.01 then 'divergent'
      else 'ok' end
    where invoice_id=p_invoice and deleted_at is null;
  select coalesce(sum(amount_charged),0), coalesce(sum(coalesce(amount_expected,amount_charged)),0)
    into v_charged, v_expected from public.invoice_charges where invoice_id=p_invoice and deleted_at is null;
  v_div := v_charged - v_expected;
  update public.transport_invoices set total_charged=v_charged, total_expected=v_expected, status='audited', audited_at=now() where id=p_invoice;
  -- glosa automática sobre a soma das divergências positivas
  select coalesce(sum(divergence),0) into v_glosa_amt from public.invoice_charges where invoice_id=p_invoice and status='divergent' and deleted_at is null;
  if v_glosa_amt > 0.01 then
    insert into public.freight_glosas (tenant_id, company_id, code, invoice_id, reason, amount, status, responsible_id)
    values (v_tenant, p_company, 'GL-'||to_char(now(),'YYMMDD')||'-'||lpad((floor(random()*100000))::text,5,'0'),
            p_invoice, 'Cobrança acima do esperado (auditoria automática)', v_glosa_amt, 'open', auth.uid())
    returning id into v_glosa;
    update public.transport_invoices set status='disputed' where id=p_invoice;
    update public.invoice_charges set status='glosa' where invoice_id=p_invoice and status='divergent' and deleted_at is null;
    perform app.emit_event(p_company, 'glosa.opened', 'facms', jsonb_build_object('invoice_id', p_invoice, 'glosa_id', v_glosa, 'amount', v_glosa_amt));
  end if;
  perform app.emit_event(p_company, 'invoice.audited', 'facms', jsonb_build_object('invoice_id', p_invoice, 'divergence', v_div));
  return jsonb_build_object('charged', v_charged, 'expected', v_expected, 'divergence', v_div, 'glosa_amount', v_glosa_amt, 'glosa_id', v_glosa);
end; $$;
grant execute on function public.audit_transport_invoice(uuid,uuid) to authenticated;

create or replace function public.contest_glosa(p_company uuid, p_glosa uuid)
returns void language plpgsql security definer set search_path = public, app as $$
begin
  if not (app.can_access_company(p_company) and app.has_permission('facms.update', p_company)) then raise exception 'forbidden'; end if;
  update public.freight_glosas set status='contested', contested_at=now() where id=p_glosa and company_id=p_company;
end; $$;
grant execute on function public.contest_glosa(uuid,uuid) to authenticated;

create or replace function public.resolve_glosa(p_company uuid, p_glosa uuid, p_accepted boolean, p_resolution text)
returns void language plpgsql security definer set search_path = public, app as $$
begin
  if not (app.can_access_company(p_company) and app.has_permission('facms.update', p_company)) then raise exception 'forbidden'; end if;
  update public.freight_glosas set status = case when p_accepted then 'accepted' else 'rejected' end,
    resolved_at=now(), resolution=p_resolution where id=p_glosa and company_id=p_company;
  perform app.emit_event(p_company, 'glosa.resolved', 'facms', jsonb_build_object('glosa_id', p_glosa, 'accepted', p_accepted));
end; $$;
grant execute on function public.resolve_glosa(uuid,uuid,boolean,text) to authenticated;

-- SIMULADOR: compara custo de frete entre transportadoras (reusa freight_rates)
create or replace function public.simulate_carrier_freight(p_company uuid, p_weight numeric, p_origin_uf text, p_value numeric default 0)
returns table(carrier_id uuid, carrier text, price_per_kg numeric, freight numeric, lead_time_days integer)
language sql security definer set search_path = public, app stable as $$
  select r.carrier_id, c.name, r.price_per_kg,
         round((p_weight * coalesce(r.price_per_kg,0))::numeric, 2) as freight, r.lead_time_days
  from public.freight_rates r
  join public.carriers c on c.id=r.carrier_id
  where r.company_id=p_company and r.deleted_at is null and app.can_access_company(p_company)
    and (p_origin_uf is null or r.origin_uf is null or r.origin_uf=p_origin_uf)
    and p_weight >= coalesce(r.weight_from_kg,0)
  order by freight;
$$;
grant execute on function public.simulate_carrier_freight(uuid,numeric,text,numeric) to authenticated;

create or replace function public.record_logistics_cost(p_company uuid, p_type text, p_amount numeric, p_entity_type text, p_entity_id uuid, p_competence text)
returns public.logistics_costs language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.logistics_costs;
begin
  if not (app.can_access_company(p_company) and app.has_permission('facms.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.logistics_costs (tenant_id, company_id, cost_type, amount, entity_type, entity_id, competence)
  values (v_tenant, p_company, coalesce(p_type,'freight'), p_amount, p_entity_type, p_entity_id, p_competence) returning * into r;
  return r;
end; $$;
grant execute on function public.record_logistics_cost(uuid,text,numeric,text,uuid,text) to authenticated;

create or replace function public.facms_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'freight_total',   (select coalesce(sum(total_charged),0) from public.transport_invoices where company_id=p_company and deleted_at is null),
    'divergence_total',(select coalesce(sum(total_divergence),0) from public.transport_invoices where company_id=p_company and status in ('audited','disputed') and deleted_at is null),
    'savings',         (select coalesce(sum(amount),0) from public.freight_glosas where company_id=p_company and status='accepted' and deleted_at is null),
    'glosas_open',     (select count(*) from public.freight_glosas where company_id=p_company and status in ('open','contested') and deleted_at is null),
    'invoices_pending',(select count(*) from public.transport_invoices where company_id=p_company and status='pending' and deleted_at is null),
    'invoices_total',  (select count(*) from public.transport_invoices where company_id=p_company and deleted_at is null),
    'cost_by_carrier', (select coalesce(jsonb_agg(jsonb_build_object('carrier', name, 'total', tot) order by tot desc),'[]'::jsonb)
                        from (select c.name, sum(i.total_charged) tot from public.transport_invoices i join public.carriers c on c.id=i.carrier_id
                              where i.company_id=p_company and i.deleted_at is null group by c.name) t),
    'cost_by_type',    (select coalesce(jsonb_agg(jsonb_build_object('type', cost_type, 'total', tot) order by tot desc),'[]'::jsonb)
                        from (select cost_type, sum(amount) tot from public.logistics_costs where company_id=p_company and deleted_at is null group by cost_type) t)
  ) into v;
  return v;
end; $$;
grant execute on function public.facms_dashboard(uuid) to authenticated;

-- motor auto-descoberto pelo LAIOS
create or replace function public.facms_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_div numeric; v_exp int; v_gl int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'FACMS%' and deleted_at is null;

  select coalesce(sum(total_divergence),0) into v_div from public.transport_invoices where company_id=p_company and status in ('audited','disputed') and deleted_at is null;
  if v_div > 0.01 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'cost_saving', 'warning', 'FACMS: fretes cobrados acima do esperado', 'Divergência total de R$ '||round(v_div,2)||' em faturas auditadas.', 'Abrir/contestar glosa para recuperar o valor.', 86);
    v_c := v_c + 1;
  end if;
  select count(*) into v_exp from public.freight_contracts where company_id=p_company and valid_to is not null and valid_to < now()::date and deleted_at is null;
  if v_exp > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'supplier_risk', 'warning', 'FACMS: contratos de frete vencidos', v_exp||' contrato(s) de transporte vencido(s).', 'Renegociar/renovar o contrato com a transportadora.', 80);
    v_c := v_c + 1;
  end if;
  select count(*) into v_gl from public.freight_glosas where company_id=p_company and status in ('open','contested') and deleted_at is null;
  if v_gl > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'cost_saving', 'info', 'FACMS: glosas em aberto', v_gl||' glosa(s) aguardando resolução.', 'Acompanhar a contestação junto à transportadora.', 72);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.facms_insights(uuid) to authenticated;

-- ── SEED (empresa Matriz Logística) ─────────────────────────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid; v_carrier uuid; v_inv uuid;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;
  if exists (select 1 from public.transport_invoices where company_id=v_company and deleted_at is null) then return; end if;

  select id into v_carrier from public.carriers where company_id=v_company and deleted_at is null order by created_at limit 1;
  if v_carrier is null then
    insert into public.carriers (tenant_id, company_id, code, name, modal) values (v_tenant, v_company, 'TR-001', 'Transportadora Exemplo', 'road') returning id into v_carrier;
  end if;

  insert into public.transport_invoices (tenant_id, company_id, code, carrier_id, invoice_number, cte_number, issue_date, competence, status)
  values (v_tenant, v_company, 'FT-0001', v_carrier, 'NF-12345', 'CTE-99887', now()::date, to_char(now(),'YYYY-MM'), 'pending')
  returning id into v_inv;
  -- 3 cobranças: 2 corretas, 1 acima do esperado (dispara glosa na auditoria)
  insert into public.invoice_charges (tenant_id, company_id, invoice_id, charge_type, description, amount_charged, amount_expected) values
    (v_tenant, v_company, v_inv, 'freight_weight', 'Frete-peso', 1200.00, 1200.00),
    (v_tenant, v_company, v_inv, 'gris',           'GRIS',        180.00,  150.00),   -- +30 divergente
    (v_tenant, v_company, v_inv, 'toll',           'Pedágio',     90.00,   90.00);

  insert into public.logistics_costs (tenant_id, company_id, cost_type, amount, entity_type, entity_id, competence) values
    (v_tenant, v_company, 'freight',   1470.00, 'carrier', v_carrier, to_char(now(),'YYYY-MM')),
    (v_tenant, v_company, 'storage',   800.00,  'warehouse', null,    to_char(now(),'YYYY-MM')),
    (v_tenant, v_company, 'lastmile',  350.00,  'carrier', v_carrier, to_char(now(),'YYYY-MM'));
end $seed$;

notify pgrst, 'reload schema';
