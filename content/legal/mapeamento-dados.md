# Mapeamento de Dados Pessoais (Data Mapping / Fluxo de Dados Pessoais)

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

## Identificação do Documento

| Campo | Conteúdo |
|---|---|
| **Título** | Mapeamento de Dados Pessoais — Fluxo Ponta a Ponta (Data Mapping) |
| **Plataforma** | [NOME FANTASIA: GLOP] — Global Logistics Platform |
| **Operadora / Controladora** | LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, inscrita no CNPJ sob nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190 |
| **Encarregado (DPO)** | a ser designado pela administração — lemoncapsencapsulados@gmail.com |
| **Classificação da informação** | CONFIDENCIAL — Uso interno e regulatório |
| **Fundamento legal** | Lei nº 13.709/2018 (LGPD), art. 37 (registro das operações); art. 38 (RIPD); ISO/IEC 27701; GDPR art. 30 (records of processing) |
| **Versão** | 1.0 — 16 de julho de 2026 |
| **Próxima revisão** | 16 de julho de 2026 (ou a cada mudança material de fluxo, sistema ou sub-operador) |

---

## 1. Objetivo

Este documento estabelece o **inventário de dados pessoais** e o **mapeamento de fluxos ponta a ponta** tratados pela plataforma [NOME FANTASIA: GLOP], operada por LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA (55.836.075/0001-07). Seu propósito é:

1. Cumprir o dever de manutenção de **registro das operações de tratamento** (LGPD, art. 37) e servir de insumo primário ao **Relatório de Impacto à Proteção de Dados Pessoais — RIPD/DPIA** (LGPD, art. 38) e ao **Registro das Atividades de Tratamento — ROPA** (GDPR, art. 30; ISO/IEC 27701).
2. Documentar, sistema a sistema, **onde** os dados nascem, **por onde** trafegam, **onde** repousam, **com quem** são compartilhados e **quando** são descartados.
3. Sustentar as respostas a requisições de titulares (LGPD, arts. 18 e 19), a resposta a incidentes de segurança (LGPD, art. 48) e as auditorias de conformidade (ISO/IEC 27001/27701).
4. Evidenciar as **bases legais** (LGPD, arts. 7º e 11) e as **transferências internacionais** (LGPD, arts. 33 a 36) aplicáveis a cada fluxo.

## 2. Escopo

Este mapeamento cobre o ambiente produtivo da plataforma [NOME FANTASIA: GLOP], compreendendo:

- A **camada de aplicação** (Next.js/App Router, SSR hospedado na Netlify);
- A **camada de dados** (Supabase/PostgreSQL, com RLS multi-tenant, Supabase Auth e Supabase Storage);
- Os **conectores de ingestão** de pedidos (Monetizze, Hotmart, Kiwify) e de e-commerces (Shopify, WooCommerce, Nuvemshop, Mercado Livre);
- Os **sub-operadores** e integrações de saída (VHSYS para NF-e, Correios para pré-postagem e rastreio, gateways de pagamento e split, canais de notificação WhatsApp e e-mail);
- O **Portal Público de Rastreio** (sem autenticação);
- Os **dados dos próprios usuários** da plataforma (produtores, lojistas, coprodutores, afiliados e colaboradores de LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA).

**Fora de escopo:** o tratamento realizado autonomamente pelos gateways de pagamento, marketplaces e plataformas de checkout **antes** da ingestão pela [NOME FANTASIA: GLOP], quando atuam como controladores independentes; e o tratamento realizado pelo produtor/lojista fora da plataforma.

## 3. Definições Operacionais

- **Titular:** pessoa natural a quem se referem os dados pessoais (LGPD, art. 5º, V).
- **Controlador:** a quem competem as decisões sobre o tratamento (LGPD, art. 5º, VI). Na plataforma, em regra, o **produtor/lojista/tenant** é o controlador dos dados do comprador.
- **Operador:** quem trata dados em nome do controlador (LGPD, art. 5º, VII). LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA atua como **operador** quanto aos dados de compradores.
- **Suboperador:** terceiro contratado pelo operador para executar parte do tratamento (Supabase, Netlify, VHSYS, Correios, gateways, canais de mensageria).
- **PII do comprador:** nome, CPF/CNPJ, e-mail, telefone, endereço completo, item/produto adquirido e valor da transação.
- **Tenant / Company / Branch / Membership:** hierarquia de isolamento lógico multi-tenant, aplicada por **RLS** no PostgreSQL, na qual todo registro carrega `tenant_id`, `company_id` e, quando aplicável, `branch_id`.

