export const SAMPLE_STATUS: Record<string, { label: string; cls: string }> = {
  registered: { label: "Registrada", cls: "bg-slate-500/15 text-slate-400" },
  in_analysis: { label: "Em análise", cls: "bg-amber-500/15 text-amber-500" },
  approved: { label: "Aprovada", cls: "bg-green-500/15 text-green-500" },
  rejected: { label: "Reprovada", cls: "bg-red-500/15 text-red-500" },
  retained: { label: "Retida", cls: "bg-indigo-500/15 text-indigo-500" },
  canceled: { label: "Cancelada", cls: "bg-slate-500/15 text-slate-400" },
};

export const SAMPLE_TYPE: [string, string][] = [
  ["raw_material", "Matéria-prima"], ["finished_product", "Produto acabado"], ["intermediate", "Intermediário"],
  ["water", "Água"], ["packaging", "Embalagem"], ["swab", "Swab"], ["environment", "Ambiente"],
  ["air", "Ar"], ["surface", "Superfície"], ["stability", "Estabilidade"], ["retention", "Retenção"],
];
export const sampleTypeLabel = (t: string) => SAMPLE_TYPE.find(([v]) => v === t)?.[1] ?? t;

export const TEST_KIND: [string, string][] = [
  ["physical", "Físico"], ["chemical", "Químico"], ["microbiological", "Microbiológico"],
  ["sensory", "Sensorial"], ["instrumental", "Instrumental"], ["stability", "Estabilidade"],
];
