# GLOP — Global Logistics Operating Platform
# MASTER BLUEPRINT · VOLUME 00 — Documento Mestre da Plataforma

> **Versão:** 1.0 Enterprise Edition
> **Classificação:** Documento Mestre de Engenharia da Plataforma
> **Status:** Documento governante — todos os volumes seguintes obedecem a estas regras.
> **Objetivo:** Definir arquitetura, filosofia, padrões, escopo e princípios obrigatórios que regem todo o desenvolvimento da plataforma logística.

Este é o documento oficial que inaugura a plataforma. A partir daqui, cada novo módulo
deve obedecer exatamente às mesmas regras. Nenhum volume pode fugir do escopo logístico.

---

## 1. Identidade da Plataforma

**Nome oficial:** GLOP – Global Logistics Operating Platform

O GLOP é uma **Plataforma Global de Operações Logísticas** para controlar integralmente
toda a cadeia logística — do planejamento à entrega final — com Inteligência Artificial,
automação, rastreabilidade completa e análise de dados em tempo real.

> O GLOP **não** é um ERP corporativo tradicional. O GLOP é uma **Plataforma Operacional
> Logística**. Toda a arquitetura foi concebida **exclusivamente** para logística.

### Missão
Centralizar, automatizar, monitorar e otimizar todas as operações logísticas de empresas
nacionais e internacionais com tecnologia de ponta, IA e engenharia logística.

### Visão
Ser a plataforma logística mais completa do mundo — referência para operadores logísticos,
CDs, transportadoras, indústrias, e-commerce e operações internacionais.

### Propósito
Eliminar desperdícios, retrabalho, atrasos, perdas, falta de rastreabilidade e processos
manuais. Automatizar decisões. Aumentar produtividade. Reduzir custos. Melhorar SLA,
previsibilidade e experiência do cliente.

---

## 2. Filosofia da Plataforma (princípios obrigatórios)

- Logística em primeiro lugar
- Arquitetura modular · baixo acoplamento · alta coesão
- Escalabilidade horizontal · alta disponibilidade
- Cloud Native · **API First** · **Event Driven** · **AI First**
- **Mobile First** · **Offline First** (quando aplicável)
- Observabilidade completa · Segurança por padrão
- Auditoria permanente · Rastreabilidade total

> **Regra de ouro:** nenhuma movimentação logística pode ocorrer sem registro.

---

## 3. Escopo da Plataforma

O GLOP controla exclusivamente operações logísticas:

Planejamento Logístico · Supply Chain · Operações · Centros de Distribuição · Armazéns ·
Pátios · Transportes · Correios · Transportadoras · Operadores Logísticos · Cross Docking ·
Fulfillment · Expedição · Recebimento · Movimentação · Inventário · Logística Internacional ·
Last / Middle / First Mile · Auditoria Logística · BI Logístico · IA Logística ·
Automação · Digital Twin · Robótica · IoT · RFID · OCR · Computer Vision · Analytics.

### O que o GLOP **NÃO** é
Fora do escopo principal (podem **integrar via API**, mas não são construídos aqui):
RH · Folha · Contabilidade · Fiscal Corporativo · CRM Comercial · Marketing ·
PCP Industrial · Financeiro Corporativo · Jurídico · ERP Administrativo · Hospitalar ·
Escolar · Bancário. Esses sistemas apenas **fornecem ou consomem** dados da plataforma.

---

## 4. Público-Alvo

3PL · 4PL · Transporte rodoviário/aéreo/marítimo/ferroviário · Correios · Couriers ·
Freight Forwarders · CDs · Fulfillment Centers · Dark Stores · Micro-Fulfillment ·
Cross Dockings · Hubs · Operações portuárias/aeroportuárias · Indústrias (só logística) ·
Distribuidores · Atacadistas · Importadores · Exportadores · Marketplaces ·
Operações internacionais · Multinacionais · Operadores Last/Middle/First Mile.

---

## 5. Objetivos Principais

Controlar integralmente: todo pedido, produto, movimentação, pallet, caixa, gaiola,
container, veículo, motorista, transportadora, operador, CD, doca, corredor, endereço,
viagem, frete, entrega, devolução, auditoria e operação logística.

