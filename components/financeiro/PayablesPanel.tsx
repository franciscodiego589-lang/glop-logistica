"use client";
import { Fragment, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { FIN_STATUS, PAY_METHOD, money, effStatus } from "./shared";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

type Payable = { id: string; code: string | null; description: string | null; supplier_id: string | null; amount: number; paid_amount: number; status: string; due_date: string | null; purchase_order_id: string | null };

export default function PayablesPanel({ payables, suppliers, banks, costCenters }: { payables: Payable[]; suppliers: any[]; banks: any[]; costCenters: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const supName = useMemo(() => Object.fromEntries(suppliers.map((s) => [s.id, s.name])), [suppliers]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [payingId, setPayingId] = useState<string | null>(null);
  const [pay, setPay] = useState({ amount: "", bank_account_id: "", method: "pix" });
  const [f, setF] = useState({ description: "", supplier_id: "", cost_center_id: "", amount: "", due_date: "" });

  async function create() {
    if (!supabase) return;
    if (!f.amount || Number(f.amount) <= 0) { setErr("Informe o valor."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    const { error } = await supabase.from("payables").insert({
      tenant_id, company_id: COMPANY, status: "open",
      description: f.description.trim() || null, supplier_id: f.supplier_id || null, cost_center_id: f.cost_center_id || null,
      amount: Number(f.amount), due_date: f.due_date || null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setF({ description: "", supplier_id: "", cost_center_id: "", amount: "", due_date: "" }); setOpen(false); router.refresh();
  }

  function startPay(p: Payable) {
    setPayingId(p.id); setErr(null);
    setPay({ amount: String(Math.max(p.amount - p.paid_amount, 0)), bank_account_id: banks[0]?.id ?? "", method: "pix" });
  }
  async function doPay(id: string) {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { error } = await supabase.rpc("pay_payable", { p_payable: id, p_amount: Number(pay.amount) || 0, p_bank_account: pay.bank_account_id || null, p_method: pay.method });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setPayingId(null); router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Contas a pagar <span className="muted font-normal">({payables.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Novo título"}</button>
      </div>
      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div className="md:col-span-2"><label className="text-xs font-semibold muted">Descrição</label>
              <input value={f.description} onChange={(e) => setF({ ...f, description: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Valor</label>
              <input type="number" value={f.amount} onChange={(e) => setF({ ...f, amount: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Fornecedor</label>
              <select value={f.supplier_id} onChange={(e) => setF({ ...f, supplier_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{suppliers.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Centro de custo</label>
              <select value={f.cost_center_id} onChange={(e) => setF({ ...f, cost_center_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{costCenters.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Vencimento</label>
              <input type="date" value={f.due_date} onChange={(e) => setF({ ...f, due_date: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          </div>
          {err && !payingId && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Salvando…" : "Criar título"}</button>
        </div>
      )}
      {payables.length === 0 ? (
        <p className="text-sm muted px-1">Nenhuma conta a pagar. Use "Sincronizar de operações" para gerar dos pedidos de compra.</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Descrição</th><th className="px-3">Fornecedor</th><th className="px-3">Valor</th><th className="px-3">Saldo</th><th className="px-3">Vencimento</th><th className="px-3">Status</th><th></th></tr></thead>
            <tbody>
              {payables.map((p) => {
                const es = effStatus(p.status, p.due_date); const remaining = p.amount - p.paid_amount;
                return (
                  <Fragment key={p.id}>
                    <tr className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                      <td className="py-2 px-3">{p.description ?? p.code ?? "—"}</td>
                      <td className="px-3 muted">{p.supplier_id ? supName[p.supplier_id] ?? "—" : "—"}</td>
                      <td className="px-3 tabular-nums">{money(p.amount)}</td>
                      <td className="px-3 tabular-nums">{money(remaining)}</td>
                      <td className="px-3">{p.due_date ?? "—"}</td>
                      <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${FIN_STATUS[es]?.cls ?? ""}`}>{FIN_STATUS[es]?.label ?? es}</span></td>
                      <td className="px-3 text-right">{p.status !== "paid" && p.status !== "canceled" && <button onClick={() => startPay(p)} className="text-xs px-2 py-1 rounded-md bg-green-600 text-white font-semibold">Pagar</button>}</td>
                    </tr>
                    {payingId === p.id && (
                      <tr className="border-b" style={{ borderColor: "var(--border)" }}>
                        <td colSpan={7} className="px-3 py-2 bg-black/[.02] dark:bg-white/[.03]">
                          <div className="flex items-end gap-2 flex-wrap">
                            <div><label className="text-xs font-semibold muted">Valor</label>
                              <input type="number" value={pay.amount} onChange={(e) => setPay({ ...pay, amount: e.target.value })} className="w-28 mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none" style={{ borderColor: "var(--border)" }} /></div>
                            <div><label className="text-xs font-semibold muted">Conta</label>
                              <select value={pay.bank_account_id} onChange={(e) => setPay({ ...pay, bank_account_id: e.target.value })} className="mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none" style={{ borderColor: "var(--border)" }}>
                                <option value="">— sem baixa bancária —</option>{banks.map((b) => <option key={b.id} value={b.id}>{b.name}</option>)}
                              </select></div>
                            <div><label className="text-xs font-semibold muted">Forma</label>
                              <select value={pay.method} onChange={(e) => setPay({ ...pay, method: e.target.value })} className="mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none" style={{ borderColor: "var(--border)" }}>
                                {PAY_METHOD.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
                              </select></div>
                            <button onClick={() => doPay(p.id)} disabled={busy} className="px-3 py-1.5 rounded-lg bg-green-600 text-white text-sm font-semibold disabled:opacity-60">Confirmar</button>
                            <button onClick={() => setPayingId(null)} className="px-3 py-1.5 rounded-lg border text-sm" style={{ borderColor: "var(--border)" }}>Cancelar</button>
                            {err && <span className="text-sm text-red-500">{err}</span>}
                          </div>
                        </td>
                      </tr>
                    )}
                  </Fragment>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
