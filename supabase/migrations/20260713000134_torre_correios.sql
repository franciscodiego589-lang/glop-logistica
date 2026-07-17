-- ════════════════════════════════════════════════════════════════════════════
-- Torre de Controle Correios — dashboard executivo (KPIs REAIS)
-- Amarra a máquina de estados de store_orders + reenvios + prepostagens num só
-- painel. Contrato auto-descritivo (ReportView + PDF enterprise). Honesto: só o
-- que é computável dos dados reais (o resto do "Prompt Master" é roadmap).
-- ════════════════════════════════════════════════════════════════════════════
create or replace function public.rel_torre_correios(p_company uuid, p_days int default 90)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_prepost int := 0; v_reenvio int := 0;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select count(*) into v_prepost from public.prepostagens where company_id = p_company and deleted_at is null
    and (p_days <= 0 or created_at >= now() - (p_days || ' days')::interval);
  select count(*) into v_reenvio from public.reenvios where company_id = p_company and deleted_at is null
    and (status is null or status not ilike '%conclu%');
  return (
    with o as (
      select state, tracking_code, dest_zip, dest_uf, sale_number, buyer_name, updated_at, created_at
      from public.store_orders
      where company_id = p_company and deleted_at is null
        and (p_days <= 0 or created_at >= now() - (p_days || ' days')::interval)
    ),
    c as (select
      count(*) filter (where state in ('recebido','importado','pronto_despacho','pre_postado') and coalesce(tracking_code,'')='') as aguard_etiqueta,
      count(*) filter (where state = 'etiquetado' or (coalesce(tracking_code,'')<>'' and state in ('pronto_despacho','pre_postado'))) as etiquetados,
      count(*) filter (where state = 'postado') as postados,
      count(*) filter (where state in ('em_transito','saiu_entrega')) as em_transito,
      count(*) filter (where state = 'entregue') as entregues,
      count(*) filter (where state = 'devolvido') as devolvidos,
      count(*) filter (where state = 'extraviado') as extraviados,
      count(*) filter (where state = 'sem_plano') as sem_plano,
      count(*) filter (where state = 'endereco_invalido' or coalesce(dest_zip,'')='') as sem_cep,
      count(*) filter (where state = 'bloqueado_reembolso') as bloqueados,
      count(*) filter (where state = 'cancelado') as cancelados,
      count(*) filter (where state in ('postado','em_transito','saiu_entrega') and coalesce(tracking_code,'')='') as sem_rastreio,
      count(*) filter (where state in ('em_transito','saiu_entrega') and updated_at < now() - interval '15 days') as sla_vencido,
      count(*) as total
      from o)
    select jsonb_build_object(
      'titulo', 'Torre de Controle — Correios',
      'periodo', 'Últimos ' || p_days || ' dias · ciclo operacional do pedido (Correios) em tempo quase-real',
      'kpis', jsonb_build_array(
        jsonb_build_object('label','Aguardando etiqueta','valor',(select aguard_etiqueta from c),'fmt','int','icon','🏷️','tone','warning'),
        jsonb_build_object('label','Etiquetados','valor',(select etiquetados from c),'fmt','int','icon','✅'),
        jsonb_build_object('label','Postados','valor',(select postados from c),'fmt','int','icon','📮'),
        jsonb_build_object('label','Em trânsito','valor',(select em_transito from c),'fmt','int','icon','🚚'),
        jsonb_build_object('label','Entregues','valor',(select entregues from c),'fmt','int','icon','📦','tone','success'),
        jsonb_build_object('label','SLA vencido (15d+)','valor',(select sla_vencido from c),'fmt','int','tone','danger'),
        jsonb_build_object('label','Devolvidos/Extraviados','valor',(select devolvidos + extraviados from c),'fmt','int','tone','danger'),
        jsonb_build_object('label','Sem rastreio','valor',(select sem_rastreio from c),'fmt','int','tone','warning'),
        jsonb_build_object('label','Sem CEP válido','valor',(select sem_cep from c),'fmt','int','tone','warning'),
        jsonb_build_object('label','Bloqueados','valor',(select bloqueados from c),'fmt','int','tone','danger'),
        jsonb_build_object('label','Prepostagens geradas','valor', v_prepost,'fmt','int','icon','🧾'),
        jsonb_build_object('label','Aguardando reenvio','valor', v_reenvio,'fmt','int','tone','warning')
      ),
      'secoes', jsonb_build_array(
        jsonb_build_object('tipo','bars','titulo','Funil operacional (pedidos por etapa)',
          'itens', jsonb_build_array(
            jsonb_build_object('label','Aguardando etiqueta','n',(select aguard_etiqueta from c)),
            jsonb_build_object('label','Etiquetados','n',(select etiquetados from c)),
            jsonb_build_object('label','Postados','n',(select postados from c)),
            jsonb_build_object('label','Em trânsito','n',(select em_transito from c)),
            jsonb_build_object('label','Entregues','n',(select entregues from c)))),
        jsonb_build_object('tipo','bars','titulo','Exceções (precisam de ação)',
          'itens', jsonb_build_array(
            jsonb_build_object('label','Sem plano de preço','n',(select sem_plano from c)),
            jsonb_build_object('label','Sem CEP válido','n',(select sem_cep from c)),
            jsonb_build_object('label','Bloqueados (reembolso)','n',(select bloqueados from c)),
            jsonb_build_object('label','Cancelados','n',(select cancelados from c)),
            jsonb_build_object('label','Devolvidos','n',(select devolvidos from c)),
            jsonb_build_object('label','Extraviados','n',(select extraviados from c)))),
        jsonb_build_object('tipo','bars','titulo','Em trânsito por UF',
          'itens', coalesce((select jsonb_agg(jsonb_build_object('label',coalesce(dest_uf,'—'),'n',c2))
                             from (select dest_uf, count(*) c2 from o where state in ('em_transito','saiu_entrega') group by dest_uf order by c2 desc limit 15) x),'[]'::jsonb)),
        jsonb_build_object('tipo','tabela','titulo','Pedidos críticos (em trânsito há 15+ dias — risco de extravio)',
          'colunas', jsonb_build_array(
            jsonb_build_object('key','venda','label','Venda'),
            jsonb_build_object('key','comprador','label','Comprador'),
            jsonb_build_object('key','uf','label','UF'),
            jsonb_build_object('key','rastreio','label','Rastreio'),
            jsonb_build_object('key','dias','label','Dias em trânsito','fmt','int')),
          'linhas', coalesce((select jsonb_agg(jsonb_build_object('venda',sale_number,'comprador',buyer_name,'uf',dest_uf,'rastreio',tracking_code,
              'dias', floor(extract(epoch from (now()-updated_at))/86400)))
            from (select * from o where state in ('em_transito','saiu_entrega') and updated_at < now() - interval '15 days' order by updated_at asc limit 200) z),'[]'::jsonb))
      )
    )
  );
end; $$;
grant execute on function public.rel_torre_correios(uuid,int) to authenticated;
