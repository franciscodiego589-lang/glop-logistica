import Link from "next/link";
import { VitrineBanner } from "@/components/VitrineBanner";
import { KpiCard } from "@/components/ui/KpiCard";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const dt = (s: any) => s ? new Date(s).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", hour: "2-digit", minute: "2-digit" }) : "—";

async function count(supabase: any, table: string, mod?: (q: any) => any) {
  let q = supabase.from(table).select("*", { count: "exact", head: true }).is("deleted_at", null);
  if (mod) q = mod(q);
  const { count } = await q;
  return count ?? 0;
}

export default async function DashboardPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-2xl font-extrabold">Cockpit Executivo</h1><VitrineBanner /></div>;
  }
  const byCo = (q: any) => q.eq("company_id", company);
  const [dash, conns, repPend, prepErro, nfeOk, nfeErr, recent] = await Promise.all([
    supabase.rpc("store_hub_dashboard", { p_company: company }),
    count(supabase, "store_connectors", byCo),
    supabase.from("coproducao_repasses").select("total_liquido_repassar", { count: "exact" }).eq("company_id", company).is("deleted_at", null).in("status", ["aberto", "conferido", "aprovado"]).limit(500),
    count(supabase, "prepostagens", (q: any) => byCo(q).not("erro", "is", null)),
    count(supabase, "nfe_emissoes", (q: any) => byCo(q).ilike("status", "%autoriz%")),
    count(supabase, "nfe_emissoes", (q: any) => byCo(q).ilike("status", "%erro%")),
    supabase.from("store_orders").select("sale_number,buyer_name,product_name,value,state,created_at").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(8),
  ]);
  const d = (dash.data ?? {}) as any;
  const repPendVal = (repPend.data ?? []).reduce((s: number, r: any) => s + Number(r.total_liquido_repassar ?? 0), 0);
  const pedidos = d.orders ?? 0;
  const semPlano = d.sem_plano ?? 0;

  // Checklist de primeiros passos (derivado dos dados)
  const steps = [
    { ok: conns > 0, label: "Conectar uma plataforma de pagamento", href: "/integracoes-nfe" },
    { ok: pedidos > 0, label: "Puxar seus pedidos", href: "/integracoes-lojas" },
    { ok: (d.postado ?? 0) > 0, label: "Gerar prepostagem nos Correios", href: "/prepostagem" },
    { ok: nfeOk > 0, label: "Emitir a primeira NF-e", href: "/integracoes-nfe" },
    { ok: (recent.data ?? []).length > 0, label: "Acompanhar as vendas por loja", href: "/integracoes-lojas" },
  ];
  const feitos = steps.filter((s) => s.ok).length;

  const alerts = [
    semPlano > 0 && { tone: "warning", txt: `${semPlano} pedido(s) SEM PLANO travados${d.sem_plano_valor ? ` (${money(d.sem_plano_valor)})` : ""}`, href: "/integracoes-lojas" },
    (d.bloqueado_reembolso ?? 0) > 0 && { tone: "danger", txt: `${d.bloqueado_reembolso} pedido(s) bloqueados por reembolso`, href: "/integracoes-lojas" },
    prepErro > 0 && { tone: "danger", txt: `${prepErro} prepostagem(ns) com erro nos Correios`, href: "/prepostagem" },
    nfeErr > 0 && { tone: "danger", txt: `${nfeErr} NF-e com erro de emissão`, href: "/integracoes-nfe" },
  ].filter(Boolean) as any[];

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>VISÃO GERAL · TEMPO REAL</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Cockpit Executivo</h1>
        <p className="text-sm muted mt-0.5">Os números do seu negócio agora — vendas, logística, fiscal e repasses.</p>
      </div>

      {alerts.length > 0 && (
        <div className="space-y-1.5">
          {alerts.map((a, idx) => (
            <Link key={idx} href={a.href} className="flex items-center gap-2 card p-2.5 no-underline text-sm" style={{ borderLeft: `3px solid var(--${a.tone})` }}>
              <span>{a.tone === "danger" ? "🚨" : "⚠️"}</span><span className="flex-1">{a.txt}</span><span className="text-xs muted">resolver →</span>
            </Link>
          ))}
        </div>
      )}

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <KpiCard label="Pedidos" value={pedidos} icon="🧾" accent />
        <KpiCard label="Postados" value={d.postado ?? 0} icon="📮" tone="success" />
        <KpiCard label="Entregues" value={d.entregue ?? 0} icon="✅" tone="success" />
        <KpiCard label="Sem plano" value={semPlano} icon="⏳" tone={semPlano ? "warning" : "neutral"} />
        <KpiCard label="Plataformas conectadas" value={conns} icon="🔌" />
        <KpiCard label="NF-e autorizadas" value={nfeOk} icon="📄" tone="success" hint={nfeErr ? `${nfeErr} com erro` : undefined} />
        <KpiCard label="A repassar (coprodução)" value={money(repPendVal)} icon="🤝" tone="brand" />
        <KpiCard label="Endereço inválido" value={d.endereco_invalido ?? 0} icon="📍" tone={(d.endereco_invalido ?? 0) ? "warning" : "neutral"} />
      </div>

      <div className="grid lg:grid-cols-3 gap-3">
        {/* Primeiros passos */}
        <div className="card p-4 lg:col-span-1">
          <div className="flex items-center justify-between">
            <div className="font-bold text-sm">🚀 Primeiros passos</div>
            <span className="text-xs muted">{feitos}/{steps.length}</span>
          </div>
          <div className="mt-2 h-1.5 rounded-full overflow-hidden" style={{ background: "var(--surface-3)" }}>
            <div className="h-full rounded-full" style={{ width: `${(feitos / steps.length) * 100}%`, background: "var(--brand)" }} />
          </div>
          <ul className="mt-3 space-y-1.5">
            {steps.map((s, idx) => (
              <li key={idx}>
                <Link href={s.href} className="flex items-center gap-2 text-sm no-underline hover:underline">
                  <span>{s.ok ? "✅" : "⬜"}</span>
                  <span className={s.ok ? "muted line-through" : ""}>{s.label}</span>
                </Link>
              </li>
            ))}
          </ul>
        </div>

        {/* Atalhos */}
        <div className="card p-4 lg:col-span-2">
          <div className="font-bold text-sm mb-2">⚡ Atalhos</div>
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
            {[
              { icon: "📈", label: "Visão Executiva", href: "/relatorios/consolidado" },
              { icon: "📊", label: "Relatórios", href: "/relatorios" },
              { icon: "🛒", label: "Puxar Pedidos", href: "/integracoes-lojas" },
              { icon: "🤝", label: "Coprodução", href: "/coproducao" },
              { icon: "🧾", label: "Integrações & NF-e", href: "/integracoes-nfe" },
              { icon: "📖", label: "Manual", href: "/manual" },
            ].map((a) => (
              <Link key={a.href} href={a.href} className="card p-3 no-underline flex items-center gap-2 hover:bg-black/5 dark:hover:bg-white/5">
                <span className="text-lg">{a.icon}</span><span className="text-sm font-medium">{a.label}</span>
              </Link>
            ))}
          </div>
        </div>
      </div>

      {/* Últimas vendas */}
      <div className="card p-0 overflow-x-auto">
        <div className="px-4 pt-3 font-semibold text-sm flex items-center justify-between">
          <span>Últimas vendas</span>
          <Link href="/integracoes-lojas" className="text-xs font-semibold" style={{ color: "var(--brand)" }}>ver todas →</Link>
        </div>
        {(recent.data ?? []).length === 0 ? <p className="text-sm muted p-4">Nenhuma venda ainda. Comece em <b>Puxar Pedidos de Lojas</b>.</p> : (
          <table className="w-full text-sm mt-2">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-4">Venda</th><th className="px-3">Comprador</th><th className="px-3">Produto</th><th className="px-3 text-right">Valor</th><th className="px-3">Status</th><th className="px-3">Quando</th></tr></thead>
            <tbody>{(recent.data ?? []).map((o: any, idx: number) => (
              <tr key={idx} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                <td className="py-2 px-4 font-medium">#{o.sale_number}</td>
                <td className="px-3">{o.buyer_name ?? "—"}</td>
                <td className="px-3 text-xs">{o.product_name ?? "—"}</td>
                <td className="px-3 text-right tabular-nums">{money(o.value)}</td>
                <td className="px-3"><span className="badge badge-neutral">{o.state}</span></td>
                <td className="px-3 text-xs muted">{dt(o.created_at)}</td>
              </tr>))}</tbody>
          </table>
        )}
      </div>
    </div>
  );
}
