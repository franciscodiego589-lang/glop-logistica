import EIPWorkbench from "@/components/integracoes/EIPWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function IntegracoesPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Integrações (iPaaS)</h1><VitrineBanner /></div>;
  }
  const [dash, apis, connectors, webhooks, events, messages, flows, apiKeys] = await Promise.all([
    supabase.rpc("eip_dashboard", { p_company: company }),
    supabase.from("api_endpoints").select("*").eq("company_id", company).is("deleted_at", null).order("category").limit(200),
    supabase.from("integration_connectors").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("webhooks").select("id,name,event_type,target_url,enabled,max_attempts,success_count,failure_count,metadata,created_at").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
    supabase.from("event_bus").select("*").eq("company_id", company).is("deleted_at", null).order("occurred_at", { ascending: false }).limit(50),
    supabase.from("integration_messages").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("integration_flows").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("api_keys").select("id,name,key_prefix,scopes,rate_limit,enabled,expires_at,last_used_at,metadata,created_at").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
  ]);
  return <EIPWorkbench dash={dash.data ?? {}} apis={apis.data ?? []} connectors={connectors.data ?? []} webhooks={webhooks.data ?? []}
    events={events.data ?? []} messages={messages.data ?? []} flows={flows.data ?? []} apiKeys={apiKeys.data ?? []} />;
}
