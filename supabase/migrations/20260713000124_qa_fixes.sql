-- QA: correções encontradas no teste ao vivo de todos os RPCs
-- 1) funções com temp table não podem ser STABLE -> VOLATILE
alter function public.rel_clientes(uuid,int) volatile;
alter function public.rel_abc(uuid,int) volatile;
alter function public.rel_lucro(uuid,int) volatile;
alter function public.rel_mrp(uuid,int) volatile;

-- 2) rel_ia: enum insight_kind/event_severity precisa cast ::text no coalesce
CREATE OR REPLACE FUNCTION public.rel_ia(p_company uuid, p_days integer DEFAULT 90)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'app'
AS $function$
declare v_desde timestamptz; d int; v_ins int; v_dec int; v_runs int; v_econ numeric;
  s_kind jsonb; s_sev jsonb; s_cat jsonb; s_risk jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,90),1); v_desde := now() - make_interval(days => d);

  select count(*) into v_ins from public.logia_insights where company_id=p_company and deleted_at is null and created_at>=v_desde;
  select count(*), coalesce(sum(estimated_saving),0) into v_dec, v_econ from public.ai_decisions where company_id=p_company and deleted_at is null and created_at>=v_desde;
  select count(*) into v_runs from public.ai_runs where company_id=p_company and deleted_at is null and started_at>=v_desde;

  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(kind::text,'—'),'n',n,'fmt','int') order by n desc),'[]') into s_kind
    from (select kind, count(*) n from public.logia_insights where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc limit 12) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(severity::text,'—'),'n',n,'fmt','int') order by n desc),'[]') into s_sev
    from (select severity, count(*) n from public.logia_insights where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(category,'—'),'n',n,'fmt','int') order by n desc),'[]') into s_cat
    from (select category, count(*) n from public.ai_decisions where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc limit 12) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(risk_level,'—'),'n',n,'fmt','int') order by n desc),'[]') into s_risk
    from (select risk_level, count(*) n from public.ai_decisions where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc) x;

  return jsonb_build_object('titulo','Relatório de Inteligência (IA / LOGIA)','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Insights','valor',v_ins,'fmt','int','icon','✧','tone','accent'),
      jsonb_build_object('label','Decisões','valor',v_dec,'fmt','int','icon','✦','tone','neutral'),
      jsonb_build_object('label','Execuções','valor',v_runs,'fmt','int','icon','⚙️','tone','neutral'),
      jsonb_build_object('label','Economia estimada','valor',v_econ,'fmt','money','icon','💡','tone','success')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Insights por tipo','tipo','bars','itens',s_kind),
      jsonb_build_object('titulo','Insights por severidade','tipo','bars','itens',s_sev),
      jsonb_build_object('titulo','Decisões por categoria','tipo','bars','itens',s_cat),
      jsonb_build_object('titulo','Decisões por risco','tipo','bars','itens',s_risk)));
end $function$

;

