-- ============================================================================
-- VOLUME 47 · GLCT — GLOBAL LOGISTICS CONTROL TOWER (migration 081)
-- Torre mundial de controle: painel situacional CONSOLIDADO cross-módulo,
-- motor de correlação de eventos (sobre logia_insights que já agrega todos os
-- *_insights), incidentes logísticos com playbooks e orquestração de ações.
-- Complementa o ECC (command_alerts/crisis_rooms) sem duplicar. Nível DHL/
-- project44/FourKites. Recurso 'controltower'. Escopo 100% logística.
-- Padrão: colunas-padrão, text+check, grant por-tabela.
-- ============================================================================

-- ── 1) PLAYBOOKS operacionais ────────────────────────────────────────────────
create table if not exists public.glct_playbooks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  name text,
  playbook_type text not null default 'generic' check (playbook_type in ('accident','theft','breakdown','strike','roadblock','port_closure','airport_closure','driver_shortage','weather','cold_chain_break','rupture','congestion','generic')),
  steps jsonb not null default '[]'::jsonb,
  escalation_to text,
  sla_minutes integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 2) INCIDENTES logísticos ─────────────────────────────────────────────────
create table if not exists public.glct_incidents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  title text,
  incident_type text not null default 'delay' check (incident_type in ('delay','rupture','congestion','accident','route_deviation','equipment_failure','stoppage','weather','strike','roadblock','theft','comm_loss','sensor_fail','cold_chain_break')),
  severity text not null default 'sev3' check (severity in ('sev1','sev2','sev3','sev4')),
  status text not null default 'open' check (status in ('open','investigating','mitigating','resolved')),
  source_module text,
  affected_ref text,
  owner text,
  playbook_id uuid references public.glct_playbooks(id) on delete set null,
  correlation_key text,
  root_cause text,
  opened_at timestamptz not null default now(),
  resolved_at timestamptz,
  mttr_min numeric(10,1),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 3) AÇÕES de orquestração ─────────────────────────────────────────────────
create table if not exists public.glct_actions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  incident_id uuid references public.glct_incidents(id) on delete cascade,
  action_type text not null default 'notify' check (action_type in ('redistribute','swap_carrier','swap_vehicle','reroute','swap_dock','swap_dc','trigger_contingency','create_plan','notify','escalate')),
  description text,
  target_ref text,
  status text not null default 'planned' check (status in ('planned','executed','canceled')),
  executed_at timestamptz,
  executed_by uuid references auth.users(id),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 4) EVENTOS correlacionados (clusters) ────────────────────────────────────
create table if not exists public.glct_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  source_module text,
  event_kind text,
  severity text,
  title text,
  correlation_key text,
  cluster_size integer not null default 1,
  occurred_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_glct_inc_status on public.glct_incidents (company_id, status);
