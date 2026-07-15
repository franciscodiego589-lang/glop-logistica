import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";
import Link from "next/link";

export const dynamic = "force-dynamic";

type Exec = {
  inventory?: { skus_active?: number; stock_value?: number; below_reorder?: number; expiring_30d?: number };
  control_tower?: { open_alerts?: number; critical_alerts?: number; sla_breaches_24h?: number };
  orders?: { outbound_open?: number; shipped_today?: number; purchase_open?: number };
  production?: { orders_open?: number };
  logia?: { new_insights?: number; critical?: number };
};

const brl = (n?: number) =>
  n == null ? "—" : n.toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 });

export default async function DashboardPage() {
  const supabase = createClient();
  let data: Exec | null = null;
  if (supabase) {
    const companyId = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
    if (companyId) {
      const { data: d } = await supabase.rpc("executive_dashboard", { p_company: companyId });
      data = (d as Exec) ?? null;
    }
  }
  const now = new Date().toLocaleDateString("pt-BR", { weekday: "long", day: "2-digit", month: "long", year: "numeric" });

  return (
    <div className="space-y-6">
      {/* Cabeçalho */}
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <div className="text-xs muted font-semibold uppercase tracking-wider">Visão Geral</div>
          <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Cockpit Executivo</h1>
          <p className="text-sm muted capitalize mt-0.5">{now}</p>
        </div>
        <div className="flex items-center gap-2">
          <Link href="/ia-central" className="btn btn-sm"><span className="text-brand-500">✦</span> Cérebro IA</Link>
          <Link href="/control-tower" className="btn btn-primary btn-sm">Torre de Controle</Link>
        </div>
      </div>

      {!supabase && <VitrineBanner />}

      {/* KPIs */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <KpiCard label="SKUs ativos" value={data?.inventory?.skus_active ?? "—"} icon="▤" tone="brand" />
        <KpiCard label="Valor em estoque" value={brl(data?.inventory?.stock_value)} icon="💰" tone="success" />
        <KpiCard label="Abaixo do ponto de pedido" value={data?.inventory?.below_reorder ?? "—"} icon="⚠" accent />
        <KpiCard label="Vencendo em 30d" value={data?.inventory?.expiring_30d ?? "—"} icon="⏳" tone="warning" />
        <KpiCard label="Pedidos de saída abertos" value={data?.orders?.outbound_open ?? "—"} icon="📦" tone="brand" />
        <KpiCard label="Embarcados hoje" value={data?.orders?.shipped_today ?? "—"} icon="🚚" tone="success" />
        <KpiCard label="Compras em aberto" value={data?.orders?.purchase_open ?? "—"} icon="🛒" tone="neutral" />
        <KpiCard label="OPs em produção" value={data?.production?.orders_open ?? "—"} icon="🏭" tone="brand" />
      </div>

      {/* Painéis */}
      <div className="grid md:grid-cols-3 gap-4">
        <div className="card p-5">
          <div className="flex items-center gap-2 mb-3">
            <span className="h-8 w-8 rounded-lg grid place-items-center" style={{ background: "var(--danger-soft)", color: "var(--danger)" }}>⛭</span>
            <div className="font-semibold">Torre de Controle</div>
          </div>
          <div className="space-y-2.5 text-sm">
            <Row k="Alertas abertos" v={data?.control_tower?.open_alerts} />
            <Row k="Alertas críticos" v={data?.control_tower?.critical_alerts} tone="danger" />
            <Row k="Quebras de SLA (24h)" v={data?.control_tower?.sla_breaches_24h} tone="warning" />
          </div>
        </div>
        <div className="card p-5">
          <div className="flex items-center gap-2 mb-3">
            <span className="h-8 w-8 rounded-lg grid place-items-center" style={{ background: "var(--brand-soft)", color: "var(--brand)" }}>✦</span>
            <div className="font-semibold">LAIOS — Cérebro do ERP</div>
          </div>
          <div className="space-y-2.5 text-sm">
            <Row k="Novos insights" v={data?.logia?.new_insights} tone="brand" />
            <Row k="Críticos" v={data?.logia?.critical} tone="danger" />
          </div>
          <p className="text-xs muted mt-3">Ruptura, excesso, gargalos e desperdício detectados automaticamente 24/7.</p>
          <Link href="/ia-central" className="btn btn-sm w-full mt-3">Abrir Centro de Comando</Link>
        </div>
        <div className="card p-5">
          <div className="font-semibold mb-3">Atalhos</div>
          <div className="grid grid-cols-2 gap-2">
            {[["Estoque", "/estoque", "▦"], ["Expedição", "/expedicao", "📦"], ["Comex", "/comex", "🌍"], ["Financeiro", "/financeiro", "💰"], ["Compras", "/compras", "🛒"], ["Qualidade", "/qualidade", "✔"]].map(([label, href, icon]) => (
              <Link key={href} href={href} className="flex items-center gap-2 text-sm px-3 py-2.5 rounded-xl surface-2 card-hover" style={{ border: "1px solid var(--border)" }}>
                <span>{icon}</span><span className="font-medium truncate">{label}</span>
              </Link>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function Row({ k, v, tone }: { k: string; v?: number; tone?: "danger" | "warning" | "brand" }) {
  const color = tone === "danger" ? "var(--danger)" : tone === "warning" ? "var(--warning)" : tone === "brand" ? "var(--brand)" : "var(--text)";
  const big = (v ?? 0) > 0;
  return (
    <div className="flex items-center justify-between">
      <span className="muted">{k}</span>
      <span className="font-bold tabular-nums" style={{ color: big && tone ? color : undefined }}>{v ?? "—"}</span>
    </div>
  );
}
