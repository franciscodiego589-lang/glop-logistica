"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { WO_STATUS, WO_TYPE, WO_PRIORITY, PRIORITY_CLS, woTypeLabel } from "./shared";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

type WO = { id: string; code: string | null; wo_type: string; status: string; priority: string; description: string | null; asset_id: string | null; due_date: string | null };

export default function WorkOrdersPanel({ workOrders, assets }: { workOrders: WO[]; assets: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const assetName = useMemo(() => Object.fromEntries(assets.map((a) => [a.id, a.name])), [assets]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [q, setQ] = useState("");
  const [f, setF] = useState({ code: "", asset_id: "", wo_type: "corrective", priority: "medium", description: "", due_date: "" });

  async function create() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { data, error } = await supabase.from("work_orders").insert({
      tenant_id, company_id: COMPANY, status: "open", wo_type: f.wo_type, priority: f.priority,
      code: f.code.trim() || null, asset_id: f.asset_id || null, description: f.description.trim() || null,
      due_date: f.due_date || null,
    }).select("id").single();
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.push(`/manutencao/os/${(data as any).id}`);
  }

  const filtered = useMemo(() => {
    const s = q.trim().toLowerCase();
    return s ? workOrders.filter((w) => (w.code ?? "").toLowerCase().includes(s) || (w.description ?? "").toLowerCase().includes(s) || (w.asset_id ? (assetName[w.asset_id] ?? "").toLowerCase().includes(s) : false)) : workOrders;
  }, [q, workOrders, assetName]);

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Ordens de serviço <span className="muted font-normal">({workOrders.length})</span></div>
        <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Buscar…"
          className="ml-auto border rounded-lg px-3 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500 w-44" style={{ borderColor: "var(--border)" }} />
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Nova OS"}</button>
      </div>
      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Código</label>
              <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="OS-0001"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Ativo</label>
              <select value={f.asset_id} onChange={(e) => setF({ ...f, asset_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{assets.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Tipo</label>
              <select value={f.wo_type} onChange={(e) => setF({ ...f, wo_type: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                {WO_TYPE.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Prioridade</label>
              <select value={f.priority} onChange={(e) => setF({ ...f, priority: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                {WO_PRIORITY.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Prazo</label>
              <input type="date" value={f.due_date} onChange={(e) => setF({ ...f, due_date: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div className="md:col-span-3"><label className="text-xs font-semibold muted">Descrição</label>
              <input value={f.description} onChange={(e) => setF({ ...f, description: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Criando…" : "Abrir OS"}</button>
        </div>
      )}
      {workOrders.length === 0 ? (
        <p className="text-sm muted px-1">Nenhuma ordem de serviço ainda.</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Código</th><th className="px-3">Ativo</th><th className="px-3">Tipo</th><th className="px-3">Prioridade</th><th className="px-3">Prazo</th><th className="px-3">Status</th><th></th></tr></thead>
            <tbody>
              {filtered.slice(0, 300).map((w) => {
                const overdue = w.due_date && w.due_date < new Date().toISOString().slice(0, 10) && !["done", "canceled"].includes(w.status);
                return (
                  <tr key={w.id} className="border-b last:border-0 hover:bg-black/[.02] dark:hover:bg-white/[.03]" style={{ borderColor: "var(--border)" }}>
                    <td className="py-2 px-3 font-mono">{w.code ?? w.id.slice(0, 8)}</td>
                    <td className="px-3 muted">{w.asset_id ? assetName[w.asset_id] ?? "—" : "—"}</td>
                    <td className="px-3">{woTypeLabel(w.wo_type)}</td>
                    <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${PRIORITY_CLS[w.priority] ?? ""}`}>{WO_PRIORITY.find(([v]) => v === w.priority)?.[1] ?? w.priority}</span></td>
                    <td className={`px-3 ${overdue ? "text-red-500 font-semibold" : ""}`}>{w.due_date ?? "—"}{overdue ? " ⚠" : ""}</td>
                    <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${WO_STATUS[w.status]?.cls ?? ""}`}>{WO_STATUS[w.status]?.label ?? w.status}</span></td>
                    <td className="px-3 text-right"><Link href={`/manutencao/os/${w.id}`} className="text-xs text-brand-500 hover:underline">abrir →</Link></td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
