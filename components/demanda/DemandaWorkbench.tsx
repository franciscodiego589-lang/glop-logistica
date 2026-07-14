"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Previsões", "Histórico"] as const;

export default function DemandaWorkbench({ data }: { data: any }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Previsões");
  const prodName: Record<string, string> = data.prodName;

  const [g, setG] = useState({ product_id: "", warehouse_id: "", window: "3", horizon: "6" });
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);

  async function generate() {
    if (!supabase) return;
    if (!g.product_id) { setErr("Escolha o produto."); return; }
    setBusy(true); setErr(null); setMsg(null);
    const { data: res, error } = await supabase.rpc("forecast_moving_average", {
      p_product: g.product_id, p_warehouse: g.warehouse_id || null,
      p_window: Number(g.window) || 3, p_horizon: Number(g.horizon) || 6,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setMsg(`${res} período(s) previsto(s) por média móvel ✓`);
    router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Previsões" && (
        <div className="space-y-4">
          <div className="card p-4 space-y-3">
            <div className="font-semibold">Gerar previsão (média móvel)</div>
            <div className="grid md:grid-cols-5 gap-3 items-end">
              <div className="md:col-span-2"><label className="text-xs font-semibold muted">Produto *</label>
                <select value={g.product_id} onChange={(e) => setG({ ...g, product_id: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                  <option value="">—</option>{data.products.map((p: any) => <option key={p.id} value={p.id}>{p.sku ? p.sku + " · " : ""}{p.name}</option>)}
                </select></div>
              <div><label className="text-xs font-semibold muted">Armazém</label>
                <select value={g.warehouse_id} onChange={(e) => setG({ ...g, warehouse_id: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                  <option value="">Todos</option>{data.warehouses.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}
                </select></div>
              <div><label className="text-xs font-semibold muted">Janela (meses)</label>
                <input type="number" value={g.window} onChange={(e) => setG({ ...g, window: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div className="flex gap-2 items-end">
                <div className="flex-1"><label className="text-xs font-semibold muted">Horizonte</label>
                  <input type="number" value={g.horizon} onChange={(e) => setG({ ...g, horizon: e.target.value })}
                    className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
                <button onClick={generate} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">▶ Prever</button>
              </div>
            </div>
            {msg && <div className="text-sm text-green-500">{msg}</div>}
            {err && <div className="text-sm text-red-500">{err}</div>}
          </div>

          <div className="card p-4">
            <div className="font-semibold mb-3">Previsões geradas ({data.forecasts.length})</div>
            {data.forecasts.length === 0 ? (
              <p className="text-sm muted">Nenhuma previsão ainda. Registre histórico (aba Histórico) e gere a previsão acima. O MRP consome estas previsões como demanda.</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead><tr className="text-left muted text-xs uppercase"><th className="py-1.5 pr-3">Produto</th><th className="pr-3">Mês</th><th className="pr-3">Método</th><th className="pr-3">Previsto</th></tr></thead>
                  <tbody>
                    {data.forecasts.map((fc: any) => (
                      <tr key={fc.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                        <td className="py-1.5 pr-3">{prodName[fc.product_id] ?? "—"}</td>
                        <td className="pr-3">{fc.period_month}</td>
                        <td className="pr-3 muted text-xs">{fc.method}</td>
                        <td className="pr-3 tabular-nums font-semibold">{fc.forecast_quantity}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      )}

      {tab === "Histórico" && (
        <CrudPanel table="demand_history" title="Histórico de demanda" rows={data.history}
          emptyHint="Registre a demanda realizada por mês para alimentar a previsão. Use o 1º dia do mês na data."
          fields={[
            { key: "product_id", label: "Produto", type: "fk", fkTable: "products", required: true },
            { key: "warehouse_id", label: "Armazém", type: "fk", fkTable: "warehouses" },
            { key: "period_month", label: "Mês (1º dia)", type: "date", required: true },
            { key: "quantity", label: "Quantidade", type: "number", required: true },
            { key: "channel", label: "Canal" },
            { key: "revenue", label: "Receita (R$)", type: "number" },
          ]}
          columns={[
            { key: "product_id", label: "Produto", fmt: () => "" },
            { key: "period_month", label: "Mês" }, { key: "quantity", label: "Qtd" },
            { key: "channel", label: "Canal" }, { key: "revenue", label: "Receita" },
          ]} />
      )}
    </div>
  );
}
