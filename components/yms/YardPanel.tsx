"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

const VISIT_STATUS: Record<string, { label: string; cls: string }> = {
  at_gate: { label: "Na portaria", cls: "bg-blue-500/15 text-blue-500" },
  in_yard: { label: "No pátio", cls: "bg-amber-500/15 text-amber-500" },
  at_dock: { label: "Na doca", cls: "bg-indigo-500/15 text-indigo-500" },
  departed: { label: "Saiu", cls: "bg-green-500/15 text-green-500" },
  canceled: { label: "Cancelado", cls: "bg-slate-500/15 text-slate-400" },
};

type Visit = { id: string; status: string; vehicle_plate: string | null; driver_name: string | null; warehouse_id: string | null; gate_in_at: string | null };

export default function YardPanel({ visits, warehouses }: { visits: Visit[]; warehouses: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ warehouse_id: "", vehicle_plate: "", driver_name: "" });

  async function gateIn() {
    if (!supabase) return;
    if (!f.vehicle_plate.trim()) { setErr("Informe a placa."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { error } = await supabase.from("yard_visits").insert({
      tenant_id, company_id: COMPANY, status: "at_gate", gate_in_at: new Date().toISOString(),
      warehouse_id: f.warehouse_id || null, vehicle_plate: f.vehicle_plate.trim(), driver_name: f.driver_name.trim() || null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setF({ warehouse_id: "", vehicle_plate: "", driver_name: "" }); setOpen(false); router.refresh();
  }

  async function setStatus(id: string, status: string) {
    if (!supabase) return;
    const patch: Record<string, any> = { status };
    if (status === "departed") patch.gate_out_at = new Date().toISOString();
    if (status === "at_dock") patch.dock_in_at = new Date().toISOString();
    await supabase.from("yard_visits").update(patch).eq("id", id);
    router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Pátio / fila <span className="muted font-normal">({visits.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Registrar entrada (portaria)"}</button>
      </div>
      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Armazém</label>
              <select value={f.warehouse_id} onChange={(e) => setF({ ...f, warehouse_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{warehouses.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Placa *</label>
              <input value={f.vehicle_plate} onChange={(e) => setF({ ...f, vehicle_plate: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Motorista</label>
              <input value={f.driver_name} onChange={(e) => setF({ ...f, driver_name: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={gateIn} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Registrando…" : "Registrar entrada"}</button>
        </div>
      )}
      {visits.length > 0 && (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Veículo</th><th className="px-3">Motorista</th><th className="px-3">Entrada</th><th className="px-3">Status</th></tr></thead>
            <tbody>
              {visits.map((v) => (
                <tr key={v.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-mono">{v.vehicle_plate ?? "—"}</td>
                  <td className="px-3 muted">{v.driver_name ?? "—"}</td>
                  <td className="px-3 text-xs">{v.gate_in_at ? new Date(v.gate_in_at).toLocaleString("pt-BR") : "—"}</td>
                  <td className="px-3">
                    <select value={v.status} onChange={(e) => setStatus(v.id, e.target.value)}
                      className={`text-xs px-2 py-0.5 rounded-md font-semibold bg-transparent outline-none ${VISIT_STATUS[v.status]?.cls ?? ""}`}>
                      {Object.entries(VISIT_STATUS).map(([val, o]) => <option key={val} value={val}>{o.label}</option>)}
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
