import EPAWorkbench from "@/components/admin/EPAWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function AdminPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Administração da Plataforma</h1><VitrineBanner /></div>;
  }
  const [dash, settings, history, flags, currencies, languages, environments, modules, licenses] = await Promise.all([
    supabase.rpc("epa_dashboard", { p_company: company }),
    supabase.from("platform_settings").select("*").eq("company_id", company).is("deleted_at", null).order("category").order("setting_key").limit(500),
    supabase.from("config_history").select("setting_key").eq("company_id", company).is("deleted_at", null).limit(1000),
    supabase.from("feature_flags").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("currencies").select("*").eq("company_id", company).is("deleted_at", null).order("is_base", { ascending: false }).limit(50),
    supabase.from("languages").select("*").eq("company_id", company).is("deleted_at", null).order("is_default", { ascending: false }).limit(50),
    supabase.from("environments").select("*").eq("company_id", company).is("deleted_at", null).order("env_type").limit(50),
    supabase.from("module_registry").select("*").eq("company_id", company).is("deleted_at", null).order("category").order("name").limit(200),
    supabase.from("licenses").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1),
  ]);
  const changedKeys = Array.from(new Set((history.data ?? []).map((h: any) => h.setting_key)));
  return <EPAWorkbench dash={dash.data ?? {}} settings={settings.data ?? []} changedKeys={changedKeys} flags={flags.data ?? []}
    currencies={currencies.data ?? []} languages={languages.data ?? []} environments={environments.data ?? []} modules={modules.data ?? []} license={(licenses.data ?? [])[0] ?? null} />;
}
