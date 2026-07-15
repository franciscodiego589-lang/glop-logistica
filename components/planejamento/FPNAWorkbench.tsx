"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const brl = (n: number) => (n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const k = (n: number) => (n ?? 0).toLocaleString("pt-BR", { maximumFractionDigits: 0 });
const GOAL_STATUS: [string, string][] = [["on_track","No trilho"],["at_risk","Em risco"],["off_track","Fora do trilho"],["done","Concluída"]];

const TABS = ["Painel","Cenários (Digital Twin)","Forecast","Investimentos","Orçamento","Budget × Realizado","Metas & OKRs"] as const;
type Tab = typeof TABS[number];

export default function FPNAWorkbench({ dash, scenarios, budgets, goals, investments, bva }: {
  dash: any; scenarios: any[]; budgets: any[]; goals: any[]; investments: any[]; bva: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Inteligência Estratégica</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Planejamento & Performance (FP&A)</h1>
        <p className="text-sm muted mt-0.5">Orçamento, forecast, cenários (digital twin financeiro), metas/OKRs e análise de investimentos — sobre os dados reais do ERP.</p>
      </div>

      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Cenários (Digital Twin)" && <Cenarios scenarios={scenarios} />}
      {tab === "Forecast" && <Forecast />}
      {tab === "Investimentos" && <Investimentos investments={investments} />}
      {tab === "Orçamento" && <Orcamento budgets={budgets} />}
      {tab === "Budget × Realizado" && <BudgetVsActual bva={bva} />}
      {tab === "Metas & OKRs" && <Metas goals={goals} />}
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
      <KPI label="Receita (12m real)" value={`R$ ${k(Number(d.revenue_12m ?? 0))}`} tone="var(--success)" />
      <KPI label="Cenários" value={String(d.scenarios ?? 0)} />
      <KPI label="Orçamentos" value={String(d.budgets ?? 0)} />
      <KPI label="Melhor VPL" value={d.best_npv != null ? `R$ ${k(Number(d.best_npv))}` : "—"} tone="var(--brand)" />
      <KPI label="Metas / OKRs" value={String(d.goals_total ?? 0)} />
      <KPI label="Metas em risco" value={String(d.goals_at_risk ?? 0)} tone={d.goals_at_risk ? "var(--danger)" : undefined} />
      <KPI label="Metas concluídas" value={String(d.goals_done ?? 0)} tone="var(--success)" />
      <KPI label="Investimentos" value={String(d.investments ?? 0)} />
    </div>
  );
}

