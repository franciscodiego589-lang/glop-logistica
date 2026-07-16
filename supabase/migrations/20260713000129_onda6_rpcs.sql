-- Onda 6 — RPCs (contrato ReportView): fluxo de caixa, CRM, metas, catálogo.
set search_path = public, app;

-- ── FLUXO DE CAIXA ──────────────────────────────────────────────────────────
create or replace function public.rel_fluxo_caixa(p_company uuid, p_days int default 90)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_receber numeric; v_pagar numeric; v_venc numeric; v_saldo numeric;
  s_pag jsonb; s_rec jsonb; t_prox jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select coalesce(sum(valor) filter (where tipo='receber' and not pago),0),
         coalesce(sum(valor) filter (where tipo='pagar' and not pago),0),
         coalesce(sum(valor) filter (where not pago and vencimento < current_date),0)
    into v_receber, v_pagar, v_venc
  from public.financeiro_contas where company_id=p_company and deleted_at is null;
  v_saldo := v_receber - v_pagar;

  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(categoria,'—'),'n',n,'valor',v,'fmt','money') order by v desc),'[]') into s_pag
    from (select categoria, count(*) n, coalesce(sum(valor),0) v from public.financeiro_contas where company_id=p_company and deleted_at is null and tipo='pagar' and not pago group by 1 order by v desc limit 10) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(categoria,'—'),'n',n,'valor',v,'fmt','money') order by v desc),'[]') into s_rec
    from (select categoria, count(*) n, coalesce(sum(valor),0) v from public.financeiro_contas where company_id=p_company and deleted_at is null and tipo='receber' and not pago group by 1 order by v desc limit 10) x;
  select coalesce(jsonb_agg(jsonb_build_object('descricao',descricao,'tipo',tipo,'vencimento',vencimento,'valor',valor) order by vencimento),'[]') into t_prox
    from (select descricao, tipo, vencimento, valor from public.financeiro_contas where company_id=p_company and deleted_at is null and not pago order by vencimento limit 40) x;

  return jsonb_build_object('titulo','Fluxo de Caixa','periodo','contas em aberto',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','A receber','valor',v_receber,'fmt','money','icon','📥','tone','success'),
      jsonb_build_object('label','A pagar','valor',v_pagar,'fmt','money','icon','📤','tone','warning'),
      jsonb_build_object('label','Vencidas','valor',v_venc,'fmt','money','icon','⚠️','tone','danger'),
      jsonb_build_object('label','Saldo projetado','valor',v_saldo,'fmt','money','icon','🏦','tone',(case when v_saldo>=0 then 'success' else 'danger' end))),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','A pagar por categoria','tipo','bars','itens',s_pag),
      jsonb_build_object('titulo','A receber por categoria','tipo','bars','itens',s_rec),
      jsonb_build_object('titulo','Próximos vencimentos','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','descricao','label','Descrição','fmt','text'),
                          jsonb_build_object('key','tipo','label','Tipo','fmt','text'),
                          jsonb_build_object('key','vencimento','label','Vencimento','fmt','date'),
                          jsonb_build_object('key','valor','label','Valor','fmt','money')),'linhas',t_prox)));
end $$;
grant execute on function public.rel_fluxo_caixa(uuid,int) to authenticated;

