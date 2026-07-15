"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Rotas & Paradas", "Otimizar", "Prova de Entrega (POD)", "Ocorrências", "Geocercas"] as const;

const stopColor = (s: string) => ({ pending: "#64748b", en_route: "#2563eb", arrived: "#d97706", completed: "#16a34a", failed: "#dc2626" } as any)[s] ?? "#64748b";

export default function LMDPWorkbench({ dash, routes, stops, pods, geofences, deliveries, attempts }: {
  dash: any; routes: any[]; stops: any[]; pods: any[]; geofences: any[]; deliveries: any[]; attempts: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState(false);
  const [routeSel, setRouteSel] = useState("");
  const d = dash ?? {};
  const stopsByRoute = useMemo(() => {
    const m: Record<string, any[]> = {};
    for (const s of stops) (m[s.route_id] ??= []).push(s);
    return m;
  }, [stops]);

  async function optimize() {
    if (!supabase || !routeSel) return;
    setBusy(true);
    const { data, error } = await supabase.rpc("optimize_route", { p_company: COMPANY, p_route: routeSel });
    setBusy(false);
    alert(error ? "Erro: " + error.message : `Rota otimizada — ${data} paradas sequenciadas.`);
    router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🛵</div>
        <div>
          <h1 className="text-xl font-bold">Última Milha — LMDP</h1>
          <p className="text-sm muted">Roteirização inteligente · paradas · POD · geocercas · OTIF/OTD</p>
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
          <KpiCard label="Entregas" value={d.total ?? 0} accent />
          <div className="card p-4">
            <div className="text-xs uppercase tracking-wide muted font-semibold">OTD (no prazo)</div>
            <div className="mt-2 text-2xl font-bold" style={{ color: d.otd_pct >= 90 ? "var(--success)" : d.otd_pct != null ? "var(--warning)" : undefined }}>{d.otd_pct != null ? `${d.otd_pct}%` : "—"}</div>
          </div>
          <KpiCard label="Entregues" value={d.delivered ?? 0} />
          <KpiCard label="Em rota" value={d.out_for_delivery ?? 0} />
          <KpiCard label="Pendentes" value={d.pending ?? 0} />
          <KpiCard label="Falhas" value={d.failed ?? 0} />
          <KpiCard label="Provas (POD)" value={d.pods ?? 0} />
          <KpiCard label="Paradas pendentes" value={d.stops_pending ?? 0} />
          <KpiCard label="Rotas ativas" value={d.routes_active ?? 0} />
          <KpiCard label="Tentativas falhas" value={d.attempts_failed ?? 0} />
          <KpiCard label="Geocercas" value={d.geofences ?? 0} />
        </div>
      )}

      {tab === "Rotas & Paradas" && (
        <div className="space-y-3">
          {routes.length === 0 ? <p className="text-sm muted px-1">Nenhuma rota cadastrada.</p> : routes.map((r) => (
            <div key={r.id} className="card p-4">
              <div className="flex items-center gap-2">
                <span className="font-semibold text-sm">{r.code ?? "Rota"}</span>
                <span className="text-xs muted ml-auto">{r.planned_date ?? ""} · {(stopsByRoute[r.id] ?? []).length} paradas</span>
              </div>
              <div className="mt-2 flex flex-wrap gap-1.5">
                {(stopsByRoute[r.id] ?? []).length === 0 ? <span className="text-xs muted">sem paradas</span> :
                  (stopsByRoute[r.id] ?? []).map((s) => (
                    <div key={s.id} title={`${s.status}${s.planned_eta ? " · ETA " + String(s.planned_eta).slice(11, 16) : ""}`}
                      className="flex items-center gap-1 rounded-lg px-2 py-1 text-xs text-white" style={{ background: stopColor(s.status) }}>
                      <b>{s.sequence ?? "–"}</b> {s.address ?? "parada"}
                    </div>
                  ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {tab === "Otimizar" && (
        <div className="card p-4 space-y-3">
          <div className="font-semibold">🧭 Otimizador de rota (nearest-neighbor + ETA)</div>
          <p className="text-sm muted">Sequencia as paradas da rota minimizando a distância e recalcula o ETA de cada parada (30 km/h + tempo de serviço).</p>
          <div className="flex flex-wrap items-end gap-3">
            <select value={routeSel} onChange={(e) => setRouteSel(e.target.value)} className="border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="">Selecione a rota…</option>
              {routes.map((r) => <option key={r.id} value={r.id}>{r.code ?? r.id.slice(0, 8)} ({(stopsByRoute[r.id] ?? []).length} paradas)</option>)}
            </select>
            <button onClick={optimize} disabled={busy || !routeSel} className="px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold disabled:opacity-50">{busy ? "Otimizando…" : "Otimizar rota"}</button>
          </div>
          {routeSel && (stopsByRoute[routeSel] ?? []).length > 0 && (
            <div className="text-xs muted">Ordem atual: {(stopsByRoute[routeSel] ?? []).map((s) => `${s.sequence ?? "–"}:${s.address ?? "?"}`).join(" → ")}</div>
          )}
        </div>
      )}

      {tab === "Prova de Entrega (POD)" && (
        <div className="space-y-3">
          <PODForm supabase={supabase} deliveries={deliveries} onDone={() => router.refresh()} />
          {pods.length === 0 ? <p className="text-sm muted px-1">Nenhuma prova de entrega registrada.</p> : (
            <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Recebedor</th><th className="px-3">Doc</th><th className="px-3">Tipo</th><th className="px-3">Código</th><th className="px-3">Quando</th></tr></thead>
              <tbody>{pods.map((p) => (
                <tr key={p.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">{p.recipient_name ?? "—"}</td><td className="px-3 text-xs">{p.recipient_document ?? "—"}</td>
                  <td className="px-3"><span className="badge badge-neutral">{p.pod_type}</span></td><td className="px-3 text-xs">{p.confirmation_code ?? "—"}</td>
                  <td className="px-3 text-xs">{String(p.delivered_at ?? "").slice(0, 16).replace("T", " ")}</td>
                </tr>))}</tbody>
            </table></div>
          )}
        </div>
      )}

      {tab === "Ocorrências" && (
        <OccPanel supabase={supabase} deliveries={deliveries} attempts={attempts} onDone={() => router.refresh()} />
      )}

      {tab === "Geocercas" && (
        <CrudPanel table="geofences" title="Geocercas" rows={geofences}
          emptyHint="Áreas geográficas: CD, clientes, portos, áreas de risco, rotas obrigatórias."
          fields={[
            { key: "name", label: "Nome", required: true }, { key: "code", label: "Código" },
            { key: "geofence_type", label: "Tipo", type: "select", options: [["distribution_center", "CD"], ["customer", "Cliente"], ["supplier", "Fornecedor"], ["port", "Porto"], ["airport", "Aeroporto"], ["yard", "Pátio"], ["risk_area", "Área de risco"], ["mandatory_route", "Rota obrigatória"]], default: "customer" },
            { key: "center_lat", label: "Latitude", type: "number" }, { key: "center_lng", label: "Longitude", type: "number" }, { key: "radius_m", label: "Raio (m)", type: "number" },
          ]}
          columns={[{ key: "name", label: "Nome" }, { key: "geofence_type", label: "Tipo" }, { key: "center_lat", label: "Lat" }, { key: "center_lng", label: "Lng" }, { key: "radius_m", label: "Raio(m)" }]} />
      )}
    </div>
  );
}

function PODForm({ supabase, deliveries, onDone }: { supabase: any; deliveries: any[]; onDone: () => void }) {
  const [open, setOpen] = useState(false);
  const [f, setF] = useState<any>({ delivery: "", recipient: "", document: "", code: "", pod_type: "signature" });
  const [busy, setBusy] = useState(false);
  const pend = deliveries.filter((d) => d.status !== "delivered");
  async function save() {
    if (!supabase || !f.delivery) return;
    setBusy(true);
    const { error } = await supabase.rpc("register_pod", {
      p_company: COMPANY, p_delivery: f.delivery, p_recipient: f.recipient, p_document: f.document,
      p_signature: null, p_photo: null, p_lat: null, p_lng: null, p_code: f.code, p_pod_type: f.pod_type,
    });
    setBusy(false);
    if (error) { alert("Erro: " + error.message); return; }
    setOpen(false); setF({ delivery: "", recipient: "", document: "", code: "", pod_type: "signature" }); onDone();
  }
  return (
    <div className="card p-4">
      <div className="flex items-center gap-2">
        <div className="font-semibold text-sm mr-auto">Baixar entrega com prova (POD)</div>
        <button onClick={() => setOpen(!open)} className="px-3 py-1.5 rounded-lg bg-brand-600 text-white text-sm font-semibold">{open ? "Cancelar" : "+ Registrar POD"}</button>
      </div>
      {open && (
        <div className="mt-3 grid md:grid-cols-2 gap-2">
          <select value={f.delivery} onChange={(e) => setF({ ...f, delivery: e.target.value })} className="input"><option value="">Entrega…</option>{pend.map((d) => <option key={d.id} value={d.id}>{d.code ?? d.address ?? d.id.slice(0, 8)}</option>)}</select>
          <select value={f.pod_type} onChange={(e) => setF({ ...f, pod_type: e.target.value })} className="input"><option value="signature">Assinatura</option><option value="photo">Foto</option><option value="code">Código</option><option value="biometric">Biometria</option></select>
          <input className="input" placeholder="Nome do recebedor" value={f.recipient} onChange={(e) => setF({ ...f, recipient: e.target.value })} />
          <input className="input" placeholder="Documento do recebedor" value={f.document} onChange={(e) => setF({ ...f, document: e.target.value })} />
          <input className="input" placeholder="Código de confirmação" value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} />
          <button onClick={save} disabled={busy || !f.delivery} className="px-3 py-2 rounded-lg bg-green-600 hover:bg-green-700 text-white text-sm font-semibold disabled:opacity-50">{busy ? "Salvando…" : "Confirmar entrega"}</button>
        </div>
      )}
    </div>
  );
}

function OccPanel({ supabase, deliveries, attempts, onDone }: { supabase: any; deliveries: any[]; attempts: any[]; onDone: () => void }) {
  const [sel, setSel] = useState("");
  const [reason, setReason] = useState("");
  const [busy, setBusy] = useState(false);
  const pend = deliveries.filter((d) => !["delivered", "canceled"].includes(d.status));
  async function record() {
    if (!supabase || !sel || !reason) return;
    setBusy(true);
    const { error } = await supabase.rpc("record_delivery_attempt", { p_company: COMPANY, p_delivery: sel, p_reason: reason });
    setBusy(false);
    if (error) { alert("Erro: " + error.message); return; }
    setSel(""); setReason(""); onDone();
  }
  return (
    <div className="space-y-3">
      <div className="card p-4 flex flex-wrap items-end gap-2">
        <div className="font-semibold text-sm w-full">Registrar ocorrência / tentativa falha</div>
        <select value={sel} onChange={(e) => setSel(e.target.value)} className="input flex-1 min-w-[180px]"><option value="">Entrega…</option>{pend.map((d) => <option key={d.id} value={d.id}>{d.code ?? d.address ?? d.id.slice(0, 8)}</option>)}</select>
        <select value={reason} onChange={(e) => setReason(e.target.value)} className="input flex-1 min-w-[180px]"><option value="">Motivo…</option>{["Cliente ausente", "Endereço incorreto", "Recusa", "Produto avariado", "Extravio", "Acidente", "Área de risco"].map((r) => <option key={r} value={r}>{r}</option>)}</select>
        <button onClick={record} disabled={busy || !sel || !reason} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-50">{busy ? "…" : "Registrar"}</button>
      </div>
      {attempts.length === 0 ? <p className="text-sm muted px-1">Nenhuma ocorrência registrada.</p> : (
        <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
          <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Tentativa</th><th className="px-3">Motivo</th><th className="px-3">Quando</th></tr></thead>
          <tbody>{attempts.map((a) => (
            <tr key={a.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
              <td className="py-2 px-3">#{a.attempt_number}</td><td className="px-3">{a.reason ?? "—"}</td><td className="px-3 text-xs">{String(a.created_at ?? "").slice(0, 16).replace("T", " ")}</td>
            </tr>))}</tbody>
        </table></div>
      )}
    </div>
  );
}
