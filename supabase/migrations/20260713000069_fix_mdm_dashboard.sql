-- ============================================================================
-- FIXES DA FASE 1 · migration 069
--
-- BUG A [ALTO]: a migration 058 (MDM governança) fez `create or replace
--   mdm_dashboard` sobrescrevendo a forma de PRODUTOS da 017_mdm_expansion →
--   KPIs da tela /produtos ficam vazios. Fix: governança vira
--   mdm_governance_dashboard e mdm_dashboard volta à forma de produtos.
--
-- BUG B [MÉDIO]: forecast_moving_average faz upsert `on conflict (product_id,
--   warehouse_id, period_month, method)`, mas com warehouse_id NULL ("Todos")
--   o NULL nunca conflita no índice único → cada "Prever" DUPLICA previsões
--   (infla KPI e faz o MRP contar demanda em dobro). Fix: dedupe + recriar o
--   índice como NULLS NOT DISTINCT (Postgres 15+, Supabase é 15+).
-- ============================================================================

-- 1) Governança (corpo da 058) sob novo nome
create or replace function public.mdm_governance_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select case when app.can_access_company(p_company) then jsonb_build_object(
    'domains', (select count(*) from public.mdm_domains where company_id=p_company and deleted_at is null),
    'avg_quality', (select coalesce(round(avg(quality_score)),0) from public.mdm_domains where company_id=p_company and quality_score is not null and deleted_at is null),
    'duplicates_open', (select count(*) from public.mdm_duplicates where company_id=p_company and status='pending' and deleted_at is null),
    'change_requests_pending', (select count(*) from public.mdm_change_requests where company_id=p_company and status='pending' and deleted_at is null),
    'glossary_terms', (select count(*) from public.mdm_glossary where company_id=p_company and deleted_at is null),
    'lineage_links', (select count(*) from public.data_lineage where company_id=p_company and deleted_at is null),
    'by_domain', (select coalesce(jsonb_agg(jsonb_build_object('domain', name, 'key', domain_key, 'score', quality_score, 'records', records_count) order by quality_score nulls last),'[]'::jsonb) from public.mdm_domains where company_id=p_company and deleted_at is null)
  ) else '{}'::jsonb end;
$$;
grant execute on function public.mdm_governance_dashboard(uuid) to authenticated;

-- 2) Restaura mdm_dashboard para a forma de PRODUTOS (corpo da 017_mdm_expansion)
create or replace function public.mdm_dashboard(p_company uuid)
returns jsonb language sql stable security definer set search_path = public, app as $$
  select jsonb_build_object(
    'total',            (select count(*) from public.products where company_id=p_company and deleted_at is null),
    'active',           (select count(*) from public.products where company_id=p_company and active and deleted_at is null),
    'blocked',          (select count(*) from public.products where company_id=p_company and not active and deleted_at is null),
    'no_photo',         (select count(*) from public.products p where p.company_id=p_company and p.deleted_at is null and not exists(select 1 from public.product_media m where m.product_id=p.id and m.deleted_at is null)),
    'no_supplier',      (select count(*) from public.products p where p.company_id=p_company and p.deleted_at is null and not exists(select 1 from public.product_suppliers s where s.product_id=p.id and s.deleted_at is null)),
    'no_tax',           (select count(*) from public.products where company_id=p_company and deleted_at is null and ncm is null),
    'no_dimensions',    (select count(*) from public.products where company_id=p_company and deleted_at is null and (length_mm is null or width_mm is null or height_mm is null)),
    'no_location',      (select count(*) from public.products where company_id=p_company and deleted_at is null and default_location_id is null),
    'brands',           (select count(*) from public.product_brands where company_id=p_company and deleted_at is null),
    'categories',       (select count(*) from public.product_categories where company_id=p_company and deleted_at is null),
    'abc_a',            (select count(*) from public.products where company_id=p_company and abc_class='A' and deleted_at is null),
    'data_quality_avg', (select round(coalesce(avg(data_quality_score),0),1) from public.products where company_id=p_company and deleted_at is null)
  ) where app.can_access_company(p_company);
$$;
grant execute on function public.mdm_dashboard(uuid) to authenticated;

-- ── BUG B: dedupe de previsões duplicadas + índice NULLS NOT DISTINCT ────────
-- remove duplicatas mantendo a linha mais recente (maior ctid) por chave,
-- tratando warehouse_id NULL como um único balde (is not distinct from).
delete from public.demand_forecasts a
using public.demand_forecasts b
where a.ctid < b.ctid
  and a.company_id  = b.company_id
  and a.product_id  = b.product_id
  and a.period_month = b.period_month
  and a.method      = b.method
  and a.warehouse_id is not distinct from b.warehouse_id;

drop index if exists public.uq_demand_forecasts_key;
create unique index uq_demand_forecasts_key
  on public.demand_forecasts (product_id, warehouse_id, period_month, method) nulls not distinct;

notify pgrst, 'reload schema';
