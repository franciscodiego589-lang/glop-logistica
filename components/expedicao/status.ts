export const OUT_STATUS: Record<string, { label: string; cls: string }> = {
  draft: { label: "Rascunho", cls: "bg-slate-500/15 text-slate-400" },
  confirmed: { label: "Confirmado", cls: "bg-blue-500/15 text-blue-500" },
  allocated: { label: "Alocado", cls: "bg-indigo-500/15 text-indigo-500" },
  picking: { label: "Separando", cls: "bg-amber-500/15 text-amber-500" },
  packed: { label: "Embalado", cls: "bg-amber-500/15 text-amber-500" },
  shipped: { label: "Expedido", cls: "bg-green-500/15 text-green-500" },
  invoiced: { label: "Faturado", cls: "bg-teal-500/15 text-teal-500" },
  delivered: { label: "Entregue", cls: "bg-green-500/15 text-green-500" },
  canceled: { label: "Cancelado", cls: "bg-slate-500/15 text-slate-400" },
};
export const money = (n: number | null | undefined) =>
  n == null ? "—" : n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
