"use client";
import Link from "next/link";
import CrudPanel from "@/components/ui/CrudPanel";

const CANAL: [string, string][] = [["whatsapp", "WhatsApp"], ["email", "E-mail"], ["telefone", "Telefone"], ["site", "Site"], ["outro", "Outro"]];
const PRIOR: [string, string][] = [["baixa", "Baixa"], ["media", "Média"], ["alta", "Alta"], ["urgente", "Urgente"]];
const STATUS: [string, string][] = [["aberto", "Aberto"], ["em_andamento", "Em andamento"], ["aguardando", "Aguardando"], ["resolvido", "Resolvido"], ["fechado", "Fechado"]];

export default function AtendimentoWorkbench({ tickets }: { tickets: any[] }) {
  const abertos = tickets.filter((t) => ["aberto", "em_andamento", "aguardando"].includes(t.status)).length;
  const urgentes = tickets.filter((t) => t.prioridade === "urgente" && !["resolvido", "fechado"].includes(t.status)).length;
  const resolvidos = tickets.filter((t) => ["resolvido", "fechado"].includes(t.status)).length;

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>ATENDIMENTO · SAC</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Central de Atendimento</h1>
        <p className="text-sm muted mt-0.5">Registre e acompanhe os chamados dos compradores — por canal, prioridade e status.</p>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Chamados</div><div className="text-2xl font-bold mt-1">{tickets.length}</div></div>
        <div className="card p-4" style={{ borderTop: `3px solid ${abertos ? "var(--warning)" : "var(--border)"}` }}><div className="text-xs uppercase muted font-semibold">Em aberto</div><div className="text-2xl font-bold mt-1" style={{ color: abertos ? "var(--warning)" : undefined }}>{abertos}</div></div>
        <div className="card p-4" style={{ borderTop: `3px solid ${urgentes ? "var(--danger)" : "var(--border)"}` }}><div className="text-xs uppercase muted font-semibold">Urgentes</div><div className="text-2xl font-bold mt-1" style={{ color: urgentes ? "var(--danger)" : undefined }}>{urgentes}</div></div>
        <div className="card p-4"><div className="text-xs uppercase muted font-semibold">Resolvidos</div><div className="text-2xl font-bold mt-1" style={{ color: "var(--success)" }}>{resolvidos}</div></div>
      </div>

      <div className="card p-3 flex items-center justify-between flex-wrap gap-2" style={{ borderLeft: "3px solid var(--brand)" }}>
        <div className="text-sm">Veja o desempenho do atendimento (por status, canal e prioridade).</div>
        <Link href="/relatorios/atendimento" className="px-3 py-1.5 rounded-lg bg-brand-600 text-white text-xs font-semibold no-underline">🎧 Ver relatório de SAC →</Link>
      </div>

      <CrudPanel table="atendimento_tickets" title="Chamados" rows={tickets}
        emptyHint="Abra um chamado quando um comprador tiver uma dúvida ou problema — vincule ao nº da venda."
        fields={[
          { key: "assunto", label: "Assunto", required: true },
          { key: "comprador_nome", label: "Comprador" },
          { key: "sale_number", label: "Nº da venda" },
          { key: "canal", label: "Canal", type: "select", options: CANAL, default: "whatsapp" },
          { key: "prioridade", label: "Prioridade", type: "select", options: PRIOR, default: "media" },
          { key: "status", label: "Status", type: "select", options: STATUS, default: "aberto" },
          { key: "descricao", label: "Descrição" },
          { key: "resposta", label: "Resposta / resolução" },
          { key: "responsavel", label: "Responsável" },
        ]}
        columns={[
          { key: "assunto", label: "Assunto" }, { key: "comprador_nome", label: "Comprador" },
          { key: "canal", label: "Canal" }, { key: "prioridade", label: "Prioridade" }, { key: "status", label: "Status" },
        ]} />
    </div>
  );
}
