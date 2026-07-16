// Registro da Central de Relatórios. Cada relatório é um RPC auto-descritivo.
export type Relatorio = {
  slug: string;
  title: string;
  icon: string;
  rpc: string;
  categoria: string;
  periodo: boolean;   // tem seletor de período (?dias=)
  diasPadrao: number;
  resumo: string;
};

export const RELATORIOS: Relatorio[] = [
  { slug: "vendas", title: "Vendas", icon: "💰", rpc: "rel_vendas", categoria: "Comercial & Financeiro", periodo: true, diasPadrao: 30, resumo: "Receita, pedidos, ticket médio, por canal, estado, produto e status — com série diária e top compradores." },
  { slug: "coproducao", title: "Coprodução & Comissões", icon: "🤝", rpc: "rel_coproducao", categoria: "Comercial & Financeiro", periodo: false, diasPadrao: 3650, resumo: "Comissões por coprodutor, status de repasse e lotes — total, pendente e líquido a repassar." },
  { slug: "fiscal", title: "Fiscal & NF-e", icon: "🧾", rpc: "rel_fiscal", categoria: "Comercial & Financeiro", periodo: true, diasPadrao: 90, resumo: "Emissões de NF-e por status, valor total, erros e emissões por dia." },
  { slug: "operacao", title: "Operacional (Pedidos)", icon: "📦", rpc: "rel_operacao", categoria: "Operação & Logística", periodo: true, diasPadrao: 30, resumo: "Funil por status, backlog, exceções (sem plano/endereço/bloqueio) e movimentações por etapa e por dia." },
  { slug: "logistica", title: "Logística & Envios", icon: "🚚", rpc: "rel_logistica", categoria: "Operação & Logística", periodo: false, diasPadrao: 90, resumo: "Envios por status e UF, prepostagens, eventos de rastreio e frete pago." },
  { slug: "integracoes", title: "Integrações & Webhooks", icon: "🔗", rpc: "rel_integracoes", categoria: "Operação & Logística", periodo: true, diasPadrao: 30, resumo: "Eventos por plataforma e tipo, processados x pendentes, assinatura inválida e por dia." },
  { slug: "ia", title: "Inteligência (IA / LOGIA)", icon: "✧", rpc: "rel_ia", categoria: "Inteligência & Governança", periodo: true, diasPadrao: 90, resumo: "Insights por tipo e severidade, decisões por categoria e risco, execuções e economia estimada." },
  { slug: "auditoria", title: "Auditoria & Governança", icon: "🛡️", rpc: "rel_auditoria", categoria: "Inteligência & Governança", periodo: true, diasPadrao: 30, resumo: "Ações por tabela e tipo (inserção/atualização/exclusão) e por dia — trilha de auditoria." },
];

export const RELATORIO_CATEGORIAS = ["Comercial & Financeiro", "Operação & Logística", "Inteligência & Governança"];
export const findRelatorio = (slug: string) => RELATORIOS.find((r) => r.slug === slug);