-- ── CRM DE COMPRADORES ──────────────────────────────────────────────────────
create or replace function public.rel_crm(p_company uuid, p_days int default 365)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int; v_unicos int; v_recorr int; v_vip int; v_ltv numeric;
  s_seg jsonb; t_top jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,365),1); v_desde := now() - make_interval(days => d);
  drop table if exists _crm;
  create temp table _crm on commit drop as
  select buyer_doc, max(buyer_name) nome, count(*) pedidos, coalesce(sum(value),0) receita, max(created_at) ultimo
  from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde
    and buyer_doc is not null and state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')
  group by buyer_doc;

  select count(*), count(*) filter (where pedidos>1), count(*) filter (where pedidos>=4), coalesce(round(avg(receita),2),0)
    into v_unicos, v_recorr, v_vip, v_ltv from _crm;
  select coalesce(jsonb_agg(jsonb_build_object('label',seg,'n',n,'valor',v,'fmt','money') order by ord),'[]') into s_seg
    from (select case when pedidos>=4 then 'VIP (4+)' when pedidos between 2 and 3 then 'Recorrente (2-3)' else 'Novo (1)' end seg,
                 case when pedidos>=4 then 1 when pedidos between 2 and 3 then 2 else 3 end ord, count(*) n, sum(receita) v from _crm group by 1,2) x;
  select coalesce(jsonb_agg(jsonb_build_object('cliente',coalesce(nome,'—'),'pedidos',pedidos,'ltv',receita,'ultima_compra',ultimo) order by receita desc),'[]') into t_top
    from (select nome, pedidos, receita, ultimo from _crm order by receita desc limit 30) x;

  return jsonb_build_object('titulo','CRM — Compradores','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Compradores','valor',v_unicos,'fmt','int','icon','👥','tone','accent'),
      jsonb_build_object('label','Recorrentes','valor',v_recorr,'fmt','int','icon','🔁','tone','success'),
      jsonb_build_object('label','VIP (4+ compras)','valor',v_vip,'fmt','int','icon','⭐','tone','success'),
      jsonb_build_object('label','LTV médio','valor',v_ltv,'fmt','money','icon','💎','tone','neutral')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Segmentação de clientes','tipo','bars','itens',s_seg),
      jsonb_build_object('titulo','Top clientes (LTV)','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','cliente','label','Cliente','fmt','text'),
                          jsonb_build_object('key','pedidos','label','Compras','fmt','int'),
                          jsonb_build_object('key','ltv','label','LTV','fmt','money'),
                          jsonb_build_object('key','ultima_compra','label','Última compra','fmt','datetime')),'linhas',t_top)));
end $$;
grant execute on function public.rel_crm(uuid,int) to authenticated;

