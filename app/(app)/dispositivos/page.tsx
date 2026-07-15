import ESAPWorkbench from "@/components/dispositivos/ESAPWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function DispositivosPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Super App & Dispositivos</h1><VitrineBanner /></div>;
  }
  const [dash, devices, syncItems, notifications, profiles] = await Promise.all([
    supabase.rpc("esap_dashboard", { p_company: company }),
    supabase.from("devices").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("sync_queue").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("push_notifications").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
    supabase.from("mobile_profiles").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(50),
  ]);
  return <ESAPWorkbench dash={dash.data ?? {}} devices={devices.data ?? []} syncItems={syncItems.data ?? []} notifications={notifications.data ?? []} profiles={profiles.data ?? []} />;
}
