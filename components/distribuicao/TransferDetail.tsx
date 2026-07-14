"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { TRANSFER_STATUS } from "./TransfersPanel";

type Item = { id: string; product_id: string | null; quantity: number; received_quantity: number };
type Product = { id: string; name: string; sku: string | null; base_uom_code: string | null };

export default function TransferDetail({ transfer, items, warehouses, products }: {
  transfer: any; items: Item[]; warehouses: any[]; products: Product[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const prod = useMemo(() => Object.fromEntries(products.map((p) => [p.id, p])), [products]);
  const whName = useMemo(() => Object.fromEntries(warehouses.map((w) => [w.id, w.name])), [warehouses]);
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [it, setIt] = useState({ product_id: "", quantity: "1" });

  const st = transfer.status as string;
  const code = transfer.code ?? transfer.id.slice(0, 8);
  const canEdit = st === "draft";
  const canReceive = (st === "draft" || st === "in_transit") && items.length > 0;

  async function addItem() {
    if (!supabase) return;
    if (!it.product_id) { setErr("Escolha um produto."); return; }
    const qty = Number(it.quantity) || 0;
    if (qty <= 0) { setErr("Quantidade inválida."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", transfer.company_id).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    const { error } = await supabase.from("stock_transfer_items").insert({
      tenant_id, company_id: transfer.company_id, transfer_id: transfer.id, product_id: it.product_id, quantity: qty,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setIt({ product_id: "", quantity: "1" }); router.refresh();
  }

  async function removeItem(id: string) {
    if (!supabase) return;
    await supabase.from("stock_transfer_items").update({ deleted_at: new Date().toISOString(), reason_deleted: "removido" }).eq("id", id);
    router.refresh();
  }

  async function setStatus(next: string) {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const patch: Record<string, any> = { status: next };
    if (next === "in_transit") patch.shipped_at = new Date().toISOString();
    const { error } = await supabase.from("stock_transfers").update(patch).eq("id", transfer.id);
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.refresh();
  }

  async function receive() {
    if (!supabase) return;
    setBusy(true); setErr(null); setMsg(null);
    const { data, error } = await supabase.rpc("receive_stock_transfer", { p_transfer: transfer.id });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setMsg(`Recebido: ${data} item(ns) movidos de ${whName[transfer.from_warehouse_id] ?? "origem"} para ${whName[transfer.to_warehouse_id] ?? "destino"} ✓`);
    router.refresh();
  }

  return (
    <div className="space-y-4 max-w-4xl">
      <div className="flex items-center gap-3 flex-wrap">
        <Link href="/distribuicao" className="muted hover:underline text-sm">← Distribuição</Link>
        <h1 className="text-xl font-bold">Transferência {code}</h1>
        <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${TRANSFER_STATUS[st]?.cls ?? ""}`}>{TRANSFER_STATUS[st]?.label ?? st}</span>
        <span className="ml-auto text-sm muted">{whName[transfer.from_warehouse_id] ?? "—"} → {whName[transfer.to_warehouse_id] ?? "—"}</span>
      </div>

      <div className="card p-4">
        <div className="font-semibold mb-3">Itens ({items.length})</div>
        {canEdit && (
          <div className="grid md:grid-cols-3 gap-2 items-end mb-4 pb-4 border-b" style={{ borderColor: "var(--border)" }}>
            <div className="md:col-span-2"><label className="text-xs font-semibold muted">Produto</label>
              <select value={it.product_id} onChange={(e) => setIt({ ...it, product_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{products.map((p) => <option key={p.id} value={p.id}>{p.sku ? p.sku + " · " : ""}{p.name}</option>)}
              </select></div>
            <div className="flex gap-2 items-end">
              <div className="flex-1"><label className="text-xs font-semibold muted">Qtd</label>
                <input type="number" value={it.quantity} onChange={(e) => setIt({ ...it, quantity: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <button onClick={addItem} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">+ Add</button>
            </div>
          </div>
        )}
        {items.length === 0 ? <p className="text-sm muted">Nenhum item.</p> : (
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase"><th className="py-1.5 pr-3">Produto</th><th className="pr-3">Qtd</th><th className="pr-3">Recebido</th><th></th></tr></thead>
            <tbody>
              {items.map((i) => (
                <tr key={i.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                  <td className="py-1.5 pr-3">{i.product_id ? prod[i.product_id]?.name ?? "—" : "—"}</td>
                  <td className="pr-3 tabular-nums">{i.quantity}</td>
                  <td className="pr-3 tabular-nums">{i.received_quantity}/{i.quantity}</td>
                  <td className="text-right">{canEdit && <button onClick={() => removeItem(i.id)} className="text-xs text-red-500 hover:underline">excluir</button>}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      <div className="card p-4 space-y-3">
        <div className="font-semibold">Ações</div>
        <div className="flex gap-2 flex-wrap items-center">
          {st === "draft" && <button onClick={() => setStatus("in_transit")} disabled={busy || items.length === 0} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">Enviar (em trânsito)</button>}
          {st !== "received" && st !== "canceled" && <button onClick={() => setStatus("canceled")} disabled={busy} className="px-4 py-2 rounded-lg border border-red-500/40 text-red-500 text-sm hover:bg-red-500/10">Cancelar</button>}
          {canReceive && <button onClick={receive} disabled={busy} className="px-4 py-2 rounded-lg bg-green-600 text-white text-sm font-semibold disabled:opacity-60 ml-auto">📥 Receber (move estoque)</button>}
        </div>
        <p className="text-xs muted">“Receber” dá saída na origem e entrada no destino (via <code>register_stock_movement</code> / <code>receive_stock_transfer</code>).</p>
        {msg && <div className="text-sm text-green-500">{msg}</div>}
        {err && <div className="text-sm text-red-500">{err}</div>}
      </div>
    </div>
  );
}
