"use client";
import { useState } from "react";
import Link from "next/link";
import CrudPanel from "@/components/ui/CrudPanel";

const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const dt = (v: any) => (v ? new Date(v + "T00:00:00").toLocaleDateString("pt-BR") : "—");
const CATEGORIAS: [string, string][] = [["marketing", "Marketing"], ["insumos", "Insumos"], ["frete", "Frete"], ["taxas", "Taxas"], ["salarios", "Salários"], ["aluguel", "Aluguel"], ["software", "Software"], ["outros", "Outros"]];

export default function FinanceiroCustosWorkbench({ despesas, custos }: { despesas: any[]; custos: any[] }) {
  const [tab, setTab] = useState<"despesas" | "custos">("despesas");
  const totalDesp = despesas.reduce((s, d) => s + Number(d.valor ?? 0), 0);
  const totalFixa = despesas.filter((d) => d.tipo === "fixa").reduce((s, d) => s + Number(d.valor ?? 0), 0);

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>FINANCEIRO · CUSTOS & DESPESAS</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Custos & Despesas</h1>
        <p className="text-sm muted mt-0.5">Lance as despesas e o custo de cada produto — a base pro <b>lucro real por pedido</b>.</p>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Despesas lançadas</div><div className="text-2xl font-bold mt-1">{despesas.length}</div></div>
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Total despesas</div><div className="text-2xl font-bold mt-1">{money(totalDesp)}</div></div>
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Fixas</div><div className="text-2xl font-bold mt-1">{money(totalFixa)}</div></div>
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Produtos com custo</div><div className="text-2xl font-bold mt-1">{custos.length}</div></div>
      </div>

      <div className="card p-3 flex items-center justify-between flex-wrap gap-2" style={{ borderLeft: "3px solid var(--brand)" }}>
        <div className="text-sm">Depois de lançar custos e despesas, veja o resultado no relatório de lucro.</div>
        <Link href="/relatorios/lucro" className="px-3 py-1.5 rounded-lg bg-brand-600 text-white text-xs font-semibold no-underline">📈 Ver Lucro Real por Pedido →</Link>
      </div>

      <div className="flex gap-1 border-b" style={{ borderColor: "var(--border)" }}>
        {([["despesas", "Despesas"], ["custos", "Custos por Produto"]] as [typeof tab, string][]).map(([k, l]) => (
          <button key={k} onClick={() => setTab(k)} className={`px-3 py-1.5 rounded-t-lg text-sm ${tab === k ? "bg-brand-600 text-white" : "hover:bg-black/5 dark:hover:bg-white/5"}`}>{l}</button>
        ))}
      </div>

      {tab === "despesas" ? (
        <CrudPanel table="financeiro_despesas" title="Despesas" rows={despesas}
          emptyHint="Lance suas despesas fixas (aluguel, software, salários) e variáveis (marketing, frete, taxas)."
          fields={[
            { key: "descricao", label: "Descrição", required: true },
            { key: "categoria", label: "Categoria", type: "select", options: CATEGORIAS },
            { key: "tipo", label: "Tipo", type: "select", options: [["variavel", "Variável"], ["fixa", "Fixa"]], default: "variavel" },
            { key: "valor", label: "Valor (R$)", type: "number", required: true },
            { key: "competencia", label: "Competência", type: "date" },
            { key: "observacoes", label: "Observações" },
          ]}
          columns={[
            { key: "descricao", label: "Descrição" }, { key: "categoria", label: "Categoria" },
            { key: "tipo", label: "Tipo" }, { key: "valor", label: "Valor", fmt: (v) => money(v) },
            { key: "competencia", label: "Competência", fmt: (v) => dt(v) },
          ]} />
      ) : (
        <CrudPanel table="financeiro_custos_produto" title="Custos por Produto" rows={custos}
          emptyHint="Cadastre o custo de cada produto (CMV), o frete médio e a taxa do gateway — o sistema casa pelo nome do produto."
          fields={[
            { key: "produto_nome", label: "Produto (nome ou parte)", required: true, placeholder: "ex.: MOUNJAX" },
            { key: "sku", label: "SKU (opcional)" },
            { key: "custo_unitario", label: "Custo unitário / CMV (R$)", type: "number" },
            { key: "frete_medio", label: "Frete médio por pedido (R$)", type: "number" },
            { key: "taxa_gateway_pct", label: "Taxa do gateway (%)", type: "number" },
            { key: "observacoes", label: "Observações" },
          ]}
          columns={[
            { key: "produto_nome", label: "Produto" }, { key: "sku", label: "SKU" },
            { key: "custo_unitario", label: "CMV", fmt: (v) => money(v) },
            { key: "frete_medio", label: "Frete médio", fmt: (v) => money(v) },
            { key: "taxa_gateway_pct", label: "Taxa %", fmt: (v) => `${Number(v ?? 0)}%` },
          ]} />
      )}
    </div>
  );
}
