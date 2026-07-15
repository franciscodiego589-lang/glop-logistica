-- ============================================================================
-- VOLUME 45 · CMS — CUSTOMS MANAGEMENT SYSTEM (migration 079)
-- Fluxo aduaneiro OPERACIONAL sobre embarques (intl_shipments/trade_processes):
-- processos aduaneiros, recintos alfandegados, canais (verde/amarelo/vermelho/
-- cinza), documentação, inspeções, eventos, liberação/retenção, SLA de desembaraço.
-- NÃO substitui sistema governamental nem faz escrituração fiscal. Nível SAP GTS/
-- CargoWise Customs/Descartes. Reusa recurso RBAC 'gtm'. Escopo 100% logística.
-- Padrão: colunas-padrão, text+check, grant por-tabela.
-- ============================================================================

-- ── 1) RECINTOS / ZONAS ADUANEIRAS ───────────────────────────────────────────
create table if not exists public.customs_zones (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  name text,
  zone_type text not null default 'seaport' check (zone_type in ('seaport','airport','dry_port','bonded_warehouse','terminal','eadi','intl_logistics_center','border_post')),
  country text, city text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 2) PROCESSOS ADUANEIROS ──────────────────────────────────────────────────
create table if not exists public.customs_processes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null,
  process_type text not null default 'import' check (process_type in ('import','export','temp_admission','temp_export','transit','bonded_warehouse','drawback','special_regime')),
  intl_shipment_id uuid references public.intl_shipments(id) on delete set null,
  trade_process_id uuid references public.trade_processes(id) on delete set null,
  zone_id uuid references public.customs_zones(id) on delete set null,
  broker_id uuid references public.shipping_agents(id) on delete set null,
  country text,
  channel text not null default 'none' check (channel in ('none','green','yellow','red','gray')),
  status text not null default 'registered' check (status in ('registered','in_analysis','channel_assigned','inspection','demand','retained','released','delivered','closed','canceled')),
  responsible text,
  registered_at timestamptz not null default now(),
  released_at timestamptz,
  closed_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 3) DOCUMENTAÇÃO aduaneira ────────────────────────────────────────────────
create table if not exists public.customs_documents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  customs_process_id uuid not null references public.customs_processes(id) on delete cascade,
  doc_type text not null default 'other' check (doc_type in ('bl','awb','house_bl','master_bl','packing_list','commercial_invoice','certificate','license','authorization','manifest','declaration','complementary','other')),
  number text,
  issuer text,
  status text not null default 'pending' check (status in ('pending','submitted','approved','rejected')),
  mandatory boolean not null default false,
  valid_to date,
  file_url text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 4) INSPEÇÕES ─────────────────────────────────────────────────────────────
create table if not exists public.customs_inspections (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  customs_process_id uuid not null references public.customs_processes(id) on delete cascade,
  inspection_type text not null default 'documental' check (inspection_type in ('documental','physical','scan','verification','sampling')),
  scheduled_at timestamptz,
  done_at timestamptz,
  result text not null default 'pending' check (result in ('pending','approved','rejected')),
  findings text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 5) EVENTOS aduaneiros (timeline) ─────────────────────────────────────────
create table if not exists public.customs_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  customs_process_id uuid not null references public.customs_processes(id) on delete cascade,
  event_type text not null default 'arrival' check (event_type in ('arrival','registration','channel_assigned','inspection','demand','retention','release','delivery','closure')),
  location text,
  event_at timestamptz not null default now(),
  notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_customs_proc_ship on public.customs_processes (intl_shipment_id);
