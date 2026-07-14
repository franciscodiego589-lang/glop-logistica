import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import CountsPanel from "@/components/inventario/CountsPanel";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function InventarioPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let counts: any[] = [], warehouses: any[] = [];
  if (supabase && company) {
    const [c, w] = await Promise.all([
      supabase.from("inventory_counts").select("id,code,status,count_type,count_date,warehouse_id").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
      supabase.from("warehouses").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
    ]);
    counts = c.data ?? []; warehouses = w.data ?? [];
  }
  const openCounts = counts.filter((c) => c.status !== "closed" && c.status !== "canceled").length;
  const closed = counts.filter((c) => c.status === "closed").length;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">⎗</div>
        <div>
          <h1 className="text-xl font-bold">Inventário &amp; Rastreio</h1>
          <p className="text-sm muted">Volume 11 · Contagens cíclicas e ajuste de estoque</p>
        </div>
      </div>
      {!supabase && <VitrineBanner />}
      <div className="grid grid-cols-2 lg:grid-cols-3 gap-3">
        <KpiCard label="Contagens" value={counts.length || "—"} />
        <KpiCard label="Abertas" value={openCounts || "—"} accent />
        <KpiCard label="Fechadas" value={closed || "—"} />
      </div>
      <CountsPanel counts={counts} warehouses={warehouses} />
    </div>
  );
}
