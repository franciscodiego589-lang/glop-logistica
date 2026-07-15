import IAMWorkbench from "@/components/seguranca/IAMWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function SegurancaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Identidade & Segurança (IAM)</h1><VitrineBanner /></div>;
  }
  const [dash, identities, sessions, pam, incidents, policies, certs] = await Promise.all([
    supabase.rpc("iam_dashboard", { p_company: company }),
    supabase.from("iam_identities").select("*").eq("company_id", company).is("deleted_at", null).order("display_name").limit(500),
    supabase.from("user_sessions").select("*").eq("company_id", company).is("deleted_at", null).order("started_at", { ascending: false }).limit(200),
    supabase.from("pam_requests").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("security_incidents").select("*").eq("company_id", company).is("deleted_at", null).order("detected_at", { ascending: false }).limit(200),
    supabase.from("access_policies").select("*").eq("company_id", company).is("deleted_at", null).order("priority").limit(200),
    supabase.from("access_certifications").select("*").eq("company_id", company).is("deleted_at", null).order("due_date").limit(100),
  ]);
  return <IAMWorkbench dash={dash.data ?? {}} identities={identities.data ?? []} sessions={sessions.data ?? []} pam={pam.data ?? []}
    incidents={incidents.data ?? []} policies={policies.data ?? []} certs={certs.data ?? []} />;
}
