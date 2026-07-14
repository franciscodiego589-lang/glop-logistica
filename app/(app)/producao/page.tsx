import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import ProducaoWorkbench from "@/components/producao/ProducaoWorkbench";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function ProducaoPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let orders: any[] = [], products: any[] = [], boms: any[] = [], warehouses: any[] = [];

  if (supabase && company) {
    const [o, p, b, w] = await Promise.all([
      supabase.from("production_orders").select("id,code,status,product_id,planned_quantity,produced_quantity,planned_end").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
      supabase.from("products").select("id,name,sku").eq("company_id", company).is("deleted_at", null).order("name").limit(5000),
      supabase.from("bills_of_materials").select("id,product_id,name").eq("company_id", company).is("deleted_at", null).limit(2000),
      supabase.from("warehouses").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
    ]);
    orders = o.data ?? []; products = p.data ?? []; boms = b.data ?? []; warehouses = w.data ?? [];
  }
  const prodName = Object.fromEntries(products.map((p) => [p.id, p.name]));
  const wip = orders.filter((o) => o.status === "in_progress" || o.status === "released").length;
  const finished = orders.filter((o) => o.status === "finished" || o.status === "closed").length;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🏭</div>
        <div>
          <h1 className="text-xl font-bold">Produção / PCP</h1>
          <p className="text-sm muted">Volume 09 · Ordens de produção, operações e apontamento</p>
        </div>
      </div>

      {!supabase && <VitrineBanner />}

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <KpiCard label="Ordens de produção" value={orders.length || "—"} />
        <KpiCard label="Em andamento" value={wip || "—"} accent />
        <KpiCard label="Finalizadas" value={finished || "—"} />
        <KpiCard label="Estruturas (BOM)" value={boms.length || "—"} />
      </div>

      <ProducaoWorkbench data={{ orders, products, boms, warehouses, prodName }} />
    </div>
  );
}
