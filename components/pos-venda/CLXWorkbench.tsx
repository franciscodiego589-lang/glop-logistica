"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Ocorrências", "Pesquisas (NPS)", "Notificações"] as const;

export default function CLXWorkbench({ dash, occurrences, surveys, notifications, customers }:
  { dash: any; occurrences: any[]; surveys: any[]; notifications: any[]; customers: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const custName = useMemo(() => Object.fromEntries(customers.map((c) => [c.id, c.name])), [customers]);

  async function ia() {
    if (!supabase) return;
    setBusy("ia"); setMsg(null);
    const { data, error } = await supabase.rpc("clx_insights", { p_company: COMPANY });
    setBusy(null); setMsg(error ? error.message : `${data ?? 0} cliente(s) em risco de churn sinalizado(s) na LOGIA.`); router.refresh();
  }
  async function resolve(id: string) {
    if (!supabase) return;
    setBusy(id);
    await supabase.from("customer_occurrences").update({ status: "resolved", resolved_at: new Date().toISOString() }).eq("id", id);
    setBusy(null); router.refresh();
  }
  const npsCls = dash?.nps == null ? "" : dash.nps >= 50 ? "text-green-500" : dash.nps >= 0 ? "text-amber-500" : "text-red-500";

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">💬</div>
        <div>
          <h1 className="text-xl font-bold">Pós-Venda & Experiência do Cliente (CLX)</h1>
          <p className="text-sm muted">Ocorrências · NPS/CSAT · notificações · rastreio público</p>
        </div>
        <div className="ml-auto flex gap-2">
          <Link href="/rastreio" target="_blank" className="text-sm px-3 py-2 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>Página pública de rastreio ↗</Link>
          <button onClick={ia} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">IA churn</button>
        </div>
      </div>
      {msg && <div className="text-sm text-brand-500 px-1">{msg}</div>}

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>
            {t}{t === "Ocorrências" && occurrences.length > 0 ? ` (${occurrences.length})` : ""}
          </button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <div className="card p-4">
            <div className="text-xs uppercase tracking-wide muted font-semibold">NPS</div>
            <div className={`mt-2 text-3xl font-bold tabular-nums ${npsCls}`}>{dash?.nps ?? "—"}</div>
          </div>
          <KpiCard label="CSAT (1-5)" value={dash?.csat ?? "—"} />
          <KpiCard label="% no prazo" value={dash?.on_time_pct != null ? `${dash.on_time_pct}%` : "—"} />
          <KpiCard label="Pesquisas" value={dash?.surveys ?? "—"} />
          <KpiCard label="Ocorrências abertas" value={dash?.occurrences_open ?? "—"} accent />
          <KpiCard label="Ocorrências resolvidas" value={dash?.occurrences_resolved ?? "—"} />
          <KpiCard label="Tempo médio resolução" value={dash?.avg_resolution_hours != null ? `${dash.avg_resolution_hours}h` : "—"} />
          <KpiCard label="Devoluções abertas" value={dash?.returns_open ?? "—"} />
        </div>
      )}

      {tab === "Ocorrências" && (
        <div className="space-y-2">
          {occurrences.length === 0 ? <p className="text-sm muted px-1">Nenhuma ocorrência aberta pelo cliente.</p> : occurrences.map((o) => (
            <div key={o.id} className="card p-4">
              <div className="flex items-center gap-2">
                <span className="text-xs px-2 py-0.5 rounded-md bg-amber-500/15 text-amber-500 font-semibold">{o.occurrence_type}</span>
                <span className="text-sm font-medium">{o.customer_id ? custName[o.customer_id] ?? "Cliente" : "Cliente"}</span>
                <span className="text-xs muted">· prioridade {o.priority}</span>
                {o.status !== "resolved" && o.status !== "closed" && <button onClick={() => resolve(o.id)} disabled={busy === o.id} className="ml-auto text-xs px-3 py-1.5 rounded-lg bg-brand-600 hover:bg-brand-700 text-white font-semibold">{busy === o.id ? "…" : "Resolver"}</button>}
              </div>
              {o.description && <p className="text-sm mt-1">{o.description}</p>}
            </div>
          ))}
          <div className="pt-2">
            <CrudPanel table="customer_occurrences" title="Registrar ocorrência" rows={[]}
              fields={[
                { key: "customer_id", label: "Cliente", type: "fk", fkTable: "customers" },
                { key: "occurrence_type", label: "Tipo", type: "select", options: [["delayed", "Pedido atrasado"], ["not_received", "Não recebido"], ["damaged", "Avariado"], ["wrong", "Produto incorreto"], ["incomplete", "Incompleto"], ["delivery_failed", "Tentativa falhou"], ["lost", "Extravio"], ["quality", "Qualidade"], ["info", "Informação"], ["other", "Outros"]], required: true },
                { key: "priority", label: "Prioridade", type: "select", options: [["low", "Baixa"], ["normal", "Normal"], ["high", "Alta"], ["urgent", "Urgente"]], default: "normal" },
                { key: "description", label: "Descrição" }, { key: "contact", label: "Contato" },
              ]}
              columns={[]} emptyHint="" />
          </div>
        </div>
      )}

      {tab === "Pesquisas (NPS)" && (
        surveys.length === 0 ? <p className="text-sm muted px-1">Nenhuma pesquisa respondida ainda.</p> : (
          <div className="card p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Cliente</th><th className="px-3">NPS</th><th className="px-3">CSAT</th><th className="px-3">No prazo</th><th className="px-3">Íntegro</th><th className="px-3">Comentário</th></tr></thead>
              <tbody>{surveys.map((s) => (
                <tr key={s.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">{s.customer_id ? custName[s.customer_id] ?? "—" : "—"}</td>
                  <td className="px-3"><span className={`font-semibold ${s.nps >= 9 ? "text-green-500" : s.nps <= 6 ? "text-red-500" : "text-amber-500"}`}>{s.nps ?? "—"}</span></td>
                  <td className="px-3">{s.csat ?? "—"}</td><td className="px-3">{s.on_time == null ? "—" : s.on_time ? "Sim" : "Não"}</td>
                  <td className="px-3">{s.intact == null ? "—" : s.intact ? "Sim" : "Não"}</td><td className="px-3 muted">{s.comment ?? "—"}</td>
                </tr>))}</tbody>
            </table>
          </div>
        )
      )}

      {tab === "Notificações" && (
        notifications.length === 0 ? <p className="text-sm muted px-1">Nenhuma notificação registrada.</p> : (
          <div className="card p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Cliente</th><th className="px-3">Canal</th><th className="px-3">Evento</th><th className="px-3">Status</th><th className="px-3">Enviado</th></tr></thead>
              <tbody>{notifications.map((n) => (
                <tr key={n.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">{n.customer_id ? custName[n.customer_id] ?? "—" : "—"}</td>
                  <td className="px-3">{n.channel}</td><td className="px-3">{n.event}</td><td className="px-3">{n.status}</td>
                  <td className="px-3 muted">{n.sent_at ? new Date(n.sent_at).toLocaleString("pt-BR") : "—"}</td>
                </tr>))}</tbody>
            </table>
          </div>
        )
      )}
    </div>
  );
}
