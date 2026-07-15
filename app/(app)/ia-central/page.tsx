import LAIOSWorkbench from "@/components/laios/LAIOSWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function IACentralPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">LAIOS — Cérebro do ERP</h1><VitrineBanner /></div>;
  }
  const [dash, brief, decisions, agents, knowledge, runs] = await Promise.all([
    supabase.rpc("laios_dashboard", { p_company: company }),
    supabase.rpc("laios_executive_brief", { p_company: company }),
    supabase.from("ai_decisions").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
    supabase.from("ai_agents").select("*").eq("company_id", company).is("deleted_at", null).order("agent_key").limit(100),
    supabase.from("ai_knowledge").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("ai_runs").select("*").eq("company_id", company).is("deleted_at", null).order("started_at", { ascending: false }).limit(50),
  ]);
  return <LAIOSWorkbench dash={dash.data ?? {}} brief={brief.data ?? {}} decisions={decisions.data ?? []} agents={agents.data ?? []} knowledge={knowledge.data ?? []} runs={runs.data ?? []} />;
}
