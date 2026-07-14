import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import TmsWorkbench from "@/components/tms/TmsWorkbench";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

const money = (n: number) => n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });

export default async function TmsPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let carriers: any[] = [], vehicles: any[] = [], drivers: any[] = [], rates: any[] = [], shipments: any[] = [];

  if (supabase && company) {
    const [c, v, d, r, s] = await Promise.all([
      supabase.from("carriers").select("id,name,code,document,modal,phone,email,rating").eq("company_id", company).is("deleted_at", null).order("name").limit(1000),
      supabase.from("vehicles").select("id,plate,vehicle_type,brand,model,carrier_id,max_weight_kg,max_volume_m3,max_pallets").eq("company_id", company).is("deleted_at", null).order("plate").limit(2000),
      supabase.from("drivers").select("id,name,document,license_number,license_category,carrier_id,phone").eq("company_id", company).is("deleted_at", null).order("name").limit(2000),
      supabase.from("freight_rates").select("id,carrier_id,origin_uf,dest_uf,weight_from_kg,weight_to_kg,price_per_kg,price_fixed,gris_percent,advalorem_percent,lead_time_days").eq("company_id", company).is("deleted_at", null).limit(5000),
      supabase.from("shipments").select("id,code,tracking_code,status,dest_city,dest_uf,carrier_id,freight_value,cargo_value,estimated_delivery,delivered_at").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
    ]);
    carriers = c.data ?? []; vehicles = v.data ?? []; drivers = d.data ?? []; rates = r.data ?? []; shipments = s.data ?? [];
  }

  const inTransit = shipments.filter((s) => s.status === "in_transit" || s.status === "dispatched").length;
  const delivered = shipments.filter((s) => s.status === "delivered");
  const onTime = delivered.filter((s) => s.delivered_at && s.estimated_delivery && new Date(s.delivered_at) <= new Date(s.estimated_delivery + "T23:59:59")).length;
  const otif = delivered.length ? Math.round((onTime / delivered.length) * 100) : null;
  const freights = shipments.map((s) => s.freight_value).filter((x): x is number => typeof x === "number" && x > 0);
  const avgFreight = freights.length ? freights.reduce((a, b) => a + b, 0) / freights.length : null;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🚚</div>
        <div>
          <h1 className="text-xl font-bold">TMS / Transporte</h1>
          <p className="text-sm muted">Volume 04 · Transportadoras, frota, fretes, embarques e rastreio</p>
        </div>
      </div>

      {!supabase && <VitrineBanner />}

      <div className="grid grid-cols-2 lg:grid-cols-6 gap-3">
        <KpiCard label="Embarques" value={shipments.length || "—"} />
        <KpiCard label="Em trânsito" value={inTransit || "—"} accent />
        <KpiCard label="OTIF" value={otif == null ? "—" : `${otif}%`} hint="entregas no prazo" />
        <KpiCard label="Frete médio" value={avgFreight == null ? "—" : money(avgFreight)} />
        <KpiCard label="Transportadoras" value={carriers.length || "—"} />
        <KpiCard label="Frota" value={vehicles.length || "—"} />
      </div>

      <TmsWorkbench data={{ carriers, vehicles, drivers, rates, shipments }} />
    </div>
  );
}
