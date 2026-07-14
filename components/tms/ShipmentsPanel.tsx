"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (n: number | null) => n == null ? "—" : n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });

export const SHIP_STATUS: Record<string, { label: string; cls: string }> = {
  draft: { label: "Rascunho", cls: "bg-slate-500/15 text-slate-400" },
  planned: { label: "Planejado", cls: "bg-blue-500/15 text-blue-500" },
  dispatched: { label: "Despachado", cls: "bg-indigo-500/15 text-indigo-500" },
  in_transit: { label: "Em trânsito", cls: "bg-amber-500/15 text-amber-500" },
  delivered: { label: "Entregue", cls: "bg-green-500/15 text-green-500" },
  returned: { label: "Devolvido", cls: "bg-red-500/15 text-red-500" },
  canceled: { label: "Cancelado", cls: "bg-slate-500/15 text-slate-400" },
};

type Shipment = {
  id: string; code: string | null; tracking_code: string | null; status: string;
  dest_city: string | null; dest_uf: string | null; carrier_id: string | null;
  freight_value: number | null; cargo_value: number | null; estimated_delivery: string | null;
};
type Carrier = { id: string; name: string };

export default function ShipmentsPanel({ shipments, carriers }: { shipments: Shipment[]; carriers: Carrier[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const carrierName = useMemo(() => Object.fromEntries(carriers.map((c) => [c.id, c.name])), [carriers]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ code: "", carrier_id: "", dest_city: "", dest_uf: "", cargo_value: "", freight_value: "", estimated_delivery: "" });

  async function create() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { error } = await supabase.from("shipments").insert({
      tenant_id, company_id: COMPANY, status: "draft",
      code: f.code.trim() || null, carrier_id: f.carrier_id || null,
      dest_city: f.dest_city.trim() || null, dest_uf: f.dest_uf.trim().toUpperCase() || null,
      cargo_value: f.cargo_value ? Number(f.cargo_value) : null,
      freight_value: f.freight_value ? Number(f.freight_value) : null,
      estimated_delivery: f.estimated_delivery || null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setF({ code: "", carrier_id: "", dest_city: "", dest_uf: "", cargo_value: "", freight_value: "", estimated_delivery: "" });
    setOpen(false); router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Embarques <span className="muted font-normal">({shipments.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Novo embarque"}</button>
      </div>

      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Código</label>
              <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="EMB-0001"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Transportadora</label>
              <select value={f.carrier_id} onChange={(e) => setF({ ...f, carrier_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{carriers.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Previsão de entrega</label>
              <input type="date" value={f.estimated_delivery} onChange={(e) => setF({ ...f, estimated_delivery: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Cidade destino</label>
              <input value={f.dest_city} onChange={(e) => setF({ ...f, dest_city: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">UF</label>
              <input value={f.dest_uf} maxLength={2} onChange={(e) => setF({ ...f, dest_uf: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div className="grid grid-cols-2 gap-2">
              <div><label className="text-xs font-semibold muted">Valor carga</label>
                <input type="number" value={f.cargo_value} onChange={(e) => setF({ ...f, cargo_value: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div><label className="text-xs font-semibold muted">Frete</label>
                <input type="number" value={f.freight_value} onChange={(e) => setF({ ...f, freight_value: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            </div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Salvando…" : "Criar embarque"}</button>
        </div>
      )}

      {shipments.length === 0 ? (
        <p className="text-sm muted px-1">Nenhum embarque ainda. Crie o primeiro para rastrear a entrega.</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-3">Código</th><th className="px-3">Destino</th><th className="px-3">Transportadora</th>
                <th className="px-3">Frete</th><th className="px-3">Previsão</th><th className="px-3">Status</th><th></th>
              </tr>
            </thead>
            <tbody>
              {shipments.map((s) => (
                <tr key={s.id} className="border-b last:border-0 hover:bg-black/[.02] dark:hover:bg-white/[.03]" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-mono">{s.code ?? s.tracking_code ?? s.id.slice(0, 8)}</td>
                  <td className="px-3">{[s.dest_city, s.dest_uf].filter(Boolean).join(" / ") || "—"}</td>
                  <td className="px-3 muted">{s.carrier_id ? carrierName[s.carrier_id] ?? "—" : "—"}</td>
                  <td className="px-3 tabular-nums">{money(s.freight_value)}</td>
                  <td className="px-3">{s.estimated_delivery ?? "—"}</td>
                  <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${SHIP_STATUS[s.status]?.cls ?? ""}`}>{SHIP_STATUS[s.status]?.label ?? s.status}</span></td>
                  <td className="px-3 text-right"><Link href={`/tms/embarque/${s.id}`} className="text-xs text-brand-500 hover:underline">rastrear →</Link></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
