"use client";
import { useEffect, useMemo, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import ExportButton from "@/components/ui/ExportButton";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const PLAT = (p: string) => ({ monetizze: "Monetizze", hotmart: "Hotmart", kiwify: "Kiwify", yampi: "Yampi", shopify: "Shopify", mercado_livre: "Mercado Livre", woocommerce: "WooCommerce", generic: "Genérico" } as any)[p] ?? p;
const dt = (s: any) => s ? new Date(s).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit" }) : "—";
const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2 });

const STATUS_FILTERS: { key: string; label: string; match: (o: any) => boolean }[] = [
  { key: "all", label: "Todos", match: () => true },
  { key: "recebido", label: "Recebidos", match: (o) => o.state === "recebido" },
  { key: "sem_plano", label: "Sem plano", match: (o) => o.state === "sem_plano" },
  { key: "postado", label: "Postados", match: (o) => o.state === "postado" },
  { key: "em_transito", label: "Em trânsito", match: (o) => o.state === "em_transito" || o.state === "saiu_entrega" },
  { key: "entregue", label: "Entregues", match: (o) => o.state === "entregue" },
  { key: "bloqueado_reembolso", label: "Reembolso/bloqueio", match: (o) => o.state === "bloqueado_reembolso" || o.state === "cancelado" },
  { key: "com_rastreio", label: "Com rastreio", match: (o) => !!o.tracking_code },
];

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
  const [statusFilter, setStatusFilter] = useState("all");
  const [search, setSearch] = useState("");
  const [sels, setSels] = useState<Set<string>>(new Set());   // #4 ações em massa
  const [autoSync, setAutoSync] = useState(false);            // #2 sincronização automática
  const autoRef = useRef<any>(null);

  const conn = connectors.find((c) => c.id === sel) ?? connectors[0];
  const rows = useMemo(() => orders.filter((o) => o.connector_id === sel), [orders, sel]);
  const recebidas = rows.length;
  const importadas = rows.filter((o) => o.state !== "sem_plano" && o.state !== "cancelado").length;
  const semPlano = rows.filter((o) => o.state === "sem_plano").length;
  const postados = rows.filter((o) => ["postado", "em_transito", "saiu_entrega", "entregue"].includes(o.state)).length;
  const entregues = rows.filter((o) => o.state === "entregue").length;
  const valor = rows.reduce((s, o) => s + Number(o.value ?? 0), 0);
  const rastreiosPendentes = rows.filter((o) => o.tracking_code && !o.tracking_pushed_at).length;
  const countBy = (k: string) => rows.filter(STATUS_FILTERS.find((f) => f.key === k)!.match).length;

  const filteredRows = useMemo(() => {
    const f = STATUS_FILTERS.find((x) => x.key === statusFilter) ?? STATUS_FILTERS[0];
    const s = search.trim().toLowerCase();
    return rows.filter(f.match).filter((o) => !s || `${o.sale_number} ${o.buyer_name} ${o.product_name} ${o.dest_city} ${o.dest_uf}`.toLowerCase().includes(s));
  }, [rows, statusFilter, search]);

  const conectada = !!conn?.metadata?.key_set;

  async function saveKey() {
    if (!supabase || !conn || !key) return; setBusy("save");
    const { error } = await supabase.from("store_connectors").update({ webhook_token: key, status: "active", metadata: { ...(conn.metadata ?? {}), key_set: true } }).eq("id", conn.id);
    setBusy(""); if (error) alert("Erro ao salvar: " + error.message); else { setKey(""); router.refresh(); }
  }
  // Puxa os pedidos com opções (modo, período, status). A rota devolve blocos de
  // páginas (has_more/next_page); aqui seguimos até acabar, com progresso.
  async function pull(opts: { mode?: "full" | "incremental"; since_days?: number; statuses?: number[]; label?: string } = {}) {
    if (!conn) return; setBusy("pull"); setProg("");
    const verbo = opts.label ?? (opts.mode === "incremental" ? "Sincronizando" : "Puxando");
    let fromPage = 1, tot = 0, imp = 0, dup = 0, err = 0, guard = 0;
    try {
      while (true) {
        const res = await fetch("/api/lojas/pull", {
          method: "POST", headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ connector_id: conn.id, from_page: fromPage, mode: opts.mode ?? "full", since_days: opts.since_days, statuses: opts.statuses }),
        });
        const j = await res.json();
        if (!res.ok) { alert("🚫 " + (j.error ?? "Falha ao puxar")); break; }
        tot += j.total ?? 0; imp += j.imported ?? 0; dup += j.duplicates ?? 0; err += j.errors ?? 0;
        if (j.pages_total > 1) setProg(`${verbo}… página ${j.page_to}/${j.pages_total} · ${tot} de ${j.record_count} vendas`);
        if (j.has_more && j.next_page && guard++ < 500) { fromPage = j.next_page; router.refresh(); continue; }
        alert(`✅ ${verbo}: ${tot} venda(s) — ${imp} novas, ${dup} já existiam${err ? `, ${err} com erro` : ""}.`);
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

  // #2 SINCRONIZAÇÃO AUTOMÁTICA: enquanto ligada e a aba aberta, puxa novas vendas
  // a cada 10 min (modo incremental). Desliga sozinha ao sair da tela.
  useEffect(() => {
    if (autoRef.current) { clearInterval(autoRef.current); autoRef.current = null; }
    if (autoSync && conectada) {
      autoRef.current = setInterval(() => { if (!busy) pull({ mode: "incremental", label: "Auto-sync" }); }, 10 * 60_000);
    }
    return () => { if (autoRef.current) clearInterval(autoRef.current); };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [autoSync, conectada, sel]);

  // #4 AÇÕES EM MASSA: aplica um novo status aos pedidos selecionados (RPC transition_store_order).
  const toggleSel = (id: string) => setSels((p) => { const n = new Set(p); n.has(id) ? n.delete(id) : n.add(id); return n; });
  const allShownSelected = filteredRows.length > 0 && filteredRows.every((o) => sels.has(o.id));
  const toggleAll = () => setSels(() => allShownSelected ? new Set() : new Set(filteredRows.map((o) => o.id)));
  async function bulkTransition(to: string, label: string) {
    if (!supabase || sels.size === 0) return;
    if (!confirm(`Marcar ${sels.size} pedido(s) como “${label}”?`)) return;
    setBusy("bulk");
    let ok = 0, fail = 0; const errs: string[] = [];
    for (const id of Array.from(sels)) {
      const { error } = await supabase.rpc("transition_store_order", { p_company: COMPANY, p_order: id, p_to_state: to, p_reason: "ação em massa" });
      if (error) { fail++; if (errs.length < 4) errs.push(error.message); } else ok++;
    }
    setBusy(""); setSels(new Set());
    alert(`${ok} atualizado(s)${fail ? `, ${fail} com erro${errs.length ? ":\n" + errs.join("\n") : ""}` : ""}.`);
    router.refresh();
  }

  const B = "w-full text-left px-3 py-2 rounded-lg text-sm font-medium transition disabled:opacity-40 disabled:cursor-not-allowed no-underline block";
  const primary = `${B} bg-brand-600 text-white hover:opacity-90`;
  const soft = `${B} border hover:bg-black/5 dark:hover:bg-white/5`;

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>VENDAS · INTEGRAÇÃO DE LOJAS</div>
        <h1 className="text-2xl font-bold">Puxar Pedidos</h1>
        <p className="text-sm muted">Escolha a loja, conecte a chave e use as opções abaixo para importar e filtrar. Sem duplicar.</p>
      </div>

      {/* HUB em colunas: Plataformas · Importar · Filtrar · Ferramentas */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-3">
        {/* Plataformas */}
        <div className="card p-3">
          <div className="font-bold text-sm mb-2">🏪 Plataformas</div>
          <div className="space-y-1.5">
            {connectors.map((c) => (
              <button key={c.id} onClick={() => setSel(c.id)} className={sel === c.id ? primary : soft} style={sel === c.id ? undefined : { borderColor: "var(--border)" }}>
                <span className="flex items-center justify-between gap-1"><span className="truncate">{c.producer_ref ?? c.name ?? c.code} · {PLAT(c.platform)}</span>{c.metadata?.key_set && <span>🔑</span>}</span>
              </button>
            ))}
            <button onClick={() => setShowConn(!showConn)} className={soft} style={{ borderColor: "var(--border)" }}>＋ Adicionar loja</button>
          </div>
        </div>

        {/* Importar */}
        <div className="card p-3">
          <div className="font-bold text-sm mb-2">⬇️ Importar pedidos</div>
          <div className="space-y-1.5">
            <button disabled={!conectada || busy === "pull"} onClick={() => pull({ mode: "full", label: "Puxando tudo" })} className={primary}>{busy === "pull" ? "Puxando…" : "Puxar todos os pedidos"}</button>
            <button disabled={!conectada || busy === "pull"} onClick={() => pull({ mode: "incremental", label: "Sincronizando" })} className={soft} style={{ borderColor: "var(--border)" }}>🔁 Sincronizar novas vendas</button>
            <button disabled={!conectada || busy === "pull"} onClick={() => pull({ since_days: 7, label: "Últimos 7 dias" })} className={soft} style={{ borderColor: "var(--border)" }}>📅 Puxar últimos 7 dias</button>
            <button disabled={!conectada || busy === "pull"} onClick={() => pull({ since_days: 30, label: "Últimos 30 dias" })} className={soft} style={{ borderColor: "var(--border)" }}>📆 Puxar últimos 30 dias</button>
            <button disabled={!conectada || busy === "pull"} onClick={() => pull({ statuses: [2, 6], label: "Puxando pagas" })} className={soft} style={{ borderColor: "var(--border)" }}>✅ Puxar só pagas (finalizadas)</button>
            <button onClick={() => router.refresh()} className={soft} style={{ borderColor: "var(--border)" }}>🔄 Atualizar lista</button>
            <button disabled={!conectada} onClick={() => setAutoSync((a) => !a)} className={autoSync ? `${B} bg-emerald-600 text-white` : soft} style={autoSync ? undefined : { borderColor: "var(--border)" }}>
              {autoSync ? "🟢 Auto-sync LIGADO (a cada 10 min)" : "⏱️ Ligar sincronização automática"}
            </button>
          </div>
          {autoSync && <p className="text-[11px] mt-1.5" style={{ color: "var(--success)" }}>Puxando novas vendas sozinho enquanto esta aba estiver aberta.</p>}
          {!conectada && <p className="text-[11px] muted mt-2">Conecte a chave (abaixo) para liberar.</p>}
          {conn?.metadata?.last_pull_at && <div className="text-[11px] muted mt-2">Última sinc.: {dt(conn.metadata.last_pull_at)}</div>}
          {prog && <div className="text-[11px] mt-1.5 font-medium" style={{ color: "var(--brand)" }}>⏳ {prog}</div>}
        </div>

        {/* Filtrar */}
        <div className="card p-3">
          <div className="font-bold text-sm mb-2">🔎 Filtrar lista</div>
          <div className="space-y-1.5">
            {STATUS_FILTERS.map((f) => (
              <button key={f.key} onClick={() => setStatusFilter(f.key)} className={statusFilter === f.key ? primary : soft} style={statusFilter === f.key ? undefined : { borderColor: "var(--border)" }}>
                <span className="flex items-center justify-between"><span>{f.label}</span><span className="opacity-70 text-xs">{countBy(f.key)}</span></span>
              </button>
            ))}
          </div>
        </div>

        {/* Ferramentas */}
        <div className="card p-3">
          <div className="font-bold text-sm mb-2">🧰 Ferramentas</div>
          <div className="space-y-1.5">
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="🔍 Buscar venda/comprador/produto" className="input w-full text-sm" />
            <div className="flex gap-1.5">
              <ExportButton rows={filteredRows} filename="pedidos" columns={[
                { key: "sale_number", label: "Venda" }, { key: "buyer_name", label: "Comprador" }, { key: "product_name", label: "Produto" },
                { key: "state", label: "Status" }, { key: "value", label: "Valor" }, { key: "dest_city", label: "Cidade" }, { key: "dest_uf", label: "UF" },
                { key: "tracking_code", label: "Rastreio" }, { key: "created_at", label: "Recebido", fmt: (v) => dt(v) },
              ]} />
              <span className="text-[11px] muted self-center">exportar filtro</span>
            </div>
            {rastreiosPendentes > 0 && <button onClick={() => pushTracking()} disabled={busy === "track"} className={`${B} bg-emerald-600 text-white hover:opacity-90`}>{busy === "track" ? "Enviando…" : `📮 Enviar ${rastreiosPendentes} rastreio(s)`}</button>}
            <a href="/integracoes-nfe" className={soft} style={{ borderColor: "var(--border)" }}>🧾 Integrações & NF-e</a>
            <a href="/prepostagem" className={soft} style={{ borderColor: "var(--border)" }}>📮 Prepostagem Correios</a>
          </div>
        </div>
      </div>

      {/* conectar chave (quando não conectada) */}
      {conn && !conectada && (
        <div className="card p-4 flex flex-wrap items-end gap-2" style={{ borderLeft: "3px solid var(--brand)" }}>
          <div className="flex-1 min-w-[260px]">
            <label className="text-xs muted">Chave da API — {conn.name ?? PLAT(conn.platform)}</label>
            <input type="password" value={key} onChange={(e) => setKey(e.target.value)} placeholder={"cole aqui a chave da API da " + PLAT(conn.platform)} className="input w-full font-mono text-xs mt-0.5" />
          </div>
          <button onClick={saveKey} disabled={busy === "save" || !key} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-50">{busy === "save" ? "Salvando…" : "✓ conectar chave"}</button>
        </div>
      )}
      {conn && conectada && (
        <div className="flex flex-wrap items-end gap-2">
          <input type="password" value={key} onChange={(e) => setKey(e.target.value)} placeholder="atualizar chave (opcional)" className="input flex-1 min-w-[240px] font-mono text-xs" />
          <button onClick={saveKey} disabled={busy === "save" || !key} className="px-3 py-2 rounded-lg card text-sm font-semibold disabled:opacity-50">atualizar chave</button>
        </div>
      )}
      {showConn && <div className="card p-4"><NewConnector supabase={supabase} onDone={() => router.refresh()} /></div>}

      {/* KPIs */}
      <div className="grid grid-cols-2 lg:grid-cols-5 gap-3">
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Recebidas</div><div className="text-2xl font-bold mt-1">{recebidas}</div></div>
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Importadas</div><div className="text-2xl font-bold mt-1" style={{ color: "var(--success)" }}>{importadas}</div></div>
        <div className="card p-4" style={{ borderTop: `3px solid ${semPlano ? "var(--warning)" : "var(--border)"}` }}><div className="text-xs uppercase muted font-semibold">Sem plano</div><div className="text-2xl font-bold mt-1" style={{ color: semPlano ? "var(--warning)" : undefined }}>{semPlano}</div></div>
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Postados</div><div className="text-2xl font-bold mt-1">{postados}<span className="text-sm muted"> · {entregues} entr.</span></div></div>
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Valor</div><div className="text-2xl font-bold mt-1">{money(valor)}</div></div>
      </div>

      {/* tabela filtrada */}
      <div className="card p-0 overflow-x-auto">
        <div className="px-4 pt-3 flex items-center justify-between flex-wrap gap-2">
          <span className="font-semibold text-sm">{conn?.producer_ref ?? conn?.name ?? "Pedidos"} — {filteredRows.length} de {recebidas}{statusFilter !== "all" || search ? " (filtrado)" : ""}</span>
          {(statusFilter !== "all" || search) && <button onClick={() => { setStatusFilter("all"); setSearch(""); }} className="text-xs font-semibold" style={{ color: "var(--brand)" }}>limpar filtro ✕</button>}
        </div>

        {/* #4 barra de ações em massa */}
        {sels.size > 0 && (
          <div className="mx-4 mt-2 p-2 rounded-lg flex flex-wrap items-center gap-1.5" style={{ background: "var(--surface-2)", border: "1px solid var(--brand)" }}>
            <span className="text-xs font-semibold px-1">{sels.size} selecionado(s):</span>
            {[
              { to: "pronto_despacho", label: "Pronto p/ despacho" },
              { to: "etiquetado", label: "Etiquetado" },
              { to: "postado", label: "Postado" },
              { to: "entregue", label: "Entregue" },
            ].map((a) => (
              <button key={a.to} disabled={busy === "bulk"} onClick={() => bulkTransition(a.to, a.label)} className="px-2.5 py-1 rounded-md bg-brand-600 text-white text-xs font-semibold disabled:opacity-50">{a.label}</button>
            ))}
            <button disabled={busy === "bulk"} onClick={() => bulkTransition("cancelado", "Cancelado")} className="px-2.5 py-1 rounded-md text-xs font-semibold text-white disabled:opacity-50" style={{ background: "var(--danger)" }}>Cancelar</button>
            <button onClick={() => setSels(new Set())} className="px-2 py-1 rounded-md text-xs muted">limpar seleção ✕</button>
            {busy === "bulk" && <span className="text-xs" style={{ color: "var(--brand)" }}>aplicando…</span>}
          </div>
        )}
        {filteredRows.length === 0 ? <p className="text-sm muted p-4">{rows.length === 0 ? <>Nenhum pedido ainda. Conecte a chave e clique em <b>Puxar todos os pedidos</b>.</> : "Nenhum pedido no filtro atual."}</p> : (
          <table className="w-full text-sm mt-2">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
              <th className="py-2 pl-4 pr-1"><input type="checkbox" checked={allShownSelected} onChange={toggleAll} title="Selecionar todos (do filtro)" /></th>
              <th className="py-2 px-2">Venda</th><th className="px-3">Comprador</th><th className="px-3">Produto</th><th className="px-3">Destino</th><th className="px-3">Status</th><th className="px-3 text-right">Valor</th><th className="px-3">Recebido</th><th className="px-3">Rastreio → Monetizze</th></tr></thead>
            <tbody>{filteredRows.map((o) => (
              <tr key={o.id} className="border-b last:border-0" style={{ borderColor: "var(--border)", background: sels.has(o.id) ? "color-mix(in srgb, var(--brand) 8%, transparent)" : undefined }}>
                <td className="pl-4 pr-1"><input type="checkbox" checked={sels.has(o.id)} onChange={() => toggleSel(o.id)} /></td>
                <td className="py-2 px-2 font-medium">#{o.sale_number}</td>
                <td className="px-3">{o.buyer_name ?? "—"}<div className="text-[11px] muted">{o.buyer_doc ?? ""}</div></td>
                <td className="px-3 text-xs">{o.product_name ?? "—"}</td>
                <td className="px-3 text-xs">{o.dest_city ?? "—"}{o.dest_uf ? `/${o.dest_uf}` : ""}</td>
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
      <p className="text-xs muted">Idempotente: puxar de novo não duplica os pedidos que já entraram. Filtros e busca são só na lista (não re-puxam).</p>
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
