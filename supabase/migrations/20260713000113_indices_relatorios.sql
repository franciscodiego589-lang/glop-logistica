-- ════════════════════════════════════════════════════════════════════════════
-- Índices de performance para os relatórios (filtros por empresa + janela de tempo).
-- Mantêm os RPCs rel_* rápidos conforme os dados crescem.
-- ════════════════════════════════════════════════════════════════════════════
create index if not exists idx_store_orders_company_created
  on public.store_orders (company_id, created_at) where deleted_at is null;

create index if not exists idx_audit_logs_company_occurred
  on public.audit_logs (company_id, occurred_at desc);

create index if not exists idx_store_order_events_company_occurred
  on public.store_order_events (company_id, occurred_at) where deleted_at is null;

create index if not exists idx_store_webhook_events_company_received
  on public.store_webhook_events (company_id, received_at) where deleted_at is null;
