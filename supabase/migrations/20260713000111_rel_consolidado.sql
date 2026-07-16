-- ════════════════════════════════════════════════════════════════════════════
-- Visão Executiva Consolidada — 1 RPC cross-módulo (usa o mesmo contrato dos rel_*)
-- ════════════════════════════════════════════════════════════════════════════
create or replace function public.rel_consolidado(p_company uuid, p_days int default 30)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
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
  select count(*) into v_ia from public.logia_insights where company_id=p_company and deleted_at is null and status <> 'resolved';

  select coalesce(jsonb_agg(jsonb_build_object('label',to_char(dia,'DD/MM'),'n',n,'valor',r,'fmt','money') order by dia),'[]') into s_serie
    from (select created_at::date dia, count(*) n, coalesce(sum(value),0) r from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by 1) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(platform,'—'),'n',n,'valor',r,'fmt','money') order by r desc),'[]') into s_canal
    from (select platform, count(*) n, coalesce(sum(value),0) r from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by r desc limit 10) x;

  t_atencao := jsonb_build_array(
    jsonb_build_object('item','Pedidos sem plano','quantidade',v_semplano,'onde','Puxar Pedidos'),
    jsonb_build_object('item','Endereços inválidos','quantidade',v_endinv,'onde','Puxar Pedidos'),
    jsonb_build_object('item','Bloqueados / reembolso','quantidade',v_bloq,'onde','Puxar Pedidos'),
    jsonb_build_object('item','Sem rastreio há +2 dias','quantidade',v_semtrack,'onde','Puxar Pedidos'),
    jsonb_build_object('item','Webhooks não processados','quantidade',v_wh_pend,'onde','Webhooks & Integrações'),
    jsonb_build_object('item','Lotes de repasse abertos','quantidade',v_repasse,'onde','Coprodução'),
    jsonb_build_object('item','NF-e com erro','quantidade',v_nfe_err,'onde','Integrações & NF-e'));

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
                          jsonb_build_object('key','onde','label','Onde resolver','fmt','text')),'linhas',t_atencao)));
end $$;
grant execute on function public.rel_consolidado(uuid,int) to authenticated;
