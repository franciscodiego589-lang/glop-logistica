-- ════════════════════════════════════════════════════════════════════════════
-- Store Hub — Devolução de rastreio para a plataforma (ex.: Monetizze /sales/tracking)
-- ════════════════════════════════════════════════════════════════════════════
-- Quando o ERP gera o código de rastreio dos Correios de um pedido, devolvemos
-- para a plataforma de origem (a Monetizze notifica o comprador). Precisamos
-- marcar o que já foi enviado para NÃO re-notificar o cliente a cada sync.
--   - tracking_pushed_at: quando o rastreio foi aceito pela plataforma
--   - tracking_push_msg:  última mensagem de retorno (sucesso/erro) da plataforma
-- Aditivo e idempotente.
-- ════════════════════════════════════════════════════════════════════════════

alter table public.store_orders
  add column if not exists tracking_pushed_at timestamptz,
  add column if not exists tracking_push_msg text;

-- Fila de pendências: pedidos com rastreio ainda não devolvido à plataforma.
create index if not exists store_orders_tracking_pending_idx
  on public.store_orders (company_id, connector_id)
  where tracking_code is not null and tracking_pushed_at is null and deleted_at is null;
