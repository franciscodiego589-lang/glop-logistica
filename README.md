# ERP Logístico Mundial

ERP de logística Enterprise (nível SAP S/4HANA + Oracle SCM + Manhattan/Blue Yonder), multi-tenant,
construído em **Supabase (PostgreSQL) + Next.js**. Backend único, tudo integrado por eventos,
RLS/RBAC desde a origem, auditoria e soft delete em todas as tabelas.

## Filosofia
Mesmo banco. Nada duplicado. Toda movimentação atualiza todos os setores em tempo real:

```
Entrada Fiscal → Financeiro → Compras → Estoque → Lotes → Qualidade
             → Custos → Produção → Expedição → CRM → BI → Cockpit Executivo
```

O "cérebro" da integração são RPCs `security definer` que mantêm o estoque coerente:
- `register_stock_movement()` — toda entrada/saída passa aqui e sincroniza `stock_balances` + kardex.
- `receive_purchase_order()` / `ship_outbound_order()` / `receive_stock_transfer()` / `finish_production_order()` / `apply_inventory_count()` — cada processo de negócio chama o cérebro.

## Volumes (schema = fonte da verdade em `supabase/migrations/`)

| Vol | Arquivo | Conteúdo |
|---|---|---|
| 01 | `..._foundation.sql` | Multi-tenant, RBAC, auditoria, triggers, RLS, seed de permissões |
| 02 | `..._master_data.sql` | Produtos/SKU, categorias, fornecedores, armazéns, **endereçamento (bins)**, lotes, séries, embalagens/UoM, kits |
| 03 | `..._wms.sql` | Saldos por bin, kardex, reservas, recebimento, tarefas, ondas, packing + `register_stock_movement` |
| 04 | `..._tms.sql` | Transportadoras, frota, motoristas, fretes, rotas, embarques/CT-e, tracking/ocorrências |
| 05 | `..._yms.sql` | Docas, agendamento **sem sobreposição (gist)**, pátio, visitas |
| 06 | `..._purchasing.sql` | Requisição → RFQ/cotação → mapa comparativo → PO → recebimento |
| 07 | `..._demand_planning.sql` | Histórico, previsões (média móvel etc.), S&OP |
| 08 | `..._mrp_aps.sql` | BOM multinível, centros de trabalho, roteiros, `run_mrp`, ordens planejadas |
| 09 | `..._production.sql` | Ordens de produção, apontamentos, consumo BOM, `finish_production_order` |
| 10 | `..._smart_inventory.sql` | Snapshots, curva **ABC**, ponto de pedido, KPIs, MV de saldo consolidado |
| 11 | `..._inventory_traceability.sql` | Contagens cíclicas, ajuste automático, genealogia de lote |
| 12 | `..._shipping.sql` | Clientes, pedidos de saída, picking/packing, embarque |
| 13 | `..._distribution.sql` | Transferências entre CDs, cross-dock, last-mile, POD |
| 14 | `..._control_tower.sql` | Eventos, SLA, quebras, alertas, exceções + `control_tower_kpis` |
| 15 | `..._logia.sql` | IA LOGIA: base RAG (pgvector), conversas, insights, planos de ação, `logia_scan` |
| 16 | `..._bi_dashboards.sql` | Dashboards persistidos, widgets, relatórios + `executive_dashboard` |
| 17 | *(próxima fase)* | Frontend Next.js Enterprise (UX SAP Fiori) para todos os módulos |

## Como colocar no ar (próximos passos)

1. Criar projeto no [Supabase](https://supabase.com) (novo, independente).
2. `supabase link --project-ref <ref>` e `supabase db push` (aplica as 16 migrations em ordem).
3. Criar buckets de Storage: `products, documents, photos, before-after, attachments, reports, avatars, logos`.
4. Novo usuário chama a RPC `bootstrap_organization('Minha Empresa','Matriz','CNPJ')` para criar tenant/empresa/filial/admin.
5. Vol 17: scaffold do Next.js (App Router + `@supabase/ssr`) e telas por módulo.

> Regras obrigatórias de código em `CLAUDE.md`.
