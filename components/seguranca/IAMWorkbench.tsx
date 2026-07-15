"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const sevBadge = (s: string) => ({ low: "badge-neutral", medium: "badge-warning", high: "badge-danger", critical: "badge-danger" } as any)[s] ?? "badge-neutral";

const TABS = ["Painel", "Identidades", "Acesso Privilegiado (PAM)", "Incidentes", "Políticas (Zero Trust)", "Certificações"] as const;
type Tab = typeof TABS[number];

export default function IAMWorkbench({ dash, identities, sessions, pam, incidents, policies, certs }: {
  dash: any; identities: any[]; sessions: any[]; pam: any[]; incidents: any[]; policies: any[]; certs: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Plataforma · Segurança</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Identidade & Segurança (IAM)</h1>
        <p className="text-sm muted mt-0.5">Zero Trust, MFA, sessões, acesso privilegiado (PAM), detecção de ameaças, incidentes e certificação de acessos.</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Identidades" && <Identidades identities={identities} sessions={sessions} />}
      {tab === "Acesso Privilegiado (PAM)" && <PAM pam={pam} />}
      {tab === "Incidentes" && <Incidentes incidents={incidents} />}
      {tab === "Políticas (Zero Trust)" && (
        <CrudPanel table="access_policies" title="Políticas de Acesso"
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "policy_type", label: "Tipo", type: "select", options: [["rbac","RBAC"],["abac","ABAC"],["pbac","PBAC"],["zerotrust","Zero Trust"]], default: "abac" },
            { key: "effect", label: "Efeito", type: "select", options: [["allow","Permitir"],["deny","Negar"]], default: "allow" },
            { key: "resource", label: "Recurso", placeholder: "finance.approve, admin.*, *" },
            { key: "priority", label: "Prioridade", type: "number", default: "100" },
          ]}
          columns={[
            { key: "name", label: "Política" }, { key: "policy_type", label: "Tipo", fmt: (v) => (v as string).toUpperCase() },
            { key: "effect", label: "Efeito" }, { key: "resource", label: "Recurso" },
          ]}
          rows={policies} emptyHint="Regras Zero Trust / ABAC / segregação de funções (SoD)." />
      )}
      {tab === "Certificações" && <Certificacoes certs={certs} />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash }: { dash: any }) {
  const d = dash ?? {};
  const mfa = Number(d.mfa_coverage ?? 0);
  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
      <KPI label="Identidades" value={String(d.identities ?? 0)} hint={`${d.privileged ?? 0} privilegiadas`} />
      <KPI label="Cobertura de MFA" value={`${mfa}%`} tone={mfa < 80 ? "var(--danger)" : "var(--success)"} />
      <KPI label="Sessões ativas" value={String(d.sessions_active ?? 0)} />
      <KPI label="Incidentes abertos" value={String(d.incidents_open ?? 0)} tone={d.incidents_open ? "var(--danger)" : "var(--success)"} />
      <KPI label="PAM ativo" value={String(d.pam_active ?? 0)} hint={`${d.pam_pending ?? 0} pendentes`} />
      <KPI label="Falhas de login (24h)" value={String(d.failed_logins_24h ?? 0)} tone={Number(d.failed_logins_24h) > 5 ? "var(--warning)" : undefined} />
      <KPI label="Políticas ativas" value={String(d.policies ?? 0)} />
      <KPI label="Certificações pendentes" value={String(d.certifications_pending ?? 0)} />
    </div>
  );
}

