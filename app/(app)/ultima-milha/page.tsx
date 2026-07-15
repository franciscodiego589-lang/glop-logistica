import LMDPWorkbench from "@/components/ultima-milha/LMDPWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function UltimaMilhaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Última Milha (LMDP)</h1><VitrineBanner /></div>;
  }
  const [dash, routes, stops, pods, geofences, deliveries, attempts] = await Promise.all([
    supabase.rpc("lmdp_dashboard", { p_company: company }),
    supabase.from("routes").select("*").eq("company_id", company).is("deleted_at", null).order("planned_date", { ascending: false }).limit(100),
    supabase.from("route_stops").select("*").eq("company_id", company).is("deleted_at", null).order("sequence").limit(500),
    supabase.from("proof_of_delivery").select("*").eq("company_id", company).is("deleted_at", null).order("delivered_at", { ascending: false }).limit(200),
    supabase.from("geofences").select("*").eq("company_id", company).is("deleted_at", null).order("geofence_type").limit(200),
    supabase.from("deliveries").select("*").eq("company_id", company).is("deleted_at", null).order("scheduled_date", { ascending: false }).limit(300),
    supabase.from("delivery_attempts").select("*").eq("company_id", company).order("created_at", { ascending: false }).limit(200),
  ]);
  return <LMDPWorkbench dash={dash.data ?? {}} routes={routes.data ?? []} stops={stops.data ?? []} pods={pods.data ?? []}
    geofences={geofences.data ?? []} deliveries={deliveries.data ?? []} attempts={attempts.data ?? []} />;
}
