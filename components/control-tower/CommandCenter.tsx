"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (n: any) => (n == null ? "—" : Number(n).toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 }));

export default function CommandCenter({ noc, scores, alerts, incidents, insights }:
  { noc: any; scores: any[]; alerts: any[]; incidents: any[]; insights: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);

  async function scan() {
    if (!supabase) return;
    setBusy("scan"); setMsg(null);
    const { data, error } = await supabase.rpc("lct_scan", { p_company: COMPANY });
    setBusy(null);
    setMsg(error ? error.message : `Varredura completa: ${(data?.dispatch_issues ?? 0) + (data?.transport_issues ?? 0)} problema(s)${data?.incident_opened ? " · 🚨 sala de crise aberta" : ""}. Scores atualizados.`);
    router.refresh();
  }
  async function resolveIncident(id: string) {
    if (!supabase) return;
    setBusy(id);
    await supabase.from("incidents").update({ status: "resolved", resolved_at: new Date().toISOString() }).eq("id", id);
    setBusy(null); router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">⛭</div>
        <div>
          <h1 className="text-xl font-bold">Torre de Controle Logística — Centro de Comando</h1>
          <p className="text-sm muted">NOC · consolida WMS/TMS/Correios/Expedição/Estoque/Financeiro em tempo real</p>
        </div>
        <button onClick={scan} disabled={!!busy} className="ml-auto text-sm px-4 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{busy === "scan" ? "Varrendo…" : "⚡ Varredura (rodar motores + IA)"}</button>
      </div>
      {msg && <div className="text-sm text-brand-500 px-1">{msg}</div>}

      {/* NOC */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <KpiCard label="Pedidos em aberto" value={noc?.orders_open ?? "—"} />
        <KpiCard label="Aguardando postagem" value={noc?.awaiting_post ?? "—"} accent />
        <KpiCard label="Sem movimentação" value={noc?.no_movement ?? "—"} />
        <KpiCard label="Em trânsito" value={noc?.in_transit ?? "—"} />
        <KpiCard label="Atrasados" value={noc?.delayed ?? "—"} />
        <KpiCard label="Alto risco" value={noc?.high_risk ?? "—"} />
        <KpiCard label="Devoluções abertas" value={noc?.returns_open ?? "—"} />
        <KpiCard label="Abaixo do ponto de pedido" value={noc?.below_reorder ?? "—"} />
        <KpiCard label="Valor em trânsito" value={money(noc?.value_in_transit)} />
        <KpiCard label="A pagar vencido" value={money(noc?.ap_overdue)} />
        <KpiCard label="Alertas abertos" value={noc?.alerts_open ?? "—"} />
        <KpiCard label="Incidentes abertos" value={noc?.incidents_open ?? "—"} accent />
      </div>

      {/* Score operacional por área */}
      <div className="card p-4">
        <div className="font-semibold mb-3">Score operacional por área</div>
        {scores.length === 0 ? <p className="text-sm muted">Rode a varredura para calcular os scores.</p> : (
          <div className="grid md:grid-cols-2 gap-x-8 gap-y-3">
            {scores.map((s) => {
              const v = Number(s.score);
              const cls = v >= 80 ? "bg-green-500" : v >= 50 ? "bg-amber-500" : "bg-red-500";
              return (
                <div key={s.area}>
                  <div className="flex justify-between text-sm mb-1"><span>{s.area}</span><span className="font-semibold tabular-nums">{v.toFixed(0)}</span></div>
                  <div className="h-2 rounded-full bg-black/10 dark:bg-white/10 overflow-hidden"><div className={`h-full ${cls}`} style={{ width: `${Math.min(v, 100)}%` }} /></div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      <div className="grid md:grid-cols-2 gap-4">
        {/* Sala de crise / incidentes */}
        <div className="card p-4">
          <div className="font-semibold mb-2">🚨 Sala de crise — incidentes ({incidents.length})</div>
          {incidents.length === 0 ? <p className="text-sm muted">Nenhum incidente aberto.</p> : (
            <div className="space-y-2">
              {incidents.map((i) => (
                <div key={i.id} className="border rounded-lg p-3" style={{ borderColor: "var(--border)" }}>
                  <div className="flex items-center gap-2">
                    <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${i.severity === "critical" ? "bg-red-500/15 text-red-500" : "bg-amber-500/15 text-amber-500"}`}>{i.severity}</span>
                    <span className="font-medium text-sm">{i.title}</span>
                    <button onClick={() => resolveIncident(i.id)} disabled={busy === i.id} className="ml-auto text-xs text-brand-500 hover:underline">resolver</button>
                  </div>
                  <p className="text-xs muted mt-1">{i.description}</p>
                  {i.action_plan && <p className="text-xs mt-1">✦ Plano: {i.action_plan}</p>}
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Recomendações da IA (insights consolidados) */}
        <div className="card p-4">
          <div className="font-semibold mb-2">✦ IA — recomendações & previsões ({insights.length})</div>
          {insights.length === 0 ? <p className="text-sm muted">Sem insights novos. Rode a varredura.</p> : (
            <div className="space-y-2">
              {insights.slice(0, 8).map((n) => (
                <div key={n.id} className="border rounded-lg p-3" style={{ borderColor: "var(--border)" }}>
                  <div className="flex items-center gap-2">
                    <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${n.severity === "critical" ? "bg-red-500/15 text-red-500" : "bg-amber-500/15 text-amber-500"}`}>{n.kind}</span>
                    <span className="font-medium text-sm">{n.title}</span>
                  </div>
                  {n.recommendation && <p className="text-xs muted mt-1">→ {n.recommendation}</p>}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Alertas */}
      {alerts.length > 0 && (
        <div className="card p-4">
          <div className="font-semibold mb-2">Alertas abertos ({alerts.length})</div>
          <div className="space-y-1">
            {alerts.slice(0, 10).map((a) => (
              <div key={a.id} className="flex items-center gap-2 text-sm border-b last:border-0 py-1.5" style={{ borderColor: "var(--border)" }}>
                <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${a.severity === "critical" ? "bg-red-500/15 text-red-500" : "bg-amber-500/15 text-amber-500"}`}>{a.severity}</span>
                <span>{a.title}</span>
                <span className="ml-auto text-xs muted">{a.domain}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
