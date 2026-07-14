"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { COUNT_STATUS } from "./CountsPanel";

type Item = { id: string; product_id: string | null; system_quantity: number | null; counted_quantity: number | null; difference: number; adjusted: boolean };
type Product = { id: string; name: string; sku: string | null };

export default function CountDetail({ count, items, products }: { count: any; items: Item[]; products: Product[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const prod = useMemo(() => Object.fromEntries(products.map((p) => [p.id, p])), [products]);
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [it, setIt] = useState({ product_id: "", system_quantity: "", counted_quantity: "" });

  const st = count.status as string;
  const code = count.code ?? count.id.slice(0, 8);
  const canEdit = st !== "closed" && st !== "canceled";
  const pendingDiff = items.filter((i) => !i.adjusted && i.difference !== 0).length;

  async function pickProduct(pid: string) {
    setIt((p) => ({ ...p, product_id: pid, system_quantity: "" }));
    if (!supabase || !pid || !count.warehouse_id) return;
    // pré-preenche a quantidade de sistema com o saldo atual no armazém
    const { data } = await supabase.from("stock_balances").select("quantity")
      .eq("company_id", count.company_id).eq("product_id", pid).eq("warehouse_id", count.warehouse_id).is("deleted_at", null);
    const sys = (data ?? []).reduce((a: number, r: any) => a + (Number(r.quantity) || 0), 0);
    setIt((p) => ({ ...p, system_quantity: String(sys) }));
  }

  async function addItem() {
    if (!supabase) return;
    if (!it.product_id) { setErr("Escolha um produto."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", count.company_id).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    const { error } = await supabase.from("inventory_count_items").insert({
      tenant_id, company_id: count.company_id, count_id: count.id, product_id: it.product_id,
      system_quantity: it.system_quantity ? Number(it.system_quantity) : 0,
      counted_quantity: it.counted_quantity ? Number(it.counted_quantity) : 0,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setIt({ product_id: "", system_quantity: "", counted_quantity: "" }); router.refresh();
  }

  async function removeItem(id: string) {
    if (!supabase) return;
    await supabase.from("inventory_count_items").update({ deleted_at: new Date().toISOString(), reason_deleted: "removido" }).eq("id", id);
    router.refresh();
  }

  async function apply() {
    if (!supabase) return;
    setBusy(true); setErr(null); setMsg(null);
    const { data, error } = await supabase.rpc("apply_inventory_count", { p_count: count.id });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setMsg(`Contagem aplicada ✓ — ${data} ajuste(s) de estoque gerado(s). Contagem fechada.`);
    router.refresh();
  }

  return (
    <div className="space-y-4 max-w-4xl">
      <div className="flex items-center gap-3 flex-wrap">
        <Link href="/inventario" className="muted hover:underline text-sm">← Inventário</Link>
        <h1 className="text-xl font-bold">Contagem {code}</h1>
        <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${COUNT_STATUS[st]?.cls ?? ""}`}>{COUNT_STATUS[st]?.label ?? st}</span>
        <span className="ml-auto text-sm muted">{count.count_type} · {count.count_date ?? "—"}</span>
      </div>

      <div className="card p-4">
        <div className="font-semibold mb-3">Itens contados ({items.length})</div>
        {canEdit && (
          <div className="grid md:grid-cols-4 gap-2 items-end mb-4 pb-4 border-b" style={{ borderColor: "var(--border)" }}>
            <div className="md:col-span-2"><label className="text-xs font-semibold muted">Produto</label>
              <select value={it.product_id} onChange={(e) => pickProduct(e.target.value)}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{products.map((p) => <option key={p.id} value={p.id}>{p.sku ? p.sku + " · " : ""}{p.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Sistema</label>
              <input type="number" value={it.system_quantity} onChange={(e) => setIt({ ...it, system_quantity: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div className="flex gap-2 items-end">
              <div className="flex-1"><label className="text-xs font-semibold muted">Contado</label>
                <input type="number" value={it.counted_quantity} onChange={(e) => setIt({ ...it, counted_quantity: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <button onClick={addItem} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">+ Add</button>
            </div>
          </div>
        )}
        {items.length === 0 ? <p className="text-sm muted">Nenhum item contado.</p> : (
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase"><th className="py-1.5 pr-3">Produto</th><th className="pr-3">Sistema</th><th className="pr-3">Contado</th><th className="pr-3">Diferença</th><th className="pr-3">Ajustado</th><th></th></tr></thead>
            <tbody>
              {items.map((i) => (
                <tr key={i.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                  <td className="py-1.5 pr-3">{i.product_id ? prod[i.product_id]?.name ?? "—" : "—"}</td>
                  <td className="pr-3 tabular-nums">{i.system_quantity ?? 0}</td>
                  <td className="pr-3 tabular-nums">{i.counted_quantity ?? 0}</td>
                  <td className={`pr-3 tabular-nums font-semibold ${i.difference > 0 ? "text-green-500" : i.difference < 0 ? "text-red-500" : "muted"}`}>{i.difference > 0 ? "+" : ""}{i.difference}</td>
                  <td className="pr-3">{i.adjusted ? "✓" : "—"}</td>
                  <td className="text-right">{canEdit && <button onClick={() => removeItem(i.id)} className="text-xs text-red-500 hover:underline">excluir</button>}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {canEdit && (
        <div className="card p-4 space-y-3">
          <div className="font-semibold">Aplicar ajuste</div>
          <p className="text-xs muted">Gera movimentos de ajuste (entrada/saída) para cada diferença e fecha a contagem. {pendingDiff} item(ns) com diferença pendente.</p>
          <button onClick={apply} disabled={busy || items.length === 0} className="px-4 py-2 rounded-lg bg-green-600 text-white text-sm font-semibold disabled:opacity-60">✅ Aplicar contagem e ajustar estoque</button>
          {msg && <div className="text-sm text-green-500">{msg}</div>}
          {err && <div className="text-sm text-red-500">{err}</div>}
        </div>
      )}
    </div>
  );
}
