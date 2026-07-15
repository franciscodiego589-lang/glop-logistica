"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Malha", "Cobertura & Balanceamento", "Simulações de Rede"] as const;
const NT_ICON = (t: string) => ({ dc: "🏭", warehouse: "🏢", mini_hub: "🔵", cross_dock: "🔀", dark_warehouse: "🌑", road_terminal: "🛣", rail_terminal: "🚂", seaport: "⚓", airport: "✈️", bonded_zone: "🛃", consolidation: "📦", deconsolidation: "📤", locker: "🔒", pickup_point: "📍", base: "🏠" } as any)[t] ?? "◻️";
const NT_LABEL = (t: string) => ({ dc: "CD", warehouse: "Armazém", mini_hub: "Mini-hub", cross_dock: "Cross-dock", dark_warehouse: "Dark WH", road_terminal: "Term. rodoviário", rail_terminal: "Term. ferroviário", seaport: "Porto", airport: "Aeroporto", bonded_zone: "Recinto alfandegado", consolidation: "Consolidação", deconsolidation: "Desconsolidação", locker: "Locker", pickup_point: "Ponto de coleta", base: "Base" } as any)[t] ?? t;
const uColor = (u: number | null) => u == null ? "#64748b" : u >= 90 ? "#dc2626" : u >= 75 ? "#d97706" : "#16a34a";
const SCENARIOS: [string, string][] = [["new_dc", "Novo CD"], ["new_hub", "Novo Hub"], ["new_region", "Nova região"], ["new_lane", "Nova conexão"], ["new_carrier", "Nova transportadora"], ["close_unit", "Fechar unidade"], ["demand_increase", "Aumento de demanda"], ["rebalance", "Rebalancear"], ["crisis", "Crise logística"], ["weather", "Evento climático"]];
const KPI_LABEL: Record<string, string> = { nodes: "Nós", avg_utilization: "Utilização %", regions: "Regiões", cost_index: "Índice de custo", lead_time_days: "Lead time (dias)" };
const goodDown = new Set(["cost_index", "lead_time_days", "avg_utilization"]);