## 4. Dupla Natureza do Tratamento (Papéis de LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA)

A plataforma [NOME FANTASIA: GLOP] opera sob **dupla natureza**, conforme o conjunto de dados:

| Conjunto de dados | Papel de LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA | Controlador | Instrumento regente |
|---|---|---|---|
| **Dados do comprador** (PII de pedidos ingeridos de gateways e e-commerces) | **Operador** | Produtor / Lojista / Tenant contratante | Contrato de Operador de Dados (DPA) + Termos de Uso |
| **Dados de coprodutores e afiliados** (PIX/bancários para split/repasse) | **Operador** (por conta do produtor titular do split) e, quando relação direta com LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, **Controlador** | Produtor / LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA | DPA + Contrato de Coprodução |
| **Dados cadastrais dos usuários da plataforma** (produtores, lojistas, colaboradores) | **Controlador** | LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA | Política de Privacidade + Termos de Uso |
| **Dados de colaboradores internos** (RH, acessos, RBAC) | **Controlador** | LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA | Política de Privacidade Interna |
| **Logs, trilha de auditoria e telemetria** | **Controlador** (interesse legítimo em segurança) | LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA | Política de Segurança da Informação |

> A separação de papéis é decisiva: como **operador**, LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA trata os dados do comprador **exclusivamente conforme instruções documentadas** do controlador (LGPD, art. 39). Como **controlador**, LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA responde diretamente pelas bases legais e pelos direitos dos titulares dos dados que ela própria coleta.

---

## 5. Inventário de Sistemas (por sistema/componente)

Cada componente da arquitetura é inventariado a seguir, com finalidade, categorias tratadas, local físico/lógico e sub-operador correspondente.

| Sistema / Componente | Função no fluxo | Categorias de dados que transitam/repousam | Local (repouso) | Papel do provedor | Transferência internacional |
|---|---|---|---|---|---|
| **Camada de aplicação Next.js (SSR) — Netlify** | Renderização, orquestração de chamadas, sessão JWT, roteamento das APIs internas (ex.: `/api/lojas/pull`) | PII em trânsito (não persiste no edge); tokens de sessão | Efêmero (memória de execução) | Sub-operador de infraestrutura | Sim — Netlify (EUA) |
| **Supabase Auth (JWT / `auth.users`)** | Autenticação de usuários da plataforma | E-mail, senha (hash), identificadores de sessão, metadados de login | Supabase (PostgreSQL gerenciado) | Sub-operador | Sim — Supabase (região a confirmar em 16 de julho de 2026) |
| **Supabase PostgreSQL (RLS multi-tenant)** | Banco único de negócio; armazena pedidos, PII do comprador, cadastros, split, fiscal | PII do comprador; dados cadastrais; PIX/bancários; documentos fiscais; trilha de auditoria | Supabase | Sub-operador | Sim — Supabase |
| **Supabase Storage (bucket por domínio)** | Armazenamento de documentos (NF-e, comprovantes, anexos) | Documentos fiscais e anexos com PII | Supabase | Sub-operador | Sim — Supabase |
| **Supabase Realtime** | Torre de controle, docas, alertas em tempo real | Status operacional, identificadores de pedido | Supabase | Sub-operador | Sim — Supabase |
| **Supabase Edge Functions** | Lógica crítica, integrações servidoras, IA (LOGIA/pgvector) | PII em processamento; embeddings | Supabase | Sub-operador | Sim — Supabase |
| **Conectores de ingestão — Gateways** (Monetizze, Hotmart, Kiwify) | Puxam pedidos via API (ex.: fluxo "colar chave da plataforma → Puxar pedidos") | PII do comprador, item, valor, dados de transação | Origem no gateway; destino Supabase | Fonte / Controlador independente na origem | Sim (conforme gateway) |
| **Conectores de ingestão — E-commerces** (Shopify, WooCommerce, Nuvemshop, Mercado Livre) | Sincronização de pedidos das lojas | PII do comprador, item, valor, endereço | Origem na loja; destino Supabase | Fonte | Sim (conforme plataforma) |
| **VHSYS (emissão de NF-e)** | Emissão de documentos fiscais | Nome, CPF/CNPJ, endereço, item, valor | VHSYS (Brasil) | Sub-operador / Controlador por obrigação fiscal | Não (Brasil) |
| **Correios — Pré-postagem (PPN) e Rastreio (SRO)** | Geração de etiqueta/pré-postagem e rastreamento | Nome, endereço completo, telefone, item (para logística) | Correios (Brasil) | Operador/Controlador (serviço postal) | Não (Brasil) |
| **Gateways de split/repasse** (AppMax e demais) | Apuração de comissão, split e repasse | PIX/dados bancários de coprodutores/afiliados; valores | Gateway | Sub-operador / Controlador para fins de pagamento | Sim (conforme gateway) |
| **Canais de notificação — E-mail** | Notificação transacional ao comprador (status, rastreio) | E-mail, nome, status do pedido, código de rastreio | Provedor de e-mail | Sub-operador | Sim (provável — provedor internacional) |
| **Canais de notificação — WhatsApp** | Notificação transacional ao comprador | Telefone, nome, status, código de rastreio | Provedor de mensageria/Meta | Sub-operador | Sim — Meta (EUA) |
| **Portal Público de Rastreio (sem login)** | Consulta pública de status pelo comprador | Exibe **apenas status neutro**; sem PII sensível/identificadora ampla | Servido via app | Componente próprio | N/A (dados minimizados) |
| **LOGIA / pgvector (IA)** | Inteligência sobre a operação (ex.: importação inteligente de pedidos, document intelligence) | Embeddings derivados; PII em processamento controlado | Supabase | Sub-operador | Sim — Supabase |

