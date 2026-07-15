import FleetWorkbench from "@/components/frota/FleetWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function FrotaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">TMS Enterprise / Frota</h1><VitrineBanner /></div>;
  }
  const [dash, trips, maint, fuel, quotes, bids, contracts] = await Promise.all([
    supabase.rpc("tms_dashboard", { p_company: company }),
    supabase.from("trips").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(500),
    supabase.from("fleet_maintenance").select("*").eq("company_id", company).is("deleted_at", null).order("next_date").limit(500),
    supabase.from("fuel_logs").select("*").eq("company_id", company).is("deleted_at", null).order("filled_at", { ascending: false }).limit(500),
    supabase.from("freight_quote_requests").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("freight_quote_bids").select("*").eq("company_id", company).is("deleted_at", null).order("price").limit(500),
    supabase.from("freight_contracts").select("*").eq("company_id", company).is("deleted_at", null).order("valid_to").limit(300),
  ]);
  return <FleetWorkbench dash={dash.data ?? {}} trips={trips.data ?? []} maintenance={maint.data ?? []} fuel={fuel.data ?? []} quotes={quotes.data ?? []} bids={bids.data ?? []} contracts={contracts.data ?? []} />;
}
