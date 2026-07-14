-- 20260713000023_qms.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 08 — QMS (Quality Management System)                               ║
-- ║  Nível SAP QM / Oracle Quality / MasterControl / ETQ / Opcenter Quality.  ║
-- ║  Especificações · planos de inspeção/amostragem · inspeções (receb/proc/  ║
-- ║  final) + resultados · NC · CAPA · auditorias · riscos (FMEA) · documentos║
-- ║  · treinamentos · reclamações · recall · CoA · estabilidade · validações  ║
-- ║  · liberação de lote. Integra WMS/PCP/MES/Compras via product_lots.        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.qms_inspection_type   as enum ('receiving','in_process','final','supplier','periodic');
create type public.qms_inspection_result as enum ('pending','approved','rejected','conditional');
create type public.qms_nc_severity       as enum ('minor','major','critical');
create type public.qms_nc_status         as enum ('open','investigating','action','verifying','closed','canceled');
create type public.qms_capa_status       as enum ('open','investigation','action_plan','implementing','verifying','effective','closed','canceled');
create type public.qms_audit_type        as enum ('internal','external','supplier','customer','regulatory');
create type public.qms_audit_status      as enum ('planned','in_progress','closed','canceled');
create type public.qms_risk_method       as enum ('fmea','matrix','haccp','impact');
create type public.qms_complaint_status  as enum ('open','investigating','responded','closed');
create type public.qms_recall_type       as enum ('simulation','partial','total');
create type public.qms_doc_status        as enum ('draft','review','approved','obsolete');
create type public.qms_validation_type   as enum ('iq','oq','pq','process','cleaning','csv');
create type public.qms_release_status    as enum ('pending','sampling','testing','review','released','rejected','quarantine');

