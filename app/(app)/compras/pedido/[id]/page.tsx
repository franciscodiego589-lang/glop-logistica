import { notFound } from "next/navigation";
import PurchaseOrderDetail from "@/components/compras/PurchaseOrderDetail";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function PedidoPage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  if (!supabase) notFound();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;

  const { data: po } = await supabase.from("purchase_orders").select("*").eq("id", params.id).is("deleted_at", null).single();
  if (!po) notFound();

  const [{ data: items }, { data: suppliers }, { data: warehouses }, { data: products }] = await Promise.all([
    supabase.from("purchase_order_items").select("id,product_id,quantity,uom_code,unit_cost,total,received_quantity")
      .eq("purchase_order_id", params.id).is("deleted_at", null).order("created_at").limit(1000),
    supabase.from("suppliers").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(1000),
    supabase.from("warehouses").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
    supabase.from("products").select("id,name,sku,cost_price,base_uom_code").eq("company_id", company).is("deleted_at", null).order("name").limit(5000),
  ]);

  return (
    <PurchaseOrderDetail
      po={po}
      items={items ?? []}
      suppliers={suppliers ?? []}
      warehouses={warehouses ?? []}
      products={products ?? []}
    />
  );
}
