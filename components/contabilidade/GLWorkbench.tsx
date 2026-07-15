"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const brl = (n: number) => (n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const TYPE_LABEL: Record<string, string> = { asset: "Ativo", liability: "Passivo", equity: "Patrimônio Líq.", revenue: "Receita", cost: "Custo", expense: "Despesa" };

const TABS = ["Painel","Diário (Lançamentos)","Razão / Balancete","DRE","Balanço","Plano de Contas","Regras de Contabilização","Períodos"] as const;
type Tab = typeof TABS[number];

export default function GLWorkbench({ dash, accounts, entries, rules, periods, trial, dre, balance }: {
  dash: any; accounts: any[]; entries: any[]; rules: any[]; periods: any[]; trial: any[]; dre: any; balance: any;
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  const postable = useMemo(() => accounts.filter((a) => a.is_postable), [accounts]);
  const acctOpts: [string, string][] = useMemo(() => postable.map((a) => [a.id, `${a.code} · ${a.name}`]), [postable]);

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <div className="text-xs muted font-semibold uppercase tracking-wider">Núcleo Financeiro-Contábil</div>
          <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Contabilidade Geral (GL)</h1>
          <p className="text-sm muted mt-0.5">Partidas dobradas, motor de contabilização por evento, DRE, Balanço e fechamento — reflexo automático de todos os módulos.</p>
        </div>
      </div>

      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} balance={balance} dre={dre} />}
      {tab === "Diário (Lançamentos)" && <Diario entries={entries} accounts={acctOpts} />}
      {tab === "Razão / Balancete" && <Balancete trial={trial} />}
      {tab === "DRE" && <DRE dre={dre} />}
      {tab === "Balanço" && <Balanco balance={balance} />}
      {tab === "Plano de Contas" && <PlanoContas accounts={accounts} />}
      {tab === "Regras de Contabilização" && (
        <CrudPanel table="posting_rules" title="Regras de Contabilização (motor por evento)"
          fields={[
            { key: "event_key", label: "Evento", required: true, placeholder: "goods_receipt, sale_invoice…" },
            { key: "description", label: "Descrição" },
            { key: "debit_account_id", label: "Conta a Débito", type: "fk", fkTable: "chart_of_accounts", fkLabel: "name", required: true },
            { key: "credit_account_id", label: "Conta a Crédito", type: "fk", fkTable: "chart_of_accounts", fkLabel: "name", required: true },
            { key: "priority", label: "Prioridade", type: "number", default: "1" },
          ]}
          columns={[
            { key: "event_key", label: "Evento" }, { key: "description", label: "Descrição" },
            { key: "debit_account_id", label: "Débito" }, { key: "credit_account_id", label: "Crédito" },
          ]}
          rows={rules} emptyHint="Defina D/C por evento — cada operação vira lançamento automático." />
      )}
      {tab === "Períodos" && <Periodos periods={periods} />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return (
    <div className="kpi">
      <div className="kpi-label">{label}</div>
      <div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>
      {hint && <div className="text-xs muted mt-0.5">{hint}</div>}
    </div>
  );
}

