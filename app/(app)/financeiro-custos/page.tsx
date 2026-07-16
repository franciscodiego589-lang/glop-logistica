import { createClient } from "@/lib/supabase/server";
import { VitrineBanner } from "@/components/VitrineBanner";
import FinanceiroCustosWorkbench from "@/components/financeiro/FinanceiroCustosWorkbench";

export const dynamic = "force-dynamic";

export default async function FinanceiroCustosPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-2xl font-extrabold">Custos & Despesas</h1><VitrineBanner /></div>;
  }
  const [despesas, custos] = await Promise.all([
    supabase.from("financeiro_despesas").select("id,descricao,categoria,tipo,valor,competencia,recorrente,observacoes").eq("company_id", company).is("deleted_at", null).order("competencia", { ascending: false }).limit(500),
    supabase.from("financeiro_custos_produto").select("id,produto_nome,sku,custo_unitario,frete_medio,taxa_gateway_pct,observacoes").eq("company_id", company).is("deleted_at", null).order("produto_nome").limit(500),
  ]);
  return <FinanceiroCustosWorkbench despesas={despesas.data ?? []} custos={custos.data ?? []} />;
}
