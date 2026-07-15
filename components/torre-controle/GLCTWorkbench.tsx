"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel Situacional", "Incidentes", "Correlação de Eventos", "Playbooks"] as const;

const SIT_TILES: { key: string; label: string; crit?: boolean }[] = [
  { key: "insights_critical", label: "Sinais críticos", crit: true },
  { key: "insights_warning", label: "Sinais de alerta" },
  { key: "incidents_open", label: "Incidentes abertos", crit: true },
  { key: "crises_active", label: "Crises ativas", crit: true },
  { key: "intl_delayed", label: "Embarques atrasados" },
  { key: "customs_retained", label: "Cargas retidas (aduana)", crit: true },
  { key: "cold_broken", label: "Cadeia fria rompida", crit: true },
  { key: "twin_bottlenecks", label: "Gargalos (twin)" },
  { key: "yard_queue", label: "Fila no pátio" },
  { key: "docks_blocked", label: "Docas bloqueadas" },
  { key: "deliveries_failed", label: "Entregas falhas" },
  { key: "deliveries_pending", label: "Entregas pendentes" },
  { key: "volumes_in_transit", label: "Volumes em trânsito" },
  { key: "carrier_occurrences", label: "Ocorrências transportadora" },
];
const sevColor = (s: string) => ({ sev1: "#dc2626", sev2: "#ea580c", sev3: "#d97706", sev4: "#64748b" } as any)[s] ?? "#64748b";
const stColor = (s: string) => ({ open: "#dc2626", investigating: "#ea580c", mitigating: "#d97706", resolved: "#16a34a" } as any)[s] ?? "#64748b";

