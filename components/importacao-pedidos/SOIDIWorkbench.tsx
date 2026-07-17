"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Importar", "Central de Pendências", "Regras", "Arquivos"] as const;
const stColor = (s: string) => ({ parsed: "#6366f1", validated: "#16a34a", pending: "#dc2626", duplicate: "#d97706", promoted: "#15803d", rejected: "#64748b" } as any)[s] ?? "#64748b";
const stLabel = (s: string) => ({ parsed: "Lido", validated: "Validado", pending: "Pendência", duplicate: "Duplicado", promoted: "Promovido", rejected: "Rejeitado" } as any)[s] ?? s;
const SAMPLE = `order_number,customer_name,customer_doc,customer_email,customer_phone,dest_zip,dest_city,dest_uf,weight_kg,total_value
PED-1001,MARIA SOUZA,529.982.247-25,MARIA@EMAIL.COM,(11) 97777-1111,01310-100,são paulo,sp,2.3,180.00
PED-1002,joão lima,111.111.111-11,joao@x.com,,99999,curitiba,pr,-1,90`;

export default function SOIDIWorkbench({ dash, files, orders, validations, rules }: {
  dash: any; files: any[]; orders: any[]; validations: any[]; rules: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState("");
  const [raw, setRaw] = useState(SAMPLE);
  const d = dash ?? {};
  const valByOrder = useMemo(() => { const m: Record<string, any[]> = {}; for (const v of validations) (m[v.import_order_id] ??= []).push(v); return m; }, [validations]);

  function parseCsv(text: string): any[] {
    const t = text.trim();
    if (t.startsWith("[") || t.startsWith("{")) { try { const j = JSON.parse(t); return Array.isArray(j) ? j : [j]; } catch { return []; } }
    const lines = t.split(/\r?\n/).filter(Boolean);
    if (lines.length < 2) return [];
    const head = lines[0].split(",").map((h) => h.trim());
    return lines.slice(1).map((ln) => { const cells = ln.split(","); const o: any = {}; head.forEach((h, i) => (o[h] = (cells[i] ?? "").trim())); return o; });
  }
  async function doImport() {
    if (!supabase) return; const rows = parseCsv(raw);
    if (rows.length === 0) { alert("Nada para importar (CSV com cabeçalho ou array JSON)."); return; }
    setBusy("import");
    const sha = "sha-" + Math.abs(raw.length * 2654435761 % 1e9) + "-" + rows.length;
    const { data: file, error: fe } = await supabase.rpc("register_import_file", { p_company: COMPANY, p_filename: `import-${rows.length}.csv`, p_source: "upload", p_file_type: "csv", p_sha256: sha, p_size: raw.length, p_storage: null });
    if (fe) { setBusy(""); alert("Erro: " + fe.message); return; }
    for (const r of rows) await supabase.rpc("parse_import_order", { p_company: COMPANY, p_file: file.id, p_raw: r, p_confidence: 92 });
    setBusy(""); router.refresh(); setTab("Central de Pendências");
  }
  async function step(fn: string, id: string) {
    if (!supabase) return; setBusy(id + fn);
    const { error } = await supabase.rpc(fn, { p_company: COMPANY, p_order: id });
    setBusy("");
    if (error) alert(error.message.includes("promovível") ? "🚫 " + error.message : "Erro: " + error.message); else router.refresh();
  }
  // ✨ Extrair com IA: manda o texto bagunçado (e-mail/WhatsApp/planilha) para o
  // Claude, que devolve os pedidos estruturados; mapeia p/ o formato do SOIDI e
  // joga no campo de importação (o usuário confere e clica em Importar e ler).
  async function extrairIA() {
    const texto = raw.trim();
    if (!texto) { alert("Cole o texto do pedido (e-mail, WhatsApp, planilha) primeiro."); return; }
    setBusy("ia");
    try {
      const res = await fetch("/api/ia/extrair-pedido", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ texto }) });
      const j = await res.json();
      if (j.configured === false) { alert("🔌 " + (j.message ?? "IA não configurada.")); setBusy(""); return; }
      if (j.error) { alert("Erro: " + j.error); setBusy(""); return; }
      const pedidos = (j.pedidos ?? []).map((p: any) => ({
        order_number: p.sale_number || "", customer_name: p.buyer_name || "", customer_doc: p.buyer_doc || "",
        customer_email: p.buyer_email || "", customer_phone: p.buyer_phone || "", dest_zip: p.dest_zip || "",
        dest_city: p.dest_city || "", dest_uf: p.dest_uf || "", total_value: p.value || 0, product_name: p.product_name || "",
      }));
      if (pedidos.length === 0) { alert("A IA não encontrou pedidos nesse texto."); setBusy(""); return; }
      setRaw(JSON.stringify(pedidos, null, 2));
      alert(`✨ ${pedidos.length} pedido(s) extraído(s). Confira abaixo e clique em Importar e ler.`);
    } catch (e: any) { alert("Erro de rede: " + (e?.message ?? "falha")); }
    setBusy("");
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">📥</div>
        <div>
          <h1 className="text-xl font-bold">Importação Inteligente de Pedidos — SOIDI</h1>
          <p className="text-sm muted">Ingestão de qualquer origem · OCR/document intelligence · validação · normalização · deduplicação</p>
        </div>
      </div>

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <KpiCard label="Arquivos" value={d.files ?? 0} accent />
          <KpiCard label="Pedidos" value={d.orders ?? 0} />
          <KpiCard label="Validados" value={d.validated ?? 0} />
          <KpiCard label="Pendências" value={d.pending ?? 0} tone={d.pending ? "danger" : undefined} />
          <KpiCard label="Duplicados" value={d.duplicates ?? 0} tone={d.duplicates ? "warning" : undefined} />
          <KpiCard label="Promovidos" value={d.promoted ?? 0} />
          <div className="card p-4">
            <div className="text-xs uppercase tracking-wide muted font-semibold">Taxa de promoção</div>
            <div className="mt-2 text-2xl font-bold" style={{ color: "var(--success)" }}>{d.promotion_rate != null ? `${d.promotion_rate}%` : "—"}</div>
          </div>
          <KpiCard label="Confiança média OCR" value={d.avg_confidence != null ? `${d.avg_confidence}%` : "—"} />
        </div>
      )}

      {tab === "Importar" && (
        <div className="space-y-3">
          <div className="card p-4">
            <div className="font-semibold text-sm mb-1">Colar pedidos (CSV, JSON — ou texto bagunçado + IA)</div>
            <p className="text-xs muted mb-2">CSV/JSON com os campos: order_number, customer_name, customer_doc, customer_email, customer_phone, dest_zip, dest_city, dest_uf, weight_kg, total_value. Ou cole um texto solto (e-mail/WhatsApp) e clique em <b>Extrair com IA</b>.</p>
            <textarea value={raw} onChange={(e) => setRaw(e.target.value)} rows={8} className="input w-full font-mono text-xs" />
            <div className="mt-2 flex flex-wrap gap-2">
              <button onClick={extrairIA} disabled={busy === "ia"} className="px-3 py-2 rounded-lg border text-sm font-semibold disabled:opacity-50" style={{ borderColor: "var(--brand)", color: "var(--brand)" }}>{busy === "ia" ? "Extraindo…" : "✨ Extrair com IA"}</button>
              <button onClick={doImport} disabled={busy === "import"} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">{busy === "import" ? "Importando…" : "📥 Importar e ler"}</button>
            </div>
            <p className="text-[11px] muted mt-1.5">✨ A extração por IA lê texto solto (e-mail, WhatsApp, planilha fora do padrão) e organiza nos campos. Requer a chave da Anthropic no servidor. Confira sempre antes de importar.</p>
          </div>
        </div>
      )}

      {tab === "Central de Pendências" && (
        <div className="space-y-3">
          {orders.filter((o) => o.status !== "promoted").length === 0 ? <p className="text-sm muted px-1">Sem pedidos em aberto. Importe na aba Importar.</p> :
            orders.filter((o) => o.status !== "promoted").map((o) => {
              const vals = valByOrder[o.id] ?? [];
              return (
                <div key={o.id} className="card p-4" style={{ borderLeft: `3px solid ${stColor(o.status)}` }}>
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="font-semibold text-sm">{o.order_number ?? "(sem número)"}</span>
                    <span className="badge" style={{ background: stColor(o.status), color: "#fff" }}>{stLabel(o.status)}</span>
                    <span className="text-xs muted">{o.customer_name ?? "—"} · {o.dest_city ?? ""}/{o.dest_uf ?? ""} · {o.weight_kg ?? "?"}kg</span>
                    {o.confidence != null && <span className="text-xs muted ml-auto">confiança {o.confidence}%</span>}
                  </div>
                  {vals.length > 0 && (
                    <ul className="mt-2 space-y-1">
                      {vals.map((v: any) => (
                        <li key={v.id} className="text-xs flex items-center gap-2">
                          <span className={`badge ${v.severity === "error" ? "badge-danger" : "badge-warning"} text-[10px]`}>{v.severity}</span>
                          <b>{v.field}</b> — {v.message}
                        </li>
                      ))}
                    </ul>
                  )}
                  <div className="flex flex-wrap gap-2 mt-3">
                    <button onClick={() => step("normalize_import_order", o.id)} disabled={busy.startsWith(o.id)} className="px-3 py-1.5 rounded-lg card text-xs">✨ normalizar</button>
                    <button onClick={() => step("validate_import_order", o.id)} disabled={busy.startsWith(o.id)} className="px-3 py-1.5 rounded-lg card text-xs">✓ validar</button>
                    <button onClick={() => step("promote_import_order", o.id)} disabled={busy.startsWith(o.id)} className="px-3 py-1.5 rounded-lg bg-green-600 text-white text-xs font-semibold">🚀 promover para pedido</button>
                  </div>
                </div>
              );
            })}
        </div>
      )}

      {tab === "Regras" && (
        <CrudPanel table="import_rules" title="Motor de regras de importação" rows={rules}
          emptyHint="Se CEP inválido → bloquear; se duplicado → ignorar; se incompleto → análise; etc."
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "condition_type", label: "Condição", type: "select", options: [["cep_invalid", "CEP inválido"], ["doc_invalid", "CPF/CNPJ inválido"], ["sku_missing", "SKU inexistente"], ["customer_exists", "Cliente existe"], ["duplicate", "Duplicado"], ["incomplete", "Incompleto"], ["weight_invalid", "Peso inválido"]], default: "incomplete" },
            { key: "action", label: "Ação", type: "select", options: [["block", "Bloquear"], ["pending", "Pendência"], ["update", "Atualizar"], ["ignore", "Ignorar"], ["review", "Análise"], ["autocorrect", "Autocorrigir"]], default: "review" },
            { key: "priority", label: "Prioridade", type: "number", default: "100" },
          ]}
          columns={[{ key: "name", label: "Nome" }, { key: "condition_type", label: "Condição" }, { key: "action", label: "Ação" }, { key: "priority", label: "Prio." }, { key: "enabled", label: "Ativa" }]} />
      )}

      {tab === "Arquivos" && (
        files.length === 0 ? <p className="text-sm muted px-1">Nenhum arquivo importado.</p> : (
          <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Arquivo</th><th className="px-3">Origem</th><th className="px-3">Tipo</th><th className="px-3 text-center">Pedidos</th><th className="px-3">Status</th><th className="px-3">Recebido</th></tr></thead>
            <tbody>{files.map((f) => (
              <tr key={f.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                <td className="py-2 px-3 font-medium">{f.filename ?? "—"}</td><td className="px-3 text-xs">{f.source}</td><td className="px-3 text-xs uppercase">{f.file_type}</td>
                <td className="px-3 text-center">{f.orders_found}</td>
                <td className="px-3"><span className={`badge ${f.status === "error" ? "badge-danger" : f.status === "duplicate" ? "badge-warning" : "badge-success"}`}>{f.status}</span></td>
                <td className="px-3 text-xs">{String(f.received_at ?? "").slice(0, 16).replace("T", " ")}</td>
              </tr>))}</tbody>
          </table></div>
        )
      )}
    </div>
  );
}
