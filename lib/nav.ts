// Registro central de módulos. A sidebar (accordion) e as rotas dinâmicas leem daqui.
// As telas são organizadas em 12 categorias de negócio (menu sanfona).
export type NavItem = {
  slug: string;
  label: string;
  icon: string;
  group: string;
  vol: number;
  description: string;
};

// Categorias de topo do menu (ordem + ícone do cabeçalho do accordion).
export const NAV_GROUP_META: { name: string; icon: string }[] = [
  { name: "Início", icon: "🏠" },
  { name: "Atendimento", icon: "🩺" },
  { name: "Comercial & Marketing", icon: "📣" },
  { name: "Catálogo & Equipe", icon: "✴️" },
  { name: "Estoque & Equipamentos", icon: "📦" },
  { name: "Financeiro", icon: "💰" },
  { name: "Fiscal & Tributos", icon: "📋" },
  { name: "Controladoria", icon: "🎛️" },
  { name: "Relatórios & IA", icon: "📊" },
  { name: "Governança & Compliance", icon: "🛡️" },
  { name: "Administração", icon: "⚙️" },
  { name: "Ajuda", icon: "📖" },
];

export const NAV: NavItem[] = [
  // ── 🏠 Início ──────────────────────────────────────────────────────────────
  { slug: "dashboard", label: "Cockpit Executivo", icon: "◎", group: "Início", vol: 16, description: "KPIs logísticos cross-módulo em tempo real" },
  { slug: "comando", label: "Command Center (tempo real)", icon: "◉", group: "Início", vol: 5, description: "Mission control: estado vivo da operação, central de alertas, sala de crise" },

  // ── 🩺 Atendimento ─────────────────────────────────────────────────────────
  { slug: "portal-cliente", label: "Portal do Cliente Logístico", icon: "💬", group: "Atendimento", vol: 8, description: "Timeline, tracking, ETA, notificações, comprovantes, self-service, devoluções, NPS" },
  { slug: "pos-venda", label: "Pós-Venda & Ocorrências (CLX)", icon: "🎧", group: "Atendimento", vol: 8, description: "Rastreio público, ocorrências, chamados/SLA, NPS/CSAT" },
  { slug: "comunicacao", label: "Comunicação (Email/WhatsApp)", icon: "📣", group: "Atendimento", vol: 58, description: "Logs de e-mail e WhatsApp de rastreio ao comprador + templates editáveis (email/WhatsApp/carteiro)" },
  { slug: "rastreio", label: "Portal de Rastreio (público)", icon: "🌍", group: "Atendimento", vol: 69, description: "Página pública que o comprador usa pra acompanhar o pedido pelo código de rastreio — cobre pedidos logísticos e pedidos de loja (Correios)" },
  { slug: "devolucoes", label: "RMA & Logística Reversa", icon: "↩", group: "Atendimento", vol: 1, description: "Devoluções, conferência, quarentena, retrabalho, reintegração ao estoque" },

  // ── 📣 Comercial & Marketing ───────────────────────────────────────────────
  { slug: "integracoes-lojas", label: "Puxar Pedidos de Lojas (Monetizze…)", icon: "🛒", group: "Comercial & Marketing", vol: 53, description: "Cole a chave da API da plataforma (Monetizze/Hotmart/Kiwify/Shopify/ML) e puxe todos os pedidos. Ingestão sem duplicar, multi-produtor" },
  { slug: "ecommerce-hub", label: "E-commerce — Lojas & Chaves API", icon: "🛍", group: "Comercial & Marketing", vol: 67, description: "Conecte qualquer e-commerce (Shopify, WooCommerce, Nuvemshop, VTEX, Tray, Yampi…): cole a chave da API, teste a conexão e puxe os pedidos" },
  { slug: "coproducao", label: "Coprodução & Split", icon: "🤝", group: "Comercial & Marketing", vol: 54, description: "Coprodutores, regras de comissão, apuração de vendas, repasses por período e split de pagamento (AppMax)" },
  { slug: "planos-precos", label: "Planos & Preços do Produtor", icon: "💰", group: "Comercial & Marketing", vol: 57, description: "Planos por plataforma, tabelas de preço por produto/faixa, regras de embalagem e faixas de frete/peso" },
  { slug: "importacao-pedidos", label: "Importação Inteligente (SOIDI)", icon: "📥", group: "Comercial & Marketing", vol: 52, description: "Importar pedidos de qualquer origem, OCR/document intelligence, validação CPF/CNPJ/CEP, normalização, dedup, promoção" },
  { slug: "pedidos-logisticos", label: "Pedidos Logísticos (LOM)", icon: "🧾", group: "Comercial & Marketing", vol: 1, description: "Domínio 01: demanda logística, validação (ATP), planejamento, reserva, máquina das 17 etapas e barramento de eventos" },

  // ── ✴️ Catálogo & Equipe ───────────────────────────────────────────────────
  { slug: "produtos", label: "Cadastro Mestre (SKU)", icon: "▤", group: "Catálogo & Equipe", vol: 11, description: "SKU, dimensões, peso, categorias, fornecedores, embalagens" },
  { slug: "mdm", label: "Governança de Dados (MDM)", icon: "🧬", group: "Catálogo & Equipe", vol: 16, description: "Fonte única da verdade: qualidade de dados, deduplicação, linhagem, glossário" },

  // ── 📦 Estoque & Equipamentos ──────────────────────────────────────────────
  { slug: "estoque", label: "Estoque Inteligente", icon: "▦", group: "Estoque & Equipamentos", vol: 11, description: "Saldos, curva ABC, ponto de pedido" },
  { slug: "estoque-logistico", label: "Estoque Logístico", icon: "🗄", group: "Estoque & Equipamentos", vol: 61, description: "Produtos, locais, movimentos, baixa automática e registros de estoque (Logística Rodrigo)" },
  { slug: "wms", label: "WMS / Armazém", icon: "⌗", group: "Estoque & Equipamentos", vol: 11, description: "Endereçamento, tarefas, ondas, packing" },
  { slug: "operacao-armazem", label: "WMS Enterprise (IA)", icon: "🏬", group: "Estoque & Equipamentos", vol: 11, description: "Slotting IA, putaway, reabastecimento, RFID, robótica, produtividade, ESG" },
  { slug: "inventario", label: "Inventário & Rastreio", icon: "⎗", group: "Estoque & Equipamentos", vol: 11, description: "Contagens cíclicas e genealogia de lote" },
  { slug: "ativos-retornaveis", label: "Ativos Retornáveis (RAMS)", icon: "♻️", group: "Estoque & Equipamentos", vol: 13, description: "Pallets/containers/gaiolas/IBCs: empréstimos, retenção, manutenção, ESG" },
  { slug: "vhsys", label: "Integração VHSYS", icon: "🏬", group: "Estoque & Equipamentos", vol: 62, description: "Saldos e movimentos de estoque sincronizados com o VHSYS e locais de estoque" },
  { slug: "manutencao", label: "EAM / Manutenção de Frota & Ativos", icon: "🔧", group: "Estoque & Equipamentos", vol: 9, description: "Ativos, ordens de serviço, preventiva, MTTR/MTBF" },
  { slug: "expedicao", label: "Expedição", icon: "📦", group: "Estoque & Equipamentos", vol: 7, description: "Pedidos, picking, packing e embarque" },
  { slug: "central-expedicao", label: "Smart Shipping Center (IA)", icon: "🧠", group: "Estoque & Equipamentos", vol: 7, description: "Wave picking, escolha de transportadora, embalagem ótima, docas, cargas, gargalos" },
  { slug: "distribuicao", label: "Distribuição & Last Mile", icon: "🗺", group: "Estoque & Equipamentos", vol: 7, description: "Transferências, cross-dock, hubs, entregas" },
  { slug: "ultima-milha", label: "Última Milha (LMDP)", icon: "🛵", group: "Estoque & Equipamentos", vol: 40, description: "Roteirização inteligente, paradas, POD, geocercas, OTIF/OTD" },
  { slug: "encomendas", label: "Encomendas & Volumes (PMS)", icon: "📦", group: "Estoque & Equipamentos", vol: 42, description: "LPN/etiquetas, scan events, rastreabilidade, hubs, lockers, consolidação" },
  { slug: "cadeia-fria", label: "Cadeia Fria (CCLMS)", icon: "❄️", group: "Estoque & Equipamentos", vol: 43, description: "Monitoramento térmico, sensores IoT, integridade, alarmes, cargas sensíveis" },
  { slug: "postagens", label: "Torre de Postagens", icon: "🛰", group: "Estoque & Equipamentos", vol: 2, description: "Etiqueta→PLP→postagem→1ª movimentação, objetos parados, CEP inválido, SLA, alertas" },
  { slug: "prepostagem", label: "Prepostagem Correios", icon: "📮", group: "Estoque & Equipamentos", vol: 55, description: "Pré-postagens (PPN), rastreio dos objetos (SRO), conferência de postagem, correções de CEP, logs automáticos" },
  { slug: "correios-central", label: "Correios — Central Única", icon: "🏤", group: "Estoque & Equipamentos", vol: 66, description: "TODAS as ferramentas dos Correios num só lugar: prepostagem, rastreio (SRO), conferência, correção de CEP, contratos/remetente, credenciais da API e logs" },
  { slug: "correios", label: "Correios (Gestão Enterprise)", icon: "📮", group: "Estoque & Equipamentos", vol: 4, description: "Contratos, cartões de postagem, PLP, objetos, SRO, auditoria de fretes, SLA" },
  { slug: "envios-rastreamento", label: "Envios & Rastreamento", icon: "📦", group: "Estoque & Equipamentos", vol: 60, description: "Remessas postadas e último status, eventos de rastreio (SRO), destinatários, carteiro ausente, reenvios" },
  { slug: "logistica-reversa", label: "Logística Reversa Enterprise (RLMS)", icon: "↩️", group: "Estoque & Equipamentos", vol: 49, description: "Ciclo reverso completo: autorização, coleta, triagem, destinação, recalls, embalagens retornáveis" },
  { slug: "tms", label: "TMS / Transporte", icon: "🚚", group: "Estoque & Equipamentos", vol: 9, description: "Transportadoras, fretes, rotas e tracking" },
  { slug: "frota", label: "TMS Enterprise / Frota", icon: "🚛", group: "Estoque & Equipamentos", vol: 9, description: "Viagens, custos, combustível, telemetria, manutenção, leilão de fretes, carbono" },
  { slug: "transporte", label: "Torre de Transporte", icon: "🌐", group: "Estoque & Equipamentos", vol: 3, description: "Monitoramento em trânsito, ETA, score de risco, ocorrências, heat map, OTIF" },
  { slug: "transportadoras", label: "Transportadoras (CMP)", icon: "🚛", group: "Estoque & Equipamentos", vol: 41, description: "SRM: homologação, contratos, documentos, scorecard, ranking, ocorrências, compliance" },
  { slug: "integracoes-transportadoras", label: "Integrações de Transportadoras (API)", icon: "🔌", group: "Estoque & Equipamentos", vol: 51, description: "Hub de API: Correios e qualquer transportadora, cotação comparativa, etiqueta, rastreio, credenciais, logs" },
  { slug: "yms", label: "YMS / Pátio & Docas", icon: "🏗", group: "Estoque & Equipamentos", vol: 12, description: "Docas, agendamento e pátio" },
  { slug: "patio", label: "YMS Enterprise (Pátio)", icon: "🚧", group: "Estoque & Equipamentos", vol: 12, description: "Portaria/OCR, balanças, filas, carga/descarga, containers, lacres, AI dock scheduler" },
  { slug: "comex", label: "Global Trade Management (GTM)", icon: "🌍", group: "Estoque & Equipamentos", vol: 14, description: "Importação/exportação, Incoterms, portos/aeroportos, aduana, containers, drawback, RECOF" },
  { slug: "embarques-internacionais", label: "Embarques Internacionais (GTM Ops)", icon: "🚢", group: "Estoque & Equipamentos", vol: 44, description: "Embarques multimodais, bookings, agentes logísticos, incoterms, eventos internacionais, timeline" },
  { slug: "aduana", label: "Aduana (CMS)", icon: "🛃", group: "Estoque & Equipamentos", vol: 45, description: "Desembaraço, canais (verde/amarelo/vermelho), documentação, inspeções, liberação, recintos alfandegados" },

  // ── 💰 Financeiro ──────────────────────────────────────────────────────────
  { slug: "financeiro-dre", label: "Financeiro — DRE", icon: "💵", group: "Financeiro", vol: 68, description: "Demonstrativo de resultado com dados reais: receita bruta, comissões de coprodução, líquido da empresa, margem, ticket médio, receita por estado e canal" },
  { slug: "financeiro-custos", label: "Custos & Despesas", icon: "🧮", group: "Financeiro", vol: 72, description: "Lance despesas (fixas/variáveis) e o custo de cada produto (CMV, frete médio, taxa de gateway) — a base para o lucro real por pedido" },
  { slug: "compras", label: "Suprimentos / Compras", icon: "🛒", group: "Financeiro", vol: 10, description: "Requisição → cotação → pedido → recebimento" },

  // ── 📋 Fiscal & Tributos ───────────────────────────────────────────────────
  { slug: "integracoes-nfe", label: "Integrações (API) & Nota Fiscal", icon: "🧾", group: "Fiscal & Tributos", vol: 64, description: "Ferramentas de integração com plataformas de pagamento (Monetizze, AppMax, Braip, Hotmart, Kiwify, Mercado Pago, PagSeguro, Stripe) e emissão de NF-e: testar conexões, chaves de API, logs e DANFE/XML" },
  { slug: "nfe", label: "NFe (Emissões)", icon: "🧾", group: "Fiscal & Tributos", vol: 63, description: "Emissões de NFe via VHSYS — status, DANFE/XML e vínculo de baixa de estoque por produto" },

  // ── 🎛️ Controladoria ───────────────────────────────────────────────────────
  { slug: "auditoria", label: "Auditoria Logística & Custos", icon: "🔎", group: "Controladoria", vol: 6, description: "Auditoria de fretes/operacional, custos, rentabilidade, riscos, compliance logístico, score" },
  { slug: "auditoria-fretes", label: "Auditoria de Fretes & Custos (FACMS)", icon: "🧮", group: "Controladoria", vol: 36, description: "Auditoria automática cobrado×esperado, faturas/CT-e, glosas, custos logísticos, simulador de transportadora" },

  // ── 📊 Relatórios & IA ─────────────────────────────────────────────────────
  { slug: "relatorios", label: "Central de Relatórios", icon: "📊", group: "Relatórios & IA", vol: 71, description: "Relatórios gerenciais com dados reais: vendas, operação, coprodução, integrações, logística, fiscal, IA e auditoria — KPIs, quebras, séries e exportação CSV" },
  { slug: "analytics", label: "Logistics Data Platform (BI)", icon: "📈", group: "Relatórios & IA", vol: 16, description: "Data lake/warehouse logístico, catálogo de KPIs, forecast, governança de dados" },
  { slug: "logia", label: "LOGIA (Insights)", icon: "✧", group: "Relatórios & IA", vol: 15, description: "Insights, previsões e planos de ação logísticos" },
  { slug: "ia-central", label: "LAIOS — Logistics AI OS", icon: "✦", group: "Relatórios & IA", vol: 15, description: "Cérebro operacional: multiagentes (WMS/TMS/YMS/Correios), IA preditiva/prescritiva, memória corporativa" },
  { slug: "gemeo-digital", label: "Gêmeo Digital (LDTP)", icon: "🧬", group: "Relatórios & IA", vol: 46, description: "Réplica viva da operação, simulação what-if, gargalos, reprodução histórica" },
  { slug: "torre-controle", label: "Torre de Controle Mundial (GLCT)", icon: "🗼", group: "Relatórios & IA", vol: 47, description: "Painel situacional consolidado, correlação de eventos, incidentes, playbooks, orquestração" },
  { slug: "visibilidade", label: "Visibilidade da Cadeia (SCVP)", icon: "🛰", group: "Relatórios & IA", vol: 48, description: "Rastreamento ponta a ponta, eventos normalizados, ETA inteligente, exceções, compartilhamento" },
  { slug: "control-tower", label: "Logistics Control Tower", icon: "⛭", group: "Relatórios & IA", vol: 5, description: "Eventos, SLA, alertas e exceções da cadeia logística" },
  { slug: "engenharia-logistica", label: "Logistics Planning & Rede", icon: "🗺", group: "Relatórios & IA", vol: 10, description: "Digital twin, mapa de demanda, IA de localização de CD, simulações, ROI/payback" },
  { slug: "rede-logistica", label: "Rede Logística Global (GLNMP)", icon: "🌐", group: "Relatórios & IA", vol: 50, description: "Malha logística: nós, conexões, capacidade, cobertura, simulação estratégica de rede" },
  { slug: "demanda", label: "Demand Planning", icon: "📈", group: "Relatórios & IA", vol: 10, description: "Histórico, previsões e S&OP" },

  // ── 🛡️ Governança & Compliance ─────────────────────────────────────────────
  { slug: "juridico", label: "Jurídico & Compliance", icon: "⚖️", group: "Governança & Compliance", vol: 70, description: "Documentos jurídicos do GLOP: Política de Privacidade (LGPD), Termos de Uso, Cookies, Política de Segurança, DPA e ROPA/RIPD — com links públicos para o comprador" },
  { slug: "seguranca", label: "Identidade & Segurança (IAM)", icon: "🛡", group: "Governança & Compliance", vol: 16, description: "Zero Trust, MFA, sessões, PAM, detecção de ameaças, incidentes, certificação de acessos" },
  { slug: "documentos", label: "Documentos (ECM / GED)", icon: "🗂", group: "Governança & Compliance", vol: 16, description: "Repositório, versionamento, check-in/out, assinaturas eletrônicas, retenção, busca" },
  { slug: "processos", label: "BPM & Workflows", icon: "🔀", group: "Governança & Compliance", vol: 16, description: "Motor de processos: aprovações multinível, regras de decisão (DMN), SLA, eventos" },

  // ── ⚙️ Administração ───────────────────────────────────────────────────────
  { slug: "admin", label: "Administração da Plataforma", icon: "⚙", group: "Administração", vol: 16, description: "Config center (rollback), feature flags, multimoeda, multilíngue, módulos, licenças" },
  { slug: "integracoes", label: "Integrações (iPaaS)", icon: "🔌", group: "Administração", vol: 16, description: "API Gateway, conectores, event bus, webhooks, fila com retry/DLQ, ETL, chaves de API" },
  { slug: "webhooks-integracoes", label: "Webhooks & Integrações", icon: "🔗", group: "Administração", vol: 59, description: "Webhooks de saída do produtor e entregas, logs SisLógica, logs de API e de webhook das plataformas" },
  { slug: "dispositivos", label: "Super App & Dispositivos", icon: "📲", group: "Administração", vol: 16, description: "PWA instalável, dispositivos, sync offline, push, modos operacionais (coletor/motorista)" },

  // ── 📖 Ajuda ───────────────────────────────────────────────────────────────
  { slug: "manual", label: "Manual / Ajuda", icon: "📖", group: "Ajuda", vol: 0, description: "Manual completo do sistema: todas as telas explicadas, o que cada uma faz e o passo a passo" },
];

// Ordem fixa das categorias (a do menu da imagem), não derivada dos itens.
export const NAV_GROUPS = NAV_GROUP_META.map((g) => g.name);
export const groupIcon = (name: string) => NAV_GROUP_META.find((g) => g.name === name)?.icon ?? "•";
export const findNav = (slug: string) => NAV.find((n) => n.slug === slug);
