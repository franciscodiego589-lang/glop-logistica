"use client";
import { useState } from "react";
import CrudPanel from "@/components/ui/CrudPanel";
import PurchaseOrdersPanel from "./PurchaseOrdersPanel";
import RequisitionsPanel from "./RequisitionsPanel";
import RfqPanel from "./RfqPanel";

const TABS = ["Pedidos", "Requisições", "RFQ / Cotações", "Fornecedores (SRM)"] as const;

export default function ComprasWorkbench({ data }: { data: any }) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Pedidos");
  return (
    <div className="space-y-4">
      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Pedidos" && <PurchaseOrdersPanel pos={data.pos} suppliers={data.suppliers} warehouses={data.warehouses} />}
      {tab === "Requisições" && <RequisitionsPanel reqs={data.reqs} warehouses={data.warehouses} />}
      {tab === "RFQ / Cotações" && <RfqPanel rfqs={data.rfqs} />}
      {tab === "Fornecedores (SRM)" && (
        <CrudPanel table="suppliers" title="Fornecedores" rows={data.suppliers}
          emptyHint="Cadastre fornecedores para requisitar, cotar e emitir pedidos."
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "legal_name", label: "Razão social" },
            { key: "document", label: "CNPJ" },
            { key: "contact_name", label: "Contato" },
            { key: "phone", label: "Telefone" },
            { key: "email", label: "E-mail" },
            { key: "lead_time_days", label: "Lead time (dias)", type: "number" },
            { key: "rating", label: "Score (0-5)", type: "number" },
          ]}
          columns={[
            { key: "name", label: "Nome" }, { key: "document", label: "CNPJ" },
            { key: "contact_name", label: "Contato" }, { key: "phone", label: "Telefone" },
            { key: "lead_time_days", label: "Lead (d)" }, { key: "rating", label: "Score" },
          ]} />
      )}
    </div>
  );
}
