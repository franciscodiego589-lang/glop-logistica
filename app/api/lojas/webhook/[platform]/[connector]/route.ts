import { createClient } from "@/lib/supabase/server";
import { parsePostback } from "@/lib/store-postback";

export const dynamic = "force-dynamic";

// ── Receptor de POSTBACK/WEBHOOK das plataformas ────────────────────────────
// A plataforma (Braip, Hotmart, Kiwify, gateways…) faz POST aqui quando há venda.
// URL: /api/lojas/webhook/{platform}/{connector_id}   (opcional ?t={token})
// A autenticação é o TOKEN (segredo compartilhado): vem no próprio payload
// (ex.: Braip basic_authentication), ou no header x-webhook-token, ou em ?t=.
// A RPC ingest_store_postback (SECURITY DEFINER) valida o token contra o conector.

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

async function readBody(req: Request): Promise<Record<string, any>> {
  const ct = (req.headers.get("content-type") || "").toLowerCase();
  try {
    if (ct.includes("application/json")) return await req.json();
    if (ct.includes("form-urlencoded")) {
      const txt = await req.text();
      return Object.fromEntries(new URLSearchParams(txt));
    }
    if (ct.includes("multipart/form-data")) {
      const fd = await req.formData();
      return Object.fromEntries(Array.from(fd.entries()).map(([k, v]) => [k, typeof v === "string" ? v : ""]));
    }
    // desconhecido: tenta JSON, depois form
    const txt = await req.text();
    try { return JSON.parse(txt); } catch { return Object.fromEntries(new URLSearchParams(txt)); }
  } catch { return {}; }
}

async function handle(req: Request, platform: string, connector: string) {
  if (!UUID_RE.test(connector)) return Response.json({ ok: false, error: "conector inválido" }, { status: 400 });
  const supabase = createClient();
  if (!supabase) return Response.json({ ok: false, error: "indisponível" }, { status: 500 });

  const body = await readBody(req);
  const norm = parsePostback(platform, body);

  // token: payload → header → querystring
  const url = new URL(req.url);
  const token = norm.token
    ?? req.headers.get("x-webhook-token")
    ?? req.headers.get("x-hub-signature")
    ?? url.searchParams.get("t")
    ?? url.searchParams.get("token");

  if (!norm.sale_number) {
    // sem nº de venda não há idempotência; devolve 200 para a plataforma não ficar reenviando
    return Response.json({ ok: false, ignored: true, reason: "sem número de venda no payload" }, { status: 200 });
  }

  const { data, error } = await supabase.rpc("ingest_store_postback", {
    p_connector: connector,
    p_token: token,
    p_event_type: norm.event_type,
    p_sale_number: norm.sale_number,
    p_raw: norm.raw,
  });

  if (error) {
    const m = (error.message || "").toLowerCase();
    if (m.includes("invalid token")) return Response.json({ ok: false, error: "token inválido" }, { status: 401 });
    if (m.includes("connector not found")) return Response.json({ ok: false, error: "conector não encontrado" }, { status: 404 });
    console.error("[lojas/webhook]", platform, error.message);
    return Response.json({ ok: false, error: "falha ao processar" }, { status: 500 });
  }
  const r: any = data ?? {};
  return Response.json({ ok: true, duplicate: !!r.duplicate, order_id: r.order_id ?? null, state: r.state ?? null }, { status: 200 });
}

export async function POST(req: Request, { params }: { params: { platform: string; connector: string } }) {
  return handle(req, params.platform, params.connector);
}
// Algumas plataformas fazem um GET de validação ao cadastrar a URL.
export async function GET(_req: Request, { params }: { params: { platform: string; connector: string } }) {
  return Response.json({ ok: true, endpoint: "postback", platform: params.platform }, { status: 200 });
}
