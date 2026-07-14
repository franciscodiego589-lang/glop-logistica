"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel, { Field, Column } from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";
import SpcChart from "./SpcChart";
import SignPanel from "./SignPanel";

const TABS = ["Painel", "Inspeções", "Não Conformidades", "CAPA", "Auditorias", "Riscos (FMEA)", "CEP/SPC", "Documentos",
  "Reclamações", "Liberação de Lote", "Assinaturas", "Especificações", "Planos", "Treinamentos", "Validações", "Recall", "CoA"] as const;

const bool: [string, string][] = [["true", "Sim"], ["false", "Não"]];

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

export default function QualityWorkbench({ kpis, data, lots }: { kpis: any; data: Record<string, any[]>; lots: any[] }) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [iaMsg, setIaMsg] = useState<string | null>(null);
  const [iaBusy, setIaBusy] = useState(false);

  async function runPredict() {
    if (!supabase) return;
    setIaBusy(true); setIaMsg(null);
    const { data: n, error } = await supabase.rpc("quality_predict", { p_company: COMPANY });
    setIaBusy(false);
    setIaMsg(error ? error.message : `LOGIA analisou os processos: ${n ?? 0} desvio(s) de capabilidade detectado(s). Veja em LOGIA (IA).`);
    router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">✔</div>
        <div>
          <h1 className="text-xl font-bold">QMS — Gestão da Qualidade</h1>
          <p className="text-sm muted">Volume 08 · Conformidade, inspeções, NC/CAPA, FMEA, liberação de lote</p>
        </div>
      </div>

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="space-y-3">
        <div className="card p-3 flex items-center gap-3">
          <div className="text-sm"><b>✦ IA da Qualidade</b> <span className="muted">— detecta processos com baixa capabilidade (Cpk&lt;1,33) antes de gerarem NC.</span></div>
          <button onClick={runPredict} disabled={iaBusy} className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white font-semibold disabled:opacity-60">
            {iaBusy ? "Analisando…" : "Analisar desvios"}
          </button>
        </div>
        {iaMsg && <div className="text-sm text-brand-500 px-1">{iaMsg}</div>}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <KpiCard label="NCs abertas" value={kpis?.nc_open ?? "—"} accent />
          <KpiCard label="NCs críticas" value={kpis?.nc_critical ?? "—"} />
          <KpiCard label="CAPAs abertas" value={kpis?.capa_open ?? "—"} />
          <KpiCard label="CAPAs em atraso" value={kpis?.capa_overdue ?? "—"} />
          <KpiCard label="Índice de aprovação" value={kpis?.approval_rate != null ? `${kpis.approval_rate}%` : "—"} hint="inspeções 90d" />
          <KpiCard label="Inspeções pendentes" value={kpis?.inspections_pending ?? "—"} />
          <KpiCard label="Riscos altos (RPN≥100)" value={kpis?.high_risks ?? "—"} />
          <KpiCard label="Lotes em quarentena" value={kpis?.lots_quarantine ?? "—"} />
          <KpiCard label="Auditorias planejadas" value={kpis?.audits_planned ?? "—"} />
          <KpiCard label="Reclamações abertas" value={kpis?.complaints_open ?? "—"} />
        </div>
        </div>
      )}

      {tab === "CEP/SPC" && <SpcChart />}

      {tab === "Assinaturas" && <SignPanel documents={data.quality_documents} inspections={data.quality_inspections} />}

      {tab === "Inspeções" && <CrudPanel table="quality_inspections" title="Inspeções" rows={data.quality_inspections}
        fields={[
          { key: "code", label: "Código" },
          { key: "inspection_type", label: "Tipo", type: "select", options: [["receiving","Recebimento"],["in_process","Em processo"],["final","Final"],["supplier","Fornecedor"],["periodic","Periódica"]] },
          { key: "product_id", label: "Produto", type: "fk", fkTable: "products" },
          { key: "lot_id", label: "Lote", type: "fk", fkTable: "product_lots", fkLabel: "lot_number" },
          { key: "supplier_id", label: "Fornecedor", type: "fk", fkTable: "suppliers" },
          { key: "result", label: "Resultado", type: "select", options: [["pending","Pendente"],["approved","Aprovado"],["rejected","Reprovado"],["conditional","Condicional"]] },
          { key: "inspected_at", label: "Data", type: "date" },
          { key: "notes", label: "Observações" },
        ] as Field[]}
        columns={[{ key: "code", label: "Código" }, { key: "inspection_type", label: "Tipo" }, { key: "product_id", label: "Produto" }, { key: "result", label: "Resultado" }] as Column[]} />}

      {tab === "Não Conformidades" && <CrudPanel table="nonconformities" title="Não Conformidades" rows={data.nonconformities}
        fields={[
          { key: "code", label: "Código" }, { key: "title", label: "Título", required: true },
          { key: "severity", label: "Gravidade", type: "select", options: [["minor","Menor"],["major","Maior"],["critical","Crítica"]] },
          { key: "source", label: "Origem" },
          { key: "status", label: "Status", type: "select", options: [["open","Aberta"],["investigating","Investigando"],["action","Ação"],["verifying","Verificando"],["closed","Fechada"]] },
          { key: "product_id", label: "Produto", type: "fk", fkTable: "products" },
          { key: "description", label: "Descrição" },
        ] as Field[]}
        columns={[{ key: "code", label: "Código" }, { key: "title", label: "Título" }, { key: "severity", label: "Gravidade" }, { key: "status", label: "Status" }] as Column[]} />}

      {tab === "CAPA" && <CrudPanel table="capas" title="CAPA — Ações Corretivas/Preventivas" rows={data.capas}
        fields={[
          { key: "code", label: "Código" }, { key: "title", label: "Título", required: true },
          { key: "status", label: "Status", type: "select", options: [["open","Aberta"],["investigation","Investigação"],["action_plan","Plano de ação"],["implementing","Implementando"],["verifying","Verificando"],["effective","Eficaz"],["closed","Fechada"]] },
          { key: "root_cause", label: "Causa raiz" }, { key: "action_plan", label: "Plano de ação" }, { key: "due_date", label: "Prazo", type: "date" },
        ] as Field[]}
        columns={[{ key: "code", label: "Código" }, { key: "title", label: "Título" }, { key: "status", label: "Status" }, { key: "due_date", label: "Prazo" }] as Column[]} />}

      {tab === "Auditorias" && <CrudPanel table="quality_audits" title="Auditorias" rows={data.quality_audits}
        fields={[
          { key: "code", label: "Código" },
          { key: "audit_type", label: "Tipo", type: "select", options: [["internal","Interna"],["external","Externa"],["supplier","Fornecedor"],["customer","Cliente"],["regulatory","Regulatória"]] },
          { key: "status", label: "Status", type: "select", options: [["planned","Planejada"],["in_progress","Em andamento"],["closed","Fechada"]] },
          { key: "scope", label: "Escopo" }, { key: "standard", label: "Norma" }, { key: "auditor", label: "Auditor" },
          { key: "planned_date", label: "Data planejada", type: "date" }, { key: "score", label: "Nota", type: "number" },
        ] as Field[]}
        columns={[{ key: "code", label: "Código" }, { key: "audit_type", label: "Tipo" }, { key: "status", label: "Status" }, { key: "planned_date", label: "Planejada" }, { key: "score", label: "Nota" }] as Column[]} />}

      {tab === "Riscos (FMEA)" && <CrudPanel table="quality_risks" title="Riscos (FMEA) — RPN = S × O × D" rows={data.quality_risks}
        fields={[
          { key: "process", label: "Processo" }, { key: "failure_mode", label: "Modo de falha", required: true },
          { key: "effect", label: "Efeito" }, { key: "cause", label: "Causa" },
          { key: "severity", label: "Severidade (1-10)", type: "number" }, { key: "occurrence", label: "Ocorrência (1-10)", type: "number" }, { key: "detection", label: "Detecção (1-10)", type: "number" },
          { key: "mitigation", label: "Mitigação" },
          { key: "status", label: "Status", type: "select", options: [["open","Aberto"],["mitigating","Mitigando"],["closed","Fechado"]] },
        ] as Field[]}
        columns={[{ key: "failure_mode", label: "Modo de falha" }, { key: "severity", label: "S" }, { key: "occurrence", label: "O" }, { key: "detection", label: "D" }, { key: "rpn", label: "RPN", fmt: (v) => String(v ?? "—") }, { key: "status", label: "Status" }] as Column[]} />}

      {tab === "Documentos" && <CrudPanel table="quality_documents" title="Gestão Documental" rows={data.quality_documents}
        fields={[
          { key: "code", label: "Código" }, { key: "title", label: "Título", required: true }, { key: "doc_type", label: "Tipo (POP, IT, Esp…)" },
          { key: "doc_version", label: "Versão", default: "1.0" },
          { key: "status", label: "Status", type: "select", options: [["draft","Rascunho"],["review","Revisão"],["approved","Aprovado"],["obsolete","Obsoleto"]] },
          { key: "content_url", label: "URL" }, { key: "effective_date", label: "Vigência", type: "date" },
        ] as Field[]}
        columns={[{ key: "code", label: "Código" }, { key: "title", label: "Título" }, { key: "doc_version", label: "Versão" }, { key: "status", label: "Status" }] as Column[]} />}

      {tab === "Reclamações" && <CrudPanel table="complaints" title="Reclamações" rows={data.complaints}
        fields={[
          { key: "code", label: "Código" }, { key: "title", label: "Título", required: true },
          { key: "customer_id", label: "Cliente", type: "fk", fkTable: "customers" },
          { key: "product_id", label: "Produto", type: "fk", fkTable: "products" },
          { key: "status", label: "Status", type: "select", options: [["open","Aberta"],["investigating","Investigando"],["responded","Respondida"],["closed","Fechada"]] },
          { key: "description", label: "Descrição" },
        ] as Field[]}
        columns={[{ key: "code", label: "Código" }, { key: "title", label: "Título" }, { key: "status", label: "Status" }] as Column[]} />}

      {tab === "Liberação de Lote" && <BatchRelease lots={lots} />}

      {tab === "Especificações" && <CrudPanel table="quality_specifications" title="Especificações técnicas" rows={data.quality_specifications}
        fields={[
          { key: "product_id", label: "Produto", type: "fk", fkTable: "products" }, { key: "parameter", label: "Parâmetro", required: true },
          { key: "method", label: "Método" }, { key: "unit", label: "Unidade" },
          { key: "min_value", label: "Mín", type: "number" }, { key: "max_value", label: "Máx", type: "number" }, { key: "target_value", label: "Alvo", type: "number" },
          { key: "is_critical", label: "Crítico", type: "select", options: bool },
        ] as Field[]}
        columns={[{ key: "parameter", label: "Parâmetro" }, { key: "unit", label: "Un" }, { key: "min_value", label: "Mín" }, { key: "max_value", label: "Máx" }, { key: "is_critical", label: "Crítico" }] as Column[]} />}

      {tab === "Planos" && <CrudPanel table="inspection_plans" title="Planos de inspeção / amostragem" rows={data.inspection_plans}
        fields={[
          { key: "code", label: "Código" }, { key: "name", label: "Nome", required: true },
          { key: "inspection_type", label: "Tipo", type: "select", options: [["receiving","Recebimento"],["in_process","Em processo"],["final","Final"],["supplier","Fornecedor"],["periodic","Periódica"]] },
          { key: "product_id", label: "Produto", type: "fk", fkTable: "products" }, { key: "sampling_plan", label: "Plano de amostragem" }, { key: "aql", label: "AQL", type: "number" },
        ] as Field[]}
        columns={[{ key: "name", label: "Nome" }, { key: "inspection_type", label: "Tipo" }, { key: "aql", label: "AQL" }] as Column[]} />}

      {tab === "Treinamentos" && <CrudPanel table="trainings" title="Treinamentos" rows={data.trainings}
        fields={[
          { key: "code", label: "Código" }, { key: "title", label: "Título", required: true },
          { key: "mandatory", label: "Obrigatório", type: "select", options: bool }, { key: "valid_days", label: "Validade (dias)", type: "number" }, { key: "description", label: "Descrição" },
        ] as Field[]}
        columns={[{ key: "title", label: "Título" }, { key: "mandatory", label: "Obrigatório" }, { key: "valid_days", label: "Validade(d)" }] as Column[]} />}

      {tab === "Validações" && <CrudPanel table="validations" title="Qualificação & Validação (IQ/OQ/PQ)" rows={data.validations}
        fields={[
          { key: "code", label: "Código" },
          { key: "validation_type", label: "Tipo", type: "select", options: [["iq","IQ"],["oq","OQ"],["pq","PQ"],["process","Processo"],["cleaning","Limpeza"],["csv","CSV"]] },
          { key: "scope", label: "Escopo" }, { key: "target", label: "Equipamento/Sistema" },
          { key: "status", label: "Status", type: "select", options: [["planned","Planejada"],["executing","Executando"],["approved","Aprovada"],["failed","Reprovada"]] },
          { key: "executed_at", label: "Executada em", type: "date" },
        ] as Field[]}
        columns={[{ key: "code", label: "Código" }, { key: "validation_type", label: "Tipo" }, { key: "status", label: "Status" }] as Column[]} />}

      {tab === "Recall" && <CrudPanel table="recalls" title="Recall" rows={data.recalls}
        fields={[
          { key: "code", label: "Código" },
          { key: "recall_type", label: "Tipo", type: "select", options: [["simulation","Simulação"],["partial","Parcial"],["total","Total"]] },
          { key: "product_id", label: "Produto", type: "fk", fkTable: "products" }, { key: "lot_id", label: "Lote", type: "fk", fkTable: "product_lots", fkLabel: "lot_number" },
          { key: "reason", label: "Motivo" }, { key: "status", label: "Status", type: "select", options: [["open","Aberto"],["communicating","Comunicando"],["recovering","Recuperando"],["closed","Fechado"]] },
        ] as Field[]}
        columns={[{ key: "code", label: "Código" }, { key: "recall_type", label: "Tipo" }, { key: "status", label: "Status" }] as Column[]} />}

      {tab === "CoA" && <CrudPanel table="certificates_of_analysis" title="Certificados de Análise (CoA)" rows={data.certificates_of_analysis}
        fields={[
          { key: "coa_number", label: "Nº do CoA" },
          { key: "product_id", label: "Produto", type: "fk", fkTable: "products" }, { key: "lot_id", label: "Lote", type: "fk", fkTable: "product_lots", fkLabel: "lot_number" },
          { key: "supplier_id", label: "Fornecedor", type: "fk", fkTable: "suppliers" }, { key: "issued_at", label: "Emitido em", type: "date" },
          { key: "url", label: "URL" }, { key: "approved", label: "Aprovado", type: "select", options: bool },
        ] as Field[]}
        columns={[{ key: "coa_number", label: "Nº" }, { key: "issued_at", label: "Emitido" }, { key: "approved", label: "Aprovado" }] as Column[]} />}
    </div>
  );
}

