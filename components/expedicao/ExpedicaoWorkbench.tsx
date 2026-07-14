"use client";
import { useState } from "react";
import CrudPanel from "@/components/ui/CrudPanel";
import OutboundPanel from "./OutboundPanel";

const TABS = ["Pedidos", "Clientes"] as const;

export default function ExpedicaoWorkbench({ data }: { data: any }) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Pedidos");
  return (
    <div className="space-y-4">
      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>
      {tab === "Pedidos" && <OutboundPanel orders={data.orders} customers={data.customers} warehouses={data.warehouses} />}
      {tab === "Clientes" && (
        <CrudPanel table="customers" title="Clientes" rows={data.customers}
          emptyHint="Cadastre clientes para emitir pedidos de saída."
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "customer_type", label: "Tipo", type: "select", options: [["company", "Empresa"], ["person", "Pessoa"]], default: "company" },
            { key: "document", label: "CPF/CNPJ" },
            { key: "email", label: "E-mail" },
            { key: "phone", label: "Telefone" },
            { key: "city", label: "Cidade" },
            { key: "uf", label: "UF" },
            { key: "credit_limit", label: "Limite de crédito", type: "number" },
          ]}
          columns={[
            { key: "name", label: "Nome" }, { key: "document", label: "Doc" },
            { key: "city", label: "Cidade" }, { key: "uf", label: "UF" }, { key: "phone", label: "Telefone" },
          ]} />
      )}
    </div>
  );
}
