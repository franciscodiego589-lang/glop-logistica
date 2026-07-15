-- 20260713000063_ecc.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  ECC — ENTERPRISE COMMAND CENTER (Vol 31) — Fase 2 Enterprise+            ║
-- ║  Torre de controle em TEMPO REAL (mission control): consolida o estado    ║
-- ║  vivo de TODOS os módulos, central de alertas classificados + owner/SLA,  ║
-- ║  sala de crise c/ plano de ação e timeline. ≠ BI (histórico). Nível SAP   ║
-- ║  Control Tower / Fabric Real-Time. ecc_insights auto-descoberto LAIOS.    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- reusa recurso RBAC 'controltower'
insert into public.permissions (slug, resource, action, description)
select 'controltower.' || a, 'controltower', a, 'Permissão ' || a || ' em controltower'
from unnest(array['read','create','update','delete','approve','resolve']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'controltower' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── COMMAND_ALERTS (central de alertas classificados) ───────────────────────
create table public.command_alerts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  source_module text, severity text default 'medium', title text not null, impact text, recommendation text,
  owner text, due_at timestamptz, status text default 'open', priority integer default 3, source_ref text,
  acked_by uuid references auth.users(id), acked_at timestamptz, resolved_by uuid references auth.users(id), resolved_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_command_alerts on public.command_alerts (company_id, status, severity) where deleted_at is null;

-- ── CRISIS_ROOMS + UPDATES (sala de crise) ──────────────────────────────────
create table public.crisis_rooms (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  crisis_type text default 'incident', title text not null, severity text default 'high', status text default 'active',
  action_plan text, commander text, opened_at timestamptz not null default now(), closed_at timestamptz, impact text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_crisis_rooms on public.crisis_rooms (company_id, status) where deleted_at is null;
create table public.crisis_updates (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  crisis_id uuid not null references public.crisis_rooms(id) on delete cascade,
  note text, status_to text, author uuid references auth.users(id),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_crisis_updates on public.crisis_updates (crisis_id, created_at);

-- ══ MISSION CONTROL: estado vivo consolidado de todos os módulos ═══════════
create or replace function public.command_overview(p_company uuid)
returns jsonb language plpgsql stable security definer set search_path = public, app as $$
declare v_ops jsonb; v_alerts jsonb; v_feed jsonb; v_kpis jsonb;
begin
  if not app.can_access_company(p_company) then return '{}'::jsonb; end if;

  v_ops := jsonb_build_object(
    'orders_open', (select count(*) from public.sales_orders where company_id=p_company and status in ('new','approved','reserved','awaiting_production','picking') and deleted_at is null),
    'awaiting_production', (select count(*) from public.sales_orders where company_id=p_company and status='awaiting_production' and deleted_at is null),
    'shipped_today', (select count(*) from public.sales_orders where company_id=p_company and shipped_at::date=now()::date and deleted_at is null),
    'invoiced_today', (select count(*) from public.sales_orders where company_id=p_company and invoiced_at::date=now()::date and deleted_at is null),
    'tasks_pending', (select count(*) from public.process_tasks where company_id=p_company and status='pending' and deleted_at is null),
    'tickets_open', (select count(*) from public.support_tickets where company_id=p_company and status in ('open','in_progress','waiting_customer') and deleted_at is null),
    'dlq', (select count(*) from public.integration_messages where company_id=p_company and status='dead_letter' and deleted_at is null),
    'sec_incidents', (select count(*) from public.security_incidents where company_id=p_company and status='open' and deleted_at is null),
    'low_stock', (select count(*) from public.stock_balances b where b.company_id=p_company and b.deleted_at is null and (b.quantity - b.reserved_quantity) <= 0)
  );
  v_alerts := jsonb_build_object(
    'critical', (select count(*) from public.command_alerts where company_id=p_company and status='open' and severity='critical' and deleted_at is null),
    'high', (select count(*) from public.command_alerts where company_id=p_company and status='open' and severity='high' and deleted_at is null),
    'medium', (select count(*) from public.command_alerts where company_id=p_company and status='open' and severity='medium' and deleted_at is null),
    'open_total', (select count(*) from public.command_alerts where company_id=p_company and status='open' and deleted_at is null),
    'crises', (select count(*) from public.crisis_rooms where company_id=p_company and status='active' and deleted_at is null)
  );
  -- feed vivo: últimos insights da IA + eventos do barramento
  v_feed := coalesce((select jsonb_agg(x order by (x->>'at') desc) from (
      (select jsonb_build_object('kind','insight','title', title, 'severity', severity::text, 'at', created_at) x
        from public.logia_insights where company_id=p_company and status='new' and deleted_at is null order by created_at desc limit 8)
      union all
      (select jsonb_build_object('kind','event','title', event_type||' ('||coalesce(source_module,'?')||')', 'severity','info', 'at', occurred_at)
        from public.event_bus where company_id=p_company and deleted_at is null order by occurred_at desc limit 8)
    ) f), '[]'::jsonb);
  v_kpis := jsonb_build_object(
    'revenue_12m', public.compute_kpi(p_company,'revenue_12m'),
    'net_income', public.compute_kpi(p_company,'net_income_month'),
    'pipeline', public.compute_kpi(p_company,'pipeline_value'),
    'headcount', public.compute_kpi(p_company,'headcount'),
    'stock_value', public.compute_kpi(p_company,'stock_value'),
    'tax_payable', public.compute_kpi(p_company,'tax_payable')
  );
  return jsonb_build_object('as_of', now(), 'ops', v_ops, 'alerts', v_alerts, 'feed', v_feed, 'kpis', v_kpis);
end;
$$;
grant execute on function public.command_overview(uuid) to authenticated;

-- Ingerir alertas: consolida insights da IA + incidentes de segurança na central
create or replace function public.sync_command_alerts(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r record; v_n int := 0;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  -- insights novos críticos/alerta → alertas (dedup por título aberto)
  for r in select title, description, recommendation, severity::text sev, kind::text from public.logia_insights
    where company_id=p_company and status='new' and severity in ('critical','warning') and deleted_at is null loop
    if not exists (select 1 from public.command_alerts where company_id=p_company and title=r.title and status<>'resolved' and deleted_at is null) then
      insert into public.command_alerts (tenant_id, company_id, source_module, severity, title, impact, recommendation, source_ref)
      values (v_tenant, p_company, 'IA/LAIOS', case when r.sev='critical' then 'critical' else 'high' end, r.title, r.description, r.recommendation, 'logia');
      v_n := v_n + 1;
    end if;
  end loop;
  -- incidentes de segurança abertos → alertas
  for r in select incident_type, subject, description, severity from public.security_incidents where company_id=p_company and status='open' and deleted_at is null loop
    if not exists (select 1 from public.command_alerts where company_id=p_company and title='Segurança: '||r.incident_type||' — '||coalesce(r.subject,'') and status<>'resolved' and deleted_at is null) then
      insert into public.command_alerts (tenant_id, company_id, source_module, severity, title, impact, source_ref)
      values (v_tenant, p_company, 'IAM', case when r.severity in ('high','critical') then 'critical' else 'high' end, 'Segurança: '||r.incident_type||' — '||coalesce(r.subject,''), r.description, 'security');
      v_n := v_n + 1;
    end if;
  end loop;
  return jsonb_build_object('new_alerts', v_n);
end;
$$;
grant execute on function public.sync_command_alerts(uuid) to authenticated;

create or replace function public.ack_alert(p_alert uuid, p_resolve boolean default false)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare a record;
begin
  select * into a from public.command_alerts where id=p_alert and deleted_at is null;
  if a.id is null then raise exception 'alerta não encontrado'; end if;
  if not (app.can_access_company(a.company_id) and app.has_permission('controltower.update', a.company_id)) then raise exception 'forbidden'; end if;
  if p_resolve then
    update public.command_alerts set status='resolved', resolved_by=auth.uid(), resolved_at=now() where id=p_alert;
  else
    update public.command_alerts set status='acknowledged', acked_by=auth.uid(), acked_at=now() where id=p_alert;
  end if;
  return jsonb_build_object('alert', p_alert, 'status', case when p_resolve then 'resolved' else 'acknowledged' end);
end;
$$;
grant execute on function public.ack_alert(uuid, boolean) to authenticated;

create or replace function public.open_crisis(p_company uuid, p_type text, p_title text, p_severity text, p_plan text default null, p_commander text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_id uuid;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.crisis_rooms (tenant_id, company_id, crisis_type, title, severity, action_plan, commander, status)
  values (v_tenant, p_company, p_type, p_title, p_severity, p_plan, p_commander, 'active') returning id into v_id;
  insert into public.crisis_updates (tenant_id, company_id, crisis_id, note, status_to, author) values (v_tenant, p_company, v_id, 'Sala de crise aberta.', 'active', auth.uid());
  return jsonb_build_object('crisis_id', v_id, 'title', p_title);
end;
$$;
grant execute on function public.open_crisis(uuid, text, text, text, text, text) to authenticated;

create or replace function public.update_crisis(p_crisis uuid, p_note text, p_status text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare c record;
begin
  select * into c from public.crisis_rooms where id=p_crisis and deleted_at is null;
  if c.id is null then raise exception 'crise não encontrada'; end if;
  if not (app.can_access_company(c.company_id) and app.has_permission('controltower.update', c.company_id)) then raise exception 'forbidden'; end if;
  insert into public.crisis_updates (tenant_id, company_id, crisis_id, note, status_to, author) values (c.tenant_id, c.company_id, p_crisis, p_note, p_status, auth.uid());
  if p_status is not null then
    update public.crisis_rooms set status=p_status, closed_at = case when p_status in ('closed','resolved') then now() else closed_at end where id=p_crisis;
  end if;
  return jsonb_build_object('crisis', p_crisis, 'status', coalesce(p_status, c.status));
end;
$$;
grant execute on function public.update_crisis(uuid, text, text) to authenticated;

create or replace function public.ecc_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'alerts_open', (select count(*) from public.command_alerts where company_id=p_company and status='open' and deleted_at is null),
    'alerts_critical', (select count(*) from public.command_alerts where company_id=p_company and status='open' and severity='critical' and deleted_at is null),
    'crises_active', (select count(*) from public.crisis_rooms where company_id=p_company and status='active' and deleted_at is null),
    'alerts_resolved_today', (select count(*) from public.command_alerts where company_id=p_company and resolved_at::date=now()::date and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.ecc_dashboard(uuid) to authenticated;

create or replace function public.ecc_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_crit int; v_crise int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Comando:%' and deleted_at is null;

  select count(*) into v_crit from public.command_alerts where company_id=p_company and status='open' and severity='critical' and deleted_at is null and created_at < now() - interval '2 hours';
  if v_crit > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'critical', 'Comando: alertas críticos sem tratativa', v_crit||' alerta(s) crítico(s) abertos há +2h.', 'Acionar o responsável — pode virar crise.', 90);
    v_c := v_c + 1;
  end if;
  select count(*) into v_crise from public.crisis_rooms where company_id=p_company and status='active' and deleted_at is null;
  if v_crise > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'fraud_risk', 'critical', 'Comando: sala(s) de crise ativa(s)', v_crise||' crise(s) em andamento.', 'Acompanhar o plano de ação até o encerramento.', 92);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.ecc_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'controltower') ───
do $do$
declare t text; specs text[] := array['command_alerts','crisis_rooms','crisis_updates'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'controltower.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'controltower.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

notify pgrst, 'reload schema';
