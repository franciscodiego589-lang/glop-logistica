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
  { slug: "consolidado", title: "Visão Executiva Consolidada", icon: "📈", rpc: "rel_consolidado", categoria: "Visão Geral", periodo: true, diasPadrao: 30, resumo: "Um só painel com os indicadores de todos os módulos: vendas, operação, coprodução, integrações, fiscal e IA — mais os pontos de atenção." },
  { slug: "vendas", title: "Vendas", icon: "💰", rpc: "rel_vendas", categoria: "Comercial & Financeiro", periodo: true, diasPadrao: 30, resumo: "Receita, pedidos, ticket médio, por canal, estado, produto e status — com série diária e top compradores." },
  { slug: "clientes", title: "Clientes — LTV & Recompra", icon: "👥", rpc: "rel_clientes", categoria: "Comercial & Financeiro", periodo: true, diasPadrao: 365, resumo: "Compradores únicos, recorrentes, taxa de recompra, LTV médio e ranking de clientes por valor." },
  { slug: "abc", title: "Curva ABC de Produtos", icon: "🔤", rpc: "rel_abc", categoria: "Comercial & Financeiro", periodo: true, diasPadrao: 90, resumo: "Classifica produtos por receita acumulada (A/B/C) — onde focar estoque e negociação." },
  { slug: "regioes", title: "Vendas por Região", icon: "🗺", rpc: "rel_regioes", categoria: "Operação & Logística", periodo: true, diasPadrao: 90, resumo: "Pedidos e receita por UF e cidade — onde você mais vende e entrega." },
  { slug: "producao", title: "Produção & Validade", icon: "🏭", rpc: "rel_producao", categoria: "Operação & Logística", periodo: false, diasPadrao: 0, resumo: "Ordens de produção por status, lotes por status e alerta de vencimento (vencidos e vencendo em 30/90 dias)." },
  { slug: "mrp", title: "MRP — Necessidade de Insumos", icon: "🧪", rpc: "rel_mrp", categoria: "Operação & Logística", periodo: true, diasPadrao: 30, resumo: "A partir das vendas × ficha técnica, calcula quanto comprar de cada insumo e o custo estimado." },
  { slug: "inventario", title: "Inventário — Divergências", icon: "📋", rpc: "rel_inventario", categoria: "Operação & Logística", periodo: false, diasPadrao: 0, resumo: "Compara a contagem física com o sistema e lista as divergências por produto." },
  { slug: "atendimento", title: "Atendimento / SAC", icon: "🎧", rpc: "rel_atendimento", categoria: "Operação & Logística", periodo: true, diasPadrao: 30, resumo: "Chamados por status, canal e prioridade — em aberto, urgentes e resolvidos." },
  { slug: "anomalias", title: "Detecção de Anomalias", icon: "🚨", rpc: "rel_anomalias", categoria: "Inteligência & Governança", periodo: true, diasPadrao: 30, resumo: "Pedidos de valor atípico, sem CPF, endereço incompleto e mesmo CPF repetido — sinais de fraude/erro." },
  { slug: "lucro", title: "Lucro Real por Pedido", icon: "📈", rpc: "rel_lucro", categoria: "Comercial & Financeiro", periodo: true, diasPadrao: 30, resumo: "Conciliação: receita − comissões − CMV − frete − taxas − despesas = resultado. Lucro por produto e canal (requer custos cadastrados)." },
  { slug: "coproducao", title: "Coprodução & Comissões", icon: "🤝", rpc: "rel_coproducao", categoria: "Comercial & Financeiro", periodo: false, diasPadrao: 3650, resumo: "Comissões por coprodutor, status de repasse e lotes — total, pendente e líquido a repassar." },
  { slug: "fiscal", title: "Fiscal & NF-e", icon: "🧾", rpc: "rel_fiscal", categoria: "Comercial & Financeiro", periodo: true, diasPadrao: 90, resumo: "Emissões de NF-e por status, valor total, erros e emissões por dia." },
  { slug: "operacao", title: "Operacional (Pedidos)", icon: "📦", rpc: "rel_operacao", categoria: "Operação & Logística", periodo: true, diasPadrao: 30, resumo: "Funil por status, backlog, exceções (sem plano/endereço/bloqueio) e movimentações por etapa e por dia." },
  { slug: "logistica", title: "Logística & Envios", icon: "🚚", rpc: "rel_logistica", categoria: "Operação & Logística", periodo: false, diasPadrao: 90, resumo: "Envios por status e UF, prepostagens, eventos de rastreio e frete pago." },
  { slug: "integracoes", title: "Integrações & Webhooks", icon: "🔗", rpc: "rel_integracoes", categoria: "Operação & Logística", periodo: true, diasPadrao: 30, resumo: "Eventos por plataforma e tipo, processados x pendentes, assinatura inválida e por dia." },
  { slug: "ia", title: "Inteligência (IA / LOGIA)", icon: "✧", rpc: "rel_ia", categoria: "Inteligência & Governança", periodo: true, diasPadrao: 90, resumo: "Insights por tipo e severidade, decisões por categoria e risco, execuções e economia estimada." },
  { slug: "auditoria", title: "Auditoria & Governança", icon: "🛡️", rpc: "rel_auditoria", categoria: "Inteligência & Governança", periodo: true, diasPadrao: 30, resumo: "Ações por tabela e tipo (inserção/atualização/exclusão) e por dia — trilha de auditoria." },
];

export const RELATORIO_CATEGORIAS = ["Visão Geral", "Comercial & Financeiro", "Operação & Logística", "Inteligência & Governança"];
export const findRelatorio = (slug: string) => RELATORIOS.find((r) => r.slug === slug);