// Liberação de lote — usa a RPC release_batch (integra product_lots.quality_status)
function BatchRelease({ lots }: { lots: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);

  async function decide(lotId: string, decision: string) {
    if (!supabase) return;
    setBusy(lotId + decision); setErr(null);
    const { error } = await supabase.rpc("release_batch", { p_lot: lotId, p_decision: decision, p_notes: null });
    setBusy(null);
    if (error) { setErr(error.message); return; }
    router.refresh();
  }
  const badge = (s: string) => s === "released" ? "bg-green-500/15 text-green-500" : s === "blocked" ? "bg-red-500/15 text-red-500" : s === "quarantine" ? "bg-amber-500/15 text-amber-500" : "bg-slate-500/15 text-slate-400";

  return (
    <div className="space-y-2">
      <div className="font-semibold">Liberação de lote <span className="muted font-normal">({lots.length})</span></div>
      {err && <div className="text-sm text-red-500">{err}</div>}
      {lots.length === 0 ? <p className="text-sm muted">Nenhum lote cadastrado. Crie lotes no Cadastro Mestre (aba Lotes) ou na Produção.</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
              <th className="py-2 px-3">Lote</th><th className="px-3">Validade</th><th className="px-3">Status qualidade</th><th className="px-3 text-right">Decisão</th>
            </tr></thead>
            <tbody>
              {lots.map((l) => (
                <tr key={l.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-mono">{l.lot_number}</td>
                  <td className="px-3">{l.expiry_date ?? "—"}</td>
                  <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${badge(l.quality_status)}`}>{l.quality_status}</span></td>
                  <td className="px-3 text-right space-x-2">
                    <button onClick={() => decide(l.id, "released")} disabled={!!busy} className="text-xs text-green-500 hover:underline">Liberar</button>
                    <button onClick={() => decide(l.id, "quarantine")} disabled={!!busy} className="text-xs text-amber-500 hover:underline">Quarentena</button>
                    <button onClick={() => decide(l.id, "rejected")} disabled={!!busy} className="text-xs text-red-500 hover:underline">Rejeitar</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
