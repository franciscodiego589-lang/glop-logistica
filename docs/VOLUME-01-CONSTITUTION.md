# VOLUME 01 — CONSTITUIÇÃO DA LOGÍSTICA

> **Documento de referência obrigatória.** Define arquitetura, filosofia, padrões técnicos,
> integrações e regras que **todos** os módulos (WMS, TMS, PCP, Compras, Produção, Estoque,
> Expedição, BI, IA) devem seguir. Versão 1.0 — Enterprise World Class.
> Em caso de conflito, esta Constituição prevalece sobre decisões pontuais de implementação.

---

## Missão

ERP Logístico Enterprise de classe mundial que integra toda a cadeia logística num único
ecossistema, atendendo de pequenas empresas a multinacionais: indústrias, CDs, operadores
3PL/4PL, e-commerce, varejo, atacado, clínicas, serviços, farma e suplementos.

Referências de mercado a superar: SAP S/4HANA · SAP EWM · SAP TM · Oracle SCM Cloud ·
Dynamics 365 SCM · Manhattan · Blue Yonder · Infor SCM · TOTVS Logix/Protheus · Senior · Odoo.

## Princípios fundamentais

1. **Única fonte da verdade** — zero duplicidade; todos os módulos na mesma base; toda alteração reflete imediatamente.
2. **Integração total** — uma movimentação atualiza Financeiro, Compras, Custos, Estoque, Produção, Qualidade, Expedição, Fiscal, Contabilidade, CRM, BI, KPIs, Dashboards, Relatórios e IA.
3. **Tempo real** — atualização automática por arquitetura orientada a eventos, sem refresh manual.

## Filosofia — todo processo possui

rastreabilidade completa · histórico permanente · logs imutáveis · auditoria · versionamento ·
assinatura eletrônica · permissões · workflow · aprovação · IA · automações · dashboards ·
indicadores · relatórios.

## Padrão de arquitetura (alvo)

Microsserviços · separação por domínios · Event-Driven Architecture · CQRS quando necessário ·
Event Sourcing para módulos críticos · REST · GraphQL · Webhooks · filas assíncronas · mensageria ·
cache distribuído · escala horizontal · balanceamento · alta disponibilidade · failover ·
backups contínuos · Disaster Recovery.

## Banco de dados

Relacional + analítico + documental quando necessário · auditoria automática · versionamento ·
soft delete · histórico completo · multiempresa · multifilial · multiCD · multimoeda · multilíngua ·
timezone-independente.

## Nomenclatura — todo registro possui

UUID · código interno · código externo · descrição · descrição reduzida · descrição técnica · status ·
empresa · filial · data criação · data alteração · usuário · origem · última sincronização · versão.

## Estrutura do ERP — 26 domínios

Cadastros Mestres · Compras · Suprimentos · Estoque · Almoxarifado · WMS · Inventário · Produção ·
PCP · MRP · APS · Qualidade · Custos · Fiscal · Contabilidade · Financeiro · CRM · Comercial · TMS ·
YMS · Expedição · Distribuição · BI · IA Corporativa · Governança · Administração.
Cada domínio independente, porém totalmente integrado.

## Padrão das telas (obrigatório em todas)

Pesquisa instantânea + avançada · filtros inteligentes · favoritos · visualizações salvas ·
exportação (PDF/Excel/CSV/XML/JSON) · impressão · compartilhamento · comentários · anexos ·
timeline · logs · histórico · KPIs · gráficos · alertas · IA · botões **Gerar Relatório / Analisar /
Simular / Otimizar / Exportar**.

## Padrão UX

Enterprise, inspirado em SAP Fiori · Oracle Fusion · Fluent · Apple HIG · Material · Linear · Notion ·
Stripe · Monday · ClickUp. Obrigatório: poucos cliques · hierarquia visual clara · dark/light ·
responsividade · atalhos de teclado · drag-and-drop · painéis redimensionáveis · componentes
reutilizáveis · **acessibilidade WCAG 2.2 AA** · internacionalização.

## Componentes padronizados

Cards inteligentes · tabelas avançadas · Kanban · timeline · calendário · mapa · heatmap ·
gráficos interativos · dashboards configuráveis · widgets · assistente por IA · central de notificações.

## Segurança

RBAC com permissão por empresa/filial/centro de custo/CD/operação/módulo/**campo**/**botão**/**API** ·
criptografia · logs imutáveis · **MFA** · **SSO** · **LGPD** · trilhas de auditoria.

## Automações

Workflows · aprovações · regras condicionais · robôs · alertas automáticos · notificações ·
integração por eventos · agendamentos · execução automática.

## IA Corporativa — LOGIA

Analisa gargalos; prevê ruptura/excesso; calcula estoque ideal; curvas ABC/**XYZ**/**PQR**; OTIF; SLA;
custos; fornecedores; transportadoras; clientes; produção; produtividade; detecta desperdício/fraude/
desvio; cria planos de ação; relatórios executivos; responde em linguagem natural; executa consultas
no ERP; sugere melhoria contínua.

