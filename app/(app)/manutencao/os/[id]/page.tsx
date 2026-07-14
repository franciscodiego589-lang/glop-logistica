import { notFound } from "next/navigation";
import WorkOrderDetail from "@/components/manutencao/WorkOrderDetail";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function OsPage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  if (!supabase) notFound();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  const { data: wo } = await supabase.from("work_orders").select("*").eq("id", params.id).is("deleted_at", null).single();
  if (!wo) notFound();
  const [{ data: parts }, { data: failures }, { data: products }, { data: assets }] = await Promise.all([
    supabase.from("wo_parts").select("id,product_id,quantity,unit_cost,total").eq("work_order_id", params.id).is("deleted_at", null).limit(500),
    supabase.from("asset_failures").select("id,failure_type,severity,cause,root_cause,rca_method,downtime_minutes,occurred_at").eq("work_order_id", params.id).is("deleted_at", null).order("occurred_at", { ascending: false }).limit(200),
    supabase.from("products").select("id,name,sku,cost_price").eq("company_id", company).is("deleted_at", null).order("name").limit(5000),
    supabase.from("assets").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(2000),
  ]);
  return <WorkOrderDetail wo={wo} parts={parts ?? []} failures={failures ?? []} products={products ?? []} assets={assets ?? []} />;
}
