import Link from "next/link";
import { NAV } from "@/lib/nav";
import { getHelp } from "@/lib/help";

export const dynamic = "force-static";

const GROUP_ORDER = [
  "Visão Geral & Inteligência", "Fluxo Operacional", "Estoque & Armazém",
  "Suprimentos", "Transporte & Pátio", "Expedição & Distribuição",
  "Comércio Exterior", "Cliente & Pós-Venda", "Plataforma",
];

export default function ManualPage() {
  const groups = GROUP_ORDER.filter((g) => NAV.some((n) => n.group === g));
  // grupos extras não previstos na ordem
  for (const n of NAV) if (!groups.includes(n.group)) groups.push(n.group);

  return (
    <div className="space-y-6">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>AJUDA · MANUAL COMPLETO</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Manual do Sistema</h1>
        <p className="text-sm muted mt-0.5">Todas as telas explicadas — o que cada uma faz, o que dá pra fazer e o passo a passo. Clique num atalho para ir direto.</p>
      </div>

      {/* Primeiros passos */}
      <div className="card p-5" style={{ borderLeft: "3px solid var(--brand)" }}>
        <div className="flex items-baseline gap-2">
          <span className="text-lg">🚪</span>
          <h2 className="text-lg font-bold">Primeiros passos</h2>
        </div>
        <p className="text-sm muted mt-1">Você não precisa saber nada de tecnologia — a gente explica cada tela. Comece por aqui.</p>
        <ol className="list-decimal pl-5 mt-3 space-y-1.5 text-sm">
          <li><b>Entrar:</b> abra o endereço do sistema, digite e-mail e senha e clique em Entrar.</li>
          <li><b>Menu (esquerda):</b> todas as áreas do sistema, agrupadas por assunto.</li>
          <li><b>Barra do topo:</b> busca (Ctrl+K), sino de notificações 🔔, tema claro/escuro 🌙, seu usuário e Sair.</li>
          <li><b>Caixa 💡 "Para que serve esta tela":</b> aparece no topo de cada tela explicando o que fazer ali (pode ocultar).</li>
          <li><b>No celular:</b> dá para "adicionar à tela de início" e usar como um aplicativo.</li>
        </ol>
      </div>

      {/* Índice em chips, por grupo */}
      <div className="card p-5">
        <h2 className="text-base font-bold mb-3">📚 Todas as telas</h2>
        <div className="space-y-4">
          {groups.map((g) => (
            <div key={g}>
              <div className="text-xs font-semibold uppercase tracking-wide muted mb-1.5">{g}</div>
              <div className="flex flex-wrap gap-1.5">
                {NAV.filter((n) => n.group === g).map((n) => (
                  <Link key={n.slug} href={`/${n.slug}`}
                    className="inline-flex items-center gap-1.5 rounded-lg border px-2.5 py-1.5 text-xs no-underline hover:bg-black/5 dark:hover:bg-white/5"
                    style={{ borderColor: "var(--border)" }}>
                    <span>{n.icon}</span><span>{n.label}</span>
                  </Link>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Detalhe de cada tela, por grupo */}
      {groups.map((g) => (
        <div key={g} className="space-y-3">
          <h2 className="text-lg font-bold border-b pb-1" style={{ borderColor: "var(--border)" }}>{g}</h2>
          <div className="grid md:grid-cols-2 gap-3">
            {NAV.filter((n) => n.group === g).map((n) => {
              const h = getHelp(n.slug);
              if (!h) return null;
              return (
                <div key={n.slug} id={n.slug} className="card p-4">
                  <div className="flex items-center gap-2">
                    <span className="text-lg">{n.icon}</span>
                    <Link href={`/${n.slug}`} className="font-bold text-sm no-underline hover:underline">{n.label}</Link>
                  </div>
                  <p className="text-sm muted mt-1.5">{h.resumo}</p>
                  {h.itens && h.itens.length > 0 && (
                    <ul className="list-disc pl-5 mt-2 space-y-1 text-xs muted">
                      {h.itens.map((it, i) => <li key={i}>{it}</li>)}
                    </ul>
                  )}
                  {h.passos && h.passos.length > 0 && (
                    <div className="mt-2">
                      <div className="text-[11px] font-semibold uppercase tracking-wide muted">Passo a passo</div>
                      <ol className="list-decimal pl-5 mt-1 space-y-1 text-xs muted">
                        {h.passos.map((p, i) => <li key={i}>{p}</li>)}
                      </ol>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      ))}
    </div>
  );
}
