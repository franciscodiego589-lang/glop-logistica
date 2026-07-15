"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (n: any) => (n == null ? "—" : Number(n).toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 }));
const riskCls = (r: any) => (r == null ? "bg-slate-500/15 text-slate-400" : r >= 60 ? "bg-red-500/15 text-red-500" : r >= 30 ? "bg-amber-500/15 text-amber-500" : "bg-green-500/15 text-green-500");
const SHIP_STATUS: Record<string, string> = { draft: "Rascunho", planned: "Planejado", dispatched: "Despachado", in_transit: "Em trânsito", delivered: "Entregue", returned: "Devolvido", canceled: "Cancelado" };

const TABS = ["Painel", "Em Trânsito", "Ocorrências"] as const;

export default function TransportTower({ dash, shipments, occurrences, carriers }: { dash: any; shipments: any[]; occurrences: any[]; carriers: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const carrierName = useMemo(() => Object.fromEntries(carriers.map((c) => [c.id, c.name])), [carriers]);

  async function call(rpc: string, label: string) {
    if (!supabase) return;
    setBusy(rpc); setMsg(null);
    const { data, error } = await supabase.rpc(rpc, { p_company: COMPANY });
    setBusy(null);
    setMsg(error ? error.message : `${label}: ${data ?? 0}`);
    router.refresh();
  }
  async function resolveOcc(id: string) {
    if (!supabase) return;
    setBusy(id);
    await supabase.from("transport_occurrences").update({ status: "resolved", resolved_at: new Date().toISOString() }).eq("id", id);
    setBusy(null); router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🌐</div>
        <div>
          <h1 className="text-xl font-bold">Torre de Controle de Transporte</h1>
          <p className="text-sm muted">Monitoramento em trânsito · ETA · score de risco · ocorrências</p>
        </div>
        <div className="ml-auto flex gap-2">
          <button onClick={() => call("transport_insights", "Insights")} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>Analisar risco (IA)</button>
          <button onClick={() => call("detect_transport_issues", "Ocorrências detectadas")} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{busy === "detect_transport_issues" ? "Verificando…" : "⚡ Verificar agora"}</button>
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
          <KpiCard label="Em trânsito" value={dash?.in_transit ?? "—"} accent />
          <KpiCard label="Entregues hoje" value={dash?.delivered_today ?? "—"} />
          <KpiCard label="Em atraso" value={dash?.delayed ?? "—"} />
          <KpiCard label="Alto risco" value={dash?.high_risk ?? "—"} />
          <KpiCard label="Ocorrências abertas" value={dash?.occurrences_open ?? "—"} />
          <KpiCard label="OTIF" value={dash?.otif != null ? `${dash.otif}%` : "—"} hint="entregas no prazo" />
          <KpiCard label="Veículos operando" value={dash?.vehicles_operating ?? "—"} />
          <KpiCard label="Valor em trânsito" value={money(dash?.value_in_transit)} />
        </div>
      )}

      {tab === "Em Trânsito" && (
        shipments.length === 0 ? <p className="text-sm muted px-1">Nenhum embarque em trânsito. (Embarques nascem no TMS.)</p> : (
          <div className="card p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-3">Embarque</th><th className="px-3">Transportadora</th><th className="px-3">Destino</th><th className="px-3">Status</th><th className="px-3">Última localização</th><th className="px-3">Previsão</th><th className="px-3 text-right">Risco</th>
              </tr></thead>
              <tbody>
                {shipments.map((s) => (
                  <tr key={s.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                    <td className="py-2 px-3 font-mono text-xs">{s.code ?? s.tracking_code ?? s.id.slice(0, 8)}</td>
                    <td className="px-3">{s.carrier_id ? carrierName[s.carrier_id] ?? "—" : "—"}</td>
                    <td className="px-3">{[s.dest_city, s.dest_uf].filter(Boolean).join("/") || "—"}</td>
                    <td className="px-3">{SHIP_STATUS[s.status] ?? s.status}</td>
                    <td className="px-3 muted">{s.last_location ?? "—"}</td>
                    <td className="px-3">{s.estimated_delivery ?? "—"}</td>
                    <td className="px-3 text-right"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${riskCls(s.risk_score)}`}>{s.risk_score != null ? Math.round(s.risk_score) : "—"}</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )
      )}

      {tab === "Ocorrências" && (
        <div className="space-y-2">
          {occurrences.length === 0 ? <p className="text-sm muted px-1">Nenhuma ocorrência aberta. Clique em “Verificar agora”.</p> : occurrences.map((o) => (
            <div key={o.id} className={`card p-4 border ${o.severity === "critical" ? "border-red-500/40" : "border-amber-500/40"}`}>
              <div className="flex items-center gap-2">
                <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${o.severity === "critical" ? "bg-red-500/15 text-red-500" : "bg-amber-500/15 text-amber-500"}`}>{o.severity}</span>
                <span className="font-semibold text-sm">{o.occurrence_type}</span>
                <span className="text-xs muted">{o.carrier_id ? "· " + (carrierName[o.carrier_id] ?? "") : ""}</span>
                <button onClick={() => resolveOcc(o.id)} disabled={busy === o.id} className="ml-auto text-xs px-3 py-1.5 rounded-lg bg-brand-600 hover:bg-brand-700 text-white font-semibold">{busy === o.id ? "…" : "Resolver"}</button>
              </div>
              <p className="text-sm mt-1">{o.description}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
