import TaxWorkbench from "@/components/fiscal/TaxWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function FiscalPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Fiscal & Tributário</h1><VitrineBanner /></div>;
  }
  const [dash, rules, natures, docs, assessments, obligations] = await Promise.all([
    supabase.rpc("fiscal_dashboard", { p_company: company }),
    supabase.from("tax_rules").select("*").eq("company_id", company).is("deleted_at", null).order("tax_kind").limit(500),
    supabase.from("operation_natures").select("*").eq("company_id", company).is("deleted_at", null).order("code").limit(300),
    supabase.from("fiscal_documents").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("tax_assessments").select("*").eq("company_id", company).is("deleted_at", null).order("fiscal_year", { ascending: false }).order("fiscal_month", { ascending: false }).limit(100),
    supabase.from("fiscal_obligations").select("*").eq("company_id", company).is("deleted_at", null).order("due_date", { ascending: false }).limit(100),
  ]);
  return <TaxWorkbench dash={dash.data ?? {}} rules={rules.data ?? []} natures={natures.data ?? []} docs={docs.data ?? []} assessments={assessments.data ?? []} obligations={obligations.data ?? []} />;
}
