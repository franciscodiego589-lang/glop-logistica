import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import DemandaWorkbench from "@/components/demanda/DemandaWorkbench";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function DemandaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let history: any[] = [], forecasts: any[] = [], products: any[] = [], warehouses: any[] = [];
  if (supabase && company) {
    const [h, f, p, w] = await Promise.all([
      supabase.from("demand_history").select("id,product_id,warehouse_id,period_month,quantity,channel,revenue").eq("company_id", company).is("deleted_at", null).order("period_month", { ascending: false }).limit(3000),
      supabase.from("demand_forecasts").select("id,product_id,period_month,method,forecast_quantity").eq("company_id", company).is("deleted_at", null).order("period_month").limit(3000),
      supabase.from("products").select("id,name,sku").eq("company_id", company).is("deleted_at", null).order("name").limit(5000),
      supabase.from("warehouses").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
    ]);
    history = h.data ?? []; forecasts = f.data ?? []; products = p.data ?? []; warehouses = w.data ?? [];
  }
  const prodName = Object.fromEntries(products.map((p) => [p.id, p.name]));
  const withHistory = new Set(history.map((h) => h.product_id)).size;
  const forecastQty = forecasts.reduce((a, f) => a + (Number(f.forecast_quantity) || 0), 0);

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">📈</div>
        <div>
          <h1 className="text-xl font-bold">Demand Planning</h1>
          <p className="text-sm muted">Volume 07 · Histórico, previsão de demanda e S&amp;OP</p>
        </div>
      </div>
      {!supabase && <VitrineBanner />}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <KpiCard label="Produtos c/ histórico" value={withHistory || "—"} />
        <KpiCard label="Registros de histórico" value={history.length || "—"} />
        <KpiCard label="Previsões geradas" value={forecasts.length || "—"} accent />
        <KpiCard label="Demanda prevista (total)" value={forecastQty || "—"} hint="soma das previsões" />
      </div>
      <DemandaWorkbench data={{ history, forecasts, products, warehouses, prodName }} />
    </div>
  );
}
