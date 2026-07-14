export const WO_STATUS: Record<string, { label: string; cls: string }> = {
  open: { label: "Aberta", cls: "bg-blue-500/15 text-blue-500" },
  planned: { label: "Planejada", cls: "bg-slate-500/15 text-slate-400" },
  assigned: { label: "Atribuída", cls: "bg-indigo-500/15 text-indigo-500" },
  in_progress: { label: "Em execução", cls: "bg-amber-500/15 text-amber-500" },
  on_hold: { label: "Em espera", cls: "bg-amber-500/15 text-amber-500" },
  done: { label: "Concluída", cls: "bg-green-500/15 text-green-500" },
  canceled: { label: "Cancelada", cls: "bg-slate-500/15 text-slate-400" },
};
export const WO_TYPE: [string, string][] = [
  ["preventive", "Preventiva"], ["corrective", "Corretiva"], ["predictive", "Preditiva"], ["detective", "Detectiva"],
  ["emergency", "Emergencial"], ["calibration", "Calibração"], ["inspection", "Inspeção"], ["lubrication", "Lubrificação"],
];
export const woTypeLabel = (t: string) => WO_TYPE.find(([v]) => v === t)?.[1] ?? t;
export const WO_PRIORITY: [string, string][] = [["low", "Baixa"], ["medium", "Média"], ["high", "Alta"], ["critical", "Crítica"]];
export const PRIORITY_CLS: Record<string, string> = {
  low: "bg-slate-500/15 text-slate-400", medium: "bg-blue-500/15 text-blue-500",
  high: "bg-amber-500/15 text-amber-500", critical: "bg-red-500/15 text-red-500",
};
export const ASSET_STATUS: Record<string, { label: string; cls: string }> = {
  operational: { label: "Operacional", cls: "bg-green-500/15 text-green-500" },
  standby: { label: "Standby", cls: "bg-slate-500/15 text-slate-400" },
  down: { label: "Parado", cls: "bg-red-500/15 text-red-500" },
  maintenance: { label: "Em manutenção", cls: "bg-amber-500/15 text-amber-500" },
  retired: { label: "Baixado", cls: "bg-slate-500/15 text-slate-400" },
};
export const money = (n: number | null | undefined) => n == null ? "—" : n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
