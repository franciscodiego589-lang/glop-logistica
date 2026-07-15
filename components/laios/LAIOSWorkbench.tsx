"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const brl = (n: number) => (n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const AUTONOMY: Record<string, string> = { observe: "Observa", suggest: "Sugere", approve: "Sugere + aprova", autonomous: "Autônomo" };

const TABS = ["Centro de Comando","Decisões","Agentes","Memória Corporativa","Execuções (24/7)"] as const;
type Tab = typeof TABS[number];

export default function LAIOSWorkbench({ dash, brief, decisions, agents, knowledge, runs }: {
  dash: any; brief: any; decisions: any[]; agents: any[]; knowledge: any[]; runs: any[];
}) {
  const [tab, setTab] = useState<Tab>("Centro de Comando");
  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3 flex-wrap">
        <div>
          <h1 className="text-xl font-bold flex items-center gap-2"><span className="text-brand-600">✦</span> LAIOS — Cérebro do ERP</h1>
          <p className="text-sm muted">IA central que orquestra os agentes, monitora todos os módulos 24/7, propõe decisões e governa a operação.</p>
        </div>
        <OrchestrateButton />
      </div>

      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Centro de Comando" && <CommandCenter dash={dash} brief={brief} />}
      {tab === "Decisões" && <Decisions decisions={decisions} />}
      {tab === "Agentes" && <Agents agents={agents} />}
      {tab === "Memória Corporativa" && (
        <CrudPanel table="ai_knowledge" title="Memória Corporativa (RAG)"
          fields={[
            { key: "title", label: "Título", required: true },
            { key: "kind", label: "Tipo", type: "select", options: [["policy","Política"],["procedure","Procedimento (POP)"],["iso","Norma ISO"],["lgpd","LGPD"],["contract","Contrato"],["manual","Manual"],["report","Relatório"],["note","Nota"]], default: "note" },
            { key: "content", label: "Conteúdo" },
            { key: "source_url", label: "Link da fonte" },
          ]}
          columns={[
            { key: "title", label: "Título" },
            { key: "kind", label: "Tipo" },
            { key: "created_at", label: "Criado", fmt: (v) => v ? new Date(v).toLocaleDateString("pt-BR") : "—" },
          ]}
          rows={knowledge} emptyHint="Ensine o cérebro: políticas, POPs, normas ISO, LGPD, contratos, manuais…" />
      )}
      {tab === "Execuções (24/7)" && <Runs runs={runs} />}
    </div>
  );
}

function OrchestrateButton() {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  async function run() {
    if (!supabase) return;
    setBusy(true); setMsg(null);
    const { data, error } = await supabase.rpc("laios_orchestrate", { p_company: COMPANY });
    setBusy(false);
    if (error) { setMsg("Erro: " + error.message); return; }
    setMsg(`✓ ${data?.engines_ran ?? 0} agentes varreram a operação · ${data?.insights ?? 0} sinais · ${data?.decisions_proposed ?? 0} decisões propostas`);
    router.refresh();
  }
  return (
    <div className="ml-auto flex items-center gap-3">
      {msg && <span className="text-xs muted max-w-xs">{msg}</span>}
      <button onClick={run} disabled={busy} className="text-sm px-4 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold disabled:opacity-60">
        {busy ? "Pensando…" : "▶ Orquestrar agora"}
      </button>
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: "danger" | "warn" }) {
  const color = tone === "danger" ? "text-red-500" : tone === "warn" ? "text-amber-500" : "";
  return (
    <div className="card p-4">
      <div className="text-xs muted font-semibold uppercase">{label}</div>
      <div className={`text-2xl font-bold mt-1 ${color}`}>{value}</div>
      {hint && <div className="text-xs muted mt-0.5">{hint}</div>}
    </div>
  );
}

