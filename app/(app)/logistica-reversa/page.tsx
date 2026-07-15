import RLMSWorkbench from "@/components/logistica-reversa/RLMSWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function LogisticaReversaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Logística Reversa (RLMS)</h1><VitrineBanner /></div>;
  }
  const [dash, returns, triage, dispositions, recalls, packaging] = await Promise.all([
    supabase.rpc("rl_dashboard", { p_company: company }),
    supabase.from("rl_returns").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("rl_triage").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(400),
    supabase.from("rl_dispositions").select("*").eq("company_id", company).is("deleted_at", null).order("done_at", { ascending: false }).limit(400),
    supabase.from("rl_recalls").select("*").eq("company_id", company).is("deleted_at", null).order("deadline").limit(100),
    supabase.from("returnable_packaging").select("*").eq("company_id", company).is("deleted_at", null).order("code").limit(300),
  ]);
  return <RLMSWorkbench dash={dash.data ?? {}} returns={returns.data ?? []} triage={triage.data ?? []}
    dispositions={dispositions.data ?? []} recalls={recalls.data ?? []} packaging={packaging.data ?? []} />;
}
