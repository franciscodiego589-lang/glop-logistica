// Registro dos documentos jurídicos do GLOP (núcleo essencial).
// O conteúdo (markdown) fica em lib/legal-content.generated.ts (gerado a partir de content/legal/*.md).
export type LegalDoc = {
  slug: string;
  title: string;
  short: string;          // rótulo curto p/ o card
  tipo: "publico" | "interno";
  publicPath?: string;    // rota pública (sem login), quando aplicável
  icon: string;
  versao: string;
  atualizado: string;     // ISO (data da minuta)
  resumo: string;
};

export const LEGAL_DOCS: LegalDoc[] = [
  {
    slug: "politica-privacidade",
    title: "Política de Privacidade (LGPD)",
    short: "Privacidade",
    tipo: "publico",
    publicPath: "/privacidade",
    icon: "🔒",
    versao: "0.1 (minuta)",
    atualizado: "2026-07-16",
    resumo: "Como o GLOP coleta, usa, compartilha e protege dados pessoais — bases legais, direitos do titular e canais do Encarregado (DPO).",
  },
  {
    slug: "termos-de-uso",
    title: "Termos de Uso",
    short: "Termos",
    tipo: "publico",
    publicPath: "/termos",
    icon: "📜",
    versao: "0.1 (minuta)",
    atualizado: "2026-07-16",
    resumo: "Condições gerais de uso da plataforma: objeto, conta, planos, responsabilidades, propriedade intelectual, limitação de responsabilidade e rescisão.",
  },
  {
    slug: "politica-cookies",
    title: "Política de Cookies",
    short: "Cookies",
    tipo: "publico",
    publicPath: "/cookies",
    icon: "🍪",
    versao: "0.1 (minuta)",
    atualizado: "2026-07-16",
    resumo: "Cookies e tecnologias similares usados pelo GLOP, categorias, finalidades, duração e como gerenciar o consentimento.",
  },
  {
    slug: "politica-seguranca",
    title: "Política de Segurança da Informação",
    short: "Segurança",
    tipo: "interno",
    icon: "🛡️",
    versao: "0.1 (minuta)",
    atualizado: "2026-07-16",
    resumo: "PSI corporativa alinhada a ISO 27001/27701, NIST e OWASP: controle de acesso, criptografia, logs, resposta a incidentes e continuidade.",
  },
  {
    slug: "dpa",
    title: "Acordo de Tratamento de Dados (DPA)",
    short: "DPA",
    tipo: "interno",
    icon: "🤝",
    versao: "0.1 (minuta)",
    atualizado: "2026-07-16",
    resumo: "Acordo controlador × operador (LGPD art. 39 / GDPR art. 28): obrigações, sub-operadores, incidentes, auditoria e anexos técnicos.",
  },
  {
    slug: "ropa-ripd",
    title: "Registro de Operações (ROPA) + Relatório de Impacto (RIPD)",
    short: "ROPA / RIPD",
    tipo: "interno",
    icon: "🗂️",
    versao: "0.1 (minuta)",
    atualizado: "2026-07-16",
    resumo: "Registro das atividades de tratamento (art. 37) e relatório de impacto (RIPD/DPIA) das operações de maior risco, com matriz de riscos.",
  },
];

export const findLegal = (slug: string) => LEGAL_DOCS.find((d) => d.slug === slug);
export const legalByPublicPath = (path: string) => LEGAL_DOCS.find((d) => d.publicPath === path);
