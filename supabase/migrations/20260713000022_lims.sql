-- 20260713000022_lims.sql
-- VOLUME 09 · LIMS (Laboratory Information Management System).
-- Amostras → ensaios (resultado × especificação) → liberação, integrando com o
-- quality_status do lote (portão de qualidade que o QMS faria).
-- Reusa recurso RBAC 'production' (simplificação; roadmap: recurso 'quality/lab' dedicado).

-- ── ENUMS ────────────────────────────────────────────────────────────────────
create type public.lab_sample_type as enum ('raw_material','finished_product','intermediate','water','packaging','swab','environment','air','surface','stability','retention');
create type public.lab_sample_status as enum ('registered','in_analysis','approved','rejected','retained','canceled');
create type public.lab_test_status as enum ('pending','pass','fail','repeat');
create type public.lab_test_kind as enum ('physical','chemical','microbiological','sensory','instrumental','stability');
create type public.lab_stability_kind as enum ('long_term','accelerated','photostability','in_use');

-- ── LAB_METHODS (métodos analíticos / POPs, versionados) ────────────────────
create table public.lab_methods (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, name text not null, technique text, test_kind public.lab_test_kind not null default 'chemical',
  status text not null default 'draft', version_label text, description text,
  approved_by uuid references auth.users(id), approved_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── PRODUCT_SPECIFICATIONS (especificação por produto) ──────────────────────
create table public.product_specifications (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid references public.products(id) on delete cascade,
  method_id uuid references public.lab_methods(id) on delete set null,
  parameter text not null, test_kind public.lab_test_kind not null default 'chemical',
  min_value numeric(18,6), max_value numeric(18,6), target_value numeric(18,6), unit text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_product_specs_product on public.product_specifications (product_id);

-- ── LAB_SAMPLES (amostras) ──────────────────────────────────────────────────
create table public.lab_samples (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid references public.products(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  code text, sample_type public.lab_sample_type not null default 'raw_material',
  status public.lab_sample_status not null default 'registered', priority text,
  source text, location text, collector text, collected_at timestamptz, notes text,
  released_by uuid references auth.users(id), released_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_lab_samples_status on public.lab_samples (company_id, status) where deleted_at is null;
create index idx_lab_samples_lot on public.lab_samples (lot_id);

-- ── LAB_TESTS (ensaios; conformidade calculada vs especificação) ────────────
create table public.lab_tests (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  sample_id uuid not null references public.lab_samples(id) on delete cascade,
  method_id uuid references public.lab_methods(id) on delete set null,
  specification_id uuid references public.product_specifications(id) on delete set null,
  parameter text not null, test_kind public.lab_test_kind not null default 'chemical',
  result_value numeric(18,6), result_text text, unit text,
  spec_min numeric(18,6), spec_max numeric(18,6),
  conforms boolean generated always as (
    result_value is not null
    and (spec_min is null or result_value >= spec_min)
    and (spec_max is null or result_value <= spec_max)
  ) stored,
  status public.lab_test_status not null default 'pending', analyst text, tested_at timestamptz, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_lab_tests_sample on public.lab_tests (sample_id);

-- ── LAB_REAGENTS (reagentes c/ validade) ────────────────────────────────────
create table public.lab_reagents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, manufacturer text, lot_number text, expiry_date date,
  quantity numeric(18,4), unit text, location text, responsible text, certificate_url text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_lab_reagents_expiry on public.lab_reagents (company_id, expiry_date) where deleted_at is null;

-- ── LAB_INSTRUMENTS (equipamentos de laboratório c/ calibração) ─────────────
create table public.lab_instruments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text, name text not null, instrument_type text, manufacturer text, model text,
  status text not null default 'available', last_calibration date, calibration_due date, responsible text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_lab_instruments_caldue on public.lab_instruments (company_id, calibration_due) where deleted_at is null;

-- ── STABILITY_STUDIES (estudos de estabilidade) ─────────────────────────────
create table public.stability_studies (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  product_id uuid references public.products(id) on delete set null,
  lot_id uuid references public.product_lots(id) on delete set null,
  code text, study_kind public.lab_stability_kind not null default 'long_term',
  condition_temp text, condition_humidity text, start_date date, end_date date,
  status text not null default 'ongoing', notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── RLS + triggers (recurso 'production') ───────────────────────────────────
do $do$
declare t text; specs text[] := array['lab_methods','product_specifications','lab_samples','lab_tests','lab_reagents','lab_instruments','stability_studies'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'production.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'production.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on all tables in schema public to authenticated;

-- ── RPC: liberar amostra — avalia ensaios × spec e libera/bloqueia o lote ────
create or replace function public.release_sample(p_sample uuid)
returns text
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_lot uuid; v_total int; v_done int; v_fail int; v_decision text;
begin
  select company_id, lot_id into v_company, v_lot from public.lab_samples where id = p_sample;
  if v_company is null then raise exception 'sample % not found', p_sample; end if;
  if not app.has_permission('production.update', v_company) then raise exception 'forbidden'; end if;

  select count(*), count(*) filter (where result_value is not null or result_text is not null),
         count(*) filter (where result_value is not null and conforms = false)
    into v_total, v_done, v_fail
  from public.lab_tests where sample_id = p_sample and deleted_at is null;

  if v_total = 0 then raise exception 'sample has no tests'; end if;
  if v_done < v_total then raise exception 'pending tests: % of %', v_total - v_done, v_total; end if;

  if v_fail > 0 then
    v_decision := 'rejected';
    update public.lab_samples set status = 'rejected', released_by = auth.uid(), released_at = now() where id = p_sample;
    if v_lot is not null then update public.product_lots set quality_status = 'blocked' where id = v_lot; end if;
  else
    v_decision := 'approved';
    update public.lab_samples set status = 'approved', released_by = auth.uid(), released_at = now() where id = p_sample;
    if v_lot is not null then update public.product_lots set quality_status = 'released' where id = v_lot; end if;
  end if;

  -- marca status pass/fail em cada ensaio conforme conformidade
  update public.lab_tests set status = case when conforms then 'pass' else 'fail' end
    where sample_id = p_sample and result_value is not null and deleted_at is null;

  return v_decision;
end;
$$;
grant execute on function public.release_sample(uuid) to authenticated;
