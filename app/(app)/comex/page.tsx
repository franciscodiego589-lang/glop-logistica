import GTMWorkbench from "@/components/gtm/GTMWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function ComexPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Comércio Exterior (GTM)</h1><VitrineBanner /></div>;
  }
  const [dash, processes, partners, locations, hs, docs, drawback] = await Promise.all([
    supabase.rpc("gtm_dashboard", { p_company: company }),
    supabase.from("trade_processes").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("trade_partners").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
    supabase.from("trade_locations").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
    supabase.from("hs_classifications").select("*").eq("company_id", company).is("deleted_at", null).order("ncm").limit(500),
    supabase.from("trade_documents").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("drawback_acts").select("*").eq("company_id", company).is("deleted_at", null).order("valid_to").limit(300),
  ]);
  return <GTMWorkbench dash={dash.data ?? {}} processes={processes.data ?? []} partners={partners.data ?? []} locations={locations.data ?? []} hs={hs.data ?? []} docs={docs.data ?? []} drawback={drawback.data ?? []} />;
}
