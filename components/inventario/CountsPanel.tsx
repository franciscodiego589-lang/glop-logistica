"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

export const COUNT_STATUS: Record<string, { label: string; cls: string }> = {
  open: { label: "Aberta", cls: "bg-blue-500/15 text-blue-500" },
  counting: { label: "Contando", cls: "bg-amber-500/15 text-amber-500" },
  review: { label: "Revisão", cls: "bg-amber-500/15 text-amber-500" },
  closed: { label: "Fechada", cls: "bg-green-500/15 text-green-500" },
  canceled: { label: "Cancelada", cls: "bg-slate-500/15 text-slate-400" },
};

type Count = { id: string; code: string | null; status: string; count_type: string; count_date: string | null; warehouse_id: string | null };

export default function CountsPanel({ counts, warehouses }: { counts: Count[]; warehouses: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const whName = useMemo(() => Object.fromEntries(warehouses.map((w) => [w.id, w.name])), [warehouses]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ code: "", warehouse_id: "", count_type: "cycle" });

  async function create() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { data, error } = await supabase.from("inventory_counts").insert({
      tenant_id, company_id: COMPANY, status: "open", count_date: new Date().toISOString().slice(0, 10),
      code: f.code.trim() || null, warehouse_id: f.warehouse_id || null, count_type: f.count_type,
    }).select("id").single();
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.push(`/inventario/contagem/${(data as any).id}`);
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Contagens de inventário <span className="muted font-normal">({counts.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Nova contagem"}</button>
      </div>
      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Código</label>
              <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="INV-0001"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Armazém</label>
              <select value={f.warehouse_id} onChange={(e) => setF({ ...f, warehouse_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{warehouses.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Tipo</label>
              <select value={f.count_type} onChange={(e) => setF({ ...f, count_type: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="cycle">Cíclica</option><option value="full">Geral</option><option value="spot">Spot</option>
              </select></div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Criando…" : "Criar e contar"}</button>
        </div>
      )}
      {counts.length === 0 ? (
        <p className="text-sm muted px-1">Nenhuma contagem ainda.</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Código</th><th className="px-3">Armazém</th><th className="px-3">Tipo</th><th className="px-3">Data</th><th className="px-3">Status</th><th></th></tr></thead>
            <tbody>
              {counts.map((c) => (
                <tr key={c.id} className="border-b last:border-0 hover:bg-black/[.02] dark:hover:bg-white/[.03]" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-mono">{c.code ?? c.id.slice(0, 8)}</td>
                  <td className="px-3 muted">{c.warehouse_id ? whName[c.warehouse_id] ?? "—" : "—"}</td>
                  <td className="px-3">{c.count_type}</td>
                  <td className="px-3">{c.count_date ?? "—"}</td>
                  <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${COUNT_STATUS[c.status]?.cls ?? ""}`}>{COUNT_STATUS[c.status]?.label ?? c.status}</span></td>
                  <td className="px-3 text-right"><Link href={`/inventario/contagem/${c.id}`} className="text-xs text-brand-500 hover:underline">abrir →</Link></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
