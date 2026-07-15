"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (n: any) => (n == null ? "—" : Number(n).toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 }));
const TABS = ["Painel", "Auditoria", "Oportunidades", "Matriz de Riscos", "Custo por Transportadora"] as const;
const LEVEL: Record<string, { l: string; cls: string }> = {
  critical: { l: "Crítico", cls: "bg-red-500/15 text-red-500" }, high: { l: "Alto", cls: "bg-orange-500/15 text-orange-500" },
  medium: { l: "Médio", cls: "bg-amber-500/15 text-amber-500" }, low: { l: "Baixo", cls: "bg-green-500/15 text-green-500" }, very_low: { l: "Muito baixo", cls: "bg-green-500/15 text-green-500" },
};

export default function AuditWorkbench({ dash, findings, opportunities, risks, carrierCosts }:
  { dash: any; findings: any[]; opportunities: any[]; risks: any[]; carrierCosts: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const igel = dash?.igel != null ? Number(dash.igel) : null;
  const igelCls = igel == null ? "text-slate-400" : igel >= 80 ? "text-green-500" : igel >= 50 ? "text-amber-500" : "text-red-500";

  async function call(rpc: string, label: string) {
    if (!supabase) return;
    setBusy(rpc); setMsg(null);
    const { data, error } = await supabase.rpc(rpc, { p_company: COMPANY });
    setBusy(null);
    setMsg(error ? error.message : `${label}: ${data ?? 0}`);
    router.refresh();
  }
  async function auditAll() {
    if (!supabase) return;
    setBusy("all"); setMsg(null);
    await supabase.rpc("run_logistics_audit", { p_company: COMPANY });
    await supabase.rpc("detect_waste_opportunities", { p_company: COMPANY });
    const { data } = await supabase.rpc("compute_igel", { p_company: COMPANY });
    setBusy(null); setMsg(`Auditoria completa. IGEL recalculado: ${data ?? "—"}.`); router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🔎</div>
        <div>
          <h1 className="text-xl font-bold">Auditoria Logística & Inteligência (LAIS)</h1>
          <p className="text-sm muted">Auditoria contínua · custos · rentabilidade · desperdícios · riscos · IGEL</p>
        </div>
        <button onClick={auditAll} disabled={!!busy} className="ml-auto text-sm px-4 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{busy === "all" ? "Auditando…" : "⚡ Auditoria completa"}</button>
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
          <div className="grid md:grid-cols-4 gap-3">
            <div className="card p-5 md:col-span-1 grid place-items-center text-center">
              <div className="text-xs uppercase tracking-wide muted font-semibold">IGEL</div>
              <div className={`text-5xl font-bold tabular-nums ${igelCls}`}>{igel != null ? igel.toFixed(0) : "—"}</div>
              <div className="text-xs muted mt-1">Índice Global de Eficiência Logística</div>
            </div>
            <div className="md:col-span-3 grid grid-cols-2 lg:grid-cols-3 gap-3">
              <KpiCard label="Custo logístico" value={money(dash?.logistics_cost)} />
              <KpiCard label="Perda com devoluções" value={money(dash?.lost_returns)} />
              <KpiCard label="Divergências de frete" value={money(dash?.freight_divergence)} accent />
              <KpiCard label="Economia potencial" value={money(dash?.potential_savings)} />
              <KpiCard label="Achados abertos" value={dash?.open_findings ?? "—"} />
              <KpiCard label="OTIF" value={dash?.otif != null ? `${dash.otif}%` : "—"} />
            </div>
          </div>
        </div>
      )}

      {tab === "Auditoria" && (
        <div className="space-y-2">
          {findings.length === 0 ? <p className="text-sm muted px-1">Nenhum achado. Clique em “Auditoria completa”.</p> : findings.map((f) => (
            <div key={f.id} className={`card p-4 border ${f.severity === "critical" ? "border-red-500/40" : "border-amber-500/40"}`}>
              <div className="flex items-center gap-2">
                <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${f.severity === "critical" ? "bg-red-500/15 text-red-500" : "bg-amber-500/15 text-amber-500"}`}>{f.category}</span>
                <span className="font-semibold text-sm">{f.finding_type}</span>
                {f.financial_impact ? <span className="ml-auto text-sm font-semibold text-red-500">{money(f.financial_impact)}</span> : null}
              </div>
              <p className="text-sm mt-1">{f.description}</p>
              {f.action_plan && <p className="text-xs muted mt-1">✦ {f.action_plan}</p>}
            </div>
          ))}
        </div>
      )}

      {tab === "Oportunidades" && (
        <div className="space-y-2">
          {opportunities.length === 0 ? <p className="text-sm muted px-1">Nenhuma oportunidade detectada ainda.</p> : opportunities.map((o) => (
            <div key={o.id} className="card p-4">
              <div className="flex items-center gap-2">
                <span className="text-xs px-2 py-0.5 rounded-md bg-brand-500/15 text-brand-500 font-semibold">{o.category}</span>
                <span className="font-semibold text-sm">{o.title}</span>
                {o.estimated_savings ? <span className="ml-auto text-sm font-semibold text-green-500">≈ {money(o.estimated_savings)}</span> : null}
              </div>
              <p className="text-sm mt-1">{o.description}</p>
              <p className="text-xs muted mt-1">Impacto no SLA: {o.sla_impact ?? "—"} · Implementação: {o.implementation_time ?? "—"}</p>
            </div>
          ))}
        </div>
      )}

      {tab === "Matriz de Riscos" && (
        <CrudPanel table="logistics_risks" title="Matriz de riscos (probabilidade × impacto)" rows={risks}
          emptyHint="Cadastre riscos logísticos; o nível (muito baixo→crítico) é calculado automaticamente."
          fields={[
            { key: "title", label: "Risco", required: true }, { key: "area", label: "Área" },
            { key: "probability", label: "Probabilidade (1-5)", type: "number", default: "1" },
            { key: "impact", label: "Impacto (1-5)", type: "number", default: "1" },
            { key: "financial_value", label: "Valor (R$)", type: "number" },
            { key: "action_plan", label: "Plano de ação" },
          ]}
          columns={[{ key: "title", label: "Risco" }, { key: "area", label: "Área" }, { key: "probability", label: "P" }, { key: "impact", label: "I" }, { key: "level", label: "Nível", fmt: (v) => LEVEL[v]?.l ?? v }, { key: "financial_value", label: "Valor", fmt: (v) => money(v) }]} />
      )}

      {tab === "Custo por Transportadora" && (
        carrierCosts.length === 0 ? <p className="text-sm muted px-1">Sem embarces com frete registrado.</p> : (
          <div className="card p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Transportadora</th><th className="px-3 text-right">Embarques</th><th className="px-3 text-right">Frete total</th><th className="px-3 text-right">Frete médio</th></tr></thead>
              <tbody>
                {carrierCosts.map((c, i) => (
                  <tr key={i} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                    <td className="py-2 px-3">{c.carrier}</td>
                    <td className="px-3 text-right">{c.shipments}</td>
                    <td className="px-3 text-right">{money(c.freight_total)}</td>
                    <td className="px-3 text-right">{money(c.avg_freight)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )
      )}
    </div>
  );
}
