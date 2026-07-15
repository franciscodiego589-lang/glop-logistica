import BIWorkbench from "@/components/bi/BIWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function AnalyticsPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Business Intelligence & Analytics</h1><VitrineBanner /></div>;
  }
  const [overview, kpis, alerts, catalog] = await Promise.all([
    supabase.rpc("bi_overview", { p_company: company }),
    supabase.from("kpi_definitions").select("*").eq("company_id", company).is("deleted_at", null).order("module").order("sort").limit(200),
    supabase.from("bi_alerts").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
    supabase.from("data_catalog").select("*").eq("company_id", company).is("deleted_at", null).order("domain").limit(200),
  ]);
  return <BIWorkbench overview={overview.data ?? {}} kpis={kpis.data ?? []} alerts={alerts.data ?? []} catalog={catalog.data ?? []} />;
}
