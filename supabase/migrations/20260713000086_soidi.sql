-- ============================================================================
-- PSOP · MÓDULO 01 · SOIDI — Smart Order Import & Document Intelligence (mig 086)
-- Importação inteligente de pedidos de qualquer origem + document intelligence:
-- ingestão de arquivos, staging de pedidos, campos com confiança (OCR), validação
-- (CPF/CNPJ/CEP determinísticos), normalização, deduplicação, motor de regras e
-- promoção para logistics_orders. Nível CargoWise/SAP TM/Descartes.
-- A leitura de PDF/imagem (OCR real) fica numa Edge Function 'document-ocr' (visão);
-- formatos estruturados (CSV/JSON/XML) são parseados no app e entram via jsonb.
-- Recurso RBAC 'ldm'. Escopo 100% logística. Padrão: colunas-padrão, text+check.
-- ============================================================================

-- ── VALIDADORES DETERMINÍSTICOS (algoritmos reais de dígito verificador) ─────
create or replace function app.valid_cpf(p text) returns boolean language plpgsql immutable as $$
declare d int[]; s int; r int; i int; c text;
begin
  c := regexp_replace(coalesce(p,''), '\D', '', 'g');
  if length(c) <> 11 then return false; end if;
  if c ~ '^(.)\1{10}$' then return false; end if;
  d := string_to_array(c, NULL)::int[];
  s := 0; for i in 1..9 loop s := s + d[i]*(11-i); end loop;
  r := s % 11; r := case when r < 2 then 0 else 11 - r end;
  if r <> d[10] then return false; end if;
  s := 0; for i in 1..10 loop s := s + d[i]*(12-i); end loop;
  r := s % 11; r := case when r < 2 then 0 else 11 - r end;
  return r = d[11];
end; $$;

create or replace function app.valid_cnpj(p text) returns boolean language plpgsql immutable as $$
declare d int[]; w1 int[] := array[5,4,3,2,9,8,7,6,5,4,3,2]; w2 int[] := array[6,5,4,3,2,9,8,7,6,5,4,3,2]; s int; r int; i int; c text;
begin
  c := regexp_replace(coalesce(p,''), '\D', '', 'g');
  if length(c) <> 14 then return false; end if;
  if c ~ '^(.)\1{13}$' then return false; end if;
  d := string_to_array(c, NULL)::int[];
  s := 0; for i in 1..12 loop s := s + d[i]*w1[i]; end loop;
  r := s % 11; r := case when r < 2 then 0 else 11 - r end;
  if r <> d[13] then return false; end if;
  s := 0; for i in 1..13 loop s := s + d[i]*w2[i]; end loop;
  r := s % 11; r := case when r < 2 then 0 else 11 - r end;
  return r = d[14];
end; $$;

create or replace function app.valid_cep(p text) returns boolean language sql immutable as $$
  select regexp_replace(coalesce(p,''), '\D', '', 'g') ~ '^\d{8}$';
$$;

create or replace function app.valid_doc(p text) returns boolean language sql immutable as $$
  select app.valid_cpf(p) or app.valid_cnpj(p);
$$;

-- normalização de nome (Title Case simples) e telefone (só dígitos)
create or replace function app.title_case(p text) returns text language sql immutable as $$
  select nullif(trim(regexp_replace(initcap(lower(coalesce(p,''))), '\s+', ' ', 'g')), '');
$$;

-- ── 1) ARQUIVOS recebidos ────────────────────────────────────────────────────
create table if not exists public.import_files (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  filename text,
  source text not null default 'upload' check (source in ('upload','api','graphql','edi','email','ftp','sftp','webhook','google_drive','onedrive','dropbox','watched_folder')),
  file_type text not null default 'csv' check (file_type in ('pdf','pdf_scanned','image','xlsx','csv','txt','xml','json','zip','edi')),
  storage_path text,
  size_bytes bigint,
  sha256 text,
  pages integer,
  ocr_confidence numeric(5,2),
  orders_found integer not null default 0,
  status text not null default 'received' check (status in ('received','parsing','parsed','error','duplicate')),
  error text,
  received_at timestamptz not null default now(),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 2) PEDIDOS em staging (antes de promover) ────────────────────────────────
