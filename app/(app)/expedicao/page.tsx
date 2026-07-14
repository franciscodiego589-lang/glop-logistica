import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import ExpedicaoWorkbench from "@/components/expedicao/ExpedicaoWorkbench";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";
const money = (n: number) => n.toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 });

export default async function ExpedicaoPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let orders: any[] = [], customers: any[] = [], warehouses: any[] = [];
  if (supabase && company) {
    const [o, c, w] = await Promise.all([
      supabase.from("outbound_orders").select("id,code,status,customer_id,ship_to_city,ship_to_uf,total,required_date").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
      supabase.from("customers").select("id,name,customer_type,document,email,phone,city,uf,credit_limit").eq("company_id", company).is("deleted_at", null).order("name").limit(3000),
      supabase.from("warehouses").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
    ]);
    orders = o.data ?? []; customers = c.data ?? []; warehouses = w.data ?? [];
  }
  const toShip = orders.filter((o) => !["shipped", "delivered", "invoiced", "canceled"].includes(o.status)).length;
  const shipped = orders.filter((o) => ["shipped", "delivered", "invoiced"].includes(o.status)).length;
  const value = orders.filter((o) => o.status !== "canceled").reduce((a, o) => a + (Number(o.total) || 0), 0);

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">📦</div>
        <div>
          <h1 className="text-xl font-bold">Expedição</h1>
          <p className="text-sm muted">Volume 12 · Pedidos de saída, separação, embarque e baixa de estoque</p>
        </div>
      </div>
      {!supabase && <VitrineBanner />}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <KpiCard label="Pedidos" value={orders.length || "—"} />
        <KpiCard label="A expedir" value={toShip || "—"} accent />
        <KpiCard label="Expedidos" value={shipped || "—"} />
        <KpiCard label="Valor em pedidos" value={value ? money(value) : "—"} />
      </div>
      <ExpedicaoWorkbench data={{ orders, customers, warehouses }} />
    </div>
  );
}