---

## 6. Diferencial (benchmark de mercado)

Reunir, numa **única plataforma integrada**, recursos equivalentes a:
SAP EWM · SAP TM · SAP Yard Logistics · Oracle Transportation Management ·
Oracle WMS Cloud · Oracle GTM · Manhattan Active · Blue Yonder · Körber · CargoWise ·
MercuryGate · project44 · FourKites · Descartes · WiseTech · e2open.

---

## 7. Dez Pilares

1. Operação Logística  2. Inteligência Logística  3. Automação  4. Rastreabilidade
5. Integração  6. Escalabilidade  7. Segurança  8. Inteligência Artificial
9. Analytics  10. Engenharia Logística

---

## 8. Resultado Esperado

Controlar operações logísticas de qualquer porte, suportando milhões de transações
diárias, múltiplos países/idiomas/empresas e múltiplos modais, com rastreabilidade
completa, IA, automação e visão operacional em tempo real.

---

## 9. Diretriz Obrigatória para Todos os Próximos Volumes

Todo módulo a partir deste documento deve:

1. Manter **foco exclusivo em logística** — nada de funcionalidades administrativas fora
   da operação logística, salvo integrações técnicas claramente definidas.
2. Ser compatível com operações **nacionais e internacionais**.
3. Suportar arquitetura escalável, **integração por APIs e eventos**, auditoria completa,
   IA e rastreabilidade ponta a ponta.

Antes de criar qualquer módulo, responder: **"Este módulo pertence exclusivamente ao
domínio da Logística?"** Se **NÃO**, o módulo não pode ser criado.

---

## 10. Padrão de Especificação por Volume (a partir do Vol. 01)

Cada volume passa a ser uma **especificação de engenharia** (não um "prompt"), contendo:
Objetivos · Escopo · Fluxos BPMN · Casos de uso · Regras de negócio · Requisitos
funcionais e não-funcionais · Protótipos de tela · Banco de dados · APIs · Eventos ·
Permissões · KPIs · Dashboards · IA · Auditoria · Testes.

---

# CAPÍTULO 2 — Princípios, Padrões e Diretrizes de Desenvolvimento

**Objetivo:** estabelecer as diretrizes obrigatórias de desenvolvimento. Todos os módulos,
funcionalidades, APIs, dashboards, bancos, fluxos, telas, IA e integrações seguem
rigorosamente este capítulo. **Nenhum módulo pode ser desenvolvido fora destes padrões.**

## 2.1 Teste de Existência de Funcionalidade
Toda funcionalidade deve responder **positivamente** a: por que existe? qual problema
logístico resolve? qual processo melhora? qual custo/tempo reduz? qual indicador melhora?
como impacta operação, cliente, operador e gestor? Se não responder, **não entra** na plataforma.

## 2.2 Princípios Fundamentais
- **Operação em primeiro lugar** — toda decisão facilita a operação; nunca complica.
- **Rastreabilidade total** — toda movimentação registra quem, quando, onde, por quê,
  dispositivo, IP, localização e resultado. Nunca há movimentação sem rastreabilidade.
- **Automação máxima** — eliminar digitação, retrabalho, controles paralelos; automatizar
  conferências, validações, decisões, alertas e auditorias.
- **IA em toda a plataforma** — não só chatbot: detectar erros, riscos, gargalos, custos,
  oportunidades, fraudes, atrasos; sugerir e prever.
- **Tempo real** — pedidos, estoque, transporte, expedição, entregas, devoluções, auditorias.

## 2.3 Experiência do Usuário
Menos cliques, menos digitação, mais automação e informação, menor curva de aprendizado.
Visual limpo e profissional. Responsivo: desktop, tablet, coletores e celulares.

## 2.4 Padrões Obrigatórios por Artefato (checklist de aceite)

**Telas:** pesquisa inteligente · filtros avançados · favoritos · exportação · importação ·
histórico · logs · dashboard · KPIs · gráficos · mapa · auditoria · ajuda contextual · IA.

**Cadastros:** código único · status · empresa · filial · CD · criado/alterado (data+usuário) ·
histórico · observações · anexos · fotos · documentos · auditoria · permissões · integrações.

