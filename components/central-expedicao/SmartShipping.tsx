"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (n: any) => (n == null ? "—" : Number(n).toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 2 }));
const TABS = ["Painel", "Escolher Transportadora", "Otimizar Embalagem", "Caixas", "Cargas"] as const;

export default function SmartShipping({ center, boxes, loads }: { center: any; boxes: any[]; loads: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);

  async function call(rpc: string, label: string) {
    if (!supabase) return;
    setBusy(rpc); setMsg(null);
    const { data, error } = await supabase.rpc(rpc, { p_company: COMPANY });
    setBusy(null);
    setMsg(error ? error.message : `${label}: ${data ?? 0}`);
    router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">📦</div>
        <div>
          <h1 className="text-xl font-bold">Central Inteligente de Expedição</h1>
          <p className="text-sm muted">Ondas · escolha de transportadora · embalagem ótima · cargas · gargalos</p>
        </div>
        <div className="ml-auto flex gap-2">
          <button onClick={() => call("ssc_insights", "Gargalos")} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>IA gargalos</button>
          <button onClick={() => call("generate_shipping_waves", "Ondas geradas")} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{busy === "generate_shipping_waves" ? "Gerando…" : "⚡ Gerar ondas"}</button>
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
            <KpiCard label="Backlog (a expedir)" value={center?.backlog ?? "—"} accent />
            <KpiCard label="Confirmados" value={center?.confirmed ?? "—"} />
            <KpiCard label="Em separação" value={center?.picking ?? "—"} />
            <KpiCard label="Embalados" value={center?.packed ?? "—"} />
            <KpiCard label="Expedidos hoje" value={center?.shipped_today ?? "—"} />
            <KpiCard label="Ondas abertas" value={center?.waves_open ?? "—"} />
            <KpiCard label="Tarefas pendentes" value={center?.tasks_pending ?? "—"} />
            <KpiCard label="Cargas abertas" value={center?.loads_open ?? "—"} />
          </div>
          <div className="card p-4">
            <div className="font-semibold mb-2">Painel de gargalos (filas)</div>
            <div className="flex flex-wrap gap-3 text-sm">
              <Fila label="Separação" v={center?.picking} /><Fila label="Embalagem" v={center?.packed} />
              <Fila label="Tarefas WMS" v={center?.tasks_pending} /><Fila label="Ondas" v={center?.waves_open} />
              <Fila label="Docas hoje" v={center?.dock_appointments_today} />
            </div>
          </div>
        </div>
      )}

      {tab === "Escolher Transportadora" && <CarrierPicker />}
      {tab === "Otimizar Embalagem" && <PackingTool hasBoxes={boxes.length > 0} />}

      {tab === "Caixas" && (
        <CrudPanel table="packaging_boxes" title="Catálogo de caixas" rows={boxes}
          emptyHint="Cadastre as caixas (dimensões e peso máximo) para o motor de embalagem escolher a ideal."
          fields={[
            { key: "name", label: "Nome", required: true }, { key: "code", label: "Código" },
            { key: "length_mm", label: "Comp. (mm)", type: "number" }, { key: "width_mm", label: "Larg. (mm)", type: "number" }, { key: "height_mm", label: "Alt. (mm)", type: "number" },
            { key: "max_weight_g", label: "Peso máx (g)", type: "number" }, { key: "cost", label: "Custo (R$)", type: "number" },
          ]}
          columns={[{ key: "name", label: "Nome" }, { key: "max_weight_g", label: "Peso máx" }, { key: "cost", label: "Custo", fmt: (v) => money(v) }]} />
      )}

      {tab === "Cargas" && (
        <CrudPanel table="shipping_loads" title="Consolidação de cargas" rows={loads}
          emptyHint="Agrupe pedidos/volumes em pallets, gaiolas ou caminhões."
          fields={[
            { key: "code", label: "Código" },
            { key: "load_type", label: "Tipo", type: "select", options: [["pallet", "Pallet"], ["cage", "Gaiola"], ["truck", "Caminhão"], ["container", "Container"], ["van", "VUC"], ["moto", "Moto"], ["air", "Aérea"]], default: "truck" },
            { key: "carrier_id", label: "Transportadora", type: "fk", fkTable: "carriers" },
            { key: "status", label: "Status", type: "select", options: [["open", "Aberta"], ["loading", "Carregando"], ["dispatched", "Despachada"]], default: "open" },
            { key: "volumes", label: "Volumes", type: "number" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "load_type", label: "Tipo" }, { key: "status", label: "Status" }, { key: "volumes", label: "Volumes" }]} />
      )}
    </div>
  );
}

