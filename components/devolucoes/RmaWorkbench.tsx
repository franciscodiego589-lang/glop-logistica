"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (n: any) => (n == null ? "—" : Number(n).toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 }));
export const RMA_STATUS: Record<string, { label: string; cls: string }> = {
  open: { label: "Aberta", cls: "bg-slate-500/15 text-slate-400" },
  in_transit: { label: "Em trânsito", cls: "bg-blue-500/15 text-blue-500" },
  received: { label: "Recebida", cls: "bg-indigo-500/15 text-indigo-500" },
  inspecting: { label: "Inspeção", cls: "bg-amber-500/15 text-amber-500" },
  approved: { label: "Aprovada", cls: "bg-green-500/15 text-green-500" },
  partially_approved: { label: "Parcial", cls: "bg-amber-500/15 text-amber-500" },
  rejected: { label: "Rejeitada", cls: "bg-red-500/15 text-red-500" },
  refunded: { label: "Reembolsada", cls: "bg-teal-500/15 text-teal-500" },
  exchanged: { label: "Trocada", cls: "bg-teal-500/15 text-teal-500" },
  reshipped: { label: "Reenviada", cls: "bg-teal-500/15 text-teal-500" },
  closed: { label: "Encerrada", cls: "bg-green-500/15 text-green-500" },
  canceled: { label: "Cancelada", cls: "bg-slate-500/15 text-slate-400" },
};

const TABS = ["Painel", "Devoluções", "Motivos"] as const;

