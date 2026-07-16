import Link from "next/link";
import { RELATORIOS, RELATORIO_CATEGORIAS } from "@/lib/relatorios";

export const dynamic = "force-static";

export default function RelatoriosHubPage() {
  return (
    <div className="space-y-5">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>RELATÓRIOS & IA · CENTRAL DE RELATÓRIOS</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Central de Relatórios</h1>
        <p className="text-sm muted mt-0.5">Relatórios gerenciais com dados reais do banco — KPIs, quebras por dimensão, séries e exportação. Filtre o período em cada um.</p>
      </div>

      {RELATORIO_CATEGORIAS.map((cat) => {
        const items = RELATORIOS.filter((r) => r.categoria === cat);
        if (!items.length) return null;
        return (
          <div key={cat}>
            <div className="text-xs uppercase font-bold muted mb-2">{cat} <span className="badge badge-neutral ml-1">{items.length}</span></div>
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
              {items.map((r) => (
                <Link key={r.slug} href={`/relatorios/${r.slug}`} className="card p-4 no-underline hover:shadow-md transition-shadow flex flex-col" style={{ color: "inherit" }}>
                  <div className="flex items-center gap-2">
                    <span className="text-xl">{r.icon}</span>
                    <div className="font-bold text-sm">{r.title}</div>
                  </div>
                  <p className="text-xs muted mt-2 flex-1">{r.resumo}</p>
                  <div className="text-xs font-semibold mt-3" style={{ color: "var(--brand)" }}>Abrir relatório →</div>
                </Link>
              ))}
            </div>
          </div>
        );
      })}

      <div className="card p-3 text-xs muted">💡 Os números são somados no banco (via RPC) — nada é calculado no navegador. Relatórios sem dados ainda aparecem zerados e se preenchem conforme a operação flui.</div>
    </div>
  );
}
