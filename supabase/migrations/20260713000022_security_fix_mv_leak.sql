-- 20260713000022_security_fix_mv_leak.sql
-- HARDENING (auditoria 2026-07-14): remove vazamento cross-tenant.
-- public.mv_stock_on_hand é uma materialized view (SEM RLS) e estava legível por
-- 'authenticated' porque os `grant ... on all tables in schema public` das migrations
-- 17/19/20/21 DESFIZERAM o `revoke` original da migration 10. Qualquer usuário logado
-- de qualquer empresa poderia ler saldo/valor de estoque de TODAS as empresas.
-- A MV não é usada pelo aplicativo → removida. Consolidação de estoque deve vir de RPC
-- security-definer com filtro por empresa (ex.: inventory_kpis), nunca de MV exposta.
drop materialized view if exists public.mv_stock_on_hand;
