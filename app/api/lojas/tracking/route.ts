import { createClient } from "@/lib/supabase/server";
import { MZ_BASE, monetizzeToken, mzSignal } from "@/lib/monetizze";

export const dynamic = "force-dynamic";

// Devolve o código de rastreio dos Correios para a plataforma de origem.
// Monetizze: POST /sales/tracking, body form-urlencoded `data` = array JSON de
// { codLog:1 (Correios), transaction:<cod. da venda>, trackingCode:"PA...BR" }.
// Até 1000 por requisição; a Monetizze notifica o comprador. Marcamos
// tracking_pushed_at para não re-notificar o cliente em sincronizações futuras.

const MAX_BATCH = 1000;

type PushItem = { sale_number: string; tracking_code: string };

async function monetizzePushTracking(token: string, items: PushItem[]) {
  const data = items.map((i) => ({ codLog: 1, transaction: Number(i.sale_number), trackingCode: i.tracking_code }));
  const res = await fetch(`${MZ_BASE}/sales/tracking`, {
    method: "POST",
    headers: { TOKEN: token, "Content-Type": "application/x-www-form-urlencoded", Accept: "application/json" },
    body: "data=" + encodeURIComponent(JSON.stringify(data)),
    cache: "no-store", signal: mzSignal(),
  });
  const json: any = await res.json().catch(() => null);
  if (!res.ok || json == null) throw new Error("Falha ao enviar rastreio à Monetizze (HTTP " + res.status + ")");
  // Resposta: [{ sale, status:"success"|"error", message }]
  return Array.isArray(json) ? json : (Array.isArray(json?.dados) ? json.dados : []);
}

