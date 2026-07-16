import { createClient } from "@/lib/supabase/server";
import { correiosRastreio, sroEventoParaEstado, sroConfigurado } from "@/lib/correios";

export const dynamic = "force-dynamic";

// Atualiza o rastreio (SRO) dos pedidos postados e propaga o estado.
// Precisa de CORREIOS_API_TOKEN_SRO (chave com escopo de rastro).
export async function POST(req: Request) {
  const supabase = createClient();
  if (!supabase) return Response.json({ error: "Supabase não configurado" }, { status: 500 });
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return Response.json({ error: "Não autenticado" }, { status: 401 });
  if (!sroConfigurado()) return Response.json({ error: "Configure o secret CORREIOS_API_TOKEN_SRO (chave dos Correios com escopo de rastreio)." }, { status: 400 });

  let body: any = {}; try { body = await req.json(); } catch {}
  const limite = Math.min(Number(body.limite) || 40, 80);

  // objetos a atualizar: com rastreio e ainda não entregues
  const { data: orders } = await supabase.from("store_orders")
    .select("id,tracking_code,state")
    .eq("company_id", company).is("deleted_at", null)
    .not("tracking_code", "is", null)
    .not("state", "in", "(entregue,devolvido,cancelado)")
    .limit(limite);

  const lista = orders ?? [];
  let atualizados = 0, entregues = 0, erros = 0; const detalhes: any[] = [];
  for (const o of lista) {
    try {
      const obj = await correiosRastreio((o as any).tracking_code);
      const eventos = obj?.eventos ?? [];
      if (!eventos.length) continue;
      const ev = eventos[0]; // o SRO retorna do mais recente para o mais antigo
      const novoEstado = sroEventoParaEstado(ev.tipo, ev.descricao);
      const local = [ev?.unidade?.nome ?? ev?.estacao, ev?.unidade?.endereco?.cidade].filter(Boolean).join(" - ");
      // grava último status na prepostagem correspondente
      await supabase.from("prepostagens").update({
        ultimo_status: ev.descricao, ultimo_status_data: ev.dtHrCriado, ultimo_status_local: local || null,
        ultima_consulta: new Date().toISOString(), eventos_rastreio: eventos,
      }).eq("codigo_objeto", (o as any).tracking_code).eq("company_id", company).is("deleted_at", null);
      // propaga o estado pro pedido
      if (novoEstado && novoEstado !== (o as any).state) {
        await supabase.rpc("transition_store_order", { p_company: company, p_order: (o as any).id, p_to_state: novoEstado, p_reason: "rastreio Correios (SRO)" });
        if (novoEstado === "entregue") entregues++;
      }
      atualizados++;
      detalhes.push({ codigo: (o as any).tracking_code, status: ev.descricao });
    } catch (e: any) { erros++; if (detalhes.length < 60) detalhes.push({ codigo: (o as any).tracking_code, erro: String(e.message ?? e).slice(0, 120) }); }
  }

  return Response.json({ ok: true, consultados: lista.length, atualizados, entregues, erros, detalhes: detalhes.slice(0, 40) });
}
