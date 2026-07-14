"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import PayablesPanel from "./PayablesPanel";
import ReceivablesPanel from "./ReceivablesPanel";
import CashFlowPanel from "./CashFlowPanel";
import { FinancePanel, ReconcilePanel, CreditPanel, ConsolidatedPanel } from "./FinanceAdvanced";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Contas a Pagar", "Contas a Receber", "Fluxo de Caixa", "Tesouraria", "Conciliação",
  "Crédito", "Cobrança", "Rateios", "Orçamento", "Bancos & Caixa", "Centros de Custo", "Consolidado"] as const;

export default function FinanceWorkbench({ data }: { data: any }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  async function sync() {
    if (!supabase) return;
    setBusy(true); setMsg(null);
    const { data: r, error } = await supabase.rpc("sync_financial_documents", { p_company: COMPANY });
    setBusy(false);
    if (error) { setMsg(error.message); return; }
    setMsg(`${r?.payables_created ?? 0} conta(s) a pagar e ${r?.receivables_created ?? 0} a receber geradas das operações ✓`);
    router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="card p-4 flex flex-wrap gap-3 items-center">
        <div className="font-semibold">Integração automática</div>
        <button onClick={sync} disabled={busy} className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold disabled:opacity-60">
          {busy ? "Sincronizando…" : "⚡ Sincronizar de operações (compras → pagar · expedição → receber)"}</button>
        {msg && <span className="text-sm text-green-500">{msg}</span>}
      </div>

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Contas a Pagar" && <PayablesPanel payables={data.payables} suppliers={data.suppliers} banks={data.banks} costCenters={data.costCenters} />}
      {tab === "Contas a Receber" && <ReceivablesPanel receivables={data.receivables} customers={data.customers} banks={data.banks} costCenters={data.costCenters} />}
      {tab === "Fluxo de Caixa" && <CashFlowPanel payables={data.payables} receivables={data.receivables} cashPosition={data.cashPosition} />}
      {tab === "Bancos & Caixa" && (
        <CrudPanel table="bank_accounts" title="Contas bancárias & caixa" rows={data.banks}
          emptyHint="Cadastre bancos, contas correntes, contas digitais e caixa. O saldo é atualizado nas baixas."
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "bank_name", label: "Banco" },
            { key: "account_type", label: "Tipo", type: "select", options: [["checking", "Conta corrente"], ["savings", "Poupança"], ["digital", "Digital"], ["cash", "Caixa"], ["investment", "Investimento"]], default: "checking" },
            { key: "agency", label: "Agência" },
            { key: "account_number", label: "Conta" },
            { key: "pix_key", label: "Chave PIX" },
            { key: "current_balance", label: "Saldo atual", type: "number", default: "0" },
          ]}
          columns={[
            { key: "name", label: "Nome" }, { key: "bank_name", label: "Banco" }, { key: "account_type", label: "Tipo" },
            { key: "account_number", label: "Conta" }, { key: "current_balance", label: "Saldo" },
          ]} />
      )}
      {tab === "Centros de Custo" && (
        <CrudPanel table="cost_centers" title="Centros de custo" rows={data.costCenters}
          emptyHint="Estruture os centros de custo (fábrica, departamento, projeto, filial, linha)."
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "code", label: "Código" },
            { key: "cc_type", label: "Tipo", type: "select", options: [["factory", "Fábrica"], ["department", "Departamento"], ["project", "Projeto"], ["branch", "Filial"], ["line", "Linha"]], default: "department" },
            { key: "parent_id", label: "Centro pai", type: "fk", fkTable: "cost_centers" },
          ]}
          columns={[
            { key: "code", label: "Código" }, { key: "name", label: "Nome" }, { key: "cc_type", label: "Tipo" },
          ]} />
      )}

      {tab === "Painel" && <FinancePanel fin={data.fin} forecast={data.forecast} />}
      {tab === "Conciliação" && <ReconcilePanel statements={data.statements} />}
      {tab === "Crédito" && <CreditPanel credit={data.credit} customers={data.customers} />}
      {tab === "Consolidado" && <ConsolidatedPanel c={data.consolidated} />}

      {tab === "Tesouraria" && (
        <CrudPanel table="treasury_positions" title="Tesouraria — investimentos, empréstimos e financiamentos" rows={data.treasury}
          emptyHint="Cadastre aplicações, empréstimos e financiamentos (com taxa, vencimento e saldo)."
          fields={[
            { key: "kind", label: "Tipo", type: "select", options: [["investment", "Investimento"], ["loan", "Empréstimo"], ["financing", "Financiamento"]], default: "investment" },
            { key: "description", label: "Descrição", required: true },
            { key: "institution", label: "Instituição" },
            { key: "bank_account_id", label: "Conta", type: "fk", fkTable: "bank_accounts" },
            { key: "principal", label: "Principal (R$)", type: "number" },
            { key: "rate_percent", label: "Taxa %", type: "number" },
            { key: "start_date", label: "Início", type: "date" },
            { key: "maturity_date", label: "Vencimento", type: "date" },
            { key: "current_value", label: "Valor atual", type: "number" },
            { key: "outstanding", label: "Saldo devedor", type: "number" },
          ]}
          columns={[{ key: "kind", label: "Tipo" }, { key: "description", label: "Descrição" }, { key: "institution", label: "Instituição" }, { key: "principal", label: "Principal" }, { key: "maturity_date", label: "Vencimento" }]} />
      )}

      {tab === "Cobrança" && (
        <CrudPanel table="dunning_rules" title="Régua de cobrança" rows={data.dunning}
          emptyHint="Defina as etapas da cobrança por dias de atraso (e-mail, SMS, WhatsApp, ligação)."
          fields={[
            { key: "name", label: "Etapa", required: true },
            { key: "days_overdue", label: "Dias de atraso", type: "number" },
            { key: "channel", label: "Canal", type: "select", options: [["email", "E-mail"], ["sms", "SMS"], ["whatsapp", "WhatsApp"], ["call", "Ligação"], ["letter", "Carta"]], default: "email" },
            { key: "action", label: "Ação" },
            { key: "sequence", label: "Ordem", type: "number" },
          ]}
          columns={[{ key: "sequence", label: "Ordem" }, { key: "name", label: "Etapa" }, { key: "days_overdue", label: "Dias" }, { key: "channel", label: "Canal" }]} />
      )}

      {tab === "Rateios" && (
        <CrudPanel table="allocation_rules" title="Rateios (alocação de custos)" rows={data.allocations}
          emptyHint="Crie regras de rateio (por percentual, receita, headcount, horas, produção...)."
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "basis", label: "Base", type: "select", options: [["percent", "Percentual"], ["revenue", "Receita"], ["headcount", "Headcount"], ["hours", "Horas"], ["production", "Produção"], ["consumption", "Consumo"], ["area", "Área"]], default: "percent" },
            { key: "source_cost_center_id", label: "CC origem", type: "fk", fkTable: "cost_centers" },
            { key: "notes", label: "Observações" },
          ]}
          columns={[{ key: "name", label: "Nome" }, { key: "basis", label: "Base" }]} />
      )}

      {tab === "Orçamento" && (
        <CrudPanel table="financial_budgets" title="Orçamento (Budget)" rows={data.budgets}
          emptyHint="Planeje orçamentos anuais/trimestrais e acompanhe previsto × realizado."
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "year", label: "Ano", type: "number" },
            { key: "period", label: "Período", type: "select", options: [["annual", "Anual"], ["quarterly", "Trimestral"], ["monthly", "Mensal"]], default: "annual" },
            { key: "status", label: "Status", type: "select", options: [["draft", "Rascunho"], ["active", "Ativo"], ["closed", "Fechado"]], default: "draft" },
          ]}
          columns={[{ key: "name", label: "Nome" }, { key: "year", label: "Ano" }, { key: "period", label: "Período" }, { key: "status", label: "Status" }]} />
      )}
    </div>
  );
}
