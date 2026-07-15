import CMSWorkbench from "@/components/aduana/CMSWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function AduanaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Aduana (CMS)</h1><VitrineBanner /></div>;
  }
  const [dash, processes, docs, inspections, zones, events] = await Promise.all([
    supabase.rpc("cms_dashboard", { p_company: company }),
    supabase.from("customs_processes").select("*").eq("company_id", company).is("deleted_at", null).order("registered_at", { ascending: false }).limit(200),
    supabase.from("customs_documents").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(400),
    supabase.from("customs_inspections").select("*").eq("company_id", company).is("deleted_at", null).order("done_at", { ascending: false }).limit(200),
    supabase.from("customs_zones").select("*").eq("company_id", company).is("deleted_at", null).order("zone_type").limit(100),
    supabase.from("customs_events").select("*").eq("company_id", company).is("deleted_at", null).order("event_at", { ascending: false }).limit(400),
  ]);
  return <CMSWorkbench dash={dash.data ?? {}} processes={processes.data ?? []} docs={docs.data ?? []}
    inspections={inspections.data ?? []} zones={zones.data ?? []} events={events.data ?? []} />;
}
