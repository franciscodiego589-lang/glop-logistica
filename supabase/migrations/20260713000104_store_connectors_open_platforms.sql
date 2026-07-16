-- ════════════════════════════════════════════════════════════════════════════
-- Store Connectors — liberar QUALQUER plataforma (pagamento/e-commerce)
-- ════════════════════════════════════════════════════════════════════════════
-- Antes, store_connectors.platform tinha um CHECK com lista fixa. Para o usuário
-- poder ADICIONAR qualquer plataforma de pagamento ou e-commerce que quiser
-- (Stripe, PagSeguro, VTEX, Nuvemshop, etc.), removemos o CHECK. A validação
-- passa a ser pela app; 'generic' continua sendo o adaptador padrão de pull.
-- ════════════════════════════════════════════════════════════════════════════

do $$
declare c record;
begin
  for c in
    select conname from pg_constraint
    where conrelid = 'public.store_connectors'::regclass and contype = 'c'
      and pg_get_constraintdef(oid) ilike '%platform%'
  loop
    execute format('alter table public.store_connectors drop constraint %I', c.conname);
  end loop;
end $$;

-- garante coluna de categoria (pagamento | ecommerce | outro) para agrupar no hub
alter table public.store_connectors
  add column if not exists categoria text not null default 'ecommerce';
