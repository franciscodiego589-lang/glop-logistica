-- ════════════════════════════════════════════════════════════════════════════
-- Onda 7 — 5 relatórios novos (auto-descritivos p/ ReportView)
--   rel_recuperacao · rel_impostos · rel_reenvios · rel_chargeback_radar · rel_recompra
-- Todos: SECURITY DEFINER, STABLE (sem temp table), guard app.can_access_company,
-- contrato { titulo, periodo, kpis[], secoes[] }.
-- ════════════════════════════════════════════════════════════════════════════

-- ── 1) Recuperação de Vendas (boleto/Pix/cancelada) ─────────────────────────
create or replace function public.rel_recuperacao(p_company uuid, p_days int default 30)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  return (
    with base as (
      select valor, comprador_nome, comprador_email, comprador_telefone, produto_nome,
             coalesce(data_inicio, created_at) as quando,
             case
               when status ilike '%cancel%' then 'Cancelada'
               when status ilike '%abandon%' then 'Abandonada'
               when status ilike '%aguard%' or status ilike '%pend%' or status ilike '%boleto%'
                 or status ilike '%anali%' or status ilike '%análi%' or status ilike '%process%'
                 or status ilike '%aberto%' then 'Aguardando/Boleto'
               when status ilike '%pix%' then 'Pix pendente'
               else null
             end as motivo
      from public.monetizze_vendas
      where company_id = p_company and deleted_at is null
        and (p_days <= 0 or coalesce(data_inicio, created_at) >= now() - (p_days || ' days')::interval)
    ),
    rec as (select * from base where motivo is not null)
    select jsonb_build_object(
      'titulo', 'Recuperação de Vendas',
      'periodo', 'Últimos ' || p_days || ' dias · pedidos que não viraram venda (boleto/Pix/cancelada)',
      'kpis', jsonb_build_array(
        jsonb_build_object('label','Recuperável em aberto','valor', coalesce((select sum(valor) from rec where motivo <> 'Cancelada'),0),'fmt','money','icon','💰','tone','warning'),
        jsonb_build_object('label','Pedidos parados','valor',(select count(*) from rec),'fmt','int','tone','warning'),
        jsonb_build_object('label','Ticket recuperável','valor', coalesce((select avg(valor) from rec where motivo <> 'Cancelada'),0),'fmt','money'),
        jsonb_build_object('label','Canceladas','valor',(select count(*) from rec where motivo = 'Cancelada'),'fmt','int','tone','danger')
      ),
      'secoes', jsonb_build_array(
        jsonb_build_object('tipo','bars','titulo','Por motivo',
          'itens', coalesce((select jsonb_agg(jsonb_build_object('label',motivo,'n',c,'valor',v,'fmt','money'))
                             from (select motivo, count(*) c, sum(valor) v from rec group by motivo order by c desc) x),'[]'::jsonb)),
        jsonb_build_object('tipo','tabela','titulo','Fila de recuperação',
          'colunas', jsonb_build_array(
            jsonb_build_object('key','comprador','label','Comprador'),
            jsonb_build_object('key','contato','label','Contato'),
            jsonb_build_object('key','produto','label','Produto'),
            jsonb_build_object('key','motivo','label','Motivo'),
            jsonb_build_object('key','valor','label','Valor','fmt','money'),
            jsonb_build_object('key','dias','label','Dias parado','fmt','int')),
          'linhas', coalesce((select jsonb_agg(jsonb_build_object(
              'comprador', comprador_nome, 'contato', coalesce(comprador_email, comprador_telefone),
              'produto', produto_nome, 'motivo', motivo, 'valor', valor,
              'dias', floor(extract(epoch from (now() - quando))/86400)))
            from (select * from rec order by quando desc limit 200) rr),'[]'::jsonb))
      )
    )
  );
end; $$;
grant execute on function public.rel_recuperacao(uuid,int) to authenticated;

