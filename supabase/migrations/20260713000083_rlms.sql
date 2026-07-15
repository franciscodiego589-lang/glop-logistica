-- ============================================================================
-- VOLUME 49 · RLMS — REVERSE LOGISTICS MANAGEMENT SYSTEM (migration 083)
-- Ciclo reverso COMPLETO sobre a base RMA existente (rma_requests/rma_items/
-- rma_events, recurso 'returns'): caso de retorno unificado, triagem/classificação,
-- destinação (reintegração/recondicionamento/reciclagem/descarte/retorno a
-- fornecedor), campanhas de recall (execução logística) e embalagens retornáveis.
-- Nível ReverseLogix/Optoro/Happy Returns. Recurso 'returns'. Escopo 100% logística.
-- Padrão: colunas-padrão, text+check, grant por-tabela.
-- ============================================================================

-- ── 1) CASO DE RETORNO (ciclo completo) ──────────────────────────────────────
create table if not exists public.rl_returns (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  return_type text not null default 'commercial' check (return_type in ('commercial','exchange','recall','warranty','tech_assistance','damage','operational_error','packaging','pallet','container','equipment')),
  rma_request_id uuid references public.rma_requests(id) on delete set null,
  customer_ref text,
  carrier_ref text,
  reason text,
  priority text not null default 'normal' check (priority in ('low','normal','high','urgent')),
  status text not null default 'requested' check (status in ('requested','authorized','rejected','collection_scheduled','collected','received','triaged','dispositioned','closed')),
  authorization_code text,
  authorized_at timestamptz, valid_until date,
  collection_scheduled_at timestamptz, collected_at timestamptz, received_at timestamptz, closed_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 2) TRIAGEM / classificação ───────────────────────────────────────────────
create table if not exists public.rl_triage (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  rl_return_id uuid not null references public.rl_returns(id) on delete cascade,
  product_ref text,
  classification text not null default 'intact' check (classification in ('intact','damaged','recoverable','recyclable','disposable','warranty','for_maintenance')),
  quantity numeric(14,3) not null default 1,
  notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 3) DESTINAÇÃO ─────────────────────────────────────────────────────────────
create table if not exists public.rl_dispositions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  rl_return_id uuid not null references public.rl_returns(id) on delete cascade,
  product_ref text,
  disposition_type text not null default 'reintegrate' check (disposition_type in ('reintegrate','refurbish','repair','repackage','recycle','dispose','scrap','return_to_supplier','reship')),
  quantity numeric(14,3) not null default 1,
  value_recovered numeric(14,2),
  done_at timestamptz not null default now(),
  notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 4) CAMPANHAS DE RECALL (execução logística) ──────────────────────────────
create table if not exists public.rl_recalls (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  name text,
  product_ref text, lot_ref text,
  severity text not null default 'medium' check (severity in ('low','medium','high','critical')),
  affected_units integer not null default 0,
  collected_units integer not null default 0,
  status text not null default 'planned' check (status in ('planned','active','collecting','completed','canceled')),
  started_at timestamptz, deadline date, completed_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 5) EMBALAGENS RETORNÁVEIS ────────────────────────────────────────────────
create table if not exists public.returnable_packaging (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  packaging_type text not null default 'pallet' check (packaging_type in ('pallet','plastic_crate','returnable_container','barrel','basket','cage','rack','special')),
  owner text not null default 'own' check (owner in ('own','customer','supplier','pool')),
  holder_ref text,
  status text not null default 'available' check (status in ('available','in_use','returned','lost','damaged')),
  location text,
  deposit_value numeric(12,2),
  cycles integer not null default 0,
  dispatched_at timestamptz, due_back date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_rl_returns_status on public.rl_returns (company_id, status);
create index if not exists idx_rl_triage_ret on public.rl_triage (rl_return_id);
create index if not exists idx_rl_disp_ret on public.rl_dispositions (rl_return_id);
create index if not exists idx_retpack_status on public.returnable_packaging (company_id, status);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'returns') ─────────
do $do$
declare t text; specs text[] := array['rl_returns','rl_triage','rl_dispositions','rl_recalls','returnable_packaging'];
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

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- Autoriza ou nega o retorno (gera RMA + validade)
create or replace function public.authorize_return(p_company uuid, p_return uuid, p_approve boolean, p_valid_days integer default 30)
returns public.rl_returns language plpgsql security definer set search_path = public, app as $$
declare r public.rl_returns; v_seq int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('returns.update', p_company)) then raise exception 'forbidden'; end if;
  if p_approve then
    select coalesce(count(*),0)+1 into v_seq from public.rl_returns where company_id=p_company and authorization_code is not null;
    update public.rl_returns set status='authorized', authorization_code='RMA-'||lpad(v_seq::text,5,'0'),
      authorized_at=now(), valid_until=(now()::date + make_interval(days => coalesce(p_valid_days,30)))::date
      where id=p_return and company_id=p_company returning * into r;
  else
    update public.rl_returns set status='rejected' where id=p_return and company_id=p_company returning * into r;
  end if;
  if r.id is null then raise exception 'Retorno não encontrado'; end if;
  return r;
