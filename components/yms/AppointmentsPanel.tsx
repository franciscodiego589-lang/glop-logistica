"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

const APPT_STATUS: Record<string, { label: string; cls: string }> = {
  scheduled: { label: "Agendado", cls: "bg-blue-500/15 text-blue-500" },
  confirmed: { label: "Confirmado", cls: "bg-indigo-500/15 text-indigo-500" },
  arrived: { label: "Chegou", cls: "bg-amber-500/15 text-amber-500" },
  in_service: { label: "Em atendimento", cls: "bg-amber-500/15 text-amber-500" },
  completed: { label: "Concluído", cls: "bg-green-500/15 text-green-500" },
  no_show: { label: "No-show", cls: "bg-red-500/15 text-red-500" },
  canceled: { label: "Cancelado", cls: "bg-slate-500/15 text-slate-400" },
};
const dt = (s: string | null) => s ? new Date(s).toLocaleString("pt-BR") : "—";

type Appt = { id: string; code: string | null; status: string; direction: string; dock_id: string; vehicle_plate: string | null; driver_name: string | null; scheduled_start: string; scheduled_end: string };

export default function AppointmentsPanel({ appointments, docks }: { appointments: Appt[]; docks: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const dockName = useMemo(() => Object.fromEntries(docks.map((d) => [d.id, d.code + (d.name ? " · " + d.name : "")])), [docks]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ code: "", dock_id: "", direction: "inbound", vehicle_plate: "", driver_name: "", scheduled_start: "", scheduled_end: "" });

  async function create() {
    if (!supabase) return;
    if (!f.dock_id) { setErr("Escolha a doca."); return; }
    if (!f.scheduled_start || !f.scheduled_end) { setErr("Informe início e fim da janela."); return; }
    if (new Date(f.scheduled_end) <= new Date(f.scheduled_start)) { setErr("O fim deve ser após o início."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { error } = await supabase.from("dock_appointments").insert({
      tenant_id, company_id: COMPANY, status: "scheduled",
      code: f.code.trim() || null, dock_id: f.dock_id, direction: f.direction,
      vehicle_plate: f.vehicle_plate.trim() || null, driver_name: f.driver_name.trim() || null,
      scheduled_start: new Date(f.scheduled_start).toISOString(), scheduled_end: new Date(f.scheduled_end).toISOString(),
    });
    setBusy(false);
    if (error) { setErr(error.message.includes("overlap") || error.message.includes("exclus") ? "Já existe agendamento nessa doca nesse horário." : error.message); return; }
    setF({ code: "", dock_id: "", direction: "inbound", vehicle_plate: "", driver_name: "", scheduled_start: "", scheduled_end: "" }); setOpen(false); router.refresh();
  }

  async function setStatus(id: string, status: string) {
    if (!supabase) return;
    const patch: Record<string, any> = { status };
    if (status === "arrived") patch.arrived_at = new Date().toISOString();
    if (status === "in_service") patch.started_at = new Date().toISOString();
    if (status === "completed") patch.finished_at = new Date().toISOString();
    await supabase.from("dock_appointments").update(patch).eq("id", id);
    router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Agendamentos de doca <span className="muted font-normal">({appointments.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }} disabled={docks.length === 0}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold disabled:opacity-50">{open ? "Cancelar" : "+ Novo agendamento"}</button>
      </div>
      {docks.length === 0 && <p className="text-sm muted px-1">Cadastre docas primeiro (aba Docas) para agendar.</p>}
      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Código</label>
              <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="AG-0001"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Doca *</label>
              <select value={f.dock_id} onChange={(e) => setF({ ...f, dock_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{docks.map((d) => <option key={d.id} value={d.id}>{d.code}{d.name ? " · " + d.name : ""}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Direção</label>
              <select value={f.direction} onChange={(e) => setF({ ...f, direction: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="inbound">Recebimento</option><option value="outbound">Expedição</option><option value="both">Ambos</option>
              </select></div>
            <div><label className="text-xs font-semibold muted">Início *</label>
              <input type="datetime-local" value={f.scheduled_start} onChange={(e) => setF({ ...f, scheduled_start: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Fim *</label>
              <input type="datetime-local" value={f.scheduled_end} onChange={(e) => setF({ ...f, scheduled_end: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Placa / motorista</label>
              <input value={f.vehicle_plate} onChange={(e) => setF({ ...f, vehicle_plate: e.target.value })} placeholder="Placa"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          </div>
          <input value={f.driver_name} onChange={(e) => setF({ ...f, driver_name: e.target.value })} placeholder="Nome do motorista"
            className="w-full border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500 max-w-sm" style={{ borderColor: "var(--border)" }} />
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Salvando…" : "Agendar"}</button>
        </div>
      )}
      {appointments.length > 0 && (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Doca</th><th className="px-3">Janela</th><th className="px-3">Veículo</th><th className="px-3">Status</th></tr></thead>
            <tbody>
              {appointments.map((a) => (
                <tr key={a.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">{dockName[a.dock_id] ?? "—"}</td>
                  <td className="px-3 text-xs">{dt(a.scheduled_start)} → {dt(a.scheduled_end)}</td>
                  <td className="px-3">{[a.vehicle_plate, a.driver_name].filter(Boolean).join(" · ") || "—"}</td>
                  <td className="px-3">
                    <select value={a.status} onChange={(e) => setStatus(a.id, e.target.value)}
                      className={`text-xs px-2 py-0.5 rounded-md font-semibold bg-transparent outline-none ${APPT_STATUS[a.status]?.cls ?? ""}`}>
                      {Object.entries(APPT_STATUS).map(([v, o]) => <option key={v} value={v}>{o.label}</option>)}
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
