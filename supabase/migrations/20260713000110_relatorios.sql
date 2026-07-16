-- ════════════════════════════════════════════════════════════════════════════
-- CENTRAL DE RELATÓRIOS — RPCs auto-descritivos (KPIs + seções) por domínio.
-- Contrato de saída: { titulo, periodo, kpis:[{label,valor,fmt,icon,tone}],
--   secoes:[{titulo, tipo:'bars', itens:[{label,n,valor,fmt}]}
--            | {titulo, tipo:'tabela', colunas:[{key,label,fmt}], linhas:[...]}] }
-- Um renderizador genérico no front exibe qualquer relatório. KPIs somados no banco.
-- ════════════════════════════════════════════════════════════════════════════
-- filtro de venda "realizada" (exclui cancelado/devolvido/extraviado/bloqueado)
-- é aplicado inline nos RPCs de vendas.

-- ── VENDAS ──────────────────────────────────────────────────────────────────
create or replace function public.rel_vendas(p_company uuid, p_days int default 30)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int;
  v_receita numeric; v_ped int; v_ticket numeric; v_entr int; v_canc int; v_compradores int;
  s_canal jsonb; s_uf jsonb; s_prod jsonb; s_status jsonb; s_serie jsonb; t_compradores jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,30),1); v_desde := now() - make_interval(days => d);

  select coalesce(sum(value) filter (where state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')),0),
         count(*) filter (where state not in ('cancelado','devolvido','extraviado','bloqueado_reembolso')),
         count(*) filter (where state='entregue'), count(*) filter (where state='cancelado'),
         count(distinct buyer_doc)
    into v_receita, v_ped, v_entr, v_canc, v_compradores
  from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde;
  v_ticket := case when v_ped>0 then round(v_receita/v_ped,2) else 0 end;

  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(platform,'—'),'n',n,'valor',r,'fmt','money') order by r desc),'[]') into s_canal
    from (select platform, count(*) n, coalesce(sum(value),0) r from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by r desc limit 12) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(dest_uf,'??'),'n',n,'valor',r,'fmt','money') order by r desc),'[]') into s_uf
    from (select dest_uf, count(*) n, coalesce(sum(value),0) r from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by r desc limit 15) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(product_name,'—'),'n',n,'valor',r,'fmt','money') order by n desc),'[]') into s_prod
    from (select product_name, count(*) n, coalesce(sum(value),0) r from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc limit 12) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',state,'n',n,'fmt','int') order by n desc),'[]') into s_status
    from (select state, count(*) n from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',to_char(dia,'DD/MM'),'n',n,'valor',r,'fmt','money') order by dia),'[]') into s_serie
    from (select created_at::date dia, count(*) n, coalesce(sum(value),0) r from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by 1) x;
  select coalesce(jsonb_agg(jsonb_build_object('comprador',coalesce(buyer_name,'—'),'pedidos',n,'total',r) order by r desc),'[]') into t_compradores
    from (select buyer_name, count(*) n, coalesce(sum(value),0) r from public.store_orders where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by r desc limit 20) x;

  return jsonb_build_object('titulo','Relatório de Vendas','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Receita','valor',v_receita,'fmt','money','icon','💰','tone','success'),
      jsonb_build_object('label','Pedidos','valor',v_ped,'fmt','int','icon','🧾','tone','accent'),
      jsonb_build_object('label','Ticket médio','valor',v_ticket,'fmt','money','icon','🎯','tone','neutral'),
      jsonb_build_object('label','Entregues','valor',v_entr,'fmt','int','icon','✅','tone','success'),
      jsonb_build_object('label','Cancelados','valor',v_canc,'fmt','int','icon','🚫','tone','danger'),
      jsonb_build_object('label','Compradores','valor',v_compradores,'fmt','int','icon','👥','tone','neutral')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Receita por canal','tipo','bars','itens',s_canal),
      jsonb_build_object('titulo','Receita por estado (UF)','tipo','bars','itens',s_uf),
      jsonb_build_object('titulo','Top produtos','tipo','bars','itens',s_prod),
      jsonb_build_object('titulo','Pedidos por status','tipo','bars','itens',s_status),
      jsonb_build_object('titulo','Série diária','tipo','bars','itens',s_serie),
      jsonb_build_object('titulo','Top compradores','tipo','tabela','colunas',
        jsonb_build_array(jsonb_build_object('key','comprador','label','Comprador','fmt','text'),
                          jsonb_build_object('key','pedidos','label','Pedidos','fmt','int'),
                          jsonb_build_object('key','total','label','Total','fmt','money')),'linhas',t_compradores)));
