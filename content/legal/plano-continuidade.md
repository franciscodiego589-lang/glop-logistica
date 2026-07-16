> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# PLANO DE CONTINUIDADE DE NEGÓCIOS (PCN / BCP)

**[NOME FANTASIA: GLOP] — Global Logistics Platform**

**Documento:** PCN-BCP-001 — Plano de Continuidade de Negócios e Recuperação de Desastres
**Classificação da informação:** Interno / Confidencial — Restrito ao Comitê de Crise
**Norma de referência:** ISO 22301 (Sistema de Gestão de Continuidade de Negócios — SGCN), com integração a ISO/IEC 27001, ISO/IEC 27701 e ISO 31000
**Versão:** 1.0
**Data de emissão:** 16 de julho de 2026
**Aprovação:** a ser designado pela administração / Diretoria Executiva / Comitê de Crise
**Controlador / Operador:** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, inscrita no CNPJ sob nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, doravante denominada **[NOME FANTASIA: GLOP]** ou "Plataforma".

---

## 1. Objetivo

1.1. Este Plano de Continuidade de Negócios (**PCN**, ou *Business Continuity Plan* — **BCP**) estabelece a estrutura de governança, as estratégias, os procedimentos e as responsabilidades destinados a **assegurar a continuidade das operações críticas** da plataforma **[NOME FANTASIA: GLOP]** — SaaS de logística e ERP para dropshipping e infoprodutos no Brasil — e a **recuperação tempestiva** dos serviços diante de incidentes disruptivos, em conformidade com a norma **ISO 22301**.

1.2. O PCN visa a:

- **Proteger a vida, a integridade das pessoas e a reputação** da Plataforma;
- **Minimizar o impacto** operacional, financeiro, contratual, regulatório e sobre titulares de dados decorrente de indisponibilidades;
- **Restabelecer os processos críticos** dentro das metas de **RTO (Recovery Time Objective)** e **RPO (Recovery Point Objective)** definidas neste documento;
- **Preservar a confidencialidade, integridade e disponibilidade (CID)** das informações, inclusive dos dados pessoais de compradores, produtores, lojistas, coprodutores, afiliados e colaboradores, na dupla condição de **OPERADOR** (dados de compradores tratados em nome de produtores/lojistas Controladores) e **CONTROLADOR** (dados dos próprios usuários e colaboradores), nos termos da **Lei nº 13.709/2018 (LGPD)**;
- **Assegurar o cumprimento de obrigações legais, contratuais e de SLA** durante e após o evento disruptivo.

1.3. Este PCN é insumo e destinatário mútuo da **Política de Backup e Restauração (POL-BKP-001)**, do **Plano de Resposta a Incidentes**, da **Política de Segurança da Informação** e dos **DPAs** firmados com sub-operadores.

---

## 2. Escopo

2.1. Este Plano aplica-se a **todos os processos, serviços, ativos, pessoas e fornecedores** que suportam a operação da **[NOME FANTASIA: GLOP]**, abrangendo, sem limitação:

- **Camada de aplicação e hospedagem:** frontend e SSR em **Next.js (App Router)** hospedado na **Netlify**;
- **Camada de dados e identidade:** banco **Supabase (PostgreSQL)** com isolamento **multi-tenant por RLS** (Tenant → Company → Branch → Membership), **Supabase Auth (JWT)**, **Supabase Storage** e **Supabase Edge Functions**;
- **Camada de ingestão de pedidos:** integrações via API com gateways **Monetizze, Hotmart, Kiwify** e e-commerces **Shopify, WooCommerce, Nuvemshop, Mercado Livre**, com PII do comprador (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto, valor);
- **Camada fiscal:** emissão de **NF-e via VHSYS** e guarda de documentos fiscais;
- **Camada de transporte:** **Correios** — pré-postagem (**PPN**), rastreio (**SRO**) e notificação ao comprador por **e-mail/WhatsApp**;
- **Camada financeira de coprodução:** coprodutores/afiliados, comissão, apuração, repasses e **split (AppMax)**, com dados de **PIX/bancários**;
- **Portal público de rastreio** (sem login, expõe apenas status neutro);
- **Controles de segurança:** RLS por empresa, RBAC (`has_permission`), soft-delete, trilha de auditoria por triggers, credenciais de API write-only e colunas de auditoria em todo registro.

2.2. **Sub-operadores e dependências externas** cobertos pela análise de continuidade: **Supabase** e **Netlify** (infraestrutura), **VHSYS** (NF-e), **Correios** (transporte), **gateways** (Monetizze/AppMax/Hotmart/Kiwify), provedores de **WhatsApp/e-mail**.

2.3. **Fora de escopo direto** (regidos por instrumentos próprios, com remissão neste PCN): os planos internos de continuidade dos próprios sub-operadores, os quais **complementam**, mas **não substituem**, os controles aqui definidos; e a continuidade de operações de negócio dos Controladores (produtores/lojistas), cuja responsabilidade lhes é própria, ressalvado o dever da Plataforma de comunicar indisponibilidades que os afetem.

2.4. Este Plano vincula **todos os colaboradores, prestadores, administradores, membros do Comitê de Crise e sub-operadores** com papel na continuidade, independentemente do vínculo.

---

## 3. Definições

