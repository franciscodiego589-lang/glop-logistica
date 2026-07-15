import GLCTWorkbench from "@/components/torre-controle/GLCTWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function TorreControlePage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Torre de Controle (GLCT)</h1><VitrineBanner /></div>;
  }
  const [sit, dash, incidents, events, playbooks, actions] = await Promise.all([
    supabase.rpc("glct_situational", { p_company: company }),
    supabase.rpc("glct_dashboard", { p_company: company }),
    supabase.from("glct_incidents").select("*").eq("company_id", company).is("deleted_at", null).order("opened_at", { ascending: false }).limit(200),
    supabase.from("glct_events").select("*").eq("company_id", company).is("deleted_at", null).order("cluster_size", { ascending: false }).limit(100),
    supabase.from("glct_playbooks").select("*").eq("company_id", company).is("deleted_at", null).order("code").limit(100),
    supabase.from("glct_actions").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
  ]);
  return <GLCTWorkbench sit={sit.data ?? {}} dash={dash.data ?? {}} incidents={incidents.data ?? []} events={events.data ?? []}
    playbooks={playbooks.data ?? []} actions={actions.data ?? []} />;
}