// ── Cenários / Digital Twin ─────────────────────────────────────────────────
function Cenarios({ scenarios }: { scenarios: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const [proj, setProj] = useState<any>(null);
  const [busy, setBusy] = useState<string | null>(null);
  async function project(id: string) {
    if (!supabase) return;
    setBusy(id); setProj(null);
    const { data } = await supabase.rpc("project_scenario", { p_company: COMPANY, p_scenario: id });
    setBusy(null); setProj(data);
  }
  const maxEbitda = proj ? Math.max(...(proj.series ?? []).map((s: any) => Math.abs(Number(s.ebitda))), 1) : 1;
  return (
    <div className="space-y-4">
      <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-3">
        {scenarios.map((s) => (
          <div key={s.id} className="card p-4 card-hover">
            <div className="flex items-center justify-between">
              <div className="font-semibold">{s.name}</div>
              <span className="badge badge-neutral">{s.scenario_type}</span>
            </div>
            <div className="text-xs muted mt-1">Horizonte: {s.horizon_months} meses</div>
            <div className="text-xs muted mt-2 space-y-0.5">
              <div>Receita: {Number(s.assumptions?.revenue_growth_pct ?? 0) >= 0 ? "+" : ""}{s.assumptions?.revenue_growth_pct ?? 0}%/mês</div>
              <div>Custo: {Number(s.assumptions?.cost_growth_pct ?? 0) >= 0 ? "+" : ""}{s.assumptions?.cost_growth_pct ?? 0}%/mês</div>
            </div>
            <button onClick={() => project(s.id)} disabled={busy === s.id} className="btn btn-primary btn-sm w-full mt-3">{busy === s.id ? "Projetando…" : "Projetar (Digital Twin)"}</button>
          </div>
        ))}
      </div>

      {proj && (
        <div className="card p-5">
          <div className="flex flex-wrap items-baseline justify-between gap-2 mb-3">
            <div className="font-semibold">Projeção — {proj.scenario}</div>
            <div className="flex gap-4 text-sm">
              <span>Receita total: <strong className="tabular-nums">R$ {brl(Number(proj.total_revenue))}</strong></span>
              <span>EBITDA total: <strong className="tabular-nums" style={{ color: Number(proj.total_ebitda) >= 0 ? "var(--success)" : "var(--danger)" }}>R$ {brl(Number(proj.total_ebitda))}</strong></span>
              <span>Margem: <strong>{proj.ebitda_margin}%</strong></span>
            </div>
          </div>
          <div className="flex items-end gap-1 h-40 mb-2">
            {(proj.series ?? []).map((s: any) => {
              const h = Math.max((Math.abs(Number(s.ebitda)) / maxEbitda) * 100, 2);
              return (
                <div key={s.month} className="flex-1 flex flex-col items-center justify-end gap-1" title={`Mês ${s.month}: EBITDA R$ ${brl(Number(s.ebitda))}`}>
                  <div className="w-full rounded-t" style={{ height: `${h}%`, background: Number(s.ebitda) >= 0 ? "var(--brand)" : "var(--danger)", minHeight: 4 }} />
                  <div className="text-[10px] muted">{s.month}</div>
                </div>
              );
            })}
          </div>
          <div className="text-xs muted">EBITDA projetado por mês (base: média dos últimos 12 meses reais do GL + premissas do cenário).</div>
        </div>
      )}
    </div>
  );
}

function Forecast() {
  const supabase = useMemo(() => createClient(), []);
  const [data, setData] = useState<any>(null);
  const [busy, setBusy] = useState(false);
  async function run() {
    if (!supabase) return;
    setBusy(true);
    const { data: d } = await supabase.rpc("generate_forecast", { p_company: COMPANY, p_months: 6 });
    setBusy(false); setData(d);
  }
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Forecast (regressão sobre o GL real)</div>
        <button onClick={run} disabled={busy} className="btn btn-primary btn-sm">{busy ? "Gerando…" : "Gerar forecast 6 meses"}</button>
      </div>
      {!data ? <p className="text-sm muted px-1">Clique para projetar receita e despesa com base no histórico contábil.</p> : (
        <div className="space-y-3">
          <span className="badge badge-brand">método: {data.method}</span>
          <div className="grid md:grid-cols-2 gap-4">
            <div className="card p-4">
              <div className="font-semibold text-sm mb-2">Histórico (real)</div>
              {(data.history ?? []).length === 0 ? <p className="text-sm muted">Sem histórico contábil ainda.</p> : (
                <table className="tbl"><thead><tr><th>Período</th><th className="text-right">Receita</th><th className="text-right">Despesa</th></tr></thead>
                  <tbody>{data.history.map((h: any) => <tr key={h.period}><td>{h.period}</td><td className="text-right tabular-nums">{brl(Number(h.revenue))}</td><td className="text-right tabular-nums">{brl(Number(h.expense))}</td></tr>)}</tbody></table>
              )}
            </div>
            <div className="card p-4">
              <div className="font-semibold text-sm mb-2">Projeção</div>
              <table className="tbl"><thead><tr><th>Mês</th><th className="text-right">Receita</th><th className="text-right">Despesa</th><th className="text-right">Resultado</th></tr></thead>
                <tbody>{(data.forecast ?? []).map((f: any) => <tr key={f.period}><td>{f.period}</td><td className="text-right tabular-nums">{brl(Number(f.revenue))}</td><td className="text-right tabular-nums">{brl(Number(f.expense))}</td><td className="text-right tabular-nums font-medium" style={{ color: Number(f.net) >= 0 ? "var(--success)" : "var(--danger)" }}>{brl(Number(f.net))}</td></tr>)}</tbody></table>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ── Investimentos ───────────────────────────────────────────────────────────
function Investimentos({ investments }: { investments: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [f, setF] = useState({ name: "", capex: "100000", rate: "12", flows: "30000, 30000, 30000, 30000, 30000" });
  const [res, setRes] = useState<any>(null);
  const [busy, setBusy] = useState(false);
  const parseFlows = () => f.flows.split(",").map((x) => Number(x.trim()) || 0).filter((_, i, a) => i < a.length);
  async function calc() {
    if (!supabase) return;
    setBusy(true);
    const { data } = await supabase.rpc("evaluate_investment", { p_capex: Number(f.capex) || 0, p_cashflows: parseFlows(), p_discount_rate: Number(f.rate) || 0 });
    setBusy(false); setRes(data);
  }
  async function save() {
    if (!supabase || !f.name) return;
    setBusy(true);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    await supabase.from("investment_cases").insert({
      tenant_id: (comp as any)?.tenant_id, company_id: COMPANY, name: f.name, capex: Number(f.capex) || 0,
      discount_rate: Number(f.rate) || 0, cashflows: parseFlows(),
      npv: res?.npv, irr: res?.irr, payback_periods: res?.payback, roi: res?.roi,
    });
    setBusy(false); router.refresh();
  }
  return (
    <div className="space-y-4">
      <div className="grid lg:grid-cols-2 gap-4">
        <div className="card p-4 space-y-3">
          <div className="font-semibold">Análise de investimento</div>
          <div><label className="label">Nome do projeto</label><input value={f.name} onChange={(e) => setF((p) => ({ ...p, name: e.target.value }))} className="input" placeholder="Nova linha de gummies" /></div>
          <div className="grid grid-cols-2 gap-3">
            <div><label className="label">CAPEX (investimento)</label><input type="number" value={f.capex} onChange={(e) => setF((p) => ({ ...p, capex: e.target.value }))} className="input" /></div>
            <div><label className="label">Taxa de desconto %</label><input type="number" value={f.rate} onChange={(e) => setF((p) => ({ ...p, rate: e.target.value }))} className="input" /></div>
          </div>
          <div><label className="label">Fluxos de caixa por período (separados por vírgula)</label><input value={f.flows} onChange={(e) => setF((p) => ({ ...p, flows: e.target.value }))} className="input" /></div>
          <div className="flex gap-2">
            <button onClick={calc} disabled={busy} className="btn btn-primary btn-sm">Calcular</button>
            {res && <button onClick={save} disabled={busy || !f.name} className="btn btn-sm">Salvar business case</button>}
          </div>
        </div>
        <div className="card p-5">
          <div className="font-semibold mb-2">Resultado</div>
          {!res ? <p className="text-sm muted">Preencha e calcule VPL, TIR, payback e ROI.</p> : (
            <div className="grid grid-cols-2 gap-3">
              <Metric label="VPL (NPV)" value={`R$ ${brl(Number(res.npv))}`} tone={Number(res.npv) >= 0 ? "var(--success)" : "var(--danger)"} />
              <Metric label="TIR (IRR)" value={res.irr != null ? `${res.irr}%` : "—"} tone="var(--brand)" />
              <Metric label="Payback" value={res.payback != null ? `${res.payback} períodos` : "—"} />
              <Metric label="ROI" value={res.roi != null ? `${res.roi}%` : "—"} tone={Number(res.roi) >= 0 ? "var(--success)" : "var(--danger)"} />
            </div>
          )}
        </div>
      </div>
      {investments.length > 0 && (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl"><thead><tr><th>Projeto</th><th className="text-right">CAPEX</th><th className="text-right">VPL</th><th className="text-right">TIR</th><th className="text-right">Payback</th><th className="text-right">ROI</th></tr></thead>
            <tbody>{investments.map((iv) => (
              <tr key={iv.id}><td className="font-medium">{iv.name}</td><td className="text-right tabular-nums">{brl(Number(iv.capex))}</td>
                <td className="text-right tabular-nums" style={{ color: Number(iv.npv) >= 0 ? "var(--success)" : "var(--danger)" }}>{iv.npv != null ? brl(Number(iv.npv)) : "—"}</td>
                <td className="text-right tabular-nums">{iv.irr != null ? iv.irr + "%" : "—"}</td><td className="text-right tabular-nums">{iv.payback_periods ?? "—"}</td><td className="text-right tabular-nums">{iv.roi != null ? iv.roi + "%" : "—"}</td></tr>
            ))}</tbody></table>
        </div>
      )}
    </div>
  );
}
function Metric({ label, value, tone }: { label: string; value: string; tone?: string }) {
  return <div className="surface-2 rounded-xl p-3" style={{ border: "1px solid var(--border)" }}><div className="text-xs muted font-semibold">{label}</div><div className="text-lg font-bold tabular-nums mt-1" style={{ color: tone }}>{value}</div></div>;
}

function Orcamento({ budgets }: { budgets: any[] }) {
  return (
    <CrudPanel table="budgets" title="Orçamentos"
      fields={[
        { key: "name", label: "Nome", required: true, placeholder: "Orçamento 2026" },
        { key: "fiscal_year", label: "Ano", type: "number", required: true, default: String(new Date().getFullYear()) },
        { key: "scope_type", label: "Escopo", type: "select", options: [["company","Empresa"],["cost_center","Centro de custo"],["department","Departamento"],["product","Produto"],["project","Projeto"]], default: "company" },
        { key: "status", label: "Status", type: "select", options: [["draft","Rascunho"],["approved","Aprovado"],["active","Ativo"],["closed","Fechado"]], default: "draft" },
      ]}
      columns={[
        { key: "name", label: "Nome" }, { key: "fiscal_year", label: "Ano" },
        { key: "scope_type", label: "Escopo" }, { key: "status", label: "Status" },
      ]}
      rows={budgets} emptyHint="Crie orçamentos anuais. Adicione linhas via API/importação por conta e mês." />
  );
}

function BudgetVsActual({ bva }: { bva: any[] }) {
  const MESES = ["", "Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"];
  if (!bva.length) return <p className="text-sm muted px-1">Sem orçamento cadastrado para o ano corrente. Crie um orçamento e linhas para comparar com o realizado do GL.</p>;
  return (
    <div className="card p-0 overflow-x-auto">
      <table className="tbl">
        <thead><tr><th>Mês</th><th className="text-right">Rec. orçada</th><th className="text-right">Rec. real</th><th className="text-right">Desp. orçada</th><th className="text-right">Desp. real</th><th className="text-right">Variação desp.</th></tr></thead>
        <tbody>
          {bva.map((r) => {
            const varExp = Number(r.actual_expense) - Number(r.budget_expense);
            return (
              <tr key={r.month}>
                <td>{MESES[r.month] ?? r.month}</td>
                <td className="text-right tabular-nums">{brl(Number(r.budget_revenue))}</td>
                <td className="text-right tabular-nums">{brl(Number(r.actual_revenue))}</td>
                <td className="text-right tabular-nums">{brl(Number(r.budget_expense))}</td>
                <td className="text-right tabular-nums">{brl(Number(r.actual_expense))}</td>
                <td className="text-right tabular-nums font-medium" style={{ color: varExp > 0 ? "var(--danger)" : "var(--success)" }}>{varExp > 0 ? "+" : ""}{brl(varExp)}</td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}

function Metas({ goals }: { goals: any[] }) {
  const pct = (g: any) => g.target_value ? Math.min(Math.round((Number(g.current_value) / Number(g.target_value)) * 100), 100) : 0;
  const statusTone = (s: string) => ({ on_track: "badge-success", at_risk: "badge-warning", off_track: "badge-danger", done: "badge-brand" } as any)[s] ?? "badge-neutral";
  return (
    <div className="space-y-4">
      <CrudPanel table="goals" title="Metas & OKRs"
        fields={[
          { key: "title", label: "Objetivo / Meta", required: true },
          { key: "level", label: "Nível", type: "select", options: [["company","Empresa"],["branch","Filial"],["department","Departamento"],["team","Equipe"],["user","Usuário"],["product","Produto"]], default: "company" },
          { key: "metric", label: "Métrica", placeholder: "Receita, NPS, unidades…" },
          { key: "target_value", label: "Alvo", type: "number" },
          { key: "current_value", label: "Atual", type: "number", default: "0" },
          { key: "unit", label: "Unidade", placeholder: "R$, %, un" },
          { key: "period", label: "Período", placeholder: "2026, Q1/2026" },
          { key: "owner", label: "Responsável" },
          { key: "status", label: "Status", type: "select", options: GOAL_STATUS, default: "on_track" },
          { key: "due_date", label: "Prazo", type: "date" },
        ]}
        columns={[
          { key: "title", label: "Objetivo" }, { key: "level", label: "Nível" }, { key: "owner", label: "Responsável" },
          { key: "current_value", label: "Progresso", fmt: (_v, r) => `${r.current_value ?? 0} / ${r.target_value ?? "—"} ${r.unit ?? ""}` },
          { key: "status", label: "Status", fmt: (v) => GOAL_STATUS.find(([kk]) => kk === v)?.[1] ?? v },
        ]}
        rows={goals} emptyHint="Defina metas e OKRs por empresa, equipe ou produto." />

      {goals.length > 0 && (
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
          {goals.map((g) => (
            <div key={g.id} className="card p-4">
              <div className="flex items-start justify-between gap-2">
                <div className="font-semibold text-sm">{g.title}</div>
                <span className={`badge ${statusTone(g.status)}`}>{GOAL_STATUS.find(([kk]) => kk === g.status)?.[1] ?? g.status}</span>
              </div>
              <div className="text-xs muted mt-1">{g.owner ?? "—"} · {g.period ?? "—"}</div>
              <div className="mt-3 h-2 rounded-full overflow-hidden" style={{ background: "var(--surface-3)" }}>
                <div className="h-full rounded-full" style={{ width: `${pct(g)}%`, background: "var(--brand)" }} />
              </div>
              <div className="text-xs muted mt-1 tabular-nums">{g.current_value ?? 0} / {g.target_value ?? "—"} {g.unit ?? ""} · {pct(g)}%</div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
