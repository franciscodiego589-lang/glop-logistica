import Link from "next/link";
import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import WarehouseManager from "@/components/wms/WarehouseManager";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

type Warehouse = {
  id: string; code: string | null; name: string; warehouse_type: string;
  address: string | null; active: boolean;
};

export default async function WmsPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let warehouses: Warehouse[] = [];
  let zoneCounts: Record<string, number> = {};
  let binCounts: Record<string, number> = {};
  let statusTotals = { available: 0, blocked: 0, full: 0, maintenance: 0, total: 0 };

  if (supabase && company) {
    const [{ data: whs }, { data: zones }, { data: locs }] = await Promise.all([
      supabase
        .from("warehouses")
        .select("id,code,name,warehouse_type,address,active")
        .eq("company_id", company).is("deleted_at", null)
        .order("name").limit(500),
      supabase
        .from("storage_zones")
        .select("id,warehouse_id")
        .eq("company_id", company).is("deleted_at", null).limit(2000),
      supabase
        .from("storage_locations")
        .select("id,warehouse_id,status")
        .eq("company_id", company).is("deleted_at", null).limit(20000),
    ]);
    warehouses = (whs as Warehouse[]) ?? [];
    for (const z of zones ?? []) zoneCounts[z.warehouse_id] = (zoneCounts[z.warehouse_id] ?? 0) + 1;
    for (const l of (locs ?? []) as { warehouse_id: string; status: string }[]) {
      binCounts[l.warehouse_id] = (binCounts[l.warehouse_id] ?? 0) + 1;
      statusTotals.total++;
      if (l.status in statusTotals) (statusTotals as any)[l.status]++;
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">⌗</div>
        <div>
          <h1 className="text-xl font-bold">WMS / Armazém</h1>
          <p className="text-sm muted">Volume 03 · Estrutura física, endereçamento e ocupação</p>
        </div>
      </div>

      {!supabase && <VitrineBanner />}

      <div className="grid grid-cols-2 lg:grid-cols-5 gap-3">
        <KpiCard label="Armazéns" value={warehouses.length || "—"} />
        <KpiCard label="Zonas" value={Object.values(zoneCounts).reduce((a, b) => a + b, 0) || "—"} />
        <KpiCard label="Endereços (bins)" value={statusTotals.total || "—"} accent hint="posições cadastradas" />
        <KpiCard label="Disponíveis" value={statusTotals.available || "—"} />
        <KpiCard label="Bloqueados / manut." value={(statusTotals.blocked + statusTotals.maintenance) || "—"} />
      </div>

      <WarehouseManager
        initial={warehouses.map((w) => ({ ...w, zones: zoneCounts[w.id] ?? 0, bins: binCounts[w.id] ?? 0 }))}
      />
    </div>
  );
}
