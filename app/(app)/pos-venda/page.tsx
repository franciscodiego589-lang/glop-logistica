import CLXWorkbench from "@/components/pos-venda/CLXWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function PosVendaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Pós-Venda (CLX)</h1><VitrineBanner /></div>;
  }
  const [dash, occ, surveys, notifs, customers] = await Promise.all([
    supabase.rpc("clx_dashboard", { p_company: company }),
    supabase.from("customer_occurrences").select("*").eq("company_id", company).is("deleted_at", null).order("opened_at", { ascending: false }).limit(300),
    supabase.from("satisfaction_surveys").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("customer_notifications").select("*").eq("company_id", company).is("deleted_at", null).order("sent_at", { ascending: false }).limit(300),
    supabase.from("customers").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(3000),
  ]);
  return <CLXWorkbench dash={dash.data ?? {}} occurrences={occ.data ?? []} surveys={surveys.data ?? []} notifications={notifs.data ?? []} customers={customers.data ?? []} />;
}
