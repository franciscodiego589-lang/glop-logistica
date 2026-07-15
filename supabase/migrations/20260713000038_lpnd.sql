-- 20260713000038_lpnd.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  LPND — LOGISTICS PLANNING & NETWORK DESIGN (Vol 10) — Engenharia Log.     ║
-- ║  Digital twin / cenários, mapa de demanda, IA de localização de CD,       ║
-- ║  simulador financeiro (ROI/payback), planejamento de capacidade.          ║
-- ║  Nível SAP IBP / Blue Yonder Network. Recurso RBAC 'controltower'.        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.scenario_status as enum ('draft','simulated','approved','rejected','implemented');

-- ── NETWORK_SCENARIOS (gêmeo digital / centro de decisão) ───────────────────
create table public.network_scenarios (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, scenario_type text, description text, assumptions jsonb not null default '{}'::jsonb,
  capex numeric(18,2), opex_annual numeric(18,2), annual_savings numeric(18,2),
  roi numeric(10,2), payback_months numeric(10,1), sla_impact text,
  status public.scenario_status not null default 'draft', approved_by uuid references auth.users(id), approved_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_network_scenarios_status on public.network_scenarios (company_id, status) where deleted_at is null;

-- ── RPC: mapa de demanda (pedidos por UF) — heatmap ─────────────────────────
create or replace function public.demand_heatmap(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(jsonb_build_object('uf', uf, 'orders', n, 'value', total) order by n desc)
    from (select coalesce(ship_to_uf,'??') uf, count(*) n, coalesce(sum(total),0) total
          from public.outbound_orders where company_id=p_company and deleted_at is null group by ship_to_uf) x
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.demand_heatmap(uuid) to authenticated;

-- ── RPC: IA de localização — regiões com maior potencial para CD/hub ────────
create or replace function public.recommend_cd_location(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(jsonb_build_object(
      'uf', uf, 'orders', n, 'demand_value', total,
      'estimated_annual_saving', round(n * 12 * 6.0, 2),   -- heurística: ~R$6 de frete economizado/pedido/mês com CD local
      'recommendation', 'Alta concentração de demanda em '||uf||' — avaliar CD/hub local para reduzir frete e prazo.'
    ) order by n desc)
    from (select coalesce(ship_to_uf,'??') uf, count(*) n, coalesce(sum(total),0) total
          from public.outbound_orders where company_id=p_company and deleted_at is null
          group by ship_to_uf order by count(*) desc limit 5) x
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.recommend_cd_location(uuid) to authenticated;

-- ── RPC: simulador financeiro do cenário (ROI/payback) ──────────────────────
create or replace function public.simulate_network_finance(p_scenario uuid)
returns jsonb
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_capex numeric; v_opex numeric; v_sav numeric; v_net numeric; v_roi numeric; v_pb numeric;
begin
  select company_id, coalesce(capex,0), coalesce(opex_annual,0), coalesce(annual_savings,0)
    into v_company, v_capex, v_opex, v_sav from public.network_scenarios where id=p_scenario;
  if v_company is null then raise exception 'cenário não encontrado'; end if;
  if not app.has_permission('controltower.update', v_company) then raise exception 'forbidden'; end if;
  v_net := v_sav - v_opex;                                    -- ganho líquido anual
  v_roi := case when v_capex > 0 then round(v_net / v_capex * 100, 1) else null end;
  v_pb  := case when v_net > 0 then round(v_capex / (v_net/12.0), 1) else null end;  -- meses
  update public.network_scenarios set roi=v_roi, payback_months=v_pb, status='simulated' where id=p_scenario;
  return jsonb_build_object('net_annual', v_net, 'roi_percent', v_roi, 'payback_months', v_pb);
end;
$$;
grant execute on function public.simulate_network_finance(uuid) to authenticated;

-- ── RPC: planejamento de capacidade (instalada × utilizada) ─────────────────
create or replace function public.capacity_planning(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'warehouses', (select count(*) from public.warehouses where company_id=p_company and deleted_at is null),
    'locations_total', (select count(*) from public.storage_locations where company_id=p_company and deleted_at is null),
    'locations_used', (select count(distinct location_id) from public.stock_balances where company_id=p_company and location_id is not null and quantity>0 and deleted_at is null),
    'docks_total', (select count(*) from public.docks where company_id=p_company and deleted_at is null),
    'docks_available', (select count(*) from public.docks where company_id=p_company and status='available' and deleted_at is null),
    'vehicles', (select count(*) from public.vehicles where company_id=p_company and deleted_at is null),
    'orders_backlog', (select count(*) from public.outbound_orders where company_id=p_company and status in ('confirmed','allocated','picking','packed') and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.capacity_planning(uuid) to authenticated;

-- ── RPC: dashboard LPND ─────────────────────────────────────────────────────
create or replace function public.lpnd_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'warehouses', (select count(*) from public.warehouses where company_id=p_company and deleted_at is null),
    'ufs_with_demand', (select count(distinct ship_to_uf) from public.outbound_orders where company_id=p_company and ship_to_uf is not null and deleted_at is null),
    'total_orders', (select count(*) from public.outbound_orders where company_id=p_company and deleted_at is null),
    'scenarios', (select count(*) from public.network_scenarios where company_id=p_company and deleted_at is null),
    'scenarios_approved', (select count(*) from public.network_scenarios where company_id=p_company and status='approved' and deleted_at is null),
    'potential_savings', (select coalesce(sum(annual_savings),0) from public.network_scenarios where company_id=p_company and status in ('simulated','approved') and deleted_at is null),
    'best_roi', (select max(roi) from public.network_scenarios where company_id=p_company and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.lpnd_dashboard(uuid) to authenticated;

-- ── RPC: IA — oportunidade de rede (top UF de demanda) → insight ────────────
create or replace function public.lpnd_insights(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_top record;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and kind='opportunity' and status='new' and title like 'Rede%' and deleted_at is null;

  select coalesce(ship_to_uf,'??') uf, count(*) n into v_top from public.outbound_orders
    where company_id=p_company and deleted_at is null group by ship_to_uf order by count(*) desc limit 1;
  if v_top.n is not null and v_top.n >= 10 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, impact_value, confidence)
    values (v_tenant, p_company, 'opportunity', 'info', 'Rede: potencial de CD em '||v_top.uf,
      v_top.n||' pedidos concentrados em '||v_top.uf||' — candidato a CD/hub.',
      'Simular abertura de CD para reduzir frete e prazo.', round(v_top.n*72.0,2), 75);
    v_count := v_count + 1;
  end if;
  return v_count;
end;
$$;
grant execute on function public.lpnd_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant ───────────────────────────────────────
alter table public.network_scenarios enable row level security;
create trigger trg_network_scenarios_touch before insert or update on public.network_scenarios for each row execute function app.tg_touch_row();
create trigger trg_network_scenarios_audit after insert or update or delete on public.network_scenarios for each row execute function app.tg_write_audit();
create policy network_scenarios_select on public.network_scenarios for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));
create policy network_scenarios_insert on public.network_scenarios for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission('controltower.create', company_id));
create policy network_scenarios_update on public.network_scenarios for update to authenticated using (app.can_access_company(company_id) and app.has_permission('controltower.update', company_id)) with check (app.can_access_company(company_id));
create policy network_scenarios_delete on public.network_scenarios for delete to authenticated using (app.is_superadmin());
grant select, insert, update, delete on public.network_scenarios to authenticated;
