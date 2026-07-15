import GLWorkbench from "@/components/contabilidade/GLWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function ContabilidadePage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Contabilidade Geral (GL)</h1><VitrineBanner /></div>;
  }
  const now = new Date();
  const monthStart = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-01`;
  const today = now.toISOString().slice(0, 10);

  const [dash, accounts, entries, rules, periods, trial, dre, balance] = await Promise.all([
    supabase.rpc("gl_dashboard", { p_company: company }),
    supabase.from("chart_of_accounts").select("*").eq("company_id", company).is("deleted_at", null).order("code").limit(500),
    supabase.from("journal_entries").select("*").eq("company_id", company).is("deleted_at", null).order("entry_number", { ascending: false }).limit(200),
    supabase.from("posting_rules").select("*").eq("company_id", company).is("deleted_at", null).order("event_key").limit(200),
    supabase.from("accounting_periods").select("*").eq("company_id", company).is("deleted_at", null).order("fiscal_year", { ascending: false }).order("fiscal_month", { ascending: false }).limit(60),
    supabase.rpc("trial_balance", { p_company: company, p_from: null, p_to: null }),
    supabase.rpc("income_statement", { p_company: company, p_from: monthStart, p_to: today }),
    supabase.rpc("balance_sheet", { p_company: company, p_as_of: null }),
  ]);

  return <GLWorkbench dash={dash.data ?? {}} accounts={accounts.data ?? []} entries={entries.data ?? []} rules={rules.data ?? []}
    periods={periods.data ?? []} trial={trial.data ?? []} dre={dre.data ?? {}} balance={balance.data ?? {}} />;
}
