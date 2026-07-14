"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { OUT_STATUS, money } from "./status";

type Item = { id: string; product_id: string | null; quantity: number; unit_price: number | null; total: number | null; shipped_quantity: number };
type Product = { id: string; name: string; sku: string | null; sale_price: number | null; base_uom_code: string | null };

const FLOW: Record<string, { next: string; label: string }[]> = {
  draft: [{ next: "confirmed", label: "Confirmar" }, { next: "canceled", label: "Cancelar" }],
  confirmed: [{ next: "picking", label: "Separar" }, { next: "canceled", label: "Cancelar" }],
  picking: [{ next: "packed", label: "Embalar" }],
  packed: [], allocated: [], shipped: [], invoiced: [], delivered: [], canceled: [],
};

export default function OutboundDetail({ order, items, customers, warehouses, products }: {
  order: any; items: Item[]; customers: any[]; warehouses: any[]; products: Product[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const prod = useMemo(() => Object.fromEntries(products.map((p) => [p.id, p])), [products]);
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [whId, setWhId] = useState(order.warehouse_id ?? "");
  const [it, setIt] = useState({ product_id: "", quantity: "1", unit_price: "" });

  const st = order.status as string;
  const code = order.code ?? order.id.slice(0, 8);
  const custName = customers.find((c) => c.id === order.customer_id)?.name ?? "—";
  const canEdit = st === "draft" || st === "confirmed";
  const canShip = ["confirmed", "picking", "packed", "allocated"].includes(st) && items.some((i) => i.quantity - i.shipped_quantity > 0);

  async function recalc() {
    if (!supabase) return;
    const { data } = await supabase.from("outbound_order_items").select("total").eq("outbound_order_id", order.id).is("deleted_at", null);
    const subtotal = (data ?? []).reduce((a: number, r: any) => a + (Number(r.total) || 0), 0);
    await supabase.from("outbound_orders").update({ subtotal, total: subtotal + (Number(order.freight) || 0) - (Number(order.discount) || 0) }).eq("id", order.id);
  }

  async function addItem() {
    if (!supabase) return;
    if (!it.product_id) { setErr("Escolha um produto."); return; }
    const qty = Number(it.quantity) || 0, price = Number(it.unit_price) || 0;
    if (qty <= 0) { setErr("Quantidade inválida."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", order.company_id).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    const p = prod[it.product_id];
    const { error } = await supabase.from("outbound_order_items").insert({
      tenant_id, company_id: order.company_id, outbound_order_id: order.id,
      product_id: it.product_id, quantity: qty, unit_price: price, total: qty * price, uom_code: p?.base_uom_code ?? null,
    });
    if (!error) await recalc();
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setIt({ product_id: "", quantity: "1", unit_price: "" }); router.refresh();
  }

  async function removeItem(id: string) {
    if (!supabase) return;
    await supabase.from("outbound_order_items").update({ deleted_at: new Date().toISOString(), reason_deleted: "removido" }).eq("id", id);
    await recalc(); router.refresh();
  }

  async function setStatus(next: string) {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { error } = await supabase.from("outbound_orders").update({ status: next }).eq("id", order.id);
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.refresh();
  }

  async function ship() {
    if (!supabase) return;
    if (!whId) { setErr("Selecione o armazém de expedição."); return; }
    setBusy(true); setErr(null); setMsg(null);
    const { data, error } = await supabase.rpc("ship_outbound_order", { p_order: order.id, p_warehouse: whId });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setMsg(`Expedido: ${data} item(ns) deram baixa no estoque ✓`);
    router.refresh();
  }

  return (
    <div className="space-y-4 max-w-5xl">
      <div className="flex items-center gap-3 flex-wrap">
        <Link href="/expedicao" className="muted hover:underline text-sm">← Expedição</Link>
        <h1 className="text-xl font-bold">Pedido {code}</h1>
        <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${OUT_STATUS[st]?.cls ?? ""}`}>{OUT_STATUS[st]?.label ?? st}</span>
        <span className="ml-auto text-sm muted">{custName}</span>
      </div>

      <div className="grid md:grid-cols-3 gap-3">
        <div className="card p-3"><div className="text-xs muted">Subtotal</div><b className="tabular-nums">{money(order.subtotal)}</b></div>
        <div className="card p-3"><div className="text-xs muted">Total</div><b className="tabular-nums">{money(order.total)}</b></div>
        <div className="card p-3"><div className="text-xs muted">Itens</div><b className="tabular-nums">{items.length}</b></div>
      </div>

      <div className="card p-4">
        <div className="font-semibold mb-3">Itens</div>
        {canEdit && (
          <div className="grid md:grid-cols-4 gap-2 items-end mb-4 pb-4 border-b" style={{ borderColor: "var(--border)" }}>
            <div className="md:col-span-2"><label className="text-xs font-semibold muted">Produto</label>
              <select value={it.product_id} onChange={(e) => { const p = prod[e.target.value]; setIt({ ...it, product_id: e.target.value, unit_price: it.unit_price || (p?.sale_price != null ? String(p.sale_price) : "") }); }}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{products.map((p) => <option key={p.id} value={p.id}>{p.sku ? p.sku + " · " : ""}{p.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Qtd</label>
              <input type="number" value={it.quantity} onChange={(e) => setIt({ ...it, quantity: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div className="flex gap-2 items-end">
              <div className="flex-1"><label className="text-xs font-semibold muted">Preço unit.</label>
                <input type="number" value={it.unit_price} onChange={(e) => setIt({ ...it, unit_price: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <button onClick={addItem} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">+ Add</button>
            </div>
          </div>
        )}
        {items.length === 0 ? <p className="text-sm muted">Nenhum item.</p> : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase"><th className="py-1.5 pr-3">Produto</th><th className="pr-3">Qtd</th><th className="pr-3">Preço</th><th className="pr-3">Total</th><th className="pr-3">Expedido</th><th></th></tr></thead>
              <tbody>
                {items.map((i) => (
                  <tr key={i.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                    <td className="py-1.5 pr-3">{i.product_id ? prod[i.product_id]?.name ?? "—" : "—"}</td>
                    <td className="pr-3 tabular-nums">{i.quantity}</td>
                    <td className="pr-3 tabular-nums">{money(i.unit_price)}</td>
                    <td className="pr-3 tabular-nums">{money(i.total)}</td>
                    <td className="pr-3 tabular-nums">{i.shipped_quantity}/{i.quantity}</td>
                    <td className="text-right">{canEdit && <button onClick={() => removeItem(i.id)} className="text-xs text-red-500 hover:underline">excluir</button>}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <div className="card p-4 space-y-3">
        <div className="font-semibold">Ações</div>
        <div className="flex gap-2 flex-wrap items-center">
          {FLOW[st]?.map((a) => (
            <button key={a.next} onClick={() => setStatus(a.next)} disabled={busy}
              className={`px-4 py-2 rounded-lg text-sm font-semibold disabled:opacity-60 ${a.next === "canceled" ? "border border-red-500/40 text-red-500 hover:bg-red-500/10" : "bg-brand-600 text-white hover:bg-brand-700"}`}>{a.label}</button>
          ))}
          {canShip && (
            <div className="flex items-center gap-2 ml-auto">
              <select value={whId} onChange={(e) => setWhId(e.target.value)}
                className="border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">Armazém…</option>{warehouses.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </select>
              <button onClick={ship} disabled={busy} className="px-4 py-2 rounded-lg bg-green-600 text-white text-sm font-semibold disabled:opacity-60">🚚 Expedir (baixa estoque)</button>
            </div>
          )}
        </div>
        <p className="text-xs muted">“Expedir” dá baixa dos itens no estoque do armazém (via <code>register_stock_movement</code> / <code>ship_out</code>) e marca o pedido como expedido.</p>
        {msg && <div className="text-sm text-green-500">{msg}</div>}
        {err && <div className="text-sm text-red-500">{err}</div>}
      </div>
    </div>
  );
}
