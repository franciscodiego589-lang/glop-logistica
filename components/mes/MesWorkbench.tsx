"use client";
import { useState } from "react";
import CrudPanel from "@/components/ui/CrudPanel";
import ShopFloorPanel from "./ShopFloorPanel";
import AppointmentsPanel from "./AppointmentsPanel";
import DowntimesPanel from "./DowntimesPanel";
import ReadingsPanel from "./ReadingsPanel";

const TABS = ["Chão de fábrica", "Apontamentos", "Paradas", "Processo", "Equipamentos"] as const;

export default function MesWorkbench({ data }: { data: any }) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Chão de fábrica");
  return (
    <div className="space-y-4">
      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Chão de fábrica" && <ShopFloorPanel equipment={data.equipment} />}
      {tab === "Apontamentos" && <AppointmentsPanel appointments={data.appointments} orders={data.orders} equipment={data.equipment} orderCode={data.orderCode} />}
      {tab === "Paradas" && <DowntimesPanel downtimes={data.downtimes} equipment={data.equipment} orders={data.orders} />}
      {tab === "Processo" && <ReadingsPanel readings={data.readings} equipment={data.equipment} />}
      {tab === "Equipamentos" && (
        <CrudPanel table="equipment" title="Equipamentos" rows={data.equipment}
          emptyHint="Cadastre as máquinas do chão de fábrica (misturadores, encapsuladoras, envasadoras…)."
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "code", label: "Código" },
            { key: "equipment_type", label: "Tipo", placeholder: "encapsuladora, envasadora…" },
            { key: "manufacturer", label: "Fabricante" },
            { key: "model", label: "Modelo" },
            { key: "work_center_id", label: "Centro de trabalho", type: "fk", fkTable: "work_centers" },
            { key: "capacity_per_hour", label: "Capacidade/hora", type: "number" },
            { key: "status", label: "Status", type: "select", options: [["operational", "Operacional"], ["running", "Produzindo"], ["idle", "Ocioso"], ["setup", "Setup"], ["down", "Parado"], ["maintenance", "Manutenção"], ["inactive", "Inativo"]], default: "operational" },
          ]}
          columns={[
            { key: "code", label: "Código" }, { key: "name", label: "Nome" }, { key: "equipment_type", label: "Tipo" },
            { key: "work_center_id", label: "Centro", fmt: () => "" },
            { key: "capacity_per_hour", label: "Cap./h" }, { key: "status", label: "Status" },
          ]} />
      )}
    </div>
  );
}