---

## 6. Categorias de Dados Pessoais e Titulares

### 6.1 Por categoria de titular

| Titular | Categorias de dados pessoais | Origem | Papel de LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA |
|---|---|---|---|
| **Comprador (consumidor final)** | Nome; CPF/CNPJ; e-mail; telefone; endereço completo; produto/item adquirido; valor; código de rastreio; histórico de status | Ingestão via gateways e e-commerces | Operador |
| **Produtor / Lojista (usuário-tenant)** | Nome/razão social; CPF/CNPJ; e-mail; telefone; credenciais de acesso; chaves de API (write-only); dados de faturamento | Cadastro direto na plataforma | Controlador |
| **Coprodutor / Afiliado** | Nome; CPF/CNPJ; chave PIX / dados bancários; percentual de comissão; valores apurados e repassados | Cadastro para split/repasse | Operador e/ou Controlador |
| **Colaborador de LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA** | Nome; e-mail corporativo; função/role (RBAC); logs de acesso; identificadores de auditoria | RH e provisionamento de acessos | Controlador |
| **Contato/representante do tenant** | Nome; e-mail; telefone; cargo | Cadastro contratual | Controlador |

### 6.2 Por natureza do dado

| Natureza | Exemplos na plataforma | Classificação LGPD | Cuidados |
|---|---|---|---|
| **Dado pessoal comum** | Nome, e-mail, telefone, endereço, item, valor | Art. 5º, I | Minimização, RLS, criptografia em trânsito e repouso |
| **Dado de identificação fiscal** | CPF/CNPJ | Art. 5º, I (identificador oficial) | Acesso restrito por RBAC; mascaramento em telas não essenciais |
| **Dado financeiro** | Chave PIX, dados bancários, valores de repasse | Art. 5º, I | Acesso mínimo; segregação de função; trilha de auditoria reforçada |
| **Dado sensível** | Não coletado de forma intencional pela plataforma | Art. 5º, II | Vedação de coleta; filtro na ingestão; não há finalidade que o justifique |
| **Dado de menor** | Não é público-alvo; não solicitado | Art. 14 | Vedação; caso identificado, tratamento no melhor interesse e exclusão |
| **Metadados/telemetria** | Logs, IP, trilha de auditoria, timestamps | Art. 5º, I quando vinculável | Interesse legítimo (segurança); retenção limitada |

> A plataforma **não coleta dados sensíveis** (LGPD, art. 5º, II) de forma intencional. Havendo ingresso acidental de dado sensível a partir de campo livre de origem, aplica-se rotina de detecção, minimização e descarte, registrada na trilha de auditoria.

