import EnviosRastreamentoWorkbench from "@/components/envios-rastreamento/EnviosRastreamentoWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function EnviosRastreamentoPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Envios &amp; Rastreamento</h1><VitrineBanner /></div>;
  }
  const [envios, trackingEvents, clientes, notificacoes, reenvios, reenvioPagamentos, produtores] = await Promise.all([
    supabase.from("envios").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("tracking_events").select("*").eq("company_id", company).is("deleted_at", null).order("data_evento", { ascending: false }).limit(300),
    supabase.from("clientes_envio").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("notificacoes_carteiro_ausente").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("reenvios").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("reenvio_pagamentos").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(300),
    supabase.from("produtores_integracao").select("id, nome").eq("company_id", company).is("deleted_at", null).order("nome").limit(500),
  ]);
  return <EnviosRastreamentoWorkbench
    envios={envios.data ?? []}
    trackingEvents={trackingEvents.data ?? []}
    clientes={clientes.data ?? []}
    notificacoes={notificacoes.data ?? []}
    reenvios={reenvios.data ?? []}
    reenvioPagamentos={reenvioPagamentos.data ?? []}
    produtores={produtores.data ?? []}
  />;
}
