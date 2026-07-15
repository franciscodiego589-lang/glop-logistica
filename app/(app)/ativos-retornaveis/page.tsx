import RAMSWorkbench from "@/components/ativos/RAMSWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function AtivosPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Ativos Retornáveis</h1><VitrineBanner /></div>;
  }
  const [dash, esg, types, loans, maint, charges] = await Promise.all([
    supabase.rpc("rams_dashboard", { p_company: company }),
    supabase.rpc("asset_esg", { p_company: company }),
    supabase.from("returnable_asset_types").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(300),
    supabase.from("asset_loans").select("*").eq("company_id", company).is("deleted_at", null).order("due_date").limit(500),
    supabase.from("asset_maintenance").select("*").eq("company_id", company).is("deleted_at", null).order("service_date", { ascending: false }).limit(300),
    supabase.from("asset_charges").select("*").eq("company_id", company).eq("status", "open").is("deleted_at", null).order("amount", { ascending: false }).limit(300),
  ]);
  return <RAMSWorkbench dash={dash.data ?? {}} esg={esg.data ?? {}} types={types.data ?? []} loans={loans.data ?? []} maintenance={maint.data ?? []} charges={charges.data ?? []} />;
}
