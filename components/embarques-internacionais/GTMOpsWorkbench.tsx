"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Embarques", "Bookings", "Agentes", "Incoterms"] as const;
const EVENT_TYPES: [string, string][] = [["booking", "Reserva"], ["booking_confirmed", "Booking confirmado"], ["empty_container", "Container vazio"], ["loaded", "Carregado"], ["factory_out", "Saída da fábrica"], ["departure", "Embarque/Saída"], ["port_arrival", "Chegada ao porto"], ["loading", "Carregamento"], ["transshipment", "Transbordo"], ["discharge", "Desembarque"], ["released", "Liberado"], ["final_delivery", "Entrega final"], ["delay", "Atraso"], ["rolled", "Rolagem"], ["route_change", "Mudança de rota"]];
const stColor = (s: string) => ({ planned: "#64748b", booked: "#6366f1", in_transit: "#2563eb", at_port: "#d97706", discharged: "#0891b2", released: "#16a34a", delivered: "#15803d", canceled: "#dc2626" } as any)[s] ?? "#64748b";
const stLabel = (s: string) => ({ planned: "Planejado", booked: "Reservado", in_transit: "Em trânsito", at_port: "No porto", discharged: "Desembarcado", released: "Liberado", delivered: "Entregue", canceled: "Cancelado" } as any)[s] ?? s;
const modalIcon = (m: string) => ({ ocean: "🚢", air: "✈️", rail: "🚂", road: "🚚", inland_water: "⛴", multimodal: "🔀", intermodal: "🔗" } as any)[m] ?? "📦";

