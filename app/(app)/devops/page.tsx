import EDOPWorkbench from "@/components/devops/EDOPWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function DevopsPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">DevSecOps & Observabilidade</h1><VitrineBanner /></div>;
  }
  const [dash, services, pipelines, runs, deployments, incidents] = await Promise.all([
    supabase.rpc("edop_dashboard", { p_company: company }),
    supabase.from("services").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("pipelines").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(100),
    supabase.from("pipeline_runs").select("*").eq("company_id", company).is("deleted_at", null).order("started_at", { ascending: false }).limit(100),
    supabase.from("platform_deployments").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
    supabase.from("ops_incidents").select("*").eq("company_id", company).is("deleted_at", null).order("started_at", { ascending: false }).limit(100),
  ]);
  return <EDOPWorkbench dash={dash.data ?? {}} services={services.data ?? []} pipelines={pipelines.data ?? []} runs={runs.data ?? []} deployments={deployments.data ?? []} incidents={incidents.data ?? []} />;
}