end $$;
grant execute on function public.rel_vendas(uuid,int) to authenticated;

-- ── OPERAÇÃO / PEDIDOS ──────────────────────────────────────────────────────
create or replace function public.rel_operacao(p_company uuid, p_days int default 30)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int; v_total int; v_backlog int; v_semplano int; v_endinv int; v_bloq int; v_transicoes int;
  s_funil jsonb; s_evt jsonb; s_serie_evt jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,30),1); v_desde := now() - make_interval(days => d);

  select count(*), count(*) filter (where state='recebido'),
         count(*) filter (where state='sem_plano'), count(*) filter (where state='endereco_invalido'),
         count(*) filter (where state='bloqueado_reembolso')
    into v_total, v_backlog, v_semplano, v_endinv, v_bloq
  from public.store_orders where company_id=p_company and deleted_at is null;

  select count(*) into v_transicoes from public.store_order_events where company_id=p_company and deleted_at is null and occurred_at>=v_desde;

  select coalesce(jsonb_agg(jsonb_build_object('label',state,'n',n,'fmt','int') order by n desc),'[]') into s_funil
    from (select state, count(*) n from public.store_orders where company_id=p_company and deleted_at is null group by 1 order by n desc) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(to_state,'—'),'n',n,'fmt','int') order by n desc),'[]') into s_evt
    from (select to_state, count(*) n from public.store_order_events where company_id=p_company and deleted_at is null and occurred_at>=v_desde group by 1 order by n desc limit 15) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',to_char(dia,'DD/MM'),'n',n,'fmt','int') order by dia),'[]') into s_serie_evt
    from (select occurred_at::date dia, count(*) n from public.store_order_events where company_id=p_company and deleted_at is null and occurred_at>=v_desde group by 1 order by 1) x;

  return jsonb_build_object('titulo','Relatório Operacional (Pedidos)','periodo','estado atual · eventos dos últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Pedidos (total)','valor',v_total,'fmt','int','icon','📦','tone','accent'),
      jsonb_build_object('label','A processar','valor',v_backlog,'fmt','int','icon','⏳','tone','warning'),
      jsonb_build_object('label','Sem plano','valor',v_semplano,'fmt','int','icon','⚠️','tone','warning'),
      jsonb_build_object('label','Endereço inválido','valor',v_endinv,'fmt','int','icon','📍','tone','danger'),
      jsonb_build_object('label','Bloqueados','valor',v_bloq,'fmt','int','icon','🚫','tone','danger'),
      jsonb_build_object('label','Transições','valor',v_transicoes,'fmt','int','icon','🔁','tone','neutral')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Funil por status (todos os pedidos)','tipo','bars','itens',s_funil),
      jsonb_build_object('titulo','Movimentações por etapa (período)','tipo','bars','itens',s_evt),
      jsonb_build_object('titulo','Movimentações por dia','tipo','bars','itens',s_serie_evt)));
end $$;
grant execute on function public.rel_operacao(uuid,int) to authenticated;

-- ── INTEGRAÇÕES & WEBHOOKS ──────────────────────────────────────────────────
create or replace function public.rel_integracoes(p_company uuid, p_days int default 30)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int; v_total int; v_proc int; v_pend int; v_invalid int; v_conn int;
  s_plat jsonb; s_tipo jsonb; s_serie jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,30),1); v_desde := now() - make_interval(days => d);

  select count(*), count(*) filter (where processed_at is not null), count(*) filter (where processed_at is null),
         count(*) filter (where signature_valid is false)
    into v_total, v_proc, v_pend, v_invalid
  from public.store_webhook_events where company_id=p_company and deleted_at is null and received_at>=v_desde;
  select count(*) into v_conn from public.store_connectors where company_id=p_company and deleted_at is null;

  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(platform,'—'),'n',n,'fmt','int') order by n desc),'[]') into s_plat
    from (select platform, count(*) n from public.store_webhook_events where company_id=p_company and deleted_at is null and received_at>=v_desde group by 1 order by n desc limit 12) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(event_type,'—'),'n',n,'fmt','int') order by n desc),'[]') into s_tipo
    from (select event_type, count(*) n from public.store_webhook_events where company_id=p_company and deleted_at is null and received_at>=v_desde group by 1 order by n desc limit 15) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',to_char(dia,'DD/MM'),'n',n,'fmt','int') order by dia),'[]') into s_serie
    from (select received_at::date dia, count(*) n from public.store_webhook_events where company_id=p_company and deleted_at is null and received_at>=v_desde group by 1 order by 1) x;

  return jsonb_build_object('titulo','Relatório de Integrações & Webhooks','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Eventos','valor',v_total,'fmt','int','icon','🔗','tone','accent'),
      jsonb_build_object('label','Processados','valor',v_proc,'fmt','int','icon','✅','tone','success'),
      jsonb_build_object('label','Pendentes','valor',v_pend,'fmt','int','icon','⏳','tone','warning'),
      jsonb_build_object('label','Assinatura inválida','valor',v_invalid,'fmt','int','icon','⚠️','tone','danger'),
      jsonb_build_object('label','Conectores','valor',v_conn,'fmt','int','icon','🧩','tone','neutral')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Eventos por plataforma','tipo','bars','itens',s_plat),
      jsonb_build_object('titulo','Eventos por tipo','tipo','bars','itens',s_tipo),
      jsonb_build_object('titulo','Eventos por dia','tipo','bars','itens',s_serie)));
