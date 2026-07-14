export const FIN_STATUS: Record<string, { label: string; cls: string }> = {
  open: { label: "Aberto", cls: "bg-blue-500/15 text-blue-500" },
  partial: { label: "Parcial", cls: "bg-amber-500/15 text-amber-500" },
  paid: { label: "Liquidado", cls: "bg-green-500/15 text-green-500" },
  overdue: { label: "Vencido", cls: "bg-red-500/15 text-red-500" },
  canceled: { label: "Cancelado", cls: "bg-slate-500/15 text-slate-400" },
};
export const PAY_METHOD: [string, string][] = [
  ["pix", "PIX"], ["ted", "TED"], ["doc", "DOC"], ["boleto", "Boleto"], ["card", "Cartão"], ["cash", "Dinheiro"], ["transfer", "Transferência"], ["other", "Outro"],
];
export const money = (n: number | null | undefined) => n == null ? "—" : n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
// status efetivo: 'open'/'partial' vencido vira "overdue" visualmente
export function effStatus(status: string, due: string | null): string {
  if ((status === "open" || status === "partial") && due && due < new Date().toISOString().slice(0, 10)) return "overdue";
  return status;
}
