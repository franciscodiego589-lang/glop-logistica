import { createClient } from "@/lib/supabase/server";
import { MZ_BASE, monetizzeToken, mzSignal } from "@/lib/monetizze";

export const dynamic = "force-dynamic";

// ── Adaptadores por plataforma ──────────────────────────────────────────────
// Cada plataforma tem sua própria API. Retornam uma lista normalizada
// { sale_number, event_type, raw }. Adicionar Hotmart/Kiwify/Shopify é só mais
// um adaptador aqui, mesma experiência ("colar chave → puxar").

type Pulled = { sale_number: string; event_type: string; raw: Record<string, unknown> };

function pick(...vals: any[]) {
  for (const v of vals) if (v !== undefined && v !== null && v !== "") return v;
  return undefined;
}

// ── Monetizze API 2.1 ───────────────────────────────────────────────────────
// Autenticação em DUAS ETAPAS:
//   1) GET /token   com header X_CONSUMER_KEY: <chave da API>  → { token, expire }
//   2) GET /transactions?page=N  com header TOKEN: <token>     → { status, dados[], pages, recordCount }
// A lista de vendas vem em "dados"; o nº da venda é venda.codigo; o comprador
// (nome/cpf/endereço) vem em "comprador". A resposta traz um pix_imagem_qrcode
// gigante (base64) que NÃO guardamos.
function monetizzeStatusToEvent(status: any): string {
  const s = String(status ?? "").toLowerCase();
  if (s.includes("cancel")) return "canceled";
  if (s.includes("reembol") || s.includes("estorn") || s.includes("refund") || s.includes("devolv")) return "refund";
  if (s.includes("charge") || s.includes("disputa") || s.includes("dispute")) return "chargeback";
  if (s.includes("aguard") || s.includes("pend") || s.includes("análi") || s.includes("anali") || s.includes("boleto") || s.includes("autoriz") || s.includes("process")) return "pending";
  // Finalizada, Aprovada, Completa, Paga, Concluída, Entregue...
  return "paid";
}

function mapMonetizze(t: any): Pulled {
  const v = t.venda ?? {};
  const c = t.comprador ?? {};
  const plano = t.plano ?? {};
  const prod = t.produto ?? {};
  const street = [c.endereco, c.numero, c.complemento, c.bairro].filter(Boolean).join(", ");
  return {
    sale_number: String(pick(v.codigo, t.chave_unica) ?? ""),
    event_type: monetizzeStatusToEvent(v.status),
    raw: {
      buyer_name: pick(c.nome),
      buyer_email: pick(c.email),
      buyer_doc: pick(c.cnpj_cpf, c.cpf, c.cnpj),
      buyer_phone: pick(c.telefone, c.celular),
      product_name: pick(plano.nome, prod.nome),
      value: pick(v.valor, v.valorRecebido),
      dest_zip: pick(c.cep),
      dest_street: street || undefined,
      dest_city: pick(c.cidade),
      dest_uf: pick(c.estado, c.uf),
      // metadados úteis (SEM o base64 do QRCode)
      plan_ref: pick(plano.referencia),
      sku: pick(plano.sku, plano.referencia),
      status_raw: pick(v.status),
      payment_method: pick(v.formaPagamento, v.meioPagamento),
      chave_unica: pick(t.chave_unica),
      _source: "monetizze",
    },
  };
}

type PageResult = { sales: Pulled[]; pages: number; recordCount: number };

// Sync incremental: filtra por data de cadastro (date_min, formato yyyy-mm-dd hh:mm:ss).
// Aplica uma sobreposição para capturar mudanças de status recentes (pago/reembolso)
// em vendas que já existiam — a idempotência evita duplicar.
const INCREMENTAL_OVERLAP_MS = 2 * 24 * 60 * 60 * 1000;
function monetizzeIncrementalQS(sinceISO: string | null): string {
  if (!sinceISO) return "";
  const since = new Date(new Date(sinceISO).getTime() - INCREMENTAL_OVERLAP_MS);
  if (isNaN(since.getTime())) return "";
  const s = since.toISOString().slice(0, 19).replace("T", " ");
  return "&date_min=" + encodeURIComponent(s);
}

async function monetizzePage(token: string, page: number, filterQS: string): Promise<PageResult> {
  const res = await fetch(`${MZ_BASE}/transactions?page=${page}${filterQS}`, {
    headers: { TOKEN: token, Accept: "application/json" },
    cache: "no-store", signal: mzSignal(),
  });
  const json: any = await res.json().catch(() => ({}));
  if (!res.ok || json?.status === 403) throw new Error("Falha ao ler vendas da Monetizze (HTTP " + res.status + ")");
  const arr = Array.isArray(json?.dados) ? json.dados : [];
  return {
    sales: arr.map(mapMonetizze).filter((x: Pulled) => x.sale_number),
    pages: Number(json?.pages) || page,
    recordCount: Number(json?.recordCount) || arr.length,
  };
}

