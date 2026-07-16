import { createClient } from "@/lib/supabase/server";
import { VitrineBanner } from "@/components/VitrineBanner";
import ContasWorkbench from "@/components/financeiro/ContasWorkbench";

export const dynamic = "force-dynamic";

export default async function ContasPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-2xl font-extrabold">Contas a Pagar & Receber</h1><VitrineBanner /></div>;
  }
  const { data } = await supabase.from("financeiro_contas")
    .select("id,tipo,descricao,categoria,valor,vencimento,pago,pago_em,forma_pagamento,observacoes")
    .eq("company_id", company).is("deleted_at", null).order("vencimento").limit(1000);
  return <ContasWorkbench contas={data ?? []} />;
}
