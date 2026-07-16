import CorreiosCentralWorkbench from "@/components/correios-central/CorreiosCentralWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function CorreiosCentralPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Correios — Central Única</h1><VitrineBanner /></div>;
  }

  const [prepostagens, ppn, conferencias, cepLogs, contratos, remetente, apiLogs, autoLogs, connRes] = await Promise.all([
    // Tabelas legadas (id bigint) — sem company_id/deleted_at. Só metadados seguros, nunca base64/payload.
    supabase.from("prepostagens")
      .select("id,venda_id,servico_codigo,servico_nome,peso_g,altura_cm,largura_cm,comprimento_cm,valor_declarado,destinatario_nome,destinatario_cep,destinatario_cidade,destinatario_estado,codigo_objeto,id_prepostagem,status,erro,created_at,ultimo_status,ultimo_status_data,ultimo_status_local")
      .order("created_at", { ascending: false }).limit(200),
    supabase.from("prepostagens_ppn")
      .select("id,id_prepostagem,codigo_objeto,destinatario_nome,data_postagem,status,servico_codigo,servico_nome,destinatario_cidade,destinatario_estado,valor_total,ultima_sincronizacao,ultimo_status,ultimo_status_data,ultimo_status_local,ultima_consulta_sro,created_at")
      .order("created_at", { ascending: false }).limit(200),
    supabase.from("conferencias_postagem")
      .select("id,planilha_nome,pdf_nome,total_planilha,total_postados,total_nao_encontrados,total_possiveis,created_at")
      .order("created_at", { ascending: false }).limit(100),
    supabase.from("cep_correcao_logs")
      .select("id,created_at,destino,cep_original,cep_corrigido,fonte,enviado_sislog,observacao")
      .order("created_at", { ascending: false }).limit(200),
    // NUNCA selecionar correios_api_token
    supabase.from("contratos_logisticos")
      .select("id,nome,transportadora,agf_nome,cidade,uf,codigo_contrato,cartao_postagem,codigo_administrativo,codigo_diretoria,numero_dr,observacao,ativo,created_at")
      .order("created_at", { ascending: false }).limit(100),
    supabase.from("remetente_config")
      .select("id,nome,documento,email,telefone,cep,endereco,numero,bairro,cidade,estado,numero_contrato,numero_cartao_postagem,numero_dr,codigo_diretoria,updated_at")
      .limit(5),
    supabase.from("correios_api_logs")
      .select("id,created_at,prefixo,acao,status,http_status,codigo_rastreio,mensagem,duracao_ms")
      .order("created_at", { ascending: false }).limit(200),
    supabase.from("prepostagem_auto_logs")
      .select("id,created_at,plataforma,plano_codigo,etapa,status,mensagem,codigo_objeto")
      .order("created_at", { ascending: false }).limit(200),
    // Conector Correios — SEM segredos (só metadados/status para exibir "configurada")
    supabase.from("store_connectors")
      .select("id,code,name,platform,categoria,status,metadata,last_event_at")
      .eq("company_id", company).eq("platform", "correios").is("deleted_at", null).limit(10),
  ]);

  return <CorreiosCentralWorkbench
    prepostagens={prepostagens.data ?? []}
    ppn={ppn.data ?? []}
    conferencias={conferencias.data ?? []}
    cepLogs={cepLogs.data ?? []}
    contratos={contratos.data ?? []}
    remetente={remetente.data ?? []}
    apiLogs={apiLogs.data ?? []}
    autoLogs={autoLogs.data ?? []}
    connectors={connRes.data ?? []}
  />;
}