export default function GTMOpsWorkbench({ dash, shipments, bookings, agents, incoterms, events, routes }: {
  dash: any; shipments: any[]; bookings: any[]; agents: any[]; incoterms: any[]; events: any[]; routes: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState("");
  const [evType, setEvType] = useState<Record<string, string>>({});
  const [open, setOpen] = useState("");
  const d = dash ?? {};
  const evByShip = useMemo(() => { const m: Record<string, any[]> = {}; for (const e of events) (m[e.intl_shipment_id] ??= []).push(e); return m; }, [events]);

  async function addEvent(ship: string) {
    if (!supabase) return; const et = evType[ship] || "departure"; setBusy(ship);
    const { error } = await supabase.rpc("add_trade_event", { p_company: COMPANY, p_shipment: ship, p_event_type: et, p_location: null, p_at: null, p_planned: null });
    setBusy(""); if (error) alert("Erro: " + error.message); else router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🌍</div>
        <div>
          <h1 className="text-xl font-bold">Embarques Internacionais — GTM</h1>
          <p className="text-sm muted">Comércio exterior operacional: embarques multimodais · bookings · agentes · incoterms · timeline</p>
        </div>
      </div>

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <KpiCard label="Embarques" value={d.shipments ?? 0} accent />
          <KpiCard label="Importações" value={d.imports ?? 0} />
          <KpiCard label="Exportações" value={d.exports ?? 0} />
          <KpiCard label="Em trânsito" value={d.in_transit ?? 0} />
          <KpiCard label="No porto" value={d.at_port ?? 0} />
          <KpiCard label="Atrasados" value={d.delayed ?? 0} tone={d.delayed ? "warning" : undefined} />
          <KpiCard label="Bookings abertos" value={d.bookings_open ?? 0} />
          <KpiCard label="Trânsito médio (dias)" value={d.avg_transit_days ?? "—"} />
          <KpiCard label="Agentes" value={d.agents ?? 0} />
          <KpiCard label="Containers" value={d.containers ?? 0} />
        </div>
      )}

      {tab === "Embarques" && (
        <div className="space-y-3">
          {shipments.length === 0 ? <p className="text-sm muted px-1">Nenhum embarque internacional.</p> : shipments.map((s) => {
            const ev = (evByShip[s.id] ?? []).slice().sort((a: any, b: any) => String(a.event_at).localeCompare(String(b.event_at)));
            return (
              <div key={s.id} className="card p-4" style={{ borderLeft: `3px solid ${stColor(s.status)}` }}>
                <div className="flex flex-wrap items-center gap-2">
                  <span className="text-lg">{modalIcon(s.modal)}</span>
                  <span className="font-semibold text-sm">{s.code}</span>
                  <span className="badge" style={{ background: stColor(s.status), color: "#fff" }}>{stLabel(s.status)}</span>
                  <span className="text-xs muted">{s.direction} · {s.incoterm ?? ""} · {s.origin_location ?? s.origin_country} → {s.dest_location ?? s.dest_country}</span>
                  <span className="text-xs muted ml-auto">{s.vessel_voyage ?? ""} {s.transit_days != null ? `· ${s.transit_days}d trânsito` : ""}</span>
                </div>
                {ev.length > 0 && (
                  <ol className="flex flex-wrap gap-2 mt-3">
                    {ev.map((e: any) => (
                      <li key={e.id} className="flex items-center gap-1 text-xs rounded-lg px-2 py-1 card">
                        <span className="h-2 w-2 rounded-full" style={{ background: e.is_actual ? "var(--success)" : "var(--muted)" }} />
                        {EVENT_TYPES.find(([k]) => k === e.event_type)?.[1] ?? e.event_type}
                        <span className="muted">{String(e.event_at ?? "").slice(5, 10)}</span>
                      </li>
                    ))}
                  </ol>
                )}
                <div className="flex items-end gap-2 mt-3">
                  <select value={evType[s.id] ?? "departure"} onChange={(e) => setEvType({ ...evType, [s.id]: e.target.value })} className="input w-auto text-xs">
                    {EVENT_TYPES.map(([k, l]) => <option key={k} value={k}>{l}</option>)}
                  </select>
                  <button onClick={() => addEvent(s.id)} disabled={busy === s.id} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">+ registrar evento</button>
                </div>
              </div>
            );
          })}
          <CrudPanel table="intl_shipments" title="Novo embarque internacional" rows={[]}
            emptyHint="Cadastre embarques de importação/exportação multimodais."
            fields={[
              { key: "code", label: "Código", required: true },
              { key: "direction", label: "Operação", type: "select", options: [["import", "Importação"], ["export", "Exportação"], ["cross_trade", "Cross trade"], ["transshipment", "Transbordo"], ["cabotage", "Cabotagem"]], default: "import" },
              { key: "modal", label: "Modal", type: "select", options: [["ocean", "Marítimo"], ["air", "Aéreo"], ["rail", "Ferroviário"], ["road", "Rodoviário"], ["inland_water", "Fluvial"], ["multimodal", "Multimodal"], ["intermodal", "Intermodal"]], default: "ocean" },
              { key: "incoterm", label: "Incoterm" }, { key: "origin_location", label: "Origem" }, { key: "dest_location", label: "Destino" },
              { key: "vessel_voyage", label: "Navio/Voo/Viagem" },
              { key: "agent_id", label: "Agente", type: "fk", fkTable: "shipping_agents", fkLabel: "code" },
            ]}
            columns={[]} />
        </div>
      )}

      {tab === "Bookings" && (
        <CrudPanel table="trade_bookings" title="Bookings" rows={bookings}
          emptyHint="Reservas de praça com armador/cia aérea; cutoff e status."
          fields={[
            { key: "intl_shipment_id", label: "Embarque", type: "fk", fkTable: "intl_shipments", fkLabel: "code", required: true },
            { key: "agent_id", label: "Agente", type: "fk", fkTable: "shipping_agents", fkLabel: "code" },
            { key: "booking_number", label: "Nº Booking" }, { key: "carrier", label: "Armador/Cia" }, { key: "vessel_voyage", label: "Navio/Voo" },
            { key: "containers_count", label: "Containers", type: "number" },
            { key: "status", label: "Status", type: "select", options: [["requested", "Solicitado"], ["confirmed", "Confirmado"], ["rolled", "Rolado"], ["canceled", "Cancelado"]], default: "requested" },
          ]}
          columns={[{ key: "booking_number", label: "Booking" }, { key: "carrier", label: "Armador" }, { key: "containers_count", label: "Cntrs" }, { key: "status", label: "Status" }]} />
      )}

      {tab === "Agentes" && (
        <CrudPanel table="shipping_agents" title="Agentes logísticos internacionais" rows={agents}
          emptyHint="Freight forwarders, NVOCC, armadores, cias aéreas, despachantes, consolidadores."
          fields={[
            { key: "code", label: "Código", required: true }, { key: "name", label: "Nome" },
            { key: "agent_type", label: "Tipo", type: "select", options: [["freight_forwarder", "Freight Forwarder"], ["nvocc", "NVOCC"], ["carrier_ocean", "Armador"], ["airline", "Cia Aérea"], ["rail_operator", "Op. Ferroviário"], ["customs_broker", "Despachante"], ["cargo_agent", "Agente de Carga"], ["consolidator", "Consolidador"], ["deconsolidator", "Desconsolidador"]], default: "freight_forwarder" },
            { key: "modal", label: "Modal" }, { key: "scac_code", label: "SCAC" }, { key: "country", label: "País" }, { key: "contact", label: "Contato" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "name", label: "Nome" }, { key: "agent_type", label: "Tipo" }, { key: "country", label: "País" }]} />
      )}

      {tab === "Incoterms" && (
        incoterms.length === 0 ? <p className="text-sm muted px-1">Sem incoterms.</p> : (
          <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Código</th><th className="px-3">Nome</th><th className="px-3">Ponto de transferência</th><th className="px-3">Edição</th></tr></thead>
            <tbody>{incoterms.map((i) => (
              <tr key={i.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                <td className="py-2 px-3 font-bold">{i.code}</td><td className="px-3">{i.name}</td><td className="px-3 text-xs muted">{i.transfer_point ?? "—"}</td><td className="px-3 text-xs">{i.edition}</td>
              </tr>))}</tbody>
          </table></div>
        )
      )}
    </div>
  );
}
