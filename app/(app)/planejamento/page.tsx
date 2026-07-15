import FPNAWorkbench from "@/components/planejamento/FPNAWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function PlanejamentoPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Planejamento & Performance (FP&A)</h1><VitrineBanner /></div>;
  }
  const year = new Date().getFullYear();
  const [dash, scenarios, budgets, goals, investments, bva] = await Promise.all([
    supabase.rpc("fpna_dashboard", { p_company: company }),
    supabase.from("planning_scenarios").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("budgets").select("*").eq("company_id", company).is("deleted_at", null).order("fiscal_year", { ascending: false }).limit(100),
    supabase.from("goals").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("investment_cases").select("*").eq("company_id", company).is("deleted_at", null).order("npv", { ascending: false }).limit(100),
    supabase.rpc("budget_vs_actual", { p_company: company, p_year: year }),
  ]);
  return <FPNAWorkbench dash={dash.data ?? {}} scenarios={scenarios.data ?? []} budgets={budgets.data ?? []} goals={goals.data ?? []} investments={investments.data ?? []} bva={bva.data ?? []} />;
}
