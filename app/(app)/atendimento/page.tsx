import { createClient } from "@/lib/supabase/server";
import { VitrineBanner } from "@/components/VitrineBanner";
import AtendimentoWorkbench from "@/components/atendimento/AtendimentoWorkbench";

export const dynamic = "force-dynamic";

export default async function AtendimentoPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-2xl font-extrabold">Central de Atendimento</h1><VitrineBanner /></div>;
  }
  const { data } = await supabase.from("atendimento_tickets")
    .select("id,assunto,comprador_nome,sale_number,canal,prioridade,status,descricao,resposta,responsavel,created_at")
    .eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(500);
  return <AtendimentoWorkbench tickets={data ?? []} />;
}
