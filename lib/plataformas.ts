// Catálogo canônico de plataformas de pagamento / checkout / marketplace.
// Fonte única da verdade para: seletor de nova loja, rótulos, e o painel de conexão.
// Pesquisa verificada (modelo de integração real de cada uma) — ver Onda "Plataformas".
//
// conexao = como o GLOP integra hoje:
//   'pull'      → o GLOP CHAMA a API e lista as vendas (cola a chave → botão Puxar). Ex.: Monetizze.
//   'postback'  → a plataforma faz POST no GLOP quando há venda (copia a URL de postback e cola
//                 no painel da plataforma + cola a chave de validação). Ex.: Braip, Hotmart, Kiwify.
// nativo = tem adaptador dedicado (Monetizze pull; Braip parser de postback). Os demais usam o
//          receptor de postback genérico (captura a venda e normaliza no melhor esforço).

export type PlatformCategoria = "checkout" | "gateway" | "marketplace" | "ecommerce";
export type PlatformConexao = "pull" | "postback";

export type Plataforma = {
  id: string;
  nome: string;
  emoji: string;
  categoria: PlatformCategoria;
  conexao: PlatformConexao;
  nativo: boolean;
  keyLabel: string;   // o que o usuário cola
  keyHint: string;    // onde encontra
  base?: string;
};

