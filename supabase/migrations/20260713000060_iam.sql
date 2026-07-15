-- 20260713000060_iam.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  IASP — IDENTITY, ACCESS & SECURITY PLATFORM (Vol 28)                     ║
-- ║  Identidades, MFA/métodos de auth, sessões, dispositivos, políticas Zero  ║
-- ║  Trust, PAM (acesso privilegiado temporário), detecção de ameaças         ║
-- ║  (brute force), incidentes e certificação de acessos (SoD). Governança    ║
-- ║  sobre o RBAC existente. Nível Entra ID/Okta/CyberArk/SailPoint.          ║
-- ║  security_insights auto-descoberto pelo cérebro LAIOS.                   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

insert into public.permissions (slug, resource, action, description)
select 'iam.' || a, 'iam', a, 'Permissão ' || a || ' em iam'
from unnest(array['read','create','update','delete','approve','revoke']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'iam' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── IAM_IDENTITIES (governança por principal) ───────────────────────────────
create table public.iam_identities (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  subject_type text not null default 'user', user_id uuid references auth.users(id) on delete set null,
  display_name text, email text, status text default 'active', is_privileged boolean not null default false,
  mfa_enabled boolean not null default false, risk_score integer not null default 0, last_login_at timestamptz, inactive_days integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_iam_identities on public.iam_identities (company_id, status) where deleted_at is null;

-- ── AUTH_METHODS ────────────────────────────────────────────────────────────
create table public.auth_methods (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  identity_id uuid references public.iam_identities(id) on delete cascade,
  method text not null, enabled boolean not null default true, verified boolean not null default false, last_used_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── USER_SESSIONS + TRUSTED_DEVICES ─────────────────────────────────────────
create table public.user_sessions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  identity_id uuid references public.iam_identities(id) on delete set null, email text, device text, ip_address text, location text,
  status text default 'active', risk_score integer default 0, started_at timestamptz not null default now(), last_seen_at timestamptz default now(), expires_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_user_sessions on public.user_sessions (company_id, status) where deleted_at is null;
create table public.trusted_devices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  identity_id uuid references public.iam_identities(id) on delete cascade, name text, fingerprint text, os text, trusted boolean not null default false, last_seen_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── LOGIN_ATTEMPTS (auditoria / brute force) ────────────────────────────────
create table public.login_attempts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  email text, ip_address text, success boolean not null default false, reason text, method text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_login_attempts on public.login_attempts (company_id, email, created_at);

-- ── ACCESS_POLICIES (RBAC/ABAC/PBAC/Zero Trust) ─────────────────────────────
create table public.access_policies (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, policy_type text default 'abac', effect text default 'allow', resource text, conditions jsonb not null default '{}'::jsonb, priority integer default 100, enabled boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── PAM_REQUESTS (acesso privilegiado temporário) ───────────────────────────
create table public.pam_requests (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  identity_id uuid references public.iam_identities(id) on delete set null, requester text, privilege text not null, reason text,
  requested_hours integer default 4, status text default 'pending', approved_by uuid references auth.users(id), activated_at timestamptz, expires_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── SECURITY_INCIDENTS + ACCESS_CERTIFICATIONS ──────────────────────────────
create table public.security_incidents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  incident_type text not null, severity text default 'medium', subject text, description text, status text default 'open', detected_at timestamptz not null default now(), resolved_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_security_incidents on public.security_incidents (company_id, status) where deleted_at is null;
create table public.access_certifications (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, scope text, reviewer text, status text default 'pending', due_date date, reviewed_count integer default 0, total_count integer default 0, decision text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Registrar tentativa de login (auditoria + brute force)
create or replace function public.record_login_attempt(p_company uuid, p_email text, p_success boolean, p_ip text default null)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_fail int; v_locked boolean := false;
begin
  if not (app.can_access_company(p_company) and app.has_permission('iam.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.login_attempts (tenant_id, company_id, email, ip_address, success) values (v_tenant, p_company, p_email, p_ip, p_success);
  if not p_success then
    select count(*) into v_fail from public.login_attempts where company_id=p_company and email=p_email and not success and created_at > now() - interval '15 minutes';
    if v_fail >= 5 then
      v_locked := true;
      if not exists (select 1 from public.security_incidents where company_id=p_company and incident_type='brute_force' and subject=p_email and status='open' and deleted_at is null) then
        insert into public.security_incidents (tenant_id, company_id, incident_type, severity, subject, description, status)
        values (v_tenant, p_company, 'brute_force', 'high', p_email, v_fail||' tentativas de login falhas em 15 min.', 'open');
      end if;
    end if;
  end if;
  return jsonb_build_object('email', p_email, 'success', p_success, 'recent_failures', coalesce(v_fail,0), 'locked', v_locked);
end;
$$;
grant execute on function public.record_login_attempt(uuid, text, boolean, text) to authenticated;

-- Revogar sessão
create or replace function public.revoke_session(p_session uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare s record;
begin
  select * into s from public.user_sessions where id=p_session and deleted_at is null;
  if s.id is null then raise exception 'sessão não encontrada'; end if;
  if not (app.can_access_company(s.company_id) and app.has_permission('iam.revoke', s.company_id)) then raise exception 'forbidden'; end if;
  update public.user_sessions set status='revoked' where id=p_session;
  return jsonb_build_object('session', p_session, 'status', 'revoked');
end;
$$;
grant execute on function public.revoke_session(uuid) to authenticated;

-- PAM: solicitar acesso privilegiado + decidir
create or replace function public.request_pam(p_company uuid, p_privilege text, p_reason text, p_hours int default 4)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_id uuid;
begin
  if not (app.can_access_company(p_company) and app.has_permission('iam.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.pam_requests (tenant_id, company_id, requester, privilege, reason, requested_hours, status)
  values (v_tenant, p_company, (select email from public.iam_identities where user_id=auth.uid() and company_id=p_company limit 1), p_privilege, p_reason, p_hours, 'pending')
  returning id into v_id;
  return jsonb_build_object('request_id', v_id, 'privilege', p_privilege, 'status', 'pending');
end;
$$;
grant execute on function public.request_pam(uuid, text, text, int) to authenticated;

create or replace function public.decide_pam(p_request uuid, p_approve boolean)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare r record;
begin
  select * into r from public.pam_requests where id=p_request and deleted_at is null;
  if r.id is null then raise exception 'solicitação não encontrada'; end if;
  if not (app.can_access_company(r.company_id) and app.has_permission('iam.approve', r.company_id)) then raise exception 'forbidden'; end if;
  if p_approve then
    update public.pam_requests set status='active', approved_by=auth.uid(), activated_at=now(), expires_at=now() + (r.requested_hours||' hours')::interval where id=p_request;
  else
    update public.pam_requests set status='rejected', approved_by=auth.uid() where id=p_request;
  end if;
  return jsonb_build_object('request', p_request, 'status', case when p_approve then 'active' else 'rejected' end);
end;
$$;
grant execute on function public.decide_pam(uuid, boolean) to authenticated;

-- Detecção de ameaças (brute force, admins dormentes, PAM expirado) → incidentes
create or replace function public.detect_security_threats(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_new int := 0; r record;
begin
  if not (app.can_access_company(p_company) and app.has_permission('iam.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;

  -- brute force (>=5 falhas/60min por email) sem incidente aberto
  for r in select email, count(*) c from public.login_attempts where company_id=p_company and not success and created_at > now() - interval '60 minutes' group by email having count(*) >= 5 loop
    if not exists (select 1 from public.security_incidents where company_id=p_company and incident_type='brute_force' and subject=r.email and status='open' and deleted_at is null) then
      insert into public.security_incidents (tenant_id, company_id, incident_type, severity, subject, description) values (v_tenant, p_company, 'brute_force', 'high', r.email, r.c||' tentativas falhas.');
      v_new := v_new + 1;
    end if;
  end loop;
  -- contas privilegiadas dormentes (>90d)
  for r in select display_name, email from public.iam_identities where company_id=p_company and is_privileged and deleted_at is null and (last_login_at is null or last_login_at < now() - interval '90 days') loop
    if not exists (select 1 from public.security_incidents where company_id=p_company and incident_type='dormant_privileged' and subject=coalesce(r.email,r.display_name) and status='open' and deleted_at is null) then
      insert into public.security_incidents (tenant_id, company_id, incident_type, severity, subject, description) values (v_tenant, p_company, 'dormant_privileged', 'medium', coalesce(r.email,r.display_name), 'Conta privilegiada sem acesso há +90 dias.');
      v_new := v_new + 1;
    end if;
  end loop;
  -- expira PAM vencido
  update public.pam_requests set status='expired' where company_id=p_company and status='active' and expires_at < now() and deleted_at is null;
  return jsonb_build_object('new_incidents', v_new);
end;
$$;
grant execute on function public.detect_security_threats(uuid) to authenticated;

create or replace function public.iam_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'identities', (select count(*) from public.iam_identities where company_id=p_company and deleted_at is null),
    'privileged', (select count(*) from public.iam_identities where company_id=p_company and is_privileged and deleted_at is null),
    'mfa_coverage', (select coalesce(round(100.0 * count(*) filter (where mfa_enabled) / nullif(count(*),0)),0) from public.iam_identities where company_id=p_company and status='active' and deleted_at is null),
    'sessions_active', (select count(*) from public.user_sessions where company_id=p_company and status='active' and deleted_at is null),
    'incidents_open', (select count(*) from public.security_incidents where company_id=p_company and status='open' and deleted_at is null),
    'pam_active', (select count(*) from public.pam_requests where company_id=p_company and status='active' and deleted_at is null),
    'pam_pending', (select count(*) from public.pam_requests where company_id=p_company and status='pending' and deleted_at is null),
    'failed_logins_24h', (select count(*) from public.login_attempts where company_id=p_company and not success and created_at > now() - interval '24 hours'),
    'certifications_pending', (select count(*) from public.access_certifications where company_id=p_company and status='pending' and deleted_at is null),
    'policies', (select count(*) from public.access_policies where company_id=p_company and enabled and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.iam_dashboard(uuid) to authenticated;

create or replace function public.security_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_inc int; v_mfa int; v_cert int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Segurança%' and deleted_at is null;

  select count(*) into v_inc from public.security_incidents where company_id=p_company and status='open' and deleted_at is null;
  if v_inc > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'fraud_risk', 'critical', 'Segurança: incidentes abertos', v_inc||' incidente(s) de segurança em aberto.', 'Investigar e conter — possível ataque ou acesso indevido.', 92);
    v_c := v_c + 1;
  end if;
  select count(*) into v_mfa from public.iam_identities where company_id=p_company and status='active' and not mfa_enabled and deleted_at is null;
  if v_mfa > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'supplier_risk', 'warning', 'Segurança: usuários sem MFA', v_mfa||' identidade(s) ativa(s) sem autenticação multifator.', 'Exigir MFA — maior fator de risco de invasão.', 86);
    v_c := v_c + 1;
  end if;
  select count(*) into v_cert from public.access_certifications where company_id=p_company and status='pending' and due_date < now()::date and deleted_at is null;
  if v_cert > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'Segurança: certificações de acesso vencidas', v_cert||' campanha(s) de revisão de acesso vencida(s).', 'Concluir a certificação (SoD/compliance ISO 27001).', 80);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.security_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'iam') ────────────
do $do$
declare t text; specs text[] := array['iam_identities','auth_methods','user_sessions','trusted_devices','login_attempts','access_policies','pam_requests','security_incidents','access_certifications'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'iam.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'iam.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: identidades (a partir de memberships) + políticas + certificação ══
do $do$
declare c record;
  pols jsonb := '[
    {"n":"Exigir MFA para administradores","tp":"pbac","e":"deny","r":"admin.*","cond":{"mfa":false}},
    {"n":"Bloquear acesso fora do horário comercial","tp":"abac","e":"deny","r":"*","cond":{"outside_hours":true}},
    {"n":"Segregação de Funções: Financeiro x Aprovação","tp":"pbac","e":"deny","r":"finance.approve","cond":{"same_as_creator":true}},
    {"n":"Zero Trust: dispositivo não confiável exige reautenticação","tp":"zerotrust","e":"deny","r":"*","cond":{"trusted_device":false}}
  ]'::jsonb;
  x jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    -- identidades a partir das memberships (com profiles)
    insert into public.iam_identities (tenant_id, company_id, subject_type, user_id, display_name, email, is_privileged, mfa_enabled, last_login_at)
    select c.tenant_id, c.id, 'user', m.user_id, coalesce(p.full_name, u.email), u.email,
      coalesce(p.is_superadmin,false), false, now()
    from public.memberships m
    left join public.profiles p on p.user_id=m.user_id
    left join auth.users u on u.id=m.user_id
    where m.company_id=c.id and m.deleted_at is null
      and not exists (select 1 from public.iam_identities i where i.company_id=c.id and i.user_id=m.user_id and i.deleted_at is null);
    -- políticas
    for x in select value from jsonb_array_elements(pols) loop
      if not exists (select 1 from public.access_policies where company_id=c.id and name=(x->>'n') and deleted_at is null) then
        insert into public.access_policies (tenant_id, company_id, name, policy_type, effect, resource, conditions)
        values (c.tenant_id, c.id, x->>'n', x->>'tp', x->>'e', x->>'r', x->'cond');
      end if;
    end loop;
    -- campanha de certificação de acesso
    if not exists (select 1 from public.access_certifications where company_id=c.id and name='Certificação Trimestral de Acessos' and deleted_at is null) then
      insert into public.access_certifications (tenant_id, company_id, name, scope, status, due_date, total_count)
      values (c.tenant_id, c.id, 'Certificação Trimestral de Acessos', 'Todos os perfis', 'pending', (now()::date + 30),
        (select count(*) from public.memberships where company_id=c.id and deleted_at is null));
    end if;
  end loop;
end $do$;

notify pgrst, 'reload schema';
