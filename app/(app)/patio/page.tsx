import YMSWorkbench from "@/components/patio/YMSWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function PatioPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">YMS / Pátio</h1><VitrineBanner /></div>;
  }
  const [dash, gates, appts, weigh, load, cont, seals, perf] = await Promise.all([
    supabase.rpc("yard_dashboard", { p_company: company }),
    supabase.from("gate_events").select("*").eq("company_id", company).is("deleted_at", null).order("occurred_at", { ascending: false }).limit(300),
    supabase.from("dock_appointments").select("*").eq("company_id", company).is("deleted_at", null).order("scheduled_start", { ascending: false }).limit(300),
    supabase.from("weighings").select("*").eq("company_id", company).is("deleted_at", null).order("occurred_at", { ascending: false }).limit(300),
    supabase.from("loading_operations").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("containers").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("seals").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.rpc("yard_performance", { p_company: company }),
  ]);
  return <YMSWorkbench dash={dash.data ?? {}} gates={gates.data ?? []} appointments={appts.data ?? []} weighings={weigh.data ?? []} loadings={load.data ?? []} containers={cont.data ?? []} seals={seals.data ?? []} performance={(perf.data as any[]) ?? []} />;
}
