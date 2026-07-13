import { notFound } from "next/navigation";
import ProductEditor from "@/components/produtos/ProductEditor";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function ProdutoEditPage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  if (!supabase) notFound();
  const { data } = await supabase.from("products").select("*").eq("id", params.id).is("deleted_at", null).single();
  if (!data) notFound();
  return <ProductEditor product={data} />;
}
