-- 20260713000065_elcp.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  ELCP — ENTERPRISE LOW-CODE / NO-CODE PLATFORM (Vol 33) — Enterprise+     ║
-- ║  Construtor visual NÃO-INVASIVO: apps, entidades e formulários            ║
-- ║  customizados guardam dados numa camada GENÉRICA (custom_records.data     ║
-- ║  jsonb) — SEM DDL, sem tocar tabelas nativas, sobrevive a updates.        ║
-- ║  Template center (app com 1 clique) + versionamento. Nível Power Platform ║
-- ║  /OutSystems/Mendix/ServiceNow Creator. elcp_insights auto-descoberto.    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

insert into public.permissions (slug, resource, action, description)
select 'lowcode.' || a, 'lowcode', a, 'Permissão ' || a || ' em lowcode'
from unnest(array['read','create','update','delete','approve','publish']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'lowcode' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── CUSTOM_APPS ─────────────────────────────────────────────────────────────
create table public.custom_apps (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  app_key text not null, name text not null, icon text default '🧩', category text, status text default 'draft', description text, app_version integer not null default 1,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_custom_apps on public.custom_apps (company_id, status) where deleted_at is null;

-- ── CUSTOM_ENTITIES (database builder SEM DDL) ──────────────────────────────
create table public.custom_entities (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  app_id uuid references public.custom_apps(id) on delete cascade,
  entity_key text not null, name text not null, icon text, fields jsonb not null default '[]'::jsonb, record_count integer not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_custom_entities on public.custom_entities (company_id, entity_key) where deleted_at is null;

-- ── CUSTOM_RECORDS (dados genéricos das entidades — NÃO-INVASIVO) ───────────
create table public.custom_records (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  entity_id uuid not null references public.custom_entities(id) on delete cascade, data jsonb not null default '{}'::jsonb,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_custom_records on public.custom_records (entity_id) where deleted_at is null;
create index idx_custom_records_gin on public.custom_records using gin (data);

-- ── CUSTOM_FORMS + PAGES + COMPONENTS + TEMPLATES + DEPLOYMENTS ─────────────
create table public.custom_forms (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  app_id uuid references public.custom_apps(id) on delete cascade, entity_id uuid references public.custom_entities(id) on delete set null,
  form_key text not null, name text, layout jsonb not null default '[]'::jsonb,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.custom_pages (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  app_id uuid references public.custom_apps(id) on delete cascade, page_key text not null, name text, page_type text default 'list', layout jsonb not null default '[]'::jsonb,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.custom_components (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  component_key text not null, name text, component_type text default 'widget', definition jsonb not null default '{}'::jsonb, is_shared boolean not null default true, usage_count integer not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.app_templates (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  template_key text not null, name text, category text, icon text, description text, definition jsonb not null default '{}'::jsonb, installs integer not null default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.elcp_deployments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  app_id uuid references public.custom_apps(id) on delete cascade, app_version integer, environment text default 'production', status text default 'deployed', changelog text, deployed_by uuid references auth.users(id),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Instanciar template → cria app + entidade(s) + formulário (app com 1 clique)
create or replace function public.instantiate_template(p_company uuid, p_template text)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; t record; v_app uuid; v_ent uuid; e jsonb; def jsonb;
begin
  if not (app.can_access_company(p_company) and app.has_permission('lowcode.create', p_company)) then raise exception 'forbidden'; end if;
  select * into t from public.app_templates where company_id=p_company and template_key=p_template and deleted_at is null limit 1;
  if t.id is null then raise exception 'template não encontrado'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  def := t.definition;

  insert into public.custom_apps (tenant_id, company_id, app_key, name, icon, category, status, description)
  values (v_tenant, p_company, p_template||'_'||substr(gen_random_uuid()::text,1,6), coalesce(def->'app'->>'name', t.name), coalesce(def->'app'->>'icon', t.icon, '🧩'), t.category, 'draft', t.description)
  returning id into v_app;

  for e in select value from jsonb_array_elements(coalesce(def->'entities','[]'::jsonb)) loop
    insert into public.custom_entities (tenant_id, company_id, app_id, entity_key, name, fields)
    values (v_tenant, p_company, v_app, (e->>'key')||'_'||substr(gen_random_uuid()::text,1,6), e->>'name', coalesce(e->'fields','[]'::jsonb))
    returning id into v_ent;
    insert into public.custom_forms (tenant_id, company_id, app_id, entity_id, form_key, name, layout)
    values (v_tenant, p_company, v_app, v_ent, 'form_'||substr(gen_random_uuid()::text,1,6), (e->>'name')||' — formulário', coalesce(e->'fields','[]'::jsonb));
  end loop;

  update public.app_templates set installs=installs+1 where id=t.id;
  return jsonb_build_object('app_id', v_app, 'name', coalesce(def->'app'->>'name', t.name));
end;
$$;
grant execute on function public.instantiate_template(uuid, text) to authenticated;

-- Criar registro em entidade customizada (valida campos obrigatórios) — NÃO-INVASIVO
create or replace function public.create_custom_record(p_company uuid, p_entity uuid, p_data jsonb)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare e record; f jsonb; v_id uuid; v_missing text;
begin
  if not (app.can_access_company(p_company) and app.has_permission('lowcode.create', p_company)) then raise exception 'forbidden'; end if;
  select * into e from public.custom_entities where id=p_entity and company_id=p_company and deleted_at is null;
  if e.id is null then raise exception 'entidade não encontrada'; end if;
  -- valida obrigatórios definidos nos fields
  for f in select value from jsonb_array_elements(e.fields) loop
    if coalesce((f->>'required')::boolean,false) and coalesce(p_data->>(f->>'key'),'') = '' then
      v_missing := coalesce(f->>'label', f->>'key'); raise exception 'campo obrigatório: %', v_missing;
    end if;
  end loop;
  insert into public.custom_records (tenant_id, company_id, entity_id, data) values (e.tenant_id, p_company, p_entity, coalesce(p_data,'{}'::jsonb)) returning id into v_id;
  update public.custom_entities set record_count=record_count+1 where id=p_entity;
  return jsonb_build_object('record_id', v_id);
end;
$$;
grant execute on function public.create_custom_record(uuid, uuid, jsonb) to authenticated;

-- Publicar app (versionamento + deployment)
create or replace function public.publish_app(p_app uuid, p_environment text default 'production', p_changelog text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare a record; v_ver int;
begin
  select * into a from public.custom_apps where id=p_app and deleted_at is null;
  if a.id is null then raise exception 'app não encontrado'; end if;
  if not (app.can_access_company(a.company_id) and app.has_permission('lowcode.publish', a.company_id)) then raise exception 'forbidden'; end if;
  v_ver := a.app_version + case when a.status='published' then 1 else 0 end;
  update public.custom_apps set status='published', app_version=v_ver where id=p_app;
  insert into public.elcp_deployments (tenant_id, company_id, app_id, app_version, environment, status, changelog, deployed_by)
  values (a.tenant_id, a.company_id, p_app, v_ver, p_environment, 'deployed', p_changelog, auth.uid());
  return jsonb_build_object('app', p_app, 'version', v_ver, 'environment', p_environment, 'status', 'published');
end;
$$;
grant execute on function public.publish_app(uuid, text, text) to authenticated;

create or replace function public.elcp_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'apps', (select count(*) from public.custom_apps where company_id=p_company and deleted_at is null),
    'apps_published', (select count(*) from public.custom_apps where company_id=p_company and status='published' and deleted_at is null),
    'entities', (select count(*) from public.custom_entities where company_id=p_company and deleted_at is null),
    'records', (select count(*) from public.custom_records where company_id=p_company and deleted_at is null),
    'forms', (select count(*) from public.custom_forms where company_id=p_company and deleted_at is null),
    'components', (select count(*) from public.custom_components where company_id=p_company and deleted_at is null),
    'templates', (select count(*) from public.app_templates where company_id=p_company and deleted_at is null),
    'deployments', (select count(*) from public.elcp_deployments where company_id=p_company and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.elcp_dashboard(uuid) to authenticated;

create or replace function public.elcp_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_draft int; v_empty int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Studio%' and deleted_at is null;

  select count(*) into v_draft from public.custom_apps where company_id=p_company and status='draft' and deleted_at is null and created_at < now() - interval '14 days';
  if v_draft > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'Studio: apps em rascunho há tempo', v_draft||' app(s) sem publicar há +14 dias.', 'Publicar ou arquivar para não acumular customizações inacabadas.', 70);
    v_c := v_c + 1;
  end if;
  select count(*) into v_empty from public.custom_entities where company_id=p_company and record_count=0 and deleted_at is null and created_at < now() - interval '7 days';
  if v_empty > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'opportunity', 'info', 'Studio: entidades sem uso', v_empty||' entidade(s) customizada(s) sem nenhum registro.', 'Avaliar adoção ou remover para governança das customizações.', 66);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.elcp_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'lowcode') ────────
do $do$
declare t text; specs text[] := array['custom_apps','custom_entities','custom_records','custom_forms','custom_pages','custom_components','app_templates','elcp_deployments'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'lowcode.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'lowcode.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: templates + componentes ══
do $do$
declare c record;
  tpls jsonb := '[
    {"k":"prod_checklist","n":"Checklist de Produção","cat":"Indústria","i":"✅","d":"Checklist de conformidade por turno/linha",
      "def":{"app":{"name":"Checklist de Produção","icon":"✅"},"entities":[{"key":"checklist","name":"Itens do Checklist","fields":[
        {"key":"turno","label":"Turno","type":"select","required":true},{"key":"linha","label":"Linha","type":"text","required":true},
        {"key":"item","label":"Item verificado","type":"text","required":true},{"key":"conforme","label":"Conforme?","type":"boolean"},{"key":"obs","label":"Observação","type":"text"}]}]}},
    {"k":"qa_inspection","n":"Inspeção de Qualidade","cat":"Qualidade","i":"🔬","d":"Registro de inspeção por lote/parâmetro",
      "def":{"app":{"name":"Inspeção de Qualidade","icon":"🔬"},"entities":[{"key":"inspection","name":"Inspeções","fields":[
        {"key":"lote","label":"Lote","type":"text","required":true},{"key":"produto","label":"Produto","type":"text"},
        {"key":"parametro","label":"Parâmetro","type":"text","required":true},{"key":"resultado","label":"Resultado","type":"number"},{"key":"aprovado","label":"Aprovado?","type":"boolean"}]}]}},
    {"k":"satisfaction","n":"Pesquisa de Satisfação","cat":"Comercial","i":"⭐","d":"NPS / satisfação de clientes ou pacientes",
      "def":{"app":{"name":"Pesquisa de Satisfação","icon":"⭐"},"entities":[{"key":"survey","name":"Respostas","fields":[
        {"key":"cliente","label":"Cliente/Paciente","type":"text"},{"key":"nota","label":"Nota (0-10)","type":"number","required":true},{"key":"comentario","label":"Comentário","type":"text"}]}]}},
    {"k":"service_order","n":"Ordem de Serviço","cat":"Operações","i":"🛠","d":"OS simples com responsável e prazo",
      "def":{"app":{"name":"Ordem de Serviço","icon":"🛠"},"entities":[{"key":"os","name":"Ordens","fields":[
        {"key":"titulo","label":"Título","type":"text","required":true},{"key":"responsavel","label":"Responsável","type":"text"},
        {"key":"status","label":"Status","type":"select"},{"key":"prazo","label":"Prazo","type":"date"}]}]}},
    {"k":"internal_audit","n":"Auditoria Interna","cat":"Governança","i":"🔎","d":"Checklist de auditoria por área/requisito",
      "def":{"app":{"name":"Auditoria Interna","icon":"🔎"},"entities":[{"key":"audit","name":"Achados","fields":[
        {"key":"area","label":"Área","type":"text","required":true},{"key":"requisito","label":"Requisito","type":"text","required":true},
        {"key":"conforme","label":"Conforme?","type":"boolean"},{"key":"evidencia","label":"Evidência","type":"text"}]}]}}
  ]'::jsonb;
  comps jsonb := '[
    {"k":"kpi_card","n":"Card de KPI","t":"widget"},{"k":"data_table","n":"Tabela de dados","t":"widget"},
    {"k":"kanban_board","n":"Quadro Kanban","t":"widget"},{"k":"chart_bar","n":"Gráfico de barras","t":"chart"},
    {"k":"signature_pad","n":"Captura de assinatura","t":"field"},{"k":"qr_scanner","n":"Leitor de QR/código","t":"field"}
  ]'::jsonb;
  x jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    for x in select value from jsonb_array_elements(tpls) loop
      if not exists (select 1 from public.app_templates where company_id=c.id and template_key=(x->>'k') and deleted_at is null) then
        insert into public.app_templates (tenant_id, company_id, template_key, name, category, icon, description, definition)
        values (c.tenant_id, c.id, x->>'k', x->>'n', x->>'cat', x->>'i', x->>'d', x->'def');
      end if;
    end loop;
    for x in select value from jsonb_array_elements(comps) loop
      if not exists (select 1 from public.custom_components where company_id=c.id and component_key=(x->>'k') and deleted_at is null) then
        insert into public.custom_components (tenant_id, company_id, component_key, name, component_type) values (c.tenant_id, c.id, x->>'k', x->>'n', x->>'t');
      end if;
    end loop;
  end loop;
end $do$;

notify pgrst, 'reload schema';
