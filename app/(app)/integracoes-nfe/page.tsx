import IntegracoesNfeWorkbench from "@/components/integracoes-nfe/IntegracoesNfeWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function IntegracoesNfePage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Integrações &amp; Nota Fiscal</h1><VitrineBanner /></div>;
  }
  const [prodRes, nfe, baixa, apiKeys, apiLogs, webhookLogs, connRes] = await Promise.all([
    supabase.from("produtores_integracao")
      .select("id,nome,plataforma,ativo,monetizze_ativa,monetizze_api_key,braip_ativa,braip_api_token,sislog_ativa,sislog_cnpj_embarcador,vhsys_cliente_id,vhsys_id_almoxarifado,emissao_nfe_ativa,cnpj,razao_social,inscricao_estadual,nfe_cfop,nfe_natureza_operacao")
      .eq("company_id", company).is("deleted_at", null).order("nome").limit(50),
    supabase.from("nfe_emissoes").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("nfe_baixa_estoque_config").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("produtor_api_keys").select("id,nome,key_prefix,escopos,ativo,last_used_at,revoked_at,created_at").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(100),
    supabase.from("api_logs").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("webhook_logs").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    // conexões (SEM webhook_token) — para "Minhas conexões" e adicionar plataformas
    supabase.from("store_connectors").select("id,code,name,platform,producer_ref,status,categoria,metadata,last_event_at").eq("company_id", company).is("deleted_at", null).order("name").limit(300),
  ]);
  // Deriva o status das integrações SEM enviar nenhum segredo ao client.
  const produtores = (prodRes.data ?? []).map((p: any) => ({
    id: p.id, nome: p.nome, plataforma: p.plataforma, ativo: p.ativo,
    monetizze_ativa: p.monetizze_ativa, has_monetizze: !!p.monetizze_api_key,
    braip_ativa: p.braip_ativa, has_braip: !!p.braip_api_token,
    sislog_ativa: p.sislog_ativa, sislog_cnpj: p.sislog_cnpj_embarcador,
    has_vhsys: !!p.vhsys_cliente_id, vhsys_almox: p.vhsys_id_almoxarifado,
    emissao_nfe_ativa: p.emissao_nfe_ativa, cnpj: p.cnpj, razao_social: p.razao_social,
    inscricao_estadual: p.inscricao_estadual, nfe_cfop: p.nfe_cfop, nfe_natureza: p.nfe_natureza_operacao,
  }));
  return <IntegracoesNfeWorkbench
    produtores={produtores}
    nfe={nfe.data ?? []}
    baixa={baixa.data ?? []}
    apiKeys={apiKeys.data ?? []}
    apiLogs={apiLogs.data ?? []}
    webhookLogs={webhookLogs.data ?? []}
    connectors={connRes.data ?? []}
  />;
}
