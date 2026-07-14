export const REQ_STATUS: Record<string, { label: string; cls: string }> = {
  draft: { label: "Rascunho", cls: "bg-slate-500/15 text-slate-400" },
  submitted: { label: "Enviada", cls: "bg-blue-500/15 text-blue-500" },
  approved: { label: "Aprovada", cls: "bg-green-500/15 text-green-500" },
  rejected: { label: "Rejeitada", cls: "bg-red-500/15 text-red-500" },
  converted: { label: "Convertida", cls: "bg-indigo-500/15 text-indigo-500" },
  canceled: { label: "Cancelada", cls: "bg-slate-500/15 text-slate-400" },
};

export const PO_STATUS: Record<string, { label: string; cls: string }> = {
  draft: { label: "Rascunho", cls: "bg-slate-500/15 text-slate-400" },
  sent: { label: "Enviado", cls: "bg-blue-500/15 text-blue-500" },
  confirmed: { label: "Confirmado", cls: "bg-indigo-500/15 text-indigo-500" },
  partial: { label: "Parcial", cls: "bg-amber-500/15 text-amber-500" },
  received: { label: "Recebido", cls: "bg-green-500/15 text-green-500" },
  invoiced: { label: "Faturado", cls: "bg-teal-500/15 text-teal-500" },
  canceled: { label: "Cancelado", cls: "bg-slate-500/15 text-slate-400" },
};

export const RFQ_STATUS: Record<string, { label: string; cls: string }> = {
  draft: { label: "Rascunho", cls: "bg-slate-500/15 text-slate-400" },
  sent: { label: "Enviada", cls: "bg-blue-500/15 text-blue-500" },
  quoted: { label: "Cotada", cls: "bg-amber-500/15 text-amber-500" },
  awarded: { label: "Adjudicada", cls: "bg-green-500/15 text-green-500" },
  canceled: { label: "Cancelada", cls: "bg-slate-500/15 text-slate-400" },
};

export const money = (n: number | null | undefined) =>
  n == null ? "—" : n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
