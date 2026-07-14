"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

const KIND: Record<string, { label: string; cls: string }> = {
  purchase: { label: "Comprar", cls: "bg-blue-500/15 text-blue-500" },
  production: { label: "Produzir", cls: "bg-indigo-500/15 text-indigo-500" },
  transfer: { label: "Transferir", cls: "bg-amber-500/15 text-amber-500" },
};

const TABS = ["Planejamento", "Estruturas (BOM)", "Centros de Trabalho"] as const;

export default function MrpWorkbench({ data }: { data: any }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Planejamento");
  const [horizon, setHorizon] = useState("90");
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const prodName: Record<string, string> = data.prodName;

  async function runMrp() {
    if (!supabase) return;
    setBusy(true); setMsg(null); setErr(null);
    const { error } = await supabase.rpc("run_mrp", { p_company: COMPANY, p_horizon_days: Number(horizon) || 90 });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setMsg("MRP executado ✓ — necessidades líquidas recalculadas.");
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

      {tab === "Planejamento" && (
        <div className="space-y-4">
          <div className="card p-4 flex flex-wrap gap-3 items-end">
            <div>
              <label className="text-xs font-semibold muted">Horizonte (dias)</label>
              <input type="number" value={horizon} onChange={(e) => setHorizon(e.target.value)}
                className="w-28 mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
            </div>
            <button onClick={runMrp} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Executando…" : "▶ Rodar MRP"}</button>
            <p className="text-xs muted flex-1 min-w-[220px]">Necessidade líquida = demanda prevista + estoque de segurança − saldo. Gera ordens planejadas (comprar / produzir).</p>
            {msg && <span className="text-sm text-green-500">{msg}</span>}
            {err && <span className="text-sm text-red-500">{err}</span>}
          </div>

          <div className="card p-4">
            <div className="font-semibold mb-3">Ordens planejadas <span className="muted font-normal">({data.planned.length})</span></div>
            {data.planned.length === 0 ? (
              <p className="text-sm muted">Nenhuma ordem planejada. Rode o MRP acima (precisa de previsões de demanda e saldos para gerar necessidades).</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead><tr className="text-left muted text-xs uppercase"><th className="py-1.5 pr-3">Produto</th><th className="pr-3">Ação</th><th className="pr-3">Qtd</th><th className="pr-3">Necessário até</th><th className="pr-3">Saldo</th><th className="pr-3">Necessidade líq.</th><th className="pr-3">Status</th></tr></thead>
                  <tbody>
                    {data.planned.map((o: any) => (
                      <tr key={o.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                        <td className="py-1.5 pr-3">{prodName[o.product_id] ?? "—"}</td>
                        <td className="pr-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${KIND[o.order_kind]?.cls ?? ""}`}>{KIND[o.order_kind]?.label ?? o.order_kind}</span></td>
                        <td className="pr-3 tabular-nums font-semibold">{o.quantity}</td>
                        <td className="pr-3">{o.need_date ?? "—"}</td>
                        <td className="pr-3 tabular-nums muted">{o.on_hand ?? "—"}</td>
                        <td className="pr-3 tabular-nums">{o.net_requirement ?? "—"}</td>
                        <td className="pr-3 muted text-xs">{o.status}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      )}

      {tab === "Estruturas (BOM)" && <BomPanel boms={data.boms} products={data.products} prodName={prodName} />}

      {tab === "Centros de Trabalho" && (
        <CrudPanel table="work_centers" title="Centros de trabalho" rows={data.workCenters}
          emptyHint="Cadastre centros de trabalho (capacidade/custo por hora) para roteiros e capacidade."
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "code", label: "Código" },
            { key: "capacity_per_hour", label: "Capacidade/h", type: "number" },
            { key: "hours_per_day", label: "Horas/dia", type: "number", default: "8" },
            { key: "cost_per_hour", label: "Custo/h (R$)", type: "number" },
            { key: "efficiency_percent", label: "Eficiência %", type: "number", default: "100" },
          ]}
          columns={[
            { key: "name", label: "Nome" }, { key: "code", label: "Código" },
            { key: "capacity_per_hour", label: "Cap./h" }, { key: "hours_per_day", label: "h/dia" },
            { key: "cost_per_hour", label: "Custo/h" }, { key: "efficiency_percent", label: "Efic.%" },
          ]} />
      )}
    </div>
  );
}

function BomPanel({ boms, products, prodName }: { boms: any[]; products: any[]; prodName: Record<string, string> }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ product_id: "", name: "", output_quantity: "1" });

  async function create() {
    if (!supabase) return;
    if (!f.product_id) { setErr("Escolha o produto acabado."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    const { data, error } = await supabase.from("bills_of_materials").insert({
      tenant_id, company_id: COMPANY, product_id: f.product_id,
      name: f.name.trim() || null, output_quantity: Number(f.output_quantity) || 1,
    }).select("id").single();
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.push(`/mrp/bom/${(data as any).id}`);
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Estruturas de produto (BOM) <span className="muted font-normal">({boms.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Nova BOM"}</button>
      </div>
      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Produto acabado *</label>
              <select value={f.product_id} onChange={(e) => setF({ ...f, product_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{products.map((p) => <option key={p.id} value={p.id}>{p.sku ? p.sku + " · " : ""}{p.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Nome / revisão</label>
              <input value={f.name} onChange={(e) => setF({ ...f, name: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Qtd produzida (base)</label>
              <input type="number" value={f.output_quantity} onChange={(e) => setF({ ...f, output_quantity: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Criando…" : "Criar e adicionar componentes"}</button>
        </div>
      )}
      {boms.length === 0 ? (
        <p className="text-sm muted px-1">Nenhuma BOM. Crie a estrutura de um produto acabado para produzi-lo com consumo automático de componentes.</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Produto</th><th className="px-3">Nome</th><th className="px-3">Base</th><th></th></tr></thead>
            <tbody>
              {boms.map((b) => (
                <tr key={b.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">{prodName[b.product_id] ?? "—"}</td>
                  <td className="px-3 muted">{b.name ?? "—"}</td>
                  <td className="px-3 tabular-nums">{b.output_quantity}</td>
                  <td className="px-3 text-right"><Link href={`/mrp/bom/${b.id}`} className="text-xs text-brand-500 hover:underline">abrir →</Link></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
