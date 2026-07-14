"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

export const TRANSFER_STATUS: Record<string, { label: string; cls: string }> = {
  draft: { label: "Rascunho", cls: "bg-slate-500/15 text-slate-400" },
  in_transit: { label: "Em trânsito", cls: "bg-amber-500/15 text-amber-500" },
  received: { label: "Recebida", cls: "bg-green-500/15 text-green-500" },
  canceled: { label: "Cancelada", cls: "bg-slate-500/15 text-slate-400" },
};

type Transfer = { id: string; code: string | null; status: string; from_warehouse_id: string; to_warehouse_id: string; is_cross_dock: boolean };

export default function TransfersPanel({ transfers, warehouses }: { transfers: Transfer[]; warehouses: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const whName = useMemo(() => Object.fromEntries(warehouses.map((w) => [w.id, w.name])), [warehouses]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ code: "", from_warehouse_id: "", to_warehouse_id: "", is_cross_dock: false });

  async function create() {
    if (!supabase) return;
    if (!f.from_warehouse_id || !f.to_warehouse_id) { setErr("Escolha origem e destino."); return; }
    if (f.from_warehouse_id === f.to_warehouse_id) { setErr("Origem e destino devem ser diferentes."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { data, error } = await supabase.from("stock_transfers").insert({
      tenant_id, company_id: COMPANY, status: "draft",
      code: f.code.trim() || null, from_warehouse_id: f.from_warehouse_id, to_warehouse_id: f.to_warehouse_id, is_cross_dock: f.is_cross_dock,
    }).select("id").single();
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.push(`/distribuicao/transferencia/${(data as any).id}`);
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Transferências <span className="muted font-normal">({transfers.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Nova transferência"}</button>
      </div>
      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Código</label>
              <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="TR-0001"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Origem *</label>
              <select value={f.from_warehouse_id} onChange={(e) => setF({ ...f, from_warehouse_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{warehouses.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Destino *</label>
              <select value={f.to_warehouse_id} onChange={(e) => setF({ ...f, to_warehouse_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{warehouses.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </select></div>
          </div>
          <label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={f.is_cross_dock} onChange={(e) => setF({ ...f, is_cross_dock: e.target.checked })} /> Cross-dock</label>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Criando…" : "Criar e adicionar itens"}</button>
        </div>
      )}
      {transfers.length === 0 ? (
        <p className="text-sm muted px-1">Nenhuma transferência ainda.</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Código</th><th className="px-3">Origem</th><th className="px-3">Destino</th><th className="px-3">Status</th><th></th></tr></thead>
            <tbody>
              {transfers.map((t) => (
                <tr key={t.id} className="border-b last:border-0 hover:bg-black/[.02] dark:hover:bg-white/[.03]" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-mono">{t.code ?? t.id.slice(0, 8)}{t.is_cross_dock ? " · XD" : ""}</td>
                  <td className="px-3">{whName[t.from_warehouse_id] ?? "—"}</td>
                  <td className="px-3">{whName[t.to_warehouse_id] ?? "—"}</td>
                  <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${TRANSFER_STATUS[t.status]?.cls ?? ""}`}>{TRANSFER_STATUS[t.status]?.label ?? t.status}</span></td>
                  <td className="px-3 text-right"><Link href={`/distribuicao/transferencia/${t.id}`} className="text-xs text-brand-500 hover:underline">abrir →</Link></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
