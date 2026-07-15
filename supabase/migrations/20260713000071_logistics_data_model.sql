-- ============================================================================
-- GLOP · CAP. 7 — fecha os 3 gaps do Modelo de Dados Logístico (migration 071)
-- Entidades: 03 volumes (físico cross-modal), 12 occurrences (ocorrência unificada
-- c/ mídia), 13 tracking_points (rastreamento geo unificado). Recurso RBAC 'ldm'.
-- Integridade do Cap. 7: volume SEMPRE tem pedido; evento SEMPRE tem origem.
-- Cada criação publica evento no barramento (contrato do Cap. 8).
-- Padrão: text+check, grant por-tabela, gerado só imutável.
-- ============================================================================

-- ── ENTIDADE 03 · VOLUMES (físico, atravessa pedido→transporte) ─────────────
create table if not exists public.volumes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text,
  order_id uuid not null references public.logistics_orders(id) on delete cascade,  -- proibido: volume sem pedido
  volume_type text not null default 'box' check (volume_type in ('box','envelope','pallet','container','bag','rack','gaylord')),
  weight_kg numeric(12,3),
  length_cm numeric(10,2), width_cm numeric(10,2), height_cm numeric(10,2),
  cubage_m3 numeric(14,6) generated always as (
    case when length_cm is null or width_cm is null or height_cm is null then null
         else (length_cm * width_cm * height_cm) / 1000000.0 end) stored,
  status text not null default 'open' check (status in ('open','packed','shipped','delivered','returned')),
  origin text, destination text,
  carrier_id uuid references public.carriers(id),
  tracking_code text,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── ENTIDADE 12 · OCORRÊNCIAS (unificada, polimórfica, com mídia) ───────────