create table if not exists public.import_orders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  import_file_id uuid references public.import_files(id) on delete set null,
  raw jsonb not null default '{}'::jsonb,
  order_number text,
  customer_name text,
  customer_doc text,
  customer_email text,
  customer_phone text,
  dest_zip text, dest_street text, dest_number text, dest_district text, dest_city text, dest_uf text,
  weight_kg numeric(14,3), cubage_m3 numeric(14,4), total_value numeric(16,2),
  priority text,
  classification text check (classification in ('national','international','correios','carrier','pickup','express','ltl','ftl','urgent')),
  confidence numeric(5,2),
  dedup_hash text,
  status text not null default 'parsed' check (status in ('parsed','validated','pending','duplicate','promoted','rejected')),
  promoted_order_id uuid references public.logistics_orders(id) on delete set null,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 3) CAMPOS extraídos (com confiança) ──────────────────────────────────────
create table if not exists public.import_fields (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  import_order_id uuid not null references public.import_orders(id) on delete cascade,
  field_name text not null,
  field_value text,
  confidence numeric(5,2),
  corrected boolean not null default false,
  original_value text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 4) VALIDAÇÕES / pendências ───────────────────────────────────────────────
create table if not exists public.import_validations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  import_order_id uuid not null references public.import_orders(id) on delete cascade,
  field text,
  rule text,
  severity text not null default 'error' check (severity in ('error','warning')),
  message text,
  status text not null default 'open' check (status in ('open','fixed','ignored')),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── 5) MOTOR DE REGRAS ───────────────────────────────────────────────────────
