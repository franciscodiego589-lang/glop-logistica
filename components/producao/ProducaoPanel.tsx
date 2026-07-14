"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

export const PROD_STATUS: Record<string, { label: string; cls: string }> = {
  planned: { label: "Planejada", cls: "bg-slate-500/15 text-slate-400" },
  released: { label: "Liberada", cls: "bg-blue-500/15 text-blue-500" },
  in_progress: { label: "Em produção", cls: "bg-amber-500/15 text-amber-500" },
  finished: { label: "Finalizada", cls: "bg-green-500/15 text-green-500" },
  closed: { label: "Encerrada", cls: "bg-teal-500/15 text-teal-500" },
  canceled: { label: "Cancelada", cls: "bg-slate-500/15 text-slate-400" },
};

type PO = { id: string; code: string | null; status: string; product_id: string; planned_quantity: number; produced_quantity: number; planned_end: string | null };

export default function ProducaoPanel({ orders, products, boms, warehouses, prodName }: {
  orders: PO[]; products: any[]; boms: any[]; warehouses: any[]; prodName: Record<string, string>;
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ code: "", product_id: "", planned_quantity: "1", bom_id: "", warehouse_id: "", planned_end: "" });

  const bomsForProduct = f.product_id ? boms.filter((b) => b.product_id === f.product_id) : boms;

  async function create() {
    if (!supabase) return;
    if (!f.product_id) { setErr("Escolha o produto a produzir."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    const { data, error } = await supabase.from("production_orders").insert({
      tenant_id, company_id: COMPANY, status: "planned",
      code: f.code.trim() || null, product_id: f.product_id,
      planned_quantity: Number(f.planned_quantity) || 1,
      bom_id: f.bom_id || null, warehouse_id: f.warehouse_id || null,
      planned_end: f.planned_end || null,
    }).select("id").single();
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.push(`/producao/op/${(data as any).id}`);
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Ordens de produção <span className="muted font-normal">({orders.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Nova OP"}</button>
      </div>

      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Código</label>
              <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="OP-0001"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Produto *</label>
              <select value={f.product_id} onChange={(e) => setF({ ...f, product_id: e.target.value, bom_id: "" })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{products.map((p) => <option key={p.id} value={p.id}>{p.sku ? p.sku + " · " : ""}{p.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Quantidade</label>
              <input type="number" value={f.planned_quantity} onChange={(e) => setF({ ...f, planned_quantity: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Estrutura (BOM)</label>
              <select value={f.bom_id} onChange={(e) => setF({ ...f, bom_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">— sem BOM —</option>{bomsForProduct.map((b) => <option key={b.id} value={b.id}>{b.name ?? prodName[b.product_id] ?? b.id.slice(0, 8)}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Armazém</label>
              <select value={f.warehouse_id} onChange={(e) => setF({ ...f, warehouse_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{warehouses.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Previsão de término</label>
              <input type="date" value={f.planned_end} onChange={(e) => setF({ ...f, planned_end: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Criando…" : "Criar OP"}</button>
        </div>
      )}

      {orders.length === 0 ? (
        <p className="text-sm muted px-1">Nenhuma ordem de produção ainda.</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Código</th><th className="px-3">Produto</th><th className="px-3">Planejado</th><th className="px-3">Produzido</th><th className="px-3">Previsão</th><th className="px-3">Status</th><th></th></tr></thead>
            <tbody>
              {orders.map((o) => (
                <tr key={o.id} className="border-b last:border-0 hover:bg-black/[.02] dark:hover:bg-white/[.03]" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-mono">{o.code ?? o.id.slice(0, 8)}</td>
                  <td className="px-3">{prodName[o.product_id] ?? "—"}</td>
                  <td className="px-3 tabular-nums">{o.planned_quantity}</td>
                  <td className="px-3 tabular-nums">{o.produced_quantity}</td>
                  <td className="px-3">{o.planned_end ?? "—"}</td>
                  <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${PROD_STATUS[o.status]?.cls ?? ""}`}>{PROD_STATUS[o.status]?.label ?? o.status}</span></td>
                  <td className="px-3 text-right"><Link href={`/producao/op/${o.id}`} className="text-xs text-brand-500 hover:underline">abrir →</Link></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
