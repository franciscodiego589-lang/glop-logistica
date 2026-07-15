"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Slotting (IA)", "Reabastecimento", "Produtividade", "Sustentabilidade (ESG)"] as const;

export default function WMSEnterprise({ dash, slotting, esg, prod, utilities }: { dash: any; slotting: any[]; esg: any; prod: any[]; utilities: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const occ = dash?.locations_total > 0 ? Math.round((dash.locations_used / dash.locations_total) * 100) : 0;

  async function call(rpc: string, label: string) {
    if (!supabase) return;
    setBusy(rpc); setMsg(null);
    const { data, error } = await supabase.rpc(rpc, { p_company: COMPANY });
    setBusy(null); setMsg(error ? error.message : `${label}: ${data ?? 0}`); router.refresh();
  }
  async function applySlotting(id: string, productId: string, locId: string) {
    if (!supabase) return;
    setBusy(id);
    await supabase.from("products").update({ default_location_id: locId }).eq("id", productId);
    await supabase.from("slotting_recommendations").update({ status: "applied" }).eq("id", id);
    setBusy(null); router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🏬</div>
        <div>
          <h1 className="text-xl font-bold">WMS Enterprise — Operação do Armazém</h1>
          <p className="text-sm muted">Slotting IA · putaway · reabastecimento · produtividade · ESG · congestão</p>
        </div>
        <div className="ml-auto flex gap-2">
          <button onClick={() => call("wms_insights", "Insights")} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>IA armazém</button>
          <button onClick={() => call("generate_replenishment_tasks", "Tarefas de reabastecimento")} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{busy === "generate_replenishment_tasks" ? "…" : "⚡ Reabastecer"}</button>
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
            <div className="card p-4">
              <div className="text-xs uppercase tracking-wide muted font-semibold">Ocupação</div>
              <div className="mt-2 text-2xl font-bold">{occ}%</div>
              <div className="h-2 rounded-full bg-black/10 dark:bg-white/10 overflow-hidden mt-2"><div className={`h-full ${occ > 85 ? "bg-red-500" : occ > 60 ? "bg-amber-500" : "bg-green-500"}`} style={{ width: `${occ}%` }} /></div>
            </div>
            <KpiCard label="Posições (bins)" value={dash?.locations_total ?? "—"} />
            <KpiCard label="Tarefas pendentes" value={dash?.tasks_pending ?? "—"} accent />
            <KpiCard label="Concluídas hoje" value={dash?.tasks_done_today ?? "—"} />
            <KpiCard label="Ondas abertas" value={dash?.waves_open ?? "—"} />
            <KpiCard label="Recebimentos abertos" value={dash?.inbound_open ?? "—"} />
            <KpiCard label="Slotting pendente" value={dash?.slotting_open ?? "—"} />
          </div>
          {dash?.aisle_congestion?.length > 0 && (
            <div className="card p-4">
              <div className="font-semibold mb-2">Congestão por zona (tarefas pendentes)</div>
              {dash.aisle_congestion.map((z: any, i: number) => (
                <div key={i} className="flex justify-between text-sm py-1"><span>{z.zone}</span><span className={`font-semibold ${z.tasks > 20 ? "text-red-500" : z.tasks > 5 ? "text-amber-500" : ""}`}>{z.tasks}</span></div>
              ))}
            </div>
          )}
        </div>
      )}

      {tab === "Slotting (IA)" && (
        <div className="space-y-2">
          <div className="flex items-center gap-2"><div className="font-semibold">Recomendações de slotting <span className="muted font-normal">({slotting.length})</span></div>
            <button onClick={() => call("recommend_slotting", "Recomendações")} disabled={!!busy} className="ml-auto text-sm px-3 py-2 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>Recalcular</button></div>
          {slotting.length === 0 ? <p className="text-sm muted px-1">Nenhuma recomendação. (Precisa de produtos curva A + zonas de picking cadastradas.)</p> : slotting.map((s) => (
            <div key={s.id} className="card p-4 flex items-center gap-2">
              <div><div className="text-sm font-medium">{s.reason}</div><div className="text-xs muted">{s.estimated_gain}</div></div>
              {s.suggested_location_id && <button onClick={() => applySlotting(s.id, s.product_id, s.suggested_location_id)} disabled={busy === s.id} className="ml-auto text-xs px-3 py-1.5 rounded-lg bg-brand-600 hover:bg-brand-700 text-white font-semibold">Aplicar</button>}
            </div>
          ))}
        </div>
      )}

      {tab === "Reabastecimento" && (
        <div className="card p-6 text-center">
          <p className="text-sm muted mb-3">Cria tarefas de reabastecimento quando as posições de picking ficam abaixo do estoque mínimo (puxando do pulmão/reserva).</p>
          <button onClick={() => call("generate_replenishment_tasks", "Tarefas criadas")} disabled={!!busy} className="px-4 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold">⚡ Gerar tarefas de reabastecimento</button>
          <p className="text-xs muted mt-3">As tarefas aparecem no módulo WMS → Tarefas.</p>
        </div>
      )}

      {tab === "Produtividade" && (
        prod.length === 0 ? <p className="text-sm muted px-1">Sem tarefas atribuídas a operadores ainda.</p> : (
          <div className="card p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Operador</th><th className="px-3 text-right">Tarefas</th><th className="px-3 text-right">Concluídas</th><th className="px-3 text-right">%</th></tr></thead>
              <tbody>{prod.map((p, i) => (
                <tr key={i} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">{p.operator}</td><td className="px-3 text-right">{p.tasks}</td><td className="px-3 text-right">{p.done}</td>
                  <td className="px-3 text-right">{p.tasks > 0 ? Math.round((p.done / p.tasks) * 100) : 0}%</td>
                </tr>))}</tbody>
            </table>
          </div>
        )
      )}

      {tab === "Sustentabilidade (ESG)" && (
        <div className="space-y-3">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="Energia" value={esg?.energy ?? "—"} hint="kWh" />
            <KpiCard label="Água" value={esg?.water ?? "—"} hint="m³" />
            <KpiCard label="Resíduos" value={esg?.waste ?? "—"} hint="kg" />
            <KpiCard label="CO₂" value={esg?.co2_kg ?? "—"} hint="kg" accent />
          </div>
          <CrudPanel table="warehouse_utilities" title="Consumos & resíduos" rows={utilities}
            emptyHint="Registre consumo de energia/água/gás e resíduos para os indicadores ESG."
            fields={[
              { key: "utility_type", label: "Tipo", type: "select", options: [["energy", "Energia"], ["water", "Água"], ["gas", "Gás"], ["waste", "Resíduos"], ["recycling", "Reciclagem"]], default: "energy" },
              { key: "value", label: "Valor", type: "number" }, { key: "unit", label: "Unidade" }, { key: "co2_kg", label: "CO₂ (kg)", type: "number" },
            ]}
            columns={[{ key: "utility_type", label: "Tipo" }, { key: "value", label: "Valor" }, { key: "unit", label: "Un" }, { key: "co2_kg", label: "CO₂" }]} />
        </div>
      )}
    </div>
  );
}
