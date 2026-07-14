"use client";
import { useState } from "react";
import CrudPanel from "@/components/ui/CrudPanel";
import LotTraceability from "@/components/producao/LotTraceability";
import ManufaturaCockpit from "./ManufaturaCockpit";
import RecipesPanel from "./RecipesPanel";

const TABS = ["Cockpit", "Receitas & Fórmulas", "Linhas de produção", "Rastreabilidade"] as const;

export default function ManufaturaWorkbench({ data }: { data: any }) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Cockpit");
  return (
    <div className="space-y-4">
      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Cockpit" && <ManufaturaCockpit wipOrders={data.wipOrders} downtimes={data.downtimes} prodName={data.prodName} />}
      {tab === "Receitas & Fórmulas" && <RecipesPanel boms={data.boms} prodName={data.prodName} revisionsByBom={data.revisionsByBom} />}
      {tab === "Linhas de produção" && (
        <CrudPanel table="production_lines" title="Linhas de produção" rows={data.lines}
          emptyHint="Cadastre as linhas produtivas (capacidade, OEE-alvo, turnos)."
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "code", label: "Código" },
            { key: "line_type", label: "Tipo", type: "select", options: [["discreta", "Discreta"], ["continua", "Contínua"], ["batelada", "Batelada"], ["processo", "Processo"]] },
            { key: "work_center_id", label: "Centro de trabalho", type: "fk", fkTable: "work_centers" },
            { key: "capacity_per_hour", label: "Capacidade/hora", type: "number" },
            { key: "oee_target", label: "OEE-alvo (%)", type: "number" },
            { key: "setup_minutes", label: "Setup (min)", type: "number" },
            { key: "responsible", label: "Responsável" },
            { key: "shift_pattern", label: "Turnos", placeholder: "1º/2º/3º" },
          ]}
          columns={[
            { key: "code", label: "Código" }, { key: "name", label: "Nome" }, { key: "line_type", label: "Tipo" },
            { key: "work_center_id", label: "Centro", fmt: () => "" },
            { key: "capacity_per_hour", label: "Cap./h" }, { key: "oee_target", label: "OEE-alvo" }, { key: "responsible", label: "Responsável" },
          ]} />
      )}
      {tab === "Rastreabilidade" && <LotTraceability products={data.products} />}
    </div>
  );
}
