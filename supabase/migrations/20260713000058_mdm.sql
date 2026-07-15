-- 20260713000058_mdm.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  EMDM — MASTER DATA MANAGEMENT (Vol 26) — o "DNA do ERP"                  ║
-- ║  Fonte única da verdade: domínios mestres governados, DATA QUALITY SCORE  ║
-- ║  (completude+unicidade sobre dados reais), MATCH & MERGE (deduplicação),   ║
-- ║  governança de mudanças, linhagem e glossário. Nível SAP MDG/Informatica. ║
-- ║  mdm_insights auto-descoberto pelo cérebro LAIOS.                        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

insert into public.permissions (slug, resource, action, description)
select 'mdm.' || a, 'mdm', a, 'Permissão ' || a || ' em mdm'
from unnest(array['read','create','update','delete','approve','merge']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'mdm' and r.slug in ('admin','superadmin')
on conflict do nothing;

-- ── MDM_DOMAINS (registro dos domínios de dados mestres) ────────────────────
create table public.mdm_domains (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  domain_key text not null, name text not null, source_table text, data_owner text, data_steward text,
  key_fields text[], quality_score integer, records_count integer, enabled boolean not null default true, last_assessed_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create unique index uq_mdm_domains_key on public.mdm_domains (company_id, domain_key) where deleted_at is null;

-- ── MDM_QUALITY_RULES ───────────────────────────────────────────────────────
create table public.mdm_quality_rules (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  domain_key text not null, name text not null, rule_type text default 'completeness', field text, expression text, weight numeric(5,2) default 1, enabled boolean not null default true,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── MDM_DUPLICATES (candidatos de match & merge) ────────────────────────────
create table public.mdm_duplicates (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  domain_key text not null, record_a uuid, record_b uuid, label_a text, label_b text, match_score numeric(5,2), reason text,
  status text not null default 'pending', resolution text, resolved_by uuid references auth.users(id), resolved_at timestamptz,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_mdm_duplicates on public.mdm_duplicates (company_id, domain_key, status) where deleted_at is null;

-- ── MDM_CHANGE_REQUESTS (governança de alterações) ──────────────────────────
create table public.mdm_change_requests (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  domain_key text not null, record_id uuid, action text default 'update', title text, payload jsonb not null default '{}'::jsonb,
  status text not null default 'pending', requested_by uuid references auth.users(id), approved_by uuid references auth.users(id), decided_at timestamptz, process_instance_id uuid,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── DATA_LINEAGE + MDM_GLOSSARY ─────────────────────────────────────────────
create table public.data_lineage (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  source_domain text, target_module text, relationship text default 'feeds', description text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create table public.mdm_glossary (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  term text not null, definition text, domain text, synonyms text[], steward text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ══ MOTOR DE QUALIDADE: mede completude + unicidade sobre a tabela real ═════
create or replace function public.assess_domain_quality(p_company uuid, p_domain text)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare v_count int := 0; v_compl numeric := 0; v_uniq numeric := 1; v_score int;
begin
  if not (app.can_access_company(p_company) and app.has_permission('mdm.update', p_company)) then raise exception 'forbidden'; end if;
  if p_domain = 'products' then
    select count(*), coalesce(avg(((name is not null)::int + (nullif(sku,'') is not null)::int + (nullif(ncm,'') is not null)::int + (cost_price is not null)::int)::numeric/4),0),
      coalesce(count(distinct lower(coalesce(sku,name)))::numeric / nullif(count(*),0),1)
      into v_count, v_compl, v_uniq from public.products where company_id=p_company and deleted_at is null;
  elsif p_domain = 'customers' then
    select count(*), coalesce(avg(((name is not null)::int + (nullif(document,'') is not null)::int + (nullif(email,'') is not null)::int + (nullif(segment,'') is not null)::int)::numeric/4),0),
      coalesce(count(distinct lower(coalesce(nullif(document,''),name)))::numeric / nullif(count(*),0),1)
      into v_count, v_compl, v_uniq from public.crm_accounts where company_id=p_company and deleted_at is null;
  elsif p_domain = 'employees' then
    select count(*), coalesce(avg(((full_name is not null)::int + (nullif(document,'') is not null)::int + (nullif(email,'') is not null)::int + (position_id is not null)::int)::numeric/4),0),
      coalesce(count(distinct lower(coalesce(nullif(document,''),full_name)))::numeric / nullif(count(*),0),1)
      into v_count, v_compl, v_uniq from public.employees where company_id=p_company and deleted_at is null;
  elsif p_domain = 'suppliers' then
    select count(*), coalesce(avg(((name is not null)::int + (nullif(document,'') is not null)::int + (nullif(country,'') is not null)::int)::numeric/3),0),
      coalesce(count(distinct lower(coalesce(nullif(document,''),name)))::numeric / nullif(count(*),0),1)
      into v_count, v_compl, v_uniq from public.trade_partners where company_id=p_company and deleted_at is null;
  else
    return jsonb_build_object('error','domínio sem coletor de qualidade');
  end if;

  v_score := round((v_compl*0.6 + v_uniq*0.4) * 100);
  update public.mdm_domains set quality_score=v_score, records_count=v_count, last_assessed_at=now() where company_id=p_company and domain_key=p_domain;
  return jsonb_build_object('domain', p_domain, 'records', v_count, 'completeness', round(v_compl*100,1), 'uniqueness', round(v_uniq*100,1), 'score', v_score);
end;
$$;
grant execute on function public.assess_domain_quality(uuid, text) to authenticated;

-- MATCH: detecta candidatos duplicados por chave (nome/documento/sku)
create or replace function public.detect_duplicates(p_company uuid, p_domain text)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; r record; v_c int := 0;
begin
  if not (app.can_access_company(p_company) and app.has_permission('mdm.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  -- limpa candidatos pendentes antigos do domínio
  delete from public.mdm_duplicates where company_id=p_company and domain_key=p_domain and status='pending';

  if p_domain='products' then
    for r in select a.id ida, b.id idb, a.name la, b.name lb,
        (case when nullif(a.sku,'')=nullif(b.sku,'') then 100 else 90 end) score,
        (case when nullif(a.sku,'')=nullif(b.sku,'') then 'mesmo SKU' else 'mesmo nome' end) reason
      from public.products a join public.products b on b.company_id=a.company_id and a.id < b.id
        and (lower(trim(a.name))=lower(trim(b.name)) or (nullif(a.sku,'') is not null and a.sku=b.sku))
      where a.company_id=p_company and a.deleted_at is null and b.deleted_at is null loop
      insert into public.mdm_duplicates (tenant_id, company_id, domain_key, record_a, record_b, label_a, label_b, match_score, reason)
      values (v_tenant, p_company, 'products', r.ida, r.idb, r.la, r.lb, r.score, r.reason); v_c := v_c + 1;
    end loop;
  elsif p_domain='customers' then
    for r in select a.id ida, b.id idb, a.name la, b.name lb,
        (case when nullif(a.document,'')=nullif(b.document,'') then 100 else 88 end) score,
        (case when nullif(a.document,'')=nullif(b.document,'') then 'mesmo documento' else 'mesmo nome' end) reason
      from public.crm_accounts a join public.crm_accounts b on b.company_id=a.company_id and a.id < b.id
        and (lower(trim(a.name))=lower(trim(b.name)) or (nullif(a.document,'') is not null and a.document=b.document))
      where a.company_id=p_company and a.deleted_at is null and b.deleted_at is null loop
      insert into public.mdm_duplicates (tenant_id, company_id, domain_key, record_a, record_b, label_a, label_b, match_score, reason)
      values (v_tenant, p_company, 'customers', r.ida, r.idb, r.la, r.lb, r.score, r.reason); v_c := v_c + 1;
    end loop;
  elsif p_domain='employees' then
    for r in select a.id ida, b.id idb, a.full_name la, b.full_name lb,
        (case when nullif(a.document,'')=nullif(b.document,'') then 100 else 88 end) score, 'mesmo colaborador' reason
      from public.employees a join public.employees b on b.company_id=a.company_id and a.id < b.id
        and (lower(trim(a.full_name))=lower(trim(b.full_name)) or (nullif(a.document,'') is not null and a.document=b.document))
      where a.company_id=p_company and a.deleted_at is null and b.deleted_at is null loop
      insert into public.mdm_duplicates (tenant_id, company_id, domain_key, record_a, record_b, label_a, label_b, match_score, reason)
      values (v_tenant, p_company, 'employees', r.ida, r.idb, r.la, r.lb, r.score, r.reason); v_c := v_c + 1;
    end loop;
  elsif p_domain='suppliers' then
    for r in select a.id ida, b.id idb, a.name la, b.name lb, 90 score, 'fornecedor semelhante' reason
      from public.trade_partners a join public.trade_partners b on b.company_id=a.company_id and a.id < b.id
        and lower(trim(a.name))=lower(trim(b.name))
      where a.company_id=p_company and a.deleted_at is null and b.deleted_at is null loop
      insert into public.mdm_duplicates (tenant_id, company_id, domain_key, record_a, record_b, label_a, label_b, match_score, reason)
      values (v_tenant, p_company, 'suppliers', r.ida, r.idb, r.la, r.lb, r.score, r.reason); v_c := v_c + 1;
    end loop;
  end if;
  return v_c;
end;
$$;
grant execute on function public.detect_duplicates(uuid, text) to authenticated;

-- MERGE: mantém o sobrevivente e desativa (soft-delete) o duplicado
create or replace function public.merge_records(p_duplicate uuid, p_keep text default 'a')
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare d record; v_src text; v_loser uuid; v_keep uuid;
begin
  select * into d from public.mdm_duplicates where id=p_duplicate and deleted_at is null;
  if d.id is null then raise exception 'candidato não encontrado'; end if;
  if not (app.can_access_company(d.company_id) and app.has_permission('mdm.merge', d.company_id)) then raise exception 'forbidden'; end if;
  select source_table into v_src from public.mdm_domains where company_id=d.company_id and domain_key=d.domain_key;
  if v_src is null then raise exception 'domínio sem tabela de origem'; end if;
  if p_keep='a' then v_keep := d.record_a; v_loser := d.record_b; else v_keep := d.record_b; v_loser := d.record_a; end if;

  execute format('update public.%I set deleted_at=now(), reason_deleted=%L, active=false where id=%L and company_id=%L', v_src, 'MDM merge → mantido '||v_keep::text, v_loser, d.company_id);
  update public.mdm_duplicates set status='merged', resolution='mantido '||v_keep::text, resolved_by=auth.uid(), resolved_at=now() where id=p_duplicate;
  return jsonb_build_object('duplicate', p_duplicate, 'kept', v_keep, 'merged_out', v_loser);
end;
$$;
grant execute on function public.merge_records(uuid, text) to authenticated;

create or replace function public.mdm_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'domains', (select count(*) from public.mdm_domains where company_id=p_company and deleted_at is null),
    'avg_quality', (select coalesce(round(avg(quality_score)),0) from public.mdm_domains where company_id=p_company and quality_score is not null and deleted_at is null),
    'duplicates_open', (select count(*) from public.mdm_duplicates where company_id=p_company and status='pending' and deleted_at is null),
    'change_requests_pending', (select count(*) from public.mdm_change_requests where company_id=p_company and status='pending' and deleted_at is null),
    'glossary_terms', (select count(*) from public.mdm_glossary where company_id=p_company and deleted_at is null),
    'lineage_links', (select count(*) from public.data_lineage where company_id=p_company and deleted_at is null),
    'by_domain', (select coalesce(jsonb_agg(jsonb_build_object('domain', name, 'key', domain_key, 'score', quality_score, 'records', records_count) order by quality_score nulls last),'[]'::jsonb) from public.mdm_domains where company_id=p_company and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.mdm_dashboard(uuid) to authenticated;

create or replace function public.mdm_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_low int; v_dup int; v_cr int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'MDM%' and deleted_at is null;

  select count(*) into v_low from public.mdm_domains where company_id=p_company and quality_score is not null and quality_score < 70 and deleted_at is null;
  if v_low > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'quality_deviation', 'warning', 'MDM: domínios com baixa qualidade de dados', v_low||' domínio(s) com score < 70.', 'Completar campos obrigatórios e padronizar cadastros.', 82);
    v_c := v_c + 1;
  end if;
  select count(*) into v_dup from public.mdm_duplicates where company_id=p_company and status='pending' and deleted_at is null;
  if v_dup > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'waste', 'warning', 'MDM: cadastros duplicados', v_dup||' candidato(s) de duplicidade pendente(s).', 'Revisar e fazer o merge — dados duplicados sujam relatórios e integrações.', 84);
    v_c := v_c + 1;
  end if;
  select count(*) into v_cr from public.mdm_change_requests where company_id=p_company and status='pending' and deleted_at is null and created_at < now() - interval '2 days';
  if v_cr > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'info', 'MDM: solicitações de mudança pendentes', v_cr||' alteração(ões) de cadastro mestre aguardando aprovação.', 'Aprovar/rejeitar para propagar aos módulos.', 74);
    v_c := v_c + 1;
  end if;
  return v_c;
end;
$$;
grant execute on function public.mdm_insights(uuid) to authenticated;

-- ── RLS + triggers + policies + grant por-tabela (recurso 'mdm') ────────────
do $do$
declare t text; specs text[] := array['mdm_domains','mdm_quality_rules','mdm_duplicates','mdm_change_requests','data_lineage','mdm_glossary'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'mdm.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'mdm.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ══ SEED: domínios + linhagem + glossário ══
do $do$
declare c record;
  doms jsonb := '[
    {"k":"products","n":"Produtos / SKU","st":"products","o":"Suprimentos","s":"MDM"},
    {"k":"customers","n":"Clientes","st":"crm_accounts","o":"Comercial","s":"MDM"},
    {"k":"suppliers","n":"Fornecedores","st":"trade_partners","o":"Compras","s":"MDM"},
    {"k":"employees","n":"Colaboradores","st":"employees","o":"RH","s":"MDM"},
    {"k":"accounts_chart","n":"Plano de Contas","st":"chart_of_accounts","o":"Contabilidade","s":"MDM"},
    {"k":"cost_centers","n":"Centros de Custo","st":"cost_centers","o":"Controladoria","s":"MDM"}
  ]'::jsonb;
  lin jsonb := '[
    {"s":"products","t":"Estoque/WMS","d":"SKU alimenta saldos e endereçamento"},
    {"s":"products","t":"Produção/PCP","d":"SKU/BOM alimenta ordens de produção"},
    {"s":"customers","t":"OMS/Financeiro","d":"Cliente alimenta pedidos e recebíveis"},
    {"s":"suppliers","t":"Compras/Comex","d":"Fornecedor alimenta pedidos e importação"},
    {"s":"employees","t":"Folha/Custos","d":"Colaborador alimenta folha e rateio de custo"},
    {"s":"accounts_chart","t":"GL/Fiscal/BI","d":"Plano de contas base de todos os lançamentos"}
  ]'::jsonb;
  gloss jsonb := '[
    {"t":"SKU","d":"Stock Keeping Unit — unidade única de estoque por produto/variação","dm":"products"},
    {"t":"Lead Time","d":"Tempo entre pedido e disponibilidade","dm":"products"},
    {"t":"OTIF","d":"On Time In Full — entregas no prazo e completas","dm":"customers"},
    {"t":"EBITDA","d":"Lucro antes de juros, impostos, depreciação e amortização","dm":"accounts_chart"}
  ]'::jsonb;
  x jsonb;
begin
  for c in select id, tenant_id from public.companies where deleted_at is null loop
    for x in select value from jsonb_array_elements(doms) loop
      if not exists (select 1 from public.mdm_domains where company_id=c.id and domain_key=(x->>'k') and deleted_at is null) then
        insert into public.mdm_domains (tenant_id, company_id, domain_key, name, source_table, data_owner, data_steward)
        values (c.tenant_id, c.id, x->>'k', x->>'n', x->>'st', x->>'o', x->>'s');
      end if;
    end loop;
    for x in select value from jsonb_array_elements(lin) loop
      if not exists (select 1 from public.data_lineage where company_id=c.id and source_domain=(x->>'s') and target_module=(x->>'t') and deleted_at is null) then
        insert into public.data_lineage (tenant_id, company_id, source_domain, target_module, description) values (c.tenant_id, c.id, x->>'s', x->>'t', x->>'d');
      end if;
    end loop;
    for x in select value from jsonb_array_elements(gloss) loop
      if not exists (select 1 from public.mdm_glossary where company_id=c.id and term=(x->>'t') and deleted_at is null) then
        insert into public.mdm_glossary (tenant_id, company_id, term, definition, domain) values (c.tenant_id, c.id, x->>'t', x->>'d', x->>'dm');
      end if;
    end loop;
  end loop;
end $do$;

notify pgrst, 'reload schema';
