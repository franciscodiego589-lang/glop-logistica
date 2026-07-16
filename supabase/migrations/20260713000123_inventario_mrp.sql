-- ════════════════════════════════════════════════════════════════════════════
-- Onda 5 — Inventário + MRP (ficha técnica de insumos → necessidade de compra)
-- ════════════════════════════════════════════════════════════════════════════

-- ── Inventário / contagem ───────────────────────────────────────────────────
create table if not exists public.estoque_inventario (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  produto_nome text not null, sku text, local text,
  qtd_sistema numeric(14,3) not null default 0,
  qtd_contada numeric(14,3) not null default 0,
  contado_em date not null default current_date,
  responsavel text, observacoes text,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_estoque_inv_company on public.estoque_inventario (company_id) where deleted_at is null;

-- ── Ficha técnica / BOM (insumos por produto) ───────────────────────────────
create table if not exists public.producao_insumos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  produto_nome text not null,                       -- produto final (casa com store_orders.product_name)
  insumo text not null,                             -- matéria-prima / componente
  quantidade_por_unidade numeric(14,4) not null default 0,
  unidade text not null default 'un',
  custo_unitario numeric(14,4) not null default 0,
  observacoes text,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_prod_insumos_company on public.producao_insumos (company_id) where deleted_at is null;

create trigger trg_estoque_inv_touch before insert or update on public.estoque_inventario for each row execute function app.tg_touch_row();
create trigger trg_estoque_inv_audit after insert or update or delete on public.estoque_inventario for each row execute function app.tg_write_audit();
create trigger trg_prod_insumos_touch before insert or update on public.producao_insumos for each row execute function app.tg_touch_row();
create trigger trg_prod_insumos_audit after insert or update or delete on public.producao_insumos for each row execute function app.tg_write_audit();

alter table public.estoque_inventario enable row level security;
alter table public.producao_insumos enable row level security;
do $$ begin
  create policy inv_select on public.estoque_inventario for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));
  create policy inv_insert on public.estoque_inventario for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission('inventory.create', company_id));
  create policy inv_update on public.estoque_inventario for update to authenticated using (app.can_access_company(company_id) and app.has_permission('inventory.update', company_id)) with check (app.can_access_company(company_id));
  create policy inv_delete on public.estoque_inventario for delete to authenticated using (app.is_superadmin());
  create policy insumo_select on public.producao_insumos for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));
  create policy insumo_insert on public.producao_insumos for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission('production.create', company_id));
  create policy insumo_update on public.producao_insumos for update to authenticated using (app.can_access_company(company_id) and app.has_permission('production.update', company_id)) with check (app.can_access_company(company_id));
  create policy insumo_delete on public.producao_insumos for delete to authenticated using (app.is_superadmin());
exception when duplicate_object then null; end $$;
grant select, insert, update, delete on public.estoque_inventario to authenticated;
grant select, insert, update, delete on public.producao_insumos to authenticated;

-- ── RPC: MRP (necessidade de insumos a partir das vendas × ficha técnica) ────
create or replace function public.rel_mrp(p_company uuid, p_days int default 30)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int; v_prod int; v_insumos int; v_custo numeric;
  s_insumo jsonb; t_det jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,30),1); v_desde := now() - make_interval(days => d);

  create temp table _mrp on commit drop as
  with vendas as (
    select coalesce(product_name,'—') produto, count(*) qtd
    from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde
      and state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')
    group by 1)
  select fi.insumo, fi.unidade,
    sum(v.qtd * fi.quantidade_por_unidade) as necessario,
    sum(v.qtd * fi.quantidade_por_unidade * fi.custo_unitario) as custo
  from vendas v
  join public.producao_insumos fi on fi.company_id=p_company and fi.deleted_at is null and v.produto ilike '%'||fi.produto_nome||'%'
  group by fi.insumo, fi.unidade;

  select count(distinct insumo), coalesce(sum(custo),0) into v_insumos, v_custo from _mrp;
  select count(distinct produto) into v_prod from (select coalesce(product_name,'—') produto from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1) x;

  select coalesce(jsonb_agg(jsonb_build_object('label',insumo||' ('||unidade||')','n',round(necessario,2),'valor',round(custo,2),'fmt','money') order by necessario desc),'[]') into s_insumo
    from (select insumo, unidade, necessario, custo from _mrp order by necessario desc limit 20) x;
  select coalesce(jsonb_agg(jsonb_build_object('insumo',insumo,'unidade',unidade,'necessario',round(necessario,2),'custo',round(custo,2)) order by necessario desc),'[]') into t_det
    from (select insumo, unidade, necessario, custo from _mrp order by necessario desc limit 100) x;

  return jsonb_build_object('titulo','MRP — Necessidade de Insumos','periodo','com base nas vendas dos últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Produtos vendidos','valor',v_prod,'fmt','int','icon','▤','tone','accent'),
      jsonb_build_object('label','Insumos necessários','valor',v_insumos,'fmt','int','icon','🧪','tone','neutral'),
      jsonb_build_object('label','Custo estimado de compra','valor',v_custo,'fmt','money','icon','💰','tone','warning')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Insumos a comprar (por quantidade)','tipo','bars','itens',s_insumo),
      jsonb_build_object('titulo','Necessidade detalhada','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','insumo','label','Insumo','fmt','text'),
                          jsonb_build_object('key','unidade','label','Un','fmt','text'),
                          jsonb_build_object('key','necessario','label','Necessário','fmt','int'),
                          jsonb_build_object('key','custo','label','Custo','fmt','money')),'linhas',t_det)));
end $$;
grant execute on function public.rel_mrp(uuid, int) to authenticated;

-- ── RPC: inventário (divergências) ──────────────────────────────────────────
create or replace function public.rel_inventario(p_company uuid, p_days int default 3650)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_itens int; v_diverg int; t_div jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select count(*), count(*) filter (where qtd_contada <> qtd_sistema) into v_itens, v_diverg
    from public.estoque_inventario where company_id=p_company and deleted_at is null;
  select coalesce(jsonb_agg(jsonb_build_object('produto',produto_nome,'local',coalesce(local,'—'),'sistema',qtd_sistema,'contado',qtd_contada,'dif',(qtd_contada-qtd_sistema)) order by abs(qtd_contada-qtd_sistema) desc),'[]') into t_div
    from (select produto_nome, local, qtd_sistema, qtd_contada from public.estoque_inventario where company_id=p_company and deleted_at is null and qtd_contada <> qtd_sistema order by abs(qtd_contada-qtd_sistema) desc limit 100) x;
  return jsonb_build_object('titulo','Inventário — Divergências','periodo','contagem atual',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Itens contados','valor',v_itens,'fmt','int','icon','📋','tone','accent'),
      jsonb_build_object('label','Com divergência','valor',v_diverg,'fmt','int','icon','⚠️','tone',(case when v_diverg>0 then 'danger' else 'success' end))),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Divergências (contado × sistema)','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','produto','label','Produto','fmt','text'),
                          jsonb_build_object('key','local','label','Local','fmt','text'),
                          jsonb_build_object('key','sistema','label','Sistema','fmt','int'),
                          jsonb_build_object('key','contado','label','Contado','fmt','int'),
                          jsonb_build_object('key','dif','label','Diferença','fmt','int')),'linhas',t_div)));
end $$;
grant execute on function public.rel_inventario(uuid, int) to authenticated;
