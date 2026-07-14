import { notFound } from "next/navigation";
import OutboundDetail from "@/components/expedicao/OutboundDetail";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function OutboundPage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  if (!supabase) notFound();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  const { data: order } = await supabase.from("outbound_orders").select("*").eq("id", params.id).is("deleted_at", null).single();
  if (!order) notFound();
  const [{ data: items }, { data: customers }, { data: warehouses }, { data: products }] = await Promise.all([
    supabase.from("outbound_order_items").select("id,product_id,quantity,uom_code,unit_price,total,shipped_quantity").eq("outbound_order_id", params.id).is("deleted_at", null).order("created_at").limit(1000),
    supabase.from("customers").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(3000),
    supabase.from("warehouses").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
    supabase.from("products").select("id,name,sku,sale_price,base_uom_code").eq("company_id", company).is("deleted_at", null).order("name").limit(5000),
  ]);
  return <OutboundDetail order={order} items={items ?? []} customers={customers ?? []} warehouses={warehouses ?? []} products={products ?? []} />;
}
