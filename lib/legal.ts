// Registro dos documentos jurídicos do GLOP.
// Conteúdo (markdown) em lib/legal-content.generated.ts (de content/legal/*.md).
export type LegalDoc = {
  slug: string;
  title: string;
  short: string;
  tipo: "publico" | "interno";
  categoria: string;
  publicPath?: string;
  icon: string;
  versao: string;
  atualizado: string;
  resumo: string;
};

const V = "0.1 (minuta)";
const D = "2026-07-16";

// Ordem das categorias no hub
export const LEGAL_CATEGORIAS = [
  "Documentos públicos",
  "Contratos & Acordos",
  "Políticas internas",
  "Códigos & Termos",
  "Privacidade & Governança",
];

export const LEGAL_DOCS: LegalDoc[] = [
  // ── Documentos públicos ─────────────────────────────────────────────────
  { slug: "politica-privacidade", title: "Política de Privacidade (LGPD)", short: "Privacidade", tipo: "publico", categoria: "Documentos públicos", publicPath: "/privacidade", icon: "🔒", versao: V, atualizado: D, resumo: "Como o GLOP coleta, usa, compartilha e protege dados pessoais — bases legais, direitos do titular e canais do Encarregado (DPO)." },
  { slug: "termos-de-uso", title: "Termos de Uso", short: "Termos", tipo: "publico", categoria: "Documentos públicos", publicPath: "/termos", icon: "📜", versao: V, atualizado: D, resumo: "Condições gerais de uso da plataforma: objeto, conta, planos, responsabilidades, propriedade intelectual e rescisão." },
  { slug: "politica-cookies", title: "Política de Cookies", short: "Cookies", tipo: "publico", categoria: "Documentos públicos", publicPath: "/cookies", icon: "🍪", versao: V, atualizado: D, resumo: "Cookies e tecnologias similares, categorias, finalidades, duração e como gerenciar o consentimento." },

  // ── Contratos & Acordos ─────────────────────────────────────────────────
  { slug: "contrato-saas", title: "Contrato de Assinatura SaaS", short: "SaaS", tipo: "interno", categoria: "Contratos & Acordos", icon: "📝", versao: V, atualizado: D, resumo: "Licença/assinatura da plataforma para o produtor/lojista: planos, SLA, dados, PI, responsabilidade e rescisão." },
  { slug: "contrato-enterprise", title: "Contrato Enterprise", short: "Enterprise", tipo: "interno", categoria: "Contratos & Acordos", icon: "🏢", versao: V, atualizado: D, resumo: "Contrato de grande porte: escopo customizado, SLA reforçado, onboarding, segurança e condições comerciais." },
  { slug: "contrato-prestacao-servicos", title: "Contrato de Prestação de Serviços", short: "Serviços", tipo: "interno", categoria: "Contratos & Acordos", icon: "🧾", versao: V, atualizado: D, resumo: "Prestação de serviços logísticos/tecnológicos: escopo, prazos, preço, obrigações, responsabilidade e foro." },
  { slug: "contrato-b2b", title: "Contrato B2B", short: "B2B", tipo: "interno", categoria: "Contratos & Acordos", icon: "🤝", versao: V, atualizado: D, resumo: "Contrato empresa-empresa: condições comerciais, confidencialidade, LGPD, SLA e rescisão." },
  { slug: "contrato-b2c", title: "Contrato B2C (Consumidor)", short: "B2C", tipo: "interno", categoria: "Contratos & Acordos", icon: "🛍️", versao: V, atualizado: D, resumo: "Relação com consumidor final sob o CDC: arrependimento, trocas, entrega, atendimento e foro do consumidor." },
  { slug: "contrato-marketplace", title: "Contrato de Marketplace", short: "Marketplace", tipo: "interno", categoria: "Contratos & Acordos", icon: "🏬", versao: V, atualizado: D, resumo: "Sellers/lojistas na plataforma: responsabilidades, comissões, qualidade, CDC e descredenciamento." },
  { slug: "contrato-transportador", title: "Contrato de Transporte", short: "Transporte", tipo: "interno", categoria: "Contratos & Acordos", icon: "🚚", versao: V, atualizado: D, resumo: "Transportador/Correios/última milha: prazos e SLA, frete, seguro, avaria/extravio, rastreio e POD." },
  { slug: "contrato-operador-logistico", title: "Contrato de Operador Logístico (3PL)", short: "3PL", tipo: "interno", categoria: "Contratos & Acordos", icon: "📦", versao: V, atualizado: D, resumo: "Armazenagem, estoque, picking/packing, expedição, KPIs/SLA, seguro e responsabilidade sobre a mercadoria." },
  { slug: "contrato-fornecedor", title: "Contrato de Fornecimento", short: "Fornecedor", tipo: "interno", categoria: "Contratos & Acordos", icon: "🚛", versao: V, atualizado: D, resumo: "Fornecimento: especificações, prazos, preço, qualidade/garantia, compliance e penalidades." },
  { slug: "contrato-parceiro", title: "Contrato de Parceria / Coprodução", short: "Parceria", tipo: "interno", categoria: "Contratos & Acordos", icon: "🤝", versao: V, atualizado: D, resumo: "Coprodutores/afiliados: comissão e split (AppMax), apuração, repasses, dados bancários e confidencialidade." },
  { slug: "contrato-white-label", title: "Contrato White Label", short: "White Label", tipo: "interno", categoria: "Contratos & Acordos", icon: "🏷️", versao: V, atualizado: D, resumo: "Licenciamento sob a marca do parceiro: limites de customização, PI, suporte, dados e rescisão." },
  { slug: "contrato-api", title: "Termo de Uso de API", short: "API", tipo: "interno", categoria: "Contratos & Acordos", icon: "🔌", versao: V, atualizado: D, resumo: "Acesso à API: chaves/segurança, rate limit, usos permitidos/vedados, versionamento e suspensão por abuso." },
  { slug: "contrato-integracao", title: "Termo de Integração", short: "Integração", tipo: "interno", categoria: "Contratos & Acordos", icon: "🔗", versao: V, atualizado: D, resumo: "Webhooks/conectores com pagamentos e e-commerce: credenciais, segurança, disponibilidade e isenções." },
  { slug: "nda", title: "Acordo de Confidencialidade (NDA)", short: "NDA", tipo: "interno", categoria: "Contratos & Acordos", icon: "🤐", versao: V, atualizado: D, resumo: "Sigilo mútuo: informação confidencial, exceções, prazo, devolução/destruição e penalidades." },
  { slug: "sla", title: "Acordo de Nível de Serviço (SLA)", short: "SLA", tipo: "interno", categoria: "Contratos & Acordos", icon: "📶", versao: V, atualizado: D, resumo: "Disponibilidade, tempos de resposta/resolução por severidade, manutenção, créditos e penalidades." },

  // ── Políticas internas ──────────────────────────────────────────────────
  { slug: "politica-seguranca", title: "Política de Segurança da Informação", short: "Segurança", tipo: "interno", categoria: "Políticas internas", icon: "🛡️", versao: V, atualizado: D, resumo: "PSI (ISO 27001/27701, NIST, OWASP): acesso, criptografia, logs, resposta a incidentes e continuidade." },
  { slug: "politica-backup", title: "Política de Backup e Restauração", short: "Backup", tipo: "interno", categoria: "Políticas internas", icon: "💽", versao: V, atualizado: D, resumo: "Tipos e frequência de backup, criptografia, retenção, testes de restauração e RTO/RPO." },
  { slug: "politica-retencao", title: "Política de Retenção de Dados", short: "Retenção", tipo: "interno", categoria: "Políticas internas", icon: "⏳", versao: V, atualizado: D, resumo: "Prazos de guarda por categoria de dado (PII, fiscal, logs), base legal e gatilhos de eliminação." },
  { slug: "politica-descarte", title: "Política de Descarte e Eliminação", short: "Descarte", tipo: "interno", categoria: "Políticas internas", icon: "🗑️", versao: V, atualizado: D, resumo: "Métodos de eliminação segura, anonimização, atendimento ao titular e registro de descarte." },
  { slug: "politica-senhas", title: "Política de Senhas e Autenticação", short: "Senhas", tipo: "interno", categoria: "Políticas internas", icon: "🔑", versao: V, atualizado: D, resumo: "Complexidade, MFA/passkeys, rotação, hash seguro e gestão de credenciais de API." },
  { slug: "politica-acesso", title: "Política de Controle de Acesso", short: "Acesso", tipo: "interno", categoria: "Políticas internas", icon: "🚪", versao: V, atualizado: D, resumo: "Least privilege, RBAC/RLS multi-tenant, provisionamento, revisão de acessos e PAM." },
  { slug: "politica-auditoria", title: "Política de Auditoria e Logs", short: "Auditoria", tipo: "interno", categoria: "Políticas internas", icon: "🧾", versao: V, atualizado: D, resumo: "O que registrar, imutabilidade, retenção de logs, monitoramento (SIEM) e accountability LGPD." },
  { slug: "politica-compliance", title: "Política de Compliance e Integridade", short: "Compliance", tipo: "interno", categoria: "Políticas internas", icon: "⚖️", versao: V, atualizado: D, resumo: "Programa de integridade, Lei Anticorrupção, canal de denúncias, due diligence e sanções." },

  // ── Códigos & Termos ────────────────────────────────────────────────────
  { slug: "codigo-etica", title: "Código de Ética", short: "Ética", tipo: "interno", categoria: "Códigos & Termos", icon: "🕊️", versao: V, atualizado: D, resumo: "Valores, conflitos de interesse, anticorrupção, confidencialidade e canal de ética." },
  { slug: "codigo-conduta", title: "Código de Conduta", short: "Conduta", tipo: "interno", categoria: "Códigos & Termos", icon: "📗", versao: V, atualizado: D, resumo: "Condutas esperadas, uso de sistemas e dados, assédio/discriminação e consequências." },
  { slug: "termo-consentimento", title: "Termo de Consentimento (LGPD)", short: "Consentimento", tipo: "interno", categoria: "Códigos & Termos", icon: "✍️", versao: V, atualizado: D, resumo: "Modelo com finalidade, base legal, prazo, revogação, direitos e registro de aceite (data/IP/hash)." },

  // ── Privacidade & Governança ────────────────────────────────────────────
  { slug: "dpa", title: "Acordo de Tratamento de Dados (DPA)", short: "DPA", tipo: "interno", categoria: "Privacidade & Governança", icon: "🤝", versao: V, atualizado: D, resumo: "Controlador × operador (LGPD art. 39 / GDPR art. 28): obrigações, sub-operadores, incidentes e anexos." },
  { slug: "ropa-ripd", title: "Registro de Operações (ROPA) + RIPD", short: "ROPA / RIPD", tipo: "interno", categoria: "Privacidade & Governança", icon: "🗂️", versao: V, atualizado: D, resumo: "Registro das atividades de tratamento (art. 37) e relatório de impacto das operações de maior risco." },
  { slug: "plano-resposta-incidentes", title: "Plano de Resposta a Incidentes", short: "Incidentes", tipo: "interno", categoria: "Privacidade & Governança", icon: "🚨", versao: V, atualizado: D, resumo: "CSIRT, fases da resposta, playbooks e comunicação à ANPD e aos titulares (LGPD art. 48)." },
  { slug: "mapeamento-dados", title: "Mapeamento de Dados (Data Mapping)", short: "Data Mapping", tipo: "interno", categoria: "Privacidade & Governança", icon: "🗺️", versao: V, atualizado: D, resumo: "Inventário e fluxos de dados pessoais ponta a ponta, por sistema, base legal e transferências." },
  { slug: "matriz-riscos", title: "Matriz de Riscos", short: "Riscos", tipo: "interno", categoria: "Privacidade & Governança", icon: "📊", versao: V, atualizado: D, resumo: "Riscos jurídicos, LGPD, segurança e operacionais: probabilidade × impacto, tratamento e responsáveis." },
  { slug: "plano-continuidade", title: "Plano de Continuidade (PCN/BCP)", short: "Continuidade", tipo: "interno", categoria: "Privacidade & Governança", icon: "♻️", versao: V, atualizado: D, resumo: "ISO 22301: BIA, processos críticos, RTO/RPO, cenários e comunicação de crise." },
  { slug: "plano-recuperacao", title: "Plano de Recuperação de Desastres (DRP)", short: "DRP", tipo: "interno", categoria: "Privacidade & Governança", icon: "🛟", versao: V, atualizado: D, resumo: "Recuperação técnica (Supabase/Netlify), restauração de backups, failover e testes." },
  { slug: "due-diligence", title: "Questionário de Due Diligence", short: "Due Diligence", tipo: "interno", categoria: "Privacidade & Governança", icon: "🔍", versao: V, atualizado: D, resumo: "Avaliação de fornecedores/sub-operadores: segurança, LGPD, certificações e incidentes." },
  { slug: "checklist-auditoria", title: "Checklist de Auditoria (LGPD + Segurança)", short: "Checklist", tipo: "interno", categoria: "Privacidade & Governança", icon: "✅", versao: V, atualizado: D, resumo: "Itens verificáveis por domínio com coluna de conformidade e evidência esperada." },
];

export const findLegal = (slug: string) => LEGAL_DOCS.find((d) => d.slug === slug);
export const legalByPublicPath = (path: string) => LEGAL_DOCS.find((d) => d.publicPath === path);