---

## 7. Fluxos Ponta a Ponta (End-to-End)

A seguir, o ciclo de vida do dado do comprador, em cinco estágios: **ingestão → armazenamento → uso → compartilhamento → descarte**.

### 7.1 Estágio 1 — Ingestão dos Pedidos

**Gatilho:** o produtor/lojista cola a chave/credencial da plataforma de origem e aciona "Puxar pedidos" (Store Integration Hub / rota `/api/lojas/pull`), ou configura a sincronização automática dos e-commerces.

| Etapa | Descrição | Dados envolvidos | Base legal |
|---|---|---|---|
| 1.1 | Autenticação do conector junto à origem (gateway/e-commerce) via chave/token fornecido pelo tenant | Credenciais de API (write-only, armazenadas cifradas) | Execução de contrato com o tenant (art. 7º, V) |
| 1.2 | Coleta dos pedidos via API (Monetizze com auth em duas etapas X_CONSUMER_KEY→TOKEN; Hotmart; Kiwify; Shopify; WooCommerce; Nuvemshop; Mercado Livre) | PII do comprador; item; valor; endereço | Cumprimento de obrigação do controlador; interesse legítimo logístico |
| 1.3 | Normalização e deduplicação (importação inteligente / document intelligence — módulo SOIDI) | PII estruturada | Instrução do controlador |
| 1.4 | Carimbo de `tenant_id`, `company_id`, `branch_id` e colunas de auditoria (`created_by`, `created_at`) | Identificadores de isolamento | Segurança do tratamento (art. 46) |

### 7.2 Estágio 2 — Armazenamento (Supabase)

| Etapa | Descrição | Controle aplicado |
|---|---|---|
| 2.1 | Persistência no PostgreSQL, isolada por **RLS** (a linha só é visível ao tenant/company autorizado) | RLS + policies por tabela |
| 2.2 | Anexos e documentos fiscais em **Supabase Storage** (bucket por domínio) | ACL por bucket + política de acesso |
| 2.3 | Colunas de auditoria e **triggers** (`tg_touch_row`, `tg_write_audit`) registram toda inserção/alteração/exclusão | Trilha de auditoria imutável |
| 2.4 | Criptografia em trânsito (TLS) e em repouso (camada Supabase) | Criptografia |
| 2.5 | **Soft-delete** — nunca DELETE físico; leitura filtra `deleted_at is null` | Reversibilidade e rastreabilidade |

### 7.3 Estágio 3 — Uso Interno

| Uso | Descrição | Dados | Base legal |
|---|---|---|---|
| 3.1 | Roteamento logístico, separação, expedição (WMS/TMS/YMS) | Endereço, item, volume | Execução do serviço logístico |
| 3.2 | Emissão fiscal (preparo dos dados para NF-e) | Nome, CPF/CNPJ, valor, item | Obrigação legal/fiscal (art. 7º, II) |
| 3.3 | Inteligência operacional (LOGIA/pgvector) — previsões, importação inteligente | Embeddings derivados; PII controlada | Interesse legítimo (art. 7º, IX) |
| 3.4 | BI e KPIs via RPC (agregações no banco, não em JS) | Dados agregados/pseudonimizados | Interesse legítimo |
| 3.5 | Controle de acesso por **RBAC** (`has_permission`) a cada operação | Metadados de permissão | Segurança |

### 7.4 Estágio 4 — Compartilhamento com Terceiros/Sub-operadores

| Destinatário | Dados compartilhados | Finalidade | Papel | Base legal |
|---|---|---|---|---|
| **VHSYS** | Nome, CPF/CNPJ, endereço, item, valor | Emissão de NF-e | Sub-operador / Controlador fiscal | Obrigação legal (art. 7º, II) |
| **Correios (PPN/SRO)** | Nome, endereço completo, telefone, dados do volume | Pré-postagem e rastreamento | Operador postal | Execução de contrato / obrigação de entrega |
| **Gateways de pagamento** (Monetizze/AppMax/Hotmart/Kiwify) | Dados de transação; PIX/bancários de coprodutores | Split, apuração e repasse | Sub-operador / Controlador de pagamento | Execução de contrato (art. 7º, V) |
| **WhatsApp (Meta) / E-mail** | Telefone/e-mail, nome, status, código de rastreio | Notificação transacional | Sub-operador | Execução de contrato / interesse legítimo |
| **Supabase / Netlify** | Todos os dados hospedados/processados | Infraestrutura de hospedagem e banco | Sub-operador | Necessidade técnica (art. 7º, V) |
| **Portal Público de Rastreio** | **Somente status neutro** (sem nome, CPF ou endereço) | Autoconsulta do comprador | Componente próprio | Legítimo interesse com minimização |

