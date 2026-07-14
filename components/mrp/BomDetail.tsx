"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

type Comp = { id: string; component_product_id: string | null; quantity: number; uom_code: string | null; scrap_percent: number; operation_seq: number | null };
type Product = { id: string; name: string; sku: string | null; base_uom_code: string | null; cost_price: number | null };

const money = (n: number) => n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });

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

  // Simulador de custo da formulação (determinístico): custo = Σ custo_comp × qtd × (1+perda%)
  const cost = useMemo(() => {
    const lines = components.map((cp) => {
      const p = cp.component_product_id ? prod[cp.component_product_id] : null;
      const unit = p?.cost_price ?? 0;
      const effQty = cp.quantity * (1 + (cp.scrap_percent || 0) / 100);
      return { name: p?.name ?? "—", unit, effQty, line: unit * effQty, hasCost: p?.cost_price != null };
    });
    const total = lines.reduce((a, l) => a + l.line, 0);
    const out = Number(bom.output_quantity) || 1;
    return { lines, total, perUnit: total / out, missing: lines.some((l) => !l.hasCost) };
  }, [components, prod, bom.output_quantity]);

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
      {/* Simulador de custo industrial da formulação */}
      {components.length > 0 && (
        <div className="card p-4">
          <div className="font-semibold mb-3">Simulador de custo da formulação</div>
          <div className="grid sm:grid-cols-2 gap-2 mb-3">
            <div className="rounded-lg border p-3" style={{ borderColor: "var(--border)" }}>
              <div className="text-xs muted">Custo do lote (produz {bom.output_quantity})</div>
              <b className="tabular-nums text-lg">{money(cost.total)}</b>
            </div>
            <div className="rounded-lg border p-3 ring-1 ring-brand-500/40" style={{ borderColor: "var(--border)" }}>
              <div className="text-xs muted">Custo por unidade produzida</div>
              <b className="tabular-nums text-lg">{money(cost.perUnit)}</b>
            </div>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase"><th className="py-1 pr-3">Componente</th><th className="pr-3">Custo unit.</th><th className="pr-3">Qtd efetiva (c/ perda)</th><th className="pr-3">Custo</th></tr></thead>
              <tbody>
                {cost.lines.map((l, i) => (
                  <tr key={i} className="border-t" style={{ borderColor: "var(--border)" }}>
                    <td className="py-1 pr-3">{l.name}</td>
                    <td className="pr-3 tabular-nums">{l.hasCost ? money(l.unit) : <span className="text-amber-500">sem custo</span>}</td>
                    <td className="pr-3 tabular-nums">{l.effQty.toLocaleString("pt-BR", { maximumFractionDigits: 4 })}</td>
                    <td className="pr-3 tabular-nums">{money(l.line)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          {cost.missing && <p className="text-xs text-amber-500 mt-2">Alguns componentes não têm custo cadastrado — o total é parcial. Informe o custo no Cadastro Mestre.</p>}
        </div>
      )}

      <p className="text-xs muted">Ao finalizar uma ordem de produção com esta BOM, os componentes são consumidos do estoque automaticamente (proporcional ao produzido + perda).</p>
    </div>
  );
}
