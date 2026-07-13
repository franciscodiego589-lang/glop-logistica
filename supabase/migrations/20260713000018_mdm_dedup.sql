-- 20260713000018_mdm_dedup.sql
-- VOLUME 02 · MDM — IA de qualidade: detecção de produtos duplicados/semelhantes (pg_trgm).
create or replace function public.detect_duplicate_products(p_company uuid, p_threshold real default 0.6)
returns jsonb
language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then coalesce(jsonb_agg(row_to_json(s)), '[]'::jsonb) else '[]'::jsonb end
  from (
    select p1.id as a_id, p1.name as a_name, p1.sku as a_sku,
           p2.id as b_id, p2.name as b_name, p2.sku as b_sku,
           round(similarity(p1.name, p2.name)::numeric, 2) as similarity,
           case when p1.sku is not null and p1.sku = p2.sku then 'sku' else 'nome' end as reason
    from public.products p1
    join public.products p2
      on p2.company_id = p1.company_id and p2.id > p1.id and p2.deleted_at is null
     and ((p1.sku is not null and p1.sku = p2.sku) or similarity(p1.name, p2.name) > p_threshold)
    where p1.company_id = p_company and p1.deleted_at is null
    order by similarity desc
    limit 100
  ) s;
$$;
grant execute on function public.detect_duplicate_products(uuid, real) to authenticated;
