"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Volumes", "Rastreamento", "Hubs", "Lockers", "Consolidação"] as const;
const SCAN_TYPES: [string, string][] = [["entry", "Entrada"], ["sortation", "Triagem"], ["load", "Carga"], ["unload", "Descarga"], ["transfer", "Transferência"], ["exit", "Saída"], ["delivery", "Entrega"], ["pickup", "Coleta"], ["check", "Conferência"]];
const vColor = (s: string) => ({ open: "#64748b", packed: "#d97706", shipped: "#2563eb", delivered: "#16a34a", returned: "#dc2626" } as any)[s] ?? "#64748b";
const vLabel = (s: string) => ({ open: "Criado", packed: "Embalado", shipped: "Em trânsito", delivered: "Entregue", returned: "Devolvido" } as any)[s] ?? s;

export default function PMSWorkbench({ dash, volumes, hubs, labels, scans, lockers, assignments, consolidations }: {
  dash: any; volumes: any[]; hubs: any[]; labels: any[]; scans: any[]; lockers: any[]; assignments: any[]; consolidations: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState("");
  const [scanType, setScanType] = useState("sortation");
  const [scanHub, setScanHub] = useState("");
  const [journeyVol, setJourneyVol] = useState("");
  const d = dash ?? {};
  const hubName = useMemo(() => Object.fromEntries(hubs.map((h) => [h.id, h.name ?? h.code])), [hubs]);

  async function genLpn(vol: string) {
    if (!supabase) return; setBusy(vol);
    const { error } = await supabase.rpc("generate_lpn", { p_company: COMPANY, p_volume: vol });
    setBusy(""); if (error) alert("Erro: " + error.message); else router.refresh();
  }
  async function scan(vol: string) {
    if (!supabase) return; setBusy(vol);
    const { error } = await supabase.rpc("scan_parcel", { p_company: COMPANY, p_volume: vol, p_scan_type: scanType, p_hub: scanHub || null, p_location: null, p_notes: null });
    setBusy(""); if (error) alert("Erro: " + error.message); else router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">📦</div>
        <div>
          <h1 className="text-xl font-bold">Encomendas & Volumes — PMS</h1>
          <p className="text-sm muted">LPN/etiquetas · scan events · rastreabilidade · hubs · lockers · consolidação</p>
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
          <KpiCard label="Volumes" value={d.volumes ?? 0} accent />
          <KpiCard label="Em trânsito" value={d.in_transit ?? 0} />
          <KpiCard label="No hub" value={d.at_hub ?? 0} />
          <KpiCard label="Entregues" value={d.delivered ?? 0} />
          <KpiCard label="Devolvidos" value={d.returned ?? 0} />
          <KpiCard label="Scans hoje" value={d.scans_today ?? 0} />
          <KpiCard label="Hubs" value={d.hubs ?? 0} hint={`${d.hubs_congested ?? 0} congestionados`} tone={d.hubs_congested ? "warning" : undefined} />
          <KpiCard label="Lockers aguardando" value={d.lockers_awaiting ?? 0} />
          <KpiCard label="Etiquetas" value={d.labels ?? 0} />
          <KpiCard label="Consolidações abertas" value={d.consolidations_open ?? 0} />
        </div>
      )}

      {tab === "Volumes" && (
        <div className="space-y-3">
          <div className="card p-3 flex flex-wrap items-end gap-2">
            <div className="font-semibold text-sm w-full">Bipar volume (scan event)</div>
            <label className="text-xs muted">Tipo
              <select value={scanType} onChange={(e) => setScanType(e.target.value)} className="input block mt-0.5">{SCAN_TYPES.map(([k, l]) => <option key={k} value={k}>{l}</option>)}</select></label>
            <label className="text-xs muted">Hub
              <select value={scanHub} onChange={(e) => setScanHub(e.target.value)} className="input block mt-0.5"><option value="">—</option>{hubs.map((h) => <option key={h.id} value={h.id}>{h.name ?? h.code}</option>)}</select></label>
            <span className="text-xs muted">Escolha o tipo/hub e clique em ↯ na linha do volume.</span>
          </div>
          {volumes.length === 0 ? <p className="text-sm muted px-1">Nenhum volume. Volumes vêm da criação de pedidos logísticos.</p> : (
            <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Código</th><th className="px-3">LPN</th><th className="px-3">Status</th><th className="px-3">Hub atual</th><th className="px-3 text-right">Ações</th></tr></thead>
              <tbody>{volumes.map((v) => (
                <tr key={v.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-medium">{v.code ?? v.tracking_code ?? v.id.slice(0, 8)}</td>
                  <td className="px-3 text-xs font-mono">{v.lpn ?? "—"}</td>
                  <td className="px-3"><span className="badge" style={{ background: vColor(v.status), color: "#fff" }}>{vLabel(v.status)}</span></td>
                  <td className="px-3 text-xs muted">{v.current_hub_id ? hubName[v.current_hub_id] ?? "hub" : "—"}</td>
                  <td className="px-3 text-right whitespace-nowrap">
                    {!v.lpn && <button onClick={() => genLpn(v.id)} disabled={busy === v.id} className="text-xs text-brand-600 hover:underline mr-3">🏷 gerar LPN</button>}
                    <button onClick={() => scan(v.id)} disabled={busy === v.id} className="text-xs text-green-600 hover:underline mr-3">↯ bipar</button>
                    <button onClick={() => { setJourneyVol(v.id); setTab("Rastreamento"); }} className="text-xs text-brand-600 hover:underline">🧭 jornada</button>
                  </td>
                </tr>))}</tbody>
            </table></div>
          )}
        </div>
      )}

      {tab === "Rastreamento" && (
        <div className="space-y-3">
          <label className="text-sm muted">Volume:
            <select value={journeyVol} onChange={(e) => setJourneyVol(e.target.value)} className="input ml-2 inline-block w-auto"><option value="">Selecione…</option>{volumes.map((v) => <option key={v.id} value={v.id}>{v.code ?? v.id.slice(0, 8)}{v.lpn ? " · " + v.lpn : ""}</option>)}</select></label>
          {!journeyVol ? <p className="text-sm muted px-1">Escolha um volume para ver a jornada de leituras.</p> : (() => {
            const j = scans.filter((s) => s.volume_id === journeyVol);
            return j.length === 0 ? <p className="text-sm muted px-1">Sem leituras para este volume.</p> : (
              <div className="card p-4">
                <ol className="relative border-l-2 pl-4 space-y-3" style={{ borderColor: "var(--border)" }}>
                  {j.map((s) => (
                    <li key={s.id} className="relative">
                      <span className="absolute -left-[21px] top-1 h-3 w-3 rounded-full" style={{ background: "var(--brand)" }} />
                      <div className="text-sm font-medium">{SCAN_TYPES.find(([k]) => k === s.scan_type)?.[1] ?? s.scan_type}{s.hub_id ? ` · ${hubName[s.hub_id] ?? "hub"}` : ""}</div>
                      <div className="text-xs muted">{String(s.scanned_at ?? "").slice(0, 16).replace("T", " ")}{s.location ? ` · ${s.location}` : ""}</div>
                    </li>
                  ))}
                </ol>
              </div>
            );
          })()}
        </div>
      )}

      {tab === "Hubs" && (
        <CrudPanel table="hubs" title="Hubs & centros de triagem" rows={hubs}
          emptyHint="Centros de triagem, CDs, hubs, mini-hubs, lockers, pontos de coleta, agências, cross-dock."
          fields={[
            { key: "code", label: "Código", required: true }, { key: "name", label: "Nome" },
            { key: "hub_type", label: "Tipo", type: "select", options: [["sorting_center", "Centro de triagem"], ["distribution_center", "CD"], ["hub", "Hub"], ["mini_hub", "Mini-hub"], ["locker_station", "Locker station"], ["pickup_point", "Ponto de coleta"], ["agency", "Agência"], ["cross_dock", "Cross-dock"]], default: "hub" },
            { key: "city", label: "Cidade" }, { key: "state", label: "UF" }, { key: "capacity", label: "Capacidade", type: "number" },
            { key: "status", label: "Status", type: "select", options: [["active", "Ativo"], ["congested", "Congestionado"], ["inactive", "Inativo"]], default: "active" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "name", label: "Nome" }, { key: "hub_type", label: "Tipo" }, { key: "city", label: "Cidade" }, { key: "status", label: "Status" }]} />
      )}

      {tab === "Lockers" && (
        <div className="space-y-4">
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-3">
            {lockers.map((l) => (
              <div key={l.id} className="card p-4">
                <div className="font-semibold text-sm">{l.code}</div>
                <div className="text-xs muted">{hubName[l.hub_id] ?? "—"}</div>
                <div className="mt-2 text-2xl font-bold">{l.available_compartments}<span className="text-sm muted">/{l.total_compartments} livres</span></div>
                <span className={`badge mt-1 ${l.status === "full" ? "badge-warning" : "badge-success"}`}>{l.status}</span>
              </div>
            ))}
            {lockers.length === 0 && <p className="text-sm muted px-1">Nenhum locker. Cadastre pela tabela abaixo.</p>}
          </div>
          {assignments.length > 0 && (
            <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Compart.</th><th className="px-3">Código retirada</th><th className="px-3">Expira</th><th className="px-3">Status</th></tr></thead>
              <tbody>{assignments.map((a) => (
                <tr key={a.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">#{a.compartment_no}</td><td className="px-3 font-mono text-xs">{a.pickup_code}</td>
                  <td className="px-3 text-xs">{String(a.expires_at ?? "").slice(0, 16).replace("T", " ")}</td>
                  <td className="px-3"><span className="badge badge-neutral">{a.status}</span></td>
                </tr>))}</tbody>
            </table></div>
          )}
          <CrudPanel table="lockers" title="Cadastro de lockers" rows={lockers}
            fields={[
              { key: "code", label: "Código", required: true }, { key: "hub_id", label: "Hub", type: "fk", fkTable: "hubs", fkLabel: "code" },
              { key: "total_compartments", label: "Compartimentos", type: "number", default: "20" }, { key: "available_compartments", label: "Disponíveis", type: "number", default: "20" },
            ]}
            columns={[{ key: "code", label: "Código" }, { key: "total_compartments", label: "Total" }, { key: "available_compartments", label: "Livres" }, { key: "status", label: "Status" }]} />
        </div>
      )}

      {tab === "Consolidação" && (
        consolidations.length === 0 ? <p className="text-sm muted px-1">Nenhuma consolidação. Use a RPC consolidate_volumes para agrupar volumes num master.</p> : (
          <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Master</th><th className="px-3">Tipo</th><th className="px-3 text-center">Volumes</th><th className="px-3">Status</th><th className="px-3">Criado</th></tr></thead>
            <tbody>{consolidations.map((cs) => (
              <tr key={cs.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                <td className="py-2 px-3 font-medium">{cs.master_code}</td><td className="px-3 text-xs">{cs.consolidation_type === "deconsolidation" ? "Desconsolidação" : "Consolidação"}</td>
                <td className="px-3 text-center">{cs.volume_count}</td><td className="px-3"><span className={`badge ${cs.status === "open" ? "badge-neutral" : "badge-success"}`}>{cs.status}</span></td>
                <td className="px-3 text-xs muted">{String(cs.created_at ?? "").slice(0, 10)}</td>
              </tr>))}</tbody>
          </table></div>
        )
      )}
    </div>
  );
}
