"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { EQUIP_STATUS, pct } from "./shared";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

type Equip = { id: string; code: string | null; name: string; status: string; equipment_type: string | null; capacity_per_hour: number | null };

function Bar({ label, value }: { label: string; value: number }) {
  const c = value >= 0.85 ? "bg-green-500" : value >= 0.6 ? "bg-amber-500" : "bg-red-500";
  return (
    <div>
      <div className="flex justify-between text-xs muted mb-1"><span>{label}</span><b className="tabular-nums">{pct(value)}</b></div>
      <div className="h-2 rounded-full bg-black/10 dark:bg-white/10 overflow-hidden"><div className={`h-full ${c}`} style={{ width: `${Math.min(value * 100, 100)}%` }} /></div>
    </div>
  );
}

export default function ShopFloorPanel({ equipment }: { equipment: Equip[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [oeeFor, setOeeFor] = useState("");
  const [from, setFrom] = useState(() => "");
  const [to, setTo] = useState("");
  const [oee, setOee] = useState<any | null>(null);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  async function setStatus(id: string, status: string) {
    if (!supabase) return;
    await supabase.from("equipment").update({ status }).eq("id", id);
    router.refresh();
  }

  async function calcOee() {
    if (!supabase || !oeeFor) { setErr("Escolha um equipamento."); return; }
    setBusy(true); setErr(null); setOee(null);
    const f = from ? new Date(from).toISOString() : new Date(Date.now() - 30 * 864e5).toISOString();
    const t = to ? new Date(to + "T23:59:59").toISOString() : new Date().toISOString();
    const { data, error } = await supabase.rpc("equipment_oee", { p_equipment: oeeFor, p_from: f, p_to: t });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setOee(data);
  }

  return (
    <div className="space-y-4">
      <div className="card p-4">
        <div className="font-semibold mb-3">Chão de fábrica — status dos equipamentos</div>
        {equipment.length === 0 ? (
          <p className="text-sm muted">Nenhum equipamento cadastrado. Vá na aba <b>Equipamentos</b>.</p>
        ) : (
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
            {equipment.map((e) => (
              <div key={e.id} className="rounded-lg border p-3" style={{ borderColor: "var(--border)" }}>
                <div className="flex items-start gap-2">
                  <div className="flex-1">
                    <div className="font-semibold text-sm">{e.name}</div>
                    <div className="text-xs muted">{e.code ?? ""}{e.equipment_type ? " · " + e.equipment_type : ""}</div>
                  </div>
                  <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${EQUIP_STATUS[e.status]?.cls ?? ""}`}>{EQUIP_STATUS[e.status]?.label ?? e.status}</span>
                </div>
                <select value={e.status} onChange={(ev) => setStatus(e.id, ev.target.value)}
                  className="w-full mt-2 border rounded-lg px-2 py-1 text-xs bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                  {Object.entries(EQUIP_STATUS).map(([v, o]) => <option key={v} value={v}>{o.label}</option>)}
                </select>
              </div>
            ))}
          </div>
        )}
      </div>

      <div className="card p-4 space-y-3">
        <div className="font-semibold">OEE por equipamento</div>
        <p className="text-xs muted">Disponibilidade × Performance × Qualidade, calculado a partir dos apontamentos e paradas do período.</p>
        <div className="grid md:grid-cols-4 gap-3 items-end">
          <div><label className="text-xs font-semibold muted">Equipamento</label>
            <select value={oeeFor} onChange={(e) => setOeeFor(e.target.value)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="">—</option>{equipment.map((e) => <option key={e.id} value={e.id}>{e.name}</option>)}
            </select></div>
          <div><label className="text-xs font-semibold muted">De</label>
            <input type="date" value={from} onChange={(e) => setFrom(e.target.value)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          <div><label className="text-xs font-semibold muted">Até</label>
            <input type="date" value={to} onChange={(e) => setTo(e.target.value)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          <button onClick={calcOee} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Calculando…" : "Calcular OEE"}</button>
        </div>
        {err && <div className="text-sm text-red-500">{err}</div>}
        {oee && (
          <div className="grid md:grid-cols-4 gap-4 pt-2">
            <div className="rounded-lg border p-3 ring-1 ring-brand-500/40" style={{ borderColor: "var(--border)" }}>
              <div className="text-xs muted">OEE global</div>
              <div className="text-2xl font-bold tabular-nums">{pct(oee.oee)}</div>
              <div className="text-xs muted mt-1">{oee.run_minutes}min produtivos · {oee.down_minutes}min parado</div>
            </div>
            <div className="md:col-span-3 space-y-2 self-center">
              <Bar label="Disponibilidade" value={oee.availability} />
              <Bar label="Performance" value={oee.performance} />
              <Bar label="Qualidade" value={oee.quality} />
              <div className="text-xs muted">Produzido {oee.produced} · refugo {oee.scrap} · retrabalho {oee.rework}</div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