**Listagens:** pesquisa instantânea · ordenação · agrupamentos · filtros · exportação ·
favoritos · campos configuráveis · visões tabela / cartões / mapa / calendário.

**Dashboards:** KPIs · indicadores · gráficos · ranking · mapa · timeline · filtros · períodos ·
comparativos · heat maps · alertas · IA.

**Relatórios:** visualização · impressão · PDF · Excel · CSV · Power BI · compartilhamento ·
agendamento · histórico · versões.

**Buscas (tudo pesquisável):** texto · código · código de barras · QR · RFID · OCR · CEP ·
cidade · estado · produto · cliente · transportadora · motorista · pedido · NF · CT-e · MDF-e ·
container · pallet · lote · validade.

**Alertas:** prioridade · categoria · origem · responsável · prazo · SLA · impacto · status ·
ações sugeridas · histórico.

**Aprovações (quando houver impacto operacional):** aprovar · rejeitar · justificativa ·
histórico · fluxo configurável · alçadas.

**Auditoria:** usuário · data · hora · IP · equipamento · localização · valor anterior · valor
novo · motivo · origem. **Nunca excluir histórico.**

**KPIs (todo módulo):** operacionais · táticos · estratégicos · financeiros-logísticos ·
produtividade · custos · qualidade · tempo · SLA · OTIF · Lead Time · rentabilidade logística.

**Mapas (quando possível):** mundial · Brasil · estados · cidades · centros · rotas · veículos ·
transportadoras · Correios · pedidos · entregas.

**Eventos:** toda movimentação gera evento (origem · destino · usuário · data · hora · resultado · histórico).

**Integrações:** controle · fila · retentativa · logs · tempo · status · alertas · auditoria · monitoramento.

**IA (todo módulo):** responder, gerar relatórios, detectar problemas, prever riscos, sugerir
melhorias, achar gargalos, calcular impactos, gerar dashboards. **Nunca executa ação crítica
sem aprovação configurada.**

**Segurança (todo módulo):** controle de acesso · permissões · perfis · logs · auditoria ·
criptografia · sessões · autenticação · autorização.

**Escalabilidade (todo módulo):** múltiplas empresas/CDs/usuários; milhões de pedidos,
produtos, eventos e registros; operação nacional e internacional.

## 2.5 Definição de Pronto (Definition of Done)
Nenhum módulo é concluído sem: requisitos funcionais · regras de negócio · fluxos operacionais ·
casos de uso · estrutura de dados · eventos · APIs · dashboards · KPIs · auditoria · permissões ·
integrações · estratégia de testes · critérios de aceite.

> **Próximo:** Capítulo 3 — Arquitetura Funcional (domínios, relação entre módulos e o
> fluxo mestre pedido → armazenagem → transporte → entrega → devolução).

---

# CAPÍTULO 3 — Arquitetura Funcional (Fluxo Mestre)

**Classificação:** Mapa Funcional da Plataforma · *rascunho v0.1 (a validar pelo dono)*.
**Objetivo:** descrever o **fluxo mestre** de ponta a ponta, quem é o domínio-dono de cada
estágio, e os **contratos de handoff** (evento + RPC oficial) entre domínios. Nenhum estágio
avança sem registro (regra de ouro do Cap. 2) e todo handoff cruza a interface oficial (Cap. 4).

## 3.1 O Fluxo Mestre (visão direta)

```
[01] PEDIDO ──▶ [02] ALOCAÇÃO ──▶ [03] SEPARAÇÃO ──▶ [04] EXPEDIÇÃO ──▶ [05] POSTAGEM/
 LOM            de estoque         wave/picking       packing+carrier     MANIFESTO
                (WMS/ATP)          (WMS+SSC)           (SSC)               (Correios/Carrier)
                                                                              │
   ┌──────────────────────────────────────────────────────────────────────────┘
   ▼
[06] PÁTIO/DOCA ──▶ [07] TRANSPORTE ──▶ [08] ENTREGA ──▶ [09] PÓS-ENTREGA
 carga (YMS)         em trânsito (TMS)    (TMS/Correios)   portal/NPS (Portal)
                     tracking/ETA         OTIF/POD
                                                             │  se devolução
                                                             ▼
                            [10] LOGÍSTICA REVERSA (RMA) ──▶ reintegra ao estoque (WMS)
```

