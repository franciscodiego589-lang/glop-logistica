-- Defensivo: drop table if exists antes de criar a temp (permite 2 chamadas na mesma tx)
CREATE OR REPLACE FUNCTION public.rel_clientes(p_company uuid, p_days integer DEFAULT 365)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'app'
AS $function$
declare v_desde timestamptz; d int;
  v_unicos int; v_recorr int; v_taxa numeric; v_ltv numeric; v_ticket numeric; v_receita numeric;
  s_dist jsonb; t_top jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,365),1); v_desde := now() - make_interval(days => d);

  drop table if exists _cli; create temp table _cli on commit drop as
  select buyer_doc, max(buyer_name) nome, count(*) pedidos, coalesce(sum(value),0) receita
  from public.store_orders
  where company_id=p_company and deleted_at is null and created_at>=v_desde
    and buyer_doc is not null and state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')
  group by buyer_doc;

  select count(*), count(*) filter (where pedidos>1), coalesce(sum(receita),0) into v_unicos, v_recorr, v_receita from _cli;
  v_taxa := case when v_unicos>0 then round(v_recorr::numeric/v_unicos*100,1) else 0 end;
  v_ltv := case when v_unicos>0 then round(v_receita/v_unicos,2) else 0 end;
  select coalesce(round(avg(receita/nullif(pedidos,0)),2),0) into v_ticket from _cli;

  select coalesce(jsonb_agg(jsonb_build_object('label',faixa,'n',n,'fmt','int') order by ord),'[]') into s_dist
    from (select case when pedidos=1 then '1 pedido' when pedidos between 2 and 3 then '2 a 3 pedidos' else '4+ pedidos' end faixa,
                 case when pedidos=1 then 1 when pedidos between 2 and 3 then 2 else 3 end ord, count(*) n
          from _cli group by 1,2) x;
  select coalesce(jsonb_agg(jsonb_build_object('cliente',coalesce(nome,'—'),'pedidos',pedidos,'ltv',receita) order by receita desc),'[]') into t_top
    from (select nome, pedidos, receita from _cli order by receita desc limit 25) x;

  return jsonb_build_object('titulo','Clientes — LTV & Recompra','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Compradores únicos','valor',v_unicos,'fmt','int','icon','👥','tone','accent'),
      jsonb_build_object('label','Recorrentes','valor',v_recorr,'fmt','int','icon','🔁','tone','success'),
      jsonb_build_object('label','Taxa de recompra','valor',v_taxa,'fmt','pct','icon','📈','tone','neutral'),
      jsonb_build_object('label','LTV médio','valor',v_ltv,'fmt','money','icon','💎','tone','success'),
      jsonb_build_object('label','Ticket/comprador','valor',v_ticket,'fmt','money','icon','🎯','tone','neutral')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Distribuição por nº de compras','tipo','bars','itens',s_dist),
      jsonb_build_object('titulo','Top clientes por LTV','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','cliente','label','Cliente','fmt','text'),
                          jsonb_build_object('key','pedidos','label','Pedidos','fmt','int'),
                          jsonb_build_object('key','ltv','label','LTV','fmt','money')),'linhas',t_top)));
end $function$

;
CREATE OR REPLACE FUNCTION public.rel_abc(p_company uuid, p_days integer DEFAULT 90)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'app'
AS $function$
declare v_desde timestamptz; d int; v_prod int; v_a int; v_b int; v_c int; v_ra numeric;
  s_bars jsonb; t_abc jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,90),1); v_desde := now() - make_interval(days => d);

  drop table if exists _abc; create temp table _abc on commit drop as
  with base as (
    select coalesce(product_name,'—') produto, count(*) pedidos, coalesce(sum(value),0) receita
    from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde
      and state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')
    group by 1),
  tot as (select nullif(sum(receita),0) t from base)
  select produto, pedidos, receita,
    round(sum(receita) over (order by receita desc) / (select t from tot) * 100, 1) as acum,
    case when sum(receita) over (order by receita desc) / (select t from tot) <= 0.8 then 'A'
         when sum(receita) over (order by receita desc) / (select t from tot) <= 0.95 then 'B' else 'C' end as classe
  from base;

  select count(*), count(*) filter (where classe='A'), count(*) filter (where classe='B'), count(*) filter (where classe='C'),
         coalesce(sum(receita) filter (where classe='A'),0)
    into v_prod, v_a, v_b, v_c, v_ra from _abc;

  select coalesce(jsonb_agg(jsonb_build_object('label',produto,'n',pedidos,'valor',receita,'fmt','money') order by receita desc),'[]') into s_bars
    from (select produto, pedidos, receita from _abc order by receita desc limit 15) x;
  select coalesce(jsonb_agg(jsonb_build_object('produto',produto,'pedidos',pedidos,'receita',receita,'acum',acum,'classe',classe) order by receita desc),'[]') into t_abc
    from (select produto, pedidos, receita, acum, classe from _abc order by receita desc limit 50) x;

  return jsonb_build_object('titulo','Curva ABC de Produtos','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Produtos','valor',v_prod,'fmt','int','icon','▤','tone','accent'),
      jsonb_build_object('label','Classe A','valor',v_a,'fmt','int','icon','🅰️','tone','success'),
      jsonb_build_object('label','Classe B','valor',v_b,'fmt','int','icon','🅱️','tone','warning'),
      jsonb_build_object('label','Classe C','valor',v_c,'fmt','int','icon','🇨','tone','neutral'),
      jsonb_build_object('label','Receita classe A','valor',v_ra,'fmt','money','icon','💰','tone','success')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Top produtos por receita','tipo','bars','itens',s_bars),
      jsonb_build_object('titulo','Classificação ABC','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','produto','label','Produto','fmt','text'),
                          jsonb_build_object('key','pedidos','label','Pedidos','fmt','int'),
                          jsonb_build_object('key','receita','label','Receita','fmt','money'),
                          jsonb_build_object('key','acum','label','% acum.','fmt','pct'),
                          jsonb_build_object('key','classe','label','Classe','fmt','text')),'linhas',t_abc)));
