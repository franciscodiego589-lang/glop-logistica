import { askClaudeJSON, iaConfigured, IA_NAO_CONFIGURADA } from "@/lib/anthropic";

export const dynamic = "force-dynamic";

// Importação inteligente (SOIDI): recebe um texto BAGUNÇADO (colado de e-mail,
// WhatsApp, planilha fora do padrão) e usa o Claude para extrair os pedidos em
// formato estruturado, que o usuário confere antes de importar. Não grava nada.

const SYSTEM = `Você extrai PEDIDOS de venda a partir de texto bagunçado (e-mail, WhatsApp, planilha colada), para um ERP de dropshipping de suplementos no Brasil.
Devolva APENAS um array JSON. Cada pedido: {"sale_number","buyer_name","buyer_doc","buyer_email","buyer_phone","dest_zip","dest_street","dest_number","dest_district","dest_city","dest_uf","product_name","value"}.
REGRAS:
- buyer_doc = só dígitos do CPF/CNPJ. dest_zip = só dígitos do CEP. dest_uf = sigla de 2 letras (SP, RJ…).
- value = número decimal com ponto (ex 197.00), sem "R$".
- Campo que não aparecer no texto → string vazia "" (ou 0 para value). NÃO invente dados.
- Se houver vários pedidos, um objeto por pedido. Se não achar nenhum pedido, devolva [].`;

export async function POST(req: Request) {
  if (!iaConfigured()) {
    return Response.json({ configured: false, pedidos: [], message: "IA não configurada. Cole a chave da Anthropic na Netlify (ANTHROPIC_API_KEY)." }, { status: 200 });
  }
  let body: any = {}; try { body = await req.json(); } catch {}
  const texto = String(body.texto ?? "").trim().slice(0, 8000);
  if (!texto) return Response.json({ error: "texto vazio" }, { status: 400 });

  try {
    const pedidos = await askClaudeJSON<any[]>({
      system: SYSTEM,
      user: `TEXTO PARA EXTRAIR:\n"""\n${texto}\n"""\n\nDevolva o array JSON dos pedidos.`,
      maxTokens: 2000,
    });
    const clean = (Array.isArray(pedidos) ? pedidos : []).slice(0, 100);
    return Response.json({ configured: true, pedidos: clean }, { status: 200 });
  } catch (e: any) {
    if (e?.message === IA_NAO_CONFIGURADA) return Response.json({ configured: false, pedidos: [] }, { status: 200 });
    console.error("[ia/extrair-pedido]", e?.message);
    return Response.json({ error: e?.message ?? "falha na IA" }, { status: 502 });
  }
}
