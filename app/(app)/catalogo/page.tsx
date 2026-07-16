import { createClient } from "@/lib/supabase/server";
import { VitrineBanner } from "@/components/VitrineBanner";
import CatalogoWorkbench from "@/components/catalogo/CatalogoWorkbench";

export const dynamic = "force-dynamic";

export default async function CatalogoPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-2xl font-extrabold">Catálogo de Produtos</h1><VitrineBanner /></div>;
  }
  const { data } = await supabase.from("catalogo_produtos")
    .select("id,sku,nome,categoria,preco,custo,peso_g,altura_cm,largura_cm,comprimento_cm,estoque_atual,estoque_minimo,foto_url,tipo,ativo")
    .eq("company_id", company).is("deleted_at", null).order("nome").limit(1000);
  return <CatalogoWorkbench produtos={data ?? []} />;
}
