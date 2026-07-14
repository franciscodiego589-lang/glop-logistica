import { notFound } from "next/navigation";
import TransferDetail from "@/components/distribuicao/TransferDetail";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function TransferPage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  if (!supabase) notFound();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  const { data: transfer } = await supabase.from("stock_transfers").select("*").eq("id", params.id).is("deleted_at", null).single();
  if (!transfer) notFound();
  const [{ data: items }, { data: warehouses }, { data: products }] = await Promise.all([
    supabase.from("stock_transfer_items").select("id,product_id,quantity,received_quantity").eq("transfer_id", params.id).is("deleted_at", null).order("created_at").limit(1000),
    supabase.from("warehouses").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
    supabase.from("products").select("id,name,sku,base_uom_code").eq("company_id", company).is("deleted_at", null).order("name").limit(5000),
  ]);
  return <TransferDetail transfer={transfer} items={items ?? []} warehouses={warehouses ?? []} products={products ?? []} />;
}
