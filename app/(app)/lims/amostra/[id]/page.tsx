import { notFound } from "next/navigation";
import SampleDetail from "@/components/lims/SampleDetail";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function AmostraPage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  if (!supabase) notFound();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;

  const { data: sample } = await supabase.from("lab_samples").select("*").eq("id", params.id).is("deleted_at", null).single();
  if (!sample) notFound();

  const [{ data: tests }, { data: methods }, { data: specs }, { data: lot }] = await Promise.all([
    supabase.from("lab_tests").select("id,parameter,test_kind,result_value,result_text,unit,spec_min,spec_max,conforms,status,analyst").eq("sample_id", params.id).is("deleted_at", null).order("created_at").limit(500),
    supabase.from("lab_methods").select("id,name,code").eq("company_id", company).is("deleted_at", null).order("name").limit(1000),
    sample.product_id
      ? supabase.from("product_specifications").select("id,parameter,test_kind,min_value,max_value,unit,method_id").eq("company_id", company).eq("product_id", sample.product_id).is("deleted_at", null).limit(500)
      : Promise.resolve({ data: [] as any[] }),
    sample.lot_id
      ? supabase.from("product_lots").select("lot_number,quality_status").eq("id", sample.lot_id).maybeSingle()
      : Promise.resolve({ data: null as any }),
  ]);

  return <SampleDetail sample={sample} tests={tests ?? []} methods={methods ?? []} specs={specs ?? []} lot={lot ?? null} />;
}
