-- ════════════════════════════════════════════════════════════════════════════
-- Store Hub — Ingestão em LOTE de pedidos puxados via API (ex.: Monetizze)
-- ════════════════════════════════════════════════════════════════════════════
-- Puxar "todos os pedidos" de uma plataforma (a Monetizze de OZEMPHARMA tem
-- ~8.7k vendas em 88 páginas) com 1 chamada de RPC por linha estouraria o
-- timeout do serverless. Esta função recebe um ARRAY de pedidos já normalizados
-- e processa tudo em UMA chamada do app, reusando ingest_store_webhook (que já é
-- idempotente e roda a máquina de estados). O loop roda no Postgres (rápido).
--
-- Cada item do array: { sale_number, event_type, raw:{ buyer_*, product_name,
-- value, dest_* , ... } } — exatamente o que a rota /api/lojas/pull monta.
-- ════════════════════════════════════════════════════════════════════════════

create or replace function public.ingest_store_orders_bulk(
  p_company uuid, p_connector uuid, p_orders jsonb)
returns jsonb language plpgsql security definer set search_path = public, app as $$
declare
  it jsonb;
  r jsonb;
  v_total int := 0; v_imported int := 0; v_dup int := 0; v_err int := 0;
begin
  if not (app.can_access_company(p_company) and app.has_permission('integration.create', p_company)) then
    raise exception 'forbidden';
  end if;
  if p_orders is null or jsonb_typeof(p_orders) <> 'array' then
    return jsonb_build_object('total', 0, 'imported', 0, 'duplicates', 0, 'errors', 0);
  end if;

  for it in select value from jsonb_array_elements(p_orders) loop
    -- sale_number vazio não entra (não há como manter idempotência)
    if coalesce(it->>'sale_number','') = '' then
      v_err := v_err + 1; continue;
    end if;
    v_total := v_total + 1;
    begin
      r := public.ingest_store_webhook(
        p_company,
        p_connector,
        coalesce(nullif(it->>'event_type',''), 'paid'),
        it->>'sale_number',
        coalesce(it->'raw', '{}'::jsonb),
        true);
      if coalesce((r->>'duplicate')::boolean, false) then
        v_dup := v_dup + 1;
      else
        v_imported := v_imported + 1;
      end if;
    exception when others then
      v_err := v_err + 1;
    end;
  end loop;

  return jsonb_build_object('total', v_total, 'imported', v_imported, 'duplicates', v_dup, 'errors', v_err);
end; $$;

grant execute on function public.ingest_store_orders_bulk(uuid,uuid,jsonb) to authenticated;
