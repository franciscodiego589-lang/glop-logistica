-- ════════════════════════════════════════════════════════════════════════════
-- FASE 2 — hardening pós-revisão adversarial (correções de banco)
--   #1  gerar_repasse: advisory lock por empresa → sem double-count concorrente
--   #7  DRE: receita/pedidos/ticket EXCLUEM cancelado/devolvido/extraviado/bloqueado
--   #8  DRE: comissão amarrada às MESMAS vendas da receita (join store_orders)
--   #10 rastreio: índice funcional upper(tracking_code) → sem seq-scan no portal anon
--   #11 rastreio: estados internos mapeados p/ status público neutro (sem vazar)
-- ════════════════════════════════════════════════════════════════════════════

-- #10 — índice p/ a consulta pública de rastreio (evita seq-scan a cada chamada anon)
create index if not exists idx_store_orders_track_upper
  on public.store_orders (upper(tracking_code)) where deleted_at is null;

-- ── #1 GERAR REPASSE (advisory lock) ────────────────────────────────────────
create or replace function public.coproducao_gerar_repasse(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare
  v_tenant uuid; v_lotes int := 0; v_total numeric := 0;
  c record; v_repasse_id uuid;
  v_ini date; v_fim date; v_qtd int; v_prod numeric; v_frete numeric; v_com numeric;
begin
  if not (app.can_access_company(p_company) and app.has_permission('purchasing.update', p_company)) then
    raise exception 'forbidden';
  end if;
  -- serializa chamadas concorrentes da MESMA empresa (dois cliques/duas abas):
  -- a 2ª espera a 1ª commitar e então já vê as vendas como 'aprovado'/linkadas.
  perform pg_advisory_xact_lock(hashtext('coproducao_gerar_repasse:' || p_company::text));

  select tenant_id into v_tenant from public.companies where id = p_company;

  for c in
    select distinct cv.coprodutor_id
    from public.coproducao_vendas cv
    where cv.company_id = p_company and cv.deleted_at is null
      and cv.status_repasse = 'pendente'
      and cv.coprodutor_id is not null
      and coalesce(cv.valor_comissao, 0) > 0
      and not exists (select 1 from public.coproducao_repasse_itens ri
                      where ri.venda_id = cv.id and ri.deleted_at is null)
  loop
    select min(cv.data_venda)::date, max(cv.data_venda)::date, count(*),
           coalesce(sum(cv.valor_produtos),0), coalesce(sum(cv.valor_frete),0), coalesce(sum(cv.valor_comissao),0)
      into v_ini, v_fim, v_qtd, v_prod, v_frete, v_com
    from public.coproducao_vendas cv
    where cv.company_id = p_company and cv.deleted_at is null
      and cv.status_repasse = 'pendente' and cv.coprodutor_id = c.coprodutor_id
      and coalesce(cv.valor_comissao,0) > 0
      and not exists (select 1 from public.coproducao_repasse_itens ri
                      where ri.venda_id = cv.id and ri.deleted_at is null);

    if v_qtd = 0 then continue; end if;

    insert into public.coproducao_repasses
      (tenant_id, company_id, coprodutor_id, periodo_inicio, periodo_fim, total_vendas,
       total_produtos, total_frete, total_comissao, total_liquido_repassar, status)
    values
      (v_tenant, p_company, c.coprodutor_id, coalesce(v_ini, current_date), coalesce(v_fim, current_date),
       v_qtd, v_prod, v_frete, v_com, v_com, 'aberto')
    returning id into v_repasse_id;

    insert into public.coproducao_repasse_itens (tenant_id, company_id, repasse_id, venda_id, valor_comissao)
    select v_tenant, p_company, v_repasse_id, cv.id, cv.valor_comissao
    from public.coproducao_vendas cv
    where cv.company_id = p_company and cv.deleted_at is null
      and cv.status_repasse = 'pendente' and cv.coprodutor_id = c.coprodutor_id
      and coalesce(cv.valor_comissao,0) > 0
      and not exists (select 1 from public.coproducao_repasse_itens ri
                      where ri.venda_id = cv.id and ri.deleted_at is null);

    update public.coproducao_vendas cv
      set status_repasse = 'aprovado', data_repasse = now()
    where cv.company_id = p_company and cv.deleted_at is null
      and cv.status_repasse = 'pendente' and cv.coprodutor_id = c.coprodutor_id
      and coalesce(cv.valor_comissao,0) > 0
      and exists (select 1 from public.coproducao_repasse_itens ri
                  where ri.venda_id = cv.id and ri.repasse_id = v_repasse_id);

    v_lotes := v_lotes + 1;
    v_total := v_total + v_com;
  end loop;

  return jsonb_build_object('lotes', v_lotes, 'total_repassar', v_total);
end; $$;
grant execute on function public.coproducao_gerar_repasse(uuid) to authenticated;

-- ── #5/#7/#8 DRE consistente ────────────────────────────────────────────────
-- receita/pedidos/ticket excluem estados que não são venda realizada; comissão é
-- somada apenas das vendas que casam com pedidos contados na receita (mesma janela).
create or replace function public.financeiro_dre(p_company uuid, p_days int default 30)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare
  v_receita numeric; v_pedidos int; v_ticket numeric; v_entregues int; v_cancel int;
  v_com numeric; v_emp numeric; v_por_estado jsonb; v_por_uf jsonb; v_por_canal jsonb; v_desde timestamptz;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  v_desde := now() - make_interval(days => greatest(coalesce(p_days,30),1));

  select coalesce(sum(value) filter (where state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')),0),
         count(*) filter (where state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')),
         count(*) filter (where state='entregue'),
         count(*) filter (where state='cancelado')
    into v_receita, v_pedidos, v_entregues, v_cancel
  from public.store_orders
  where company_id = p_company and deleted_at is null and created_at >= v_desde;

  v_ticket := case when v_pedidos > 0 then round(v_receita / v_pedidos, 2) else 0 end;

  -- comissão só das vendas que correspondem a pedidos válidos contados na receita
  select coalesce(sum(cv.valor_comissao),0), coalesce(sum(cv.valor_empresa),0)
    into v_com, v_emp
  from public.coproducao_vendas cv
  join public.store_orders so
    on so.company_id = cv.company_id and so.sale_number = cv.codigo_venda and so.deleted_at is null
  where cv.company_id = p_company and cv.deleted_at is null
    and so.created_at >= v_desde
    and so.state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso');

  select coalesce(jsonb_object_agg(state, n), '{}'::jsonb) into v_por_estado
  from (select state, count(*) n from public.store_orders
        where company_id=p_company and deleted_at is null and created_at>=v_desde group by state) s;

  select coalesce(jsonb_agg(jsonb_build_object('uf', uf, 'pedidos', n, 'receita', r) order by r desc), '[]'::jsonb)
    into v_por_uf
  from (select coalesce(dest_uf,'??') uf, count(*) n,
               coalesce(sum(value) filter (where state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')),0) r
        from public.store_orders
        where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by r desc limit 12) u;

  select coalesce(jsonb_agg(jsonb_build_object('canal', canal, 'pedidos', n, 'receita', r) order by r desc), '[]'::jsonb)
    into v_por_canal
  from (select coalesce(platform,'—') canal, count(*) n,
               coalesce(sum(value) filter (where state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')),0) r
        from public.store_orders
        where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by r desc limit 12) c;

  return jsonb_build_object(
    'dias', greatest(coalesce(p_days,30),1),
    'receita_bruta', v_receita,
    'pedidos', v_pedidos,
    'ticket_medio', v_ticket,
    'entregues', v_entregues,
    'cancelados', v_cancel,
    'comissao_coproducao', v_com,
    'liquido_empresa', v_emp,
    'margem_liquida', case when v_receita>0 then round((v_receita - v_com)/v_receita*100,1) else 0 end,
    'por_estado', v_por_estado,
    'por_uf', v_por_uf,
    'por_canal', v_por_canal
  );
end; $$;
grant execute on function public.financeiro_dre(uuid, int) to authenticated;

-- ── #11 RASTREIO PÚBLICO (estado neutro, sem vazar estados internos) ─────────
create or replace function public.rastreio_publico(p_codigo text)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare o record; v_code text; v_status text;
begin
  v_code := upper(regexp_replace(coalesce(p_codigo,''), '\s', '', 'g'));
  if length(v_code) < 8 then return jsonb_build_object('found', false); end if;

  select so.sale_number, so.state, so.tracking_code, so.dest_city, so.dest_uf,
         so.product_name, so.buyer_name, so.updated_at, so.created_at
    into o
  from public.store_orders so
  where upper(so.tracking_code) = v_code and so.deleted_at is null
  order by so.updated_at desc limit 1;

  if o.tracking_code is null then return jsonb_build_object('found', false); end if;

  -- estados internos → status público neutro (não expõe sem_plano/bloqueio/extravio)
  v_status := case o.state
    when 'postado' then 'postado'
    when 'em_transito' then 'em_transito'
    when 'saiu_entrega' then 'saiu_entrega'
    when 'entregue' then 'entregue'
    when 'cancelado' then 'cancelado'
    when 'devolvido' then 'devolvido'
    else 'processando'   -- recebido/importado/pronto/pre_postado/etiquetado/sem_plano/endereco_invalido/bloqueado/extraviado
  end;

  return jsonb_build_object(
    'found', true,
    'codigo', o.tracking_code,
    'status', v_status,
    'produto', o.product_name,
    'destino', coalesce(o.dest_city,'') || case when o.dest_uf is not null then '/'||o.dest_uf else '' end,
    'cliente', case when o.buyer_name is not null then left(o.buyer_name,1) || '••••' else null end,
    'criado_em', o.created_at,
    'atualizado_em', o.updated_at
  );
end; $$;
grant execute on function public.rastreio_publico(text) to anon, authenticated;
