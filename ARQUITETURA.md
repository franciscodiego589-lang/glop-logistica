# ERP Logístico Mundial — Arquitetura (mapa vivo)

> Documento **enxuto e honesto**: o que existe de verdade (schema no banco + tela que grava/lê)
> vs. o que é **roadmap**. Cresce junto com o código — não é uma spec escrita antes das telas.
> Regras de engenharia em [CLAUDE.md](./CLAUDE.md). Fonte da verdade do schema: `supabase/migrations/`.

## Stack
Supabase (PostgreSQL + Auth + Storage + RLS) · Next.js 14 App Router + TypeScript + Tailwind · `@supabase/ssr`.
Multi-tenant `tenant → company → branch`. Toda tabela: colunas-padrão + triggers `app.tg_touch_row`/`tg_write_audit`,
RLS por `app.has_permission('<recurso>.<ação>', company_id)`, soft delete.

## O cérebro de integração
Um único ponto sincroniza estoque: **`register_stock_movement()`** (atualiza `stock_balances` + kardex `stock_movements`).
Todos os processos chamam-no, então **os módulos se conectam pelo estoque**, não por telas:

```
Compras ── receive_purchase_order() ──▶ entrada  ┐
Produção ─ finish_production_order() ─▶ entrada   ├─▶ register_stock_movement ─▶ stock_balances ─▶ Estoque / WMS
Produção ─ finish_production_order() ─▶ consumo   ┘                                                    │
MRP ────── run_mrp() lê saldo + demanda ◀──────────────────────────────────────────────────────────────┘
```

## Volumes — estado real

| Vol | Módulo | Rota | Estado | Telas reais |
|----|--------|------|--------|-------------|
| 01 | Fundação (RBAC, auditoria, multi-tenant) | — | ✅ no banco | — |
| 02 | Cadastro Mestre (MDM) | `/produtos` | ✅ **tela real** | dashboard qualidade, CRUD em abas, upload foto (Storage), endereço-padrão, IA duplicidade |
| 03 | WMS / Armazém | `/wms` | ✅ **tela real** | armazéns → zonas → **gerador de bins em massa**, status/ocupação |
| 04 | TMS / Transporte | `/tms` | ✅ **tela real** | transportadoras, frota, motoristas, tabelas de frete, **calculadora de frete**, embarques + **rastreio** |
| 05 | YMS / Pátio & Docas | `/yms` | ✅ **tela real** | docas, agendamento de doca (janela sem sobreposição), gestão de pátio |
| 06 | Compras / Procurement | `/compras` | ✅ **tela real** | SRM (score), requisição → RFQ → **pedido + itens + receber no estoque** |
| 07 | Demand Planning | `/demanda` | ✅ **tela real** | histórico de demanda + previsão por média móvel (`forecast_moving_average`) |
| 08 | MRP / APS | `/mrp` | ✅ **tela real** | **rodar MRP**, ordens planejadas, estruturas (BOM) + componentes, centros de trabalho |
| 09 | Produção / PCP | `/producao` | ✅ **tela real** | ordens de produção, operações, **finalizar** (consome BOM + dá entrada do acabado) |
| 10 | Estoque Inteligente | `/estoque` | ✅ **tela real** | KPIs, **curva ABC**, **ressuprimento** (ponto de pedido), saldo por produto |
| 11 | Inventário & Rastreio | `/inventario` | ✅ **tela real** | contagens cíclicas + aplicar ajuste (`apply_inventory_count`); genealogia de lote em /producao |
| 12 | Expedição | `/expedicao` | ✅ **tela real** | clientes + pedidos de saída + itens + expedir (`ship_outbound_order`, baixa de estoque) |
| 13 | Distribuição & Last Mile | `/distribuicao` | ✅ **tela real** | transferências entre CDs + receber (`receive_stock_transfer`) + entregas last-mile |
| 14 | Torre de Controle | `/control-tower` | 🟡 schema + vitrine | RPC `control_tower_kpis` |
| 15 | LOGIA (IA) | `/logia` | 🟡 schema + vitrine | RAG pgvector `logia_knowledge`; Edge `logia-brain` a criar |
| 16 | BI Executivo | `/dashboard` | 🟡 cockpit | RPC `executive_dashboard` |
| 17 | Frontend (scaffold) | — | ✅ | sidebar, login, dark/light, rota vitrine `[slug]` |

Legenda: ✅ tela real que grava/lê · 🟡 schema no banco + tela “vitrine” (features/tabelas), aguardando tela CRUD.

## RPCs de negócio (já no banco)
`register_stock_movement` · `receive_purchase_order` · `finish_production_order` · `run_mrp` ·
`calculate_abc` · `generate_reorder_suggestions` · `inventory_kpis` · `control_tower_kpis` ·
`executive_dashboard` · `detect_duplicate_products` · `mdm_dashboard`.

## Padrões de frontend reutilizáveis
- **`components/ui/CrudPanel.tsx`** — CRUD genérico (create/list/soft-delete + FK), usado por TMS, Compras, MRP.
- **`components/ui/KpiCard.tsx`** — cartão de KPI.
- Rota estática `app/(app)/<slug>/page.tsx` **sobrepõe** a vitrine genérica `[slug]` para aquele módulo.
- Insert resolve `tenant_id` via `companies.select(tenant_id).eq(id, COMPANY)`.

## Roadmap explícito (NÃO feito — não fingir que existe)
- **TMS**: roteirização VRP real (algoritmo genético/colônia), mapa GPS ao vivo/telemetria, digital twin, emissão CT-e/MDF-e.
- **Compras**: comparação de cotações item-a-item, leilão reverso, portal do fornecedor, due diligence/ESG, IA de negociação, aprovações multinível.
- **MRP/APS**: capacidade finita (APS real), roteiros (routing_operations na tela), pegging.
- **Demand Planning**: métodos avançados (suavização exponencial, sazonal, IA) além da média móvel; consenso S&OP.
- **Distribuição**: roteirização de entregas, POD com foto/assinatura, tentativas com geolocalização.
- **LOGIA**: Edge `logia-brain` (geração fina) + secrets.
- Geral: seed de dados demo, deploy (Netlify); telas operacionais restantes: Torre de Controle (14), LOGIA (15), BI (16) hoje só com dashboard/RPC.

## Como aplicar migrations (deste ambiente)
Porta 5432 do pooler está acessível. Aplicar arquivo-a-arquivo via driver `pg` (o histórico do `db push` está vazio,
pois as 16 migrations iniciais foram aplicadas por API). Nunca hardcodar a senha em arquivo versionado.
