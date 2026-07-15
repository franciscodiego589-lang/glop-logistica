import CommandCenter from "@/components/control-tower/CommandCenter";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function ControlTowerPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Torre de Controle</h1><VitrineBanner /></div>;
  }
  const [noc, scores, alerts, incidents, insights] = await Promise.all([
    supabase.rpc("lct_command_center", { p_company: company }),
    supabase.from("operational_scores").select("area,score").eq("company_id", company).is("deleted_at", null).order("area"),
    supabase.from("alerts").select("id,title,severity,domain").eq("company_id", company).eq("status", "open").is("deleted_at", null).order("severity").limit(50),
    supabase.from("incidents").select("*").eq("company_id", company).not("status", "in", "(resolved,closed)").is("deleted_at", null).order("opened_at", { ascending: false }).limit(50),
    supabase.from("logia_insights").select("id,kind,severity,title,recommendation").eq("company_id", company).eq("status", "new").is("deleted_at", null).order("severity").limit(30),
  ]);
  return <CommandCenter noc={noc.data ?? {}} scores={scores.data ?? []} alerts={alerts.data ?? []} incidents={incidents.data ?? []} insights={insights.data ?? []} />;
}
