import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import LimsWorkbench from "@/components/lims/LimsWorkbench";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function LimsPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let samples: any[] = [], products: any[] = [], lots: any[] = [], methods: any[] = [],
    specs: any[] = [], reagents: any[] = [], instruments: any[] = [], stability: any[] = [];

  if (supabase && company) {
    const [sa, pr, lo, me, sp, re, ins, stb] = await Promise.all([
      supabase.from("lab_samples").select("id,code,sample_type,status,product_id,lot_id,collector,collected_at,priority").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(2000),
      supabase.from("products").select("id,name,sku").eq("company_id", company).is("deleted_at", null).order("name").limit(5000),
      supabase.from("product_lots").select("id,lot_number,product_id").eq("company_id", company).is("deleted_at", null).order("lot_number").limit(5000),
      supabase.from("lab_methods").select("id,code,name,technique,test_kind,version_label,status").eq("company_id", company).is("deleted_at", null).order("name").limit(2000),
      supabase.from("product_specifications").select("id,product_id,parameter,test_kind,min_value,max_value,unit,method_id").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(3000),
      supabase.from("lab_reagents").select("id,name,manufacturer,lot_number,expiry_date,quantity,unit,location,responsible").eq("company_id", company).is("deleted_at", null).order("expiry_date").limit(2000),
      supabase.from("lab_instruments").select("id,code,name,instrument_type,manufacturer,model,calibration_due,last_calibration,responsible,status").eq("company_id", company).is("deleted_at", null).order("name").limit(2000),
      supabase.from("stability_studies").select("id,code,product_id,study_kind,condition_temp,condition_humidity,start_date,end_date,status").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(2000),
    ]);
    samples = sa.data ?? []; products = pr.data ?? []; lots = lo.data ?? []; methods = me.data ?? [];
    specs = sp.data ?? []; reagents = re.data ?? []; instruments = ins.data ?? []; stability = stb.data ?? [];
  }
  const prodName = Object.fromEntries(products.map((p) => [p.id, p.name]));
  const inAnalysis = samples.filter((s) => s.status === "registered" || s.status === "in_analysis").length;
  const approved = samples.filter((s) => s.status === "approved").length;
  const rejected = samples.filter((s) => s.status === "rejected").length;
  const today = new Date().toISOString().slice(0, 10);
  const in30 = new Date(Date.now() + 30 * 864e5).toISOString().slice(0, 10);
  const expiringReagents = reagents.filter((r) => r.expiry_date && r.expiry_date <= in30).length;
  const overdueCal = instruments.filter((i) => i.calibration_due && i.calibration_due < today).length;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🧪</div>
        <div>
          <h1 className="text-xl font-bold">LIMS — Laboratório</h1>
          <p className="text-sm muted">Volume 09 · Amostras, ensaios, especificações, reagentes e liberação de lote</p>
        </div>
      </div>

      {!supabase && <VitrineBanner />}

      <div className="grid grid-cols-2 lg:grid-cols-6 gap-3">
        <KpiCard label="Amostras" value={samples.length || "—"} />
        <KpiCard label="Em análise" value={inAnalysis || "—"} accent />
        <KpiCard label="Aprovadas" value={approved || "—"} />
        <KpiCard label="Reprovadas" value={rejected || "—"} />
        <KpiCard label="Reagentes vencendo" value={expiringReagents || "—"} hint="≤ 30 dias" />
        <KpiCard label="Calibração vencida" value={overdueCal || "—"} />
      </div>

      <LimsWorkbench data={{ samples, products, lots, methods, specs, reagents, instruments, stability, prodName }} />
    </div>
  );
}
