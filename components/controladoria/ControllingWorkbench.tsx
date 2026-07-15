"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (n: any) => (n == null ? "—" : Number(n).toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 }));
const pct = (n: any) => (n == null ? "—" : `${n}%`);

const TABS = ["Painel", "DRE Gerencial", "Margens", "Variações", "Centros de Lucro", "Objetos de Custo",
  "Lançamentos de Custo", "Custo Padrão", "Simulações"] as const;

export default function ControllingWorkbench({ dash, dre, variance, products, data }:
  { dash: any; dre: any; variance: any[]; products: any[]; data: Record<string, any[]> }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  async function runIA() {
    if (!supabase) return;
    setBusy(true); setMsg(null);
    const { data: n, error } = await supabase.rpc("controlling_insights", { p_company: COMPANY });
    setBusy(false);
    setMsg(error ? error.message : `IA da Controladoria: ${n ?? 0} produto(s) de baixa margem sinalizado(s) na LOGIA.`);
    router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">📊</div>
        <div>
          <h1 className="text-xl font-bold">Controladoria & Custos</h1>
          <p className="text-sm muted">Volume 12 · DRE gerencial, custos, margens, rateios, variações</p>
        </div>
      </div>

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="space-y-3">
          <div className="card p-3 flex items-center gap-3">
            <div className="text-sm"><b>✦ IA da Controladoria</b> <span className="muted">— sinaliza produtos com margem baixa e desperdícios.</span></div>
            <button onClick={runIA} disabled={busy} className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white font-semibold disabled:opacity-60">
              {busy ? "Analisando…" : "Analisar rentabilidade"}
            </button>
          </div>
          {msg && <div className="text-sm text-brand-500 px-1">{msg}</div>}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="Custo do mês" value={money(dash?.cost_month)} accent />
            <KpiCard label="Margem média" value={pct(dash?.avg_margin)} />
            <KpiCard label="Produtos baixa margem" value={dash?.low_margin ?? "—"} />
            <KpiCard label="Variação orçamentária" value={money(dash?.budget_variance)} />
            <KpiCard label="Centros de custo" value={dash?.cost_centers ?? "—"} />
            <KpiCard label="Centros de lucro" value={dash?.profit_centers ?? "—"} />
            <KpiCard label="Objetos de custo" value={dash?.cost_objects ?? "—"} />
          </div>
        </div>
      )}

      {tab === "DRE Gerencial" && (
        <div className="card p-5 max-w-xl">
          <div className="font-semibold mb-3">DRE Gerencial — {dre?.month ?? "mês atual"}</div>
          <table className="w-full text-sm">
            <tbody>
              <DreRow label="Receita" value={money(dre?.revenue)} bold />
              <DreRow label="(−) Custos (CMV/CPV)" value={money(dre?.cogs)} />
              <DreRow label="= Margem bruta" value={money(dre?.gross_margin)} bold hint={pct(dre?.gross_margin_pct)} />
              <DreRow label="(−) Despesas operacionais" value={money(dre?.opex)} />
              <DreRow label="= EBITDA" value={money(dre?.ebitda)} bold accent hint={pct(dre?.ebitda_pct)} />
            </tbody>
          </table>
          <p className="text-xs muted mt-3">Receita vem de contas a receber; custos dos lançamentos de custo; despesas de contas a pagar. Cada operação alimenta isto automaticamente.</p>
        </div>
      )}

      {tab === "Margens" && <MarginTable products={products} />}

      {tab === "Variações" && (
        <div className="space-y-2">
          <div className="font-semibold">Orçado × Realizado</div>
          {variance.length === 0 ? <p className="text-sm muted">Sem linhas de orçamento. Cadastre no Financeiro → Orçamento.</p> : (
            <div className="card p-0 overflow-x-auto">
              <table className="w-full text-sm">
                <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                  <th className="py-2 px-3">Categoria</th><th className="px-3 text-right">Orçado</th><th className="px-3 text-right">Realizado</th><th className="px-3 text-right">Variação</th><th className="px-3 text-right">%</th>
                </tr></thead>
                <tbody>
                  {variance.map((v, i) => (
                    <tr key={i} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                      <td className="py-2 px-3">{v.category}</td>
                      <td className="px-3 text-right">{money(v.planned)}</td>
                      <td className="px-3 text-right">{money(v.actual)}</td>
                      <td className={`px-3 text-right ${v.variance > 0 ? "text-red-500" : "text-green-500"}`}>{money(v.variance)}</td>
                      <td className="px-3 text-right">{v.variance_pct != null ? `${v.variance_pct}%` : "—"}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}

      {tab === "Centros de Lucro" && (
        <CrudPanel table="profit_centers" title="Centros de lucro" rows={data.profit_centers}
          emptyHint="Filiais, marcas, produtos, canais, franquias, projetos — para DRE por centro de lucro."
          fields={[
            { key: "name", label: "Nome", required: true }, { key: "code", label: "Código" },
            { key: "pc_type", label: "Tipo", type: "select", options: [["branch", "Filial"], ["brand", "Marca"], ["product", "Produto"], ["channel", "Canal"], ["franchise", "Franquia"], ["project", "Projeto"], ["unit", "Unidade"]], default: "unit" },
            { key: "responsible", label: "Responsável" }, { key: "parent_id", label: "Centro pai", type: "fk", fkTable: "profit_centers" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "name", label: "Nome" }, { key: "pc_type", label: "Tipo" }, { key: "responsible", label: "Responsável" }]} />
      )}

      {tab === "Objetos de Custo" && (
        <CrudPanel table="cost_objects" title="Objetos de custo" rows={data.cost_objects}
          emptyHint="Produtos, lotes, ordens de produção, serviços, procedimentos, projetos, clientes, contratos."
          fields={[
            { key: "object_type", label: "Tipo", type: "select", options: [["product", "Produto"], ["lot", "Lote"], ["production_order", "Ordem de produção"], ["service", "Serviço"], ["procedure", "Procedimento"], ["project", "Projeto"], ["customer", "Cliente"], ["contract", "Contrato"]], default: "product" },
            { key: "name", label: "Nome", required: true }, { key: "product_id", label: "Produto", type: "fk", fkTable: "products" }, { key: "code", label: "Código" },
          ]}
          columns={[{ key: "object_type", label: "Tipo" }, { key: "name", label: "Nome" }, { key: "code", label: "Código" }]} />
      )}

      {tab === "Lançamentos de Custo" && (
        <CrudPanel table="cost_entries" title="Lançamentos de custo" rows={data.cost_entries}
          emptyHint="Apropriação de custos por centro/objeto (material, mão de obra, energia, depreciação, CIF…)."
          fields={[
            { key: "cost_type", label: "Tipo de custo", type: "select", options: [["material", "Matéria-prima"], ["packaging", "Embalagem"], ["direct_labor", "MOD"], ["indirect_labor", "MOI"], ["energy", "Energia"], ["depreciation", "Depreciação"], ["maintenance", "Manutenção"], ["loss", "Perda"], ["scrap", "Refugo"], ["rework", "Retrabalho"], ["overhead", "CIF"], ["service", "Serviço"], ["other", "Outro"]], default: "material" },
            { key: "amount", label: "Valor (R$)", type: "number", required: true },
            { key: "cost_center_id", label: "Centro de custo", type: "fk", fkTable: "cost_centers" },
            { key: "product_id", label: "Produto", type: "fk", fkTable: "products" },
            { key: "method", label: "Método", type: "select", options: [["real", "Real"], ["standard", "Padrão"], ["absorption", "Absorção"], ["variable", "Variável"], ["abc", "ABC"]], default: "real" },
          ]}
          columns={[{ key: "cost_type", label: "Tipo" }, { key: "amount", label: "Valor", fmt: (v) => money(v) }, { key: "cost_center_id", label: "Centro" }, { key: "method", label: "Método" }, { key: "period_month", label: "Competência" }]} />
      )}

      {tab === "Custo Padrão" && (
        <CrudPanel table="standard_costs" title="Custo padrão por produto" rows={data.standard_costs}
          emptyHint="Componentes de custo padrão por produto (para comparar padrão × real)."
          fields={[
            { key: "product_id", label: "Produto", type: "fk", fkTable: "products", required: true },
            { key: "cost_type", label: "Tipo", type: "select", options: [["material", "Matéria-prima"], ["packaging", "Embalagem"], ["direct_labor", "MOD"], ["overhead", "CIF"], ["other", "Outro"]], default: "material" },
            { key: "amount_per_unit", label: "Custo/unidade", type: "number", required: true },
          ]}
          columns={[{ key: "product_id", label: "Produto" }, { key: "cost_type", label: "Tipo" }, { key: "amount_per_unit", label: "Custo/un" }]} />
      )}

      {tab === "Simulações" && (
        <CrudPanel table="cost_simulations" title="Simulações de cenário" rows={data.cost_simulations}
          emptyHint="Cenários: aumento de MP, câmbio, expansão, novos produtos, troca de fornecedor…"
          fields={[
            { key: "name", label: "Nome", required: true }, { key: "scenario", label: "Cenário" },
            { key: "status", label: "Status", type: "select", options: [["draft", "Rascunho"], ["running", "Rodando"], ["done", "Concluída"]], default: "draft" },
          ]}
          columns={[{ key: "name", label: "Nome" }, { key: "scenario", label: "Cenário" }, { key: "status", label: "Status" }]} />
      )}
    </div>
  );
}

function DreRow({ label, value, bold, accent, hint }: { label: string; value: string; bold?: boolean; accent?: boolean; hint?: string }) {
  return (
    <tr className={accent ? "text-brand-500" : ""}>
      <td className={`py-1.5 ${bold ? "font-semibold" : "muted"}`}>{label}</td>
      <td className={`py-1.5 text-right tabular-nums ${bold ? "font-semibold" : ""}`}>{value}{hint && <span className="text-xs muted ml-2">{hint}</span>}</td>
    </tr>
  );
}

function MarginTable({ products }: { products: any[] }) {
  const rows = products
    .filter((p) => p.sale_price)
    .map((p) => {
      const cost = p.cost_price ?? 0;
      const margin = p.sale_price > 0 ? ((p.sale_price - cost) / p.sale_price) * 100 : null;
      return { ...p, cost, margin };
    })
    .sort((a, b) => (a.margin ?? 999) - (b.margin ?? 999));
  return (
    <div className="space-y-2">
      <div className="font-semibold">Margem por produto (contribuição)</div>
      <div className="card p-0 overflow-x-auto">
        <table className="w-full text-sm">
          <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
            <th className="py-2 px-3">SKU</th><th className="px-3">Produto</th><th className="px-3 text-right">Custo</th><th className="px-3 text-right">Preço</th><th className="px-3 text-right">Contribuição</th><th className="px-3 text-right">Margem</th>
          </tr></thead>
          <tbody>
            {rows.length === 0 && <tr><td colSpan={6} className="px-4 py-8 text-center muted">Sem produtos com preço.</td></tr>}
            {rows.map((p) => (
              <tr key={p.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                <td className="py-2 px-3 font-mono text-xs">{p.sku ?? "—"}</td>
                <td className="px-3">{p.name}</td>
                <td className="px-3 text-right">{money(p.cost)}</td>
                <td className="px-3 text-right">{money(p.sale_price)}</td>
                <td className="px-3 text-right">{money(p.sale_price - p.cost)}</td>
                <td className="px-3 text-right"><span className={`font-semibold ${p.margin >= 40 ? "text-green-500" : p.margin >= 15 ? "text-amber-500" : "text-red-500"}`}>{p.margin != null ? p.margin.toFixed(1) + "%" : "—"}</span></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
