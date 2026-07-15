"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const stColor = (s: string) => ({ up: "var(--success)", degraded: "var(--warning)", down: "var(--danger)" } as any)[s] ?? "var(--muted)";
const runBadge = (s: string) => ({ success: "badge-success", failed: "badge-danger", running: "badge-warning" } as any)[s] ?? "badge-neutral";
const sevBadge = (s: string) => ({ sev1: "badge-danger", sev2: "badge-danger", sev3: "badge-warning", sev4: "badge-neutral" } as any)[s] ?? "badge-neutral";

const TABS = ["Painel (SRE)", "Serviços", "CI/CD & Deploys", "Incidentes"] as const;
type Tab = typeof TABS[number];

export default function EDOPWorkbench({ dash, services, pipelines, runs, deployments, incidents }: {
  dash: any; services: any[]; pipelines: any[]; runs: any[]; deployments: any[]; incidents: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel (SRE)");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Enterprise+ · Engenharia de Plataforma</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">DevSecOps & Observabilidade</h1>
        <p className="text-sm muted mt-0.5">CI/CD, deploys com rollback, incidentes SRE (MTTR), SLO/error budget e saúde dos serviços. <span className="text-xs">CI/CD real roda no GitHub Actions; aqui o Cargyon monitora e governa.</span></p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel (SRE)" && <Painel dash={dash} />}
      {tab === "Serviços" && <Servicos services={services} />}
      {tab === "CI/CD & Deploys" && <CICD pipelines={pipelines} runs={runs} deployments={deployments} services={services} />}
      {tab === "Incidentes" && <Incidentes incidents={incidents} services={services} />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash }: { dash: any }) {
  const d = dash ?? {}; const slos: any[] = d.slos ?? [];
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <KPI label="Disponibilidade" value={`${d.availability ?? 100}%`} tone={Number(d.availability) >= 99.9 ? "var(--success)" : "var(--warning)"} />
        <KPI label="Serviços saudáveis" value={`${d.services_up ?? 0}/${d.services_total ?? 0}`} tone={d.services_down ? "var(--danger)" : "var(--success)"} />
        <KPI label="Deploys (30d)" value={String(d.deploys_30d ?? 0)} hint="frequência de deploy" />
        <KPI label="MTTR médio" value={`${d.mttr_avg ?? 0} min`} />
        <KPI label="Incidentes abertos" value={String(d.incidents_open ?? 0)} tone={d.incidents_open ? "var(--danger)" : undefined} />
        <KPI label="Sucesso CI/CD" value={`${d.pipeline_success_rate ?? 100}%`} />
        <KPI label="Execuções CI/CD" value={String(d.pipeline_runs ?? 0)} />
        <KPI label="Alertas disparando" value={String(d.alerts_firing ?? 0)} tone={d.alerts_firing ? "var(--warning)" : undefined} />
      </div>
      {slos.length > 0 && (
        <div className="card p-5">
          <div className="font-semibold mb-3">SLOs / Error Budget</div>
          {slos.map((s, i) => (
            <div key={i} className="flex items-center gap-3 mb-2">
              <div className="w-64 text-sm">{s.name}</div>
              <div className="flex-1 h-3 rounded-full overflow-hidden" style={{ background: "var(--surface-3)" }}>
                <div className="h-full rounded-full" style={{ width: `${Math.min(Number(s.current ?? 0), 100)}%`, background: Number(s.current) >= Number(s.target) ? "var(--success)" : "var(--danger)" }} />
              </div>
              <div className="w-32 text-right text-sm tabular-nums">{s.current}% <span className="muted">/ {s.target}%</span></div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function Servicos({ services }: { services: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  async function check() { if (!supabase) return; setBusy(true); await supabase.rpc("health_check", { p_company: COMPANY }); setBusy(false); router.refresh(); }
  const icon = (t: string) => ({ api: "🔌", database: "🗄", realtime: "📡", storage: "📦", functions: "⚡", job: "✦", cache: "⚡", queue: "📥" } as any)[t] ?? "🖥";
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Saúde dos Serviços</div>
        <button onClick={check} disabled={busy} className="btn btn-primary btn-sm">{busy ? "Verificando…" : "↻ Health check"}</button>
      </div>
      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
        {services.map((s) => (
          <div key={s.id} className="card p-4">
            <div className="flex items-center gap-2">
              <span className="text-xl">{icon(s.service_type)}</span>
              <div className="font-semibold text-sm flex-1">{s.name}</div>
              <span className="dot" style={{ background: stColor(s.status) }} />
            </div>
            <div className="grid grid-cols-2 gap-2 mt-3 text-center">
              <div className="surface-2 rounded-lg p-2" style={{ border: "1px solid var(--border)" }}><div className="text-sm font-bold tabular-nums" style={{ color: Number(s.uptime_pct) >= 99.9 ? "var(--success)" : "var(--warning)" }}>{s.uptime_pct}%</div><div className="text-[10px] muted">uptime</div></div>
              <div className="surface-2 rounded-lg p-2" style={{ border: "1px solid var(--border)" }}><div className="text-sm font-bold tabular-nums">{s.response_ms ?? "—"}ms</div><div className="text-[10px] muted">latência</div></div>
            </div>
            <div className="text-[11px] muted mt-2">Status: <span style={{ color: stColor(s.status) }}>{s.status}</span> · {s.last_check_at ? new Date(s.last_check_at).toLocaleTimeString("pt-BR") : "—"}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function CICD({ pipelines, runs, deployments, services }: { pipelines: any[]; runs: any[]; deployments: any[]; services: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  async function run(id: string) { if (!supabase) return; setBusy(id); await supabase.rpc("run_pipeline", { p_company: COMPANY, p_pipeline: id, p_environment: "production", p_git_ref: "main" }); setBusy(null); router.refresh(); }
  async function rollback(id: string) { if (!supabase) return; setBusy(id); await supabase.rpc("rollback_deployment", { p_deployment: id }); setBusy(null); router.refresh(); }
  const pipeName = (id: string) => pipelines.find((p) => p.id === id)?.name ?? "—";
  return (
    <div className="space-y-4">
      <div>
        <div className="font-semibold text-sm mb-2">Pipelines</div>
        <div className="grid md:grid-cols-3 gap-3">
          {pipelines.map((p) => (
            <div key={p.id} className="card p-4">
              <div className="font-semibold text-sm">{p.name}</div>
              <div className="text-xs muted mt-0.5"><code>{p.repo}</code> · {p.runs_count} execuções</div>
              <div className="flex gap-1 mt-2">{(p.stages ?? []).map((s: string) => <span key={s} className="badge badge-neutral">{s}</span>)}</div>
              <button onClick={() => run(p.id)} disabled={busy === p.id} className="btn btn-primary btn-sm w-full mt-3">{busy === p.id ? "Executando…" : "▶ Rodar pipeline"}</button>
            </div>
          ))}
        </div>
      </div>
      <div className="grid lg:grid-cols-2 gap-4">
        <div>
          <div className="font-semibold text-sm mb-2">Execuções recentes</div>
          {runs.length === 0 ? <p className="text-sm muted">Nenhuma execução.</p> : (
            <div className="card p-0 overflow-x-auto"><table className="tbl">
              <thead><tr><th>Pipeline</th><th>#</th><th>Status</th><th className="text-right">Duração</th><th className="text-right">Cobertura</th></tr></thead>
              <tbody>{runs.slice(0, 12).map((r) => (<tr key={r.id}><td className="text-xs">{pipeName(r.pipeline_id)}</td><td className="tabular-nums">{r.run_number}</td><td><span className={`badge ${runBadge(r.status)}`}>{r.status}</span></td><td className="text-right tabular-nums">{r.duration_s}s</td><td className="text-right tabular-nums">{r.coverage_pct ?? "—"}%</td></tr>))}</tbody>
            </table></div>
          )}
        </div>
        <div>
          <div className="font-semibold text-sm mb-2">Deploys</div>
          {deployments.length === 0 ? <p className="text-sm muted">Nenhum deploy.</p> : (
            <div className="card p-0 overflow-x-auto"><table className="tbl">
              <thead><tr><th>Serviço</th><th>Versão</th><th>Ambiente</th><th>Status</th><th></th></tr></thead>
              <tbody>{deployments.slice(0, 12).map((d) => (
                <tr key={d.id}><td className="text-xs">{d.service_name ?? "—"}</td><td className="tabular-nums">{d.release_version}</td><td className="text-xs">{d.environment}</td><td><span className={`badge ${d.status === "deployed" ? "badge-success" : d.status === "rolled_back" ? "badge-danger" : "badge-neutral"}`}>{d.status}</span></td><td className="text-right">{d.status === "deployed" && !d.rollback_of && <button onClick={() => rollback(d.id)} disabled={busy === d.id} className="text-xs font-semibold hover:underline" style={{ color: "var(--warning)" }}>rollback</button>}</td></tr>
              ))}</tbody>
            </table></div>
          )}
        </div>
      </div>
    </div>
  );
}

function Incidentes({ incidents, services }: { incidents: any[]; services: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [f, setF] = useState({ service: "", severity: "sev3", title: "" });
  const [busy, setBusy] = useState<string | null>(null);
  const svcName = (id: string) => services.find((s) => s.id === id)?.name ?? "—";
  async function open() {
    if (!supabase || !f.title) return;
    setBusy("open");
    await supabase.rpc("open_ops_incident", { p_company: COMPANY, p_service: f.service || null, p_severity: f.severity, p_title: f.title, p_commander: null });
    setBusy(null); setF({ service: "", severity: "sev3", title: "" }); router.refresh();
  }
  async function resolve(id: string) { if (!supabase) return; setBusy(id); await supabase.rpc("resolve_ops_incident", { p_incident: id, p_root_cause: "resolvido pela tela" }); setBusy(null); router.refresh(); }
  return (
    <div className="space-y-3">
      <div className="card p-4 grid md:grid-cols-4 gap-3 items-end">
        <div><label className="label">Serviço</label><select value={f.service} onChange={(e) => setF((p) => ({ ...p, service: e.target.value }))} className="select"><option value="">—</option>{services.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}</select></div>
        <div><label className="label">Severidade</label><select value={f.severity} onChange={(e) => setF((p) => ({ ...p, severity: e.target.value }))} className="select"><option value="sev1">SEV1 (crítico)</option><option value="sev2">SEV2 (alto)</option><option value="sev3">SEV3 (médio)</option><option value="sev4">SEV4 (baixo)</option></select></div>
        <div><label className="label">Título</label><input value={f.title} onChange={(e) => setF((p) => ({ ...p, title: e.target.value }))} className="input" /></div>
        <button onClick={open} disabled={busy === "open" || !f.title} className="btn btn-danger btn-sm">Abrir incidente</button>
      </div>
      {incidents.length === 0 ? <p className="text-sm muted px-1">🟢 Nenhum incidente registrado.</p> : (
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Severidade</th><th>Título</th><th>Serviço</th><th>Status</th><th className="text-right">MTTR</th><th></th></tr></thead>
          <tbody>{incidents.map((i) => (
            <tr key={i.id}>
              <td><span className={`badge ${sevBadge(i.severity)}`}>{(i.severity as string).toUpperCase()}</span></td>
              <td>{i.title}</td><td className="text-xs muted">{svcName(i.service_id)}</td>
              <td><span className={`badge ${i.status === "open" ? "badge-danger" : "badge-success"}`}>{i.status === "open" ? "aberto" : "resolvido"}</span></td>
              <td className="text-right tabular-nums">{i.mttr_minutes != null ? i.mttr_minutes + " min" : "—"}</td>
              <td className="text-right">{i.status === "open" && <button onClick={() => resolve(i.id)} disabled={busy === i.id} className="btn btn-sm">Resolver</button>}</td>
            </tr>
          ))}</tbody>
        </table></div>
      )}
    </div>
  );
}
