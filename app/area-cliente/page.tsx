"use client";
import { useState } from "react";
import { createClient } from "@/lib/supabase/client";

const brl = (n: number) => (n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const OSTATUS: Record<string, string> = { new: "Novo", approved: "Aprovado", reserved: "Reservado", awaiting_production: "Em produção", picking: "Separação", shipped: "Expedido", delivered: "Entregue", invoiced: "Faturado", canceled: "Cancelado" };
const TSTATUS: Record<string, string> = { open: "Aberto", in_progress: "Em andamento", waiting_customer: "Aguardando você", resolved: "Resolvido", closed: "Fechado" };

export default function AreaClientePage() {
  const [code, setCode] = useState("");
  const [data, setData] = useState<any>(null);
  const [err, setErr] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [tab, setTab] = useState<"pedidos" | "documentos" | "chamados">("pedidos");
  const [nt, setNt] = useState({ subject: "", body: "" });
  const [sent, setSent] = useState<string | null>(null);

  async function enter(e?: React.FormEvent) {
    e?.preventDefault();
    const supabase = createClient();
    if (!supabase || !code.trim()) return;
    setBusy(true); setErr(null);
    const { data: d, error } = await supabase.rpc("portal_public_snapshot", { p_token: code.trim() });
    setBusy(false);
    if (error || !d || d.error) { setErr("Código inválido. Confira com o seu contato comercial."); return; }
    setData(d);
  }
  async function openTicket() {
    const supabase = createClient();
    if (!supabase || !nt.subject) return;
    setBusy(true);
    const { data: r } = await supabase.rpc("portal_public_open_ticket", { p_token: code.trim(), p_subject: nt.subject, p_body: nt.body || null, p_priority: "normal" });
    setBusy(false);
    if (r?.ticket_number) { setSent(`Chamado #${r.ticket_number} aberto! Nossa equipe vai responder em breve.`); setNt({ subject: "", body: "" }); enter(); }
  }

  if (!data) {
    return (
      <div className="min-h-screen grid place-items-center p-4" style={{ background: "linear-gradient(150deg,#1a336f,#2f56e6)" }}>
        <div className="w-full max-w-sm rounded-2xl p-8 animate-in" style={{ background: "var(--surface)", boxShadow: "var(--shadow-lg)" }}>
          <div className="h-12 w-12 rounded-2xl grid place-items-center font-black text-xl text-white mb-5" style={{ background: "linear-gradient(150deg,#2f56e6,#1a336f)" }}>◈</div>
          <h1 className="text-xl font-extrabold tracking-tight">Área do Cliente</h1>
          <p className="text-sm muted mt-1">Acompanhe seus pedidos, documentos e chamados.</p>
          <form onSubmit={enter} className="mt-6 space-y-3">
            <div>
              <label className="label">Código de acesso</label>
              <input value={code} onChange={(e) => setCode(e.target.value)} className="input" placeholder="cole seu código aqui" autoFocus />
            </div>
            {err && <div className="text-sm rounded-xl px-3 py-2" style={{ background: "var(--danger-soft)", color: "var(--danger)" }}>{err}</div>}
            <button disabled={busy} className="btn btn-primary w-full h-11">{busy ? "Entrando…" : "Entrar"}</button>
          </form>
          <p className="text-xs muted mt-6 text-center">Não tem um código? Solicite ao seu contato comercial.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen" style={{ background: "var(--bg)" }}>
      <header className="h-16 px-6 flex items-center gap-3 border-b" style={{ borderColor: "var(--border)", background: "var(--surface)" }}>
        <div className="h-9 w-9 rounded-xl grid place-items-center font-black text-white" style={{ background: "linear-gradient(150deg,#2f56e6,#1a336f)" }}>◈</div>
        <div className="flex-1"><div className="font-bold leading-tight">{data.account}</div><div className="text-xs muted">Olá, {data.user}</div></div>
        <button onClick={() => setData(null)} className="btn btn-sm">Sair</button>
      </header>

      <main className="max-w-4xl mx-auto p-6 space-y-4">
        <div className="grid grid-cols-3 gap-3">
          <div className="kpi"><div className="kpi-label">Pedidos</div><div className="kpi-value">{data.orders.length}</div></div>
          <div className="kpi"><div className="kpi-label">Documentos</div><div className="kpi-value">{data.documents.length}</div></div>
          <div className="kpi"><div className="kpi-label">Chamados</div><div className="kpi-value">{data.tickets.length}</div></div>
        </div>

        <div className="flex gap-1 border-b" style={{ borderColor: "var(--border)" }}>
          {(["pedidos", "documentos", "chamados"] as const).map((t) => (
            <button key={t} onClick={() => setTab(t)} className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px capitalize ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted"}`}>{t}</button>
          ))}
        </div>

        {tab === "pedidos" && (
          <div className="card p-0 overflow-x-auto">
            {data.orders.length === 0 ? <p className="text-sm muted p-4">Nenhum pedido ainda.</p> : (
              <table className="tbl"><thead><tr><th>Nº</th><th>Data</th><th>Status</th><th className="text-right">Total</th></tr></thead>
                <tbody>{data.orders.map((o: any) => (<tr key={o.number}><td className="font-semibold tabular-nums">#{o.number}</td><td>{o.date}</td><td><span className="badge badge-brand">{OSTATUS[o.status] ?? o.status}</span></td><td className="text-right tabular-nums">R$ {brl(Number(o.total))}</td></tr>))}</tbody>
              </table>
            )}
          </div>
        )}
        {tab === "documentos" && (
          <div className="card p-0 overflow-x-auto">
            {data.documents.length === 0 ? <p className="text-sm muted p-4">Nenhum documento disponível.</p> : (
              <table className="tbl"><thead><tr><th>Documento</th><th>Tipo</th><th>Data</th><th></th></tr></thead>
                <tbody>{data.documents.map((d: any, i: number) => (<tr key={i}><td>{d.title}</td><td className="uppercase text-xs muted">{d.type}</td><td>{d.date}</td><td className="text-right">{d.url ? <a href={d.url} target="_blank" className="text-brand-600 text-xs font-semibold hover:underline">baixar</a> : "—"}</td></tr>))}</tbody>
              </table>
            )}
          </div>
        )}
        {tab === "chamados" && (
          <div className="space-y-4">
            <div className="card p-4 space-y-3">
              <div className="font-semibold">Abrir novo chamado</div>
              {sent && <div className="text-sm rounded-xl px-3 py-2" style={{ background: "var(--success-soft)", color: "var(--success)" }}>{sent}</div>}
              <input value={nt.subject} onChange={(e) => setNt((p) => ({ ...p, subject: e.target.value }))} className="input" placeholder="Assunto" />
              <textarea value={nt.body} onChange={(e) => setNt((p) => ({ ...p, body: e.target.value }))} className="input" style={{ height: 80, paddingTop: 8 }} placeholder="Como podemos ajudar?" />
              <button onClick={openTicket} disabled={busy || !nt.subject} className="btn btn-primary btn-sm">Enviar chamado</button>
            </div>
            <div className="card p-0 overflow-x-auto">
              {data.tickets.length === 0 ? <p className="text-sm muted p-4">Nenhum chamado.</p> : (
                <table className="tbl"><thead><tr><th>Nº</th><th>Assunto</th><th>Status</th><th>Data</th></tr></thead>
                  <tbody>{data.tickets.map((t: any) => (<tr key={t.number}><td className="font-semibold tabular-nums">#{t.number}</td><td>{t.subject}</td><td><span className="badge badge-warning">{TSTATUS[t.status] ?? t.status}</span></td><td>{t.date}</td></tr>))}</tbody>
                </table>
              )}
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
