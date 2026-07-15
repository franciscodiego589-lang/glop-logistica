import DispatchWorkbench from "@/components/postagens/DispatchWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function PostagensPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Torre de Postagens</h1><VitrineBanner /></div>;
  }
  const [dash, dispatches, issues] = await Promise.all([
    supabase.rpc("dispatch_dashboard", { p_company: company }),
    supabase.from("dispatches").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(2000),
    supabase.from("dispatch_issues").select("*").eq("company_id", company).eq("status", "open").is("deleted_at", null).order("severity").limit(500),
  ]);
  return <DispatchWorkbench dash={dash.data ?? {}} dispatches={dispatches.data ?? []} issues={issues.data ?? []} />;
}
