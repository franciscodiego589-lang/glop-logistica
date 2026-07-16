import { createClient } from "@/lib/supabase/server";
import { VitrineBanner } from "@/components/VitrineBanner";
import CrmWorkbench from "@/components/crm/CrmWorkbench";

export const dynamic = "force-dynamic";

export default async function CrmPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-2xl font-extrabold">CRM de Compradores</h1><VitrineBanner /></div>;
  }
  const { data } = await supabase.from("crm_compradores")
    .select("id,buyer_doc,nome,email,telefone,segmento,tags,observacoes")
    .eq("company_id", company).is("deleted_at", null).order("nome").limit(1000);
  return <CrmWorkbench compradores={data ?? []} />;
}
