import CoproducaoWorkbench from "@/components/coproducao/CoproducaoWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function CoproducaoPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Coprodução &amp; Split</h1><VitrineBanner /></div>;
  }
  const [coprodutores, regras, vendas, repasses, config, appmax] = await Promise.all([
    supabase.from("coprodutores").select("*").eq("company_id", company).is("deleted_at", null).order("nome").limit(300),
    supabase.from("coproducao_regras").select("*").eq("company_id", company).is("deleted_at", null).order("prioridade").limit(300),
    supabase.from("coproducao_vendas").select("*").eq("company_id", company).is("deleted_at", null).order("data_venda", { ascending: false }).limit(200),
    supabase.from("coproducao_repasses").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("coproducao_configuracoes").select("*").eq("company_id", company).is("deleted_at", null).limit(1),
    // SEGURANÇA: nunca enviar segredos ao client. Exclui client_secret, oauth_access_token, oauth_refresh_token, oauth_state.
    supabase.from("appmax_split_config").select("id,tenant_id,company_id,environment,client_id,app_id,redirect_uri,logistics_recipient_id,logistics_recipient_name,logistics_recipient_document,recipient_status,active,oauth_token_expires_at,oauth_connected_at,created_at,updated_at").eq("company_id", company).is("deleted_at", null).limit(1),
  ]);
  return <CoproducaoWorkbench
    coprodutores={coprodutores.data ?? []}
    regras={regras.data ?? []}
    vendas={vendas.data ?? []}
    repasses={repasses.data ?? []}
    config={(config.data ?? [])[0] ?? null}
    appmax={(appmax.data ?? [])[0] ?? null}
  />;
}
