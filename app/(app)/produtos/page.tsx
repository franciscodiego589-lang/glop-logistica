import Link from "next/link";
import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import ProductTable from "@/components/produtos/ProductTable";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

type Dup = { a_name: string; b_name: string; similarity: number; reason: string };

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
  let dups: Dup[] = [];
  if (supabase && company) {
    const [{ data: k }, { data: rows }, { data: d }] = await Promise.all([
      supabase.rpc("mdm_dashboard", { p_company: company }),
      supabase
        .from("products")
        .select("id,sku,code,name,product_type,abc_class,cost_price,sale_price,active,data_quality_score")
        .eq("company_id", company)
        .is("deleted_at", null)
        .order("created_at", { ascending: false })
        .limit(500),
      supabase.rpc("detect_duplicate_products", { p_company: company, p_threshold: 0.6 }),
    ]);
    kpis = (k as Kpis) ?? null;
    products = (rows as Product[]) ?? [];
    dups = (d as Dup[]) ?? [];
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

      {dups.length > 0 && (
        <div className="card p-4 border-amber-500/40">
          <div className="font-semibold mb-2">✦ LOGIA — possíveis duplicidades ({dups.length})</div>
          <div className="space-y-1 text-sm">
            {dups.slice(0, 6).map((d, i) => (
              <div key={i} className="flex items-center gap-2">
                <span className="px-2 py-0.5 rounded-md bg-amber-500/15 text-amber-500 text-xs font-semibold">{Math.round(d.similarity * 100)}%</span>
                <span>“{d.a_name}” ≈ “{d.b_name}”</span>
                <span className="muted text-xs">por {d.reason}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      <ProductTable products={products} />
    </div>
  );
}