> **Princípio de minimização no rastreio público:** o Portal Público (sem login) foi desenhado para expor **apenas status neutro**, jamais nome, CPF, endereço ou telefone, evitando enumeração de PII por código de rastreio.

### 7.5 Estágio 5 — Retenção e Descarte

| Categoria | Retenção | Fundamento | Descarte |
|---|---|---|---|
| PII do comprador (pedido) | Durante a relação + prazo prescricional | CDC (art. 27), Código Civil | Anonimização/eliminação após prazo |
| Documentos fiscais (NF-e) | 5 anos, no mínimo | Legislação fiscal | Eliminação segura após prazo |
| Dados de split/PIX | Enquanto durar apuração + prazo contábil/fiscal | Obrigação legal | Eliminação segura |
| Logs e trilha de auditoria | Prazo definido na Política de Retenção | Segurança/defesa | Rotação e expurgo |
| Cadastro de usuário inativo | Até solicitação de exclusão ou fim contratual | Base contratual | Soft-delete → anonimização |
| Credenciais de API | Até revogação pelo tenant | Segurança | Revogação e purga cifrada |

> O descarte segue a **Política de Descarte** e a **Política de Retenção**. Como regra técnica, a plataforma pratica **soft-delete** (marcação `deleted_at`/`reason_deleted`), seguido de **anonimização ou eliminação definitiva** ao término do prazo legal, com registro na trilha de auditoria.

---

## 8. Descrição do Diagrama de Fluxo de Dados

O diagrama de fluxo (Data Flow Diagram) da [NOME FANTASIA: GLOP] pode ser lido como um pipeline linear com ramificações de saída, descrito textualmente abaixo (para renderização em ferramenta gráfica a partir desta narrativa):

**Nós de origem (fontes externas):**
- Gateways: Monetizze, Hotmart, Kiwify.
- E-commerces: Shopify, WooCommerce, Nuvemshop, Mercado Livre.

**Fluxo principal (esquerda → direita):**

1. **[Origem]** Comprador realiza a compra no gateway/loja → PII nasce no controlador de origem.
2. **[Ingestão]** Conector da [NOME FANTASIA: GLOP] autentica com a chave do tenant e **puxa** o pedido via API (seta de entrada rotulada "PII: nome, CPF, e-mail, telefone, endereço, item, valor").
3. **[Aplicação Next.js/Netlify]** processa em trânsito (nó efêmero, sem persistência de PII no edge) e encaminha para o banco.
4. **[Supabase PostgreSQL — RLS]** persiste o registro carimbado com `tenant_id`/`company_id` (nó de repouso central; borda dupla indicando isolamento multi-tenant e criptografia). Anexos seguem para **[Supabase Storage]**; eventos em tempo real para **[Realtime]**; lógica crítica/IA para **[Edge Functions / LOGIA / pgvector]**.
5. **[Uso interno]** WMS/TMS/YMS, preparo fiscal, BI (RPC) e RBAC consomem o dado dentro do perímetro Supabase.

**Ramificações de saída (compartilhamentos), partindo do nó central Supabase:**

- **→ VHSYS**: seta rotulada "NF-e: nome, CPF/CNPJ, endereço, item, valor" (Brasil).
- **→ Correios (PPN/SRO)**: seta rotulada "Logística: nome, endereço, telefone, volume" (Brasil).
- **→ Gateways de split (AppMax etc.)**: seta rotulada "Split/repasse: PIX/bancários, valores".
- **→ WhatsApp/E-mail**: seta rotulada "Notificação: telefone/e-mail, status, rastreio".
- **→ Portal Público de Rastreio**: seta rotulada "**apenas status neutro**" (nó público, borda tracejada indicando ausência de autenticação e minimização de PII).

