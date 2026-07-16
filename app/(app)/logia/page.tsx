import Link from "next/link";
import { VitrineBanner } from "@/components/VitrineBanner";
import { KpiCard } from "@/components/ui/KpiCard";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";
const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2 });

export default async function LogiaPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-2xl font-extrabold">LOGIA — Insights</h1><VitrineBanner /></div>;
  }
  const { data: orders } = await supabase.from("store_orders")
    .select("product_name,value,dest_uf,platform,state,buyer_name")
    .eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(2000);
  const rows = orders ?? [];

  const total = rows.length;
  const receita = rows.reduce((s, o) => s + Number(o.value ?? 0), 0);
  const ticket = total ? receita / total : 0;
  const agg = (key: string) => {
    const m = new Map<string, { n: number; v: number }>();
    for (const o of rows) { const k = (o as any)[key] || "—"; const e = m.get(k) ?? { n: 0, v: 0 }; e.n++; e.v += Number(o.value ?? 0); m.set(k, e); }
    return [...m.entries()].sort((a, b) => b[1].n - a[1].n);
  };
  const topProdutos = agg("product_name").slice(0, 8);
  const porUF = agg("dest_uf").slice(0, 10);
  const porPlataforma = agg("platform");
  const maxProd = topProdutos[0]?.[1].n || 1;

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>INTELIGÊNCIA · LOGIA</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">LOGIA — Insights</h1>
        <p className="text-sm muted mt-0.5">Leituras automáticas das suas vendas: o que mais vende, para onde e por qual canal.</p>
      </div>

      {total === 0 ? (
        <div className="card p-6 text-center">
          <div className="text-3xl mb-2">✨</div>
          <div className="font-bold">Ainda sem dados para analisar</div>
          <p className="text-sm muted mt-1">Puxe seus pedidos e a LOGIA começa a gerar insights automaticamente.</p>
          <Link href="/integracoes-lojas" className="inline-block mt-3 px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold no-underline">Puxar Pedidos →</Link>
        </div>
      ) : (
        <>
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="Vendas analisadas" value={total} icon="🧾" accent />
            <KpiCard label="Receita" value={money(receita)} icon="💰" tone="success" />
            <KpiCard label="Ticket médio" value={money(ticket)} icon="🎯" />
            <KpiCard label="Estados atendidos" value={porUF.filter(([k]) => k !== "—").length} icon="🗺" />
          </div>

          <div className="grid lg:grid-cols-2 gap-3">
            <div className="card p-4">
              <div className="font-bold text-sm mb-3">🏆 Produtos que mais vendem</div>
              <div className="space-y-2">
                {topProdutos.map(([nome, e]) => (
                  <div key={nome}>
                    <div className="flex justify-between text-xs mb-0.5"><span className="truncate pr-2">{nome}</span><span className="muted tabular-nums">{e.n} · {money(e.v)}</span></div>
                    <div className="h-1.5 rounded-full overflow-hidden" style={{ background: "var(--surface-3)" }}><div className="h-full rounded-full" style={{ width: `${(e.n / maxProd) * 100}%`, background: "var(--brand)" }} /></div>
                  </div>
                ))}
              </div>
            </div>

            <div className="card p-4">
              <div className="font-bold text-sm mb-3">📍 Para onde você mais vende (UF)</div>
              <div className="flex flex-wrap gap-1.5">
                {porUF.map(([uf, e]) => (
                  <div key={uf} className="rounded-lg border px-2.5 py-1.5 text-xs" style={{ borderColor: "var(--border)" }}>
                    <b>{uf}</b> · {e.n} <span className="muted">({money(e.v)})</span>
                  </div>
                ))}
              </div>
              <div className="font-bold text-sm mt-4 mb-2">Por canal</div>
              <div className="flex flex-wrap gap-1.5">
                {porPlataforma.map(([pl, e]) => (
                  <span key={pl} className="badge badge-neutral">{pl}: {e.n}</span>
                ))}
              </div>
            </div>
          </div>

          <div className="card p-3 text-xs muted">💡 Dica: os produtos no topo merecem estoque garantido e frete negociado. Estados com muitas vendas são candidatos a um CD ou contrato de frete regional.</div>
        </>
      )}
    </div>
  );
}
