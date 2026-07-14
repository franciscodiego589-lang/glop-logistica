"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { DOWNTIME_REASON, reasonLabel } from "./shared";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const dt = (s: string | null) => s ? new Date(s).toLocaleString("pt-BR") : "—";

type Downtime = { id: string; equipment_id: string | null; reason: string; started_at: string | null; ended_at: string | null; minutes: number | null; notes: string | null };

export default function DowntimesPanel({ downtimes, equipment, orders }: { downtimes: Downtime[]; equipment: any[]; orders: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const equipName = useMemo(() => Object.fromEntries(equipment.map((e) => [e.id, e.name])), [equipment]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ equipment_id: "", production_order_id: "", reason: "breakdown", started_at: "", ended_at: "", minutes: "", notes: "" });

  async function create() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    // minutos: usa o informado ou calcula de início→fim
    let minutes: number | null = f.minutes ? Number(f.minutes) : null;
    if (minutes == null && f.started_at && f.ended_at) minutes = Math.max(0, Math.round((new Date(f.ended_at).getTime() - new Date(f.started_at).getTime()) / 60000));
    const { error } = await supabase.from("production_downtimes").insert({
      tenant_id, company_id: COMPANY, reason: f.reason,
      equipment_id: f.equipment_id || null, production_order_id: f.production_order_id || null,
      started_at: f.started_at ? new Date(f.started_at).toISOString() : null,
      ended_at: f.ended_at ? new Date(f.ended_at).toISOString() : null,
      minutes, notes: f.notes.trim() || null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setF({ equipment_id: "", production_order_id: "", reason: "breakdown", started_at: "", ended_at: "", minutes: "", notes: "" });
    setOpen(false); router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Paradas <span className="muted font-normal">({downtimes.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Registrar parada"}</button>
      </div>
      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Equipamento</label>
              <select value={f.equipment_id} onChange={(e) => setF({ ...f, equipment_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{equipment.map((eq) => <option key={eq.id} value={eq.id}>{eq.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Motivo</label>
              <select value={f.reason} onChange={(e) => setF({ ...f, reason: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                {DOWNTIME_REASON.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Minutos (ou início/fim)</label>
              <input type="number" value={f.minutes} onChange={(e) => setF({ ...f, minutes: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Início</label>
              <input type="datetime-local" value={f.started_at} onChange={(e) => setF({ ...f, started_at: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Fim</label>
              <input type="datetime-local" value={f.ended_at} onChange={(e) => setF({ ...f, ended_at: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Observação</label>
              <input value={f.notes} onChange={(e) => setF({ ...f, notes: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Salvando…" : "Registrar"}</button>
        </div>
      )}
      {downtimes.length > 0 && (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Equipamento</th><th className="px-3">Motivo</th><th className="px-3">Minutos</th><th className="px-3">Período</th><th className="px-3">Obs.</th></tr></thead>
            <tbody>
              {downtimes.map((d) => (
                <tr key={d.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">{d.equipment_id ? equipName[d.equipment_id] ?? "—" : "—"}</td>
                  <td className="px-3"><span className="text-xs px-2 py-0.5 rounded-md bg-red-500/15 text-red-500 font-semibold">{reasonLabel(d.reason)}</span></td>
                  <td className="px-3 tabular-nums">{d.minutes ?? "—"}</td>
                  <td className="px-3 text-xs muted">{dt(d.started_at)} → {dt(d.ended_at)}</td>
                  <td className="px-3 muted text-xs">{d.notes ?? "—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
