"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { SHIP_STATUS } from "./ShipmentsPanel";

const money = (n: number | null) => n == null ? "—" : n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
const dt = (s: string | null) => s ? new Date(s).toLocaleString("pt-BR") : "—";

// próximo status no fluxo + o evento de rastreio que ele dispara
const FLOW: Record<string, { next: string; label: string; event: string }[]> = {
  draft: [{ next: "planned", label: "Planejar", event: "created" }, { next: "canceled", label: "Cancelar", event: "exception" }],
  planned: [{ next: "dispatched", label: "Despachar", event: "picked_up" }, { next: "canceled", label: "Cancelar", event: "exception" }],
  dispatched: [{ next: "in_transit", label: "Em trânsito", event: "in_transit" }],
  in_transit: [{ next: "delivered", label: "Entregar", event: "delivered" }, { next: "returned", label: "Devolver", event: "returned" }],
  delivered: [],
  returned: [],
  canceled: [],
};

const EVENTS: [string, string][] = [
  ["created", "Criado"], ["picked_up", "Coletado"], ["in_transit", "Em trânsito"],
  ["out_for_delivery", "Saiu para entrega"], ["delivered", "Entregue"],
  ["delivery_failed", "Falha na entrega"], ["returned", "Devolvido"], ["exception", "Ocorrência"],
];
const eventLabel = (t: string) => EVENTS.find(([v]) => v === t)?.[1] ?? t;
const eventIcon = (t: string) => ({
  created: "📝", picked_up: "📦", in_transit: "🚚", out_for_delivery: "🛵",
  delivered: "✅", delivery_failed: "⚠️", returned: "↩️", exception: "🚨",
} as Record<string, string>)[t] ?? "•";

type Ev = { id: string; event_type: string; description: string | null; location_text: string | null; occurred_at: string; is_exception: boolean };

