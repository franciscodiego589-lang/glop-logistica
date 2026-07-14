"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const dt = (s: string | null) => s ? new Date(s).toLocaleString("pt-BR") : "—";

type Reading = { id: string; equipment_id: string | null; parameter: string; value: number; unit: string | null; min_limit: number | null; max_limit: number | null; out_of_range: boolean; recorded_at: string };

export default function ReadingsPanel({ readings, equipment }: { readings: Reading[]; equipment: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const equipName = useMemo(() => Object.fromEntries(equipment.map((e) => [e.id, e.name])), [equipment]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ equipment_id: "", parameter: "", value: "", unit: "", min_limit: "", max_limit: "" });

  async function create() {
    if (!supabase) return;
    if (!f.parameter.trim() || f.value === "") { setErr("Informe o parâmetro e o valor."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { error } = await supabase.from("process_readings").insert({
      tenant_id, company_id: COMPANY, equipment_id: f.equipment_id || null,
      parameter: f.parameter.trim(), value: Number(f.value), unit: f.unit.trim() || null,
      min_limit: f.min_limit ? Number(f.min_limit) : null, max_limit: f.max_limit ? Number(f.max_limit) : null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setF({ equipment_id: "", parameter: "", value: "", unit: "", min_limit: "", max_limit: "" }); setOpen(false); router.refresh();
  }

  const oor = readings.filter((r) => r.out_of_range).length;

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Parâmetros de processo <span className="muted font-normal">({readings.length})</span></div>
        {oor > 0 && <span className="text-xs px-2 py-0.5 rounded-md bg-red-500/15 text-red-500 font-semibold">{oor} fora do limite</span>}
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Nova leitura"}</button>
      </div>
      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Equipamento</label>
              <select value={f.equipment_id} onChange={(e) => setF({ ...f, equipment_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{equipment.map((eq) => <option key={eq.id} value={eq.id}>{eq.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Parâmetro</label>
              <input value={f.parameter} onChange={(e) => setF({ ...f, parameter: e.target.value })} placeholder="temperatura, pH, peso…"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div className="grid grid-cols-2 gap-2">
              <div><label className="text-xs font-semibold muted">Valor</label>
                <input type="number" value={f.value} onChange={(e) => setF({ ...f, value: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div><label className="text-xs font-semibold muted">Unidade</label>
                <input value={f.unit} onChange={(e) => setF({ ...f, unit: e.target.value })} placeholder="°C, pH…"
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            </div>
            <div><label className="text-xs font-semibold muted">Limite mínimo</label>
              <input type="number" value={f.min_limit} onChange={(e) => setF({ ...f, min_limit: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Limite máximo</label>
              <input type="number" value={f.max_limit} onChange={(e) => setF({ ...f, max_limit: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Salvando…" : "Registrar leitura"}</button>
        </div>
      )}
      {readings.length > 0 && (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Equipamento</th><th className="px-3">Parâmetro</th><th className="px-3">Valor</th><th className="px-3">Limites</th><th className="px-3">Quando</th></tr></thead>
            <tbody>
              {readings.map((r) => (
                <tr key={r.id} className={`border-b last:border-0 ${r.out_of_range ? "bg-red-500/[.06]" : ""}`} style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">{r.equipment_id ? equipName[r.equipment_id] ?? "—" : "—"}</td>
                  <td className="px-3">{r.parameter}</td>
                  <td className={`px-3 tabular-nums font-semibold ${r.out_of_range ? "text-red-500" : ""}`}>{r.value}{r.unit ? " " + r.unit : ""}{r.out_of_range ? " ⚠" : ""}</td>
                  <td className="px-3 muted text-xs">{r.min_limit ?? "—"} … {r.max_limit ?? "—"}</td>
                  <td className="px-3 text-xs muted">{dt(r.recorded_at)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
