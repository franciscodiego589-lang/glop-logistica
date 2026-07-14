import { notFound } from "next/navigation";
import WarehouseDetail from "@/components/wms/WarehouseDetail";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function WarehouseDetailPage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  if (!supabase) notFound();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;

  const { data: wh } = await supabase
    .from("warehouses").select("*").eq("id", params.id).is("deleted_at", null).single();
  if (!wh) notFound();

  const [{ data: zones }, { data: locs }] = await Promise.all([
    supabase.from("storage_zones")
      .select("id,code,name,zone_type,temperature_controlled")
      .eq("warehouse_id", params.id).is("deleted_at", null).order("code").limit(2000),
    supabase.from("storage_locations")
      .select("id,code,location_type,status,zone_id,aisle,rack,level,position,is_pickable")
      .eq("warehouse_id", params.id).is("deleted_at", null).order("code").limit(20000),
  ]);

  return (
    <WarehouseDetail
      warehouse={wh}
      company={company ?? ""}
      zones={zones ?? []}
      locations={locs ?? []}
    />
  );
}
