"use client";
import Link from "next/link";
import CrudPanel from "@/components/ui/CrudPanel";

export default function InventarioWorkbench({ itens }: { itens: any[] }) {
  const diverg = itens.filter((i) => Number(i.qtd_contada) !== Number(i.qtd_sistema)).length;
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>ESTOQUE · INVENTÁRIO</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Inventário / Contagem</h1>
        <p className="text-sm muted mt-0.5">Registre a contagem física e compare com o sistema — as divergências aparecem no relatório.</p>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-3 gap-3">
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Itens contados</div><div className="text-2xl font-bold mt-1">{itens.length}</div></div>
        <div className="card p-4" style={{ borderTop: `3px solid ${diverg ? "var(--danger)" : "var(--border)"}` }}><div className="text-xs uppercase muted font-semibold">Com divergência</div><div className="text-2xl font-bold mt-1" style={{ color: diverg ? "var(--danger)" : undefined }}>{diverg}</div></div>
        <div className="card p-4 flex items-center"><Link href="/relatorios/inventario" className="px-3 py-1.5 rounded-lg bg-brand-600 text-white text-xs font-semibold no-underline">📋 Ver divergências →</Link></div>
      </div>

      <CrudPanel table="estoque_inventario" title="Contagem de inventário" rows={itens}
        emptyHint="Conte o estoque físico de cada produto e informe a quantidade do sistema para achar as diferenças."
        fields={[
          { key: "produto_nome", label: "Produto", required: true },
          { key: "sku", label: "SKU" },
          { key: "local", label: "Local/prateleira" },
          { key: "qtd_sistema", label: "Qtde no sistema", type: "number" },
          { key: "qtd_contada", label: "Qtde contada", type: "number", required: true },
          { key: "contado_em", label: "Data da contagem", type: "date" },
          { key: "responsavel", label: "Responsável" },
          { key: "observacoes", label: "Observações" },
        ]}
        columns={[
          { key: "produto_nome", label: "Produto" }, { key: "local", label: "Local" },
          { key: "qtd_sistema", label: "Sistema" }, { key: "qtd_contada", label: "Contado" },
          { key: "diferenca", label: "Diferença", fmt: (_v, r) => String(Number(r.qtd_contada ?? 0) - Number(r.qtd_sistema ?? 0)) },
        ]} />
    </div>
  );
}
