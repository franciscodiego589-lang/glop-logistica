"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Pedidos", "SEM PLANO", "Conectores", "Regras de Plano", "Logs de Webhook"] as const;
const PLAT = (p: string) => ({ monetizze: "Monetizze", hotmart: "Hotmart", kiwify: "Kiwify", yampi: "Yampi", shopify: "Shopify", mercado_livre: "Mercado Livre", woocommerce: "WooCommerce", nuvemshop: "Nuvemshop", tray: "Tray", cartpanda: "CartPanda", braip: "Braip", eduzz: "Eduzz", perfectpay: "PerfectPay", generic: "Genérico" } as any)[p] ?? p;
const stColor = (s: string) => ({ recebido: "#6366f1", importado: "#2563eb", pronto_despacho: "#0891b2", pre_postado: "#0891b2", etiquetado: "#d97706", postado: "#16a34a", em_transito: "#2563eb", saiu_entrega: "#d97706", entregue: "#15803d", sem_plano: "#eab308", endereco_invalido: "#ea580c", bloqueado_reembolso: "#dc2626", cancelado: "#64748b", devolvido: "#7c3aed", extraviado: "#dc2626" } as any)[s] ?? "#64748b";
const stLabel = (s: string) => ({ recebido: "Recebido", importado: "Importado", pronto_despacho: "Pronto p/ despacho", pre_postado: "Pré-postado", etiquetado: "Etiquetado", postado: "Postado", em_transito: "Em trânsito", saiu_entrega: "Saiu p/ entrega", entregue: "Entregue", sem_plano: "SEM PLANO", endereco_invalido: "Endereço inválido", bloqueado_reembolso: "Bloqueado (reembolso)", cancelado: "Cancelado", devolvido: "Devolvido", extraviado: "Extraviado" } as any)[s] ?? s;
const NEXT_STATE: Record<string, string> = { recebido: "importado", importado: "pronto_despacho", pronto_despacho: "pre_postado", pre_postado: "etiquetado", etiquetado: "postado", postado: "em_transito", em_transito: "saiu_entrega", saiu_entrega: "entregue" };

