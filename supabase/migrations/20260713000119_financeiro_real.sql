-- ════════════════════════════════════════════════════════════════════════════
-- Onda 2 — Financeiro real: despesas + custo por produto → lucro real por pedido
-- ════════════════════════════════════════════════════════════════════════════

-- ── Despesas ────────────────────────────────────────────────────────────────
create table if not exists public.financeiro_despesas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  descricao text not null,
  categoria text,                          -- marketing, insumos, frete, taxas, salarios, aluguel, outros
  tipo text not null default 'variavel' check (tipo in ('fixa','variavel')),
  valor numeric(14,2) not null default 0,
  competencia date not null default current_date,
  recorrente boolean not null default false,
  observacoes text,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_fin_despesas_company on public.financeiro_despesas (company_id, competencia) where deleted_at is null;

-- ── Custo por produto ───────────────────────────────────────────────────────
create table if not exists public.financeiro_custos_produto (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  produto_nome text,                       -- casa com store_orders.product_name (contém)
  sku text,
  custo_unitario numeric(14,2) not null default 0,   -- CMV por unidade
  frete_medio numeric(14,2) not null default 0,      -- custo médio de frete por pedido
  taxa_gateway_pct numeric(6,2) not null default 0,  -- % de taxa do gateway/checkout
  observacoes text,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_fin_custos_company on public.financeiro_custos_produto (company_id) where deleted_at is null;

-- triggers padrão
create trigger trg_fin_despesas_touch before insert or update on public.financeiro_despesas for each row execute function app.tg_touch_row();
create trigger trg_fin_despesas_audit after insert or update or delete on public.financeiro_despesas for each row execute function app.tg_write_audit();
create trigger trg_fin_custos_touch before insert or update on public.financeiro_custos_produto for each row execute function app.tg_touch_row();
create trigger trg_fin_custos_audit after insert or update or delete on public.financeiro_custos_produto for each row execute function app.tg_write_audit();

-- RLS (recurso: purchasing)
alter table public.financeiro_despesas enable row level security;
alter table public.financeiro_custos_produto enable row level security;
do $$ begin
  create policy fin_despesas_select on public.financeiro_despesas for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));
  create policy fin_despesas_insert on public.financeiro_despesas for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission('purchasing.create', company_id));
  create policy fin_despesas_update on public.financeiro_despesas for update to authenticated using (app.can_access_company(company_id) and app.has_permission('purchasing.update', company_id)) with check (app.can_access_company(company_id));
  create policy fin_despesas_delete on public.financeiro_despesas for delete to authenticated using (app.is_superadmin());
  create policy fin_custos_select on public.financeiro_custos_produto for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));
  create policy fin_custos_insert on public.financeiro_custos_produto for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission('purchasing.create', company_id));
  create policy fin_custos_update on public.financeiro_custos_produto for update to authenticated using (app.can_access_company(company_id) and app.has_permission('purchasing.update', company_id)) with check (app.can_access_company(company_id));
  create policy fin_custos_delete on public.financeiro_custos_produto for delete to authenticated using (app.is_superadmin());
exception when duplicate_object then null; end $$;

grant select, insert, update, delete on public.financeiro_despesas to authenticated;
grant select, insert, update, delete on public.financeiro_custos_produto to authenticated;