**Fronteiras de confiança (trust boundaries), representadas por linhas pontilhadas:**
- Fronteira 1: entre as fontes externas e a plataforma (ponto de ingestão).
- Fronteira 2: entre a aplicação (Netlify, EUA) e o banco (Supabase).
- Fronteira 3: entre o perímetro Supabase e cada sub-operador de saída (VHSYS, Correios, gateways, mensageria).
- Fronteira 4 (crítica): entre o dado autenticado interno e o **Portal Público** — travessia unidirecional que só deixa passar status neutro.

**Nó terminal (ciclo de vida):**
- **[Retenção → Descarte]**: soft-delete → anonimização/eliminação ao fim do prazo legal, com escrita na trilha de auditoria.

Cada seta do diagrama corresponde a uma linha das tabelas dos itens 5, 7 e 9, permitindo rastrear qualquer categoria de dado do ponto de entrada ao descarte.

---

## 9. Bases Legais (LGPD, arts. 7º e 11)

| Operação de tratamento | Base legal | Dispositivo | Titular |
|---|---|---|---|
| Ingestão e processamento logístico de pedidos por conta do tenant | Cumprimento de obrigação/execução por conta do controlador; execução de contrato | Art. 7º, V; art. 39 | Comprador |
| Emissão de NF-e e guarda fiscal | Cumprimento de obrigação legal/regulatória | Art. 7º, II | Comprador |
| Notificação transacional de status/rastreio | Execução de contrato; legítimo interesse | Art. 7º, V e IX | Comprador |
| Split, apuração e repasse a coprodutores/afiliados | Execução de contrato | Art. 7º, V | Coprodutor/Afiliado |
| Cadastro e autenticação de usuários da plataforma | Execução de contrato | Art. 7º, V | Produtor/Lojista/Colaborador |
| Segurança da informação, prevenção a fraude, logs e auditoria | Legítimo interesse | Art. 7º, IX; art. 10 | Todos |
| Inteligência operacional (LOGIA), com pseudonimização | Legítimo interesse | Art. 7º, IX | Comprador (dado derivado) |
| Comunicações de marketing (se houver) | Consentimento | Art. 7º, I | Usuário/Contato |

> Para o **legítimo interesse** (art. 7º, IX; art. 10), aplica-se o **teste de proporcionalidade (LIA — Legitimate Interest Assessment)**: (i) finalidade legítima; (ii) necessidade/minimização; (iii) balanceamento com direitos e liberdades do titular, com salvaguardas (RLS, RBAC, criptografia, minimização no rastreio público).

---

## 10. Compartilhamento e Sub-operadores (Cadeia de Tratamento)

| Sub-operador | Categoria de serviço | Dados acessados | Instrumento contratual | Localização do tratamento |
|---|---|---|---|---|
| **Supabase** | Banco, Auth, Storage, Realtime, Edge, IA | Todos os dados persistidos | DPA + cláusulas-padrão de transferência | Internacional (a confirmar em 16 de julho de 2026) |
| **Netlify** | Hospedagem SSR (aplicação) | PII em trânsito | DPA + cláusulas-padrão | EUA |
| **VHSYS** | Emissão de NF-e | Dados fiscais do comprador | Contrato + DPA | Brasil |
| **Correios** | Pré-postagem e rastreio | Nome, endereço, telefone, volume | Contrato de serviço postal | Brasil |
| **Monetizze / Hotmart / Kiwify** | Gateway/ingestão | PII do comprador, transação | Termos + integração autorizada pelo tenant | Conforme provedor |
| **AppMax** (e demais de split) | Split/repasse | PIX/bancários, valores | Contrato + DPA | Conforme provedor |
| **Provedor de e-mail** | Notificação transacional | E-mail, nome, status | DPA | Provável internacional |
| **WhatsApp / Meta** | Notificação transacional | Telefone, nome, status | Termos do provedor + DPA | EUA |

> LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, como operadora, mantém contrato com cada sub-operador contendo **obrigações de proteção de dados equivalentes** (LGPD, art. 39; GDPR art. 28) e **autorização prévia** do controlador para a subcontratação, registrada no DPA.

---

## 11. Transferências Internacionais (LGPD, arts. 33 a 36)

