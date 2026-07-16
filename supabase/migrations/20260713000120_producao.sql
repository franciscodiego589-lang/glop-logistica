-- ════════════════════════════════════════════════════════════════════════════
-- Onda 3 — Produção & Estoque (fabricante): Ordem de Produção + Lote & Validade
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.producao_ordens (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  numero text,
  produto_nome text not null,
  quantidade numeric(14,3) not null default 0,
  unidade text not null default 'un',
  status text not null default 'planejada' check (status in ('planejada','em_producao','concluida','cancelada')),
  data_prevista date,
  data_conclusao date,
  responsavel text,
  observacoes text,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_prod_ordens_company on public.producao_ordens (company_id, status) where deleted_at is null;

create table if not exists public.producao_lotes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  lote text not null,
  produto_nome text not null,
  quantidade numeric(14,3) not null default 0,
  fabricacao date,
  validade date,
  status text not null default 'liberado' check (status in ('liberado','quarentena','bloqueado','vencido','esgotado')),
  observacoes text,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_prod_lotes_company on public.producao_lotes (company_id, validade) where deleted_at is null;

create trigger trg_prod_ordens_touch before insert or update on public.producao_ordens for each row execute function app.tg_touch_row();
create trigger trg_prod_ordens_audit after insert or update or delete on public.producao_ordens for each row execute function app.tg_write_audit();
create trigger trg_prod_lotes_touch before insert or update on public.producao_lotes for each row execute function app.tg_touch_row();
create trigger trg_prod_lotes_audit after insert or update or delete on public.producao_lotes for each row execute function app.tg_write_audit();

alter table public.producao_ordens enable row level security;
alter table public.producao_lotes enable row level security;
do $$ begin
  create policy prod_ordens_select on public.producao_ordens for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));
  create policy prod_ordens_insert on public.producao_ordens for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission('production.create', company_id));
  create policy prod_ordens_update on public.producao_ordens for update to authenticated using (app.can_access_company(company_id) and app.has_permission('production.update', company_id)) with check (app.can_access_company(company_id));
  create policy prod_ordens_delete on public.producao_ordens for delete to authenticated using (app.is_superadmin());
  create policy prod_lotes_select on public.producao_lotes for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));
  create policy prod_lotes_insert on public.producao_lotes for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission('production.create', company_id));
  create policy prod_lotes_update on public.producao_lotes for update to authenticated using (app.can_access_company(company_id) and app.has_permission('production.update', company_id)) with check (app.can_access_company(company_id));
  create policy prod_lotes_delete on public.producao_lotes for delete to authenticated using (app.is_superadmin());
exception when duplicate_object then null; end $$;
grant select, insert, update, delete on public.producao_ordens to authenticated;
grant select, insert, update, delete on public.producao_lotes to authenticated;

-- ── RPC: painel de produção (OPs + lotes + vencimentos) ─────────────────────
create or replace function public.rel_producao(p_company uuid, p_days int default 0)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_op_abertas int; v_op_prod int; v_lotes int; v_venc int; v_venc30 int; v_quar int;
  s_op jsonb; s_lote jsonb; t_venc jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;

  select count(*) filter (where status in ('planejada','em_producao')), count(*) filter (where status='em_producao')
    into v_op_abertas, v_op_prod from public.producao_ordens where company_id=p_company and deleted_at is null;
  select count(*) filter (where status not in ('vencido','esgotado')),
         count(*) filter (where validade is not null and validade < current_date),
         count(*) filter (where validade is not null and validade >= current_date and validade < current_date + 30),
         count(*) filter (where status='quarentena')
    into v_lotes, v_venc, v_venc30, v_quar from public.producao_lotes where company_id=p_company and deleted_at is null;

  select coalesce(jsonb_agg(jsonb_build_object('label',status,'n',n,'fmt','int') order by n desc),'[]') into s_op
    from (select status, count(*) n from public.producao_ordens where company_id=p_company and deleted_at is null group by 1 order by n desc) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',status,'n',n,'fmt','int') order by n desc),'[]') into s_lote
    from (select status, count(*) n from public.producao_lotes where company_id=p_company and deleted_at is null group by 1 order by n desc) x;
  select coalesce(jsonb_agg(jsonb_build_object('lote',lote,'produto',produto_nome,'validade',validade,'vence_em',(validade-current_date)||' dias') order by validade),'[]') into t_venc
    from (select lote, produto_nome, validade from public.producao_lotes
          where company_id=p_company and deleted_at is null and validade is not null and validade < current_date + 90
          order by validade limit 50) x;

  return jsonb_build_object('titulo','Produção & Validade','periodo','estado atual',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Ordens abertas','valor',v_op_abertas,'fmt','int','icon','🏭','tone','accent'),
      jsonb_build_object('label','Em produção','valor',v_op_prod,'fmt','int','icon','⚙️','tone','warning'),
      jsonb_build_object('label','Lotes ativos','valor',v_lotes,'fmt','int','icon','📦','tone','neutral'),
      jsonb_build_object('label','Vencidos','valor',v_venc,'fmt','int','icon','⛔','tone','danger'),
      jsonb_build_object('label','Vencem em 30 dias','valor',v_venc30,'fmt','int','icon','⏳','tone','warning'),
      jsonb_build_object('label','Em quarentena','valor',v_quar,'fmt','int','icon','🔬','tone','warning')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Ordens por status','tipo','bars','itens',s_op),
      jsonb_build_object('titulo','Lotes por status','tipo','bars','itens',s_lote),
      jsonb_build_object('titulo','Lotes vencendo (próximos 90 dias)','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','lote','label','Lote','fmt','text'),
                          jsonb_build_object('key','produto','label','Produto','fmt','text'),
                          jsonb_build_object('key','validade','label','Validade','fmt','date'),
                          jsonb_build_object('key','vence_em','label','Vence em','fmt','text')),'linhas',t_venc)));
end $$;
grant execute on function public.rel_producao(uuid, int) to authenticated;