create table if not exists public.occurrences (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  code text,
  occurrence_type text not null,
  category text,
  description text,
  entity_type text not null check (entity_type in ('order','shipment','volume','delivery','carrier','asset','warehouse')),
  entity_id uuid not null,
  priority text not null default 'normal' check (priority in ('low','normal','high','urgent')),
  status text not null default 'open' check (status in ('open','in_progress','resolved','canceled')),
  responsible_id uuid references auth.users(id),
  media jsonb not null default '[]'::jsonb,   -- fotos/vídeos: [{type,url}]
  resolution text,
  resolved_at timestamptz,
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

-- ── ENTIDADE 13 · TRACKING POINTS (geo unificado; alimenta o mapa) ──────────
create table if not exists public.tracking_points (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  company_id uuid references public.companies(id) on delete restrict,
  branch_id uuid references public.branches(id) on delete restrict,
  tracking_code text,
  entity_type text not null check (entity_type in ('order','shipment','volume')),
  entity_id uuid not null,                    -- proibido: evento/rastreio sem origem
  latitude numeric(10,7), longitude numeric(10,7),
  city text, uf text, country text default 'BR',
  event_description text,
  carrier_id uuid references public.carriers(id),
  occurred_at timestamptz not null default now(),
  active boolean not null default true,
  version integer not null default 1,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz, deleted_by uuid references auth.users(id), reason_deleted text,
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);

create index if not exists idx_volumes_order on public.volumes (order_id);
create index if not exists idx_occurrences_entity on public.occurrences (entity_type, entity_id);
create index if not exists idx_occurrences_status on public.occurrences (company_id, status, priority);
create index if not exists idx_tracking_entity on public.tracking_points (entity_type, entity_id, occurred_at);

-- ── RBAC 'ldm' ───────────────────────────────────────────────────────────────
insert into public.permissions (slug, resource, action, description)
select 'ldm.' || a, 'ldm', a, 'Permissão ' || a || ' em ldm'
from unnest(array['read','create','update','delete']) a
on conflict (slug) do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p
where p.resource = 'ldm' and r.slug in ('admin','superadmin')
on conflict do nothing;

do $do$
declare t text; specs text[] := array['volumes','occurrences','tracking_points'];
begin
  foreach t in array specs loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('create index if not exists %I on public.%I (company_id);', 'idx_'||t||'_company', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function app.tg_touch_row();', 'trg_'||t||'_touch', t);
    execute format('create trigger %I after insert or update or delete on public.%I for each row execute function app.tg_write_audit();', 'trg_'||t||'_audit', t);
    execute format('create policy %I on public.%I for select to authenticated using (app.is_superadmin() or company_id in (select app.user_company_ids()));', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (app.can_access_company(company_id) and app.has_permission(%L, company_id));', t||'_insert', t, 'ldm.create');
    execute format('create policy %I on public.%I for update to authenticated using (app.can_access_company(company_id) and app.has_permission(%L, company_id)) with check (app.can_access_company(company_id));', t||'_update', t, 'ldm.update');
    execute format('create policy %I on public.%I for delete to authenticated using (app.is_superadmin());', t||'_delete', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated;', t);
  end loop;
end $do$;

-- catálogo de eventos (contrato) desta camada
insert into public.event_types (slug, domain, stage_order, description) values
  ('volume.created', 'LDM', null, 'Volume físico criado'),
  ('volume.shipped', 'LDM', null, 'Volume embarcado'),
  ('occurrence.opened', 'LDM', null, 'Ocorrência logística registrada'),
  ('occurrence.resolved', 'LDM', null, 'Ocorrência resolvida'),
  ('tracking.point', 'LDM', null, 'Ponto de rastreamento capturado')
on conflict (slug) do nothing;

-- ── RPCs ─────────────────────────────────────────────────────────────────────
create or replace function public.create_volume(
  p_company uuid, p_order uuid, p_type text, p_weight numeric,
  p_length numeric, p_width numeric, p_height numeric, p_carrier uuid default null,
  p_origin text default null, p_destination text default null)
returns public.volumes language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v public.volumes; v_code text;
begin
  if not (app.can_access_company(p_company) and app.has_permission('ldm.create', p_company)) then raise exception 'forbidden'; end if;
  if not exists (select 1 from public.logistics_orders where id=p_order and company_id=p_company and deleted_at is null) then
    raise exception 'volume exige um pedido válido'; -- integridade Cap. 7
  end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  v_code := 'VOL-' || to_char(now(),'YYMMDD') || '-' || lpad((floor(random()*100000))::text,5,'0');
  insert into public.volumes (tenant_id, company_id, code, order_id, volume_type, weight_kg, length_cm, width_cm, height_cm, carrier_id, origin, destination)
  values (v_tenant, p_company, v_code, p_order, coalesce(p_type,'box'), p_weight, p_length, p_width, p_height, p_carrier, p_origin, p_destination)
  returning * into v;
  perform app.emit_event(p_company, 'volume.created', 'ldm', jsonb_build_object('volume_id', v.id, 'order_id', p_order, 'code', v_code));
  return v;
end; $$;
grant execute on function public.create_volume(uuid,uuid,text,numeric,numeric,numeric,numeric,uuid,text,text) to authenticated;

create or replace function public.log_occurrence(
  p_company uuid, p_type text, p_category text, p_description text,
  p_entity_type text, p_entity_id uuid, p_priority text default 'normal', p_media jsonb default '[]'::jsonb)
returns public.occurrences language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; o public.occurrences; v_code text;
begin
  if not (app.can_access_company(p_company) and app.has_permission('ldm.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  v_code := 'OCC-' || to_char(now(),'YYMMDD') || '-' || lpad((floor(random()*100000))::text,5,'0');
  insert into public.occurrences (tenant_id, company_id, code, occurrence_type, category, description, entity_type, entity_id, priority, media, responsible_id)
  values (v_tenant, p_company, v_code, p_type, p_category, p_description, p_entity_type, p_entity_id, coalesce(p_priority,'normal'), coalesce(p_media,'[]'::jsonb), auth.uid())
  returning * into o;
  perform app.emit_event(p_company, 'occurrence.opened', 'ldm', jsonb_build_object('occurrence_id', o.id, 'entity_type', p_entity_type, 'entity_id', p_entity_id, 'priority', o.priority));
  return o;
end; $$;
grant execute on function public.log_occurrence(uuid,text,text,text,text,uuid,text,jsonb) to authenticated;

create or replace function public.resolve_occurrence(p_company uuid, p_occurrence uuid, p_resolution text)
returns public.occurrences language plpgsql security definer set search_path = public, app as $$
declare o public.occurrences;
begin
  if not (app.can_access_company(p_company) and app.has_permission('ldm.update', p_company)) then raise exception 'forbidden'; end if;
  update public.occurrences set status='resolved', resolution=p_resolution, resolved_at=now()
    where id=p_occurrence and company_id=p_company returning * into o;
  if o.id is null then raise exception 'ocorrência não encontrada'; end if;
  perform app.emit_event(p_company, 'occurrence.resolved', 'ldm', jsonb_build_object('occurrence_id', o.id));
  return o;
end; $$;
grant execute on function public.resolve_occurrence(uuid,uuid,text) to authenticated;

create or replace function public.add_tracking_point(
  p_company uuid, p_entity_type text, p_entity_id uuid, p_lat numeric, p_lng numeric,
  p_city text, p_uf text, p_event text, p_carrier uuid default null, p_country text default 'BR')
returns public.tracking_points language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; tp public.tracking_points;
begin
  if not (app.can_access_company(p_company) and app.has_permission('ldm.create', p_company)) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  insert into public.tracking_points (tenant_id, company_id, entity_type, entity_id, latitude, longitude, city, uf, country, event_description, carrier_id)
  values (v_tenant, p_company, p_entity_type, p_entity_id, p_lat, p_lng, p_city, p_uf, coalesce(p_country,'BR'), p_event, p_carrier)
  returning * into tp;
  perform app.emit_event(p_company, 'tracking.point', 'ldm', jsonb_build_object('entity_type', p_entity_type, 'entity_id', p_entity_id, 'city', p_city, 'uf', p_uf));
  return tp;
end; $$;
grant execute on function public.add_tracking_point(uuid,text,uuid,numeric,numeric,text,text,text,uuid,text) to authenticated;

create or replace function public.ldm_dashboard(p_company uuid)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'volumes_total', (select count(*) from public.volumes where company_id=p_company and deleted_at is null),
    'volumes_by_status', (select coalesce(jsonb_object_agg(status, n),'{}'::jsonb) from (select status, count(*) n from public.volumes where company_id=p_company and deleted_at is null group by status) t),
    'occurrences_open', (select count(*) from public.occurrences where company_id=p_company and status in ('open','in_progress') and deleted_at is null),
    'occurrences_urgent', (select count(*) from public.occurrences where company_id=p_company and status in ('open','in_progress') and priority in ('high','urgent') and deleted_at is null),
    'tracking_points', (select count(*) from public.tracking_points where company_id=p_company and deleted_at is null)
  ) into v;
  return v;
end; $$;
grant execute on function public.ldm_dashboard(uuid) to authenticated;

-- última posição conhecida por entidade (alimenta o mapa)
create or replace function public.last_known_positions(p_company uuid, p_limit integer default 100)
returns table(entity_type text, entity_id uuid, latitude numeric, longitude numeric, city text, uf text, event_description text, occurred_at timestamptz)
language sql security definer set search_path = public, app stable as $$
  select distinct on (t.entity_type, t.entity_id)
    t.entity_type, t.entity_id, t.latitude, t.longitude, t.city, t.uf, t.event_description, t.occurred_at
  from public.tracking_points t
  where t.company_id=p_company and t.deleted_at is null and app.can_access_company(p_company)
  order by t.entity_type, t.entity_id, t.occurred_at desc
  limit p_limit;
$$;
grant execute on function public.last_known_positions(uuid,integer) to authenticated;

-- motor auto-descoberto pelo LAIOS
create or replace function public.occurrences_insights(p_company uuid)
returns integer language plpgsql security definer set search_path = public, app as $$
declare v_tenant uuid; v_c int := 0; v_urg int; v_old int;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  select tenant_id into v_tenant from public.companies where id=p_company;
  update public.logia_insights set status='dismissed' where company_id=p_company and status='new' and title like 'Ocorrências%' and deleted_at is null;

  select count(*) into v_urg from public.occurrences where company_id=p_company and status in ('open','in_progress') and priority in ('high','urgent') and deleted_at is null;
  if v_urg > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'critical', 'Ocorrências urgentes abertas', v_urg||' ocorrência(s) de alta prioridade sem resolução.', 'Acionar o responsável e resolver.', 88);
    v_c := v_c + 1;
  end if;
  select count(*) into v_old from public.occurrences where company_id=p_company and status in ('open','in_progress') and created_at < now() - interval '48 hours' and deleted_at is null;
  if v_old > 0 then
    insert into public.logia_insights (tenant_id, company_id, kind, severity, title, description, recommendation, confidence)
    values (v_tenant, p_company, 'bottleneck', 'warning', 'Ocorrências paradas há 48h+', v_old||' ocorrência(s) aberta(s) há mais de 48h.', 'Revisar SLA de tratamento de ocorrências.', 76);
    v_c := v_c + 1;
  end if;
  return v_c;
end; $$;
grant execute on function public.occurrences_insights(uuid) to authenticated;

notify pgrst, 'reload schema';
