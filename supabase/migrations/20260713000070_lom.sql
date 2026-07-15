-- ============================================================================
-- GLOP · DOMÍNIO 01 — LOGISTICS ORDER MANAGEMENT (LOM) + EVENT BUS FORMALIZADO
-- migration 070
--
-- Fecha o gap do Cap. 4 (ponto de entrada do fluxo mestre) e implementa a máquina
-- de estados das 17 etapas do Cap. 5. Formaliza o contrato de eventos do event bus
-- (app.emit_event + catálogo event_types) publicando logistics_order.<evento> a cada
-- transição. Recurso RBAC 'lom'. Padrão: text+check, grant por-tabela, gerado só imutável.
-- ============================================================================

-- ── EVENT BUS: helper interno (sem gate — chamado por RPCs já autorizadas) ────
create or replace function app.emit_event(p_company uuid, p_event_type text, p_source text, p_payload jsonb)
returns uuid language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_event uuid; w record; v_n int := 0;
begin
  select tenant_id into v_tenant from public.companies where id = p_company;
  insert into public.event_bus (tenant_id, company_id, event_type, source_module, payload)
  values (v_tenant, p_company, p_event_type, coalesce(p_source,'lom'), coalesce(p_payload,'{}'::jsonb))
  returning id into v_event;
  -- fan-out para webhooks assinantes (mesmo padrão do publish_event)
  for w in select * from public.webhooks where company_id=p_company and enabled and deleted_at is null
           and (event_type=p_event_type or event_type='*') loop
    insert into public.integration_messages (tenant_id, company_id, webhook_id, event_id, channel, target, payload, status, max_attempts)
    values (v_tenant, p_company, w.id, v_event, 'webhook', w.target_url, coalesce(p_payload,'{}'::jsonb), 'queued', w.max_attempts);
    v_n := v_n + 1;
  end loop;
  update public.event_bus set subscribers_notified=v_n where id=v_event;
  return v_event;
end; $$;

-- ── CATÁLOGO: contrato de eventos (global, sem company) ──────────────────────
create table if not exists public.event_types (
  slug text primary key,
  domain text not null,
  stage_order integer,
  description text,
  created_at timestamptz not null default now()
);

-- ── CATÁLOGO: as 17 etapas do fluxo operacional (Cap. 5) ─────────────────────
create table if not exists public.logistics_stages (
  stage_key text primary key,
  order_index integer not null,
  label text not null,
  domain text not null,
  event_type text not null,
  is_branch boolean not null default false   -- reverse é ramo, fora do caminho feliz
);

insert into public.logistics_stages (stage_key, order_index, label, domain, event_type, is_branch) values
  ('demand',           1,  'Demanda Logística',      'LOM',            'logistics_order.created',          false),
  ('validated',        2,  'Validação Operacional',  'LOM',            'logistics_order.validated',        false),
  ('planned',          3,  'Planejamento Logístico', 'LOM',            'logistics_order.planned',          false),
  ('allocated',        4,  'Reserva Operacional',    'WMS',            'logistics_order.allocated',        false),
  ('picking',          5,  'Separação (Picking)',    'WMS',            'logistics_order.picking',          false),
  ('checked',          6,  'Conferência',            'WMS',            'logistics_order.checked',          false),
  ('packed',           7,  'Embalagem (Packing)',    'SmartShipping',  'logistics_order.packed',           false),
  ('staged',           8,  'Expedição',              'SmartShipping',  'logistics_order.staged',           false),
  ('manifested',       9,  'Manifestação',           'SmartShipping',  'logistics_order.manifested',       false),
  ('posted',           10, 'Postagem / Coleta',      'Correios',       'logistics_order.posted',           false),
  ('in_transit',       11, 'Transporte',             'TMS',            'logistics_order.in_transit',       false),
  ('at_hub',           12, 'Hub / Cross Docking',    'TMS',            'logistics_order.at_hub',           false),
  ('out_for_delivery', 13, 'Última Milha',           'TMS',            'logistics_order.out_for_delivery', false),
  ('delivered',        14, 'Entrega',                'TMS',            'logistics_order.delivered',        false),
  ('post_delivery',    15, 'Pós-Entrega',            'Portal',         'logistics_order.post_delivery',    false),
  ('reverse',          16, 'Logística Reversa',      'Reversa',        'logistics_order.reverse',          true),
  ('closed',           17, 'Encerramento',           'LOM',            'logistics_order.closed',           false)
