"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const brl = (n: any) => "R$ " + Number(n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const CHARGE: Record<string, string> = {
  freight_weight: "Frete-peso", freight_value: "Frete-valor", freight_cubed: "Frete cubado", gris: "GRIS",
  advalorem: "Ad Valorem", toll: "Pedágio", restriction: "Restrição", interiorization: "Interiorização",
  permanence: "Permanência", pickup: "Coleta", delivery: "Entrega", extra: "Extra",
};
const invBadge = (s: string) => ({ pending: "badge-neutral", audited: "badge-warning", approved: "badge-success", disputed: "badge-danger", paid: "badge-success", canceled: "badge-neutral" } as any)[s] ?? "badge-neutral";

const TABS = ["Painel", "Faturas & Auditoria", "Glosas", "Custos Logísticos", "Simulador", "Contratos"] as const;
type Tab = typeof TABS[number];

export default function FACMSWorkbench({ dash, invoices, charges, glosas, costs, contracts, carriers }: any) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Volume 36 · Domínio Logístico</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Auditoria de Fretes & Custos (FACMS)</h1>
        <p className="text-sm muted mt-0.5">Auditoria automática cobrado × esperado, glosas, custos operacionais e simulação entre transportadoras.</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>
      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Faturas & Auditoria" && <Faturas invoices={invoices} charges={charges} />}
      {tab === "Glosas" && <Glosas glosas={glosas} />}
      {tab === "Custos Logísticos" && <Custos dash={dash} costs={costs} />}
      {tab === "Simulador" && <Simulador carriers={carriers} />}
      {tab === "Contratos" && <Contratos contracts={contracts} carriers={carriers} />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: any) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash }: any) {
  const d = dash ?? {};
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <KPI label="Frete total" value={brl(d.freight_total)} hint={`${d.invoices_total ?? 0} faturas`} />
        <KPI label="Divergências" value={brl(d.divergence_total)} tone={Number(d.divergence_total) > 0 ? "var(--danger)" : "var(--success)"} />
        <KPI label="Economia (glosas aceitas)" value={brl(d.savings)} tone="var(--success)" />
        <KPI label="Glosas em aberto" value={String(d.glosas_open ?? 0)} hint={`${d.invoices_pending ?? 0} faturas a auditar`} tone={d.glosas_open ? "var(--warning)" : undefined} />
      </div>
      <div className="grid md:grid-cols-2 gap-4">
        <div className="card p-4">
          <div className="font-semibold mb-3">Custo por transportadora</div>
          {(d.cost_by_carrier ?? []).length === 0 ? <p className="text-sm muted">Sem faturas.</p> : (d.cost_by_carrier ?? []).map((c: any) => (
            <div key={c.carrier} className="flex items-center justify-between py-1.5 border-b text-sm" style={{ borderColor: "var(--border)" }}>
              <span>{c.carrier}</span><span className="tabular-nums font-semibold">{brl(c.total)}</span>
            </div>
          ))}
        </div>
        <div className="card p-4">
          <div className="font-semibold mb-3">Custo por tipo</div>
          {(d.cost_by_type ?? []).length === 0 ? <p className="text-sm muted">—</p> : (d.cost_by_type ?? []).map((c: any) => (
            <div key={c.type} className="flex items-center justify-between py-1.5 border-b text-sm" style={{ borderColor: "var(--border)" }}>
              <span className="capitalize">{c.type}</span><span className="tabular-nums font-semibold">{brl(c.total)}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function Faturas({ invoices, charges }: any) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState<string | null>(null);
  const [busy, setBusy] = useState("");
  async function audit(id: string) {
    if (!supabase) return; setBusy(id);
    const { data, error } = await supabase.rpc("audit_transport_invoice", { p_company: COMPANY, p_invoice: id });
    setBusy("");
    if (error) { alert(error.message); return; }
    if (data) alert(`Auditoria: cobrado ${brl(data.charged)} · esperado ${brl(data.expected)} · divergência ${brl(data.divergence)}${data.glosa_amount > 0 ? ` → glosa ${brl(data.glosa_amount)} aberta` : " (sem glosa)"}`);
    router.refresh();
  }
  return (
    <div className="card p-0 overflow-x-auto">
      <table className="tbl">
        <thead><tr><th>Fatura</th><th>CT-e</th><th>Cobrado</th><th>Esperado</th><th>Divergência</th><th>Status</th><th></th></tr></thead>
        <tbody>
          {invoices.length === 0 ? <tr><td colSpan={7} className="text-sm muted p-4 text-center">Nenhuma fatura de transporte.</td></tr> :
            invoices.map((iv: any) => {
              const ch = charges.filter((c: any) => c.invoice_id === iv.id);
              const isOpen = open === iv.id;
              return (
                <>
                  <tr key={iv.id} className="cursor-pointer" onClick={() => setOpen(isOpen ? null : iv.id)}>
                    <td className="font-medium mono">{iv.invoice_number ?? iv.code}</td>
                    <td className="text-xs muted">{iv.cte_number ?? "—"}</td>
                    <td className="tabular-nums text-sm">{brl(iv.total_charged)}</td>
                    <td className="tabular-nums text-sm">{brl(iv.total_expected)}</td>
                    <td className="tabular-nums text-sm" style={{ color: Number(iv.total_divergence) > 0 ? "var(--danger)" : undefined }}>{brl(iv.total_divergence)}</td>
                    <td><span className={`badge ${invBadge(iv.status)}`}>{iv.status}</span></td>
                    <td className="text-right">
                      {iv.status === "pending" && <button onClick={(e) => { e.stopPropagation(); audit(iv.id); }} disabled={!!busy} className="btn btn-primary btn-sm">Auditar</button>}
                    </td>
                  </tr>
                  {isOpen && (
                    <tr key={iv.id + "-d"}><td colSpan={7} style={{ background: "var(--surface-2, transparent)" }}>
                      <table className="tbl" style={{ margin: 4 }}>
                        <thead><tr><th>Cobrança</th><th>Cobrado</th><th>Esperado</th><th>Divergência</th><th>Status</th></tr></thead>
                        <tbody>{ch.length === 0 ? <tr><td colSpan={5} className="text-xs muted p-2">Sem itens.</td></tr> : ch.map((c: any) => (
                          <tr key={c.id}>
                            <td className="text-xs">{CHARGE[c.charge_type] ?? c.charge_type}</td>
                            <td className="tabular-nums text-xs">{brl(c.amount_charged)}</td>
                            <td className="tabular-nums text-xs">{c.amount_expected == null ? "—" : brl(c.amount_expected)}</td>
                            <td className="tabular-nums text-xs" style={{ color: Number(c.divergence) > 0 ? "var(--danger)" : undefined }}>{brl(c.divergence)}</td>
                            <td><span className={`badge ${c.status === "divergent" || c.status === "glosa" ? "badge-danger" : c.status === "ok" ? "badge-success" : "badge-neutral"}`}>{c.status}</span></td>
                          </tr>
                        ))}</tbody>
                      </table>
                    </td></tr>
                  )}
                </>
              );
            })}
        </tbody>
      </table>
    </div>
  );
}

function Glosas({ glosas }: any) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  async function act(fn: string, args: any) {
    if (!supabase) return;
    const { error } = await supabase.rpc(fn, { p_company: COMPANY, ...args });
    if (error) { alert(error.message); return; }
    router.refresh();
  }
  return (
    <div className="card p-0 overflow-x-auto">
      <table className="tbl">
        <thead><tr><th>Glosa</th><th>Motivo</th><th>Valor</th><th>Status</th><th></th></tr></thead>
        <tbody>
          {glosas.length === 0 ? <tr><td colSpan={5} className="text-sm muted p-4 text-center">Nenhuma glosa. Audite uma fatura com divergência para gerar.</td></tr> :
            glosas.map((g: any) => (
              <tr key={g.id}>
                <td className="font-medium mono text-xs">{g.code}</td>
                <td className="text-xs">{g.reason}</td>
                <td className="tabular-nums text-sm" style={{ color: "var(--danger)" }}>{brl(g.amount)}</td>
                <td><span className={`badge ${g.status === "accepted" ? "badge-success" : g.status === "rejected" ? "badge-neutral" : "badge-warning"}`}>{g.status}</span></td>
                <td className="text-right whitespace-nowrap">
                  {g.status === "open" && <button onClick={() => act("contest_glosa", { p_glosa: g.id })} className="text-xs text-brand-600 hover:underline mr-2">Contestar</button>}
                  {(g.status === "open" || g.status === "contested") && <>
                    <button onClick={() => { const r = prompt("Resolução (aceita):"); if (r != null) act("resolve_glosa", { p_glosa: g.id, p_accepted: true, p_resolution: r }); }} className="text-xs hover:underline mr-2" style={{ color: "var(--success)" }}>Aceitar</button>
                    <button onClick={() => { const r = prompt("Resolução (rejeitada):"); if (r != null) act("resolve_glosa", { p_glosa: g.id, p_accepted: false, p_resolution: r }); }} className="text-xs hover:underline" style={{ color: "var(--danger)" }}>Rejeitar</button>
                  </>}
                </td>
              </tr>
            ))}
        </tbody>
      </table>
    </div>
  );
}

function Custos({ dash, costs }: any) {
  const total = (dash?.cost_by_type ?? []).reduce((s: number, c: any) => s + Number(c.total), 0);
  return (
    <div className="space-y-4">
      <div className="card p-4">
        <div className="font-semibold mb-3">Custos logísticos por tipo <span className="text-xs muted font-normal">· total {brl(total)}</span></div>
        {(dash?.cost_by_type ?? []).map((c: any) => (
          <div key={c.type} className="flex items-center gap-3 mb-2">
            <div className="w-28 text-sm capitalize">{c.type}</div>
            <div className="flex-1 h-2.5 rounded-full overflow-hidden" style={{ background: "var(--surface-3)" }}>
              <div className="h-full rounded-full" style={{ width: `${total ? (Number(c.total) / total) * 100 : 0}%`, background: "var(--brand-600, #2f56e6)" }} />
            </div>
            <div className="w-28 text-right text-sm tabular-nums">{brl(c.total)}</div>
          </div>
        ))}
      </div>
      <div className="card p-0 overflow-x-auto">
        <table className="tbl">
          <thead><tr><th>Tipo</th><th>Entidade</th><th>Competência</th><th>Valor</th></tr></thead>
          <tbody>{costs.length === 0 ? <tr><td colSpan={4} className="text-sm muted p-4 text-center">Sem lançamentos.</td></tr> :
            costs.map((c: any) => (<tr key={c.id}><td className="capitalize text-sm">{c.cost_type}</td><td className="text-xs muted">{c.entity_type ?? "—"}</td><td className="text-xs tabular-nums">{c.competence ?? "—"}</td><td className="tabular-nums text-sm">{brl(c.amount)}</td></tr>))}</tbody>
        </table>
      </div>
    </div>
  );
}

function Simulador({ carriers }: any) {
  const supabase = useMemo(() => createClient(), []);
  const [weight, setWeight] = useState("100");
  const [uf, setUf] = useState("");
  const [rows, setRows] = useState<any[] | null>(null);
  const [busy, setBusy] = useState(false);
  async function run() {
    if (!supabase) return; setBusy(true);
    const { data } = await supabase.rpc("simulate_carrier_freight", { p_company: COMPANY, p_weight: Number(weight), p_origin_uf: uf || null, p_value: 0 });
    setRows(data ?? []); setBusy(false);
  }
  return (
    <div className="space-y-3">
      <div className="card p-4">
        <div className="font-semibold mb-2">Simulador de frete entre transportadoras</div>
        <div className="flex flex-wrap gap-2 items-end">
          <label className="text-sm">Peso (kg)<input className="input mt-1 w-32" type="number" value={weight} onChange={(e) => setWeight(e.target.value)} /></label>
          <label className="text-sm">UF origem<input className="input mt-1 w-24" value={uf} maxLength={2} onChange={(e) => setUf(e.target.value.toUpperCase())} /></label>
          <button onClick={run} disabled={busy} className="btn btn-primary btn-sm">{busy ? "Calculando…" : "Comparar"}</button>
        </div>
      </div>
      {rows && (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead><tr><th>Transportadora</th><th>R$/kg</th><th>Frete estimado</th><th>Prazo</th><th></th></tr></thead>
            <tbody>{rows.length === 0 ? <tr><td colSpan={5} className="text-sm muted p-4 text-center">Sem tabela de frete para os parâmetros.</td></tr> :
              rows.map((r: any, i: number) => (
                <tr key={r.carrier_id}>
                  <td className="font-medium">{r.carrier}</td>
                  <td className="tabular-nums text-sm">{brl(r.price_per_kg)}</td>
                  <td className="tabular-nums text-sm font-semibold">{brl(r.freight)}</td>
                  <td className="text-xs">{r.lead_time_days ?? "—"} d</td>
                  <td>{i === 0 && <span className="badge badge-success">mais econômica</span>}{i === rows.length - 1 && rows.length > 1 && <span className="badge badge-danger">mais cara</span>}</td>
                </tr>
              ))}</tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function Contratos({ contracts, carriers }: any) {
  const cname = (id: string) => carriers.find((c: any) => c.id === id)?.name ?? "—";
  const today = new Date().toISOString().slice(0, 10);
  return (
    <div className="card p-0 overflow-x-auto">
      <table className="tbl">
        <thead><tr><th>Contrato</th><th>Transportadora</th><th>GRIS</th><th>Ad Valorem</th><th>Vigência</th><th>Status</th></tr></thead>
        <tbody>{contracts.length === 0 ? <tr><td colSpan={6} className="text-sm muted p-4 text-center">Nenhum contrato.</td></tr> :
          contracts.map((c: any) => {
            const expired = c.valid_to && c.valid_to < today;
            return (
              <tr key={c.id}>
                <td className="font-medium mono text-xs">{c.code}</td>
                <td className="text-sm">{cname(c.carrier_id)}</td>
                <td className="tabular-nums text-xs">{c.gris_percent ?? 0}%</td>
                <td className="tabular-nums text-xs">{c.advalorem_percent ?? 0}%</td>
                <td className="text-xs">{c.valid_from ?? "—"} → {c.valid_to ?? "—"}</td>
                <td><span className={`badge ${expired ? "badge-danger" : "badge-success"}`}>{expired ? "vencido" : (c.status ?? "active")}</span></td>
              </tr>
            );
          })}</tbody>
      </table>
    </div>
  );
}
