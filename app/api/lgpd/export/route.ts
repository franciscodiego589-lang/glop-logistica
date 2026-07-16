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

  let q = supabase.from("store_orders")
    .select("sale_number,platform,buyer_name,buyer_doc,buyer_email,buyer_phone,dest_zip,dest_street,dest_number,dest_district,dest_city,dest_uf,product_name,value,state,tracking_code,created_at")
    .eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(2000);
  if (doc) q = q.eq("buyer_doc", doc);
  else q = q.ilike("buyer_email", email);
  const { data: pedidos } = await q;

  const lista = pedidos ?? [];
  const titular = lista[0] ? { nome: lista[0].buyer_name, documento: lista[0].buyer_doc, email: lista[0].buyer_email, telefone: lista[0].buyer_phone } : { documento: doc || null, email: email || null };

  return Response.json({
    lgpd: "Relatório de dados pessoais do titular (art. 18, LGPD) — gerado pelo GLOP",
    gerado_em: new Date().toISOString(),
    titular,
    total_pedidos: lista.length,
    pedidos: lista,
    observacao: "Dados tratados na qualidade de operador/controlador conforme a Política de Privacidade. Para exclusão/anonimização, acionar o Encarregado.",
  });
}
