import { createClient } from "@/lib/supabase/server";
import { VitrineBanner } from "@/components/VitrineBanner";
import MetasWorkbench from "@/components/metas/MetasWorkbench";

export const dynamic = "force-dynamic";

export default async function MetasPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-2xl font-extrabold">Metas</h1><VitrineBanner /></div>;
  }
  const { data } = await supabase.from("metas")
    .select("id,nome,tipo,competencia,valor_meta,observacoes")
    .eq("company_id", company).is("deleted_at", null).order("competencia", { ascending: false }).limit(500);
  return <MetasWorkbench metas={data ?? []} />;
}
