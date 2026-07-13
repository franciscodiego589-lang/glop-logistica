// Detalhamento por módulo: o que cada tela entrega (features) e o que a sustenta no banco.
export type ModuleDetail = { features: string[]; tables: string[]; rpcs?: string[] };

export const MODULE_DETAILS: Record<string, ModuleDetail> = {
  produtos: {
    features: ["Cadastro de SKU com fiscal (NCM/CEST)", "Categorias hierárquicas", "Fornecedores", "Embalagens un→caixa→pallet (UoM)", "Lotes, validade e séries", "Kits/BOM"],
    tables: ["products", "product_categories", "suppliers", "units_of_measure", "product_packagings", "product_lots", "product_serials", "kit_items"],
  },
  estoque: {
    features: ["Saldo por produto/armazém/bin/lote", "Curva ABC automática", "Ponto de pedido e sugestões", "Vencimentos", "KPIs de valor e cobertura"],
    tables: ["stock_balances", "stock_movements", "reorder_suggestions", "stock_snapshots", "mv_stock_on_hand"],
    rpcs: ["inventory_kpis", "calculate_abc", "generate_reorder_suggestions"],
  },
  wms: {
    features: ["Endereçamento (zonas + bins)", "Recebimento e putaway", "Tarefas de armazém", "Ondas de separação", "Packing e volumes"],
    tables: ["storage_zones", "storage_locations", "inbound_receipts", "warehouse_tasks", "pick_waves", "packages"],
    rpcs: ["register_stock_movement"],
  },
  inventario: {
    features: ["Contagens cíclicas e full", "Ajuste automático por diferença", "Genealogia de lote (rastreio)", "Auditoria completa"],
    tables: ["inventory_counts", "inventory_count_items", "lot_genealogy", "audit_logs"],
    rpcs: ["apply_inventory_count"],
  },
  compras: {
    features: ["Requisição de compra", "RFQ / cotação com mapa comparativo", "Pedido de compra", "Recebimento com entrada de estoque"],
    tables: ["purchase_requisitions", "rfqs", "supplier_quotes", "purchase_orders"],
    rpcs: ["receive_purchase_order"],
  },
  demanda: {
    features: ["Histórico de demanda", "Previsão (média móvel, tendência)", "Acurácia", "S&OP / plano de consenso"],
    tables: ["demand_history", "demand_forecasts", "demand_plans"],
    rpcs: ["forecast_moving_average"],
  },
  mrp: {
    features: ["BOM multinível", "Centros de trabalho e roteiros", "Rodada de MRP", "Ordens planejadas (compra/produção)"],
    tables: ["bills_of_materials", "bom_components", "work_centers", "routing_operations", "mrp_planned_orders"],
    rpcs: ["run_mrp"],
  },
  producao: {
    features: ["Ordens de produção", "Apontamento de operações", "Consumo de componentes (BOM)", "Entrada de acabado com lote"],
    tables: ["production_orders", "production_operations", "production_consumptions"],
    rpcs: ["finish_production_order"],
  },
  expedicao: {
    features: ["Clientes", "Pedidos de saída", "Alocação e picking", "Packing", "Embarque com baixa de estoque"],
    tables: ["customers", "outbound_orders", "outbound_order_items"],
    rpcs: ["ship_outbound_order"],
  },
  tms: {
    features: ["Transportadoras, frota e motoristas", "Tabelas de frete", "Rotas", "Embarques / CT-e", "Tracking e ocorrências"],
    tables: ["carriers", "vehicles", "drivers", "freight_rates", "routes", "shipments", "shipment_events"],
  },
  yms: {
    features: ["Docas", "Agendamento sem sobreposição", "Pátio e vagas", "Fila de veículos"],
    tables: ["docks", "dock_appointments", "yard_zones", "yard_visits"],
  },
  distribuicao: {
    features: ["Transferências entre CDs", "Cross-docking", "Last mile", "Tentativas e POD"],
    tables: ["stock_transfers", "deliveries", "delivery_attempts"],
    rpcs: ["receive_stock_transfer"],
  },
  "control-tower": {
    features: ["Barramento de eventos", "Políticas e quebras de SLA", "Alertas", "Exceções e escalonamento"],
    tables: ["logistics_events", "sla_policies", "sla_breaches", "alerts", "logistics_exceptions"],
    rpcs: ["control_tower_kpis"],
  },
  logia: {
    features: ["Insights proativos (ruptura/excesso/gargalo)", "Base RAG (pgvector)", "Conversas com a IA", "Planos de ação"],
    tables: ["logia_insights", "logia_knowledge", "logia_conversations", "logia_action_plans"],
    rpcs: ["logia_scan"],
  },
};
