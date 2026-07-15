import ECMWorkbench from "@/components/documentos/ECMWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function DocumentosPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Documentos (ECM / GED)</h1><VitrineBanner /></div>;
  }
  const [dash, folders, documents, versions, signatures, policies] = await Promise.all([
    supabase.rpc("ecm_dashboard", { p_company: company }),
    supabase.from("document_folders").select("*").eq("company_id", company).is("deleted_at", null).order("path").limit(300),
    supabase.from("documents").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(500),
    supabase.from("document_versions").select("*").eq("company_id", company).is("deleted_at", null).order("version_no", { ascending: false }).limit(1000),
    supabase.from("document_signatures").select("*").eq("company_id", company).is("deleted_at", null).order("sign_order").limit(500),
    supabase.from("retention_policies").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
  ]);
  return <ECMWorkbench dash={dash.data ?? {}} folders={folders.data ?? []} documents={documents.data ?? []} versions={versions.data ?? []} signatures={signatures.data ?? []} policies={policies.data ?? []} />;
}
