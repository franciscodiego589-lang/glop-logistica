"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";

type Product = {
  id: string; sku: string | null; code: string | null; name: string; product_type: string;
  abc_class: string; cost_price: number | null; sale_price: number | null; active: boolean; data_quality_score: number;
};
const money = (n: number | null) => (n == null ? "—" : n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" }));

export default function ProductTable({ products }: { products: Product[] }) {
  const router = useRouter();
  const [q, setQ] = useState("");
  const filtered = useMemo(() => {
    const s = q.trim().toLowerCase();
    if (!s) return products;
    return products.filter((p) =>
      [p.name, p.sku, p.code].filter(Boolean).some((v) => v!.toLowerCase().includes(s))
    );
  }, [q, products]);

  function exportCsv() {
    const head = ["sku", "codigo", "nome", "tipo", "abc", "custo", "venda", "qualidade", "status"];
    const lines = filtered.map((p) =>
      [p.sku ?? "", p.code ?? "", `"${p.name}"`, p.product_type, p.abc_class, p.cost_price ?? "", p.sale_price ?? "", p.data_quality_score, p.active ? "ativo" : "bloqueado"].join(",")
    );
    const blob = new Blob([[head.join(","), ...lines].join("\n")], { type: "text/csv;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url; a.download = "produtos.csv"; a.click(); URL.revokeObjectURL(url);
  }

  return (
    <div className="card overflow-hidden">
      <div className="px-4 py-3 border-b flex items-center gap-3" style={{ borderColor: "var(--border)" }}>
        <div className="font-semibold">Produtos <span className="muted font-normal">({filtered.length})</span></div>
        <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Buscar por nome, SKU, código…"
          className="ml-auto w-64 border rounded-lg px-3 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
        <button onClick={exportCsv} className="text-sm px-3 py-1.5 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>Exportar CSV</button>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="text-left muted border-b" style={{ borderColor: "var(--border)" }}>
              <th className="px-4 py-2 font-semibold">SKU</th><th className="px-4 py-2 font-semibold">Nome</th>
              <th className="px-4 py-2 font-semibold">Tipo</th><th className="px-4 py-2 font-semibold">ABC</th>
              <th className="px-4 py-2 font-semibold text-right">Custo</th><th className="px-4 py-2 font-semibold text-right">Venda</th>
              <th className="px-4 py-2 font-semibold text-right">Qualidade</th><th className="px-4 py-2 font-semibold">Status</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 && <tr><td colSpan={8} className="px-4 py-10 text-center muted">Nenhum produto encontrado.</td></tr>}
            {filtered.map((p) => (
              <tr key={p.id} onClick={() => router.push(`/produtos/${p.id}`)}
                className="border-b hover:bg-black/5 dark:hover:bg-white/5 cursor-pointer" style={{ borderColor: "var(--border)" }}>
                <td className="px-4 py-2 font-mono text-xs">{p.sku ?? p.code ?? "—"}</td>
                <td className="px-4 py-2 font-medium">{p.name}</td>
                <td className="px-4 py-2 muted">{p.product_type}</td>
                <td className="px-4 py-2">{p.abc_class !== "none" ? p.abc_class : "—"}</td>
                <td className="px-4 py-2 text-right tabular-nums">{money(p.cost_price)}</td>
                <td className="px-4 py-2 text-right tabular-nums">{money(p.sale_price)}</td>
                <td className="px-4 py-2 text-right">
                  <span className={`px-2 py-0.5 rounded-md text-xs font-semibold ${p.data_quality_score >= 80 ? "bg-green-500/15 text-green-500" : p.data_quality_score >= 50 ? "bg-amber-500/15 text-amber-500" : "bg-red-500/15 text-red-500"}`}>
                    {Math.round(p.data_quality_score)}%
                  </span>
                </td>
                <td className="px-4 py-2">{p.active ? "Ativo" : "Bloqueado"}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
