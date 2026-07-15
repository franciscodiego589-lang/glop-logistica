import ControllingWorkbench from "@/components/controladoria/ControllingWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function ControladoriaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Controladoria & Custos</h1><VitrineBanner /></div>;
  }
  const [dash, dre, variance, products, pc, co, ce, sc, sim] = await Promise.all([
    supabase.rpc("controlling_dashboard", { p_company: company }),
    supabase.rpc("dre_managerial", { p_company: company }),
    supabase.rpc("variance_analysis", { p_company: company }),
    supabase.from("products").select("id,name,sku,cost_price,sale_price").eq("company_id", company).is("deleted_at", null).order("name").limit(2000),
    supabase.from("profit_centers").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(1000),
    supabase.from("cost_objects").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
    supabase.from("cost_entries").select("*").eq("company_id", company).is("deleted_at", null).order("period_month", { ascending: false }).limit(1000),
    supabase.from("standard_costs").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
    supabase.from("cost_simulations").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
  ]);
  return (
    <ControllingWorkbench
      dash={dash.data ?? {}} dre={dre.data ?? {}} variance={(variance.data as any[]) ?? []} products={products.data ?? []}
      data={{ profit_centers: pc.data ?? [], cost_objects: co.data ?? [], cost_entries: ce.data ?? [], standard_costs: sc.data ?? [], cost_simulations: sim.data ?? [] }}
    />
  );
}
