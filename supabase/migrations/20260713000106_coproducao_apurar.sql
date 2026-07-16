-- ════════════════════════════════════════════════════════════════════════════
-- AUTOMAÇÃO #2 — Apuração automática de comissão da coprodução
-- ════════════════════════════════════════════════════════════════════════════
-- Transforma as VENDAS (store_orders) em comissões (coproducao_vendas) sozinho:
-- para cada venda ainda não apurada, acha a regra de comissão que casa pelo
-- produto (produto_nome contido, maior prioridade) e calcula comissão × empresa.
-- Idempotente: não reapura venda que já tem coproducao_venda (por codigo_venda).
-- ════════════════════════════════════════════════════════════════════════════

create or replace function public.coproducao_apurar(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare
  v_tenant uuid; v_apurados int := 0; v_sem_regra int := 0;
  o record; r record; v_base numeric; v_com numeric;
begin
  if not (app.can_access_company(p_company) and app.has_permission('purchasing.create', p_company)) then
    raise exception 'forbidden';
  end if;
  select tenant_id into v_tenant from public.companies where id = p_company;

  for o in
    select so.id, so.sale_number, so.buyer_name, so.product_name, so.value, so.created_at
    from public.store_orders so
    where so.company_id = p_company and so.deleted_at is null
      and so.state in ('recebido','pronto_despacho','pre_postado','etiquetado','postado','em_transito','saiu_entrega','entregue')
      and so.sale_number is not null
      and not exists (
        select 1 from public.coproducao_vendas cv
        where cv.company_id = p_company and cv.codigo_venda = so.sale_number and cv.deleted_at is null)
    limit 5000
  loop
    select cr.id, cr.coprodutor_id, cr.percentual_comissao
      into r
    from public.coproducao_regras cr
    where cr.company_id = p_company and cr.status = 'ativo' and cr.deleted_at is null
      and cr.produto_nome is not null and o.product_name ilike '%' || cr.produto_nome || '%'
    order by cr.prioridade nulls last
    limit 1;

    if r.id is null then v_sem_regra := v_sem_regra + 1; continue; end if;

    v_base := coalesce(o.value, 0);
    v_com  := round(v_base * coalesce(r.percentual_comissao, 0) / 100.0, 2);

    insert into public.coproducao_vendas
      (tenant_id, company_id, coprodutor_id, regra_comissao_id, origem, codigo_venda, cliente_nome,
       produto_nome, valor_total, valor_comissao, valor_empresa, percentual_comissao, status_repasse, data_venda)
    values
      (v_tenant, p_company, r.coprodutor_id, r.id, 'manual', o.sale_number, o.buyer_name,
       o.product_name, v_base, v_com, v_base - v_com, r.percentual_comissao, 'pendente', o.created_at);
    v_apurados := v_apurados + 1;
  end loop;

  return jsonb_build_object('apurados', v_apurados, 'sem_regra', v_sem_regra);
end; $$;

grant execute on function public.coproducao_apurar(uuid) to authenticated;
