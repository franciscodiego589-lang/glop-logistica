-- 20260713000056_ecm.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  ECM / GED — ENTERPRISE CONTENT MANAGEMENT (Vol 24) — repositório oficial ║
-- ║  Pastas hierárquicas, versionamento + check-in/out, fluxo de ASSINATURAS  ║
-- ║  eletrônicas, retenção/descarte, metadados, OCR (campo), colaboração.     ║
-- ║  Nível OpenText/SharePoint/FileNet/DocuSign. Integra com BPM (Vol 23).    ║
-- ║  ecm_insights auto-descoberto pelo cérebro LAIOS.                        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

do $e$ begin
  if not exists (select 1 from pg_type where typname='document_status') then
    create type public.document_status as enum ('draft','review','approved','signed','archived','obsolete'); end if;
  if not exists (select 1 from pg_type where typname='signature_status') then
    create type public.signature_status as enum ('pending','signed','rejected'); end if;
end $e$;

insert into public.permissions (slug, resource, action, description)
select 'ecm.' || a, 'ecm', a, 'Permissão ' || a || ' em ecm'
from unnest(array['read','create','update','delete','approve','sign']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'ecm' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── DOCUMENT_FOLDERS (estrutura dinâmica, parent_id) ────────────────────────
create table public.document_folders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, parent_id uuid references public.document_folders(id) on delete set null, path text, is_vault boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_document_folders_parent on public.document_folders (parent_id);

-- ── RETENTION_POLICIES ──────────────────────────────────────────────────────
create table public.retention_policies (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, category text, retention_months integer, is_permanent boolean not null default false, legal_basis text, disposal_action text default 'review',
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── DOCUMENTS ───────────────────────────────────────────────────────────────
create table public.documents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  folder_id uuid references public.document_folders(id) on delete set null,
  code text, title text not null, category text, doc_type text, status public.document_status not null default 'draft',
  current_version integer not null default 1, storage_path text, url text, mime_type text, file_size bigint,
  ocr_text text, tags text[], author text, owner uuid references auth.users(id),
  reference_type text, reference_id uuid, retention_until date, expires_at date,
  checked_out_by uuid references auth.users(id), checked_out_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_documents_folder on public.documents (folder_id);
create index idx_documents_status on public.documents (company_id, status) where deleted_at is null;
create index idx_documents_search on public.documents using gin (to_tsvector('portuguese', coalesce(title,'') || ' ' || coalesce(ocr_text,'')));

-- ── DOCUMENT_VERSIONS ───────────────────────────────────────────────────────
create table public.document_versions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  document_id uuid not null references public.documents(id) on delete cascade,
  version_no integer not null, storage_path text, url text, file_size bigint, author text, change_reason text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_document_versions_doc on public.document_versions (document_id, version_no);

-- ── DOCUMENT_SIGNATURES (fluxo de assinatura) ───────────────────────────────
create table public.document_signatures (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  document_id uuid not null references public.documents(id) on delete cascade,
  signer_name text not null, signer_email text, sign_order integer not null default 1, method text default 'electronic',
  status public.signature_status not null default 'pending', signed_at timestamptz, ip_address text, hash text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_document_signatures_doc on public.document_signatures (document_id, sign_order);

-- ── DOCUMENT_COMMENTS ───────────────────────────────────────────────────────
create table public.document_comments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  document_id uuid not null references public.documents(id) on delete cascade,
  author text, body text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Check-out (bloqueia p/ edição)
create or replace function public.checkout_document(p_document uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare d record;
begin
  select * into d from public.documents where id=p_document and deleted_at is null;
  if d.id is null then raise exception 'documento não encontrado'; end if;
  if not (app.can_access_company(d.company_id) and app.has_permission('ecm.update', d.company_id)) then raise exception 'forbidden'; end if;
  if d.checked_out_by is not null and d.checked_out_by <> auth.uid() then raise exception 'documento em edição por outro usuário'; end if;
  update public.documents set checked_out_by=auth.uid(), checked_out_at=now() where id=p_document;
  return jsonb_build_object('document', p_document, 'checked_out', true);
end;
$$;
grant execute on function public.checkout_document(uuid) to authenticated;

-- Check-in com nova versão (libera o bloqueio)
create or replace function public.checkin_document(p_document uuid, p_storage_path text default null, p_reason text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare d record; v_new int;
begin
  select * into d from public.documents where id=p_document and deleted_at is null;
  if d.id is null then raise exception 'documento não encontrado'; end if;
  if not (app.can_access_company(d.company_id) and app.has_permission('ecm.update', d.company_id)) then raise exception 'forbidden'; end if;
  v_new := d.current_version + 1;
  insert into public.document_versions (tenant_id, company_id, document_id, version_no, storage_path, author, change_reason)
  values (d.tenant_id, d.company_id, p_document, v_new, coalesce(p_storage_path, d.storage_path), d.author, p_reason);
  update public.documents set current_version=v_new, storage_path=coalesce(p_storage_path, storage_path), checked_out_by=null, checked_out_at=null where id=p_document;
  return jsonb_build_object('document', p_document, 'new_version', v_new);
end;
$$;
grant execute on function public.checkin_document(uuid, text, text) to authenticated;

-- Solicitar assinaturas (múltiplos signatários, com ordem)
create or replace function public.request_signatures(p_document uuid, p_signers jsonb)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare d record; s jsonb; v_i int := 0; v_count int := 0;
begin
  select * into d from public.documents where id=p_document and deleted_at is null;
  if d.id is null then raise exception 'documento não encontrado'; end if;
  if not (app.can_access_company(d.company_id) and app.has_permission('ecm.sign', d.company_id)) then raise exception 'forbidden'; end if;
  for s in select value from jsonb_array_elements(p_signers) loop
    v_i := v_i + 1;
    insert into public.document_signatures (tenant_id, company_id, document_id, signer_name, signer_email, sign_order, method, status)
    values (d.tenant_id, d.company_id, p_document, s->>'name', s->>'email', coalesce((s->>'order')::int, v_i), coalesce(s->>'method','electronic'), 'pending');
    v_count := v_count + 1;
  end loop;
  update public.documents set status='review' where id=p_document;
  return jsonb_build_object('document', p_document, 'signers', v_count);
end;
$$;
grant execute on function public.request_signatures(uuid, jsonb) to authenticated;

-- Assinar (carimbo de tempo + hash); quando todos assinam → documento assinado
create or replace function public.sign_document(p_signature uuid, p_method text default 'electronic')
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare sg record; v_pending int;
begin
  select * into sg from public.document_signatures where id=p_signature and deleted_at is null;
  if sg.id is null then raise exception 'assinatura não encontrada'; end if;
  if not (app.can_access_company(sg.company_id) and app.has_permission('ecm.sign', sg.company_id)) then raise exception 'forbidden'; end if;
  if sg.status <> 'pending' then raise exception 'já assinado/rejeitado'; end if;
  update public.document_signatures set status='signed', signed_at=now(), method=coalesce(p_method, method),
    hash = md5(sg.document_id::text || sg.signer_name || now()::text) where id=p_signature;
  select count(*) into v_pending from public.document_signatures where document_id=sg.document_id and status='pending' and deleted_at is null;
  if v_pending = 0 then update public.documents set status='signed' where id=sg.document_id; end if;
  return jsonb_build_object('signature', p_signature, 'remaining', v_pending, 'document_signed', v_pending=0);
end;
$$;
grant execute on function public.sign_document(uuid, text) to authenticated;

-- Busca full-text (título + OCR)
create or replace function public.search_documents(p_company uuid, p_query text)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce((
    select jsonb_agg(jsonb_build_object('id', id, 'title', title, 'category', category, 'status', status, 'version', current_version) order by ts_rank(to_tsvector('portuguese', coalesce(title,'')||' '||coalesce(ocr_text,'')), plainto_tsquery('portuguese', p_query)) desc)
    from public.documents where company_id=p_company and deleted_at is null
      and to_tsvector('portuguese', coalesce(title,'')||' '||coalesce(ocr_text,'')) @@ plainto_tsquery('portuguese', p_query) limit 50
  ), '[]'::jsonb) else '[]'::jsonb end;
$$;
grant execute on function public.search_documents(uuid, text) to authenticated;

create or replace function public.ecm_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'documents', (select count(*) from public.documents where company_id=p_company and deleted_at is null),
    'signed', (select count(*) from public.documents where company_id=p_company and status='signed' and deleted_at is null),
    'pending_signatures', (select count(*) from public.document_signatures where company_id=p_company and status='pending' and deleted_at is null),
    'checked_out', (select count(*) from public.documents where company_id=p_company and checked_out_by is not null and deleted_at is null),
    'expiring_retention', (select count(*) from public.documents where company_id=p_company and retention_until is not null and retention_until <= now()::date + 30 and deleted_at is null),
    'expired', (select count(*) from public.documents where company_id=p_company and expires_at is not null and expires_at < now()::date and deleted_at is null),
    'folders', (select count(*) from public.document_folders where company_id=p_company and deleted_at is null),
    'versions', (select count(*) from public.document_versions where company_id=p_company and deleted_at is null),
    'by_category', (select coalesce(jsonb_object_agg(coalesce(category,'—'), c),'{}'::jsonb) from (select category, count(*) c from public.documents where company_id=p_company and deleted_at is null group by category) s)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.ecm_dashboard(uuid) to authenticated;

create or replace function public.ecm_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_ret int; v_sig int; v_co int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Documentos%' and deleted_at is null;

  select count(*) into v_ret from public.documents where company_id=p_company and retention_until is not null and retention_until < now()::date and deleted_at is null;
  if v_ret > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'waste', 'info', 'Documentos: retenção vencida', v_ret||' documento(s) além do prazo de retenção.', 'Revisar descarte/arquivamento conforme política (LGPD).', 74);
    v_c := v_c + 1;
  end if;
  select count(*) into v_sig from public.document_signatures where company_id=p_company and status='pending' and deleted_at is null and created_at < now() - interval '3 days';
  if v_sig > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'warning', 'Documentos: assinaturas pendentes', v_sig||' assinatura(s) sem resposta há +3 dias.', 'Cobrar os signatários — documentos travados.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_co from public.documents where company_id=p_company and checked_out_by is not null and checked_out_at < now() - interval '2 days' and deleted_at is null;
  if v_co > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'Documentos: check-out prolongado', v_co||' documento(s) bloqueado(s) em edição há +2 dias.', 'Liberar (check-in) para não travar a colaboração.', 70);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.ecm_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'ecm') ────────────
do $do$
declare t text; specs text[] := array['document_folders','retention_policies','documents','document_versions','document_signatures','document_comments'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'ecm.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'ecm.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: pastas + políticas de retenção + documentos exemplo ══
do $do$
declare c record; v_qa uuid; v_prod uuid; v_com uuid;
  pols jsonb := '[
    {"n":"Contratos","c":"contract","m":60,"p":false,"l":"Código Civil"},
    {"n":"Documentos Fiscais","c":"fiscal","m":60,"p":false,"l":"CTN art.173"},
    {"n":"CoA / Laudos","c":"coa","m":60,"p":false,"l":"ANVISA/BPF"},
    {"n":"POP / Procedimentos","c":"pop","m":null,"p":true,"l":"ISO 9001"},
    {"n":"Prontuários","c":"medical","m":240,"p":false,"l":"CFM 1.821/2007"}
  ]'::jsonb;
  pol jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    if not exists (select 1 from public.document_folders where company_id=c.id and name='Qualidade' and deleted_at is null) then
      insert into public.document_folders (tenant_id, company_id, name, path) values (c.tenant_id, c.id, 'Qualidade', '/Qualidade') returning id into v_qa;
      insert into public.document_folders (tenant_id, company_id, name, path) values (c.tenant_id, c.id, 'Produção', '/Produção') returning id into v_prod;
      insert into public.document_folders (tenant_id, company_id, name, path, is_vault) values (c.tenant_id, c.id, 'Contratos (Cofre)', '/Contratos', true) returning id into v_com;
      insert into public.document_folders (tenant_id, company_id, name, parent_id, path) values
        (c.tenant_id, c.id, 'POPs', v_qa, '/Qualidade/POPs'),
        (c.tenant_id, c.id, 'CoA', v_qa, '/Qualidade/CoA'),
        (c.tenant_id, c.id, 'Ordens de Produção', v_prod, '/Produção/OPs');
      -- documentos exemplo
      insert into public.documents (tenant_id, company_id, folder_id, code, title, category, doc_type, status, author, retention_until)
      values (c.tenant_id, c.id, v_qa, 'POP-001', 'POP — Higienização de Encapsuladora', 'pop', 'pdf', 'approved', 'Qualidade', null),
             (c.tenant_id, c.id, v_qa, 'COA-2026-001', 'CoA — Lote WHEY-2026-001', 'coa', 'pdf', 'signed', 'Laboratório', (now()::date + interval '5 years')::date);
    end if;
    for pol in select value from jsonb_array_elements(pols) loop
      if not exists (select 1 from public.retention_policies where company_id=c.id and name=(pol->>'n') and deleted_at is null) then
        insert into public.retention_policies (tenant_id, company_id, name, category, retention_months, is_permanent, legal_basis)
        values (c.tenant_id, c.id, pol->>'n', pol->>'c', nullif(pol->>'m','null')::int, (pol->>'p')::boolean, pol->>'l');
      end if;
    end loop;
  end loop;
end $do$;

notify pgrst, 'reload schema';
