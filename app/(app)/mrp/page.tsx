import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import MrpWorkbench from "@/components/mrp/MrpWorkbench";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function MrpPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let planned: any[] = [], boms: any[] = [], workCenters: any[] = [], products: any[] = [], lastRun: any = null;

  if (supabase && company) {
    const [{ data: run }, { data: bm }, { data: wc }, { data: pr }] = await Promise.all([
      supabase.from("mrp_runs").select("id,status,orders_generated,finished_at").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1).maybeSingle(),
      supabase.from("bills_of_materials").select("id,product_id,name,output_quantity").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
      supabase.from("work_centers").select("id,name,code,capacity_per_hour,hours_per_day,cost_per_hour,efficiency_percent").eq("company_id", company).is("deleted_at", null).order("name").limit(1000),
      supabase.from("products").select("id,name,sku").eq("company_id", company).is("deleted_at", null).order("name").limit(5000),
    ]);
    lastRun = run ?? null; boms = bm ?? []; workCenters = wc ?? []; products = pr ?? [];
    if (lastRun) {
      const { data: po } = await supabase.from("mrp_planned_orders")
        .select("id,product_id,order_kind,status,quantity,need_date,on_hand,net_requirement")
        .eq("mrp_run_id", lastRun.id).is("deleted_at", null).order("need_date").limit(2000);
      planned = po ?? [];
    }
  }
  const prodName = Object.fromEntries(products.map((p) => [p.id, p.name]));
  const toBuy = planned.filter((o) => o.order_kind === "purchase").length;
  const toMake = planned.filter((o) => o.order_kind === "production").length;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">⚙</div>
        <div>
          <h1 className="text-xl font-bold">MRP / APS</h1>
          <p className="text-sm muted">Volume 08 · Necessidades, estruturas (BOM) e capacidade</p>
        </div>
      </div>

      {!supabase && <VitrineBanner />}

      <div className="grid grid-cols-2 lg:grid-cols-5 gap-3">
        <KpiCard label="Ordens planejadas" value={planned.length || "—"} accent />
        <KpiCard label="A comprar" value={toBuy || "—"} />
        <KpiCard label="A produzir" value={toMake || "—"} />
        <KpiCard label="Estruturas (BOM)" value={boms.length || "—"} />
        <KpiCard label="Centros de trabalho" value={workCenters.length || "—"} />
      </div>

      <MrpWorkbench data={{ planned, boms, workCenters, products, prodName }} />
    </div>
  );
}
