"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (n: any) => (n == null ? "—" : Number(n).toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 }));

// horas desde uma data + cor do alerta (regras de tempo configuráveis)
function elapsed(from: string | null) {
  if (!from) return { h: 0, label: "—", cls: "" };
  const h = (Date.now() - new Date(from).getTime()) / 3.6e6;
  const label = h < 1 ? `${Math.round(h * 60)}min` : `${h.toFixed(1)}h`;
  const cls = h > 24 ? "bg-red-600/20 text-red-500" : h > 12 ? "bg-red-500/15 text-red-500" : h > 6 ? "bg-orange-500/15 text-orange-500" : h > 2 ? "bg-amber-500/15 text-amber-500" : "bg-green-500/15 text-green-500";
  return { h, label, cls };
}

const TABS = ["Painel", "Aguardando Postagem", "Sem Movimentação", "Problemas"] as const;

export default function DispatchWorkbench({ dash, dispatches, issues }: { dash: any; dispatches: any[]; issues: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);

  const awaiting = dispatches.filter((d) => !d.posted_at && !["canceled", "returned"].includes(d.stage));
  const noMove = dispatches.filter((d) => d.posted_at && !d.first_movement_at);

  async function call(rpc: string, label: string) {
    if (!supabase) return;
    setBusy(rpc); setMsg(null);
    const { data, error } = await supabase.rpc(rpc, { p_company: COMPANY });
    setBusy(null);
    setMsg(error ? error.message : `${label}: ${data ?? 0}`);
    router.refresh();
  }
  async function resolveIssue(id: string) {
    if (!supabase) return;
    setBusy(id);
    await supabase.from("dispatch_issues").update({ status: "resolved", resolved_at: new Date().toISOString() }).eq("id", id);
    setBusy(null); router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🛰</div>
        <div>
          <h1 className="text-xl font-bold">Torre de Controle de Postagens</h1>
          <p className="text-sm muted">Correios + transportadoras · etiqueta → postagem → 1ª movimentação</p>
        </div>
        <div className="ml-auto flex gap-2">
          <button onClick={() => call("generate_dispatches", "Postagens geradas")} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>Gerar dos pedidos</button>
          <button onClick={() => call("detect_dispatch_issues", "Problemas detectados")} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{busy === "detect_dispatch_issues" ? "Verificando…" : "⚡ Verificar agora"}</button>
        </div>
      </div>
      {msg && <div className="text-sm text-brand-500 px-1">{msg}</div>}

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>
            {t}{t === "Problemas" && issues.length > 0 ? ` (${issues.length})` : ""}
          </button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="space-y-3">
          <div className="card p-3 flex items-center gap-3">
            <div className="text-sm"><b>✦ IA da Torre</b> <span className="muted">— objetos parados, transportadoras abaixo do SLA, redistribuição de carga.</span></div>
            <button onClick={() => call("dispatch_insights", "Insights gerados")} disabled={!!busy} className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white font-semibold disabled:opacity-60">Analisar atrasos</button>
          </div>
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="Aguardando postagem" value={dash?.awaiting_post ?? "—"} accent />
            <KpiCard label="Postados hoje" value={dash?.posted_today ?? "—"} />
            <KpiCard label="Sem 1ª movimentação" value={dash?.no_movement ?? "—"} />
            <KpiCard label="Problemas abertos" value={dash?.open_issues ?? "—"} />
            <KpiCard label="Problemas críticos" value={dash?.critical_issues ?? "—"} />
            <KpiCard label="Entregues" value={dash?.delivered ?? "—"} />
            <KpiCard label="Tempo médio postagem" value={dash?.avg_post_hours != null ? `${dash.avg_post_hours}h` : "—"} />
            <KpiCard label="Peso hoje (kg)" value={dash?.total_weight_kg ?? "—"} />
          </div>
        </div>
      )}

      {tab === "Aguardando Postagem" && (
        <DispatchTable rows={awaiting} timeField="label_created_at" timeLabel="Aguardando" empty="Nenhum pedido aguardando postagem." />
      )}

      {tab === "Sem Movimentação" && (
        <DispatchTable rows={noMove} timeField="posted_at" timeLabel="Desde postagem" empty="Todos os objetos postados já tiveram movimentação." />
      )}

      {tab === "Problemas" && (
        <div className="space-y-2">
          {issues.length === 0 ? <p className="text-sm muted px-1">Nenhum problema aberto. Clique em “Verificar agora”.</p> : issues.map((it) => {
            const sevCls = it.severity === "critical" ? "border-red-500/40" : it.severity === "warning" ? "border-amber-500/40" : "border-slate-500/30";
            return (
              <div key={it.id} className={`card p-4 border ${sevCls}`}>
                <div className="flex items-center gap-2">
                  <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${it.severity === "critical" ? "bg-red-500/15 text-red-500" : "bg-amber-500/15 text-amber-500"}`}>{it.severity}</span>
                  <span className="font-semibold text-sm">{it.issue_type}</span>
                  <button onClick={() => resolveIssue(it.id)} disabled={busy === it.id} className="ml-auto text-xs px-3 py-1.5 rounded-lg bg-brand-600 hover:bg-brand-700 text-white font-semibold">{busy === it.id ? "…" : "Resolver"}</button>
                </div>
                <p className="text-sm mt-1">{it.description}</p>
                {it.suggestion && <p className="text-xs muted mt-1">✦ Sugestão: {it.suggestion}</p>}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function DispatchTable({ rows, timeField, timeLabel, empty }: { rows: any[]; timeField: string; timeLabel: string; empty: string }) {
  const sorted = [...rows].sort((a, b) => elapsed(b[timeField]).h - elapsed(a[timeField]).h);
  return rows.length === 0 ? <p className="text-sm muted px-1">{empty}</p> : (
    <div className="card p-0 overflow-x-auto">
      <table className="w-full text-sm">
        <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
          <th className="py-2 px-3">Postagem</th><th className="px-3">Destino</th><th className="px-3">Rastreio</th><th className="px-3">Peso</th><th className="px-3">Valor</th><th className="px-3">{timeLabel}</th>
        </tr></thead>
        <tbody>
          {sorted.map((d) => {
            const e = elapsed(d[timeField]);
            return (
              <tr key={d.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                <td className="py-2 px-3 font-mono text-xs">{d.code ?? d.id.slice(0, 8)}</td>
                <td className="px-3">{[d.dest_city, d.dest_uf].filter(Boolean).join("/") || d.dest_cep || "—"}</td>
                <td className="px-3 font-mono text-xs">{d.tracking_code ?? "—"}</td>
                <td className="px-3">{d.weight_g ? (d.weight_g / 1000).toFixed(2) + " kg" : "—"}</td>
                <td className="px-3">{money(d.order_value)}</td>
                <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${e.cls}`}>{e.label}</span></td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
