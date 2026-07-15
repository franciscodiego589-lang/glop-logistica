-- ============================================================================
-- VOLUME 37 · YMS ENTERPRISE+ (migration 069)
-- Complementa o YMS existente (docks/dock_appointments/gate_events/yard_visits/
-- yard_zones/weighings/containers/seals — migrations 005+040) com a profundidade
-- de nível Manhattan/SAP Yard: PORTARIAS tipadas, VAGAS/POSIÇÕES do pátio, FILA
-- virtual com prioridade, LOG de movimentações, CREDENCIAIS de acesso
-- (QR/RFID/tag/PIN/biometria), VISITANTES/prestadores, SLA por fase e MAPA
-- operacional. Reusa o recurso RBAC 'yms'. Escopo 100% logística.
-- Padrão: colunas-padrão completas, text+check (sem cast de enum), grant por-tabela.
-- ============================================================================

-- ── 1) PORTARIAS (gates) ─────────────────────────────────────────────────────
create table if not exists public.gates (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  code text not null,
  name text,
  gate_type text not null default 'main' check (gate_type in ('main','entry','exit','pedestrian','visitor','contractor','emergency')),
  status text not null default 'open' check (status in ('open','closed','blocked')),
  lanes integer not null default 1,
  supports_lpr boolean not null default false,
  notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 2) VAGAS / POSIÇÕES do pátio (yard_slots) ────────────────────────────────
create table if not exists public.yard_slots (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  yard_zone_id uuid references public.yard_zones(id) on delete cascade,
  warehouse_id uuid references public.warehouses(id) on delete set null,
  code text not null,
  row_label text,                 -- corredor
  position integer,               -- posição na fileira
  slot_type text not null default 'truck' check (slot_type in ('truck','trailer','container','support','parking')),
  direction text,                 -- sentido de circulação
  status text not null default 'free' check (status in ('free','occupied','blocked','reserved')),
  current_visit_id uuid references public.yard_visits(id) on delete set null,
  blocked_reason text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- liga a visita à vaga ocupada (ciclo resolvido: ambas nullable)
alter table public.yard_visits add column if not exists slot_id uuid references public.yard_slots(id) on delete set null;
alter table public.yard_visits add column if not exists queue_priority integer;

-- ── 3) FILA virtual/física (yard_queue) ──────────────────────────────────────
create table if not exists public.yard_queue (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  yard_visit_id uuid not null references public.yard_visits(id) on delete cascade,
  dock_id uuid references public.docks(id) on delete set null,
  queue_type text not null default 'virtual' check (queue_type in ('virtual','physical')),
  priority integer not null default 0,          -- maior = mais prioritário
  position integer,
  reason text,                                  -- ex.: emergência, agendamento
  status text not null default 'waiting' check (status in ('waiting','called','serving','done','left')),
  enqueued_at timestamptz not null default now(),
  called_at timestamptz,
  served_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 4) LOG de movimentações (yard_movements) ─────────────────────────────────
create table if not exists public.yard_movements (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  yard_visit_id uuid not null references public.yard_visits(id) on delete cascade,
  movement_type text not null default 'reposition' check (movement_type in ('gate_in','park','reposition','dock_change','yard_change','dock_in','dock_out','gate_out')),
  from_slot_id uuid references public.yard_slots(id) on delete set null,
  to_slot_id uuid references public.yard_slots(id) on delete set null,
  dock_id uuid references public.docks(id) on delete set null,
  from_ref text, to_ref text,
  occurred_at timestamptz not null default now(),
  duration_min numeric(10,2),
  operator_id uuid references auth.users(id),
  notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 5) CREDENCIAIS de acesso (access_credentials) ────────────────────────────
create table if not exists public.access_credentials (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  credential_type text not null default 'qr' check (credential_type in ('qr','barcode','rfid','vehicle_tag','biometric','badge','pin')),
  code text not null,
  subject_type text not null default 'driver' check (subject_type in ('driver','vehicle','visitor','contractor','employee')),
  subject_ref text,
  subject_id uuid,
  valid_from date not null default now()::date,
  valid_to date,
  status text not null default 'active' check (status in ('active','revoked','expired')),
  last_used_at timestamptz,
  notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 6) VISITANTES / prestadores (yard_visitors) ──────────────────────────────