- **PCN / BCP (Plano de Continuidade de Negócios):** conjunto de procedimentos para manter e restabelecer processos críticos após disrupção.
- **PRD / DRP (Plano de Recuperação de Desastres):** componente técnico do PCN voltado à recuperação de TI/infraestrutura.
- **BIA (Business Impact Analysis / Análise de Impacto no Negócio):** metodologia que identifica processos críticos e quantifica os impactos de sua interrupção ao longo do tempo.
- **RTO (Recovery Time Objective):** tempo máximo tolerável para restabelecer um serviço após a interrupção.
- **RPO (Recovery Point Objective):** volume máximo de dados (medido em tempo) que a organização tolera perder.
- **MTPD / MTD (Maximum Tolerable Period of Disruption):** período máximo além do qual a interrupção causa dano inaceitável e potencialmente irreversível ao negócio.
- **MBCO (Minimum Business Continuity Objective):** nível mínimo de serviço aceitável durante a disrupção.
- **WRT (Work Recovery Time):** tempo, dentro do RTO, para validar e reintegrar dados após a recuperação técnica.
- **Incidente disruptivo:** evento que interrompe, degrada ou ameaça interromper processos críticos.
- **Cenário de continuidade:** situação hipotética de disrupção usada para planejar e testar respostas.
- **Comitê de Crise:** órgão de decisão e coordenação acionado durante o evento.
- **Acionamento (invocation):** ato formal de declarar o estado de continuidade/desastre e disparar o Plano.
- **Failover:** transferência de operação para recurso/rota alternativa.
- **PITR (Point-in-Time Recovery):** recuperação do banco a um instante arbitrário via reprodução de WAL.
- **Modo degradado:** operação parcial com funcionalidades essenciais preservadas e não essenciais suspensas.
- **SPOF (Single Point of Failure):** ponto único de falha cuja indisponibilidade paralisa o processo.
- **Controlador / Operador:** conforme art. 5º, VI e VII, da LGPD.

---

## 4. Governança do SGCN (Sistema de Gestão de Continuidade)

4.1. **Política de continuidade:** a Direção da **[NOME FANTASIA: GLOP]** compromete-se a estabelecer, implementar, manter e melhorar continuamente o SGCN, provendo recursos, atribuindo responsabilidades e revisando o desempenho (cláusulas 5 e 9 da ISO 22301).

4.2. **Estrutura de papéis do SGCN:**

| Papel | Atribuição em continuidade |
|---|---|
| **Patrocinador Executivo (Diretoria)** | Aprova o PCN, autoriza recursos e declara desastre de alto impacto |
| **Gestor de Continuidade (BCM)** | Proprietário do PCN; conduz BIA, estratégias, testes e melhoria contínua |
| **Coordenador do Comitê de Crise** | Lidera o acionamento e a coordenação durante o evento |
| **Líder Técnico / DevOps** | Executa failover, restauração e recuperação de infraestrutura |
| **Encarregado (DPO) — a ser designado pela administração, lemoncapsencapsulados@gmail.com** | Avalia impacto a titulares, aciona resposta a incidentes e comunica ANPD/titulares quando aplicável |
| **Líder de Comunicação de Crise** | Conduz a comunicação interna e externa (clientes, sub-operadores, autoridades) |
| **Líder Jurídico/Compliance** | Avalia obrigações legais, contratuais e regulatórias e riscos de responsabilização |
| **Ponto Focal por Sub-operador** | Interlocução técnica com Supabase, Netlify, VHSYS, Correios e gateways |

4.3. **Apetite a risco:** a continuidade é priorizada segundo a criticidade dos processos apurada na BIA (seção 5) e o apetite a risco aprovado pela Direção, alinhado à **ISO 31000**.

4.4. **Integração documental:** o PCN opera de forma indissociável com a Política de Backup (metas RTO/RPO e testes de restauração), o Plano de Resposta a Incidentes (tratamento de incidentes de segurança/dados) e os DPAs (obrigações dos sub-operadores em contingência).

---

## 5. Análise de Impacto no Negócio (BIA)

5.1. **Metodologia:** para cada processo, avaliam-se (i) a **criticidade**, (ii) os **impactos** da interrupção nas dimensões financeira, operacional, reputacional, contratual/SLA, legal/regulatória e sobre titulares de dados, e (iii) a **evolução do impacto no tempo**, definindo **MTPD**, **RTO** e **RPO**.

5.2. **Escala de criticidade e MTPD:**

| Nível | Criticidade | MTPD (disrupção máxima tolerável) | Característica |
|---|---|---|---|
| **1** | Crítico / Vital | ≤ 4 h | Interrupção paralisa vendas, fiscal ou financeiro; dano grave e crescente |
| **2** | Alto | ≤ 8 h | Degrada expedição/transporte e comunicação ao comprador |
| **3** | Médio | ≤ 24 h | Afeta funções de apoio; tolerável por período curto |
| **4** | Baixo | ≤ 72 h | Impacto marginal; contornável manualmente |

5.3. **Impacto no tempo (curva de dano) por processo crítico:**

| Processo | 0–1 h | 1–4 h | 4–8 h | 8–24 h | > 24 h |
|---|---|---|---|---|---|
| Ingestão de pedidos (API gateways/e-commerces) | Moderado | Alto | Grave | Crítico | Irreversível (pedidos perdidos, SLA rompido) |
| Emissão de NF-e (VHSYS) | Baixo | Moderado | Alto | Grave | Crítico (bloqueio fiscal, multa) |
| Split/repasses e dados PIX/bancários (AppMax) | Moderado | Alto | Grave | Crítico | Crítico (inadimplência a coprodutores) |
| Pré-postagem/rastreio Correios (PPN/SRO) | Baixo | Moderado | Alto | Grave | Grave (atraso logístico, reclamações) |
| Notificação ao comprador (e-mail/WhatsApp) | Baixo | Baixo | Moderado | Alto | Alto (ruído reputacional) |
| Autenticação/acesso (Supabase Auth) | Alto | Grave | Crítico | Crítico | Irreversível (operação parada) |
| Banco transacional / PII do comprador (Supabase) | Alto | Grave | Crítico | Crítico | Irreversível (perda de dados) |
| Portal público de rastreio | Baixo | Baixo | Moderado | Moderado | Moderado |