function CommandCenter({ dash, brief }: { dash: any; brief: any }) {
  const d = dash ?? {}, b = brief ?? {};
  const last = d.last_run ? new Date(d.last_run).toLocaleString("pt-BR") : "—";
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
        <KPI label="Agentes ativos" value={`${d.agents_active ?? 0}/${d.agents_total ?? 0}`} />
        <KPI label="Decisões p/ aprovar" value={String(d.decisions_open ?? 0)} tone={d.decisions_open ? "warn" : undefined} />
        <KPI label="Sinais críticos" value={String(d.insights_critical ?? 0)} tone={d.insights_critical ? "danger" : undefined} />
        <KPI label="Alertas" value={String(d.insights_warning ?? 0)} tone={d.insights_warning ? "warn" : undefined} />
        <KPI label="Varreduras hoje" value={String(d.runs_today ?? 0)} hint="a cada 15 min" />
        <KPI label="Memória (docs)" value={String(d.knowledge_docs ?? 0)} />
      </div>

      <div className="grid lg:grid-cols-2 gap-4">
        <div className="card p-4">
          <div className="font-semibold mb-2">🔴 Meus maiores problemas agora</div>
          {(b.top_problems ?? []).length === 0 ? <p className="text-sm muted">Nenhum problema aberto. Operação saudável.</p> : (
            <div className="space-y-2">
              {(b.top_problems ?? []).map((p: any, i: number) => (
                <div key={i} className="border-b last:border-0 pb-2" style={{ borderColor: "var(--border)" }}>
                  <div className="flex items-center gap-2">
                    <span className={`text-xs px-1.5 py-0.5 rounded font-semibold ${p.severity === "critical" ? "bg-red-500/15 text-red-500" : "bg-amber-500/15 text-amber-600"}`}>{p.severity === "critical" ? "crítico" : "alerta"}</span>
                    <span className="text-sm font-medium">{p.title}</span>
                  </div>
                  {p.recommendation && <div className="text-xs muted mt-0.5">→ {p.recommendation}</div>}
                </div>
              ))}
            </div>
          )}
        </div>
        <div className="card p-4">
          <div className="font-semibold mb-2">🟢 Oportunidades</div>
          {(b.opportunities ?? []).length === 0 ? <p className="text-sm muted">Nenhuma oportunidade destacada no momento.</p> : (
            <div className="space-y-2">
              {(b.opportunities ?? []).map((p: any, i: number) => (
                <div key={i} className="border-b last:border-0 pb-2" style={{ borderColor: "var(--border)" }}>
                  <div className="text-sm font-medium">{p.title}</div>
                  {p.recommendation && <div className="text-xs muted mt-0.5">→ {p.recommendation}</div>}
                  {p.impact_value ? <div className="text-xs text-emerald-500 mt-0.5">Impacto estimado: R$ {brl(Number(p.impact_value))}</div> : null}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
      <p className="text-xs muted">Última varredura completa: {last}. O cérebro roda automaticamente a cada 15 minutos (pg_cron) e sempre que você clicar em “Orquestrar agora”.</p>
    </div>
  );
}

function Decisions({ decisions }: { decisions: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  async function decide(id: string, action: "approve" | "reject") {
    if (!supabase) return;
    setBusy(id);
    await supabase.rpc("decide_ai_action", { p_decision: id, p_action: action, p_note: null });
    setBusy(null); router.refresh();
  }
  const badge = (s: string) => ({ proposed: "bg-amber-500/15 text-amber-600", approved: "bg-emerald-500/15 text-emerald-600", rejected: "bg-red-500/15 text-red-500", executed: "bg-brand-600/15 text-brand-600" } as any)[s] ?? "bg-gray-500/15";
  if (!decisions.length) return <p className="text-sm muted px-1">Nenhuma decisão proposta. Clique em “Orquestrar agora” — o cérebro analisa a operação e propõe ações.</p>;
  return (
    <div className="space-y-3">
      {decisions.map((d) => (
        <div key={d.id} className="card p-4">
          <div className="flex items-start gap-3">
            <div className="flex-1">
              <div className="flex items-center gap-2 flex-wrap">
                <span className={`text-xs px-1.5 py-0.5 rounded font-semibold ${badge(d.status)}`}>{d.status}</span>
                <span className={`text-xs px-1.5 py-0.5 rounded font-semibold ${d.risk_level === "high" ? "bg-red-500/15 text-red-500" : "bg-amber-500/15 text-amber-600"}`}>risco {d.risk_level}</span>
                <span className="text-xs muted">{d.category}</span>
                <span className="font-semibold text-sm">{d.title}</span>
              </div>
              {d.motivation && <div className="text-sm mt-1"><span className="muted">Motivação:</span> {d.motivation}</div>}
              {d.expected_impact && <div className="text-xs muted mt-0.5">Impacto: {d.expected_impact}</div>}
              {d.estimated_saving ? <div className="text-xs text-emerald-500 mt-0.5">Economia estimada: R$ {brl(Number(d.estimated_saving))}</div> : null}
            </div>
            {d.status === "proposed" && (
              <div className="flex gap-2">
                <button onClick={() => decide(d.id, "approve")} disabled={busy === d.id} className="text-xs px-3 py-1.5 rounded-lg bg-emerald-600 text-white font-semibold disabled:opacity-60">Aprovar</button>
                <button onClick={() => decide(d.id, "reject")} disabled={busy === d.id} className="text-xs px-3 py-1.5 rounded-lg border font-semibold disabled:opacity-60" style={{ borderColor: "var(--border)" }}>Rejeitar</button>
              </div>
            )}
          </div>
        </div>
      ))}
    </div>
  );
}

function Agents({ agents }: { agents: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  async function toggle(id: string, enabled: boolean) {
    if (!supabase) return;
    await supabase.from("ai_agents").update({ enabled: !enabled }).eq("id", id);
    router.refresh();
  }
  return (
    <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
      {agents.map((a) => (
        <div key={a.id} className="card p-4">
          <div className="flex items-center gap-2">
            <span className="text-xl">{a.avatar}</span>
            <div className="flex-1">
              <div className="font-semibold text-sm">{a.name}</div>
              <div className="text-xs muted">{a.role_title}</div>
            </div>
            <button onClick={() => toggle(a.id, a.enabled)} className={`text-xs px-2 py-1 rounded-full font-semibold ${a.enabled ? "bg-emerald-500/15 text-emerald-600" : "bg-gray-500/15 muted"}`}>{a.enabled ? "ativo" : "pausado"}</button>
          </div>
          <div className="text-xs muted mt-2">Autonomia: <span className="font-medium">{AUTONOMY[a.autonomy_level] ?? a.autonomy_level}</span></div>
          {a.engines?.length ? <div className="text-xs muted mt-1">Motores: {a.engines.join(", ")}</div> : <div className="text-xs muted mt-1">Sem motor dedicado (consultivo)</div>}
        </div>
      ))}
    </div>
  );
}

function Runs({ runs }: { runs: any[] }) {
  if (!runs.length) return <p className="text-sm muted px-1">Nenhuma execução registrada ainda.</p>;
  return (
    <div className="card p-0 overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
            <th className="py-2 px-3">Quando</th><th className="py-2 px-3">Tipo</th><th className="py-2 px-3">Status</th>
            <th className="py-2 px-3">Motores</th><th className="py-2 px-3">Sinais</th><th className="py-2 px-3">Decisões</th>
          </tr>
        </thead>
        <tbody>
          {runs.map((r) => (
            <tr key={r.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
              <td className="py-2 px-3">{new Date(r.started_at).toLocaleString("pt-BR")}</td>
              <td className="py-2 px-3">{r.run_type}</td>
              <td className="py-2 px-3">{r.status}</td>
              <td className="py-2 px-3">{r.summary?.engines_ran ?? "—"}</td>
              <td className="py-2 px-3">{r.insights_created ?? 0}</td>
              <td className="py-2 px-3">{r.decisions_created ?? 0}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
