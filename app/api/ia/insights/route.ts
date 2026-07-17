import { createClient } from "@/lib/supabase/server";
import { askClaudeJSON, iaConfigured, IA_NAO_CONFIGURADA } from "@/lib/anthropic";

export const dynamic = "force-dynamic";

// LOGIA — insights com IA. Monta um retrato dos dados e pede ao Claude uma lista
// priorizada de insights acionáveis (título, gravidade, o que fazer). Retorna JSON.

type Insight = { titulo: string; gravidade: "alta" | "media" | "baixa"; achado: string; acao: string };

const SYSTEM = `Você é a LOGIA, a inteligência do GLOP (ERP de dropshipping de suplementos da Lemoncaps, Correios/Monetizze/Braip).
Analise os dados reais e gere de 4 a 7 INSIGHTS acionáveis para o dono (leigo). Cada insight: titulo curto, gravidade (alta/media/baixa), achado (o número/fato que embasa) e acao (o que fazer agora, prático).
Baseie-se SOMENTE nos dados. Não invente. Priorize dinheiro parado, risco (bloqueios, lote vencendo, reembolso), e oportunidade (produto/UF forte). Responda APENAS um array JSON: [{"titulo","gravidade","achado","acao"}].`;

export async function POST() {
  if (!iaConfigured()) {
    return Response.json({ configured: false, insights: [], message: "IA não configurada. Cole a chave da Anthropic na Netlify (ANTHROPIC_API_KEY)." }, { status: 200 });
  }
  const supabase = createClient();
  if (!supabase) return Response.json({ error: "indisponível" }, { status: 500 });
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;

  const rpc = (fn: string, days?: number) =>
    supabase.rpc(fn, days === undefined ? { p_company: company } : { p_company: company, p_days: days })
      .then((r: any) => r.data, () => null);
  const [consolidado, anomalias, producao, regioes, abc, copro] = await Promise.all([
    rpc("rel_consolidado", 30), rpc("rel_anomalias", 30), rpc("rel_producao", 0),
    rpc("rel_regioes", 90), rpc("rel_abc", 90), rpc("rel_coproducao", 3650),
  ]);
  const slim = (d: any) => d && ({ titulo: d.titulo, kpis: d.kpis, secoes: (d.secoes ?? []).slice(0, 2) });
  const contexto = {
    consolidado_30d: slim(consolidado), anomalias_30d: slim(anomalias), producao_validade: slim(producao),
    regioes_90d: slim(regioes), curva_abc_90d: slim(abc), coproducao: slim(copro),
  };

  try {
    const insights = await askClaudeJSON<Insight[]>({
      system: SYSTEM,
      user: `DADOS REAIS DA EMPRESA:\n${JSON.stringify(contexto)}\n\nGere os insights (array JSON).`,
      maxTokens: 1400,
    });
    const clean = (Array.isArray(insights) ? insights : []).slice(0, 8).filter((i) => i && i.titulo);
    return Response.json({ configured: true, insights: clean }, { status: 200 });
  } catch (e: any) {
    if (e?.message === IA_NAO_CONFIGURADA) return Response.json({ configured: false, insights: [] }, { status: 200 });
    console.error("[ia/insights]", e?.message);
    return Response.json({ error: e?.message ?? "falha na IA" }, { status: 502 });
  }
}