5.4. **Recursos mínimos por processo crítico (MBCO):** para cada processo, identificam-se as dependências mínimas — infraestrutura (Supabase/Netlify), integrações (gateway/VHSYS/Correios), pessoas-chave, credenciais/segredos e dados de backup — necessárias para operar em nível mínimo aceitável durante a disrupção.

5.5. **Pontos únicos de falha (SPOF) identificados e tratamento:**

| SPOF | Risco | Tratamento de continuidade |
|---|---|---|
| Instância única Supabase (banco + auth + storage) | Paralisação total | PITR, réplica/leitura, backup off-site imutável, procedimento de restauração testado |
| Netlify como único host SSR | Site fora do ar | Cache/CDN, modo de leitura, plano de failover de hospedagem, página de status |
| Gateway único de ingestão | Perda de pedidos | Reprocessamento por webhook/reconciliação, ingestão retroativa por API, fila de retry |
| VHSYS como único emissor de NF-e | Bloqueio fiscal | Fila de emissão diferida, contingência fiscal, emissão retroativa quando restabelecido |
| Chave/segredo único de integração | Interrupção de integração | Custódia em cofre, rotação, procedimento de reemissão |

5.6. **Resultado da BIA:** os processos de nível 1 e 2 (seção 6) recebem prioridade máxima de recuperação e determinam as metas de RTO/RPO da seção 7.

---

## 6. Processos Críticos e Ordem de Recuperação

6.1. **Cadeia de valor GLOP (fluxo real):** `Ingestão de pedido (API/e-commerce) → Persistência com RLS multi-tenant → Emissão de NF-e (VHSYS) → Pré-postagem Correios (PPN) → Rastreio (SRO) → Notificação ao comprador (e-mail/WhatsApp) → Apuração de comissão/split e repasses (AppMax) → Portal público de rastreio`.

6.2. **Priorização de recuperação (ordem de retomada):**

| Ordem | Processo crítico | Nível BIA | Dependências principais |
|---|---|---|---|
| 1º | Autenticação e acesso (Supabase Auth + RLS/RBAC) | 1 | Supabase, segredos JWT |
| 2º | Banco transacional e PII do comprador | 1 | Supabase (PostgreSQL), PITR |
| 3º | Ingestão de pedidos (gateways/e-commerces) | 1 | API dos gateways, webhooks, banco |
| 4º | Split/repasses e dados PIX/bancários | 1 | AppMax, banco, financeiro |
| 5º | Emissão de NF-e | 2 | VHSYS, banco |
| 6º | Pré-postagem e rastreio Correios | 2 | Correios PPN/SRO, banco |
| 7º | Notificação ao comprador | 2 | Provedor e-mail/WhatsApp |
| 8º | Portal público de rastreio | 3 | Netlify, banco (leitura) |
| 9º | Funções de apoio (BI, relatórios, dashboards) | 3–4 | Banco, RPC/materialized views |

6.3. **Interdependências:** a recuperação obedece à cadeia de dependência — não se restabelece a ingestão de pedidos sem banco e autenticação; não se emite NF-e nem se gera PPN sem os dados persistidos. A ordem acima reflete essas dependências e a curva de dano da BIA.

6.4. **Preservação do isolamento multi-tenant:** qualquer retomada deve reestabelecer **integralmente a RLS por empresa** e o **RBAC (`has_permission`)** antes de reabrir o tráfego, sob pena de vazamento cross-tenant; o portal público permanece restrito a **status neutro**, sem PII.

---

## 7. Metas de Continuidade — RTO e RPO

7.1. **Metas por processo/serviço** (alinhadas à Política de Backup POL-BKP-001):

| Processo / serviço | RPO (perda máx.) | RTO (restabelecimento) | MTPD | Criticidade |
|---|---|---|---|---|
| Autenticação (Supabase Auth) | ≤ 15 min | ≤ 4 h | 4 h | Crítica |
| Banco transacional / PII do comprador | ≤ 15 min (PITR) | ≤ 4 h | 4 h | Crítica |
| Ingestão de pedidos (gateways/e-commerces) | ≤ 15 min | ≤ 4 h | 4 h | Crítica |
| Split/repasses / dados PIX-bancários (AppMax) | ≤ 15 min | ≤ 4 h | 4 h | Crítica |
| Emissão de NF-e (VHSYS) | ≤ 1 h | ≤ 6 h | 8 h | Alta |
| Pré-postagem/rastreio Correios (PPN/SRO) | ≤ 1 h | ≤ 6 h | 8 h | Alta |
| Notificação ao comprador (e-mail/WhatsApp) | ≤ 1 h | ≤ 8 h | 24 h | Média |
| Supabase Storage (documentos, etiquetas, NF-e) | ≤ 1 h | ≤ 8 h | 24 h | Alta |
| Portal público de rastreio | ≤ 1 h | ≤ 8 h | 24 h | Média |
| Trilha de auditoria / logs | ≤ 1 h | ≤ 12 h | 24 h | Média |
| BI / relatórios / dashboards | ≤ 24 h | ≤ 24 h | 72 h | Baixa |

7.2. **MBCO (nível mínimo aceitável durante a crise):** manter (i) autenticação e leitura de pedidos existentes, (ii) recepção e enfileiramento de novos pedidos para processamento diferido, (iii) portal público de rastreio em modo leitura, ainda que as emissões fiscais e a geração de PPN ocorram em modo diferido.