function Painel({ dash, balance, dre }: { dash: any; balance: any; dre: any }) {
  const d = dash ?? {};
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <KPI label="Contas no plano" value={String(d.accounts ?? 0)} />
        <KPI label="Lançamentos contabilizados" value={String(d.entries_posted ?? 0)} hint={`${d.entries_auto ?? 0} automáticos · ${d.entries_manual ?? 0} manuais`} />
        <KPI label="Rascunhos" value={String(d.entries_draft ?? 0)} tone={d.entries_draft ? "var(--warning)" : undefined} />
        <KPI label="Regras de contabilização" value={String(d.posting_rules ?? 0)} />
        <KPI label="Resultado do exercício" value={`R$ ${brl(Number(dre?.net_income ?? 0))}`} tone={Number(dre?.net_income ?? 0) >= 0 ? "var(--success)" : "var(--danger)"} />
        <KPI label="Conciliações abertas" value={String(d.recon_open ?? 0)} />
        <KPI label="Períodos fechados" value={String(d.periods_closed ?? 0)} />
        <KPI label="Ativo total" value={`R$ ${brl(Number(balance?.assets ?? 0))}`} />
      </div>
      <div className="card p-5">
        <div className="font-semibold mb-3">Equação patrimonial</div>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 text-center">
          <Eq label="Ativo" v={balance?.assets} tone="var(--brand)" />
          <Eq label="Passivo" v={balance?.liabilities} tone="var(--warning)" />
          <Eq label="Patrimônio Líquido" v={balance?.equity} tone="var(--info)" />
          <Eq label="Resultado" v={balance?.result} tone={Number(balance?.result ?? 0) >= 0 ? "var(--success)" : "var(--danger)"} />
        </div>
      </div>
    </div>
  );
}
function Eq({ label, v, tone }: { label: string; v: any; tone: string }) {
  return (
    <div className="surface-2 rounded-xl p-3" style={{ border: "1px solid var(--border)" }}>
      <div className="text-xs muted font-semibold">{label}</div>
      <div className="text-lg font-bold tabular-nums mt-1" style={{ color: tone }}>R$ {brl(Number(v ?? 0))}</div>
    </div>
  );
}

