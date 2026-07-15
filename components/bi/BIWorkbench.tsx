"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const fmt = (v: number, f: string) => f === "currency"
  ? "R$ " + (v ?? 0).toLocaleString("pt-BR", { maximumFractionDigits: 0 })
  : (v ?? 0).toLocaleString("pt-BR", { maximumFractionDigits: 0 });

const TABS = ["Cockpit Executivo", "KPIs & Tendências", "Alertas", "Catálogo de Dados"] as const;
type Tab = typeof TABS[number];

export default function BIWorkbench({ overview, kpis, alerts, catalog }: {
  overview: any; kpis: any[]; alerts: any[]; catalog: any[];
}) {
  const [tab, setTab] = useState<Tab>("Cockpit Executivo");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Plataforma · Inteligência Corporativa</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Business Intelligence & Analytics</h1>
        <p className="text-sm muted mt-0.5">Cockpit executivo, catálogo de KPIs com tendências, alertas por limite e governança de dados — sobre os dados reais de todos os módulos.</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Cockpit Executivo" && <Cockpit overview={overview} />}
      {tab === "KPIs & Tendências" && <KpiCatalog kpis={kpis} />}
      {tab === "Alertas" && (
        <CrudPanel table="bi_alerts" title="Alertas por Limite"
          fields={[
            { key: "name", label: "Nome do alerta", required: true },
            { key: "kpi_key", label: "KPI", type: "select", options: kpis.map((k) => [k.kpi_key, k.name]) as [string, string][], required: true },
            { key: "operator", label: "Operador", type: "select", options: [[">","maior que"],[">=","maior ou igual"],["<","menor que"],["<=","menor ou igual"]], default: ">" },
            { key: "threshold", label: "Limite", type: "number", required: true },
            { key: "channel", label: "Canal", type: "select", options: [["portal","Portal"],["email","E-mail"],["whatsapp","WhatsApp"]], default: "portal" },
          ]}
          columns={[{ key: "name", label: "Alerta" }, { key: "kpi_key", label: "KPI" }, { key: "operator", label: "Op." }, { key: "threshold", label: "Limite" }]}
          rows={alerts} emptyHint="Dispare avisos quando indicadores ultrapassarem limites (alimenta o LAIOS)." />
      )}
      {tab === "Catálogo de Dados" && (
        <CrudPanel table="data_catalog" title="Catálogo & Governança de Dados"
          fields={[
            { key: "name", label: "Ativo de dados", required: true },
            { key: "description", label: "Descrição" },
            { key: "domain", label: "Domínio" },
            { key: "source_table", label: "Tabela de origem" },
            { key: "classification", label: "Classificação", type: "select", options: [["public","Pública"],["internal","Interna"],["confidential","Confidencial"],["restricted","Restrita"]], default: "internal" },
            { key: "quality_score", label: "Qualidade (0-100)", type: "number" },
            { key: "owner", label: "Data Owner" },
          ]}
          columns={[
            { key: "name", label: "Ativo" }, { key: "domain", label: "Domínio" }, { key: "source_table", label: "Origem" },
            { key: "classification", label: "Classificação" }, { key: "quality_score", label: "Qualidade" },
          ]}
          rows={catalog} emptyHint="Catálogo corporativo de dados, linhagem e qualidade." />
      )}
    </div>
  );
}

function Cockpit({ overview }: { overview: any }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const kpis: any[] = overview?.kpis ?? [];
  const byModule = useMemo(() => {
    const m: Record<string, any[]> = {};
    kpis.forEach((k) => { (m[k.module] = m[k.module] || []).push(k); });
    return Object.entries(m);
  }, [kpis]);
  async function snapshot() {
    if (!supabase) return;
    setBusy(true);
    await supabase.rpc("snapshot_kpis", { p_company: COMPANY });
    setBusy(false); router.refresh();
  }
  const tone = (s: string) => s === "ok" ? "var(--success)" : s === "warn" ? "var(--warning)" : "var(--muted)";
  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="text-sm muted mr-auto">Atualizado em {overview?.as_of ? new Date(overview.as_of).toLocaleString("pt-BR") : "—"}</div>
        <button onClick={snapshot} disabled={busy} className="btn btn-sm">{busy ? "Capturando…" : "📸 Capturar snapshot (tendência)"}</button>
      </div>
      {byModule.map(([mod, ks]) => (
        <div key={mod}>
          <div className="text-xs font-semibold uppercase tracking-wider muted mb-2">{mod}</div>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
            {ks.map((k) => (
              <div key={k.key} className="kpi relative overflow-hidden">
                <span className="absolute left-0 top-0 bottom-0 w-1" style={{ background: tone(k.status) }} />
                <div className="kpi-label">{k.name}</div>
                <div className="kpi-value tabular-nums">{fmt(Number(k.value), k.format)}</div>
                {k.target != null && <div className="text-xs muted mt-0.5">Meta: {fmt(Number(k.target), k.format)} · <span style={{ color: tone(k.status) }}>{k.status === "ok" ? "atingida" : k.status === "warn" ? "abaixo" : "—"}</span></div>}
              </div>
            ))}
          </div>
        </div>
      ))}
      {kpis.length === 0 && <p className="text-sm muted">Sem KPIs no catálogo.</p>}
    </div>
  );
}

function KpiCatalog({ kpis }: { kpis: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const [sel, setSel] = useState<string | null>(null);
  const [trend, setTrend] = useState<any[] | null>(null);
  async function loadTrend(key: string) {
    if (!supabase) return;
    setSel(key); setTrend(null);
    const { data } = await supabase.rpc("kpi_trend", { p_company: COMPANY, p_key: key, p_limit: 30 });
    setTrend(data ?? []);
  }
  const max = trend && trend.length ? Math.max(...trend.map((t) => Math.abs(Number(t.value))), 1) : 1;
  return (
    <div className="grid lg:grid-cols-2 gap-4">
      <div className="card p-0 overflow-x-auto">
        <table className="tbl">
          <thead><tr><th>KPI</th><th>Módulo</th><th className="text-right">Meta</th><th></th></tr></thead>
          <tbody>
            {kpis.map((k) => (
              <tr key={k.id} className={sel === k.kpi_key ? "surface-2" : ""}>
                <td className="font-medium">{k.name}</td>
                <td className="text-xs muted">{k.module}</td>
                <td className="text-right tabular-nums">{k.target_value != null ? fmt(Number(k.target_value), k.format) : "—"}</td>
                <td className="text-right"><button onClick={() => loadTrend(k.kpi_key)} className="text-xs text-brand-600 hover:underline">tendência</button></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="card p-5">
        <div className="font-semibold mb-3">{sel ? `Tendência — ${kpis.find((k) => k.kpi_key === sel)?.name}` : "Selecione um KPI"}</div>
        {!sel ? <p className="text-sm muted">Clique em “tendência” num KPI.</p> : !trend ? <p className="text-sm muted">Carregando…</p> : trend.length === 0 ? (
          <p className="text-sm muted">Sem histórico ainda. Capture snapshots no Cockpit para acumular a série.</p>
        ) : (
          <div className="flex items-end gap-1 h-40">
            {trend.map((t, i) => (
              <div key={i} className="flex-1 flex flex-col items-center justify-end gap-1" title={`${new Date(t.at).toLocaleString("pt-BR")}: ${t.value}`}>
                <div className="w-full rounded-t" style={{ height: `${(Math.abs(Number(t.value)) / max) * 100}%`, background: "var(--brand)", minHeight: 3 }} />
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
