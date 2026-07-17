-- Fix: rel_chargeback_radar tinha aggregate aninhado (jsonb_agg sobre max/count/sum).
-- Agrega por CPF numa subquery e só então monta o jsonb.
create or replace function public.rel_chargeback_radar(p_company uuid, p_days int default 90)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  return (
    with ev as (
      select w.event_type, w.platform, w.sale_number, w.received_at,
             o.value, o.dest_uf, o.buyer_doc, o.buyer_name
      from public.store_webhook_events w
      left join public.store_orders o on o.company_id = w.company_id and o.sale_number = w.sale_number and o.deleted_at is null
      where w.company_id = p_company and w.deleted_at is null
        and w.event_type in ('refund','chargeback','dispute')
        and (p_days <= 0 or w.received_at >= now() - (p_days || ' days')::interval)
    ),
    tot as (
      select count(*) n from public.store_webhook_events
      where company_id = p_company and deleted_at is null
        and (p_days <= 0 or received_at >= now() - (p_days || ' days')::interval)
    ),
    reinc as (
      select buyer_doc as doc, max(buyer_name) as nome, count(*) as n, coalesce(sum(value),0) as valor
      from ev where buyer_doc is not null group by buyer_doc having count(*) >= 2
    )
    select jsonb_build_object(
      'titulo', 'Radar de Chargeback & Reembolso',
      'periodo', 'Últimos ' || p_days || ' dias · estornos, disputas e reincidência por CPF',
      'kpis', jsonb_build_array(
        jsonb_build_object('label','Estornos/chargebacks','valor',(select count(*) from ev),'fmt','int','icon','🚨','tone','danger'),
        jsonb_build_object('label','Valor estornado','valor', coalesce((select sum(value) from ev),0),'fmt','money','tone','danger'),
        jsonb_build_object('label','Taxa de estorno','valor', round(100.0 * (select count(*) from ev) / nullif((select n from tot),0), 2),'fmt','pct','tone','warning'),
        jsonb_build_object('label','CPFs reincidentes','valor',(select count(*) from reinc),'fmt','int','tone','danger')
      ),
      'secoes', jsonb_build_array(
        jsonb_build_object('tipo','bars','titulo','Por plataforma',
          'itens', coalesce((select jsonb_agg(jsonb_build_object('label', coalesce(platform,'—'),'n',c,'valor',v,'fmt','money'))
                             from (select platform, count(*) c, coalesce(sum(value),0) v from ev group by platform order by c desc) x),'[]'::jsonb)),
        jsonb_build_object('tipo','bars','titulo','Por UF',
          'itens', coalesce((select jsonb_agg(jsonb_build_object('label', coalesce(dest_uf,'—'),'n',c))
                             from (select dest_uf, count(*) c from ev group by dest_uf order by c desc limit 15) x),'[]'::jsonb)),
        jsonb_build_object('tipo','tabela','titulo','CPFs reincidentes (2+ estornos)',
          'colunas', jsonb_build_array(
            jsonb_build_object('key','doc','label','CPF/CNPJ'),
            jsonb_build_object('key','nome','label','Comprador'),
            jsonb_build_object('key','n','label','Estornos','fmt','int'),
            jsonb_build_object('key','valor','label','Valor','fmt','money')),
          'linhas', coalesce((select jsonb_agg(jsonb_build_object('doc',doc,'nome',nome,'n',n,'valor',valor))
            from (select * from reinc order by n desc limit 100) z),'[]'::jsonb))
      )
    )
  );
end; $$;
grant execute on function public.rel_chargeback_radar(uuid,int) to authenticated;