-- ── METAS ───────────────────────────────────────────────────────────────────
create or replace function public.rel_metas(p_company uuid, p_days int default 0)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_total int; v_atingidas int; v_risco int; v_prog numeric; s_bars jsonb; t_det jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  drop table if exists _metas;
  create temp table _metas on commit drop as
  select m.nome, m.tipo, m.valor_meta, m.competencia,
    case m.tipo
      when 'receita' then coalesce((select sum(value) from public.store_orders so where so.company_id=p_company and so.deleted_at is null and date_trunc('month',so.created_at)=date_trunc('month',m.competencia) and so.state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')),0)
      when 'pedidos' then coalesce((select count(*) from public.store_orders so where so.company_id=p_company and so.deleted_at is null and date_trunc('month',so.created_at)=date_trunc('month',m.competencia) and so.state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')),0)
      when 'entregues' then coalesce((select count(*) from public.store_orders so where so.company_id=p_company and so.deleted_at is null and date_trunc('month',so.created_at)=date_trunc('month',m.competencia) and so.state='entregue'),0)
      when 'ticket' then coalesce((select avg(value) from public.store_orders so where so.company_id=p_company and so.deleted_at is null and date_trunc('month',so.created_at)=date_trunc('month',m.competencia) and so.state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')),0)
      when 'comissao' then coalesce((select sum(valor_comissao) from public.coproducao_vendas cv where cv.company_id=p_company and cv.deleted_at is null and date_trunc('month',coalesce(cv.data_venda,cv.created_at))=date_trunc('month',m.competencia)),0)
      else 0 end as realizado
  from public.metas m where m.company_id=p_company and m.deleted_at is null;

  select count(*), count(*) filter (where realizado>=valor_meta and valor_meta>0), count(*) filter (where valor_meta>0 and realizado < valor_meta*0.7),
         coalesce(round(avg(case when valor_meta>0 then least(realizado/valor_meta*100,999) else 0 end),1),0)
    into v_total, v_atingidas, v_risco, v_prog from _metas;
  select coalesce(jsonb_agg(jsonb_build_object('label',nome,'n',round(case when valor_meta>0 then realizado/valor_meta*100 else 0 end),'fmt','pct') order by competencia desc),'[]') into s_bars
    from (select nome, valor_meta, realizado, competencia from _metas order by competencia desc limit 20) x;
  select coalesce(jsonb_agg(jsonb_build_object('meta',nome,'tipo',tipo,'competencia',competencia,'alvo',valor_meta,'realizado',round(realizado,2),'progresso',round(case when valor_meta>0 then realizado/valor_meta*100 else 0 end,1)) order by competencia desc),'[]') into t_det
    from (select nome, tipo, competencia, valor_meta, realizado from _metas order by competencia desc limit 50) x;

  return jsonb_build_object('titulo','Metas & Desempenho','periodo','metas cadastradas',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Metas','valor',v_total,'fmt','int','icon','🎯','tone','accent'),
      jsonb_build_object('label','Atingidas','valor',v_atingidas,'fmt','int','icon','✅','tone','success'),
      jsonb_build_object('label','Em risco (<70%)','valor',v_risco,'fmt','int','icon','⚠️','tone','danger'),
      jsonb_build_object('label','Progresso médio','valor',v_prog,'fmt','pct','icon','📈','tone','neutral')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Progresso por meta (%)','tipo','bars','itens',s_bars),
      jsonb_build_object('titulo','Detalhe das metas','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','meta','label','Meta','fmt','text'),
                          jsonb_build_object('key','tipo','label','Tipo','fmt','text'),
                          jsonb_build_object('key','competencia','label','Mês','fmt','date'),
                          jsonb_build_object('key','alvo','label','Alvo','fmt','money'),
                          jsonb_build_object('key','realizado','label','Realizado','fmt','money'),
                          jsonb_build_object('key','progresso','label','%','fmt','pct')),'linhas',t_det)));
end $$;
grant execute on function public.rel_metas(uuid,int) to authenticated;

-- ── CATÁLOGO ────────────────────────────────────────────────────────────────
create or replace function public.rel_catalogo(p_company uuid, p_days int default 0)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_total int; v_ativos int; v_valor numeric; v_abaixo int; s_cat jsonb; t_baixo jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select count(*), count(*) filter (where ativo), coalesce(sum(estoque_atual*custo),0), count(*) filter (where estoque_atual < estoque_minimo)
    into v_total, v_ativos, v_valor, v_abaixo from public.catalogo_produtos where company_id=p_company and deleted_at is null;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(categoria,'—'),'n',n,'valor',v,'fmt','money') order by n desc),'[]') into s_cat
    from (select categoria, count(*) n, coalesce(sum(estoque_atual*custo),0) v from public.catalogo_produtos where company_id=p_company and deleted_at is null group by 1 order by n desc limit 15) x;
  select coalesce(jsonb_agg(jsonb_build_object('produto',nome,'sku',sku,'estoque',estoque_atual,'minimo',estoque_minimo) order by (estoque_minimo-estoque_atual) desc),'[]') into t_baixo
    from (select nome, sku, estoque_atual, estoque_minimo from public.catalogo_produtos where company_id=p_company and deleted_at is null and estoque_atual < estoque_minimo order by (estoque_minimo-estoque_atual) desc limit 50) x;

  return jsonb_build_object('titulo','Catálogo de Produtos','periodo','estado atual',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Produtos','valor',v_total,'fmt','int','icon','▤','tone','accent'),
      jsonb_build_object('label','Ativos','valor',v_ativos,'fmt','int','icon','✅','tone','success'),
      jsonb_build_object('label','Valor em estoque','valor',v_valor,'fmt','money','icon','💰','tone','neutral'),
      jsonb_build_object('label','Abaixo do mínimo','valor',v_abaixo,'fmt','int','icon','⚠️','tone',(case when v_abaixo>0 then 'danger' else 'success' end))),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Valor de estoque por categoria','tipo','bars','itens',s_cat),
      jsonb_build_object('titulo','Reposição (abaixo do mínimo)','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','produto','label','Produto','fmt','text'),
                          jsonb_build_object('key','sku','label','SKU','fmt','text'),
                          jsonb_build_object('key','estoque','label','Estoque','fmt','int'),
                          jsonb_build_object('key','minimo','label','Mínimo','fmt','int')),'linhas',t_baixo)));
end $$;
grant execute on function public.rel_catalogo(uuid,int) to authenticated;
