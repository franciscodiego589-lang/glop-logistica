import EstoqueLogisticoWorkbench from "@/components/estoque-logistico/EstoqueLogisticoWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function EstoqueLogisticoPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Estoque Logístico</h1><VitrineBanner /></div>;
  }
  const [produtos, locais, movimentos, baixaConfig, registros] = await Promise.all([
    supabase.from("estoque_produtos").select("*").eq("company_id", company).is("deleted_at", null).order("nome").limit(500),
    supabase.from("estoque_locais").select("*").eq("company_id", company).is("deleted_at", null).order("nome").limit(300),
    supabase.from("estoque_movimentos").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("estoque_baixa_config").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("registro_estoque").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
  ]);
  return <EstoqueLogisticoWorkbench
    produtos={produtos.data ?? []}
    locais={locais.data ?? []}
    movimentos={movimentos.data ?? []}
    baixaConfig={baixaConfig.data ?? []}
    registros={registros.data ?? []}
  />;
}
