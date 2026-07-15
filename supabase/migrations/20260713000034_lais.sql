-- 20260713000034_lais.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  LAIS — LOGISTICS AUDIT & INTELLIGENCE SYSTEM (Vol 6)                      ║
-- ║  Auditoria contínua da operação: acha perdas, desperdícios e divergências ║
-- ║  reusando freight_divergences, rma, shipments, dispatches, cost_entries.  ║
-- ║  Custos/rentabilidade, matriz de risco, oportunidades de economia e IGEL  ║
-- ║  (Índice Global de Eficiência Logística 0-100). Recurso 'controltower'.   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- (nível de risco é texto gerado — cast p/ enum em generated column não é imutável)

-- ── LOGISTICS_AUDIT_FINDINGS (achados da auditoria contínua) ────────────────
create table public.logistics_audit_findings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  finding_type text not null, category text, severity public.event_severity not null default 'warning',
  description text, financial_impact numeric(18,2), reference_type text, reference_id uuid,
  status text not null default 'open', action_plan text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_logistics_audit_findings_status on public.logistics_audit_findings (company_id, status) where deleted_at is null;

-- ── SAVINGS_OPPORTUNITIES (centro de oportunidades) ─────────────────────────
create table public.savings_opportunities (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  title text not null, category text, description text, estimated_savings numeric(18,2),
  sla_impact text, implementation_time text, status text not null default 'open',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_savings_opportunities_status on public.savings_opportunities (company_id, status) where deleted_at is null;

-- ── LOGISTICS_RISKS (matriz de risco: probabilidade × impacto) ──────────────
create table public.logistics_risks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  title text not null, area text, probability integer not null default 1, impact integer not null default 1,
  level text generated always as (
    case when probability*impact >= 20 then 'critical'
         when probability*impact >= 12 then 'high'
         when probability*impact >= 6  then 'medium'
         when probability*impact >= 3  then 'low' else 'very_low' end) stored,
  financial_value numeric(18,2), action_plan text, owner_id uuid references auth.users(id),
  status text not null default 'open',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_logistics_risks_level on public.logistics_risks (company_id, level) where deleted_at is null;

-- ── RPC: motor de auditoria contínua ────────────────────────────────────────
create or replace function public.run_logistics_audit(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_sum numeric; v_n int;
begin
  if not app.has_permission('controltower.update', p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logistics_audit_findings set status='dismissed' where company_id=p_company and status='open' and deleted_at is null;

  -- 1) divergências de frete (cobranças indevidas)
  select coalesce(sum(difference),0), count(*) into v_sum, v_n from public.freight_divergences where company_id=p_company and status='open' and deleted_at is null;
  if v_n > 0 then
    insert into public.logistics_audit_findings (tenant_id, company_id, finding_type, category, severity, description, financial_impact, action_plan)
    values (v_tenant, p_company, 'freight_divergence', 'frete', 'warning', v_n||' divergência(s) de frete detectada(s).', v_sum, 'Contestar cobranças junto à transportadora/Correios.');
    v_count := v_count + 1;
  end if;

  -- 2) devoluções recebidas sem processamento (item pendente)
  select count(*) into v_n from public.rma_items i join public.rma_requests r on r.id=i.rma_id
    where i.company_id=p_company and i.disposition='pending' and r.status in ('received','inspecting') and i.deleted_at is null;
  if v_n > 0 then
    insert into public.logistics_audit_findings (tenant_id, company_id, finding_type, category, severity, description, action_plan)
    values (v_tenant, p_company, 'return_not_processed', 'devolução', 'warning', v_n||' item(ns) de devolução recebido(s) sem disposição/reintegração.', 'Concluir a conferência e reintegrar/descartar.');
    v_count := v_count + 1;
  end if;

  -- 3) objetos postados sem 1ª movimentação
  select count(*) into v_n from public.dispatches where company_id=p_company and posted_at is not null and first_movement_at is null and posted_at < now()-interval '24 hours' and deleted_at is null;
  if v_n > 0 then
    insert into public.logistics_audit_findings (tenant_id, company_id, finding_type, category, severity, description, action_plan)
    values (v_tenant, p_company, 'no_movement', 'transporte', 'critical', v_n||' objeto(s) sem 1ª movimentação há +24h (risco de extravio).', 'Acionar transportadora/Correios.');
    v_count := v_count + 1;
  end if;

  -- 4) pedidos confirmados há +3 dias sem embarque
  select count(*) into v_n from public.outbound_orders where company_id=p_company and status in ('confirmed','allocated','picking','packed') and order_date < now()::date - 3 and deleted_at is null;
  if v_n > 0 then
    insert into public.logistics_audit_findings (tenant_id, company_id, finding_type, category, severity, description, action_plan)
    values (v_tenant, p_company, 'not_shipped', 'expedição', 'warning', v_n||' pedido(s) confirmado(s) há +3 dias sem embarque.', 'Priorizar a expedição.');
    v_count := v_count + 1;
  end if;

  return v_count;
end;
$$;
grant execute on function public.run_logistics_audit(uuid) to authenticated;

