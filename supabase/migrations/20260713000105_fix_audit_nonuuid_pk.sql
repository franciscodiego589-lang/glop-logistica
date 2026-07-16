-- ════════════════════════════════════════════════════════════════════════════
-- FIX: trigger de auditoria quebrava em tabelas com PK não-uuid (bigint/integer)
-- ════════════════════════════════════════════════════════════════════════════
-- app.tg_write_audit() fazia (id)::uuid direto. As tabelas importadas com id
-- bigint (prepostagens, nfe_emissoes, api_logs, webhook_logs, pedidos_xls,
-- monetizze_vendas, vendas_ml, braip_vendas_xls, produto_regras, etc.) falhavam
-- em QUALQUER insert/update/delete: "invalid input syntax for type uuid".
-- Correção: cast seguro — só preenche record_id quando o id é um UUID válido;
-- caso contrário null (o id real continua salvo em new_data/old_data). Nenhuma
-- perda de auditoria; tabelas de id uuid continuam idênticas.
-- ════════════════════════════════════════════════════════════════════════════

create or replace function app.tg_write_audit()
returns trigger language plpgsql security definer set search_path = public, app as $function$
declare
  v_old jsonb; v_new jsonb; v_changed text[]; v_action public.audit_action;
  v_record uuid; v_tenant uuid; v_company uuid; v_id_text text;
begin
  if tg_op = 'INSERT' then
    v_action := 'insert'; v_new := to_jsonb(new); v_old := null;
  elsif tg_op = 'UPDATE' then
    v_action := 'update'; v_new := to_jsonb(new); v_old := to_jsonb(old);
  else
    v_action := 'delete'; v_new := null; v_old := to_jsonb(old);
  end if;

  if tg_op = 'UPDATE' then
    select array_agg(k) into v_changed
    from jsonb_object_keys(v_new) k
    where (v_new -> k) is distinct from (v_old -> k)
      and k not in ('updated_at','version');
  end if;

  -- cast seguro: só uuid válido vira record_id; bigint/integer ficam null
  v_id_text := coalesce(v_new->>'id', v_old->>'id');
  v_record  := case when v_id_text ~ '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
                    then v_id_text::uuid else null end;
  v_tenant  := nullif(coalesce(v_new->>'tenant_id',  v_old->>'tenant_id'),  '')::uuid;
  v_company := nullif(coalesce(v_new->>'company_id', v_old->>'company_id'), '')::uuid;

  insert into public.audit_logs
    (tenant_id, company_id, table_name, record_id, action, actor_id, old_data, new_data, changed_fields)
  values
    (v_tenant, v_company, tg_table_name, v_record, v_action, auth.uid(), v_old, v_new, v_changed);
  return null;
end;
$function$;
