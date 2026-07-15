import CRMWorkbench from "@/components/comercial/CRMWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function ComercialPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">CRM & Vendas</h1><VitrineBanner /></div>;
  }
  const [dash, forecast, stages, accounts, leads, opportunities, activities, proposals, campaigns] = await Promise.all([
    supabase.rpc("crm_dashboard", { p_company: company }),
    supabase.rpc("sales_forecast", { p_company: company }),
    supabase.from("crm_stages").select("*").eq("company_id", company).is("deleted_at", null).order("order_index").limit(100),
    supabase.from("crm_accounts").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
    supabase.from("crm_leads").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("crm_opportunities").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(500),
    supabase.from("crm_activities").select("*").eq("company_id", company).is("deleted_at", null).order("due_at", { ascending: true }).limit(300),
    supabase.from("crm_proposals").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("crm_campaigns").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
  ]);
  return <CRMWorkbench dash={dash.data ?? {}} forecast={forecast.data ?? []} stages={stages.data ?? []} accounts={accounts.data ?? []}
    leads={leads.data ?? []} opportunities={opportunities.data ?? []} activities={activities.data ?? []} proposals={proposals.data ?? []} campaigns={campaigns.data ?? []} />;
}
