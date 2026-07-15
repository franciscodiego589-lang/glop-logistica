import OMSWorkbench from "@/components/pedidos/OMSWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function PedidosPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Gestão de Pedidos (OMS)</h1><VitrineBanner /></div>;
  }
  const [dash, orders, items, events, products, accounts] = await Promise.all([
    supabase.rpc("oms_dashboard", { p_company: company }),
    supabase.from("sales_orders").select("*").eq("company_id", company).is("deleted_at", null).order("order_number", { ascending: false }).limit(300),
    supabase.from("sales_order_items").select("*").eq("company_id", company).is("deleted_at", null).limit(1000),
    supabase.from("order_events").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: true }).limit(1000),
    supabase.from("products").select("id, name, sku, sale_price, is_sellable").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
    supabase.from("crm_accounts").select("id, name, credit_limit").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
  ]);
  return <OMSWorkbench dash={dash.data ?? {}} orders={orders.data ?? []} items={items.data ?? []} events={events.data ?? []} products={products.data ?? []} accounts={accounts.data ?? []} />;
}