end $function$

;
CREATE OR REPLACE FUNCTION public.rel_lucro(p_company uuid, p_days integer DEFAULT 30)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'app'
AS $function$
declare v_desde timestamptz; d int;
  v_receita numeric; v_com numeric; v_cmv numeric; v_frete numeric; v_taxa numeric; v_lucro numeric;
  v_desp numeric; v_result numeric; v_ped int; v_margem numeric;
  s_prod jsonb; s_canal jsonb; t_top jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,30),1); v_desde := now() - make_interval(days => d);

  drop table if exists _lucro; create temp table _lucro on commit drop as
  select so.sale_number, coalesce(so.product_name,'—') produto, coalesce(so.platform,'—') canal,
    coalesce(so.value,0) receita,
    coalesce((select sum(cv.valor_comissao) from public.coproducao_vendas cv
              where cv.company_id=p_company and cv.codigo_venda=so.sale_number and cv.deleted_at is null),0) comissao,
    coalesce(c.custo_unitario,0) cmv,
    coalesce(c.frete_medio,0) frete,
    round(coalesce(so.value,0) * coalesce(c.taxa_gateway_pct,0)/100.0, 2) taxa
  from public.store_orders so
  left join lateral (
    select custo_unitario, frete_medio, taxa_gateway_pct
    from public.financeiro_custos_produto fc
    where fc.company_id=p_company and fc.deleted_at is null
      and ((length(trim(coalesce(fc.produto_nome,'')))>0 and so.product_name ilike '%'||fc.produto_nome||'%')
           or (fc.sku is not null and fc.sku = so.sku))
    order by length(coalesce(fc.produto_nome,'')) desc limit 1
  ) c on true
  where so.company_id=p_company and so.deleted_at is null and so.created_at>=v_desde
    and so.state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso');

  select coalesce(sum(receita),0), coalesce(sum(comissao),0), coalesce(sum(cmv),0),
         coalesce(sum(frete),0), coalesce(sum(taxa),0), count(*)
    into v_receita, v_com, v_cmv, v_frete, v_taxa, v_ped from _lucro;
  v_lucro := v_receita - v_com - v_cmv - v_frete - v_taxa;

  select coalesce(sum(valor),0) into v_desp from public.financeiro_despesas
   where company_id=p_company and deleted_at is null and competencia >= v_desde::date;
  v_result := v_lucro - v_desp;
  v_margem := case when v_receita>0 then round(v_lucro/v_receita*100,1) else 0 end;

  select coalesce(jsonb_agg(jsonb_build_object('label',produto,'n',pedidos,'valor',lucro,'fmt','money') order by lucro desc),'[]') into s_prod
    from (select produto, count(*) pedidos, sum(receita-comissao-cmv-frete-taxa) lucro from _lucro group by 1 order by lucro desc limit 15) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',canal,'n',pedidos,'valor',lucro,'fmt','money') order by lucro desc),'[]') into s_canal
    from (select canal, count(*) pedidos, sum(receita-comissao-cmv-frete-taxa) lucro from _lucro group by 1 order by lucro desc limit 10) x;
  select coalesce(jsonb_agg(jsonb_build_object('venda',sale_number,'produto',produto,'receita',receita,'lucro',(receita-comissao-cmv-frete-taxa)) order by (receita-comissao-cmv-frete-taxa) desc),'[]') into t_top
    from (select sale_number, produto, receita, comissao, cmv, frete, taxa from _lucro order by (receita-comissao-cmv-frete-taxa) desc limit 30) x;

  return jsonb_build_object('titulo','Lucro Real por Pedido','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Receita','valor',v_receita,'fmt','money','icon','💰','tone','success'),
      jsonb_build_object('label','(−) Comissões','valor',v_com,'fmt','money','icon','🤝','tone','warning'),
      jsonb_build_object('label','(−) CMV (produto)','valor',v_cmv,'fmt','money','icon','📦','tone','warning'),
      jsonb_build_object('label','(−) Frete','valor',v_frete,'fmt','money','icon','🚚','tone','warning'),
      jsonb_build_object('label','(−) Taxas gateway','valor',v_taxa,'fmt','money','icon','💳','tone','warning'),
      jsonb_build_object('label','= Lucro bruto','valor',v_lucro,'fmt','money','icon','📈','tone','success'),
      jsonb_build_object('label','(−) Despesas','valor',v_desp,'fmt','money','icon','🧾','tone','danger'),
      jsonb_build_object('label','= Resultado','valor',v_result,'fmt','money','icon','🏦','tone',(case when v_result>=0 then 'success' else 'danger' end)),
      jsonb_build_object('label','Margem','valor',v_margem,'fmt','pct','icon','🎯','tone','neutral'),
      jsonb_build_object('label','Pedidos','valor',v_ped,'fmt','int','icon','🧮','tone','accent')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Lucro por produto','tipo','bars','itens',s_prod),
      jsonb_build_object('titulo','Lucro por canal','tipo','bars','itens',s_canal),
      jsonb_build_object('titulo','Pedidos mais lucrativos','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','venda','label','Venda','fmt','text'),
                          jsonb_build_object('key','produto','label','Produto','fmt','text'),
                          jsonb_build_object('key','receita','label','Receita','fmt','money'),
                          jsonb_build_object('key','lucro','label','Lucro','fmt','money')),'linhas',t_top)));
