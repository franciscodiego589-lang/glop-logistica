import ECCWorkbench from "@/components/comando/ECCWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function ComandoPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Enterprise Command Center</h1><VitrineBanner /></div>;
  }
  const [overview, dash, alerts, crises, updates] = await Promise.all([
    supabase.rpc("command_overview", { p_company: company }),
    supabase.rpc("ecc_dashboard", { p_company: company }),
    supabase.from("command_alerts").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("crisis_rooms").select("*").eq("company_id", company).is("deleted_at", null).order("opened_at", { ascending: false }).limit(100),
    supabase.from("crisis_updates").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: true }).limit(500),
  ]);
  return <ECCWorkbench overview={overview.data ?? {}} dash={dash.data ?? {}} alerts={alerts.data ?? []} crises={crises.data ?? []} updates={updates.data ?? []} />;
}
