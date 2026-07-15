"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Remessas Frias", "Sensores", "Equipamentos", "Categorias & Faixas", "Alarmes"] as const;
const intColor = (s: string) => ({ intact: "#16a34a", at_risk: "#d97706", broken: "#dc2626" } as any)[s] ?? "#64748b";
const intLabel = (s: string) => ({ intact: "Íntegra", at_risk: "Em risco", broken: "Rompida" } as any)[s] ?? s;

export default function CCLMSWorkbench({ dash, shipments, categories, sensors, equipment, alarms, readings }: {
  dash: any; shipments: any[]; categories: any[]; sensors: any[]; equipment: any[]; alarms: any[]; readings: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState("");
  const [temp, setTemp] = useState<Record<string, string>>({});
  const d = dash ?? {};
  const catName = useMemo(() => Object.fromEntries(categories.map((c) => [c.id, c])), [categories]);

  async function reading(ship: string) {
    if (!supabase || !temp[ship]) return; setBusy(ship);
    const { error, data } = await supabase.rpc("record_environmental_reading", { p_company: COMPANY, p_shipment: ship, p_temp: Number(temp[ship]) });
    setBusy("");
    if (error) { alert("Erro: " + error.message); return; }
    if (data?.breach) alert("⚠️ Leitura FORA da faixa — alarme térmico gerado.");
    setTemp({ ...temp, [ship]: "" }); router.refresh();
  }
  async function resolveAlarm(id: string) {
    if (!supabase) return; setBusy(id);
    await supabase.rpc("resolve_cold_alarm", { p_company: COMPANY, p_alarm: id });
    setBusy(""); router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">❄️</div>
        <div>
          <h1 className="text-xl font-bold">Cadeia Fria — CCLMS</h1>
          <p className="text-sm muted">Monitoramento térmico · sensores IoT · integridade · alarmes · rastreabilidade ambiental</p>
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
          <div className="card p-4">
            <div className="text-xs uppercase tracking-wide muted font-semibold">Integridade da cadeia</div>
            <div className="mt-2 text-2xl font-bold" style={{ color: d.integrity_pct >= 95 ? "var(--success)" : d.integrity_pct != null ? "var(--warning)" : undefined }}>{d.integrity_pct != null ? `${d.integrity_pct}%` : "—"}</div>
          </div>
          <KpiCard label="Remessas frias" value={d.cold_shipments ?? 0} accent />
          <KpiCard label="Em risco" value={d.at_risk ?? 0} tone={d.at_risk ? "warning" : undefined} />
          <KpiCard label="Rompidas" value={d.broken ?? 0} tone={d.broken ? "danger" : undefined} />
          <KpiCard label="Sensores ativos" value={d.sensors_active ?? 0} hint={`${d.sensors_offline ?? 0} offline`} />
          <KpiCard label="Alarmes abertos" value={d.alarms_open ?? 0} tone={d.alarms_open ? "warning" : undefined} />
          <KpiCard label="Equip. disponíveis" value={d.equipment_available ?? 0} />
          <KpiCard label="Calibração p/ vencer" value={d.calibration_due ?? 0} />
        </div>
      )}

      {tab === "Remessas Frias" && (
        <div className="space-y-3">
          <p className="text-sm muted">Registre leituras de temperatura (simula ingestão IoT). Fora da faixa gera alarme e afeta a integridade.</p>
          {shipments.length === 0 ? <p className="text-sm muted px-1">Nenhuma remessa fria.</p> : shipments.map((s) => {
            const cat = catName[s.cold_category_id];
            const rd = readings.filter((r) => r.cold_shipment_id === s.id).slice(0, 12);
            return (
              <div key={s.id} className="card p-4" style={{ borderLeft: `3px solid ${intColor(s.integrity_status)}` }}>
                <div className="flex flex-wrap items-center gap-2">
                  <span className="font-semibold text-sm">{s.code}</span>
                  <span className="badge" style={{ background: intColor(s.integrity_status), color: "#fff" }}>{intLabel(s.integrity_status)}</span>
                  {cat && <span className="text-xs muted">{cat.name} ({cat.min_temp}…{cat.max_temp}°C)</span>}
                  <span className="text-xs muted ml-auto">{s.minutes_out_of_range} min fora · {s.origin} → {s.destination}</span>
                </div>
                {rd.length > 0 && (
                  <div className="flex items-end gap-1 mt-3 h-16">
                    {[...rd].reverse().map((r) => (
                      <div key={r.id} title={`${r.temperature}°C ${r.breach ? "(fora)" : ""}`}
                        className="flex-1 rounded-t" style={{ height: `${Math.min(100, Math.max(8, (Number(r.temperature) + 30) * 1.6))}%`, background: r.breach ? "var(--danger)" : "var(--brand)", minWidth: 6 }} />
                    ))}
                  </div>
                )}
                <div className="flex items-end gap-2 mt-3">
                  <input type="number" step="0.1" placeholder="Temp °C" value={temp[s.id] ?? ""} onChange={(e) => setTemp({ ...temp, [s.id]: e.target.value })} className="input w-28" />
                  <button onClick={() => reading(s.id)} disabled={busy === s.id || !temp[s.id]} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-50">↯ registrar leitura</button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {tab === "Sensores" && (
        <CrudPanel table="cold_sensors" title="Sensores IoT / data loggers" rows={sensors}
          emptyHint="Data loggers, Bluetooth, LoRaWAN, NB-IoT, GSM, RFID, gateways."
          fields={[
            { key: "code", label: "Código", required: true },
            { key: "sensor_type", label: "Tipo", type: "select", options: [["data_logger", "Data Logger"], ["bluetooth", "Bluetooth"], ["lorawan", "LoRaWAN"], ["nbiot", "NB-IoT"], ["gsm", "GSM"], ["rfid_tag", "RFID"], ["gateway", "Gateway"]], default: "data_logger" },
            { key: "device_id", label: "Device ID" },
            { key: "status", label: "Status", type: "select", options: [["active", "Ativo"], ["offline", "Offline"], ["faulty", "Falha"], ["maintenance", "Manutenção"]], default: "active" },
            { key: "next_calibration", label: "Próx. calibração", type: "date" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "sensor_type", label: "Tipo" }, { key: "status", label: "Status" }, { key: "next_calibration", label: "Calibração" }]} />
      )}

      {tab === "Equipamentos" && (
        <CrudPanel table="cold_equipment" title="Equipamentos refrigerados" rows={equipment}
          emptyHint="Baús/contêineres refrigerados, câmaras frias, freezers, unidades de refrigeração, geradores."
          fields={[
            { key: "code", label: "Código", required: true }, { key: "name", label: "Nome" },
            { key: "equip_type", label: "Tipo", type: "select", options: [["reefer_truck", "Baú refrigerado"], ["reefer_container", "Contêiner reefer"], ["cold_room", "Câmara fria"], ["freezer", "Freezer"], ["refrigerator", "Refrigerador"], ["refrig_unit", "Unidade refrig."], ["generator", "Gerador"]], default: "reefer_truck" },
            { key: "temp_setpoint", label: "Setpoint °C", type: "number" },
            { key: "status", label: "Status", type: "select", options: [["available", "Disponível"], ["in_use", "Em uso"], ["maintenance", "Manutenção"], ["faulty", "Falha"]], default: "available" },
            { key: "next_maintenance", label: "Próx. manutenção", type: "date" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "equip_type", label: "Tipo" }, { key: "temp_setpoint", label: "Setpoint" }, { key: "status", label: "Status" }]} />
      )}

      {tab === "Categorias & Faixas" && (
        <CrudPanel table="cold_categories" title="Categorias térmicas & faixas" rows={categories}
          emptyHint="Congelados, resfriados, vacinas, biológicos, alimentos, químicos — com faixa de temperatura."
          fields={[
            { key: "code", label: "Código", required: true }, { key: "name", label: "Nome" },
            { key: "category_kind", label: "Tipo", type: "select", options: [["frozen", "Congelado"], ["chilled", "Resfriado"], ["vaccine", "Vacina"], ["biological", "Biológico"], ["food", "Alimento"], ["chemical", "Químico"], ["cosmetic", "Cosmético"], ["lab", "Laboratorial"], ["other", "Outro"]], default: "chilled" },
            { key: "min_temp", label: "Temp mín °C", type: "number" }, { key: "max_temp", label: "Temp máx °C", type: "number" }, { key: "ideal_temp", label: "Ideal °C", type: "number" },
            { key: "tolerance_c", label: "Tolerância °C", type: "number", default: "0" }, { key: "max_minutes_out", label: "Máx min fora", type: "number", default: "60" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "name", label: "Nome" }, { key: "min_temp", label: "Mín" }, { key: "max_temp", label: "Máx" }, { key: "max_minutes_out", label: "Máx fora(min)" }]} />
      )}

      {tab === "Alarmes" && (
        alarms.length === 0 ? <p className="text-sm muted px-1">Nenhum alarme térmico.</p> : (
          <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Tipo</th><th className="px-3">Severidade</th><th className="px-3 text-right">Valor</th><th className="px-3">Disparado</th><th className="px-3">Status</th><th className="px-3"></th></tr></thead>
            <tbody>{alarms.map((a) => (
              <tr key={a.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                <td className="py-2 px-3 font-medium">{a.alarm_type}</td>
                <td className="px-3"><span className={`badge ${a.severity === "critical" ? "badge-danger" : a.severity === "high" ? "badge-warning" : "badge-neutral"}`}>{a.severity}</span></td>
                <td className="px-3 text-right tabular-nums">{a.value != null ? `${a.value}°C` : "—"}</td>
                <td className="px-3 text-xs">{String(a.triggered_at ?? "").slice(0, 16).replace("T", " ")}</td>
                <td className="px-3"><span className={`badge ${a.status === "resolved" ? "badge-success" : "badge-neutral"}`}>{a.status}</span></td>
                <td className="px-3 text-right">{a.status !== "resolved" && <button onClick={() => resolveAlarm(a.id)} disabled={busy === a.id} className="text-xs text-brand-600 hover:underline">✓ resolver</button>}</td>
              </tr>))}</tbody>
          </table></div>
        )
      )}
    </div>
  );
}