create table if not exists public.import_rules (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null,
  condition_type text not null default 'incomplete' check (condition_type in ('cep_invalid','doc_invalid','sku_missing','customer_exists','duplicate','incomplete','weight_invalid')),
  action text not null default 'review' check (action in ('block','pending','update','ignore','review','autocorrect')),
  priority integer not null default 100,
  enabled boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_import_files_sha on public.import_files (company_id, sha256);
create index if not exists idx_import_orders_file on public.import_orders (import_file_id);
create index if not exists idx_import_orders_dedup on public.import_orders (company_id, dedup_hash);
create index if not exists idx_import_fields_order on public.import_fields (import_order_id);
create index if not exists idx_import_val_order on public.import_validations (import_order_id);

-- ── RLS + triggers + policies + grant POR-TABELA (recurso 'ldm') ────────────
do $do$
declare t text; specs text[] := array['import_files','import_orders','import_fields','import_validations','import_rules'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'ldm.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'ldm.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ── RPCs ────────────────────────────────────────────────────────────────────
-- Registra um arquivo recebido (dedup por sha256)
create or replace function public.register_import_file(p_company uuid, p_filename text, p_source text, p_file_type text, p_sha256 text, p_size bigint default null, p_storage text default null)
returns public.import_files language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.import_files; v_dup int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('ldm.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select count(*) into v_dup from public.import_files where company_id=p_company and sha256=p_sha256 and p_sha256 is not null and deleted_at is null;
  insert into public.import_files (tenant_id, company_id, filename, source, file_type, sha256, size_bytes, storage_path, status)
    values (v_tenant, p_company, p_filename, coalesce(p_source,'upload'), coalesce(p_file_type,'csv'), p_sha256, p_size, p_storage,
      case when v_dup > 0 then 'duplicate' else 'received' end) returning * into r;
  return r;
end; $$;
grant execute on function public.register_import_file(uuid,text,text,text,text,bigint,text) to authenticated;

-- Cria um pedido em staging a partir de um payload já parseado (jsonb) + campos c/ confiança
create or replace function public.parse_import_order(p_company uuid, p_file uuid, p_raw jsonb, p_confidence numeric default 90)
returns public.import_orders language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.import_orders; v_hash text; k text; v text;
begin
  if not (app.can_access_company(p_company) and app.has_permission('ldm.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  v_hash := md5(coalesce(p_raw->>'order_number','')||'|'||coalesce(p_raw->>'customer_doc','')||'|'||coalesce(p_raw->>'total_value',''));
  insert into public.import_orders (tenant_id, company_id, import_file_id, raw, order_number, customer_name, customer_doc,
    customer_email, customer_phone, dest_zip, dest_street, dest_number, dest_district, dest_city, dest_uf,
    weight_kg, cubage_m3, total_value, priority, confidence, dedup_hash,
    status)
  values (v_tenant, p_company, p_file, p_raw, p_raw->>'order_number', p_raw->>'customer_name', p_raw->>'customer_doc',
    p_raw->>'customer_email', p_raw->>'customer_phone', p_raw->>'dest_zip', p_raw->>'dest_street', p_raw->>'dest_number',
    p_raw->>'dest_district', p_raw->>'dest_city', p_raw->>'dest_uf',
    (p_raw->>'weight_kg')::numeric, (p_raw->>'cubage_m3')::numeric, (p_raw->>'total_value')::numeric, p_raw->>'priority',
    coalesce(p_confidence,90),
    v_hash,
    case when exists (select 1 from public.import_orders o where o.company_id=p_company and o.dedup_hash=v_hash and o.deleted_at is null) then 'duplicate' else 'parsed' end)
  returning * into r;
  -- registra os campos extraídos com a confiança
  for k, v in select key, value::text from jsonb_each_text(p_raw) loop
    insert into public.import_fields (tenant_id, company_id, import_order_id, field_name, field_value, confidence)
      values (v_tenant, p_company, r.id, k, v, coalesce(p_confidence,90));
  end loop;
  update public.import_files set orders_found = orders_found + 1, status='parsed' where id=p_file and company_id=p_company;
  return r;
end; $$;
grant execute on function public.parse_import_order(uuid,uuid,jsonb,numeric) to authenticated;

-- Normaliza (Title Case nome, UF maiúscula, telefone/doc só dígitos) + registra correções
create or replace function public.normalize_import_order(p_company uuid, p_order uuid)
returns public.import_orders language plpgsql security definer set search_path = public, app as $$
declare r public.import_orders;
begin
  if not (app.can_access_company(p_company) and app.has_permission('ldm.update', p_company)) then raise exception 'forbidden'; end if;
  update public.import_orders set
    customer_name = app.title_case(customer_name),
    customer_doc = nullif(regexp_replace(coalesce(customer_doc,''), '\D', '', 'g'),''),
    customer_phone = nullif(regexp_replace(coalesce(customer_phone,''), '\D', '', 'g'),''),
    dest_zip = nullif(regexp_replace(coalesce(dest_zip,''), '\D', '', 'g'),''),
    dest_uf = upper(nullif(trim(coalesce(dest_uf,'')),'')),
    dest_city = app.title_case(dest_city),
    customer_email = lower(nullif(trim(coalesce(customer_email,'')),''))
    where id=p_order and company_id=p_company returning * into r;
  return r;
end; $$;
grant execute on function public.normalize_import_order(uuid,uuid) to authenticated;

-- Valida o pedido em staging: doc, CEP, UF, obrigatórios, peso, duplicidade
create or replace function public.validate_import_order(p_company uuid, p_order uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.import_orders; v_err int := 0;
begin
  if not (app.can_access_company(p_company) and app.has_permission('ldm.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select * into r from public.import_orders where id=p_order and company_id=p_company;
  if r.id is null then raise exception 'Pedido não encontrado'; end if;
  update public.import_validations set status='fixed' where import_order_id=p_order and status='open';

  if coalesce(r.order_number,'') = '' then
    insert into public.import_validations (tenant_id, company_id, import_order_id, field, rule, severity, message) values (v_tenant,p_company,p_order,'order_number','required','error','Número do pedido ausente'); v_err:=v_err+1; end if;
  if coalesce(r.customer_name,'') = '' then
    insert into public.import_validations (tenant_id, company_id, import_order_id, field, rule, severity, message) values (v_tenant,p_company,p_order,'customer_name','required','error','Cliente ausente'); v_err:=v_err+1; end if;
  if r.customer_doc is not null and not app.valid_doc(r.customer_doc) then
    insert into public.import_validations (tenant_id, company_id, import_order_id, field, rule, severity, message) values (v_tenant,p_company,p_order,'customer_doc','cpf_cnpj','error','CPF/CNPJ inválido'); v_err:=v_err+1; end if;
  if r.dest_zip is not null and not app.valid_cep(r.dest_zip) then
    insert into public.import_validations (tenant_id, company_id, import_order_id, field, rule, severity, message) values (v_tenant,p_company,p_order,'dest_zip','cep','error','CEP inválido'); v_err:=v_err+1; end if;
  if r.dest_uf is not null and length(r.dest_uf) <> 2 then
    insert into public.import_validations (tenant_id, company_id, import_order_id, field, rule, severity, message) values (v_tenant,p_company,p_order,'dest_uf','uf','warning','UF fora do padrão'); end if;
  if r.weight_kg is not null and r.weight_kg <= 0 then
    insert into public.import_validations (tenant_id, company_id, import_order_id, field, rule, severity, message) values (v_tenant,p_company,p_order,'weight_kg','positive','error','Peso inválido'); v_err:=v_err+1; end if;
  if r.status <> 'duplicate' and exists (select 1 from public.import_orders o where o.company_id=p_company and o.dedup_hash=r.dedup_hash and o.id<>p_order and o.deleted_at is null) then
    insert into public.import_validations (tenant_id, company_id, import_order_id, field, rule, severity, message) values (v_tenant,p_company,p_order,'*','duplicate','warning','Possível pedido duplicado'); end if;

  update public.import_orders set status = case when v_err > 0 then 'pending' else 'validated' end where id=p_order and company_id=p_company;
  return v_err;
end; $$;
grant execute on function public.validate_import_order(uuid,uuid) to authenticated;

-- Promove o pedido validado para logistics_orders (entra no fluxo logístico)
create or replace function public.promote_import_order(p_company uuid, p_order uuid)
returns public.logistics_orders language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r public.import_orders; o public.logistics_orders; v_open int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('ldm.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select * into r from public.import_orders where id=p_order and company_id=p_company;
  if r.id is null then raise exception 'Pedido não encontrado'; end if;
  select count(*) into v_open from public.import_validations where import_order_id=p_order and severity='error' and status='open';
  if v_open > 0 then raise exception 'Não promovível: % erro(s) de validação em aberto', v_open; end if;
  if r.status = 'promoted' then raise exception 'Pedido já promovido'; end if;

  insert into public.logistics_orders (tenant_id, company_id, code, origin, destination, dest_uf, dest_zip, metadata)
    values (v_tenant, p_company, coalesce(r.order_number, 'IMP-'||substr(r.id::text,1,8)),
      nullif(concat_ws(', ', r.dest_city, r.dest_uf),''), nullif(concat_ws(', ', r.dest_street, r.dest_number, r.dest_city),''),
      r.dest_uf, r.dest_zip,
      jsonb_build_object('customer_name', r.customer_name, 'customer_doc', r.customer_doc, 'weight_kg', r.weight_kg, 'total_value', r.total_value, 'imported_from', r.import_file_id))
    returning * into o;
  update public.import_orders set status='promoted', promoted_order_id=o.id where id=p_order and company_id=p_company;
  return o;
end; $$;
grant execute on function public.promote_import_order(uuid,uuid) to authenticated;

create or replace function public.soidi_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb; v_tot int; v_prom int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select count(*) into v_tot from public.import_orders where company_id=p_company and deleted_at is null;
  select count(*) into v_prom from public.import_orders where company_id=p_company and status='promoted' and deleted_at is null;
  select jsonb_build_object(
    'files', (select count(*) from public.import_files where company_id=p_company and deleted_at is null),
    'files_error', (select count(*) from public.import_files where company_id=p_company and status='error' and deleted_at is null),
    'orders', v_tot,
    'parsed', (select count(*) from public.import_orders where company_id=p_company and status='parsed' and deleted_at is null),
    'validated', (select count(*) from public.import_orders where company_id=p_company and status='validated' and deleted_at is null),
    'pending', (select count(*) from public.import_orders where company_id=p_company and status='pending' and deleted_at is null),
    'duplicates', (select count(*) from public.import_orders where company_id=p_company and status='duplicate' and deleted_at is null),
    'promoted', v_prom,
    'promotion_rate', case when v_tot>0 then round(100.0*v_prom/v_tot,1) else null end,
    'avg_confidence', (select round(avg(confidence),1) from public.import_orders where company_id=p_company and confidence is not null and deleted_at is null),
    'open_validations', (select count(*) from public.import_validations where company_id=p_company and status='open' and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.soidi_dashboard(uuid) to authenticated;

-- Motor de insights ADICIONAL, auto-descoberto pelo cérebro LAIOS (padrão *_insights)
create or replace function public.soidi_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_pend int; v_dup int; v_err int; v_lowconf int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'SOIDI%' and deleted_at is null;

  select count(*) into v_pend from public.import_orders where company_id=p_company and status='pending' and deleted_at is null;
  if v_pend > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'SOIDI: pedidos pendentes na importação', v_pend||' pedido(s) com erro de validação aguardando correção.', 'Tratar na Central de Pendências para liberar o fluxo.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_dup from public.import_orders where company_id=p_company and status='duplicate' and deleted_at is null;
  if v_dup > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'info', 'SOIDI: pedidos duplicados', v_dup||' pedido(s) marcados como duplicados.', 'Revisar/descartar duplicidades para não expedir em dobro.', 76);
    v_c := v_c + 1;
  end if;
  select count(*) into v_err from public.import_files where company_id=p_company and status='error' and deleted_at is null;
  if v_err > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'SOIDI: arquivos com erro de leitura', v_err||' arquivo(s) falharam no processamento/OCR.', 'Reenviar em melhor qualidade ou corrigir o layout.', 80);
    v_c := v_c + 1;
  end if;
  select count(*) into v_lowconf from public.import_orders where company_id=p_company and confidence is not null and confidence < 70 and status not in ('promoted','rejected') and deleted_at is null;
  if v_lowconf > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'info', 'SOIDI: leitura de baixa confiança', v_lowconf||' pedido(s) com confiança de OCR abaixo de 70%.', 'Conferir manualmente os campos identificados.', 72);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.soidi_insights(uuid) to authenticated;

-- ── SEED: regras padrão do motor ────────────────────────────────────────────
do $seed$
declare v_company uuid := '94e93b2a-3523-4102-9fc9-e5bce46a4a41'; v_tenant uuid;
begin
  select tenant_id into v_tenant from public.companies where id=v_company;
  if v_tenant is null then return; end if;
  if not exists (select 1 from public.import_rules where company_id=v_company and deleted_at is null) then
    insert into public.import_rules (tenant_id, company_id, name, condition_type, action, priority) values
      (v_tenant, v_company, 'CEP inválido → bloquear', 'cep_invalid', 'block', 10),
      (v_tenant, v_company, 'CPF/CNPJ inválido → pendência', 'doc_invalid', 'pending', 20),
      (v_tenant, v_company, 'Pedido duplicado → ignorar', 'duplicate', 'ignore', 30),
      (v_tenant, v_company, 'Documento incompleto → análise', 'incomplete', 'review', 40),
      (v_tenant, v_company, 'Peso inválido → pendência', 'weight_invalid', 'pending', 50);
  end if;
end $seed$;

notify pgrst, 'reload schema';
