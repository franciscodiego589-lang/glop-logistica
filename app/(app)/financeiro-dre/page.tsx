import Link from "next/link";
import { VitrineBanner } from "@/components/VitrineBanner";
import { KpiCard } from "@/components/ui/KpiCard";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";
const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2 });
const ESTADO_LABEL: Record<string, string> = {
  recebido: "Recebido", importado: "Importado", pronto_despacho: "Pronto p/ despacho", pre_postado: "Pré-postado",
  etiquetado: "Etiquetado", postado: "Postado", em_transito: "Em trânsito", saiu_entrega: "Saiu p/ entrega",
  entregue: "Entregue", sem_plano: "Sem plano", endereco_invalido: "Endereço inválido",
  bloqueado_reembolso: "Bloqueado", cancelado: "Cancelado", devolvido: "Devolvido", extraviado: "Extraviado",
};

export default async function FinanceiroDrePage({ searchParams }: { searchParams?: { dias?: string } }) {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  const dias = Math.max(Math.trunc(Number(searchParams?.dias ?? 30)) || 30, 1); // inteiro (param int)

  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-2xl font-extrabold">Financeiro — DRE</h1><VitrineBanner /></div>;
  }

  const { data, error } = await supabase.rpc("financeiro_dre", { p_company: company, p_days: dias });
  const erro = !!error && data == null;
  const d = (data ?? {}) as any;
  const receita = Number(d.receita_bruta ?? 0);
  const comissao = Number(d.comissao_coproducao ?? 0);
  const liquido = receita - comissao;
  const porEstado = Object.entries((d.por_estado ?? {}) as Record<string, number>).sort((a, b) => b[1] - a[1]);
  const porUF: any[] = d.por_uf ?? [];
  const porCanal: any[] = d.por_canal ?? [];
  const maxUF = porUF[0]?.receita || 1;
  const semDados = (d.pedidos ?? 0) === 0;

  const periodos = [7, 30, 90, 365];

  return (
    <div className="space-y-4">
      <div className="flex items-end justify-between flex-wrap gap-2">
        <div>
          <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>FINANCEIRO · DRE GERENCIAL</div>
          <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">DRE — Demonstrativo de Resultado</h1>
          <p className="text-sm muted mt-0.5">Receita, comissões de coprodução e resultado — números reais direto do banco (últimos {dias} dias).</p>
        </div>
        <div className="flex gap-1.5">
          {periodos.map((p) => (
            <Link key={p} href={`/financeiro-dre?dias=${p}`} className={`px-3 py-1.5 rounded-lg text-xs font-semibold no-underline ${dias === p ? "bg-brand-600 text-white" : "border"}`} style={dias === p ? undefined : { borderColor: "var(--border)" }}>{p}d</Link>
          ))}
        </div>
      </div>

      {erro ? (
        <div className="card p-6 text-center" style={{ borderLeft: "3px solid var(--danger)" }}>
          <div className="text-3xl mb-2">⚠️</div>
          <div className="font-bold">Não foi possível carregar o DRE</div>
          <p className="text-sm muted mt-1">Houve uma falha ao consultar os números. Recarregue a página ou tente outro período.</p>
          <Link href="/financeiro-dre?dias=30" className="inline-block mt-3 px-4 py-2 rounded-lg border text-sm font-semibold no-underline" style={{ borderColor: "var(--border)" }}>Recarregar →</Link>
        </div>
      ) : semDados ? (
        <div className="card p-6 text-center">
          <div className="text-3xl mb-2">📊</div>
          <div className="font-bold">Sem vendas no período</div>
          <p className="text-sm muted mt-1">Puxe seus pedidos e o DRE se preenche automaticamente.</p>
          <Link href="/integracoes-lojas" className="inline-block mt-3 px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold no-underline">Puxar Pedidos →</Link>
        </div>
      ) : (
        <>
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="Receita bruta" value={money(receita)} icon="💰" accent />
            <KpiCard label="Comissão coprodução" value={money(comissao)} icon="🤝" tone={comissao ? "warning" : "neutral"} hint="a repassar" />
            <KpiCard label="Líquido (empresa)" value={money(liquido)} icon="🏦" tone="success" />
            <KpiCard label="Margem líquida" value={`${d.margem_liquida ?? 0}%`} icon="📈" />
          </div>
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="Pedidos" value={d.pedidos ?? 0} icon="🧾" />
            <KpiCard label="Ticket médio" value={money(d.ticket_medio)} icon="🎯" />
            <KpiCard label="Entregues" value={d.entregues ?? 0} icon="✅" tone="success" />
            <KpiCard label="Cancelados" value={d.cancelados ?? 0} icon="🚫" tone={d.cancelados ? "danger" : "neutral"} />
          </div>

          {/* Estrutura do DRE */}
          <div className="card p-4">
            <div className="font-bold text-sm mb-3">🧮 Estrutura do resultado</div>
            <table className="w-full text-sm">
              <tbody>
                <tr className="border-b" style={{ borderColor: "var(--border)" }}><td className="py-2">(=) Receita bruta de vendas</td><td className="text-right tabular-nums font-semibold">{money(receita)}</td></tr>
                <tr className="border-b" style={{ borderColor: "var(--border)" }}><td className="py-2 pl-4 muted">(−) Comissões de coprodução</td><td className="text-right tabular-nums" style={{ color: "var(--warning)" }}>− {money(comissao)}</td></tr>
                <tr><td className="py-2 font-bold">(=) Resultado líquido da empresa</td><td className="text-right tabular-nums font-bold" style={{ color: "var(--success)" }}>{money(liquido)}</td></tr>
              </tbody>
            </table>
            <p className="text-[11px] muted mt-2">* Ainda não deduz frete/impostos/taxas de gateway — entram quando as notas e os custos de frete estiverem lançados.</p>
          </div>

          <div className="grid lg:grid-cols-2 gap-3">
            <div className="card p-4">
              <div className="font-bold text-sm mb-3">🗺 Receita por estado (top 12)</div>
              <div className="space-y-2">
                {porUF.map((u) => (
                  <div key={u.uf}>
                    <div className="flex justify-between text-xs mb-0.5"><span><b>{u.uf}</b> · {u.pedidos} ped.</span><span className="muted tabular-nums">{money(u.receita)}</span></div>
                    <div className="h-1.5 rounded-full overflow-hidden" style={{ background: "var(--surface-3)" }}><div className="h-full rounded-full" style={{ width: `${(u.receita / maxUF) * 100}%`, background: "var(--brand)" }} /></div>
                  </div>
                ))}
              </div>
            </div>
            <div className="card p-4">
              <div className="font-bold text-sm mb-3">🛒 Receita por canal</div>
              <div className="space-y-1.5">
                {porCanal.map((c) => (
                  <div key={c.canal} className="flex items-center justify-between text-sm border-b last:border-0 py-1.5" style={{ borderColor: "var(--border)" }}>
                    <span className="capitalize">{c.canal}</span><span className="tabular-nums"><b>{money(c.receita)}</b> <span className="muted text-xs">· {c.pedidos}</span></span>
                  </div>
                ))}
              </div>
              <div className="font-bold text-sm mt-4 mb-2">Pedidos por status</div>
              <div className="flex flex-wrap gap-1.5">
                {porEstado.map(([st, n]) => (
                  <span key={st} className="badge badge-neutral">{ESTADO_LABEL[st] ?? st}: {n}</span>
                ))}
              </div>
            </div>
          </div>

          <div className="card p-3 text-xs muted">💡 O líquido é o que sobra pra empresa depois das comissões. Estados/canais no topo são onde vale negociar frete e reforçar estoque. Gere os <Link href="/coproducao" className="font-semibold no-underline" style={{ color: "var(--brand)" }}>repasses</Link> pra fechar o que deve aos coprodutores.</div>
        </>
      )}
    </div>
  );
}