-- ── 2) Provisão de Impostos (Simples/DAS — estimativa) ──────────────────────
create or replace function public.rel_impostos(p_company uuid, p_days int default 365)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_aliq numeric := 0.06;  -- alíquota efetiva default (Simples ~6%); ajuste por metadata
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  -- permite sobrescrever a alíquota via companies.metadata->>'aliquota_simples'
  select coalesce((metadata->>'aliquota_simples')::numeric, 0.06) into v_aliq from public.companies where id = p_company;
  return (
    with vendas as (
      select value as v, date_trunc('month', created_at)::date as mes
      from public.store_orders
      where company_id = p_company and deleted_at is null
        and state not in ('cancelado','bloqueado_reembolso','devolvido','sem_plano')
        and (p_days <= 0 or created_at >= now() - (p_days || ' days')::interval)
    ),
    por_mes as (select mes, sum(v) base from vendas group by mes)
    select jsonb_build_object(
      'titulo', 'Provisão de Impostos (Simples Nacional)',
      'periodo', 'Estimativa · alíquota efetiva ' || round(v_aliq*100,2) || '% sobre a receita real (ajustável)',
      'kpis', jsonb_build_array(
        jsonb_build_object('label','Receita-base','valor', coalesce((select sum(base) from por_mes),0),'fmt','money','icon','🧾'),
        jsonb_build_object('label','Alíquota efetiva','valor', round(v_aliq*100,2),'fmt','pct'),
        jsonb_build_object('label','DAS provisionado','valor', coalesce((select sum(base) from por_mes),0)*v_aliq,'fmt','money','tone','warning'),
        jsonb_build_object('label','Mês atual (base)','valor', coalesce((select base from por_mes where mes = date_trunc('month', now())::date),0),'fmt','money')
      ),
      'secoes', jsonb_build_array(
        jsonb_build_object('tipo','bars','titulo','DAS provisionado por mês',
          'itens', coalesce((select jsonb_agg(jsonb_build_object('label', to_char(mes,'MM/YYYY'),'n', round(base*v_aliq)::int,'valor', base*v_aliq,'fmt','money'))
                             from (select * from por_mes order by mes desc limit 12) m),'[]'::jsonb)),
        jsonb_build_object('tipo','tabela','titulo','Apuração mensal',
          'colunas', jsonb_build_array(
            jsonb_build_object('key','competencia','label','Competência'),
            jsonb_build_object('key','base','label','Base (receita)','fmt','money'),
            jsonb_build_object('key','aliquota','label','Alíquota','fmt','pct'),
            jsonb_build_object('key','das','label','DAS a provisionar','fmt','money')),
          'linhas', coalesce((select jsonb_agg(jsonb_build_object(
              'competencia', to_char(mes,'MM/YYYY'), 'base', base, 'aliquota', round(v_aliq*100,2), 'das', base*v_aliq))
            from (select * from por_mes order by mes desc limit 24) m),'[]'::jsonb))
      )
    )
  );
end; $$;
grant execute on function public.rel_impostos(uuid,int) to authenticated;

