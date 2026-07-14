import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import DistribuicaoWorkbench from "@/components/distribuicao/DistribuicaoWorkbench";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function DistribuicaoPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let transfers: any[] = [], deliveries: any[] = [], warehouses: any[] = [], customers: any[] = [];
  if (supabase && company) {
    const [t, d, w, c] = await Promise.all([
      supabase.from("stock_transfers").select("id,code,status,from_warehouse_id,to_warehouse_id,is_cross_dock").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
      supabase.from("deliveries").select("id,code,status,address,city,uf,scheduled_date,receiver_name,customer_id").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
      supabase.from("warehouses").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
      supabase.from("customers").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(3000),
    ]);
    transfers = t.data ?? []; deliveries = d.data ?? []; warehouses = w.data ?? []; customers = c.data ?? [];
  }
  const inTransit = transfers.filter((t) => t.status === "in_transit").length;
  const pendingDel = deliveries.filter((d) => d.status === "pending" || d.status === "out_for_delivery").length;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🗺</div>
        <div>
          <h1 className="text-xl font-bold">Distribuição &amp; Last Mile</h1>
          <p className="text-sm muted">Volume 13 · Transferências entre CDs, cross-dock e entregas</p>
        </div>
      </div>
      {!supabase && <VitrineBanner />}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <KpiCard label="Transferências" value={transfers.length || "—"} />
        <KpiCard label="Em trânsito" value={inTransit || "—"} accent />
        <KpiCard label="Entregas" value={deliveries.length || "—"} />
        <KpiCard label="Entregas pendentes" value={pendingDel || "—"} />
      </div>
      <DistribuicaoWorkbench data={{ transfers, deliveries, warehouses, customers }} />
    </div>
  );
}
