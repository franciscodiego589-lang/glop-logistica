import { correiosConfigurado, cepToken, correiosCep } from "@/lib/correios";

export const dynamic = "force-dynamic";

// Diagnóstico: informa (sem vazar segredo) se as chaves Correios chegaram à função
// e faz um teste ao vivo de CEP. Retorna só booleanos + resultado público.
export async function GET() {
  const out: any = {
    pedidos_token_presente: correiosConfigurado(),
    cep_token_presente: !!cepToken(),
  };
  if (out.cep_token_presente) {
    try {
      const r = await correiosCep("01310100");
      out.cep_teste_ok = !!r?.uf;
      out.cep_teste = r?.uf ? `${r.localidade ?? r.cidade}/${r.uf}` : null;
    } catch (e: any) {
      out.cep_teste_ok = false;
      out.cep_teste_erro = String(e?.message ?? e).slice(0, 200);
    }
  }
  return Response.json(out);
}