end $$;
grant execute on function public.rel_integracoes(uuid,int) to authenticated;

-- ── AUDITORIA & GOVERNANÇA ──────────────────────────────────────────────────
create or replace function public.rel_auditoria(p_company uuid, p_days int default 30)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int; v_total int; v_ins int; v_upd int; v_del int;
  s_tabela jsonb; s_acao jsonb; s_serie jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,30),1); v_desde := now() - make_interval(days => d);

  select count(*), count(*) filter (where action='INSERT'), count(*) filter (where action='UPDATE'), count(*) filter (where action='DELETE')
    into v_total, v_ins, v_upd, v_del
  from public.audit_logs where company_id=p_company and occurred_at>=v_desde;

  select coalesce(jsonb_agg(jsonb_build_object('label',table_name,'n',n,'fmt','int') order by n desc),'[]') into s_tabela
    from (select table_name, count(*) n from public.audit_logs where company_id=p_company and occurred_at>=v_desde group by 1 order by n desc limit 15) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',action,'n',n,'fmt','int') order by n desc),'[]') into s_acao
    from (select action, count(*) n from public.audit_logs where company_id=p_company and occurred_at>=v_desde group by 1 order by n desc) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',to_char(dia,'DD/MM'),'n',n,'fmt','int') order by dia),'[]') into s_serie
    from (select occurred_at::date dia, count(*) n from public.audit_logs where company_id=p_company and occurred_at>=v_desde group by 1 order by 1) x;

  return jsonb_build_object('titulo','Relatório de Auditoria & Governança','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Eventos de auditoria','valor',v_total,'fmt','int','icon','🧾','tone','accent'),
      jsonb_build_object('label','Inserções','valor',v_ins,'fmt','int','icon','➕','tone','success'),
      jsonb_build_object('label','Atualizações','valor',v_upd,'fmt','int','icon','✏️','tone','warning'),
      jsonb_build_object('label','Exclusões','valor',v_del,'fmt','int','icon','🗑️','tone','danger')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Ações por tabela','tipo','bars','itens',s_tabela),
      jsonb_build_object('titulo','Ações por tipo','tipo','bars','itens',s_acao),
      jsonb_build_object('titulo','Ações por dia','tipo','bars','itens',s_serie)));
end $$;
grant execute on function public.rel_auditoria(uuid,int) to authenticated;

