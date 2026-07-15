"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Réplica Digital", "Simulações What-If", "Gargalos", "Histórico"] as const;
const OBJ_ICON = (t: string) => ({ dc: "🏭", warehouse: "🏢", dock: "🚪", yard: "🅿️", fleet: "🚛", vehicle: "🚐", hub: "🔵", route: "🗺", carrier: "🚚", network: "🌐" } as any)[t] ?? "◻️";
const OBJ_LABEL = (t: string) => ({ dc: "CD", warehouse: "Armazém", dock: "Doca", yard: "Pátio", fleet: "Frota", vehicle: "Veículo", hub: "Hub", route: "Rota", carrier: "Transportadora", network: "Rede" } as any)[t] ?? t;
const stColor = (s: string) => ({ ok: "#16a34a", warning: "#d97706", critical: "#dc2626", offline: "#64748b" } as any)[s] ?? "#64748b";
const SCENARIOS: [string, string][] = [["demand_increase", "Aumento de demanda"], ["new_dc", "Novo CD"], ["new_hub", "Novo Hub"], ["new_carrier", "Nova transportadora"], ["close_unit", "Fechamento de unidade"], ["route_change", "Mudança de rota"], ["modal_change", "Mudança de modal"], ["strike", "Greve"], ["roadblock", "Bloqueio rodoviário"], ["weather", "Evento climático"], ["accident", "Acidente"], ["disruption", "Interrupção geral"]];
const KPI_LABEL: Record<string, string> = { cost_index: "Índice de custo", lead_time_days: "Lead time (dias)", utilization_pct: "Utilização %", sla_pct: "SLA %", otif_pct: "OTIF %" };
const goodDown = new Set(["cost_index", "lead_time_days", "utilization_pct"]);

