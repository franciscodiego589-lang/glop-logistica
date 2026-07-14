"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { WO_STATUS, woTypeLabel, money } from "./shared";

type Part = { id: string; product_id: string | null; quantity: number; unit_cost: number | null; total: number | null };
type Failure = { id: string; failure_type: string | null; severity: string; cause: string | null; root_cause: string | null; rca_method: string | null; downtime_minutes: number | null; occurred_at: string };

const FLOW: Record<string, { next: string; label: string }[]> = {
  open: [{ next: "assigned", label: "Atribuir" }, { next: "canceled", label: "Cancelar" }],
  assigned: [{ next: "in_progress", label: "Iniciar" }, { next: "canceled", label: "Cancelar" }],
  in_progress: [{ next: "on_hold", label: "Pausar" }],
  on_hold: [{ next: "in_progress", label: "Retomar" }],
  planned: [{ next: "assigned", label: "Atribuir" }],
  done: [], canceled: [],
};
const SEVERITY: [string, string][] = [["low", "Baixa"], ["medium", "Média"], ["high", "Alta"], ["critical", "Crítica"]];

export default function WorkOrderDetail({ wo, parts, failures, products, assets }: {
  wo: any; parts: Part[]; failures: Failure[]; products: any[]; assets: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const prod = useMemo(() => Object.fromEntries(products.map((p) => [p.id, p])), [products]);
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [pt, setPt] = useState({ product_id: "", quantity: "1", unit_cost: "" });
  const [fa, setFa] = useState({ failure_type: "", severity: "medium", cause: "", root_cause: "", rca_method: "5whys", downtime_minutes: "" });
  const [fin, setFin] = useState({ downtime: "", cost: "", note: "" });

  const st = wo.status as string;
  const code = wo.code ?? wo.id.slice(0, 8);
  const assetName = assets.find((a) => a.id === wo.asset_id)?.name ?? "—";
  const editable = !["done", "canceled"].includes(st);
  const partsCost = parts.reduce((a, p) => a + (Number(p.total) || 0), 0);

  async function tenant() { if (!supabase) return null; const { data } = await supabase.from("companies").select("tenant_id").eq("id", wo.company_id).single(); return (data as any)?.tenant_id ?? null; }

  async function setStatus(next: string) {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const patch: Record<string, any> = { status: next };
    if (next === "in_progress" && !wo.started_at) patch.started_at = new Date().toISOString();
    const { error } = await supabase.from("work_orders").update(patch).eq("id", wo.id);
    if (!error && next === "in_progress" && wo.asset_id) await supabase.from("assets").update({ status: "maintenance" }).eq("id", wo.asset_id);
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.refresh();
  }

  async function addPart() {
    if (!supabase) return;
    if (!pt.product_id) { setErr("Escolha a peça."); return; }
    const qty = Number(pt.quantity) || 0, cost = Number(pt.unit_cost) || 0;
    setBusy(true); setErr(null);
    const tenant_id = await tenant();
    const { error } = await supabase.from("wo_parts").insert({
      tenant_id, company_id: wo.company_id, work_order_id: wo.id, product_id: pt.product_id, quantity: qty, unit_cost: cost, total: qty * cost,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setPt({ product_id: "", quantity: "1", unit_cost: "" }); router.refresh();
  }
  async function removePart(id: string) { if (!supabase) return; await supabase.from("wo_parts").update({ deleted_at: new Date().toISOString(), reason_deleted: "removido" }).eq("id", id); router.refresh(); }

  async function addFailure() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const tenant_id = await tenant();
    const { error } = await supabase.from("asset_failures").insert({
      tenant_id, company_id: wo.company_id, work_order_id: wo.id, asset_id: wo.asset_id,
      failure_type: fa.failure_type.trim() || null, severity: fa.severity, cause: fa.cause.trim() || null,
      root_cause: fa.root_cause.trim() || null, rca_method: fa.rca_method,
      downtime_minutes: fa.downtime_minutes ? Number(fa.downtime_minutes) : null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setFa({ failure_type: "", severity: "medium", cause: "", root_cause: "", rca_method: "5whys", downtime_minutes: "" }); router.refresh();
  }

  async function complete() {
    if (!supabase) return;
    setBusy(true); setErr(null); setMsg(null);
    const { error } = await supabase.rpc("complete_work_order", {
      p_wo: wo.id, p_downtime: fin.downtime ? Number(fin.downtime) : null,
      p_cost: fin.cost ? Number(fin.cost) : (partsCost || null), p_note: fin.note.trim() || null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setMsg("OS concluída ✓ — ativo normalizado" + (wo.plan_id ? " e plano preventivo reprogramado." : "."));
    router.refresh();
  }

  return (
    <div className="space-y-4 max-w-5xl">
      <div className="flex items-center gap-3 flex-wrap">
        <Link href="/manutencao" className="muted hover:underline text-sm">← Manutenção</Link>
        <h1 className="text-xl font-bold">OS {code}</h1>
        <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${WO_STATUS[st]?.cls ?? ""}`}>{WO_STATUS[st]?.label ?? st}</span>
        <span className="ml-auto text-sm muted">{woTypeLabel(wo.wo_type)} · {assetName}{wo.plan_id ? " · preventiva" : ""}</span>
      </div>
      {wo.description && <div className="card p-3 text-sm">{wo.description}</div>}

      {/* peças */}
      <div className="card p-4">
        <div className="font-semibold mb-3">Peças consumidas ({parts.length}) · {money(partsCost)}</div>
        {editable && (
          <div className="grid md:grid-cols-4 gap-2 items-end mb-4 pb-4 border-b" style={{ borderColor: "var(--border)" }}>
            <div className="md:col-span-2"><label className="text-xs font-semibold muted">Peça</label>
              <select value={pt.product_id} onChange={(e) => { const p = prod[e.target.value]; setPt({ ...pt, product_id: e.target.value, unit_cost: pt.unit_cost || (p?.cost_price != null ? String(p.cost_price) : "") }); }}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{products.map((p) => <option key={p.id} value={p.id}>{p.sku ? p.sku + " · " : ""}{p.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Qtd</label>
              <input type="number" value={pt.quantity} onChange={(e) => setPt({ ...pt, quantity: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div className="flex gap-2 items-end">
              <div className="flex-1"><label className="text-xs font-semibold muted">Custo un.</label>
                <input type="number" value={pt.unit_cost} onChange={(e) => setPt({ ...pt, unit_cost: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <button onClick={addPart} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">+ Add</button>
            </div>
          </div>
        )}
        {parts.length === 0 ? <p className="text-sm muted">Nenhuma peça.</p> : (
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase"><th className="py-1.5 pr-3">Peça</th><th className="pr-3">Qtd</th><th className="pr-3">Custo</th><th className="pr-3">Total</th><th></th></tr></thead>
            <tbody>
              {parts.map((p) => (
                <tr key={p.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                  <td className="py-1.5 pr-3">{p.product_id ? prod[p.product_id]?.name ?? "—" : "—"}</td>
                  <td className="pr-3 tabular-nums">{p.quantity}</td>
                  <td className="pr-3 tabular-nums">{money(p.unit_cost)}</td>
                  <td className="pr-3 tabular-nums">{money(p.total)}</td>
                  <td className="text-right">{editable && <button onClick={() => removePart(p.id)} className="text-xs text-red-500 hover:underline">excluir</button>}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* falhas / RCA */}
      <div className="card p-4">
        <div className="font-semibold mb-3">Falhas / análise de causa ({failures.length})</div>
        {editable && (
          <div className="grid md:grid-cols-3 gap-2 items-end mb-4 pb-4 border-b" style={{ borderColor: "var(--border)" }}>
            <div><label className="text-xs font-semibold muted">Tipo de falha</label>
              <input value={fa.failure_type} onChange={(e) => setFa({ ...fa, failure_type: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Severidade</label>
              <select value={fa.severity} onChange={(e) => setFa({ ...fa, severity: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                {SEVERITY.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Parada (min)</label>
              <input type="number" value={fa.downtime_minutes} onChange={(e) => setFa({ ...fa, downtime_minutes: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Causa</label>
              <input value={fa.cause} onChange={(e) => setFa({ ...fa, cause: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Causa raiz (RCA)</label>
              <input value={fa.root_cause} onChange={(e) => setFa({ ...fa, root_cause: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div className="flex gap-2 items-end">
              <div className="flex-1"><label className="text-xs font-semibold muted">Método</label>
                <select value={fa.rca_method} onChange={(e) => setFa({ ...fa, rca_method: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                  <option value="5whys">5 Porquês</option><option value="ishikawa">Ishikawa</option><option value="fmea">FMEA</option><option value="rca">RCA</option>
                </select></div>
              <button onClick={addFailure} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">+ Add</button>
            </div>
          </div>
        )}
        {failures.length === 0 ? <p className="text-sm muted">Nenhuma falha registrada.</p> : (
          <div className="space-y-1 text-sm">
            {failures.map((x) => (
              <div key={x.id} className="flex gap-2 flex-wrap">
                <span className="font-semibold">{x.failure_type ?? "Falha"}</span>
                <span className="text-xs px-1.5 py-0.5 rounded bg-red-500/15 text-red-500">{SEVERITY.find(([v]) => v === x.severity)?.[1] ?? x.severity}</span>
                {x.cause && <span className="muted">causa: {x.cause}</span>}
                {x.root_cause && <span className="muted">· raiz: {x.root_cause} ({x.rca_method})</span>}
                {x.downtime_minutes != null && <span className="muted">· {x.downtime_minutes}min</span>}
              </div>
            ))}
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
          {editable && (
            <div className="flex items-end gap-2 ml-auto flex-wrap">
              <div><label className="text-xs font-semibold muted">Parada (min)</label>
                <input type="number" value={fin.downtime} onChange={(e) => setFin({ ...fin, downtime: e.target.value })}
                  className="w-24 mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div><label className="text-xs font-semibold muted">Custo</label>
                <input type="number" value={fin.cost} onChange={(e) => setFin({ ...fin, cost: e.target.value })} placeholder={partsCost ? String(partsCost) : ""}
                  className="w-28 mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <button onClick={complete} disabled={busy} className="px-4 py-2 rounded-lg bg-green-600 text-white text-sm font-semibold disabled:opacity-60">✅ Concluir OS</button>
            </div>
          )}
        </div>
        <p className="text-xs muted">Concluir fecha a OS, normaliza o ativo e — se for de um plano preventivo — reprograma a próxima data automaticamente.</p>
        {msg && <div className="text-sm text-green-500">{msg}</div>}
        {err && <div className="text-sm text-red-500">{err}</div>}
      </div>
    </div>
  );
}
