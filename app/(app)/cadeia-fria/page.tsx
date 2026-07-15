import CCLMSWorkbench from "@/components/cadeia-fria/CCLMSWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function CadeiaFriaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Cadeia Fria (CCLMS)</h1><VitrineBanner /></div>;
  }
  const [dash, shipments, categories, sensors, equipment, alarms, readings] = await Promise.all([
    supabase.rpc("cclms_dashboard", { p_company: company }),
    supabase.from("cold_shipments").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("cold_categories").select("*").eq("company_id", company).is("deleted_at", null).order("code").limit(100),
    supabase.from("cold_sensors").select("*").eq("company_id", company).is("deleted_at", null).order("code").limit(200),
    supabase.from("cold_equipment").select("*").eq("company_id", company).is("deleted_at", null).order("code").limit(200),
    supabase.from("cold_alarms").select("*").eq("company_id", company).is("deleted_at", null).order("triggered_at", { ascending: false }).limit(300),
    supabase.from("environmental_readings").select("*").eq("company_id", company).is("deleted_at", null).order("reading_at", { ascending: false }).limit(400),
  ]);
  return <CCLMSWorkbench dash={dash.data ?? {}} shipments={shipments.data ?? []} categories={categories.data ?? []}
    sensors={sensors.data ?? []} equipment={equipment.data ?? []} alarms={alarms.data ?? []} readings={readings.data ?? []} />;
}
