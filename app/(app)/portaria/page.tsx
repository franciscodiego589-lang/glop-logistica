import YMSGateWorkbench from "@/components/portaria/YMSGateWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function PortariaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Portaria & Pátio (YMS)</h1><VitrineBanner /></div>;
  }
  const [dash, map, passes, queue, gates, docks, creds, visitors, containers] = await Promise.all([
    supabase.rpc("yard_ops_dashboard", { p_company: company }),
    supabase.rpc("yard_ops_map", { p_company: company }),
    supabase.from("gate_passes").select("*").eq("company_id", company).is("deleted_at", null).order("check_in_at", { ascending: false }).limit(200),
    supabase.from("yard_queue").select("*").eq("company_id", company).is("deleted_at", null).in("status", ["waiting", "called", "at_dock"]).order("position").limit(100),
    supabase.from("gates").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(50),
    supabase.from("docks").select("id,code,name,status").eq("company_id", company).is("deleted_at", null).order("code").limit(100),
    supabase.from("access_credentials").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
    supabase.from("yard_visitors").select("*").eq("company_id", company).is("deleted_at", null).order("check_in_at", { ascending: false }).limit(100),
    supabase.from("yard_containers").select("*").eq("company_id", company).is("deleted_at", null).order("entry_at", { ascending: false }).limit(100),
  ]);
  return <YMSGateWorkbench dash={dash.data ?? {}} map={map.data ?? {}} passes={passes.data ?? []} queue={queue.data ?? []}
    gates={gates.data ?? []} docks={docks.data ?? []} creds={creds.data ?? []} visitors={visitors.data ?? []} containers={containers.data ?? []} />;
}