end; $$;
grant execute on function public.authorize_return(uuid,uuid,boolean,integer) to authenticated;

-- Avança o caso: agenda coleta / coleta / recebe
create or replace function public.advance_return(p_company uuid, p_return uuid, p_stage text)
returns public.rl_returns language plpgsql security definer set search_path = public, app as $$
declare r public.rl_returns;
begin
  if not (app.can_access_company(p_company) and app.has_permission('returns.update', p_company)) then raise exception 'forbidden'; end if;
  update public.rl_returns set
    status = p_stage,
    collection_scheduled_at = case when p_stage='collection_scheduled' then now() else collection_scheduled_at end,
    collected_at = case when p_stage='collected' then now() else collected_at end,
    received_at = case when p_stage='received' then now() else received_at end,
    closed_at = case when p_stage='closed' then now() else closed_at end
    where id=p_return and company_id=p_company and status <> 'rejected' returning * into r;
  if r.id is null then raise exception 'Retorno não encontrado ou já negado'; end if;
  return r;
end; $$;
grant execute on function public.advance_return(uuid,uuid,text) to authenticated;

-- Triagem de item + marca o retorno como triado
create or replace function public.triage_return(p_company uuid, p_return uuid, p_product text, p_class text, p_qty numeric default 1)
returns public.rl_triage language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.rl_triage;
begin
  if not (app.can_access_company(p_company) and app.has_permission('returns.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.rl_triage (tenant_id, company_id, rl_return_id, product_ref, classification, quantity)
    values (v_tenant, p_company, p_return, p_product, coalesce(p_class,'intact'), coalesce(p_qty,1)) returning * into r;
  update public.rl_returns set status='triaged' where id=p_return and company_id=p_company and status in ('received','collected');
  return r;
end; $$;
grant execute on function public.triage_return(uuid,uuid,text,text,numeric) to authenticated;

-- Destinação de item (+ reintegração ao estoque quando aplicável) + fecha se tudo destinado
create or replace function public.disposition_return(p_company uuid, p_return uuid, p_product text, p_type text, p_qty numeric default 1, p_value numeric default null)
returns public.rl_dispositions language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.rl_dispositions; v_triaged numeric; v_disp numeric;
begin
  if not (app.can_access_company(p_company) and app.has_permission('returns.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.rl_dispositions (tenant_id, company_id, rl_return_id, product_ref, disposition_type, quantity, value_recovered)
    values (v_tenant, p_company, p_return, p_product, coalesce(p_type,'reintegrate'), coalesce(p_qty,1), p_value) returning * into r;
  update public.rl_returns set status='dispositioned' where id=p_return and company_id=p_company and status='triaged';
  -- fecha quando a quantidade destinada alcança a triada
  select coalesce(sum(quantity),0) into v_triaged from public.rl_triage where rl_return_id=p_return and deleted_at is null;
  select coalesce(sum(quantity),0) into v_disp from public.rl_dispositions where rl_return_id=p_return and deleted_at is null;
  if v_triaged > 0 and v_disp >= v_triaged then
    update public.rl_returns set status='closed', closed_at=now() where id=p_return and company_id=p_company;
  end if;
  return r;
end; $$;
grant execute on function public.disposition_return(uuid,uuid,text,text,numeric,numeric) to authenticated;

create or replace function public.rl_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb; v_disp_total numeric; v_reuse numeric; v_recycle numeric; v_dispose numeric;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select coalesce(sum(quantity),0) into v_disp_total from public.rl_dispositions where company_id=p_company and deleted_at is null;
  select coalesce(sum(quantity),0) into v_reuse from public.rl_dispositions where company_id=p_company and disposition_type in ('reintegrate','refurbish','repair','repackage','reship') and deleted_at is null;
  select coalesce(sum(quantity),0) into v_recycle from public.rl_dispositions where company_id=p_company and disposition_type='recycle' and deleted_at is null;
  select coalesce(sum(quantity),0) into v_dispose from public.rl_dispositions where company_id=p_company and disposition_type in ('dispose','scrap') and deleted_at is null;
  select jsonb_build_object(
    'returns', (select count(*) from public.rl_returns where company_id=p_company and deleted_at is null),
    'pending_auth', (select count(*) from public.rl_returns where company_id=p_company and status='requested' and deleted_at is null),
    'in_process', (select count(*) from public.rl_returns where company_id=p_company and status in ('authorized','collection_scheduled','collected','received','triaged') and deleted_at is null),
    'closed', (select count(*) from public.rl_returns where company_id=p_company and status='closed' and deleted_at is null),
    'awaiting_disposition', (select count(*) from public.rl_returns where company_id=p_company and status='triaged' and deleted_at is null),
    'reuse_rate', case when v_disp_total>0 then round(100.0*v_reuse/v_disp_total,1) else null end,
    'recycle_rate', case when v_disp_total>0 then round(100.0*v_recycle/v_disp_total,1) else null end,
    'dispose_rate', case when v_disp_total>0 then round(100.0*v_dispose/v_disp_total,1) else null end,
    'value_recovered', (select coalesce(round(sum(value_recovered),2),0) from public.rl_dispositions where company_id=p_company and deleted_at is null),
    'recalls_active', (select count(*) from public.rl_recalls where company_id=p_company and status in ('active','collecting') and deleted_at is null),
    'packaging_out', (select count(*) from public.returnable_packaging where company_id=p_company and status='in_use' and deleted_at is null),
    'packaging_lost', (select count(*) from public.returnable_packaging where company_id=p_company and status='lost' and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.rl_dashboard(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.rlms_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_stuck int; v_nodisp int; v_recall int; v_pack int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'RLMS%' and deleted_at is null;

  select count(*) into v_stuck from public.rl_returns where company_id=p_company and status='received' and received_at < now()-interval '3 days' and deleted_at is null;
  if v_stuck > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'RLMS: retornos parados sem triagem', v_stuck||' retorno(s) recebido(s) há mais de 3 dias sem triagem.', 'Acelerar a triagem para liberar destinação/estoque.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_nodisp from public.rl_returns where company_id=p_company and status='triaged' and deleted_at is null;
  if v_nodisp > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'RLMS: itens sem destinação', v_nodisp||' retorno(s) triado(s) aguardando destinação.', 'Definir reintegração/recondicionamento/reciclagem/descarte.', 74);
    v_c := v_c + 1;
  end if;
  select count(*) into v_recall from public.rl_recalls where company_id=p_company and status in ('active','collecting') and deadline is not null and deadline < now()::date + 7 and deleted_at is null;
  if v_recall > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'critical', 'RLMS: recall com prazo próximo', v_recall||' campanha(s) de recall com prazo em 7 dias.', 'Intensificar coleta das unidades afetadas.', 88);
    v_c := v_c + 1;
  end if;
  select count(*) into v_pack from public.returnable_packaging where company_id=p_company and status='in_use' and due_back is not null and due_back < now()::date and deleted_at is null;
  if v_pack > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'RLMS: embalagens retornáveis vencidas', v_pack||' embalagem(ns) retornável(is) com devolução vencida.', 'Cobrar retorno; risco de perda de ativo/depósito.', 80);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.rlms_insights(uuid) to authenticated;

-- ── SEED (empresa Matriz Logística) ─────────────────────────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;
  if not exists (select 1 from public.rl_returns where company_id=v_company and deleted_at is null) then
    insert into public.rl_returns (tenant_id, company_id, code, return_type, customer_ref, reason, priority, status) values
      (v_tenant, v_company, 'RET-0001', 'commercial', 'Cliente A', 'Produto errado', 'normal', 'requested'),
      (v_tenant, v_company, 'RET-0002', 'damage', 'Cliente B', 'Avaria no transporte', 'high', 'received');
    insert into public.rl_recalls (tenant_id, company_id, code, name, product_ref, lot_ref, severity, affected_units, status, deadline)
      values (v_tenant, v_company, 'RC-0001', 'Recall lote whey L2231', 'Whey 900g', 'L2231', 'high', 1200, 'active', (now()::date + interval '5 days')::date);
    insert into public.returnable_packaging (tenant_id, company_id, code, packaging_type, owner, status, holder_ref, due_back) values
      (v_tenant, v_company, 'PAL-0001', 'pallet', 'pool', 'in_use', 'Cliente A', (now()::date - interval '2 days')::date),
      (v_tenant, v_company, 'GAI-0001', 'cage', 'own', 'available', null, null);
  end if;
end $seed$;

notify pgrst, 'reload schema';