## KPIs globais

OTIF · Fill Rate · Perfect Order · Lead Time · Dock to Stock · Order Cycle Time · Inventory Turnover ·
Days of Inventory · Acuracidade de Inventário · Picking Accuracy · Produtividade por operador/turno ·
Utilização de docas/veículos · Custo logístico por pedido/kg/cliente · SLA fornecedores/transportadoras ·
Taxa de avarias/devoluções · Ocupação do armazém · Eficiência de recebimento/expedição/abastecimento ·
Eficiência operacional por CD · CO₂ estimado por operação.

## Integrações nativas (arquitetura preparada)

REST · GraphQL · EDI · XML · JSON · MQTT · RFID · código de barras · QR · balanças · coletores ·
impressoras térmicas · etiquetadoras · CLPs · MES · sistemas fiscais · e-commerce · marketplaces ·
transportadoras · bancos · gateways de pagamento · Power BI/Tableau/Qlik · Data Lake/Warehouse ·
automação industrial.

## Template obrigatório de TODO volume (20 pontos)

1. Objetivo do módulo · 2. Arquitetura funcional · 3. Arquitetura técnica · 4. Fluxo operacional ·
5. Regras de negócio · 6. Estrutura do banco · 7. Entidades e relacionamentos · 8. APIs e eventos ·
9. UX/UI · 10. Componentes visuais · 11. Dashboards · 12. KPIs · 13. Permissões e perfis ·
14. Automações · 15. Integrações · 16. Relatórios · 17. IA aplicada ao módulo · 18. Auditoria e logs ·
19. Desempenho e escalabilidade · 20. Roadmap de evolução.

---

# CONFORMIDADE ATUAL (honesta) — o que já cumpre × o que é roadmap

> Atualizado em 2026-07-13. A plataforma real é **Supabase (PostgreSQL) + Next.js** — um monólito
> modular, não microsserviços. Vários itens da Constituição são **alvo/roadmap**, não estão prontos.
> Este bloco existe para nunca confundir "projetado" com "implementado".

## ✅ Já implementado e verificado
- **Única fonte da verdade / integração total**: um só banco; RPC-cérebro `register_stock_movement` +
  processos (`receive_purchase_order`, `ship_outbound_order`, `finish_production_order`,
  `apply_inventory_count`, `receive_stock_transfer`) mantêm estoque coerente entre módulos.
- **Auditoria / versionamento / soft delete / histórico**: `audit_logs` + triggers `tg_touch_row`/
  `tg_write_audit` + colunas-padrão (version, deleted_at…) em todas as tabelas.
- **RBAC + RLS**: permissão por empresa/módulo/ação; RLS em 100% das tabelas; 90 permissões semeadas.
- **Multiempresa / multifilial / multiCD**: tenant→company→branch em todo registro.
- **IA LOGIA (base)**: pgvector, insights determinísticos (`logia_scan`), tabelas de conversa/knowledge/
  action plans. KPIs por RPC (`inventory_kpis`, `control_tower_kpis`, `executive_dashboard`).
- **UX base**: Next.js App Router, dark/light, sidebar dos módulos, cockpit executivo com dados reais.
- **26 domínios**: cobertos no schema (Vol 02–16) — WMS/TMS/YMS/MRP/APS/PCP/Compras/Inventário/
  Distribuição/Torre de Controle/BI presentes.

## 🟡 Parcial
- **Tempo real**: Supabase Realtime disponível, ainda não ligado nas telas (agenda/docas/torre).
- **Telas**: hoje cockpit + vitrine por módulo; falta CRUD real, filtros, export, timeline por tela.
- **Permissão por campo/botão/API**: existe por módulo/ação; falta granularidade de campo e botão.
- **Assinatura eletrônica / workflow / aprovação**: modelado (approvals no Vol 06 e afins), sem UI.
- **KPIs avançados** (OTIF, Dock-to-Stock, XYZ/PQR): estrutura permite; cálculo dedicado pendente.

## 🔴 Roadmap (ainda NÃO existe — não alegar como pronto)
- **Microsserviços · CQRS · Event Sourcing** (hoje é monólito Postgres; eventos via triggers/Realtime).
- **GraphQL · EDI · MQTT · RFID · CLP/MES · impressoras/etiquetadoras/balanças/coletores**.
- **SSO · MFA** nativos · permissão por campo/botão ponta a ponta.
- **i18n · WCAG 2.2 AA** formais · atalhos de teclado · drag-and-drop · painéis redimensionáveis.
- **Multimoeda / multilíngua** · Disaster Recovery / failover / cache distribuído dedicados.
- Integrações Power BI/Tableau/Qlik · Data Lake/Warehouse.

> Regra: ao entregar qualquer volume, seguir o template de 20 pontos e **marcar honestamente** em qual
> das três faixas (✅/🟡/🔴) cada item caiu.
