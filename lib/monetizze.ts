// Helpers compartilhados da API Monetizze 2.1.
// Autenticação em 2 etapas: GET /token com header X_CONSUMER_KEY devolve um token
// de sessão (15 min) que vai no header TOKEN das demais chamadas.

export const MZ_BASE = "https://api.monetizze.com.br/2.1";

// Timeout por requisição — evita socket travado segurar a função serverless.
export const MZ_FETCH_TIMEOUT_MS = 15000;
export function mzSignal() {
  return AbortSignal.timeout(MZ_FETCH_TIMEOUT_MS);
}

export async function monetizzeToken(apiKey: string): Promise<string> {
  const res = await fetch(`${MZ_BASE}/token`, {
    headers: { X_CONSUMER_KEY: apiKey, Accept: "application/json" },
    cache: "no-store", signal: mzSignal(),
  });
  const json: any = await res.json().catch(() => ({}));
  if (res.status === 401 || res.status === 403 || json?.status === 403 || json?.Error) {
    throw new Error("Chave da Monetizze inválida ou sem permissão de API. Gere a chave em Ferramentas → API no painel da Monetizze.");
  }
  if (!res.ok || !json?.token) throw new Error("Não foi possível autenticar na Monetizze (HTTP " + res.status + ")");
  return json.token as string;
}
