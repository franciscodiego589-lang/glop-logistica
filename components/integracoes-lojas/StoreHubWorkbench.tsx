"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import ExportButton from "@/components/ui/ExportButton";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const PLAT = (p: string) => ({ monetizze: "Monetizze", hotmart: "Hotmart", kiwify: "Kiwify", yampi: "Yampi", shopify: "Shopify", mercado_livre: "Mercado Livre", woocommerce: "WooCommerce", generic: "Genérico" } as any)[p] ?? p;
const dt = (s: any) => s ? new Date(s).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit" }) : "—";
const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2 });

export default function StoreHubWorkbench({ connectors, orders }: {
  dash?: any; connectors: any[]; orders: any[]; events?: any[]; rules?: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [sel, setSel] = useState<string>(connectors[0]?.id ?? "");
  const [key, setKey] = useState("");
  const [busy, setBusy] = useState("");
  const [prog, setProg] = useState("");
  const [showConn, setShowConn] = useState(connectors.length === 0);
  const [trk, setTrk] = useState<Record<string, string>>({});

  const conn = connectors.find((c) => c.id === sel) ?? connectors[0];
  const rows = useMemo(() => orders.filter((o) => o.connector_id === sel), [orders, sel]);
  const recebidas = rows.length;
  const importadas = rows.filter((o) => o.state !== "sem_plano" && o.state !== "cancelado").length;
  const semPlano = rows.filter((o) => o.state === "sem_plano").length;
  const valor = rows.reduce((s, o) => s + Number(o.value ?? 0), 0);
  const rastreiosPendentes = rows.filter((o) => o.tracking_code && !o.tracking_pushed_at).length;

  async function saveKey() {
    if (!supabase || !conn || !key) return; setBusy("save");
    const { error } = await supabase.from("store_connectors").update({ webhook_token: key, status: "active", metadata: { ...(conn.metadata ?? {}), key_set: true } }).eq("id", conn.id);
    setBusy(""); if (error) alert("Erro ao salvar: " + error.message); else { setKey(""); router.refresh(); }
  }
  // Puxa os pedidos: a rota devolve blocos de páginas (has_more/next_page) para
  // não estourar o timeout; aqui seguimos puxando até acabar, com progresso.
  // mode "full" = tudo; "incremental" = só novas vendas desde a última sincronização.
  async function pull(mode: "full" | "incremental" = "full") {
    if (!conn) return; setBusy("pull"); setProg("");
    const verbo = mode === "incremental" ? "Sincronizando" : "Puxando";
    let fromPage = 1, tot = 0, imp = 0, dup = 0, err = 0, guard = 0;
    try {
      while (true) {
        const res = await fetch("/api/lojas/pull", {
          method: "POST", headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ connector_id: conn.id, from_page: fromPage, mode }),
        });
        const j = await res.json();
        if (!res.ok) { alert("🚫 " + (j.error ?? "Falha ao puxar")); break; }
        tot += j.total ?? 0; imp += j.imported ?? 0; dup += j.duplicates ?? 0; err += j.errors ?? 0;
        if (j.pages_total > 1) setProg(`${verbo}… página ${j.page_to}/${j.pages_total} · ${tot} de ${j.record_count} vendas`);
        if (j.has_more && j.next_page && guard++ < 500) { fromPage = j.next_page; router.refresh(); continue; }
        alert(`✅ ${mode === "incremental" ? "Sincronização" : "Concluído"}: ${tot} venda(s) — ${imp} novas, ${dup} já existiam${err ? `, ${err} com erro` : ""}.`);
        break;
      }
    } catch (e: any) { alert("Erro de rede: " + e.message); }
    setBusy(""); setProg(""); router.refresh();
  }

  // Devolve os códigos de rastreio à plataforma (Monetizze notifica o comprador).
  // Sem itens = envia todos os pendentes (com rastreio, ainda não enviados).
  async function pushTracking(items?: { sale_number: string; tracking_code: string }[]) {
    if (!conn) return; setBusy("track");
    try {
      const res = await fetch("/api/lojas/tracking", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ connector_id: conn.id, ...(items ? { items } : {}) }),
      });
      const j = await res.json();
      if (!res.ok) alert("🚫 " + (j.error ?? "Falha ao enviar rastreio"));
      else if (j.sent === 0) alert("ℹ️ " + (j.message ?? "Nenhum rastreio pendente."));
      else {
        const errs = (j.details ?? []).filter((d: any) => d.status === "error").slice(0, 6).map((d: any) => `#${d.sale_number}: ${d.message}`).join("\n");
        alert(`📮 Enviado à Monetizze: ${j.success} ok, ${j.errors} com erro (de ${j.sent}).${errs ? "\n\n" + errs : ""}`);
      }
    } catch (e: any) { alert("Erro de rede: " + e.message); }
    setBusy(""); router.refresh();
  }

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>VENDAS · INTEGRAÇÃO DE LOJAS</div>
        <h1 className="text-2xl font-bold">Pedidos por Loja</h1>
        <p className="text-sm muted">Cole a chave da API da plataforma e clique <b>Puxar pedidos</b>. As vendas entram aqui sem duplicar.</p>
      </div>

      {/* seletor de loja/produtor */}
      <div className="flex flex-wrap gap-2 items-center">
        {connectors.map((c) => (
          <button key={c.id} onClick={() => setSel(c.id)}
            className={`px-4 py-2 rounded-lg text-sm font-semibold ${sel === c.id ? "bg-brand-600 text-white" : "card"}`}>
            {c.producer_ref ? c.producer_ref : (c.name ?? c.code)} <span className="opacity-70 text-xs">· {PLAT(c.platform)}</span>
          </button>
        ))}
        <button onClick={() => setShowConn(!showConn)} className="px-3 py-2 rounded-lg card text-sm">+ loja</button>
      </div>

      {/* linha: colar chave → aparecem os botões */}
      {conn && (
        <div className="card p-4 space-y-3">
          <div className="flex flex-wrap items-end gap-2">
            <div className="flex-1 min-w-[260px]">
              <label className="text-xs muted">Chave da API — {conn.name ?? PLAT(conn.platform)} {conn.metadata?.key_set && <span className="badge badge-success ml-1">🔑 configurada</span>}</label>
              <input type="password" value={key} onChange={(e) => setKey(e.target.value)} placeholder={conn.metadata?.key_set ? "colar nova chave (opcional)" : "cole aqui a chave da API da " + PLAT(conn.platform)} className="input w-full font-mono text-xs mt-0.5" />
            </div>
            <button onClick={saveKey} disabled={busy === "save" || !key} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-50">{busy === "save" ? "Salvando…" : (conn.metadata?.key_set ? "atualizar chave" : "✓ conectar chave")}</button>
          </div>

          {/* botões de opção — só aparecem depois que a chave está conectada */}
          {conn.metadata?.key_set ? (
            <div className="pt-1 border-t" style={{ borderColor: "var(--border)" }}>
              <div className="flex flex-wrap gap-2">
                <button onClick={() => pull("full")} disabled={busy === "pull"} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-50">{busy === "pull" ? "Puxando…" : "⬇️ Puxar todos os pedidos"}</button>
                <button onClick={() => pull("incremental")} disabled={busy === "pull"} className="px-4 py-2 rounded-lg card text-sm font-semibold disabled:opacity-50">🔁 Sincronizar novas vendas</button>
                <button onClick={() => router.refresh()} disabled={busy === "pull"} className="px-4 py-2 rounded-lg card text-sm font-semibold disabled:opacity-50">🔄 Atualizar lista</button>
                {rastreiosPendentes > 0 && (
                  <button onClick={() => pushTracking()} disabled={busy === "track"} className="px-4 py-2 rounded-lg bg-emerald-600 text-white text-sm font-semibold disabled:opacity-50">{busy === "track" ? "Enviando…" : `📮 Enviar ${rastreiosPendentes} rastreio(s) à Monetizze`}</button>
                )}
              </div>
              {conn.metadata?.last_pull_at && <div className="text-[11px] muted mt-1.5">Última sincronização: {dt(conn.metadata.last_pull_at)}</div>}
              {prog && <div className="text-xs mt-2 font-medium" style={{ color: "var(--brand)" }}>⏳ {prog}</div>}
            </div>
          ) : (
            <p className="text-xs muted">Cole a chave da API acima e clique em <b>conectar chave</b>. Aí aparecem os botões (Puxar pedidos, etc.).</p>
          )}
        </div>
      )}

      {/* cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Vendas recebidas</div><div className="text-2xl font-bold mt-1">{recebidas}</div></div>
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Importadas</div><div className="text-2xl font-bold mt-1" style={{ color: "var(--success)" }}>{importadas}</div></div>
        <div className="card p-4" style={{ borderTop: `3px solid ${semPlano ? "var(--warning)" : "var(--border)"}` }}><div className="text-xs uppercase muted font-semibold">Sem plano</div><div className="text-2xl font-bold mt-1" style={{ color: semPlano ? "var(--warning)" : undefined }}>{semPlano}</div></div>
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Valor</div><div className="text-2xl font-bold mt-1">{money(valor)}</div></div>
      </div>

      {/* nova loja (opcional, escondido por padrão) */}
      {showConn && (
        <div className="card p-4">
          <NewConnector supabase={supabase} onDone={() => router.refresh()} />
        </div>
      )}

      {/* tabela de pedidos */}
      <div className="card p-0 overflow-x-auto">
        <div className="px-4 pt-3 flex items-center justify-between">
          <span className="font-semibold text-sm">{conn?.producer_ref ?? conn?.name ?? "Pedidos"} — {recebidas} pedido(s)</span>
          <ExportButton rows={rows} filename="pedidos" columns={[
            { key: "sale_number", label: "Venda" }, { key: "buyer_name", label: "Comprador" },
            { key: "product_name", label: "Produto" }, { key: "state", label: "Status" },
            { key: "value", label: "Valor" }, { key: "dest_city", label: "Cidade" }, { key: "dest_uf", label: "UF" },
            { key: "created_at", label: "Recebido", fmt: (v) => dt(v) },
          ]} />
        </div>
        {rows.length === 0 ? <p className="text-sm muted p-4">Nenhum pedido ainda. Salve a chave da API e clique em <b>Puxar pedidos</b>.</p> : (
          <table className="w-full text-sm mt-2">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
              <th className="py-2 px-4">Venda</th><th className="px-3">Comprador</th><th className="px-3">Produto</th><th className="px-3">Status</th><th className="px-3 text-right">Valor</th><th className="px-3">Recebido</th><th className="px-3">Rastreio (Correios → Monetizze)</th></tr></thead>
            <tbody>{rows.map((o) => (
              <tr key={o.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                <td className="py-2 px-4 font-medium">#{o.sale_number}</td>
                <td className="px-3">{o.buyer_name ?? "—"}</td>
                <td className="px-3 text-xs">{o.product_name ?? "—"}</td>
                <td className="px-3">{o.state === "sem_plano" ? <span className="badge badge-warning">SEM PLANO</span> : o.state === "bloqueado_reembolso" ? <span className="badge badge-danger">reembolso</span> : <span className="badge badge-success">{o.state === "recebido" ? "Recebido" : o.state}</span>}</td>
                <td className="px-3 text-right tabular-nums">{money(o.value)}</td>
                <td className="px-3 text-xs muted">{dt(o.created_at)}</td>
                <td className="px-3">
                  {o.tracking_pushed_at ? (
                    <span className="text-xs" title={o.tracking_push_msg ?? ""}><span className="font-mono">{o.tracking_code}</span> <span className="badge badge-success ml-1">✓ notificado</span></span>
                  ) : (
                    <div className="flex items-center gap-1">
                      <input value={trk[o.id] ?? o.tracking_code ?? ""} onChange={(e) => setTrk({ ...trk, [o.id]: e.target.value.toUpperCase() })} placeholder="PA123456789BR" className="input w-36 font-mono text-[11px] py-1" />
                      <button onClick={() => { const code = (trk[o.id] ?? o.tracking_code ?? "").trim(); if (!code) { alert("Digite o código de rastreio."); return; } pushTracking([{ sale_number: o.sale_number, tracking_code: code }]); }}
                        disabled={busy === "track"} className="px-2 py-1 rounded bg-emerald-600 text-white text-xs font-semibold disabled:opacity-50">📮</button>
                    </div>
                  )}
                </td>
              </tr>))}</tbody>
          </table>
        )}
      </div>
      <p className="text-xs muted">Idempotente: puxar de novo não duplica os pedidos que já entraram.</p>
    </div>
  );
}

