// Registro central de módulos (Vol 02–16). A sidebar e as rotas dinâmicas leem daqui.
export type NavItem = {
  slug: string;
  label: string;
  icon: string;
  group: string;
  vol: number;
  description: string;
};

export const NAV: NavItem[] = [
  { slug: "dashboard", label: "Cockpit Executivo", icon: "◎", group: "Visão Geral", vol: 16, description: "KPIs cross-módulo em tempo real" },
  { slug: "control-tower", label: "Torre de Controle", icon: "⛭", group: "Visão Geral", vol: 14, description: "Eventos, SLA, alertas e exceções" },
  { slug: "logia", label: "LOGIA (IA)", icon: "✦", group: "Visão Geral", vol: 15, description: "Insights, previsões e planos de ação" },

  { slug: "produtos", label: "Cadastro Mestre", icon: "▤", group: "Estoque & Armazém", vol: 2, description: "SKU, categorias, fornecedores, embalagens" },
  { slug: "estoque", label: "Estoque Inteligente", icon: "▦", group: "Estoque & Armazém", vol: 10, description: "Saldos, curva ABC, ponto de pedido" },
  { slug: "wms", label: "WMS / Armazém", icon: "⌗", group: "Estoque & Armazém", vol: 3, description: "Endereçamento, tarefas, ondas, packing" },
  { slug: "inventario", label: "Inventário & Rastreio", icon: "⎗", group: "Estoque & Armazém", vol: 11, description: "Contagens cíclicas e genealogia de lote" },

  { slug: "compras", label: "Compras", icon: "🛒", group: "Suprimentos", vol: 6, description: "Requisição → cotação → pedido → recebimento" },
  { slug: "demanda", label: "Demand Planning", icon: "📈", group: "Suprimentos", vol: 7, description: "Histórico, previsões e S&OP" },
  { slug: "mrp", label: "MRP / APS", icon: "⚙", group: "Suprimentos", vol: 8, description: "BOM, necessidades e capacidade" },
  { slug: "producao", label: "Produção / PCP", icon: "🏭", group: "Suprimentos", vol: 9, description: "Ordens, apontamentos e consumo" },
  { slug: "mes", label: "MES / Chão de Fábrica", icon: "🕹", group: "Suprimentos", vol: 6, description: "Execução em tempo real, apontamentos, paradas e OEE" },
  { slug: "manufatura", label: "Manufatura (MFG)", icon: "🏗", group: "Suprimentos", vol: 7, description: "Governança da produção: receitas, linhas, rastreabilidade" },

  { slug: "qualidade", label: "QMS / Qualidade", icon: "✔", group: "Qualidade & Conformidade", vol: 8, description: "Inspeções, NC, CAPA, auditorias, FMEA, liberação de lote" },
  { slug: "lims", label: "LIMS / Laboratório", icon: "🧪", group: "Suprimentos", vol: 9, description: "Amostras, ensaios, especificações e liberação de lote" },
  { slug: "manutencao", label: "EAM / Manutenção", icon: "🔧", group: "Suprimentos", vol: 10, description: "Ativos, ordens de serviço, preventiva, MTTR/MTBF" },

  { slug: "expedicao", label: "Expedição", icon: "📦", group: "Distribuição", vol: 12, description: "Pedidos, picking, packing e embarque" },
  { slug: "tms", label: "TMS / Transporte", icon: "🚚", group: "Distribuição", vol: 4, description: "Transportadoras, fretes, rotas e tracking" },
  { slug: "yms", label: "YMS / Pátio & Docas", icon: "🏗", group: "Distribuição", vol: 5, description: "Docas, agendamento e pátio" },
  { slug: "distribuicao", label: "Distribuição & Last Mile", icon: "🗺", group: "Distribuição", vol: 13, description: "Transferências, cross-dock, entregas" },
  { slug: "devolucoes", label: "Devoluções (RMA)", icon: "↩", group: "Distribuição", vol: 14, description: "Logística reversa, conferência, reintegração ao estoque" },
  { slug: "postagens", label: "Torre de Postagens", icon: "🛰", group: "Distribuição", vol: 15, description: "Correios/transportadoras: etiqueta→postagem→1ª movimentação, SLA, alertas" },

  { slug: "financeiro", label: "Financeiro / Tesouraria", icon: "💰", group: "Financeiro", vol: 11, description: "Contas a pagar/receber, bancos, fluxo de caixa" },
  { slug: "controladoria", label: "Controladoria & Custos", icon: "📊", group: "Financeiro", vol: 12, description: "DRE gerencial, custos, margens, rateios, variações" },
];

export const NAV_GROUPS = Array.from(new Set(NAV.map((n) => n.group)));
export const findNav = (slug: string) => NAV.find((n) => n.slug === slug);
