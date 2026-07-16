import { createClient } from "@/lib/supabase/server";
import { VitrineBanner } from "@/components/VitrineBanner";
import ProducaoWorkbench from "@/components/producao/ProducaoWorkbench";

export const dynamic = "force-dynamic";

export default async function ProducaoPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-2xl font-extrabold">Produção & Lotes</h1><VitrineBanner /></div>;
  }
  const [ordens, lotes] = await Promise.all([
    supabase.from("producao_ordens").select("id,numero,produto_nome,quantidade,unidade,status,data_prevista,data_conclusao,responsavel,observacoes").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(500),
    supabase.from("producao_lotes").select("id,lote,produto_nome,quantidade,fabricacao,validade,status,observacoes").eq("company_id", company).is("deleted_at", null).order("validade", { ascending: true }).limit(500),
  ]);
  return <ProducaoWorkbench ordens={ordens.data ?? []} lotes={lotes.data ?? []} />;
}
