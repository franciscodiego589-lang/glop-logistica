import { NAV } from "@/lib/nav";
import { HELP_CONTENT } from "@/lib/help-content";

// Ajuda contextual por tela. Cada módulo tem um resumo ("para que serve") + itens
// (o que dá pra fazer / o que cada número significa) e, opcionalmente, passos.
// O conteúdo detalhado vive em help-content.ts; telas sem conteúdo caem no
// fallback (a descrição do nav), então TODA aba tem pelo menos uma explicação.

export type Help = { resumo: string; itens?: string[]; passos?: string[] };

export type HelpResolved = { titulo: string; icon?: string; grupo?: string } & Help;

export function getHelp(slug: string): HelpResolved | null {
  const item = NAV.find((n) => n.slug === slug);
  const rich = (HELP_CONTENT as Record<string, Help>)[slug];
  if (rich) return { titulo: item?.label ?? slug, icon: item?.icon, grupo: item?.group, ...rich };
  if (item) return { titulo: item.label, icon: item.icon, grupo: item.group, resumo: item.description };
  return null;
}

// Todas as telas com ajuda (para o Manual), na ordem do nav.
export function allHelp(): HelpResolved[] {
  return NAV.map((n) => getHelp(n.slug)).filter(Boolean) as HelpResolved[];
}
