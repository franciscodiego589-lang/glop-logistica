-- 20260713000061_epa.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  EPA — ENTERPRISE PLATFORM ADMINISTRATION (Vol 29) — o "SAP IMG" do ERP   ║
-- ║  Centro de Configuração (95% parametrizável sem código, com HISTÓRICO +   ║
-- ║  ROLLBACK), feature flags, multimoeda, multilíngue, ambientes, registro   ║
-- ║  de módulos (ativar/desativar), licenciamento. Nível SAP IMG/SF Setup.    ║
-- ║  epa_insights auto-descoberto pelo cérebro LAIOS.                        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- reusa recurso RBAC 'admin' (administração da plataforma)
insert into public.permissions (slug, resource, action, description)
select 'admin.' || a, 'admin', a, 'Permissão ' || a || ' em admin'
from unnest(array['read','create','update','delete','approve','configure']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'admin' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── PLATFORM_SETTINGS (Centro de Configuração) ──────────────────────────────
create table public.platform_settings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  setting_key text not null, value text, category text default 'geral', data_type text default 'string',
  name text, description text, editable boolean not null default true, is_sensitive boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_platform_settings on public.platform_settings (company_id, setting_key) where deleted_at is null;

-- ── CONFIG_HISTORY (versionamento / rollback) ───────────────────────────────
create table public.config_history (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  setting_key text not null, old_value text, new_value text, action text default 'update', changed_by uuid references auth.users(id),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_config_history on public.config_history (company_id, setting_key, created_at desc);

-- ── FEATURE_FLAGS ───────────────────────────────────────────────────────────
create table public.feature_flags (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  flag_key text not null, name text, enabled boolean not null default false, rollout_pct integer default 100, environment text default 'production', stage text default 'ga', description text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_feature_flags on public.feature_flags (company_id, flag_key) where deleted_at is null;

-- ── CURRENCIES + LANGUAGES + TRANSLATIONS ───────────────────────────────────
create table public.currencies (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null, name text, symbol text, is_base boolean not null default false, rate_to_base numeric(18,6) not null default 1, rate_updated_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.languages (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text not null, name text, enabled boolean not null default true, is_default boolean not null default false, completion_pct integer default 100,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── ENVIRONMENTS + MODULE_REGISTRY + LICENSES ───────────────────────────────
create table public.environments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  name text not null, env_type text default 'production', status text default 'active', url text, notes text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.module_registry (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  module_key text not null, name text, category text, enabled boolean not null default true, module_version text default '1.0', plan_tier text default 'enterprise', is_marketplace boolean not null default false,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_module_registry on public.module_registry (company_id, module_key) where deleted_at is null;
create table public.licenses (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  plan text not null default 'enterprise', users_limit integer, modules_limit integer, status text default 'active', valid_until date, seats_used integer default 0,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ RPCs ═══════════════════════════════════════════════════════════════════

-- Alterar um parâmetro (com histórico p/ rollback) — upsert
create or replace function public.set_setting(p_company uuid, p_key text, p_value text, p_category text default 'geral')
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_old text; v_exists boolean;
begin
  if not (app.can_access_company(p_company) and app.has_permission('admin.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select value, true into v_old, v_exists from public.platform_settings where company_id=p_company and setting_key=p_key and deleted_at is null;
  if v_exists then
    update public.platform_settings set value=p_value where company_id=p_company and setting_key=p_key;
  else
    insert into public.platform_settings (tenant_id, company_id, setting_key, value, category) values (v_tenant, p_company, p_key, p_value, p_category);
  end if;
  insert into public.config_history (tenant_id, company_id, setting_key, old_value, new_value, action, changed_by)
  values (v_tenant, p_company, p_key, v_old, p_value, case when v_exists then 'update' else 'create' end, auth.uid());
  return jsonb_build_object('key', p_key, 'old', v_old, 'new', p_value);
end;
$$;
grant execute on function public.set_setting(uuid, text, text, text) to authenticated;

-- Rollback: restaura o valor anterior do último histórico
create or replace function public.rollback_setting(p_company uuid, p_key text)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; h record;
begin
  if not (app.can_access_company(p_company) and app.has_permission('admin.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select * into h from public.config_history where company_id=p_company and setting_key=p_key and deleted_at is null order by created_at desc limit 1;
  if h.id is null or h.old_value is null then raise exception 'sem histórico para rollback'; end if;
  update public.platform_settings set value=h.old_value where company_id=p_company and setting_key=p_key;
  insert into public.config_history (tenant_id, company_id, setting_key, old_value, new_value, action, changed_by)
  values (v_tenant, p_company, p_key, h.new_value, h.old_value, 'rollback', auth.uid());
  return jsonb_build_object('key', p_key, 'restored_to', h.old_value);
end;
$$;
grant execute on function public.rollback_setting(uuid, text) to authenticated;

-- Conversão multimoeda
create or replace function public.convert_currency(p_company uuid, p_amount numeric, p_from text, p_to text)
returns jsonb language plpgsql stable security definer set search_path = public, app as $$
declare rf numeric; rt numeric; v_base numeric; v_res numeric;
begin
  if not app.can_access_company(p_company) then return '{}'::jsonb; end if;
  select rate_to_base into rf from public.currencies where company_id=p_company and code=p_from and deleted_at is null;
  select rate_to_base into rt from public.currencies where company_id=p_company and code=p_to and deleted_at is null;
  if rf is null or rt is null then return jsonb_build_object('error','moeda não cadastrada'); end if;
  v_base := p_amount * rf; v_res := round(v_base / nullif(rt,0), 2);
  return jsonb_build_object('amount', p_amount, 'from', p_from, 'to', p_to, 'result', v_res, 'rate', round(rf/nullif(rt,0),6));
end;
$$;
grant execute on function public.convert_currency(uuid, numeric, text, text) to authenticated;

create or replace function public.epa_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'companies', (select count(*) from public.companies where tenant_id=(select tenant_id from public.companies where id=p_company) and deleted_at is null),
    'users', (select count(distinct user_id) from public.memberships where company_id=p_company and deleted_at is null),
    'settings', (select count(*) from public.platform_settings where company_id=p_company and deleted_at is null),
    'modules_enabled', (select count(*) from public.module_registry where company_id=p_company and enabled and deleted_at is null),
    'modules_total', (select count(*) from public.module_registry where company_id=p_company and deleted_at is null),
    'feature_flags_on', (select count(*) from public.feature_flags where company_id=p_company and enabled and deleted_at is null),
    'currencies', (select count(*) from public.currencies where company_id=p_company and deleted_at is null),
    'languages', (select count(*) from public.languages where company_id=p_company and enabled and deleted_at is null),
    'environments', (select count(*) from public.environments where company_id=p_company and deleted_at is null),
    'config_changes_7d', (select count(*) from public.config_history where company_id=p_company and created_at > now() - interval '7 days'),
    'license', (select jsonb_build_object('plan', plan, 'users_limit', users_limit, 'valid_until', valid_until, 'status', status) from public.licenses where company_id=p_company and deleted_at is null order by created_at desc limit 1)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.epa_dashboard(uuid) to authenticated;

create or replace function public.epa_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_lic int; v_base int; v_chg int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Admin%' and deleted_at is null;

  select count(*) into v_lic from public.licenses where company_id=p_company and status='active' and valid_until is not null and valid_until <= now()::date + 30 and deleted_at is null;
  if v_lic > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'sla_risk', 'warning', 'Admin: licença a vencer', 'A licença da plataforma vence em até 30 dias.', 'Renovar para não interromper o acesso.', 88);
    v_c := v_c + 1;
  end if;
  select count(*) into v_base from public.currencies where company_id=p_company and is_base and deleted_at is null;
  if v_base <> 1 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'Admin: moeda base inconsistente', 'Deve haver exatamente 1 moeda base configurada (encontradas: '||v_base||').', 'Configurar a moeda base no Admin Global.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_chg from public.config_history where company_id=p_company and created_at > now() - interval '24 hours';
  if v_chg >= 10 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'Admin: muitas mudanças de configuração', v_chg||' alterações de parâmetros nas últimas 24h.', 'Revisar mudanças (governança/rollback se necessário).', 70);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.epa_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'admin') ──────────
do $do$
declare t text; specs text[] := array['platform_settings','config_history','feature_flags','currencies','languages','environments','module_registry','licenses'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'admin.update');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'admin.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: parâmetros + flags + moedas + idiomas + ambientes + módulos + licença ══
do $do$
declare c record;
  sets jsonb := '[
    {"k":"company.timezone","v":"America/Sao_Paulo","cat":"geral","n":"Fuso horário"},
    {"k":"company.fiscal_year_start","v":"01-01","cat":"geral","n":"Início do ano fiscal"},
    {"k":"finance.default_payment_terms","v":"30","cat":"financeiro","n":"Prazo de pagamento padrão (dias)"},
    {"k":"fiscal.default_regime","v":"simples","cat":"fiscal","n":"Regime tributário padrão"},
    {"k":"inventory.fefo_enabled","v":"true","cat":"estoque","n":"Separação FEFO"},
    {"k":"inventory.reorder_auto","v":"false","cat":"estoque","n":"Sugestão de compra automática"},
    {"k":"production.auto_backflush","v":"true","cat":"producao","n":"Baixa automática de insumos"},
    {"k":"crm.lead_auto_assign","v":"true","cat":"crm","n":"Distribuição automática de leads"},
    {"k":"hr.probation_days","v":"90","cat":"rh","n":"Período de experiência (dias)"},
    {"k":"ai.laios_autonomy","v":"suggest","cat":"ia","n":"Autonomia do cérebro LAIOS"},
    {"k":"ai.cron_minutes","v":"15","cat":"ia","n":"Frequência da varredura da IA (min)"},
    {"k":"security.idle_timeout_min","v":"15","cat":"seguranca","n":"Logout por inatividade (min)"}
  ]'::jsonb;
  flags jsonb := '[
    {"k":"new_executive_cockpit","n":"Novo Cockpit Executivo","e":true,"st":"ga"},
    {"k":"ai_copilot","n":"Copiloto de IA por módulo","e":false,"st":"beta"},
    {"k":"whatsapp_integration","n":"Integração WhatsApp","e":false,"st":"beta"},
    {"k":"advanced_analytics","n":"Analytics avançado","e":true,"st":"ga"}
  ]'::jsonb;
  curs jsonb := '[
    {"c":"BRL","n":"Real","s":"R$","b":true,"r":1},
    {"c":"USD","n":"Dólar americano","s":"US$","b":false,"r":5.4},
    {"c":"EUR","n":"Euro","s":"€","b":false,"r":5.9}
  ]'::jsonb;
  langs jsonb := '[
    {"c":"pt-BR","n":"Português (Brasil)","d":true,"p":100},
    {"c":"en","n":"English","d":false,"p":80},
    {"c":"es","n":"Español","d":false,"p":75}
  ]'::jsonb;
  envs jsonb := '[
    {"n":"Produção","t":"production","s":"active"},
    {"n":"Homologação","t":"staging","s":"active"},
    {"n":"Desenvolvimento","t":"development","s":"active"},
    {"n":"Sandbox","t":"sandbox","s":"inactive"}
  ]'::jsonb;
  mods jsonb := '[
    {"k":"wms","n":"WMS / Armazém","cat":"Operacao"},{"k":"tms","n":"TMS / Transporte","cat":"Operacao"},
    {"k":"comercial","n":"CRM & Vendas","cat":"Comercial"},{"k":"pedidos","n":"OMS / Pedidos","cat":"Comercial"},
    {"k":"commerce","n":"Loja & Comércio Digital","cat":"Comercial"},{"k":"financeiro","n":"Financeiro","cat":"Financeiro"},
    {"k":"contabilidade","n":"Contabilidade","cat":"Financeiro"},{"k":"fiscal","n":"Fiscal & Tributário","cat":"Financeiro"},
    {"k":"rh","n":"RH / HCM","cat":"Pessoas"},{"k":"folha","n":"Folha","cat":"Pessoas"},
    {"k":"processos","n":"BPM & Workflows","cat":"Plataforma"},{"k":"documentos","n":"ECM / GED","cat":"Plataforma"},
    {"k":"analytics","n":"BI & Analytics","cat":"Plataforma"},{"k":"mdm","n":"MDM","cat":"Plataforma"},
    {"k":"integracoes","n":"Integrações (iPaaS)","cat":"Plataforma"},{"k":"seguranca","n":"IAM & Segurança","cat":"Plataforma"},
    {"k":"ia-central","n":"LAIOS (Cérebro IA)","cat":"IA"}
  ]'::jsonb;
  x jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    for x in select value from jsonb_array_elements(sets) loop
      if not exists (select 1 from public.platform_settings where company_id=c.id and setting_key=(x->>'k') and deleted_at is null) then
        insert into public.platform_settings (tenant_id, company_id, setting_key, value, category, name) values (c.tenant_id, c.id, x->>'k', x->>'v', x->>'cat', x->>'n');
      end if;
    end loop;
    for x in select value from jsonb_array_elements(flags) loop
      if not exists (select 1 from public.feature_flags where company_id=c.id and flag_key=(x->>'k') and deleted_at is null) then
        insert into public.feature_flags (tenant_id, company_id, flag_key, name, enabled, stage) values (c.tenant_id, c.id, x->>'k', x->>'n', (x->>'e')::boolean, x->>'st');
      end if;
    end loop;
    for x in select value from jsonb_array_elements(curs) loop
      if not exists (select 1 from public.currencies where company_id=c.id and code=(x->>'c') and deleted_at is null) then
        insert into public.currencies (tenant_id, company_id, code, name, symbol, is_base, rate_to_base, rate_updated_at) values (c.tenant_id, c.id, x->>'c', x->>'n', x->>'s', (x->>'b')::boolean, (x->>'r')::numeric, now());
      end if;
    end loop;
    for x in select value from jsonb_array_elements(langs) loop
      if not exists (select 1 from public.languages where company_id=c.id and code=(x->>'c') and deleted_at is null) then
        insert into public.languages (tenant_id, company_id, code, name, is_default, completion_pct) values (c.tenant_id, c.id, x->>'c', x->>'n', (x->>'d')::boolean, (x->>'p')::int);
      end if;
    end loop;
    for x in select value from jsonb_array_elements(envs) loop
      if not exists (select 1 from public.environments where company_id=c.id and name=(x->>'n') and deleted_at is null) then
        insert into public.environments (tenant_id, company_id, name, env_type, status) values (c.tenant_id, c.id, x->>'n', x->>'t', x->>'s');
      end if;
    end loop;
    for x in select value from jsonb_array_elements(mods) loop
      if not exists (select 1 from public.module_registry where company_id=c.id and module_key=(x->>'k') and deleted_at is null) then
        insert into public.module_registry (tenant_id, company_id, module_key, name, category, enabled) values (c.tenant_id, c.id, x->>'k', x->>'n', x->>'cat', true);
      end if;
    end loop;
    if not exists (select 1 from public.licenses where company_id=c.id and deleted_at is null) then
      insert into public.licenses (tenant_id, company_id, plan, users_limit, modules_limit, status, valid_until)
      values (c.tenant_id, c.id, 'enterprise', 100, 999, 'active', (now()::date + interval '1 year')::date);
    end if;
  end loop;
end $do$;

notify pgrst, 'reload schema';