7.3. **Compatibilização com SLA e sub-operadores:** as metas são conciliadas com os compromissos de disponibilidade assumidos com clientes e com os limites técnicos de Supabase/Netlify/VHSYS/Correios/gateways; divergências são registradas como **risco aceito**, formalizadas e comunicadas.

7.4. **Revisão:** RTO/RPO/MTPD são revisados no mínimo anualmente e após mudança arquitetural relevante, troca de sub-operador ou incidente com lição aprendida.

---

## 8. Estratégias de Continuidade

8.1. **Princípios estratégicos:**

- **Redundância e diversificação** de rotas críticas sempre que técnica e economicamente viável;
- **Desacoplamento por filas e reprocessamento**, de modo que a indisponibilidade de um sub-operador não descarte pedidos, apenas os difira;
- **Idempotência e reconciliação**, para reprocessar sem duplicar (pedidos, NF-e, PPN, repasses);
- **Modo degradado** com preservação das funções essenciais;
- **Backups testados** como base do DRP (remissão à POL-BKP-001);
- **Segurança preservada na contingência** — RLS/RBAC, cifragem, write-only de credenciais e menor privilégio não são relaxados em crise.

8.2. **Estratégias técnicas por camada:**

| Camada | Estratégia primária | Estratégia de contingência |
|---|---|---|
| Banco (Supabase/PostgreSQL) | Alta disponibilidade gerenciada + PITR | Restauração PITR/full em ambiente saudável; réplica de leitura; backup off-site imutável |
| Autenticação (Supabase Auth) | HA gerenciada | Restauração conjunta com o banco; sessão em modo leitura |
| Hospedagem (Netlify) | SSR + CDN/cache | Servir cache/estático; failover de host; página de status independente |
| Ingestão (gateways/e-commerces) | Webhooks + polling por API | Fila de retry, reconciliação retroativa, ingestão manual assistida |
| NF-e (VHSYS) | Emissão em tempo real | Fila de emissão diferida; emissão retroativa; contingência fiscal |
| Correios (PPN/SRO) | Pré-postagem e rastreio via API | Enfileirar PPN; rastreio em cache; postagem manual quando necessário |
| Notificação (e-mail/WhatsApp) | Envio automático | Provedor alternativo; reenvio em lote após restabelecimento |
| Split/repasses (AppMax) | Apuração e repasse automáticos | Congelar apuração, repassar após reconciliação validada |
| Storage (documentos/etiquetas) | HA gerenciada | Restauração correlacionada por timestamp com o banco |

8.3. **Estratégias organizacionais:**

- **Pessoas-chave e sucessão:** para cada papel do Comitê de Crise há **substituto designado**; conhecimento crítico é documentado (runbooks) para evitar dependência de indivíduo (SPOF humano);
- **Trabalho remoto:** a operação é executável remotamente, reduzindo dependência de local físico;
- **Contratos e SLA de sub-operadores:** cláusulas de disponibilidade, suporte prioritário em incidente e obrigações de continuidade no DPA;
- **Reserva de contingência:** procedimentos manuais assistidos documentados para os processos de nível 1 e 2.

---

## 9. Cenários de Continuidade e Planos de Resposta

> Para cada cenário: **gatilho de detecção**, **impacto**, **resposta imediata**, **recuperação** e **critério de retorno ao normal**.

### 9.1. Cenário A — Indisponibilidade do Supabase (banco / auth / storage)

- **Gatilho:** falha de conectividade ao banco, erros de autenticação em massa, latência anômala, alerta de saúde do provedor.
- **Impacto:** paralisação de autenticação, leitura/gravação de pedidos, split e emissões dependentes — **evento de nível 1 (crítico)**.
- **Resposta imediata:**
  1. Acionar Comitê de Crise e declarar incidente;
  2. Confirmar escopo (região/serviço) junto ao **Ponto Focal Supabase** e ao status do provedor;
  3. Colocar a aplicação em **modo degradado/leitura** e enfileirar novos pedidos recebidos por webhook para processamento diferido (evitar perda — proteger RPO);
  4. Suspender temporariamente split/repasses e emissão de NF-e para evitar inconsistência.
- **Recuperação:**
  1. Se falha lógica/corrupção: executar **PITR** para instante imediatamente anterior ao evento (RPO ≤ 15 min), validar integridade e **revalidar RLS/RBAC** antes de reabrir;
  2. Se indisponibilidade regional do provedor: restaurar **full + WAL** em ambiente saudável a partir do backup off-site imutável;
  3. Reintegrar segredos, reconectar integrações e rodar **smoke tests** dos fluxos críticos.
- **Retorno ao normal:** RLS/RBAC validados, integridade confirmada (FKs, `version`, auditoria), fila de pedidos processada sem duplicidade, NF-e e split retomados; comunicar encerramento.

### 9.2. Cenário B — Indisponibilidade da Netlify (hospedagem SSR)

- **Gatilho:** erros 5xx generalizados no SSR, deploy falho, alerta de status Netlify, indisponibilidade de build.
- **Impacto:** frontend/portal indisponível, ainda que o banco esteja saudável — **nível 2**.
- **Resposta imediata:**
  1. Servir **conteúdo em cache/CDN** e o **portal público de rastreio em modo leitura**;
  2. Publicar **página de status** independente (fora da Netlify) informando indisponibilidade;
  3. Verificar se a causa é deploy recente e, se for, executar **rollback** para a versão anterior estável.
- **Recuperação:** restabelecer via Netlify (novo deploy/rollback) ou acionar **host de failover** previamente configurado; reconferir variáveis de ambiente e segredos.
- **Retorno ao normal:** SSR estável, health checks verdes, portal e área logada operacionais.