export default function GLCTWorkbench({ sit, dash, incidents, events, playbooks, actions }: {
  sit: any; dash: any; incidents: any[]; events: any[]; playbooks: any[]; actions: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel Situacional");
  const [busy, setBusy] = useState("");
  const [pbSel, setPbSel] = useState<Record<string, string>>({});
  const actByInc = useMemo(() => { const m: Record<string, any[]> = {}; for (const a of actions) (m[a.incident_id] ??= []).push(a); return m; }, [actions]);

  async function act(fn: () => PromiseLike<any>, key: string) {
    if (!supabase) return; setBusy(key);
    const { error } = await fn(); setBusy("");
    if (error) alert("Erro: " + error.message); else router.refresh();
  }
  const correlate = () => act(() => supabase!.rpc("correlate_events", { p_company: COMPANY }), "corr");
  const applyPb = (inc: string) => { const pb = pbSel[inc] || playbooks[0]?.id; if (pb) act(() => supabase!.rpc("apply_playbook", { p_company: COMPANY, p_incident: inc, p_playbook: pb }), inc); };
  const resolve = (inc: string) => act(() => supabase!.rpc("resolve_incident", { p_company: COMPANY, p_incident: inc, p_root_cause: "Resolvido pela torre" }), inc);

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🗼</div>
        <div>
          <h1 className="text-xl font-bold">Torre de Controle — GLCT</h1>
          <p className="text-sm muted">Centro mundial de operações: visão ponta a ponta · correlação · incidentes · playbooks · orquestração</p>
        </div>
        <button onClick={correlate} disabled={busy === "corr"} className="ml-auto px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">{busy === "corr" ? "Correlacionando…" : "⚡ Correlacionar eventos"}</button>
      </div>

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel Situacional" && (
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3">
          {SIT_TILES.map((t) => {
            const v = sit?.[t.key] ?? 0;
            const on = Number(v) > 0;
            return (
              <div key={t.key} className="card p-4" style={{ borderTop: `3px solid ${on && t.crit ? "var(--danger)" : on ? "var(--warning)" : "var(--success)"}` }}>
                <div className="text-3xl font-extrabold tabular-nums" style={{ color: on && t.crit ? "var(--danger)" : on ? "var(--warning)" : "var(--muted)" }}>{v}</div>
                <div className="text-xs muted mt-1">{t.label}</div>
              </div>
            );
          })}
        </div>
      )}

      {tab === "Incidentes" && (
        <div className="space-y-3">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <div className="card p-4"><div className="text-2xl font-bold" style={{ color: dash.sev1 ? "var(--danger)" : undefined }}>{dash.sev1 ?? 0}</div><div className="text-xs muted">SEV1</div></div>
            <div className="card p-4"><div className="text-2xl font-bold" style={{ color: dash.sev2 ? "var(--warning)" : undefined }}>{dash.sev2 ?? 0}</div><div className="text-xs muted">SEV2</div></div>
            <div className="card p-4"><div className="text-2xl font-bold">{dash.incidents_open ?? 0}</div><div className="text-xs muted">Abertos</div></div>
            <div className="card p-4"><div className="text-2xl font-bold">{dash.avg_mttr_min != null ? `${dash.avg_mttr_min}m` : "—"}</div><div className="text-xs muted">MTTR médio</div></div>
          </div>
          {incidents.length === 0 ? <p className="text-sm muted px-1">Nenhum incidente. Use "Correlacionar eventos" para gerar dos clusters críticos.</p> : incidents.map((i) => {
            const acts = actByInc[i.id] ?? [];
            return (
              <div key={i.id} className="card p-4" style={{ borderLeft: `3px solid ${sevColor(i.severity)}` }}>
                <div className="flex flex-wrap items-center gap-2">
                  <span className="badge" style={{ background: sevColor(i.severity), color: "#fff" }}>{i.severity.toUpperCase()}</span>
                  <span className="font-semibold text-sm">{i.code}</span>
                  <span className="text-sm">{i.title ?? i.incident_type}</span>
                  <span className="badge" style={{ background: stColor(i.status), color: "#fff" }}>{i.status}</span>
                  <span className="text-xs muted ml-auto">{i.incident_type} · {i.source_module ?? ""}{i.mttr_min != null ? ` · MTTR ${i.mttr_min}m` : ""}</span>
                </div>
                {acts.length > 0 && (
                  <ul className="mt-2 space-y-1">
                    {acts.map((a: any) => (
                      <li key={a.id} className="text-xs flex items-center gap-2"><span className="badge badge-neutral text-[10px]">{a.action_type}</span>{a.description}</li>
                    ))}
                  </ul>
                )}
                {i.status !== "resolved" && (
                  <div className="flex flex-wrap items-end gap-2 mt-3">
                    <select value={pbSel[i.id] ?? ""} onChange={(e) => setPbSel({ ...pbSel, [i.id]: e.target.value })} className="input w-auto text-xs">
                      <option value="">Playbook…</option>{playbooks.map((p) => <option key={p.id} value={p.id}>{p.name ?? p.code}</option>)}
                    </select>
                    <button onClick={() => applyPb(i.id)} disabled={busy === i.id} className="px-3 py-2 rounded-lg card text-sm">📋 aplicar playbook</button>
                    <button onClick={() => resolve(i.id)} disabled={busy === i.id} className="px-3 py-2 rounded-lg bg-green-600 text-white text-sm font-semibold">✓ resolver</button>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}

      {tab === "Correlação de Eventos" && (
        events.length === 0 ? <p className="text-sm muted px-1">Sem clusters. Clique em "⚡ Correlacionar eventos".</p> : (
          <div className="space-y-2">
            <p className="text-sm muted">Eventos agrupados por tipo × severidade (a partir da inteligência consolidada do LAIOS).</p>
            {events.map((e) => (
              <div key={e.id} className="card p-3 flex items-center gap-3">
                <div className="grid place-items-center rounded-lg text-white font-bold text-lg" style={{ background: e.severity === "critical" ? "var(--danger)" : e.severity === "warning" ? "var(--warning)" : "var(--muted)", width: 44, height: 44 }}>{e.cluster_size}</div>
                <div>
                  <div className="font-semibold text-sm">{e.title ?? e.event_kind}</div>
                  <div className="text-xs muted">{e.event_kind} · {e.severity} · chave {e.correlation_key}</div>
                </div>
                <span className="badge badge-neutral ml-auto">{e.source_module}</span>
              </div>
            ))}
          </div>
        )
      )}

      {tab === "Playbooks" && (
        <div className="grid md:grid-cols-2 gap-3">
          {playbooks.length === 0 ? <p className="text-sm muted px-1">Nenhum playbook.</p> : playbooks.map((p) => (
            <div key={p.id} className="card p-4">
              <div className="flex items-center gap-2">
                <span className="font-semibold text-sm">{p.name ?? p.code}</span>
                <span className="badge badge-neutral ml-auto">{p.playbook_type}</span>
              </div>
              <div className="text-xs muted mt-1">SLA {p.sla_minutes ?? "—"} min · escala p/ {p.escalation_to ?? "—"}</div>
              <ol className="mt-2 space-y-1 list-decimal list-inside">
                {(Array.isArray(p.steps) ? p.steps : []).map((s: any, idx: number) => (
                  <li key={idx} className="text-xs"><span className="badge badge-neutral text-[10px] mr-1">{s.action_type}</span>{s.step}</li>
                ))}
              </ol>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
