"use client";
import { useMemo } from "react";
import Link from "next/link";
import { reasonLabel } from "@/components/mes/shared";
import { PROD_STATUS } from "@/components/producao/ProducaoPanel";

type Order = { id: string; code: string | null; status: string; product_id: string; planned_quantity: number; produced_quantity: number };
type Downtime = { reason: string; minutes: number | null };

export default function ManufaturaCockpit({ wipOrders, downtimes, prodName }: {
  wipOrders: Order[]; downtimes: Downtime[]; prodName: Record<string, string>;
}) {
  const losses = useMemo(() => {
    const m: Record<string, number> = {};
    for (const d of downtimes) m[d.reason] = (m[d.reason] ?? 0) + (Number(d.minutes) || 0);
    return Object.entries(m).sort((a, b) => b[1] - a[1]);
  }, [downtimes]);
  const totalLoss = losses.reduce((a, [, m]) => a + m, 0);

  return (
    <div className="space-y-4">
      <div className="grid lg:grid-cols-2 gap-4">
        {/* WIP */}
        <div className="card p-4">
          <div className="flex items-center gap-2 mb-3">
            <div className="font-semibold">Produção em andamento (WIP)</div>
            <Link href="/producao" className="ml-auto text-xs text-brand-500 hover:underline">ver ordens →</Link>
          </div>
          {wipOrders.length === 0 ? (
            <p className="text-sm muted">Nenhuma ordem em andamento.</p>
          ) : (
            <div className="space-y-2">
              {wipOrders.slice(0, 8).map((o) => {
                const pct = o.planned_quantity > 0 ? Math.min(Math.round((o.produced_quantity / o.planned_quantity) * 100), 100) : 0;
                return (
                  <Link key={o.id} href={`/producao/op/${o.id}`} className="block">
                    <div className="flex items-center gap-2 text-sm">
                      <span className="font-mono">{o.code ?? o.id.slice(0, 8)}</span>
                      <span className="muted truncate flex-1">{prodName[o.product_id] ?? "—"}</span>
                      <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${PROD_STATUS[o.status]?.cls ?? ""}`}>{PROD_STATUS[o.status]?.label ?? o.status}</span>
                    </div>
                    <div className="h-1.5 rounded-full bg-black/10 dark:bg-white/10 overflow-hidden mt-1"><div className="h-full bg-brand-500" style={{ width: `${pct}%` }} /></div>
                  </Link>
                );
              })}
            </div>
          )}
        </div>

        {/* Perdas por categoria */}
        <div className="card p-4">
          <div className="flex items-center gap-2 mb-3">
            <div className="font-semibold">Perdas por categoria (min)</div>
            <Link href="/mes" className="ml-auto text-xs text-brand-500 hover:underline">chão de fábrica →</Link>
          </div>
          {losses.length === 0 ? (
            <p className="text-sm muted">Nenhuma parada registrada.</p>
          ) : (
            <div className="space-y-2">
              {losses.map(([reason, min]) => (
                <div key={reason}>
                  <div className="flex justify-between text-xs mb-1"><span>{reasonLabel(reason)}</span><b className="tabular-nums">{Math.round(min)}min</b></div>
                  <div className="h-2 rounded-full bg-black/10 dark:bg-white/10 overflow-hidden"><div className="h-full bg-red-500" style={{ width: `${totalLoss > 0 ? (min / totalLoss) * 100 : 0}%` }} /></div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      <div className="grid sm:grid-cols-3 gap-3">
        <Link href="/mrp" className="card p-4 hover:ring-1 hover:ring-brand-500/40"><div className="text-2xl mb-1">⚙</div><div className="font-semibold text-sm">MRP / Estruturas</div><div className="text-xs muted">necessidades, BOM, capacidade</div></Link>
        <Link href="/producao" className="card p-4 hover:ring-1 hover:ring-brand-500/40"><div className="text-2xl mb-1">🏭</div><div className="font-semibold text-sm">Produção / PCP</div><div className="text-xs muted">ordens, operações, finalizar</div></Link>
        <Link href="/mes" className="card p-4 hover:ring-1 hover:ring-brand-500/40"><div className="text-2xl mb-1">🕹</div><div className="font-semibold text-sm">MES / Chão de fábrica</div><div className="text-xs muted">apontamentos, paradas, OEE</div></Link>
      </div>
    </div>
  );
}
