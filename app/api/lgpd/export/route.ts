import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";
const dig = (v: any) => String(v ?? "").replace(/\D/g, "");

// Portabilidade LGPD (art. 18): reúne todos os dados de um titular (comprador) por
// CPF/CNPJ ou e-mail e devolve em JSON. Exige usuário autenticado.
export async function POST(req: Request) {
  const supabase = createClient();
  if (!supabase) return Response.json({ error: "Supabase não configurado" }, { status: 500 });
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return Response.json({ error: "Não autenticado" }, { status: 401 });

  let body: any = {}; try { body = await req.json(); } catch {}
  const doc = dig(body.doc);
  const email = String(body.email ?? "").trim().toLowerCase();
  if (!doc && !email) return Response.json({ error: "Informe o CPF/CNPJ ou o e-mail do titular." }, { status: 400 });

  // RPC guardada por permissão (admin.read); casa o documento por dígitos (grava formatado ou cru)
  const { data, error } = await supabase.rpc("lgpd_export_titular", { p_company: company, p_doc: doc || null, p_email: email || null });
  if (error) {
    if (/forbidden/i.test(error.message)) return Response.json({ error: "Sem permissão para exportar dados de titular." }, { status: 403 });
    console.error("lgpd export", error);
    return Response.json({ error: "Não foi possível gerar o relatório." }, { status: 500 });
  }
  return Response.json({ ...(data as any), observacao: "Dados tratados conforme a Política de Privacidade. Para exclusão/anonimização, acionar o Encarregado." });
}
