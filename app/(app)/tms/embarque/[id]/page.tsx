import { notFound } from "next/navigation";
import ShipmentDetail from "@/components/tms/ShipmentDetail";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function EmbarquePage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  if (!supabase) notFound();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;

  const { data: shipment } = await supabase.from("shipments").select("*").eq("id", params.id).is("deleted_at", null).single();
  if (!shipment) notFound();

  const [{ data: events }, { data: carriers }, { data: vehicles }, { data: drivers }] = await Promise.all([
    supabase.from("shipment_events").select("id,event_type,description,location_text,occurred_at,is_exception")
      .eq("shipment_id", params.id).is("deleted_at", null).order("occurred_at", { ascending: false }).limit(500),
    supabase.from("carriers").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(1000),
    supabase.from("vehicles").select("id,plate,carrier_id").eq("company_id", company).is("deleted_at", null).order("plate").limit(2000),
    supabase.from("drivers").select("id,name,carrier_id").eq("company_id", company).is("deleted_at", null).order("name").limit(2000),
  ]);

  return (
    <ShipmentDetail
      shipment={shipment}
      events={events ?? []}
      carriers={carriers ?? []}
      vehicles={vehicles ?? []}
      drivers={drivers ?? []}
    />
  );
}
