import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import YmsWorkbench from "@/components/yms/YmsWorkbench";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function YmsPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let docks: any[] = [], appointments: any[] = [], visits: any[] = [], warehouses: any[] = [];
  if (supabase && company) {
    const [d, a, v, w] = await Promise.all([
      supabase.from("docks").select("id,code,name,warehouse_id,dock_type,status").eq("company_id", company).is("deleted_at", null).order("code").limit(1000),
      supabase.from("dock_appointments").select("id,code,status,direction,dock_id,vehicle_plate,driver_name,scheduled_start,scheduled_end").eq("company_id", company).is("deleted_at", null).order("scheduled_start", { ascending: false }).limit(1000),
      supabase.from("yard_visits").select("id,status,vehicle_plate,driver_name,warehouse_id,gate_in_at").eq("company_id", company).is("deleted_at", null).order("gate_in_at", { ascending: false }).limit(1000),
      supabase.from("warehouses").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
    ]);
    docks = d.data ?? []; appointments = a.data ?? []; visits = v.data ?? []; warehouses = w.data ?? [];
  }
  const occupied = docks.filter((d) => d.status === "occupied").length;
  const todayAppts = appointments.filter((a) => a.status === "scheduled" || a.status === "confirmed" || a.status === "arrived").length;
  const inYard = visits.filter((v) => v.status !== "departed" && v.status !== "canceled").length;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🏗</div>
        <div>
          <h1 className="text-xl font-bold">YMS / Pátio &amp; Docas</h1>
          <p className="text-sm muted">Volume 05 · Docas, agendamento e gestão de pátio</p>
        </div>
      </div>
      {!supabase && <VitrineBanner />}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <KpiCard label="Docas" value={docks.length || "—"} />
        <KpiCard label="Docas ocupadas" value={occupied || "—"} />
        <KpiCard label="Agendamentos ativos" value={todayAppts || "—"} accent />
        <KpiCard label="Veículos no pátio" value={inYard || "—"} />
      </div>
      <YmsWorkbench data={{ docks, appointments, visits, warehouses }} />
    </div>
  );
}
