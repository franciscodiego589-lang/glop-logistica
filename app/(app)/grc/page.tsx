import GRCWorkbench from "@/components/grc/GRCWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function GrcPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">GRC — Governança, Riscos & Compliance</h1><VitrineBanner /></div>;
  }
  const [dash, matrix, compliance, controls, sods, requirements, audits, policies,
    gov, kris, obligations, bodies, delegations, evidence] = await Promise.all([
    supabase.rpc("grc_dashboard", { p_company: company }),
    supabase.rpc("grc_risk_matrix", { p_company: company }),
    supabase.rpc("assess_compliance", { p_company: company, p_framework: null }),
    supabase.from("internal_controls").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(200),
    supabase.from("sod_rules").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("compliance_requirements").select("*").eq("company_id", company).is("deleted_at", null).order("framework").limit(300),
    supabase.from("grc_audits").select("*").eq("company_id", company).is("deleted_at", null).order("planned_date").limit(100),
    supabase.from("grc_policies").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.rpc("governance_overview", { p_company: company }),
    supabase.rpc("grc_kri_panel", { p_company: company }),
    supabase.rpc("grc_obligations_calendar", { p_company: company, p_days: 180 }),
    supabase.from("governance_bodies").select("*").eq("company_id", company).is("deleted_at", null).order("body_type").limit(100),
    supabase.from("authority_delegations").select("*").eq("company_id", company).is("deleted_at", null).order("valid_to").limit(100),
    supabase.from("grc_evidence").select("*").eq("company_id", company).is("deleted_at", null).order("collected_at", { ascending: false }).limit(100),
  ]);
  return <GRCWorkbench dash={dash.data ?? {}} matrix={matrix.data ?? []} controls={controls.data ?? []} sods={sods.data ?? []}
    compliance={compliance.data ?? []} requirements={requirements.data ?? []} audits={audits.data ?? []} policies={policies.data ?? []}
    gov={gov.data ?? {}} kris={kris.data ?? []} obligations={obligations.data ?? []} bodies={bodies.data ?? []}
    delegations={delegations.data ?? []} evidence={evidence.data ?? []} />;
}