## 3.2 Estágios × Domínio-dono × Handoff (evento + RPC oficial)

| # | Estágio | Domínio-dono | Entrada → Saída | Evento emitido | RPC/Interface oficial |
|---|---------|--------------|-----------------|----------------|-----------------------|
| 01 | Pedido logístico | **LOM (D01)** ⚠️ | pedido recebido → validado/priorizado | `order.created` | *(gap — a criar; ver Cap. 4.4)* |
| 02 | Alocação/Reserva | **WMS (D02)** | pedido → estoque reservado (ATP) | `stock.reserved` | `register_stock_movement` |
| 03 | Separação | **WMS + SSC** | reserva → onda/picking | `wave.released` | `generate_shipping_waves` |
| 04 | Expedição | **Smart Shipping (D05)** | picking → packing + transportadora | `shipment.packed` | `optimize_packing`, `recommend_carrier`, `ship_outbound_order` |
| 05 | Postagem/Manifesto | **Correios (D06) / Carriers (D07)** | volume → PLP/etiqueta/manifesto | `dispatch.posted` | `generate_dispatches`, `audit_postal_freight` |
| 06 | Pátio/Doca | **YMS (D04)** | manifesto → agendamento/carga | `dock.loaded` | `recommend_dock` |
| 07 | Transporte | **TMS (D03)** | carga → em trânsito (ETA/tracking) | `shipment.in_transit` | `shipment_events` (via `tg_shipment_event_sync`) |
| 08 | Entrega | **TMS/Correios** | trânsito → entregue (POD/OTIF) | `shipment.delivered` | fluxo de status do `shipment` |
| 09 | Pós-entrega | **Portal (suporte)** | entregue → NPS/ocorrência | `delivery.confirmed` | `cxp`/`clx` dashboards |
| 10 | Logística Reversa | **Reversa (D09)** | devolução → conferência → reintegra | `return.reintegrated` | `process_rma_item` → `register_stock_movement` |

> O estágio 02 (reserva) e o 10 (reintegração) usam a **mesma** interface oficial do WMS
> (`register_stock_movement`) — nenhuma outra área grava saldo direto. É o padrão de "interface
> única por domínio" do Cap. 4 já materializado.

## 3.3 Camadas Transversais (observam/servem todo o fluxo)

- **Control Tower (D08)** — consome os eventos de todos os estágios e consolida estado vivo
  (`command_overview`), alertas (`sync_command_alerts`) e crises. Não altera dados de domínio.
- **Logistics AI (D13)** — o LAIOS (`laios_orchestrate`) descobre e roda os motores `*_insights`
  de cada domínio a cada 15 min, propõe decisões (nunca executa ação crítica sem aprovação — Cap. 2).
- **Logistics Analytics (D12)** — materializa KPIs/forecast/heatmap sobre os eventos (BI).
- **Auditoria Logística (suporte)** — auditoria de fretes/operacional e score sobre o histórico.
- **Integrações / Event Bus (iPaaS)** — o barramento por onde os eventos de handoff trafegam
  (fila, retentativa, DLQ, logs) — é o "mecanismo controlado" das regras do Cap. 4.
- **MDM, IAM, ECM, BPM, Super App** — dados-mestre (SKU), identidade/permissão, documentos/POD,
  aprovações/alçadas e captura em campo (coletor/motorista).

## 3.4 Máquina de Estados do Pedido (resumo)

```
draft → validated → allocated → picking → packed → dispatched
      → in_transit → delivered → closed
                   ↘ (exceção) → on_hold / canceled
delivered → return_requested → received → inspected → reintegrated | discarded | refunded
```

Toda transição registra usuário, data/hora, origem e resultado (Cap. 2 · Auditoria) e emite
o evento correspondente da tabela 3.2.

## 3.5 Invariantes do Fluxo (critérios de aceite arquitetural)
1. Nenhum estágio grava dados de outro domínio fora da RPC oficial da coluna "Interface".
2. Todo handoff emite evento no event bus (rastreável, com retentativa).
3. O saldo de estoque só muda por `register_stock_movement` (estágios 02, 03, 10).
4. Control Tower e AI **leem** eventos; não escrevem no domínio de origem.
5. Todo estágio tem KPI próprio (Lead Time do estágio) que alimenta OTIF/Lead Time ponta a ponta.

