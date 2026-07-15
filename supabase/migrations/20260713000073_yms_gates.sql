-- ============================================================================
-- GLOP · VOLUME 37 — YARD MANAGEMENT SYSTEM (YMS) · Portarias, Pátio, Filas
-- migration 073 · Expande o YMS (Vol 12) controlando o lado de FORA do armazém:
-- portarias, check-in/out, credenciais de acesso, visitantes, vagas de pátio,
-- fila (virtual/física), containers e movimentações. 100% domínio logístico.
-- REUSA: docks, dock_appointments, yard_zones, carriers, logistics_orders.
-- Recurso RBAC 'yms'. NÃO redefine yms_insights/yard_dashboard (já existem) —
-- usa yard_ops_dashboard/yard_ops_insights. Padrão: text+check, grant por-tabela.
-- ============================================================================

-- ── PORTARIAS ────────────────────────────────────────────────────────────────
create table if not exists public.gates (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, name text not null,
  gate_type text not null default 'main' check (gate_type in ('main','entry','exit','pedestrian','visitor','contractor','emergency')),
  direction text not null default 'both' check (direction in ('in','out','both')),
  warehouse_id uuid references public.warehouses(id),
  status text not null default 'open' check (status in ('open','closed')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── CREDENCIAIS DE ACESSO (QR/RFID/tag/biometria/PIN) ────────────────────────
create table if not exists public.access_credentials (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  credential_type text not null default 'qr' check (credential_type in ('qr','barcode','rfid','vehicle_tag','lpr','biometry','badge','pin')),
  code text not null,
  holder_name text, holder_type text check (holder_type in ('driver','visitor','contractor','vehicle')),
  valid_from date, valid_to date,
  status text not null default 'active' check (status in ('active','revoked','expired')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── VISITANTES / PRESTADORES ─────────────────────────────────────────────────
create table if not exists public.yard_visitors (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, document text, company_name text,
  visitor_type text not null default 'visitor' check (visitor_type in ('visitor','contractor','service')),
  purpose text, host_name text,
  gate_id uuid references public.gates(id),
  check_in_at timestamptz default now(), check_out_at timestamptz,
  status text not null default 'inside' check (status in ('inside','left')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── VAGAS DO PÁTIO ───────────────────────────────────────────────────────────
create table if not exists public.yard_slots (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  zone_id uuid references public.yard_zones(id),
  code text not null,
  slot_type text not null default 'truck' check (slot_type in ('truck','trailer','container','light','support')),
  status text not null default 'free' check (status in ('free','occupied','blocked','reserved')),
  current_pass_id uuid,
  capacity integer not null default 1,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── CHECK-IN / PASSAGEM DE PORTARIA (entidade central) ───────────────────────
create table if not exists public.gate_passes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text,
  gate_id uuid references public.gates(id),
  carrier_id uuid references public.carriers(id),
  vehicle_plate text, trailer_plate text, container_number text,
  driver_name text, driver_document text, cnh text,
  credential_id uuid references public.access_credentials(id),
  order_id uuid references public.logistics_orders(id),
  slot_id uuid references public.yard_slots(id),
  cargo_description text, destination text,
  status text not null default 'in_yard' check (status in ('in_yard','at_dock','completed','canceled')),
  check_in_at timestamptz not null default now(), check_out_at timestamptz,
  photos jsonb not null default '[]'::jsonb,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── FILA (virtual/física) ────────────────────────────────────────────────────
create table if not exists public.yard_queue (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  gate_pass_id uuid references public.gate_passes(id) on delete cascade,
  vehicle_plate text,
  priority text not null default 'normal' check (priority in ('low','normal','high','emergency')),
  status text not null default 'waiting' check (status in ('waiting','called','at_dock','done')),
  position integer,
  dock_id uuid references public.docks(id),
  waited_since timestamptz not null default now(), called_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── CONTAINERS ───────────────────────────────────────────────────────────────
create table if not exists public.yard_containers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  container_number text not null, iso_type text, seal_number text,
  weight_kg numeric(12,3), volume_m3 numeric(12,3),
  status text not null default 'in_yard' check (status in ('in_yard','loaded','shipped','empty')),
  slot_id uuid references public.yard_slots(id),
  gate_pass_id uuid references public.gate_passes(id),
  entry_at timestamptz default now(), exit_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── MOVIMENTAÇÕES NO PÁTIO ───────────────────────────────────────────────────
create table if not exists public.yard_movements (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  gate_pass_id uuid references public.gate_passes(id) on delete cascade,
  movement_type text not null check (movement_type in ('entry','reposition','dock_change','yard_change','exit')),
  from_slot_id uuid references public.yard_slots(id),
  to_slot_id uuid references public.yard_slots(id),
  dock_id uuid references public.docks(id),
  occurred_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_gate_passes_status on public.gate_passes (company_id, status);
create index if not exists idx_yard_queue_status on public.yard_queue (company_id, status, position);
create index if not exists idx_yard_slots_status on public.yard_slots (company_id, status);
create index if not exists idx_yard_mov_pass on public.yard_movements (gate_pass_id);
create index if not exists idx_yard_containers_status on public.yard_containers (company_id, status);

-- ── RBAC 'yms' (reusa; garante slugs) ────────────────────────────────────────
insert into public.permissions (slug, resource, action, description)
select 'yms.' || a, 'yms', a, 'Permissão ' || a || ' em yms'
from unnest(array['read','create','update','delete']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'yms' and r.slug in ('admin','superadmin')
on conflict do nothing;

do $do$
declare t text; specs text[] := array['gates','access_credentials','yard_visitors','yard_slots','gate_passes','yard_queue','yard_containers','yard_movements'];
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

insert into public.event_types (slug, domain, stage_order, description) values
  ('yard.check_in', 'YMS', null, 'Veículo entrou (check-in na portaria)'),
  ('yard.dock_assigned', 'YMS', null, 'Veículo chamado para a doca'),
  ('yard.check_out', 'YMS', null, 'Veículo saiu (check-out)')
on conflict (slug) do nothing;

-- ── RPCs ─────────────────────────────────────────────────────────────────────
-- CHECK-IN: registra a passagem na portaria e entra na fila
create or replace function public.gate_check_in(
  p_company uuid, p_gate uuid, p_carrier uuid, p_plate text, p_driver text, p_driver_doc text,
  p_order uuid default null, p_cargo text default null, p_destination text default null, p_priority text default 'normal')
returns public.gate_passes language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; gp public.gate_passes; v_pos int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('yms.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.gate_passes (tenant_id, company_id, code, gate_id, carrier_id, vehicle_plate, driver_name, driver_document, order_id, cargo_description, destination, status, check_in_at)
  values (v_tenant, p_company, 'GP-'||to_char(now(),'YYMMDD')||'-'||lpad((floor(random()*100000))::text,5,'0'),
          p_gate, p_carrier, p_plate, p_driver, p_driver_doc, p_order, p_cargo, p_destination, 'in_yard', now())
  returning * into gp;
  select coalesce(max(position),0)+1 into v_pos from public.yard_queue where company_id=p_company and status in ('waiting','called') and deleted_at is null;
  insert into public.yard_queue (tenant_id, company_id, gate_pass_id, vehicle_plate, priority, status, position)
  values (v_tenant, p_company, gp.id, p_plate, coalesce(p_priority,'normal'), 'waiting', v_pos);
  insert into public.yard_movements (tenant_id, company_id, gate_pass_id, movement_type) values (v_tenant, p_company, gp.id, 'entry');
  perform app.emit_event(p_company, 'yard.check_in', 'yms', jsonb_build_object('gate_pass_id', gp.id, 'plate', p_plate, 'carrier', p_carrier));
  return gp;
end; $$;
grant execute on function public.gate_check_in(uuid,uuid,uuid,text,text,text,uuid,text,text,text) to authenticated;

-- CHAMAR PARA A DOCA
create or replace function public.call_to_dock(p_company uuid, p_queue uuid, p_dock uuid)
returns void language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_pass uuid;
begin
  if not (app.can_access_company(p_company) and app.has_permission('yms.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.yard_queue set status='at_dock', dock_id=p_dock, called_at=now() where id=p_queue and company_id=p_company returning gate_pass_id into v_pass;
  if v_pass is null then raise exception 'item de fila não encontrado'; end if;
  update public.gate_passes set status='at_dock' where id=v_pass;
  insert into public.yard_movements (tenant_id, company_id, gate_pass_id, movement_type, dock_id) values (v_tenant, p_company, v_pass, 'dock_change', p_dock);
  perform app.emit_event(p_company, 'yard.dock_assigned', 'yms', jsonb_build_object('gate_pass_id', v_pass, 'dock_id', p_dock));
end; $$;
grant execute on function public.call_to_dock(uuid,uuid,uuid) to authenticated;

-- CHECK-OUT
create or replace function public.gate_check_out(p_company uuid, p_pass uuid)
returns public.gate_passes language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; gp public.gate_passes;
begin
  if not (app.can_access_company(p_company) and app.has_permission('yms.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.gate_passes set status='completed', check_out_at=now() where id=p_pass and company_id=p_company returning * into gp;
  if gp.id is null then raise exception 'passagem não encontrada'; end if;
  update public.yard_slots set status='free', current_pass_id=null where current_pass_id=p_pass;
  update public.yard_queue set status='done' where gate_pass_id=p_pass and status<>'done';
  insert into public.yard_movements (tenant_id, company_id, gate_pass_id, movement_type) values (v_tenant, p_company, p_pass, 'exit');
  perform app.emit_event(p_company, 'yard.check_out', 'yms', jsonb_build_object('gate_pass_id', p_pass));
  return gp;
end; $$;
grant execute on function public.gate_check_out(uuid,uuid) to authenticated;

-- ALOCAR VAGA
create or replace function public.assign_yard_slot(p_company uuid, p_pass uuid, p_slot uuid)
returns void language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_old uuid;
begin
  if not (app.can_access_company(p_company) and app.has_permission('yms.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select slot_id into v_old from public.gate_passes where id=p_pass and company_id=p_company;
  update public.yard_slots set status='free', current_pass_id=null where id=v_old;
  update public.yard_slots set status='occupied', current_pass_id=p_pass where id=p_slot and company_id=p_company;
  update public.gate_passes set slot_id=p_slot where id=p_pass;
  insert into public.yard_movements (tenant_id, company_id, gate_pass_id, movement_type, from_slot_id, to_slot_id)
  values (v_tenant, p_company, p_pass, 'reposition', v_old, p_slot);
end; $$;
grant execute on function public.assign_yard_slot(uuid,uuid,uuid) to authenticated;

create or replace function public.yard_ops_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'in_yard',       (select count(*) from public.gate_passes where company_id=p_company and status='in_yard' and deleted_at is null),
    'at_dock',       (select count(*) from public.gate_passes where company_id=p_company and status='at_dock' and deleted_at is null),
    'queue_waiting', (select count(*) from public.yard_queue where company_id=p_company and status='waiting' and deleted_at is null),
    'slots_total',   (select count(*) from public.yard_slots where company_id=p_company and deleted_at is null),
    'slots_free',    (select count(*) from public.yard_slots where company_id=p_company and status='free' and deleted_at is null),
    'slots_occupied',(select count(*) from public.yard_slots where company_id=p_company and status='occupied' and deleted_at is null),
    'gates',         (select count(*) from public.gates where company_id=p_company and status='open' and deleted_at is null),
    'containers_in_yard', (select count(*) from public.yard_containers where company_id=p_company and status='in_yard' and deleted_at is null),
    'avg_dwell_min', (select round(coalesce(avg(extract(epoch from (check_out_at-check_in_at))/60.0),0)::numeric,1) from public.gate_passes where company_id=p_company and status='completed' and check_out_at is not null and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.yard_ops_dashboard(uuid) to authenticated;

-- mapa operacional (vagas + fila + portarias)
create or replace function public.yard_ops_map(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'slots', (select coalesce(jsonb_agg(jsonb_build_object('code', s.code, 'type', s.slot_type, 'status', s.status,
                'plate', (select gp.vehicle_plate from public.gate_passes gp where gp.id=s.current_pass_id)) order by s.code),'[]'::jsonb)
              from public.yard_slots s where s.company_id=p_company and s.deleted_at is null),
    'queue', (select coalesce(jsonb_agg(jsonb_build_object('plate', q.vehicle_plate, 'priority', q.priority, 'status', q.status, 'position', q.position)
                order by (q.priority='emergency') desc, q.position),'[]'::jsonb)
              from public.yard_queue q where q.company_id=p_company and q.status in ('waiting','called','at_dock') and q.deleted_at is null),
    'gates', (select coalesce(jsonb_agg(jsonb_build_object('name', g.name, 'type', g.gate_type, 'status', g.status) order by g.name),'[]'::jsonb)
              from public.gates g where g.company_id=p_company and g.deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.yard_ops_map(uuid) to authenticated;

-- motor auto-descoberto pelo LAIOS (nome NÃO colide com yms_insights existente)
create or replace function public.yard_ops_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_dwell int; v_q int; v_blk int; v_cont int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'YMS%' and deleted_at is null;

  select count(*) into v_dwell from public.gate_passes where company_id=p_company and status in ('in_yard','at_dock') and check_in_at < now() - interval '8 hours' and deleted_at is null;
  if v_dwell > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'YMS: permanência excedida no pátio', v_dwell||' veículo(s) há mais de 8h no pátio.', 'Priorizar liberação/doca desses veículos.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_q from public.yard_queue where company_id=p_company and status='waiting' and deleted_at is null;
  if v_q >= 10 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'YMS: fila excessiva na portaria', v_q||' veículos aguardando na fila.', 'Abrir mais docas ou reordenar por prioridade.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_blk from public.yard_slots where company_id=p_company and status='blocked' and deleted_at is null;
  if v_blk > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'YMS: vagas bloqueadas', v_blk||' vaga(s) de pátio bloqueada(s).', 'Verificar o motivo do bloqueio e liberar.', 70);
    v_c := v_c + 1;
  end if;
  select count(*) into v_cont from public.yard_containers where company_id=p_company and status='in_yard' and entry_at < now() - interval '72 hours' and deleted_at is null;
  if v_cont > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'YMS: containers parados', v_cont||' container(s) há mais de 72h sem movimentação.', 'Programar retirada/expedição do container.', 72);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.yard_ops_insights(uuid) to authenticated;

-- ── SEED (empresa Matriz Logística) ─────────────────────────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid; v_zone uuid; i int;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;
  if exists (select 1 from public.gates where company_id=v_company and deleted_at is null) then return; end if;

  insert into public.gates (tenant_id, company_id, code, name, gate_type, direction) values
    (v_tenant, v_company, 'P-01', 'Portaria Principal', 'main', 'both'),
    (v_tenant, v_company, 'P-02', 'Portaria de Entrada', 'entry', 'in'),
    (v_tenant, v_company, 'P-03', 'Portaria de Saída', 'exit', 'out'),
    (v_tenant, v_company, 'P-04', 'Portaria de Visitantes', 'visitor', 'both');

  select id into v_zone from public.yard_zones where company_id=v_company and deleted_at is null order by created_at limit 1;
  if v_zone is null then
    insert into public.yard_zones (tenant_id, company_id, code, name) values (v_tenant, v_company, 'Z-PAT', 'Pátio Principal') returning id into v_zone;
  end if;
  for i in 1..12 loop
    insert into public.yard_slots (tenant_id, company_id, zone_id, code, slot_type, status)
    values (v_tenant, v_company, v_zone, 'V-'||lpad(i::text,2,'0'), case when i>10 then 'container' else 'truck' end, 'free');
  end loop;

  insert into public.access_credentials (tenant_id, company_id, credential_type, code, holder_name, holder_type, status) values
    (v_tenant, v_company, 'rfid', 'RFID-0001', 'Motorista Exemplo', 'driver', 'active'),
    (v_tenant, v_company, 'lpr',  'ABC1D23',   'Veículo Exemplo',   'vehicle', 'active');
end $seed$;

notify pgrst, 'reload schema';