-- ── 3) Reenvios & Custo de Retrabalho ───────────────────────────────────────
create or replace function public.rel_reenvios(p_company uuid, p_days int default 90)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  return (
    with rv as (
      select r.id, r.motivo, r.status, r.destino_uf, r.comprador_nome, r.produto_nome, r.created_at,
             p.preco_total, p.status as pag_status, p.link_asaas, p.email_enviado, p.comprador_email
      from public.reenvios r
      left join public.reenvio_pagamentos p on p.reenvio_id = r.id and p.deleted_at is null
      where r.company_id = p_company and r.deleted_at is null
        and (p_days <= 0 or r.created_at >= now() - (p_days || ' days')::interval)
    )
    select jsonb_build_object(
      'titulo', 'Reenvios & Custo de Retrabalho',
      'periodo', 'Últimos ' || p_days || ' dias · reenvios, motivos e recuperação via cobrança (Asaas)',
      'kpis', jsonb_build_array(
        jsonb_build_object('label','Reenvios','valor',(select count(*) from rv),'fmt','int','icon','↩️'),
        jsonb_build_object('label','Pendentes','valor',(select count(*) from rv where status is null or status not ilike '%conclu%'),'fmt','int','tone','warning'),
        jsonb_build_object('label','Recuperado do cliente','valor', coalesce((select sum(preco_total) from rv where pag_status ilike '%pag%' or pag_status ilike '%receb%' or pag_status ilike '%conclu%'),0),'fmt','money','tone','success'),
        jsonb_build_object('label','A receber (cobranças)','valor', coalesce((select sum(preco_total) from rv where preco_total is not null and not (pag_status ilike '%pag%' or pag_status ilike '%receb%' or pag_status ilike '%conclu%')),0),'fmt','money','tone','danger')
      ),
      'secoes', jsonb_build_array(
        jsonb_build_object('tipo','bars','titulo','Por motivo',
          'itens', coalesce((select jsonb_agg(jsonb_build_object('label', coalesce(motivo,'—'),'n',c))
                             from (select motivo, count(*) c from rv group by motivo order by c desc limit 12) x),'[]'::jsonb)),
        jsonb_build_object('tipo','bars','titulo','Por UF de destino',
          'itens', coalesce((select jsonb_agg(jsonb_build_object('label', coalesce(destino_uf,'—'),'n',c))
                             from (select destino_uf, count(*) c from rv group by destino_uf order by c desc limit 15) x),'[]'::jsonb)),
        jsonb_build_object('tipo','tabela','titulo','Compradores reincidentes (2+ reenvios)',
          'colunas', jsonb_build_array(
            jsonb_build_object('key','comprador','label','Comprador'),
            jsonb_build_object('key','reenvios','label','Reenvios','fmt','int'),
            jsonb_build_object('key','valor','label','Valor cobrado','fmt','money')),
          'linhas', coalesce((select jsonb_agg(jsonb_build_object('comprador',comprador_nome,'reenvios',c,'valor',v))
            from (select comprador_nome, count(*) c, coalesce(sum(preco_total),0) v from rv group by comprador_nome having count(*) >= 2 order by c desc limit 100) x),'[]'::jsonb)),
        jsonb_build_object('tipo','tabela','titulo','Cobranças pendentes',
          'colunas', jsonb_build_array(
            jsonb_build_object('key','comprador','label','Comprador'),
            jsonb_build_object('key','email','label','E-mail'),
            jsonb_build_object('key','valor','label','Valor','fmt','money'),
            jsonb_build_object('key','enviado','label','E-mail enviado')),
          'linhas', coalesce((select jsonb_agg(jsonb_build_object('comprador',comprador_nome,'email',comprador_email,'valor',preco_total,'enviado', case when email_enviado then 'Sim' else 'Não' end))
            from (select * from rv where preco_total is not null and not (pag_status ilike '%pag%' or pag_status ilike '%receb%' or pag_status ilike '%conclu%') order by created_at desc limit 150) x),'[]'::jsonb))
      )
    )
  );
end; $$;
grant execute on function public.rel_reenvios(uuid,int) to authenticated;

-- ── 4) Radar de Chargeback / Reembolso / Fraude ─────────────────────────────
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
    )
    select jsonb_build_object(
      'titulo', 'Radar de Chargeback & Reembolso',
      'periodo', 'Últimos ' || p_days || ' dias · estornos, disputas e reincidência por CPF',
      'kpis', jsonb_build_array(
        jsonb_build_object('label','Estornos/chargebacks','valor',(select count(*) from ev),'fmt','int','icon','🚨','tone','danger'),
        jsonb_build_object('label','Valor estornado','valor', coalesce((select sum(value) from ev),0),'fmt','money','tone','danger'),
        jsonb_build_object('label','Taxa de estorno','valor', round(100.0 * (select count(*) from ev) / nullif((select n from tot),0), 2),'fmt','pct','tone','warning'),
        jsonb_build_object('label','CPFs reincidentes','valor',(select count(*) from (select buyer_doc from ev where buyer_doc is not null group by buyer_doc having count(*) >= 2) z),'fmt','int','tone','danger')
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
          'linhas', coalesce((select jsonb_agg(jsonb_build_object('doc',buyer_doc,'nome',max(buyer_name),'n',count(*),'valor',coalesce(sum(value),0)))
            from ev where buyer_doc is not null group by buyer_doc having count(*) >= 2),'[]'::jsonb))
      )
    )
  );