> **Pendente de decisão do dono:** nomes/versões dos eventos (`order.created`, `shipment.*`…) e
> se o Domínio 01 (LOM) será um módulo novo que passa a **originar** o fluxo (recomendado).

---

# CAPÍTULO 4 — Domínios Funcionais da Plataforma

**Classificação:** Arquitetura Funcional Logística.
**Regra-mestra:** cada domínio tem responsabilidade **exclusiva**; nenhum domínio executa
funções de outro; **nenhum domínio altera dados de outro domínio sem passar pelas interfaces
oficiais** (no GLOP, as interfaces oficiais são as **RPCs `security definer`** + o **event bus**).

## 4.1 Os 13 Domínios Logísticos

| # | Domínio | Responsabilidade | Funções-núcleo |
|---|---------|------------------|----------------|
| 01 | **Logistics Order Management** | Ciclo operacional do pedido até a entrega | receber · validar · disponibilidade · prioridade · encaminhar p/ separação · status · SLA · cancelamento · bloqueio · histórico |
| 02 | **Warehouse Management** | Operação interna do armazém | recebimento · conferência · endereçamento · slotting · picking · packing · inventário · reabastecimento · cross-dock |
| 03 | **Transportation Management** | Todos os transportes | planejamento · viagens · rotas · coletas · entregas · custos · SLA · ETA · tracking · consolidação |
| 04 | **Yard Management** | Área externa do CD | portaria · OCR · RFID · docas · agendamentos · filas · balanças · containers · segurança |
| 05 | **Smart Shipping** | Expedição | conferência final · consolidação · embalagem · manifestação · etiquetas · separação por transportadora |
| 06 | **Correios Enterprise** | Operações Correios | PLP · coletas · contratos · etiquetas · rastreamento · reversa · auditoria · custos · SLA |
| 07 | **Transportadoras** | Gestão de carriers | contratos · custos · performance · SLA · coletas · entregas · tracking · auditorias |
| 08 | **Control Tower** | Monitorar toda a operação | painel · alertas · IA · KPIs · eventos · heat maps · digital twin · centro de crises |
| 09 | **Logística Reversa** | Devoluções | solicitações · recebimento · bipagem · conferência · qualidade · reintegração · descarte · reembolso |
| 10 | **Global Trade** | Logística internacional | importação · exportação · portos · aeroportos · Incoterms · containers · compliance · aduana |
| 11 | **Returnable Asset Management** | Ativos retornáveis | pallets · gaiolas · containers · caixas · IBC · racks · RFID · manutenção · inventário |
| 12 | **Logistics Analytics** | Inteligência operacional | dashboards · KPIs · BI · forecast · DW · data lake · simulações |
| 13 | **Logistics AI** | IA da plataforma | IA operacional/WMS/TMS/Correios/carriers/torre/auditoria · preditiva · prescritiva |

## 4.2 Matriz de Responsabilidades (invariantes de todo domínio)
Cada domínio possui: responsabilidade exclusiva · banco lógico próprio · APIs próprias ·
eventos próprios · KPIs próprios · dashboards próprios · auditoria própria · permissões
próprias · configurações próprias · integrações controladas.

## 4.3 Regras de Comunicação e Evolução
- Troca de dados **apenas** por mecanismos controlados: validar · logar · gerar evento ·
  rastrear · suportar retentativa · informar falha · auditar · manter compatibilidade de versão.
- Todo módulo futuro **pertence a um domínio existente** ou **cria um novo domínio** claramente
  documentado — nada é desenvolvido sem domínio de responsabilidade previamente definido.
- Princípios de integração: baixo acoplamento · alta coesão · responsabilidade única ·
  escalabilidade · independência funcional · versionamento · observabilidade · auditoria.

## 4.4 Mapa Domínio → Implementação Atual (honesto, com gaps)

