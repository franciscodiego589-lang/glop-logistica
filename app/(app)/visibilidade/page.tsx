import SCVPWorkbench from "@/components/visibilidade/SCVPWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function VisibilidadePage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Visibilidade (SCVP)</h1><VitrineBanner /></div>;
  }
  const [dash, shipments, events, exceptions, shares] = await Promise.all([
    supabase.rpc("scvp_dashboard", { p_company: company }),
    supabase.from("scv_shipments").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("scv_events").select("*").eq("company_id", company).is("deleted_at", null).order("event_at", { ascending: false }).limit(500),
    supabase.from("scv_exceptions").select("*").eq("company_id", company).is("deleted_at", null).order("detected_at", { ascending: false }).limit(200),
    supabase.from("scv_shares").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
  ]);
  return <SCVPWorkbench dash={dash.data ?? {}} shipments={shipments.data ?? []} events={events.data ?? []}
    exceptions={exceptions.data ?? []} shares={shares.data ?? []} />;
}
