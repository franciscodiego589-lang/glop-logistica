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
  { slug: "auditoria", label: "Auditoria & Custos (LAIS)", icon: "🔎", group: "Visão Geral", vol: 18, description: "Auditoria contínua, custos, desperdícios, riscos, IGEL" },
  { slug: "engenharia-logistica", label: "Engenharia & Rede (LPND)", icon: "🗺", group: "Visão Geral", vol: 21, description: "Digital twin, mapa de demanda, IA de localização de CD, ROI/payback" },

  { slug: "produtos", label: "Cadastro Mestre", icon: "▤", group: "Estoque & Armazém", vol: 2, description: "SKU, categorias, fornecedores, embalagens" },
  { slug: "estoque", label: "Estoque Inteligente", icon: "▦", group: "Estoque & Armazém", vol: 10, description: "Saldos, curva ABC, ponto de pedido" },
  { slug: "wms", label: "WMS / Armazém", icon: "⌗", group: "Estoque & Armazém", vol: 3, description: "Endereçamento, tarefas, ondas, packing" },
  { slug: "operacao-armazem", label: "WMS Enterprise (IA)", icon: "🏬", group: "Estoque & Armazém", vol: 22, description: "Slotting IA, putaway, reabastecimento, produtividade, ESG, congestão" },
  { slug: "inventario", label: "Inventário & Rastreio", icon: "⎗", group: "Estoque & Armazém", vol: 11, description: "Contagens cíclicas e genealogia de lote" },
  { slug: "ativos-retornaveis", label: "Ativos Retornáveis (RAMS)", icon: "♻️", group: "Estoque & Armazém", vol: 24, description: "Pallets/containers/gaiolas: empréstimos, retenção, manutenção, ESG" },

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
  { slug: "central-expedicao", label: "Central de Expedição (IA)", icon: "🧠", group: "Distribuição", vol: 18, description: "Ondas, escolha de transportadora, embalagem ótima, cargas, gargalos" },
  { slug: "tms", label: "TMS / Transporte", icon: "🚚", group: "Distribuição", vol: 4, description: "Transportadoras, fretes, rotas e tracking" },
  { slug: "frota", label: "TMS Enterprise / Frota", icon: "🚛", group: "Distribuição", vol: 20, description: "Viagens, custos, combustível, manutenção, leilão de fretes, carbono" },
  { slug: "yms", label: "YMS / Pátio & Docas", icon: "🏗", group: "Distribuição", vol: 5, description: "Docas, agendamento e pátio" },
  { slug: "patio", label: "YMS Enterprise (Pátio)", icon: "🚧", group: "Distribuição", vol: 23, description: "Portaria/OCR, balanças, carga/descarga, containers, lacres, AI dock scheduler" },
  { slug: "distribuicao", label: "Distribuição & Last Mile", icon: "🗺", group: "Distribuição", vol: 13, description: "Transferências, cross-dock, entregas" },
  { slug: "devolucoes", label: "Devoluções (RMA)", icon: "↩", group: "Distribuição", vol: 14, description: "Logística reversa, conferência, reintegração ao estoque" },
  { slug: "pos-venda", label: "Pós-Venda & CLX", icon: "💬", group: "Distribuição", vol: 19, description: "Portal do cliente, rastreio público, ocorrências, NPS/CSAT" },
  { slug: "postagens", label: "Torre de Postagens", icon: "🛰", group: "Distribuição", vol: 15, description: "Correios/transportadoras: etiqueta→postagem→1ª movimentação, SLA, alertas" },
  { slug: "transporte", label: "Torre de Transporte", icon: "🌐", group: "Distribuição", vol: 16, description: "Monitoramento em trânsito, ETA, score de risco, ocorrências, OTIF" },
  { slug: "correios", label: "Correios (CMS)", icon: "📮", group: "Distribuição", vol: 17, description: "Contratos, PLP, objetos, SRO, auditoria de fretes, simulador, SLA" },

  { slug: "financeiro", label: "Financeiro / Tesouraria", icon: "💰", group: "Financeiro", vol: 11, description: "Contas a pagar/receber, bancos, fluxo de caixa" },
  { slug: "controladoria", label: "Controladoria & Custos", icon: "📊", group: "Financeiro", vol: 12, description: "DRE gerencial, custos, margens, rateios, variações" },
];

export const NAV_GROUPS = Array.from(new Set(NAV.map((n) => n.group)));
export const findNav = (slug: string) => NAV.find((n) => n.slug === slug);
