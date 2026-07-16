-- ════════════════════════════════════════════════════════════════════════════
-- FASE 2 — as 6 features (RPCs de back-end)
--   #1 coproducao_gerar_repasse  → fecha comissões pendentes em lotes de repasse
--   #6 rastreio_publico          → consulta pública de rastreio por código (portal)
--   #5 financeiro_dre            → DRE/financeiro com dados reais (via RPC, sem somar em JS)
--   #3 alertas_resumo            → contadores pro sino de notificações
-- ════════════════════════════════════════════════════════════════════════════

-- ── #1 GERAR REPASSE ────────────────────────────────────────────────────────
-- Junta todas as coproducao_vendas 'pendente' (com comissão > 0) de cada
-- coprodutor num lote de repasse (coproducao_repasses) + itens, e marca as
-- vendas como 'aprovado'. Idempotente: só pega vendas ainda não linkadas.
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

-- ── #6 RASTREIO PÚBLICO ─────────────────────────────────────────────────────
-- Portal público: quem tem o código de rastreio vê status limitado (sem PII).
-- security definer → ignora RLS, mas só expõe campos não sensíveis por código.
create or replace function public.rastreio_publico(p_codigo text)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare o record; v_code text;
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

  return jsonb_build_object(
    'found', true,
    'codigo', o.tracking_code,
    'status', o.state,
    'produto', o.product_name,
    'destino', coalesce(o.dest_city,'') || case when o.dest_uf is not null then '/'||o.dest_uf else '' end,
    'cliente', case when o.buyer_name is not null then left(o.buyer_name,1) || '••••' else null end,
    'criado_em', o.created_at,
    'atualizado_em', o.updated_at
  );
end; $$;
grant execute on function public.rastreio_publico(text) to anon, authenticated;

-- ── #5 DRE / FINANCEIRO ─────────────────────────────────────────────────────
-- Números reais agregados no banco (nunca somar em JS). Janela de p_days dias.
create or replace function public.financeiro_dre(p_company uuid, p_days int default 30)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare
  v_receita numeric; v_pedidos int; v_ticket numeric; v_entregues int; v_cancel int;
  v_com numeric; v_emp numeric; v_por_estado jsonb; v_por_uf jsonb; v_por_canal jsonb; v_desde timestamptz;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  v_desde := now() - make_interval(days => greatest(coalesce(p_days,30),1));

  select coalesce(sum(value),0), count(*),
         count(*) filter (where state='entregue'),
         count(*) filter (where state='cancelado')
    into v_receita, v_pedidos, v_entregues, v_cancel
  from public.store_orders
  where company_id = p_company and deleted_at is null and created_at >= v_desde;

  v_ticket := case when v_pedidos > 0 then round(v_receita / v_pedidos, 2) else 0 end;

  select coalesce(sum(valor_comissao),0), coalesce(sum(valor_empresa),0)
    into v_com, v_emp
  from public.coproducao_vendas
  where company_id = p_company and deleted_at is null and coalesce(data_venda, created_at) >= v_desde;

  select coalesce(jsonb_object_agg(state, n), '{}'::jsonb) into v_por_estado
  from (select state, count(*) n from public.store_orders
        where company_id=p_company and deleted_at is null and created_at>=v_desde group by state) s;

  select coalesce(jsonb_agg(jsonb_build_object('uf', uf, 'pedidos', n, 'receita', r) order by r desc), '[]'::jsonb)
    into v_por_uf
  from (select coalesce(dest_uf,'??') uf, count(*) n, coalesce(sum(value),0) r from public.store_orders
        where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by r desc limit 12) u;

  select coalesce(jsonb_agg(jsonb_build_object('canal', canal, 'pedidos', n, 'receita', r) order by r desc), '[]'::jsonb)
    into v_por_canal
  from (select coalesce(platform,'—') canal, count(*) n, coalesce(sum(value),0) r from public.store_orders
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

-- ── #3 ALERTAS / SINO ───────────────────────────────────────────────────────
-- Contadores de coisas que precisam de atenção → alimenta o sino de notificações.
create or replace function public.alertas_resumo(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare
  v_sem_plano int; v_end_inval int; v_bloq int; v_sem_track int; v_repasse_pend int; v_com_pend int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;

  select count(*) filter (where state='sem_plano'),
         count(*) filter (where state='endereco_invalido'),
         count(*) filter (where state='bloqueado_reembolso'),
         count(*) filter (where state in ('pronto_despacho','pre_postado','etiquetado') and tracking_code is null and created_at < now() - interval '2 days')
    into v_sem_plano, v_end_inval, v_bloq, v_sem_track
  from public.store_orders where company_id=p_company and deleted_at is null;

  select count(*) into v_com_pend from public.coproducao_vendas
   where company_id=p_company and deleted_at is null and status_repasse='pendente' and coalesce(valor_comissao,0)>0;

  select count(*) into v_repasse_pend from public.coproducao_repasses
   where company_id=p_company and deleted_at is null and status in ('aberto','conferido');

  return jsonb_build_object(
    'total', coalesce(v_sem_plano,0)+coalesce(v_end_inval,0)+coalesce(v_bloq,0)+coalesce(v_sem_track,0),
    'itens', jsonb_build_array(
      jsonb_build_object('chave','sem_plano','label','Pedidos sem plano','n',coalesce(v_sem_plano,0),'nivel','alerta','href','/integracoes-lojas'),
      jsonb_build_object('chave','endereco_invalido','label','Endereços inválidos','n',coalesce(v_end_inval,0),'nivel','erro','href','/integracoes-lojas'),
      jsonb_build_object('chave','bloqueado','label','Bloqueados/reembolso','n',coalesce(v_bloq,0),'nivel','erro','href','/integracoes-lojas'),
      jsonb_build_object('chave','sem_rastreio','label','Sem rastreio há +2 dias','n',coalesce(v_sem_track,0),'nivel','alerta','href','/integracoes-lojas'),
      jsonb_build_object('chave','comissao_pend','label','Comissões a repassar','n',coalesce(v_com_pend,0),'nivel','info','href','/coproducao'),
      jsonb_build_object('chave','repasse_aberto','label','Lotes de repasse abertos','n',coalesce(v_repasse_pend,0),'nivel','info','href','/coproducao')
    )
  );
end; $$;
grant execute on function public.alertas_resumo(uuid) to authenticated;
