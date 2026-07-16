import { createClient } from "@/lib/supabase/server";
import { monetizzeToken } from "@/lib/monetizze";

export const dynamic = "force-dynamic";

// Ferramenta de teste de integrações: pinga as APIs externas (gateways de pagamento
// + logística/fiscal) e valida credenciais quando existirem, SEM expor segredo ao
// client (roda no servidor). Retorna { provider, ok, code, ms, message }.

const T = 15000;
async function ping(url: string, init?: RequestInit): Promise<{ code: number; ms: number }> {
  const t0 = Date.now();
  try {
    const res = await fetch(url, { ...init, cache: "no-store", redirect: "manual", signal: AbortSignal.timeout(T) });
    return { code: res.status, ms: Date.now() - t0 };
  } catch { return { code: 0, ms: Date.now() - t0 }; }
}

// Reachability simples: qualquer resposta HTTP (mesmo 401/403/404) = API no ar.
const REACH: Record<string, { url: string; nome: string; init?: RequestInit }> = {
  // ── Checkouts / infoproduto ──
  appmax: { url: "https://admin.appmax.com.br/api/v3/", nome: "AppMax" },
  braip: { url: "https://ev.braip.com/", nome: "Braip" },
  hotmart: { url: "https://api-sec-vlc.hotmart.com/security/oauth/token", nome: "Hotmart" },
  kiwify: { url: "https://public-api.kiwify.com/v1/", nome: "Kiwify" },
  eduzz: { url: "https://api.eduzz.com/", nome: "Eduzz" },
  perfectpay: { url: "https://app.perfectpay.com.br/", nome: "PerfectPay" },
  cakto: { url: "https://api.cakto.com.br/", nome: "Cakto" },
  // ── Gateways de pagamento ──
  mercadopago: { url: "https://api.mercadopago.com/v1/payment_methods", nome: "Mercado Pago" },
  pagseguro: { url: "https://api.pagseguro.com/", nome: "PagSeguro" },
  stripe: { url: "https://api.stripe.com/v1/", nome: "Stripe" },
  paypal: { url: "https://api-m.paypal.com/v1/", nome: "PayPal" },
  pagarme: { url: "https://api.pagar.me/core/v5/", nome: "Pagar.me" },
  cielo: { url: "https://apiquery.cieloecommerce.cielo.com.br/", nome: "Cielo" },
  rede: { url: "https://api.userede.com.br/", nome: "Rede" },
  getnet: { url: "https://api.getnet.com.br/", nome: "Getnet" },
  iugu: { url: "https://api.iugu.com/v1/", nome: "Iugu" },
  asaas: { url: "https://api.asaas.com/v3/", nome: "Asaas" },
  vindi: { url: "https://app.vindi.com.br/api/v1/", nome: "Vindi" },
  picpay: { url: "https://appws.picpay.com/ecommerce/public/", nome: "PicPay" },
  efi: { url: "https://api.efipay.com.br/", nome: "Efí (Gerencianet)" },
  ebanx: { url: "https://api.ebanxpay.com/", nome: "EBANX" },
  adyen: { url: "https://checkout.adyen.com/v71/", nome: "Adyen" },
  // ── E-commerce / marketplaces ──
  shopify: { url: "https://www.shopify.com/", nome: "Shopify" },
  woocommerce: { url: "https://woocommerce.com/", nome: "WooCommerce" },
  nuvemshop: { url: "https://api.tiendanube.com/", nome: "Nuvemshop" },
  tray: { url: "https://www.tray.com.br/", nome: "Tray" },
  vtex: { url: "https://vtex.com/", nome: "VTEX" },
  loja_integrada: { url: "https://api.awsli.com.br/", nome: "Loja Integrada" },
  wix: { url: "https://www.wixapis.com/", nome: "Wix" },
  magento: { url: "https://magento.com/", nome: "Magento" },
  yampi: { url: "https://api.dooki.com.br/", nome: "Yampi" },
  cartpanda: { url: "https://accounts.cartpanda.com/", nome: "CartPanda" },
  mercadolivre: { url: "https://api.mercadolibre.com/sites/MLB", nome: "Mercado Livre" },
  amazon: { url: "https://sellingpartnerapi-na.amazon.com/", nome: "Amazon" },
  shopee: { url: "https://partner.shopeemobile.com/", nome: "Shopee" },
  magalu: { url: "https://api.magalu.com/", nome: "Magalu" },
  // ── Logística / fiscal ──
  correios: { url: "https://api.correios.com.br/", nome: "Correios" },
  vhsys: { url: "https://api.vhsys.com/v2/", nome: "VHSYS" },
};

export async function POST(req: Request) {
  const supabase = createClient();
  if (!supabase) return Response.json({ error: "Supabase não configurado" }, { status: 500 });
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let body: any = {}; try { body = await req.json(); } catch {}
  const provider = String(body.provider ?? "");

  try {
    // Monetizze: valida a chave REAL configurada (se houver), senão testa reachability.
    if (provider === "monetizze") {
      const { data: conn } = await supabase.from("store_connectors")
        .select("webhook_token").eq("company_id", company).eq("platform", "monetizze")
        .not("webhook_token", "is", null).is("deleted_at", null).limit(1).maybeSingle();
      if (conn?.webhook_token) {
        const t0 = Date.now();
        try { await monetizzeToken(conn.webhook_token); return Response.json({ provider, ok: true, code: 200, ms: Date.now() - t0, message: "Chave válida — autenticou na Monetizze." }); }
        catch (e: any) { return Response.json({ provider, ok: false, code: 403, ms: Date.now() - t0, message: e.message || "Chave inválida." }); }
      }
      const r = await ping("https://api.monetizze.com.br/2.1/token", { headers: { X_CONSUMER_KEY: "teste" } });
      return Response.json({ provider, ok: r.code === 403, code: r.code, ms: r.ms, message: r.code === 403 ? "API no ar (sem chave — cadastre em Puxar Pedidos de Lojas)." : (r.code === 0 ? "Fora do ar/timeout." : "Resposta inesperada.") });
    }
    if (provider === "supabase") {
      const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
      const r = await ping(`${url}/rest/v1/`, { headers: { apikey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "" } });
      return Response.json({ provider, ok: r.code >= 200 && r.code < 500, code: r.code, ms: r.ms, message: r.code ? "Banco de dados respondendo." : "Fora do ar." });
    }
    const cfg = REACH[provider];
    if (cfg) {
      const r = await ping(cfg.url, cfg.init);
      return Response.json({ provider, ok: r.code > 0, code: r.code, ms: r.ms, message: r.code > 0 ? `${cfg.nome} respondendo (HTTP ${r.code}).` : `${cfg.nome} fora do ar/timeout.` });
    }
    return Response.json({ error: "Integração desconhecida: " + provider }, { status: 400 });
  } catch (e: any) {
    console.error("[integracoes/test]", provider, e.message);
    return Response.json({ provider, ok: false, code: 0, ms: 0, message: "Falha ao testar." });
  }
}
