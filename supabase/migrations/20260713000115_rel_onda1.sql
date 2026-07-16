-- ════════════════════════════════════════════════════════════════════════════
-- Onda 1 de ferramentas — relatórios analíticos (mesmo contrato dos rel_*)
--   rel_clientes  — LTV & recompra por comprador
--   rel_abc       — curva ABC de produtos
--   rel_regioes   — vendas/entregas por região (UF/cidade)
--   rel_anomalias — detecção de pedidos atípicos/suspeitos
-- ════════════════════════════════════════════════════════════════════════════
-- realizadas = state not in (cancelado/devolvido/extraviado/bloqueado_reembolso)

-- ── LTV & RECOMPRA ──────────────────────────────────────────────────────────
create or replace function public.rel_clientes(p_company uuid, p_days int default 365)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int;
  v_unicos int; v_recorr int; v_taxa numeric; v_ltv numeric; v_ticket numeric; v_receita numeric;
  s_dist jsonb; t_top jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,365),1); v_desde := now() - make_interval(days => d);

  create temp table _cli on commit drop as
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
end $$;
grant execute on function public.rel_clientes(uuid,int) to authenticated;

-- ── CURVA ABC DE PRODUTOS ───────────────────────────────────────────────────
create or replace function public.rel_abc(p_company uuid, p_days int default 90)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int; v_prod int; v_a int; v_b int; v_c int; v_ra numeric;
  s_bars jsonb; t_abc jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,90),1); v_desde := now() - make_interval(days => d);

  create temp table _abc on commit drop as
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
end $$;
grant execute on function public.rel_abc(uuid,int) to authenticated;

-- ── REGIÕES (UF / CIDADE) ───────────────────────────────────────────────────
create or replace function public.rel_regioes(p_company uuid, p_days int default 90)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int; v_uf int; v_cidades int; v_top_uf text; v_ticket numeric;
  s_uf jsonb; s_cidade jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,90),1); v_desde := now() - make_interval(days => d);

  select count(distinct dest_uf), count(distinct dest_city),
         coalesce(round(avg(value) filter (where state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')),2),0)
    into v_uf, v_cidades, v_ticket
  from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde;
  select dest_uf into v_top_uf from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde and dest_uf is not null group by dest_uf order by count(*) desc limit 1;

  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(dest_uf,'??'),'n',n,'valor',r,'fmt','money') order by n desc),'[]') into s_uf
    from (select dest_uf, count(*) n, coalesce(sum(value),0) r from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc limit 27) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(dest_city,'—')||'/'||coalesce(dest_uf,'??'),'n',n,'valor',r,'fmt','money') order by n desc),'[]') into s_cidade
    from (select dest_city, dest_uf, count(*) n, coalesce(sum(value),0) r from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1,2 order by n desc limit 20) x;

  return jsonb_build_object('titulo','Vendas por Região','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Estados atendidos','valor',v_uf,'fmt','int','icon','🗺','tone','accent'),
      jsonb_build_object('label','Cidades','valor',v_cidades,'fmt','int','icon','🏙','tone','neutral'),
      jsonb_build_object('label','UF campeã','valor',coalesce(v_top_uf,'—'),'fmt','text','icon','🏆','tone','success'),
      jsonb_build_object('label','Ticket médio','valor',v_ticket,'fmt','money','icon','🎯','tone','neutral')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Pedidos e receita por UF','tipo','bars','itens',s_uf),
      jsonb_build_object('titulo','Top cidades','tipo','bars','itens',s_cidade)));
end $$;
grant execute on function public.rel_regioes(uuid,int) to authenticated;

-- ── ANOMALIAS / PEDIDOS SUSPEITOS ───────────────────────────────────────────
create or replace function public.rel_anomalias(p_company uuid, p_days int default 30)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int; v_media numeric; v_desvio numeric; v_lim numeric;
  v_atipico int; v_semcpf int; v_semend int; v_multi int; t_atip jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,30),1); v_desde := now() - make_interval(days => d);

  select coalesce(avg(value),0), coalesce(stddev_pop(value),0) into v_media, v_desvio
  from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde and value is not null;
  v_lim := v_media + 3*v_desvio;

  select count(*) filter (where value > v_lim),
         count(*) filter (where buyer_doc is null),
         count(*) filter (where dest_zip is null or dest_city is null)
    into v_atipico, v_semcpf, v_semend
  from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde;

  select count(*) into v_multi from (
    select buyer_doc from public.store_orders
    where company_id=p_company and deleted_at is null and created_at>=now()-interval '7 days' and buyer_doc is not null
    group by buyer_doc having count(*) >= 4) x;

  select coalesce(jsonb_agg(jsonb_build_object('venda',sale_number,'comprador',coalesce(buyer_name,'—'),'produto',coalesce(product_name,'—'),'valor',value) order by value desc),'[]') into t_atip
    from (select sale_number, buyer_name, product_name, value from public.store_orders
          where company_id=p_company and deleted_at is null and created_at>=v_desde and value > v_lim order by value desc limit 30) x;

  return jsonb_build_object('titulo','Detecção de Anomalias','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Valor atípico (>μ+3σ)','valor',v_atipico,'fmt','int','icon','📊','tone','warning'),
      jsonb_build_object('label','Sem CPF','valor',v_semcpf,'fmt','int','icon','🪪','tone','danger'),
      jsonb_build_object('label','Endereço incompleto','valor',v_semend,'fmt','int','icon','📍','tone','warning'),
      jsonb_build_object('label','Mesmo CPF 4+ em 7d','valor',v_multi,'fmt','int','icon','⚠️','tone','danger')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Pedidos de valor atípico','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','venda','label','Venda','fmt','text'),
                          jsonb_build_object('key','comprador','label','Comprador','fmt','text'),
                          jsonb_build_object('key','produto','label','Produto','fmt','text'),
                          jsonb_build_object('key','valor','label','Valor','fmt','money')),'linhas',t_atip)));
end $$;
grant execute on function public.rel_anomalias(uuid,int) to authenticated;
