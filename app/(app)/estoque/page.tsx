import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import EstoqueWorkbench from "@/components/estoque/EstoqueWorkbench";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

const money = (n: number) => n.toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 });

type Kpis = { skus_active?: number; stock_value?: number; below_reorder?: number; expiring_30d?: number; open_receipts?: number; pending_tasks?: number };

export default async function EstoquePage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let kpis: Kpis = {};
  let suggestions: any[] = [], products: any[] = [], balances: any[] = [];

  if (supabase && company) {
    const [{ data: k }, { data: sg }, { data: pr }, { data: bl }] = await Promise.all([
      supabase.rpc("inventory_kpis", { p_company: company }),
      supabase.from("reorder_suggestions").select("id,product_id,on_hand,reorder_point,suggested_quantity,reason,status").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
      supabase.from("products").select("id,name,sku,abc_class,cost_price,reorder_point").eq("company_id", company).is("deleted_at", null).order("name").limit(5000),
      supabase.from("stock_balances").select("product_id,quantity").eq("company_id", company).is("deleted_at", null).limit(20000),
    ]);
    kpis = (k as Kpis) ?? {};
    suggestions = sg ?? []; products = pr ?? []; balances = bl ?? [];
  }

  const onHand: Record<string, number> = {};
  for (const b of balances) onHand[b.product_id] = (onHand[b.product_id] ?? 0) + (Number(b.quantity) || 0);
  const stock = products
    .map((p) => ({ ...p, on_hand: onHand[p.id] ?? 0 }))
    .sort((a, b) => (b.on_hand * (b.cost_price ?? 0)) - (a.on_hand * (a.cost_price ?? 0)));
  const prodName = Object.fromEntries(products.map((p) => [p.id, p.name]));

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">▦</div>
        <div>
          <h1 className="text-xl font-bold">Estoque Inteligente</h1>
          <p className="text-sm muted">Volume 10 · Saldos, curva ABC, ponto de pedido e ressuprimento</p>
        </div>
      </div>

      {!supabase && <VitrineBanner />}

      <div className="grid grid-cols-2 lg:grid-cols-6 gap-3">
        <KpiCard label="SKUs ativos" value={kpis.skus_active ?? "—"} />
        <KpiCard label="Valor em estoque" value={kpis.stock_value != null ? money(kpis.stock_value) : "—"} accent />
        <KpiCard label="Abaixo do ponto" value={kpis.below_reorder ?? "—"} hint="ressuprimento" />
        <KpiCard label="Vencendo 30d" value={kpis.expiring_30d ?? "—"} />
        <KpiCard label="Recebimentos abertos" value={kpis.open_receipts ?? "—"} />
        <KpiCard label="Tarefas pendentes" value={kpis.pending_tasks ?? "—"} />
      </div>

      <EstoqueWorkbench suggestions={suggestions} stock={stock} prodName={prodName} />
    </div>
  );
}
