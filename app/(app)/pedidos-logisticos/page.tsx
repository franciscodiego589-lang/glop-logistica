import LOMWorkbench from "@/components/lom/LOMWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function PedidosLogisticosPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Gestão de Pedidos Logísticos (LOM)</h1><VitrineBanner /></div>;
  }
  const [dash, orders, stages, events, products, warehouses, carriers] = await Promise.all([
    supabase.rpc("lom_dashboard", { p_company: company }),
    supabase.from("logistics_orders").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("logistics_stages").select("*").order("order_index"),
    supabase.from("event_bus").select("id,event_type,payload,occurred_at,subscribers_notified").eq("company_id", company).like("event_type", "logistics_order.%").order("occurred_at", { ascending: false }).limit(80),
    supabase.from("products").select("id,name,sku").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
    supabase.from("warehouses").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("carriers").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
  ]);
  return <LOMWorkbench dash={dash.data ?? {}} orders={orders.data ?? []} stages={stages.data ?? []}
    events={events.data ?? []} products={products.data ?? []} warehouses={warehouses.data ?? []} carriers={carriers.data ?? []} />;
}