| Destinatário | País/Região | Dados | Mecanismo de adequação |
|---|---|---|---|
| **Supabase** | [A confirmar em 16 de julho de 2026] | Todos os dados persistidos | Cláusulas-padrão contratuais; garantias do art. 33, II; verificar região de hospedagem |
| **Netlify** | EUA | PII em trânsito (SSR) | Cláusulas-padrão contratuais (art. 33, II, "d") |
| **WhatsApp / Meta** | EUA | Telefone, nome, status | Cláusulas-padrão / termos com garantias |
| **Provedor de e-mail** | [A confirmar] | E-mail, nome, status | Cláusulas-padrão contratuais |
| **Gateways** (conforme provedor) | [A confirmar] | PII/transação | Cláusulas-padrão / garantias equivalentes |

Enquanto a ANPD não editar a lista de países com **nível adequado** de proteção, as transferências para Supabase, Netlify e Meta apoiam-se em **cláusulas-padrão contratuais** e **garantias específicas** (LGPD, art. 33, II). Recomenda-se: (i) confirmar e, se possível, fixar a **região de hospedagem** do Supabase (preferencialmente Brasil/América do Sul, quando disponível); (ii) manter o **inventário de subprocessadores atualizado**; (iii) reavaliar mecanismos a cada novo entendimento da ANPD.

---

## 12. Medidas de Segurança Aplicadas ao Fluxo

- **Isolamento multi-tenant por RLS** em todas as tabelas de `public` — nenhuma decisão de acesso confia no frontend.
- **RBAC** via `has_permission('resource.action', company_id)` em cada operação de escrita.
- **Criptografia** em trânsito (TLS) e em repouso (camada Supabase).
- **Trilha de auditoria** por triggers (`tg_write_audit`) em toda inserção/alteração/exclusão; colunas de auditoria em todo registro.
- **Soft-delete** universal; ausência de DELETE físico.
- **Credenciais de API write-only**, cifradas, revogáveis pelo tenant.
- **Minimização** no Portal Público (apenas status neutro).
- **Segregação de funções** e privilégio mínimo para dados financeiros (PIX/bancários).
- Alinhamento a **ISO/IEC 27001, 27701, 22301, 31000, NIST CSF e OWASP** (ver Política de Segurança).

## 13. Direitos dos Titulares e Rastreabilidade (LGPD, arts. 18 e 19)

O mapeamento habilita o atendimento a: confirmação de tratamento; acesso; correção; anonimização/bloqueio/eliminação; portabilidade; informação sobre compartilhamento; revogação de consentimento. Como **operador**, LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA **repassa** a requisição ao controlador (produtor/lojista) e o **apoia tecnicamente** (localização do dado por `tenant_id`/`company_id`, exportação, eliminação). Como **controlador**, responde diretamente. Prazo-alvo de resposta: conforme LGPD e Política de Privacidade. Canal: lemoncapsencapsulados@gmail.com.

---

## Engenharia Jurídica & Governança

### (a) Fundamentação das Cláusulas

| Seção | Fundamento legal/normativo |
|---|---|
| Registro das operações (todo o documento) | LGPD, art. 37; GDPR art. 30; ISO/IEC 27701 |
| RIPD/DPIA (insumo) | LGPD, art. 38; GDPR art. 35 |
| Papéis Operador/Controlador (item 4) | LGPD, art. 5º, VI e VII; art. 39; GDPR art. 28 |
| Bases legais (item 9) | LGPD, arts. 7º, 10 e 11 |
| Legítimo interesse / LIA (itens 9 e 12) | LGPD, art. 7º, IX e art. 10 |
| Segurança do tratamento (item 12) | LGPD, arts. 46 a 49; ISO/IEC 27001; NIST CSF; OWASP |
| Compartilhamento/sub-operadores (item 10) | LGPD, art. 39; GDPR art. 28 |
| Transferências internacionais (item 11) | LGPD, arts. 33 a 36 |
| Retenção fiscal (item 7.5) | Legislação fiscal (mínimo 5 anos); CDC, art. 27 |
| Direitos dos titulares (item 13) | LGPD, arts. 18 e 19 |
| Continuidade e resiliência | ISO 22301; Política de Backup |
| Gestão de riscos | ISO 31000 |

### (b) Riscos Mitigados

