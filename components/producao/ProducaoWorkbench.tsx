"use client";
import { useState } from "react";
import Link from "next/link";
import CrudPanel from "@/components/ui/CrudPanel";

const dt = (v: any) => (v ? new Date(v + "T00:00:00").toLocaleDateString("pt-BR") : "—");
const OP_STATUS: [string, string][] = [["planejada", "Planejada"], ["em_producao", "Em produção"], ["concluida", "Concluída"], ["cancelada", "Cancelada"]];
const LOTE_STATUS: [string, string][] = [["liberado", "Liberado"], ["quarentena", "Quarentena"], ["bloqueado", "Bloqueado"], ["vencido", "Vencido"], ["esgotado", "Esgotado"]];

export default function ProducaoWorkbench({ ordens, lotes }: { ordens: any[]; lotes: any[] }) {
  const [tab, setTab] = useState<"ordens" | "lotes">("ordens");
  const hoje = new Date().toISOString().slice(0, 10);
  const abertas = ordens.filter((o) => ["planejada", "em_producao"].includes(o.status)).length;
  const vencidos = lotes.filter((l) => l.validade && l.validade < hoje).length;
  const vencendo = lotes.filter((l) => l.validade && l.validade >= hoje && l.validade < new Date(Date.now() + 30 * 864e5).toISOString().slice(0, 10)).length;

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>PRODUÇÃO · FABRICAÇÃO & VALIDADE</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Produção & Lotes</h1>
        <p className="text-sm muted mt-0.5">Ordens de produção e controle de lote/validade — rastreabilidade do que você fabrica.</p>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Ordens abertas</div><div className="text-2xl font-bold mt-1">{abertas}</div></div>
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Lotes</div><div className="text-2xl font-bold mt-1">{lotes.length}</div></div>
        <div className="card p-4" style={{ borderTop: `3px solid ${vencidos ? "var(--danger)" : "var(--border)"}` }}><div className="text-xs uppercase muted font-semibold">Vencidos</div><div className="text-2xl font-bold mt-1" style={{ color: vencidos ? "var(--danger)" : undefined }}>{vencidos}</div></div>
        <div className="card p-4" style={{ borderTop: `3px solid ${vencendo ? "var(--warning)" : "var(--border)"}` }}><div className="text-xs uppercase muted font-semibold">Vencem em 30d</div><div className="text-2xl font-bold mt-1" style={{ color: vencendo ? "var(--warning)" : undefined }}>{vencendo}</div></div>
      </div>

      <div className="card p-3 flex items-center justify-between flex-wrap gap-2" style={{ borderLeft: "3px solid var(--brand)" }}>
        <div className="text-sm">Acompanhe vencimentos e status no painel de produção.</div>
        <Link href="/relatorios/producao" className="px-3 py-1.5 rounded-lg bg-brand-600 text-white text-xs font-semibold no-underline">🏭 Ver painel de Produção & Validade →</Link>
      </div>

      <div className="flex gap-1 border-b" style={{ borderColor: "var(--border)" }}>
        {([["ordens", "Ordens de Produção"], ["lotes", "Lotes & Validade"]] as [typeof tab, string][]).map(([k, l]) => (
          <button key={k} onClick={() => setTab(k)} className={`px-3 py-1.5 rounded-t-lg text-sm ${tab === k ? "bg-brand-600 text-white" : "hover:bg-black/5 dark:hover:bg-white/5"}`}>{l}</button>
        ))}
      </div>

      {tab === "ordens" ? (
        <CrudPanel table="producao_ordens" title="Ordens de Produção" rows={ordens}
          emptyHint="Crie ordens de produção do que você fabrica: produto, quantidade, prazo e responsável."
          fields={[
            { key: "numero", label: "Nº da OP", placeholder: "ex.: OP-001" },
            { key: "produto_nome", label: "Produto", required: true },
            { key: "quantidade", label: "Quantidade", type: "number" },
            { key: "unidade", label: "Unidade", default: "un" },
            { key: "status", label: "Status", type: "select", options: OP_STATUS, default: "planejada" },
            { key: "data_prevista", label: "Data prevista", type: "date" },
            { key: "responsavel", label: "Responsável" },
            { key: "observacoes", label: "Observações" },
          ]}
          columns={[
            { key: "numero", label: "OP" }, { key: "produto_nome", label: "Produto" },
            { key: "quantidade", label: "Qtde" }, { key: "status", label: "Status" },
            { key: "data_prevista", label: "Prevista", fmt: (v) => dt(v) },
          ]} />
      ) : (
        <CrudPanel table="producao_lotes" title="Lotes & Validade" rows={lotes}
          emptyHint="Registre cada lote fabricado com data de fabricação e validade — rastreabilidade e alerta de vencimento."
          fields={[
            { key: "lote", label: "Lote", required: true, placeholder: "ex.: L2607" },
            { key: "produto_nome", label: "Produto", required: true },
            { key: "quantidade", label: "Quantidade", type: "number" },
            { key: "fabricacao", label: "Fabricação", type: "date" },
            { key: "validade", label: "Validade", type: "date" },
            { key: "status", label: "Status", type: "select", options: LOTE_STATUS, default: "liberado" },
            { key: "observacoes", label: "Observações" },
          ]}
          columns={[
            { key: "lote", label: "Lote" }, { key: "produto_nome", label: "Produto" },
            { key: "quantidade", label: "Qtde" }, { key: "validade", label: "Validade", fmt: (v) => dt(v) },
            { key: "status", label: "Status" },
          ]} />
      )}
    </div>
  );
}
