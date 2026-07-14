import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import ComprasWorkbench from "@/components/compras/ComprasWorkbench";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

const money = (n: number) => n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });

export default async function ComprasPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let suppliers: any[] = [], reqs: any[] = [], rfqs: any[] = [], pos: any[] = [], warehouses: any[] = [];

  if (supabase && company) {
    const [s, r, q, p, w] = await Promise.all([
      supabase.from("suppliers").select("id,name,legal_name,document,contact_name,phone,email,lead_time_days,rating").eq("company_id", company).is("deleted_at", null).order("name").limit(2000),
      supabase.from("purchase_requisitions").select("id,code,status,needed_by,justification,warehouse_id").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
      supabase.from("rfqs").select("id,code,status,due_date,notes").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
      supabase.from("purchase_orders").select("id,code,status,supplier_id,warehouse_id,order_date,expected_date,total").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
      supabase.from("warehouses").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
    ]);
    suppliers = s.data ?? []; reqs = r.data ?? []; rfqs = q.data ?? []; pos = p.data ?? []; warehouses = w.data ?? [];
  }

  const openReqs = reqs.filter((r) => r.status === "draft" || r.status === "submitted").length;
  const openPos = pos.filter((p) => !["received", "invoiced", "canceled"].includes(p.status)).length;
  const poValue = pos.filter((p) => !["canceled"].includes(p.status)).reduce((a, p) => a + (Number(p.total) || 0), 0);
  const avgScore = (() => {
    const rs = suppliers.map((s) => s.rating).filter((x): x is number => typeof x === "number" && x > 0);
    return rs.length ? (rs.reduce((a, b) => a + b, 0) / rs.length) : null;
  })();

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🛒</div>
        <div>
          <h1 className="text-xl font-bold">Compras / Procurement</h1>
          <p className="text-sm muted">Volume 06 · Fornecedores, requisição → cotação → pedido → recebimento</p>
        </div>
      </div>

      {!supabase && <VitrineBanner />}

      <div className="grid grid-cols-2 lg:grid-cols-6 gap-3">
        <KpiCard label="Fornecedores" value={suppliers.length || "—"} />
        <KpiCard label="Requisições abertas" value={openReqs || "—"} />
        <KpiCard label="Pedidos abertos" value={openPos || "—"} accent />
        <KpiCard label="Valor em pedidos" value={poValue ? money(poValue) : "—"} />
        <KpiCard label="RFQs" value={rfqs.length || "—"} />
        <KpiCard label="Score médio forn." value={avgScore == null ? "—" : avgScore.toFixed(1)} hint="rating 0-5" />
      </div>

      <ComprasWorkbench data={{ suppliers, reqs, rfqs, pos, warehouses }} />
    </div>
  );
}
