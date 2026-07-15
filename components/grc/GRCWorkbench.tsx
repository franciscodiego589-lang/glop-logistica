"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const levelColor = (l: string) => ({ critical: "var(--danger)", high: "var(--warning)", medium: "#eab308", low: "var(--success)" } as any)[l] ?? "var(--muted)";
const cellColor = (crit: number) => crit >= 15 ? "var(--danger)" : crit >= 8 ? "var(--warning)" : crit >= 4 ? "#eab308" : "var(--success)";

const TABS = ["Painel", "Matriz de Risco", "Controles Internos", "Segregação de Funções (SoD)", "Compliance", "Auditorias & Políticas"] as const;
type Tab = typeof TABS[number];

export default function GRCWorkbench({ dash, matrix, controls, sods, compliance, requirements, audits, policies }: {
  dash: any; matrix: any[]; controls: any[]; sods: any[]; compliance: any[]; requirements: any[]; audits: any[]; policies: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Enterprise+ · Governança, Riscos & Compliance</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">GRC — Governança, Riscos & Compliance</h1>
        <p className="text-sm muted mt-0.5">Matriz de risco, controles internos, segregação de funções (SoD), compliance (LGPD/ISO/BPF), auditorias e planos de ação.</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} compliance={compliance} />}
      {tab === "Matriz de Risco" && <Matriz matrix={matrix} />}
      {tab === "Controles Internos" && <Controles controls={controls} />}
      {tab === "Segregação de Funções (SoD)" && <SoD sods={sods} />}
      {tab === "Compliance" && <Compliance compliance={compliance} requirements={requirements} />}
      {tab === "Auditorias & Políticas" && <AuditPol audits={audits} policies={policies} />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash, compliance }: { dash: any; compliance: any[] }) {
  const d = dash ?? {};
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <KPI label="Riscos ativos" value={String(d.risks ?? 0)} hint={`${d.risks_critical ?? 0} críticos · ${d.risks_high ?? 0} altos`} tone={d.risks_critical ? "var(--danger)" : undefined} />
        <KPI label="Controles efetivos" value={`${d.controls_effective ?? 0}/${d.controls ?? 0}`} tone="var(--success)" />
        <KPI label="Violações de SoD" value={String(d.sod_violations ?? 0)} tone={d.sod_violations ? "var(--danger)" : "var(--success)"} />
        <KPI label="Nível de compliance" value={`${d.compliance ?? 0}%`} tone={Number(d.compliance) >= 80 ? "var(--success)" : "var(--warning)"} />
        <KPI label="Planos de ação" value={String(d.action_plans_open ?? 0)} hint={`${d.action_plans_overdue ?? 0} atrasados`} />
        <KPI label="Auditorias" value={String(d.audits ?? 0)} />
        <KPI label="Políticas" value={String(d.policies ?? 0)} hint={`${d.policies_expired ?? 0} a revisar`} />
      </div>
      <div className="card p-5">
        <div className="font-semibold mb-3">Conformidade por framework</div>
        {compliance.length === 0 ? <p className="text-sm muted">Sem requisitos cadastrados.</p> : compliance.map((f) => (
          <div key={f.framework} className="flex items-center gap-3 mb-2">
            <div className="w-24 text-sm font-medium">{f.framework}</div>
            <div className="flex-1 h-3 rounded-full overflow-hidden" style={{ background: "var(--surface-3)" }}>
              <div className="h-full rounded-full" style={{ width: `${f.level}%`, background: Number(f.level) >= 80 ? "var(--success)" : Number(f.level) >= 60 ? "var(--warning)" : "var(--danger)" }} />
            </div>
            <div className="w-24 text-right text-sm tabular-nums">{f.compliant}/{f.total} · {f.level}%</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function Matriz({ matrix }: { matrix: any[] }) {
  // heat map 5x5: linhas = impacto (5→1), colunas = probabilidade (1→5)
  const cell = (p: number, i: number) => matrix.filter((r) => r.probability === p && r.impact === i);
  return (
    <div className="space-y-4">
      <div className="card p-5 overflow-x-auto">
        <div className="font-semibold mb-3">Matriz de Risco (Probabilidade × Impacto)</div>
        <div className="inline-grid gap-1" style={{ gridTemplateColumns: "auto repeat(5, 64px)" }}>
          <div />
          {[1, 2, 3, 4, 5].map((p) => <div key={p} className="text-center text-xs muted font-semibold pb-1">P{p}</div>)}
          {[5, 4, 3, 2, 1].map((i) => (
            <>
              <div key={"lbl" + i} className="text-xs muted font-semibold pr-2 grid place-items-center">I{i}</div>
              {[1, 2, 3, 4, 5].map((p) => {
                const rs = cell(p, i); const crit = p * i;
                return (
                  <div key={p + "-" + i} className="h-16 rounded-lg grid place-items-center relative" style={{ background: cellColor(crit), opacity: rs.length ? 1 : 0.28 }} title={rs.map((r) => r.name).join("\n")}>
                    <span className="text-white font-bold text-lg">{rs.length || ""}</span>
                  </div>
                );
              })}
            </>
          ))}
        </div>
        <div className="flex gap-3 mt-3 text-xs muted">
          <span className="flex items-center gap-1"><span className="w-3 h-3 rounded" style={{ background: "var(--success)" }} /> Baixo</span>
          <span className="flex items-center gap-1"><span className="w-3 h-3 rounded" style={{ background: "#eab308" }} /> Médio</span>
          <span className="flex items-center gap-1"><span className="w-3 h-3 rounded" style={{ background: "var(--warning)" }} /> Alto</span>
          <span className="flex items-center gap-1"><span className="w-3 h-3 rounded" style={{ background: "var(--danger)" }} /> Crítico</span>
        </div>
      </div>
      <div className="card p-0 overflow-x-auto">
        <table className="tbl">
          <thead><tr><th>Risco</th><th>Categoria</th><th>Resp.</th><th className="text-center">Prob.</th><th className="text-center">Impacto</th><th className="text-center">Criticidade</th><th>Nível</th></tr></thead>
          <tbody>{matrix.map((r, idx) => (
            <tr key={idx}><td className="font-medium">{r.name}</td><td className="text-xs muted">{r.category}</td><td className="text-xs muted">{r.owner}</td><td className="text-center tabular-nums">{r.probability}</td><td className="text-center tabular-nums">{r.impact}</td><td className="text-center tabular-nums font-bold">{r.criticality}</td><td><span className="badge" style={{ background: levelColor(r.level), color: "#fff" }}>{r.level}</span></td></tr>
          ))}</tbody>
        </table>
      </div>
    </div>
  );
}

function Controles({ controls }: { controls: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  async function test(id: string, eff: string) {
    if (!supabase) return;
    await supabase.from("internal_controls").update({ effectiveness: eff, last_test_date: new Date().toISOString().slice(0, 10), next_test_date: new Date(Date.now() + 30 * 864e5).toISOString().slice(0, 10) }).eq("id", id);
    router.refresh();
  }
  const TYPE: Record<string, string> = { preventive: "Preventivo", detective: "Detectivo", corrective: "Corretivo" };
  return (
    <div className="card p-0 overflow-x-auto">
      <table className="tbl">
        <thead><tr><th>Controle</th><th>Tipo</th><th>Frequência</th><th>Efetividade</th><th>Próx. teste</th><th></th></tr></thead>
        <tbody>{controls.map((c) => (
          <tr key={c.id}>
            <td className="font-medium">{c.name}</td><td>{TYPE[c.control_type] ?? c.control_type}</td><td className="text-xs muted">{c.frequency}</td>
            <td><span className={`badge ${c.effectiveness === "effective" ? "badge-success" : c.effectiveness === "ineffective" ? "badge-danger" : "badge-neutral"}`}>{c.effectiveness === "effective" ? "efetivo" : c.effectiveness === "ineffective" ? "inefetivo" : "não testado"}</span></td>
            <td className="text-xs tabular-nums">{c.next_test_date ?? "—"}</td>
            <td className="text-right whitespace-nowrap"><button onClick={() => test(c.id, "effective")} className="text-xs text-brand-600 hover:underline mr-2">✓ efetivo</button><button onClick={() => test(c.id, "ineffective")} className="text-xs hover:underline" style={{ color: "var(--danger)" }}>✗ falho</button></td>
          </tr>
        ))}</tbody>
      </table>
    </div>
  );
}

function SoD({ sods }: { sods: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  async function check() { if (!supabase) return; setBusy(true); await supabase.rpc("check_sod_violations", { p_company: COMPANY }); setBusy(false); router.refresh(); }
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Regras de Segregação de Funções</div>
        <button onClick={check} disabled={busy} className="btn btn-primary btn-sm">{busy ? "Analisando…" : "🔍 Verificar violações"}</button>
      </div>
      {sods.map((s) => (
        <div key={s.id} className="card p-4 flex items-center gap-3" style={{ borderLeft: `3px solid ${s.last_violations > 0 ? "var(--danger)" : "var(--success)"}` }}>
          <div className="flex-1">
            <div className="font-semibold text-sm">{s.name}</div>
            <div className="text-xs muted">{s.description}</div>
            <div className="text-[11px] muted mt-1"><code>{s.permission_a}</code> ⊗ <code>{s.permission_b}</code></div>
          </div>
          <span className={`badge ${s.last_violations > 0 ? "badge-danger" : "badge-success"}`}>{s.last_violations > 0 ? s.last_violations + " violação(ões)" : "conforme"}</span>
        </div>
      ))}
    </div>
  );
}

function Compliance({ compliance, requirements }: { compliance: any[]; requirements: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  async function toggle(id: string, status: string) {
    if (!supabase) return;
    await supabase.from("compliance_requirements").update({ status: status === "compliant" ? "gap" : "compliant" }).eq("id", id);
    router.refresh();
  }
  const byFw = useMemo(() => { const m: Record<string, any[]> = {}; requirements.forEach((r) => { (m[r.framework] = m[r.framework] || []).push(r); }); return Object.entries(m); }, [requirements]);
  return (
    <div className="space-y-4">
      {byFw.map(([fw, reqs]) => {
        const cf = compliance.find((c) => c.framework === fw);
        return (
          <div key={fw} className="card p-4">
            <div className="flex items-center justify-between mb-2">
              <div className="font-semibold">{fw}</div>
              {cf && <span className="text-sm font-bold" style={{ color: Number(cf.level) >= 80 ? "var(--success)" : "var(--warning)" }}>{cf.level}% conforme</span>}
            </div>
            <div className="space-y-1.5">
              {reqs.map((r) => (
                <div key={r.id} className="flex items-center gap-2 text-sm">
                  <button onClick={() => toggle(r.id, r.status)} className={`badge ${r.status === "compliant" ? "badge-success" : "badge-danger"}`}>{r.status === "compliant" ? "✓ conforme" : "gap"}</button>
                  <span className="flex-1">{r.requirement}</span>
                </div>
              ))}
            </div>
          </div>
        );
      })}
    </div>
  );
}

function AuditPol({ audits, policies }: { audits: any[]; policies: any[] }) {
  return (
    <div className="grid lg:grid-cols-2 gap-4">
      <div>
        <div className="font-semibold text-sm mb-2">Auditorias planejadas</div>
        {audits.length === 0 ? <p className="text-sm muted">—</p> : (
          <div className="card p-0 overflow-x-auto"><table className="tbl">
            <thead><tr><th>Auditoria</th><th>Tipo</th><th>Framework</th><th>Data</th><th>Status</th></tr></thead>
            <tbody>{audits.map((a) => (<tr key={a.id}><td className="font-medium">{a.name}</td><td className="text-xs">{a.audit_type}</td><td className="text-xs muted">{a.framework}</td><td className="text-xs tabular-nums">{a.planned_date}</td><td><span className="badge badge-warning">{a.status}</span></td></tr>))}</tbody>
          </table></div>
        )}
      </div>
      <div>
        <div className="font-semibold text-sm mb-2">Políticas corporativas</div>
        {policies.length === 0 ? <p className="text-sm muted">—</p> : (
          <div className="card p-0 overflow-x-auto"><table className="tbl">
            <thead><tr><th>Política</th><th>Framework</th><th>Revisão</th><th>Status</th></tr></thead>
            <tbody>{policies.map((p) => (<tr key={p.id}><td className="font-medium">{p.name}</td><td className="text-xs muted">{p.framework}</td><td className="text-xs tabular-nums">{p.review_date}</td><td><span className="badge badge-success">{p.status}</span></td></tr>))}</tbody>
          </table></div>
        )}
      </div>
    </div>
  );
}