create index if not exists idx_glct_act_inc on public.glct_actions (incident_id);
create index if not exists idx_glct_evt_key on public.glct_events (company_id, correlation_key);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'controltower') ────
do $do$
declare t text; specs text[] := array['glct_playbooks','glct_incidents','glct_actions','glct_events'];
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

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- PAINEL SITUACIONAL CONSOLIDADO: estado vivo de TODA a cadeia logística
create or replace function public.glct_situational(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'deliveries_pending', (select count(*) from public.deliveries where company_id=p_company and status='pending' and deleted_at is null),
    'deliveries_failed', (select count(*) from public.deliveries where company_id=p_company and status='failed' and deleted_at is null),
    'volumes_in_transit', (select count(*) from public.volumes where company_id=p_company and status='shipped' and deleted_at is null),
    'intl_delayed', (select count(*) from public.intl_shipments where company_id=p_company and eta is not null and eta < now() and status not in ('delivered','released','discharged','canceled') and deleted_at is null),
    'customs_retained', (select count(*) from public.customs_processes where company_id=p_company and status='retained' and deleted_at is null),
    'cold_broken', (select count(*) from public.cold_shipments where company_id=p_company and integrity_status='broken' and deleted_at is null),
    'yard_queue', (select count(*) from public.yard_queue where company_id=p_company and status='waiting' and deleted_at is null),
    'docks_blocked', (select count(*) from public.docks where company_id=p_company and status='blocked' and deleted_at is null),
    'twin_bottlenecks', (select count(*) from public.twin_bottlenecks where company_id=p_company and status='open' and deleted_at is null),
    'carrier_occurrences', (select count(*) from public.carrier_occurrences where company_id=p_company and status in ('open','investigating') and deleted_at is null),
    'incidents_open', (select count(*) from public.glct_incidents where company_id=p_company and status<>'resolved' and deleted_at is null),
    'crises_active', (select count(*) from public.crisis_rooms where company_id=p_company and coalesce(status::text,'')<>'closed' and deleted_at is null),
    'insights_critical', (select count(*) from public.logia_insights where company_id=p_company and severity='critical' and status='new' and deleted_at is null),
    'insights_warning', (select count(*) from public.logia_insights where company_id=p_company and severity='warning' and status='new' and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.glct_situational(uuid) to authenticated;

-- MOTOR DE CORRELAÇÃO: agrupa os insights (fonte unificada) em clusters + abre incidente p/ críticos
create or replace function public.correlate_events(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_n int := 0; rec record; v_seq int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  -- limpa clusters anteriores (recomputados)
  update public.glct_events set deleted_at=now() where company_id=p_company and deleted_at is null;

  for rec in
    select kind, severity, count(*) n, min(created_at) first_at, max(title) sample
    from public.logia_insights where company_id=p_company and status='new' and deleted_at is null
    group by kind, severity
  loop
    insert into public.glct_events (tenant_id, company_id, source_module, event_kind, severity, title, correlation_key, cluster_size, occurred_at)
    values (v_tenant, p_company, 'logia', rec.kind, rec.severity, rec.sample, rec.kind||':'||rec.severity, rec.n, rec.first_at);
    v_n := v_n + 1;
    -- cluster crítico -> abre incidente (idempotente por correlation_key aberto)
    if rec.severity = 'critical' and not exists (
        select 1 from public.glct_incidents where company_id=p_company and correlation_key=rec.kind||':'||rec.severity and status<>'resolved' and deleted_at is null) then
      select coalesce(count(*),0)+1 into v_seq from public.glct_incidents where company_id=p_company;
      insert into public.glct_incidents (tenant_id, company_id, code, title, incident_type, severity, source_module, correlation_key)
      values (v_tenant, p_company, 'INC-'||lpad(v_seq::text,4,'0'), rec.sample,
        case rec.kind when 'fraud_risk' then 'theft' when 'quality_deviation' then 'equipment_failure' else 'congestion' end,
        'sev2', 'logia', rec.kind||':'||rec.severity);
    end if;
  end loop;
  return v_n;
end; $$;
grant execute on function public.correlate_events(uuid) to authenticated;

create or replace function public.open_incident(p_company uuid, p_title text, p_type text, p_severity text, p_module text default null, p_ref text default null)
returns public.glct_incidents language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.glct_incidents; v_seq int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select coalesce(count(*),0)+1 into v_seq from public.glct_incidents where company_id=p_company;
  insert into public.glct_incidents (tenant_id, company_id, code, title, incident_type, severity, source_module, affected_ref, status)
    values (v_tenant, p_company, 'INC-'||lpad(v_seq::text,4,'0'), p_title, coalesce(p_type,'delay'), coalesce(p_severity,'sev3'), p_module, p_ref, 'open') returning * into r;
  return r;
end; $$;
grant execute on function public.open_incident(uuid,text,text,text,text,text) to authenticated;

-- Aplica um playbook: copia os passos como ações planejadas + entra em mitigação
create or replace function public.apply_playbook(p_company uuid, p_incident uuid, p_playbook uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_n int := 0; step jsonb;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.glct_incidents set playbook_id=p_playbook, status='mitigating' where id=p_incident and company_id=p_company;
  for step in select * from jsonb_array_elements((select steps from public.glct_playbooks where id=p_playbook and company_id=p_company))
  loop
    insert into public.glct_actions (tenant_id, company_id, incident_id, action_type, description)
    values (v_tenant, p_company, p_incident, coalesce(step->>'action_type','notify'), coalesce(step->>'step', step::text));
    v_n := v_n + 1;
  end loop;
  return v_n;
end; $$;
grant execute on function public.apply_playbook(uuid,uuid,uuid) to authenticated;

create or replace function public.resolve_incident(p_company uuid, p_incident uuid, p_root_cause text default null)
returns public.glct_incidents language plpgsql security definer set search_path = public, app as $$
declare r public.glct_incidents;
begin
  if not (app.can_access_company(p_company) and app.has_permission('controltower.update', p_company)) then raise exception 'forbidden'; end if;
  update public.glct_incidents set status='resolved', resolved_at=now(), root_cause=p_root_cause,
    mttr_min = round((extract(epoch from (now()-opened_at))/60.0)::numeric,1)
    where id=p_incident and company_id=p_company returning * into r;
  if r.id is null then raise exception 'Incidente não encontrado'; end if;
  return r;
end; $$;
grant execute on function public.resolve_incident(uuid,uuid,text) to authenticated;

create or replace function public.glct_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'incidents_open', (select count(*) from public.glct_incidents where company_id=p_company and status<>'resolved' and deleted_at is null),
    'sev1', (select count(*) from public.glct_incidents where company_id=p_company and severity='sev1' and status<>'resolved' and deleted_at is null),
    'sev2', (select count(*) from public.glct_incidents where company_id=p_company and severity='sev2' and status<>'resolved' and deleted_at is null),
    'resolved', (select count(*) from public.glct_incidents where company_id=p_company and status='resolved' and deleted_at is null),
    'avg_mttr_min', (select round(avg(mttr_min),1) from public.glct_incidents where company_id=p_company and mttr_min is not null and deleted_at is null),
    'actions_planned', (select count(*) from public.glct_actions where company_id=p_company and status='planned' and deleted_at is null),
    'playbooks', (select count(*) from public.glct_playbooks where company_id=p_company and deleted_at is null),
    'event_clusters', (select count(*) from public.glct_events where company_id=p_company and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.glct_dashboard(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.glct_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_sev int; v_nopb int; v_old int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'GLCT%' and deleted_at is null;

  select count(*) into v_sev from public.glct_incidents where company_id=p_company and severity in ('sev1','sev2') and status<>'resolved' and deleted_at is null;
  if v_sev > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'critical', 'GLCT: incidentes graves abertos', v_sev||' incidente(s) SEV1/SEV2 sem resolução.', 'Acionar playbook e sala de crise se necessário.', 90);
    v_c := v_c + 1;
  end if;
  select count(*) into v_nopb from public.glct_incidents where company_id=p_company and status<>'resolved' and playbook_id is null and deleted_at is null;
  if v_nopb > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'GLCT: incidentes sem playbook', v_nopb||' incidente(s) aberto(s) sem procedimento aplicado.', 'Aplicar um playbook operacional padronizado.', 78);
    v_c := v_c + 1;
  end if;
  select count(*) into v_old from public.glct_incidents where company_id=p_company and status<>'resolved' and opened_at < now()-interval '24 hours' and deleted_at is null;
  if v_old > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'GLCT: incidentes antigos abertos', v_old||' incidente(s) aberto(s) há mais de 24h.', 'Escalar; tempo elevado agrava o impacto operacional.', 80);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.glct_insights(uuid) to authenticated;

-- ── SEED (empresa Matriz Logística) — playbooks padrão ──────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;
  if not exists (select 1 from public.glct_playbooks where company_id=v_company and deleted_at is null) then
    insert into public.glct_playbooks (tenant_id, company_id, code, name, playbook_type, sla_minutes, escalation_to, steps) values
      (v_tenant, v_company, 'PB-ACID', 'Acidente com veículo', 'accident', 60, 'Gerência de Transporte',
        '[{"step":"Acionar socorro e isolar a via","action_type":"notify"},{"step":"Redistribuir a carga para outro veículo","action_type":"swap_vehicle"},{"step":"Reroteirizar entregas afetadas","action_type":"reroute"},{"step":"Comunicar clientes impactados","action_type":"notify"}]'::jsonb),
      (v_tenant, v_company, 'PB-GREVE', 'Greve / bloqueio rodoviário', 'strike', 120, 'Torre de Controle',
        '[{"step":"Mapear rotas bloqueadas","action_type":"notify"},{"step":"Trocar modal quando possível","action_type":"reroute"},{"step":"Acionar transportadora alternativa","action_type":"swap_carrier"},{"step":"Ativar contingência de estoque","action_type":"trigger_contingency"}]'::jsonb),
      (v_tenant, v_company, 'PB-FRIO', 'Quebra da cadeia fria', 'cold_chain_break', 30, 'Qualidade',
        '[{"step":"Segregar a carga afetada","action_type":"notify"},{"step":"Transferir para equipamento reserva","action_type":"swap_vehicle"},{"step":"Emitir laudo de conformidade","action_type":"create_plan"}]'::jsonb),
      (v_tenant, v_company, 'PB-ROUBO', 'Roubo de carga', 'theft', 30, 'Segurança',
        '[{"step":"Acionar seguradora e BO","action_type":"notify"},{"step":"Bloquear rastreamento e alertar rede","action_type":"escalate"},{"step":"Reprogramar reposição ao cliente","action_type":"create_plan"}]'::jsonb);
  end if;
end $seed$;

notify pgrst, 'reload schema';
