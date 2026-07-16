-- ════════════════════════════════════════════════════════════════════════════
-- Sino de notificações v2 — alertas_resumo mais completo e acionável
-- Cada item traz: chave, label, n (quantidade), nivel (erro/alerta/info),
-- href (para onde ir, já com filtro) e hint (o que é / o que fazer).
-- ════════════════════════════════════════════════════════════════════════════
create or replace function public.alertas_resumo(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare
  v_sem_plano int; v_end_inval int; v_bloq int; v_sem_track int;
  v_backlog int; v_track_enviar int; v_wh_pend int; v_com_pend int; v_repasse int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;

  select count(*) filter (where state='sem_plano'),
         count(*) filter (where state='endereco_invalido'),
         count(*) filter (where state='bloqueado_reembolso'),
         count(*) filter (where state in ('pronto_despacho','pre_postado','etiquetado') and tracking_code is null and created_at < now() - interval '2 days'),
         count(*) filter (where state='recebido'),
         count(*) filter (where tracking_code is not null and tracking_pushed_at is null)
    into v_sem_plano, v_end_inval, v_bloq, v_sem_track, v_backlog, v_track_enviar
  from public.store_orders where company_id=p_company and deleted_at is null;

  select count(*) into v_wh_pend from public.store_webhook_events
   where company_id=p_company and processed_at is null and deleted_at is null;

  select count(*) into v_com_pend from public.coproducao_vendas
   where company_id=p_company and deleted_at is null and status_repasse='pendente' and coalesce(valor_comissao,0)>0;

  select count(*) into v_repasse from public.coproducao_repasses
   where company_id=p_company and deleted_at is null and status in ('aberto','conferido');

  return jsonb_build_object(
    'gerado_em', now(),
    'itens', jsonb_build_array(
      jsonb_build_object('chave','sem_plano','label','Pedidos sem plano','n',coalesce(v_sem_plano,0),'nivel','erro','href','/integracoes-lojas?status=sem_plano','hint','Sem plano de envio — não dá pra despachar até resolver'),
      jsonb_build_object('chave','endereco_invalido','label','Endereços inválidos','n',coalesce(v_end_inval,0),'nivel','erro','href','/integracoes-lojas?status=endereco_invalido','hint','CEP/endereço não confere — corrigir antes de postar'),
      jsonb_build_object('chave','bloqueado','label','Bloqueados / reembolso','n',coalesce(v_bloq,0),'nivel','erro','href','/integracoes-lojas?status=bloqueado_reembolso','hint','Bloqueados por reembolso/chargeback'),
      jsonb_build_object('chave','rastreio_a_enviar','label','Rastreios a notificar','n',coalesce(v_track_enviar,0),'nivel','alerta','href','/integracoes-lojas?status=com_rastreio','hint','Têm código dos Correios mas ainda não foram enviados à plataforma'),
      jsonb_build_object('chave','sem_rastreio','label','Sem rastreio há +2 dias','n',coalesce(v_sem_track,0),'nivel','alerta','href','/integracoes-lojas','hint','Prontos para despacho mas sem código de rastreio'),
      jsonb_build_object('chave','webhook_pendente','label','Webhooks não processados','n',coalesce(v_wh_pend,0),'nivel','alerta','href','/webhooks-integracoes','hint','Eventos recebidos das plataformas ainda não processados'),
      jsonb_build_object('chave','backlog','label','Pedidos a processar','n',coalesce(v_backlog,0),'nivel','info','href','/integracoes-lojas?status=recebido','hint','Recebidos aguardando importação/preparo'),
      jsonb_build_object('chave','comissao_pend','label','Comissões a repassar','n',coalesce(v_com_pend,0),'nivel','info','href','/coproducao','hint','Vendas apuradas aguardando gerar repasse'),
      jsonb_build_object('chave','repasse_aberto','label','Lotes de repasse abertos','n',coalesce(v_repasse,0),'nivel','info','href','/coproducao','hint','Repasses gerados ainda não pagos')
    )
  );
end; $$;
grant execute on function public.alertas_resumo(uuid) to authenticated;