### 9.3. Cenário C — Indisponibilidade dos Correios (PPN / SRO)

- **Gatilho:** erros na API de pré-postagem/rastreio, timeout, indisponibilidade divulgada dos Correios.
- **Impacto:** não geração de etiquetas PPN e não atualização de rastreio; comprador sem informação atualizada — **nível 2**.
- **Resposta imediata:**
  1. **Enfileirar** solicitações de PPN com retry idempotente (não perder pedido);
  2. Servir **rastreio a partir de cache** com aviso de possível atraso na atualização;
  3. Ajustar a **comunicação ao comprador** para status neutro ("em processamento");
  4. Avaliar **postagem manual assistida** para pedidos urgentes/SLA sensível.
- **Recuperação:** ao restabelecer, drenar a fila de PPN, sincronizar eventos SRO e reenviar notificações pendentes em lote.
- **Retorno ao normal:** fila de PPN zerada, rastreio sincronizado, notificações enviadas.

### 9.4. Cenário D — Indisponibilidade de Gateway / Ingestão (Monetizze / Hotmart / Kiwify / e-commerces)

- **Gatilho:** falha de webhook, erro de autenticação de API, ausência anômala de pedidos, alerta do gateway.
- **Impacto:** pedidos não ingeridos em tempo real — risco de **perda de pedido (nível 1)**.
- **Resposta imediata:**
  1. Ativar **reconciliação por polling/API** (buscar pedidos do período pela API do gateway);
  2. Manter **fila de retry** para webhooks falhos com deduplicação por identificador de transação;
  3. Priorizar reprocessamento por ordem de criticidade/valor.
- **Recuperação:** ingestão retroativa completa do intervalo afetado, com verificação de duplicidade e reconciliação financeira.
- **Retorno ao normal:** pedidos do período conciliados 1:1, sem duplicidade, com trilha de auditoria íntegra.

### 9.5. Cenário E — Indisponibilidade do Split / Repasses (AppMax)

- **Gatilho:** falha na API de split, divergência de apuração, indisponibilidade do provedor de repasse.
- **Impacto:** repasses a coprodutores/afiliados atrasados; risco financeiro e reputacional — **nível 1**.
- **Resposta imediata:** **congelar apuração e repasses** para evitar erro; registrar valores devidos; comunicar coprodutores/afiliados sobre o diferimento.
- **Recuperação:** ao restabelecer, reprocessar apuração de forma **idempotente**, conciliar e executar repasses represados com trilha de auditoria e proteção dos dados PIX/bancários.
- **Retorno ao normal:** apuração conferida, repasses concluídos, evidências arquivadas.

### 9.6. Cenário F — Indisponibilidade da Emissão Fiscal (VHSYS)

- **Gatilho:** erro na API de NF-e, rejeição em massa, indisponibilidade da SEFAZ/VHSYS.
- **Impacto:** bloqueio de emissão fiscal; risco tributário — **nível 2, escalável a 1**.
- **Resposta imediata:** **enfileirar** emissões com retry; avaliar contingência fiscal cabível; separar pedidos que dependem de NF-e para expedição.
- **Recuperação:** emissão retroativa da fila ao restabelecer, com conferência de numeração e conformidade.
- **Retorno ao normal:** fila fiscal drenada, documentos armazenados no Storage, conciliação fiscal validada.

### 9.7. Cenário G — Incidente de Segurança / Vazamento / Ransomware

- **Gatilho:** exfiltração suspeita, escalonamento indevido, exclusão em massa, ransomware, falha de RLS.
- **Impacto:** confidencialidade/integridade de PII e segredos — **nível 1**; potencial dever de comunicação à **ANPD** e aos titulares.
- **Resposta imediata:** acionar o **Plano de Resposta a Incidentes** e o **DPO**; conter (isolar credenciais, rotacionar chaves, bloquear acessos); preservar evidências (trilha de auditoria por triggers).
- **Recuperação:** restaurar de **cópia off-site imutável (WORM)** anterior ao comprometimento; revalidar RLS/RBAC; reforçar controles.
- **Retorno ao normal:** ambiente limpo verificado, comunicação legal concluída (art. 48 LGPD, se aplicável), lições aprendidas.

### 9.8. Cenário H — Indisponibilidade de Notificação (E-mail / WhatsApp)

- **Gatilho:** falha do provedor de mensageria, bloqueio de número, erro de entrega em massa.
- **Impacto:** comprador sem notificação de status — **nível 3**.
- **Resposta imediata:** **enfileirar** notificações; ativar **provedor alternativo** de e-mail/WhatsApp; manter o portal público como fonte de consulta.
- **Recuperação:** reenvio em lote das notificações represadas ao restabelecer.
- **Retorno ao normal:** fila de notificações drenada.

### 9.9. Cenário I — Perda de Pessoa-Chave / Indisponibilidade de Equipe

- **Gatilho:** ausência de responsável por incapacidade, desligamento ou indisponibilidade simultânea.
- **Impacto:** atraso na resposta — **nível 2/3**.
- **Resposta imediata:** acionar o **substituto designado** (seção 4.2 e RACI); consultar **runbooks** documentados.
- **Recuperação:** redistribuição de tarefas e reforço temporário.
- **Retorno ao normal:** cobertura de papéis restabelecida.

---

## 10. Acionamento do Plano (Invocação)

10.1. **Critérios de acionamento:** o PCN é acionado quando um incidente (i) atinge processo de **nível 1 ou 2**, (ii) tende a ultrapassar o **MTPD**, ou (iii) exige coordenação multiárea. Incidentes menores seguem o tratamento operacional padrão, com registro.

10.2. **Níveis de severidade e escalonamento:**

