import CarrierHubWorkbench from "@/components/integracoes-transportadoras/CarrierHubWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function IntegracoesTransportadorasPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Integrações de Transportadoras</h1><VitrineBanner /></div>;
  }
  const [dash, connectors, operations, credentials, logs] = await Promise.all([
    supabase.rpc("connector_dashboard", { p_company: company }),
    supabase.from("carrier_connectors").select("*").eq("company_id", company).is("deleted_at", null).order("code").limit(200),
    supabase.from("connector_operations").select("*").eq("company_id", company).is("deleted_at", null).order("operation").limit(400),
    supabase.from("connector_credentials").select("id,connector_id,key_name,is_secret,valid_to").eq("company_id", company).is("deleted_at", null).limit(400),
    supabase.from("connector_logs").select("*").eq("company_id", company).is("deleted_at", null).order("requested_at", { ascending: false }).limit(200),
  ]);
  return <CarrierHubWorkbench dash={dash.data ?? {}} connectors={connectors.data ?? []} operations={operations.data ?? []}
    credentials={credentials.data ?? []} logs={logs.data ?? []} />;
}
