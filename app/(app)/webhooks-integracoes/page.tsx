import WebhooksIntegracoesWorkbench from "@/components/webhooks-integracoes/WebhooksIntegracoesWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function WebhooksIntegracoesPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Webhooks &amp; Integrações</h1><VitrineBanner /></div>;
  }
  const log = (t: string) => supabase.from(t).select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200);
  const [webhooks, entregas, envios, recebidos, tokens, apiLogs, webhookLogs] = await Promise.all([
    supabase.from("produtor_webhooks").select("*").eq("company_id", company).is("deleted_at", null).order("nome").limit(300),
    log("produtor_webhook_entregas"),
    log("sislogica_envios_log"),
    log("sislogica_webhook_recebidos"),
    supabase.from("sislogica_webhook_tokens").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    log("api_logs"),
    log("webhook_logs"),
  ]);
  return <WebhooksIntegracoesWorkbench
    webhooks={webhooks.data ?? []}
    entregas={entregas.data ?? []}
    envios={envios.data ?? []}
    recebidos={recebidos.data ?? []}
    tokens={tokens.data ?? []}
    apiLogs={apiLogs.data ?? []}
    webhookLogs={webhookLogs.data ?? []}
  />;
}
