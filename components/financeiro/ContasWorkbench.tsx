"use client";
import Link from "next/link";
import CrudPanel from "@/components/ui/CrudPanel";

const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const dt = (v: any) => (v ? new Date(v + "T00:00:00").toLocaleDateString("pt-BR") : "—");
const hoje = new Date().toISOString().slice(0, 10);

export default function ContasWorkbench({ contas }: { contas: any[] }) {
  const aReceber = contas.filter((c) => c.tipo === "receber" && !c.pago).reduce((s, c) => s + Number(c.valor ?? 0), 0);
  const aPagar = contas.filter((c) => c.tipo === "pagar" && !c.pago).reduce((s, c) => s + Number(c.valor ?? 0), 0);
  const vencidas = contas.filter((c) => !c.pago && c.vencimento < hoje).length;

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>FINANCEIRO · CONTAS</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Contas a Pagar & Receber</h1>
        <p className="text-sm muted mt-0.5">Lance o que a empresa tem a pagar e a receber, com vencimentos — e veja o fluxo de caixa.</p>
      </div>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <div className="card p-4" style={{ borderTop: "3px solid var(--success)" }}><div className="text-xs uppercase muted font-semibold">A receber</div><div className="text-2xl font-bold mt-1" style={{ color: "var(--success)" }}>{money(aReceber)}</div></div>
        <div className="card p-4" style={{ borderTop: "3px solid var(--warning)" }}><div className="text-xs uppercase muted font-semibold">A pagar</div><div className="text-2xl font-bold mt-1" style={{ color: "var(--warning)" }}>{money(aPagar)}</div></div>
        <div className="card p-4" style={{ borderTop: `3px solid ${aReceber - aPagar >= 0 ? "var(--success)" : "var(--danger)"}` }}><div className="text-xs uppercase muted font-semibold">Saldo projetado</div><div className="text-2xl font-bold mt-1" style={{ color: aReceber - aPagar >= 0 ? "var(--success)" : "var(--danger)" }}>{money(aReceber - aPagar)}</div></div>
        <div className="card p-4" style={{ borderTop: `3px solid ${vencidas ? "var(--danger)" : "var(--border)"}` }}><div className="text-xs uppercase muted font-semibold">Vencidas</div><div className="text-2xl font-bold mt-1" style={{ color: vencidas ? "var(--danger)" : undefined }}>{vencidas}</div></div>
      </div>
      <div className="card p-3 flex items-center justify-between flex-wrap gap-2" style={{ borderLeft: "3px solid var(--brand)" }}>
        <div className="text-sm">Veja o fluxo de caixa e os próximos vencimentos.</div>
        <Link href="/relatorios/fluxo-caixa" className="px-3 py-1.5 rounded-lg bg-brand-600 text-white text-xs font-semibold no-underline">💵 Ver Fluxo de Caixa →</Link>
      </div>
      <CrudPanel table="financeiro_contas" title="Contas" rows={contas}
        emptyHint="Lance contas a pagar (fornecedores, impostos) e a receber (repasses, vendas a prazo) com vencimento."
        fields={[
          { key: "tipo", label: "Tipo", type: "select", options: [["pagar", "A pagar"], ["receber", "A receber"]], default: "pagar" },
          { key: "descricao", label: "Descrição", required: true },
          { key: "categoria", label: "Categoria" },
          { key: "valor", label: "Valor (R$)", type: "number", required: true },
          { key: "vencimento", label: "Vencimento", type: "date" },
          { key: "pago", label: "Pago?", type: "select", options: [["false", "Não"], ["true", "Sim"]], default: "false" },
          { key: "pago_em", label: "Pago em", type: "date" },
          { key: "forma_pagamento", label: "Forma de pagamento" },
          { key: "observacoes", label: "Observações" },
        ]}
        columns={[
          { key: "tipo", label: "Tipo" }, { key: "descricao", label: "Descrição" }, { key: "categoria", label: "Categoria" },
          { key: "valor", label: "Valor", fmt: (v) => money(v) }, { key: "vencimento", label: "Vencimento", fmt: (v) => dt(v) },
          { key: "pago", label: "Pago", fmt: (v) => (v ? "✅" : "—") },
        ]} />
    </div>
  );
}
