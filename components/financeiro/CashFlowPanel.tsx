"use client";
import { useMemo } from "react";
import { money } from "./shared";

type Doc = { amount: number; paid_amount?: number; received_amount?: number; status: string; due_date: string | null };

export default function CashFlowPanel({ payables, receivables, cashPosition }: {
  payables: Doc[]; receivables: Doc[]; cashPosition: number;
}) {
  const rows = useMemo(() => {
    const map: Record<string, { inflow: number; outflow: number }> = {};
    const add = (m: string, k: "inflow" | "outflow", v: number) => { (map[m] ??= { inflow: 0, outflow: 0 })[k] += v; };
    for (const p of payables) {
      if (p.status === "paid" || p.status === "canceled") continue;
      const rem = p.amount - (p.paid_amount ?? 0);
      if (rem > 0) add((p.due_date ?? "sem-data").slice(0, 7), "outflow", rem);
    }
    for (const r of receivables) {
      if (r.status === "paid" || r.status === "canceled") continue;
      const rem = r.amount - (r.received_amount ?? 0);
      if (rem > 0) add((r.due_date ?? "sem-data").slice(0, 7), "inflow", rem);
    }
    const months = Object.keys(map).sort();
    let acc = cashPosition;
    return months.map((m) => {
      const net = map[m]!.inflow - map[m]!.outflow;
      acc += net;
      return { month: m, inflow: map[m]!.inflow, outflow: map[m]!.outflow, net, acc };
    });
  }, [payables, receivables, cashPosition]);

  return (
    <div className="space-y-3">
      <div className="card p-4 flex items-center gap-3">
        <div className="text-xs muted">Posição de caixa atual (bancos)</div>
        <div className="text-xl font-bold tabular-nums">{money(cashPosition)}</div>
      </div>
      <div className="card p-4">
        <div className="font-semibold mb-3">Projeção de fluxo de caixa (por vencimento)</div>
        {rows.length === 0 ? (
          <p className="text-sm muted">Sem títulos em aberto. Gere contas a pagar/receber (sincronizar de operações) para projetar.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase"><th className="py-1.5 pr-3">Mês</th><th className="pr-3 text-right">Entradas</th><th className="pr-3 text-right">Saídas</th><th className="pr-3 text-right">Saldo do mês</th><th className="pr-3 text-right">Acumulado</th></tr></thead>
              <tbody>
                {rows.map((r) => (
                  <tr key={r.month} className="border-t" style={{ borderColor: "var(--border)" }}>
                    <td className="py-1.5 pr-3 font-mono">{r.month}</td>
                    <td className="pr-3 text-right tabular-nums text-green-500">{money(r.inflow)}</td>
                    <td className="pr-3 text-right tabular-nums text-red-500">{money(r.outflow)}</td>
                    <td className={`pr-3 text-right tabular-nums font-semibold ${r.net < 0 ? "text-red-500" : "text-green-500"}`}>{money(r.net)}</td>
                    <td className={`pr-3 text-right tabular-nums font-bold ${r.acc < 0 ? "text-red-500" : ""}`}>{money(r.acc)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