-- 3) rel_consolidado: enum insight_status não tem 'resolved' -> new/reviewed
CREATE OR REPLACE FUNCTION public.rel_consolidado(p_company uuid, p_days integer DEFAULT 30)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'app'
AS $function$
declare v_desde timestamptz; d int;
  v_receita numeric; v_ped int; v_ticket numeric;
  v_backlog int; v_semplano int; v_endinv int; v_bloq int; v_semtrack int;
  v_com_pend numeric; v_repasse int; v_wh_pend int; v_nfe_ok int; v_nfe_err int; v_ia int;
  s_serie jsonb; s_canal jsonb; t_atencao jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,30),1); v_desde := now() - make_interval(days => d);

  select coalesce(sum(value) filter (where state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')),0),
         count(*) filter (where state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso'))
    into v_receita, v_ped
  from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde;
  v_ticket := case when v_ped>0 then round(v_receita/v_ped,2) else 0 end;

  select count(*) filter (where state='recebido'), count(*) filter (where state='sem_plano'),
         count(*) filter (where state='endereco_invalido'), count(*) filter (where state='bloqueado_reembolso'),
         count(*) filter (where state in ('pronto_despacho','pre_postado','etiquetado') and tracking_code is null and created_at < now()-interval '2 days')
    into v_backlog, v_semplano, v_endinv, v_bloq, v_semtrack
  from public.store_orders where company_id=p_company and deleted_at is null;

  select coalesce(sum(valor_comissao) filter (where status_repasse='pendente'),0) into v_com_pend
    from public.coproducao_vendas where company_id=p_company and deleted_at is null;
  select count(*) into v_repasse from public.coproducao_repasses where company_id=p_company and deleted_at is null and status in ('aberto','conferido');
  select count(*) into v_wh_pend from public.store_webhook_events where company_id=p_company and deleted_at is null and processed_at is null;
  select count(*) filter (where status ilike '%autoriz%' or status ilike '%emit%'), count(*) filter (where erro is not null)
    into v_nfe_ok, v_nfe_err from public.nfe_emissoes where company_id=p_company and deleted_at is null;
  select count(*) into v_ia from public.logia_insights where company_id=p_company and deleted_at is null and status in ('new','reviewed');

  select coalesce(jsonb_agg(jsonb_build_object('label',to_char(dia,'DD/MM'),'n',n,'valor',r,'fmt','money') order by dia),'[]') into s_serie
    from (select created_at::date dia, count(*) n, coalesce(sum(value),0) r from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde and state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso') group by 1 order by 1) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(platform,'—'),'n',n,'valor',r,'fmt','money') order by r desc),'[]') into s_canal
    from (select platform, count(*) n, coalesce(sum(value),0) r from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde and state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso') group by 1 order by r desc limit 10) x;

  t_atencao := jsonb_build_array(
    jsonb_build_object('item','Pedidos sem plano','quantidade',v_semplano,'onde','Resolver','href','/integracoes-lojas?status=sem_plano'),
    jsonb_build_object('item','Endereços inválidos','quantidade',v_endinv,'onde','Resolver','href','/integracoes-lojas?status=endereco_invalido'),
    jsonb_build_object('item','Bloqueados / reembolso','quantidade',v_bloq,'onde','Ver','href','/integracoes-lojas?status=bloqueado_reembolso'),
    jsonb_build_object('item','Sem rastreio há +2 dias','quantidade',v_semtrack,'onde','Ver','href','/integracoes-lojas'),
    jsonb_build_object('item','Webhooks não processados','quantidade',v_wh_pend,'onde','Ver','href','/webhooks-integracoes'),
    jsonb_build_object('item','Lotes de repasse abertos','quantidade',v_repasse,'onde','Gerar','href','/coproducao'),
    jsonb_build_object('item','NF-e com erro','quantidade',v_nfe_err,'onde','Ver','href','/integracoes-nfe'));

  return jsonb_build_object('titulo','Visão Executiva Consolidada','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Receita','valor',v_receita,'fmt','money','icon','💰','tone','success'),
      jsonb_build_object('label','Pedidos','valor',v_ped,'fmt','int','icon','🧾','tone','accent'),
      jsonb_build_object('label','Ticket médio','valor',v_ticket,'fmt','money','icon','🎯','tone','neutral'),
      jsonb_build_object('label','A processar','valor',v_backlog,'fmt','int','icon','⏳','tone','warning'),
      jsonb_build_object('label','Sem plano','valor',v_semplano,'fmt','int','icon','⚠️','tone','warning'),
      jsonb_build_object('label','Bloqueados','valor',v_bloq,'fmt','int','icon','🚫','tone','danger'),
      jsonb_build_object('label','Comissão a repassar','valor',v_com_pend,'fmt','money','icon','🤝','tone','warning'),
      jsonb_build_object('label','Webhooks pendentes','valor',v_wh_pend,'fmt','int','icon','🔗','tone','warning'),
      jsonb_build_object('label','NF-e emitidas','valor',v_nfe_ok,'fmt','int','icon','📄','tone','success'),
      jsonb_build_object('label','Insights (IA) abertos','valor',v_ia,'fmt','int','icon','✧','tone','neutral')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Receita por dia','tipo','bars','itens',s_serie),
      jsonb_build_object('titulo','Receita por canal','tipo','bars','itens',s_canal),
      jsonb_build_object('titulo','Pontos de atenção','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','item','label','Item','fmt','text'),
                          jsonb_build_object('key','quantidade','label','Qtde','fmt','int'),
                          jsonb_build_object('key','onde','label','Ação','fmt','link','hrefKey','href')),'linhas',t_atencao)));
end $function$

;

-- 4) store_hub_dashboard: chave nula no jsonb_object_agg -> coalesce
CREATE OR REPLACE FUNCTION public.store_hub_dashboard(p_company uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'app'
AS $function$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'connectors', (select count(*) from public.store_connectors where company_id=p_company and deleted_at is null),
    'orders', (select count(*) from public.store_orders where company_id=p_company and deleted_at is null),
    'recebido', (select count(*) from public.store_orders where company_id=p_company and state='recebido' and deleted_at is null),
    'sem_plano', (select count(*) from public.store_orders where company_id=p_company and state='sem_plano' and deleted_at is null),
    'sem_plano_valor', (select coalesce(round(sum(value),2),0) from public.store_orders where company_id=p_company and state='sem_plano' and deleted_at is null),
    'bloqueado_reembolso', (select count(*) from public.store_orders where company_id=p_company and state='bloqueado_reembolso' and deleted_at is null),
    'endereco_invalido', (select count(*) from public.store_orders where company_id=p_company and state='endereco_invalido' and deleted_at is null),
    'postado', (select count(*) from public.store_orders where company_id=p_company and state in ('postado','em_transito','saiu_entrega') and deleted_at is null),
    'entregue', (select count(*) from public.store_orders where company_id=p_company and state='entregue' and deleted_at is null),
    'eventos_hoje', (select count(*) from public.store_webhook_events where company_id=p_company and received_at::date=now()::date and deleted_at is null),
    'eventos_nao_processados', (select count(*) from public.store_webhook_events where company_id=p_company and processed_at is null and deleted_at is null),
    'by_platform', (select coalesce(jsonb_object_agg(coalesce(platform,'—'), n), '{}'::jsonb) from (select platform, count(*) n from public.store_orders where company_id=p_company and deleted_at is null group by platform) x)
  ) into v;
  return v;
end; $function$

;
