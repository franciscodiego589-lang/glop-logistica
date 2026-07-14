"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const dt = (s: string | null) => s ? new Date(s).toLocaleString("pt-BR") : "—";

type Appt = { id: string; production_order_id: string | null; equipment_id: string | null; shift: string | null; produced_quantity: number; scrap_quantity: number; rework_quantity: number; started_at: string | null; ended_at: string | null };

export default function AppointmentsPanel({ appointments, orders, equipment, orderCode }: {
  appointments: Appt[]; orders: any[]; equipment: any[]; orderCode: Record<string, string>;
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const equipName = useMemo(() => Object.fromEntries(equipment.map((e) => [e.id, e.name])), [equipment]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ production_order_id: "", equipment_id: "", shift: "", produced_quantity: "", scrap_quantity: "0", rework_quantity: "0", started_at: "", ended_at: "" });

  async function create() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const operator_id = (await supabase.auth.getUser()).data.user?.id ?? null;
    const { error } = await supabase.from("production_appointments").insert({
      tenant_id, company_id: COMPANY, operator_id,
      production_order_id: f.production_order_id || null, equipment_id: f.equipment_id || null, shift: f.shift.trim() || null,
      produced_quantity: Number(f.produced_quantity) || 0, scrap_quantity: Number(f.scrap_quantity) || 0, rework_quantity: Number(f.rework_quantity) || 0,
      started_at: f.started_at ? new Date(f.started_at).toISOString() : null,
      ended_at: f.ended_at ? new Date(f.ended_at).toISOString() : null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setF({ production_order_id: "", equipment_id: "", shift: "", produced_quantity: "", scrap_quantity: "0", rework_quantity: "0", started_at: "", ended_at: "" });
    setOpen(false); router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Apontamentos <span className="muted font-normal">({appointments.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Novo apontamento"}</button>
      </div>
      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Ordem de produção</label>
              <select value={f.production_order_id} onChange={(e) => setF({ ...f, production_order_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{orders.map((o) => <option key={o.id} value={o.id}>{o.code ?? o.id.slice(0, 8)}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Equipamento</label>
              <select value={f.equipment_id} onChange={(e) => setF({ ...f, equipment_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{equipment.map((eq) => <option key={eq.id} value={eq.id}>{eq.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Turno</label>
              <input value={f.shift} onChange={(e) => setF({ ...f, shift: e.target.value })} placeholder="1º / 2º / 3º"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Produzido</label>
              <input type="number" value={f.produced_quantity} onChange={(e) => setF({ ...f, produced_quantity: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div className="grid grid-cols-2 gap-2">
              <div><label className="text-xs font-semibold muted">Refugo</label>
                <input type="number" value={f.scrap_quantity} onChange={(e) => setF({ ...f, scrap_quantity: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div><label className="text-xs font-semibold muted">Retrabalho</label>
                <input type="number" value={f.rework_quantity} onChange={(e) => setF({ ...f, rework_quantity: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            </div>
            <div><label className="text-xs font-semibold muted">Início</label>
              <input type="datetime-local" value={f.started_at} onChange={(e) => setF({ ...f, started_at: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Fim</label>
              <input type="datetime-local" value={f.ended_at} onChange={(e) => setF({ ...f, ended_at: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Salvando…" : "Apontar"}</button>
        </div>
      )}
      {appointments.length > 0 && (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">OP</th><th className="px-3">Equipamento</th><th className="px-3">Turno</th><th className="px-3">Prod.</th><th className="px-3">Refugo</th><th className="px-3">Retrab.</th><th className="px-3">Período</th></tr></thead>
            <tbody>
              {appointments.map((a) => (
                <tr key={a.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-mono">{a.production_order_id ? orderCode[a.production_order_id] ?? "—" : "—"}</td>
                  <td className="px-3">{a.equipment_id ? equipName[a.equipment_id] ?? "—" : "—"}</td>
                  <td className="px-3">{a.shift ?? "—"}</td>
                  <td className="px-3 tabular-nums font-semibold">{a.produced_quantity}</td>
                  <td className="px-3 tabular-nums text-red-500">{a.scrap_quantity}</td>
                  <td className="px-3 tabular-nums text-amber-500">{a.rework_quantity}</td>
                  <td className="px-3 text-xs muted">{dt(a.started_at)} → {dt(a.ended_at)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
