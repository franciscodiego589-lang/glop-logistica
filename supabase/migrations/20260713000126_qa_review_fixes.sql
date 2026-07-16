-- QA review: correções de lógica (19 achados)
-- #3 transition trail
create or replace function public.transition_store_order(p_company uuid, p_order uuid, p_to_state text, p_reason text default null)
returns store_orders language plpgsql security definer set search_path to 'public','app' as $function$
declare v_tenant uuid; o public.store_orders; v_old text;
begin
  if not (app.can_access_company(p_company) and app.has_permission('integration.update', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  select * into o from public.store_orders where id=p_order and company_id=p_company;
  if o.id is null then raise exception 'Pedido não encontrado'; end if;
  v_old := o.state;
  if o.state='bloqueado_reembolso' and p_to_state in ('pre_postado','etiquetado','postado') then
    raise exception 'Bloqueado por reembolso — não pode despachar';
  end if;
  update public.store_orders set state=p_to_state where id=p_order returning * into o;
  perform app.store_log_transition(v_tenant, p_company, p_order, v_old, p_to_state, 'usuario', p_reason);
  return o;
end; $function$;

-- #2 rel_fiscal ilike
CREATE OR REPLACE FUNCTION public.rel_fiscal(p_company uuid, p_days integer DEFAULT 90)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'app'
AS $function$
declare v_desde timestamptz; d int; v_total int; v_emit int; v_erro int; v_valor numeric;
  s_status jsonb; s_serie jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,90),1); v_desde := now() - make_interval(days => d);

  select count(*), count(*) filter (where status ilike '%autoriz%' or status ilike '%emit%'), count(*) filter (where erro is not null), coalesce(sum(valor),0)
    into v_total, v_emit, v_erro, v_valor
  from public.nfe_emissoes where company_id=p_company and deleted_at is null;

  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(status,'—'),'n',n,'valor',v,'fmt','money') order by n desc),'[]') into s_status
    from (select status, count(*) n, coalesce(sum(valor),0) v from public.nfe_emissoes where company_id=p_company and deleted_at is null group by 1 order by n desc) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',to_char(dia,'DD/MM'),'n',n,'fmt','int') order by dia),'[]') into s_serie
    from (select coalesce(emitida_at,created_at)::date dia, count(*) n from public.nfe_emissoes where company_id=p_company and deleted_at is null group by 1 order by 1) x;

  return jsonb_build_object('titulo','Relatório Fiscal & NF-e','periodo','todo o período',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','NF-e (total)','valor',v_total,'fmt','int','icon','🧾','tone','accent'),
      jsonb_build_object('label','Emitidas','valor',v_emit,'fmt','int','icon','✅','tone','success'),
      jsonb_build_object('label','Com erro','valor',v_erro,'fmt','int','icon','⚠️','tone','danger'),
      jsonb_build_object('label','Valor total','valor',v_valor,'fmt','money','icon','💰','tone','neutral')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','NF-e por status','tipo','bars','itens',s_status),
      jsonb_build_object('titulo','Emissões por dia','tipo','bars','itens',s_serie)));
end $function$

;
-- #13 rel_regioes receita
CREATE OR REPLACE FUNCTION public.rel_regioes(p_company uuid, p_days integer DEFAULT 90)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'app'
AS $function$
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
    from (select dest_uf, count(*) n, coalesce(sum(value) filter (where state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')),0) r from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc limit 27) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(dest_city,'—')||'/'||coalesce(dest_uf,'??'),'n',n,'valor',r,'fmt','money') order by n desc),'[]') into s_cidade
    from (select dest_city, dest_uf, count(*) n, coalesce(sum(value) filter (where state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')),0) r from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1,2 order by n desc limit 20) x;

  return jsonb_build_object('titulo','Vendas por Região','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Estados atendidos','valor',v_uf,'fmt','int','icon','🗺','tone','accent'),
      jsonb_build_object('label','Cidades','valor',v_cidades,'fmt','int','icon','🏙','tone','neutral'),
      jsonb_build_object('label','UF campeã','valor',coalesce(v_top_uf,'—'),'fmt','text','icon','🏆','tone','success'),
      jsonb_build_object('label','Ticket médio','valor',v_ticket,'fmt','money','icon','🎯','tone','neutral')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Pedidos e receita por UF','tipo','bars','itens',s_uf),
      jsonb_build_object('titulo','Top cidades','tipo','bars','itens',s_cidade)));
end $function$

;
-- #11/#12/#19 rel_mrp
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

  create temp table _mrp on commit drop as
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
-- #19 rel_lucro
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

  create temp table _lucro on commit drop as
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
-- #7/#8 LGPD RPC
create or replace function public.lgpd_export_titular(p_company uuid, p_doc text default null, p_email text default null)
returns jsonb language plpgsql security definer set search_path=public,app stable as $$
declare v_doc text := regexp_replace(coalesce(p_doc,''),'\D','','g'); v_email text := lower(trim(coalesce(p_email,''))); ped jsonb; t record;
begin
  if not (app.can_access_company(p_company) and (app.is_superadmin() or app.has_permission('admin.read', p_company))) then raise exception 'forbidden'; end if;
  if v_doc='' and v_email='' then return jsonb_build_object('error','Informe o CPF/CNPJ ou o e-mail do titular.'); end if;
  select coalesce(jsonb_agg(to_jsonb(o) order by o.created_at desc),'[]') into ped from (
    select sale_number, platform, buyer_name, buyer_doc, buyer_email, buyer_phone, dest_zip, dest_street, dest_number, dest_district, dest_city, dest_uf, product_name, value, state, tracking_code, created_at
    from public.store_orders where company_id=p_company and deleted_at is null
      and ((v_doc<>'' and regexp_replace(coalesce(buyer_doc,''),'\D','','g')=v_doc) or (v_email<>'' and lower(coalesce(buyer_email,''))=v_email))
    order by created_at desc limit 5000) o;
  select buyer_name nome, buyer_doc documento, buyer_email email, buyer_phone telefone into t
    from public.store_orders where company_id=p_company and deleted_at is null
      and ((v_doc<>'' and regexp_replace(coalesce(buyer_doc,''),'\D','','g')=v_doc) or (v_email<>'' and lower(coalesce(buyer_email,''))=v_email))
    order by created_at desc limit 1;
  return jsonb_build_object('lgpd','Dados do titular (LGPD art. 18) — GLOP','gerado_em', now(),
    'titular', jsonb_build_object('nome',t.nome,'documento',coalesce(t.documento,p_doc),'email',coalesce(t.email,p_email),'telefone',t.telefone),
    'total_pedidos', jsonb_array_length(ped), 'pedidos', ped);
end $$;
grant execute on function public.lgpd_export_titular(uuid,text,text) to authenticated;
