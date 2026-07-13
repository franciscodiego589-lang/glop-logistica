import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

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
    // company_id vem da sessão/contexto — placeholder até o seletor de empresa existir
    const companyId = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
    if (companyId) {
      const { data: d } = await supabase.rpc("executive_dashboard", { p_company: companyId });
      data = (d as Exec) ?? null;
    }
  }

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-xl font-bold">Cockpit Executivo</h1>
        <p className="text-sm muted">Visão única cross-módulo em tempo real</p>
      </div>

      {!supabase && <VitrineBanner />}

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <KpiCard label="SKUs ativos" value={data?.inventory?.skus_active ?? "—"} />
        <KpiCard label="Valor em estoque" value={brl(data?.inventory?.stock_value)} />
        <KpiCard label="Abaixo do ponto de pedido" value={data?.inventory?.below_reorder ?? "—"} accent />
        <KpiCard label="Vencendo em 30d" value={data?.inventory?.expiring_30d ?? "—"} />
        <KpiCard label="Pedidos de saída abertos" value={data?.orders?.outbound_open ?? "—"} />
        <KpiCard label="Embarcados hoje" value={data?.orders?.shipped_today ?? "—"} />
        <KpiCard label="Compras em aberto" value={data?.orders?.purchase_open ?? "—"} />
        <KpiCard label="OPs em produção" value={data?.production?.orders_open ?? "—"} />
      </div>

      <div className="grid md:grid-cols-3 gap-3">
        <div className="card p-4">
          <div className="font-semibold mb-2">Torre de Controle</div>
          <div className="space-y-1 text-sm">
            <Row k="Alertas abertos" v={data?.control_tower?.open_alerts} />
            <Row k="Alertas críticos" v={data?.control_tower?.critical_alerts} />
            <Row k="Quebras de SLA (24h)" v={data?.control_tower?.sla_breaches_24h} />
          </div>
        </div>
        <div className="card p-4">
          <div className="font-semibold mb-2">LOGIA — IA</div>
          <div className="space-y-1 text-sm">
            <Row k="Novos insights" v={data?.logia?.new_insights} />
            <Row k="Críticos" v={data?.logia?.critical} />
          </div>
          <p className="text-xs muted mt-3">Ruptura, excesso, gargalos e desperdício detectados automaticamente.</p>
        </div>
        <div className="card p-4 flex flex-col gap-2">
          <div className="font-semibold">Ações rápidas</div>
          {["Gerar Relatório", "Analisar", "Simular", "Otimizar"].map((a) => (
            <button key={a} className="text-left text-sm px-3 py-2 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>
              {a}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

function Row({ k, v }: { k: string; v?: number }) {
  return (
    <div className="flex items-center justify-between">
      <span className="muted">{k}</span>
      <span className="font-semibold tabular-nums">{v ?? "—"}</span>
    </div>
  );
}
