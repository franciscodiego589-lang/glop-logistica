"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { PO_STATUS, money } from "./status";

type Item = { id: string; product_id: string | null; quantity: number; uom_code: string | null; unit_cost: number | null; total: number | null; received_quantity: number };
type Product = { id: string; name: string; sku: string | null; cost_price: number | null; base_uom_code: string | null };
type Opt = { id: string; name: string };

// próximo status manual do PO (o 'received' vem do botão Receber via RPC)
const FLOW: Record<string, { next: string; label: string }[]> = {
  draft: [{ next: "sent", label: "Enviar ao fornecedor" }, { next: "canceled", label: "Cancelar" }],
  sent: [{ next: "confirmed", label: "Confirmar" }, { next: "canceled", label: "Cancelar" }],
  confirmed: [],
  partial: [], received: [], invoiced: [], canceled: [],
};

export default function PurchaseOrderDetail({
  po, items, suppliers, warehouses, products,
}: { po: any; items: Item[]; suppliers: Opt[]; warehouses: Opt[]; products: Product[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const prodName = useMemo(() => Object.fromEntries(products.map((p) => [p.id, p])), [products]);
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [whId, setWhId] = useState<string>(po.warehouse_id ?? "");
  const [it, setIt] = useState({ product_id: "", quantity: "1", unit_cost: "" });

  const st = po.status as string;
  const code = po.code ?? po.id.slice(0, 8);
  const supplierName = suppliers.find((s) => s.id === po.supplier_id)?.name ?? "—";
  const canEdit = st === "draft" || st === "sent";
  const canReceive = (st === "confirmed" || st === "partial" || st === "sent") && items.some((i) => i.quantity - i.received_quantity > 0);

  async function recalcTotals() {
    if (!supabase) return;
    const { data } = await supabase.from("purchase_order_items").select("total")
      .eq("purchase_order_id", po.id).is("deleted_at", null);
    const subtotal = (data ?? []).reduce((a: number, r: any) => a + (Number(r.total) || 0), 0);
    const total = subtotal + (Number(po.freight) || 0) + (Number(po.taxes) || 0);
    await supabase.from("purchase_orders").update({ subtotal, total }).eq("id", po.id);
  }

  async function addItem() {
    if (!supabase) return;
    if (!it.product_id) { setErr("Escolha um produto."); return; }
    const qty = Number(it.quantity) || 0, cost = Number(it.unit_cost) || 0;
    if (qty <= 0) { setErr("Quantidade inválida."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", po.company_id).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    const prod = prodName[it.product_id];
    const { error } = await supabase.from("purchase_order_items").insert({
      tenant_id, company_id: po.company_id, purchase_order_id: po.id,
      product_id: it.product_id, quantity: qty, unit_cost: cost, total: qty * cost,
      uom_code: prod?.base_uom_code ?? null,
    });
    if (!error) await recalcTotals();
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setIt({ product_id: "", quantity: "1", unit_cost: "" }); router.refresh();
  }

  async function removeItem(id: string) {
    if (!supabase) return;
    await supabase.from("purchase_order_items").update({ deleted_at: new Date().toISOString(), reason_deleted: "removido" }).eq("id", id);
    await recalcTotals();
    router.refresh();
  }

  async function setStatus(next: string) {
    if (!supabase) return;
    setBusy(true); setMsg(null);
    const { error } = await supabase.from("purchase_orders").update({ status: next }).eq("id", po.id);
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.refresh();
  }

  async function receive() {
    if (!supabase) return;
    if (!whId) { setErr("Selecione o armazém de recebimento."); return; }
    setBusy(true); setErr(null); setMsg(null);
    // garante o armazém no PO (a RPC usa coalesce(p_warehouse, po.warehouse_id))
    const { data, error } = await supabase.rpc("receive_purchase_order", { p_po: po.id, p_warehouse: whId });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setMsg(`Recebido no estoque: ${data} item(ns) deram entrada no armazém ✓`);
    router.refresh();
  }

  const onPct = (i: Item) => i.quantity > 0 ? Math.round((i.received_quantity / i.quantity) * 100) : 0;

  return (
    <div className="space-y-4 max-w-5xl">
      <div className="flex items-center gap-3 flex-wrap">
        <Link href="/compras" className="muted hover:underline text-sm">← Compras</Link>
        <h1 className="text-xl font-bold">Pedido {code}</h1>
        <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${PO_STATUS[st]?.cls ?? ""}`}>{PO_STATUS[st]?.label ?? st}</span>
        <span className="ml-auto text-sm muted">{supplierName}{po.expected_date ? ` · previsão ${po.expected_date}` : ""}</span>
      </div>

      <div className="grid md:grid-cols-3 gap-3">
        <div className="card p-3"><div className="text-xs muted">Subtotal</div><b className="tabular-nums">{money(po.subtotal)}</b></div>
        <div className="card p-3"><div className="text-xs muted">Total</div><b className="tabular-nums">{money(po.total)}</b></div>
        <div className="card p-3"><div className="text-xs muted">Itens</div><b className="tabular-nums">{items.length}</b></div>
      </div>

      {/* itens */}
      <div className="card p-4">
        <div className="font-semibold mb-3">Itens do pedido</div>

        {canEdit && (
          <div className="grid md:grid-cols-4 gap-2 items-end mb-4 pb-4 border-b" style={{ borderColor: "var(--border)" }}>
            <div className="md:col-span-2"><label className="text-xs font-semibold muted">Produto</label>
              <select value={it.product_id} onChange={(e) => {
                const p = prodName[e.target.value];
                setIt({ ...it, product_id: e.target.value, unit_cost: it.unit_cost || (p?.cost_price != null ? String(p.cost_price) : "") });
              }} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{products.map((p) => <option key={p.id} value={p.id}>{p.sku ? p.sku + " · " : ""}{p.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Qtd</label>
              <input type="number" value={it.quantity} onChange={(e) => setIt({ ...it, quantity: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div className="flex gap-2 items-end">
              <div className="flex-1"><label className="text-xs font-semibold muted">Custo unit.</label>
                <input type="number" value={it.unit_cost} onChange={(e) => setIt({ ...it, unit_cost: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <button onClick={addItem} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">+ Add</button>
            </div>
          </div>
        )}

        {items.length === 0 ? (
          <p className="text-sm muted">Nenhum item. Adicione produtos ao pedido.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase"><th className="py-1.5 pr-3">Produto</th><th className="pr-3">Qtd</th><th className="pr-3">Custo</th><th className="pr-3">Total</th><th className="pr-3">Recebido</th><th></th></tr></thead>
              <tbody>
                {items.map((i) => (
                  <tr key={i.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                    <td className="py-1.5 pr-3">{i.product_id ? prodName[i.product_id]?.name ?? "—" : "—"}</td>
                    <td className="pr-3 tabular-nums">{i.quantity}</td>
                    <td className="pr-3 tabular-nums">{money(i.unit_cost)}</td>
                    <td className="pr-3 tabular-nums">{money(i.total)}</td>
                    <td className="pr-3 tabular-nums">{i.received_quantity}/{i.quantity} <span className="muted text-xs">({onPct(i)}%)</span></td>
                    <td className="text-right">{canEdit && <button onClick={() => removeItem(i.id)} className="text-xs text-red-500 hover:underline">excluir</button>}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* ações */}
      <div className="card p-4 space-y-3">
        <div className="font-semibold">Ações</div>
        <div className="flex gap-2 flex-wrap items-center">
          {FLOW[st]?.map((a) => (
            <button key={a.next} onClick={() => setStatus(a.next)} disabled={busy}
              className={`px-4 py-2 rounded-lg text-sm font-semibold disabled:opacity-60 ${a.next === "canceled" ? "border border-red-500/40 text-red-500 hover:bg-red-500/10" : "bg-brand-600 text-white hover:bg-brand-700"}`}>{a.label}</button>
          ))}
          {canReceive && (
            <div className="flex items-center gap-2 ml-auto">
              <select value={whId} onChange={(e) => setWhId(e.target.value)}
                className="border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">Armazém p/ receber…</option>{warehouses.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </select>
              <button onClick={receive} disabled={busy} className="px-4 py-2 rounded-lg bg-green-600 text-white text-sm font-semibold disabled:opacity-60">📦 Receber no estoque</button>
            </div>
          )}
        </div>
        <p className="text-xs muted">“Receber” dá entrada dos itens no estoque do armazém (via <code>register_stock_movement</code>) e marca o pedido como recebido — o saldo aparece no WMS/Estoque.</p>
        {msg && <div className="text-sm text-green-500">{msg}</div>}
        {err && <div className="text-sm text-red-500">{err}</div>}
      </div>
    </div>
  );
}
