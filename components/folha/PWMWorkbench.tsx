"use client";
import { Fragment, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const brl = (n: number) => (n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const k = (n: number) => (n ?? 0).toLocaleString("pt-BR", { maximumFractionDigits: 0 });
const PBADGE: Record<string, string> = { draft: "badge-neutral", calculated: "badge-warning", approved: "badge-success", paid: "badge-brand" };
const PSTATUS: Record<string, string> = { draft: "Rascunho", calculated: "Calculada", approved: "Aprovada", paid: "Paga" };

const TABS = ["Painel", "Folha de Pagamento", "Ponto", "Escalas", "Banco de Horas", "Rescisões"] as const;
type Tab = typeof TABS[number];

export default function PWMWorkbench({ dash, runs, items, schedules, timeEntries, timeBank, terminations, employees }: {
  dash: any; runs: any[]; items: any[]; schedules: any[]; timeEntries: any[]; timeBank: any[]; terminations: any[]; employees: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  const empName = (id: string) => employees.find((e) => e.id === id)?.full_name ?? "—";
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Capital Humano · Folha</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Folha & Força de Trabalho (PWM)</h1>
        <p className="text-sm muted mt-0.5">Cálculo de folha (INSS/IRRF/FGTS), ponto, escalas, banco de horas e rescisões — a folha aprovada lança no GL.</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Folha de Pagamento" && <Folha runs={runs} items={items} empName={empName} />}
      {tab === "Ponto" && <Ponto entries={timeEntries} employees={employees} empName={empName} />}
      {tab === "Escalas" && (
        <CrudPanel table="work_schedules" title="Escalas de Trabalho"
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "schedule_type", label: "Tipo", type: "select", options: [["5x2","5x2"],["6x1","6x1"],["12x36","12x36"],["24x72","24x72"],["turno","Turno"],["custom","Personalizada"]], default: "5x2" },
            { key: "hours_per_day", label: "Horas/dia", type: "number", default: "8" },
            { key: "weekly_hours", label: "Horas/semana", type: "number", default: "44" },
          ]}
          columns={[{ key: "name", label: "Escala" }, { key: "schedule_type", label: "Tipo" }, { key: "hours_per_day", label: "H/dia" }, { key: "weekly_hours", label: "H/sem" }]}
          rows={schedules} emptyHint="5x2, 6x1, 12x36, turnos industriais…" />
      )}
      {tab === "Banco de Horas" && <BancoHoras movements={timeBank} empName={empName} />}
      {tab === "Rescisões" && <Rescisoes terminations={terminations} employees={employees} empName={empName} />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash }: { dash: any }) {
  const d = dash ?? {}; const lr = d.last_run;
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <KPI label="Headcount" value={String(d.headcount ?? 0)} />
        <KPI label="Base salarial" value={`R$ ${k(Number(d.payroll_base ?? 0))}`} tone="var(--brand)" />
        <KPI label="Horas extras (mês)" value={`${d.overtime_month ?? 0}h`} tone={Number(d.overtime_month) > 100 ? "var(--warning)" : undefined} />
        <KPI label="Banco de horas" value={`${d.time_bank_balance ?? 0}h`} />
        <KPI label="Escalas" value={String(d.schedules ?? 0)} />
        <KPI label="Folhas processadas" value={String(d.runs ?? 0)} />
        <KPI label="Rescisões (ano)" value={String(d.terminations_ytd ?? 0)} />
      </div>
      {lr && (
        <div className="card p-5">
          <div className="font-semibold mb-3">Última folha — {lr.period} <span className={`badge ${PBADGE[lr.status]} ml-1`}>{PSTATUS[lr.status] ?? lr.status}</span></div>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            <div className="surface-2 rounded-xl p-3" style={{ border: "1px solid var(--border)" }}><div className="text-xs muted font-semibold">Bruto</div><div className="text-lg font-bold tabular-nums mt-1">R$ {brl(Number(lr.gross))}</div></div>
            <div className="surface-2 rounded-xl p-3" style={{ border: "1px solid var(--border)" }}><div className="text-xs muted font-semibold">Líquido</div><div className="text-lg font-bold tabular-nums mt-1" style={{ color: "var(--success)" }}>R$ {brl(Number(lr.net))}</div></div>
            <div className="surface-2 rounded-xl p-3" style={{ border: "1px solid var(--border)" }}><div className="text-xs muted font-semibold">Encargos patronais</div><div className="text-lg font-bold tabular-nums mt-1" style={{ color: "var(--warning)" }}>R$ {brl(Number(lr.employer))}</div></div>
            <div className="surface-2 rounded-xl p-3" style={{ border: "1px solid var(--border)" }}><div className="text-xs muted font-semibold">Custo total</div><div className="text-lg font-bold tabular-nums mt-1">R$ {brl(Number(lr.gross) + Number(lr.employer))}</div></div>
          </div>
        </div>
      )}
    </div>
  );
}

