// Cliente da API da Anthropic (Claude) — SÓ SERVIDOR.
// A chave vive em process.env.ANTHROPIC_API_KEY (nunca NEXT_PUBLIC_, nunca no repo,
// nunca vai ao client). Definida no painel da Netlify › Environment variables.
// Usado apenas por rotas /api/ia/* (server). Se a chave não estiver configurada,
// as rotas degradam com uma mensagem amigável — nada quebra.

const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";
const DEFAULT_MODEL = process.env.ANTHROPIC_MODEL || "claude-sonnet-5";

export const IA_NAO_CONFIGURADA = "IA_NAO_CONFIGURADA";

export function iaConfigured(): boolean {
  return !!process.env.ANTHROPIC_API_KEY;
}

type AskOpts = {
  system?: string;
  user: string;
  maxTokens?: number;
  temperature?: number;
  model?: string;
};

// Chama o Claude e devolve o texto da resposta. Lança IA_NAO_CONFIGURADA se não há chave.
export async function askClaude(opts: AskOpts): Promise<string> {
  const key = process.env.ANTHROPIC_API_KEY;
  if (!key) throw new Error(IA_NAO_CONFIGURADA);

  const res = await fetch(ANTHROPIC_URL, {
    method: "POST",
    headers: {
      "x-api-key": key,
      "anthropic-version": "2023-06-01",
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model: opts.model || DEFAULT_MODEL,
      max_tokens: opts.maxTokens ?? 1024,
      temperature: opts.temperature ?? 0.3,
      ...(opts.system ? { system: opts.system } : {}),
      messages: [{ role: "user", content: opts.user }],
    }),
    cache: "no-store",
    signal: AbortSignal.timeout(60_000),
  });

  if (!res.ok) {
    const t = await res.text().catch(() => "");
    if (res.status === 401) throw new Error("Chave da Anthropic inválida (401). Confira ANTHROPIC_API_KEY na Netlify.");
    if (res.status === 429) throw new Error("Limite de uso da Anthropic atingido (429). Tente de novo em instantes.");
    throw new Error("Anthropic HTTP " + res.status + ": " + t.slice(0, 200));
  }
  const j: any = await res.json();
  return (j?.content ?? []).filter((c: any) => c?.type === "text").map((c: any) => c.text).join("\n").trim();
}

// Igual, mas força e extrai um JSON da resposta (para extração estruturada).
export async function askClaudeJSON<T = any>(opts: AskOpts): Promise<T> {
  const raw = await askClaude({ ...opts, temperature: opts.temperature ?? 0 });
  // tenta achar o primeiro bloco {...} ou [...] mesmo se vier com texto ao redor
  const match = raw.match(/```json\s*([\s\S]*?)```/) || raw.match(/([\[{][\s\S]*[\]}])/);
  const jsonStr = (match ? match[1] : raw).trim();
  return JSON.parse(jsonStr) as T;
}
