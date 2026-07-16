"use client";
import Link from "next/link";
import CrudPanel from "@/components/ui/CrudPanel";

const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const dt = (v: any) => (v ? new Date(v + "T00:00:00").toLocaleDateString("pt-BR", { month: "2-digit", year: "numeric" }) : "—");

export default function MetasWorkbench({ metas }: { metas: any[] }) {
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>DESEMPENHO · METAS</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Metas</h1>
        <p className="text-sm muted mt-0.5">Defina metas por mês (receita, pedidos, entregas, ticket, comissão) — o sistema calcula o progresso automaticamente.</p>
      </div>
      <div className="card p-3 flex items-center justify-between flex-wrap gap-2" style={{ borderLeft: "3px solid var(--brand)" }}>
        <div className="text-sm">Acompanhe o progresso de cada meta contra o realizado.</div>
        <Link href="/relatorios/metas" className="px-3 py-1.5 rounded-lg bg-brand-600 text-white text-xs font-semibold no-underline">🎯 Ver painel de Metas →</Link>
      </div>
      <CrudPanel table="metas" title="Metas" rows={metas}
        emptyHint="Defina uma meta: ex. Receita de julho = R$ 100.000. O realizado é apurado dos pedidos automaticamente."
        fields={[
          { key: "nome", label: "Nome da meta", required: true, placeholder: "ex.: Receita Julho" },
          { key: "tipo", label: "Tipo", type: "select", options: [["receita", "Receita (R$)"], ["pedidos", "Pedidos (qtd)"], ["entregues", "Entregues (qtd)"], ["ticket", "Ticket médio (R$)"], ["comissao", "Comissão (R$)"]], default: "receita" },
          { key: "competencia", label: "Mês (competência)", type: "date" },
          { key: "valor_meta", label: "Alvo", type: "number", required: true },
          { key: "observacoes", label: "Observações" },
        ]}
        columns={[
          { key: "nome", label: "Meta" }, { key: "tipo", label: "Tipo" },
          { key: "competencia", label: "Mês", fmt: (v) => dt(v) }, { key: "valor_meta", label: "Alvo", fmt: (v) => money(v) },
        ]} />
    </div>
  );
}
