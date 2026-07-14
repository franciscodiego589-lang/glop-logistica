"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { PO_STATUS, money } from "./status";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

type PO = {
  id: string; code: string | null; status: string; supplier_id: string | null; warehouse_id: string | null;
  order_date: string | null; expected_date: string | null; total: number | null;
};
type Opt = { id: string; name?: string };

export default function PurchaseOrdersPanel({ pos, suppliers, warehouses }: { pos: PO[]; suppliers: Opt[]; warehouses: Opt[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const supName = useMemo(() => Object.fromEntries(suppliers.map((s) => [s.id, s.name])), [suppliers]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ code: "", supplier_id: "", warehouse_id: "", expected_date: "", payment_terms: "" });

  async function create() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { data, error } = await supabase.from("purchase_orders").insert({
      tenant_id, company_id: COMPANY, status: "draft",
      code: f.code.trim() || null, supplier_id: f.supplier_id || null, warehouse_id: f.warehouse_id || null,
      order_date: new Date().toISOString().slice(0, 10),
      expected_date: f.expected_date || null, payment_terms: f.payment_terms.trim() || null,
    }).select("id").single();
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.push(`/compras/pedido/${(data as any).id}`);
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Pedidos de compra <span className="muted font-normal">({pos.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Novo pedido"}</button>
      </div>

      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Código</label>
              <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="PO-0001"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Fornecedor</label>
              <select value={f.supplier_id} onChange={(e) => setF({ ...f, supplier_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{suppliers.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Armazém (recebimento)</label>
              <select value={f.warehouse_id} onChange={(e) => setF({ ...f, warehouse_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{warehouses.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Previsão de entrega</label>
              <input type="date" value={f.expected_date} onChange={(e) => setF({ ...f, expected_date: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Condição de pagamento</label>
              <input value={f.payment_terms} onChange={(e) => setF({ ...f, payment_terms: e.target.value })} placeholder="30/60/90"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Criando…" : "Criar e adicionar itens"}</button>
        </div>
      )}

      {pos.length === 0 ? (
        <p className="text-sm muted px-1">Nenhum pedido ainda. Crie o primeiro para adicionar itens e receber no estoque.</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-3">Código</th><th className="px-3">Fornecedor</th><th className="px-3">Previsão</th><th className="px-3">Total</th><th className="px-3">Status</th><th></th>
              </tr>
            </thead>
            <tbody>
              {pos.map((p) => (
                <tr key={p.id} className="border-b last:border-0 hover:bg-black/[.02] dark:hover:bg-white/[.03]" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-mono">{p.code ?? p.id.slice(0, 8)}</td>
                  <td className="px-3 muted">{p.supplier_id ? supName[p.supplier_id] ?? "—" : "—"}</td>
                  <td className="px-3">{p.expected_date ?? "—"}</td>
                  <td className="px-3 tabular-nums">{money(p.total)}</td>
                  <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${PO_STATUS[p.status]?.cls ?? ""}`}>{PO_STATUS[p.status]?.label ?? p.status}</span></td>
                  <td className="px-3 text-right"><Link href={`/compras/pedido/${p.id}`} className="text-xs text-brand-500 hover:underline">abrir →</Link></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