export async function POST(req: Request) {
  const supabase = createClient();
  if (!supabase) return Response.json({ error: "Supabase não configurado" }, { status: 500 });
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let body: any = {};
  try { body = await req.json(); } catch {}
  const connectorId = body.connector_id;
  if (!connectorId) return Response.json({ error: "connector_id ausente" }, { status: 400 });

  const { data: conn, error: ce } = await supabase
    .from("store_connectors").select("id,platform,webhook_token")
    .eq("id", connectorId).eq("company_id", company).is("deleted_at", null).single();
  if (ce || !conn) return Response.json({ error: "Conector não encontrado" }, { status: 404 });
  if (conn.platform !== "monetizze") return Response.json({ error: "Devolução de rastreio disponível só para Monetizze por enquanto." }, { status: 400 });
  if (!conn.webhook_token) return Response.json({ error: "Cole a chave da API neste conector antes de enviar rastreio." }, { status: 400 });

  // 1) Se vierem itens explícitos, grava o tracking_code nos pedidos correspondentes.
  const explicit: PushItem[] = Array.isArray(body.items)
    ? body.items
        .map((i: any) => ({ sale_number: String(i.sale_number ?? "").trim(), tracking_code: String(i.tracking_code ?? "").trim().toUpperCase() }))
        .filter((i: PushItem) => i.sale_number && i.tracking_code)
    : [];
  for (const it of explicit) {
    await supabase.from("store_orders")
      .update({ tracking_code: it.tracking_code })
      .eq("company_id", company).eq("connector_id", connectorId).eq("sale_number", it.sale_number).is("deleted_at", null);
  }

  // 2) Monta a fila a enviar.
  //    - Com itens explícitos (botão 📮 de uma linha): envia SÓ esses (não varre a fila),
  //      senão o clique de uma linha notificaria todos os pendentes de uma vez.
  //    - Sem itens (botão em lote): envia todos os pendentes (com rastreio, ainda não enviados).
  const byNumber = new Map<string, string>();
  let claimedBatch = false;
  if (explicit.length > 0) {
    // IDEMPOTÊNCIA: pula pedidos já enviados com o MESMO código — não re-notifica o cliente.
    const { data: cur } = await supabase.from("store_orders")
      .select("sale_number,tracking_code,tracking_pushed_at")
      .eq("company_id", company).eq("connector_id", connectorId)
      .in("sale_number", explicit.map((e) => e.sale_number)).is("deleted_at", null);
    const state = new Map((cur ?? []).map((o: any) => [String(o.sale_number), o]));
    for (const it of explicit) {
      const o = state.get(it.sale_number);
      if (o && o.tracking_pushed_at && o.tracking_code === it.tracking_code) continue; // já notificado
      byNumber.set(it.sale_number, it.tracking_code);
    }
  } else {
    // CLAIM ATÔMICO contra corrida: seleciona pendentes e reivindica só os que ainda
    // estão null num UPDATE ... WHERE tracking_pushed_at IS NULL. Requisições simultâneas
    // reivindicam conjuntos disjuntos (sem duplo-envio). Reset em caso de falha (abaixo).
    const { data: pending } = await supabase.from("store_orders").select("sale_number")
      .eq("company_id", company).eq("connector_id", connectorId)
      .not("tracking_code", "is", null).is("tracking_pushed_at", null).is("deleted_at", null)
      .limit(MAX_BATCH);
    const nums = (pending ?? []).map((p: any) => String(p.sale_number)).filter(Boolean);
    if (nums.length) {
      const { data: claimed } = await supabase.from("store_orders")
        .update({ tracking_pushed_at: new Date().toISOString(), tracking_push_msg: "enviando à plataforma…" })
        .eq("company_id", company).eq("connector_id", connectorId)
        .in("sale_number", nums).is("tracking_pushed_at", null).is("deleted_at", null)
        .select("sale_number,tracking_code");
      claimedBatch = true;
      for (const p of (claimed ?? [])) if (p.sale_number && p.tracking_code) byNumber.set(String(p.sale_number), p.tracking_code);
    }
  }
  // Monetizze exige transaction NUMÉRICO (cód. da venda). Vendas cujo número não é
  // numérico (ex.: fallback para chave_unica) não têm como receber rastreio lá.
  const all: PushItem[] = Array.from(byNumber, ([sale_number, tracking_code]) => ({ sale_number, tracking_code }));
  const invalid = all.filter((q) => !Number.isFinite(Number(q.sale_number)));
  const invalidDetails = invalid.map((q) => ({ sale_number: q.sale_number, status: "error", message: "Número da venda não é numérico — a Monetizze não aceita." }));
  const queue: PushItem[] = all.filter((q) => Number.isFinite(Number(q.sale_number))).slice(0, MAX_BATCH);

  if (queue.length === 0) return Response.json({
    sent: 0, success: 0, errors: invalid.length,
    message: invalid.length ? "Vendas sem número numérico não podem receber rastreio na Monetizze." : "Nenhum pedido com rastreio pendente para enviar.",
    details: invalidDetails,
  });

  let results: any[];
  try {
    const token = await monetizzeToken(conn.webhook_token);
    results = await monetizzePushTracking(token, queue);
  } catch (e: any) {
    // Falha total: libera o claim (batch) para retentar depois; não deixa marcado como enviado.
    if (claimedBatch && queue.length) {
      await supabase.from("store_orders").update({ tracking_pushed_at: null, tracking_push_msg: "falha no envio — retentar" })
        .eq("company_id", company).eq("connector_id", connectorId).in("sale_number", queue.map((q) => q.sale_number)).is("deleted_at", null);
    }
    return Response.json({ error: e.message || "Falha ao enviar rastreio" }, { status: 502 });
  }

  // 3) Marca cada pedido conforme o retorno (sucesso → pushed_at; erro → só a mensagem, retenta depois).
  const bySale = new Map<string, any>();
  for (const r of results) if (r?.sale != null) bySale.set(String(r.sale), r);
  let success = 0, errors = 0;
  const details: any[] = [];
  for (const it of queue) {
    const r = bySale.get(it.sale_number);
    const ok = r?.status === "success";
    const msg = r?.message ?? (r ? "" : "Sem retorno da plataforma para esta venda.");
    if (ok) success++; else errors++;
    details.push({ sale_number: it.sale_number, status: ok ? "success" : "error", message: msg });
    // sucesso → confirma pushed_at; erro → LIBERA (pushed_at=null) para retentar (desfaz o claim do batch).
    await supabase.from("store_orders")
      .update(ok ? { tracking_pushed_at: new Date().toISOString(), tracking_push_msg: msg } : { tracking_pushed_at: null, tracking_push_msg: msg })
      .eq("company_id", company).eq("connector_id", connectorId).eq("sale_number", it.sale_number).is("deleted_at", null);
  }

  return Response.json({ sent: queue.length, success, errors: errors + invalid.length, details: [...details, ...invalidDetails] });
}
