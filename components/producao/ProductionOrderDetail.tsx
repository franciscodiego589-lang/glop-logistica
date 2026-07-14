"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { PROD_STATUS } from "./ProducaoPanel";

type Op = { id: string; operation_seq: number; name: string | null; status: string; work_center_id: string | null; planned_minutes: number | null; actual_minutes: number | null };
type Cons = { id: string; component_product_id: string | null; planned_quantity: number | null; consumed_quantity: number };

const OP_STATUS: Record<string, string> = { pending: "Pendente", in_progress: "Em execução", done: "Concluída", skipped: "Pulada" };

const FLOW: Record<string, { next: string; label: string }[]> = {
  planned: [{ next: "released", label: "Liberar" }, { next: "canceled", label: "Cancelar" }],
  released: [{ next: "in_progress", label: "Iniciar produção" }, { next: "canceled", label: "Cancelar" }],
  in_progress: [], finished: [{ next: "closed", label: "Encerrar" }], closed: [], canceled: [],
};

export default function ProductionOrderDetail({ order, operations, consumptions, products, workCenters }: {
  order: any; operations: Op[]; consumptions: Cons[]; products: any[]; workCenters: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const prod = useMemo(() => Object.fromEntries(products.map((p) => [p.id, p])), [products]);
  const wcName = useMemo(() => Object.fromEntries(workCenters.map((w) => [w.id, w.name])), [workCenters]);
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [op, setOp] = useState({ name: "", work_center_id: "", planned_minutes: "" });
  const [fin, setFin] = useState({ produced: String(order.planned_quantity ?? ""), lot: "" });

  const st = order.status as string;
  const code = order.code ?? order.id.slice(0, 8);
  const finished = prod[order.product_id];
  const canFinish = st === "in_progress" || st === "released";

  async function tenant() {
    if (!supabase) return null;
    const { data } = await supabase.from("companies").select("tenant_id").eq("id", order.company_id).single();
    return (data as any)?.tenant_id ?? null;
  }

  async function setStatus(next: string) {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const patch: Record<string, any> = { status: next };
    if (next === "in_progress") patch.started_at = new Date().toISOString();
    const { error } = await supabase.from("production_orders").update(patch).eq("id", order.id);
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.refresh();
  }

  async function addOp() {
    if (!supabase) return;
    if (!op.name.trim()) { setErr("Informe o nome da operação."); return; }
    setBusy(true); setErr(null);
    const tenant_id = await tenant();
    const seq = (operations.reduce((m, o) => Math.max(m, o.operation_seq), 0) || 0) + 10;
    const { error } = await supabase.from("production_operations").insert({
      tenant_id, company_id: order.company_id, production_order_id: order.id,
      operation_seq: seq, name: op.name.trim(), work_center_id: op.work_center_id || null,
      planned_minutes: op.planned_minutes ? Number(op.planned_minutes) : null, status: "pending",
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setOp({ name: "", work_center_id: "", planned_minutes: "" }); router.refresh();
  }

  async function opStatus(id: string, status: string) {
    if (!supabase) return;
    await supabase.from("production_operations").update({ status }).eq("id", id);
    router.refresh();
  }

  async function finishOrder() {
    if (!supabase) return;
    const produced = Number(fin.produced) || 0;
    if (produced <= 0) { setErr("Quantidade produzida inválida."); return; }
    setBusy(true); setErr(null); setMsg(null);
    const { error } = await supabase.rpc("finish_production_order", {
      p_order: order.id, p_produced: produced, p_lot_number: fin.lot.trim() || null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setMsg(`OP finalizada ✓ — ${produced} un. deram entrada no estoque` + (order.bom_id ? " e os componentes da BOM foram consumidos." : "."));
    router.refresh();
  }

  return (
    <div className="space-y-4 max-w-5xl">
      <div className="flex items-center gap-3 flex-wrap">
        <Link href="/producao" className="muted hover:underline text-sm">← Produção / PCP</Link>
        <h1 className="text-xl font-bold">OP {code}</h1>
        <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${PROD_STATUS[st]?.cls ?? ""}`}>{PROD_STATUS[st]?.label ?? st}</span>
        <span className="ml-auto text-sm muted">{finished?.name ?? "—"}</span>
      </div>

      <div className="grid md:grid-cols-3 gap-3">
        <div className="card p-3"><div className="text-xs muted">Planejado</div><b className="tabular-nums">{order.planned_quantity} {finished?.base_uom_code ?? ""}</b></div>
        <div className="card p-3"><div className="text-xs muted">Produzido</div><b className="tabular-nums">{order.produced_quantity}</b></div>
        <div className="card p-3"><div className="text-xs muted">Estrutura (BOM)</div><b>{order.bom_id ? "vinculada" : "sem BOM"}</b></div>
      </div>

      {/* operações */}
      <div className="card p-4">
        <div className="font-semibold mb-3">Roteiro / operações ({operations.length})</div>
        {(st === "planned" || st === "released" || st === "in_progress") && (
          <div className="grid md:grid-cols-4 gap-2 items-end mb-4 pb-4 border-b" style={{ borderColor: "var(--border)" }}>
            <div className="md:col-span-2"><label className="text-xs font-semibold muted">Operação</label>
              <input value={op.name} onChange={(e) => setOp({ ...op, name: e.target.value })} placeholder="Corte, montagem, envase…"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Centro</label>
              <select value={op.work_center_id} onChange={(e) => setOp({ ...op, work_center_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{workCenters.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </select></div>
            <div className="flex gap-2 items-end">
              <div className="flex-1"><label className="text-xs font-semibold muted">Min. plan.</label>
                <input type="number" value={op.planned_minutes} onChange={(e) => setOp({ ...op, planned_minutes: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <button onClick={addOp} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">+ Add</button>
            </div>
          </div>
        )}
        {operations.length === 0 ? (
          <p className="text-sm muted">Nenhuma operação. Adicione as etapas do roteiro de produção.</p>
        ) : (
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase"><th className="py-1.5 pr-3">#</th><th className="pr-3">Operação</th><th className="pr-3">Centro</th><th className="pr-3">Min.</th><th className="pr-3">Status</th></tr></thead>
            <tbody>
              {operations.map((o) => (
                <tr key={o.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                  <td className="py-1.5 pr-3 tabular-nums">{o.operation_seq}</td>
                  <td className="pr-3">{o.name ?? "—"}</td>
                  <td className="pr-3 muted">{o.work_center_id ? wcName[o.work_center_id] ?? "—" : "—"}</td>
                  <td className="pr-3 tabular-nums">{o.planned_minutes ?? "—"}</td>
                  <td className="pr-3">
                    <select value={o.status} onChange={(e) => opStatus(o.id, e.target.value)}
                      className="text-xs px-2 py-0.5 rounded-md font-semibold bg-transparent outline-none border" style={{ borderColor: "var(--border)" }}>
                      {Object.entries(OP_STATUS).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* consumos */}
      {consumptions.length > 0 && (
        <div className="card p-4">
          <div className="font-semibold mb-3">Componentes consumidos</div>
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase"><th className="py-1.5 pr-3">Componente</th><th className="pr-3">Consumido</th></tr></thead>
            <tbody>
              {consumptions.map((c) => (
                <tr key={c.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                  <td className="py-1.5 pr-3">{c.component_product_id ? prod[c.component_product_id]?.name ?? "—" : "—"}</td>
                  <td className="pr-3 tabular-nums">{c.consumed_quantity}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* ações */}
      <div className="card p-4 space-y-3">
        <div className="font-semibold">Ações</div>
        <div className="flex gap-2 flex-wrap items-center">
          {FLOW[st]?.map((a) => (
            <button key={a.next} onClick={() => setStatus(a.next)} disabled={busy}
              className={`px-4 py-2 rounded-lg text-sm font-semibold disabled:opacity-60 ${a.next === "canceled" ? "border border-red-500/40 text-red-500 hover:bg-red-500/10" : "bg-brand-600 text-white hover:bg-brand-700"}`}>{a.label}</button>
          ))}
          {canFinish && (
            <div className="flex items-end gap-2 ml-auto flex-wrap">
              <div><label className="text-xs font-semibold muted">Qtd produzida</label>
                <input type="number" value={fin.produced} onChange={(e) => setFin({ ...fin, produced: e.target.value })}
                  className="w-28 mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div><label className="text-xs font-semibold muted">Lote (opcional)</label>
                <input value={fin.lot} onChange={(e) => setFin({ ...fin, lot: e.target.value })}
                  className="w-36 mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <button onClick={finishOrder} disabled={busy} className="px-4 py-2 rounded-lg bg-green-600 text-white text-sm font-semibold disabled:opacity-60">✅ Finalizar e dar entrada</button>
            </div>
          )}
        </div>
        <p className="text-xs muted">“Finalizar” dá entrada do acabado no estoque (cria lote) e, se houver BOM, consome os componentes automaticamente via <code>finish_production_order</code>.</p>
        {msg && <div className="text-sm text-green-500">{msg}</div>}
        {err && <div className="text-sm text-red-500">{err}</div>}
      </div>
    </div>
  );
}
