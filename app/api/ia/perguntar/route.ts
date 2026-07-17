import { createClient } from "@/lib/supabase/server";
import { askClaude, iaConfigured, IA_NAO_CONFIGURADA } from "@/lib/anthropic";

export const dynamic = "force-dynamic";

// Assistente em texto livre: monta um retrato dos dados reais da empresa (via RPCs
// seguros, com a sessão do usuário → RLS) e pede ao Claude para responder em PT-BR
// baseado SÓ nesse retrato. Sem chave da IA, responde com instrução amigável.

const SYSTEM = `Você é o assistente do GLOP, um ERP de logística/dropshipping de suplementos (Lemoncaps) que vende por Monetizze/Braip/checkouts e envia pelos Correios.
Responda em português do Brasil, de forma direta e curta (o dono é leigo em tecnologia).
REGRAS:
- Baseie-se SOMENTE nos dados do CONTEXTO fornecido. Não invente números.
- Se a pergunta pede algo que não está no contexto, diga que não tem esse dado aqui e sugira em qual tela ver (ex.: Relatórios, Custos & Despesas).
- Use R$ e formato brasileiro. Seja prático: se houver um problema (bloqueados, sem plano, lote vencendo), aponte a ação.
- Nunca peça dados sensíveis nem exponha CPF/chaves.`;

export async function POST(req: Request) {
  if (!iaConfigured()) {
    return Response.json({ answer: "🔌 A IA ainda não está configurada. Peça para o administrador colar a chave da Anthropic na Netlify (variável ANTHROPIC_API_KEY). Enquanto isso, use as perguntas rápidas acima — elas já funcionam." }, { status: 200 });
  }
  const supabase = createClient();
  if (!supabase) return Response.json({ error: "indisponível" }, { status: 500 });
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let body: any = {}; try { body = await req.json(); } catch {}
  const question = String(body.question ?? "").trim().slice(0, 500);
  if (!question) return Response.json({ error: "pergunta vazia" }, { status: 400 });

  // Retrato compacto do negócio (as mesmas fontes das perguntas rápidas).
  const rpc = (fn: string, days?: number) =>
    supabase.rpc(fn, days === undefined ? { p_company: company } : { p_company: company, p_days: days })
      .then((r: any) => r.data, () => null);
  const [consolidado, vendas7, alertas, lucro, producao, copro, sac] = await Promise.all([
    rpc("rel_consolidado", 30), rpc("rel_vendas", 7), rpc("alertas_resumo"),
    rpc("rel_lucro", 30), rpc("rel_producao", 0), rpc("rel_coproducao", 3650), rpc("rel_atendimento", 30),
  ]);

  const slim = (d: any) => d && ({ titulo: d.titulo, kpis: d.kpis, secoes: (d.secoes ?? []).slice(0, 3) });
  const contexto = {
    consolidado_30d: slim(consolidado),
    vendas_7d: slim(vendas7),
    alertas_agora: alertas?.itens ?? alertas,
    lucro_30d: slim(lucro),
    producao_validade: slim(producao),
    coproducao: slim(copro),
    atendimento_30d: slim(sac),
  };

  try {
    const answer = await askClaude({
      system: SYSTEM,
      user: `CONTEXTO (dados reais da empresa):\n${JSON.stringify(contexto)}\n\nPERGUNTA DO DONO: ${question}`,
      maxTokens: 700,
    });
    return Response.json({ answer: answer || "Não consegui gerar uma resposta agora." }, { status: 200 });
  } catch (e: any) {
    if (e?.message === IA_NAO_CONFIGURADA) return Response.json({ answer: "🔌 IA não configurada (ANTHROPIC_API_KEY)." }, { status: 200 });
    console.error("[ia/perguntar]", e?.message);
    return Response.json({ error: e?.message ?? "falha na IA" }, { status: 502 });
  }
}
