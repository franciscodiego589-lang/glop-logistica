-- 20260713000031_transport_tower.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  TORRE DE CONTROLE DE TRANSPORTE (Control Tower) — em trânsito             ║
-- ║  Monitora a viagem: coleta→CD→hub→rota→entrega. Reusa shipments/          ║
-- ║  shipment_events/carriers/vehicles/drivers (TMS). Adiciona ocorrências,   ║
-- ║  score de risco por pedido, ETA, detecção automática e IA preditiva.      ║
-- ║  Recurso RBAC 'tms'.                                                       ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.transport_occurrence_status as enum ('open','in_progress','resolved','escalated');

-- ── Enriquecimento de shipments (monitoramento) ─────────────────────────────
alter table public.shipments
  add column if not exists eta timestamptz,
  add column if not exists risk_score numeric(5,2),
  add column if not exists delay_probability numeric(5,2),
  add column if not exists last_event_at timestamptz,
  add column if not exists last_location text;

-- ── TRANSPORT_OCCURRENCES (ocorrências da viagem) ───────────────────────────
create table public.transport_occurrences (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  shipment_id uuid references public.shipments(id) on delete cascade,
  carrier_id uuid references public.carriers(id) on delete set null,
  occurrence_type text not null, severity public.event_severity not null default 'warning',
  status public.transport_occurrence_status not null default 'open',
  description text, location_text text, occurred_at timestamptz not null default now(),
  resolved_by uuid references auth.users(id), resolved_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_transport_occurrences_status on public.transport_occurrences (company_id, status) where deleted_at is null;
create index idx_transport_occurrences_shipment on public.transport_occurrences (shipment_id);

-- ── Trigger: cada evento de rastreio atualiza o shipment (last event/status) ─
create or replace function app.tg_shipment_event_sync() returns trigger
language plpgsql security definer set search_path = public, app as $$
begin
  update public.shipments
     set last_event_at = new.occurred_at,
         last_location = coalesce(new.location_text, last_location),
         status = case when new.event_type = 'delivered' then 'delivered'
                       when new.event_type = 'returned'  then 'returned'
                       when new.event_type = 'in_transit' and status = 'dispatched' then 'in_transit'
                       else status end,
         delivered_at = case when new.event_type = 'delivered' then new.occurred_at else delivered_at end
   where id = new.shipment_id;
  return null;
end;
$$;
drop trigger if exists trg_shipment_events_sync on public.shipment_events;
create trigger trg_shipment_events_sync after insert on public.shipment_events
  for each row execute function app.tg_shipment_event_sync();

-- ── RPC: score de risco por embarque (0-100) ────────────────────────────────
create or replace function public.compute_shipment_risk(p_shipment uuid)
returns numeric
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_s record; v_risk numeric := 0; v_occ int; v_rating numeric;
begin
  select * into v_s from public.shipments where id = p_shipment;
  v_company := v_s.company_id;
  if v_company is null then raise exception 'embarque não encontrado'; end if;
  if not app.can_access_company(v_company) then raise exception 'forbidden'; end if;

  -- valor da carga
  if coalesce(v_s.cargo_value,0) > 5000 then v_risk := v_risk + 25;
  elsif coalesce(v_s.cargo_value,0) > 1000 then v_risk := v_risk + 12; end if;
  -- rating da transportadora (baixo = mais risco)
  select rating into v_rating from public.carriers where id = v_s.carrier_id;
  if v_rating is not null then v_risk := v_risk + greatest(0, (5 - v_rating) * 6); else v_risk := v_risk + 8; end if;
  -- ocorrências abertas
  select count(*) into v_occ from public.transport_occurrences where shipment_id = p_shipment and status <> 'resolved' and deleted_at is null;
  v_risk := v_risk + v_occ * 15;
  -- atraso: sem evento recente
  if v_s.last_event_at is not null and v_s.last_event_at < now() - interval '48 hours' and v_s.status not in ('delivered','returned','canceled') then v_risk := v_risk + 25; end if;
  -- SLA estourado
  if v_s.estimated_delivery is not null and v_s.estimated_delivery < now()::date and v_s.status not in ('delivered','returned','canceled') then v_risk := v_risk + 30; end if;

  v_risk := least(round(v_risk,2), 100);
  update public.shipments set risk_score = v_risk, delay_probability = least(v_risk, 95) where id = p_shipment;
  return v_risk;
end;
$$;
grant execute on function public.compute_shipment_risk(uuid) to authenticated;

-- ── RPC-MOTOR: detecta problemas de transporte (parado, atraso) ─────────────
create or replace function public.detect_transport_issues(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_s record;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;

  for v_s in
    select * from public.shipments
    where company_id=p_company and deleted_at is null and status in ('dispatched','in_transit')
  loop
    -- veículo/objeto parado: sem evento há +48h
    if coalesce(v_s.last_event_at, v_s.dispatched_at) < now() - interval '48 hours'
       and not exists (select 1 from public.transport_occurrences o where o.shipment_id=v_s.id and o.occurrence_type='stopped' and o.status<>'resolved' and o.deleted_at is null) then
      insert into public.transport_occurrences (tenant_id, company_id, branch_id, shipment_id, carrier_id, occurrence_type, severity, status, description)
      values (v_tenant, p_company, v_s.branch_id, v_s.id, v_s.carrier_id, 'stopped', 'critical', 'open',
        'Sem movimentação há mais de 48h — possível objeto parado/extravio.');
      v_count := v_count + 1;
    end if;
    -- SLA estourado
    if v_s.estimated_delivery is not null and v_s.estimated_delivery < now()::date
       and not exists (select 1 from public.transport_occurrences o where o.shipment_id=v_s.id and o.occurrence_type='delayed' and o.status<>'resolved' and o.deleted_at is null) then
      insert into public.transport_occurrences (tenant_id, company_id, branch_id, shipment_id, carrier_id, occurrence_type, severity, status, description)
      values (v_tenant, p_company, v_s.branch_id, v_s.id, v_s.carrier_id, 'delayed', 'warning', 'open',
        'Previsão de entrega ('||v_s.estimated_delivery||') vencida sem entrega.');
      v_count := v_count + 1;
    end if;
    -- recalcula risco
    perform public.compute_shipment_risk(v_s.id);
  end loop;
  return v_count;
end;
$$;
grant execute on function public.detect_transport_issues(uuid) to authenticated;

-- ── RPC: dashboard da torre de transporte ───────────────────────────────────
create or replace function public.transport_control_tower(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'in_transit',   (select count(*) from public.shipments where company_id=p_company and status in ('dispatched','in_transit') and deleted_at is null),
    'delivered_today', (select count(*) from public.shipments where company_id=p_company and delivered_at::date=now()::date and deleted_at is null),
    'delayed',      (select count(*) from public.shipments where company_id=p_company and estimated_delivery<now()::date and status not in ('delivered','returned','canceled') and deleted_at is null),
    'returned',     (select count(*) from public.shipments where company_id=p_company and status='returned' and deleted_at is null),
    'occurrences_open', (select count(*) from public.transport_occurrences where company_id=p_company and status<>'resolved' and deleted_at is null),
    'high_risk',    (select count(*) from public.shipments where company_id=p_company and risk_score>=60 and status in ('dispatched','in_transit') and deleted_at is null),
    'vehicles_operating', (select count(distinct vehicle_id) from public.shipments where company_id=p_company and status in ('dispatched','in_transit') and vehicle_id is not null and deleted_at is null),
    'value_in_transit', (select coalesce(sum(cargo_value),0) from public.shipments where company_id=p_company and status in ('dispatched','in_transit') and deleted_at is null),
    'weight_in_transit_kg', (select coalesce(sum(total_weight_kg),0) from public.shipments where company_id=p_company and status in ('dispatched','in_transit') and deleted_at is null),
    'otif', (select round(100.0 * count(*) filter (where delivered_at::date <= estimated_delivery) / nullif(count(*) filter (where status='delivered' and estimated_delivery is not null),0), 1)
             from public.shipments where company_id=p_company and status='delivered' and deleted_at is null),
    'avg_delivery_hours', (select round(avg(extract(epoch from (delivered_at - dispatched_at))/3600),1) from public.shipments where company_id=p_company and delivered_at is not null and dispatched_at is not null and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.transport_control_tower(uuid) to authenticated;

-- ── RPC: IA — embarques com alto risco de estourar SLA → insights ───────────
create or replace function public.transport_insights(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_r record;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and kind='sla_risk' and status='new' and title like 'Transporte%' and deleted_at is null;

  for v_r in
    select coalesce(c.name,'(sem transportadora)') carrier, count(*) c, round(avg(s.risk_score),0) risk
    from public.shipments s left join public.carriers c on c.id=s.carrier_id
    where s.company_id=p_company and s.status in ('dispatched','in_transit') and s.risk_score>=60 and s.deleted_at is null
    group by c.name having count(*) >= 1
  loop
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'warning', 'Transporte: risco de SLA em '||v_r.carrier,
      v_r.c||' embarque(s) com risco médio '||v_r.risk||' na transportadora '||v_r.carrier||'.',
      'Priorizar acompanhamento / considerar redistribuir carga.', 82);
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.transport_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant (transport_occurrences; recurso 'tms') ─
alter table public.transport_occurrences enable row level security;
create trigger trg_transport_occurrences_touch before insert or update on public.transport_occurrences for each row execute function app.tg_touch_row();
create trigger trg_transport_occurrences_audit after insert or update or delete on public.transport_occurrences for each row execute function app.tg_write_audit();
create policy transport_occurrences_select on public.transport_occurrences for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));
create policy transport_occurrences_insert on public.transport_occurrences for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission('tms.create', company_id));
create policy transport_occurrences_update on public.transport_occurrences for update to authenticated using (app.can_access_company(company_id) and app.has_permission('tms.update', company_id)) with check (app.can_access_company(company_id));
create policy transport_occurrences_delete on public.transport_occurrences for delete to authenticated using (app.is_superadmin());
grant select, insert, update, delete on public.transport_occurrences to authenticated;
