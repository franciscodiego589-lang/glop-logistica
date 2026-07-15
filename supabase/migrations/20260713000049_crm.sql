-- 20260713000049_crm.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  ECSP — ENTERPRISE CRM & SALES PLATFORM (Vol 17) — Core Comercial         ║
-- ║  Contas 360°, leads multicanal, PIPELINE Kanban configurável,             ║
-- ║  oportunidades, propostas, atividades/agenda, campanhas, IA comercial.    ║
-- ║  Integração real: oportunidade GANHA → lança venda no GL/Financeiro.      ║
-- ║  Nível Salesforce / Dynamics 365 Sales. crm_insights auto-descoberto LAIOS.║
-- ╚══════════════════════════════════════════════════════════════════════════╝

do $e$ begin
  if not exists (select 1 from pg_type where typname='crm_lead_status') then
    create type public.crm_lead_status as enum ('new','qualified','converted','lost'); end if;
  if not exists (select 1 from pg_type where typname='crm_opp_status') then
    create type public.crm_opp_status as enum ('open','won','lost'); end if;
end $e$;

-- recurso RBAC 'crm'
insert into public.permissions (slug, resource, action, description)
select 'crm.' || a, 'crm', a, 'Permissão ' || a || ' em crm'
from unnest(array['read','create','update','delete','approve','convert']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'crm' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── PIPELINES + STAGES (funis configuráveis) ────────────────────────────────
create table public.crm_pipelines (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, is_default boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.crm_stages (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  pipeline_id uuid not null references public.crm_pipelines(id) on delete cascade,
  name text not null, order_index integer not null default 1, probability numeric(5,2) not null default 0,
  is_won boolean not null default false, is_lost boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_crm_stages_pipeline on public.crm_stages (pipeline_id, order_index);

-- ── ACCOUNTS (clientes 360°) + CONTACTS ─────────────────────────────────────
create table public.crm_accounts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, account_type text default 'company', segment text, classification text,
  document text, email text, phone text, city text, state text,
  score integer not null default 0, credit_limit numeric(18,2), payment_terms text,
  owner text, health text default 'healthy', nps integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_crm_accounts_owner on public.crm_accounts (company_id, owner) where deleted_at is null;

create table public.crm_contacts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  account_id uuid references public.crm_accounts(id) on delete cascade,
  name text not null, role_title text, email text, phone text, is_primary boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_crm_contacts_account on public.crm_contacts (account_id);

-- ── LEADS ───────────────────────────────────────────────────────────────────
create table public.crm_leads (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, company_name text, source text, status public.crm_lead_status not null default 'new',
  score integer not null default 0, email text, phone text, estimated_value numeric(18,2), owner text, notes text,
  converted_account_id uuid references public.crm_accounts(id) on delete set null,
  converted_opportunity_id uuid, last_contacted_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_crm_leads_status on public.crm_leads (company_id, status) where deleted_at is null;

-- ── OPPORTUNITIES ───────────────────────────────────────────────────────────
create table public.crm_opportunities (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  title text not null, account_id uuid references public.crm_accounts(id) on delete set null,
  pipeline_id uuid references public.crm_pipelines(id) on delete set null,
  stage_id uuid references public.crm_stages(id) on delete set null,
  amount numeric(18,2) not null default 0, probability numeric(5,2) not null default 0,
  owner text, source text, expected_close date, status public.crm_opp_status not null default 'open',
  lost_reason text, won_at timestamptz, lost_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_crm_opps_stage on public.crm_opportunities (company_id, stage_id, status) where deleted_at is null;

-- ── ACTIVITIES (interações + agenda) ────────────────────────────────────────
create table public.crm_activities (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  subject text not null, activity_type text default 'task', channel text,
  related_type text, related_id uuid, account_id uuid references public.crm_accounts(id) on delete set null,
  due_at timestamptz, done boolean not null default false, done_at timestamptz, owner text, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_crm_activities_due on public.crm_activities (company_id, done, due_at) where deleted_at is null;

-- ── PROPOSALS + CAMPAIGNS ───────────────────────────────────────────────────
create table public.crm_proposals (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  opportunity_id uuid references public.crm_opportunities(id) on delete set null,
  account_id uuid references public.crm_accounts(id) on delete set null,
  number text, title text, amount numeric(18,2) not null default 0, status text not null default 'draft',
  valid_until date, version_label text, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.crm_campaigns (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, channel text, budget numeric(18,2), start_date date, end_date date,
  status text not null default 'planned', leads_generated integer not null default 0, revenue numeric(18,2) not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Converter lead → cria conta (se preciso) + oportunidade no funil padrão
create or replace function public.convert_lead(p_lead uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare l record; v_account uuid; v_pipeline uuid; v_stage uuid; v_opp uuid; v_prob numeric;
begin
  select * into l from public.crm_leads where id=p_lead and deleted_at is null;
  if l.id is null then raise exception 'lead não encontrado'; end if;
  if not (app.can_access_company(l.company_id) and app.has_permission('crm.convert', l.company_id)) then raise exception 'forbidden'; end if;
  if l.status = 'converted' then raise exception 'lead já convertido'; end if;

  v_account := l.converted_account_id;
  if v_account is null then
    insert into public.crm_accounts (tenant_id, company_id, name, account_type, email, phone, owner, score)
    values (l.tenant_id, l.company_id, coalesce(l.company_name, l.name), 'company', l.email, l.phone, l.owner, l.score)
    returning id into v_account;
  end if;

  select id into v_pipeline from public.crm_pipelines where company_id=l.company_id and is_default and deleted_at is null limit 1;
  select id, probability into v_stage, v_prob from public.crm_stages where pipeline_id=v_pipeline and deleted_at is null and not is_won and not is_lost order by order_index limit 1;

  insert into public.crm_opportunities (tenant_id, company_id, title, account_id, pipeline_id, stage_id, amount, probability, owner, source, status)
  values (l.tenant_id, l.company_id, coalesce(l.name,'Oportunidade')||' — '||coalesce(l.company_name,''), v_account, v_pipeline, v_stage, coalesce(l.estimated_value,0), coalesce(v_prob,0), l.owner, l.source, 'open')
  returning id into v_opp;

  update public.crm_leads set status='converted', converted_account_id=v_account, converted_opportunity_id=v_opp where id=p_lead;
  return jsonb_build_object('account_id', v_account, 'opportunity_id', v_opp);
end;
$$;
grant execute on function public.convert_lead(uuid) to authenticated;

-- Mover oportunidade de etapa; se etapa "ganha" → fecha e LANÇA VENDA no GL
create or replace function public.move_opportunity(p_opp uuid, p_stage uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare o record; st record; v_gl jsonb; v_status public.crm_opp_status;
begin
  select * into o from public.crm_opportunities where id=p_opp and deleted_at is null;
  if o.id is null then raise exception 'oportunidade não encontrada'; end if;
  if not (app.can_access_company(o.company_id) and app.has_permission('crm.update', o.company_id)) then raise exception 'forbidden'; end if;
  select * into st from public.crm_stages where id=p_stage and deleted_at is null;
  if st.id is null then raise exception 'etapa inválida'; end if;

  v_status := case when st.is_won then 'won' when st.is_lost then 'lost' else 'open' end::public.crm_opp_status;
  update public.crm_opportunities set stage_id=p_stage, probability=st.probability, status=v_status,
    won_at = case when st.is_won then now() else won_at end, lost_at = case when st.is_lost then now() else lost_at end
  where id=p_opp;

  -- venda ganha alimenta o Financeiro/Contabilidade automaticamente
  if st.is_won and o.status <> 'won' and o.amount > 0 then
    begin
      v_gl := public.post_accounting_event(o.company_id, 'sale_invoice', o.amount, 'Venda CRM: '||o.title, 'OPP-'||left(p_opp::text,8), 'crm', p_opp);
    exception when others then v_gl := null; end;
  end if;
  return jsonb_build_object('opportunity_id', p_opp, 'status', v_status, 'probability', st.probability, 'gl_posted', v_gl is not null);
end;
$$;
grant execute on function public.move_opportunity(uuid, uuid) to authenticated;

-- Dashboard comercial
create or replace function public.crm_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'accounts', (select count(*) from public.crm_accounts where company_id=p_company and deleted_at is null),
    'leads_open', (select count(*) from public.crm_leads where company_id=p_company and status in ('new','qualified') and deleted_at is null),
    'opps_open', (select count(*) from public.crm_opportunities where company_id=p_company and status='open' and deleted_at is null),
    'pipeline_value', (select coalesce(sum(amount),0) from public.crm_opportunities where company_id=p_company and status='open' and deleted_at is null),
    'weighted_pipeline', (select coalesce(round(sum(amount*probability/100),2),0) from public.crm_opportunities where company_id=p_company and status='open' and deleted_at is null),
    'won_value_ytd', (select coalesce(sum(amount),0) from public.crm_opportunities where company_id=p_company and status='won' and deleted_at is null and extract(year from coalesce(won_at, updated_at))=extract(year from now())),
    'won_count', (select count(*) from public.crm_opportunities where company_id=p_company and status='won' and deleted_at is null),
    'lost_count', (select count(*) from public.crm_opportunities where company_id=p_company and status='lost' and deleted_at is null),
    'avg_ticket', (select coalesce(round(avg(amount),2),0) from public.crm_opportunities where company_id=p_company and status='won' and deleted_at is null),
    'tasks_due', (select count(*) from public.crm_activities where company_id=p_company and not done and due_at <= now() and deleted_at is null),
    'by_source', (select coalesce(jsonb_object_agg(coalesce(source,'—'), c),'{}'::jsonb) from (select source, count(*) c from public.crm_leads where company_id=p_company and deleted_at is null group by source) s)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.crm_dashboard(uuid) to authenticated;

-- Forecast de vendas: pipeline ponderado (valor × probabilidade) por mês de fechamento
create or replace function public.sales_forecast(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(jsonb_build_object('month', m, 'pipeline', pipe, 'weighted', weighted) order by m) from (
      select to_char(coalesce(expected_close, now()::date),'YYYY-MM') m,
        round(sum(amount),2) pipe, round(sum(amount*probability/100),2) weighted
      from public.crm_opportunities where company_id=p_company and status='open' and deleted_at is null
      group by 1
    ) s
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.sales_forecast(uuid) to authenticated;

-- IA COMERCIAL: oportunidades paradas, leads sem contato, clientes em risco → LOGIA
create or replace function public.crm_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_stale int; v_cold int; v_churn int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Comercial%' and deleted_at is null;

  select count(*) into v_stale from public.crm_opportunities where company_id=p_company and status='open' and deleted_at is null and updated_at < now() - interval '14 days';
  if v_stale > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'Comercial: oportunidades paradas', v_stale||' oportunidade(s) sem movimento há mais de 14 dias.', 'Retomar contato ou reavaliar a etapa — pipeline estagnado.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_cold from public.crm_leads where company_id=p_company and status='new' and deleted_at is null and created_at < now() - interval '7 days' and last_contacted_at is null;
  if v_cold > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'opportunity', 'warning', 'Comercial: leads sem contato', v_cold||' lead(s) novo(s) sem primeiro contato há +7 dias.', 'Priorizar contato — leads esfriam rápido.', 85);
    v_c := v_c + 1;
  end if;
  select count(*) into v_churn from public.crm_accounts where company_id=p_company and deleted_at is null and (health='at_risk' or (nps is not null and nps <= 6));
  if v_churn > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'supplier_risk', 'critical', 'Comercial: risco de churn', v_churn||' cliente(s) com saúde em risco / NPS baixo.', 'Acionar Customer Success com plano de retenção.', 80);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.crm_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'crm') ────────────
do $do$
declare t text; specs text[] := array['crm_pipelines','crm_stages','crm_accounts','crm_contacts','crm_leads','crm_opportunities','crm_activities','crm_proposals','crm_campaigns'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'crm.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'crm.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: funil padrão + etapas (por empresa) ══
do $do$
declare c record; v_pipe uuid;
  stages jsonb := '[
    {"n":"Novo Lead","o":1,"p":10,"w":false,"l":false},
    {"n":"Qualificação","o":2,"p":20,"w":false,"l":false},
    {"n":"Contato","o":3,"p":30,"w":false,"l":false},
    {"n":"Reunião/Diagnóstico","o":4,"p":45,"w":false,"l":false},
    {"n":"Proposta","o":5,"p":60,"w":false,"l":false},
    {"n":"Negociação","o":6,"p":80,"w":false,"l":false},
    {"n":"Ganho","o":7,"p":100,"w":true,"l":false},
    {"n":"Perdido","o":8,"p":0,"w":false,"l":true}
  ]'::jsonb;
  s jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    if not exists (select 1 from public.crm_pipelines where company_id=c.id and is_default and deleted_at is null) then
      insert into public.crm_pipelines (tenant_id, company_id, name, is_default) values (c.tenant_id, c.id, 'Funil de Vendas', true) returning id into v_pipe;
      for s in select value from jsonb_array_elements(stages) loop
        insert into public.crm_stages (tenant_id, company_id, pipeline_id, name, order_index, probability, is_won, is_lost)
        values (c.tenant_id, c.id, v_pipe, s->>'n', (s->>'o')::int, (s->>'p')::numeric, (s->>'w')::boolean, (s->>'l')::boolean);
      end loop;
    end if;
  end loop;
end $do$;

notify pgrst, 'reload schema';
