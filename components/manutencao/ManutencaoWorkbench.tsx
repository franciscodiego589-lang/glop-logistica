"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import WorkOrdersPanel from "./WorkOrdersPanel";
import { WO_TYPE } from "./shared";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Ordens de serviço", "Ativos", "Planos preventivos", "Falhas", "Leituras"] as const;

export default function ManutencaoWorkbench({ data }: { data: any }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Ordens de serviço");
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  async function generate() {
    if (!supabase) return;
    setBusy(true); setMsg(null);
    const { data: n, error } = await supabase.rpc("generate_preventive_wos", { p_company: COMPANY });
    setBusy(false);
    setMsg(error ? error.message : `${n} OS preventiva(s) geradas dos planos vencidos ✓`);
    if (!error) router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Ordens de serviço" && <WorkOrdersPanel workOrders={data.workOrders} assets={data.assets} />}

      {tab === "Ativos" && (
        <CrudPanel table="assets" title="Ativos" rows={data.assets}
          emptyHint="Cadastre os ativos (equipamentos, linhas, instrumentos). Use 'Ativo pai' para montar a hierarquia planta→área→linha→equipamento."
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "code", label: "Cód. patrimonial" },
            { key: "asset_type", label: "Tipo", placeholder: "encapsuladora, motor…" },
            { key: "criticality", label: "Criticidade", type: "select", options: [["low", "Baixa"], ["medium", "Média"], ["high", "Alta"], ["critical", "Crítica"]], default: "medium" },
            { key: "status", label: "Status", type: "select", options: [["operational", "Operacional"], ["standby", "Standby"], ["down", "Parado"], ["maintenance", "Manutenção"], ["retired", "Baixado"]], default: "operational" },
            { key: "parent_id", label: "Ativo pai", type: "fk", fkTable: "assets" },
            { key: "equipment_id", label: "Equipamento (MES)", type: "fk", fkTable: "equipment" },
            { key: "manufacturer", label: "Fabricante" },
            { key: "model", label: "Modelo" },
            { key: "serial_number", label: "Nº série" },
            { key: "location", label: "Localização" },
            { key: "cost_center", label: "Centro de custo" },
            { key: "responsible", label: "Responsável" },
            { key: "install_date", label: "Instalação", type: "date" },
            { key: "warranty_until", label: "Garantia até", type: "date" },
            { key: "acquisition_value", label: "Valor aquisição", type: "number" },
          ]}
          columns={[
            { key: "code", label: "Patrimônio" }, { key: "name", label: "Nome" }, { key: "asset_type", label: "Tipo" },
            { key: "criticality", label: "Criticidade" }, { key: "location", label: "Local" }, { key: "status", label: "Status" },
          ]} />
      )}

      {tab === "Planos preventivos" && (
        <div className="space-y-3">
          <div className="card p-4 flex flex-wrap gap-3 items-center">
            <div className="font-semibold">Planos preventivos</div>
            <button onClick={generate} disabled={busy} className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold disabled:opacity-60">{busy ? "Gerando…" : "⚙ Gerar OS dos planos vencidos"}</button>
            {msg && <span className="text-sm text-green-500">{msg}</span>}
          </div>
          <CrudPanel table="maintenance_plans" title="Planos" rows={data.plans}
            emptyHint="Crie planos preventivos (por calendário/horas). 'Próxima data' vencida gera OS no botão acima."
            fields={[
              { key: "name", label: "Nome", required: true },
              { key: "code", label: "Código" },
              { key: "asset_id", label: "Ativo", type: "fk", fkTable: "assets" },
              { key: "wo_type", label: "Tipo de OS", type: "select", options: WO_TYPE, default: "preventive" },
              { key: "trigger", label: "Gatilho", type: "select", options: [["calendar", "Calendário"], ["hours", "Horas"], ["production", "Produção"], ["cycles", "Ciclos"], ["km", "KM"], ["condition", "Condição"]], default: "calendar" },
              { key: "interval_value", label: "Intervalo (dias)", type: "number" },
              { key: "next_due", label: "Próxima data", type: "date" },
              { key: "task", label: "Tarefa" },
              { key: "responsible", label: "Responsável" },
            ]}
            columns={[
              { key: "code", label: "Código" }, { key: "name", label: "Nome" },
              { key: "asset_id", label: "Ativo", fmt: () => "" },
              { key: "trigger", label: "Gatilho" }, { key: "interval_value", label: "Intervalo" }, { key: "next_due", label: "Próxima" },
            ]} />
        </div>
      )}

      {tab === "Falhas" && (
        <CrudPanel table="asset_failures" title="Histórico de falhas" rows={data.failures}
          emptyHint="Registro de falhas com causa raiz (RCA). Também alimentadas pelas ordens de serviço corretivas."
          fields={[
            { key: "asset_id", label: "Ativo", type: "fk", fkTable: "assets", required: true },
            { key: "failure_type", label: "Tipo de falha" },
            { key: "severity", label: "Severidade", type: "select", options: [["low", "Baixa"], ["medium", "Média"], ["high", "Alta"], ["critical", "Crítica"]], default: "medium" },
            { key: "cause", label: "Causa" },
            { key: "root_cause", label: "Causa raiz" },
            { key: "rca_method", label: "Método RCA", type: "select", options: [["5whys", "5 Porquês"], ["ishikawa", "Ishikawa"], ["fmea", "FMEA"], ["rca", "RCA"]] },
            { key: "downtime_minutes", label: "Parada (min)", type: "number" },
          ]}
          columns={[
            { key: "asset_id", label: "Ativo", fmt: () => "" }, { key: "failure_type", label: "Falha" },
            { key: "severity", label: "Severidade" }, { key: "root_cause", label: "Causa raiz" }, { key: "downtime_minutes", label: "Parada (min)" },
          ]} />
      )}

      {tab === "Leituras" && (
        <CrudPanel table="asset_readings" title="Leituras preditivas (IIoT)" rows={data.readings}
          emptyHint="Leituras de condição (vibração, temperatura, corrente…) com limites. Fora do limite = alerta."
          fields={[
            { key: "asset_id", label: "Ativo", type: "fk", fkTable: "assets", required: true },
            { key: "parameter", label: "Parâmetro", required: true, placeholder: "vibração, temperatura…" },
            { key: "value", label: "Valor", type: "number", required: true },
            { key: "unit", label: "Unidade" },
            { key: "min_limit", label: "Limite mín", type: "number" },
            { key: "max_limit", label: "Limite máx", type: "number" },
          ]}
          columns={[
            { key: "asset_id", label: "Ativo", fmt: () => "" }, { key: "parameter", label: "Parâmetro" },
            { key: "value", label: "Valor" }, { key: "unit", label: "Un." },
            { key: "out_of_range", label: "Fora?", fmt: (v) => v ? "⚠ sim" : "não" },
          ]} />
      )}
    </div>
  );
}
