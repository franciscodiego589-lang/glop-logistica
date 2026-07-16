import PrepostagemWorkbench from "@/components/prepostagem/PrepostagemWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function PrepostagemPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Prepostagem Correios</h1><VitrineBanner /></div>;
  }
  const base = (t: string, order: string) => supabase.from(t).select("*").eq("company_id", company).is("deleted_at", null).order(order, { ascending: false }).limit(200);
  const [prepostagens, ppn, conferencias, cepLogs, autoLogs] = await Promise.all([
    base("prepostagens", "created_at"),
    base("prepostagens_ppn", "created_at"),
    supabase.from("conferencias_postagem").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
    base("cep_correcao_logs", "created_at"),
    base("prepostagem_auto_logs", "created_at"),
  ]);
  return <PrepostagemWorkbench
    prepostagens={prepostagens.data ?? []}
    ppn={ppn.data ?? []}
    conferencias={conferencias.data ?? []}
    cepLogs={cepLogs.data ?? []}
    autoLogs={autoLogs.data ?? []}
  />;
}
