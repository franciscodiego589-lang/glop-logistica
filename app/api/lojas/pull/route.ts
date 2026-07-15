import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

// ── Adaptadores por plataforma ──────────────────────────────────────────────
// Cada plataforma tem sua própria API. Começamos pela Monetizze; adicionar
// Hotmart/Kiwify/Shopify é só mais uma função aqui, mesma experiência ("colar
// chave → puxar"). Retornam uma lista normalizada { sale_number, event_type, raw }.

type Pulled = { sale_number: string; event_type: string; raw: Record<string, unknown> };

function pick(...vals: any[]) {
  for (const v of vals) if (v !== undefined && v !== null && v !== "") return v;
  return undefined;
}

function mapMonetizze(v: any): Pulled {
  const c = v.comprador ?? v.cliente ?? {};
  const e = v.endereco ?? c.endereco ?? {};
  const p = v.produto ?? {};
  const plano = v.plano ?? {};
  return {
    sale_number: String(pick(v.codigo, v.codigo_venda, v.venda, v.id, v.chave_venda) ?? ""),
    event_type: (() => {
      const st = String(pick(v.status, v.situacao, v.status_venda) ?? "").toLowerCase();
      if (st.includes("cancel")) return "canceled";
      if (st.includes("reembol") || st.includes("refund")) return "refund";
      if (st.includes("charge")) return "chargeback";
      if (st.includes("aguard") || st.includes("pend")) return "pending";
      return "paid";
    })(),
    raw: {
      buyer_name: pick(c.nome, v.nome_comprador, v.comprador_nome),
      buyer_email: pick(c.email, v.email_comprador),
      buyer_doc: pick(c.cpf, c.cnpj, c.documento, v.documento_comprador),
      buyer_phone: pick(c.telefone, c.celular, v.telefone_comprador),
      product_name: pick(p.nome, plano.nome, v.nome_produto, v.produto_nome),
      value: pick(v.valor, v.valor_venda, v.valor_total),
      dest_zip: pick(e.cep, c.cep),
      dest_street: pick(e.logradouro, e.endereco, c.endereco),
      dest_city: pick(e.cidade, c.cidade),
      dest_uf: pick(e.estado, e.uf, c.estado),
      _source: "monetizze",
    },
  };
}

async function pullMonetizze(key: string): Promise<Pulled[]> {
  // Monetizze API 2.1 — autenticação por header "chave" (a API key do painel deles).
  const bases = [
    "https://api.monetizze.com.br/2.1/vendas",
    "https://api.monetizze.com.br/2.0/vendas",
  ];
  let lastErr = "";
  for (const url of bases) {
    try {
      const res = await fetch(url, { headers: { chave: key, Accept: "application/json" }, cache: "no-store" });
      if (res.status === 401 || res.status === 403) throw new Error("Chave da Monetizze inválida ou sem permissão (HTTP " + res.status + ")");
      if (!res.ok) { lastErr = "Monetizze HTTP " + res.status; continue; }
      const json: any = await res.json();
      const arr = json?.venda ?? json?.vendas ?? json?.data ?? json?.itens ?? (Array.isArray(json) ? json : []);
      return (Array.isArray(arr) ? arr : []).map(mapMonetizze).filter((x) => x.sale_number);
    } catch (e: any) {
      if (String(e.message).includes("inválida")) throw e;
      lastErr = e.message;
    }
  }
  throw new Error(lastErr || "Não foi possível ler as vendas da Monetizze");
}

async function pullGeneric(baseUrl: string, key: string): Promise<Pulled[]> {
  if (!baseUrl) throw new Error("Defina a Base URL do conector para a API genérica.");
  const url = baseUrl.replace(/\/$/, "") + "/orders";
  const res = await fetch(url, { headers: { Authorization: "Bearer " + key, Accept: "application/json" }, cache: "no-store" });
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
  })).filter((x) => x.sale_number);
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
    .from("store_connectors").select("id,platform,webhook_token,api_base_url,producer_ref,name")
    .eq("id", connectorId).eq("company_id", company).single();
  if (ce || !conn) return Response.json({ error: "Conector não encontrado" }, { status: 404 });
  if (!conn.webhook_token) return Response.json({ error: "Cole a chave da API neste conector antes de puxar." }, { status: 400 });

  let sales: Pulled[];
  try {
    sales = conn.platform === "monetizze"
      ? await pullMonetizze(conn.webhook_token)
      : await pullGeneric(conn.api_base_url, conn.webhook_token);
  } catch (e: any) {
    return Response.json({ error: e.message || "Falha ao chamar a API da plataforma" }, { status: 502 });
  }

  let imported = 0, duplicates = 0, errors = 0;
  for (const s of sales) {
    const { data, error } = await supabase.rpc("ingest_store_webhook", {
      p_company: company, p_connector: connectorId, p_event_type: s.event_type,
      p_sale_number: s.sale_number, p_raw: s.raw, p_signature_valid: true,
    });
    if (error) errors++;
    else if ((data as any)?.duplicate) duplicates++;
    else imported++;
  }
  return Response.json({ total: sales.length, imported, duplicates, errors });
}
