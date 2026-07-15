import GTMOpsWorkbench from "@/components/embarques-internacionais/GTMOpsWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function EmbarquesInternacionaisPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Embarques Internacionais (GTM)</h1><VitrineBanner /></div>;
  }
  const [dash, shipments, bookings, agents, incoterms, events, routes] = await Promise.all([
    supabase.rpc("gtm_ops_dashboard", { p_company: company }),
    supabase.from("intl_shipments").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("trade_bookings").select("*").eq("company_id", company).is("deleted_at", null).order("cutoff_date").limit(200),
    supabase.from("shipping_agents").select("*").eq("company_id", company).is("deleted_at", null).order("code").limit(200),
    supabase.from("incoterms").select("*").eq("company_id", company).is("deleted_at", null).order("code").limit(50),
    supabase.from("trade_shipment_events").select("*").eq("company_id", company).is("deleted_at", null).order("event_at", { ascending: false }).limit(400),
    supabase.from("trade_routes").select("*").eq("company_id", company).is("deleted_at", null).order("leg_seq").limit(200),
  ]);
  return <GTMOpsWorkbench dash={dash.data ?? {}} shipments={shipments.data ?? []} bookings={bookings.data ?? []} agents={agents.data ?? []}
    incoterms={incoterms.data ?? []} events={events.data ?? []} routes={routes.data ?? []} />;
}
