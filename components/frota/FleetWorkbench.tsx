"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (n: any) => (n == null ? "—" : Number(n).toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 }));
const TABS = ["Painel", "Viagens", "Manutenção", "Combustível", "Cotações", "Lances", "Contratos"] as const;

export default function FleetWorkbench({ dash, trips, maintenance, fuel, quotes, bids, contracts }:
  { dash: any; trips: any[]; maintenance: any[]; fuel: any[]; quotes: any[]; bids: any[]; contracts: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const [carbon, setCarbon] = useState<any>(null);

  async function carbonFp() {
    if (!supabase) return;
    setBusy("carbon");
    const { data } = await supabase.rpc("compute_carbon_footprint", { p_company: COMPANY, p_days: 30 });
    setCarbon(data); setBusy(null);
  }
  async function recalcTrips() {
    if (!supabase) return;
    setBusy("recalc"); setMsg(null);
    for (const t of trips.slice(0, 100)) await supabase.rpc("trip_cost", { p_trip: t.id });
    setBusy(null); setMsg("Custos das viagens recalculados ✓"); router.refresh();
  }
  async function ia() {
    if (!supabase) return;
    setBusy("ia"); setMsg(null);
    const { data, error } = await supabase.rpc("tms_insights", { p_company: COMPANY });
    setBusy(null); setMsg(error ? error.message : `${data ?? 0} alerta(s) de frota/contratos na LOGIA.`); router.refresh();
  }
  async function award(reqId: string, bidId: string) {
    if (!supabase) return;
    setBusy(bidId);
    await supabase.rpc("award_freight_quote", { p_request: reqId, p_bid: bidId });
    setBusy(null); setMsg("Lance vencedor definido ✓"); router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🚛</div>
        <div>
          <h1 className="text-xl font-bold">TMS Enterprise — Frota, Viagens & Fretes</h1>
          <p className="text-sm muted">Viagens · custos · combustível · manutenção · leilão de fretes · carbono</p>
        </div>
        <div className="ml-auto flex gap-2">
          <button onClick={ia} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>IA frota</button>
          <button onClick={recalcTrips} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{busy === "recalc" ? "…" : "Recalcular custos"}</button>
        </div>
      </div>
      {msg && <div className="text-sm text-brand-500 px-1">{msg}</div>}

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="space-y-3">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="Viagens ativas" value={dash?.trips_active ?? "—"} accent />
            <KpiCard label="Planejadas" value={dash?.trips_planned ?? "—"} />
            <KpiCard label="Custo viagens (mês)" value={money(dash?.trip_cost_month)} />
            <KpiCard label="Combustível (mês)" value={money(dash?.fuel_cost_month)} />
            <KpiCard label="Custo médio/km" value={dash?.avg_cost_per_km != null ? money(dash.avg_cost_per_km) : "—"} />
            <KpiCard label="Manutenção vencendo" value={dash?.maintenance_due ?? "—"} />
            <KpiCard label="Contratos a renovar" value={dash?.contracts_expiring ?? "—"} />
            <KpiCard label="Cotações abertas" value={dash?.open_quotes ?? "—"} />
          </div>
          <div className="card p-4 flex items-center gap-3">
            <div className="font-semibold">🌱 Pegada de carbono (30 dias)</div>
            {carbon ? <span className="text-sm">{carbon.total_km} km · <b>{carbon.total_co2_kg} kg CO₂</b></span> : <span className="text-sm muted">clique para calcular</span>}
            <button onClick={carbonFp} disabled={!!busy} className="ml-auto text-sm px-3 py-2 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>{busy === "carbon" ? "…" : "Calcular CO₂"}</button>
          </div>
        </div>
      )}

      {tab === "Viagens" && (
        <CrudPanel table="trips" title="Viagens" rows={trips}
          emptyHint="Cadastre viagens (frota própria ou terceirizada), com origem/destino, distância e modal."
          fields={[
            { key: "code", label: "Código" },
            { key: "modal", label: "Modal", type: "select", options: [["road", "Rodoviário"], ["air", "Aéreo"], ["sea", "Marítimo"], ["rail", "Ferroviário"], ["courier", "Courier"]], default: "road" },
            { key: "carrier_id", label: "Transportadora", type: "fk", fkTable: "carriers" },
            { key: "vehicle_id", label: "Veículo", type: "fk", fkTable: "vehicles", fkLabel: "plate" },
            { key: "driver_id", label: "Motorista", type: "fk", fkTable: "drivers" },
            { key: "origin", label: "Origem" }, { key: "destination", label: "Destino" },
            { key: "distance_km", label: "Distância (km)", type: "number" },
            { key: "status", label: "Status", type: "select", options: [["planned", "Planejada"], ["in_progress", "Em andamento"], ["completed", "Concluída"]], default: "planned" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "modal", label: "Modal" }, { key: "destination", label: "Destino" }, { key: "distance_km", label: "km" }, { key: "total_cost", label: "Custo", fmt: (v) => money(v) }, { key: "cost_per_km", label: "R$/km", fmt: (v) => money(v) }, { key: "status", label: "Status" }]} />
      )}

      {tab === "Manutenção" && (
        <CrudPanel table="fleet_maintenance" title="Manutenção da frota" rows={maintenance}
          emptyHint="Preventiva/corretiva, troca de óleo, pneus — com próxima data para alertar."
          fields={[
            { key: "vehicle_id", label: "Veículo", type: "fk", fkTable: "vehicles", fkLabel: "plate", required: true },
            { key: "maintenance_type", label: "Tipo", type: "select", options: [["preventive", "Preventiva"], ["corrective", "Corretiva"], ["inspection", "Inspeção"], ["tire", "Pneus"], ["oil", "Óleo"]], default: "preventive" },
            { key: "description", label: "Descrição" }, { key: "cost", label: "Custo", type: "number" },
            { key: "service_date", label: "Data", type: "date" }, { key: "next_date", label: "Próxima", type: "date" },
          ]}
          columns={[{ key: "maintenance_type", label: "Tipo" }, { key: "description", label: "Descrição" }, { key: "cost", label: "Custo", fmt: (v) => money(v) }, { key: "next_date", label: "Próxima" }]} />
      )}

      {tab === "Combustível" && (
        <CrudPanel table="fuel_logs" title="Abastecimentos" rows={fuel}
          emptyHint="Registre abastecimentos (litros, custo, odômetro) por veículo/viagem."
          fields={[
            { key: "vehicle_id", label: "Veículo", type: "fk", fkTable: "vehicles", fkLabel: "plate" },
            { key: "liters", label: "Litros", type: "number" }, { key: "cost", label: "Custo (R$)", type: "number" },
            { key: "odometer", label: "Odômetro", type: "number" }, { key: "filled_at", label: "Data", type: "date" },
          ]}
          columns={[{ key: "liters", label: "Litros" }, { key: "cost", label: "Custo", fmt: (v) => money(v) }, { key: "odometer", label: "Odômetro" }, { key: "filled_at", label: "Data" }]} />
      )}

      {tab === "Cotações" && (
        <CrudPanel table="freight_quote_requests" title="Cotações de frete (procurement)" rows={quotes}
          emptyHint="Abra uma cotação; as transportadoras enviam lances (aba Lances) e você adjudica o vencedor."
          fields={[
            { key: "code", label: "Código" }, { key: "origin_uf", label: "UF origem" }, { key: "dest_uf", label: "UF destino" },
            { key: "weight_g", label: "Peso (g)", type: "number" }, { key: "deadline", label: "Prazo", type: "date" },
            { key: "status", label: "Status", type: "select", options: [["open", "Aberta"], ["quoted", "Cotada"], ["awarded", "Adjudicada"]], default: "open" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "dest_uf", label: "Destino" }, { key: "weight_g", label: "Peso" }, { key: "status", label: "Status" }]} />
      )}

      {tab === "Lances" && (
        <div className="space-y-2">
          <CrudPanel table="freight_quote_bids" title="Lances das transportadoras" rows={bids}
            emptyHint="Registre lances (preço + prazo) por cotação. Depois adjudique o vencedor abaixo."
            fields={[
              { key: "request_id", label: "Cotação", type: "fk", fkTable: "freight_quote_requests", fkLabel: "code", required: true },
              { key: "carrier_id", label: "Transportadora", type: "fk", fkTable: "carriers" },
              { key: "price", label: "Preço (R$)", type: "number" }, { key: "sla_days", label: "Prazo (dias)", type: "number" },
            ]}
            columns={[{ key: "request_id", label: "Cotação" }, { key: "carrier_id", label: "Transportadora" }, { key: "price", label: "Preço", fmt: (v) => money(v) }, { key: "sla_days", label: "Prazo" }, { key: "is_winner", label: "Vencedor", fmt: (v) => (v ? "🏆" : "") }]} />
          {bids.filter((b) => !b.is_winner).length > 0 && (
            <div className="card p-4">
              <div className="font-semibold mb-2">Adjudicar vencedor</div>
              <div className="space-y-1">
                {bids.filter((b) => !b.is_winner).map((b) => (
                  <div key={b.id} className="flex items-center gap-2 text-sm border rounded-lg px-3 py-2" style={{ borderColor: "var(--border)" }}>
                    <span>{money(b.price)} · {b.sla_days ?? "—"}d</span>
                    <button onClick={() => award(b.request_id, b.id)} disabled={busy === b.id} className="ml-auto text-xs px-3 py-1.5 rounded-lg bg-brand-600 hover:bg-brand-700 text-white font-semibold">🏆 Escolher</button>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {tab === "Contratos" && (
        <CrudPanel table="freight_contracts" title="Contratos de transporte" rows={contracts}
          emptyHint="Contratos com transportadoras: vigência, SLA, multas, reajuste — com alerta de renovação."
          fields={[
            { key: "code", label: "Código" }, { key: "carrier_id", label: "Transportadora", type: "fk", fkTable: "carriers" },
            { key: "valid_from", label: "Início", type: "date" }, { key: "valid_to", label: "Fim", type: "date" },
            { key: "sla_days", label: "SLA (dias)", type: "number" }, { key: "penalty_percent", label: "Multa %", type: "number" },
            { key: "adjustment_index", label: "Índice reajuste" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "valid_to", label: "Vence" }, { key: "sla_days", label: "SLA" }, { key: "penalty_percent", label: "Multa%" }]} />
      )}
    </div>
  );
}