-- ── INTELIGÊNCIA (IA / LOGIA) ───────────────────────────────────────────────
create or replace function public.rel_ia(p_company uuid, p_days int default 90)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int; v_ins int; v_dec int; v_runs int; v_econ numeric;
  s_kind jsonb; s_sev jsonb; s_cat jsonb; s_risk jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,90),1); v_desde := now() - make_interval(days => d);

  select count(*) into v_ins from public.logia_insights where company_id=p_company and deleted_at is null and created_at>=v_desde;
  select count(*), coalesce(sum(estimated_saving),0) into v_dec, v_econ from public.ai_decisions where company_id=p_company and deleted_at is null and created_at>=v_desde;
  select count(*) into v_runs from public.ai_runs where company_id=p_company and deleted_at is null and started_at>=v_desde;

  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(kind,'—'),'n',n,'fmt','int') order by n desc),'[]') into s_kind
    from (select kind, count(*) n from public.logia_insights where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc limit 12) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(severity,'—'),'n',n,'fmt','int') order by n desc),'[]') into s_sev
    from (select severity, count(*) n from public.logia_insights where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(category,'—'),'n',n,'fmt','int') order by n desc),'[]') into s_cat
    from (select category, count(*) n from public.ai_decisions where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc limit 12) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(risk_level,'—'),'n',n,'fmt','int') order by n desc),'[]') into s_risk
    from (select risk_level, count(*) n from public.ai_decisions where company_id=p_company and deleted_at is null and created_at>=v_desde group by 1 order by n desc) x;

  return jsonb_build_object('titulo','Relatório de Inteligência (IA / LOGIA)','periodo','últimos '||d||' dias',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Insights','valor',v_ins,'fmt','int','icon','✧','tone','accent'),
      jsonb_build_object('label','Decisões','valor',v_dec,'fmt','int','icon','✦','tone','neutral'),
      jsonb_build_object('label','Execuções','valor',v_runs,'fmt','int','icon','⚙️','tone','neutral'),
      jsonb_build_object('label','Economia estimada','valor',v_econ,'fmt','money','icon','💡','tone','success')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Insights por tipo','tipo','bars','itens',s_kind),
      jsonb_build_object('titulo','Insights por severidade','tipo','bars','itens',s_sev),
      jsonb_build_object('titulo','Decisões por categoria','tipo','bars','itens',s_cat),
      jsonb_build_object('titulo','Decisões por risco','tipo','bars','itens',s_risk)));
end $$;
grant execute on function public.rel_ia(uuid,int) to authenticated;

-- ── COPRODUÇÃO & COMISSÕES ──────────────────────────────────────────────────
create or replace function public.rel_coproducao(p_company uuid, p_days int default 3650)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_com numeric; v_pend numeric; v_vendas int; v_repasses int; v_liq numeric;
  s_copro jsonb; s_status jsonb; s_repasse jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;

  select coalesce(sum(valor_comissao),0), coalesce(sum(valor_comissao) filter (where status_repasse='pendente'),0), count(*)
    into v_com, v_pend, v_vendas
  from public.coproducao_vendas where company_id=p_company and deleted_at is null;
  select count(*), coalesce(sum(total_liquido_repassar),0) into v_repasses, v_liq
  from public.coproducao_repasses where company_id=p_company and deleted_at is null;

  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(c.nome,'—'),'n',x.n,'valor',x.com,'fmt','money') order by x.com desc),'[]') into s_copro
    from (select coprodutor_id, count(*) n, coalesce(sum(valor_comissao),0) com from public.coproducao_vendas where company_id=p_company and deleted_at is null group by 1) x
    left join public.coprodutores c on c.id=x.coprodutor_id;
  select coalesce(jsonb_agg(jsonb_build_object('label',status_repasse,'n',n,'valor',com,'fmt','money') order by n desc),'[]') into s_status
    from (select status_repasse, count(*) n, coalesce(sum(valor_comissao),0) com from public.coproducao_vendas where company_id=p_company and deleted_at is null group by 1 order by n desc) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',status,'n',n,'valor',liq,'fmt','money') order by n desc),'[]') into s_repasse
    from (select status, count(*) n, coalesce(sum(total_liquido_repassar),0) liq from public.coproducao_repasses where company_id=p_company and deleted_at is null group by 1 order by n desc) x;

  return jsonb_build_object('titulo','Relatório de Coprodução & Comissões','periodo','todo o período',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Comissão total','valor',v_com,'fmt','money','icon','🤝','tone','accent'),
      jsonb_build_object('label','A repassar (pendente)','valor',v_pend,'fmt','money','icon','💸','tone','warning'),
      jsonb_build_object('label','Vendas apuradas','valor',v_vendas,'fmt','int','icon','🧾','tone','neutral'),
      jsonb_build_object('label','Lotes de repasse','valor',v_repasses,'fmt','int','icon','📋','tone','neutral'),
      jsonb_build_object('label','Líquido em repasses','valor',v_liq,'fmt','money','icon','🏦','tone','success')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Comissão por coprodutor','tipo','bars','itens',s_copro),
      jsonb_build_object('titulo','Comissões por status de repasse','tipo','bars','itens',s_status),
      jsonb_build_object('titulo','Repasses por status','tipo','bars','itens',s_repasse)));
end $$;
grant execute on function public.rel_coproducao(uuid,int) to authenticated;

