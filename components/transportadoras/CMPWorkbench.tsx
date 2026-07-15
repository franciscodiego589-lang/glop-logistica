"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Transportadoras", "Scorecard & Ranking", "Contratos", "Documentos", "Ocorrências"] as const;

const homColor = (s: string) => ({ approved: "#16a34a", pending: "#d97706", under_review: "#2563eb", rejected: "#dc2626", suspended: "#64748b" } as any)[s] ?? "#64748b";
const homLabel = (s: string) => ({ approved: "Homologada", pending: "Pendente", under_review: "Em análise", rejected: "Rejeitada", suspended: "Suspensa" } as any)[s] ?? s;
const scoreColor = (n: number) => n >= 80 ? "var(--success)" : n >= 60 ? "var(--warning)" : "var(--danger)";

export default function CMPWorkbench({ dash, ranking, carriers, docs, contracts, occurrences }: {
  dash: any; ranking: any[]; carriers: any[]; docs: any[]; contracts: any[]; occurrences: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState("");
  const d = dash ?? {};
  const now = new Date();

  async function homologate(carrier: string, status: string) {
    if (!supabase) return;
    setBusy(carrier);
    const { error } = await supabase.rpc("homologate_carrier", { p_company: COMPANY, p_carrier: carrier, p_status: status });
    setBusy("");
    if (error) { alert("Bloqueado: " + error.message); return; }
    router.refresh();
  }
  async function scorecard(carrier: string) {
    if (!supabase) return;
    setBusy(carrier);
    const { error } = await supabase.rpc("compute_carrier_scorecard", { p_company: COMPANY, p_carrier: carrier, p_year: now.getFullYear(), p_month: now.getMonth() + 1 });
    setBusy("");
    if (error) { alert("Erro: " + error.message); return; }
    router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🚛</div>
        <div>
          <h1 className="text-xl font-bold">Transportadoras — CMP</h1>
          <p className="text-sm muted">SRM logístico: homologação · contratos · documentos · scorecard · ranking · ocorrências</p>
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
          <KpiCard label="Transportadoras" value={d.carriers ?? 0} accent />
          <KpiCard label="Homologadas" value={d.homologated ?? 0} />
          <KpiCard label="Homologação pendente" value={d.pending_homolog ?? 0} />
          <div className="card p-4">
            <div className="text-xs uppercase tracking-wide muted font-semibold">OTD médio</div>
            <div className="mt-2 text-2xl font-bold">{d.avg_otd != null ? `${d.avg_otd}%` : "—"}</div>
          </div>
          <KpiCard label="Contratos vencendo (30d)" value={d.contracts_expiring ?? 0} />
          <KpiCard label="Docs vencendo (30d)" value={d.docs_expiring ?? 0} />
          <KpiCard label="Docs vencidos" value={d.docs_expired ?? 0} />
          <KpiCard label="Ocorrências abertas" value={d.occurrences_open ?? 0} />
        </div>
      )}

      {tab === "Transportadoras" && (
        <div className="space-y-3">
          <p className="text-sm muted">Homologação e recálculo de scorecard por transportadora.</p>
          {carriers.length === 0 ? <p className="text-sm muted px-1">Nenhuma transportadora.</p> : (
            <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Código</th><th className="px-3">Nome</th><th className="px-3">Tipo</th><th className="px-3">Homologação</th><th className="px-3 text-right">Rating</th><th className="px-3 text-right">Ações</th></tr></thead>
              <tbody>{carriers.map((c) => (
                <tr key={c.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-medium">{c.code}</td>
                  <td className="px-3">{c.trade_name ?? c.legal_name ?? "—"}</td>
                  <td className="px-3 text-xs muted">{c.carrier_type ?? "—"}</td>
                  <td className="px-3"><span className="badge" style={{ background: homColor(c.homologation_status), color: "#fff" }}>{homLabel(c.homologation_status)}</span></td>
                  <td className="px-3 text-right tabular-nums">{c.rating != null ? <span style={{ color: scoreColor(c.rating) }}>{c.rating}</span> : "—"}</td>
                  <td className="px-3 text-right whitespace-nowrap">
                    <button onClick={() => scorecard(c.id)} disabled={busy === c.id} className="text-xs text-brand-600 hover:underline mr-3">↻ scorecard</button>
                    {c.homologation_status !== "approved"
                      ? <button onClick={() => homologate(c.id, "approved")} disabled={busy === c.id} className="text-xs text-green-600 hover:underline">✓ homologar</button>
                      : <button onClick={() => homologate(c.id, "suspended")} disabled={busy === c.id} className="text-xs text-red-600 hover:underline">⊘ suspender</button>}
                  </td>
                </tr>))}</tbody>
            </table></div>
          )}
        </div>
      )}

      {tab === "Scorecard & Ranking" && (
        ranking.length === 0 ? <p className="text-sm muted px-1">Sem scorecards. Calcule na aba Transportadoras.</p> : (
          <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">#</th><th className="px-3">Transportadora</th><th className="px-3">Tipo</th><th className="px-3 text-right">OTD</th><th className="px-3 text-center">Ocorr.</th><th className="px-3 text-right">Score</th><th className="px-3">Período</th></tr></thead>
            <tbody>{ranking.map((r, i) => (
              <tr key={r.carrier_id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                <td className="py-2 px-3 font-bold">{i + 1}º</td><td className="px-3 font-medium">{r.carrier}</td><td className="px-3 text-xs muted">{r.carrier_type ?? "—"}</td>
                <td className="px-3 text-right tabular-nums">{r.otd_pct != null ? `${r.otd_pct}%` : "—"}</td>
                <td className="px-3 text-center">{r.occurrences ?? 0}</td>
                <td className="px-3 text-right"><span className="font-bold text-base" style={{ color: r.overall_score != null ? scoreColor(r.overall_score) : undefined }}>{r.overall_score ?? "—"}</span></td>
                <td className="px-3 text-xs muted">{r.period ?? "—"}</td>
              </tr>))}</tbody>
          </table></div>
        )
      )}

      {tab === "Contratos" && (
        <CrudPanel table="carrier_contracts" title="Contratos comerciais" rows={contracts}
          emptyHint="Contratos, vigência, SLA de coleta/entrega, penalidades e bônus."
          fields={[
            { key: "carrier_id", label: "Transportadora", type: "fk", fkTable: "carriers", fkLabel: "code", required: true },
            { key: "code", label: "Código" },
            { key: "contract_type", label: "Tipo", type: "select", options: [["spot", "Spot"], ["dedicated", "Dedicado"], ["master", "Master"], ["addendum", "Aditivo"]], default: "spot" },
            { key: "start_date", label: "Início", type: "date" }, { key: "end_date", label: "Fim", type: "date" },
            { key: "sla_pickup_hours", label: "SLA coleta (h)", type: "number" }, { key: "sla_delivery_hours", label: "SLA entrega (h)", type: "number" },
            { key: "status", label: "Status", type: "select", options: [["draft", "Rascunho"], ["active", "Ativo"], ["suspended", "Suspenso"], ["expired", "Vencido"], ["canceled", "Cancelado"]], default: "active" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "contract_type", label: "Tipo" }, { key: "end_date", label: "Vence" }, { key: "status", label: "Status" }]} />
      )}

      {tab === "Documentos" && (
        <CrudPanel table="carrier_documents" title="Documentos & compliance" rows={docs}
          emptyHint="ANTT, seguros, licenças, certificações, alvarás — com validade."
          fields={[
            { key: "carrier_id", label: "Transportadora", type: "fk", fkTable: "carriers", fkLabel: "code", required: true },
            { key: "doc_type", label: "Tipo", type: "select", options: [["antt", "ANTT"], ["insurance", "Seguro"], ["license", "Licença"], ["certificate", "Certificado"], ["alvara", "Alvará"], ["fiscal", "Fiscal"], ["special_auth", "Autorização especial"], ["other", "Outro"]], default: "antt" },
            { key: "number", label: "Número" }, { key: "issuer", label: "Emissor" }, { key: "valid_to", label: "Válido até", type: "date" },
            { key: "mandatory", label: "Obrigatório", type: "select", options: [["false", "Não"], ["true", "Sim"]], default: "false" },
            { key: "status", label: "Status", type: "select", options: [["valid", "Válido"], ["expired", "Vencido"], ["pending", "Pendente"], ["revoked", "Revogado"]], default: "valid" },
          ]}
          columns={[{ key: "doc_type", label: "Tipo" }, { key: "number", label: "Número" }, { key: "valid_to", label: "Válido até" }, { key: "status", label: "Status" }]} />
      )}

      {tab === "Ocorrências" && (
        <CrudPanel table="carrier_occurrences" title="Ocorrências operacionais" rows={occurrences}
          emptyHint="Atrasos, avarias, extravios, sinistros, recusas, não conformidades + plano de ação."
          fields={[
            { key: "carrier_id", label: "Transportadora", type: "fk", fkTable: "carriers", fkLabel: "code", required: true },
            { key: "occurrence_type", label: "Tipo", type: "select", options: [["delay", "Atraso"], ["damage", "Avaria"], ["loss", "Extravio"], ["theft", "Roubo"], ["refusal", "Recusa"], ["failure", "Falha"], ["nonconformity", "Não conformidade"], ["accident", "Acidente"]], default: "delay" },
            { key: "severity", label: "Severidade", type: "select", options: [["low", "Baixa"], ["medium", "Média"], ["high", "Alta"], ["critical", "Crítica"]], default: "medium" },
            { key: "description", label: "Descrição" }, { key: "occurred_on", label: "Data", type: "date" }, { key: "action_plan", label: "Plano de ação" },
            { key: "status", label: "Status", type: "select", options: [["open", "Aberta"], ["investigating", "Investigando"], ["resolved", "Resolvida"], ["closed", "Fechada"]], default: "open" },
          ]}
          columns={[{ key: "occurrence_type", label: "Tipo" }, { key: "severity", label: "Sev." }, { key: "occurred_on", label: "Data" }, { key: "status", label: "Status" }]} />
      )}
    </div>
  );
}
