import NfeWorkbench from "@/components/nfe/NfeWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function NfePage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">NFe — Emissões</h1><VitrineBanner /></div>;
  }
  const [emissoes, baixaConfig] = await Promise.all([
    supabase.from("nfe_emissoes").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("nfe_baixa_estoque_config").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
  ]);
  return <NfeWorkbench
    emissoes={emissoes.data ?? []}
    baixaConfig={baixaConfig.data ?? []}
  />;
}
