import LDTPWorkbench from "@/components/gemeo-digital/LDTPWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function GemeoDigitalPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Gêmeo Digital (LDTP)</h1><VitrineBanner /></div>;
  }
  const [dash, objects, bottlenecks, simulations, snapshots] = await Promise.all([
    supabase.rpc("ldtp_dashboard", { p_company: company }),
    supabase.from("twin_objects").select("*").eq("company_id", company).is("deleted_at", null).order("utilization_pct", { ascending: false, nullsFirst: false }).limit(300),
    supabase.from("twin_bottlenecks").select("*").eq("company_id", company).is("deleted_at", null).order("detected_at", { ascending: false }).limit(200),
    supabase.from("twin_simulations").select("*").eq("company_id", company).is("deleted_at", null).order("run_at", { ascending: false }).limit(100),
    supabase.from("twin_snapshots").select("*").eq("company_id", company).is("deleted_at", null).order("captured_at", { ascending: false }).limit(60),
  ]);
  return <LDTPWorkbench dash={dash.data ?? {}} objects={objects.data ?? []} bottlenecks={bottlenecks.data ?? []}
    simulations={simulations.data ?? []} snapshots={snapshots.data ?? []} />;
}
