import RmaWorkbench from "@/components/devolucoes/RmaWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function DevolucoesPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Devoluções (RMA)</h1><VitrineBanner /></div>;
  }
  const [dash, rmas, reasons, customers] = await Promise.all([
    supabase.rpc("rma_dashboard", { p_company: company }),
    supabase.from("rma_requests").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(500),
    supabase.from("return_reasons").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(300),
    supabase.from("customers").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(3000),
  ]);
  return <RmaWorkbench dash={dash.data ?? {}} rmas={rmas.data ?? []} reasons={reasons.data ?? []} customers={customers.data ?? []} />;
}
