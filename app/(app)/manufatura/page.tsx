import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import ManufaturaWorkbench from "@/components/manufatura/ManufaturaWorkbench";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function ManufaturaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let boms: any[] = [], revisions: any[] = [], lines: any[] = [], products: any[] = [], orders: any[] = [], downtimes: any[] = [];

  if (supabase && company) {
    const [b, r, l, p, o, d] = await Promise.all([
      supabase.from("bills_of_materials").select("id,product_id,name,status,version_label,approved_at,output_quantity").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(2000),
      supabase.from("bom_revisions").select("id,bom_id,version_label,note,approved_at,components").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(5000),
      supabase.from("production_lines").select("id,code,name,line_type,work_center_id,capacity_per_hour,oee_target,responsible").eq("company_id", company).is("deleted_at", null).order("name").limit(1000),
      supabase.from("products").select("id,name,sku").eq("company_id", company).is("deleted_at", null).order("name").limit(5000),
      supabase.from("production_orders").select("id,code,status,product_id,planned_quantity,produced_quantity").eq("company_id", company).is("deleted_at", null).in("status", ["released", "in_progress"]).order("created_at", { ascending: false }).limit(500),
      supabase.from("production_downtimes").select("reason,minutes").eq("company_id", company).is("deleted_at", null).limit(5000),
    ]);
    boms = b.data ?? []; revisions = r.data ?? []; lines = l.data ?? []; products = p.data ?? []; orders = o.data ?? []; downtimes = d.data ?? [];
  }
  const prodName = Object.fromEntries(products.map((p) => [p.id, p.name]));
  const revisionsByBom: Record<string, any[]> = {};
  for (const rev of revisions) (revisionsByBom[rev.bom_id] ??= []).push(rev);
  const pendingApproval = boms.filter((b) => (b.status ?? "draft") === "draft").length;
  const approved = boms.filter((b) => b.status === "approved").length;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🏗</div>
        <div>
          <h1 className="text-xl font-bold">Manufatura (MFG)</h1>
          <p className="text-sm muted">Volume 07 · Governança da produção: receitas, linhas, rastreabilidade e cockpit</p>
        </div>
      </div>

      {!supabase && <VitrineBanner />}

      <div className="grid grid-cols-2 lg:grid-cols-5 gap-3">
        <KpiCard label="Ordens em WIP" value={orders.length || "—"} accent />
        <KpiCard label="Receitas" value={boms.length || "—"} />
        <KpiCard label="Aprovadas" value={approved || "—"} />
        <KpiCard label="Aguardando aprovação" value={pendingApproval || "—"} />
        <KpiCard label="Linhas de produção" value={lines.length || "—"} />
      </div>

      <ManufaturaWorkbench data={{ boms, revisionsByBom, lines, products, wipOrders: orders, downtimes, prodName }} />
    </div>
  );
}