| Severidade | Definição | Quem declara | Comitê |
|---|---|---|---|
| **SEV-1 (Crítico)** | Processo nível 1 parado ou dado/segurança comprometidos | Coordenador do Comitê + Patrocinador | Comitê pleno |
| **SEV-2 (Alto)** | Processo nível 2 degradado; risco de escalar | Coordenador do Comitê | Comitê reduzido |
| **SEV-3 (Médio)** | Impacto contornável | Líder Técnico de plantão | Notificação ao Comitê |

10.3. **Fluxo de acionamento:**

1. **Detecção** (monitoramento/alerta/report) e **abertura de ocorrência** com classificação de severidade;
2. **Declaração** do estado de continuidade pelo responsável competente (10.2);
3. **Convocação** do Comitê de Crise (canal primário e secundário — ver 11);
4. **Diagnóstico** do cenário aplicável (seção 9) e definição de RTO/RPO-alvo;
5. **Execução** da resposta imediata e da estratégia de recuperação;
6. **Monitoramento** contínuo e reavaliação de severidade;
7. **Declaração de retorno ao normal** e abertura da fase de pós-crise (seção 13).

10.4. **Autoridade de decisão:** o **Coordenador do Comitê** decide medidas operacionais; medidas com impacto contratual, financeiro relevante ou de comunicação pública dependem do **Patrocinador Executivo**; medidas que envolvam dados pessoais dependem de parecer do **DPO** e do **Jurídico**.

10.5. **Runbooks:** cada cenário da seção 9 possui runbook operacional detalhado, mantido atualizado e acessível ao Comitê mesmo em indisponibilidade da plataforma (cópia offline).

---

## 11. Comunicação de Crise

11.1. **Princípios:** comunicação **tempestiva, precisa, coordenada e por canal único de verdade**, evitando informação conflitante; preservação de dados pessoais e de segredos nas mensagens; registro de todas as comunicações.

11.2. **Públicos e canais:**

| Público | Conteúdo | Canal primário | Canal secundário |
|---|---|---|---|
| Comitê de Crise / equipe interna | Situação, tarefas, decisões | Canal operacional interno | Telefone/WhatsApp de emergência |
| Clientes (produtores/lojistas) | Status, impacto, previsão | E-mail + **página de status** | WhatsApp/painel |
| Compradores (titulares) | Status neutro do pedido | Portal público de rastreio | E-mail/WhatsApp (quando restabelecido) |
| Sub-operadores (Supabase/Netlify/VHSYS/Correios/gateways) | Abertura de chamado prioritário | Suporte contratual | Ponto Focal |
| Coprodutores/afiliados | Diferimento de repasses | E-mail | Painel |
| ANPD e titulares (incidente com dado) | Comunicação legal (art. 48 LGPD) | Canal oficial ANPD | E-mail ao titular |
| Autoridades/terceiros (se aplicável) | Conforme obrigação legal | Jurídico | — |

11.3. **Página de status:** mantida **fora da infraestrutura afetada** (independente de Supabase/Netlify), publica indisponibilidades, escopo, impacto e previsão de normalização, sem expor PII nem detalhes que aumentem risco de segurança.

11.4. **Modelos de comunicação (templates):** o PCN mantém modelos pré-aprovados para (i) aviso inicial, (ii) atualização periódica, (iii) encerramento, (iv) comunicação de incidente a titular/ANPD — todos validados pelo Jurídico e pelo DPO, com placeholders 16 de julho de 2026, [CONTRATANTE], [PARTE].

11.5. **Comunicação de incidente com dados pessoais:** havendo incidente de segurança que possa acarretar risco ou dano relevante aos titulares, o **DPO** conduz a comunicação à **ANPD** e aos titulares em **prazo razoável** (art. 48 da LGPD), com o conteúdo mínimo legal; quando a Plataforma atua como **OPERADOR**, comunica o **CONTROLADOR** (produtor/lojista) sem demora, para que este exerça seus deveres, conforme o **DPA**.

11.6. **Porta-voz único:** a comunicação externa institucional é centralizada no **Líder de Comunicação de Crise**, vedada manifestação individual não autorizada.

---

## 12. Testes, Exercícios e Manutenção do Plano

12.1. **Programa de testes (ISO 22301, cláusula 8.5):** o PCN é exercitado periodicamente; **plano não testado não é confiável**.

| Exercício | Frequência | Objetivo | Métrica aferida |
|---|---|---|---|
| Revisão de mesa (tabletop) dos cenários | Trimestral | Validar papéis, decisões e runbooks | Cobertura de cenários, gaps |
| Teste de acionamento e comunicação | Semestral | Exercitar convocação e árvore de contatos | Tempo de mobilização |
| DR drill — restauração PITR/full (com POL-BKP-001) | Semestral | Validar recuperação técnica end-to-end | RTO/RPO efetivos |
| Simulação Cenário A (queda Supabase) | Semestral | Validar failover/restauração de dados | RTO, integridade, RLS |
| Simulação Cenário B (queda Netlify) | Anual | Validar failover de hospedagem | RTO do frontend |
| Simulação Cenário D/E/F (gateway/split/NF-e) | Anual | Validar filas, idempotência e reconciliação | Ausência de perda/duplicidade |
| Simulação Cenário G (segurança/vazamento) | Anual | Integrar PCN e Resposta a Incidentes | Tempo de contenção/comunicação |

12.2. **Evidência:** cada exercício gera **relatório** com data/hora, cenário, participantes, RTO/RPO medidos, não conformidades e plano de ação com prazo e responsável.

12.3. **Não conformidade** identificada é tratada como risco, acompanhada até a remediação e submetida a **reteste**.