function NewConnector({ supabase, onDone }: { supabase: any; onDone: () => void }) {
  const [f, setF] = useState({ code: "", name: "", platform: "monetizze", producer_ref: "" });
  const [busy, setBusy] = useState(false);
  async function create() {
    if (!supabase || !f.code) return; setBusy(true);
    // insert direto (RLS: integration.create)
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const { error: e2 } = await supabase.from("store_connectors").insert({ tenant_id: comp?.tenant_id, company_id: COMPANY, code: f.code, name: f.name || f.code, platform: f.platform, producer_ref: f.producer_ref || null, auth_type: "webhook_token", status: "inactive" });
    setBusy(false); if (e2) alert("Erro: " + e2.message); else { setF({ code: "", name: "", platform: "monetizze", producer_ref: "" }); onDone(); }
  }
  return (
    <div className="flex flex-wrap items-end gap-2">
      <div className="font-semibold text-sm w-full">Adicionar loja / produtor</div>
      <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="código" className="input w-32 text-sm" />
      <input value={f.name} onChange={(e) => setF({ ...f, name: e.target.value })} placeholder="nome" className="input w-40 text-sm" />
      <select value={f.platform} onChange={(e) => setF({ ...f, platform: e.target.value })} className="input w-auto text-sm">{["monetizze", "hotmart", "kiwify", "yampi", "shopify", "mercado_livre", "woocommerce", "generic"].map((p) => <option key={p} value={p}>{PLAT(p)}</option>)}</select>
      <input value={f.producer_ref} onChange={(e) => setF({ ...f, producer_ref: e.target.value })} placeholder="produtor (ex.: OZEMPHARMA)" className="input w-48 text-sm" />
      <button onClick={create} disabled={busy || !f.code} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">criar</button>
    </div>
  );
}
