import { createClient } from "@/lib/supabase/server";
import { VitrineBanner } from "@/components/VitrineBanner";
import InventarioWorkbench from "@/components/inventario/InventarioWorkbench";

export const dynamic = "force-dynamic";

export default async function InventarioContagemPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-2xl font-extrabold">Inventário / Contagem</h1><VitrineBanner /></div>;
  }
  const { data } = await supabase.from("estoque_inventario")
    .select("id,produto_nome,sku,local,qtd_sistema,qtd_contada,contado_em,responsavel,observacoes")
    .eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(500);
  return <InventarioWorkbench itens={data ?? []} />;
}
