import DCPWorkbench from "@/components/commerce/DCPWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function CommercePage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Loja & Comércio Digital (DCP)</h1><VitrineBanner /></div>;
  }
  const [dash, stores, priceLists, promotions, subscriptions, listings, pages, products, accounts] = await Promise.all([
    supabase.rpc("dcp_dashboard", { p_company: company }),
    supabase.from("stores").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("price_lists").select("*").eq("company_id", company).is("deleted_at", null).order("priority", { ascending: false }).limit(200),
    supabase.from("promotions").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("subscriptions").select("*").eq("company_id", company).is("deleted_at", null).order("next_charge").limit(300),
    supabase.from("marketplace_listings").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("cms_pages").select("*").eq("company_id", company).is("deleted_at", null).order("title").limit(200),
    supabase.from("products").select("id, name, sku, sale_price, is_sellable").eq("company_id", company).is("deleted_at", null).order("name").limit(200),
    supabase.from("crm_accounts").select("id, name").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
  ]);
  return <DCPWorkbench dash={dash.data ?? {}} stores={stores.data ?? []} priceLists={priceLists.data ?? []} promotions={promotions.data ?? []}
    subscriptions={subscriptions.data ?? []} listings={listings.data ?? []} pages={pages.data ?? []} products={products.data ?? []} accounts={accounts.data ?? []} />;
}
