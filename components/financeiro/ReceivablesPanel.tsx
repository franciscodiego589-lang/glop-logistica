"use client";
import { Fragment, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { FIN_STATUS, PAY_METHOD, money, effStatus } from "./shared";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

type Receivable = { id: string; code: string | null; description: string | null; customer_id: string | null; amount: number; received_amount: number; status: string; due_date: string | null; outbound_order_id: string | null };

export default function ReceivablesPanel({ receivables, customers, banks, costCenters }: { receivables: Receivable[]; customers: any[]; banks: any[]; costCenters: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const custName = useMemo(() => Object.fromEntries(customers.map((c) => [c.id, c.name])), [customers]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [recvId, setRecvId] = useState<string | null>(null);
  const [rc, setRc] = useState({ amount: "", bank_account_id: "", method: "pix" });
  const [f, setF] = useState({ description: "", customer_id: "", cost_center_id: "", amount: "", due_date: "" });

  async function create() {
    if (!supabase) return;
    if (!f.amount || Number(f.amount) <= 0) { setErr("Informe o valor."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    const { error } = await supabase.from("receivables").insert({
      tenant_id, company_id: COMPANY, status: "open",
      description: f.description.trim() || null, customer_id: f.customer_id || null, cost_center_id: f.cost_center_id || null,
      amount: Number(f.amount), due_date: f.due_date || null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setF({ description: "", customer_id: "", cost_center_id: "", amount: "", due_date: "" }); setOpen(false); router.refresh();
  }

  function startRecv(r: Receivable) {
    setRecvId(r.id); setErr(null);
    setRc({ amount: String(Math.max(r.amount - r.received_amount, 0)), bank_account_id: banks[0]?.id ?? "", method: "pix" });
  }
  async function doRecv(id: string) {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { error } = await supabase.rpc("receive_receivable", { p_receivable: id, p_amount: Number(rc.amount) || 0, p_bank_account: rc.bank_account_id || null, p_method: rc.method });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setRecvId(null); router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Contas a receber <span className="muted font-normal">({receivables.length})</span></div>
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
            <div><label className="text-xs font-semibold muted">Cliente</label>
              <select value={f.customer_id} onChange={(e) => setF({ ...f, customer_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{customers.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
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
          {err && !recvId && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Salvando…" : "Criar título"}</button>
        </div>
      )}
      {receivables.length === 0 ? (
        <p className="text-sm muted px-1">Nenhuma conta a receber. Use "Sincronizar de operações" para gerar dos pedidos de expedição.</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Descrição</th><th className="px-3">Cliente</th><th className="px-3">Valor</th><th className="px-3">Saldo</th><th className="px-3">Vencimento</th><th className="px-3">Status</th><th></th></tr></thead>
            <tbody>
              {receivables.map((r) => {
                const es = effStatus(r.status, r.due_date); const remaining = r.amount - r.received_amount;
                return (
                  <Fragment key={r.id}>
                    <tr className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                      <td className="py-2 px-3">{r.description ?? r.code ?? "—"}</td>
                      <td className="px-3 muted">{r.customer_id ? custName[r.customer_id] ?? "—" : "—"}</td>
                      <td className="px-3 tabular-nums">{money(r.amount)}</td>
                      <td className="px-3 tabular-nums">{money(remaining)}</td>
                      <td className="px-3">{r.due_date ?? "—"}</td>
                      <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${FIN_STATUS[es]?.cls ?? ""}`}>{FIN_STATUS[es]?.label ?? es}</span></td>
                      <td className="px-3 text-right">{r.status !== "paid" && r.status !== "canceled" && <button onClick={() => startRecv(r)} className="text-xs px-2 py-1 rounded-md bg-green-600 text-white font-semibold">Receber</button>}</td>
                    </tr>
                    {recvId === r.id && (
                      <tr className="border-b" style={{ borderColor: "var(--border)" }}>
                        <td colSpan={7} className="px-3 py-2 bg-black/[.02] dark:bg-white/[.03]">
                          <div className="flex items-end gap-2 flex-wrap">
                            <div><label className="text-xs font-semibold muted">Valor</label>
                              <input type="number" value={rc.amount} onChange={(e) => setRc({ ...rc, amount: e.target.value })} className="w-28 mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none" style={{ borderColor: "var(--border)" }} /></div>
                            <div><label className="text-xs font-semibold muted">Conta</label>
                              <select value={rc.bank_account_id} onChange={(e) => setRc({ ...rc, bank_account_id: e.target.value })} className="mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none" style={{ borderColor: "var(--border)" }}>
                                <option value="">— sem baixa bancária —</option>{banks.map((b) => <option key={b.id} value={b.id}>{b.name}</option>)}
                              </select></div>
                            <div><label className="text-xs font-semibold muted">Forma</label>
                              <select value={rc.method} onChange={(e) => setRc({ ...rc, method: e.target.value })} className="mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none" style={{ borderColor: "var(--border)" }}>
                                {PAY_METHOD.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
                              </select></div>
                            <button onClick={() => doRecv(r.id)} disabled={busy} className="px-3 py-1.5 rounded-lg bg-green-600 text-white text-sm font-semibold disabled:opacity-60">Confirmar</button>
                            <button onClick={() => setRecvId(null)} className="px-3 py-1.5 rounded-lg border text-sm" style={{ borderColor: "var(--border)" }}>Cancelar</button>
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
