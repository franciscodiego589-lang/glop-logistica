-- 20260713000015_logia.sql
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  VOLUME 15 — LOGIA (IA Corporativa de Logística)                          ║
-- ║  Base de conhecimento (pgvector) · conversas/mensagens · insights ·       ║
-- ║  planos de ação. A geração é feita por Edge Function (logia-brain).       ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

create type public.insight_kind    as enum ('rupture_risk','excess_stock','bottleneck','waste','fraud_risk','cost_saving','demand_shift','supplier_risk','sla_risk','opportunity');
create type public.insight_status  as enum ('new','reviewed','acted','dismissed');
create type public.action_status   as enum ('proposed','approved','in_progress','done','canceled');

-- ── LOGIA_KNOWLEDGE (RAG / embeddings) ───────────────────────────────────────
create table public.logia_knowledge (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  source text, title text, content text not null, embedding vector(1536),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
-- (idx_logia_knowledge_company é criado pelo loop padrão no fim do arquivo)
create index idx_logia_knowledge_embedding on public.logia_knowledge using ivfflat (embedding vector_cosine_ops) with (lists = 100);

-- ── LOGIA_CONVERSATIONS + mensagens ──────────────────────────────────────────
create table public.logia_conversations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  user_id uuid references auth.users(id) on delete set null, title text,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create table public.logia_messages (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  conversation_id uuid not null references public.logia_conversations(id) on delete cascade,
  role text not null,                                 -- user, assistant, system, tool
  content text, tokens integer,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_logia_messages_conversation on public.logia_messages (conversation_id, created_at);

-- ── LOGIA_INSIGHTS (vigia proativo) ──────────────────────────────────────────
create table public.logia_insights (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  kind public.insight_kind not null, status public.insight_status not null default 'new',
  severity public.event_severity not null default 'warning',
  title text not null, description text, recommendation text,
  impact_value numeric(16,2), confidence numeric(5,2),
  reference_type text, reference_id uuid,
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_logia_insights_status on public.logia_insights (company_id, status) where deleted_at is null;
create index idx_logia_insights_kind on public.logia_insights (company_id, kind);

-- ── LOGIA_ACTION_PLANS (planos de ação gerados/executados) ───────────────────
create table public.logia_action_plans (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid not null references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  insight_id uuid references public.logia_insights(id) on delete set null,
  title text not null, status public.action_status not null default 'proposed',
  steps jsonb not null default '[]'::jsonb, owner_id uuid references auth.users(id),
  due_date date, expected_impact numeric(16,2),
  active boolean not null default true, version integer not null default 1, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index idx_logia_action_plans_status on public.logia_action_plans (company_id, status) where deleted_at is null;

-- ── RPC: computa insights determinísticos (baratos, sem chamar LLM) ─────────
-- Rupturas, excessos e vencimentos viram insights consultáveis pela LOGIA.
create or replace function public.logia_scan(p_company uuid)
returns integer
language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_count int := 0; v_p record; v_onhand numeric;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id = p_company;

  -- limpa insights antigos 'new' regenerados
  update public.logia_insights set status='dismissed'
    where company_id=p_company and status='new' and kind in ('rupture_risk','excess_stock') and deleted_at is null;

  for v_p in select id, name, reorder_point, max_stock, safety_stock from public.products
             where company_id=p_company and active and deleted_at is null
  loop
    select coalesce(sum(quantity),0) into v_onhand from public.stock_balances
      where product_id=v_p.id and deleted_at is null;

    if v_p.reorder_point is not null and v_onhand < v_p.reorder_point then
      insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
      values (v_tenant, p_company, 'rupture_risk', 'critical', 'Risco de ruptura: '||v_p.name,
        'Saldo '||v_onhand||' abaixo do ponto de pedido '||v_p.reorder_point,
        'Emitir ordem de compra/produção imediatamente.', 95);
      v_count := v_count + 1;
    elsif v_p.max_stock is not null and v_onhand > v_p.max_stock then
      insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
      values (v_tenant, p_company, 'excess_stock', 'warning', 'Excesso de estoque: '||v_p.name,
        'Saldo '||v_onhand||' acima do máximo '||v_p.max_stock,
        'Rever compras / promover giro para liberar capital.', 85);
      v_count := v_count + 1;
    end if;
  end loop;
  return v_count;
end;
$$;
grant execute on function public.logia_scan(uuid) to authenticated;

do $do$
declare t text; specs text[] := array[
  'logia_knowledge','logia_conversations','logia_messages','logia_insights','logia_action_plans'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'logia.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'logia.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
  end loop;
end $do$;
grant select, insert, update, delete on all tables in schema public to authenticated;
