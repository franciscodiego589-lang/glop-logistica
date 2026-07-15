"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Mapa", "Portaria", "Portarias", "Docas", "Vagas", "Fila", "Movimentações", "Balança", "Carga/Descarga", "Containers", "Lacres", "Credenciais", "Visitantes", "SLA", "Performance"] as const;

export default function YMSWorkbench({ dash, gates, appointments, weighings, loadings, containers, seals, performance,
  map, sla, gateList, slots, queue, movements, credentials, visitors }:
  { dash: any; gates: any[]; appointments: any[]; weighings: any[]; loadings: any[]; containers: any[]; seals: any[]; performance: any[];
    map: any; sla: any; gateList: any[]; slots: any[]; queue: any[]; movements: any[]; credentials: any[]; visitors: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState(false);
  const [rec, setRec] = useState<any>(null);
  const [dir, setDir] = useState("inbound");
  const occ = dash?.docks_total > 0 ? Math.round((dash.docks_occupied / dash.docks_total) * 100) : 0;

  async function callNext() {
    if (!supabase) return; setBusy(true);
    const { data } = await supabase.rpc("yard_call_next", { p_company: COMPANY, p_dock: null });
    setBusy(false);
    alert(data ? "Próximo chamado da fila." : "Fila vazia.");
    router.refresh();
  }
  const slotColor = (s: string) => ({ free: "#16a34a", occupied: "#2563eb", blocked: "#dc2626", reserved: "#d97706" } as any)[s] ?? "#64748b";

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

      {tab === "Mapa" && (
        <div className="space-y-4">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="Veículos no pátio" value={map?.in_yard ?? 0} accent />
            <KpiCard label="Aguardando na fila" value={map?.queue_waiting ?? 0} />
            <KpiCard label="Visitantes na área" value={map?.visitors_inside ?? 0} />
            <KpiCard label="Portarias" value={(map?.gates ?? []).length} />
          </div>
          <div className="card p-4">
            <div className="font-semibold text-sm mb-2">🛂 Portarias</div>
            <div className="flex flex-wrap gap-2">{(map?.gates ?? []).map((g: any) => (
              <span key={g.id} className="badge" style={{ background: g.status === "blocked" ? "#dc2626" : g.status === "closed" ? "#64748b" : "#16a34a", color: "#fff" }}>{g.code} · {g.status}</span>
            ))}</div>
          </div>
          <div className="card p-4">
            <div className="font-semibold text-sm mb-2">🅿️ Pátio — mapa de vagas</div>
            {(map?.zones ?? []).length === 0 ? <p className="text-sm muted">Sem zonas/vagas cadastradas.</p> : (map?.zones ?? []).map((z: any) => (
              <div key={z.id} className="mb-3">
                <div className="text-xs muted mb-1">{z.name ?? z.code} · {(z.slots ?? []).length} vagas · capacidade {z.capacity ?? "—"}</div>
                <div className="flex flex-wrap gap-1.5">{(z.slots ?? []).map((s: any) => (
                  <div key={s.id} title={`${s.code} · ${s.status}${s.plate ? " · " + s.plate : ""}`} className="grid place-items-center rounded text-[10px] text-white font-semibold"
                    style={{ background: slotColor(s.status), width: 46, height: 34 }}>{s.code}</div>
                ))}</div>
              </div>
            ))}
            <div className="flex gap-3 mt-2 text-[11px] muted">
              {[["free", "livre"], ["occupied", "ocupada"], ["reserved", "reservada"], ["blocked", "bloqueada"]].map(([k, l]) => (
                <span key={k} className="flex items-center gap-1"><span style={{ background: slotColor(k), width: 12, height: 12, borderRadius: 3, display: "inline-block" }} />{l}</span>
              ))}
            </div>
          </div>
          <div className="card p-4">
            <div className="font-semibold text-sm mb-2">🚪 Docas</div>
            <div className="flex flex-wrap gap-2">{(map?.docks ?? []).map((d: any) => (
              <span key={d.id} className="badge" style={{ background: d.status === "occupied" ? "#2563eb" : d.status === "blocked" ? "#dc2626" : "#16a34a", color: "#fff" }}>{d.code} · {d.status}</span>
            ))}</div>
          </div>
        </div>
      )}

      {tab === "Portarias" && (
        <CrudPanel table="gates" title="Portarias" rows={gateList}
          emptyHint="Cadastre as portarias (principal, entrada, saída, visitantes, prestadores, emergência)."
          fields={[
            { key: "code", label: "Código", required: true }, { key: "name", label: "Nome" },
            { key: "gate_type", label: "Tipo", type: "select", options: [["main", "Principal"], ["entry", "Entrada"], ["exit", "Saída"], ["pedestrian", "Pedestres"], ["visitor", "Visitantes"], ["contractor", "Prestadores"], ["emergency", "Emergência"]], default: "main" },
            { key: "status", label: "Status", type: "select", options: [["open", "Aberta"], ["closed", "Fechada"], ["blocked", "Bloqueada"]], default: "open" },
            { key: "lanes", label: "Faixas", type: "number", default: "1" }, { key: "supports_lpr", label: "LPR/ANPR", type: "select", options: [["false", "Não"], ["true", "Sim"]], default: "false" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "name", label: "Nome" }, { key: "gate_type", label: "Tipo" }, { key: "status", label: "Status" }, { key: "lanes", label: "Faixas" }]} />
      )}

      {tab === "Vagas" && (
        <div className="space-y-3">
          <p className="text-sm muted">Vagas/posições do pátio. Cor por status; edite ou cadastre novas posições.</p>
          <div className="flex flex-wrap gap-1.5">{slots.map((s: any) => (
            <div key={s.id} title={`${s.code} · ${s.status}`} className="grid place-items-center rounded text-[10px] text-white font-semibold" style={{ background: slotColor(s.status), width: 48, height: 36 }}>{s.code}</div>
          ))}</div>
          <CrudPanel table="yard_slots" title="Posições do pátio" rows={slots}
            emptyHint="Cadastre vagas por corredor/posição."
            fields={[
              { key: "code", label: "Código", required: true }, { key: "yard_zone_id", label: "Zona", type: "fk", fkTable: "yard_zones", fkLabel: "code" },
              { key: "row_label", label: "Corredor" }, { key: "position", label: "Posição", type: "number" },
              { key: "slot_type", label: "Tipo", type: "select", options: [["truck", "Caminhão"], ["trailer", "Carreta"], ["container", "Container"], ["support", "Apoio"], ["parking", "Estacionamento"]], default: "truck" },
              { key: "status", label: "Status", type: "select", options: [["free", "Livre"], ["occupied", "Ocupada"], ["reserved", "Reservada"], ["blocked", "Bloqueada"]], default: "free" },
            ]}
            columns={[{ key: "code", label: "Código" }, { key: "row_label", label: "Corredor" }, { key: "slot_type", label: "Tipo" }, { key: "status", label: "Status" }]} />
        </div>
      )}

      {tab === "Fila" && (
        <div className="space-y-3">
          <div className="card p-4 flex items-center gap-3">
            <div className="font-semibold text-sm mr-auto">Fila de atendimento (prioridade → chegada)</div>
            <button onClick={callNext} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold">{busy ? "…" : "📢 Chamar próximo"}</button>
          </div>
          {queue.length === 0 ? <p className="text-sm muted px-1">Fila vazia.</p> : (
            <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">#</th><th className="px-3">Tipo</th><th className="px-3 text-center">Prioridade</th><th className="px-3">Motivo</th><th className="px-3">Status</th><th className="px-3">Desde</th></tr></thead>
              <tbody>{queue.map((q: any, i: number) => (
                <tr key={q.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">{q.position ?? i + 1}</td><td className="px-3">{q.queue_type}</td>
                  <td className="px-3 text-center">{q.priority > 0 ? <span className="badge badge-warning">P{q.priority}</span> : q.priority}</td>
                  <td className="px-3 text-xs muted">{q.reason ?? "—"}</td>
                  <td className="px-3"><span className={`badge ${q.status === "waiting" ? "badge-neutral" : q.status === "serving" ? "badge-success" : ""}`}>{q.status}</span></td>
                  <td className="px-3 text-xs">{(q.enqueued_at ?? "").slice(0, 16).replace("T", " ")}</td>
                </tr>))}</tbody>
            </table></div>
          )}
        </div>
      )}

      {tab === "Movimentações" && (
        movements.length === 0 ? <p className="text-sm muted px-1">Sem movimentações registradas.</p> : (
          <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Quando</th><th className="px-3">Tipo</th><th className="px-3 text-right">Duração (min)</th><th className="px-3">Obs.</th></tr></thead>
            <tbody>{movements.map((m: any) => (
              <tr key={m.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                <td className="py-2 px-3 text-xs">{(m.occurred_at ?? "").slice(0, 16).replace("T", " ")}</td>
                <td className="px-3"><span className="badge badge-neutral">{m.movement_type}</span></td>
                <td className="px-3 text-right tabular-nums">{m.duration_min ?? "—"}</td><td className="px-3 text-xs muted">{m.notes ?? "—"}</td>
              </tr>))}</tbody>
          </table></div>
        )
      )}

      {tab === "Credenciais" && (
        <CrudPanel table="access_credentials" title="Credenciais de acesso" rows={credentials}
          emptyHint="QR, código de barras, RFID, tag veicular, biometria, crachá ou PIN — por motorista/veículo/visitante."
          fields={[
            { key: "credential_type", label: "Tipo", type: "select", options: [["qr", "QR Code"], ["barcode", "Código de barras"], ["rfid", "RFID"], ["vehicle_tag", "Tag veicular"], ["biometric", "Biometria"], ["badge", "Crachá"], ["pin", "PIN"]], default: "qr" },
            { key: "code", label: "Código/valor", required: true },
            { key: "subject_type", label: "Titular", type: "select", options: [["driver", "Motorista"], ["vehicle", "Veículo"], ["visitor", "Visitante"], ["contractor", "Prestador"], ["employee", "Colaborador"]], default: "driver" },
            { key: "subject_ref", label: "Identificação" }, { key: "valid_to", label: "Válida até", type: "date" },
            { key: "status", label: "Status", type: "select", options: [["active", "Ativa"], ["revoked", "Revogada"], ["expired", "Expirada"]], default: "active" },
          ]}
          columns={[{ key: "credential_type", label: "Tipo" }, { key: "code", label: "Código" }, { key: "subject_ref", label: "Titular" }, { key: "valid_to", label: "Válida até" }, { key: "status", label: "Status" }]} />
      )}

      {tab === "Visitantes" && (
        <CrudPanel table="yard_visitors" title="Visitantes & prestadores" rows={visitors}
          emptyHint="Registro de portaria de visitantes/prestadores (LGPD): nome, documento, anfitrião, motivo, crachá."
          fields={[
            { key: "name", label: "Nome", required: true }, { key: "document", label: "Documento" },
            { key: "visitor_type", label: "Tipo", type: "select", options: [["visitor", "Visitante"], ["contractor", "Prestador"], ["service", "Serviço"]], default: "visitor" },
            { key: "company_name", label: "Empresa" }, { key: "host_name", label: "Anfitrião" }, { key: "purpose", label: "Motivo" },
            { key: "badge_number", label: "Crachá" }, { key: "vehicle_plate", label: "Placa" },
            { key: "status", label: "Status", type: "select", options: [["inside", "Na área"], ["left", "Saiu"]], default: "inside" },
          ]}
          columns={[{ key: "name", label: "Nome" }, { key: "visitor_type", label: "Tipo" }, { key: "company_name", label: "Empresa" }, { key: "badge_number", label: "Crachá" }, { key: "status", label: "Status" }]} />
      )}

      {tab === "SLA" && (
        <div className="space-y-4">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="Portaria → doca (méd. min)" value={sla?.avg_gate_to_dock_min ?? "—"} accent />
            <KpiCard label="Doca → saída (méd. min)" value={sla?.avg_dock_to_out_min ?? "—"} />
            <KpiCard label="Tempo total (méd. min)" value={sla?.avg_total_min ?? "—"} />
            <KpiCard label="Visitas concluídas" value={sla?.completed_visits ?? 0} />
          </div>
          <div className="card p-0 overflow-x-auto">
            <div className="px-3 pt-3 font-semibold text-sm">Tempo total por transportadora</div>
            {(sla?.by_carrier ?? []).length === 0 ? <p className="text-sm muted p-3">Sem visitas concluídas.</p> : (
              <table className="w-full text-sm"><thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Transportadora</th><th className="px-3 text-right">Visitas</th><th className="px-3 text-right">Tempo total médio (min)</th></tr></thead>
              <tbody>{(sla?.by_carrier ?? []).map((c: any, i: number) => (
                <tr key={i} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">{c.carrier}</td><td className="px-3 text-right">{c.visits}</td>
                  <td className="px-3 text-right"><span className={`font-semibold ${c.avg_total_min > 120 ? "text-red-500" : "text-green-500"}`}>{c.avg_total_min ?? "—"}</span></td>
                </tr>))}</tbody></table>
            )}
          </div>
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
