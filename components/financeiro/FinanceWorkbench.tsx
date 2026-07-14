"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import PayablesPanel from "./PayablesPanel";
import ReceivablesPanel from "./ReceivablesPanel";
import CashFlowPanel from "./CashFlowPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Contas a Pagar", "Contas a Receber", "Fluxo de Caixa", "Bancos & Caixa", "Centros de Custo"] as const;

export default function FinanceWorkbench({ data }: { data: any }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Contas a Pagar");
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
    </div>
  );
}
