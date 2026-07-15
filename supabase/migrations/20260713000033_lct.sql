-- 20260713000033_lct.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  LOGISTICS CONTROL TOWER (LCT) — Centro de Comando Operacional + IA        ║
-- ║  O "cérebro" que consolida WMS/TMS/Correios/Expedição/Estoque/Financeiro/  ║
-- ║  Devoluções/Torres em um NOC único: KPIs consolidados, score operacional  ║
-- ║  por área, sala de crise (incidentes) e IA de recomendação/predição.      ║
-- ║  Reusa alerts/logistics_events e os motores detect_* das torres.          ║
-- ║  Recurso RBAC 'controltower'.                                             ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.incident_status as enum ('open','investigating','mitigating','resolved','closed');

-- ── OPERATIONAL_SCORES (nota 0-100 por área) ────────────────────────────────
create table public.operational_scores (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  area text not null, score numeric(5,2) not null default 0, details jsonb not null default '{}'::jsonb,
  computed_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_operational_scores_area on public.operational_scores (company_id, area) where deleted_at is null;

-- ── INCIDENTS (sala de crise) ───────────────────────────────────────────────
create table public.incidents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, category text, severity public.event_severity not null default 'warning',
  status public.incident_status not null default 'open', title text not null, description text,
  affected_orders integer, affected_customers integer, financial_risk numeric(18,2),
  action_plan text, owner_id uuid references auth.users(id),
  opened_at timestamptz not null default now(), resolved_at timestamptz, timeline jsonb not null default '[]'::jsonb,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_incidents_status on public.incidents (company_id, status) where deleted_at is null;

-- ── RPC: Centro de Comando (NOC) — KPIs consolidados de toda a operação ─────
create or replace function public.lct_command_center(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'orders_open',     (select count(*) from public.outbound_orders where company_id=p_company and status not in ('delivered','canceled') and deleted_at is null),
    'orders_shipped_today', (select count(*) from public.outbound_orders where company_id=p_company and shipped_at::date=now()::date and deleted_at is null),
    'awaiting_post',   (select count(*) from public.dispatches where company_id=p_company and posted_at is null and stage not in ('canceled','returned') and deleted_at is null),
    'no_movement',     (select count(*) from public.dispatches where company_id=p_company and posted_at is not null and first_movement_at is null and deleted_at is null)
                     + (select count(*) from public.postal_objects where company_id=p_company and posted_at is not null and last_event_at is null and deleted_at is null),
    'in_transit',      (select count(*) from public.shipments where company_id=p_company and status in ('dispatched','in_transit') and deleted_at is null),
    'delivered_today', (select count(*) from public.shipments where company_id=p_company and delivered_at::date=now()::date and deleted_at is null),
    'delayed',         (select count(*) from public.shipments where company_id=p_company and estimated_delivery<now()::date and status not in ('delivered','returned','canceled') and deleted_at is null),
    'high_risk',       (select count(*) from public.shipments where company_id=p_company and risk_score>=60 and status in ('dispatched','in_transit') and deleted_at is null),
    'returns_open',    (select count(*) from public.rma_requests where company_id=p_company and status not in ('closed','canceled') and deleted_at is null),
    'value_in_transit',(select coalesce(sum(cargo_value),0) from public.shipments where company_id=p_company and status in ('dispatched','in_transit') and deleted_at is null),
    'below_reorder',   (select count(*) from public.reorder_suggestions where company_id=p_company and status='open' and deleted_at is null),
    'ap_overdue',      (select coalesce(sum(amount-paid_amount),0) from public.payables where company_id=p_company and status not in ('paid','canceled') and due_date<current_date and deleted_at is null),
    'alerts_open',     (select count(*) from public.alerts where company_id=p_company and status='open' and deleted_at is null),
    'incidents_open',  (select count(*) from public.incidents where company_id=p_company and status not in ('resolved','closed') and deleted_at is null),
    'insights_new',    (select count(*) from public.logia_insights where company_id=p_company and status='new' and deleted_at is null),
    'freight_divergences',(select coalesce(sum(difference),0) from public.freight_divergences where company_id=p_company and status='open' and deleted_at is null),
    'generated_at', now()
  ) else '{}'::jsonb end;
$$;
grant execute on function public.lct_command_center(uuid) to authenticated;

-- ── RPC: calcula score operacional (0-100) por área ─────────────────────────
create or replace function public.compute_operational_scores(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_score numeric; v_a text; v_val numeric; v_tot numeric;
begin
  if not app.has_permission('controltower.update', p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;

  -- Expedição: % de pedidos embarcados no prazo (ou sem atraso)
  select count(*) filter (where status='delivered' or shipped_at is not null), count(*)
    into v_val, v_tot from public.outbound_orders where company_id=p_company and deleted_at is null;
  perform 1; -- placeholder
  v_score := case when coalesce(v_tot,0)=0 then 100 else round(100.0*coalesce(v_val,0)/v_tot,1) end;
  perform public._upsert_score(v_tenant, p_company, 'Expedição', v_score);

  -- Transporte: OTIF
  select round(100.0 * count(*) filter (where delivered_at::date <= estimated_delivery) / nullif(count(*) filter (where status='delivered' and estimated_delivery is not null),0),1)
    into v_score from public.shipments where company_id=p_company and deleted_at is null;
  perform public._upsert_score(v_tenant, p_company, 'Transporte', coalesce(v_score,100));

  -- Correios: 100 − proporção de divergências/objetos
  select 100 - least(50, coalesce(count(*) filter (where status='open'),0)*5) into v_score
    from public.freight_divergences where company_id=p_company and deleted_at is null;
  perform public._upsert_score(v_tenant, p_company, 'Correios', coalesce(v_score,100));

  -- Estoque: 100 − itens abaixo do ponto de pedido (penalidade)
  select 100 - least(60, coalesce(count(*),0)*3) into v_score
    from public.reorder_suggestions where company_id=p_company and status='open' and deleted_at is null;
  perform public._upsert_score(v_tenant, p_company, 'Estoque', coalesce(v_score,100));

  -- Financeiro: % de títulos a receber em dia
  select round(100.0 * count(*) filter (where due_date >= current_date or status='paid') / nullif(count(*),0),1)
    into v_score from public.receivables where company_id=p_company and deleted_at is null;
  perform public._upsert_score(v_tenant, p_company, 'Financeiro', coalesce(v_score,100));

  return 5;
end;
$$;
grant execute on function public.compute_operational_scores(uuid) to authenticated;

-- helper de upsert de score (interno)
create or replace function public._upsert_score(p_tenant uuid, p_company uuid, p_area text, p_score numeric)
returns void language sql security definer set search_path = public, app as $$
  insert into public.operational_scores (tenant_id, company_id, area, score, computed_at)
  values (p_tenant, p_company, p_area, p_score, now())
  on conflict (company_id, area) where deleted_at is null
  do update set score = excluded.score, computed_at = now();
$$;

-- ── RPC: varredura da torre — roda os motores + abre sala de crise se crítico ─
create or replace function public.lct_scan(p_company uuid)
returns jsonb
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_disp int; v_trans int; v_stopped int; v_inc uuid;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;

  v_disp  := public.detect_dispatch_issues(p_company);
  v_trans := public.detect_transport_issues(p_company);
  perform public.compute_operational_scores(p_company);

  -- objetos/embarques parados (crítico) → abre incidente se ainda não houver aberto
  select (select count(*) from public.transport_occurrences where company_id=p_company and occurrence_type='stopped' and status<>'resolved' and deleted_at is null)
       + (select count(*) from public.dispatch_issues where company_id=p_company and issue_type='no_first_movement' and status='open' and deleted_at is null)
    into v_stopped;

  if v_stopped >= 5 and not exists (select 1 from public.incidents where company_id=p_company and category='stopped_objects' and status not in ('resolved','closed') and deleted_at is null) then
    insert into public.incidents (tenant_id, company_id, code, category, severity, status, title, description, affected_orders, action_plan)
    values (v_tenant, p_company, 'INC-'||to_char(now(),'YYYYMMDDHH24MISS'), 'stopped_objects', 'critical', 'open',
      'Sala de crise: '||v_stopped||' objetos parados', 'Vários objetos/embarques sem movimentação — possível falha de transportadora/Correios.',
      v_stopped, 'Acionar transportadoras, redistribuir carga e priorizar os pedidos afetados.')
    returning id into v_inc;
  end if;

  return jsonb_build_object('dispatch_issues', v_disp, 'transport_issues', v_trans, 'stopped', v_stopped, 'incident_opened', v_inc is not null);
end;
$$;
grant execute on function public.lct_scan(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela ────────────────────────────
do $do$
declare t text; specs text[] := array['operational_scores','incidents'];
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
