"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { OUT_STATUS, money } from "./status";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
type Order = { id: string; code: string | null; status: string; customer_id: string | null; ship_to_city: string | null; ship_to_uf: string | null; total: number | null; required_date: string | null };

export default function OutboundPanel({ orders, customers, warehouses }: { orders: Order[]; customers: any[]; warehouses: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const custName = useMemo(() => Object.fromEntries(customers.map((c) => [c.id, c.name])), [customers]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ code: "", customer_id: "", warehouse_id: "", ship_to_city: "", ship_to_uf: "", required_date: "" });

  async function create() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { data, error } = await supabase.from("outbound_orders").insert({
      tenant_id, company_id: COMPANY, status: "draft", order_date: new Date().toISOString().slice(0, 10),
      code: f.code.trim() || null, customer_id: f.customer_id || null, warehouse_id: f.warehouse_id || null,
      ship_to_city: f.ship_to_city.trim() || null, ship_to_uf: f.ship_to_uf.trim().toUpperCase() || null,
      required_date: f.required_date || null,
    }).select("id").single();
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.push(`/expedicao/pedido/${(data as any).id}`);
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Pedidos de saída <span className="muted font-normal">({orders.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Novo pedido"}</button>
      </div>
      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Código</label>
              <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="OUT-0001"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Cliente</label>
              <select value={f.customer_id} onChange={(e) => setF({ ...f, customer_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{customers.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Armazém (expedição)</label>
              <select value={f.warehouse_id} onChange={(e) => setF({ ...f, warehouse_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{warehouses.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Cidade destino</label>
              <input value={f.ship_to_city} onChange={(e) => setF({ ...f, ship_to_city: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">UF</label>
              <input value={f.ship_to_uf} maxLength={2} onChange={(e) => setF({ ...f, ship_to_uf: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Data requerida</label>
              <input type="date" value={f.required_date} onChange={(e) => setF({ ...f, required_date: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Criando…" : "Criar e adicionar itens"}</button>
        </div>
      )}
      {orders.length === 0 ? (
        <p className="text-sm muted px-1">Nenhum pedido de saída ainda.</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Código</th><th className="px-3">Cliente</th><th className="px-3">Destino</th><th className="px-3">Total</th><th className="px-3">Status</th><th></th></tr></thead>
            <tbody>
              {orders.map((o) => (
                <tr key={o.id} className="border-b last:border-0 hover:bg-black/[.02] dark:hover:bg-white/[.03]" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-mono">{o.code ?? o.id.slice(0, 8)}</td>
                  <td className="px-3 muted">{o.customer_id ? custName[o.customer_id] ?? "—" : "—"}</td>
                  <td className="px-3">{[o.ship_to_city, o.ship_to_uf].filter(Boolean).join(" / ") || "—"}</td>
                  <td className="px-3 tabular-nums">{money(o.total)}</td>
                  <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${OUT_STATUS[o.status]?.cls ?? ""}`}>{OUT_STATUS[o.status]?.label ?? o.status}</span></td>
                  <td className="px-3 text-right"><Link href={`/expedicao/pedido/${o.id}`} className="text-xs text-brand-500 hover:underline">abrir →</Link></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
