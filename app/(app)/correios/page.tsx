import CorreiosWorkbench from "@/components/correios/CorreiosWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function CorreiosPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Correios</h1><VitrineBanner /></div>;
  }
  const [dash, objects, divergences, plps, contracts, services] = await Promise.all([
    supabase.rpc("correios_dashboard", { p_company: company }),
    supabase.from("postal_objects").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(1000),
    supabase.from("freight_divergences").select("*").eq("company_id", company).eq("status", "open").is("deleted_at", null).order("difference", { ascending: false }).limit(500),
    supabase.from("plps").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("postal_contracts").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(200),
    supabase.from("postal_services").select("*").eq("company_id", company).is("deleted_at", null).order("base_price").limit(200),
  ]);
  return <CorreiosWorkbench dash={dash.data ?? {}} objects={objects.data ?? []} divergences={divergences.data ?? []} plps={plps.data ?? []} contracts={contracts.data ?? []} services={services.data ?? []} />;
}
