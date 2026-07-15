-- 20260713000064_esap.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  ESAP — ENTERPRISE SUPER APP PLATFORM (Vol 32) — Fase 2 Enterprise+       ║
-- ║  Experiência multiplataforma (PWA/mobile/desktop): registro de            ║
-- ║  dispositivos, SYNC ENGINE (fila offline c/ conflitos), push, home        ║
-- ║  widgets e modos operacionais por perfil. Nível MS365/SAP Mobile Start.   ║
-- ║  esap_insights auto-descoberto LAIOS. Entrega push real = FCM/Edge (nota).║
-- ╚══════════════════════════════════════════════════════════════════════════╝

insert into public.permissions (slug, resource, action, description)
select 'mobile.' || a, 'mobile', a, 'Permissão ' || a || ' em mobile'
from unnest(array['read','create','update','delete','approve','manage']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'mobile' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── DEVICES (registro de dispositivos) ──────────────────────────────────────
create table public.devices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  user_id uuid references auth.users(id) on delete set null,
  name text not null, platform text default 'web', os text, app_version text, push_token text, status text default 'active',
  is_trusted boolean not null default false, last_seen_at timestamptz, last_sync_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_devices on public.devices (company_id, status) where deleted_at is null;

-- ── SYNC_QUEUE (fila offline — sync engine) ─────────────────────────────────
create table public.sync_queue (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  device_id uuid references public.devices(id) on delete cascade,
  entity text not null, operation text default 'update', direction text default 'up', payload jsonb not null default '{}'::jsonb,
  status text not null default 'pending', attempts integer not null default 0, error text, synced_at timestamptz, priority integer default 3,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_sync_queue on public.sync_queue (company_id, status, priority) where deleted_at is null;

-- ── PUSH_NOTIFICATIONS ──────────────────────────────────────────────────────
create table public.push_notifications (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  device_id uuid references public.devices(id) on delete set null, user_id uuid references auth.users(id) on delete set null,
  title text not null, body text, category text default 'info', deep_link text, status text default 'sent', sent_at timestamptz default now(), read_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_push_notifications on public.push_notifications (company_id, status, created_at);

-- ── HOME_WIDGETS + MOBILE_PROFILES ──────────────────────────────────────────
create table public.home_widgets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  user_id uuid references auth.users(id) on delete cascade,
  widget_key text not null, title text, size text default 'md', position integer default 0, config jsonb not null default '{}'::jsonb, enabled boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.mobile_profiles (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  mode_key text not null, name text, icon text, allowed_modules text[], home_layout jsonb not null default '[]'::jsonb,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Registrar/atualizar dispositivo (upsert por push_token ou nome+user)
create or replace function public.register_device(p_company uuid, p_name text, p_platform text, p_version text default null, p_push_token text default null, p_os text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_id uuid;
begin
  if not (app.can_access_company(p_company) and app.has_permission('mobile.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select id into v_id from public.devices where company_id=p_company and user_id=auth.uid() and name=p_name and deleted_at is null limit 1;
  if v_id is null then
    insert into public.devices (tenant_id, company_id, user_id, name, platform, os, app_version, push_token, last_seen_at)
    values (v_tenant, p_company, auth.uid(), p_name, p_platform, p_os, p_version, p_push_token, now()) returning id into v_id;
  else
    update public.devices set platform=p_platform, os=coalesce(p_os,os), app_version=coalesce(p_version,app_version), push_token=coalesce(p_push_token,push_token), last_seen_at=now() where id=v_id;
  end if;
  return jsonb_build_object('device_id', v_id, 'name', p_name);
end;
$$;
grant execute on function public.register_device(uuid, text, text, text, text, text) to authenticated;

-- Enfileirar operação para sincronização (offline)
create or replace function public.enqueue_sync(p_company uuid, p_device uuid, p_entity text, p_operation text, p_payload jsonb, p_direction text default 'up')
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_id uuid;
begin
  if not (app.can_access_company(p_company) and app.has_permission('mobile.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.sync_queue (tenant_id, company_id, device_id, entity, operation, direction, payload, status)
  values (v_tenant, p_company, p_device, p_entity, p_operation, p_direction, coalesce(p_payload,'{}'::jsonb), 'pending') returning id into v_id;
  return jsonb_build_object('sync_id', v_id, 'status', 'pending');
end;
$$;
grant execute on function public.enqueue_sync(uuid, uuid, text, text, jsonb, text) to authenticated;

-- SYNC ENGINE: processa a fila (detecta conflito: 2 'up' pendentes p/ mesma entidade)
create or replace function public.process_sync(p_company uuid, p_device uuid default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare m record; v_ok int := 0; v_conf int := 0; v_dup boolean;
begin
  if not (app.can_access_company(p_company) and app.has_permission('mobile.update', p_company)) then raise exception 'forbidden'; end if;
  for m in select * from public.sync_queue where company_id=p_company and status='pending' and (p_device is null or device_id=p_device) and deleted_at is null order by priority, created_at limit 500 loop
    select exists (select 1 from public.sync_queue s where s.company_id=p_company and s.entity=m.entity and s.direction='up' and s.status in ('synced','conflict') and (s.payload->>'ref') is not distinct from (m.payload->>'ref') and s.id<>m.id and s.updated_at > m.created_at) into v_dup;
    if v_dup then
      update public.sync_queue set status='conflict', attempts=attempts+1, error='conflito de versão (edição concorrente)' where id=m.id; v_conf := v_conf + 1;
    else
      update public.sync_queue set status='synced', attempts=attempts+1, synced_at=now() where id=m.id; v_ok := v_ok + 1;
    end if;
  end loop;
  if p_device is not null then update public.devices set last_sync_at=now() where id=p_device; end if;
  return jsonb_build_object('synced', v_ok, 'conflicts', v_conf);
end;
$$;
grant execute on function public.process_sync(uuid, uuid) to authenticated;

-- Enviar push (registra; entrega real via FCM/Edge Function)
create or replace function public.send_push(p_company uuid, p_title text, p_body text, p_category text default 'info', p_device uuid default null, p_deep_link text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_id uuid;
begin
  if not (app.can_access_company(p_company) and app.has_permission('mobile.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.push_notifications (tenant_id, company_id, device_id, title, body, category, deep_link, status, sent_at)
  values (v_tenant, p_company, p_device, p_title, p_body, p_category, p_deep_link, 'sent', now()) returning id into v_id;
  return jsonb_build_object('notification_id', v_id, 'status', 'sent');
end;
$$;
grant execute on function public.send_push(uuid, text, text, text, uuid, text) to authenticated;

create or replace function public.esap_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'devices', (select count(*) from public.devices where company_id=p_company and deleted_at is null),
    'devices_active', (select count(*) from public.devices where company_id=p_company and status='active' and last_seen_at > now() - interval '7 days' and deleted_at is null),
    'sync_pending', (select count(*) from public.sync_queue where company_id=p_company and status='pending' and deleted_at is null),
    'sync_conflicts', (select count(*) from public.sync_queue where company_id=p_company and status='conflict' and deleted_at is null),
    'sync_synced', (select count(*) from public.sync_queue where company_id=p_company and status='synced' and deleted_at is null),
    'push_sent_today', (select count(*) from public.push_notifications where company_id=p_company and sent_at::date=now()::date and deleted_at is null),
    'push_unread', (select count(*) from public.push_notifications where company_id=p_company and read_at is null and status='sent' and deleted_at is null),
    'profiles', (select count(*) from public.mobile_profiles where company_id=p_company and deleted_at is null),
    'by_platform', (select coalesce(jsonb_object_agg(platform, c),'{}'::jsonb) from (select platform, count(*) c from public.devices where company_id=p_company and deleted_at is null group by platform) s)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.esap_dashboard(uuid) to authenticated;

create or replace function public.esap_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_conf int; v_stale int; v_queue int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'App%' and deleted_at is null;

  select count(*) into v_conf from public.sync_queue where company_id=p_company and status='conflict' and deleted_at is null;
  if v_conf > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'App: conflitos de sincronização', v_conf||' registro(s) com conflito de sync (edição offline concorrente).', 'Resolver os conflitos para não perder dados de campo.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_queue from public.sync_queue where company_id=p_company and status='pending' and created_at < now() - interval '1 day' and deleted_at is null;
  if v_queue > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'App: fila offline acumulando', v_queue||' operação(ões) offline sem sincronizar há +24h.', 'Verificar conectividade dos dispositivos de campo.', 74);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.esap_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'mobile') ─────────
do $do$
declare t text; specs text[] := array['devices','sync_queue','push_notifications','home_widgets','mobile_profiles'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'mobile.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'mobile.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: modos operacionais ══
do $do$
declare c record;
  modes jsonb := '[
    {"k":"operador","n":"Operador de Produção","i":"🏭","m":["mes","producao","inventario","qualidade"]},
    {"k":"supervisor","n":"Supervisor","i":"📋","m":["producao","estoque","processos","comando"]},
    {"k":"vendedor","n":"Vendedor","i":"🤝","m":["comercial","pedidos","commerce"]},
    {"k":"motorista","n":"Motorista","i":"🚚","m":["tms","distribuicao","frota"]},
    {"k":"tecnico","n":"Técnico de Manutenção","i":"🔧","m":["manutencao","patrimonio"]},
    {"k":"auditor","n":"Auditor","i":"🔎","m":["auditoria","documentos","seguranca"]},
    {"k":"diretor","n":"Diretor","i":"📈","m":["comando","analytics","ceo","planejamento"]}
  ]'::jsonb;
  x jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    for x in select value from jsonb_array_elements(modes) loop
      if not exists (select 1 from public.mobile_profiles where company_id=c.id and mode_key=(x->>'k') and deleted_at is null) then
        insert into public.mobile_profiles (tenant_id, company_id, mode_key, name, icon, allowed_modules)
        values (c.tenant_id, c.id, x->>'k', x->>'n', x->>'i', array(select jsonb_array_elements_text(x->'m')));
      end if;
    end loop;
  end loop;
end $do$;

notify pgrst, 'reload schema';