-- ── RPC: IGEL — Índice Global de Eficiência Logística (0-100) ───────────────
create or replace function public.compute_igel(p_company uuid)
returns numeric
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_otif numeric; v_returns int; v_orders int; v_div numeric; v_avg_score numeric; v_igel numeric;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;

  select round(100.0 * count(*) filter (where delivered_at::date <= estimated_delivery) / nullif(count(*) filter (where status='delivered' and estimated_delivery is not null),0),1)
    into v_otif from public.shipments where company_id=p_company and deleted_at is null;
  select count(*) into v_returns from public.rma_requests where company_id=p_company and deleted_at is null;
  select count(*) into v_orders from public.outbound_orders where company_id=p_company and deleted_at is null;
  select coalesce(sum(difference),0) into v_div from public.freight_divergences where company_id=p_company and status='open' and deleted_at is null;
  select coalesce(avg(score),100) into v_avg_score from public.operational_scores where company_id=p_company and area <> 'IGEL' and deleted_at is null;

  -- composição: OTIF(40%) + score médio das áreas(40%) + penalidade devoluções + penalidade divergências
  v_igel := 0.4 * coalesce(v_otif,100) + 0.4 * coalesce(v_avg_score,100)
          + 0.2 * greatest(0, 100 - (case when v_orders>0 then 100.0*v_returns/v_orders else 0 end) - least(20, v_div/100));
  v_igel := least(round(v_igel,1), 100);

  insert into public.operational_scores (tenant_id, company_id, area, score, computed_at)
  values (v_tenant, p_company, 'IGEL', v_igel, now())
  on conflict (company_id, area) where deleted_at is null do update set score=excluded.score, computed_at=now();
  return v_igel;
end;
$$;
grant execute on function public.compute_igel(uuid) to authenticated;

-- ── RPC: detecta desperdícios → oportunidades de economia ───────────────────
create or replace function public.detect_waste_opportunities(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_div numeric; v_ret int; v_otif numeric;
begin
  if not app.has_permission('controltower.create', p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.savings_opportunities set status='dismissed' where company_id=p_company and status='open' and deleted_at is null;

  select coalesce(sum(difference),0) into v_div from public.freight_divergences where company_id=p_company and status='open' and deleted_at is null;
  if v_div > 0 then
    insert into public.savings_opportunities (tenant_id, company_id, title, category, description, estimated_savings, sla_impact, implementation_time)
    values (v_tenant, p_company, 'Contestar cobranças indevidas de frete', 'frete', 'Recuperar divergências de frete detectadas na auditoria.', v_div, 'nenhum', 'imediato');
    v_count := v_count + 1;
  end if;

  select count(*) into v_ret from public.rma_requests where company_id=p_company and deleted_at is null and created_at > now()-interval '30 days';
  if v_ret >= 5 then
    insert into public.savings_opportunities (tenant_id, company_id, title, category, description, sla_impact, implementation_time)
    values (v_tenant, p_company, 'Reduzir índice de devoluções', 'devoluções', v_ret||' devoluções em 30 dias — investigar causas (produto/transporte/expedição).', 'positivo', 'médio prazo');
    v_count := v_count + 1;
  end if;

  select round(100.0 * count(*) filter (where delivered_at::date <= estimated_delivery) / nullif(count(*) filter (where status='delivered' and estimated_delivery is not null),0),1)
    into v_otif from public.shipments where company_id=p_company and deleted_at is null;
  if v_otif is not null and v_otif < 90 then
    insert into public.savings_opportunities (tenant_id, company_id, title, category, description, sla_impact, implementation_time)
    values (v_tenant, p_company, 'Rever transportadoras com baixo OTIF', 'transporte', 'OTIF em '||v_otif||'% — considerar redistribuir carga p/ transportadoras melhores.', 'positivo', 'curto prazo');
    v_count := v_count + 1;
  end if;
  return v_count;
end;
$$;
grant execute on function public.detect_waste_opportunities(uuid) to authenticated;

-- ── RPC: custo por transportadora (real, dos embarques) ─────────────────────
create or replace function public.cost_by_carrier(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(jsonb_build_object('carrier', coalesce(c.name,'(sem transportadora)'), 'shipments', x.n, 'freight_total', x.total, 'avg_freight', round(x.total/nullif(x.n,0),2)) order by x.total desc)
    from (select carrier_id, count(*) n, coalesce(sum(freight_value),0) total from public.shipments where company_id=p_company and deleted_at is null group by carrier_id) x
    left join public.carriers c on c.id=x.carrier_id
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.cost_by_carrier(uuid) to authenticated;

-- ── RPC: painel executivo LAIS ──────────────────────────────────────────────
create or replace function public.lais_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'logistics_cost', (select coalesce(sum(freight_value),0) from public.shipments where company_id=p_company and deleted_at is null)
                    + (select coalesce(sum(amount),0) from public.cost_entries where company_id=p_company and cost_type in ('freight','overhead') and is_planned=false and deleted_at is null),
    'orders_delivered', (select count(*) from public.outbound_orders where company_id=p_company and status in ('shipped','delivered') and deleted_at is null),
    'lost_returns', (select coalesce(sum(total_value),0) from public.rma_requests where company_id=p_company and deleted_at is null),
    'freight_divergence', (select coalesce(sum(difference),0) from public.freight_divergences where company_id=p_company and status='open' and deleted_at is null),
    'open_findings', (select count(*) from public.logistics_audit_findings where company_id=p_company and status='open' and deleted_at is null),
    'potential_savings', (select coalesce(sum(estimated_savings),0) from public.savings_opportunities where company_id=p_company and status='open' and deleted_at is null),
    'open_opportunities', (select count(*) from public.savings_opportunities where company_id=p_company and status='open' and deleted_at is null),
    'critical_risks', (select count(*) from public.logistics_risks where company_id=p_company and level in ('high','critical') and status='open' and deleted_at is null),
    'igel', (select score from public.operational_scores where company_id=p_company and area='IGEL' and deleted_at is null),
    'otif', (select round(100.0 * count(*) filter (where delivered_at::date <= estimated_delivery) / nullif(count(*) filter (where status='delivered' and estimated_delivery is not null),0),1) from public.shipments where company_id=p_company and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.lais_dashboard(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela ────────────────────────────
do $do$
declare t text; specs text[] := array['logistics_audit_findings','savings_opportunities','logistics_risks'];
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
