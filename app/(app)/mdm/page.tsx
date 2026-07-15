import MDMWorkbench from "@/components/mdm/MDMWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function MdmPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Master Data Management (MDM)</h1><VitrineBanner /></div>;
  }
  const [dash, domains, duplicates, changes, lineage, glossary] = await Promise.all([
    supabase.rpc("mdm_dashboard", { p_company: company }),
    supabase.from("mdm_domains").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("mdm_duplicates").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("mdm_change_requests").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("data_lineage").select("*").eq("company_id", company).is("deleted_at", null).order("source_domain").limit(200),
    supabase.from("mdm_glossary").select("*").eq("company_id", company).is("deleted_at", null).order("term").limit(200),
  ]);
  return <MDMWorkbench dash={dash.data ?? {}} domains={domains.data ?? []} duplicates={duplicates.data ?? []} changes={changes.data ?? []} lineage={lineage.data ?? []} glossary={glossary.data ?? []} />;
}
