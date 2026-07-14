"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

type Comp = { id: string; component_product_id: string | null; quantity: number; uom_code: string | null; scrap_percent: number; operation_seq: number | null };
type Product = { id: string; name: string; sku: string | null; base_uom_code: string | null };

export default function BomDetail({ bom, components, products }: { bom: any; components: Comp[]; products: Product[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const prod = useMemo(() => Object.fromEntries(products.map((p) => [p.id, p])), [products]);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [c, setC] = useState({ component_product_id: "", quantity: "1", scrap_percent: "0" });

  async function add() {
    if (!supabase) return;
    if (!c.component_product_id) { setErr("Escolha o componente."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", bom.company_id).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    const p = prod[c.component_product_id];
    const { error } = await supabase.from("bom_components").insert({
      tenant_id, company_id: bom.company_id, bom_id: bom.id,
      component_product_id: c.component_product_id, quantity: Number(c.quantity) || 1,
      scrap_percent: Number(c.scrap_percent) || 0, uom_code: p?.base_uom_code ?? null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setC({ component_product_id: "", quantity: "1", scrap_percent: "0" }); router.refresh();
  }

  async function remove(id: string) {
    if (!supabase) return;
    await supabase.from("bom_components").update({ deleted_at: new Date().toISOString(), reason_deleted: "removido" }).eq("id", id);
    router.refresh();
  }

  const finished = prod[bom.product_id];

  return (
    <div className="space-y-4 max-w-4xl">
      <div className="flex items-center gap-3 flex-wrap">
        <Link href="/mrp" className="muted hover:underline text-sm">← MRP / APS</Link>
        <h1 className="text-xl font-bold">BOM · {finished?.name ?? "—"}</h1>
        {bom.name && <span className="text-xs px-2 py-0.5 rounded-md bg-brand-500/15 text-brand-500">{bom.name}</span>}
        <span className="ml-auto text-sm muted">produz {bom.output_quantity} {finished?.base_uom_code ?? ""}</span>
      </div>

      <div className="card p-4">
        <div className="font-semibold mb-3">Componentes ({components.length})</div>
        <div className="grid md:grid-cols-4 gap-2 items-end mb-4 pb-4 border-b" style={{ borderColor: "var(--border)" }}>
          <div className="md:col-span-2"><label className="text-xs font-semibold muted">Componente</label>
            <select value={c.component_product_id} onChange={(e) => setC({ ...c, component_product_id: e.target.value })}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="">—</option>{products.filter((p) => p.id !== bom.product_id).map((p) => <option key={p.id} value={p.id}>{p.sku ? p.sku + " · " : ""}{p.name}</option>)}
            </select></div>
          <div><label className="text-xs font-semibold muted">Qtd (por base)</label>
            <input type="number" value={c.quantity} onChange={(e) => setC({ ...c, quantity: e.target.value })}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          <div className="flex gap-2 items-end">
            <div className="flex-1"><label className="text-xs font-semibold muted">Perda %</label>
              <input type="number" value={c.scrap_percent} onChange={(e) => setC({ ...c, scrap_percent: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <button onClick={add} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">+ Add</button>
          </div>
        </div>
        {err && <div className="text-sm text-red-500 mb-2">{err}</div>}
        {components.length === 0 ? (
          <p className="text-sm muted">Nenhum componente. Adicione os insumos que compõem este produto.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase"><th className="py-1.5 pr-3">Componente</th><th className="pr-3">Qtd</th><th className="pr-3">UOM</th><th className="pr-3">Perda %</th><th></th></tr></thead>
              <tbody>
                {components.map((cp) => (
                  <tr key={cp.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                    <td className="py-1.5 pr-3">{cp.component_product_id ? prod[cp.component_product_id]?.name ?? "—" : "—"}</td>
                    <td className="pr-3 tabular-nums">{cp.quantity}</td>
                    <td className="pr-3 muted">{cp.uom_code ?? "—"}</td>
                    <td className="pr-3 tabular-nums">{cp.scrap_percent}%</td>
                    <td className="text-right"><button onClick={() => remove(cp.id)} className="text-xs text-red-500 hover:underline">excluir</button></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
      <p className="text-xs muted">Ao finalizar uma ordem de produção com esta BOM, os componentes são consumidos do estoque automaticamente (proporcional ao produzido + perda).</p>
    </div>
  );
}
