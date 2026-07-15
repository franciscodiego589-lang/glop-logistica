import AuditWorkbench from "@/components/auditoria/AuditWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function AuditoriaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Auditoria Logística</h1><VitrineBanner /></div>;
  }
  const [dash, findings, opps, risks, carrierCosts] = await Promise.all([
    supabase.rpc("lais_dashboard", { p_company: company }),
    supabase.from("logistics_audit_findings").select("*").eq("company_id", company).eq("status", "open").is("deleted_at", null).order("severity").limit(200),
    supabase.from("savings_opportunities").select("*").eq("company_id", company).eq("status", "open").is("deleted_at", null).order("estimated_savings", { ascending: false, nullsFirst: false }).limit(200),
    supabase.from("logistics_risks").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.rpc("cost_by_carrier", { p_company: company }),
  ]);
  return <AuditWorkbench dash={dash.data ?? {}} findings={findings.data ?? []} opportunities={opps.data ?? []} risks={risks.data ?? []} carrierCosts={(carrierCosts.data as any[]) ?? []} />;
}
