-- 20260713000051_cxp.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  CXP — CUSTOMER EXPERIENCE PLATFORM (Vol 19) — Portal do Cliente          ║
-- ║  Chamados+SLA, conversas, RMA, usuários do portal, documentos (NF/boleto/ ║
-- ║  CoA/contrato), base de conhecimento, NPS/CSAT. Duas pontas: gestão       ║
-- ║  interna + ÁREA DO CLIENTE pública (token anon-safe, padrão /rastreio).   ║
-- ║  Nível Salesforce Experience Cloud. cxp_insights auto-descoberto LAIOS.   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

do $e$ begin
  if not exists (select 1 from pg_type where typname='ticket_status') then
    create type public.ticket_status as enum ('open','in_progress','waiting_customer','resolved','closed'); end if;
  if not exists (select 1 from pg_type where typname='cxp_rma_status') then
    create type public.cxp_rma_status as enum ('requested','approved','rejected','in_transit','received','completed'); end if;
end $e$;

insert into public.permissions (slug, resource, action, description)
select 'cxp.' || a, 'cxp', a, 'Permissão ' || a || ' em cxp'
from unnest(array['read','create','update','delete','approve','resolve']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'cxp' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── PORTAL_USERS (usuários do cliente; access_token p/ área pública) ────────
create table public.portal_users (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  account_id uuid references public.crm_accounts(id) on delete cascade,
  name text not null, email text, portal_role text default 'buyer', access_token text not null default replace(gen_random_uuid()::text,'-',''),
  last_login_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_portal_users_token on public.portal_users (access_token) where deleted_at is null;

-- ── SUPPORT_TICKETS + MESSAGES ──────────────────────────────────────────────
create table public.support_tickets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  ticket_number integer, account_id uuid references public.crm_accounts(id) on delete set null,
  portal_user_id uuid references public.portal_users(id) on delete set null,
  order_id uuid references public.sales_orders(id) on delete set null,
  subject text not null, category text default 'general', priority text default 'normal',
  status public.ticket_status not null default 'open', channel text default 'portal',
  assigned_to text, sla_due timestamptz, resolved_at timestamptz, csat integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_tickets_status on public.support_tickets (company_id, status) where deleted_at is null;

create table public.ticket_messages (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  ticket_id uuid not null references public.support_tickets(id) on delete cascade,
  sender_type text not null default 'agent', sender_name text, body text, attachment_url text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_ticket_messages_ticket on public.ticket_messages (ticket_id, created_at);

-- ── RMA_REQUESTS (troca/garantia/devolução/crédito) ─────────────────────────
create table public.cxp_rma_requests (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  rma_number integer, account_id uuid references public.crm_accounts(id) on delete set null,
  order_id uuid references public.sales_orders(id) on delete set null,
  rma_type text default 'return', status public.cxp_rma_status not null default 'requested',
  reason text, resolution text, refund_amount numeric(18,2),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_cxp_rma_status on public.cxp_rma_requests (company_id, status) where deleted_at is null;

-- ── CUSTOMER_DOCUMENTS (NF/boleto/contrato/CoA/laudo) ───────────────────────
create table public.customer_documents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  account_id uuid references public.crm_accounts(id) on delete cascade,
  doc_type text not null default 'invoice', title text not null, url text, storage_path text, reference text, issued_at date default now()::date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_customer_documents_account on public.customer_documents (account_id);

-- ── KNOWLEDGE_ARTICLES (área técnica: manuais/FISPQ/FAQ/vídeos) ─────────────
create table public.knowledge_articles (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  title text not null, category text, article_type text default 'faq', url text, content text, is_public boolean not null default true, views integer not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── CUSTOMER_FEEDBACK (NPS/CSAT/CES) ────────────────────────────────────────
create table public.customer_feedback (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  account_id uuid references public.crm_accounts(id) on delete set null,
  kind text not null default 'nps', score integer, comment text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ RPCs (gestão interna) ══════════════════════════════════════════════════

create or replace function app.ticket_sla(p_priority text)
returns interval language sql immutable as $$
  select case p_priority when 'urgent' then interval '4 hours' when 'high' then interval '1 day'
    when 'low' then interval '5 days' else interval '3 days' end;
$$;

create or replace function public.open_ticket(p_company uuid, p_account uuid, p_subject text, p_category text default 'general', p_priority text default 'normal', p_body text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_ticket uuid; v_num int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('cxp.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select coalesce(max(ticket_number),0)+1 into v_num from public.support_tickets where company_id=p_company;
  insert into public.support_tickets (tenant_id, company_id, ticket_number, account_id, subject, category, priority, status, sla_due)
  values (v_tenant, p_company, v_num, p_account, p_subject, p_category, p_priority, 'open', now() + app.ticket_sla(p_priority))
  returning id into v_ticket;
  if p_body is not null then
    insert into public.ticket_messages (tenant_id, company_id, ticket_id, sender_type, body) values (v_tenant, p_company, v_ticket, 'customer', p_body);
  end if;
  return jsonb_build_object('id', v_ticket, 'ticket_number', v_num);
end;
$$;
grant execute on function public.open_ticket(uuid, uuid, text, text, text, text) to authenticated;

create or replace function public.reply_ticket(p_ticket uuid, p_body text, p_sender_type text default 'agent', p_new_status public.ticket_status default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare t record;
begin
  select * into t from public.support_tickets where id=p_ticket and deleted_at is null;
  if t.id is null then raise exception 'chamado não encontrado'; end if;
  if not (app.can_access_company(t.company_id) and app.has_permission('cxp.update', t.company_id)) then raise exception 'forbidden'; end if;
  insert into public.ticket_messages (tenant_id, company_id, ticket_id, sender_type, body) values (t.tenant_id, t.company_id, p_ticket, coalesce(p_sender_type,'agent'), p_body);
  update public.support_tickets set status = coalesce(p_new_status, case when p_sender_type='customer' then 'open' else 'in_progress' end::public.ticket_status) where id=p_ticket;
  return jsonb_build_object('ticket_id', p_ticket, 'replied', true);
end;
$$;
grant execute on function public.reply_ticket(uuid, text, text, public.ticket_status) to authenticated;

create or replace function public.resolve_ticket(p_ticket uuid, p_csat integer default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare t record;
begin
  select * into t from public.support_tickets where id=p_ticket and deleted_at is null;
  if t.id is null then raise exception 'chamado não encontrado'; end if;
  if not (app.can_access_company(t.company_id) and app.has_permission('cxp.resolve', t.company_id)) then raise exception 'forbidden'; end if;
  update public.support_tickets set status='resolved', resolved_at=now(), csat=p_csat where id=p_ticket;
  return jsonb_build_object('ticket_id', p_ticket, 'status', 'resolved');
end;
$$;
grant execute on function public.resolve_ticket(uuid, integer) to authenticated;

create or replace function public.open_rma(p_company uuid, p_account uuid, p_order uuid, p_type text, p_reason text)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_rma uuid; v_num int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('cxp.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select coalesce(max(rma_number),0)+1 into v_num from public.cxp_rma_requests where company_id=p_company;
  insert into public.cxp_rma_requests (tenant_id, company_id, rma_number, account_id, order_id, rma_type, status, reason)
  values (v_tenant, p_company, v_num, p_account, p_order, coalesce(p_type,'return'), 'requested', p_reason)
  returning id into v_rma;
  return jsonb_build_object('id', v_rma, 'rma_number', v_num);
end;
$$;
grant execute on function public.open_rma(uuid, uuid, uuid, text, text) to authenticated;

create or replace function public.cxp_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'tickets_open', (select count(*) from public.support_tickets where company_id=p_company and status in ('open','in_progress','waiting_customer') and deleted_at is null),
    'tickets_overdue', (select count(*) from public.support_tickets where company_id=p_company and status in ('open','in_progress','waiting_customer') and sla_due < now() and deleted_at is null),
    'avg_resolution_h', (select coalesce(round(avg(extract(epoch from (resolved_at-created_at))/3600)::numeric,1),0) from public.support_tickets where company_id=p_company and resolved_at is not null and deleted_at is null),
    'csat', (select coalesce(round(avg(csat)::numeric,1),0) from public.support_tickets where company_id=p_company and csat is not null and deleted_at is null),
    'nps', (select coalesce(round(avg(score)::numeric,1),0) from public.customer_feedback where company_id=p_company and kind='nps' and deleted_at is null),
    'rma_open', (select count(*) from public.cxp_rma_requests where company_id=p_company and status not in ('completed','rejected') and deleted_at is null),
    'portal_users', (select count(*) from public.portal_users where company_id=p_company and active and deleted_at is null),
    'documents', (select count(*) from public.customer_documents where company_id=p_company and deleted_at is null),
    'articles', (select count(*) from public.knowledge_articles where company_id=p_company and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.cxp_dashboard(uuid) to authenticated;

create or replace function public.cxp_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_sla int; v_stale int; v_rma int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Atendimento%' and deleted_at is null;

  select count(*) into v_sla from public.support_tickets where company_id=p_company and status in ('open','in_progress','waiting_customer') and sla_due < now() and deleted_at is null;
  if v_sla > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'critical', 'Atendimento: SLA estourado', v_sla||' chamado(s) com SLA vencido.', 'Priorizar resposta — impacto direto no CSAT/NPS.', 90);
    v_c := v_c + 1;
  end if;
  select count(*) into v_stale from public.support_tickets where company_id=p_company and status in ('open','in_progress') and deleted_at is null and updated_at < now() - interval '3 days';
  if v_stale > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'Atendimento: chamados parados', v_stale||' chamado(s) sem interação há +3 dias.', 'Retomar ou reatribuir os chamados.', 80);
    v_c := v_c + 1;
  end if;
  select count(*) into v_rma from public.cxp_rma_requests where company_id=p_company and status='requested' and deleted_at is null and created_at < now() - interval '2 days';
  if v_rma > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'supplier_risk', 'warning', 'Atendimento: RMA aguardando análise', v_rma||' solicitação(ões) de RMA sem tratativa há +2 dias.', 'Analisar troca/garantia/devolução para não perder o cliente.', 82);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.cxp_insights(uuid) to authenticated;

-- Snapshot 360 do cliente (staff/impersonation)
create or replace function public.customer_portal_snapshot(p_account uuid)
returns jsonb language plpgsql stable security definer set search_path = public, app as $$
declare a record;
begin
  select * into a from public.crm_accounts where id=p_account and deleted_at is null;
  if a.id is null or not app.can_access_company(a.company_id) then return '{}'::jsonb; end if;
  return jsonb_build_object(
    'account', jsonb_build_object('name', a.name, 'segment', a.segment, 'health', a.health, 'nps', a.nps),
    'orders', (select coalesce(jsonb_agg(jsonb_build_object('number', order_number, 'status', status, 'total', total_amount, 'date', created_at::date) order by order_number desc),'[]'::jsonb)
        from (select * from public.sales_orders where account_id=p_account and deleted_at is null order by order_number desc limit 10) o),
    'documents', (select coalesce(jsonb_agg(jsonb_build_object('type', doc_type, 'title', title, 'url', url, 'date', issued_at) order by issued_at desc),'[]'::jsonb)
        from public.customer_documents where account_id=p_account and deleted_at is null),
    'tickets_open', (select count(*) from public.support_tickets where account_id=p_account and status in ('open','in_progress','waiting_customer') and deleted_at is null)
  );
end;
$$;
grant execute on function public.customer_portal_snapshot(uuid) to authenticated;

-- ══ RPCs PÚBLICOS (área do cliente, anon-safe por token — padrão /rastreio) ══
create or replace function public.portal_public_snapshot(p_token text)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare u record; a record;
begin
  select * into u from public.portal_users where access_token=p_token and active and deleted_at is null;
  if u.id is null then return jsonb_build_object('error','código inválido'); end if;
  update public.portal_users set last_login_at=now() where id=u.id;
  select * into a from public.crm_accounts where id=u.account_id;
  return jsonb_build_object(
    'user', u.name, 'account', coalesce(a.name, u.name),
    'orders', (select coalesce(jsonb_agg(jsonb_build_object('number', order_number, 'status', status, 'total', total_amount, 'date', created_at::date) order by order_number desc),'[]'::jsonb)
        from (select * from public.sales_orders where account_id=u.account_id and deleted_at is null order by order_number desc limit 10) o),
    'documents', (select coalesce(jsonb_agg(jsonb_build_object('type', doc_type, 'title', title, 'url', url, 'date', issued_at) order by issued_at desc),'[]'::jsonb)
        from public.customer_documents where account_id=u.account_id and deleted_at is null),
    'tickets', (select coalesce(jsonb_agg(jsonb_build_object('number', ticket_number, 'subject', subject, 'status', status, 'date', created_at::date) order by ticket_number desc),'[]'::jsonb)
        from public.support_tickets where account_id=u.account_id and deleted_at is null)
  );
end;
$$;
grant execute on function public.portal_public_snapshot(text) to anon, authenticated;

create or replace function public.portal_public_open_ticket(p_token text, p_subject text, p_body text, p_priority text default 'normal')
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare u record; v_ticket uuid; v_num int;
begin
  select * into u from public.portal_users where access_token=p_token and active and deleted_at is null;
  if u.id is null then return jsonb_build_object('error','código inválido'); end if;
  select coalesce(max(ticket_number),0)+1 into v_num from public.support_tickets where company_id=u.company_id;
  insert into public.support_tickets (tenant_id, company_id, ticket_number, account_id, portal_user_id, subject, priority, status, channel, sla_due)
  values (u.tenant_id, u.company_id, v_num, u.account_id, u.id, p_subject, coalesce(p_priority,'normal'), 'open', 'portal', now() + app.ticket_sla(coalesce(p_priority,'normal')))
  returning id into v_ticket;
  if p_body is not null then
    insert into public.ticket_messages (tenant_id, company_id, ticket_id, sender_type, sender_name, body) values (u.tenant_id, u.company_id, v_ticket, 'customer', u.name, p_body);
  end if;
  return jsonb_build_object('ticket_number', v_num);
end;
$$;
grant execute on function public.portal_public_open_ticket(text, text, text, text) to anon, authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'cxp') ────────────
do $do$
declare t text; specs text[] := array['portal_users','support_tickets','ticket_messages','cxp_rma_requests','customer_documents','knowledge_articles','customer_feedback'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'cxp.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'cxp.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

notify pgrst, 'reload schema';