end; $$;
grant execute on function public.rel_chargeback_radar(uuid,int) to authenticated;

-- ── 5) Recompra & Reposição prevista (suplemento) ───────────────────────────
create or replace function public.rel_recompra(p_company uuid, p_days int default 365)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  return (
    with ped as (
      select buyer_doc, buyer_name, value, created_at
      from public.store_orders
      where company_id = p_company and deleted_at is null and buyer_doc is not null and buyer_doc <> ''
        and state not in ('cancelado','bloqueado_reembolso','devolvido','sem_plano')
        and (p_days <= 0 or created_at >= now() - (p_days || ' days')::interval)
    ),
    cli as (
      select buyer_doc, max(buyer_name) nome, count(*) pedidos, sum(value) ltv,
             max(created_at) ultima, min(created_at) primeira
      from ped group by buyer_doc
    )
    select jsonb_build_object(
      'titulo', 'Recompra & Reposição prevista',
      'periodo', 'Últimos ' || p_days || ' dias · recorrência de clientes e quem está na hora de reabastecer',
      'kpis', jsonb_build_array(
        jsonb_build_object('label','Clientes únicos','valor',(select count(*) from cli),'fmt','int','icon','👥'),
        jsonb_build_object('label','Recorrentes (2+)','valor',(select count(*) from cli where pedidos >= 2),'fmt','int','tone','success'),
        jsonb_build_object('label','Taxa de recompra','valor', round(100.0 * (select count(*) from cli where pedidos >= 2) / nullif((select count(*) from cli),0),1),'fmt','pct'),
        jsonb_build_object('label','LTV médio','valor', coalesce((select avg(ltv) from cli),0),'fmt','money')
      ),
      'secoes', jsonb_build_array(
        jsonb_build_object('tipo','bars','titulo','Distribuição por nº de compras',
          'itens', jsonb_build_array(
            jsonb_build_object('label','1 compra','n',(select count(*) from cli where pedidos = 1)),
            jsonb_build_object('label','2 compras','n',(select count(*) from cli where pedidos = 2)),
            jsonb_build_object('label','3 ou mais','n',(select count(*) from cli where pedidos >= 3)))),
        jsonb_build_object('tipo','tabela','titulo','Reabastecer agora (última compra há 30–90 dias)',
          'colunas', jsonb_build_array(
            jsonb_build_object('key','nome','label','Cliente'),
            jsonb_build_object('key','doc','label','CPF/CNPJ'),
            jsonb_build_object('key','pedidos','label','Compras','fmt','int'),
            jsonb_build_object('key','dias','label','Dias desde a última','fmt','int'),
            jsonb_build_object('key','ltv','label','LTV','fmt','money')),
          'linhas', coalesce((select jsonb_agg(jsonb_build_object('nome',nome,'doc',buyer_doc,'pedidos',pedidos,
              'dias', floor(extract(epoch from (now()-ultima))/86400), 'ltv', ltv))
            from (select * from cli where ultima < now() - interval '30 days' and ultima >= now() - interval '90 days' order by ultima asc limit 200) c),'[]'::jsonb)),
        jsonb_build_object('tipo','tabela','titulo','Melhores clientes (por LTV)',
          'colunas', jsonb_build_array(
            jsonb_build_object('key','nome','label','Cliente'),
            jsonb_build_object('key','pedidos','label','Compras','fmt','int'),
            jsonb_build_object('key','ltv','label','LTV','fmt','money'),
            jsonb_build_object('key','dias','label','Dias desde a última','fmt','int')),
          'linhas', coalesce((select jsonb_agg(jsonb_build_object('nome',nome,'pedidos',pedidos,'ltv',ltv,
              'dias', floor(extract(epoch from (now()-ultima))/86400)))
            from (select * from cli order by ltv desc limit 100) c),'[]'::jsonb))
      )
    )
  );
end; $$;
grant execute on function public.rel_recompra(uuid,int) to authenticated;