1. **Vazamento cross-tenant** — mitigado por RLS + RBAC + carimbo de `tenant_id`/`company_id`.
2. **Exposição de PII em rastreio público** — mitigado pela exibição de apenas status neutro (minimização).
3. **Uso indevido de dados do comprador pelo operador** — mitigado pela vinculação a instruções do controlador (art. 39) e pelo DPA.
4. **Transferência internacional sem salvaguarda** — mitigado por cláusulas-padrão e revisão de região de hospedagem.
5. **Perda de rastreabilidade / não repúdio** — mitigado por trilha de auditoria imutável por triggers.
6. **Retenção excessiva** — mitigado por Política de Retenção/Descarte e soft-delete com prazo.
7. **Comprometimento de credenciais de API** — mitigado por armazenamento write-only, cifrado e revogável.
8. **Coleta acidental de dado sensível** — mitigado por vedação, detecção e descarte.
9. **Falha de sub-operador na cadeia** — mitigado por contratos com obrigações equivalentes e autorização prévia.
10. **Incapacidade de responder ao titular** — mitigado pela rastreabilidade que localiza o dado por chaves de tenant.

### (c) Checklist de Conformidade

- [ ] Inventário de sistemas revisado e atualizado (item 5).
- [ ] Cada categoria de dado tem base legal identificada (item 9).
- [ ] LIA documentado para cada tratamento por legítimo interesse.
- [ ] DPA firmado com todos os sub-operadores (Supabase, Netlify, VHSYS, Correios, gateways, mensageria).
- [ ] Região de hospedagem Supabase confirmada e registrada em 16 de julho de 2026.
- [ ] Mecanismo de transferência internacional vigente para cada destino (item 11).
- [ ] Portal Público validado como expondo apenas status neutro.
- [ ] Políticas de Retenção e Descarte vigentes e vinculadas aos prazos deste mapa.
- [ ] Trilha de auditoria ativa (triggers) em todas as tabelas de negócio.
- [ ] Fluxo de atendimento a titulares testado (operador ↔ controlador).
- [ ] RIPD/DPIA elaborado a partir deste mapeamento.
- [ ] Encarregado (DPO) designado e canal publicado.

### (d) Matriz RACI

| Atividade | DPO/Encarregado | Segurança da Informação | Engenharia/Dev | Jurídico | Controlador (Tenant) |
|---|---|---|---|---|---|
| Manter o mapeamento de dados | A | C | R | C | I |
| Confirmar região/hospedagem (Supabase) | C | R | R | C | I |
| Firmar DPAs com sub-operadores | C | C | I | R/A | I |
| Elaborar RIPD/DPIA | R/A | C | C | C | I |
| Responder a titulares (dados do comprador) | C | I | R | C | A/R |
| Responder a titulares (dados próprios) | A | I | R | C | I |
| Executar retenção/descarte | C | R | R | C | I |
| Monitorar transferências internacionais | A | R | C | R | I |
| Revisar bases legais e LIA | R/A | I | I | R | I |

(R = Responsável; A = Aprovador; C = Consultado; I = Informado)

### (e) Plano de Revisão

- **Periodicidade ordinária:** anual, com data-alvo em 16 de julho de 2026.
- **Gatilhos de revisão extraordinária:** inclusão/troca de sub-operador; nova fonte de ingestão; mudança de região de hospedagem; nova finalidade de tratamento; incidente de segurança; alteração legislativa ou de entendimento da ANPD.
- **Responsável pela condução:** DPO/Encarregado, com apoio de Engenharia e Jurídico.
- **Saída da revisão:** atualização deste documento, do ROPA/RIPD e do inventário de subprocessadores.

### (f) Controle de Versão

| Versão | Data | Autor | Alteração | Aprovação |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | Chief Legal AI (minuta) | Emissão inicial do mapeamento de dados ponta a ponta | Pendente — a ser designado pela administração |
| [n] | 16 de julho de 2026 | [PARTE] | [descrição] | [aprovador] |

---

**Encerramento.** Este mapeamento integra o programa de governança em privacidade de LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA (55.836.075/0001-07) para a plataforma [NOME FANTASIA: GLOP] e deve ser lido em conjunto com o DPA, a Política de Privacidade, a Política de Segurança da Informação, as Políticas de Retenção e Descarte e o ROPA/RIPD. Dúvidas e requisições de titulares: lemoncapsencapsulados@gmail.com. Documento aprovado por [CONTRATANTE]/[PARTE] em 16 de julho de 2026.
