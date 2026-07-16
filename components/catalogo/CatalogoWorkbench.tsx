"use client";
import Link from "next/link";
import CrudPanel from "@/components/ui/CrudPanel";

const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });

export default function CatalogoWorkbench({ produtos }: { produtos: any[] }) {
  const ativos = produtos.filter((p) => p.ativo).length;
  const valorEstoque = produtos.reduce((s, p) => s + Number(p.estoque_atual ?? 0) * Number(p.custo ?? 0), 0);
  const abaixo = produtos.filter((p) => Number(p.estoque_atual ?? 0) < Number(p.estoque_minimo ?? 0)).length;

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>CATÁLOGO · PRODUTOS</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Catálogo de Produtos</h1>
        <p className="text-sm muted mt-0.5">Cadastro completo: SKU, preço, custo, peso/dimensões e estoque — a base pro frete, lucro e MRP.</p>
      </div>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Produtos</div><div className="text-2xl font-bold mt-1">{produtos.length}</div></div>
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Ativos</div><div className="text-2xl font-bold mt-1" style={{ color: "var(--success)" }}>{ativos}</div></div>
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Valor em estoque</div><div className="text-2xl font-bold mt-1">{money(valorEstoque)}</div></div>
        <div className="card p-4" style={{ borderTop: `3px solid ${abaixo ? "var(--danger)" : "var(--border)"}` }}><div className="text-xs uppercase muted font-semibold">Abaixo do mínimo</div><div className="text-2xl font-bold mt-1" style={{ color: abaixo ? "var(--danger)" : undefined }}>{abaixo}</div></div>
      </div>
      <div className="card p-3 flex items-center justify-between flex-wrap gap-2" style={{ borderLeft: "3px solid var(--brand)" }}>
        <div className="text-sm">Veja o valor de estoque por categoria e o que precisa repor.</div>
        <Link href="/relatorios/catalogo" className="px-3 py-1.5 rounded-lg bg-brand-600 text-white text-xs font-semibold no-underline">▤ Ver relatório do catálogo →</Link>
      </div>
      <CrudPanel table="catalogo_produtos" title="Produtos" rows={produtos}
        emptyHint="Cadastre seus produtos com SKU, preço, custo, peso e dimensões — o casamento com os pedidos é pelo nome."
        fields={[
          { key: "sku", label: "SKU" }, { key: "nome", label: "Nome", required: true },
          { key: "categoria", label: "Categoria" },
          { key: "preco", label: "Preço de venda (R$)", type: "number" }, { key: "custo", label: "Custo/CMV (R$)", type: "number" },
          { key: "peso_g", label: "Peso (g)", type: "number" },
          { key: "altura_cm", label: "Altura (cm)", type: "number" }, { key: "largura_cm", label: "Largura (cm)", type: "number" }, { key: "comprimento_cm", label: "Comprimento (cm)", type: "number" },
          { key: "estoque_atual", label: "Estoque atual", type: "number" }, { key: "estoque_minimo", label: "Estoque mínimo", type: "number" },
          { key: "foto_url", label: "URL da foto" },
          { key: "tipo", label: "Tipo", type: "select", options: [["simples", "Simples"], ["kit", "Kit/Combo"]], default: "simples" },
          { key: "ativo", label: "Ativo", type: "select", options: [["true", "Sim"], ["false", "Não"]], default: "true" },
        ]}
        columns={[
          { key: "sku", label: "SKU" }, { key: "nome", label: "Produto" }, { key: "categoria", label: "Categoria" },
          { key: "preco", label: "Preço", fmt: (v) => money(v) }, { key: "custo", label: "Custo", fmt: (v) => money(v) },
          { key: "estoque_atual", label: "Estoque" }, { key: "estoque_minimo", label: "Mínimo" },
        ]} />
    </div>
  );
}
