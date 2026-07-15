import AAWorkbench from "@/components/patrimonio/AAWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function PatrimonioPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Patrimônio & Ativos Fixos</h1><VitrineBanner /></div>;
  }
  const [dash, categories, assets, depreciations, revaluations, transfers, insurances, inventory] = await Promise.all([
    supabase.rpc("aa_dashboard", { p_company: company }),
    supabase.from("asset_categories").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(200),
    supabase.from("fixed_assets").select("*").eq("company_id", company).is("deleted_at", null).order("asset_code").limit(500),
    supabase.from("depreciation_entries").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("asset_revaluations").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
    supabase.from("asset_transfers").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
    supabase.from("asset_insurances").select("*").eq("company_id", company).is("deleted_at", null).order("valid_to", { ascending: false }).limit(200),
    supabase.from("asset_inventory_counts").select("*").eq("company_id", company).is("deleted_at", null).order("counted_at", { ascending: false }).limit(200),
  ]);
  return <AAWorkbench dash={dash.data ?? {}} categories={categories.data ?? []} assets={assets.data ?? []} depreciations={depreciations.data ?? []}
    revaluations={revaluations.data ?? []} transfers={transfers.data ?? []} insurances={insurances.data ?? []} inventory={inventory.data ?? []} />;
}