export default function ShipmentDetail({
  shipment, events, carriers, vehicles, drivers,
}: { shipment: any; events: Ev[]; carriers: any[]; vehicles: any[]; drivers: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  const [assign, setAssign] = useState({
    carrier_id: shipment.carrier_id ?? "", vehicle_id: shipment.vehicle_id ?? "", driver_id: shipment.driver_id ?? "",
  });
  const [ev, setEv] = useState({ event_type: "in_transit", description: "", location_text: "", is_exception: false });

  const st = shipment.status as string;
  const code = shipment.code ?? shipment.tracking_code ?? shipment.id.slice(0, 8);

  async function tenant(): Promise<string | null> {
    if (!supabase) return null;
    const { data } = await supabase.from("companies").select("tenant_id").eq("id", shipment.company_id).single();
    return (data as any)?.tenant_id ?? null;
  }

  async function logEvent(event_type: string, description: string, location = "", exception = false) {
    if (!supabase) return;
    const tenant_id = await tenant();
    await supabase.from("shipment_events").insert({
      tenant_id, company_id: shipment.company_id, shipment_id: shipment.id,
      event_type, description: description || null, location_text: location || null, is_exception: exception,
    });
  }

  async function advance(next: string, event: string, label: string) {
    if (!supabase) return;
    setBusy(true); setMsg(null);
    const patch: Record<string, any> = { status: next };
    if (next === "dispatched") patch.dispatched_at = new Date().toISOString();
    if (next === "delivered") patch.delivered_at = new Date().toISOString();
    const { error } = await supabase.from("shipments").update(patch).eq("id", shipment.id);
    if (!error) await logEvent(event, `Status: ${label}`, "", next === "canceled" || next === "returned");
    setBusy(false);
    if (error) { setMsg(error.message); return; }
    router.refresh();
  }

  async function saveAssign() {
    if (!supabase) return;
    setBusy(true); setMsg(null);
    const { error } = await supabase.from("shipments").update({
      carrier_id: assign.carrier_id || null, vehicle_id: assign.vehicle_id || null, driver_id: assign.driver_id || null,
    }).eq("id", shipment.id);
    setBusy(false);
    setMsg(error ? error.message : "Atribuição salva ✓");
    if (!error) router.refresh();
  }

  async function addEvent() {
    if (!supabase) return;
    setBusy(true); setMsg(null);
    await logEvent(ev.event_type, ev.description, ev.location_text, ev.is_exception);
    setBusy(false);
    setEv({ event_type: "in_transit", description: "", location_text: "", is_exception: false });
    router.refresh();
  }

  const vehiclesForCarrier = assign.carrier_id ? vehicles.filter((v) => !v.carrier_id || v.carrier_id === assign.carrier_id) : vehicles;
  const driversForCarrier = assign.carrier_id ? drivers.filter((d) => !d.carrier_id || d.carrier_id === assign.carrier_id) : drivers;

  return (
    <div className="space-y-4 max-w-5xl">
      <div className="flex items-center gap-3 flex-wrap">
        <Link href="/tms" className="muted hover:underline text-sm">← TMS / Transporte</Link>
        <h1 className="text-xl font-bold">Embarque {code}</h1>
        <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${SHIP_STATUS[st]?.cls ?? ""}`}>{SHIP_STATUS[st]?.label ?? st}</span>
        <span className="ml-auto text-sm muted">{[shipment.dest_city, shipment.dest_uf].filter(Boolean).join(" / ") || "sem destino"}</span>
      </div>

      <div className="grid md:grid-cols-3 gap-3">
        <div className="card p-3"><div className="text-xs muted">Valor da carga</div><b className="tabular-nums">{money(shipment.cargo_value)}</b></div>
        <div className="card p-3"><div className="text-xs muted">Frete</div><b className="tabular-nums">{money(shipment.freight_value)}</b></div>
        <div className="card p-3"><div className="text-xs muted">Previsão / entregue</div><b>{shipment.estimated_delivery ?? "—"}{shipment.delivered_at ? ` · ✅ ${dt(shipment.delivered_at)}` : ""}</b></div>
      </div>

      {/* fluxo de status */}
      {FLOW[st]?.length > 0 && (
        <div className="card p-4">
          <div className="font-semibold mb-2">Avançar status</div>
          <div className="flex gap-2 flex-wrap">
            {FLOW[st].map((a) => (
              <button key={a.next} onClick={() => advance(a.next, a.event, a.label)} disabled={busy}
                className={`px-4 py-2 rounded-lg text-sm font-semibold disabled:opacity-60 ${a.next === "canceled" || a.next === "returned" ? "border border-red-500/40 text-red-500 hover:bg-red-500/10" : "bg-brand-600 text-white hover:bg-brand-700"}`}>
                {a.label}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* atribuição */}
      <div className="card p-4">
        <div className="font-semibold mb-2">Atribuição</div>
        <div className="grid md:grid-cols-3 gap-3">
          <div><label className="text-xs font-semibold muted">Transportadora</label>
            <select value={assign.carrier_id} onChange={(e) => setAssign({ ...assign, carrier_id: e.target.value, vehicle_id: "", driver_id: "" })}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="">—</option>{carriers.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select></div>
          <div><label className="text-xs font-semibold muted">Veículo</label>
            <select value={assign.vehicle_id} onChange={(e) => setAssign({ ...assign, vehicle_id: e.target.value })}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="">—</option>{vehiclesForCarrier.map((v) => <option key={v.id} value={v.id}>{v.plate}</option>)}
            </select></div>
          <div><label className="text-xs font-semibold muted">Motorista</label>
            <select value={assign.driver_id} onChange={(e) => setAssign({ ...assign, driver_id: e.target.value })}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="">—</option>{driversForCarrier.map((d) => <option key={d.id} value={d.id}>{d.name}</option>)}
            </select></div>
        </div>
        <button onClick={saveAssign} disabled={busy} className="mt-3 px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">Salvar atribuição</button>
      </div>

      {/* rastreio */}
      <div className="card p-4">
        <div className="font-semibold mb-3">Rastreio ({events.length})</div>

        <div className="grid md:grid-cols-4 gap-2 items-end mb-4 pb-4 border-b" style={{ borderColor: "var(--border)" }}>
          <div><label className="text-xs font-semibold muted">Evento</label>
            <select value={ev.event_type} onChange={(e) => setEv({ ...ev, event_type: e.target.value })}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              {EVENTS.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
            </select></div>
          <div><label className="text-xs font-semibold muted">Local</label>
            <input value={ev.location_text} onChange={(e) => setEv({ ...ev, location_text: e.target.value })} placeholder="cidade / UF"
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          <div><label className="text-xs font-semibold muted">Descrição</label>
            <input value={ev.description} onChange={(e) => setEv({ ...ev, description: e.target.value })}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          <div className="flex items-center gap-2">
            <label className="flex items-center gap-1.5 text-sm"><input type="checkbox" checked={ev.is_exception} onChange={(e) => setEv({ ...ev, is_exception: e.target.checked })} /> Ocorrência</label>
            <button onClick={addEvent} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">Registrar</button>
          </div>
        </div>

        {events.length === 0 ? (
          <p className="text-sm muted">Nenhum evento ainda. Avance o status ou registre um evento manual.</p>
        ) : (
          <ol className="space-y-3">
            {events.map((e) => (
              <li key={e.id} className="flex gap-3">
                <div className="text-lg leading-none">{eventIcon(e.event_type)}</div>
                <div className="flex-1">
                  <div className="flex items-center gap-2">
                    <span className="font-semibold text-sm">{eventLabel(e.event_type)}</span>
                    {e.is_exception && <span className="text-xs px-1.5 py-0.5 rounded bg-red-500/15 text-red-500 font-semibold">ocorrência</span>}
                    <span className="ml-auto text-xs muted">{dt(e.occurred_at)}</span>
                  </div>
                  {(e.description || e.location_text) && (
                    <div className="text-sm muted">{[e.location_text, e.description].filter(Boolean).join(" · ")}</div>
                  )}
                </div>
              </li>
            ))}
          </ol>
        )}
      </div>

      {msg && <div className="text-sm text-green-500">{msg}</div>}
    </div>
  );
}
