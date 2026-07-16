import { createClient } from "@/lib/supabase/server";
import crypto from "node:crypto";

export const dynamic = "force-dynamic";

// Gera uma chave de API do produtor. A chave em texto é mostrada UMA vez ao criar;
// o banco guarda só o hash (sha256) + um prefixo para exibição. Nunca re-exibida.

export async function POST(req: Request) {
  const supabase = createClient();
  if (!supabase) return Response.json({ error: "Supabase não configurado" }, { status: 500 });
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  const { data: auth } = await supabase.auth.getUser();
  const userId = auth?.user?.id;
  if (!userId) return Response.json({ error: "Não autenticado" }, { status: 401 });
  let body: any = {}; try { body = await req.json(); } catch {}
  const nome = String(body.nome ?? "").trim() || "Chave de API";
  const escopos: string[] = Array.isArray(body.escopos) && body.escopos.length ? body.escopos : ["vendas:read", "pedidos:read"];

  const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", company).single();
  const tenant = (comp as any)?.tenant_id;
  if (!tenant) return Response.json({ error: "Empresa não resolvida." }, { status: 400 });

  // resolve (ou cria) um produtor para a company
  let { data: prod } = await supabase.from("produtores_integracao").select("id").eq("company_id", company).is("deleted_at", null).limit(1).maybeSingle();
  if (!prod) {
    const { data: novo, error: e0 } = await supabase.from("produtores_integracao")
      .insert({ tenant_id: tenant, company_id: company, nome: "Produtor Principal" })
      .select("id").single();
    if (e0) return Response.json({ error: "Não foi possível preparar o produtor: " + e0.message }, { status: 500 });
    prod = novo;
  }

  // gera a chave
  const raw = "glp_" + crypto.randomBytes(24).toString("hex");
  const key_prefix = raw.slice(0, 12);
  const key_hash = crypto.createHash("sha256").update(raw).digest("hex");

  const { error } = await supabase.from("produtor_api_keys").insert({
    tenant_id: tenant, company_id: company, produtor_id: (prod as any).id, user_id: userId,
    nome, key_prefix, key_hash, escopos, ativo: true,
  });
  if (error) return Response.json({ error: "Erro ao criar chave: " + error.message }, { status: 500 });

  // retorna a chave em texto UMA vez
  return Response.json({ ok: true, key: raw, key_prefix, nome, escopos, aviso: "Guarde esta chave agora — ela não será exibida de novo." });
}
