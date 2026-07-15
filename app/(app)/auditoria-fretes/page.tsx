import FACMSWorkbench from "@/components/facms/FACMSWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function AuditoriaFretesPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Auditoria de Fretes & Custos (FACMS)</h1><VitrineBanner /></div>;
  }
  const [dash, invoices, charges, glosas, costs, contracts, carriers] = await Promise.all([
    supabase.rpc("facms_dashboard", { p_company: company }),
    supabase.from("transport_invoices").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("invoice_charges").select("*").eq("company_id", company).is("deleted_at", null).limit(1000),
    supabase.from("freight_glosas").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("logistics_costs").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(500),
    supabase.from("freight_contracts").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
    supabase.from("carriers").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
  ]);
  return <FACMSWorkbench dash={dash.data ?? {}} invoices={invoices.data ?? []} charges={charges.data ?? []}
    glosas={glosas.data ?? []} costs={costs.data ?? []} contracts={contracts.data ?? []} carriers={carriers.data ?? []} />;
}
