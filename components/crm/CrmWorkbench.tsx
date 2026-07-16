"use client";
import Link from "next/link";
import CrudPanel from "@/components/ui/CrudPanel";

export default function CrmWorkbench({ compradores }: { compradores: any[] }) {
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>CRM · COMPRADORES</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">CRM de Compradores</h1>
        <p className="text-sm muted mt-0.5">Anote e segmente seus clientes (VIP, recorrente…), com tags e observações. As métricas (LTV, recompra) estão no relatório.</p>
      </div>
      <div className="card p-3 flex items-center justify-between flex-wrap gap-2" style={{ borderLeft: "3px solid var(--brand)" }}>
        <div className="text-sm">Veja a segmentação, LTV e os melhores clientes calculados dos pedidos.</div>
        <Link href="/relatorios/crm" className="px-3 py-1.5 rounded-lg bg-brand-600 text-white text-xs font-semibold no-underline">👥 Ver CRM (LTV & segmentos) →</Link>
      </div>
      <CrudPanel table="crm_compradores" title="Fichas de clientes" rows={compradores}
        emptyHint="Crie fichas dos seus clientes com CPF/CNPJ, segmento (VIP, recorrente), tags e observações."
        fields={[
          { key: "buyer_doc", label: "CPF/CNPJ" }, { key: "nome", label: "Nome", required: true },
          { key: "email", label: "E-mail" }, { key: "telefone", label: "Telefone" },
          { key: "segmento", label: "Segmento", type: "select", options: [["novo", "Novo"], ["recorrente", "Recorrente"], ["vip", "VIP"], ["inativo", "Inativo"]] },
          { key: "tags", label: "Tags (separadas por vírgula)" },
          { key: "observacoes", label: "Observações" },
        ]}
        columns={[
          { key: "nome", label: "Cliente" }, { key: "buyer_doc", label: "Documento" },
          { key: "segmento", label: "Segmento" }, { key: "tags", label: "Tags" }, { key: "telefone", label: "Telefone" },
        ]} />
    </div>
  );
}
