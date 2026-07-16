-- ════════════════════════════════════════════════════════════════════════════
-- Onda 4 — SAC / Atendimento: central de tickets (chamados) com SLA
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists public.atendimento_tickets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null, company_id uuid, branch_id uuid,
  assunto text not null,
  comprador_nome text,
  sale_number text,
  canal text not null default 'whatsapp' check (canal in ('whatsapp','email','telefone','site','outro')),
  prioridade text not null default 'media' check (prioridade in ('baixa','media','alta','urgente')),
  status text not null default 'aberto' check (status in ('aberto','em_andamento','aguardando','resolvido','fechado')),
  descricao text,
  resposta text,
  responsavel text,
  active boolean not null default true, version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index if not exists idx_atend_company on public.atendimento_tickets (company_id, status) where deleted_at is null;

create trigger trg_atend_touch before insert or update on public.atendimento_tickets for each row execute function app.tg_touch_row();
create trigger trg_atend_audit after insert or update or delete on public.atendimento_tickets for each row execute function app.tg_write_audit();

alter table public.atendimento_tickets enable row level security;
do $$ begin
  create policy atend_select on public.atendimento_tickets for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));
  create policy atend_insert on public.atendimento_tickets for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission('shipping.create', company_id));
  create policy atend_update on public.atendimento_tickets for update to authenticated using (app.can_access_company(company_id) and app.has_permission('shipping.update', company_id)) with check (app.can_access_company(company_id));
  create policy atend_delete on public.atendimento_tickets for delete to authenticated using (app.is_superadmin());
exception when duplicate_object then null; end $$;
grant select, insert, update, delete on public.atendimento_tickets to authenticated;

create or replace function public.rel_atendimento(p_company uuid, p_days int default 30)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int; v_abertos int; v_urg int; v_resolv int; v_total int;
  s_status jsonb; s_canal jsonb; s_prior jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,30),1); v_desde := now() - make_interval(days => d);

  select count(*), count(*) filter (where status in ('aberto','em_andamento','aguardando')),
         count(*) filter (where prioridade='urgente' and status not in ('resolvido','fechado')),
         count(*) filter (where status in ('resolvido','fechado'))
    into v_total, v_abertos, v_urg, v_resolv
  from public.atendimento_tickets where company_id=p_company and deleted_at is null and created_at>=v_desde;

  select coalesce(jsonb_agg(jsonb_build_object('label',status,'n',n,'fmt','int') order by n desc),'[]') into s_status
    from (select status, count(*) n from public.atendimento_tickets where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',canal,'n',n,'fmt','int') order by n desc),'[]') into s_canal
    from (select canal, count(*) n from public.atendimento_tickets where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',prioridade,'n',n,'fmt','int') order by n desc),'[]') into s_prior
    from (select prioridade, count(*) n from public.atendimento_tickets where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc) x;

  return jsonb_build_object('titulo','Atendimento / SAC','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Chamados','valor',v_total,'fmt','int','icon','🎧','tone','accent'),
      jsonb_build_object('label','Em aberto','valor',v_abertos,'fmt','int','icon','📬','tone','warning'),
      jsonb_build_object('label','Urgentes','valor',v_urg,'fmt','int','icon','🚨','tone','danger'),
      jsonb_build_object('label','Resolvidos','valor',v_resolv,'fmt','int','icon','✅','tone','success')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Chamados por status','tipo','bars','itens',s_status),
      jsonb_build_object('titulo','Por canal','tipo','bars','itens',s_canal),
      jsonb_build_object('titulo','Por prioridade','tipo','bars','itens',s_prior)));
end $$;
grant execute on function public.rel_atendimento(uuid, int) to authenticated;
