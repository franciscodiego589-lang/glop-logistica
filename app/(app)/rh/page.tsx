import HCMWorkbench from "@/components/rh/HCMWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function RhPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Recursos Humanos (HCM)</h1><VitrineBanner /></div>;
  }
  const [dash, employees, departments, positions, vacancies, candidates, timeoff, reviews, trainings, records, competencies, benefits] = await Promise.all([
    supabase.rpc("hcm_dashboard", { p_company: company }),
    supabase.from("employees").select("*").eq("company_id", company).is("deleted_at", null).order("full_name").limit(1000),
    supabase.from("departments").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(200),
    supabase.from("positions").select("*").eq("company_id", company).is("deleted_at", null).order("title").limit(200),
    supabase.from("job_vacancies").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("candidates").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(500),
    supabase.from("time_off_requests").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("performance_reviews").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("hr_trainings").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(200),
    supabase.from("hr_training_records").select("*").eq("company_id", company).is("deleted_at", null).order("expires_at").limit(500),
    supabase.from("employee_competencies").select("*").eq("company_id", company).is("deleted_at", null).limit(500),
    supabase.from("employee_benefits").select("*").eq("company_id", company).is("deleted_at", null).limit(500),
  ]);
  return <HCMWorkbench dash={dash.data ?? {}} employees={employees.data ?? []} departments={departments.data ?? []} positions={positions.data ?? []}
    vacancies={vacancies.data ?? []} candidates={candidates.data ?? []} timeoff={timeoff.data ?? []} reviews={reviews.data ?? []}
    trainings={trainings.data ?? []} records={records.data ?? []} competencies={competencies.data ?? []} benefits={benefits.data ?? []} />;
}
