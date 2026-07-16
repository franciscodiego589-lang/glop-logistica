import PlanosPrecosWorkbench from "@/components/planos-precos/PlanosPrecosWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function PlanosPrecosPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Planos &amp; Preços do Produtor</h1><VitrineBanner /></div>;
  }
  const q = (t: string) => supabase.from(t).select("*").eq("company_id", company).is("deleted_at", null);
  const [planos, produtoPrecos, precos, regras, freteFaixas, pesoFaixas] = await Promise.all([
    q("produtor_planos").order("plano_codigo").limit(500),
    q("produtor_produto_precos").order("produto_codigo").limit(500),
    q("produto_precos").order("produto_nome").limit(500),
    q("produto_regras").order("nome").limit(500),
    q("produtor_frete_faixas").order("qtd_min").limit(500),
    q("produtor_peso_faixas").order("qtd_min").limit(500),
  ]);
  return <PlanosPrecosWorkbench
    planos={planos.data ?? []}
    produtoPrecos={produtoPrecos.data ?? []}
    precos={precos.data ?? []}
    regras={regras.data ?? []}
    freteFaixas={freteFaixas.data ?? []}
    pesoFaixas={pesoFaixas.data ?? []}
  />;
}
