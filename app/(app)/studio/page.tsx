import ELCPWorkbench from "@/components/studio/ELCPWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function StudioPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Studio (Low-Code / No-Code)</h1><VitrineBanner /></div>;
  }
  const [dash, apps, entities, records, templates, components] = await Promise.all([
    supabase.rpc("elcp_dashboard", { p_company: company }),
    supabase.from("custom_apps").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("custom_entities").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("custom_records").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(500),
    supabase.from("app_templates").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("custom_components").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
  ]);
  return <ELCPWorkbench dash={dash.data ?? {}} apps={apps.data ?? []} entities={entities.data ?? []} records={records.data ?? []} templates={templates.data ?? []} components={components.data ?? []} />;
}
