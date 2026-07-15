-- 20260713000044_laios_system_actor.sql
-- O cérebro (app.laios_run) roda em contexto de sistema (pg_cron / service_role),
-- onde não há auth.uid() e os motores de insight rejeitam com 'forbidden'
-- (todos exigem app.can_access_company). Solução: dentro da própria transação,
-- o cérebro ASSUME localmente a identidade de um superadmin (ou de um membro da
-- empresa) via set_config('request.jwt.claims', ...), roda os motores e o
-- contexto é descartado no fim da transação (is_local = true). Governança:
-- é só leitura+geração de insights/decisões — nunca executa ação crítica.

create or replace function app.laios_run(p_company uuid)
returns jsonb
language plpgsql security definer set search_path = public, app as $$
declare
  v_tenant uuid; v_run uuid; v_rec record; v_n int; v_total int := 0; v_engines int := 0;
  v_per jsonb := '[]'::jsonb; v_decisions int := 0; v_actor uuid;
begin
  select tenant_id into v_tenant from public.companies where id = p_company;
  if v_tenant is null then return jsonb_build_object('error','company not found'); end if;

  -- contexto de sistema: assume um superadmin (senão, um membro da empresa)
  select user_id into v_actor from public.profiles where is_superadmin = true limit 1;
  if v_actor is null then
    select user_id into v_actor from public.memberships where company_id = p_company and deleted_at is null limit 1;
  end if;
  if v_actor is not null then
    perform set_config('request.jwt.claims', json_build_object('sub', v_actor::text, 'role', 'authenticated')::text, true);
  end if;

  insert into public.ai_runs (tenant_id, company_id, run_type, agent_key, status)
  values (v_tenant, p_company, 'orchestrate', 'central', 'running') returning id into v_run;

  -- descobre e roda cada motor de insight (1 arg uuid, retorno integer)
  for v_rec in
    select p.proname from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.pronargs = 1 and format_type(p.proargtypes[0], null) = 'uuid'
      and format_type(p.prorettype, null) = 'integer'
      and (p.proname like '%\_insights' or p.proname like 'detect\_%' or p.proname like 'audit\_%'
           or p.proname in ('logia_scan','run_logistics_audit'))
    order by p.proname
  loop
    begin
      execute format('select public.%I($1)', v_rec.proname) into v_n using p_company;
      v_engines := v_engines + 1;
      v_total := v_total + coalesce(v_n, 0);
      v_per := v_per || jsonb_build_object('engine', v_rec.proname, 'insights', coalesce(v_n, 0));
    exception when others then
      v_per := v_per || jsonb_build_object('engine', v_rec.proname, 'error', left(sqlerrm, 140));
    end;
  end loop;

  -- Decision Engine: insights novos (críticos/alerta) -> decisões propostas
  for v_rec in
    select i.id, i.kind::text kind, i.severity::text sev, i.title, i.description, i.recommendation, i.impact_value
    from public.logia_insights i
    where i.company_id = p_company and i.status = 'new' and i.deleted_at is null
      and i.severity in ('critical','warning')
      and not exists (select 1 from public.ai_decisions d where d.reference_insight_id = i.id and d.deleted_at is null)
    order by i.severity desc, coalesce(i.impact_value, 0) desc
    limit 50
  loop
    insert into public.ai_decisions (tenant_id, company_id, agent_key, title, category, motivation, expected_impact,
        risk_level, estimated_saving, status, reference_insight_id, data_used)
    values (v_tenant, p_company, 'central', v_rec.title, v_rec.kind,
        coalesce(v_rec.recommendation, v_rec.description), v_rec.description,
        case when v_rec.sev = 'critical' then 'high' else 'medium' end,
        v_rec.impact_value, 'proposed', v_rec.id,
        jsonb_build_object('insight_kind', v_rec.kind, 'severity', v_rec.sev));
    v_decisions := v_decisions + 1;
  end loop;

  update public.ai_runs set status = 'done', finished_at = now(),
    insights_created = v_total, decisions_created = v_decisions,
    summary = jsonb_build_object('engines_ran', v_engines, 'insights', v_total, 'decisions', v_decisions, 'per_engine', v_per)
  where id = v_run;

  return jsonb_build_object('run_id', v_run, 'engines_ran', v_engines, 'insights', v_total,
    'decisions_proposed', v_decisions, 'per_engine', v_per);
end;
$$;

notify pgrst, 'reload schema';
