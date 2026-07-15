-- ============================================================================
-- VOLUME 41 · CMP — CARRIER MANAGEMENT PLATFORM (migration 075)
-- SRM especializado em transportadoras sobre a tabela `carriers` (mín., recurso
-- 'tms'): homologação, documentos, contratos comerciais, scorecard/ranking,
-- ocorrências, compliance. Nível Oracle TM/SAP TM/Transporeon/project44.
-- NÃO colide com freight_contracts (tarifas/FACMS) nem postal_contracts.
-- Padrão: colunas-padrão, text+check, grant por-tabela, recurso RBAC 'tms'.
-- ============================================================================

-- ── carriers: campos de SRM (ADD, não destrutivo) ───────────────────────────
alter table public.carriers add column if not exists carrier_type text not null default 'transportadora';
alter table public.carriers add column if not exists homologation_status text not null default 'pending';
alter table public.carriers add column if not exists legal_name text;
alter table public.carriers add column if not exists trade_name text;
alter table public.carriers add column if not exists cnpj text;
alter table public.carriers add column if not exists coverage text;
alter table public.carriers add column if not exists specialties text;
alter table public.carriers add column if not exists rating numeric(4,1);

-- ── 1) DOCUMENTOS da transportadora ─────────────────────────────────────────
create table if not exists public.carrier_documents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  carrier_id uuid not null references public.carriers(id) on delete cascade,
  doc_type text not null default 'other' check (doc_type in ('antt','insurance','license','certificate','alvara','fiscal','special_auth','other')),
  number text,
  issuer text,
  valid_from date,
  valid_to date,
  status text not null default 'valid' check (status in ('valid','expired','pending','revoked')),
  file_url text,
  mandatory boolean not null default false,
  notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 2) CONTRATOS comerciais ─────────────────────────────────────────────────
create table if not exists public.carrier_contracts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  carrier_id uuid not null references public.carriers(id) on delete cascade,
  code text,
  contract_type text not null default 'spot' check (contract_type in ('spot','dedicated','master','addendum')),
  start_date date,
  end_date date,
  readjust_index text,
  sla_pickup_hours integer,
  sla_delivery_hours integer,
  penalty_terms text,
  bonus_terms text,
  status text not null default 'active' check (status in ('draft','active','suspended','expired','canceled')),
  notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 3) SCORECARD / performance por período ──────────────────────────────────
create table if not exists public.carrier_scorecards (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  carrier_id uuid not null references public.carriers(id) on delete cascade,
  period_year integer not null,
  period_month integer not null,
  deliveries_total integer not null default 0,
  on_time integer not null default 0,
  otif_pct numeric(5,2),
  otd_pct numeric(5,2),
  lead_time_days numeric(6,2),
  occurrences integer not null default 0,
  damages integer not null default 0,
  losses integer not null default 0,
  cancellations integer not null default 0,
  complaints integer not null default 0,
  punctuality_score numeric(5,2) not null default 0,
  cost_score numeric(5,2) not null default 0,
  quality_score numeric(5,2) not null default 0,
  compliance_score numeric(5,2) not null default 0,
  availability_score numeric(5,2) not null default 0,
  overall_score numeric(6,2) generated always as (
    punctuality_score * 0.30 + quality_score * 0.25 + cost_score * 0.20 + compliance_score * 0.15 + availability_score * 0.10
  ) stored,
  rank integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id),
  constraint carrier_scorecard_uk unique (carrier_id, period_year, period_month)
);

