// Registro central de módulos — FASE 1: Operação Logística Global.
// ERP 100% especializado em Logística, Supply Chain, WMS, TMS, YMS e Torre de Controle.
// A sidebar e as rotas dinâmicas leem daqui.
export type NavItem = {
  slug: string;
  label: string;
  icon: string;
  group: string;
  vol: number;
  description: string;
};

export const NAV: NavItem[] = [
  // ── Visão Geral & Inteligência Logística ──────────────────────────────────
  { slug: "dashboard", label: "Cockpit Executivo", icon: "◎", group: "Visão Geral & Inteligência", vol: 16, description: "KPIs logísticos cross-módulo em tempo real" },
  { slug: "comando", label: "Command Center (tempo real)", icon: "◉", group: "Visão Geral & Inteligência", vol: 5, description: "Mission control: estado vivo da operação, central de alertas, sala de crise" },
  { slug: "control-tower", label: "Logistics Control Tower", icon: "⛭", group: "Visão Geral & Inteligência", vol: 5, description: "Eventos, SLA, alertas e exceções da cadeia logística" },
  { slug: "ia-central", label: "LAIOS — Logistics AI OS", icon: "✦", group: "Visão Geral & Inteligência", vol: 15, description: "Cérebro operacional: multiagentes (WMS/TMS/YMS/Correios), IA preditiva/prescritiva, memória corporativa" },
  { slug: "logia", label: "LOGIA (Insights)", icon: "✧", group: "Visão Geral & Inteligência", vol: 15, description: "Insights, previsões e planos de ação logísticos" },
  { slug: "analytics", label: "Logistics Data Platform (BI)", icon: "📈", group: "Visão Geral & Inteligência", vol: 16, description: "Data lake/warehouse logístico, catálogo de KPIs, forecast, governança de dados" },
  { slug: "auditoria", label: "Auditoria Logística & Custos", icon: "🔎", group: "Visão Geral & Inteligência", vol: 6, description: "Auditoria de fretes/operacional, custos, rentabilidade, riscos, compliance logístico, score" },
  { slug: "engenharia-logistica", label: "Logistics Planning & Rede", icon: "🗺", group: "Visão Geral & Inteligência", vol: 10, description: "Digital twin, mapa de demanda, IA de localização de CD, simulações, ROI/payback" },

  // ── Fluxo Operacional (ponto de entrada do fluxo mestre) ──────────────────
  { slug: "pedidos-logisticos", label: "Pedidos Logísticos (LOM)", icon: "🧾", group: "Fluxo Operacional", vol: 1, description: "Domínio 01: demanda logística, validação (ATP), planejamento, reserva, máquina das 17 etapas e barramento de eventos" },

  // ── Estoque & Armazém (WMS) ───────────────────────────────────────────────
  { slug: "produtos", label: "Cadastro Mestre (SKU)", icon: "▤", group: "Estoque & Armazém", vol: 11, description: "SKU, dimensões, peso, categorias, fornecedores, embalagens" },
  { slug: "estoque", label: "Estoque Inteligente", icon: "▦", group: "Estoque & Armazém", vol: 11, description: "Saldos, curva ABC, ponto de pedido" },
  { slug: "wms", label: "WMS / Armazém", icon: "⌗", group: "Estoque & Armazém", vol: 11, description: "Endereçamento, tarefas, ondas, packing" },
  { slug: "operacao-armazem", label: "WMS Enterprise (IA)", icon: "🏬", group: "Estoque & Armazém", vol: 11, description: "Slotting IA, putaway, reabastecimento, RFID, robótica, produtividade, ESG" },
  { slug: "inventario", label: "Inventário & Rastreio", icon: "⎗", group: "Estoque & Armazém", vol: 11, description: "Contagens cíclicas e genealogia de lote" },
  { slug: "ativos-retornaveis", label: "Ativos Retornáveis (RAMS)", icon: "♻️", group: "Estoque & Armazém", vol: 13, description: "Pallets/containers/gaiolas/IBCs: empréstimos, retenção, manutenção, ESG" },

  // ── Suprimentos & Abastecimento ───────────────────────────────────────────
  { slug: "compras", label: "Suprimentos / Compras", icon: "🛒", group: "Suprimentos", vol: 10, description: "Requisição → cotação → pedido → recebimento" },
  { slug: "demanda", label: "Demand Planning", icon: "📈", group: "Suprimentos", vol: 10, description: "Histórico, previsões e S&OP" },
  { slug: "manutencao", label: "EAM / Manutenção de Frota & Ativos", icon: "🔧", group: "Suprimentos", vol: 9, description: "Ativos, ordens de serviço, preventiva, MTTR/MTBF" },

  // ── Expedição & Distribuição ──────────────────────────────────────────────
  { slug: "expedicao", label: "Expedição", icon: "📦", group: "Expedição & Distribuição", vol: 7, description: "Pedidos, picking, packing e embarque" },
  { slug: "central-expedicao", label: "Smart Shipping Center (IA)", icon: "🧠", group: "Expedição & Distribuição", vol: 7, description: "Wave picking, escolha de transportadora, embalagem ótima, docas, cargas, gargalos" },
  { slug: "distribuicao", label: "Distribuição & Last Mile", icon: "🗺", group: "Expedição & Distribuição", vol: 7, description: "Transferências, cross-dock, hubs, entregas" },
  { slug: "ultima-milha", label: "Última Milha (LMDP)", icon: "🛵", group: "Expedição & Distribuição", vol: 40, description: "Roteirização inteligente, paradas, POD, geocercas, OTIF/OTD" },
  { slug: "encomendas", label: "Encomendas & Volumes (PMS)", icon: "📦", group: "Expedição & Distribuição", vol: 42, description: "LPN/etiquetas, scan events, rastreabilidade, hubs, lockers, consolidação" },
  { slug: "cadeia-fria", label: "Cadeia Fria (CCLMS)", icon: "❄️", group: "Expedição & Distribuição", vol: 43, description: "Monitoramento térmico, sensores IoT, integridade, alarmes, cargas sensíveis" },
  { slug: "devolucoes", label: "RMA & Logística Reversa", icon: "↩", group: "Expedição & Distribuição", vol: 1, description: "Devoluções, conferência, quarentena, retrabalho, reintegração ao estoque" },
  { slug: "postagens", label: "Torre de Postagens", icon: "🛰", group: "Expedição & Distribuição", vol: 2, description: "Etiqueta→PLP→postagem→1ª movimentação, objetos parados, CEP inválido, SLA, alertas" },

  // ── Transporte ────────────────────────────────────────────────────────────
  { slug: "tms", label: "TMS / Transporte", icon: "🚚", group: "Transporte & Pátio", vol: 9, description: "Transportadoras, fretes, rotas e tracking" },
  { slug: "frota", label: "TMS Enterprise / Frota", icon: "🚛", group: "Transporte & Pátio", vol: 9, description: "Viagens, custos, combustível, telemetria, manutenção, leilão de fretes, carbono" },
  { slug: "transporte", label: "Torre de Transporte", icon: "🌐", group: "Transporte & Pátio", vol: 3, description: "Monitoramento em trânsito, ETA, score de risco, ocorrências, heat map, OTIF" },
  { slug: "correios", label: "Correios (Gestão Enterprise)", icon: "📮", group: "Transporte & Pátio", vol: 4, description: "Contratos, cartões de postagem, PLP, objetos, SRO, auditoria de fretes, SLA" },
  { slug: "transportadoras", label: "Transportadoras (CMP)", icon: "🚛", group: "Transporte & Pátio", vol: 41, description: "SRM: homologação, contratos, documentos, scorecard, ranking, ocorrências, compliance" },
  { slug: "auditoria-fretes", label: "Auditoria de Fretes & Custos (FACMS)", icon: "🧮", group: "Transporte & Pátio", vol: 36, description: "Auditoria automática cobrado×esperado, faturas/CT-e, glosas, custos logísticos, simulador de transportadora" },
  { slug: "yms", label: "YMS / Pátio & Docas", icon: "🏗", group: "Transporte & Pátio", vol: 12, description: "Docas, agendamento e pátio" },
  { slug: "patio", label: "YMS Enterprise (Pátio)", icon: "🚧", group: "Transporte & Pátio", vol: 12, description: "Portaria/OCR, balanças, filas, carga/descarga, containers, lacres, AI dock scheduler" },

  // ── Comércio Exterior ─────────────────────────────────────────────────────
  { slug: "comex", label: "Global Trade Management (GTM)", icon: "🌍", group: "Comércio Exterior", vol: 14, description: "Importação/exportação, Incoterms, portos/aeroportos, aduana, containers, drawback, RECOF" },
  { slug: "embarques-internacionais", label: "Embarques Internacionais (GTM Ops)", icon: "🚢", group: "Comércio Exterior", vol: 44, description: "Embarques multimodais, bookings, agentes logísticos, incoterms, eventos internacionais, timeline" },

  // ── Cliente & Pós-Venda ───────────────────────────────────────────────────
  { slug: "portal-cliente", label: "Portal do Cliente Logístico", icon: "💬", group: "Cliente & Pós-Venda", vol: 8, description: "Timeline, tracking, ETA, notificações, comprovantes, self-service, devoluções, NPS" },
  { slug: "pos-venda", label: "Pós-Venda & Ocorrências (CLX)", icon: "🎧", group: "Cliente & Pós-Venda", vol: 8, description: "Rastreio público, ocorrências, chamados/SLA, NPS/CSAT" },

  // ── Plataforma & Governança (infra transversal) ───────────────────────────
  { slug: "processos", label: "BPM & Workflows", icon: "🔀", group: "Plataforma", vol: 16, description: "Motor de processos: aprovações multinível, regras de decisão (DMN), SLA, eventos" },
  { slug: "documentos", label: "Documentos (ECM / GED)", icon: "🗂", group: "Plataforma", vol: 16, description: "Repositório, versionamento, check-in/out, assinaturas eletrônicas, retenção, busca" },
  { slug: "mdm", label: "Governança de Dados (MDM)", icon: "🧬", group: "Plataforma", vol: 16, description: "Fonte única da verdade: qualidade de dados, deduplicação, linhagem, glossário" },
  { slug: "integracoes", label: "Integrações (iPaaS)", icon: "🔌", group: "Plataforma", vol: 16, description: "API Gateway, conectores, event bus, webhooks, fila com retry/DLQ, ETL, chaves de API" },
  { slug: "seguranca", label: "Identidade & Segurança (IAM)", icon: "🛡", group: "Plataforma", vol: 16, description: "Zero Trust, MFA, sessões, PAM, detecção de ameaças, incidentes, certificação de acessos" },
  { slug: "admin", label: "Administração da Plataforma", icon: "⚙", group: "Plataforma", vol: 16, description: "Config center (rollback), feature flags, multimoeda, multilíngue, módulos, licenças" },
  { slug: "dispositivos", label: "Super App & Dispositivos", icon: "📲", group: "Plataforma", vol: 16, description: "PWA instalável, dispositivos, sync offline, push, modos operacionais (coletor/motorista)" },
];

export const NAV_GROUPS = Array.from(new Set(NAV.map((n) => n.group)));
export const findNav = (slug: string) => NAV.find((n) => n.slug === slug);