on conflict (stage_key) do nothing;

insert into public.event_types (slug, domain, stage_order, description)
select event_type, domain, order_index, label from public.logistics_stages
on conflict (slug) do nothing;

-- ── TABELAS DE NEGÓCIO ───────────────────────────────────────────────────────
create table if not exists public.logistics_orders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text,
  operation_type text not null default 'customer_order'
    check (operation_type in ('customer_order','transfer','replenishment','supplier_pickup','return','exchange','toll_manufacturing','export','import')),
  origin text,
  destination text,
  dest_uf text,
  dest_zip text,
  priority text not null default 'normal' check (priority in ('low','normal','high','urgent')),
  sla_hours integer,
  sla_due_at timestamptz,
  stage text not null default 'demand' references public.logistics_stages(stage_key),
  status text not null default 'open' check (status in ('open','blocked','canceled','closed')),
  responsible_id uuid references auth.users(id),
  planned_warehouse_id uuid references public.warehouses(id),
  planned_carrier_id uuid references public.carriers(id),
  eta timestamptz,
  closed_at timestamptz,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create table if not exists public.logistics_order_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  order_id uuid not null references public.logistics_orders(id) on delete cascade,
  product_id uuid references public.products(id),
  description text,
  quantity numeric(18,3) not null default 0,
  uom text default 'un',
  lot_id uuid references public.product_lots(id),
  reserved_quantity numeric(18,3) not null default 0,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create table if not exists public.logistics_order_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  order_id uuid not null references public.logistics_orders(id) on delete cascade,
  from_stage text,
  to_stage text,
  event_type text not null,
  result text default 'ok',
  notes text,
  occurred_at timestamptz not null default now(),
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create table if not exists public.logistics_order_holds (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  order_id uuid not null references public.logistics_orders(id) on delete cascade,
  reason text not null,
  status text not null default 'open' check (status in ('open','released')),
  released_at timestamptz,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_lo_items_order on public.logistics_order_items (order_id);
create index if not exists idx_lo_items_product on public.logistics_order_items (product_id);
create index if not exists idx_lo_events_order on public.logistics_order_events (order_id);
create index if not exists idx_lo_holds_order on public.logistics_order_holds (order_id);
create index if not exists idx_lo_stage on public.logistics_orders (company_id, stage);

-- ── RBAC 'lom' ───────────────────────────────────────────────────────────────
insert into public.permissions (slug, resource, action, description)
select 'lom.' || a, 'lom', a, 'Permissão ' || a || ' em lom'
from unnest(array['read','create','update','delete']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'lom' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- catálogos: leitura global, escrita só superadmin
alter table public.event_types enable row level security;
alter table public.logistics_stages enable row level security;
do $cat$
declare t text;
begin
  foreach t in array array['event_types','logistics_stages'] loop
    execute format('create policy %I on public.%I for select to authenticated using (true);', t||'_sel', t);
    execute format('create policy %I on public.%I for all to authenticated using (app.is_superadmin()) with check (app.is_superadmin());', t||'_admin', t);
    execute format('grant select on public.%I to authenticated;', t);
  end loop;
end $cat$;

-- tabelas de negócio: RLS + triggers + grant por-tabela
do $do$
declare t text; specs text[] := array['logistics_orders','logistics_order_items','logistics_order_events','logistics_order_holds'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'lom.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'lom.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ── RPCs ─────────────────────────────────────────────────────────────────────
-- Etapa 01: cria a demanda logística + itens + evento created
create or replace function public.create_logistics_order(
  p_company uuid, p_operation_type text, p_origin text, p_destination text,
  p_priority text, p_sla_hours integer, p_items jsonb, p_dest_uf text default null, p_dest_zip text default null)
returns public.logistics_orders language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_order public.logistics_orders; v_code text; it jsonb;
begin
  if not (app.can_access_company(p_company) and app.has_permission('lom.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  v_code := 'LO-' || to_char(now(),'YYMM') || '-' || lpad((floor(random()*100000))::text, 5, '0');
  insert into public.logistics_orders (tenant_id, company_id, code, operation_type, origin, destination, dest_uf, dest_zip, priority, sla_hours, sla_due_at, responsible_id, stage, status)
  values (v_tenant, p_company, v_code, coalesce(p_operation_type,'customer_order'), p_origin, p_destination, p_dest_uf, p_dest_zip,
          coalesce(p_priority,'normal'), p_sla_hours,
          case when p_sla_hours is not null then now() + (p_sla_hours||' hours')::interval else null end,
          auth.uid(), 'demand', 'open')
  returning * into v_order;
  for it in select * from jsonb_array_elements(coalesce(p_items,'[]'::jsonb)) loop
    insert into public.logistics_order_items (tenant_id, company_id, order_id, product_id, description, quantity, uom, lot_id)
    values (v_tenant, p_company, v_order.id, nullif(it->>'product_id','')::uuid, it->>'description',
            coalesce((it->>'quantity')::numeric,0), coalesce(it->>'uom','un'), nullif(it->>'lot_id','')::uuid);
  end loop;
  insert into public.logistics_order_events (tenant_id, company_id, order_id, from_stage, to_stage, event_type, result)
  values (v_tenant, p_company, v_order.id, null, 'demand', 'logistics_order.created', 'ok');
  perform app.emit_event(p_company, 'logistics_order.created', 'lom', jsonb_build_object('order_id', v_order.id, 'code', v_code, 'operation_type', v_order.operation_type));
  return v_order;
end; $$;
grant execute on function public.create_logistics_order(uuid,text,text,text,text,integer,jsonb,text,text) to authenticated;

-- Etapa 02: valida disponibilidade (ATP) + endereços; bloqueia se inconsistente
create or replace function public.validate_logistics_order(p_company uuid, p_order uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_o public.logistics_orders; r record; v_short jsonb := '[]'::jsonb; v_ok boolean := true; v_reason text := '';
begin
  if not (app.can_access_company(p_company) and app.has_permission('lom.update', p_company)) then raise exception 'forbidden'; end if;
  select * into v_o from public.logistics_orders where id=p_order and company_id=p_company and deleted_at is null;
  if v_o.id is null then raise exception 'ordem não encontrada'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  if coalesce(v_o.origin,'')='' or coalesce(v_o.destination,'')='' then v_ok := false; v_reason := 'origem/destino ausente; '; end if;
  -- ATP por item: on-hand (todos os bins) menos reservas de OUTRAS ordens abertas
  for r in
    select i.id, i.product_id, i.description, i.quantity,
      coalesce((select sum(sb.quantity) from public.stock_balances sb where sb.product_id=i.product_id and sb.company_id=p_company and sb.deleted_at is null),0) as on_hand,
      coalesce((select sum(oi.reserved_quantity) from public.logistics_order_items oi join public.logistics_orders o on o.id=oi.order_id
                where oi.product_id=i.product_id and o.company_id=p_company and o.status='open' and o.id<>p_order and oi.deleted_at is null),0) as reserved_other
    from public.logistics_order_items i where i.order_id=p_order and i.product_id is not null and i.deleted_at is null
  loop
    if r.quantity > (r.on_hand - r.reserved_other) then
      v_ok := false;
      v_short := v_short || jsonb_build_object('product_id', r.product_id, 'description', r.description, 'requested', r.quantity, 'available', (r.on_hand - r.reserved_other));
    end if;
  end loop;
  if v_ok then
    update public.logistics_orders set stage='validated' where id=p_order;
    insert into public.logistics_order_events (tenant_id, company_id, order_id, from_stage, to_stage, event_type, result)
    values (v_tenant, p_company, p_order, v_o.stage, 'validated', 'logistics_order.validated', 'ok');
    perform app.emit_event(p_company, 'logistics_order.validated', 'lom', jsonb_build_object('order_id', p_order));
  else
    update public.logistics_orders set status='blocked' where id=p_order;
    insert into public.logistics_order_holds (tenant_id, company_id, order_id, reason)
    values (v_tenant, p_company, p_order, nullif(v_reason,'') || case when jsonb_array_length(v_short)>0 then 'estoque insuficiente' else '' end);
    insert into public.logistics_order_events (tenant_id, company_id, order_id, from_stage, to_stage, event_type, result, notes)
    values (v_tenant, p_company, p_order, v_o.stage, v_o.stage, 'logistics_order.blocked', 'blocked', v_reason);
    perform app.emit_event(p_company, 'logistics_order.blocked', 'lom', jsonb_build_object('order_id', p_order, 'shortages', v_short));
  end if;
  return jsonb_build_object('ok', v_ok, 'shortages', v_short, 'reason', v_reason);
end; $$;
grant execute on function public.validate_logistics_order(uuid,uuid) to authenticated;

-- Etapa 03: planejamento (CD/transportadora/ETA)
create or replace function public.plan_logistics_order(p_company uuid, p_order uuid, p_warehouse uuid, p_carrier uuid, p_eta timestamptz)
returns public.logistics_orders language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_o public.logistics_orders;
begin
  if not (app.can_access_company(p_company) and app.has_permission('lom.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logistics_orders set planned_warehouse_id=p_warehouse, planned_carrier_id=p_carrier, eta=p_eta, stage='planned'
    where id=p_order and company_id=p_company and status='open' returning * into v_o;
  if v_o.id is null then raise exception 'ordem não encontrada ou não está aberta'; end if;
  insert into public.logistics_order_events (tenant_id, company_id, order_id, from_stage, to_stage, event_type, result)
  values (v_tenant, p_company, p_order, 'validated', 'planned', 'logistics_order.planned', 'ok');
  perform app.emit_event(p_company, 'logistics_order.planned', 'lom', jsonb_build_object('order_id', p_order, 'warehouse', p_warehouse, 'carrier', p_carrier));
  return v_o;
end; $$;
grant execute on function public.plan_logistics_order(uuid,uuid,uuid,uuid,timestamptz) to authenticated;

-- Etapa 04: reserva lógica de estoque (reserved_quantity = quantity)
create or replace function public.allocate_logistics_order(p_company uuid, p_order uuid)
returns public.logistics_orders language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_o public.logistics_orders;
begin
  if not (app.can_access_company(p_company) and app.has_permission('lom.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select * into v_o from public.logistics_orders where id=p_order and company_id=p_company and deleted_at is null;
  if v_o.id is null then raise exception 'ordem não encontrada'; end if;
  if v_o.status <> 'open' then raise exception 'ordem não está aberta'; end if;
  update public.logistics_order_items set reserved_quantity = quantity where order_id=p_order and deleted_at is null;
  update public.logistics_orders set stage='allocated' where id=p_order;
  insert into public.logistics_order_events (tenant_id, company_id, order_id, from_stage, to_stage, event_type, result)
  values (v_tenant, p_company, p_order, v_o.stage, 'allocated', 'logistics_order.allocated', 'ok');
  perform app.emit_event(p_company, 'logistics_order.allocated', 'lom', jsonb_build_object('order_id', p_order));
  select * into v_o from public.logistics_orders where id=p_order;
  return v_o;
end; $$;
grant execute on function public.allocate_logistics_order(uuid,uuid) to authenticated;

-- Etapas 05→17: avança para a próxima etapa (ou uma etapa-alvo válida), emitindo evento
create or replace function public.advance_logistics_order(p_company uuid, p_order uuid, p_to_stage text default null)
returns public.logistics_orders language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_o public.logistics_orders; v_cur int; v_next text; v_evt text;
begin
  if not (app.can_access_company(p_company) and app.has_permission('lom.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select * into v_o from public.logistics_orders where id=p_order and company_id=p_company and deleted_at is null;
  if v_o.id is null then raise exception 'ordem não encontrada'; end if;
  if v_o.status not in ('open') then raise exception 'ordem % (não avançável)', v_o.status; end if;
  select order_index into v_cur from public.logistics_stages where stage_key=v_o.stage;
  if p_to_stage is not null then
    if not exists (select 1 from public.logistics_stages where stage_key=p_to_stage) then raise exception 'etapa inválida'; end if;
    v_next := p_to_stage;
  else
    -- próxima etapa linear, pulando o ramo 'reverse'
    select stage_key into v_next from public.logistics_stages
      where order_index > v_cur and not is_branch order by order_index limit 1;
  end if;
  if v_next is null then raise exception 'não há próxima etapa'; end if;
  select event_type into v_evt from public.logistics_stages where stage_key=v_next;
  update public.logistics_orders set stage=v_next,
      status = case when v_next='closed' then 'closed' else status end,
      closed_at = case when v_next='closed' then now() else closed_at end
    where id=p_order;
  insert into public.logistics_order_events (tenant_id, company_id, order_id, from_stage, to_stage, event_type, result)
  values (v_tenant, p_company, p_order, v_o.stage, v_next, v_evt, 'ok');
  perform app.emit_event(p_company, v_evt, 'lom', jsonb_build_object('order_id', p_order, 'stage', v_next));
  select * into v_o from public.logistics_orders where id=p_order;
  return v_o;
end; $$;
grant execute on function public.advance_logistics_order(uuid,uuid,text) to authenticated;

-- Bloqueio operacional
create or replace function public.hold_logistics_order(p_company uuid, p_order uuid, p_reason text)
returns void language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_stage text;
begin
  if not (app.can_access_company(p_company) and app.has_permission('lom.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select stage into v_stage from public.logistics_orders where id=p_order and company_id=p_company;
  if v_stage is null then raise exception 'ordem não encontrada'; end if;
  update public.logistics_orders set status='blocked' where id=p_order and company_id=p_company;
  insert into public.logistics_order_holds (tenant_id, company_id, order_id, reason) values (v_tenant, p_company, p_order, p_reason);
  insert into public.logistics_order_events (tenant_id, company_id, order_id, from_stage, to_stage, event_type, result, notes)
  values (v_tenant, p_company, p_order, v_stage, v_stage, 'logistics_order.blocked', 'blocked', p_reason);
  perform app.emit_event(p_company, 'logistics_order.blocked', 'lom', jsonb_build_object('order_id', p_order, 'reason', p_reason));
end; $$;
grant execute on function public.hold_logistics_order(uuid,uuid,text) to authenticated;

create or replace function public.release_logistics_hold(p_company uuid, p_hold uuid)
returns void language plpgsql security definer set search_path = public, app as $$
declare v_order uuid;
begin
  if not (app.can_access_company(p_company) and app.has_permission('lom.update', p_company)) then raise exception 'forbidden'; end if;
  update public.logistics_order_holds set status='released', released_at=now() where id=p_hold and company_id=p_company returning order_id into v_order;
  if v_order is null then raise exception 'bloqueio não encontrado'; end if;
  -- se não há mais bloqueios abertos, reabre a ordem
  if not exists (select 1 from public.logistics_order_holds where order_id=v_order and status='open' and deleted_at is null) then
    update public.logistics_orders set status='open' where id=v_order and status='blocked';
  end if;
end; $$;
grant execute on function public.release_logistics_hold(uuid,uuid) to authenticated;

create or replace function public.cancel_logistics_order(p_company uuid, p_order uuid, p_reason text)
returns void language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_stage text;
begin
  if not (app.can_access_company(p_company) and app.has_permission('lom.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select stage into v_stage from public.logistics_orders where id=p_order and company_id=p_company;
  if v_stage is null then raise exception 'ordem não encontrada'; end if;
  update public.logistics_orders set status='canceled', reason_deleted=p_reason where id=p_order and company_id=p_company;
  update public.logistics_order_items set reserved_quantity=0 where order_id=p_order;
  insert into public.logistics_order_events (tenant_id, company_id, order_id, from_stage, to_stage, event_type, result, notes)
  values (v_tenant, p_company, p_order, v_stage, v_stage, 'logistics_order.canceled', 'canceled', p_reason);
  perform app.emit_event(p_company, 'logistics_order.canceled', 'lom', jsonb_build_object('order_id', p_order, 'reason', p_reason));
end; $$;
grant execute on function public.cancel_logistics_order(uuid,uuid,text) to authenticated;

-- Dashboard + timeline + insights
create or replace function public.lom_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'total',       (select count(*) from public.logistics_orders where company_id=p_company and deleted_at is null),
    'open',        (select count(*) from public.logistics_orders where company_id=p_company and status='open' and deleted_at is null),
    'blocked',     (select count(*) from public.logistics_orders where company_id=p_company and status='blocked' and deleted_at is null),
    'closed',      (select count(*) from public.logistics_orders where company_id=p_company and status='closed' and deleted_at is null),
    'sla_at_risk', (select count(*) from public.logistics_orders where company_id=p_company and status='open' and sla_due_at is not null and sla_due_at < now() + interval '6 hours' and deleted_at is null),
    'sla_breached',(select count(*) from public.logistics_orders where company_id=p_company and status='open' and sla_due_at is not null and sla_due_at < now() and deleted_at is null),
    'avg_lead_hours', (select round(coalesce(avg(extract(epoch from (closed_at - created_at))/3600.0),0)::numeric,1) from public.logistics_orders where company_id=p_company and status='closed' and closed_at is not null and deleted_at is null),
    'by_stage',    (select coalesce(jsonb_agg(jsonb_build_object('stage', s.stage_key, 'label', s.label, 'count', c.n) order by s.order_index),'[]'::jsonb)
                    from public.logistics_stages s
                    left join (select stage, count(*) n from public.logistics_orders where company_id=p_company and status<>'closed' and deleted_at is null group by stage) c on c.stage=s.stage_key
                    where coalesce(c.n,0) > 0),
    'by_operation',(select coalesce(jsonb_agg(jsonb_build_object('op', operation_type, 'count', n) order by n desc),'[]'::jsonb)
                    from (select operation_type, count(*) n from public.logistics_orders where company_id=p_company and deleted_at is null group by operation_type) t)
  ) into v;
  return v;
end; $$;
grant execute on function public.lom_dashboard(uuid) to authenticated;

create or replace function public.lom_order_timeline(p_company uuid, p_order uuid)
returns table(occurred_at timestamptz, from_stage text, to_stage text, event_type text, result text, notes text)
language sql security definer set search_path = public, app stable as $$
  select e.occurred_at, e.from_stage, e.to_stage, e.event_type, e.result, e.notes
  from public.logistics_order_events e
  where e.order_id=p_order and e.company_id=p_company and e.deleted_at is null and app.can_access_company(p_company)
  order by e.occurred_at;
$$;
grant execute on function public.lom_order_timeline(uuid,uuid) to authenticated;

-- motor auto-descoberto pelo LAIOS (padrão *_insights)
create or replace function public.lom_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_blk int; v_sla int; v_stuck int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'LOM%' and deleted_at is null;

  select count(*) into v_blk from public.logistics_orders where company_id=p_company and status='blocked' and deleted_at is null;
  if v_blk > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'LOM: ordens logísticas bloqueadas', v_blk||' ordem(ns) bloqueada(s) na validação.', 'Tratar o bloqueio (estoque/endereço) e liberar.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_sla from public.logistics_orders where company_id=p_company and status='open' and sla_due_at is not null and sla_due_at < now() and deleted_at is null;
  if v_sla > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'critical', 'LOM: SLA estourado', v_sla||' ordem(ns) com SLA vencido ainda aberta(s).', 'Priorizar/escalar imediatamente.', 90);
    v_c := v_c + 1;
  end if;
  select count(*) into v_stuck from public.logistics_orders where company_id=p_company and status='open' and stage not in ('closed') and updated_at < now() - interval '24 hours' and deleted_at is null;
  if v_stuck > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'LOM: ordens paradas há mais de 24h', v_stuck||' ordem(ns) sem avançar de etapa há 24h+.', 'Verificar gargalo na etapa atual.', 72);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.lom_insights(uuid) to authenticated;

notify pgrst, 'reload schema';
