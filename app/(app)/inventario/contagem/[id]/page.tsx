import { notFound } from "next/navigation";
import CountDetail from "@/components/inventario/CountDetail";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function CountPage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  if (!supabase) notFound();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  const { data: count } = await supabase.from("inventory_counts").select("*").eq("id", params.id).is("deleted_at", null).single();
  if (!count) notFound();
  const [{ data: items }, { data: products }] = await Promise.all([
    supabase.from("inventory_count_items").select("id,product_id,system_quantity,counted_quantity,difference,adjusted").eq("count_id", params.id).is("deleted_at", null).order("created_at").limit(2000),
    supabase.from("products").select("id,name,sku").eq("company_id", company).is("deleted_at", null).order("name").limit(5000),
  ]);
  return <CountDetail count={count} items={items ?? []} products={products ?? []} />;
}
