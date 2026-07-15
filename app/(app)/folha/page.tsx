import PWMWorkbench from "@/components/folha/PWMWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function FolhaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Folha & Força de Trabalho (PWM)</h1><VitrineBanner /></div>;
  }
  const [dash, runs, items, schedules, timeEntries, timeBank, terminations, employees] = await Promise.all([
    supabase.rpc("pwm_dashboard", { p_company: company }),
    supabase.from("payroll_runs").select("*").eq("company_id", company).is("deleted_at", null).order("fiscal_year", { ascending: false }).order("fiscal_month", { ascending: false }).limit(60),
    supabase.from("payroll_items").select("*").eq("company_id", company).is("deleted_at", null).limit(1000),
    supabase.from("work_schedules").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("time_entries").select("*").eq("company_id", company).is("deleted_at", null).order("entry_date", { ascending: false }).limit(300),
    supabase.from("time_bank_movements").select("*").eq("company_id", company).is("deleted_at", null).order("movement_date", { ascending: false }).limit(300),
    supabase.from("terminations").select("*").eq("company_id", company).is("deleted_at", null).order("termination_date", { ascending: false }).limit(200),
    supabase.from("employees").select("id, full_name, status, salary").eq("company_id", company).is("deleted_at", null).order("full_name").limit(1000),
  ]);
  return <PWMWorkbench dash={dash.data ?? {}} runs={runs.data ?? []} items={items.data ?? []} schedules={schedules.data ?? []}
    timeEntries={timeEntries.data ?? []} timeBank={timeBank.data ?? []} terminations={terminations.data ?? []} employees={employees.data ?? []} />;
}
