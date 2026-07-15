"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (n: any) => (n == null ? "—" : Number(n).toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 }));
const TABS = ["Painel", "Tipos de Ativo", "Empréstimos", "Manutenção", "Cobranças", "ESG"] as const;

export default function RAMSWorkbench({ dash, esg, types, loans, maintenance, charges }:
  { dash: any; esg: any; types: any[]; loans: any[]; maintenance: any[]; charges: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const [open, setOpen] = useState(false);
  const [f, setF] = useState({ asset_type_id: "", holder_name: "", quantity: "", due_date: "" });
  const typeName = useMemo(() => Object.fromEntries(types.map((t) => [t.id, t.name])), [types]);

  async function call(rpc: string, label: string) {
    if (!supabase) return;
    setBusy(rpc); setMsg(null);
    const { data, error } = await supabase.rpc(rpc, { p_company: COMPANY });
    setBusy(null);
    setMsg(error ? error.message : `${label}: ${typeof data === "object" ? `${data.charges} cobrança(s) · ${money(data.total)}` : (data ?? 0)}`); router.refresh();
  }
  async function createLoan() {
    if (!supabase || !f.asset_type_id || !f.quantity) return;
    setBusy("loan");
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    await supabase.from("asset_loans").insert({
      tenant_id: (comp as any)?.tenant_id, company_id: COMPANY, asset_type_id: f.asset_type_id, holder_type: "customer",
      holder_name: f.holder_name || null, quantity: Number(f.quantity), due_date: f.due_date || null,
    });
    setBusy(null); setOpen(false); setF({ asset_type_id: "", holder_name: "", quantity: "", due_date: "" }); router.refresh();
  }
  async function returnLoan(id: string, qty: number) {
    if (!supabase) return;
    setBusy(id);
    await supabase.rpc("return_asset_loan", { p_loan: id, p_quantity: qty });
    setBusy(null); router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">♻️</div>
        <div>
          <h1 className="text-xl font-bold">Ativos Retornáveis (RAMS)</h1>
          <p className="text-sm muted">Pallets, containers, gaiolas · empréstimos · retenção · manutenção · ESG</p>
        </div>
        <div className="ml-auto flex gap-2">
          <button onClick={() => call("rams_insights", "Retenções")} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>IA retenção</button>
          <button onClick={() => call("generate_retention_charges", "Cobranças")} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{busy === "generate_retention_charges" ? "…" : "⚡ Cobrar retenção"}</button>
        </div>
      </div>
      {msg && <div className="text-sm text-brand-500 px-1">{msg}</div>}

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <KpiCard label="Total de ativos" value={dash?.total_assets ?? "—"} />
          <KpiCard label="Emprestados" value={dash?.on_loan ?? "—"} accent />
          <KpiCard label="Disponíveis" value={dash?.available ?? "—"} />
          <KpiCard label="Empréstimos vencidos" value={dash?.overdue_loans ?? "—"} />
          <KpiCard label="A cobrar (retenção)" value={money(dash?.charges_open)} />
          <KpiCard label="Custo manutenção" value={money(dash?.maintenance_cost)} />
          <KpiCard label="Reutilizações" value={dash?.reuses ?? "—"} />
          <KpiCard label="Tipos de ativo" value={dash?.asset_types ?? "—"} />
        </div>
      )}

      {tab === "Tipos de Ativo" && (
        <CrudPanel table="returnable_asset_types" title="Tipos de ativo retornável" rows={types}
          emptyHint="Pallet PBR/CHEP, container, IBC, rack, gaiola, caixa retornável — com quantidade e taxa de retenção."
          fields={[
            { key: "name", label: "Nome", required: true }, { key: "code", label: "Código" },
            { key: "asset_class", label: "Classe", type: "select", options: [["pallet_pbr", "Pallet PBR"], ["pallet_chep", "Pallet CHEP"], ["pallet_wood", "Pallet madeira"], ["pallet_plastic", "Pallet plástico"], ["container", "Container"], ["ibc", "IBC"], ["rack", "Rack"], ["cage", "Gaiola"], ["box", "Caixa retornável"], ["other", "Outro"]], default: "pallet_pbr" },
            { key: "unit_value", label: "Valor unit. (R$)", type: "number" }, { key: "total_quantity", label: "Quantidade", type: "number" },
            { key: "daily_retention_fee", label: "Taxa retenção/dia", type: "number" },
          ]}
          columns={[{ key: "name", label: "Nome" }, { key: "asset_class", label: "Classe" }, { key: "total_quantity", label: "Qtd" }, { key: "daily_retention_fee", label: "Retenção/dia", fmt: (v) => money(v) }, { key: "reuses", label: "Reusos" }]} />
      )}

      {tab === "Empréstimos" && (
        <div className="space-y-3">
          <div className="flex items-center gap-2"><div className="font-semibold">Empréstimos <span className="muted font-normal">({loans.length})</span></div>
            <button onClick={() => setOpen((o) => !o)} className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Novo empréstimo"}</button></div>
          {open && (
            <div className="card p-4 grid md:grid-cols-4 gap-3 items-end">
              <div><label className="text-xs font-semibold muted">Tipo</label>
                <select value={f.asset_type_id} onChange={(e) => setF({ ...f, asset_type_id: e.target.value })} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                  <option value="">—</option>{types.map((t) => <option key={t.id} value={t.id}>{t.name}</option>)}</select></div>
              <div><label className="text-xs font-semibold muted">Detentor (cliente)</label><input value={f.holder_name} onChange={(e) => setF({ ...f, holder_name: e.target.value })} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div><label className="text-xs font-semibold muted">Quantidade</label><input type="number" value={f.quantity} onChange={(e) => setF({ ...f, quantity: e.target.value })} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div className="flex gap-2 items-end"><div className="flex-1"><label className="text-xs font-semibold muted">Devolver até</label><input type="date" value={f.due_date} onChange={(e) => setF({ ...f, due_date: e.target.value })} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
                <button onClick={createLoan} disabled={busy === "loan"} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">Emprestar</button></div>
            </div>
          )}
          {loans.length === 0 ? <p className="text-sm muted px-1">Nenhum empréstimo.</p> : (
            <div className="card p-0 overflow-x-auto">
              <table className="w-full text-sm">
                <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Ativo</th><th className="px-3">Detentor</th><th className="px-3 text-right">Qtd</th><th className="px-3 text-right">Devolvido</th><th className="px-3">Vencimento</th><th className="px-3">Status</th><th></th></tr></thead>
                <tbody>{loans.map((l) => (
                  <tr key={l.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                    <td className="py-2 px-3">{typeName[l.asset_type_id] ?? "—"}</td><td className="px-3">{l.holder_name ?? "—"}</td>
                    <td className="px-3 text-right">{l.quantity}</td><td className="px-3 text-right">{l.returned_quantity}</td>
                    <td className="px-3">{l.due_date ?? "—"}</td>
                    <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${l.status === "returned" ? "bg-green-500/15 text-green-500" : l.status === "overdue" ? "bg-red-500/15 text-red-500" : "bg-amber-500/15 text-amber-500"}`}>{l.status}</span></td>
                    <td className="px-3 text-right">{l.returned_quantity < l.quantity && <button onClick={() => returnLoan(l.id, l.quantity - l.returned_quantity)} disabled={busy === l.id} className="text-xs text-brand-500 hover:underline">devolver</button>}</td>
                  </tr>))}</tbody>
              </table>
            </div>
          )}
        </div>
      )}

      {tab === "Manutenção" && (
        <CrudPanel table="asset_maintenance" title="Manutenção de ativos" rows={maintenance}
          emptyHint="Reparo, lavagem, pintura, reforma — com custo."
          fields={[
            { key: "asset_type_id", label: "Tipo", type: "fk", fkTable: "returnable_asset_types", required: true },
            { key: "maintenance_type", label: "Tipo", type: "select", options: [["preventive", "Preventiva"], ["repair", "Reparo"], ["wash", "Lavagem"], ["paint", "Pintura"], ["reform", "Reforma"], ["scrap", "Descarte"]], default: "repair" },
            { key: "quantity", label: "Quantidade", type: "number" }, { key: "cost", label: "Custo (R$)", type: "number" }, { key: "description", label: "Descrição" },
          ]}
          columns={[{ key: "maintenance_type", label: "Tipo" }, { key: "quantity", label: "Qtd" }, { key: "cost", label: "Custo", fmt: (v) => money(v) }]} />
      )}

      {tab === "Cobranças" && (
        charges.length === 0 ? <p className="text-sm muted px-1">Nenhuma cobrança de retenção. Use “⚡ Cobrar retenção”.</p> : (
          <div className="card p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Dias vencido</th><th className="px-3 text-right">Qtd</th><th className="px-3 text-right">Valor</th><th className="px-3">Status</th></tr></thead>
              <tbody>{charges.map((c) => (
                <tr key={c.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">{c.days_overdue}</td><td className="px-3 text-right">{c.quantity}</td>
                  <td className="px-3 text-right font-semibold text-red-500">{money(c.amount)}</td><td className="px-3">{c.status}</td>
                </tr>))}</tbody>
            </table>
          </div>
        )
      )}

      {tab === "ESG" && (
        <div className="grid grid-cols-2 lg:grid-cols-3 gap-3">
          <KpiCard label="Reutilizações" value={esg?.reuses ?? "—"} accent />
          <KpiCard label="Economia vs descartável" value={money(esg?.savings_vs_disposable)} />
          <KpiCard label="CO₂ evitado (kg)" value={esg?.co2_avoided_kg ?? "—"} />
        </div>
      )}
    </div>
  );
}
