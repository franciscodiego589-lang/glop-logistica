import { notFound } from "next/navigation";
import RmaDetail from "@/components/devolucoes/RmaDetail";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function RmaPage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  if (!supabase) notFound();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  const { data: rma } = await supabase.from("rma_requests").select("*").eq("id", params.id).is("deleted_at", null).single();
  if (!rma) notFound();
  const [items, reasons, products, warehouses] = await Promise.all([
    supabase.from("rma_items").select("*").eq("rma_id", params.id).is("deleted_at", null).order("created_at").limit(500),
    supabase.from("return_reasons").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(300),
    supabase.from("products").select("id,name,sku").eq("company_id", company).is("deleted_at", null).order("name").limit(5000),
    supabase.from("warehouses").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
  ]);
  return <RmaDetail rma={rma} items={items.data ?? []} reasons={reasons.data ?? []} products={products.data ?? []} warehouses={warehouses.data ?? []} />;
}
