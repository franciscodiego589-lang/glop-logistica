import CMPWorkbench from "@/components/transportadoras/CMPWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function TransportadorasPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Transportadoras (CMP)</h1><VitrineBanner /></div>;
  }
  const [dash, ranking, carriers, docs, contracts, occ] = await Promise.all([
    supabase.rpc("cmp_dashboard", { p_company: company }),
    supabase.rpc("carrier_ranking", { p_company: company }),
    supabase.from("carriers").select("*").eq("company_id", company).is("deleted_at", null).order("code").limit(300),
    supabase.from("carrier_documents").select("*").eq("company_id", company).is("deleted_at", null).order("valid_to").limit(300),
    supabase.from("carrier_contracts").select("*").eq("company_id", company).is("deleted_at", null).order("end_date").limit(200),
    supabase.from("carrier_occurrences").select("*").eq("company_id", company).is("deleted_at", null).order("occurred_on", { ascending: false }).limit(300),
  ]);
  return <CMPWorkbench dash={dash.data ?? {}} ranking={ranking.data ?? []} carriers={carriers.data ?? []}
    docs={docs.data ?? []} contracts={contracts.data ?? []} occurrences={occ.data ?? []} />;
}
