"use client";
import { Fragment, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const ISTATUS: Record<string, string> = { running: "Em andamento", completed: "Concluído", rejected: "Reprovado", canceled: "Cancelado" };
const IBADGE: Record<string, string> = { running: "badge-brand", completed: "badge-success", rejected: "badge-danger", canceled: "badge-neutral" };

const TABS = ["Painel", "Minhas Tarefas", "Instâncias", "Processos", "Regras de Negócio"] as const;
type Tab = typeof TABS[number];

export default function BPMWorkbench({ dash, definitions, instances, tasks, events, rules }: {
  dash: any; definitions: any[]; instances: any[]; tasks: any[]; events: any[]; rules: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Plataforma · Motor de Processos</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">BPM & Workflows</h1>
        <p className="text-sm muted mt-0.5">Motor de processos: aprovações multinível, regras de decisão (DMN), SLA e trilha de eventos — o coração da automação.</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Minhas Tarefas" && <Tarefas tasks={tasks} instances={instances} />}
      {tab === "Instâncias" && <Instancias instances={instances} events={events} definitions={definitions} />}
      {tab === "Processos" && <Processos definitions={definitions} />}
      {tab === "Regras de Negócio" && <Regras rules={rules} />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash }: { dash: any }) {
  const d = dash ?? {};
  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
      <KPI label="Processos publicados" value={String(d.definitions ?? 0)} />
      <KPI label="Instâncias ativas" value={String(d.instances_active ?? 0)} tone="var(--brand)" />
      <KPI label="Tarefas pendentes" value={String(d.tasks_pending ?? 0)} tone={d.tasks_pending ? "var(--warning)" : undefined} />
      <KPI label="SLA vencido" value={String(d.tasks_overdue ?? 0)} tone={d.tasks_overdue ? "var(--danger)" : undefined} />
      <KPI label="Concluídos" value={String(d.instances_completed ?? 0)} tone="var(--success)" />
      <KPI label="Tempo médio de ciclo" value={`${d.avg_cycle_h ?? 0}h`} />
      <KPI label="Regras de decisão" value={String(d.rules ?? 0)} />
      <KPI label="Automações" value={String(d.automations ?? 0)} />
    </div>
  );
}

function Tarefas({ tasks, instances }: { tasks: any[]; instances: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  const [comment, setComment] = useState<Record<string, string>>({});
  const instTitle = (id: string) => instances.find((i) => i.id === id)?.title ?? "—";
  const pending = tasks.filter((t) => t.status === "pending");
  async function decide(id: string, decision: string) {
    if (!supabase) return;
    setBusy(id);
    await supabase.rpc("complete_task", { p_task: id, p_decision: decision, p_comment: comment[id] || null });
    setBusy(null); router.refresh();
  }
  const overdue = (t: any) => t.sla_due && new Date(t.sla_due) < new Date();
  if (pending.length === 0) return <p className="text-sm muted px-1">🎉 Nenhuma tarefa pendente. Tudo aprovado!</p>;
  return (
    <div className="space-y-3">
      {pending.map((t) => (
        <div key={t.id} className="card p-4">
          <div className="flex items-start gap-3">
            <div className="flex-1">
              <div className="flex items-center gap-2 flex-wrap">
                <span className="badge badge-brand">{t.assignee_role ?? "—"}</span>
                {overdue(t) && <span className="badge badge-danger">SLA vencido</span>}
                <span className="font-semibold">{t.name}</span>
              </div>
              <div className="text-sm muted mt-0.5">{instTitle(t.instance_id)}</div>
              <div className="text-xs muted mt-0.5">Prazo: {t.sla_due ? new Date(t.sla_due).toLocaleString("pt-BR") : "—"}</div>
              <input value={comment[t.id] ?? ""} onChange={(e) => setComment((p) => ({ ...p, [t.id]: e.target.value }))} className="input h-9 mt-2" placeholder="Comentário (opcional)" />
            </div>
            <div className="flex flex-col gap-2">
              <button onClick={() => decide(t.id, "approve")} disabled={busy === t.id} className="btn btn-sm" style={{ background: "var(--success)", color: "#fff", borderColor: "transparent" }}>Aprovar</button>
              <button onClick={() => decide(t.id, "reject")} disabled={busy === t.id} className="btn btn-sm" style={{ background: "var(--danger)", color: "#fff", borderColor: "transparent" }}>Reprovar</button>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

function Instancias({ instances, events, definitions }: { instances: any[]; events: any[]; definitions: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [expand, setExpand] = useState<string | null>(null);
  const [f, setF] = useState({ key: "", title: "" });
  const [busy, setBusy] = useState(false);
  async function start() {
    if (!supabase || !f.key || !f.title) return;
    setBusy(true);
    await supabase.rpc("start_process", { p_company: COMPANY, p_process_key: f.key, p_title: f.title, p_business_key: null, p_context: {} });
    setBusy(false); setOpen(false); setF({ key: "", title: "" }); router.refresh();
  }
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Instâncias <span className="badge badge-neutral ml-1">{instances.length}</span></div>
        <button onClick={() => setOpen((o) => !o)} className={`btn btn-sm ${open ? "" : "btn-primary"}`}>{open ? "Cancelar" : "+ Iniciar processo"}</button>
      </div>
      {open && (
        <div className="card p-4 grid md:grid-cols-3 gap-3 items-end">
          <div><label className="label">Processo</label><select value={f.key} onChange={(e) => setF((p) => ({ ...p, key: e.target.value }))} className="select"><option value="">—</option>{definitions.map((d) => <option key={d.id} value={d.process_key}>{d.name}</option>)}</select></div>
          <div><label className="label">Título / referência</label><input value={f.title} onChange={(e) => setF((p) => ({ ...p, title: e.target.value }))} className="input" /></div>
          <button onClick={start} disabled={busy || !f.key || !f.title} className="btn btn-primary btn-sm">Iniciar</button>
        </div>
      )}
      {instances.length === 0 ? <p className="text-sm muted px-1">Nenhuma instância.</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead><tr><th>Processo</th><th>Título</th><th>Etapa atual</th><th>Status</th><th>Iniciado</th><th></th></tr></thead>
            <tbody>
              {instances.map((i) => (
                <Fragment key={i.id}>
                  <tr>
                    <td>{i.process_key}</td><td>{i.title}</td>
                    <td className="text-xs muted">{i.current_step}</td>
                    <td><span className={`badge ${IBADGE[i.status]}`}>{ISTATUS[i.status] ?? i.status}{i.result ? ` · ${i.result}` : ""}</span></td>
                    <td className="tabular-nums text-xs">{new Date(i.started_at).toLocaleDateString("pt-BR")}</td>
                    <td className="text-right"><button onClick={() => setExpand(expand === i.id ? null : i.id)} className="text-xs text-brand-600 hover:underline">trilha</button></td>
                  </tr>
                  {expand === i.id && (
                    <tr><td colSpan={6} className="surface-2"><div className="p-3 space-y-1">
                      {events.filter((e) => e.instance_id === i.id).map((e) => (
                        <div key={e.id} className="text-xs flex gap-2"><span className="muted tabular-nums">{new Date(e.created_at).toLocaleString("pt-BR")}</span><span className="font-medium">{e.event_type}</span><span className="muted">{e.step_key}</span></div>
                      ))}
                    </div></td></tr>
                  )}
                </Fragment>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function Processos({ definitions }: { definitions: any[] }) {
  return (
    <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
      {definitions.map((d) => {
        const steps = (d.definition?.steps ?? []).filter((s: any) => ["approval", "task"].includes(s.type));
        return (
          <div key={d.id} className="card p-4">
            <div className="flex items-center justify-between">
              <div className="font-semibold text-sm">{d.name}</div>
              <span className="badge badge-neutral">v{d.version}</span>
            </div>
            <div className="text-xs muted mt-0.5">{d.category} · <code>{d.process_key}</code></div>
            <div className="mt-3 space-y-1.5">
              {steps.map((s: any, idx: number) => (
                <div key={s.key} className="flex items-center gap-2 text-sm">
                  <span className="h-5 w-5 rounded-full grid place-items-center text-[10px] font-bold text-white shrink-0" style={{ background: "var(--brand)" }}>{idx + 1}</span>
                  <span className="flex-1">{s.name}</span>
                  <span className="text-[10px] muted">{s.sla_hours}h</span>
                </div>
              ))}
            </div>
          </div>
        );
      })}
      {definitions.length === 0 && <p className="text-sm muted">Nenhum processo publicado.</p>}
    </div>
  );
}

function Regras({ rules }: { rules: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const [sel, setSel] = useState("");
  const [val, setVal] = useState("30000");
  const [res, setRes] = useState<any>(null);
  async function test() {
    if (!supabase || !sel) return;
    const { data } = await supabase.rpc("evaluate_rule", { p_company: COMPANY, p_rule_key: sel, p_inputs: { value: Number(val) || 0 } });
    setRes(data);
  }
  return (
    <div className="space-y-4">
      {rules.map((r) => (
        <div key={r.id} className="card p-4">
          <div className="font-semibold">{r.name} <code className="text-xs muted ml-1">{r.rule_key}</code></div>
          <div className="text-xs muted">{r.description}</div>
          <div className="mt-3 overflow-x-auto">
            <table className="tbl"><thead><tr><th>Condições (SE)</th><th>Resultado (ENTÃO)</th></tr></thead>
              <tbody>{(r.rules ?? []).map((rule: any, i: number) => (
                <tr key={i}>
                  <td className="text-xs">{(rule.when ?? []).map((w: any) => `${w.field} ${w.op} ${w.value}`).join(" e ")}</td>
                  <td className="text-xs font-medium">{JSON.stringify(rule.then)}</td>
                </tr>
              ))}</tbody>
            </table>
          </div>
        </div>
      ))}
      <div className="card p-4 space-y-3">
        <div className="font-semibold">Testar regra (DMN)</div>
        <div className="grid md:grid-cols-3 gap-3 items-end">
          <div><label className="label">Regra</label><select value={sel} onChange={(e) => setSel(e.target.value)} className="select"><option value="">—</option>{rules.map((r) => <option key={r.id} value={r.rule_key}>{r.name}</option>)}</select></div>
          <div><label className="label">Valor</label><input type="number" value={val} onChange={(e) => setVal(e.target.value)} className="input" /></div>
          <button onClick={test} disabled={!sel} className="btn btn-primary btn-sm">Avaliar</button>
        </div>
        {res && <div className="text-sm rounded-xl px-3 py-2" style={{ background: res.matched ? "var(--success-soft)" : "var(--warning-soft)", color: res.matched ? "var(--success)" : "var(--warning)" }}>{res.matched ? `Resultado: ${JSON.stringify(res.output)}` : "Nenhuma condição atendida (usa default)"}</div>}
      </div>
    </div>
  );
}