| Domínio | Rotas atuais | Interface oficial (RPCs) | Status |
|---------|--------------|--------------------------|--------|
| 01 Logistics Order Mgmt | *(parcial: `expedicao`)* | `ship_outbound_order` | ⚠️ **GAP** — não há módulo dedicado de pedido logístico (o `pedidos`/OMS comercial foi removido no pivô). É o **ponto de entrada do fluxo mestre**; candidato nº 1 a especificar. |
| 02 Warehouse Mgmt | `wms`, `operacao-armazem`, `estoque`, `inventario`, `produtos` | `register_stock_movement`, `apply_inventory_count` | ✅ |
| 03 Transportation Mgmt | `tms`, `frota`, `transporte` | `tms_dashboard`, `trip_cost`, `award_freight_quote` | ✅ |
| 04 Yard Mgmt | `yms`, `patio` | `recommend_dock`, `yard_dashboard` | ✅ |
| 05 Smart Shipping | `central-expedicao`, `expedicao` | `shipping_center`, `recommend_carrier`, `optimize_packing` | ✅ |
| 06 Correios Enterprise | `correios`, `postagens` | `correios_dashboard`, `audit_postal_freight` | ✅ |
| 07 Transportadoras | *(dentro de `tms`)* | `cost_by_carrier`, `carrier` perf | 🟡 existe embutido no TMS; separar em domínio próprio é opcional |
| 08 Control Tower | `comando`, `control-tower` | `command_overview`, `lct_command_center` | ✅ |
| 09 Logística Reversa | `devolucoes` | `process_rma_item`, `rma_dashboard` | ✅ |
| 10 Global Trade | `comex` | `import_cost_simulator` | ✅ |
| 11 Returnable Asset Mgmt | `ativos-retornaveis` | `rams_dashboard`, `generate_retention_charges` | ✅ |
| 12 Logistics Analytics | `analytics`, `engenharia-logistica` | `bi_overview`, `kpi_trend`, `demand_heatmap` | ✅ |
| 13 Logistics AI | `ia-central` (LAIOS), `logia` | `laios_orchestrate`, `laios_executive_brief` | ✅ |

**Domínios de suporte transversais** (existem, mas fora dos 13 núcleo — servem a todos):
`portal-cliente`/`pos-venda` (Portal do Cliente = VOL 08), `auditoria` (Auditoria Logística/LAIS),
`mdm` (Governança de Dados), `seguranca` (IAM), `integracoes` (iPaaS/event bus), `processos` (BPM),
`documentos` (ECM), `dispositivos` (Super App), `admin` (config da plataforma).

> **Reconciliação Fase 1 × Cap. 4:** a lista de 16 volumes da Fase 1 e os 13 domínios batem,
> exceto: (a) **Domínio 01** ainda sem módulo dedicado (gap acima); (b) **Transportadoras**
> hoje vive dentro do TMS; (c) **Portal do Cliente** e **Auditoria Logística** são tratados
> como domínios de suporte, não como um dos 13 núcleo.

---

# CAPÍTULO 5 — Fluxo Operacional Logístico Global (End-to-End)

**Classificação:** Arquitetura Operacional Logística.
**Objetivo:** o fluxo operacional **único, padronizado e auditável** que toda operação segue —
da criação da demanda logística ao encerramento. Nenhuma movimentação ocorre fora dele; cada
etapa gera evento, registro, indicador, auditoria e integração. Este é o detalhamento (17
etapas) do fluxo mestre do Cap. 3, e é **materializado pelo Domínio 01 (LOM)** como máquina de estados.

## 5.1 As 17 Etapas × Domínio-dono × Evento padrão

