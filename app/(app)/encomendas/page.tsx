import PMSWorkbench from "@/components/encomendas/PMSWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function EncomendasPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Encomendas & Volumes (PMS)</h1><VitrineBanner /></div>;
  }
  const [dash, volumes, hubs, labels, scans, lockers, assignments, consolidations] = await Promise.all([
    supabase.rpc("pms_dashboard", { p_company: company }),
    supabase.from("volumes").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("hubs").select("*").eq("company_id", company).is("deleted_at", null).order("hub_type").limit(100),
    supabase.from("parcel_labels").select("*").eq("company_id", company).is("deleted_at", null).order("printed_at", { ascending: false }).limit(200),
    supabase.from("scan_events").select("*").eq("company_id", company).is("deleted_at", null).order("scanned_at", { ascending: false }).limit(300),
    supabase.from("lockers").select("*").eq("company_id", company).is("deleted_at", null).order("code").limit(100),
    supabase.from("locker_assignments").select("*").eq("company_id", company).is("deleted_at", null).order("assigned_at", { ascending: false }).limit(200),
    supabase.from("parcel_consolidations").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
  ]);
  return <PMSWorkbench dash={dash.data ?? {}} volumes={volumes.data ?? []} hubs={hubs.data ?? []} labels={labels.data ?? []}
    scans={scans.data ?? []} lockers={lockers.data ?? []} assignments={assignments.data ?? []} consolidations={consolidations.data ?? []} />;
}
