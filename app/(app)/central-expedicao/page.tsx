import SmartShipping from "@/components/central-expedicao/SmartShipping";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function CentralExpedicaoPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Central de Expedição</h1><VitrineBanner /></div>;
  }
  const [center, boxes, loads] = await Promise.all([
    supabase.rpc("shipping_center", { p_company: company }),
    supabase.from("packaging_boxes").select("*").eq("company_id", company).is("deleted_at", null).order("max_weight_g").limit(200),
    supabase.from("shipping_loads").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
  ]);
  return <SmartShipping center={center.data ?? {}} boxes={boxes.data ?? []} loads={loads.data ?? []} />;
}