| # | Etapa | Domínio-dono | Ações/validações-chave | Evento (`logistics_order.*`) |
|---|-------|--------------|------------------------|------------------------------|
| 01 | Demanda Logística | LOM | registrar (pedido/transferência/reposição/coleta/devolução/import/export) c/ origem, destino, prioridade, SLA | `created` |
| 02 | Validação Operacional | LOM | estoque disponível (ATP), endereços/CEP, área de atendimento, carrier habilitado, peso/cubagem, incompatibilidades, janelas → bloqueia se inconsistente | `validated` / `blocked` |
| 03 | Planejamento Logístico | LOM + Planning | melhor CD, rota, transportadora, modal, janela, SLA previsto, consolidação (IA justifica) | `planned` |
| 04 | Reserva Operacional | LOM ↔ WMS/YMS | reserva de estoque (lógica), posições, doca, transportadora/veículo | `allocated` |
| 05 | Separação (Picking) | WMS | gerar tarefas, estratégia, menor percurso, início/fim, divergências | `picking` |
| 06 | Conferência | WMS | SKU, qtd, lote, validade, peso, integridade + operador/equipamento | `checked` |
| 07 | Embalagem (Packing) | Smart Shipping | caixa/envelope/proteção/etiqueta/lacre, peso/cubagem final, fotos | `packed` |
| 08 | Expedição | Smart Shipping | consolidação por transportadora/rota/prioridade/coleta | `staged` |
| 09 | Manifestação | Smart Shipping / Correios | manifesto, romaneio, lista de carregamento, etiquetas finais | `manifested` |
| 10 | Postagem / Coleta | Correios / Carriers | horário, motorista/veículo, coleta, objetos não coletados | `posted` |
| 11 | Transporte | TMS | localização, eventos, ETA, SLA, ocorrências, mudanças de rota | `in_transit` |
| 12 | Hub / Cross Docking | TMS / WMS | entrada, conferência, permanência, transferência, saída | `at_hub` |
| 13 | Última Milha | TMS | roteirização urbana, ordem, motorista/veículo, saída p/ entrega | `out_for_delivery` |
| 14 | Entrega | TMS / Correios | data/hora, recebedor, assinatura, foto, geolocalização, tentativas | `delivered` |
| 15 | Pós-Entrega | Portal | status, comprovante (POD), NPS, ocorrências, SLA final | `post_delivery` |
| 16 | Logística Reversa | Reversa (D09) | solicitação, autorização, etiqueta, coleta, inspeção, destinação | `reverse` |
| 17 | Encerramento | LOM | só após todas as etapas + auditoria + eventos + KPIs + histórico consolidado | `closed` |

## 5.2 Evento obrigatório (contrato)
Toda etapa emite evento padronizado no **event bus** com: identificador · tipo · origem ·
destino · data/hora · usuário-ou-sistema responsável · resultado · status · dados complementares.

## 5.3 Indicadores do fluxo (calculados automaticamente)
Lead Time (ponta a ponta) · tempo por etapa · SLA · OTIF · tempo de espera · tempo de picking ·
packing · transporte · entrega · devolução · índice de retrabalho · índice de conformidade.

> **Implementação:** o Domínio 01 (LOM) carrega o catálogo `logistics_stages` (as 17 etapas
> acima) e a máquina de estados; cada transição chama `app.emit_event` publicando o
> `logistics_order.<evento>` no `event_bus` (fan-out p/ webhooks assinantes).

---

# CAPÍTULO 7 — Modelo de Dados Logístico Global

**Classificação:** Arquitetura de Dados Logísticos.
**Objetivo:** entidades, relacionamentos, integridade, rastreabilidade e governança que
servem de base a todos os módulos. Nenhum módulo cria entidade fora deste modelo.

## 7.1 Princípios (já materializados pelas colunas-padrão do `CLAUDE.md`)
Identificação única (**UUID**) · chaves imutáveis · **versão** (`version`) · auditoria
permanente (triggers `tg_write_audit` → `audit_logs`) · relacionamentos explícitos (FK
indexada) · integridade referencial · histórico completo · soft-delete (`deleted_at`).
Identificadores por entidade: ID Global (UUID) · código interno · código externo · QR ·
RFID · código de barras (quando aplicável).

## 7.2 As 14 Grandes Entidades × Tabela real (mapa honesto, com gaps)