export default function StoreHubWorkbench({ dash, connectors, orders, events, rules }: {
  dash: any; connectors: any[]; orders: any[]; events: any[]; rules: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState("");
  const [sim, setSim] = useState({ connector: "", event: "paid", sale: "", value: "197.90" });
  const d = dash ?? {};

  async function advance(o: any) {
    if (!supabase) return; const to = NEXT_STATE[o.state]; if (!to) return; setBusy(o.id);
    const { error } = await supabase.rpc("transition_store_order", { p_company: COMPANY, p_order: o.id, p_to_state: to, p_reason: "Avançado manualmente" });
    setBusy(""); if (error) alert(error.message.includes("Bloqueado") ? "🚫 " + error.message : "Erro: " + error.message); else router.refresh();
  }
  async function resolve(id: string) {
    if (!supabase) return; setBusy(id);
    const { data, error } = await supabase.rpc("resolve_store_plan", { p_company: COMPANY, p_order: id });
    setBusy(""); if (error) alert("Erro: " + error.message); else { if (!data?.plan_ref) alert("Nenhuma regra casou — crie uma em Regras de Plano."); router.refresh(); }
  }
  async function simulate() {
    if (!supabase || !sim.connector || !sim.sale) { alert("Escolha conector e nº da venda."); return; }
    setBusy("sim");
    const { data, error } = await supabase.rpc("ingest_store_webhook", { p_company: COMPANY, p_connector: sim.connector, p_event_type: sim.event, p_sale_number: sim.sale, p_raw: { buyer_name: "Cliente Teste", product_name: "MOUNJAX - GOTAS - 1 FRASCO", value: sim.value, dest_uf: "SP", dest_zip: "01310100" }, p_signature_valid: true });
    setBusy("");
    if (error) alert("Erro: " + error.message);
    else alert(data?.duplicate ? "🔁 " + data.message + " (idempotência funcionou)" : `✅ Evento processado. Estado: ${data?.state}`);
    router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🏪</div>
        <div>
          <h1 className="text-xl font-bold">Integrações de Lojas</h1>
          <p className="text-sm muted">Webhooks à prova de reentrega · Monetizze/Hotmart/Kiwify/Shopify/... · máquina de estados · SEM PLANO · multi-produtor</p>
        </div>
      </div>

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="space-y-4">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="Lojas conectadas" value={d.connectors ?? 0} accent />
            <KpiCard label="Pedidos" value={d.orders ?? 0} />
            <KpiCard label="Recebidos" value={d.recebido ?? 0} />
            <KpiCard label="Postados" value={d.postado ?? 0} />
            <div className="card p-4" style={{ borderTop: `3px solid ${d.sem_plano ? "var(--warning)" : "var(--success)"}` }}>
              <div className="text-xs uppercase tracking-wide muted font-semibold">SEM PLANO</div>
              <div className="mt-1 text-2xl font-bold" style={{ color: d.sem_plano ? "var(--warning)" : undefined }}>{d.sem_plano ?? 0}</div>
              <div className="text-[11px] muted">R$ {Number(d.sem_plano_valor ?? 0).toLocaleString("pt-BR")} travados</div>
            </div>
            <KpiCard label="Bloqueados (reembolso)" value={d.bloqueado_reembolso ?? 0} tone={d.bloqueado_reembolso ? "danger" : undefined} />
            <KpiCard label="Endereço inválido" value={d.endereco_invalido ?? 0} tone={d.endereco_invalido ? "warning" : undefined} />
            <KpiCard label="Eventos hoje" value={d.eventos_hoje ?? 0} hint={`${d.eventos_nao_processados ?? 0} não processados`} />
          </div>
          <div className="card p-4">
            <div className="font-semibold text-sm mb-2">Por plataforma</div>
            <div className="flex flex-wrap gap-2">{Object.entries(d.by_platform ?? {}).map(([k, v]) => <span key={k} className="badge badge-neutral">{PLAT(k)}: {String(v)}</span>)}
              {Object.keys(d.by_platform ?? {}).length === 0 && <span className="text-sm muted">Sem pedidos ainda — simule um webhook na aba Logs.</span>}</div>
          </div>
          <div className="card p-3 text-xs muted">🔌 As lojas apontam o webhook para a Edge Function <code>store-gateway</code> (a publicar), que valida a assinatura e chama <code>ingest_store_webhook</code> (idempotente). Do lado da logística, o <b>Carrier Hub</b> (Correios/Jadlog/...) já está pronto — juntos cobrem "todas as lojas e todas as transportadoras".</div>
        </div>
      )}

      {tab === "Pedidos" && (
        <div className="space-y-3">
          {orders.length === 0 ? <p className="text-sm muted px-1">Nenhum pedido. Simule um webhook na aba Logs.</p> : orders.map((o) => (
            <div key={o.id} className="card p-4" style={{ borderLeft: `3px solid ${stColor(o.state)}` }}>
              <div className="flex flex-wrap items-center gap-2">
                <span className="font-semibold text-sm">#{o.sale_number}</span>
                <span className="badge" style={{ background: stColor(o.state), color: "#fff" }}>{stLabel(o.state)}</span>
                <span className="badge badge-neutral">{PLAT(o.platform)}{o.producer_ref ? ` · ${o.producer_ref}` : ""}</span>
                <span className="text-xs muted">{o.buyer_name ?? "—"} · {o.product_name ?? ""} · R$ {Number(o.value ?? 0).toLocaleString("pt-BR")}</span>
              </div>
              {o.blocked_reason && <div className="text-xs mt-1 font-semibold" style={{ color: "var(--danger)" }}>⚠ {o.blocked_reason}</div>}
              <div className="flex flex-wrap gap-2 mt-2">
                {NEXT_STATE[o.state] && <button onClick={() => advance(o)} disabled={busy === o.id} className="px-3 py-1.5 rounded-lg bg-brand-600 text-white text-xs font-semibold">→ {stLabel(NEXT_STATE[o.state])}</button>}
                {o.state === "sem_plano" && <button onClick={() => resolve(o.id)} disabled={busy === o.id} className="px-3 py-1.5 rounded-lg bg-yellow-600 text-white text-xs font-semibold">🔧 mapear plano</button>}
              </div>
            </div>
          ))}
        </div>
      )}

      {tab === "SEM PLANO" && (
        orders.filter((o) => o.state === "sem_plano").length === 0 ? <p className="text-sm muted px-1">✅ Nenhum pedido sem plano. Fila limpa.</p> : (
          <div className="space-y-2">
            <p className="text-sm muted">Pedidos que não casaram com nenhum plano/SKU — resolva para liberar o despacho e criar regra permanente.</p>
            {orders.filter((o) => o.state === "sem_plano").map((o) => (
              <div key={o.id} className="card p-3 flex flex-wrap items-center gap-2">
                <span className="font-semibold text-sm">#{o.sale_number}</span>
                <span className="text-xs muted">{o.product_name} · R$ {Number(o.value ?? 0).toLocaleString("pt-BR")}</span>
                <button onClick={() => resolve(o.id)} disabled={busy === o.id} className="ml-auto px-3 py-1.5 rounded-lg bg-yellow-600 text-white text-xs font-semibold">🔧 mapear plano</button>
              </div>
            ))}
          </div>
        )
      )}

      {tab === "Conectores" && (
        <CrudPanel table="store_connectors" title="Lojas / plataformas conectadas" rows={connectors}
          emptyHint="Monetizze, Hotmart, Kiwify, Yampi, Shopify, Mercado Livre... por produtor."
          fields={[
            { key: "code", label: "Código", required: true }, { key: "name", label: "Nome" },
            { key: "platform", label: "Plataforma", type: "select", options: [["monetizze", "Monetizze"], ["hotmart", "Hotmart"], ["kiwify", "Kiwify"], ["yampi", "Yampi"], ["shopify", "Shopify"], ["mercado_livre", "Mercado Livre"], ["woocommerce", "WooCommerce"], ["nuvemshop", "Nuvemshop"], ["tray", "Tray"], ["cartpanda", "CartPanda"], ["braip", "Braip"], ["eduzz", "Eduzz"], ["perfectpay", "PerfectPay"], ["generic", "Genérico"]], default: "monetizze" },
            { key: "producer_ref", label: "Produtor (multi)" },
            { key: "auth_type", label: "Autenticação", type: "select", options: [["webhook_token", "Webhook Token"], ["hmac_signature", "Assinatura HMAC"], ["apikey", "API Key"], ["bearer_token", "Bearer Token"], ["basic", "Basic"], ["oauth2", "OAuth2"], ["none", "Nenhuma"]], default: "webhook_token" },
            { key: "environment", label: "Ambiente", type: "select", options: [["production", "Produção"], ["sandbox", "Sandbox"]], default: "production" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "platform", label: "Plataforma" }, { key: "producer_ref", label: "Produtor" }, { key: "status", label: "Status" }]} />
      )}

      {tab === "Regras de Plano" && (
        <CrudPanel table="store_plan_rules" title="Regras de mapeamento de plano (SEM PLANO → SKU)" rows={rules}
          emptyHint="Se o produto casar (nome + faixa de valor) → aplica plano/SKU/peso automaticamente."
          fields={[
            { key: "producer_ref", label: "Produtor" }, { key: "match_product", label: "Produto contém (ILIKE)" },
            { key: "match_value_min", label: "Valor mín", type: "number" }, { key: "match_value_max", label: "Valor máx", type: "number" },
            { key: "plan_ref", label: "Plano" }, { key: "sku", label: "SKU" }, { key: "weight_kg", label: "Peso (kg)", type: "number" },
            { key: "priority", label: "Prioridade", type: "number", default: "100" },
          ]}
          columns={[{ key: "match_product", label: "Produto contém" }, { key: "plan_ref", label: "Plano" }, { key: "sku", label: "SKU" }, { key: "weight_kg", label: "Peso" }]} />
      )}

      {tab === "Logs de Webhook" && (
        <div className="space-y-3">
          <div className="card p-4 flex flex-wrap items-end gap-2">
            <div className="font-semibold text-sm w-full">🧪 Simular webhook (testar idempotência e estados)</div>
            <select value={sim.connector} onChange={(e) => setSim({ ...sim, connector: e.target.value })} className="input w-auto text-xs"><option value="">Loja…</option>{connectors.map((c) => <option key={c.id} value={c.id}>{c.name ?? c.code}</option>)}</select>
            <select value={sim.event} onChange={(e) => setSim({ ...sim, event: e.target.value })} className="input w-auto text-xs">{["paid", "pending", "canceled", "refund", "chargeback"].map((e) => <option key={e} value={e}>{e}</option>)}</select>
            <input value={sim.sale} onChange={(e) => setSim({ ...sim, sale: e.target.value })} placeholder="nº venda" className="input w-28 text-xs" />
            <button onClick={simulate} disabled={busy === "sim"} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">Enviar</button>
            <span className="text-xs muted">Envie 2× o mesmo nº para ver a idempotência.</span>
          </div>
          {events.length === 0 ? <p className="text-sm muted px-1">Sem eventos.</p> : (
            <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Recebido</th><th className="px-3">Plataforma</th><th className="px-3">Venda</th><th className="px-3">Evento</th><th className="px-3">Assinatura</th><th className="px-3">Chave (idempotência)</th></tr></thead>
              <tbody>{events.map((e) => (
                <tr key={e.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 text-xs">{String(e.received_at ?? "").slice(0, 16).replace("T", " ")}</td>
                  <td className="px-3 text-xs">{PLAT(e.platform)}</td><td className="px-3 text-xs">{e.sale_number}</td>
                  <td className="px-3"><span className="badge badge-neutral">{e.event_type}</span></td>
                  <td className="px-3">{e.signature_valid == null ? "—" : e.signature_valid ? <span className="badge badge-success">ok</span> : <span className="badge badge-danger">inválida</span>}</td>
                  <td className="px-3 font-mono text-[11px] muted">{e.event_key}</td>
                </tr>))}</tbody>
            </table></div>
          )}
        </div>
      )}
    </div>
  );
}
