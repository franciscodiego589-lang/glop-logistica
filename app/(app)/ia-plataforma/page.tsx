import EAAFWorkbench from "@/components/ia/EAAFWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function IaPlataformaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">IA & Automação (EAAF)</h1><VitrineBanner /></div>;
  }
  const [dash, providers, models, prompts, tools, usage] = await Promise.all([
    supabase.rpc("eaaf_dashboard", { p_company: company }),
    supabase.from("ai_providers").select("*").eq("company_id", company).is("deleted_at", null).order("is_default", { ascending: false }).limit(50),
    supabase.from("ai_models").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("ai_prompts").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("ai_tools").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("ai_usage_logs").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
  ]);
  return <EAAFWorkbench dash={dash.data ?? {}} providers={providers.data ?? []} models={models.data ?? []} prompts={prompts.data ?? []} tools={tools.data ?? []} usage={usage.data ?? []} />;
}