create index if not exists idx_customs_proc_zone on public.customs_processes (zone_id);
create index if not exists idx_customs_docs_proc on public.customs_documents (customs_process_id);
create index if not exists idx_customs_insp_proc on public.customs_inspections (customs_process_id);
create index if not exists idx_customs_events_proc on public.customs_events (customs_process_id, event_at);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'gtm') ────────────
do $do$
declare t text; specs text[] := array['customs_zones','customs_processes','customs_documents','customs_inspections','customs_events'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'gtm.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'gtm.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- Parametriza o canal de conferência + registra evento (verde libera direto)
create or replace function public.set_customs_channel(p_company uuid, p_process uuid, p_channel text)
returns public.customs_processes language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.customs_processes;
begin
  if not (app.can_access_company(p_company) and app.has_permission('gtm.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.customs_processes set channel=p_channel,
    status = case when p_channel in ('red','yellow','gray') then 'inspection' else 'channel_assigned' end
    where id=p_process and company_id=p_company returning * into r;
  if r.id is null then raise exception 'Processo não encontrado'; end if;
  insert into public.customs_events (tenant_id, company_id, customs_process_id, event_type, notes)
    values (v_tenant, p_company, p_process, 'channel_assigned', 'Canal '||p_channel);
  return r;
end; $$;
grant execute on function public.set_customs_channel(uuid,uuid,text) to authenticated;

-- Registra inspeção; se reprovada, retém o processo
create or replace function public.record_customs_inspection(p_company uuid, p_process uuid, p_type text, p_result text, p_findings text default null)
returns public.customs_inspections language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.customs_inspections;
begin
  if not (app.can_access_company(p_company) and app.has_permission('gtm.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.customs_inspections (tenant_id, company_id, customs_process_id, inspection_type, result, findings, done_at)
    values (v_tenant, p_company, p_process, coalesce(p_type,'documental'), coalesce(p_result,'pending'), p_findings, now()) returning * into r;
  insert into public.customs_events (tenant_id, company_id, customs_process_id, event_type, notes)
    values (v_tenant, p_company, p_process, 'inspection', coalesce(p_type,'')||': '||coalesce(p_result,''));
  if p_result = 'rejected' then
    update public.customs_processes set status='retained' where id=p_process and company_id=p_company;
    insert into public.customs_events (tenant_id, company_id, customs_process_id, event_type, notes)
      values (v_tenant, p_company, p_process, 'retention', coalesce(p_findings,'Inspeção reprovada'));
  end if;
  return r;
end; $$;
grant execute on function public.record_customs_inspection(uuid,uuid,text,text,text) to authenticated;

-- Libera o desembaraço (BARRA se doc obrigatório pendente ou inspeção reprovada/pendente em canal não-verde)
create or replace function public.release_customs_process(p_company uuid, p_process uuid)
returns public.customs_processes language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.customs_processes; v_channel text; v_pend int; v_badinsp int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('gtm.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select channel into v_channel from public.customs_processes where id=p_process and company_id=p_company;
  if v_channel is null then raise exception 'Processo não encontrado'; end if;

  select count(*) into v_pend from public.customs_documents
    where customs_process_id=p_process and mandatory and status <> 'approved' and deleted_at is null;
  if v_pend > 0 then raise exception 'Não liberável: % documento(s) obrigatório(s) pendente(s)', v_pend; end if;

  if v_channel in ('red','yellow','gray') then
    select count(*) into v_badinsp from public.customs_inspections
      where customs_process_id=p_process and result <> 'approved' and deleted_at is null;
    if v_badinsp > 0 or not exists (select 1 from public.customs_inspections where customs_process_id=p_process and result='approved' and deleted_at is null)
    then raise exception 'Não liberável: canal % exige inspeção aprovada', v_channel; end if;
  end if;

  update public.customs_processes set status='released', released_at=now() where id=p_process and company_id=p_company returning * into r;
  insert into public.customs_events (tenant_id, company_id, customs_process_id, event_type, notes)
    values (v_tenant, p_company, p_process, 'release', 'Desembaraço concluído');
  return r;
end; $$;
grant execute on function public.release_customs_process(uuid,uuid) to authenticated;

create or replace function public.cms_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'processes', (select count(*) from public.customs_processes where company_id=p_company and deleted_at is null),
    'registered', (select count(*) from public.customs_processes where company_id=p_company and status in ('registered','in_analysis','channel_assigned') and deleted_at is null),
    'in_inspection', (select count(*) from public.customs_processes where company_id=p_company and status='inspection' and deleted_at is null),
    'retained', (select count(*) from public.customs_processes where company_id=p_company and status='retained' and deleted_at is null),
    'released', (select count(*) from public.customs_processes where company_id=p_company and status in ('released','delivered','closed') and deleted_at is null),
    'green', (select count(*) from public.customs_processes where company_id=p_company and channel='green' and deleted_at is null),
    'red', (select count(*) from public.customs_processes where company_id=p_company and channel='red' and deleted_at is null),
    'docs_pending', (select count(*) from public.customs_documents where company_id=p_company and status='pending' and deleted_at is null),
    'docs_expiring', (select count(*) from public.customs_documents where company_id=p_company and valid_to is not null and valid_to <= now()::date + 15 and status<>'rejected' and deleted_at is null),
    'avg_clearance_days', (select round(avg(extract(epoch from (released_at - registered_at))/86400.0)::numeric,1) from public.customs_processes where company_id=p_company and released_at is not null and deleted_at is null),
    'zones', (select count(*) from public.customs_zones where company_id=p_company and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.cms_dashboard(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.cms_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_ret int; v_doc int; v_lic int; v_old int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'CMS%' and deleted_at is null;

  select count(*) into v_ret from public.customs_processes where company_id=p_company and status='retained' and deleted_at is null;
  if v_ret > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'critical', 'CMS: cargas retidas na aduana', v_ret||' processo(s) retido(s).', 'Sanar exigência/documentação para liberar; risco de demurrage.', 88);
    v_c := v_c + 1;
  end if;
  select count(*) into v_doc from public.customs_documents where company_id=p_company and mandatory and status<>'approved' and deleted_at is null;
  if v_doc > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'CMS: documentos obrigatórios pendentes', v_doc||' documento(s) obrigatório(s) não aprovado(s).', 'Providenciar/corrigir para permitir o desembaraço.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_lic from public.customs_documents where company_id=p_company and doc_type in ('license','authorization','certificate') and valid_to is not null and valid_to <= now()::date + 15 and valid_to >= now()::date and deleted_at is null;
  if v_lic > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'CMS: licenças vencendo', v_lic||' licença(s)/certificado(s) vencem em 15 dias.', 'Renovar antes do desembaraço para não travar a carga.', 74);
    v_c := v_c + 1;
  end if;
  select count(*) into v_old from public.customs_processes where company_id=p_company and status not in ('released','delivered','closed','canceled') and registered_at < now()-interval '10 days' and deleted_at is null;
  if v_old > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'CMS: desembaraço demorado', v_old||' processo(s) abertos há mais de 10 dias.', 'Priorizar; tempo elevado gera custo de armazenagem.', 78);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.cms_insights(uuid) to authenticated;

-- ── SEED (empresa Matriz Logística) ─────────────────────────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid; v_zone uuid; v_ship uuid; v_proc uuid; v_broker uuid;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;
  if not exists (select 1 from public.customs_zones where company_id=v_company and deleted_at is null) then
    insert into public.customs_zones (tenant_id, company_id, code, name, zone_type, country, city) values
      (v_tenant, v_company, 'PORTO-SSZ', 'Porto de Santos', 'seaport', 'BR', 'Santos'),
      (v_tenant, v_company, 'AERO-GRU', 'Aeroporto de Guarulhos', 'airport', 'BR', 'Guarulhos'),
      (v_tenant, v_company, 'EADI-SP', 'Porto Seco Campinas', 'dry_port', 'BR', 'Campinas');
    select id into v_zone from public.customs_zones where company_id=v_company and code='PORTO-SSZ';
    select id into v_ship from public.intl_shipments where company_id=v_company and code='IMP-0001';
    select id into v_broker from public.shipping_agents where company_id=v_company limit 1;
    insert into public.customs_processes (tenant_id, company_id, code, process_type, intl_shipment_id, zone_id, broker_id, country, channel, status, responsible)
      values (v_tenant, v_company, 'DI-0001', 'import', v_ship, v_zone, v_broker, 'BR', 'none', 'registered', 'Despachante A') returning id into v_proc;
    insert into public.customs_documents (tenant_id, company_id, customs_process_id, doc_type, number, status, mandatory) values
      (v_tenant, v_company, v_proc, 'bl', 'BL-778812', 'approved', true),
      (v_tenant, v_company, v_proc, 'commercial_invoice', 'INV-9931', 'pending', true), -- pendente obrigatório (barra liberação + insight)
      (v_tenant, v_company, v_proc, 'packing_list', 'PL-9931', 'submitted', false);
    insert into public.customs_events (tenant_id, company_id, customs_process_id, event_type, location) values
      (v_tenant, v_company, v_proc, 'arrival', 'Porto de Santos'),
      (v_tenant, v_company, v_proc, 'registration', 'Porto de Santos');
  end if;
end $seed$;

notify pgrst, 'reload schema';
