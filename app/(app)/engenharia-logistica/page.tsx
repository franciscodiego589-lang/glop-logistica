import NetworkDesign from "@/components/engenharia/NetworkDesign";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function EngenhariaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Engenharia Logística</h1><VitrineBanner /></div>;
  }
  const [dash, demand, capacity, scenarios] = await Promise.all([
    supabase.rpc("lpnd_dashboard", { p_company: company }),
    supabase.rpc("demand_heatmap", { p_company: company }),
    supabase.rpc("capacity_planning", { p_company: company }),
    supabase.from("network_scenarios").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
  ]);
  return <NetworkDesign dash={dash.data ?? {}} demand={(demand.data as any[]) ?? []} capacity={capacity.data ?? {}} scenarios={scenarios.data ?? []} />;
}