-- ── RPC: lucro real por pedido (conciliação) ────────────────────────────────
create or replace function public.rel_lucro(p_company uuid, p_days int default 30)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int;
  v_receita numeric; v_com numeric; v_cmv numeric; v_frete numeric; v_taxa numeric; v_lucro numeric;
  v_desp numeric; v_result numeric; v_ped int; v_margem numeric;
  s_prod jsonb; s_canal jsonb; t_top jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,30),1); v_desde := now() - make_interval(days => d);

  create temp table _lucro on commit drop as
  select so.sale_number, coalesce(so.product_name,'—') produto, coalesce(so.platform,'—') canal,
    coalesce(so.value,0) receita,
    coalesce((select sum(cv.valor_comissao) from public.coproducao_vendas cv
              where cv.company_id=p_company and cv.codigo_venda=so.sale_number and cv.deleted_at is null),0) comissao,
    coalesce(c.custo_unitario,0) cmv,
    coalesce(c.frete_medio,0) frete,
    round(coalesce(so.value,0) * coalesce(c.taxa_gateway_pct,0)/100.0, 2) taxa
  from public.store_orders so
  left join lateral (
    select custo_unitario, frete_medio, taxa_gateway_pct
    from public.financeiro_custos_produto fc
    where fc.company_id=p_company and fc.deleted_at is null
      and ((fc.produto_nome is not null and so.product_name ilike '%'||fc.produto_nome||'%')
           or (fc.sku is not null and fc.sku = so.sku))
    order by length(coalesce(fc.produto_nome,'')) desc limit 1
  ) c on true
  where so.company_id=p_company and so.deleted_at is null and so.created_at>=v_desde
    and so.state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso');

  select coalesce(sum(receita),0), coalesce(sum(comissao),0), coalesce(sum(cmv),0),
         coalesce(sum(frete),0), coalesce(sum(taxa),0), count(*)
    into v_receita, v_com, v_cmv, v_frete, v_taxa, v_ped from _lucro;
  v_lucro := v_receita - v_com - v_cmv - v_frete - v_taxa;

  select coalesce(sum(valor),0) into v_desp from public.financeiro_despesas
   where company_id=p_company and deleted_at is null and competencia >= v_desde::date;
  v_result := v_lucro - v_desp;
  v_margem := case when v_receita>0 then round(v_lucro/v_receita*100,1) else 0 end;

  select coalesce(jsonb_agg(jsonb_build_object('label',produto,'n',pedidos,'valor',lucro,'fmt','money') order by lucro desc),'[]') into s_prod
    from (select produto, count(*) pedidos, sum(receita-comissao-cmv-frete-taxa) lucro from _lucro group by 1 order by lucro desc limit 15) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',canal,'n',pedidos,'valor',lucro,'fmt','money') order by lucro desc),'[]') into s_canal
    from (select canal, count(*) pedidos, sum(receita-comissao-cmv-frete-taxa) lucro from _lucro group by 1 order by lucro desc limit 10) x;
  select coalesce(jsonb_agg(jsonb_build_object('venda',sale_number,'produto',produto,'receita',receita,'lucro',(receita-comissao-cmv-frete-taxa)) order by (receita-comissao-cmv-frete-taxa) desc),'[]') into t_top
    from (select sale_number, produto, receita, comissao, cmv, frete, taxa from _lucro order by (receita-comissao-cmv-frete-taxa) desc limit 30) x;

  return jsonb_build_object('titulo','Lucro Real por Pedido','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Receita','valor',v_receita,'fmt','money','icon','💰','tone','success'),
      jsonb_build_object('label','(−) Comissões','valor',v_com,'fmt','money','icon','🤝','tone','warning'),
      jsonb_build_object('label','(−) CMV (produto)','valor',v_cmv,'fmt','money','icon','📦','tone','warning'),
      jsonb_build_object('label','(−) Frete','valor',v_frete,'fmt','money','icon','🚚','tone','warning'),
      jsonb_build_object('label','(−) Taxas gateway','valor',v_taxa,'fmt','money','icon','💳','tone','warning'),
      jsonb_build_object('label','= Lucro bruto','valor',v_lucro,'fmt','money','icon','📈','tone','success'),
      jsonb_build_object('label','(−) Despesas','valor',v_desp,'fmt','money','icon','🧾','tone','danger'),
      jsonb_build_object('label','= Resultado','valor',v_result,'fmt','money','icon','🏦','tone',(case when v_result>=0 then 'success' else 'danger' end)),
      jsonb_build_object('label','Margem','valor',v_margem,'fmt','pct','icon','🎯','tone','neutral'),
      jsonb_build_object('label','Pedidos','valor',v_ped,'fmt','int','icon','🧮','tone','accent')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Lucro por produto','tipo','bars','itens',s_prod),
      jsonb_build_object('titulo','Lucro por canal','tipo','bars','itens',s_canal),
      jsonb_build_object('titulo','Pedidos mais lucrativos','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','venda','label','Venda','fmt','text'),
                          jsonb_build_object('key','produto','label','Produto','fmt','text'),
                          jsonb_build_object('key','receita','label','Receita','fmt','money'),
                          jsonb_build_object('key','lucro','label','Lucro','fmt','money')),'linhas',t_top)));
end $$;
grant execute on function public.rel_lucro(uuid, int) to authenticated;
