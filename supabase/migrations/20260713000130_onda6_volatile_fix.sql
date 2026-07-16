-- Onda 6: rel_crm e rel_metas usam tabelas temporárias (drop/create table),
-- portanto precisam ser VOLATILE (STABLE proíbe DROP TABLE). rel_fluxo_caixa e
-- rel_catalogo não usam temp tables e podem seguir STABLE.
alter function public.rel_crm(uuid, int) volatile;
alter function public.rel_metas(uuid, int) volatile;