-- ── 4) OCORRÊNCIAS operacionais ─────────────────────────────────────────────
create table if not exists public.carrier_occurrences (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  carrier_id uuid not null references public.carriers(id) on delete cascade,
  occurrence_type text not null default 'delay' check (occurrence_type in ('delay','damage','loss','theft','refusal','failure','nonconformity','accident')),
  severity text not null default 'medium' check (severity in ('low','medium','high','critical')),
  description text,
  shipment_id uuid references public.shipments(id) on delete set null,
  occurred_on date not null default now()::date,
  action_plan text,
  status text not null default 'open' check (status in ('open','investigating','resolved','closed')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_carrier_docs_carrier on public.carrier_documents (carrier_id);
create index if not exists idx_carrier_contracts_carrier on public.carrier_contracts (carrier_id);
create index if not exists idx_carrier_score_carrier on public.carrier_scorecards (carrier_id);
create index if not exists idx_carrier_occ_carrier on public.carrier_occurrences (carrier_id);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'tms') ────────────
do $do$
declare t text; specs text[] := array['carrier_documents','carrier_contracts','carrier_scorecards','carrier_occurrences'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'tms.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'tms.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- Homologa/atualiza situação da transportadora (barra se houver doc obrigatório vencido)
create or replace function public.homologate_carrier(p_company uuid, p_carrier uuid, p_status text)
returns public.carriers language plpgsql security definer set search_path = public, app as $$
declare r public.carriers; v_expired int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('tms.update', p_company)) then raise exception 'forbidden'; end if;
  if p_status = 'approved' then
    select count(*) into v_expired from public.carrier_documents
      where carrier_id=p_carrier and company_id=p_company and mandatory and deleted_at is null
        and (status='expired' or (valid_to is not null and valid_to < now()::date));
    if v_expired > 0 then raise exception 'Não homologável: % documento(s) obrigatório(s) vencido(s)', v_expired; end if;
  end if;
  update public.carriers set homologation_status = p_status where id=p_carrier and company_id=p_company returning * into r;
  if r.id is null then raise exception 'Transportadora não encontrada'; end if;
  return r;
end; $$;
grant execute on function public.homologate_carrier(uuid,uuid,text) to authenticated;

-- Calcula o scorecard do período a partir de shipments + ocorrências (determinístico)
create or replace function public.compute_carrier_scorecard(p_company uuid, p_carrier uuid, p_year integer, p_month integer)
returns public.carrier_scorecards language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.carrier_scorecards;
  v_total int; v_ontime int; v_occ int; v_dmg int; v_loss int; v_cxl int;
  v_otd numeric; v_punct numeric; v_qual numeric; v_comp numeric; v_expired int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('tms.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  -- volume e pontualidade via shipments da transportadora no mês
  select count(*),
         count(*) filter (where status::text in ('delivered','completed','finalizado','entregue'))
    into v_total, v_ontime
  from public.shipments
  where company_id=p_company and carrier_id=p_carrier and deleted_at is null
    and extract(year from created_at)=p_year and extract(month from created_at)=p_month;
  select count(*),
         count(*) filter (where occurrence_type in ('damage')),
         count(*) filter (where occurrence_type in ('loss','theft')),
         count(*) filter (where occurrence_type in ('refusal'))
    into v_occ, v_dmg, v_loss, v_cxl
  from public.carrier_occurrences
  where company_id=p_company and carrier_id=p_carrier and deleted_at is null
    and extract(year from occurred_on)=p_year and extract(month from occurred_on)=p_month;

  v_otd := case when v_total > 0 then round(100.0 * v_ontime / v_total, 2) else 0 end;
  v_punct := v_otd;
  v_qual := greatest(0, 100 - v_occ * 5);
  select count(*) into v_expired from public.carrier_documents
    where carrier_id=p_carrier and company_id=p_company and mandatory and deleted_at is null
      and (status='expired' or (valid_to is not null and valid_to < now()::date));
  v_comp := case when v_expired = 0 then 100 else greatest(0, 100 - v_expired * 25) end;

  insert into public.carrier_scorecards (tenant_id, company_id, carrier_id, period_year, period_month,
     deliveries_total, on_time, otif_pct, otd_pct, occurrences, damages, losses, cancellations,
     punctuality_score, cost_score, quality_score, compliance_score, availability_score)
  values (v_tenant, p_company, p_carrier, p_year, p_month, v_total, v_ontime, v_otd, v_otd, v_occ, v_dmg, v_loss, v_cxl,
     v_punct, 75, v_qual, v_comp, 80)
  on conflict (carrier_id, period_year, period_month) do update set
     deliveries_total=excluded.deliveries_total, on_time=excluded.on_time, otif_pct=excluded.otif_pct, otd_pct=excluded.otd_pct,
     occurrences=excluded.occurrences, damages=excluded.damages, losses=excluded.losses, cancellations=excluded.cancellations,
     punctuality_score=excluded.punctuality_score, quality_score=excluded.quality_score, compliance_score=excluded.compliance_score,
     updated_at=now()
  returning * into r;

  update public.carriers set rating = r.overall_score where id=p_carrier and company_id=p_company;
  return r;
end; $$;
grant execute on function public.compute_carrier_scorecard(uuid,uuid,integer,integer) to authenticated;

-- Ranking das transportadoras pelo scorecard mais recente
create or replace function public.carrier_ranking(p_company uuid)
returns table(carrier_id uuid, carrier text, carrier_type text, homologation_status text, overall_score numeric,
              otd_pct numeric, occurrences integer, period text)
language sql security definer set search_path = public, app stable as $$
  select c.id, coalesce(c.trade_name, c.legal_name, c.code), c.carrier_type, c.homologation_status,
         s.overall_score, s.otd_pct, s.occurrences, s.period_year||'-'||lpad(s.period_month::text,2,'0')
  from public.carriers c
  left join lateral (
    select * from public.carrier_scorecards sc where sc.carrier_id=c.id and sc.deleted_at is null
    order by period_year desc, period_month desc limit 1
  ) s on true
  where c.company_id=p_company and c.deleted_at is null and app.can_access_company(p_company)
  order by s.overall_score desc nulls last, c.code;
$$;
grant execute on function public.carrier_ranking(uuid) to authenticated;

create or replace function public.cmp_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'carriers', (select count(*) from public.carriers where company_id=p_company and deleted_at is null),
    'homologated', (select count(*) from public.carriers where company_id=p_company and homologation_status='approved' and deleted_at is null),
    'pending_homolog', (select count(*) from public.carriers where company_id=p_company and homologation_status in ('pending','under_review') and deleted_at is null),
    'avg_otd', (select round(avg(otd_pct),1) from public.carrier_scorecards where company_id=p_company and deleted_at is null),
    'contracts_expiring', (select count(*) from public.carrier_contracts where company_id=p_company and status='active' and end_date is not null and end_date <= now()::date + 30 and deleted_at is null),
    'docs_expiring', (select count(*) from public.carrier_documents where company_id=p_company and valid_to is not null and valid_to <= now()::date + 30 and status<>'expired' and deleted_at is null),
    'docs_expired', (select count(*) from public.carrier_documents where company_id=p_company and deleted_at is null and (status='expired' or (valid_to is not null and valid_to < now()::date))),
    'occurrences_open', (select count(*) from public.carrier_occurrences where company_id=p_company and status in ('open','investigating') and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.cmp_dashboard(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.cmp_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_doc int; v_ctr int; v_perf int; v_occ int; v_hom int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'CMP%' and deleted_at is null;

  select count(*) into v_doc from public.carrier_documents where company_id=p_company and deleted_at is null
    and (status='expired' or (valid_to is not null and valid_to < now()::date));
  if v_doc > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'CMP: documentos de transportadora vencidos', v_doc||' documento(s) vencido(s).', 'Cobrar renovação; suspender homologação se obrigatório.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_ctr from public.carrier_contracts where company_id=p_company and status='active' and end_date is not null and end_date <= now()::date + 30 and deleted_at is null;
  if v_ctr > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'CMP: contratos vencendo', v_ctr||' contrato(s) vencem em 30 dias.', 'Renegociar/renovar antes do vencimento.', 76);
    v_c := v_c + 1;
  end if;
  select count(*) into v_perf from public.carrier_scorecards s where s.company_id=p_company and s.deleted_at is null and s.overall_score < 60
    and (s.period_year, s.period_month) = (select max(period_year), max(period_month) from public.carrier_scorecards where carrier_id=s.carrier_id);
  if v_perf > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'CMP: transportadoras abaixo da meta', v_perf||' transportadora(s) com score < 60.', 'Plano de melhoria ou realocar volume.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_occ from public.carrier_occurrences where company_id=p_company and status in ('open','investigating') and severity in ('high','critical') and deleted_at is null;
  if v_occ > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'fraud_risk', 'warning', 'CMP: ocorrências graves abertas', v_occ||' ocorrência(s) grave(s)/crítica(s) sem resolução.', 'Acionar plano de ação com a transportadora.', 80);
    v_c := v_c + 1;
  end if;
  select count(*) into v_hom from public.carriers where company_id=p_company and homologation_status in ('pending','under_review') and deleted_at is null;
  if v_hom > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'CMP: homologações pendentes', v_hom||' transportadora(s) aguardando homologação.', 'Concluir a análise documental.', 70);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.cmp_insights(uuid) to authenticated;

-- ── SEED (empresa Matriz Logística) ─────────────────────────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid; v_carrier uuid;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;
  -- pega (ou cria) uma transportadora para semear documentos/contrato/ocorrência
  select id into v_carrier from public.carriers where company_id=v_company and deleted_at is null order by created_at limit 1;
  if v_carrier is null then
    insert into public.carriers (tenant_id, company_id, code, modal, carrier_type, homologation_status, trade_name, legal_name)
    values (v_tenant, v_company, 'TRANSP-01', 'road', 'transportadora', 'approved', 'Rodo Expresso', 'Rodo Expresso Ltda') returning id into v_carrier;
  end if;
  if not exists (select 1 from public.carrier_documents where company_id=v_company and deleted_at is null) then
    insert into public.carrier_documents (tenant_id, company_id, carrier_id, doc_type, number, issuer, valid_to, mandatory, status) values
      (v_tenant, v_company, v_carrier, 'antt', 'RNTRC-12345', 'ANTT', (now()::date + interval '8 months')::date, true, 'valid'),
      (v_tenant, v_company, v_carrier, 'insurance', 'AP-99881', 'Seguradora X', (now()::date - interval '5 days')::date, true, 'expired'); -- vencido (dispara insight)
    insert into public.carrier_contracts (tenant_id, company_id, carrier_id, code, contract_type, start_date, end_date, sla_pickup_hours, sla_delivery_hours, status)
      values (v_tenant, v_company, v_carrier, 'CT-2026-01', 'dedicated', (now()::date - interval '6 months')::date, (now()::date + interval '20 days')::date, 24, 72, 'active');
    insert into public.carrier_occurrences (tenant_id, company_id, carrier_id, occurrence_type, severity, description, status)
      values (v_tenant, v_company, v_carrier, 'delay', 'high', 'Atraso recorrente na coleta', 'open');
  end if;
end $seed$;

notify pgrst, 'reload schema';