export default function GLNMPWorkbench({ dash, coverage, balance, nodes, lanes, scenarios }: {
  dash: any; coverage: any; balance: any; nodes: any[]; lanes: any[]; scenarios: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState("");
  const [scn, setScn] = useState("new_dc");
  const d = dash ?? {};
  const lastSim = scenarios[0];

  async function act(fn: () => PromiseLike<any>, key: string) {
    if (!supabase) return; setBusy(key);
    const { error } = await fn(); setBusy("");
    if (error) alert("Erro: " + error.message); else router.refresh();
  }
  const sync = () => act(() => supabase!.rpc("sync_network", { p_company: COMPANY }), "sync");
  const runSim = () => act(() => supabase!.rpc("run_network_scenario", { p_company: COMPANY, p_name: SCENARIOS.find(([k]) => k === scn)?.[1] ?? scn, p_scenario_type: scn, p_assumptions: { pct: 30 } }), "sim");

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🌐</div>
        <div>
          <h1 className="text-xl font-bold">Rede Logística Global — GLNMP</h1>
          <p className="text-sm muted">Malha operacional: nós · conexões · fluxos · capacidade · cobertura · simulação estratégica</p>
        </div>
        <button onClick={sync} disabled={busy === "sync"} className="ml-auto px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">{busy === "sync" ? "Sincronizando…" : "🔄 Sincronizar malha"}</button>
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
            <KpiCard label="Nós da rede" value={d.nodes ?? 0} accent />
            <KpiCard label="Regiões cobertas" value={d.regions ?? 0} />
            <KpiCard label="Nós saturados" value={d.saturated ?? 0} tone={d.saturated ? "danger" : undefined} />
            <div className="card p-4">
              <div className="text-xs uppercase tracking-wide muted font-semibold">Utilização média</div>
              <div className="mt-2 text-2xl font-bold" style={{ color: uColor(d.avg_utilization) }}>{d.avg_utilization != null ? `${d.avg_utilization}%` : "—"}</div>
            </div>
            <KpiCard label="Conexões (lanes)" value={d.lanes ?? 0} />
            <KpiCard label="Capacidade total" value={d.total_capacity != null ? Number(d.total_capacity).toLocaleString("pt-BR") : "—"} />
            <KpiCard label="Fluxos" value={d.flows ?? 0} />
            <KpiCard label="Última sync" value={d.last_sync ? String(d.last_sync).slice(11, 16) : "—"} hint={d.last_sync ? String(d.last_sync).slice(0, 10) : "nunca"} />
          </div>
          <div className="card p-4">
            <div className="font-semibold text-sm mb-2">Nós por tipo</div>
            <div className="flex flex-wrap gap-2">
              {Object.entries(coverage?.by_type ?? {}).map(([k, v]) => (
                <span key={k} className="badge badge-neutral">{NT_ICON(k)} {NT_LABEL(k)}: {String(v)}</span>
              ))}
              {Object.keys(coverage?.by_type ?? {}).length === 0 && <span className="text-sm muted">Rode "Sincronizar malha" para modelar a rede.</span>}
            </div>
          </div>
        </div>
      )}

      {tab === "Malha" && (
        nodes.length === 0 ? <p className="text-sm muted px-1">Malha vazia. Clique em "🔄 Sincronizar malha".</p> : (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
            {nodes.map((n) => (
              <div key={n.id} className="card p-4" style={{ borderLeft: `3px solid ${uColor(n.utilization_pct)}` }}>
                <div className="flex items-center gap-2">
                  <span className="text-lg">{NT_ICON(n.node_type)}</span>
                  <span className="font-semibold text-sm">{n.name ?? n.node_code}</span>
                  <span className="badge badge-neutral ml-auto text-[10px]">{NT_LABEL(n.node_type)}</span>
                </div>
                <div className="text-xs muted mt-1">{n.region ?? "sem região"} · {n.status}</div>
                {n.utilization_pct != null ? (
                  <>
                    <div className="flex items-end justify-between mt-2">
                      <span className="text-xl font-bold" style={{ color: uColor(n.utilization_pct) }}>{n.utilization_pct}%</span>
                      <span className="text-xs muted">{Number(n.current_load).toLocaleString("pt-BR")}/{Number(n.capacity).toLocaleString("pt-BR")}</span>
                    </div>
                    <div className="h-2 rounded-full bg-black/10 dark:bg-white/10 overflow-hidden mt-1"><div className="h-full" style={{ width: `${Math.min(100, n.utilization_pct)}%`, background: uColor(n.utilization_pct) }} /></div>
                  </>
                ) : <div className="text-xs muted mt-2">sem capacidade definida</div>}
              </div>
            ))}
          </div>
        )
      )}

      {tab === "Cobertura & Balanceamento" && (
        <div className="space-y-4">
          <div className="card p-4">
            <div className="font-semibold text-sm mb-2">Cobertura por região ({coverage?.regions_covered ?? 0} regiões)</div>
            <div className="flex flex-wrap gap-2">
              {Object.entries(coverage?.by_region ?? {}).map(([k, v]) => (
                <span key={k} className="badge badge-neutral">📍 {k}: {String(v)}</span>
              ))}
            </div>
          </div>
          <div className="grid md:grid-cols-2 gap-4">
            <div className="card p-4">
              <div className="font-semibold text-sm mb-2" style={{ color: "var(--danger)" }}>⚠ Sobrecarregados (≥85%)</div>
              {(balance?.overloaded ?? []).length === 0 ? <p className="text-sm muted">Nenhum.</p> : (balance.overloaded).map((o: any, i: number) => (
                <div key={i} className="flex items-center gap-2 text-sm py-1"><span className="font-medium">{o.name}</span><span className="ml-auto font-bold" style={{ color: "var(--danger)" }}>{o.utilization}%</span></div>
              ))}
            </div>
            <div className="card p-4">
              <div className="font-semibold text-sm mb-2" style={{ color: "var(--success)" }}>Ociosos (&lt;50%)</div>
              {(balance?.underused ?? []).length === 0 ? <p className="text-sm muted">Nenhum.</p> : (balance.underused).map((o: any, i: number) => (
                <div key={i} className="flex items-center gap-2 text-sm py-1"><span className="font-medium">{o.name}</span><span className="ml-auto font-bold" style={{ color: "var(--success)" }}>{o.utilization}%</span></div>
              ))}
            </div>
          </div>
          {(balance?.overloaded ?? []).length > 0 && (balance?.underused ?? []).length > 0 && (
            <div className="card p-3 text-sm" style={{ background: "var(--brand-50, transparent)" }}>💡 Sugestão: redistribuir carga de <b>{balance.overloaded[0].name}</b> para <b>{balance.underused[0].name}</b> para equilibrar a malha.</div>
          )}
        </div>
      )}

      {tab === "Simulações de Rede" && (
        <div className="space-y-4">
          <div className="card p-4 flex flex-wrap items-end gap-3">
            <div className="font-semibold text-sm w-full">🌐 Simulação de rede (network design what-if)</div>
            <label className="text-xs muted">Cenário
              <select value={scn} onChange={(e) => setScn(e.target.value)} className="input block mt-0.5 w-52">{SCENARIOS.map(([k, l]) => <option key={k} value={k}>{l}</option>)}</select></label>
            <button onClick={runSim} disabled={busy === "sim"} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">{busy === "sim" ? "Simulando…" : "▶ Simular"}</button>
          </div>
          {lastSim && (
            <div className="card p-4">
              <div className="font-semibold text-sm mb-3">{lastSim.name} — rede atual × cenário</div>
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
          {scenarios.length > 1 && (
            <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Cenário</th><th className="px-3 text-right">Regiões</th><th className="px-3 text-right">Custo</th><th className="px-3 text-right">Lead time</th><th className="px-3">Quando</th></tr></thead>
              <tbody>{scenarios.map((s) => (
                <tr key={s.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-medium">{s.name}</td><td className="px-3 text-right">{s.result?.regions ?? "—"}</td>
                  <td className="px-3 text-right tabular-nums">{s.result?.cost_index ?? "—"}</td><td className="px-3 text-right tabular-nums">{s.result?.lead_time_days ?? "—"}d</td>
                  <td className="px-3 text-xs muted">{String(s.run_at ?? "").slice(0, 16).replace("T", " ")}</td>
                </tr>))}</tbody>
            </table></div>
          )}
        </div>
      )}
    </div>
  );
}
