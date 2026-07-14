"use client";
import { useState } from "react";
import TransfersPanel from "./TransfersPanel";
import DeliveriesPanel from "./DeliveriesPanel";

const TABS = ["Transferências", "Entregas"] as const;

export default function DistribuicaoWorkbench({ data }: { data: any }) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Transferências");
  return (
    <div className="space-y-4">
      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>
      {tab === "Transferências" && <TransfersPanel transfers={data.transfers} warehouses={data.warehouses} />}
      {tab === "Entregas" && <DeliveriesPanel deliveries={data.deliveries} customers={data.customers} />}
    </div>
  );
}
