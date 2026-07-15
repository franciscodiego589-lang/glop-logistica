"use client";
import { useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Portaria", "Docas", "Balança", "Carga/Descarga", "Containers", "Lacres", "Performance"] as const;

export default function YMSWorkbench({ dash, gates, appointments, weighings, loadings, containers, seals, performance }:
  { dash: any; gates: any[]; appointments: any[]; weighings: any[]; loadings: any[]; containers: any[]; seals: any[]; performance: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState(false);
  const [rec, setRec] = useState<any>(null);
  const [dir, setDir] = useState("inbound");
  const occ = dash?.docks_total > 0 ? Math.round((dash.docks_occupied / dash.docks_total) * 100) : 0;

  async function recommendDock() {
    if (!supabase) return;
    setBusy(true);
    const { data } = await supabase.rpc("recommend_dock", { p_company: COMPANY, p_direction: dir });
    setRec(data); setBusy(false);
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🏗</div>
        <div>
          <h1 className="text-xl font-bold">YMS Enterprise — Pátio & Portaria</h1>
          <p className="text-sm muted">Gate/OCR · docas · filas · balanças · containers · lacres · performance</p>
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
          <KpiCard label="Veículos no pátio" value={dash?.in_yard ?? "—"} accent />
          <KpiCard label="Na portaria" value={dash?.at_gate ?? "—"} />
          <div className="card p-4">
            <div className="text-xs uppercase tracking-wide muted font-semibold">Ocupação docas</div>
            <div className="mt-2 text-2xl font-bold">{occ}%</div>
            <div className="h-2 rounded-full bg-black/10 dark:bg-white/10 overflow-hidden mt-2"><div className={`h-full ${occ > 85 ? "bg-red-500" : "bg-green-500"}`} style={{ width: `${occ}%` }} /></div>
          </div>
          <KpiCard label="Docas livres" value={dash?.docks_available ?? "—"} />
          <KpiCard label="Agendamentos hoje" value={dash?.appointments_today ?? "—"} />
          <KpiCard label="Carregamentos hoje" value={dash?.loadings_today ?? "—"} />
          <KpiCard label="Tempo médio pátio" value={dash?.avg_dwell_hours != null ? `${dash.avg_dwell_hours}h` : "—"} />
          <KpiCard label="Lacres violados" value={dash?.violated_seals ?? "—"} />
        </div>
      )}

      {tab === "Portaria" && (
        <CrudPanel table="gate_events" title="Portaria (check-in/out)" rows={gates}
          emptyHint="Registre entradas/saídas: motorista, placa, transportadora, documento (OCR nos campos)."
          fields={[
            { key: "direction", label: "Direção", type: "select", options: [["in", "Entrada"], ["out", "Saída"]], default: "in" },
            { key: "vehicle_plate", label: "Placa", required: true }, { key: "driver_name", label: "Motorista" }, { key: "driver_document", label: "Documento" },
            { key: "carrier_id", label: "Transportadora", type: "fk", fkTable: "carriers" }, { key: "container_number", label: "Container" }, { key: "gate", label: "Portaria" },
          ]}
          columns={[{ key: "direction", label: "Dir" }, { key: "vehicle_plate", label: "Placa" }, { key: "driver_name", label: "Motorista" }, { key: "container_number", label: "Container" }]} />
      )}

      {tab === "Docas" && (
        <div className="space-y-3">
          <div className="card p-4 flex flex-wrap gap-3 items-end">
            <div className="font-semibold">🤖 AI Dock Scheduler</div>
            <select value={dir} onChange={(e) => setDir(e.target.value)} className="border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="inbound">Recebimento</option><option value="outbound">Expedição</option></select>
            <button onClick={recommendDock} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold">{busy ? "…" : "Recomendar doca"}</button>
            {rec && <span className="text-sm">{rec.dock_id ? <>Melhor doca: <b>{rec.code ?? rec.name}</b> (fila {rec.queue})</> : rec.message}</span>}
          </div>
          <CrudPanel table="dock_appointments" title="Agendamento de docas" rows={appointments}
            emptyHint="Agende janelas de doca (sem sobreposição garantida no banco)."
            fields={[
              { key: "dock_id", label: "Doca", type: "fk", fkTable: "docks", fkLabel: "code", required: true },
              { key: "direction", label: "Direção", type: "select", options: [["inbound", "Recebimento"], ["outbound", "Expedição"], ["both", "Ambos"]], default: "inbound" },
              { key: "vehicle_plate", label: "Placa" }, { key: "driver_name", label: "Motorista" },
              { key: "scheduled_start", label: "Início", type: "text", placeholder: "2026-07-15 09:00", required: true },
              { key: "scheduled_end", label: "Fim", type: "text", placeholder: "2026-07-15 10:00", required: true },
            ]}
            columns={[{ key: "dock_id", label: "Doca" }, { key: "vehicle_plate", label: "Placa" }, { key: "scheduled_start", label: "Início" }, { key: "status", label: "Status" }]} />
        </div>
      )}

      {tab === "Balança" && (
        <CrudPanel table="weighings" title="Pesagens (balança)" rows={weighings}
          emptyHint="Registre peso bruto e tara; o líquido é calculado automaticamente."
          fields={[
            { key: "vehicle_plate", label: "Placa" }, { key: "gross_kg", label: "Bruto (kg)", type: "number" }, { key: "tare_kg", label: "Tara (kg)", type: "number" },
          ]}
          columns={[{ key: "vehicle_plate", label: "Placa" }, { key: "gross_kg", label: "Bruto" }, { key: "tare_kg", label: "Tara" }, { key: "net_kg", label: "Líquido" }]} />
      )}

      {tab === "Carga/Descarga" && (
        <CrudPanel table="loading_operations" title="Carregamento / descarga" rows={loadings}
          emptyHint="Registre operações de carga/descarga por doca (equipe, volumes, lacre, checklist)."
          fields={[
            { key: "dock_id", label: "Doca", type: "fk", fkTable: "docks", fkLabel: "code" },
            { key: "operation_type", label: "Tipo", type: "select", options: [["load", "Carregamento"], ["unload", "Descarga"]], default: "load" },
            { key: "team", label: "Equipe" }, { key: "volumes", label: "Volumes", type: "number" }, { key: "weight_kg", label: "Peso (kg)", type: "number" }, { key: "seal_number", label: "Lacre" },
          ]}
          columns={[{ key: "operation_type", label: "Tipo" }, { key: "dock_id", label: "Doca" }, { key: "volumes", label: "Volumes" }, { key: "status", label: "Status" }]} />
      )}

      {tab === "Containers" && (
        <CrudPanel table="containers" title="Containers" rows={containers}
          emptyHint="Cadastre containers (nº, ISO, peso, lacre, temperatura, status)."
          fields={[
            { key: "number", label: "Número", required: true }, { key: "iso_type", label: "ISO" },
            { key: "container_type", label: "Tipo", type: "select", options: [["dry", "Dry"], ["reefer", "Reefer"], ["tank", "Tanque"], ["open_top", "Open Top"], ["flat_rack", "Flat Rack"]], default: "dry" },
            { key: "weight_kg", label: "Peso (kg)", type: "number" }, { key: "seal_number", label: "Lacre" },
            { key: "status", label: "Status", type: "select", options: [["in_yard", "No pátio"], ["loaded", "Carregado"], ["dispatched", "Despachado"]], default: "in_yard" },
          ]}
          columns={[{ key: "number", label: "Número" }, { key: "container_type", label: "Tipo" }, { key: "seal_number", label: "Lacre" }, { key: "status", label: "Status" }]} />
      )}

      {tab === "Lacres" && (
        <CrudPanel table="seals" title="Lacres" rows={seals}
          emptyHint="Controle de lacres (número, tipo, status, violação)."
          fields={[
            { key: "number", label: "Número", required: true }, { key: "seal_type", label: "Tipo" },
            { key: "status", label: "Status", type: "select", options: [["intact", "Íntegro"], ["applied", "Aplicado"], ["violated", "Violado"], ["removed", "Removido"]], default: "intact" },
            { key: "applied_to", label: "Aplicado em" },
          ]}
          columns={[{ key: "number", label: "Número" }, { key: "seal_type", label: "Tipo" }, { key: "status", label: "Status" }, { key: "applied_to", label: "Aplicado em" }]} />
      )}

      {tab === "Performance" && (
        performance.length === 0 ? <p className="text-sm muted px-1">Sem visitas concluídas para medir permanência.</p> : (
          <div className="card p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Transportadora</th><th className="px-3 text-right">Visitas</th><th className="px-3 text-right">Permanência média (h)</th></tr></thead>
              <tbody>{performance.map((p, i) => (
                <tr key={i} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">{p.carrier}</td><td className="px-3 text-right">{p.visits}</td>
                  <td className="px-3 text-right"><span className={`font-semibold ${p.avg_dwell_hours > 4 ? "text-red-500" : "text-green-500"}`}>{p.avg_dwell_hours ?? "—"}</span></td>
                </tr>))}</tbody>
            </table>
          </div>
        )
      )}
    </div>
  );
}
