-- 20260713000029_rma.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  MÓDULO RMA — DEVOLUÇÕES + LOGÍSTICA REVERSA + QC + REINTEGRAÇÃO           ║
-- ║  Nível SAP EWM Returns / Oracle SCM / Manhattan / Blue Yonder.            ║
-- ║  Solicitação → logística reversa → recebimento → conferência (checklist)  ║
-- ║  → classificação/disposição → reintegração automática ao estoque.         ║
-- ║  Integra customers, outbound_orders, product_lots, warehouses e o motor   ║
-- ║  de estoque (register_stock_movement 'return_in'). Recurso RBAC 'returns'.║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.rma_status      as enum ('open','in_transit','received','inspecting','approved','partially_approved','rejected','refunded','exchanged','reshipped','closed','canceled');
create type public.rma_channel     as enum ('customer','sac','sales','marketplace','finance','tech_assistance','supervisor','api','ai');
create type public.rma_resolution  as enum ('none','refund','exchange','reship','credit');
create type public.rma_disposition as enum ('pending','approved_stock','rework','quality','lab','disposal','supplier','tech_assistance','quarantine','analysis','recycling','rejected');

-- recurso RBAC dedicado
insert into public.permissions (slug, resource, action, description)
select 'returns.' || a, 'returns', a, 'Permissão ' || a || ' em returns'
from unnest(array['read','create','update','delete','approve','export']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'returns' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── RETURN_REASONS (motivos configuráveis) ──────────────────────────────────
create table public.return_reasons (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, name text not null, category text, requires_photo boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── RMA_REQUESTS (cabeçalho da devolução) ───────────────────────────────────
create table public.rma_requests (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  customer_id uuid references public.customers(id) on delete set null,
  outbound_order_id uuid references public.outbound_orders(id) on delete set null,
  code text, channel public.rma_channel not null default 'customer',
  status public.rma_status not null default 'open', resolution public.rma_resolution not null default 'none',
  document text, invoice_number text, purchase_date date, delivery_date date,
  carrier_name text, tracking_code text, reverse_tracking_code text,
  total_value numeric(18,2), refund_amount numeric(18,2), description text, notes text,
  opened_by uuid references auth.users(id), closed_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_rma_requests_status on public.rma_requests (company_id, status) where deleted_at is null;
create index idx_rma_requests_customer on public.rma_requests (customer_id);
create unique index uq_rma_requests_code on public.rma_requests (company_id, code) where code is not null and deleted_at is null;

-- ── RMA_ITEMS (itens devolvidos) ────────────────────────────────────────────
create table public.rma_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  rma_id uuid not null references public.rma_requests(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  reason_id uuid references public.return_reasons(id) on delete set null,
  sku text, quantity_requested numeric(18,3) not null default 1,
  quantity_received numeric(18,3) not null default 0, quantity_approved numeric(18,3) not null default 0,
  disposition public.rma_disposition not null default 'pending',
  unit_value numeric(18,4), condition_notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_rma_items_rma on public.rma_items (rma_id);
create index idx_rma_items_product on public.rma_items (product_id);

-- ── RMA_INSPECTIONS (conferência inteligente — checklist em jsonb) ──────────
create table public.rma_inspections (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  rma_item_id uuid not null references public.rma_items(id) on delete cascade,
  inspector_id uuid references auth.users(id),
  checklist jsonb not null default '{}'::jsonb,      -- {received, qty_ok, packaging_ok, seal_ok, opened, used, contaminated, expired, near_expiry, damages, stains, humidity, odor, color_changed, weight_ok, volume_ok}
  verdict public.rma_disposition, weight_received numeric(14,3), notes text, inspected_at timestamptz default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_rma_inspections_item on public.rma_inspections (rma_item_id);

-- ── RMA_EVENTS (trilha de status/histórico) ─────────────────────────────────
create table public.rma_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  rma_id uuid not null references public.rma_requests(id) on delete cascade,
  event_type text not null, from_status text, to_status text, actor_id uuid references auth.users(id), notes text,
  occurred_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_rma_events_rma on public.rma_events (rma_id, occurred_at desc);

-- ── Trigger: gera código RMA-YYYY-NNNNNN por empresa/ano ────────────────────
create or replace function app.tg_rma_code() returns trigger
language plpgsql security definer set search_path = public, app as $$
begin
  if new.code is null then
    new.code := 'RMA-' || to_char(now(),'YYYY') || '-' || lpad((
      coalesce((select count(*) from public.rma_requests
                where company_id = new.company_id
                  and extract(year from created_at) = extract(year from now())), 0) + 1
    )::text, 6, '0');
  end if;
  return new;
end;
$$;
create trigger trg_rma_requests_code before insert on public.rma_requests
  for each row execute function app.tg_rma_code();

-- ── RPC: processa item (disposição) e reintegra ao estoque quando aplicável ─
create or replace function public.process_rma_item(p_item uuid, p_disposition public.rma_disposition, p_warehouse uuid default null, p_quantity numeric default null)
returns void
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_product uuid; v_lot uuid; v_qty numeric;
begin
  select company_id, product_id, lot_id, coalesce(p_quantity, nullif(quantity_received,0), quantity_requested)
    into v_company, v_product, v_lot, v_qty
  from public.rma_items where id = p_item;
  if v_company is null then raise exception 'item de RMA não encontrado'; end if;
  if not app.has_permission('returns.update', v_company) then raise exception 'forbidden'; end if;

  update public.rma_items
     set disposition = p_disposition,
         quantity_approved = case when p_disposition in ('approved_stock','quarantine') then v_qty else quantity_approved end
   where id = p_item;

  -- reintegra ao estoque (entrada por devolução) quando aprovado ou quarentena
  if p_disposition in ('approved_stock','quarantine') and p_warehouse is not null and v_product is not null then
    perform public.register_stock_movement(
      v_product, p_warehouse, 'return_in'::public.stock_movement_type, v_qty,
      null, null, v_lot, null, 'rma_item', p_item, 'Reintegração RMA ('||p_disposition||')');
    if p_disposition = 'quarantine' and v_lot is not null then
      update public.product_lots set quality_status = 'quarantine' where id = v_lot;
    end if;
  end if;
end;
$$;
grant execute on function public.process_rma_item(uuid, public.rma_disposition, uuid, numeric) to authenticated;

-- ── RPC: dashboard de devoluções ────────────────────────────────────────────
create or replace function public.rma_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'open',        (select count(*) from public.rma_requests where company_id=p_company and status not in ('closed','canceled') and deleted_at is null),
    'closed',      (select count(*) from public.rma_requests where company_id=p_company and status='closed' and deleted_at is null),
    'inspecting',  (select count(*) from public.rma_requests where company_id=p_company and status in ('received','inspecting') and deleted_at is null),
    'total',       (select count(*) from public.rma_requests where company_id=p_company and deleted_at is null),
    'value_returned', (select coalesce(sum(total_value),0) from public.rma_requests where company_id=p_company and deleted_at is null),
    'refund_amount',  (select coalesce(sum(refund_amount),0) from public.rma_requests where company_id=p_company and deleted_at is null),
    'quarantine_items', (select count(*) from public.rma_items where company_id=p_company and disposition='quarantine' and deleted_at is null),
    'disposal_items',   (select count(*) from public.rma_items where company_id=p_company and disposition='disposal' and deleted_at is null),
    'avg_days', (select round(avg(extract(epoch from (closed_at - created_at))/86400),1) from public.rma_requests where company_id=p_company and closed_at is not null and deleted_at is null),
    'top_reasons', (select coalesce(jsonb_agg(x), '[]'::jsonb) from (
        select r.name, count(*) c from public.rma_items i join public.return_reasons r on r.id=i.reason_id
        where i.company_id=p_company and i.deleted_at is null group by r.name order by count(*) desc limit 5) x)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.rma_dashboard(uuid) to authenticated;

-- ── RPC: IA — produtos/lotes/clientes mais devolvidos → insights ────────────
create or replace function public.rma_insights(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_r record;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and kind='supplier_risk' and status='new' and title like 'Devoluç%' and deleted_at is null;

  for v_r in
    select p.name, count(*) c from public.rma_items i join public.products p on p.id=i.product_id
    where i.company_id=p_company and i.deleted_at is null group by p.name having count(*) >= 3 order by count(*) desc limit 10
  loop
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'supplier_risk', 'warning', 'Devoluções recorrentes: '||v_r.name,
      v_r.c||' devoluções do produto "'||v_r.name||'".',
      'Investigar causa (fornecedor, lote, transporte) e agir na origem.', 80);
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.rma_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela ────────────────────────────
do $do$
declare t text; specs text[] := array['return_reasons','rma_requests','rma_items','rma_inspections','rma_events'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'returns.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'returns.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;
