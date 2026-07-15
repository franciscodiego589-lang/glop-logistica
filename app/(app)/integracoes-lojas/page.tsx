import StoreHubWorkbench from "@/components/integracoes-lojas/StoreHubWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function IntegracoesLojasPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Integrações de Lojas</h1><VitrineBanner /></div>;
  }
  const [dash, connectors, orders, events, rules] = await Promise.all([
    supabase.rpc("store_hub_dashboard", { p_company: company }),
    supabase.from("store_connectors").select("id,code,name,platform,producer_ref,api_base_url,auth_type,environment,status,last_event_at,metadata").eq("company_id", company).is("deleted_at", null).order("code").limit(200),
    supabase.from("store_orders").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("store_webhook_events").select("*").eq("company_id", company).is("deleted_at", null).order("received_at", { ascending: false }).limit(200),
    supabase.from("store_plan_rules").select("*").eq("company_id", company).is("deleted_at", null).order("priority").limit(100),
  ]);
  return <StoreHubWorkbench dash={dash.data ?? {}} connectors={connectors.data ?? []} orders={orders.data ?? []}
    events={events.data ?? []} rules={rules.data ?? []} />;
}
