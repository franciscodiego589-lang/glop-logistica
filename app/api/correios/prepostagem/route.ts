import { createClient } from "@/lib/supabase/server";
import { correiosBearerCartao, correiosPrepostagem, correiosConfigurado, correiosCep } from "@/lib/correios";

export const dynamic = "force-dynamic";

const dig = (v: any) => String(v ?? "").replace(/\D/g, "");
const ddd = (fone: any) => { const d = dig(fone); return d.length >= 10 ? d.slice(0, 2) : ""; };
const num = (fone: any) => { const d = dig(fone); return d.length >= 10 ? d.slice(2) : d; };

// Gera a prepostagem oficial dos Correios para um pedido (store_orders).
export async function POST(req: Request) {
  const supabase = createClient();
  if (!supabase) return Response.json({ error: "Supabase não configurado" }, { status: 500 });
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return Response.json({ error: "Não autenticado" }, { status: 401 });
  if (!correiosConfigurado()) return Response.json({ error: "Configure o secret CORREIOS_API_TOKEN_PEDIDOS (chave CWS) nas variáveis de ambiente." }, { status: 400 });

  let body: any = {}; try { body = await req.json(); } catch {}
  const orderId = body.order_id;
  if (!orderId) return Response.json({ error: "order_id ausente" }, { status: 400 });

  const { data: o } = await supabase.from("store_orders")
    .select("id,sale_number,connector_id,buyer_name,buyer_doc,buyer_email,buyer_phone,dest_zip,dest_street,dest_number,dest_district,dest_city,dest_uf,product_name,weight_kg,value,state")
    .eq("id", orderId).eq("company_id", company).is("deleted_at", null).single();
  if (!o) return Response.json({ error: "Pedido não encontrado" }, { status: 404 });
  if (!o.dest_zip || !o.dest_city) return Response.json({ error: "Pedido sem endereço/CEP de destino — corrija antes de prepostar." }, { status: 400 });

  const { data: rem } = await supabase.from("remetente_config")
    .select("nome,documento,email,telefone,cep,endereco,numero,complemento,bairro,cidade,estado,numero_contrato,numero_cartao_postagem")
    .eq("company_id", company).is("deleted_at", null).limit(1).maybeSingle();
  if (!rem?.numero_cartao_postagem) return Response.json({ error: "Configure o remetente (cartão de postagem, endereço, documento) em Correios → Contratos & Remetente." }, { status: 400 });

  const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", company).single();
  const tenant = (comp as any)?.tenant_id;

  const servico = String(body.servico_codigo ?? "03298"); // PAC contrato AG (default)
  const peso_g = Number(body.peso_g) || (o.weight_kg ? Math.round(Number(o.weight_kg) * 1000) : 300);
  const dims = body.dimensoes ?? { altura: 5, largura: 12, comprimento: 18 };
  const foneOk = (f: any) => { const d = dig(f); return d.length === 10 || d.length === 11; };

  // Os pedidos geralmente vêm sem logradouro/bairro — enriquece pelo CEP (Correios exige).
  let logradouro = o.dest_street, bairro = o.dest_district;
  if (!logradouro || !bairro) {
    try { const c: any = await correiosCep(o.dest_zip); logradouro = logradouro || c.logradouro; bairro = bairro || c.bairro; } catch {}
  }
  const valorDecl = (Number(o.value) > 0 ? Number(o.value) : 1).toFixed(2).replace(".", ",");
  const enderecoDest = { cep: dig(o.dest_zip), logradouro: logradouro || "Centro", numero: String(o.dest_number ?? "SN"), bairro: bairro || "Centro", cidade: o.dest_city, uf: o.dest_uf };

  const payload: any = {
    codigoServico: servico,
    numeroCartaoPostagem: String(rem.numero_cartao_postagem),
    cienteObjetoNaoProibido: "1",
    modalidadePagamento: "2",
    codigoFormatoObjetoInformado: String(body.formato ?? "2"), // 1=envelope, 2=pacote/caixa, 3=rolo
    pesoInformado: String(peso_g),
    alturaInformada: String(dims.altura), larguraInformada: String(dims.largura), comprimentoInformado: String(dims.comprimento),
    remetente: {
      nome: rem.nome, cpfCnpj: dig(rem.documento), email: rem.email ?? "",
      ...(foneOk(rem.telefone) ? { dddTelefone: ddd(rem.telefone), telefone: num(rem.telefone) } : {}),
      endereco: { cep: dig(rem.cep), logradouro: rem.endereco, numero: String(rem.numero ?? "SN"), bairro: rem.bairro, cidade: rem.cidade, uf: rem.estado },
    },
    destinatario: {
      nome: o.buyer_name, cpfCnpj: dig(o.buyer_doc), email: o.buyer_email ?? "",
      ...(foneOk(o.buyer_phone) ? { dddTelefone: ddd(o.buyer_phone), telefone: num(o.buyer_phone) } : {}),
      endereco: enderecoDest,
    },
    itensDeclaracaoConteudo: [{ conteudo: String(o.product_name ?? "Produto").slice(0, 60), quantidade: "1", valor: valorDecl }],
    observacao: ("Pedido " + o.sale_number).slice(0, 50),
  };

  // 1) grava prepostagem 'pendente' com o request
  const { data: pre, error: insErr } = await supabase.from("prepostagens").insert({
    tenant_id: tenant, company_id: company, servico_codigo: servico, quantidade: 1,
    peso_g, altura_cm: dims.altura, largura_cm: dims.largura, comprimento_cm: dims.comprimento,
    valor_declarado: Number(o.value) || null,
    destinatario_nome: o.buyer_name, destinatario_cep: dig(o.dest_zip),
    destinatario_endereco: [logradouro, o.dest_number, bairro].filter(Boolean).join(", "),
    destinatario_cidade: o.dest_city, destinatario_estado: o.dest_uf,
    status: "pendente", payload_request: payload, metadata: { store_order_id: o.id, sale_number: o.sale_number },
  }).select("id").single();
  if (insErr) { console.error("prepostagem insert", insErr); return Response.json({ error: "Não foi possível registrar a prepostagem." }, { status: 500 }); }

  // 2) chama os Correios
  let r: { ok: boolean; status: number; body: any };
  try {
    const bearer = await correiosBearerCartao(String(rem.numero_cartao_postagem));
    r = await correiosPrepostagem(bearer, payload);
  } catch (e: any) {
    await supabase.from("prepostagens").update({ status: "erro", erro: String(e.message ?? e).slice(0, 800) }).eq("id", (pre as any).id);
    return Response.json({ error: e.message ?? "Falha na autenticação Correios" }, { status: 502 });
  }

  if (r.ok) {
    const codigoObjeto = r.body.codigoObjeto ?? r.body.codigoRastreio ?? r.body.numeroObjeto ?? null;
    const idPre = r.body.id ?? r.body.idPrepostagem ?? r.body.numeroPrepostagem ?? null;
    const servNome = r.body.nomeServico ?? null;
    await supabase.from("prepostagens").update({
      codigo_objeto: codigoObjeto, id_prepostagem: idPre ? String(idPre) : null, servico_nome: servNome,
      status: "criada", payload_response: r.body,
    }).eq("id", (pre as any).id);
    // propaga o rastreio pro pedido
    if (codigoObjeto) {
      await supabase.rpc("transition_store_order", { p_company: company, p_order: o.id, p_to_state: "pre_postado", p_reason: "prepostagem Correios" }).then(() => {});
      await supabase.from("store_orders").update({ tracking_code: codigoObjeto }).eq("id", o.id).eq("company_id", company);
    }
    return Response.json({ ok: true, codigo_objeto: codigoObjeto, id_prepostagem: idPre, prepostagem_id: (pre as any).id });
  }

  const msg = String(r.body?.mensagem ?? r.body?.msgs?.[0] ?? r.body?.erro ?? ("HTTP " + r.status)).slice(0, 800);
  await supabase.from("prepostagens").update({ status: "erro", erro: "[" + r.status + "] " + msg, payload_response: r.body }).eq("id", (pre as any).id);
  return Response.json({ error: msg }, { status: 502 });
}
