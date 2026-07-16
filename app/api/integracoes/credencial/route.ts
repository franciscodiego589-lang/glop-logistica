import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

// Salva a CHAVE de API de uma plataforma (write-only): grava em store_connectors.
// A chave NUNCA é retornada ao client. Aceita:
//  - connector_id + key  → atualiza o conector existente
//  - platform (+ nome, categoria) + key → acha ou cria o conector e grava a chave
export async function POST(req: Request) {
  const supabase = createClient();
  if (!supabase) return Response.json({ error: "Supabase não configurado" }, { status: 500 });
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let body: any = {}; try { body = await req.json(); } catch {}
  const key = String(body.key ?? "").trim();
  if (!key) return Response.json({ error: "Cole a chave da API." }, { status: 400 });

  const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", company).single();
  const tenant = (comp as any)?.tenant_id;
  if (!tenant) return Response.json({ error: "Empresa não resolvida." }, { status: 400 });

  let connectorId = body.connector_id as string | undefined;

  // sem connector_id: acha ou cria por plataforma
  if (!connectorId) {
    const platform = String(body.platform ?? "").trim();
    if (!platform) return Response.json({ error: "Informe a plataforma." }, { status: 400 });
    const categoria = String(body.categoria ?? "ecommerce");
    const nome = String(body.nome ?? "").trim() || platform;
    const { data: existing } = await supabase.from("store_connectors")
      .select("id").eq("company_id", company).eq("platform", platform).is("deleted_at", null).limit(1).maybeSingle();
    if (existing) connectorId = (existing as any).id;
    else {
      const code = (platform + "-" + Math.random().toString(36).slice(2, 7)).toUpperCase();
      const { data: novo, error: e0 } = await supabase.from("store_connectors")
        .insert({ tenant_id: tenant, company_id: company, code, name: nome, platform, categoria, auth_type: "apikey", status: "inactive" })
        .select("id").single();
      if (e0) return Response.json({ error: "Não foi possível criar o conector: " + e0.message }, { status: 500 });
      connectorId = (novo as any).id;
    }
  }

  // pega metadata atual (pra preservar) — SÓ metadata, sem a chave
  const { data: cur } = await supabase.from("store_connectors").select("metadata").eq("id", connectorId).eq("company_id", company).single();
  const meta = ((cur as any)?.metadata ?? {}) as Record<string, any>;

  const { error } = await supabase.from("store_connectors")
    .update({ webhook_token: key, status: "active", metadata: { ...meta, key_set: true } })
    .eq("id", connectorId).eq("company_id", company).is("deleted_at", null);
  if (error) return Response.json({ error: "Erro ao salvar a chave: " + error.message }, { status: 500 });

  return Response.json({ ok: true, connector_id: connectorId, message: "Chave salva. Agora você pode puxar os pedidos." });
}