12.4. **Manutenção:** o PCN é atualizado após cada exercício, incidente real, mudança arquitetural, troca de sub-operador ou alteração legislativa; a **árvore de contatos** e os **runbooks** são revisados a cada trimestre.

12.5. **Melhoria contínua (PDCA / ISO 31000):** os resultados alimentam a análise crítica pela Direção e a revisão de RTO/RPO e estratégias.

---

## 13. Pós-Crise, Retorno ao Normal e Lições Aprendidas

13.1. **Declaração de normalização:** o Coordenador do Comitê declara o retorno após verificação de que os processos críticos operam dentro dos parâmetros, integridade e RLS/RBAC validados, filas drenadas e comunicações encerradas.

13.2. **Análise pós-incidente (post-mortem):** em até **16 de julho de 2026/prazo definido** após o encerramento, elabora-se relatório com linha do tempo, causa-raiz, impacto (financeiro, operacional, a titulares), eficácia da resposta, RTO/RPO efetivos vs. metas e **lições aprendidas**.

13.3. **Plano de ação:** as recomendações viram ações rastreadas até a conclusão, com reavaliação de riscos e, se necessário, revisão do PCN e da BIA.

13.4. **Preservação de evidências:** trilhas de auditoria, logs, decisões do Comitê e comunicações são retidas como evidência (auditoria/ISO/ANPD/eventual litígio), respeitados os prazos de retenção e o *legal hold* quando houver.

---

## 14. Papéis e Responsabilidades

14.1. **Patrocinador Executivo (Diretoria):** aprova o PCN, provê recursos e declara desastres de alto impacto.

14.2. **Gestor de Continuidade (BCM):** proprietário do Plano; conduz BIA, estratégias, programa de testes e melhoria contínua.

14.3. **Coordenador do Comitê de Crise:** lidera o acionamento e a coordenação durante o evento; decide medidas operacionais.

14.4. **Líder Técnico / DevOps:** executa failover, restauração (PITR/full), reconexão de integrações e smoke tests; custodia segredos sob menor privilégio.

14.5. **Encarregado (DPO) — a ser designado pela administração, lemoncapsencapsulados@gmail.com:** avalia impacto a titulares, aciona a Resposta a Incidentes e conduz comunicação à ANPD/titulares e ao Controlador (papel de Operador).

14.6. **Líder de Comunicação de Crise:** porta-voz único; conduz comunicação interna e externa e a página de status.

14.7. **Líder Jurídico / Compliance:** avalia obrigações legais/contratuais/regulatórias e riscos de responsabilização.

14.8. **Pontos Focais de Sub-operadores:** interlocução prioritária com Supabase, Netlify, VHSYS, Correios e gateways.

14.9. **Colaboradores e prestadores:** cumprem o Plano, reportam eventos pelos canais oficiais e seguem instruções do Comitê.

14.10. Ver **Matriz RACI** na seção de Engenharia Jurídica & Governança.

---

## 15. Vigência e Revisão

15.1. Este Plano entra em vigor na data de aprovação e vigora por prazo indeterminado, até revisão ou revogação formal.

15.2. É **revisado, no mínimo, anualmente**, e sempre que houver: alteração legislativa/regulatória; mudança arquitetural relevante; troca de sub-operador; incidente disruptivo; ou não conformidade recorrente em exercícios.

15.3. Alterações são registradas no **Controle de Versão** e comunicadas às partes afetadas.

---

## Engenharia Jurídica & Governança

### (a) Fundamentação das cláusulas

| Cláusula / Tema | Fundamento legal / normativo |
|---|---|
| Continuidade de negócios (SGCN, BIA, estratégias, testes) | **ISO 22301** (cláusulas 4 a 10: contexto, liderança, planejamento, apoio, operação — BIA e estratégias, avaliação de desempenho, melhoria) |
| Gestão de riscos que embasa a BIA e o apetite a risco | **ISO 31000** (princípios, estrutura e processo de gestão de riscos) |
| Segurança da informação e controles de continuidade de TI | **ISO/IEC 27001** (Anexo A: A.5.29 continuidade da SI, A.5.30 prontidão de TIC, A.8.13 backup) |
| Proteção de dados na continuidade e comunicação de incidentes | Art. 6º, VII e VIII (segurança e prevenção), art. 46 (medidas técnicas/administrativas) e art. 48 (comunicação de incidente à ANPD e ao titular) da **LGPD** |
| Responsabilidade Controlador/Operador em contingência | Arts. 5º (VI, VII), 39 e 42 da **LGPD**; remissão ao **DPA** |
| Continuidade da privacidade (papel de Operador) | **ISO/IEC 27701** (SGPI — extensão de privacidade da 27001/27002) |
| Guarda de registros/logs de continuidade e incidentes | Arts. 13, 15 e 16 do **Marco Civil da Internet (Lei nº 12.965/2014)** |
| Continuidade da emissão fiscal e guarda de documentos | Legislação tributária aplicável (NF-e; guarda quinquenal) |
| Recuperação técnica, RTO/RPO e testes de restauração | Remissão à **Política de Backup POL-BKP-001**; **NIST SP 800-34** (planejamento de contingência) |
| Cifragem e proteção de segredos na contingência | **NIST SP 800-57** (gestão de chaves); **OWASP** (proteção de dados sensíveis) |
| Obrigações de disponibilidade e continuidade de terceiros | Cláusulas contratuais de SLA e continuidade nos contratos e DPAs com sub-operadores |

### (b) Riscos mitigados

