"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const brl = (n: number) => (n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const k = (n: number) => (n ?? 0).toLocaleString("pt-BR", { maximumFractionDigits: 0 });
const CAND_STAGES: [string, string][] = [["applied","Inscritos"],["screening","Triagem"],["interview","Entrevista"],["test","Teste"],["offer","Proposta"],["hired","Contratado"],["rejected","Recusado"]];
const OFF_TYPE: Record<string, string> = { vacation: "Férias", sick: "Atestado", maternity: "Maternidade", paternity: "Paternidade", unpaid: "Sem venc.", other: "Outro" };

const TABS = ["Painel","Colaboradores","Organograma","Recrutamento","Férias & Ausências","Treinamentos","Competências","Benefícios","Cargos & Deptos"] as const;
type Tab = typeof TABS[number];

export default function HCMWorkbench({ dash, employees, departments, positions, vacancies, candidates, timeoff, reviews, trainings, records, competencies, benefits }: {
  dash: any; employees: any[]; departments: any[]; positions: any[]; vacancies: any[]; candidates: any[]; timeoff: any[]; reviews: any[]; trainings: any[]; records: any[]; competencies: any[]; benefits: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  const empName = (id: string) => employees.find((e) => e.id === id)?.full_name ?? "—";
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Capital Humano</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Recursos Humanos (HCM)</h1>
        <p className="text-sm muted mt-0.5">Colaboradores, organograma, recrutamento, férias, desempenho, treinamentos (BPF) e People Analytics.</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Colaboradores" && (
        <CrudPanel table="employees" title="Colaboradores"
          fields={[
            { key: "full_name", label: "Nome completo", required: true },
            { key: "document", label: "CPF" }, { key: "email", label: "E-mail" }, { key: "phone", label: "Telefone" },
            { key: "birth_date", label: "Nascimento", type: "date" },
            { key: "position_id", label: "Cargo", type: "fk", fkTable: "positions", fkLabel: "title" },
            { key: "department_id", label: "Departamento", type: "fk", fkTable: "departments", fkLabel: "name" },
            { key: "manager_id", label: "Gestor", type: "fk", fkTable: "employees", fkLabel: "full_name" },
            { key: "hire_date", label: "Admissão", type: "date" },
            { key: "salary", label: "Salário", type: "number" },
            { key: "employment_type", label: "Vínculo", type: "select", options: [["clt","CLT"],["pj","PJ"],["intern","Estágio"],["temp","Temporário"]], default: "clt" },
            { key: "status", label: "Status", type: "select", options: [["active","Ativo"],["on_leave","Afastado"],["vacation","Férias"],["terminated","Desligado"]], default: "active" },
          ]}
          columns={[
            { key: "registration", label: "Matrícula" }, { key: "full_name", label: "Nome" },
            { key: "position_id", label: "Cargo" }, { key: "department_id", label: "Depto" },
            { key: "salary", label: "Salário", fmt: (v) => v ? brl(Number(v)) : "—" }, { key: "status", label: "Status" },
          ]}
          rows={employees} emptyHint="Cadastre os colaboradores." />
      )}
      {tab === "Organograma" && <Organograma employees={employees} departments={departments} />}
      {tab === "Recrutamento" && <Recrutamento vacancies={vacancies} candidates={candidates} positions={positions} departments={departments} />}
      {tab === "Férias & Ausências" && <Ferias timeoff={timeoff} employees={employees} empName={empName} />}
      {tab === "Treinamentos" && <Treinamentos trainings={trainings} records={records} empName={empName} />}
      {tab === "Competências" && (
        <CrudPanel table="employee_competencies" title="Matriz de Competências"
          fields={[
            { key: "employee_id", label: "Colaborador", type: "fk", fkTable: "employees", fkLabel: "full_name", required: true },
            { key: "competency_id", label: "Competência", type: "fk", fkTable: "competencies", fkLabel: "name", required: true },
            { key: "level", label: "Nível (1-5)", type: "number", default: "1" },
            { key: "target_level", label: "Nível alvo", type: "number" },
            { key: "assessed_at", label: "Avaliado em", type: "date" },
          ]}
          columns={[{ key: "employee_id", label: "Colaborador" }, { key: "competency_id", label: "Competência" }, { key: "level", label: "Nível" }, { key: "target_level", label: "Alvo" }]}
          rows={competencies.length ? competencies : []} emptyHint="Mapeie competências por colaborador (técnicas, comportamentais, por máquina/processo)." />
      )}
      {tab === "Benefícios" && (
        <CrudPanel table="employee_benefits" title="Benefícios"
          fields={[
            { key: "employee_id", label: "Colaborador", type: "fk", fkTable: "employees", fkLabel: "full_name", required: true },
            { key: "benefit_type", label: "Benefício", type: "select", options: [["health","Plano de Saúde"],["dental","Odontológico"],["meal","Vale Refeição"],["food","Vale Alimentação"],["transport","Vale Transporte"],["life","Seguro de Vida"],["pension","Previdência"]], required: true },
            { key: "provider", label: "Operadora" },
            { key: "monthly_value", label: "Valor mensal", type: "number" },
            { key: "employee_share", label: "Coparticipação", type: "number" },
          ]}
          columns={[{ key: "employee_id", label: "Colaborador" }, { key: "benefit_type", label: "Benefício" }, { key: "provider", label: "Operadora" }, { key: "monthly_value", label: "Valor", fmt: (v) => v ? brl(Number(v)) : "—" }]}
          rows={benefits} emptyHint="Plano de saúde, VR/VA, VT, seguro de vida, previdência." />
      )}
      {tab === "Cargos & Deptos" && (
        <div className="grid lg:grid-cols-2 gap-4">
          <CrudPanel table="positions" title="Cargos"
            fields={[
              { key: "title", label: "Cargo", required: true },
              { key: "level", label: "Nível", type: "select", options: [["executive","Executivo"],["management","Gerência"],["coordination","Coordenação"],["technical","Técnico"],["commercial","Comercial"],["operational","Operacional"]] },
              { key: "salary_min", label: "Salário mín.", type: "number" }, { key: "salary_max", label: "Salário máx.", type: "number" }, { key: "cbo", label: "CBO" },
            ]}
            columns={[{ key: "title", label: "Cargo" }, { key: "level", label: "Nível" }, { key: "cbo", label: "CBO" }]}
            rows={positions} emptyHint="Cadastre os cargos." />
          <CrudPanel table="departments" title="Departamentos"
            fields={[
              { key: "name", label: "Nome", required: true }, { key: "code", label: "Código" },
              { key: "parent_id", label: "Departamento pai", type: "fk", fkTable: "departments", fkLabel: "name" },
              { key: "manager_name", label: "Gestor" },
            ]}
            columns={[{ key: "name", label: "Departamento" }, { key: "code", label: "Código" }, { key: "manager_name", label: "Gestor" }]}
            rows={departments} emptyHint="Estrutura organizacional." />
        </div>
      )}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash }: { dash: any }) {
  const d = dash ?? {};
  const bd: Record<string, number> = d.by_department ?? {};
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <KPI label="Headcount" value={String(d.headcount ?? 0)} />
        <KPI label="Folha mensal" value={`R$ ${k(Number(d.payroll_monthly ?? 0))}`} tone="var(--brand)" />
        <KPI label="Em férias / afastados" value={String(d.on_leave ?? 0)} />
        <KPI label="Tempo médio de casa" value={`${d.avg_tenure_years ?? 0} anos`} />
        <KPI label="Vagas abertas" value={String(d.open_vacancies ?? 0)} hint={`${d.candidates ?? 0} candidatos`} />
        <KPI label="Férias a aprovar" value={String(d.time_off_pending ?? 0)} tone={d.time_off_pending ? "var(--warning)" : undefined} />
        <KPI label="Avaliações pendentes" value={String(d.reviews_pending ?? 0)} />
        <KPI label="Desligamentos (ano)" value={String(d.terminated_ytd ?? 0)} />
      </div>
      <div className="card p-5">
        <div className="font-semibold mb-3">Headcount por departamento</div>
        {Object.keys(bd).length === 0 ? <p className="text-sm muted">Sem colaboradores.</p> : (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            {Object.entries(bd).map(([dep, c]) => (
              <div key={dep} className="surface-2 rounded-xl p-3" style={{ border: "1px solid var(--border)" }}><div className="text-xs muted font-semibold">{dep}</div><div className="text-lg font-bold tabular-nums mt-1">{c}</div></div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function Organograma({ employees, departments }: { employees: any[]; departments: any[] }) {
  const active = employees.filter((e) => e.status !== "terminated");
  const byDept = departments.map((d) => ({ dept: d, members: active.filter((e) => e.department_id === d.id) })).filter((x) => x.members.length > 0);
  const noDept = active.filter((e) => !e.department_id);
  const posName = (e: any) => e.position_id ? "" : "";
  return (
    <div className="space-y-3">
      {byDept.length === 0 && noDept.length === 0 && <p className="text-sm muted px-1">Sem colaboradores cadastrados.</p>}
      {byDept.map(({ dept, members }) => (
        <div key={dept.id} className="card p-4">
          <div className="font-semibold mb-2">{dept.name} <span className="badge badge-neutral ml-1">{members.length}</span></div>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
            {members.map((e: any) => (
              <div key={e.id} className="flex items-center gap-2 surface-2 rounded-xl p-2" style={{ border: "1px solid var(--border)" }}>
                <span className="h-8 w-8 rounded-full grid place-items-center text-white text-xs font-bold shrink-0" style={{ background: "linear-gradient(150deg,#2f56e6,#1a336f)" }}>{(e.full_name?.[0] ?? "?").toUpperCase()}</span>
                <div className="min-w-0"><div className="text-sm font-medium truncate">{e.full_name}</div><div className="text-[11px] muted truncate">{e.registration} · {e.status}</div></div>
              </div>
            ))}
          </div>
        </div>
      ))}
      {noDept.length > 0 && <div className="card p-4"><div className="font-semibold mb-2">Sem departamento</div><div className="text-sm muted">{noDept.map((e) => e.full_name).join(", ")}</div></div>}
    </div>
  );
}

function Recrutamento({ vacancies, candidates, positions, departments }: { vacancies: any[]; candidates: any[]; positions: any[]; departments: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [hiring, setHiring] = useState<string | null>(null);
  const [hf, setHf] = useState({ position: "", department: "", salary: "" });
  const [busy, setBusy] = useState(false);

  async function move(id: string, stage: string) {
    if (!supabase) return;
    await supabase.from("candidates").update({ stage }).eq("id", id);
    router.refresh();
  }
  async function hire(id: string) {
    if (!supabase) return;
    setBusy(true);
    await supabase.rpc("hire_candidate", { p_candidate: id, p_position: hf.position || null, p_department: hf.department || null, p_salary: Number(hf.salary) || null, p_hire_date: null });
    setBusy(false); setHiring(null); setHf({ position: "", department: "", salary: "" }); router.refresh();
  }
  const stages = CAND_STAGES.filter(([s]) => !["hired", "rejected"].includes(s));

  return (
    <div className="space-y-4">
      <CrudPanel table="job_vacancies" title="Vagas"
        fields={[
          { key: "title", label: "Título da vaga", required: true },
          { key: "department_id", label: "Departamento", type: "fk", fkTable: "departments", fkLabel: "name" },
          { key: "position_id", label: "Cargo", type: "fk", fkTable: "positions", fkLabel: "title" },
          { key: "openings", label: "Vagas", type: "number", default: "1" },
          { key: "salary_range", label: "Faixa salarial" },
          { key: "status", label: "Status", type: "select", options: [["open","Aberta"],["closed","Fechada"],["paused","Pausada"]], default: "open" },
          { key: "requirements", label: "Requisitos" },
        ]}
        columns={[{ key: "title", label: "Vaga" }, { key: "openings", label: "Vagas" }, { key: "salary_range", label: "Faixa" }, { key: "status", label: "Status" }]}
        rows={vacancies} emptyHint="Abra vagas para receber candidatos." />

      <div className="flex gap-3 overflow-x-auto pb-2">
        {stages.map(([s, label]) => {
          const list = candidates.filter((c) => c.stage === s);
          return (
            <div key={s} className="shrink-0 w-56">
              <div className="flex items-center justify-between px-1 mb-2"><div className="text-sm font-semibold">{label}</div><span className="badge badge-neutral">{list.length}</span></div>
              <div className="space-y-2">
                {list.map((c) => (
                  <div key={c.id} className="card p-3">
                    <div className="font-medium text-sm">{c.full_name}</div>
                    <div className="text-xs muted">{c.source ?? "—"}</div>
                    {hiring === c.id ? (
                      <div className="mt-2 space-y-1.5">
                        <select value={hf.position} onChange={(e) => setHf((p) => ({ ...p, position: e.target.value }))} className="select h-8 text-xs"><option value="">Cargo…</option>{positions.map((p) => <option key={p.id} value={p.id}>{p.title}</option>)}</select>
                        <select value={hf.department} onChange={(e) => setHf((p) => ({ ...p, department: e.target.value }))} className="select h-8 text-xs"><option value="">Depto…</option>{departments.map((d) => <option key={d.id} value={d.id}>{d.name}</option>)}</select>
                        <input type="number" value={hf.salary} onChange={(e) => setHf((p) => ({ ...p, salary: e.target.value }))} className="input h-8 text-xs" placeholder="Salário" />
                        <button onClick={() => hire(c.id)} disabled={busy} className="btn btn-primary btn-sm w-full">Confirmar</button>
                      </div>
                    ) : (
                      <div className="mt-2 flex gap-1">
                        <select value="" onChange={(e) => e.target.value && move(c.id, e.target.value)} className="select h-8 text-xs flex-1"><option value="">mover…</option>{CAND_STAGES.filter(([x]) => x !== c.stage).map(([x, l]) => <option key={x} value={x}>{l}</option>)}</select>
                        {s === "offer" && <button onClick={() => setHiring(c.id)} className="btn btn-primary btn-sm">Contratar</button>}
                      </div>
                    )}
                  </div>
                ))}
                {list.length === 0 && <div className="text-xs muted px-1 py-3 text-center rounded-xl" style={{ border: "1px dashed var(--border)" }}>—</div>}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function Ferias({ timeoff, employees, empName }: { timeoff: any[]; employees: any[]; empName: (id: string) => string }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [f, setF] = useState({ employee: "", type: "vacation", start: "", end: "" });
  const [busy, setBusy] = useState(false);
  async function request() {
    if (!supabase || !f.employee || !f.start || !f.end) return;
    setBusy(true);
    await supabase.rpc("request_time_off", { p_employee: f.employee, p_type: f.type, p_start: f.start, p_end: f.end, p_reason: null });
    setBusy(false); setF({ employee: "", type: "vacation", start: "", end: "" }); router.refresh();
  }
  async function decide(id: string, ok: boolean) {
    if (!supabase) return;
    await supabase.rpc("decide_time_off", { p_request: id, p_approve: ok });
    router.refresh();
  }
  const badge = (s: string) => ({ requested: "badge-warning", approved: "badge-success", rejected: "badge-danger", canceled: "badge-neutral" } as any)[s] ?? "badge-neutral";
  return (
    <div className="space-y-3">
      <div className="card p-4 grid md:grid-cols-5 gap-3 items-end">
        <div className="md:col-span-2"><label className="label">Colaborador</label><select value={f.employee} onChange={(e) => setF((p) => ({ ...p, employee: e.target.value }))} className="select"><option value="">—</option>{employees.filter((e) => e.status !== "terminated").map((e) => <option key={e.id} value={e.id}>{e.full_name}</option>)}</select></div>
        <div><label className="label">Tipo</label><select value={f.type} onChange={(e) => setF((p) => ({ ...p, type: e.target.value }))} className="select">{Object.entries(OFF_TYPE).map(([v, l]) => <option key={v} value={v}>{l}</option>)}</select></div>
        <div><label className="label">Início</label><input type="date" value={f.start} onChange={(e) => setF((p) => ({ ...p, start: e.target.value }))} className="input" /></div>
        <div><label className="label">Fim</label><input type="date" value={f.end} onChange={(e) => setF((p) => ({ ...p, end: e.target.value }))} className="input" /></div>
        <button onClick={request} disabled={busy || !f.employee} className="btn btn-primary btn-sm md:col-span-5 md:w-48">Solicitar</button>
      </div>
      {timeoff.length === 0 ? <p className="text-sm muted px-1">Nenhuma solicitação.</p> : (
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Colaborador</th><th>Tipo</th><th>Período</th><th>Dias</th><th>Status</th><th></th></tr></thead>
          <tbody>{timeoff.map((t) => (
            <tr key={t.id}>
              <td>{empName(t.employee_id)}</td><td>{OFF_TYPE[t.time_off_type] ?? t.time_off_type}</td>
              <td className="tabular-nums text-xs">{t.start_date} → {t.end_date}</td><td className="tabular-nums">{t.days}</td>
              <td><span className={`badge ${badge(t.status)}`}>{t.status}</span></td>
              <td className="text-right whitespace-nowrap">{t.status === "requested" && (<><button onClick={() => decide(t.id, true)} className="btn btn-primary btn-sm mr-1">Aprovar</button><button onClick={() => decide(t.id, false)} className="text-xs font-semibold hover:underline" style={{ color: "var(--danger)" }}>rejeitar</button></>)}</td>
            </tr>
          ))}</tbody>
        </table></div>
      )}
    </div>
  );
}

function Treinamentos({ trainings, records, empName }: { trainings: any[]; records: any[]; empName: (id: string) => string }) {
  const trName = (id: string) => trainings.find((t) => t.id === id)?.name ?? "—";
  const expiry = (r: any) => {
    if (!r.expires_at) return { label: "sem validade", cls: "badge-neutral" };
    const d = new Date(r.expires_at); const now = new Date();
    if (d < now) return { label: "vencido", cls: "badge-danger" };
    if (d.getTime() - now.getTime() < 30 * 864e5) return { label: "vence em breve", cls: "badge-warning" };
    return { label: "válido", cls: "badge-success" };
  };
  return (
    <div className="space-y-4">
      <div className="grid lg:grid-cols-2 gap-4">
        <CrudPanel table="hr_trainings" title="Catálogo de Treinamentos"
          fields={[
            { key: "name", label: "Treinamento", required: true },
            { key: "category", label: "Categoria" },
            { key: "is_mandatory", label: "Obrigatório?", type: "select", options: [["true","Sim (BPF/NR)"],["false","Não"]], default: "false" },
            { key: "valid_months", label: "Validade (meses)", type: "number" },
            { key: "workload_hours", label: "Carga horária", type: "number" },
          ]}
          columns={[{ key: "name", label: "Treinamento" }, { key: "category", label: "Categoria" }, { key: "is_mandatory", label: "Obrig.", fmt: (v) => v ? "Sim" : "—" }, { key: "valid_months", label: "Validade (m)" }]}
          rows={trainings} emptyHint="BPF, NR, operação de máquinas, LGPD…" />
        <CrudPanel table="hr_training_records" title="Realizações"
          fields={[
            { key: "employee_id", label: "Colaborador", type: "fk", fkTable: "employees", fkLabel: "full_name", required: true },
            { key: "training_id", label: "Treinamento", type: "fk", fkTable: "hr_trainings", fkLabel: "name", required: true },
            { key: "completed_at", label: "Concluído em", type: "date" },
            { key: "expires_at", label: "Vence em", type: "date" },
            { key: "score", label: "Nota", type: "number" },
          ]}
          columns={[
            { key: "employee_id", label: "Colaborador" }, { key: "training_id", label: "Treinamento" },
            { key: "completed_at", label: "Concluído" }, { key: "expires_at", label: "Vence" },
          ]}
          rows={records} emptyHint="Registre treinamentos realizados por colaborador." />
      </div>
      {records.length > 0 && (
        <div className="card p-4">
          <div className="font-semibold text-sm mb-2">Situação das certificações</div>
          <div className="space-y-1.5">
            {records.map((r) => { const ex = expiry(r); return (
              <div key={r.id} className="flex items-center gap-2 text-sm">
                <span className="flex-1">{empName(r.employee_id)} · <span className="muted">{trName(r.training_id)}</span></span>
                <span className="text-xs muted tabular-nums">{r.expires_at ?? "—"}</span>
                <span className={`badge ${ex.cls}`}>{ex.label}</span>
              </div>
            ); })}
          </div>
        </div>
      )}
    </div>
  );
}
