import BPMWorkbench from "@/components/processos/BPMWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function ProcessosPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">BPM & Workflows</h1><VitrineBanner /></div>;
  }
  const [dash, definitions, instances, tasks, events, rules] = await Promise.all([
    supabase.rpc("bpm_dashboard", { p_company: company }),
    supabase.from("process_definitions").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(200),
    supabase.from("process_instances").select("*").eq("company_id", company).is("deleted_at", null).order("started_at", { ascending: false }).limit(300),
    supabase.from("process_tasks").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(500),
    supabase.from("process_events").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: true }).limit(1000),
    supabase.from("business_rules").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
  ]);
  return <BPMWorkbench dash={dash.data ?? {}} definitions={definitions.data ?? []} instances={instances.data ?? []} tasks={tasks.data ?? []} events={events.data ?? []} rules={rules.data ?? []} />;
}
