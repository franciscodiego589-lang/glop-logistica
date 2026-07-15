import SOIDIWorkbench from "@/components/importacao-pedidos/SOIDIWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function ImportacaoPedidosPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Importação de Pedidos (SOIDI)</h1><VitrineBanner /></div>;
  }
  const [dash, files, orders, validations, rules] = await Promise.all([
    supabase.rpc("soidi_dashboard", { p_company: company }),
    supabase.from("import_files").select("*").eq("company_id", company).is("deleted_at", null).order("received_at", { ascending: false }).limit(100),
    supabase.from("import_orders").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("import_validations").select("*").eq("company_id", company).is("deleted_at", null).eq("status", "open").limit(500),
    supabase.from("import_rules").select("*").eq("company_id", company).is("deleted_at", null).order("priority").limit(100),
  ]);
  return <SOIDIWorkbench dash={dash.data ?? {}} files={files.data ?? []} orders={orders.data ?? []}
    validations={validations.data ?? []} rules={rules.data ?? []} />;
}
