import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import ManutencaoWorkbench from "@/components/manutencao/ManutencaoWorkbench";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";
const money = (n: number) => n.toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 });

type Kpis = { assets?: number; assets_down?: number; open_wos?: number; overdue_wos?: number; preventive_wos?: number; corrective_wos?: number; mttr_minutes?: number; failures?: number; maintenance_cost?: number };

export default async function ManutencaoPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let kpis: Kpis = {};
  let workOrders: any[] = [], assets: any[] = [], plans: any[] = [], failures: any[] = [], readings: any[] = [];

  if (supabase && company) {
    const [{ data: k }, wo, a, p, f, r] = await Promise.all([
      supabase.rpc("maintenance_kpis", { p_company: company }),
      supabase.from("work_orders").select("id,code,wo_type,status,priority,description,asset_id,due_date").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(2000),
      supabase.from("assets").select("id,code,name,asset_type,criticality,location,status").eq("company_id", company).is("deleted_at", null).order("name").limit(3000),
      supabase.from("maintenance_plans").select("id,code,name,asset_id,wo_type,trigger,interval_value,next_due,responsible,task").eq("company_id", company).is("deleted_at", null).order("next_due").limit(2000),
      supabase.from("asset_failures").select("id,asset_id,failure_type,severity,cause,root_cause,rca_method,downtime_minutes").eq("company_id", company).is("deleted_at", null).order("occurred_at", { ascending: false }).limit(2000),
      supabase.from("asset_readings").select("id,asset_id,parameter,value,unit,min_limit,max_limit,out_of_range").eq("company_id", company).is("deleted_at", null).order("recorded_at", { ascending: false }).limit(2000),
    ]);
    kpis = (k as Kpis) ?? {};
    workOrders = wo.data ?? []; assets = a.data ?? []; plans = p.data ?? []; failures = f.data ?? []; readings = r.data ?? [];
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🔧</div>
        <div>
          <h1 className="text-xl font-bold">EAM / Manutenção</h1>
          <p className="text-sm muted">Volume 10 · Ativos, ordens de serviço, preventiva e confiabilidade</p>
        </div>
      </div>

      {!supabase && <VitrineBanner />}

      <div className="grid grid-cols-2 lg:grid-cols-6 gap-3">
        <KpiCard label="Ativos" value={kpis.assets ?? "—"} />
        <KpiCard label="Ativos parados" value={kpis.assets_down ?? "—"} />
        <KpiCard label="OS abertas" value={kpis.open_wos ?? "—"} accent />
        <KpiCard label="OS vencidas" value={kpis.overdue_wos ?? "—"} />
        <KpiCard label="MTTR (min)" value={kpis.mttr_minutes ?? "—"} hint="tempo médio de reparo" />
        <KpiCard label="Custo manutenção" value={kpis.maintenance_cost != null ? money(kpis.maintenance_cost) : "—"} />
      </div>

      <ManutencaoWorkbench data={{ workOrders, assets, plans, failures, readings }} />
    </div>
  );
}
