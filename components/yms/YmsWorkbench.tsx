"use client";
import { useState } from "react";
import CrudPanel from "@/components/ui/CrudPanel";
import AppointmentsPanel from "./AppointmentsPanel";
import YardPanel from "./YardPanel";

const TABS = ["Agendamentos", "Docas", "Pátio"] as const;

export default function YmsWorkbench({ data }: { data: any }) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Agendamentos");
  return (
    <div className="space-y-4">
      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>
      {tab === "Agendamentos" && <AppointmentsPanel appointments={data.appointments} docks={data.docks} />}
      {tab === "Docas" && (
        <CrudPanel table="docks" title="Docas" rows={data.docks}
          emptyHint="Cadastre as docas do armazém para agendar recebimentos e expedições."
          fields={[
            { key: "code", label: "Código", required: true },
            { key: "name", label: "Nome" },
            { key: "warehouse_id", label: "Armazém", type: "fk", fkTable: "warehouses", required: true },
            { key: "dock_type", label: "Tipo", type: "select", options: [["inbound", "Recebimento"], ["outbound", "Expedição"], ["both", "Ambos"]], default: "both" },
            { key: "status", label: "Status", type: "select", options: [["available", "Disponível"], ["occupied", "Ocupada"], ["blocked", "Bloqueada"], ["maintenance", "Manutenção"]], default: "available" },
          ]}
          columns={[
            { key: "code", label: "Código" }, { key: "name", label: "Nome" },
            { key: "warehouse_id", label: "Armazém", fmt: () => "" },
            { key: "dock_type", label: "Tipo" }, { key: "status", label: "Status" },
          ]} />
      )}
      {tab === "Pátio" && <YardPanel visits={data.visits} warehouses={data.warehouses} />}
    </div>
  );
}
