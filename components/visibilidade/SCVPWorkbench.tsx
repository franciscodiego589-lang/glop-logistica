"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Rastreios", "Exceções", "Compartilhamentos"] as const;
const MILESTONES: [string, string][] = [["created", "Criado"], ["picked_up", "Coletado"], ["at_warehouse", "No armazém"], ["at_hub", "No hub"], ["departed", "Embarcado"], ["in_transit", "Em trânsito"], ["arrived", "Chegou"], ["customs", "Aduana"], ["out_for_delivery", "Saiu p/ entrega"], ["delivered", "Entregue"], ["returned", "Devolvido"]];
const hColor = (h: string) => ({ on_track: "#16a34a", at_risk: "#d97706", delayed: "#dc2626", exception: "#7c3aed", delivered: "#15803d" } as any)[h] ?? "#64748b";
const hLabel = (h: string) => ({ on_track: "No prazo", at_risk: "Em risco", delayed: "Atrasado", exception: "Exceção", delivered: "Entregue" } as any)[h] ?? h;
const dt = (s: any) => s ? new Date(s).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", hour: "2-digit", minute: "2-digit" }) : "—";

export default function SCVPWorkbench({ dash, shipments, events, exceptions, shares }: {
  dash: any; shipments: any[]; events: any[]; exceptions: any[]; shares: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState("");
  const [ms, setMs] = useState<Record<string, string>>({});
  const d = dash ?? {};
  const evByShip = useMemo(() => { const m: Record<string, any[]> = {}; for (const e of events) (m[e.scv_shipment_id] ??= []).push(e); return m; }, [events]);

  async function act(fn: () => PromiseLike<any>, key: string) {
    if (!supabase) return; setBusy(key);
    const { error } = await fn(); setBusy("");
    if (error) alert("Erro: " + error.message); else router.refresh();
  }
  const ingest = (sh: string) => act(() => supabase!.rpc("ingest_scv_event", { p_company: COMPANY, p_scv: sh, p_event_code: ms[sh] || "in_transit", p_source: "manual", p_location: null, p_lat: null, p_lng: null, p_at: null }), sh);
  const share = (sh: string) => act(() => supabase!.rpc("create_scv_share", { p_company: COMPANY, p_scv: sh, p_party_type: "customer", p_party_ref: "cliente", p_hours: 168 }), sh + "s");
  const detect = () => act(() => supabase!.rpc("detect_scv_exceptions", { p_company: COMPANY }), "det");

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🛰</div>
        <div>
          <h1 className="text-xl font-bold">Visibilidade da Cadeia — SCVP</h1>
          <p className="text-sm muted">Rastreamento ponta a ponta · eventos normalizados · ETA inteligente · exceções · compartilhamento</p>
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
          <KpiCard label="Rastreios" value={d.shipments ?? 0} accent />
          <div className="card p-4">
            <div className="text-xs uppercase tracking-wide muted font-semibold">Visibilidade no prazo</div>
            <div className="mt-2 text-2xl font-bold" style={{ color: d.visibility_pct >= 90 ? "var(--success)" : d.visibility_pct != null ? "var(--warning)" : undefined }}>{d.visibility_pct != null ? `${d.visibility_pct}%` : "—"}</div>
          </div>
          <KpiCard label="Em risco" value={d.at_risk ?? 0} tone={d.at_risk ? "warning" : undefined} />
          <KpiCard label="Atrasados" value={d.delayed ?? 0} tone={d.delayed ? "danger" : undefined} />
          <KpiCard label="Eventos capturados" value={d.events_captured ?? 0} />
          <KpiCard label="Posições GPS" value={d.positions ?? 0} />
          <KpiCard label="Exceções abertas" value={d.exceptions_open ?? 0} tone={d.exceptions_open ? "warning" : undefined} />
          <KpiCard label="Confiança ETA média" value={d.avg_eta_confidence != null ? `${d.avg_eta_confidence}%` : "—"} />
        </div>
      )}

      {tab === "Rastreios" && (
        <div className="space-y-3">
          {shipments.length === 0 ? <p className="text-sm muted px-1">Nenhum rastreio.</p> : shipments.map((s) => {
            const ev = (evByShip[s.id] ?? []).slice().sort((a: any, b: any) => String(a.event_at).localeCompare(String(b.event_at)));
            const late = s.planned_eta && s.predicted_eta && new Date(s.predicted_eta) > new Date(s.planned_eta);
            return (
              <div key={s.id} className="card p-4" style={{ borderLeft: `3px solid ${hColor(s.health)}` }}>
                <div className="flex flex-wrap items-center gap-2">
                  <span className="font-semibold text-sm">{s.code}</span>
                  <span className="badge" style={{ background: hColor(s.health), color: "#fff" }}>{hLabel(s.health)}</span>
                  <span className="text-xs muted">{s.origin} → {s.destination} · {s.modal ?? ""}</span>
                  <span className="text-xs muted ml-auto">{MILESTONES.find(([k]) => k === s.current_status)?.[1] ?? s.current_status}{s.current_location ? ` · ${s.current_location}` : ""}</span>
                </div>
                <div className="flex items-center gap-3 mt-2">
                  <div className="flex-1 h-2 rounded-full bg-black/10 dark:bg-white/10 overflow-hidden">
                    <div className="h-full" style={{ width: `${s.pct_complete}%`, background: hColor(s.health) }} />
                  </div>
                  <span className="text-xs tabular-nums font-semibold">{s.pct_complete}%</span>
                </div>
                <div className="flex flex-wrap gap-4 mt-2 text-xs">
                  <div>ETA planejado: <b>{dt(s.planned_eta)}</b></div>
                  <div style={{ color: late ? "var(--danger)" : "var(--success)" }}>ETA previsto: <b>{dt(s.predicted_eta)}</b>{s.eta_confidence != null ? ` (${s.eta_confidence}% conf.)` : ""}</div>
                </div>
                {ev.length > 0 && (
                  <ol className="flex flex-wrap gap-2 mt-3">
                    {ev.map((e: any) => (
                      <li key={e.id} className="flex items-center gap-1 text-xs rounded-lg px-2 py-1 card">
                        <span className="h-2 w-2 rounded-full" style={{ background: "var(--brand)" }} />
                        {MILESTONES.find(([k]) => k === e.event_code)?.[1] ?? e.event_code}
                        <span className="muted">{dt(e.event_at)}</span>
                      </li>
                    ))}
                  </ol>
                )}
                <div className="flex flex-wrap items-end gap-2 mt-3">
                  <select value={ms[s.id] ?? "in_transit"} onChange={(e) => setMs({ ...ms, [s.id]: e.target.value })} className="input w-auto text-xs">
                    {MILESTONES.map(([k, l]) => <option key={k} value={k}>{l}</option>)}
                  </select>
                  <button onClick={() => ingest(s.id)} disabled={busy === s.id} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">+ registrar evento</button>
                  <button onClick={() => share(s.id)} disabled={busy === s.id + "s"} className="px-3 py-2 rounded-lg card text-sm">🔗 compartilhar</button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {tab === "Exceções" && (
        <div className="space-y-3">
          <button onClick={detect} disabled={busy === "det"} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">{busy === "det" ? "Analisando…" : "🔍 Detectar exceções"}</button>
          {exceptions.length === 0 ? <p className="text-sm muted px-1">Nenhuma exceção detectada.</p> : (
            <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Tipo</th><th className="px-3">Severidade</th><th className="px-3">Detalhe</th><th className="px-3">Detectada</th><th className="px-3">Status</th></tr></thead>
              <tbody>{exceptions.map((e) => (
                <tr key={e.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-medium">{e.exception_type}</td>
                  <td className="px-3"><span className={`badge ${e.severity === "critical" ? "badge-danger" : e.severity === "high" ? "badge-warning" : "badge-neutral"}`}>{e.severity}</span></td>
                  <td className="px-3 text-xs muted">{e.details ?? "—"}</td><td className="px-3 text-xs">{dt(e.detected_at)}</td>
                  <td className="px-3"><span className={`badge ${e.status === "resolved" ? "badge-success" : "badge-neutral"}`}>{e.status}</span></td>
                </tr>))}</tbody>
            </table></div>
          )}
        </div>
      )}

      {tab === "Compartilhamentos" && (
        shares.length === 0 ? <p className="text-sm muted px-1">Nenhum link de rastreio compartilhado. Use "🔗 compartilhar" num rastreio.</p> : (
          <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Parte</th><th className="px-3">Referência</th><th className="px-3">Token</th><th className="px-3">Expira</th><th className="px-3">Status</th></tr></thead>
            <tbody>{shares.map((s) => (
              <tr key={s.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                <td className="py-2 px-3 font-medium">{s.party_type}</td><td className="px-3 text-xs">{s.party_ref ?? "—"}</td>
                <td className="px-3 font-mono text-xs">{(s.share_token ?? "").slice(0, 20)}…</td><td className="px-3 text-xs">{dt(s.expires_at)}</td>
                <td className="px-3"><span className="badge badge-success">{s.status}</span></td>
              </tr>))}</tbody>
          </table></div>
        )
      )}
    </div>
  );
}