- **Interrupção prolongada de processo crítico** além do MTPD (mitigado por BIA, RTO/RPO, estratégias e testes);
- **Perda de pedidos** por queda de gateway/ingestão (mitigado por filas de retry, reconciliação por API e idempotência);
- **Perda de dados** por queda/corrupção do Supabase (mitigado por PITR, backup off-site imutável e restauração testada);
- **Indisponibilidade do frontend** por queda da Netlify (mitigado por cache/CDN, rollback e host de failover);
- **Bloqueio fiscal** por indisponibilidade do VHSYS (mitigado por fila de emissão diferida e emissão retroativa);
- **Atraso logístico** por queda dos Correios (mitigado por enfileiramento de PPN, rastreio em cache e postagem manual assistida);
- **Inadimplência a coprodutores** por falha de split (mitigado por congelamento e reprocessamento idempotente do AppMax);
- **Vazamento cross-tenant** na recuperação (mitigado por revalidação obrigatória de RLS/RBAC antes da reabertura);
- **Vazamento/ransomware** (mitigado por cópias WORM, resposta a incidentes integrada e comunicação legal — art. 48 LGPD);
- **Dependência de pessoa-chave (SPOF humano)** (mitigado por substitutos designados e runbooks);
- **Comunicação inconsistente na crise** (mitigado por porta-voz único, página de status e templates aprovados);
- **Não conformidade regulatória/contratual** por resposta inadequada (mitigado por governança, RACI e revisão jurídica).

### (c) Checklist

- [ ] BIA concluída, com processos críticos, MTPD, RTO e RPO aprovados.
- [ ] SPOFs identificados e com tratamento de continuidade definido.
- [ ] RTO/RPO conciliados com SLA de clientes e limites dos sub-operadores.
- [ ] Estratégias de contingência definidas por camada (banco, auth, host, ingestão, NF-e, Correios, split, notificação).
- [ ] Runbooks dos cenários A–I redigidos, testados e disponíveis offline.
- [ ] Filas de retry/reconciliação idempotentes ativas para ingestão, PPN, NF-e, split e notificação.
- [ ] Backup off-site imutável e PITR validados (remissão à POL-BKP-001).
- [ ] Revalidação de RLS/RBAC incluída obrigatoriamente em todo procedimento de retomada.
- [ ] Comitê de Crise constituído com titulares e substitutos designados.
- [ ] Árvore de contatos e canais primário/secundário atualizados (≤ trimestre).
- [ ] Página de status hospedada fora de Supabase/Netlify.
- [ ] Templates de comunicação (interna, cliente, titular, ANPD, sub-operador) aprovados pelo Jurídico/DPO.
- [ ] Fluxo de comunicação de incidente com dado pessoal alinhado ao art. 48 LGPD e ao DPA.
- [ ] Programa de exercícios executado no ciclo (tabletop, acionamento, DR drill, cenários).
- [ ] Relatórios de exercício com RTO/RPO efetivos e plano de ação para não conformidades.
- [ ] Post-mortem padronizado e trilha de auditoria preservada.
- [ ] PCN revisado no último ciclo (≤ 12 meses) e Controle de Versão atualizado.

### (d) Matriz RACI

Legenda: **R** = Responsável executa · **A** = Aprova/Presta contas · **C** = Consultado · **I** = Informado.

| Atividade | Líder Técnico/DevOps | Gestor de Continuidade (BCM) | Coordenador do Comitê | DPO / Encarregado | Comunicação de Crise | Jurídico/Compliance | Patrocinador (Diretoria) | Sub-operadores |
|---|---|---|---|---|---|---|---|---|
| Elaborar/manter a BIA | C | R | C | C | I | C | A | I |
| Definir RTO/RPO/MTPD | C | R | C | C | I | C | A | C |
| Definir estratégias de continuidade | R | R | C | C | I | C | A | C |
| Declarar acionamento (SEV-1) | I | C | R | C | I | C | A | I |
| Executar failover/restauração | R | A | C | C | I | I | I | C |
| Revalidar RLS/RBAC na retomada | R | A | C | C | I | I | I | I |
| Coordenar filas/reconciliação (ingestão/NF-e/split) | R | A | C | I | I | I | I | C |
| Conduzir comunicação interna/externa | I | C | A | C | R | C | I | I |
| Comunicar incidente a ANPD/titulares/Controlador | I | C | C | R | C | A | I | I |
| Avaliar obrigações legais/contratuais na crise | I | C | C | C | I | R | A | I |
| Executar programa de testes/DR drill | R | A | C | C | I | I | I | C |
| Conduzir post-mortem e lições aprendidas | C | R | A | C | C | C | I | I |
| Revisar o PCN | C | R | C | C | I | C | A | I |

### (e) Plano de revisão

- **Revisão ordinária:** anual, conduzida pelo Gestor de Continuidade (BCM) com o DPO e o Jurídico, aprovada pela Diretoria.
- **Revisão extraordinária:** disparada por incidente disruptivo real, mudança arquitetural, troca de sub-operador, alteração legislativa/regulatória ou não conformidade recorrente em exercícios.
- **Revisão de artefatos operacionais:** árvore de contatos e runbooks revisados trimestralmente; templates de comunicação a cada alteração relevante.
- **Fontes de melhoria:** relatórios de tabletop e DR drill, post-mortems, auditorias ISO 22301/27001/27701, recomendações da ANPD, indicadores de RTO/RPO efetivos.
- **Registro:** toda revisão é lançada no Controle de Versão, com aprovação nominal e data.

### (f) Controle de versão

| Versão | Data | Autor / Responsável | Descrição da alteração | Aprovação |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | a ser designado pela administração | Emissão inicial do Plano de Continuidade de Negócios (PCN/BCP) alinhado à ISO 22301 | [PARTE] |
| | | | | |

---

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.