create table if not exists public.yard_visitors (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  gate_id uuid references public.gates(id) on delete set null,
  name text not null,
  document text,
  visitor_type text not null default 'visitor' check (visitor_type in ('visitor','contractor','service')),
  company_name text,
  host_name text,
  purpose text,
  badge_number text,
  vehicle_plate text,
  check_in_at timestamptz not null default now(),
  check_out_at timestamptz,
  status text not null default 'inside' check (status in ('inside','left')),
  photos jsonb not null default '[]'::jsonb,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- índices auxiliares (toda FK indexada)
create index if not exists idx_gates_wh on public.gates (warehouse_id);
create index if not exists idx_yslots_zone on public.yard_slots (yard_zone_id);
create index if not exists idx_yslots_status on public.yard_slots (company_id, status);
create index if not exists idx_yqueue_visit on public.yard_queue (yard_visit_id);
create index if not exists idx_yqueue_status on public.yard_queue (company_id, status);
create index if not exists idx_ymov_visit on public.yard_movements (yard_visit_id);
create index if not exists idx_cred_code on public.access_credentials (company_id, code);
create index if not exists idx_visitor_status on public.yard_visitors (company_id, status);
create index if not exists idx_yvisits_slot on public.yard_visits (slot_id);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'yms') ────────────
do $do$
declare t text; specs text[] := array['gates','yard_slots','yard_queue','yard_movements','access_credentials','yard_visitors'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'yms.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'yms.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- Enfileira uma visita (fila virtual/física) com prioridade
create or replace function public.yard_enqueue(p_company uuid, p_visit uuid, p_queue_type text default 'virtual', p_priority integer default 0, p_reason text default null, p_dock uuid default null)
returns public.yard_queue language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_pos int; r public.yard_queue;
begin
  if not (app.can_access_company(p_company) and app.has_permission('yms.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select coalesce(max(position),0)+1 into v_pos from public.yard_queue where company_id=p_company and status='waiting' and deleted_at is null;
  insert into public.yard_queue (tenant_id, company_id, yard_visit_id, dock_id, queue_type, priority, position, reason)
    values (v_tenant, p_company, p_visit, p_dock, coalesce(p_queue_type,'virtual'), coalesce(p_priority,0), v_pos, p_reason)
    returning * into r;
  update public.yard_visits set queue_priority = coalesce(p_priority,0) where id=p_visit and company_id=p_company;
  return r;
end; $$;
grant execute on function public.yard_enqueue(uuid,uuid,text,integer,text,uuid) to authenticated;

-- Chama o próximo da fila (maior prioridade, depois ordem de chegada)
create or replace function public.yard_call_next(p_company uuid, p_dock uuid default null)
returns public.yard_queue language plpgsql security definer set search_path = public, app as $$
declare r public.yard_queue;
begin
  if not (app.can_access_company(p_company) and app.has_permission('yms.update', p_company)) then raise exception 'forbidden'; end if;
  select * into r from public.yard_queue
    where company_id=p_company and status='waiting' and deleted_at is null
    order by priority desc, enqueued_at asc limit 1;
  if r.id is null then return null; end if;
  update public.yard_queue set status='called', called_at=now(), dock_id=coalesce(p_dock, dock_id) where id=r.id returning * into r;
  return r;
end; $$;
grant execute on function public.yard_call_next(uuid,uuid) to authenticated;

-- Aloca uma vaga do pátio à visita (libera a anterior, registra movimento)
create or replace function public.yard_assign_slot(p_company uuid, p_visit uuid, p_slot uuid, p_movement text default 'park')
returns public.yard_slots language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_prev uuid; r public.yard_slots;
begin
  if not (app.can_access_company(p_company) and app.has_permission('yms.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select slot_id into v_prev from public.yard_visits where id=p_visit and company_id=p_company;
  if v_prev is not null and v_prev <> p_slot then
    update public.yard_slots set status='free', current_visit_id=null where id=v_prev and company_id=p_company;
  end if;
  update public.yard_slots set status='occupied', current_visit_id=p_visit where id=p_slot and company_id=p_company and status in ('free','reserved') returning * into r;
  if r.id is null then raise exception 'Vaga indisponível'; end if;
  update public.yard_visits set slot_id=p_slot where id=p_visit and company_id=p_company;
  insert into public.yard_movements (tenant_id, company_id, yard_visit_id, movement_type, from_slot_id, to_slot_id, operator_id)
    values (v_tenant, p_company, p_visit, case when v_prev is not null and v_prev<>p_slot then 'reposition' else coalesce(p_movement,'park') end, v_prev, p_slot, auth.uid());
  return r;
end; $$;
grant execute on function public.yard_assign_slot(uuid,uuid,uuid,text) to authenticated;

-- Registra uma movimentação genérica (troca de doca/pátio/saída) com duração desde o último evento
create or replace function public.yard_move(p_company uuid, p_visit uuid, p_movement text, p_dock uuid default null, p_notes text default null)
returns public.yard_movements language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_last timestamptz; v_dur numeric; r public.yard_movements;
begin
  if not (app.can_access_company(p_company) and app.has_permission('yms.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select max(occurred_at) into v_last from public.yard_movements where yard_visit_id=p_visit and company_id=p_company and deleted_at is null;
  v_dur := case when v_last is not null then round((extract(epoch from (now()-v_last))/60.0)::numeric, 2) else null end;
  insert into public.yard_movements (tenant_id, company_id, yard_visit_id, movement_type, dock_id, duration_min, operator_id, notes)
    values (v_tenant, p_company, p_visit, p_movement, p_dock, v_dur, auth.uid(), p_notes) returning * into r;
  -- efeitos colaterais mínimos e seguros
  if p_movement='gate_out' then
    update public.yard_visits set status='departed', gate_out_at=now() where id=p_visit and company_id=p_company;
    update public.yard_slots set status='free', current_visit_id=null where current_visit_id=p_visit and company_id=p_company;
    update public.yard_queue set status='done', served_at=now() where yard_visit_id=p_visit and company_id=p_company and status in ('waiting','called','serving');
  elsif p_movement='dock_in' and p_dock is not null then
    update public.yard_visits set status='at_dock', dock_id=p_dock, dock_in_at=coalesce(dock_in_at, now()) where id=p_visit and company_id=p_company;
    update public.yard_queue set status='serving' where yard_visit_id=p_visit and company_id=p_company and status='called';
  end if;
  return r;
end; $$;
grant execute on function public.yard_move(uuid,uuid,text,uuid,text) to authenticated;

-- Registra e valida uma credencial de acesso
create or replace function public.register_credential(p_company uuid, p_type text, p_code text, p_subject_type text, p_subject_ref text, p_valid_to date default null)
returns public.access_credentials language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.access_credentials;
begin
  if not (app.can_access_company(p_company) and app.has_permission('yms.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.access_credentials (tenant_id, company_id, credential_type, code, subject_type, subject_ref, valid_to)
    values (v_tenant, p_company, coalesce(p_type,'qr'), p_code, coalesce(p_subject_type,'driver'), p_subject_ref, p_valid_to) returning * into r;
  return r;
end; $$;
grant execute on function public.register_credential(uuid,text,text,text,text,date) to authenticated;

create or replace function public.use_credential(p_company uuid, p_code text)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare r public.access_credentials;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select * into r from public.access_credentials where company_id=p_company and code=p_code and deleted_at is null order by created_at desc limit 1;
  if r.id is null then return jsonb_build_object('ok', false, 'reason', 'credencial inexistente'); end if;
  if r.status <> 'active' then return jsonb_build_object('ok', false, 'reason', 'credencial '||r.status); end if;
  if r.valid_to is not null and r.valid_to < now()::date then
    update public.access_credentials set status='expired' where id=r.id;
    return jsonb_build_object('ok', false, 'reason', 'credencial expirada');
  end if;
  update public.access_credentials set last_used_at=now() where id=r.id;
  return jsonb_build_object('ok', true, 'subject_type', r.subject_type, 'subject_ref', r.subject_ref, 'credential_type', r.credential_type);
end; $$;
grant execute on function public.use_credential(uuid,text) to authenticated;

-- Mapa operacional (para a tela de mapa interativo)
create or replace function public.yard_map(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'gates', (select coalesce(jsonb_agg(jsonb_build_object('id',id,'code',code,'name',name,'gate_type',gate_type,'status',status) order by gate_type), '[]'::jsonb)
              from public.gates where company_id=p_company and deleted_at is null),
    'zones', (select coalesce(jsonb_agg(jsonb_build_object(
                'id', z.id, 'code', z.code, 'name', z.name, 'capacity', z.capacity,
                'slots', (select coalesce(jsonb_agg(jsonb_build_object('id',s.id,'code',s.code,'status',s.status,'slot_type',s.slot_type,'plate',
                            (select vv.vehicle_plate from public.yard_visits vv where vv.id=s.current_visit_id)) order by s.position), '[]'::jsonb)
                          from public.yard_slots s where s.yard_zone_id=z.id and s.deleted_at is null)), '[]'::jsonb)
              from public.yard_zones z where z.company_id=p_company and z.deleted_at is null),
    'docks', (select coalesce(jsonb_agg(jsonb_build_object('id',id,'code',code,'status',status,'dock_type',dock_type) order by code), '[]'::jsonb)
              from public.docks where company_id=p_company and deleted_at is null),
    'in_yard', (select count(*) from public.yard_visits v where v.company_id=p_company and v.deleted_at is null and coalesce(v.status::text,'') not in ('departed') and v.gate_in_at is not null and v.gate_out_at is null),
    'queue_waiting', (select count(*) from public.yard_queue q where q.company_id=p_company and q.status='waiting' and q.deleted_at is null),
    'visitors_inside', (select count(*) from public.yard_visitors vi where vi.company_id=p_company and vi.status='inside' and vi.deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.yard_map(uuid) to authenticated;

-- SLA por fase (portaria→pátio→doca→saída) e por transportadora
create or replace function public.yard_sla(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'avg_gate_to_dock_min', (select round(avg(extract(epoch from (dock_in_at - gate_in_at))/60.0)::numeric,1) from public.yard_visits where company_id=p_company and gate_in_at is not null and dock_in_at is not null and deleted_at is null),
    'avg_dock_to_out_min',  (select round(avg(extract(epoch from (gate_out_at - dock_in_at))/60.0)::numeric,1) from public.yard_visits where company_id=p_company and dock_in_at is not null and gate_out_at is not null and deleted_at is null),
    'avg_total_min',        (select round(avg(extract(epoch from (gate_out_at - gate_in_at))/60.0)::numeric,1) from public.yard_visits where company_id=p_company and gate_in_at is not null and gate_out_at is not null and deleted_at is null),
    'completed_visits',     (select count(*) from public.yard_visits where company_id=p_company and gate_out_at is not null and deleted_at is null),
    'by_carrier', (select coalesce(jsonb_agg(x), '[]'::jsonb) from (
        select c.name as carrier, count(*) as visits,
               round(avg(extract(epoch from (v.gate_out_at - v.gate_in_at))/60.0)::numeric,1) as avg_total_min
        from public.yard_visits v join public.carriers c on c.id=v.carrier_id
        where v.company_id=p_company and v.gate_in_at is not null and v.gate_out_at is not null and v.deleted_at is null
        group by c.name order by avg(extract(epoch from (v.gate_out_at - v.gate_in_at))) desc limit 10) x)
  ) into v;
  return v;
end; $$;
grant execute on function public.yard_sla(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.yms2_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_over int; v_q int; v_block int; v_cont int; v_cred int; v_vis int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'YMS+%' and deleted_at is null;

  -- permanência excedida (>6h no pátio sem sair)
  select count(*) into v_over from public.yard_visits where company_id=p_company and gate_in_at is not null and gate_out_at is null and gate_in_at < now() - interval '6 hours' and deleted_at is null;
  if v_over > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'YMS+: permanência excedida no pátio', v_over||' veículo(s) há mais de 6h sem sair.', 'Priorizar liberação ou investigar retenção.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_q from public.yard_queue where company_id=p_company and status='waiting' and deleted_at is null;
  if v_q >= 5 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'YMS+: fila excessiva', v_q||' veículo(s) aguardando na fila.', 'Abrir doca adicional ou reordenar por prioridade.', 80);
    v_c := v_c + 1;
  end if;
  select count(*) into v_block from public.docks where company_id=p_company and status='blocked' and deleted_at is null;
  if v_block > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'YMS+: docas bloqueadas', v_block||' doca(s) bloqueada(s).', 'Liberar a doca para não estrangular a operação.', 78);
    v_c := v_c + 1;
  end if;
  select count(*) into v_cont from public.containers where company_id=p_company and status='in_yard' and created_at < now() - interval '48 hours' and deleted_at is null;
  if v_cont > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'YMS+: containers parados', v_cont||' container(es) no pátio há mais de 48h.', 'Programar movimentação/expedição.', 72);
    v_c := v_c + 1;
  end if;
  select count(*) into v_cred from public.access_credentials where company_id=p_company and status='active' and valid_to is not null and valid_to < now()::date and deleted_at is null;
  if v_cred > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'fraud_risk', 'warning', 'YMS+: credenciais expiradas ativas', v_cred||' credencial(is) vencida(s) ainda ativa(s).', 'Revogar credenciais expiradas (risco de acesso indevido).', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_vis from public.yard_visitors where company_id=p_company and status='inside' and check_in_at < now() - interval '12 hours' and deleted_at is null;
  if v_vis > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'info', 'YMS+: visitantes sem check-out', v_vis||' visitante(s) na área há mais de 12h.', 'Confirmar saída ou regularizar o registro de portaria.', 70);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.yms2_insights(uuid) to authenticated;

-- ── SEED (empresa Matriz Logística) ─────────────────────────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid; v_zone uuid; i int;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;

  if not exists (select 1 from public.gates where company_id=v_company and deleted_at is null) then
    insert into public.gates (tenant_id, company_id, code, name, gate_type, lanes, supports_lpr) values
      (v_tenant, v_company, 'P-PRIN', 'Portaria Principal', 'main', 2, true),
      (v_tenant, v_company, 'P-ENT', 'Portaria de Entrada', 'entry', 2, true),
      (v_tenant, v_company, 'P-SAI', 'Portaria de Saída', 'exit', 1, true),
      (v_tenant, v_company, 'P-VIS', 'Portaria de Visitantes', 'visitor', 1, false),
      (v_tenant, v_company, 'P-EME', 'Portaria de Emergência', 'emergency', 1, false);
  end if;

  -- garante uma zona de pátio e gera vagas
  select id into v_zone from public.yard_zones where company_id=v_company and deleted_at is null order by created_at limit 1;
  if v_zone is null then
    insert into public.yard_zones (tenant_id, company_id, code, name, capacity) values (v_tenant, v_company, 'PATIO-A', 'Pátio A', 20) returning id into v_zone;
  end if;
  if not exists (select 1 from public.yard_slots where company_id=v_company and deleted_at is null) then
    for i in 1..12 loop
      insert into public.yard_slots (tenant_id, company_id, yard_zone_id, code, row_label, position, slot_type, direction, status)
      values (v_tenant, v_company, v_zone, 'A-'||lpad(i::text,2,'0'), 'Corredor A', i, case when i%4=0 then 'container' else 'truck' end, 'norte-sul',
              case when i in (3,7) then 'occupied' when i=10 then 'blocked' else 'free' end);
    end loop;
    update public.yard_slots set blocked_reason='Manutenção de piso' where company_id=v_company and status='blocked';
  end if;

  if not exists (select 1 from public.access_credentials where company_id=v_company and deleted_at is null) then
    insert into public.access_credentials (tenant_id, company_id, credential_type, code, subject_type, subject_ref, valid_to, status) values
      (v_tenant, v_company, 'vehicle_tag', 'TAG-9A21', 'vehicle', 'Placa ABC1D23', (now()::date + interval '1 year')::date, 'active'),
      (v_tenant, v_company, 'rfid', 'RFID-0077', 'driver', 'João Motorista', (now()::date - interval '3 days')::date, 'active'); -- expirada (dispara insight)
  end if;

  if not exists (select 1 from public.yard_visitors where company_id=v_company and deleted_at is null) then
    insert into public.yard_visitors (tenant_id, company_id, gate_id, name, document, visitor_type, company_name, host_name, purpose, badge_number, status)
    select v_tenant, v_company, (select id from public.gates where company_id=v_company and gate_type='visitor' limit 1),
           'Carlos Prestador', '123.456.789-00', 'contractor', 'ManutençãoTech', 'Supervisor Pátio', 'Manutenção de balança', 'V-001', 'inside';
  end if;
end $seed$;

notify pgrst, 'reload schema';
