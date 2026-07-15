import TransportTower from "@/components/transporte/TransportTower";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function TransportePage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Torre de Transporte</h1><VitrineBanner /></div>;
  }
  const [dash, shipments, occurrences, carriers] = await Promise.all([
    supabase.rpc("transport_control_tower", { p_company: company }),
    supabase.from("shipments").select("id,code,tracking_code,carrier_id,dest_city,dest_uf,status,estimated_delivery,risk_score,last_location,last_event_at,cargo_value").eq("company_id", company).in("status", ["dispatched", "in_transit"]).is("deleted_at", null).order("risk_score", { ascending: false, nullsFirst: false }).limit(1000),
    supabase.from("transport_occurrences").select("*").eq("company_id", company).neq("status", "resolved").is("deleted_at", null).order("severity").limit(500),
    supabase.from("carriers").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
  ]);
  return <TransportTower dash={dash.data ?? {}} shipments={shipments.data ?? []} occurrences={occurrences.data ?? []} carriers={carriers.data ?? []} />;
}