function Identidades({ identities, sessions }: { identities: any[]; sessions: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  async function toggleMfa(id: string, on: boolean) {
    if (!supabase) return;
    await supabase.from("iam_identities").update({ mfa_enabled: !on }).eq("id", id);
    router.refresh();
  }
  async function revoke(sid: string) {
    if (!supabase) return;
    await supabase.rpc("revoke_session", { p_session: sid });
    router.refresh();
  }
  const active = sessions.filter((s) => s.status === "active");
  return (
    <div className="space-y-4">
      <div className="card p-0 overflow-x-auto">
        <table className="tbl">
          <thead><tr><th>Identidade</th><th>E-mail</th><th>Tipo</th><th>Privilegiada</th><th>MFA</th><th>Risco</th></tr></thead>
          <tbody>
            {identities.map((i) => (
              <tr key={i.id}>
                <td className="font-medium">{i.display_name ?? "—"}</td>
                <td className="text-xs muted">{i.email ?? "—"}</td>
                <td className="text-xs">{i.subject_type}</td>
                <td>{i.is_privileged ? <span className="badge badge-warning">privilegiada</span> : "—"}</td>
                <td><button onClick={() => toggleMfa(i.id, i.mfa_enabled)} className={`badge ${i.mfa_enabled ? "badge-success" : "badge-danger"}`}>{i.mfa_enabled ? "ativado" : "desativado"}</button></td>
                <td className="tabular-nums">{i.risk_score}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {active.length > 0 && (
        <div>
          <div className="font-semibold text-sm mb-2">Sessões ativas</div>
          <div className="card p-0 overflow-x-auto"><table className="tbl">
            <thead><tr><th>E-mail</th><th>Dispositivo</th><th>IP</th><th>Início</th><th></th></tr></thead>
            <tbody>{active.map((s) => (<tr key={s.id}><td>{s.email ?? "—"}</td><td className="text-xs muted">{s.device ?? "—"}</td><td className="text-xs muted">{s.ip_address ?? "—"}</td><td className="text-xs tabular-nums">{new Date(s.started_at).toLocaleString("pt-BR")}</td><td className="text-right"><button onClick={() => revoke(s.id)} className="text-xs font-semibold hover:underline" style={{ color: "var(--danger)" }}>revogar</button></td></tr>))}</tbody>
          </table></div>
        </div>
      )}
    </div>
  );
}

function PAM({ pam }: { pam: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [f, setF] = useState({ privilege: "", reason: "", hours: "4" });
  const [busy, setBusy] = useState<string | null>(null);
  async function request() {
    if (!supabase || !f.privilege) return;
    setBusy("req");
    await supabase.rpc("request_pam", { p_company: COMPANY, p_privilege: f.privilege, p_reason: f.reason || null, p_hours: Number(f.hours) || 4 });
    setBusy(null); setF({ privilege: "", reason: "", hours: "4" }); router.refresh();
  }
  async function decide(id: string, ok: boolean) {
    if (!supabase) return;
    setBusy(id);
    await supabase.rpc("decide_pam", { p_request: id, p_approve: ok });
    setBusy(null); router.refresh();
  }
  const badge = (s: string) => ({ pending: "badge-warning", active: "badge-success", rejected: "badge-danger", expired: "badge-neutral" } as any)[s] ?? "badge-neutral";
  return (
    <div className="space-y-3">
      <div className="card p-4 grid md:grid-cols-4 gap-3 items-end">
        <div><label className="label">Privilégio</label><input value={f.privilege} onChange={(e) => setF((p) => ({ ...p, privilege: e.target.value }))} className="input" placeholder="db.readonly.prod" /></div>
        <div className="md:col-span-2"><label className="label">Justificativa</label><input value={f.reason} onChange={(e) => setF((p) => ({ ...p, reason: e.target.value }))} className="input" /></div>
        <div className="flex gap-2 items-end"><div className="flex-1"><label className="label">Horas</label><input type="number" value={f.hours} onChange={(e) => setF((p) => ({ ...p, hours: e.target.value }))} className="input" /></div><button onClick={request} disabled={busy === "req" || !f.privilege} className="btn btn-primary btn-sm">Solicitar</button></div>
      </div>
      {pam.length === 0 ? <p className="text-sm muted px-1">Nenhuma solicitação de acesso privilegiado.</p> : (
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Privilégio</th><th>Justificativa</th><th>Horas</th><th>Status</th><th>Expira</th><th></th></tr></thead>
          <tbody>{pam.map((r) => (
            <tr key={r.id}>
              <td className="font-medium">{r.privilege}</td><td className="text-xs muted">{r.reason}</td><td className="tabular-nums">{r.requested_hours}h</td>
              <td><span className={`badge ${badge(r.status)}`}>{r.status}</span></td>
              <td className="text-xs muted tabular-nums">{r.expires_at ? new Date(r.expires_at).toLocaleString("pt-BR") : "—"}</td>
              <td className="text-right whitespace-nowrap">{r.status === "pending" && (<><button onClick={() => decide(r.id, true)} className="btn btn-primary btn-sm mr-1">Aprovar</button><button onClick={() => decide(r.id, false)} className="text-xs font-semibold hover:underline" style={{ color: "var(--danger)" }}>negar</button></>)}</td>
            </tr>
          ))}</tbody>
        </table></div>
      )}
    </div>
  );
}

function Incidentes({ incidents }: { incidents: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  async function detect() {
    if (!supabase) return;
    setBusy("detect");
    await supabase.rpc("detect_security_threats", { p_company: COMPANY });
    setBusy(null); router.refresh();
  }
  async function resolve(id: string) {
    if (!supabase) return;
    setBusy(id);
    await supabase.from("security_incidents").update({ status: "resolved", resolved_at: new Date().toISOString() }).eq("id", id);
    setBusy(null); router.refresh();
  }
  const TYPE: Record<string, string> = { brute_force: "Força bruta", dormant_privileged: "Admin dormente", privilege_escalation: "Escalada de privilégio", suspicious_login: "Login suspeito" };
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Incidentes de Segurança</div>
        <button onClick={detect} disabled={busy === "detect"} className="btn btn-primary btn-sm">{busy === "detect" ? "Analisando…" : "🔍 Detectar ameaças"}</button>
      </div>
      {incidents.length === 0 ? <p className="text-sm muted px-1">🛡️ Nenhum incidente. Ambiente seguro.</p> : (
        <div className="space-y-2">
          {incidents.map((i) => (
            <div key={i.id} className="card p-4 flex items-center gap-3">
              <span className={`badge ${sevBadge(i.severity)}`}>{i.severity}</span>
              <div className="flex-1">
                <div className="font-semibold text-sm">{TYPE[i.incident_type] ?? i.incident_type} — {i.subject}</div>
                <div className="text-xs muted">{i.description} · {new Date(i.detected_at).toLocaleString("pt-BR")}</div>
              </div>
              <span className={`badge ${i.status === "open" ? "badge-danger" : "badge-success"}`}>{i.status === "open" ? "aberto" : i.status}</span>
              {i.status === "open" && <button onClick={() => resolve(i.id)} disabled={busy === i.id} className="btn btn-sm">Resolver</button>}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function Certificacoes({ certs }: { certs: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  async function complete(id: string, total: number) {
    if (!supabase) return;
    setBusy(id);
    await supabase.from("access_certifications").update({ status: "completed", reviewed_count: total, decision: "todos os acessos revisados e mantidos" }).eq("id", id);
    setBusy(null); router.refresh();
  }
  const late = (c: any) => c.status === "pending" && c.due_date && c.due_date < new Date().toISOString().slice(0, 10);
  return (
    <div className="space-y-2">
      {certs.length === 0 ? <p className="text-sm muted px-1">Nenhuma campanha de certificação.</p> : certs.map((c) => (
        <div key={c.id} className="card p-4 flex items-center gap-3">
          <div className="flex-1">
            <div className="font-semibold text-sm">{c.name}</div>
            <div className="text-xs muted">{c.scope} · {c.total_count} acessos · vence {c.due_date ? new Date(c.due_date + "T00:00:00").toLocaleDateString("pt-BR") : "—"}</div>
          </div>
          <span className={`badge ${c.status === "completed" ? "badge-success" : late(c) ? "badge-danger" : "badge-warning"}`}>{c.status === "completed" ? "concluída" : late(c) ? "vencida" : "pendente"}</span>
          {c.status !== "completed" && <button onClick={() => complete(c.id, c.total_count)} disabled={busy === c.id} className="btn btn-primary btn-sm">Certificar acessos</button>}
        </div>
      ))}
    </div>
  );
}
