"use client";
import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const dt = (s: string | null) => s ? new Date(s).toLocaleString("pt-BR") : "—";

type Product = { id: string; name: string; sku: string | null };
type Lot = { id: string; lot_number: string; manufacture_date: string | null; expiry_date: string | null; quality_status: string; received_quantity: number | null };

const QUALITY: Record<string, { label: string; cls: string }> = {
  released: { label: "Liberado", cls: "bg-green-500/15 text-green-500" },
  quarantine: { label: "Quarentena", cls: "bg-amber-500/15 text-amber-500" },
  blocked: { label: "Bloqueado", cls: "bg-red-500/15 text-red-500" },
};

export default function LotTraceability({ products }: { products: Product[] }) {
  const supabase = useMemo(() => createClient(), []);
  const prodName = useMemo(() => Object.fromEntries(products.map((p) => [p.id, p.name])), [products]);
  const [productId, setProductId] = useState("");
  const [lots, setLots] = useState<Lot[]>([]);
  const [lot, setLot] = useState<Lot | null>(null);
  const [op, setOp] = useState<any | null>(null);
  const [consumptions, setConsumptions] = useState<any[]>([]);
  const [movements, setMovements] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!supabase || !productId) { setLots([]); setLot(null); return; }
    (async () => {
      const { data } = await supabase.from("product_lots")
        .select("id,lot_number,manufacture_date,expiry_date,quality_status,received_quantity")
        .eq("company_id", COMPANY).eq("product_id", productId).is("deleted_at", null)
        .order("manufacture_date", { ascending: false }).limit(500);
      setLots(data ?? []); setLot(null); setOp(null); setConsumptions([]); setMovements([]);
    })();
  }, [supabase, productId]);

  async function openLot(l: Lot) {
    if (!supabase) return;
    setLot(l); setLoading(true); setOp(null); setConsumptions([]); setMovements([]);
    // 1) OP que produziu este lote (montante)
    const { data: ops } = await supabase.from("production_orders")
      .select("id,code,status,produced_quantity,finished_at,product_id")
      .eq("output_lot_id", l.id).is("deleted_at", null).limit(1);
    const o = ops?.[0] ?? null; setOp(o);
    if (o) {
      const { data: cons } = await supabase.from("production_consumptions")
        .select("id,component_product_id,consumed_quantity")
        .eq("production_order_id", o.id).is("deleted_at", null).limit(500);
      setConsumptions(cons ?? []);
    }
    // 2) movimentos deste lote (jusante e entradas)
    const { data: mv } = await supabase.from("stock_movements")
      .select("id,movement_type,signed_quantity,occurred_at,reference_type,warehouse_id")
      .eq("lot_id", l.id).is("deleted_at", null).order("occurred_at", { ascending: false }).limit(500);
    setMovements(mv ?? []);
    setLoading(false);
  }

  return (
    <div className="space-y-4">
      <div className="card p-4">
        <div className="font-semibold mb-2">Rastreabilidade de lote</div>
        <p className="text-xs muted mb-3">Selecione um produto e um lote para ver a genealogia: a ordem que o produziu, os componentes/insumos consumidos e todos os movimentos do lote — para recall em segundos.</p>
        <div className="grid md:grid-cols-2 gap-3">
          <div><label className="text-xs font-semibold muted">Produto</label>
            <select value={productId} onChange={(e) => setProductId(e.target.value)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="">—</option>{products.map((p) => <option key={p.id} value={p.id}>{p.sku ? p.sku + " · " : ""}{p.name}</option>)}
            </select></div>
          <div><label className="text-xs font-semibold muted">Lote ({lots.length})</label>
            <select value={lot?.id ?? ""} onChange={(e) => { const l = lots.find((x) => x.id === e.target.value); if (l) openLot(l); }}
              disabled={lots.length === 0}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500 disabled:opacity-50" style={{ borderColor: "var(--border)" }}>
              <option value="">{lots.length ? "— selecione —" : "sem lotes"}</option>
              {lots.map((l) => <option key={l.id} value={l.id}>{l.lot_number}{l.manufacture_date ? ` (${l.manufacture_date})` : ""}</option>)}
            </select></div>
        </div>
      </div>

      {lot && (
        <div className="space-y-4">
          <div className="card p-4">
            <div className="flex items-center gap-2 flex-wrap">
              <span className="font-semibold">Lote {lot.lot_number}</span>
              <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${QUALITY[lot.quality_status]?.cls ?? ""}`}>{QUALITY[lot.quality_status]?.label ?? lot.quality_status}</span>
              <span className="ml-auto text-sm muted">fab. {lot.manufacture_date ?? "—"} · val. {lot.expiry_date ?? "—"} · qtd {lot.received_quantity ?? "—"}</span>
            </div>
          </div>

          {loading ? <div className="card p-4 text-sm muted">Carregando genealogia…</div> : (
            <>
              <div className="card p-4">
                <div className="font-semibold mb-2">◀ Montante — origem do lote</div>
                {op ? (
                  <>
                    <div className="text-sm">Produzido pela OP <b>{op.code ?? op.id.slice(0, 8)}</b> · {op.produced_quantity} un · {dt(op.finished_at)}</div>
                    {consumptions.length > 0 ? (
                      <table className="w-full text-sm mt-3">
                        <thead><tr className="text-left muted text-xs uppercase"><th className="py-1 pr-3">Insumo consumido</th><th className="pr-3">Quantidade</th></tr></thead>
                        <tbody>
                          {consumptions.map((c) => (
                            <tr key={c.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                              <td className="py-1 pr-3">{c.component_product_id ? prodName[c.component_product_id] ?? "—" : "—"}</td>
                              <td className="pr-3 tabular-nums">{c.consumed_quantity}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    ) : <p className="text-sm muted mt-2">Sem consumos registrados (OP sem BOM ou lote de origem/compra).</p>}
                  </>
                ) : <p className="text-sm muted">Este lote não veio de uma ordem de produção (provavelmente entrada de compra/recebimento).</p>}
              </div>

              <div className="card p-4">
                <div className="font-semibold mb-2">▶ Jusante — movimentos do lote ({movements.length})</div>
                {movements.length === 0 ? <p className="text-sm muted">Nenhum movimento registrado para este lote.</p> : (
                  <table className="w-full text-sm">
                    <thead><tr className="text-left muted text-xs uppercase"><th className="py-1 pr-3">Data</th><th className="pr-3">Tipo</th><th className="pr-3">Qtd</th><th className="pr-3">Referência</th></tr></thead>
                    <tbody>
                      {movements.map((m) => (
                        <tr key={m.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                          <td className="py-1 pr-3">{dt(m.occurred_at)}</td>
                          <td className="pr-3">{m.movement_type}</td>
                          <td className={`pr-3 tabular-nums ${m.signed_quantity < 0 ? "text-red-500" : "text-green-500"}`}>{m.signed_quantity > 0 ? "+" : ""}{m.signed_quantity}</td>
                          <td className="pr-3 muted text-xs">{m.reference_type ?? "—"}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                )}
              </div>
            </>
          )}
        </div>
      )}
    </div>
  );
}