-- ── LOGÍSTICA & ENVIOS ──────────────────────────────────────────────────────
create or replace function public.rel_logistica(p_company uuid, p_days int default 90)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int; v_envios int; v_prep int; v_track int; v_pago numeric;
  s_status jsonb; s_uf jsonb; s_prep jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,90),1); v_desde := now() - make_interval(days => d);

  select count(*), coalesce(sum(valor_pago),0) into v_envios, v_pago from public.envios where company_id=p_company and deleted_at is null;
  select count(*) into v_prep from public.prepostagens where company_id=p_company and deleted_at is null;
  select count(*) into v_track from public.tracking_events where company_id=p_company and deleted_at is null;

  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(ultimo_status,'—'),'n',n,'fmt','int') order by n desc),'[]') into s_status
    from (select ultimo_status, count(*) n from public.envios where company_id=p_company and deleted_at is null group by 1 order by n desc limit 15) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(uf,'??'),'n',n,'fmt','int') order by n desc),'[]') into s_uf
    from (select uf, count(*) n from public.envios where company_id=p_company and deleted_at is null group by 1 order by n desc limit 15) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(status,'—'),'n',n,'fmt','int') order by n desc),'[]') into s_prep
    from (select status, count(*) n from public.prepostagens where company_id=p_company and deleted_at is null group by 1 order by n desc) x;

  return jsonb_build_object('titulo','Relatório de Logística & Envios','periodo','todo o período',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','Envios','valor',v_envios,'fmt','int','icon','📦','tone','accent'),
      jsonb_build_object('label','Prepostagens','valor',v_prep,'fmt','int','icon','📮','tone','neutral'),
      jsonb_build_object('label','Eventos de rastreio','valor',v_track,'fmt','int','icon','🛰','tone','neutral'),
      jsonb_build_object('label','Frete pago','valor',v_pago,'fmt','money','icon','💰','tone','warning')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','Envios por status','tipo','bars','itens',s_status),
      jsonb_build_object('titulo','Envios por UF','tipo','bars','itens',s_uf),
      jsonb_build_object('titulo','Prepostagens por status','tipo','bars','itens',s_prep)));
end $$;
grant execute on function public.rel_logistica(uuid,int) to authenticated;

-- ── FISCAL & NF-e ───────────────────────────────────────────────────────────
create or replace function public.rel_fiscal(p_company uuid, p_days int default 90)
returns jsonb language plpgsql security definer set search_path = public, app stable as $$
declare v_desde timestamptz; d int; v_total int; v_emit int; v_erro int; v_valor numeric;
  s_status jsonb; s_serie jsonb;
begin
  if not app.can_access_company(p_company) then raise exception 'forbidden'; end if;
  d := greatest(coalesce(p_days,90),1); v_desde := now() - make_interval(days => d);

  select count(*), count(*) filter (where status in ('emitida','autorizada','emitido')), count(*) filter (where erro is not null), coalesce(sum(valor),0)
    into v_total, v_emit, v_erro, v_valor
  from public.nfe_emissoes where company_id=p_company and deleted_at is null;

  select coalesce(jsonb_agg(jsonb_build_object('label',coalesce(status,'—'),'n',n,'valor',v,'fmt','money') order by n desc),'[]') into s_status
    from (select status, count(*) n, coalesce(sum(valor),0) v from public.nfe_emissoes where company_id=p_company and deleted_at is null group by 1 order by n desc) x;
  select coalesce(jsonb_agg(jsonb_build_object('label',to_char(dia,'DD/MM'),'n',n,'fmt','int') order by dia),'[]') into s_serie
    from (select coalesce(emitida_at,created_at)::date dia, count(*) n from public.nfe_emissoes where company_id=p_company and deleted_at is null group by 1 order by 1) x;

  return jsonb_build_object('titulo','Relatório Fiscal & NF-e','periodo','todo o período',
    'kpis', jsonb_build_array(
      jsonb_build_object('label','NF-e (total)','valor',v_total,'fmt','int','icon','🧾','tone','accent'),
      jsonb_build_object('label','Emitidas','valor',v_emit,'fmt','int','icon','✅','tone','success'),
      jsonb_build_object('label','Com erro','valor',v_erro,'fmt','int','icon','⚠️','tone','danger'),
      jsonb_build_object('label','Valor total','valor',v_valor,'fmt','money','icon','💰','tone','neutral')),
    'secoes', jsonb_build_array(
      jsonb_build_object('titulo','NF-e por status','tipo','bars','itens',s_status),
      jsonb_build_object('titulo','Emissões por dia','tipo','bars','itens',s_serie)));
end $$;
grant execute on function public.rel_fiscal(uuid,int) to authenticated;
