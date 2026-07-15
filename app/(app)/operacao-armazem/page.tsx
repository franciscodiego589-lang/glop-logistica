import WMSEnterprise from "@/components/operacao-armazem/WMSEnterprise";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function OperacaoArmazemPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">WMS Enterprise</h1><VitrineBanner /></div>;
  }
  const [dash, slotting, esg, prod, utilities] = await Promise.all([
    supabase.rpc("wms_enterprise_dashboard", { p_company: company }),
    supabase.from("slotting_recommendations").select("*").eq("company_id", company).eq("status", "open").is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.rpc("warehouse_esg", { p_company: company }),
    supabase.rpc("operator_productivity", { p_company: company }),
    supabase.from("warehouse_utilities").select("*").eq("company_id", company).is("deleted_at", null).order("period_month", { ascending: false }).limit(300),
  ]);
  return <WMSEnterprise dash={dash.data ?? {}} slotting={slotting.data ?? []} esg={esg.data ?? {}} prod={(prod.data as any[]) ?? []} utilities={utilities.data ?? []} />;
}
