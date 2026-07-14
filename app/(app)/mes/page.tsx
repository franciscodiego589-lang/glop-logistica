import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import MesWorkbench from "@/components/mes/MesWorkbench";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function MesPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let equipment: any[] = [], appointments: any[] = [], downtimes: any[] = [], readings: any[] = [], orders: any[] = [];

  if (supabase && company) {
    const [eq, ap, dn, rd, or] = await Promise.all([
      supabase.from("equipment").select("id,code,name,status,equipment_type,work_center_id,capacity_per_hour,manufacturer,model").eq("company_id", company).is("deleted_at", null).order("name").limit(1000),
      supabase.from("production_appointments").select("id,production_order_id,equipment_id,shift,produced_quantity,scrap_quantity,rework_quantity,started_at,ended_at").eq("company_id", company).is("deleted_at", null).order("started_at", { ascending: false }).limit(1000),
      supabase.from("production_downtimes").select("id,equipment_id,reason,started_at,ended_at,minutes,notes").eq("company_id", company).is("deleted_at", null).order("started_at", { ascending: false }).limit(1000),
      supabase.from("process_readings").select("id,equipment_id,parameter,value,unit,min_limit,max_limit,out_of_range,recorded_at").eq("company_id", company).is("deleted_at", null).order("recorded_at", { ascending: false }).limit(1000),
      supabase.from("production_orders").select("id,code").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
    ]);
    equipment = eq.data ?? []; appointments = ap.data ?? []; downtimes = dn.data ?? []; readings = rd.data ?? []; orders = or.data ?? [];
  }
  const orderCode = Object.fromEntries(orders.map((o) => [o.id, o.code ?? o.id.slice(0, 8)]));
  const running = equipment.filter((e) => e.status === "running" || e.status === "operational").length;
  const stopped = equipment.filter((e) => e.status === "down" || e.status === "maintenance").length;
  const oorReadings = readings.filter((r) => r.out_of_range).length;
  const today = new Date().toISOString().slice(0, 10);
  const producedToday = appointments.filter((a) => (a.started_at ?? "").slice(0, 10) === today).reduce((s, a) => s + (Number(a.produced_quantity) || 0), 0);

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🕹</div>
        <div>
          <h1 className="text-xl font-bold">MES — Execução da Produção</h1>
          <p className="text-sm muted">Volume 06 · Chão de fábrica: equipamentos, apontamentos, paradas, processo e OEE</p>
        </div>
      </div>

      {!supabase && <VitrineBanner />}

      <div className="grid grid-cols-2 lg:grid-cols-5 gap-3">
        <KpiCard label="Equipamentos" value={equipment.length || "—"} />
        <KpiCard label="Em operação" value={running || "—"} accent />
        <KpiCard label="Parados / manut." value={stopped || "—"} />
        <KpiCard label="Produção hoje" value={producedToday || "—"} />
        <KpiCard label="Leituras fora do limite" value={oorReadings || "—"} />
      </div>

      <MesWorkbench data={{ equipment, appointments, downtimes, readings, orders, orderCode }} />
    </div>
  );
}
