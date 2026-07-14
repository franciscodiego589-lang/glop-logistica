"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

type Row = {
  id: string; code: string | null; name: string; warehouse_type: string;
  address: string | null; active: boolean; zones: number; bins: number;
};

const TYPES: [string, string][] = [
  ["distribution", "Distribuição (CD)"],
  ["factory", "Fábrica"],
  ["transit", "Trânsito / cross-dock"],
  ["3pl", "Operador logístico (3PL)"],
];
const typeLabel = (t: string) => TYPES.find(([v]) => v === t)?.[1] ?? t;

export default function WarehouseManager({ initial }: { initial: Row[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ name: "", code: "", warehouse_type: "distribution", address: "" });

  async function create() {
    if (!supabase || !f.name.trim()) { setErr("Informe o nome do armazém."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenantId = (comp as any)?.tenant_id ?? null;
    if (!tenantId) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { error } = await supabase.from("warehouses").insert({
      tenant_id: tenantId,
      company_id: COMPANY,
      name: f.name.trim(),
      code: f.code.trim() || null,
      warehouse_type: f.warehouse_type,
      address: f.address.trim() || null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setOpen(false); setF({ name: "", code: "", warehouse_type: "distribution", address: "" });
    router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <h2 className="font-semibold">Armazéns</h2>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">
          {open ? "Cancelar" : "+ Novo armazém"}
        </button>
      </div>

      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-2 gap-3">
            <div>
              <label className="text-xs font-semibold muted">Nome *</label>
              <input value={f.name} onChange={(e) => setF({ ...f, name: e.target.value })} autoFocus
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
            </div>
            <div>
              <label className="text-xs font-semibold muted">Código</label>
              <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="CD-01"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
            </div>
            <div>
              <label className="text-xs font-semibold muted">Tipo</label>
              <select value={f.warehouse_type} onChange={(e) => setF({ ...f, warehouse_type: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                {TYPES.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
              </select>
            </div>
            <div>
              <label className="text-xs font-semibold muted">Endereço</label>
              <input value={f.address} onChange={(e) => setF({ ...f, address: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
            </div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy}
            className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">
            {busy ? "Salvando…" : "Criar armazém"}
          </button>
        </div>
      )}

      {initial.length === 0 ? (
        <div className="card p-8 text-center">
          <div className="text-3xl mb-2">⌗</div>
          <div className="font-semibold">Nenhum armazém cadastrado</div>
          <p className="text-sm muted mt-1">Crie o primeiro armazém para começar a endereçar produtos (zonas e bins).</p>
        </div>
      ) : (
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
          {initial.map((w) => (
            <Link key={w.id} href={`/wms/${w.id}`} className="card p-4 hover:ring-1 hover:ring-brand-500/50 transition">
              <div className="flex items-start gap-2">
                <div className="font-semibold">{w.name}</div>
                {w.code && <span className="text-xs px-2 py-0.5 rounded-md bg-brand-500/15 text-brand-500 font-mono">{w.code}</span>}
              </div>
              <div className="text-xs muted mt-0.5">{typeLabel(w.warehouse_type)}</div>
              {w.address && <div className="text-xs muted mt-1 truncate">{w.address}</div>}
              <div className="flex gap-4 mt-3 text-sm">
                <span><b className="tabular-nums">{w.zones}</b> <span className="muted">zonas</span></span>
                <span><b className="tabular-nums">{w.bins}</b> <span className="muted">bins</span></span>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
