export const EQUIP_STATUS: Record<string, { label: string; cls: string }> = {
  operational: { label: "Operacional", cls: "bg-green-500/15 text-green-500" },
  running: { label: "Produzindo", cls: "bg-green-500/15 text-green-500" },
  idle: { label: "Ocioso", cls: "bg-slate-500/15 text-slate-400" },
  setup: { label: "Setup", cls: "bg-amber-500/15 text-amber-500" },
  down: { label: "Parado", cls: "bg-red-500/15 text-red-500" },
  maintenance: { label: "Manutenção", cls: "bg-indigo-500/15 text-indigo-500" },
  inactive: { label: "Inativo", cls: "bg-slate-500/15 text-slate-400" },
};

export const DOWNTIME_REASON: [string, string][] = [
  ["setup", "Setup"], ["cleaning", "Limpeza"], ["breakdown", "Quebra"], ["adjustment", "Ajuste"],
  ["material_shortage", "Falta de material"], ["quality", "Qualidade"], ["changeover", "Troca (changeover)"],
  ["waiting", "Espera"], ["other", "Outro"],
];
export const reasonLabel = (r: string) => DOWNTIME_REASON.find(([v]) => v === r)?.[1] ?? r;

export const pct = (n: number) => `${(n * 100).toFixed(1)}%`;