function Folha({ runs, items, empName }: { runs: any[]; items: any[]; empName: (id: string) => string }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const [expand, setExpand] = useState<string | null>(null);
  const now = new Date();
  async function process() {
    if (!supabase) return;
    setBusy("run"); setMsg(null);
    const { data, error } = await supabase.rpc("run_payroll", { p_company: COMPANY, p_year: now.getFullYear(), p_month: now.getMonth() + 1 });
    setBusy(null);
    if (error) { setMsg(error.message); return; }
    setMsg(`✓ ${data?.employees ?? 0} colaboradores · líquido R$ ${brl(Number(data?.net ?? 0))}`); router.refresh();
  }
  async function approve(id: string) {
    if (!supabase) return;
    setBusy(id);
    await supabase.rpc("approve_payroll", { p_run: id });
    setBusy(null); router.refresh();
  }
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3 flex-wrap">
        <div className="font-semibold text-base mr-auto">Competências</div>
        {msg && <span className="text-xs muted">{msg}</span>}
        <button onClick={process} disabled={busy === "run"} className="btn btn-primary btn-sm">{busy === "run" ? "Processando…" : `Processar folha ${now.getMonth() + 1}/${now.getFullYear()}`}</button>
      </div>
      {runs.length === 0 ? <p className="text-sm muted px-1">Nenhuma folha processada. Clique em processar.</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead><tr><th>Competência</th><th>Colab.</th><th className="text-right">Bruto</th><th className="text-right">Descontos</th><th className="text-right">Líquido</th><th className="text-right">Encargos</th><th>Status</th><th></th></tr></thead>
            <tbody>
              {runs.map((r) => (
                <Fragment key={r.id}>
                  <tr>
                    <td className="tabular-nums font-semibold">{r.fiscal_year}/{String(r.fiscal_month).padStart(2, "0")}</td>
                    <td className="tabular-nums">{r.employees_count}</td>
                    <td className="text-right tabular-nums">{brl(Number(r.total_gross))}</td>
                    <td className="text-right tabular-nums">{brl(Number(r.total_deductions))}</td>
                    <td className="text-right tabular-nums font-medium">{brl(Number(r.total_net))}</td>
                    <td className="text-right tabular-nums">{brl(Number(r.total_employer))}</td>
                    <td><span className={`badge ${PBADGE[r.status]}`}>{PSTATUS[r.status] ?? r.status}</span></td>
                    <td className="text-right whitespace-nowrap">
                      <button onClick={() => setExpand(expand === r.id ? null : r.id)} className="text-xs text-brand-600 hover:underline mr-2">ver</button>
                      {r.status === "calculated" && <button onClick={() => approve(r.id)} disabled={busy === r.id} className="btn btn-primary btn-sm">Aprovar (GL)</button>}
                      {r.journal_ref && <span className="badge badge-success ml-1">no GL</span>}
                    </td>
                  </tr>
                  {expand === r.id && (
                    <tr><td colSpan={8} className="surface-2"><div className="p-3 overflow-x-auto">
                      <table className="tbl"><thead><tr><th>Colaborador</th><th className="text-right">Bruto</th><th className="text-right">INSS</th><th className="text-right">IRRF</th><th className="text-right">FGTS</th><th className="text-right">Líquido</th></tr></thead>
                        <tbody>{items.filter((it) => it.run_id === r.id).map((it) => (
                          <tr key={it.id}><td>{empName(it.employee_id)}</td><td className="text-right tabular-nums">{brl(Number(it.gross))}</td><td className="text-right tabular-nums">{brl(Number(it.inss))}</td><td className="text-right tabular-nums">{brl(Number(it.irrf))}</td><td className="text-right tabular-nums">{brl(Number(it.fgts))}</td><td className="text-right tabular-nums font-medium">{brl(Number(it.net))}</td></tr>
                        ))}</tbody></table>
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

function Ponto({ entries, employees, empName }: { entries: any[]; employees: any[]; empName: (id: string) => string }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [f, setF] = useState({ employee: "", date: new Date().toISOString().slice(0, 10), hours: "8", overtime: "0" });
  const [busy, setBusy] = useState(false);
  async function register() {
    if (!supabase || !f.employee) return;
    setBusy(true);
    await supabase.rpc("register_time", { p_employee: f.employee, p_date: f.date, p_hours: Number(f.hours) || 0, p_overtime: Number(f.overtime) || 0, p_source: "app", p_absence: false });
    setBusy(false); setF((p) => ({ ...p, hours: "8", overtime: "0" })); router.refresh();
  }
  return (
    <div className="space-y-3">
      <div className="card p-4 grid md:grid-cols-5 gap-3 items-end">
        <div className="md:col-span-2"><label className="label">Colaborador</label><select value={f.employee} onChange={(e) => setF((p) => ({ ...p, employee: e.target.value }))} className="select"><option value="">—</option>{employees.filter((e) => e.status !== "terminated").map((e) => <option key={e.id} value={e.id}>{e.full_name}</option>)}</select></div>
        <div><label className="label">Data</label><input type="date" value={f.date} onChange={(e) => setF((p) => ({ ...p, date: e.target.value }))} className="input" /></div>
        <div><label className="label">Horas</label><input type="number" value={f.hours} onChange={(e) => setF((p) => ({ ...p, hours: e.target.value }))} className="input" /></div>
        <div><label className="label">Extras</label><input type="number" value={f.overtime} onChange={(e) => setF((p) => ({ ...p, overtime: e.target.value }))} className="input" /></div>
        <button onClick={register} disabled={busy || !f.employee} className="btn btn-primary btn-sm md:col-span-5 md:w-40">Registrar ponto</button>
      </div>
      {entries.length === 0 ? <p className="text-sm muted px-1">Nenhum registro de ponto.</p> : (
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Colaborador</th><th>Data</th><th className="text-right">Horas</th><th className="text-right">Extras</th><th>Origem</th></tr></thead>
          <tbody>{entries.map((t) => (<tr key={t.id}><td>{empName(t.employee_id)}</td><td className="tabular-nums">{t.entry_date}</td><td className="text-right tabular-nums">{Number(t.hours_worked)}</td><td className="text-right tabular-nums">{Number(t.overtime_hours)}</td><td className="uppercase text-xs muted">{t.source}</td></tr>))}</tbody>
        </table></div>
      )}
    </div>
  );
}

function BancoHoras({ movements, empName }: { movements: any[]; empName: (id: string) => string }) {
  const byEmp = useMemo(() => {
    const m: Record<string, number> = {};
    movements.forEach((x) => { m[x.employee_id] = (m[x.employee_id] || 0) + Number(x.hours); });
    return Object.entries(m);
  }, [movements]);
  return (
    <div className="space-y-3">
      {byEmp.length > 0 && (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {byEmp.map(([id, h]) => (
            <div key={id} className="kpi"><div className="kpi-label">{empName(id)}</div><div className="kpi-value tabular-nums" style={{ color: Math.abs(h) > 40 ? "var(--warning)" : h >= 0 ? "var(--success)" : "var(--danger)" }}>{h > 0 ? "+" : ""}{h}h</div></div>
          ))}
        </div>
      )}
      {movements.length === 0 ? <p className="text-sm muted px-1">Sem movimentos no banco de horas.</p> : (
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Colaborador</th><th>Data</th><th className="text-right">Horas</th><th>Motivo</th></tr></thead>
          <tbody>{movements.map((m) => (<tr key={m.id}><td>{empName(m.employee_id)}</td><td className="tabular-nums">{m.movement_date}</td><td className="text-right tabular-nums" style={{ color: Number(m.hours) >= 0 ? "var(--success)" : "var(--danger)" }}>{Number(m.hours) > 0 ? "+" : ""}{Number(m.hours)}</td><td>{m.reason}</td></tr>))}</tbody>
        </table></div>
      )}
    </div>
  );
}

function Rescisoes({ terminations, employees, empName }: { terminations: any[]; employees: any[]; empName: (id: string) => string }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [f, setF] = useState({ employee: "", reason: "dismissal_without_cause" });
  const [busy, setBusy] = useState(false);
  const [res, setRes] = useState<any>(null);
  async function compute() {
    if (!supabase || !f.employee) return;
    setBusy(true);
    const { data } = await supabase.rpc("compute_termination", { p_employee: f.employee, p_reason: f.reason, p_date: null });
    setBusy(false); setRes(data); setF({ employee: "", reason: "dismissal_without_cause" }); router.refresh();
  }
  const REASON: Record<string, string> = { dismissal_without_cause: "Sem justa causa", dismissal_with_cause: "Com justa causa", resignation: "Pedido de demissão", agreement: "Acordo", end_contract: "Fim de contrato" };
  return (
    <div className="space-y-3">
      <div className="card p-4 grid md:grid-cols-4 gap-3 items-end">
        <div className="md:col-span-2"><label className="label">Colaborador</label><select value={f.employee} onChange={(e) => setF((p) => ({ ...p, employee: e.target.value }))} className="select"><option value="">—</option>{employees.filter((e) => e.status !== "terminated").map((e) => <option key={e.id} value={e.id}>{e.full_name}</option>)}</select></div>
        <div><label className="label">Motivo</label><select value={f.reason} onChange={(e) => setF((p) => ({ ...p, reason: e.target.value }))} className="select">{Object.entries(REASON).map(([v, l]) => <option key={v} value={v}>{l}</option>)}</select></div>
        <button onClick={compute} disabled={busy || !f.employee} className="btn btn-danger btn-sm">Calcular rescisão</button>
      </div>
      {res && <div className="card p-4 text-sm"><div className="font-semibold mb-1">{res.employee}</div>Saldo salário R$ {brl(Number(res.salary_balance))} · 13º R$ {brl(Number(res.thirteenth))} · Férias R$ {brl(Number(res.vacation))} · Multa FGTS R$ {brl(Number(res.fgts_fine))} · <strong>Total R$ {brl(Number(res.total))}</strong></div>}
      {terminations.length > 0 && (
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Colaborador</th><th>Data</th><th>Motivo</th><th className="text-right">Total</th></tr></thead>
          <tbody>{terminations.map((t) => (<tr key={t.id}><td>{empName(t.employee_id)}</td><td className="tabular-nums">{t.termination_date}</td><td>{REASON[t.reason] ?? t.reason}</td><td className="text-right tabular-nums font-medium">{brl(Number(t.total_amount))}</td></tr>))}</tbody>
        </table></div>
      )}
    </div>
  );
}
