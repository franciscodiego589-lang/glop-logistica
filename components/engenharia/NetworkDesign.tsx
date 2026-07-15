"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (n: any) => (n == null ? "—" : Number(n).toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 }));
const TABS = ["Painel", "Mapa de Demanda", "IA de Localização", "Cenários (Digital Twin)", "Capacidade"] as const;

export default function NetworkDesign({ dash, demand, capacity, scenarios }: { dash: any; demand: any[]; capacity: any; scenarios: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const [recs, setRecs] = useState<any[]>([]);
  const [open, setOpen] = useState(false);
  const [f, setF] = useState({ name: "", scenario_type: "open_cd", capex: "", opex_annual: "", annual_savings: "", description: "" });
  const maxDemand = Math.max(1, ...demand.map((d) => d.orders));

  async function loadRecs() {
    if (!supabase) return;
    setBusy("rec");
    const { data } = await supabase.rpc("recommend_cd_location", { p_company: COMPANY });
    setRecs((data as any[]) ?? []); setBusy(null);
  }
  async function ia() {
    if (!supabase) return;
    setBusy("ia"); setMsg(null);
    const { data, error } = await supabase.rpc("lpnd_insights", { p_company: COMPANY });
    setBusy(null); setMsg(error ? error.message : `${data ?? 0} oportunidade(s) de rede na LOGIA.`); router.refresh();
  }
  async function createScenario() {
    if (!supabase || !f.name.trim()) return;
    setBusy("create");
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    await supabase.from("network_scenarios").insert({
      tenant_id: (comp as any)?.tenant_id, company_id: COMPANY, name: f.name.trim(), scenario_type: f.scenario_type,
      description: f.description || null, capex: f.capex ? Number(f.capex) : null, opex_annual: f.opex_annual ? Number(f.opex_annual) : null,
      annual_savings: f.annual_savings ? Number(f.annual_savings) : null,
    });
    setBusy(null); setOpen(false); setF({ name: "", scenario_type: "open_cd", capex: "", opex_annual: "", annual_savings: "", description: "" }); router.refresh();
  }
  async function simulate(id: string) {
    if (!supabase) return;
    setBusy(id);
    const { data } = await supabase.rpc("simulate_network_finance", { p_scenario: id });
    setBusy(null); setMsg(`Simulado: ROI ${data?.roi_percent ?? "—"}% · payback ${data?.payback_months ?? "—"} meses`); router.refresh();
  }
  async function approve(id: string) {
    if (!supabase) return;
    setBusy(id);
    await supabase.from("network_scenarios").update({ status: "approved", approved_at: new Date().toISOString() }).eq("id", id);
    setBusy(null); router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🗺</div>
        <div>
          <h1 className="text-xl font-bold">Engenharia Logística — Network Design</h1>
          <p className="text-sm muted">Digital twin · mapa de demanda · IA de localização · ROI/payback · capacidade</p>
        </div>
        <button onClick={ia} disabled={!!busy} className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">IA rede</button>
      </div>
      {msg && <div className="text-sm text-brand-500 px-1">{msg}</div>}

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => { setTab(t); if (t === "IA de Localização" && recs.length === 0) loadRecs(); }}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <KpiCard label="Centros de distribuição" value={dash?.warehouses ?? "—"} />
          <KpiCard label="UFs com demanda" value={dash?.ufs_with_demand ?? "—"} />
          <KpiCard label="Pedidos (base)" value={dash?.total_orders ?? "—"} />
          <KpiCard label="Cenários" value={dash?.scenarios ?? "—"} />
          <KpiCard label="Cenários aprovados" value={dash?.scenarios_approved ?? "—"} />
          <KpiCard label="Economia potencial" value={money(dash?.potential_savings)} accent />
          <KpiCard label="Melhor ROI" value={dash?.best_roi != null ? `${dash.best_roi}%` : "—"} />
        </div>
      )}

      {tab === "Mapa de Demanda" && (
        demand.length === 0 ? <p className="text-sm muted px-1">Sem pedidos de saída para mapear a demanda.</p> : (
          <div className="card p-4 space-y-2">
            <div className="font-semibold mb-2">Demanda por UF (heatmap)</div>
            {demand.map((d) => (
              <div key={d.uf} className="flex items-center gap-3 text-sm">
                <span className="w-8 font-mono">{d.uf}</span>
                <div className="flex-1 h-4 rounded bg-black/5 dark:bg-white/5 overflow-hidden"><div className="h-full bg-brand-500" style={{ width: `${(d.orders / maxDemand) * 100}%` }} /></div>
                <span className="w-16 text-right tabular-nums">{d.orders}</span>
                <span className="w-24 text-right tabular-nums muted">{money(d.value)}</span>
              </div>
            ))}
          </div>
        )
      )}

      {tab === "IA de Localização" && (
        <div className="space-y-2">
          <div className="flex items-center gap-2"><div className="font-semibold">Regiões com maior potencial para CD/hub</div>
            <button onClick={loadRecs} disabled={!!busy} className="ml-auto text-sm px-3 py-2 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>{busy === "rec" ? "…" : "Analisar"}</button></div>
          {recs.length === 0 ? <p className="text-sm muted px-1">Sem demanda suficiente para recomendar. (Precisa de pedidos de saída.)</p> : recs.map((r, i) => (
            <div key={i} className={`card p-4 ${i === 0 ? "ring-1 ring-brand-500/40" : ""}`}>
              <div className="flex items-center gap-2">
                <span className="font-mono font-bold text-lg">{r.uf}</span>
                {i === 0 && <span className="text-xs text-brand-500 font-semibold">melhor candidato</span>}
                <span className="ml-auto text-sm font-semibold text-green-500">≈ {money(r.estimated_annual_saving)}/ano</span>
              </div>
              <p className="text-sm mt-1">{r.recommendation}</p>
              <p className="text-xs muted mt-1">{r.orders} pedidos · demanda {money(r.demand_value)}</p>
            </div>
          ))}
        </div>
      )}

      {tab === "Cenários (Digital Twin)" && (
        <div className="space-y-3">
          <div className="flex items-center gap-2"><div className="font-semibold">Cenários <span className="muted font-normal">({scenarios.length})</span></div>
            <button onClick={() => setOpen((o) => !o)} className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Novo cenário"}</button></div>
          {open && (
            <div className="card p-4 grid md:grid-cols-3 gap-3">
              <div className="md:col-span-2"><label className="text-xs font-semibold muted">Nome</label><input value={f.name} onChange={(e) => setF({ ...f, name: e.target.value })} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div><label className="text-xs font-semibold muted">Tipo</label>
                <select value={f.scenario_type} onChange={(e) => setF({ ...f, scenario_type: e.target.value })} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                  {[["open_cd", "Abrir CD"], ["close_cd", "Fechar CD"], ["open_hub", "Abrir Hub"], ["change_carrier", "Trocar transportadora"], ["change_modal", "Trocar modal"], ["expand", "Expandir"]].map(([v, l]) => <option key={v} value={v}>{l}</option>)}
                </select></div>
              <div><label className="text-xs font-semibold muted">CapEx (R$)</label><input type="number" value={f.capex} onChange={(e) => setF({ ...f, capex: e.target.value })} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div><label className="text-xs font-semibold muted">OpEx anual (R$)</label><input type="number" value={f.opex_annual} onChange={(e) => setF({ ...f, opex_annual: e.target.value })} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div><label className="text-xs font-semibold muted">Economia anual (R$)</label><input type="number" value={f.annual_savings} onChange={(e) => setF({ ...f, annual_savings: e.target.value })} className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <button onClick={createScenario} disabled={busy === "create"} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60 md:col-span-3 w-fit">Criar cenário</button>
            </div>
          )}
          {scenarios.map((s) => (
            <div key={s.id} className="card p-4">
              <div className="flex items-center gap-2 flex-wrap">
                <span className="font-semibold">{s.name}</span>
                <span className="text-xs muted">{s.scenario_type}</span>
                <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${s.status === "approved" ? "bg-green-500/15 text-green-500" : s.status === "simulated" ? "bg-blue-500/15 text-blue-500" : "bg-slate-500/15 text-slate-400"}`}>{s.status}</span>
                <div className="ml-auto flex gap-2">
                  <button onClick={() => simulate(s.id)} disabled={busy === s.id} className="text-xs px-3 py-1.5 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>Simular</button>
                  {s.status !== "approved" && <button onClick={() => approve(s.id)} disabled={busy === s.id} className="text-xs px-3 py-1.5 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">Aprovar</button>}
                </div>
              </div>
              <div className="flex flex-wrap gap-4 text-sm mt-2">
                <span>CapEx: {money(s.capex)}</span><span>OpEx/ano: {money(s.opex_annual)}</span><span>Economia/ano: {money(s.annual_savings)}</span>
                <span>ROI: <b className={s.roi >= 0 ? "text-green-500" : "text-red-500"}>{s.roi != null ? s.roi + "%" : "—"}</b></span>
                <span>Payback: <b>{s.payback_months != null ? s.payback_months + " meses" : "—"}</b></span>
              </div>
            </div>
          ))}
        </div>
      )}

      {tab === "Capacidade" && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <KpiCard label="Armazéns" value={capacity?.warehouses ?? "—"} />
          <KpiCard label="Posições (bins)" value={capacity?.locations_total ?? "—"} />
          <KpiCard label="Posições ocupadas" value={capacity?.locations_used ?? "—"} accent />
          <KpiCard label="Docas" value={capacity?.docks_total ?? "—"} />
          <KpiCard label="Docas livres" value={capacity?.docks_available ?? "—"} />
          <KpiCard label="Veículos" value={capacity?.vehicles ?? "—"} />
          <KpiCard label="Backlog de pedidos" value={capacity?.orders_backlog ?? "—"} />
        </div>
      )}
    </div>
  );
}
