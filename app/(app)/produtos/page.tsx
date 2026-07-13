import Link from "next/link";
import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

type Kpis = {
  total?: number; active?: number; blocked?: number; no_photo?: number; no_supplier?: number;
  no_tax?: number; no_dimensions?: number; no_location?: number; brands?: number; categories?: number;
  abc_a?: number; data_quality_avg?: number;
};
type Product = {
  id: string; sku: string | null; code: string | null; name: string; product_type: string;
  abc_class: string; cost_price: number | null; sale_price: number | null; active: boolean;
  data_quality_score: number;
};

const money = (n: number | null) =>
  n == null ? "—" : n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });

export default async function ProdutosPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let kpis: Kpis | null = null;
  let products: Product[] = [];
  if (supabase && company) {
    const [{ data: k }, { data: rows }] = await Promise.all([
      supabase.rpc("mdm_dashboard", { p_company: company }),
      supabase
        .from("products")
        .select("id,sku,code,name,product_type,abc_class,cost_price,sale_price,active,data_quality_score")
        .eq("company_id", company)
        .is("deleted_at", null)
        .order("created_at", { ascending: false })
        .limit(100),
    ]);
    kpis = (k as Kpis) ?? null;
    products = (rows as Product[]) ?? [];
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">▤</div>
        <div>
          <h1 className="text-xl font-bold">Cadastro Mestre (MDM)</h1>
          <p className="text-sm muted">Volume 02 · Governança de dados de produtos</p>
        </div>
        <div className="ml-auto flex gap-2">
          <Link href="/produtos/novo" className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">+ Novo produto</Link>
        </div>
      </div>

      {!supabase && <VitrineBanner />}

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <KpiCard label="Total de produtos" value={kpis?.total ?? "—"} />
        <KpiCard label="Ativos" value={kpis?.active ?? "—"} />
        <KpiCard label="Índice de qualidade" value={kpis ? `${kpis.data_quality_avg ?? 0}%` : "—"} accent hint="Data Quality médio" />
        <KpiCard label="Curva A" value={kpis?.abc_a ?? "—"} />
        <KpiCard label="Sem foto" value={kpis?.no_photo ?? "—"} />
        <KpiCard label="Sem fornecedor" value={kpis?.no_supplier ?? "—"} />
        <KpiCard label="Sem tributação (NCM)" value={kpis?.no_tax ?? "—"} />
        <KpiCard label="Sem dimensões" value={kpis?.no_dimensions ?? "—"} />
      </div>

      <div className="card overflow-hidden">
        <div className="px-4 py-3 border-b flex items-center justify-between" style={{ borderColor: "var(--border)" }}>
          <div className="font-semibold">Produtos <span className="muted font-normal">({products.length})</span></div>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left muted border-b" style={{ borderColor: "var(--border)" }}>
                <th className="px-4 py-2 font-semibold">SKU</th>
                <th className="px-4 py-2 font-semibold">Nome</th>
                <th className="px-4 py-2 font-semibold">Tipo</th>
                <th className="px-4 py-2 font-semibold">ABC</th>
                <th className="px-4 py-2 font-semibold text-right">Custo</th>
                <th className="px-4 py-2 font-semibold text-right">Venda</th>
                <th className="px-4 py-2 font-semibold text-right">Qualidade</th>
                <th className="px-4 py-2 font-semibold">Status</th>
              </tr>
            </thead>
            <tbody>
              {products.length === 0 && (
                <tr><td colSpan={8} className="px-4 py-10 text-center muted">Nenhum produto ainda. Clique em <b>+ Novo produto</b>.</td></tr>
              )}
              {products.map((p) => (
                <tr key={p.id} className="border-b hover:bg-black/5 dark:hover:bg-white/5" style={{ borderColor: "var(--border)" }}>
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
    </div>
  );
}
