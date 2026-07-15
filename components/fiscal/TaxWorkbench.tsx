"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const brl = (n: number) => (n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const TAX_OPTS: [string, string][] = [["icms","ICMS"],["ipi","IPI"],["pis","PIS"],["cofins","COFINS"],["iss","ISS"],["irrf","IRRF"],["csll","CSLL"],["inss","INSS"],["ii","II"],["difal","DIFAL"],["fcp","FCP"],["outros","Outros"]];
const OP_OPTS: [string, string][] = [["sale","Venda"],["purchase","Compra"],["service","Serviço"],["import","Importação"],["export","Exportação"]];
const DOC_OPTS: [string, string][] = [["nfe","NF-e"],["nfce","NFC-e"],["nfse","NFS-e"],["cte","CT-e"],["mdfe","MDF-e"],["other","Outro"]];

const TABS = ["Painel","Documentos Fiscais","Calculadora de Tributos","Motor Tributário","Naturezas de Operação","Apuração","Obrigações Acessórias"] as const;
type Tab = typeof TABS[number];

export default function TaxWorkbench({ dash, rules, natures, docs, assessments, obligations }: {
  dash: any; rules: any[]; natures: any[]; docs: any[]; assessments: any[]; obligations: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Núcleo Financeiro-Contábil</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Fiscal & Tributário (ETP)</h1>
        <p className="text-sm muted mt-0.5">Motor tributário parametrizável, documentos fiscais eletrônicos, apuração e obrigações acessórias — global com regras locais configuráveis.</p>
      </div>

      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Documentos Fiscais" && <Documentos docs={docs} />}
      {tab === "Calculadora de Tributos" && <Calculadora />}
      {tab === "Motor Tributário" && (
        <CrudPanel table="tax_rules" title="Regras Tributárias (motor parametrizável)"
          fields={[
            { key: "tax_kind", label: "Tributo", type: "select", options: TAX_OPTS, required: true },
            { key: "description", label: "Descrição", required: true },
            { key: "operation_type", label: "Operação", type: "select", options: OP_OPTS },
            { key: "state", label: "UF", placeholder: "SP (vazio = todas)" },
            { key: "municipality", label: "Município" },
            { key: "regime", label: "Regime", placeholder: "simples / presumido / real" },
            { key: "ncm_prefix", label: "NCM (prefixo)", placeholder: "2106" },
            { key: "rate", label: "Alíquota %", type: "number", required: true },
            { key: "reduction_pct", label: "Redução base %", type: "number", default: "0" },
            { key: "cst", label: "CST/CSOSN" },
            { key: "is_withholding", label: "Retido na fonte?", type: "select", options: [["false","Não"],["true","Sim"]], default: "false" },
            { key: "priority", label: "Prioridade", type: "number", default: "1" },
            { key: "valid_from", label: "Vigência a partir de", type: "date" },
          ]}
          columns={[
            { key: "tax_kind", label: "Tributo", fmt: (v) => (v as string).toUpperCase() },
            { key: "description", label: "Descrição" },
            { key: "operation_type", label: "Operação", fmt: (v) => OP_OPTS.find(([k]) => k === v)?.[1] ?? v ?? "todas" },
            { key: "state", label: "UF", fmt: (v) => v ?? "todas" },
            { key: "rate", label: "Alíq %" },
            { key: "is_withholding", label: "Retido", fmt: (v) => v ? "Sim" : "—" },
          ]}
          rows={rules} emptyHint="Configure as regras por tributo/operação/UF/regime." />
      )}
      {tab === "Naturezas de Operação" && (
        <CrudPanel table="operation_natures" title="Naturezas de Operação (CFOP)"
          fields={[
            { key: "code", label: "Código", required: true, placeholder: "5102" },
            { key: "name", label: "Descrição", required: true },
            { key: "cfop", label: "CFOP", placeholder: "5102" },
            { key: "direction", label: "Sentido", type: "select", options: [["out","Saída"],["in","Entrada"]] },
            { key: "operation_type", label: "Operação", type: "select", options: OP_OPTS },
          ]}
          columns={[
            { key: "code", label: "Código" }, { key: "name", label: "Descrição" }, { key: "cfop", label: "CFOP" },
            { key: "direction", label: "Sentido", fmt: (v) => v === "out" ? "Saída" : v === "in" ? "Entrada" : "—" },
          ]}
          rows={natures} emptyHint="Cadastre CFOPs e naturezas de operação." />
      )}
      {tab === "Apuração" && <Apuracao assessments={assessments} />}
      {tab === "Obrigações Acessórias" && <Obrigacoes obligations={obligations} />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}

function Painel({ dash }: { dash: any }) {
  const d = dash ?? {};
  const byKind: Record<string, number> = d.tax_by_kind ?? {};
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <KPI label="Documentos emitidos" value={String(d.docs_issued ?? 0)} />
        <KPI label="Documentos recebidos" value={String(d.docs_received ?? 0)} />
        <KPI label="Pendentes / rejeitados" value={String(d.docs_pending ?? 0)} tone={d.docs_pending ? "var(--warning)" : undefined} />
        <KPI label="Regras tributárias" value={String(d.tax_rules ?? 0)} />
        <KPI label="Obrigações pendentes" value={String(d.obligations_pending ?? 0)} hint={`${d.obligations_late ?? 0} em atraso`} tone={d.obligations_late ? "var(--danger)" : undefined} />
        <KPI label="Tributos a recolher" value={`R$ ${brl(Number(d.tax_payable_open ?? 0))}`} tone="var(--danger)" />
      </div>
      <div className="card p-5">
        <div className="font-semibold mb-3">Tributos apurados nas saídas (por tipo)</div>
        {Object.keys(byKind).length === 0 ? <p className="text-sm muted">Sem documentos emitidos ainda.</p> : (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
            {Object.entries(byKind).map(([k, v]) => (
              <div key={k} className="surface-2 rounded-xl p-3" style={{ border: "1px solid var(--border)" }}>
                <div className="text-xs muted font-semibold uppercase">{k}</div>
                <div className="text-base font-bold tabular-nums mt-1">R$ {brl(Number(v))}</div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function Calculadora() {
  const supabase = useMemo(() => createClient(), []);
  const [f, setF] = useState({ tax: "icms", base: "10000", state: "SP", operation: "sale", ncm: "" });
  const [res, setRes] = useState<any>(null);
  const [busy, setBusy] = useState(false);
  const set = (k: string) => (e: any) => setF((p) => ({ ...p, [k]: e.target.value }));
  async function run() {
    if (!supabase) return;
    setBusy(true);
    const { data } = await supabase.rpc("calculate_tax", {
      p_company: COMPANY, p_tax: f.tax, p_base: Number(f.base) || 0,
      p_state: f.state || null, p_operation: f.operation || null, p_ncm: f.ncm || null, p_regime: null, p_on_date: null,
    });
    setBusy(false); setRes(data);
  }
  return (
    <div className="grid lg:grid-cols-2 gap-4">
      <div className="card p-5 space-y-3">
        <div className="font-semibold">Simular tributo</div>
        <div className="grid grid-cols-2 gap-3">
          <div><label className="label">Tributo</label>
            <select value={f.tax} onChange={set("tax")} className="select">{TAX_OPTS.map(([v, l]) => <option key={v} value={v}>{l}</option>)}</select></div>
          <div><label className="label">Base (R$)</label><input type="number" value={f.base} onChange={set("base")} className="input" /></div>
          <div><label className="label">Operação</label>
            <select value={f.operation} onChange={set("operation")} className="select">{OP_OPTS.map(([v, l]) => <option key={v} value={v}>{l}</option>)}</select></div>
          <div><label className="label">UF</label><input value={f.state} onChange={set("state")} className="input" placeholder="SP" /></div>
          <div className="col-span-2"><label className="label">NCM (opcional)</label><input value={f.ncm} onChange={set("ncm")} className="input" placeholder="2106.90.30" /></div>
        </div>
        <button onClick={run} disabled={busy} className="btn btn-primary btn-sm">{busy ? "Calculando…" : "Calcular tributo"}</button>
        <p className="text-xs muted">O motor escolhe a regra mais específica e vigente (UF + operação + NCM + regime), respeitando prioridade.</p>
      </div>
      <div className="card p-5">
        <div className="font-semibold mb-2">Resultado</div>
        {!res ? <p className="text-sm muted">Preencha e calcule.</p> : !res.rule_found ? (
          <div className="text-sm rounded-xl px-3 py-2" style={{ background: "var(--warning-soft)", color: "var(--warning)" }}>Nenhuma regra tributária encontrada para esses parâmetros. Cadastre no Motor Tributário.</div>
        ) : (
          <div className="space-y-1.5 text-sm">
            <div className="text-xs muted">{res.rule}</div>
            <Row k="Base de cálculo" v={`R$ ${brl(Number(res.base))}`} />
            {Number(res.reduction_pct) > 0 && <Row k={`Redução de base (${res.reduction_pct}%)`} v={`R$ ${brl(Number(res.effective_base))}`} />}
            <Row k="Alíquota" v={`${res.rate}%`} />
            {res.cst && <Row k="CST/CSOSN" v={res.cst} />}
            <div className="flex justify-between pt-2 mt-1 border-t" style={{ borderColor: "var(--border)" }}>
              <span className="font-bold">{res.is_withholding ? "Tributo retido" : "Tributo devido"}</span>
              <span className="text-xl font-bold tabular-nums text-brand-600">R$ {brl(Number(res.tax_amount))}</span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
function Row({ k, v }: { k: string; v: string }) {
  return <div className="flex justify-between py-1"><span className="muted">{k}</span><span className="tabular-nums font-medium">{v}</span></div>;
}

function Documentos({ docs }: { docs: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ doc_type: "nfe", direction: "issued", partner: "", operation: "sale", total: "", state: "SP" });
  const set = (k: string) => (e: any) => setF((p) => ({ ...p, [k]: e.target.value }));
  async function save() {
    if (!supabase) return;
    if (!f.partner || !(Number(f.total) > 0)) { setErr("Informe parceiro e valor."); return; }
    setBusy(true); setErr(null);
    const { error } = await supabase.rpc("create_fiscal_document", {
      p_company: COMPANY, p_doc_type: f.doc_type, p_direction: f.direction, p_partner: f.partner,
      p_operation: f.operation, p_total: Number(f.total), p_taxes: null, p_state: f.state, p_status: "authorized",
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setOpen(false); setF({ doc_type: "nfe", direction: "issued", partner: "", operation: "sale", total: "", state: "SP" }); router.refresh();
  }
  const badge = (s: string) => ({ authorized: "badge-success", draft: "badge-warning", rejected: "badge-danger", canceled: "badge-danger", inutilized: "badge-neutral" } as any)[s] ?? "badge-neutral";
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base">Documentos Fiscais <span className="badge badge-neutral ml-1">{docs.length}</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }} className={`btn btn-sm ml-auto ${open ? "" : "btn-primary"}`}>{open ? "Cancelar" : "+ Emitir documento"}</button>
      </div>
      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="label">Tipo</label><select value={f.doc_type} onChange={set("doc_type")} className="select">{DOC_OPTS.map(([v, l]) => <option key={v} value={v}>{l}</option>)}</select></div>
            <div><label className="label">Sentido</label><select value={f.direction} onChange={set("direction")} className="select"><option value="issued">Emitido (saída)</option><option value="received">Recebido (entrada)</option></select></div>
            <div><label className="label">Operação</label><select value={f.operation} onChange={set("operation")} className="select">{OP_OPTS.map(([v, l]) => <option key={v} value={v}>{l}</option>)}</select></div>
            <div className="md:col-span-2"><label className="label">Parceiro</label><input value={f.partner} onChange={set("partner")} className="input" placeholder="Cliente / Fornecedor" /></div>
            <div><label className="label">Valor total (R$)</label><input type="number" value={f.total} onChange={set("total")} className="input" /></div>
          </div>
          {err && <div className="text-sm" style={{ color: "var(--danger)" }}>{err}</div>}
          <button onClick={save} disabled={busy} className="btn btn-primary btn-sm">{busy ? "Emitindo…" : "Emitir (tributos automáticos pelo motor)"}</button>
        </div>
      )}
      {docs.length === 0 ? <p className="text-sm muted px-1">Nenhum documento fiscal ainda.</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead><tr><th>Nº</th><th>Tipo</th><th>Sentido</th><th>Parceiro</th><th>Operação</th><th className="text-right">Total</th><th className="text-right">Tributos</th><th>Status</th></tr></thead>
            <tbody>
              {docs.map((d) => (
                <tr key={d.id}>
                  <td className="tabular-nums">{d.number}</td>
                  <td>{(d.doc_type as string).toUpperCase()}</td>
                  <td>{d.direction === "issued" ? "Saída" : "Entrada"}</td>
                  <td>{d.partner_name ?? "—"}</td>
                  <td className="muted text-xs">{d.operation_nature ?? "—"}</td>
                  <td className="text-right tabular-nums">{brl(Number(d.total_amount))}</td>
                  <td className="text-right tabular-nums">{brl(Number(d.tax_total))}</td>
                  <td><span className={`badge ${badge(d.status)}`}>{d.status}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function Apuracao({ assessments }: { assessments: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tax, setTax] = useState("icms");
  const [busy, setBusy] = useState(false);
  const now = new Date();
  async function run() {
    if (!supabase) return;
    setBusy(true);
    await supabase.rpc("run_tax_assessment", { p_company: COMPANY, p_tax: tax, p_year: now.getFullYear(), p_month: now.getMonth() + 1 });
    setBusy(false); router.refresh();
  }
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2 flex-wrap">
        <div className="font-semibold text-base mr-auto">Apuração de Tributos</div>
        <select value={tax} onChange={(e) => setTax(e.target.value)} className="select h-9 w-40">{TAX_OPTS.map(([v, l]) => <option key={v} value={v}>{l}</option>)}</select>
        <button onClick={run} disabled={busy} className="btn btn-primary btn-sm">{busy ? "Apurando…" : `Apurar ${now.getMonth() + 1}/${now.getFullYear()}`}</button>
      </div>
      {assessments.length === 0 ? <p className="text-sm muted px-1">Nenhuma apuração ainda. Selecione o tributo e apure o período.</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead><tr><th>Tributo</th><th>Período</th><th className="text-right">Débito</th><th className="text-right">Crédito</th><th className="text-right">Saldo</th><th>Situação</th></tr></thead>
            <tbody>
              {assessments.map((a) => {
                const bal = Number(a.balance);
                return (
                  <tr key={a.id}>
                    <td className="font-semibold">{(a.tax_kind as string).toUpperCase()}</td>
                    <td className="tabular-nums">{a.fiscal_year}/{String(a.fiscal_month).padStart(2, "0")}</td>
                    <td className="text-right tabular-nums">{brl(Number(a.debit_total))}</td>
                    <td className="text-right tabular-nums">{brl(Number(a.credit_total))}</td>
                    <td className="text-right tabular-nums font-bold">{brl(bal)}</td>
                    <td><span className={`badge ${bal > 0 ? "badge-danger" : bal < 0 ? "badge-success" : "badge-neutral"}`}>{bal > 0 ? "a recolher" : bal < 0 ? "saldo credor" : "zerado"}</span></td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function Obrigacoes({ obligations }: { obligations: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const now = new Date();
  async function gen() {
    if (!supabase) return;
    setBusy(true);
    await supabase.rpc("generate_fiscal_obligations", { p_company: COMPANY, p_year: now.getFullYear(), p_month: now.getMonth() + 1 });
    setBusy(false); router.refresh();
  }
  async function submit(id: string) {
    if (!supabase) return;
    await supabase.from("fiscal_obligations").update({ status: "submitted", submitted_at: new Date().toISOString() }).eq("id", id);
    router.refresh();
  }
  const late = (o: any) => o.status === "pending" && o.due_date && o.due_date < now.toISOString().slice(0, 10);
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Obrigações Acessórias</div>
        <button onClick={gen} disabled={busy} className="btn btn-primary btn-sm">{busy ? "Gerando…" : `Gerar calendário ${now.getMonth() + 1}/${now.getFullYear()}`}</button>
      </div>
      {obligations.length === 0 ? <p className="text-sm muted px-1">Nenhuma obrigação. Gere o calendário do período.</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead><tr><th>Obrigação</th><th>Período</th><th>Vencimento</th><th>Status</th><th></th></tr></thead>
            <tbody>
              {obligations.map((o) => (
                <tr key={o.id}>
                  <td><div className="font-medium">{o.obligation_code}</div><div className="text-xs muted">{o.name}</div></td>
                  <td className="tabular-nums">{o.reference_period}</td>
                  <td className="tabular-nums">{o.due_date ? new Date(o.due_date + "T00:00:00").toLocaleDateString("pt-BR") : "—"}</td>
                  <td><span className={`badge ${o.status === "submitted" ? "badge-success" : late(o) ? "badge-danger" : "badge-warning"}`}>{o.status === "submitted" ? "Entregue" : late(o) ? "Em atraso" : "Pendente"}</span></td>
                  <td className="text-right">{o.status !== "submitted" && <button onClick={() => submit(o.id)} className="text-xs font-semibold hover:underline text-brand-600">marcar entregue</button>}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