-- ── QUALITY_SPECIFICATIONS (parâmetros de especificação por produto) ────────
create table public.quality_specifications (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid references public.products(id) on delete cascade,
  parameter text not null, method text, unit text,
  min_value numeric(18,6), max_value numeric(18,6), target_value numeric(18,6), is_critical boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_quality_specifications_product on public.quality_specifications (product_id);

-- ── INSPECTION_PLANS + itens (planos de inspeção/amostragem) ────────────────
create table public.inspection_plans (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid references public.products(id) on delete set null,
  code text, name text not null, inspection_type public.qms_inspection_type not null default 'receiving',
  sampling_plan text, aql numeric(6,3),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_inspection_plans_product on public.inspection_plans (product_id);

create table public.inspection_plan_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  plan_id uuid not null references public.inspection_plans(id) on delete cascade,
  parameter text not null, method text, unit text,
  min_value numeric(18,6), max_value numeric(18,6), target_value numeric(18,6), is_critical boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_inspection_plan_items_plan on public.inspection_plan_items (plan_id);

-- ── QUALITY_INSPECTIONS + resultados ────────────────────────────────────────
create table public.quality_inspections (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  plan_id uuid references public.inspection_plans(id) on delete set null,
  product_id uuid references public.products(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  supplier_id uuid references public.suppliers(id) on delete set null,
  code text, inspection_type public.qms_inspection_type not null default 'receiving',
  result public.qms_inspection_result not null default 'pending',
  reference_type text, reference_id uuid,
  inspector_id uuid references auth.users(id), inspected_at timestamptz, sample_size numeric(12,3), notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_quality_inspections_status on public.quality_inspections (company_id, result) where deleted_at is null;
create index idx_quality_inspections_lot on public.quality_inspections (lot_id);

create table public.inspection_results (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  inspection_id uuid not null references public.quality_inspections(id) on delete cascade,
  parameter text not null, measured_value numeric(18,6), text_value text, unit text,
  min_value numeric(18,6), max_value numeric(18,6),
  conforms boolean generated always as (
    measured_value is null
    or ((min_value is null or measured_value >= min_value) and (max_value is null or measured_value <= max_value))
  ) stored,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_inspection_results_inspection on public.inspection_results (inspection_id);

-- ── NONCONFORMITIES (NC) ────────────────────────────────────────────────────
create table public.nonconformities (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, nc_type text, source text, severity public.qms_nc_severity not null default 'minor',
  status public.qms_nc_status not null default 'open',
  product_id uuid references public.products(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  inspection_id uuid references public.quality_inspections(id) on delete set null,
  title text not null, description text, impact text,
  responsible_id uuid references auth.users(id), opened_at timestamptz not null default now(), closed_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_nonconformities_status on public.nonconformities (company_id, status) where deleted_at is null;

-- ── CAPAS ───────────────────────────────────────────────────────────────────
create table public.capas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  nonconformity_id uuid references public.nonconformities(id) on delete set null,
  code text, title text not null, status public.qms_capa_status not null default 'open',
  investigation text, root_cause text, action_plan text,
  responsible_id uuid references auth.users(id), due_date date,
  effectiveness_check text, effective boolean, verified_by uuid references auth.users(id), closed_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_capas_status on public.capas (company_id, status) where deleted_at is null;

-- ── QUALITY_AUDITS + findings ───────────────────────────────────────────────
create table public.quality_audits (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, audit_type public.qms_audit_type not null default 'internal', status public.qms_audit_status not null default 'planned',
  scope text, standard text, auditor text, supplier_id uuid references public.suppliers(id) on delete set null,
  planned_date date, executed_date date, score numeric(5,2),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_quality_audits_status on public.quality_audits (company_id, status) where deleted_at is null;

create table public.audit_findings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  audit_id uuid not null references public.quality_audits(id) on delete cascade,
  description text not null, severity public.qms_nc_severity not null default 'minor', status text not null default 'open',
  action text, capa_id uuid references public.capas(id) on delete set null,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_audit_findings_audit on public.audit_findings (audit_id);

-- ── QUALITY_RISKS (FMEA: RPN = severity × occurrence × detection) ───────────
create table public.quality_risks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  method public.qms_risk_method not null default 'fmea', scope text, process text,
  failure_mode text not null, effect text, cause text,
  severity integer not null default 1, occurrence integer not null default 1, detection integer not null default 1,
  rpn integer generated always as (severity * occurrence * detection) stored,
  mitigation text, responsible_id uuid references auth.users(id), status text not null default 'open',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_quality_risks_rpn on public.quality_risks (company_id, rpn desc) where deleted_at is null;

-- ── QUALITY_DOCUMENTS (gestão documental com versão/aprovação) ──────────────
create table public.quality_documents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, doc_type text, title text not null, doc_version text not null default '1.0',
  status public.qms_doc_status not null default 'draft', content_url text, storage_path text,
  approved_by uuid references auth.users(id), approved_at timestamptz, effective_date date, review_date date,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_quality_documents_status on public.quality_documents (company_id, status) where deleted_at is null;

-- ── TRAININGS + records (treinamentos obrigatórios) ─────────────────────────
create table public.trainings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, title text not null, description text, mandatory boolean not null default false, valid_days integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create table public.training_records (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  training_id uuid not null references public.trainings(id) on delete cascade,
  user_id uuid references auth.users(id) on delete set null,
  completed_at date, expires_at date, score numeric(5,2), status text not null default 'completed',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_training_records_training on public.training_records (training_id);

-- ── COMPLAINTS (reclamações) ────────────────────────────────────────────────
create table public.complaints (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, customer_id uuid references public.customers(id) on delete set null,
  product_id uuid references public.products(id) on delete set null, lot_id uuid references public.product_lots(id) on delete set null,
  title text not null, description text, status public.qms_complaint_status not null default 'open',
  investigation text, root_cause text, response text, capa_id uuid references public.capas(id) on delete set null,
  opened_at timestamptz not null default now(), closed_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_complaints_status on public.complaints (company_id, status) where deleted_at is null;

-- ── RECALLS ─────────────────────────────────────────────────────────────────
create table public.recalls (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, recall_type public.qms_recall_type not null default 'simulation',
  product_id uuid references public.products(id) on delete set null, lot_id uuid references public.product_lots(id) on delete set null,
  reason text, status text not null default 'open',
  quantity_affected numeric(18,3), quantity_recovered numeric(18,3),
  opened_at timestamptz not null default now(), closed_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_recalls_status on public.recalls (company_id, status) where deleted_at is null;

-- ── CERTIFICATES_OF_ANALYSIS (CoA) ──────────────────────────────────────────
create table public.certificates_of_analysis (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid references public.products(id) on delete set null, lot_id uuid references public.product_lots(id) on delete set null,
  supplier_id uuid references public.suppliers(id) on delete set null,
  coa_number text, issued_at date, url text, storage_path text, approved boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_coa_lot on public.certificates_of_analysis (lot_id);

-- ── STABILITY_STUDIES (shelf life) ──────────────────────────────────────────
create table public.stability_studies (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid references public.products(id) on delete set null, lot_id uuid references public.product_lots(id) on delete set null,
  code text, condition text, start_date date, duration_days integer, status text not null default 'ongoing', results jsonb not null default '[]'::jsonb,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_stability_studies_product on public.stability_studies (product_id);

-- ── VALIDATIONS (IQ/OQ/PQ, processo, limpeza, CSV) ──────────────────────────
create table public.validations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, validation_type public.qms_validation_type not null default 'process', scope text, target text,
  status text not null default 'planned', executed_at date, approved_by uuid references auth.users(id), result text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_validations_status on public.validations (company_id, status) where deleted_at is null;

-- ── BATCH_RELEASES (liberação de lote) ──────────────────────────────────────
create table public.batch_releases (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  lot_id uuid not null references public.product_lots(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  status public.qms_release_status not null default 'pending',
  sampled_at timestamptz, tested_at timestamptz, decision text,
  released_by uuid references auth.users(id), released_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_batch_releases_lot on public.batch_releases (lot_id);

-- ── Permissões quality.* + concessão aos papéis admin/superadmin existentes ─
insert into public.permissions (slug, resource, action, description)
select 'quality.' || a, 'quality', a, 'Permissão ' || a || ' em quality'
from unnest(array['read','create','update','delete','approve','export']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'quality' and (r.slug in ('admin','superadmin'))
on conflict do nothing;

-- ── RPC: libera/quarentena/rejeita lote (integra com product_lots) ──────────
create or replace function public.release_batch(p_lot uuid, p_decision text, p_notes text default null)
returns uuid
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_tenant uuid; v_product uuid; v_qs text; v_rel uuid; v_status public.qms_release_status;
begin
  select company_id, tenant_id, product_id into v_company, v_tenant, v_product from public.product_lots where id = p_lot;
  if v_company is null then raise exception 'lote % não encontrado', p_lot; end if;
  if not app.has_permission('quality.approve', v_company) then raise exception 'forbidden'; end if;

  v_status := case p_decision
    when 'released' then 'released' when 'rejected' then 'rejected' else 'quarantine' end::public.qms_release_status;
  v_qs := case p_decision when 'released' then 'released' when 'rejected' then 'blocked' else 'quarantine' end;

  update public.product_lots set quality_status = v_qs where id = p_lot;

  insert into public.batch_releases (tenant_id, company_id, lot_id, product_id, status, decision, tested_at,
     released_by, released_at, notes)
  values (v_tenant, v_company, p_lot, v_product, v_status, p_decision, now(),
     case when p_decision='released' then auth.uid() end,
     case when p_decision='released' then now() end, p_notes)
  returning id into v_rel;
  return v_rel;
end;
$$;
grant execute on function public.release_batch(uuid, text, text) to authenticated;

-- ── RPC: dashboard de qualidade (KPIs) ──────────────────────────────────────
create or replace function public.quality_dashboard(p_company uuid)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select jsonb_build_object(
    'nc_open',          (select count(*) from public.nonconformities where company_id=p_company and status not in ('closed','canceled') and deleted_at is null),
    'nc_critical',      (select count(*) from public.nonconformities where company_id=p_company and severity='critical' and status not in ('closed','canceled') and deleted_at is null),
    'capa_open',        (select count(*) from public.capas where company_id=p_company and status not in ('closed','canceled') and deleted_at is null),
    'capa_overdue',     (select count(*) from public.capas where company_id=p_company and due_date < now()::date and status not in ('closed','canceled') and deleted_at is null),
    'audits_planned',   (select count(*) from public.quality_audits where company_id=p_company and status in ('planned','in_progress') and deleted_at is null),
    'complaints_open',  (select count(*) from public.complaints where company_id=p_company and status not in ('closed') and deleted_at is null),
    'inspections_pending',(select count(*) from public.quality_inspections where company_id=p_company and result='pending' and deleted_at is null),
    'approval_rate',    (select round(100.0 * count(*) filter (where result='approved') / nullif(count(*) filter (where result in ('approved','rejected')),0), 1)
                          from public.quality_inspections where company_id=p_company and deleted_at is null and inspected_at > now()-interval '90 days'),
    'high_risks',       (select count(*) from public.quality_risks where company_id=p_company and rpn >= 100 and status='open' and deleted_at is null),
    'lots_quarantine',  (select count(*) from public.product_lots where company_id=p_company and quality_status='quarantine' and deleted_at is null)
  ) where app.can_access_company(p_company);
$$;
grant execute on function public.quality_dashboard(uuid) to authenticated;

-- ── RLS + triggers + policies (padrão via loop; grants explícitos por tabela) ─
do $do$
declare t text; specs text[] := array[
  'quality_specifications','inspection_plans','inspection_plan_items','quality_inspections','inspection_results',
  'nonconformities','capas','quality_audits','audit_findings','quality_risks','quality_documents',
  'trainings','training_records','complaints','recalls','certificates_of_analysis','stability_studies',
  'validations','batch_releases'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'quality.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'quality.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    -- grant explícito só na tabela nova (evita re-expor objetos como MVs; ver migration 22)
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;