// ── API genérica (Bearer) ───────────────────────────────────────────────────
async function pullGeneric(baseUrl: string, key: string): Promise<Pulled[]> {
  if (!baseUrl) throw new Error("Defina a Base URL do conector para a API genérica.");
  const url = baseUrl.replace(/\/$/, "") + "/orders";
  const res = await fetch(url, { headers: { Authorization: "Bearer " + key, Accept: "application/json" }, cache: "no-store", signal: mzSignal() });
  if (!res.ok) throw new Error("API HTTP " + res.status);
  const json: any = await res.json();
  const arr = json?.orders ?? json?.data ?? (Array.isArray(json) ? json : []);
  return (Array.isArray(arr) ? arr : []).map((o: any) => ({
    sale_number: String(pick(o.id, o.number, o.order_number, o.codigo) ?? ""),
    event_type: "paid",
    raw: {
      buyer_name: pick(o.customer?.name, o.buyer_name, o.cliente),
      buyer_email: pick(o.customer?.email, o.email),
      value: pick(o.total, o.value, o.amount),
      product_name: pick(o.items?.[0]?.name, o.product_name),
      dest_zip: pick(o.shipping?.zip, o.dest_zip),
      dest_city: pick(o.shipping?.city, o.dest_city),
      dest_uf: pick(o.shipping?.state, o.dest_uf),
      _source: "generic",
    },
  })).filter((x: Pulled) => x.sale_number);
}

// ── Handler ─────────────────────────────────────────────────────────────────
// Puxa em blocos de páginas dentro de um orçamento de tempo (evita timeout do
// serverless com milhares de vendas) e devolve has_more/next_page para o front
// continuar de onde parou até puxar TODOS os pedidos.
const TIME_BUDGET_MS = 7000;

export async function POST(req: Request) {
  const supabase = createClient();
  if (!supabase) return Response.json({ error: "Supabase não configurado" }, { status: 500 });
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let body: any = {};
  try { body = await req.json(); } catch {}
  const connectorId = body.connector_id;
  const fromPage = Math.max(1, Number(body.from_page) || 1);
  // "full" = puxa tudo; "incremental" = só vendas novas desde a última sincronização.
  const mode = body.mode === "incremental" ? "incremental" : "full";
  if (!connectorId) return Response.json({ error: "connector_id ausente" }, { status: 400 });

  const { data: conn, error: ce } = await supabase
    .from("store_connectors").select("id,platform,webhook_token,api_base_url,producer_ref,name,metadata")
    .eq("id", connectorId).eq("company_id", company).is("deleted_at", null).single();
  if (ce || !conn) return Response.json({ error: "Conector não encontrado" }, { status: 404 });
  if (!conn.webhook_token) return Response.json({ error: "Cole a chave da API neste conector antes de puxar." }, { status: 400 });

  // No incremental, filtra pela última sincronização; se nunca sincronizou, últimos 30 dias.
  const meta = (conn.metadata ?? {}) as Record<string, any>;
  const sinceISO = mode === "incremental"
    ? (meta.last_pull_at ?? new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString())
    : null;

  let sales: Pulled[] = [];
  let hasMore = false, nextPage: number | null = null, pagesTotal = fromPage, recordCount = 0, pageTo = fromPage;

  try {
    if (conn.platform === "monetizze") {
      const token = await monetizzeToken(conn.webhook_token);
      const filterQS = monetizzeIncrementalQS(sinceISO);
      const started = Date.now();
      let page = fromPage;
      do {
        const pr = await monetizzePage(token, page, filterQS);
        pagesTotal = pr.pages;
        recordCount = pr.recordCount;
        sales.push(...pr.sales);
        pageTo = page;
        page += 1;
        if (Date.now() - started > TIME_BUDGET_MS) break;
      } while (page <= pagesTotal);
      if (page <= pagesTotal) { hasMore = true; nextPage = page; }
    } else {
      sales = await pullGeneric(conn.api_base_url, conn.webhook_token);
      recordCount = sales.length;
    }
  } catch (e: any) {
    return Response.json({ error: e.message || "Falha ao chamar a API da plataforma" }, { status: 502 });
  }

  // Ingestão em lote (idempotente) — 1 chamada ao banco para todo o bloco.
  const { data, error } = await supabase.rpc("ingest_store_orders_bulk", {
    p_company: company, p_connector: connectorId, p_orders: sales,
  });
  if (error) {
    const m = (error.message || "").toLowerCase();
    if (m.includes("does not exist") || m.includes("could not find") || m.includes("schema cache")) {
      return Response.json({ error: "Falta aplicar a migration 088 (ingest_store_orders_bulk) no Supabase. Rode supabase/migrations/20260713000088_store_pull_bulk.sql." }, { status: 500 });
    }
    return Response.json({ error: "Erro ao gravar pedidos: " + error.message }, { status: 500 });
  }

  // Ao concluir a sincronização (último bloco), marca a data para o próximo incremental.
  if (!hasMore) {
    await supabase.from("store_connectors")
      .update({ metadata: { ...meta, last_pull_at: new Date().toISOString() } })
      .eq("id", connectorId).eq("company_id", company);
  }

  const r: any = data ?? {};
  return Response.json({
    total: r.total ?? sales.length,
    imported: r.imported ?? 0,
    duplicates: r.duplicates ?? 0,
    errors: r.errors ?? 0,
    mode,
    page_from: fromPage,
    page_to: pageTo,
    pages_total: pagesTotal,
    record_count: recordCount,
    has_more: hasMore,
    next_page: nextPage,
  });
}
