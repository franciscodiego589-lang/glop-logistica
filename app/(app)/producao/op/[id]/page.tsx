import { notFound } from "next/navigation";
import ProductionOrderDetail from "@/components/producao/ProductionOrderDetail";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function OpPage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  if (!supabase) notFound();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;

  const { data: order } = await supabase.from("production_orders").select("*").eq("id", params.id).is("deleted_at", null).single();
  if (!order) notFound();

  const [{ data: ops }, { data: cons }, { data: products }, { data: workCenters }] = await Promise.all([
    supabase.from("production_operations").select("id,operation_seq,name,status,work_center_id,planned_minutes,actual_minutes")
      .eq("production_order_id", params.id).is("deleted_at", null).order("operation_seq").limit(500),
    supabase.from("production_consumptions").select("id,component_product_id,planned_quantity,consumed_quantity")
      .eq("production_order_id", params.id).is("deleted_at", null).limit(500),
    supabase.from("products").select("id,name,sku,base_uom_code").eq("company_id", company).is("deleted_at", null).order("name").limit(5000),
    supabase.from("work_centers").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(1000),
  ]);

  return (
    <ProductionOrderDetail
      order={order}
      operations={ops ?? []}
      consumptions={cons ?? []}
      products={products ?? []}
      workCenters={workCenters ?? []}
    />
  );
}
