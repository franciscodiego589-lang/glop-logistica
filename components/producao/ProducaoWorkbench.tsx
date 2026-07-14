"use client";
import { useState } from "react";
import ProducaoPanel from "./ProducaoPanel";
import UnitConverter from "./UnitConverter";
import LotTraceability from "./LotTraceability";

const TABS = ["Ordens de produção", "Ficha técnica / dosagem", "Rastreabilidade de lote"] as const;

export default function ProducaoWorkbench({ data }: { data: any }) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Ordens de produção");
  return (
    <div className="space-y-4">
      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Ordens de produção" && (
        <ProducaoPanel orders={data.orders} products={data.products} boms={data.boms} warehouses={data.warehouses} prodName={data.prodName} />
      )}
      {tab === "Ficha técnica / dosagem" && <UnitConverter />}
      {tab === "Rastreabilidade de lote" && <LotTraceability products={data.products} />}
    </div>
  );
}
