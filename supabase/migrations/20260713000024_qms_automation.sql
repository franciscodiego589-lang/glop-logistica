-- 20260713000024_qms_automation.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 08 · QMS — AUTOMAÇÃO (fecha 🟡 e 🔴)                               ║
-- ║  • Workflow event-driven: inspeção reprovada → NC → CAPA (trigger).        ║
-- ║  • Auto-avaliação de inspeção pelos resultados (integração LIMS).          ║
-- ║  • Bloqueio de produção por parâmetro crítico (process_readings OOR → NC   ║
-- ║    + alerta na Torre de Controle + flag quality_hold na OP).               ║
-- ║  • CEP/SPC: RPC spc_analysis (média, UCL/LCL, Cp, Cpk).                     ║
-- ║  • IA preditiva de desvios: quality_predict (Cpk<1.33 → insight LOGIA).    ║
-- ║  • Assinatura eletrônica (electronic_signatures + sign_record).            ║
-- ║  • Evidências no Storage (quality_evidences + bucket 'quality').           ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- novo tipo de insight p/ a LOGIA (autocommit por statement na API → seguro)
alter type public.insight_kind add value if not exists 'quality_deviation';

-- ── ELECTRONIC_SIGNATURES (assinatura eletrônica) ───────────────────────────
create table if not exists public.electronic_signatures (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  entity_table text not null, entity_id uuid not null,
  meaning text not null,                            -- approval, review, release, verification
  reason text, signed_by uuid references auth.users(id), signed_at timestamptz not null default now(),
  signature_hash text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_electronic_signatures_entity on public.electronic_signatures (entity_table, entity_id);

-- ── QUALITY_EVIDENCES (fotos/documentos de evidência) ───────────────────────
create table if not exists public.quality_evidences (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  entity_table text not null, entity_id uuid not null,
  kind text, title text, url text, storage_path text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_quality_evidences_entity on public.quality_evidences (entity_table, entity_id);

-- bucket de evidências
insert into storage.buckets (id, name, public) values ('quality','quality', true) on conflict (id) do nothing;
drop policy if exists quality_bucket_read   on storage.objects;
drop policy if exists quality_bucket_insert on storage.objects;
drop policy if exists quality_bucket_delete on storage.objects;
create policy quality_bucket_read   on storage.objects for select to public        using (bucket_id='quality');
create policy quality_bucket_insert on storage.objects for insert to authenticated with check (bucket_id='quality');
create policy quality_bucket_delete on storage.objects for delete to authenticated using (bucket_id='quality');

-- ── RLS/triggers/policies/grant para as 2 tabelas novas ─────────────────────
do $do$
declare t text; specs text[] := array['electronic_signatures','quality_evidences'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'quality.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'quality.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- ── Helper: avalia inspeção pelos resultados (all conform → approved; algum não → rejected) ─
create or replace function app.eval_inspection(p_inspection uuid) returns void
language plpgsql security definer set search_path = public, app as $$
declare v_total int; v_fail int; v_res public.qms_inspection_result;
begin
  select count(*), count(*) filter (where conforms = false)
    into v_total, v_fail
  from public.inspection_results where inspection_id = p_inspection and deleted_at is null;

  if v_total = 0 then v_res := 'pending';
  elsif v_fail > 0 then v_res := 'rejected';
  else v_res := 'approved';
  end if;

  update public.quality_inspections
     set result = v_res, inspected_at = coalesce(inspected_at, now())
   where id = p_inspection and result is distinct from v_res;
end;
$$;

-- gatilho: sempre que um resultado é inserido/alterado/removido, reavalia a inspeção
create or replace function app.tg_result_eval() returns trigger
language plpgsql security definer set search_path = public, app as $$
begin
  perform app.eval_inspection(coalesce(new.inspection_id, old.inspection_id));
  return null;
end;
$$;
drop trigger if exists trg_inspection_results_eval on public.inspection_results;
create trigger trg_inspection_results_eval after insert or update or delete on public.inspection_results
  for each row execute function app.tg_result_eval();

-- RPC pública p/ LIMS/manual: importa resultado e reavalia
create or replace function public.evaluate_inspection(p_inspection uuid) returns public.qms_inspection_result
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_res public.qms_inspection_result;
begin
  select company_id into v_company from public.quality_inspections where id = p_inspection;
  if v_company is null then raise exception 'inspeção não encontrada'; end if;
  if not app.can_access_company(v_company) then raise exception 'forbidden'; end if;
  perform app.eval_inspection(p_inspection);
  select result into v_res from public.quality_inspections where id = p_inspection;
  return v_res;
end;
$$;
grant execute on function public.evaluate_inspection(uuid) to authenticated;

-- ── Workflow: inspeção reprovada → abre NC + gera CAPA ──────────────────────
create or replace function app.tg_inspection_autonc() returns trigger
language plpgsql security definer set search_path = public, app as $$
declare v_nc uuid;
begin
  if new.result = 'rejected' and (tg_op = 'INSERT' or old.result is distinct from new.result) then
    if not exists (select 1 from public.nonconformities where inspection_id = new.id and deleted_at is null) then
      insert into public.nonconformities
        (tenant_id, company_id, branch_id, code, source, nc_type, severity, status, product_id, lot_id, inspection_id, title, description, created_by)
      values
        (new.tenant_id, new.company_id, new.branch_id, 'NC-'||to_char(now(),'YYYYMMDDHH24MISS'),
         'inspection', 'quality', 'major', 'open', new.product_id, new.lot_id, new.id,
         'NC automática — inspeção '||coalesce(new.code, left(new.id::text,8))||' reprovada',
         'Não conformidade aberta automaticamente pela reprovação da inspeção de qualidade.', new.created_by)
      returning id into v_nc;

      insert into public.capas
        (tenant_id, company_id, branch_id, nonconformity_id, code, title, status, created_by)
      values
        (new.tenant_id, new.company_id, new.branch_id, v_nc, 'CAPA-'||to_char(now(),'YYYYMMDDHH24MISS'),
         'CAPA — investigação da inspeção reprovada', 'open', new.created_by);

      -- se houver lote, coloca em quarentena
      if new.lot_id is not null then
        update public.product_lots set quality_status = 'quarantine' where id = new.lot_id and quality_status <> 'blocked';
      end if;
    end if;
  end if;
  return null;
end;
$$;
drop trigger if exists trg_quality_inspections_autonc on public.quality_inspections;
create trigger trg_quality_inspections_autonc after insert or update on public.quality_inspections
  for each row execute function app.tg_inspection_autonc();

-- ── Bloqueio por parâmetro crítico: process_reading fora da faixa → NC + alerta ─
create or replace function app.tg_reading_block() returns trigger
language plpgsql security definer set search_path = public, app as $$
begin
  if new.out_of_range then
    insert into public.nonconformities
      (tenant_id, company_id, branch_id, code, source, nc_type, severity, status, title, description, created_by)
    values
      (new.tenant_id, new.company_id, new.branch_id, 'NC-'||to_char(now(),'YYYYMMDDHH24MISS'),
       'in_process', 'process', 'major', 'open',
       'Parâmetro fora da faixa: '||new.parameter,
       'Leitura de '||new.value||coalesce(' '||new.unit,'')||' fora dos limites ['||coalesce(new.min_limit::text,'-')||', '||coalesce(new.max_limit::text,'-')||'].',
       new.created_by);

    insert into public.alerts
      (tenant_id, company_id, branch_id, domain, severity, status, title, description, reference_type, reference_id)
    values
      (new.tenant_id, new.company_id, new.branch_id, 'quality', 'critical', 'open',
       'Bloqueio de qualidade: '||new.parameter,
       'Parâmetro crítico fora da faixa na produção. Verificar antes de liberar.',
       'process_reading', new.id);

    -- sinaliza retenção na ordem de produção (enum não tem "blocked" → flag em metadata)
    if new.production_order_id is not null then
      update public.production_orders
         set metadata = jsonb_set(coalesce(metadata,'{}'::jsonb), '{quality_hold}', 'true'::jsonb)
       where id = new.production_order_id;
    end if;
  end if;
  return null;
end;
$$;
drop trigger if exists trg_process_readings_block on public.process_readings;
create trigger trg_process_readings_block after insert on public.process_readings
  for each row execute function app.tg_reading_block();

-- ── CEP/SPC: análise de capabilidade (Cp/Cpk) a partir de process_readings ──
create or replace function public.spc_analysis(p_company uuid, p_parameter text, p_days integer default 90)
returns jsonb
language plpgsql stable security definer set search_path = public, app as $$
declare
  v_mean numeric; v_sigma numeric; v_n int; v_usl numeric; v_lsl numeric;
  v_cp numeric; v_cpk numeric; v_points jsonb;
begin
  if not app.can_access_company(p_company) then return '{}'::jsonb; end if;

  select avg(value), stddev_samp(value), count(*), max(max_limit), min(min_limit)
    into v_mean, v_sigma, v_n, v_usl, v_lsl
  from public.process_readings
  where company_id = p_company and parameter = p_parameter and deleted_at is null
    and recorded_at > now() - (p_days || ' days')::interval;

  if coalesce(v_n,0) = 0 then return jsonb_build_object('n',0); end if;

  select jsonb_agg(jsonb_build_object('t', recorded_at, 'v', value) order by recorded_at)
    into v_points
  from public.process_readings
  where company_id = p_company and parameter = p_parameter and deleted_at is null
    and recorded_at > now() - (p_days || ' days')::interval;

  if v_sigma is not null and v_sigma > 0 and v_usl is not null and v_lsl is not null then
    v_cp  := (v_usl - v_lsl) / (6 * v_sigma);
    v_cpk := least(v_usl - v_mean, v_mean - v_lsl) / (3 * v_sigma);
  end if;

  return jsonb_build_object(
    'parameter', p_parameter, 'n', v_n,
    'mean', round(v_mean,4), 'sigma', round(coalesce(v_sigma,0),4),
    'ucl', round(v_mean + 3*coalesce(v_sigma,0),4), 'lcl', round(v_mean - 3*coalesce(v_sigma,0),4),
    'usl', v_usl, 'lsl', v_lsl,
    'cp', round(coalesce(v_cp,0),3), 'cpk', round(coalesce(v_cpk,0),3),
    'points', coalesce(v_points,'[]'::jsonb)
  );
end;
$$;
grant execute on function public.spc_analysis(uuid, text, integer) to authenticated;

-- lista os parâmetros que têm leituras (para o seletor de CEP)
create or replace function public.spc_parameters(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company)
    then coalesce((select jsonb_agg(distinct parameter) from public.process_readings where company_id=p_company and deleted_at is null), '[]'::jsonb)
    else '[]'::jsonb end;
$$;
grant execute on function public.spc_parameters(uuid) to authenticated;

-- ── IA preditiva: Cpk baixo (<1.33) vira insight da LOGIA ───────────────────
create or replace function public.quality_predict(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_p text; v_stat jsonb; v_cpk numeric; v_count int := 0;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id = p_company;

  update public.logia_insights set status='dismissed'
    where company_id=p_company and kind='quality_deviation' and status='new' and deleted_at is null;

  for v_p in select distinct parameter from public.process_readings where company_id=p_company and deleted_at is null loop
    v_stat := public.spc_analysis(p_company, v_p, 90);
    if (v_stat->>'n')::int >= 8 then
      v_cpk := (v_stat->>'cpk')::numeric;
      if v_cpk is not null and v_cpk > 0 and v_cpk < 1.33 then
        insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
        values (v_tenant, p_company, 'quality_deviation',
          case when v_cpk < 1.0 then 'critical' else 'warning' end,
          'Capabilidade baixa: '||v_p||' (Cpk '||v_cpk||')',
          'O processo para "'||v_p||'" tem Cpk '||v_cpk||' (< 1,33), risco de gerar itens fora de especificação.',
          'Reduzir variabilidade / centralizar o processo antes que gere não conformidades.',
          90);
        v_count := v_count + 1;
      end if;
    end if;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.quality_predict(uuid) to authenticated;

-- ── Assinatura eletrônica: registra assinatura e efetiva a ação ─────────────
create or replace function public.sign_record(p_table text, p_id uuid, p_meaning text, p_reason text default null)
returns uuid
language plpgsql security definer set search_path = public, app as $$
declare v_company uuid; v_tenant uuid; v_sig uuid;
begin
  execute format('select company_id, tenant_id from public.%I where id = $1', p_table)
    into v_company, v_tenant using p_id;
  if v_company is null then raise exception 'registro não encontrado em %', p_table; end if;
  if not app.has_permission('quality.approve', v_company) then raise exception 'forbidden'; end if;

  insert into public.electronic_signatures
    (tenant_id, company_id, entity_table, entity_id, meaning, reason, signed_by, signature_hash)
  values
    (v_tenant, v_company, p_table, p_id, p_meaning, p_reason, auth.uid(),
     encode(digest(p_table||p_id::text||coalesce(auth.uid()::text,'')||now()::text, 'sha256'),'hex'))
  returning id into v_sig;

  -- efetiva a ação conforme a entidade assinada
  if p_table = 'quality_documents' and p_meaning = 'approval' then
    update public.quality_documents set status='approved', approved_by=auth.uid(), approved_at=now() where id=p_id;
  elsif p_table = 'capas' and p_meaning = 'verification' then
    update public.capas set effective=true, verified_by=auth.uid(), status='effective' where id=p_id;
  elsif p_table = 'validations' and p_meaning = 'approval' then
    update public.validations set status='approved', approved_by=auth.uid() where id=p_id;
  end if;
  return v_sig;
end;
$$;
grant execute on function public.sign_record(text, uuid, text, text) to authenticated;