export const PLATAFORMAS: Plataforma[] = [
  // ── Checkouts / infoproduto (o coração do dropshipping BR) ──────────────────
  { id: "monetizze", nome: "Monetizze", emoji: "🟩", categoria: "checkout", conexao: "pull", nativo: true, keyLabel: "Chave da API (Consumer Key)", keyHint: "Painel Monetizze › Ferramentas › API 2.1 › Chave de Consumo.", base: "https://api.monetizze.com.br/2.1/" },
  { id: "braip", nome: "Braip", emoji: "🟪", categoria: "checkout", conexao: "postback", nativo: true, keyLabel: "Chave única do Postback (basic_authentication)", keyHint: "Painel Braip › Ferramentas › Postback › Documentação (chave única da conta). Cole a URL de postback abaixo em Ferramentas › Postback › Nova configuração (Método POST).", base: "https://ev.braip.com" },
  { id: "hotmart", nome: "Hotmart", emoji: "🔥", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Token do Webhook (Hottok)", keyHint: "Painel Hotmart › Ferramentas › Webhook (Hottok). Cole a URL de postback lá.", base: "https://developers.hotmart.com" },
  { id: "kiwify", nome: "Kiwify", emoji: "🥝", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Token/segredo do Webhook", keyHint: "Painel Kiwify › Apps › Webhooks › criar. Cole a URL de postback e copie o segredo.", base: "https://public-api.kiwify.com/v1" },
  { id: "eduzz", nome: "Eduzz", emoji: "🟠", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Chave de validação do Webhook", keyHint: "Myeduzz › Configurações › Notificações/Webhook. Cole a URL de postback.", base: "https://api.eduzz.com" },
  { id: "perfectpay", nome: "PerfectPay", emoji: "🟦", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Token do Postback", keyHint: "Painel PerfectPay › Configurações › Postback/Notificações. Cole a URL de postback.", base: "https://app.perfectpay.com.br/api" },
  { id: "cakto", nome: "Cakto", emoji: "🟢", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Chave do Webhook", keyHint: "Painel Cakto › Integrações/Webhooks. Cole a URL de postback.", base: "https://api.cakto.com.br" },
  { id: "appmax", nome: "AppMax", emoji: "🅰️", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Token do Webhook", keyHint: "Painel AppMax › Configurações › Webhooks/Notificações. Cole a URL de postback.", base: "https://admin.appmax.com.br/api/v3" },
  { id: "kirvano", nome: "Kirvano", emoji: "⚫", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Token de validação do Webhook", keyHint: "Painel Kirvano › Webhooks › criar. Cole a URL de postback.", base: "" },
  { id: "ticto", nome: "Ticto", emoji: "🟡", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Token do Postback", keyHint: "Painel Ticto › Integrações/Postback. Cole a URL de postback.", base: "https://glados.ticto.cloud/api" },
  { id: "greenn", nome: "Greenn", emoji: "🟩", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Token do Webhook", keyHint: "Painel Greenn › Integrações › Webhook. Cole a URL de postback.", base: "" },
  { id: "hubla", nome: "Hubla", emoji: "🟣", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Hubla Token (webhook)", keyHint: "Painel Hubla › Configurações › Webhooks. Cole a URL de postback.", base: "" },
  { id: "guru", nome: "Digital Manager Guru", emoji: "🧙", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Token do Webhook", keyHint: "Painel Guru › Meu Perfil › Tokens/Webhooks. Cole a URL de postback.", base: "https://digitalmanager.guru/api/v2" },
  { id: "payt", nome: "Payt", emoji: "💳", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Token do Postback", keyHint: "Painel Payt › Integrações/Postback. Cole a URL de postback.", base: "https://app.payt.com" },
  { id: "voomp", nome: "Voomp", emoji: "🎬", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Token do Postback", keyHint: "Painel Voomp › Configurações do sistema › Integrações e Tokens. Cole a URL de postback.", base: "" },
  { id: "yever", nome: "Yever", emoji: "🟧", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Token do Webhook", keyHint: "Painel Yever › Configuração › Webhook. Cole a URL de postback.", base: "https://api.yever.com.br/api/v1" },
  { id: "adoorei", nome: "Adoorei", emoji: "🚪", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Token do Webhook", keyHint: "Painel Adoorei › Configurações › Webhooks. Cole a URL de postback.", base: "" },
  { id: "pepper", nome: "PepperPay", emoji: "🌶️", categoria: "checkout", conexao: "postback", nativo: false, keyLabel: "Token do Webhook", keyHint: "Painel Pepper › Configurações › Webhooks. Cole a URL de postback.", base: "https://api.cloud.pepperpay.com.br" },

  // ── Gateways de pagamento ───────────────────────────────────────────────────
  { id: "mercadopago", nome: "Mercado Pago", emoji: "💙", categoria: "gateway", conexao: "postback", nativo: false, keyLabel: "Access Token (produção)", keyHint: "Painel Mercado Pago › Suas integrações › Credenciais de produção. Configure o Webhook/IPN com a URL abaixo.", base: "https://api.mercadopago.com" },
  { id: "pagseguro", nome: "PagBank / PagSeguro", emoji: "🟨", categoria: "gateway", conexao: "postback", nativo: false, keyLabel: "Token da conta", keyHint: "Painel PagBank › Integrações › Token + Notificação (URL abaixo).", base: "https://api.pagseguro.com" },
  { id: "pagarme", nome: "Pagar.me", emoji: "🟩", categoria: "gateway", conexao: "postback", nativo: false, keyLabel: "Secret Key", keyHint: "Dashboard Pagar.me › Configurações › Chaves + Webhooks (URL abaixo).", base: "https://api.pagar.me/core/v5" },
  { id: "asaas", nome: "Asaas", emoji: "🔵", categoria: "gateway", conexao: "postback", nativo: false, keyLabel: "Chave de API", keyHint: "Painel Asaas › Integrações › API + Webhooks (URL abaixo).", base: "https://api.asaas.com/v3" },
  { id: "stripe", nome: "Stripe", emoji: "🟦", categoria: "gateway", conexao: "postback", nativo: false, keyLabel: "Secret Key (sk_live_…)", keyHint: "Dashboard Stripe › Developers › API keys + Webhooks (URL abaixo).", base: "https://api.stripe.com/v1" },
  { id: "iugu", nome: "Iugu", emoji: "🟩", categoria: "gateway", conexao: "postback", nativo: false, keyLabel: "API Token (live)", keyHint: "Painel Iugu › Administração › API + Gatilhos/Webhooks (URL abaixo).", base: "https://api.iugu.com/v1" },
  { id: "efi", nome: "Efí (Gerencianet)", emoji: "🟠", categoria: "gateway", conexao: "postback", nativo: false, keyLabel: "Client_Id/Secret + certificado", keyHint: "Painel Efí › API › Aplicações + Notificações (URL abaixo).", base: "https://cobrancas.api.efipay.com.br" },
  { id: "vindi", nome: "Vindi", emoji: "🟣", categoria: "gateway", conexao: "postback", nativo: false, keyLabel: "Chave privada da API", keyHint: "Painel Vindi › Configurações › Chaves de API + Webhooks (URL abaixo).", base: "https://app.vindi.com.br/api/v1" },
  { id: "cielo", nome: "Cielo", emoji: "🔷", categoria: "gateway", conexao: "postback", nativo: false, keyLabel: "MerchantId + MerchantKey", keyHint: "Cielo E-commerce › credenciais da API + Notificação (URL abaixo).", base: "https://apiquery.cieloecommerce.cielo.com.br" },
  { id: "getnet", nome: "Getnet", emoji: "🟥", categoria: "gateway", conexao: "postback", nativo: false, keyLabel: "Client_Id/Secret (aplicação)", keyHint: "Portal do Desenvolvedor Getnet › aplicação + Notificações (URL abaixo).", base: "https://api.getnet.com.br" },
  { id: "ebanx", nome: "EBANX", emoji: "🟦", categoria: "gateway", conexao: "postback", nativo: false, keyLabel: "Integration Key", keyHint: "Dashboard EBANX › Integration › Keys + Notificações (URL abaixo).", base: "https://api.ebanxpay.com/ws" },

  // ── E-commerce / plataformas de loja ────────────────────────────────────────
  { id: "shopify", nome: "Shopify", emoji: "🛍", categoria: "ecommerce", conexao: "postback", nativo: false, keyLabel: "Admin API access token + domínio", keyHint: "Admin Shopify › Apps › Develop apps › API credentials. Configure o Webhook de pedidos com a URL abaixo.", base: "https://{loja}.myshopify.com/admin/api" },
  { id: "nuvemshop", nome: "Nuvemshop", emoji: "🟦", categoria: "ecommerce", conexao: "postback", nativo: false, keyLabel: "Access Token (OAuth)", keyHint: "Painel Nuvemshop › Apps/Notificações. Configure a URL de webhook abaixo.", base: "https://api.nuvemshop.com.br" },
  { id: "woocommerce", nome: "WooCommerce", emoji: "🟪", categoria: "ecommerce", conexao: "postback", nativo: false, keyLabel: "Consumer Key/Secret + domínio", keyHint: "WordPress › WooCommerce › Configurações › Avançado › Webhooks. Aponte para a URL abaixo.", base: "https://SEU-DOMINIO/wp-json/wc/v3" },
  { id: "yampi", nome: "Yampi", emoji: "🟧", categoria: "ecommerce", conexao: "postback", nativo: false, keyLabel: "User-Token + Secret Key", keyHint: "Painel Yampi › Configurações › Credenciais de API + Webhooks (URL abaixo).", base: "https://api.dooki.com.br/v2" },
  { id: "tray", nome: "Tray", emoji: "🟩", categoria: "ecommerce", conexao: "postback", nativo: false, keyLabel: "Consumer Key/Secret (app)", keyHint: "Tray › aplicativo OAuth + Notificações (URL abaixo).", base: "https://{loja}/web_api" },
  { id: "vtex", nome: "VTEX", emoji: "🩷", categoria: "ecommerce", conexao: "postback", nativo: false, keyLabel: "appKey + appToken", keyHint: "Admin VTEX › Account Settings › Application Keys + Hook de pedidos (URL abaixo).", base: "https://{conta}.vtexcommercestable.com.br" },
  { id: "cartpanda", nome: "CartPanda", emoji: "🐼", categoria: "ecommerce", conexao: "postback", nativo: false, keyLabel: "API token + shop_slug", keyHint: "Painel CartPanda › API + Webhooks (URL abaixo).", base: "https://accounts.cartpanda.com/api/v3" },
  { id: "loja_integrada", nome: "Loja Integrada", emoji: "🟦", categoria: "ecommerce", conexao: "postback", nativo: false, keyLabel: "Chave API + Application Key", keyHint: "Painel Loja Integrada › Configurações › API + Webhooks (URL abaixo).", base: "https://api.awsli.com.br/api/v1" },

  // ── Marketplaces ────────────────────────────────────────────────────────────
  { id: "mercadolivre", nome: "Mercado Livre", emoji: "💛", categoria: "marketplace", conexao: "postback", nativo: false, keyLabel: "Access Token (OAuth)", keyHint: "Mercado Livre › Devcenter › aplicação (OAuth) + Notificações (URL abaixo).", base: "https://api.mercadolibre.com" },
  { id: "shopee", nome: "Shopee", emoji: "🧡", categoria: "marketplace", conexao: "postback", nativo: false, keyLabel: "Partner Id/Key (OAuth)", keyHint: "Shopee Open Platform › app (OAuth) + Push/Callback (URL abaixo).", base: "https://partner.shopeemobile.com" },

  // ── Genérico (qualquer API REST) ────────────────────────────────────────────
  { id: "generic", nome: "Genérico (API/Webhook)", emoji: "🧩", categoria: "ecommerce", conexao: "pull", nativo: false, keyLabel: "Chave da API (Bearer)", keyHint: "Para qualquer plataforma com API REST: informe a Base URL do conector e a chave; puxamos de {base}/orders. Ou use a URL de postback abaixo.", base: "" },
];

export const PLATAFORMA_CATEGORIAS: { key: PlatformCategoria; label: string }[] = [
  { key: "checkout", label: "Checkouts / Infoproduto" },
  { key: "gateway", label: "Gateways de Pagamento" },
  { key: "ecommerce", label: "E-commerce / Loja" },
  { key: "marketplace", label: "Marketplaces" },
];

const BY_ID: Record<string, Plataforma> = Object.fromEntries(PLATAFORMAS.map((p) => [p.id, p]));
export const getPlataforma = (id: string): Plataforma | undefined => BY_ID[id];
export const platformName = (id: string): string => BY_ID[id]?.nome ?? id;
export const platformEmoji = (id: string): string => BY_ID[id]?.emoji ?? "🏪";
export const platformCategoriaDb = (id: string): string => {
  const c = BY_ID[id]?.categoria;
  return c === "checkout" || c === "gateway" ? "pagamento" : "ecommerce";
};
