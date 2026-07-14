import { notFound } from "next/navigation";
import BomDetail from "@/components/mrp/BomDetail";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function BomPage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  if (!supabase) notFound();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;

  const { data: bom } = await supabase.from("bills_of_materials").select("*").eq("id", params.id).is("deleted_at", null).single();
  if (!bom) notFound();

  const [{ data: components }, { data: products }] = await Promise.all([
    supabase.from("bom_components").select("id,component_product_id,quantity,uom_code,scrap_percent,operation_seq")
      .eq("bom_id", params.id).is("deleted_at", null).order("operation_seq").limit(1000),
    supabase.from("products").select("id,name,sku,base_uom_code,cost_price").eq("company_id", company).is("deleted_at", null).order("name").limit(5000),
  ]);

  return <BomDetail bom={bom} components={components ?? []} products={products ?? []} />;
}
