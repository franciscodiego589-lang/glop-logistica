import QualityWorkbench from "@/components/qualidade/QualityWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

const TABLES = [
  "quality_inspections", "nonconformities", "capas", "quality_audits", "quality_risks",
  "quality_documents", "complaints", "quality_specifications", "inspection_plans",
  "trainings", "validations", "recalls", "certificates_of_analysis",
];

export default async function QualidadePage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">QMS — Qualidade</h1><VitrineBanner /></div>;
  }
  const [{ data: kpis }, { data: lots }, ...results] = await Promise.all([
    supabase.rpc("quality_dashboard", { p_company: company }),
    supabase.from("product_lots").select("id,lot_number,expiry_date,quality_status").eq("company_id", company).is("deleted_at", null).order("expiry_date").limit(300),
    ...TABLES.map((t) => supabase.from(t).select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300)),
  ]);
  const data: Record<string, any[]> = {};
  TABLES.forEach((t, i) => { data[t] = (results[i] as any).data ?? []; });
  return <QualityWorkbench kpis={kpis} data={data} lots={lots ?? []} />;
}