| # | Entidade | Tabela(s) atual(is) | Status |
|---|----------|---------------------|--------|
| 01 | Pedidos Logísticos | `logistics_orders` (+items/events/holds) | ✅ (Domínio 01/LOM) |
| 02 | Produtos | `products` (+ lots/serials/media/…) | ✅ |
| 03 | **Volumes** | `packages` (WMS) | 🟡 existe como "package"; falta entidade **volume** cross-modal (tipo caixa/envelope/pallet/container + peso/cubagem/dimensões/origem/destino/transportadora/status) |
| 04 | Endereços Logísticos | `storage_zones`, `storage_locations` (bin: aisle/rack/level/pos) | ✅ |
| 05 | Centros de Distribuição | `warehouses` | ✅ |
| 06 | Transportadoras | `carriers` | ✅ |
| 07 | Veículos | `vehicles` | ✅ |
| 08 | Motoristas | `drivers` | ✅ |
| 09 | Docas | `docks` (+ `dock_appointments`) | ✅ |
| 10 | Rotas | `routes` | ✅ |
| 11 | Eventos | `event_bus` + `logistics_order_events` + `shipment_events` | ✅ (contrato no Cap. 8) |
| 12 | **Ocorrências** | `incidents` (NOC/Control Tower) | 🟡 falta entidade **ocorrência** logística unificada (tipo/categoria/fotos/vídeos/responsável/solução) ligada a pedido/embarque |
| 13 | **Rastreamento** | `shipment_events`, `postal_objects` (SRO Correios) | 🟡 falta **tracking_points** geo unificado (lat/long/cidade/UF/país/data-hora) |
| 14 | Ativos Retornáveis | `returnable_asset_types`, `asset_loans`, `asset_charges` | ✅ |

## 7.3 Cadeia de Relacionamentos (integridade obrigatória)
```
Pedido → Produtos → Volumes → Picking → Packing → Expedição → Transportadora
       → Veículo → Motorista → Rota → Entrega → Eventos → Auditoria
```
**Proibido (integridade):** pedido órfão · volume sem pedido · motorista sem transportadora ·
evento sem origem · entrega sem rastreamento · picking sem operador · packing sem conferência.

## 7.4 Governança de Dados (por entidade)
Responsável · origem · destino · sensibilidade · criticidade · tempo de retenção · política
de arquivamento · política de exclusão. **IA sobre dados** (via MDM): duplicidades,
inconsistências, campos incompletos, produtos/pedidos/volumes/endereços conflitantes.

## 7.5 Gaps priorizados (candidatos a próximas migrations)
1. **`volumes`** — entidade física cross-modal (hoje só `packages` no WMS). Liga pedido↔transporte.
2. **`occurrences`** — ocorrência logística unificada (com mídia) ligada a pedido/embarque/entrega.
3. **`tracking_points`** — pontos de rastreamento geo unificados (alimenta mapa do Cap. 2).

> Os três fecham 100% do Cap. 7; os outros 11 já existem e seguem as colunas-padrão.

---

## Anexo A — Mapa de Implementação (Fase 1, 16 volumes)

Estado atual da base sobre a qual o GLOP evolui (rotas já existentes):

| Vol | Módulo | Rotas atuais |
|----|--------|--------------|
| 01 | RMA & Logística Reversa | `devolucoes` |
| 02 | Torre de Postagens | `postagens` |
| 03 | Torre de Transporte | `transporte` |
| 04 | Correios Enterprise | `correios` |
| 05 | Logistics Control Tower | `comando`, `control-tower` |
| 06 | Auditoria Logística | `auditoria` |
| 07 | Smart Shipping Center | `central-expedicao`, `expedicao`, `distribuicao` |
| 08 | Portal do Cliente Logístico | `portal-cliente`, `pos-venda` |
| 09 | TMS Enterprise | `tms`, `frota`, `manutencao` |
| 10 | Logistics Planning | `engenharia-logistica`, `compras`, `demanda` |
| 11 | WMS Enterprise | `wms`, `operacao-armazem`, `estoque`, `inventario`, `produtos` |
| 12 | YMS Enterprise | `yms`, `patio` |
| 13 | Returnable Asset Management | `ativos-retornaveis` |
| 14 | Global Trade Management | `comex` |
| 15 | Logistics AI OS (LAIOS) | `ia-central`, `logia` |
| 16 | Logistics Data Platform | `analytics` + infra (`mdm`, `integracoes`, `seguranca`, `admin`, `dispositivos`, `processos`, `documentos`) |

> Governança técnica herdada: multi-tenant (tenant→company→branch), RLS em 100% das
> tabelas, RBAC via `app.has_permission`, colunas-padrão + triggers de auditoria,
> soft-delete. Ver `CLAUDE.md`.
