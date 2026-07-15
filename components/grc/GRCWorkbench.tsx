"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const levelColor = (l: string) => ({ critical: "var(--danger)", high: "var(--warning)", medium: "#eab308", low: "var(--success)" } as any)[l] ?? "var(--muted)";
const cellColor = (crit: number) => crit >= 15 ? "var(--danger)" : crit >= 8 ? "var(--warning)" : crit >= 4 ? "#eab308" : "var(--success)";

const TABS = ["Painel", "Matriz de Risco", "KRIs", "Controles Internos", "Segregação de Funções (SoD)", "Obrigações", "Compliance", "Governança", "Evidências", "Auditorias & Políticas"] as const;
type Tab = typeof TABS[number];

export default function GRCWorkbench({ dash, matrix, controls, sods, compliance, requirements, audits, policies, gov, kris, obligations, bodies, delegations, evidence }: {
  dash: any; matrix: any[]; controls: any[]; sods: any[]; compliance: any[]; requirements: any[]; audits: any[]; policies: any[];
  gov: any; kris: any[]; obligations: any[]; bodies: any[]; delegations: any[]; evidence: any[];
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

      {tab === "Painel" && <Painel dash={dash} compliance={compliance} gov={gov} />}
      {tab === "Matriz de Risco" && <Matriz matrix={matrix} />}
      {tab === "KRIs" && <KRIs kris={kris} />}
      {tab === "Controles Internos" && <Controles controls={controls} />}
      {tab === "Segregação de Funções (SoD)" && <SoD sods={sods} />}
      {tab === "Obrigações" && <Obrigacoes obligations={obligations} />}
      {tab === "Compliance" && <Compliance compliance={compliance} requirements={requirements} />}
      {tab === "Governança" && <Governanca bodies={bodies} delegations={delegations} />}
      {tab === "Evidências" && <Evidencias evidence={evidence} />}
      {tab === "Auditorias & Políticas" && <AuditPol audits={audits} policies={policies} />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash, compliance, gov }: { dash: any; compliance: any[]; gov: any }) {
  const d = dash ?? {}; const g = gov ?? {};
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <KPI label="Riscos ativos" value={String(d.risks ?? 0)} hint={`${d.risks_critical ?? 0} críticos · ${d.risks_high ?? 0} altos`} tone={d.risks_critical ? "var(--danger)" : undefined} />
        <KPI label="KRIs no vermelho" value={String(g.kri_red ?? 0)} hint={`${g.kri_amber ?? 0} em alerta · ${g.kri_total ?? 0} total`} tone={g.kri_red ? "var(--danger)" : "var(--success)"} />
        <KPI label="Controles efetivos" value={`${d.controls_effective ?? 0}/${d.controls ?? 0}`} tone="var(--success)" />
        <KPI label="Violações de SoD" value={String(d.sod_violations ?? 0)} tone={d.sod_violations ? "var(--danger)" : "var(--success)"} />
        <KPI label="Nível de compliance" value={`${d.compliance ?? 0}%`} tone={Number(d.compliance) >= 80 ? "var(--success)" : "var(--warning)"} />
        <KPI label="Obrigações vencidas" value={String(g.obligations_overdue ?? 0)} hint={`${g.obligations_pending ?? 0} pendentes`} tone={g.obligations_overdue ? "var(--danger)" : undefined} />
        <KPI label="Não conformidades" value={String(g.nonconformities_open ?? 0)} hint={`${g.capas_open ?? 0} CAPAs abertas`} tone={g.nonconformities_open ? "var(--warning)" : "var(--success)"} />
        <KPI label="Delegações ativas" value={String(g.delegations_active ?? 0)} hint={`${g.delegations_expired ?? 0} expiradas · ${g.bodies ?? 0} comitês`} tone={g.delegations_expired ? "var(--warning)" : undefined} />
        <KPI label="Planos de ação" value={String(d.action_plans_open ?? 0)} hint={`${d.action_plans_overdue ?? 0} atrasados`} />
        <KPI label="Evidências (GED)" value={String(g.evidence_count ?? 0)} />
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

const kriColor = (s: string) => ({ red: "var(--danger)", amber: "var(--warning)", green: "var(--success)" } as any)[s] ?? "var(--muted)";
function KRIs({ kris }: { kris: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  async function measure(id: string) {
    if (!supabase) return;
    const v = prompt("Novo valor medido do indicador:");
    if (v === null || v.trim() === "") return;
    await supabase.rpc("record_kri", { p_company: COMPANY, p_kri: id, p_value: Number(v) });
    router.refresh();
  }
  return (
    <div className="space-y-3">
      <div className="font-semibold text-base">Indicadores-Chave de Risco (KRIs)</div>
      {kris.length === 0 ? <p className="text-sm muted">Sem KRIs cadastrados.</p> : (
        <div className="grid md:grid-cols-2 gap-3">
          {kris.map((k) => (
            <div key={k.id} className="card p-4" style={{ borderLeft: `3px solid ${kriColor(k.status)}` }}>
              <div className="flex items-start justify-between gap-2">
                <div>
                  <div className="font-semibold text-sm">{k.name}</div>
                  <div className="text-xs muted">{k.metric}{k.risk_name ? ` · risco: ${k.risk_name}` : ""}</div>
                </div>
                <span className="badge" style={{ background: kriColor(k.status), color: "#fff" }}>{k.status}</span>
              </div>
              <div className="flex items-end gap-3 mt-2">
                <div><span className="text-2xl font-extrabold tabular-nums" style={{ color: kriColor(k.status) }}>{k.current_value ?? "—"}</span> <span className="text-xs muted">{k.unit}</span></div>
                <div className="text-[11px] muted ml-auto text-right">
                  <div>meta {k.target_value ?? "—"} · {k.direction === "down_bad" ? "menor=pior" : "maior=pior"}</div>
                  <div>alerta {k.threshold_amber ?? "—"} · crítico {k.threshold_red ?? "—"}</div>
                </div>
              </div>
              <button onClick={() => measure(k.id)} className="text-xs text-brand-600 hover:underline mt-2">↻ registrar medição</button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function Obrigacoes({ obligations }: { obligations: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  async function gen() { if (!supabase) return; setBusy(true); await supabase.rpc("generate_grc_obligations", { p_company: COMPANY }); setBusy(false); router.refresh(); }
  async function done(id: string) { if (!supabase) return; await supabase.rpc("complete_obligation", { p_company: COMPANY, p_obligation: id }); router.refresh(); }
  const KIND: Record<string, string> = { audit: "Auditoria", control_test: "Teste de controle", policy_review: "Revisão de política", training: "Treinamento", renewal: "Renovação", certification: "Certificação", regulatory: "Regulatória", other: "Outra" };
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Calendário de Obrigações</div>
        <button onClick={gen} disabled={busy} className="btn btn-primary btn-sm">{busy ? "Gerando…" : "⟳ Gerar de controles/políticas/auditorias"}</button>
      </div>
      {obligations.length === 0 ? <p className="text-sm muted">Nenhuma obrigação nos próximos meses. Clique em gerar.</p> : (
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Obrigação</th><th>Tipo</th><th>Framework</th><th>Vencimento</th><th className="text-center">Prazo</th><th>Evidência</th><th>Status</th><th></th></tr></thead>
          <tbody>{obligations.map((o) => {
            const overdue = o.status === "overdue"; const soon = o.days_left != null && o.days_left >= 0 && o.days_left <= 15;
            return (
              <tr key={o.id}>
                <td className="font-medium">{o.title}</td><td className="text-xs">{KIND[o.obligation_kind] ?? o.obligation_kind}</td><td className="text-xs muted">{o.framework ?? "—"}</td>
                <td className="text-xs tabular-nums">{o.due_date}</td>
                <td className="text-center text-xs tabular-nums" style={{ color: overdue ? "var(--danger)" : soon ? "var(--warning)" : undefined }}>{o.days_left != null ? (o.days_left < 0 ? `${-o.days_left}d atrás` : `${o.days_left}d`) : "—"}</td>
                <td>{o.evidence_required ? (o.has_evidence ? <span className="badge badge-success">✓ anexada</span> : <span className="badge badge-warning">falta</span>) : <span className="text-xs muted">n/a</span>}</td>
                <td><span className={`badge ${overdue ? "badge-danger" : o.status === "done" ? "badge-success" : "badge-neutral"}`}>{overdue ? "vencida" : o.status === "done" ? "concluída" : "pendente"}</span></td>
                <td className="text-right"><button onClick={() => done(o.id)} className="text-xs text-brand-600 hover:underline">✓ concluir</button></td>
              </tr>
            );
          })}</tbody>
        </table></div>
      )}
    </div>
  );
}

function Governanca({ bodies, delegations }: { bodies: any[]; delegations: any[] }) {
  const BODY: Record<string, string> = { board: "Conselho", committee: "Comitê", council: "Conselho", forum: "Fórum" };
  const today = new Date().toISOString().slice(0, 10);
  return (
    <div className="grid lg:grid-cols-2 gap-4">
      <div>
        <div className="font-semibold text-sm mb-2">Estrutura de Governança</div>
        {bodies.length === 0 ? <p className="text-sm muted">—</p> : bodies.map((b) => (
          <div key={b.id} className="card p-4 mb-2">
            <div className="flex items-center gap-2"><span className="badge badge-neutral">{BODY[b.body_type] ?? b.body_type}</span><span className="font-semibold text-sm">{b.name}</span><span className="text-xs muted ml-auto">{b.meeting_frequency}</span></div>
            <div className="text-xs muted mt-1">{b.purpose}</div>
            <div className="text-[11px] muted mt-1">{Array.isArray(b.members) ? b.members.length : 0} membro(s)</div>
          </div>
        ))}
      </div>
      <div>
        <div className="font-semibold text-sm mb-2">Delegação de Autoridade</div>
        {delegations.length === 0 ? <p className="text-sm muted">—</p> : (
          <div className="card p-0 overflow-x-auto"><table className="tbl">
            <thead><tr><th>Alçada</th><th>Tipo</th><th className="text-right">Limite</th><th>Validade</th></tr></thead>
            <tbody>{delegations.map((d) => {
              const expired = d.valid_to && d.valid_to < today;
              return (<tr key={d.id}><td className="font-medium">{d.title}</td><td className="text-xs muted">{d.authority_type}</td><td className="text-right tabular-nums text-xs">{d.limit_amount ? "R$ " + Number(d.limit_amount).toLocaleString("pt-BR") : "—"}</td><td className="text-xs"><span className={expired ? "badge badge-danger" : "badge badge-success"}>{expired ? "expirada " : "até "}{d.valid_to ?? "—"}</span></td></tr>);
            })}</tbody>
          </table></div>
        )}
      </div>
    </div>
  );
}

function Evidencias({ evidence }: { evidence: any[] }) {
  const ENT: Record<string, string> = { risk: "Risco", control: "Controle", audit: "Auditoria", obligation: "Obrigação", nonconformity: "Não conformidade", action_plan: "Plano de ação", policy: "Política", sod: "SoD", continuity: "Continuidade" };
  return (
    <div className="space-y-3">
      <div className="font-semibold text-base">Evidências (integradas ao ECM/GED)</div>
      {evidence.length === 0 ? <p className="text-sm muted">Nenhuma evidência anexada. Use <code>attach_evidence</code> a partir de riscos, controles, auditorias e obrigações.</p> : (
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Título</th><th>Vínculo</th><th>Tipo</th><th>Coletada em</th><th>Referência</th></tr></thead>
          <tbody>{evidence.map((e) => (
            <tr key={e.id}><td className="font-medium">{e.title ?? "(sem título)"}</td><td className="text-xs"><span className="badge badge-neutral">{ENT[e.entity_type] ?? e.entity_type}</span></td><td className="text-xs muted">{e.evidence_type}</td><td className="text-xs tabular-nums">{(e.collected_at ?? "").slice(0, 10)}</td><td className="text-xs">{e.document_id ? "📎 documento GED" : e.external_url ? <a href={e.external_url} target="_blank" rel="noreferrer" className="text-brand-600 hover:underline">🔗 link</a> : "—"}</td></tr>
          ))}</tbody>
        </table></div>
      )}
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
