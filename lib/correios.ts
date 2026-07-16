// Integração Correios (CWS) — prepostagem, CEP e rótulo. Baseado no fluxo LemonLog.
// Segredos vêm de env (Netlify → Environment): CORREIOS_API_TOKEN_PEDIDOS (Bearer CWS
// do cartão de postagem / prepostagem) e CORREIOS_API_TOKEN_CEP (escopo Endereços).
// NUNCA expor esses tokens ao cliente — só usados server-side aqui.

const BASE = "https://api.correios.com.br";
const TOKEN_SAFETY_MS = 30 * 60 * 1000;

export const pedidosToken = () => process.env.CORREIOS_API_TOKEN_PEDIDOS?.trim() || "";
export const cepToken = () => process.env.CORREIOS_API_TOKEN_CEP?.trim() || "";
export const correiosConfigurado = () => !!pedidosToken();

// cache em memória do token Basic (só usado no fallback; a chave CWS é usada direto)
let _cartaoMem: { token: string; exp: number } | null = null;

// Resolve o Bearer para o cartão de postagem (prepostagem + rótulo).
export async function correiosBearerCartao(cartao: string): Promise<string> {
  const t = pedidosToken();
  if (!t) throw new Error("Configure o secret CORREIOS_API_TOKEN_PEDIDOS (chave CWS dos Correios).");
  // Chave CWS / JWT → usa direto (não passa por /token/v1/*).
  if (t.startsWith("cws-") || t.startsWith("eyJ")) return t;
  // Basic (usuario:codigoAcesso ou base64) → autentica no cartão de postagem.
  if (_cartaoMem && _cartaoMem.exp - Date.now() > TOKEN_SAFETY_MS) return _cartaoMem.token;
  const basic = t.includes(":") ? Buffer.from(t).toString("base64") : t;
  const res = await fetch(`${BASE}/token/v1/autentica/cartaopostagem`, {
    method: "POST",
    headers: { Authorization: "Basic " + basic, "Content-Type": "application/json", Accept: "application/json" },
    body: JSON.stringify({ numero: cartao }), cache: "no-store",
  });
  const j: any = await res.json().catch(() => ({}));
  if (!res.ok || !j.token) throw new Error("Falha ao autenticar cartão de postagem: " + (j.mensagem ?? ("HTTP " + res.status)));
  _cartaoMem = { token: j.token, exp: j.expiraEm ? new Date(j.expiraEm).getTime() : Date.now() + 3600e3 };
  return j.token;
}

// Busca/valida CEP (escopo Endereços — token isolado).
export async function correiosCep(cep: string): Promise<any> {
  const t = cepToken();
  if (!t) throw new Error("Configure o secret CORREIOS_API_TOKEN_CEP.");
  const clean = String(cep ?? "").replace(/\D/g, "");
  if (clean.length !== 8) throw new Error("CEP inválido (precisa de 8 dígitos).");
  const res = await fetch(`${BASE}/cep/v2/enderecos/${clean}`, {
    headers: { Authorization: "Bearer " + t, Accept: "application/json" }, cache: "no-store",
  });
  const j: any = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(j.mensagem ?? j?.msgs?.[0] ?? ("CEP HTTP " + res.status));
  return j; // { cep, logradouro, bairro, localidade|cidade, uf, cepAnterior? }
}

// Cria a prepostagem oficial.
export async function correiosPrepostagem(bearer: string, payload: any): Promise<{ ok: boolean; status: number; body: any }> {
  const res = await fetch(`${BASE}/prepostagem/v1/prepostagens`, {
    method: "POST",
    headers: { Authorization: "Bearer " + bearer, "Content-Type": "application/json", Accept: "application/json" },
    body: JSON.stringify(payload), cache: "no-store",
  });
  const j: any = await res.json().catch(() => ({}));
  return { ok: res.ok, status: res.status, body: j };
}

// Gera o rótulo (PDF) de forma assíncrona: solicita e faz polling do download.
export async function correiosRotulo(bearer: string, idPrepostagem: string, codigoObjeto?: string): Promise<{ ok: boolean; pdfBase64?: string; body?: any }> {
  const post = await fetch(`${BASE}/prepostagem/v1/prepostagens/rotulo/assincrono/pdf`, {
    method: "POST",
    headers: { Authorization: "Bearer " + bearer, "Content-Type": "application/json", Accept: "application/json" },
    body: JSON.stringify({
      codigosObjeto: codigoObjeto ? [codigoObjeto] : undefined,
      idsPrePostagem: [idPrepostagem],
      tipoRotulo: "P", formatoRotulo: "ET", imprimeRemetente: "S", layoutImpressao: "PADRAO",
    }), cache: "no-store",
  });
  const pj: any = await post.json().catch(() => ({}));
  const recibo = pj.idRecibo ?? pj.recibo ?? pj.id;
  if (!post.ok || !recibo) return { ok: false, body: pj };
  for (let i = 0; i < 5; i++) {
    await new Promise((r) => setTimeout(r, 1200));
    const g = await fetch(`${BASE}/prepostagem/v1/prepostagens/rotulo/download/assincrono/${recibo}`, {
      headers: { Authorization: "Bearer " + bearer, Accept: "application/json" }, cache: "no-store",
    });
    const gj: any = await g.json().catch(() => ({}));
    const pdf = gj.dados ?? gj.pdf ?? gj.arquivo ?? gj.dadosBase64;
    if (g.ok && pdf) return { ok: true, pdfBase64: pdf };
  }
  return { ok: false, body: { mensagem: "Rótulo ainda em processamento — tente baixar novamente em instantes." } };
}
