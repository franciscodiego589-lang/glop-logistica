import { createClient } from "@/lib/supabase/server";
import { correiosCep } from "@/lib/correios";

export const dynamic = "force-dynamic";

// Valida/consulta CEP nos Correios (escopo Endereços). Exige usuário autenticado.
export async function POST(req: Request) {
  const supabase = createClient();
  if (!supabase) return Response.json({ error: "Supabase não configurado" }, { status: 500 });
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return Response.json({ error: "Não autenticado" }, { status: 401 });

  let body: any = {}; try { body = await req.json(); } catch {}
  try {
    const r = await correiosCep(String(body.cep ?? ""));
    const cidade = r.cidade ?? r.localidade ?? r.municipio;
    return Response.json({
      ok: true,
      cep: r.cep, logradouro: r.logradouro, bairro: r.bairro, cidade, uf: r.uf,
      cepAnterior: r.cepAnterior ?? null,
    });
  } catch (e: any) {
    return Response.json({ error: e.message ?? "Falha ao consultar CEP" }, { status: 400 });
  }
}
