// Parsers de POSTBACK/WEBHOOK das plataformas → formato normalizado do GLOP.
// Cada plataforma manda um payload diferente; aqui normalizamos para
// { event_type, sale_number, token, raw:{ buyer_*, dest_*, product_name, value, ... } }.
// Braip = parser dedicado (form-urlencoded). Demais = parser genérico (JSON, cobre
// muitos nomes de campo comuns) — captura a venda no melhor esforço.

export type Normalized = {
  event_type: string;      // paid | pending | refund | chargeback | canceled | completed | other
  sale_number: string;     // nº da venda (idempotência)
  token: string | null;    // token de validação vindo do próprio payload (ex.: Braip basic_authentication)
  raw: Record<string, any>;
};

const s = (v: any): string | undefined => {
  if (v === undefined || v === null) return undefined;
  const t = String(v).trim();
  return t === "" ? undefined : t;
};
const pick = (...vals: any[]): any => {
  for (const v of vals) { const r = s(v); if (r !== undefined) return r; }
  return undefined;
};
// procura uma chave por lista de nomes possíveis (case-insensitive), inclusive aninhado 1 nível
const field = (o: any, ...names: string[]): any => {
  if (!o || typeof o !== "object") return undefined;
  const lower: Record<string, any> = {};
  for (const k of Object.keys(o)) lower[k.toLowerCase()] = o[k];
  for (const n of names) { const v = lower[n.toLowerCase()]; if (s(v) !== undefined) return v; }
  return undefined;
};

// ── Mapa de status textual → evento normalizado (cobre PT e EN dos checkouts) ──
export function statusToEvent(status: any): string {
  const v = String(status ?? "").toLowerCase();
  if (!v) return "paid";
  if (v.includes("charge")) return "chargeback";
  if (v.includes("disput")) return "chargeback";
  if (v.includes("reembol") || v.includes("estorn") || v.includes("refund") || v.includes("devolv")) return "refund";
  if (v.includes("cancel")) return "canceled";
  if (v.includes("aguard") || v.includes("pend") || v.includes("analis") || v.includes("análi") ||
      v.includes("process") || v.includes("boleto") || v.includes("aberto") || v.includes("waiting") ||
      v.includes("atras") || v.includes("parcial")) return "pending";
  // aprovado / pago / completo / finalizado / concluído / entregue / paid / approved / completed
  return "paid";
}

// ── Braip (form-urlencoded) ─────────────────────────────────────────────────
// Campos client_* confirmados em código real; trans_* e endereço são o padrão de
// mercado. Validação: campo basic_authentication (chave única da conta).
export function parseBraip(body: Record<string, any>): Normalized {
  const street = pick(field(body, "client_address", "address", "client_endereco"));
  const number = pick(field(body, "client_number", "number", "client_numero"));
  const district = pick(field(body, "client_neighborhood", "neighborhood", "client_bairro"));
  return {
    token: pick(field(body, "basic_authentication", "authentication", "token")) ?? null,
    sale_number: pick(field(body, "trans_cod", "trans_code", "transaction", "trans_key", "code")) ?? "",
    event_type: statusToEvent(field(body, "trans_status", "status", "trans_status_name")),
    raw: {
      buyer_name: pick(field(body, "client_name", "buyer_name", "name")),
      buyer_email: pick(field(body, "client_email", "email")),
      buyer_doc: pick(field(body, "client_document", "client_cpf", "document", "cpf")),
      buyer_phone: pick(field(body, "client_cel", "client_phone", "phone", "telefone")),
      dest_zip: pick(field(body, "client_zipcode", "zipcode", "client_cep", "cep")),
      dest_street: [street, number, district].filter(Boolean).join(", ") || undefined,
      dest_number: number,
      dest_district: district,
      dest_city: pick(field(body, "client_city", "city", "cidade")),
      dest_uf: pick(field(body, "client_state", "state", "uf", "estado")),
      product_name: pick(field(body, "product_name", "prod_name", "produto")),
      sku: pick(field(body, "product_cod", "product_code", "sku")),
      value: pick(field(body, "trans_value", "value", "amount", "valor")),
      payment_method: pick(field(body, "trans_pay", "payment_method", "forma_pagamento")),
      status_raw: pick(field(body, "trans_status", "status")),
      _source: "braip",
    },
  };
}

// ── Genérico (JSON ou form) ─────────────────────────────────────────────────
// Cobre os nomes de campo mais comuns dos checkouts/e-commerces. Aceita payload
// achatado ou com objetos buyer/customer/shipping aninhados.
export function parseGeneric(body: Record<string, any>, platform: string): Normalized {
  const buyer = field(body, "buyer", "customer", "cliente", "comprador") ?? {};
  const ship = field(body, "shipping", "shipping_address", "address", "endereco", "delivery") ?? {};
  const item = (Array.isArray(field(body, "items", "products", "itens")) ? field(body, "items", "products", "itens")[0] : undefined) ?? {};
  return {
    token: pick(field(body, "token", "webhook_token", "secret", "basic_authentication", "signature")) ?? null,
    sale_number: pick(
      field(body, "sale_number", "order_number", "order_id", "id", "code", "codigo", "transaction_id", "reference"),
      field(field(body, "order", "venda", "sale") ?? {}, "id", "number", "code"),
    ) ?? "",
    event_type: statusToEvent(pick(field(body, "status", "event", "event_type", "status_name", "financial_status", "situacao"))),
    raw: {
      buyer_name: pick(field(buyer, "name", "nome", "full_name"), field(body, "buyer_name", "customer_name", "name")),
      buyer_email: pick(field(buyer, "email"), field(body, "email", "buyer_email")),
      buyer_doc: pick(field(buyer, "document", "cpf", "cnpj", "doc"), field(body, "document", "cpf", "buyer_doc")),
      buyer_phone: pick(field(buyer, "phone", "telefone", "cel", "mobile"), field(body, "phone", "telefone")),
      dest_zip: pick(field(ship, "zip", "zipcode", "cep", "postal_code"), field(body, "zip", "cep", "dest_zip")),
      dest_street: pick(field(ship, "street", "address", "logradouro", "address1"), field(body, "street", "endereco")),
      dest_number: pick(field(ship, "number", "numero")),
      dest_district: pick(field(ship, "district", "neighborhood", "bairro")),
      dest_city: pick(field(ship, "city", "cidade"), field(body, "city", "dest_city")),
      dest_uf: pick(field(ship, "state", "uf", "province"), field(body, "state", "uf", "dest_uf")),
      product_name: pick(field(item, "name", "title", "nome"), field(body, "product_name", "product", "produto")),
      sku: pick(field(item, "sku", "code"), field(body, "sku", "product_code")),
      value: pick(field(body, "total", "value", "amount", "valor", "total_price", "price"), field(item, "price")),
      payment_method: pick(field(body, "payment_method", "payment_type", "forma_pagamento", "gateway")),
      status_raw: pick(field(body, "status", "event", "situacao")),
      _source: platform,
    },
  };
}

export function parsePostback(platform: string, body: Record<string, any>): Normalized {
  if (platform === "braip") return parseBraip(body);
  return parseGeneric(body, platform);
}