// ── Diário + formulário de partidas dobradas ────────────────────────────────
type Line = { account_id: string; debit: string; credit: string; description: string };
function Diario({ entries, accounts }: { entries: any[]; accounts: [string, string][] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [desc, setDesc] = useState("");
  const [date, setDate] = useState(new Date().toISOString().slice(0, 10));
  const [lines, setLines] = useState<Line[]>([
    { account_id: "", debit: "", credit: "", description: "" },
    { account_id: "", debit: "", credit: "", description: "" },
  ]);

  const totDeb = lines.reduce((s, l) => s + (Number(l.debit) || 0), 0);
  const totCred = lines.reduce((s, l) => s + (Number(l.credit) || 0), 0);
  const balanced = totDeb > 0 && Math.round(totDeb * 100) === Math.round(totCred * 100);

  const setLine = (i: number, k: keyof Line, v: string) => setLines((p) => p.map((l, idx) => idx === i ? { ...l, [k]: v } : l));
  const addLine = () => setLines((p) => [...p, { account_id: "", debit: "", credit: "", description: "" }]);
  const rmLine = (i: number) => setLines((p) => p.filter((_, idx) => idx !== i));

  async function save() {
    if (!supabase) return;
    setErr(null);
    const payload = lines.filter((l) => l.account_id && (Number(l.debit) || Number(l.credit)))
      .map((l) => ({ account_id: l.account_id, debit: Number(l.debit) || 0, credit: Number(l.credit) || 0, description: l.description || null }));
    if (payload.length < 2) { setErr("Informe ao menos 2 partidas com conta e valor."); return; }
    if (!balanced) { setErr("Débito e crédito precisam ser iguais (partida dobrada)."); return; }
    setBusy(true);
    const { error } = await supabase.rpc("create_journal_entry", {
      p_company: COMPANY, p_date: date, p_description: desc, p_lines: payload, p_type: "manual", p_document_ref: null, p_post: true,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setOpen(false); setDesc(""); setLines([{ account_id: "", debit: "", credit: "", description: "" }, { account_id: "", debit: "", credit: "", description: "" }]);
    router.refresh();
  }

  async function reverse(id: string) {
    if (!supabase) return;
    await supabase.rpc("reverse_journal_entry", { p_entry: id, p_reason: "estorno pela tela" });
    router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base">Livro Diário <span className="badge badge-neutral ml-1">{entries.length}</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }} className={`btn btn-sm ml-auto ${open ? "" : "btn-primary"}`}>{open ? "Cancelar" : "+ Novo lançamento"}</button>
      </div>

      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div className="md:col-span-2"><label className="label">Histórico</label>
              <input value={desc} onChange={(e) => setDesc(e.target.value)} className="input" placeholder="Ex.: Provisão de despesa administrativa" /></div>
            <div><label className="label">Data</label><input type="date" value={date} onChange={(e) => setDate(e.target.value)} className="input" /></div>
          </div>

          <div className="overflow-x-auto">
            <table className="tbl">
              <thead><tr><th>Conta</th><th className="text-right">Débito</th><th className="text-right">Crédito</th><th>Histórico da linha</th><th></th></tr></thead>
              <tbody>
                {lines.map((l, i) => (
                  <tr key={i}>
                    <td style={{ minWidth: 240 }}>
                      <select value={l.account_id} onChange={(e) => setLine(i, "account_id", e.target.value)} className="select h-9">
                        <option value="">— conta —</option>
                        {accounts.map(([v, lbl]) => <option key={v} value={v}>{lbl}</option>)}
                      </select>
                    </td>
                    <td style={{ width: 130 }}><input type="number" value={l.debit} onChange={(e) => setLine(i, "debit", e.target.value)} className="input h-9 text-right" placeholder="0,00" /></td>
                    <td style={{ width: 130 }}><input type="number" value={l.credit} onChange={(e) => setLine(i, "credit", e.target.value)} className="input h-9 text-right" placeholder="0,00" /></td>
                    <td><input value={l.description} onChange={(e) => setLine(i, "description", e.target.value)} className="input h-9" /></td>
                    <td>{lines.length > 2 && <button onClick={() => rmLine(i)} className="text-xs" style={{ color: "var(--danger)" }}>✕</button>}</td>
                  </tr>
                ))}
              </tbody>
              <tfoot>
                <tr style={{ borderTop: "2px solid var(--border)" }}>
                  <td className="py-2 font-semibold">Totais</td>
                  <td className="text-right font-bold tabular-nums">{brl(totDeb)}</td>
                  <td className="text-right font-bold tabular-nums">{brl(totCred)}</td>
                  <td colSpan={2}>
                    <span className={`badge ${balanced ? "badge-success" : "badge-danger"}`}>{balanced ? "✓ partida fecha" : `diferença ${brl(Math.abs(totDeb - totCred))}`}</span>
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          <div className="flex items-center gap-2">
            <button onClick={addLine} className="btn btn-sm">+ Linha</button>
            <button onClick={save} disabled={busy || !balanced} className="btn btn-primary btn-sm">{busy ? "Contabilizando…" : "Contabilizar"}</button>
            {err && <span className="text-sm" style={{ color: "var(--danger)" }}>{err}</span>}
          </div>
        </div>
      )}

      {entries.length === 0 ? <p className="text-sm muted px-1">Nenhum lançamento ainda.</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead><tr><th>Nº</th><th>Data</th><th>Histórico</th><th>Tipo</th><th>Origem</th><th className="text-right">Valor</th><th>Status</th><th></th></tr></thead>
            <tbody>
              {entries.map((e) => (
                <tr key={e.id}>
                  <td className="tabular-nums">{e.entry_number}</td>
                  <td>{e.competence_date}</td>
                  <td>{e.description ?? "—"}</td>
                  <td><span className="badge badge-neutral">{e.entry_type}</span></td>
                  <td className="muted text-xs">{e.source_module ?? e.document_ref ?? "—"}</td>
                  <td className="text-right tabular-nums font-medium">{brl(Number(e.total_debit))}</td>
                  <td><span className={`badge ${e.status === "posted" ? "badge-success" : e.status === "reversed" ? "badge-danger" : "badge-warning"}`}>{e.status}</span></td>
                  <td className="text-right">{e.status === "posted" && <button onClick={() => reverse(e.id)} className="text-xs font-semibold hover:underline" style={{ color: "var(--danger)" }}>estornar</button>}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function Balancete({ trial }: { trial: any[] }) {
  const totDeb = trial.reduce((s, r) => s + Number(r.debit || 0), 0);
  const totCred = trial.reduce((s, r) => s + Number(r.credit || 0), 0);
  if (!trial.length) return <p className="text-sm muted px-1">Sem movimento contabilizado no período.</p>;
  return (
    <div className="card p-0 overflow-x-auto">
      <table className="tbl">
        <thead><tr><th>Código</th><th>Conta</th><th>Natureza</th><th className="text-right">Débito</th><th className="text-right">Crédito</th><th className="text-right">Saldo</th></tr></thead>
        <tbody>
          {trial.map((r, i) => (
            <tr key={i}>
              <td className="tabular-nums">{r.code}</td><td>{r.name}</td>
              <td><span className="badge badge-neutral">{TYPE_LABEL[r.type] ?? r.type}</span></td>
              <td className="text-right tabular-nums">{brl(Number(r.debit))}</td>
              <td className="text-right tabular-nums">{brl(Number(r.credit))}</td>
              <td className="text-right tabular-nums font-medium">{brl(Number(r.balance))}</td>
            </tr>
          ))}
        </tbody>
        <tfoot>
          <tr style={{ borderTop: "2px solid var(--border)" }}>
            <td colSpan={3} className="py-2 font-semibold">Totais</td>
            <td className="text-right font-bold tabular-nums">{brl(totDeb)}</td>
            <td className="text-right font-bold tabular-nums">{brl(totCred)}</td>
            <td className="text-right"><span className={`badge ${Math.round(totDeb*100)===Math.round(totCred*100) ? "badge-success" : "badge-danger"}`}>{Math.round(totDeb*100)===Math.round(totCred*100) ? "✓ fecha" : "✗"}</span></td>
          </tr>
        </tfoot>
      </table>
    </div>
  );
}

function DRE({ dre }: { dre: any }) {
  const d = dre ?? {};
  const line = (label: string, v: number, bold?: boolean, tone?: string) => (
    <div className={`flex justify-between py-2 ${bold ? "font-bold" : ""}`} style={{ borderBottom: "1px solid var(--border)" }}>
      <span className={bold ? "" : "muted"}>{label}</span>
      <span className="tabular-nums" style={{ color: tone }}>R$ {brl(v)}</span>
    </div>
  );
  return (
    <div className="card p-5 max-w-2xl">
      <div className="font-semibold mb-2">Demonstração do Resultado (DRE) — mês corrente</div>
      {line("(+) Receita bruta", Number(d.revenue ?? 0), false, "var(--success)")}
      {line("(−) Custos", -Number(d.cost ?? 0), false, "var(--danger)")}
      {line("(−) Despesas", -Number(d.expense ?? 0), false, "var(--danger)")}
      {line("(=) Resultado líquido", Number(d.net_income ?? 0), true, Number(d.net_income ?? 0) >= 0 ? "var(--success)" : "var(--danger)")}
      {(d.lines ?? []).length > 0 && (
        <div className="mt-4">
          <div className="text-xs muted font-semibold uppercase mb-1">Detalhamento por conta</div>
          {(d.lines ?? []).map((l: any, i: number) => (
            <div key={i} className="flex justify-between text-sm py-1"><span className="muted">{l.code} · {l.name}</span><span className="tabular-nums">R$ {brl(Number(l.amount))}</span></div>
          ))}
        </div>
      )}
    </div>
  );
}

function Balanco({ balance }: { balance: any }) {
  const b = balance ?? {};
  const totalPL = Number(b.equity ?? 0) + Number(b.result ?? 0);
  const box = (title: string, rows: [string, number][], total: number, tone: string) => (
    <div className="card p-5">
      <div className="font-semibold mb-3">{title}</div>
      {rows.map(([l, v]) => <div key={l} className="flex justify-between py-1.5 text-sm" style={{ borderBottom: "1px solid var(--border)" }}><span className="muted">{l}</span><span className="tabular-nums">R$ {brl(v)}</span></div>)}
      <div className="flex justify-between pt-2 mt-1 font-bold"><span>Total</span><span className="tabular-nums" style={{ color: tone }}>R$ {brl(total)}</span></div>
    </div>
  );
  return (
    <div className="grid md:grid-cols-2 gap-4 max-w-4xl">
      {box("ATIVO", [["Ativo total", Number(b.assets ?? 0)]], Number(b.assets ?? 0), "var(--brand)")}
      {box("PASSIVO + PATRIMÔNIO LÍQUIDO", [["Passivo", Number(b.liabilities ?? 0)], ["Patrimônio líquido", Number(b.equity ?? 0)], ["Resultado do exercício", Number(b.result ?? 0)]], Number(b.liabilities ?? 0) + totalPL, "var(--info)")}
    </div>
  );
}

function PlanoContas({ accounts }: { accounts: any[] }) {
  return (
    <CrudPanel table="chart_of_accounts" title="Plano de Contas"
      fields={[
        { key: "code", label: "Código", required: true, placeholder: "1.1.06" },
        { key: "name", label: "Nome da conta", required: true },
        { key: "account_type", label: "Tipo", type: "select", required: true, options: [["asset","Ativo"],["liability","Passivo"],["equity","Patrimônio Líquido"],["revenue","Receita"],["cost","Custo"],["expense","Despesa"]] },
        { key: "nature", label: "Natureza", type: "select", required: true, options: [["debit","Devedora"],["credit","Credora"]] },
        { key: "parent_id", label: "Conta pai", type: "fk", fkTable: "chart_of_accounts", fkLabel: "name" },
        { key: "is_postable", label: "Analítica? (recebe lançamento)", type: "select", options: [["true","Sim — analítica"],["false","Não — sintética"]], default: "true" },
        { key: "plan_type", label: "Plano", type: "select", options: [["statutory","Societário"],["managerial","Gerencial"],["fiscal","Fiscal"],["ifrs","Internacional (IFRS)"]], default: "statutory" },
      ]}
      columns={[
        { key: "code", label: "Código" }, { key: "name", label: "Conta" },
        { key: "account_type", label: "Tipo", fmt: (v) => TYPE_LABEL[v] ?? v },
        { key: "nature", label: "Natureza", fmt: (v) => v === "debit" ? "Devedora" : "Credora" },
        { key: "is_postable", label: "Analítica", fmt: (v) => v ? "Sim" : "—" },
      ]}
      rows={accounts} emptyHint="Plano de contas vazio." />
  );
}

function Periodos({ periods }: { periods: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const now = new Date();
  async function close() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { error } = await supabase.rpc("close_accounting_period", { p_company: COMPANY, p_year: now.getFullYear(), p_month: now.getMonth() + 1 });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.refresh();
  }
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base">Períodos contábeis</div>
        <button onClick={close} disabled={busy} className="btn btn-primary btn-sm ml-auto">{busy ? "Fechando…" : `Fechar ${now.getMonth() + 1}/${now.getFullYear()}`}</button>
      </div>
      {err && <div className="text-sm rounded-xl px-3 py-2" style={{ background: "var(--danger-soft)", color: "var(--danger)" }}>{err}</div>}
      {periods.length === 0 ? <p className="text-sm muted px-1">Nenhum período fechado. Todos os meses estão abertos para lançamento.</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead><tr><th>Ano</th><th>Mês</th><th>Status</th><th>Fechado em</th></tr></thead>
            <tbody>
              {periods.map((p) => (
                <tr key={p.id}>
                  <td className="tabular-nums">{p.fiscal_year}</td><td className="tabular-nums">{String(p.fiscal_month).padStart(2, "0")}</td>
                  <td><span className={`badge ${p.status === "closed" ? "badge-danger" : "badge-success"}`}>{p.status === "closed" ? "Fechado" : "Aberto"}</span></td>
                  <td>{p.closed_at ? new Date(p.closed_at).toLocaleString("pt-BR") : "—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
