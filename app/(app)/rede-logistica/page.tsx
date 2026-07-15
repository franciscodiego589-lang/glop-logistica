import GLNMPWorkbench from "@/components/rede-logistica/GLNMPWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function RedeLogisticaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Rede Logística (GLNMP)</h1><VitrineBanner /></div>;
  }
  const [dash, coverage, balance, nodes, lanes, scenarios] = await Promise.all([
    supabase.rpc("glnmp_dashboard", { p_company: company }),
    supabase.rpc("network_coverage", { p_company: company }),
    supabase.rpc("balance_network", { p_company: company }),
    supabase.from("glnmp_nodes").select("*").eq("company_id", company).is("deleted_at", null).order("utilization_pct", { ascending: false, nullsFirst: false }).limit(300),
    supabase.from("glnmp_lanes").select("*").eq("company_id", company).is("deleted_at", null).order("code").limit(300),
    supabase.from("glnmp_scenarios").select("*").eq("company_id", company).is("deleted_at", null).order("run_at", { ascending: false }).limit(100),
  ]);
  return <GLNMPWorkbench dash={dash.data ?? {}} coverage={coverage.data ?? {}} balance={balance.data ?? {}}
    nodes={nodes.data ?? []} lanes={lanes.data ?? []} scenarios={scenarios.data ?? []} />;
}
