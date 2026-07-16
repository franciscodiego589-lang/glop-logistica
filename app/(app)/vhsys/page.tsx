import VhsysWorkbench from "@/components/vhsys/VhsysWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function VhsysPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Integração VHSYS</h1><VitrineBanner /></div>;
  }
  const [saldos, movimentos, locais] = await Promise.all([
    supabase.from("vhsys_estoque_saldos").select("*").order("updated_at", { ascending: false }).limit(300),
    supabase.from("vhsys_estoque_movimentos").select("*").order("created_at", { ascending: false }).limit(300),
    supabase.from("vhsys_locais_estoque").select("*").order("nome").limit(300),
  ]);
  return <VhsysWorkbench
    saldos={saldos.data ?? []}
    movimentos={movimentos.data ?? []}
    locais={locais.data ?? []}
  />;
}
