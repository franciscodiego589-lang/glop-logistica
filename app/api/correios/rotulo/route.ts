import { createClient } from "@/lib/supabase/server";
import { correiosBearerCartao, correiosRotulo, correiosConfigurado } from "@/lib/correios";

export const dynamic = "force-dynamic";

// Gera o rótulo/etiqueta (PDF base64) de um objeto já prepostado.
export async function POST(req: Request) {
  const supabase = createClient();
  if (!supabase) return Response.json({ error: "Supabase não configurado" }, { status: 500 });
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return Response.json({ error: "Não autenticado" }, { status: 401 });
  if (!correiosConfigurado()) return Response.json({ error: "Configure o secret CORREIOS_API_TOKEN_PEDIDOS." }, { status: 400 });

  let body: any = {}; try { body = await req.json(); } catch {}
  const codigo = String(body.codigo_objeto ?? "").trim().toUpperCase();
  if (!codigo) return Response.json({ error: "codigo_objeto ausente" }, { status: 400 });

  const { data: rem } = await supabase.from("remetente_config").select("numero_cartao_postagem").eq("company_id", company).is("deleted_at", null).limit(1).maybeSingle();
  const cartao = String((rem as any)?.numero_cartao_postagem ?? "");

  try {
    const bearer = await correiosBearerCartao(cartao);
    const r = await correiosRotulo(bearer, codigo);
    if (!r.ok || !r.pdfBase64) return Response.json({ error: (r.body?.mensagem ?? "Rótulo não disponível ainda.") }, { status: 502 });
    // salva na prepostagem correspondente (se existir)
    await supabase.from("prepostagens").update({ etiqueta_pdf_base64: r.pdfBase64 }).eq("codigo_objeto", codigo).eq("company_id", company).is("deleted_at", null);
    return Response.json({ ok: true, pdf_base64: r.pdfBase64, nome: r.nome ?? `etiqueta-${codigo}.pdf` });
  } catch (e: any) {
    return Response.json({ error: e.message ?? "Falha ao gerar rótulo" }, { status: 502 });
  }
}