function Fila({ label, v }: { label: string; v: any }) {
  const n = Number(v ?? 0);
  const cls = n > 20 ? "bg-red-500/15 text-red-500" : n > 5 ? "bg-amber-500/15 text-amber-500" : "bg-green-500/15 text-green-500";
  return <div className="flex items-center gap-2"><span>{label}</span><span className={`px-2 py-0.5 rounded-md text-xs font-semibold ${cls}`}>{n}</span></div>;
}

function CarrierPicker() {
  const supabase = useMemo(() => createClient(), []);
  const [weight, setWeight] = useState("1000");
  const [urgency, setUrgency] = useState("normal");
  const [rows, setRows] = useState<any[]>([]);
  const [busy, setBusy] = useState(false);
  async function run() {
    if (!supabase) return;
    setBusy(true);
    const { data } = await supabase.rpc("recommend_carrier", { p_company: COMPANY, p_weight_g: Number(weight) || 0, p_urgency: urgency });
    setRows((data as any[]) ?? []); setBusy(false);
  }
  return (
    <div className="space-y-3 max-w-2xl">
      <div className="card p-4 flex flex-wrap gap-3 items-end">
        <div><label className="text-xs font-semibold muted">Peso (g)</label><input type="number" value={weight} onChange={(e) => setWeight(e.target.value)} className="w-28 mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
        <div><label className="text-xs font-semibold muted">Urgência</label>
          <select value={urgency} onChange={(e) => setUrgency(e.target.value)} className="mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
            <option value="normal">Normal</option><option value="high">Urgente</option></select></div>
        <button onClick={run} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold disabled:opacity-60">{busy ? "…" : "Recomendar"}</button>
      </div>
      {rows.length > 0 && (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Serviço</th><th className="px-3">Prazo</th><th className="px-3 text-right">Preço</th><th className="px-3 text-right">Score</th></tr></thead>
            <tbody>{rows.map((r, i) => (
              <tr key={i} className={`border-b last:border-0 ${i === 0 ? "bg-green-500/5" : ""}`} style={{ borderColor: "var(--border)" }}>
                <td className="py-2 px-3 font-medium">{r.service}{i === 0 && <span className="ml-2 text-xs text-green-500">recomendado</span>}</td>
                <td className="px-3">{r.sla_days} dia(s)</td><td className="px-3 text-right">{money(r.price)}</td><td className="px-3 text-right muted">{r.score}</td>
              </tr>))}</tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function PackingTool({ hasBoxes }: { hasBoxes: boolean }) {
  const supabase = useMemo(() => createClient(), []);
  const [weight, setWeight] = useState("2000");
  const [vol, setVol] = useState("2000");
  const [res, setRes] = useState<any>(null);
  const [busy, setBusy] = useState(false);
  async function run() {
    if (!supabase) return;
    setBusy(true);
    const { data } = await supabase.rpc("optimize_packing", { p_company: COMPANY, p_weight_g: Number(weight) || 0, p_volume_cm3: Number(vol) || 0 });
    setRes(data); setBusy(false);
  }
  return (
    <div className="space-y-3 max-w-2xl">
      {!hasBoxes && <p className="text-sm muted">Cadastre caixas (aba Caixas) para otimizar.</p>}
      <div className="card p-4 flex flex-wrap gap-3 items-end">
        <div><label className="text-xs font-semibold muted">Peso (g)</label><input type="number" value={weight} onChange={(e) => setWeight(e.target.value)} className="w-28 mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
        <div><label className="text-xs font-semibold muted">Volume (cm³)</label><input type="number" value={vol} onChange={(e) => setVol(e.target.value)} className="w-32 mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
        <button onClick={run} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold disabled:opacity-60">{busy ? "…" : "Otimizar"}</button>
      </div>
      {res && (
        <div className="card p-4">
          {res.box ? (
            <div>
              <div className="text-sm muted">Caixa ideal (menor que comporta):</div>
              <div className="text-2xl font-bold mt-1">{res.box}</div>
              <div className="text-sm muted mt-1">Volume interno {res.inner_volume_cm3} cm³ · peso máx {res.max_weight_g}g · custo {money(res.cost)}</div>
            </div>
          ) : <div className="text-sm text-amber-500">{res.message}</div>}
        </div>
      )}
    </div>
  );
}