export default function RmaWorkbench({ dash, rmas, reasons, customers }: { dash: any; rmas: any[]; reasons: any[]; customers: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ customer_id: "", channel: "customer", invoice_number: "", description: "", total_value: "" });
  const custName = useMemo(() => Object.fromEntries(customers.map((c) => [c.id, c.name])), [customers]);

  async function createRma() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id;
    const { data, error } = await supabase.from("rma_requests").insert({
      tenant_id, company_id: COMPANY, status: "open", channel: f.channel,
      customer_id: f.customer_id || null, invoice_number: f.invoice_number || null,
      description: f.description || null, total_value: f.total_value ? Number(f.total_value) : null,
    }).select("id").single();
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.push(`/devolucoes/${(data as any).id}`);
  }

  async function runIA() {
    if (!supabase) return;
    setBusy(true); setMsg(null);
    const { data, error } = await supabase.rpc("rma_insights", { p_company: COMPANY });
    setBusy(false);
    setMsg(error ? error.message : `IA de devoluções: ${data ?? 0} produto(s) com devoluções recorrentes sinalizado(s) na LOGIA.`);
    router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">↩</div>
        <div>
          <h1 className="text-xl font-bold">Devoluções (RMA) & Logística Reversa</h1>
          <p className="text-sm muted">Solicitação → recebimento → conferência → disposição → reintegração</p>
        </div>
      </div>

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="space-y-3">
          <div className="card p-3 flex items-center gap-3">
            <div className="text-sm"><b>✦ IA de Devoluções</b> <span className="muted">— produtos/lotes mais devolvidos, padrões e reincidência.</span></div>
            <button onClick={runIA} disabled={busy} className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white font-semibold disabled:opacity-60">
              {busy ? "Analisando…" : "Analisar padrões"}
            </button>
          </div>
          {msg && <div className="text-sm text-brand-500 px-1">{msg}</div>}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="RMA em aberto" value={dash?.open ?? "—"} accent />
            <KpiCard label="Em inspeção" value={dash?.inspecting ?? "—"} />
            <KpiCard label="Encerradas" value={dash?.closed ?? "—"} />
            <KpiCard label="Valor devolvido" value={money(dash?.value_returned)} />
            <KpiCard label="Reembolsos" value={money(dash?.refund_amount)} />
            <KpiCard label="Itens em quarentena" value={dash?.quarantine_items ?? "—"} />
            <KpiCard label="Itens p/ descarte" value={dash?.disposal_items ?? "—"} />
            <KpiCard label="Tempo médio (dias)" value={dash?.avg_days ?? "—"} />
          </div>
          {dash?.top_reasons?.length > 0 && (
            <div className="card p-4">
              <div className="font-semibold mb-2">Top motivos de devolução</div>
              {dash.top_reasons.map((r: any, i: number) => (
                <div key={i} className="flex justify-between text-sm py-1"><span>{r.name}</span><span className="font-semibold">{r.c}</span></div>
              ))}
            </div>
          )}
        </div>
      )}

      {tab === "Devoluções" && (
        <div className="space-y-3">
          <div className="flex items-center gap-3">
            <div className="font-semibold">Devoluções <span className="muted font-normal">({rmas.length})</span></div>
            <button onClick={() => { setOpen((o) => !o); setErr(null); }} className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Nova devolução"}</button>
          </div>
          {open && (
            <div className="card p-4 grid md:grid-cols-3 gap-3">
              <div><label className="text-xs font-semibold muted">Cliente</label>
                <select value={f.customer_id} onChange={(e) => setF({ ...f, customer_id: e.target.value })} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                  <option value="">—</option>{customers.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
                </select></div>
              <div><label className="text-xs font-semibold muted">Canal</label>
                <select value={f.channel} onChange={(e) => setF({ ...f, channel: e.target.value })} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                  {[["customer", "Cliente"], ["sac", "SAC"], ["sales", "Comercial"], ["marketplace", "Marketplace"], ["finance", "Financeiro"], ["tech_assistance", "Assistência"], ["api", "API"]].map(([v, l]) => <option key={v} value={v}>{l}</option>)}
                </select></div>
              <div><label className="text-xs font-semibold muted">Nota fiscal</label>
                <input value={f.invoice_number} onChange={(e) => setF({ ...f, invoice_number: e.target.value })} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div className="md:col-span-2"><label className="text-xs font-semibold muted">Descrição</label>
                <input value={f.description} onChange={(e) => setF({ ...f, description: e.target.value })} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div><label className="text-xs font-semibold muted">Valor (R$)</label>
                <input type="number" value={f.total_value} onChange={(e) => setF({ ...f, total_value: e.target.value })} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              {err && <div className="text-sm text-red-500 md:col-span-3">{err}</div>}
              <button onClick={createRma} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60 md:col-span-3 w-fit">{busy ? "Criando…" : "Criar e adicionar itens"}</button>
            </div>
          )}
          {rmas.length === 0 ? <p className="text-sm muted px-1">Nenhuma devolução ainda.</p> : (
            <div className="card p-0 overflow-x-auto">
              <table className="w-full text-sm">
                <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">RMA</th><th className="px-3">Cliente</th><th className="px-3">Canal</th><th className="px-3">Valor</th><th className="px-3">Status</th><th></th></tr></thead>
                <tbody>
                  {rmas.map((r) => (
                    <tr key={r.id} className="border-b last:border-0 hover:bg-black/[.02] dark:hover:bg-white/[.03]" style={{ borderColor: "var(--border)" }}>
                      <td className="py-2 px-3 font-mono">{r.code ?? r.id.slice(0, 8)}</td>
                      <td className="px-3">{r.customer_id ? custName[r.customer_id] ?? "—" : "—"}</td>
                      <td className="px-3 muted">{r.channel}</td>
                      <td className="px-3">{money(r.total_value)}</td>
                      <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${RMA_STATUS[r.status]?.cls ?? ""}`}>{RMA_STATUS[r.status]?.label ?? r.status}</span></td>
                      <td className="px-3 text-right"><Link href={`/devolucoes/${r.id}`} className="text-xs text-brand-500 hover:underline">abrir →</Link></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}

      {tab === "Motivos" && (
        <CrudPanel table="return_reasons" title="Motivos de devolução" rows={reasons}
          emptyHint="Cadastre motivos (produto errado, avariado, vencido, arrependimento, erro de separação…)."
          fields={[
            { key: "name", label: "Motivo", required: true },
            { key: "category", label: "Categoria", type: "select", options: [["logistics", "Logística"], ["quality", "Qualidade"], ["commercial", "Comercial"], ["customer", "Cliente"], ["operational", "Operacional"], ["carrier", "Transporte"]] },
            { key: "requires_photo", label: "Exige foto", type: "select", options: [["true", "Sim"], ["false", "Não"]], default: "false" },
          ]}
          columns={[{ key: "name", label: "Motivo" }, { key: "category", label: "Categoria" }, { key: "requires_photo", label: "Foto" }]} />
      )}
    </div>
  );
}