end $function$

;
CREATE OR REPLACE FUNCTION public.rel_mrp(p_company uuid, p_days integer DEFAULT 30)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'app'
AS $function$
declare v_desde timestamptz; d int; v_prod int; v_insumos int; v_custo numeric;
  s_insumo jsonb; t_det jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,30),1); v_desde := now() - make_interval(days => d);

  drop table if exists _mrp; create temp table _mrp on commit drop as
  with vendas as (
    select coalesce(product_name,'—') produto, count(*) qtd
    from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde
      and state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')
    group by 1)
  select fi.insumo, fi.unidade,
    sum(v.qtd * fi.quantidade_por_unidade) as necessario,
    sum(v.qtd * fi.quantidade_por_unidade * fi.custo_unitario) as custo
  from vendas v
  join public.producao_insumos fi on fi.company_id=p_company and fi.deleted_at is null and length(trim(coalesce(fi.produto_nome,'')))>0 and v.produto ilike '%'||fi.produto_nome||'%'
  group by fi.insumo, fi.unidade;

  select count(distinct insumo), coalesce(sum(custo),0) into v_insumos, v_custo from _mrp;
  select count(distinct produto) into v_prod from (select coalesce(product_name,'—') produto from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde and state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso') group by 1) x;

  select coalesce(jsonb_agg(jsonb_build_object('label',insumo||' ('||unidade||')','n',round(necessario,2),'valor',round(custo,2),'fmt','money') order by necessario desc),'[]') into s_insumo
    from (select insumo, unidade, necessario, custo from _mrp order by necessario desc limit 20) x;
  select coalesce(jsonb_agg(jsonb_build_object('insumo',insumo,'unidade',unidade,'necessario',round(necessario,2),'custo',round(custo,2)) order by necessario desc),'[]') into t_det
    from (select insumo, unidade, necessario, custo from _mrp order by necessario desc limit 100) x;

  return jsonb_build_object('titulo','MRP — Necessidade de Insumos','periodo','com base nas vendas dos últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Produtos vendidos','valor',v_prod,'fmt','int','icon','▤','tone','accent'),
      jsonb_build_object('label','Insumos necessários','valor',v_insumos,'fmt','int','icon','🧪','tone','neutral'),
      jsonb_build_object('label','Custo estimado de compra','valor',v_custo,'fmt','money','icon','💰','tone','warning')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Insumos a comprar (por quantidade)','tipo','bars','itens',s_insumo),
      jsonb_build_object('titulo','Necessidade detalhada','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','insumo','label','Insumo','fmt','text'),
                          jsonb_build_object('key','unidade','label','Un','fmt','text'),
                          jsonb_build_object('key','necessario','label','Necessário','fmt','int'),
                          jsonb_build_object('key','custo','label','Custo','fmt','money')),'linhas',t_det)));
end $function$

;