export default function LDTPWorkbench({ dash, objects, bottlenecks, simulations, snapshots }: {
  dash: any; objects: any[]; bottlenecks: any[]; simulations: any[]; snapshots: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState("");
  const [scn, setScn] = useState("demand_increase");
  const [pct, setPct] = useState("30");
  const d = dash ?? {};
  const lastSim = simulations[0];

  async function act(fn: () => PromiseLike<any>, key: string) {
    if (!supabase) return; setBusy(key);
    const { error } = await fn(); setBusy("");
    if (error) alert("Erro: " + error.message); else router.refresh();
  }
  const sync = () => act(() => supabase!.rpc("sync_twin", { p_company: COMPANY }), "sync");
  const detect = () => act(() => supabase!.rpc("detect_bottlenecks", { p_company: COMPANY }), "detect");
  const snapshot = () => act(() => supabase!.rpc("capture_twin_snapshot", { p_company: COMPANY }), "snap");
  const runSim = () => act(() => supabase!.rpc("run_simulation", { p_company: COMPANY, p_name: SCENARIOS.find(([k]) => k === scn)?.[1] ?? scn, p_scenario_type: scn, p_assumptions: { pct: Number(pct) } }), "sim");

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🧬</div>
        <div>
          <h1 className="text-xl font-bold">Gêmeo Digital — LDTP</h1>
          <p className="text-sm muted">Réplica viva da operação · simulação what-if · gargalos · reprodução histórica</p>
        </div>
        <button onClick={sync} disabled={busy === "sync"} className="ml-auto px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">{busy === "sync" ? "Sincronizando…" : "🔄 Sincronizar réplica"}</button>
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
            <KpiCard label="Objetos digitais" value={d.objects ?? 0} accent />
            <div className="card p-4">
              <div className="text-xs uppercase tracking-wide muted font-semibold">Utilização média</div>
              <div className="mt-2 text-2xl font-bold" style={{ color: d.avg_utilization >= 85 ? "var(--danger)" : d.avg_utilization >= 70 ? "var(--warning)" : "var(--success)" }}>{d.avg_utilization != null ? `${d.avg_utilization}%` : "—"}</div>
            </div>
            <KpiCard label="Objetos críticos" value={d.critical_objects ?? 0} tone={d.critical_objects ? "danger" : undefined} />
            <KpiCard label="Gargalos abertos" value={d.bottlenecks_open ?? 0} tone={d.bottlenecks_open ? "warning" : undefined} />
            <KpiCard label="Simulações" value={d.simulations ?? 0} />
            <KpiCard label="Snapshots" value={d.snapshots ?? 0} />
            <KpiCard label="Última sync" value={d.last_sync ? String(d.last_sync).slice(11, 16) : "—"} hint={d.last_sync ? String(d.last_sync).slice(0, 10) : "nunca"} />
          </div>
          <div className="card p-4">
            <div className="font-semibold text-sm mb-2">Objetos por tipo</div>
            <div className="flex flex-wrap gap-2">
              {Object.entries(d.by_type ?? {}).map(([k, v]) => (
                <span key={k} className="badge badge-neutral">{OBJ_ICON(k)} {OBJ_LABEL(k)}: {String(v)}</span>
              ))}
              {Object.keys(d.by_type ?? {}).length === 0 && <span className="text-sm muted">Rode "Sincronizar réplica" para popular o gêmeo digital.</span>}
            </div>
          </div>
        </div>
      )}

      {tab === "Réplica Digital" && (
        objects.length === 0 ? <p className="text-sm muted px-1">Réplica vazia. Clique em "🔄 Sincronizar réplica" no topo.</p> : (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
            {objects.map((o) => (
              <div key={o.id} className="card p-4" style={{ borderLeft: `3px solid ${stColor(o.status)}` }}>
                <div className="flex items-center gap-2">
                  <span className="text-lg">{OBJ_ICON(o.object_type)}</span>
                  <span className="font-semibold text-sm">{o.name ?? o.code}</span>
                  <span className="badge badge-neutral ml-auto text-[10px]">{OBJ_LABEL(o.object_type)}</span>
                </div>
                {o.utilization_pct != null ? (
                  <>
                    <div className="flex items-end justify-between mt-2">
                      <span className="text-2xl font-bold" style={{ color: stColor(o.status) }}>{o.utilization_pct}%</span>
                      <span className="text-xs muted">{o.current_load}/{o.capacity}</span>
                    </div>
                    <div className="h-2 rounded-full bg-black/10 dark:bg-white/10 overflow-hidden mt-1">
                      <div className="h-full" style={{ width: `${Math.min(100, o.utilization_pct)}%`, background: stColor(o.status) }} />
                    </div>
                  </>
                ) : <div className="text-xs muted mt-2">sem métrica de capacidade</div>}
              </div>
            ))}
          </div>
        )
      )}

      {tab === "Simulações What-If" && (
        <div className="space-y-4">
          <div className="card p-4 flex flex-wrap items-end gap-3">
            <div className="font-semibold text-sm w-full">🔮 Rodar cenário (what-if determinístico sobre o estado real)</div>
            <label className="text-xs muted">Cenário
              <select value={scn} onChange={(e) => setScn(e.target.value)} className="input block mt-0.5 w-56">{SCENARIOS.map(([k, l]) => <option key={k} value={k}>{l}</option>)}</select></label>
            {scn === "demand_increase" && <label className="text-xs muted">Intensidade %
              <input type="number" value={pct} onChange={(e) => setPct(e.target.value)} className="input block mt-0.5 w-24" /></label>}
            <button onClick={runSim} disabled={busy === "sim"} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">{busy === "sim" ? "Simulando…" : "▶ Simular"}</button>
          </div>
          {lastSim && (
            <div className="card p-4">
              <div className="font-semibold text-sm mb-3">{lastSim.scenario_name} — comparação atual × cenário</div>
              <div className="overflow-x-auto"><table className="w-full text-sm">
                <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Indicador</th><th className="px-3 text-right">Atual</th><th className="px-3 text-right">Cenário</th><th className="px-3 text-right">Δ</th></tr></thead>
                <tbody>{Object.keys(KPI_LABEL).map((k) => {
                  const base = lastSim.baseline?.[k], res = lastSim.result?.[k], dl = lastSim.delta?.[k];
                  const bad = dl != null && dl !== 0 && ((goodDown.has(k) && dl > 0) || (!goodDown.has(k) && dl < 0));
                  return (
                    <tr key={k} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                      <td className="py-2 px-3">{KPI_LABEL[k]}</td>
                      <td className="px-3 text-right tabular-nums">{base ?? "—"}</td>
                      <td className="px-3 text-right tabular-nums font-semibold">{res ?? "—"}</td>
                      <td className="px-3 text-right tabular-nums font-semibold" style={{ color: dl == null || dl === 0 ? "var(--muted)" : bad ? "var(--danger)" : "var(--success)" }}>{dl != null ? (dl > 0 ? "+" : "") + dl : "—"}</td>
                    </tr>
                  );
                })}</tbody>
              </table></div>
            </div>
          )}
          {simulations.length > 1 && (
            <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Cenário</th><th className="px-3 text-right">SLA</th><th className="px-3 text-right">Custo</th><th className="px-3 text-right">Lead time</th><th className="px-3">Quando</th></tr></thead>
              <tbody>{simulations.map((s) => (
                <tr key={s.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-medium">{s.scenario_name}</td>
                  <td className="px-3 text-right tabular-nums">{s.result?.sla_pct ?? "—"}</td>
                  <td className="px-3 text-right tabular-nums">{s.result?.cost_index ?? "—"}</td>
                  <td className="px-3 text-right tabular-nums">{s.result?.lead_time_days ?? "—"}d</td>
                  <td className="px-3 text-xs muted">{String(s.run_at ?? "").slice(0, 16).replace("T", " ")}</td>
                </tr>))}</tbody>
            </table></div>
          )}
        </div>
      )}

      {tab === "Gargalos" && (
        <div className="space-y-3">
          <button onClick={detect} disabled={busy === "detect"} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">{busy === "detect" ? "Analisando…" : "🔍 Detectar gargalos"}</button>
          {bottlenecks.length === 0 ? <p className="text-sm muted px-1">Nenhum gargalo detectado.</p> : (
            <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Tipo</th><th className="px-3">Severidade</th><th className="px-3 text-right">Valor</th><th className="px-3 text-right">Limite</th><th className="px-3">Status</th></tr></thead>
              <tbody>{bottlenecks.map((b) => (
                <tr key={b.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-medium">{b.bottleneck_type}</td>
                  <td className="px-3"><span className={`badge ${b.severity === "critical" ? "badge-danger" : b.severity === "high" ? "badge-warning" : "badge-neutral"}`}>{b.severity}</span></td>
                  <td className="px-3 text-right tabular-nums">{b.value ?? "—"}%</td><td className="px-3 text-right tabular-nums">{b.threshold ?? "—"}%</td>
                  <td className="px-3"><span className={`badge ${b.status === "resolved" ? "badge-success" : "badge-neutral"}`}>{b.status}</span></td>
                </tr>))}</tbody>
            </table></div>
          )}
        </div>
      )}

      {tab === "Histórico" && (
        <div className="space-y-3">
          <button onClick={snapshot} disabled={busy === "snap"} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">{busy === "snap" ? "Capturando…" : "📸 Capturar snapshot"}</button>
          {snapshots.length === 0 ? <p className="text-sm muted px-1">Sem snapshots. Capture o estado atual para reprodução histórica.</p> : (
            <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Capturado</th><th className="px-3 text-right">Objetos</th><th className="px-3 text-right">Utilização média</th><th className="px-3 text-right">Gargalos</th></tr></thead>
              <tbody>{snapshots.map((s) => (
                <tr key={s.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">{String(s.captured_at ?? "").slice(0, 16).replace("T", " ")}</td>
                  <td className="px-3 text-right">{s.object_count}</td><td className="px-3 text-right tabular-nums">{s.avg_utilization}%</td><td className="px-3 text-right">{s.bottlenecks}</td>
                </tr>))}</tbody>
            </table></div>
          )}
        </div>
      )}
    </div>
  );
}
