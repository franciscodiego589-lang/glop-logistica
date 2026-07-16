> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# POLÍTICA DE CONTROLE DE ACESSO — GLOP (GLOBAL LOGISTICS PLATFORM)

**Documento:** POL-SEG-004 — Política de Controle de Acesso Lógico e Físico
**Classificação da informação:** INTERNA / CONFIDENCIAL
**Controlador / Operador:** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, inscrita no CNPJ sob nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, operadora da plataforma [NOME FANTASIA: GLOP] (Global Logistics Platform).
**Encarregado pelo Tratamento de Dados Pessoais (DPO):** a ser designado pela administração — lemoncapsencapsulados@gmail.com.
**Aprovação:** [NOME — CISO/Diretoria] — 16 de julho de 2026.
**Vigência a partir de:** 16 de julho de 2026.

---

## 1. Objetivo

1.1. Esta Política de Controle de Acesso ("Política") estabelece as regras, os princípios, os papéis e os controles técnicos e administrativos que governam a **concessão, o uso, a revisão e a revogação** de acessos lógicos e físicos aos ativos de informação da plataforma **GLOP (Global Logistics Platform)**, SaaS de logística e ERP voltado a operações de dropshipping e infoprodutos no Brasil.

1.2. O GLOP trata volumes relevantes de **dados pessoais de compradores** (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor da compra) ingeridos por API de gateways (Monetizze, Hotmart, Kiwify, AppMax) e de e-commerces (Shopify, WooCommerce, Nuvemshop, Mercado Livre), além de **dados fiscais** (NF-e via VHSYS), **dados de transporte** (pré-postagem PPN e rastreio SRO dos Correios), **dados financeiros** de coprodução/split (PIX e dados bancários de coprodutores e afiliados) e **dados dos próprios usuários e colaboradores** da plataforma. O controle de acesso é o mecanismo primário de proteção da confidencialidade, integridade e disponibilidade desses ativos.

1.3. Esta Política operacionaliza os princípios de **privacy by design e by default** (art. 46, §2º, da LGPD), de **segurança da informação** (art. 46 da LGPD) e os requisitos de gestão de identidade e acesso das normas **ISO/IEC 27001:2022** (Anexo A, controles 5.15 a 5.18, 8.2, 8.3, 8.5), **ISO/IEC 27701:2019** (extensão de privacidade), **NIST SP 800-53 (família AC — Access Control)** e **NIST Cybersecurity Framework (função PROTECT — PR.AC/PR.AA)**.

## 2. Escopo

2.1. Esta Política aplica-se a **todos** os acessos a ativos do GLOP, sem exceção, incluindo:

- **a) Sistemas e aplicações:** frontend Next.js (App Router), APIs internas, painéis administrativos, funções serverless (Supabase Edge Functions) e jobs de integração.
- **b) Banco de dados e armazenamento:** PostgreSQL gerenciado no **Supabase**, buckets do **Supabase Storage**, réplicas e backups.
- **c) Infraestrutura e sub-operadores:** consoles administrativos de **Supabase** e **Netlify** (hospedagem SSR), painéis de sub-operadores e integrações (VHSYS/NF-e, Correios PPN/SRO, gateways Monetizze/AppMax/Hotmart/Kiwify, provedores de WhatsApp e e-mail).
- **d) Credenciais e segredos:** chaves de API, tokens de service role, chaves JWT, segredos de webhook, credenciais de integração (armazenadas em regime **write-only** — inseríveis, nunca legíveis pela interface).
- **e) Ferramentas de suporte:** repositórios de código, pipelines de CI/CD, ferramentas de observabilidade, logs e trilhas de auditoria.
- **f) Acesso físico:** instalações administrativas da LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, estações de trabalho e dispositivos que acessem dados do GLOP (os data centers são operados pelos sub-operadores Supabase e Netlify, cobertos pelas respectivas certificações e contratos).

2.2. **Sujeitos abrangidos:** colaboradores (CLT ou não), sócios, administradores, estagiários, prestadores de serviço, consultores, sub-operadores e quaisquer terceiros que, a qualquer título, acessem ativos do GLOP.

2.3. **Natureza dupla do tratamento.** O GLOP atua simultaneamente como:

- **OPERADOR** — quando trata dados pessoais de compradores em nome do produtor/lojista (o **CONTROLADOR**), na execução dos fluxos de ingestão de pedidos, emissão de NF-e, pré-postagem, rastreio e notificação. Nesses casos, os acessos observam também as instruções do controlador e o respectivo Contrato de Operador (DPA);
- **CONTROLADOR** — quando trata dados dos próprios usuários da plataforma, colaboradores e da relação contratual. Nesses casos, a LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA responde diretamente pelas decisões de tratamento.

Esta Política aplica-se a ambas as naturezas, resguardadas as instruções documentadas do controlador quando o GLOP atuar como operador.

## 3. Definições

- **Ativo de informação:** qualquer dado, sistema, serviço ou recurso que tenha valor para a operação do GLOP.
- **Least privilege (menor privilégio):** cada identidade recebe **apenas** os privilégios estritamente necessários para executar suas funções, pelo tempo estritamente necessário.
- **Need to know (necessidade de conhecer):** o acesso a dado específico é concedido somente a quem precisa dele para uma finalidade legítima e definida.
- **RBAC (Role-Based Access Control):** controle de acesso baseado em papéis; permissões são atribuídas a papéis, e papéis a usuários.
- **RLS (Row-Level Security):** segurança em nível de linha do PostgreSQL; políticas de banco que filtram, por tenant/empresa, quais registros cada identidade pode ler ou gravar.
- **Multi-tenant:** arquitetura em que múltiplos clientes (tenants) compartilham a mesma instância, com isolamento lógico rígido. No GLOP: **Tenant → Company → Branch → Membership (usuário + papel)**.
- **PAM (Privileged Access Management):** gestão de acessos privilegiados (superadmin, service role, DBA, chaves de infraestrutura).
- **SoD (Segregation of Duties / Segregação de Funções):** separação de responsabilidades incompatíveis para reduzir fraude e erro.
- **JIT (Just-in-Time):** concessão de privilégio elevado apenas no momento e pela janela de tempo em que é necessário.
- **Provisionamento / Desprovisionamento:** criação/atribuição e remoção/revogação de acessos ao longo do ciclo de vida do vínculo.
- **Superadmin:** identidade com privilégio máximo que transpõe filtros de tenant (função `app.is_superadmin()`).
- **Service role:** credencial técnica de máquina, com privilégio elevado, usada por integrações e jobs — nunca associada a pessoa física para uso interativo.

## 4. Princípios Fundamentais

### 4.1. Menor privilégio (Least Privilege)

4.1.1. Todo acesso parte do estado **negado por padrão** (deny by default). Privilégios são adicionados de forma explícita, granular e justificada; nunca herdados por conveniência.

4.1.2. Nenhuma identidade humana opera rotineiramente com privilégios de superadmin ou service role. O acesso máximo é o **mínimo suficiente** para a função.

4.1.3. Papéis são desenhados por **função de negócio** (ex.: operador de expedição, analista fiscal, suporte, financeiro/split, administrador de empresa), não por pessoa.

### 4.2. Necessidade de conhecer (Need to Know)

4.2.1. O acesso a dados pessoais de compradores, dados fiscais, dados bancários/PIX e trilhas de auditoria é restrito a quem tem finalidade legítima, documentada e vinculada à sua função.

4.2.2. A exposição de PII é sempre a **mínima necessária**. Exemplo aplicado ao GLOP: o **portal público de rastreio** opera **sem login** e expõe **apenas status neutro** de entrega, jamais nome, CPF, endereço, valor ou produto do comprador — materialização do need-to-know na camada pública.

4.2.3. Campos sensíveis (CPF/CNPJ, dados bancários) devem ser mascarados na interface por padrão, com exibição integral condicionada a permissão específica e registrada em log.

### 4.3. Isolamento multi-tenant por padrão

4.3.1. O isolamento entre clientes **nunca** é confiado ao frontend. É imposto no banco, via **RLS**, e reforçado por **RBAC** na camada de aplicação. O frontend é tratado como não confiável.

4.3.2. Toda tabela de negócio carrega `tenant_id`, `company_id` (e `branch_id` quando aplicável) e tem RLS habilitada. As políticas usam funções auxiliares de segurança (`app.is_superadmin()`, `app.user_company_ids()`, `app.can_access_company()`, `app.has_permission('recurso.ação', company_id)`).

### 4.4. Defesa em profundidade

4.4.1. Controles independentes e sobrepostos: autenticação forte (Supabase Auth/JWT) → autorização por papel (RBAC/`has_permission`) → filtragem por linha (RLS) → soft-delete → trilha de auditoria imutável por triggers → segregação de credenciais (write-only).

### 4.5. Responsabilização (Accountability) e rastreabilidade

4.5.1. Toda ação relevante é atribuível a uma identidade única. É **proibido** o compartilhamento de contas, senhas ou tokens. Toda tabela de negócio mantém colunas de auditoria (`created_by`, `updated_by`, `deleted_by`, `created_at`, `updated_at`, `deleted_at`, `reason_deleted`, `version`) e trilha por triggers.

## 5. Modelo de Controle de Acesso do GLOP (RBAC + RLS Multi-Tenant)

### 5.1. Hierarquia de tenancy

5.1.1. A estrutura de acesso segue a hierarquia:

- **Tenant** — a organização cliente (topo do isolamento).
- **Company** — empresa/CNPJ dentro do tenant.
- **Branch** — filial/unidade operacional.
- **Membership** — vínculo que associa um **usuário** (identidade em `auth.users`) a um **papel (role)** dentro de uma company/branch.

5.1.2. Um usuário só enxerga e opera dados das companies às quais possui Membership ativo, conforme retornado por `app.user_company_ids()` e validado por `app.can_access_company(company_id)`.

### 5.2. Autenticação

5.2.1. A autenticação é feita via **Supabase Auth** com emissão de **JWT**. As credenciais residem em `auth.users`. É **obrigatório**:

- **a)** senha forte conforme política de senhas (ver item 6);
- **b)** **MFA (autenticação multifator)** para todos os acessos administrativos, privilegiados e a consoles de sub-operadores (Supabase, Netlify), sempre que suportado;
- **c)** expiração e rotação de tokens/sessões; revogação imediata de sessões ao desprovisionar.

### 5.3. Autorização (RBAC)

5.3.1. A autorização é decidida por **papel** e verificada pela função `app.has_permission('<recurso>.<ação>', company_id)`. Os recursos já semeados incluem: `master_data, inventory, wms, tms, yms, purchasing, demand, mrp, production, shipping, distribution, controltower, logia, bi, admin`.

5.3.2. As ações canônicas são, no mínimo: `create`, `read`, `update`, `delete` (o `delete` físico é vedado; ver item 9). Papéis agregam conjuntos de permissões `recurso.ação`.

5.3.3. **Catálogo mínimo de papéis** (exemplificativo; ajustar à operação real):

| Papel | Escopo típico | Permissões-chave | Acesso a PII do comprador |
|---|---|---|---|
| Superadmin (plataforma) | Global (transpõe tenant) | Todas — uso PAM/quebra de vidro | Sim — restrito, logado, excepcional |
| Admin da Empresa | Company | `admin.*`, gestão de membros e papéis da própria company | Sim, dentro da própria company |
| Operador de Expedição | Branch | `shipping.*`, `tms.read/update`, `distribution.read` | Endereço/nome para PPN e rastreio |
| Analista Fiscal | Company | `purchasing.read`, emissão NF-e (VHSYS) | Nome, CPF/CNPJ, endereço (fins fiscais) |
| Financeiro / Split | Company | apuração, comissões, repasses (AppMax), PIX/bancário | Dados bancários de coprodutores/afiliados |
| Suporte / Atendimento | Company | `read` limitado, sem exportação em massa | PII mascarada por padrão |
| Analista de BI | Company | `bi.read` via RPC/MV (sem SELECT bruto cross-tenant) | Agregados; sem PII individual |
| Auditor / Compliance | Company | leitura de trilha de auditoria e logs | Somente metadados; PII sob need-to-know |
| Service role (máquina) | Integrações/jobs | escopo técnico mínimo por integração | Conforme fluxo (ingestão, PPN, NF-e) |

### 5.4. Autorização em nível de linha (RLS)

5.4.1. **Toda** tabela de `public` tem RLS habilitada. O padrão de política por tabela é:

- **SELECT:** permitido a `authenticated` se `app.is_superadmin()` **ou** `company_id in (select app.user_company_ids())`.
- **INSERT:** exige `app.can_access_company(company_id)` **e** `app.has_permission('<recurso>.create', company_id)`.
- **UPDATE:** exige `app.can_access_company(company_id)` **e** `app.has_permission('<recurso>.update', company_id)`, com `WITH CHECK` reafirmando o vínculo.
- **DELETE (físico):** restrito a `app.is_superadmin()` — e, ainda assim, a regra de negócio impõe **soft-delete** (item 9).

5.4.2. Relatórios pesados e KPIs são servidos por **RPC** e **materialized views** com `anon`/`authenticated` **revogados** na MV, evitando vazamento cross-tenant.

5.4.3. **Vedação:** nenhuma consulta de aplicação usa `SELECT *`; toda leitura é paginada; não há resolução de N+1 que contorne RLS.

### 5.5. Segregação de credenciais e segredos

5.5.1. Credenciais de API de terceiros (gateways, VHSYS, Correios, WhatsApp/e-mail) são armazenadas em regime **write-only**: podem ser inseridas/atualizadas, **nunca lidas** de volta pela interface. A `service_role key` do Supabase e demais segredos de infraestrutura residem exclusivamente no lado servidor (Edge Functions / variáveis de ambiente do Netlify), **nunca** expostos ao cliente.

## 6. Gestão de Identidade, Autenticação e Senhas

6.1. **Identidade única e nominal.** Cada pessoa tem uma identidade individual em `auth.users`. Contas genéricas, compartilhadas ou "de setor" são proibidas para uso interativo.

6.2. **Política de senhas.** Comprimento mínimo de 12 caracteres; complexidade ou passphrase; vedação de reuso das últimas N senhas; bloqueio após tentativas malsucedidas; armazenamento apenas como hash (responsabilidade do Supabase Auth). Senhas nunca trafegam ou são registradas em texto claro em logs.

6.3. **MFA obrigatório** para: superadmins, admins de empresa, DBAs, acesso a consoles de sub-operadores, acesso a segredos e a pipelines de CI/CD.

6.4. **Gestão de sessões.** Tempo máximo de sessão e de inatividade definidos; revogação imediata de sessões e rotação de tokens no desprovisionamento ou em incidente.

6.5. **Contas de serviço.** Toda service role tem dono responsável nomeado, escopo técnico mínimo, e é inventariada. Chaves rotacionadas periodicamente e imediatamente após incidente ou desligamento de responsável.

## 7. Provisionamento e Desprovisionamento (Ciclo de Vida do Acesso)

### 7.1. Provisionamento (concessão)

7.1.1. Todo acesso nasce de uma **solicitação formal e rastreável**, aprovada pelo **gestor da área** e pelo **responsável técnico/segurança**, com base em papel padrão (menor privilégio). Concessões fora do papel-padrão exigem justificativa e aprovação adicional.

7.1.2. O acesso é materializado pela criação do usuário em `auth.users` e do **Membership** (usuário + papel + company/branch). Nenhum acesso é concedido diretamente por manipulação de linhas fora do fluxo aprovado.

7.1.3. Vigora o princípio de **provisionamento por papel**: adiciona-se a pessoa ao papel; não se criam permissões individuais ad hoc, salvo exceção documentada e temporária.

### 7.2. Alteração (movimentação interna)

7.2.1. Mudança de função, área ou empresa dispara **revisão imediata** dos acessos: remoção dos privilégios da função anterior antes da adição dos novos (evita **acúmulo de privilégios** / *privilege creep*).

### 7.3. Desprovisionamento (revogação)

7.3.1. O desligamento, término de contrato de prestador, ou fim de necessidade dispara **revogação imediata** (meta: no mesmo dia útil, idealmente em tempo real): desativação da identidade, revogação de sessões e tokens, remoção de Memberships e rotação de quaisquer segredos aos quais a pessoa teve acesso.

7.3.2. Aplica-se **soft-delete** aos registros de vínculo (não exclusão física), preservando a trilha de auditoria (`deleted_at`, `deleted_by`, `reason_deleted`).

7.3.3. **Gatilhos automáticos:** sempre que possível, o desprovisionamento é acionado por evento de RH/contratos (offboarding), não por lembrança manual.

## 8. Revisão Periódica de Acessos (Recertificação)

8.1. Os acessos são recertificados em ciclos:

| Tipo de acesso | Periodicidade mínima de revisão |
|---|---|
| Acessos privilegiados (superadmin, service role, DBA) | Trimestral |
| Acessos a PII de compradores, dados fiscais e bancários/PIX | Trimestral |
| Acessos padrão de colaboradores | Semestral |
| Acessos de sub-operadores/terceiros e consoles (Supabase/Netlify) | Trimestral |
| Contas de serviço e chaves de API | Semestral + após incidente |

8.2. Cada revisão é conduzida pelos **gestores das áreas** (donos dos papéis), com apoio de Segurança, e produz evidência: lista revisada, decisões (manter/revogar/ajustar), responsável e data. Acessos não confirmados na revisão são **revogados**.

8.3. A revisão verifica especialmente: contas órfãs/inativas, acúmulo de privilégios, exceções temporárias vencidas, service roles sem dono e conformidade com SoD.

## 9. Soft-Delete, Integridade e Auditoria

9.1. **É proibida a exclusão física (DELETE)** de dados de negócio. A remoção é lógica: `UPDATE ... SET deleted_at = now(), deleted_by = <id>, reason_deleted = '<motivo>'`. Toda leitura filtra `deleted_at is null`.

9.2. Toda tabela de negócio possui **colunas de auditoria** e dois gatilhos: `tg_touch_row()` (mantém `updated_at`/`version`) e `tg_write_audit()` (grava a trilha em `insert/update/delete`). A trilha é tratada como registro **imutável** e é insumo probatório de accountability (LGPD, art. 37 — registro das operações).

9.3. O acesso à **trilha de auditoria** é ele próprio restrito (papéis Auditor/Compliance/Superadmin) e monitorado.

## 10. Segregação de Funções (SoD)

10.1. Funções incompatíveis são separadas entre identidades distintas para prevenir fraude, erro e abuso. Combinações vedadas na mesma pessoa (sem controle compensatório aprovado):

- **a)** conceder acesso a si mesmo (quem solicita ≠ quem aprova ≠ quem provisiona);
- **b)** administrar chaves de gateway/split **e** aprovar/executar repasses financeiros (AppMax/PIX) sem dupla verificação;
- **c)** desenvolver/publicar código **e** deter acesso irrestrito ao banco de produção sem revisão;
- **d)** operar dados fiscais (emissão de NF-e/VHSYS) **e** manipular a trilha de auditoria correspondente;
- **e)** gerir a própria conta privilegiada **e** ser o único revisor dos seus acessos.

10.2. Onde a separação total for inviável (equipe reduzida), adotam-se **controles compensatórios** documentados: dupla aprovação, revisão por segunda pessoa, alertas automáticos e revisão reforçada de logs.

## 11. Acesso Privilegiado (PAM)

11.1. **Inventário.** Todos os acessos privilegiados — superadmins, `service_role` do Supabase, admins de console Netlify/Supabase, DBAs, detentores de segredos e de chaves de CI/CD — são inventariados, nominais e com dono responsável.

11.2. **Menor privilégio e JIT.** Privilégio elevado é concedido **just-in-time**, pela menor janela possível, e revogado automaticamente ao fim. Nenhum superadmin opera em modo permanente para tarefas rotineiras.

11.3. **Quebra de vidro (break-glass).** Acesso emergencial de superadmin exige: justificativa registrada, aprovação (ou notificação imediata a duas pessoas), janela limitada, **MFA**, e **revisão obrigatória a posteriori** de tudo que foi executado.

11.4. **Segredos.** Chaves e tokens residem apenas no lado servidor (Edge Functions / variáveis de ambiente), em cofre/secret manager, **nunca** em código, repositório, frontend ou logs. Rotação periódica e imediata após incidente/desligamento. Credenciais de terceiros permanecem **write-only** na plataforma.

11.5. **Sessões privilegiadas monitoradas.** Toda ação privilegiada é logada com identidade, horário, origem e escopo, e sujeita a alerta e revisão.

## 12. Logs de Acesso e Monitoramento

12.1. **Eventos registrados (mínimo):** login/logout e falhas de autenticação; uso e elevação de privilégio (PAM/break-glass); acesso e exportação de PII de comprador; leitura/gravação de dados fiscais e bancários/PIX; alteração de papéis/Memberships; provisionamento e desprovisionamento; alteração de segredos/credenciais; operações de soft-delete; e acessos a consoles de sub-operadores.

12.2. **Conteúdo do log:** identidade, timestamp (com fuso), ação, recurso/`recurso.ação`, `company_id`/`tenant_id` de contexto, origem (IP/agente) e resultado. **Nunca** registrar em log: senhas, tokens, chaves, CPF/dados bancários em texto claro (minimização — LGPD, art. 6º, III).

12.3. **Integridade e retenção.** Logs de segurança e a trilha de auditoria são protegidos contra alteração e retidos por prazo definido pela política de retenção e por obrigações legais/fiscais, respeitada a minimização.

12.4. **Monitoramento e resposta.** Padrões anômalos (acessos fora de horário, exportações em massa de PII, tentativas cross-tenant, uso indevido de service role) geram **alertas**. Incidentes de acesso seguem o Plano de Resposta a Incidentes e, quando aplicável, a comunicação à ANPD e aos titulares (LGPD, art. 48).

## 13. Acesso de Terceiros e Sub-Operadores

13.1. O acesso de sub-operadores (Supabase, Netlify, VHSYS, Correios, gateways, WhatsApp/e-mail) e demais terceiros observa: contrato com cláusulas de proteção de dados/DPA, menor privilégio, escopo técnico mínimo, prazo determinado, MFA quando aplicável, e revisão trimestral. O encadeamento operador → sub-operador respeita as instruções do controlador (LGPD, arts. 39 e 46).

13.2. Terceiros não recebem privilégios permanentes; acessos de suporte pontual são JIT, logados e revogados ao término.

## 14. Acesso Físico

14.1. Instalações administrativas da LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA têm acesso controlado e registrado; estações de trabalho que acessem dados do GLOP exigem bloqueio automático de tela, disco criptografado e antimalware. Data centers são responsabilidade dos sub-operadores (Supabase/Netlify), cobertos por suas certificações e contratos.

## 15. Papéis e Responsabilidades

- **a) Diretoria / Controlador:** aprova a Política, provê recursos, responde legalmente pelo tratamento.
- **b) CISO / Segurança da Informação:** mantém a Política, o modelo RBAC/RLS, o PAM, o monitoramento e conduz as revisões.
- **c) Encarregado (DPO) — a ser designado pela administração, lemoncapsencapsulados@gmail.com:** assegura aderência à LGPD, atua junto a titulares e ANPD, valida bases legais e minimização nos acessos a PII.
- **d) Gestores de área (donos de papéis):** aprovam solicitações, executam recertificações, garantem SoD e need-to-know.
- **e) Administradores de Empresa (tenant):** gerenciam Memberships e papéis dentro da própria company, sob esta Política.
- **f) TI / Engenharia:** implementa e mantém os controles técnicos (Supabase Auth, RLS, `has_permission`, triggers, segredos), sem contornar RLS.
- **g) Colaboradores e terceiros:** usam apenas os acessos concedidos, protegem credenciais, não compartilham contas e reportam incidentes.

## 16. Sanções

16.1. O descumprimento desta Política sujeita o infrator a medidas disciplinares proporcionais à gravidade — advertência, suspensão, revogação de acessos, rescisão do vínculo (com justa causa quando cabível) e término de contrato de prestação de serviços — sem prejuízo das responsabilidades **civil, administrativa e penal** aplicáveis (LGPD, arts. 42 a 45 e 52; CLT, art. 482; Código Civil; Lei nº 12.737/2012).

16.2. O compartilhamento de credenciais, a exportação não autorizada de PII e o uso indevido de acesso privilegiado são consideradas faltas graves.

## 17. Vigência e Revisão

17.1. Esta Política entra em vigor em 16 de julho de 2026 e vigora por prazo indeterminado, devendo ser revisada, no mínimo, **anualmente** ou sempre que houver mudança regulatória, incidente relevante, alteração arquitetural (novos sub-operadores, novos fluxos de dados) ou recomendação de auditoria. Versões anteriores são arquivadas para fins de rastreabilidade.

---

## Engenharia Jurídica & Governança

### (a) Fundamentação das cláusulas

- **LGPD (Lei nº 13.709/2018):** art. 6º (princípios — finalidade, adequação, necessidade/minimização, segurança, prevenção, responsabilização) — itens 4, 8, 12.2; art. 37 (registro das operações de tratamento) — item 9; art. 46 e §2º (medidas de segurança; privacy by design/default) — itens 1.3, 4, 5; art. 47 (responsabilidade dos agentes) — item 15; art. 48 (comunicação de incidentes) — item 12.4; arts. 39, 46 (operador/sub-operador segue instruções do controlador) — itens 2.3 e 13; arts. 42–45 e 52 (responsabilidade e sanções) — item 16.
- **ISO/IEC 27001:2022, Anexo A:** 5.15 (controle de acesso), 5.16 (gestão de identidade), 5.17 (informações de autenticação), 5.18 (direitos de acesso / recertificação), 8.2 (direitos de acesso privilegiado — PAM), 8.3 (restrição de acesso à informação — need-to-know), 8.5 (autenticação segura/MFA) — itens 4 a 12.
- **ISO/IEC 27701:2019:** extensão de privacidade da gestão de acessos a dados pessoais — itens 4.2, 5, 12.
- **NIST SP 800-53 (família AC) e NIST CSF (PR.AC/PR.AA):** least privilege (AC-6), separação de funções (AC-5), gestão de contas (AC-2), acesso remoto/privilegiado, auditoria (AU) — itens 4, 7, 10, 11, 12.
- **OWASP:** controle de acesso quebrado e reforço server-side (RLS como imposição no banco, frontend não confiável) — item 4.3.
- **CLT art. 482; Lei nº 12.737/2012 (invasão de dispositivo); Código Civil (responsabilidade):** base das sanções — item 16.

### (b) Riscos mitigados

- **Vazamento cross-tenant de PII de comprador** → RLS por `company_id` + RBAC + revogação de MV (itens 4.3, 5.4).
- **Exposição indevida de PII no rastreio público** → portal sem login expõe só status neutro (item 4.2.2).
- **Escalada e abuso de privilégio** → PAM, JIT, break-glass revisado, inventário de service roles (item 11).
- **Privilege creep e acessos órfãos** → recertificação periódica e desprovisionamento imediato (itens 7, 8).
- **Fraude financeira em split/repasses** → segregação de funções e dupla aprovação (itens 10.1.b).
- **Comprometimento de segredos** → credenciais write-only, segredos server-side, rotação (itens 5.5, 11.4).
- **Falta de rastreabilidade / repúdio** → identidade nominal, trilha por triggers, soft-delete (itens 4.5, 9).
- **Acesso indevido de terceiros/sub-operadores** → contrato/DPA, menor privilégio, revisão trimestral (item 13).

### (c) Checklist de conformidade

- [ ] RLS habilitada em todas as tabelas de `public`, com policies-padrão (SELECT/INSERT/UPDATE/DELETE).
- [ ] `app.has_permission()` verificado em toda ação sensível; nenhum bypass no frontend.
- [ ] MFA ativo para superadmins, admins, DBAs e consoles de sub-operadores.
- [ ] Catálogo de papéis publicado e mapeado a `recurso.ação`.
- [ ] Fluxo formal de provisionamento/aprovação implantado (solicita ≠ aprova ≠ provisiona).
- [ ] Desprovisionamento imediato integrado ao offboarding; sessões e tokens revogados.
- [ ] Cronograma de recertificação (trimestral/semestral) com evidências arquivadas.
- [ ] Inventário de acessos privilegiados e service roles, com donos nomeados.
- [ ] Procedimento de break-glass documentado e testado, com revisão a posteriori.
- [ ] Segredos exclusivamente server-side; credenciais de terceiros write-only; rotação definida.
- [ ] Logs de acesso capturam eventos mínimos, sem PII/segredos em claro; alertas ativos.
- [ ] Soft-delete e trilha de auditoria (triggers) validados em todas as tabelas de negócio.
- [ ] SoD revisada; controles compensatórios documentados onde a separação for inviável.
- [ ] DPA/contratos com sub-operadores vigentes e revisados.

### (d) Matriz RACI

| Atividade | Diretoria | CISO/Segurança | DPO | Gestor de área | TI/Engenharia | Auditoria |
|---|---|---|---|---|---|---|
| Aprovar a Política | A | R | C | I | I | C |
| Definir modelo RBAC/RLS | I | A | C | C | R | C |
| Provisionar acesso | I | C | I | A | R | I |
| Desprovisionar acesso | I | A | I | R | R | I |
| Recertificação periódica | I | A | C | R | C | C |
| Gestão de PAM/segredos | I | A | I | C | R | C |
| Monitorar logs / responder a incidentes | I | A/R | C | I | R | C |
| Aplicar sanções | A | C | C | R | I | I |
| Revisar a Política | A | R | C | C | C | C |

(R = Responsável; A = Aprovador; C = Consultado; I = Informado.)

### (e) Plano de revisão

- **Revisão ordinária:** anual, conduzida pelo CISO com validação do DPO e da Diretoria.
- **Revisão extraordinária:** disparada por mudança regulatória, incidente de segurança, novo sub-operador/fluxo de dados, achado de auditoria ou alteração arquitetural relevante.
- **Recertificações de acesso:** trimestral (privilegiado/PII/terceiros) e semestral (padrão), conforme item 8.
- **Testes:** simulação anual de break-glass e de desprovisionamento; verificação amostral de policies RLS a cada release que altere schema.
- **Registro:** todas as revisões geram ata, versão atualizada e arquivamento da versão anterior.

### (f) Controle de versão

| Versão | Data | Autor(a) | Descrição | Aprovação |
|---|---|---|---|---|
| 0.1 (minuta) | 16 de julho de 2026 | Chief Legal AI (IA) | Elaboração inicial — minuta para revisão jurídica | Pendente |
| 1.0 | 16 de julho de 2026 | [NOME] | Versão aprovada para produção | [NOME — Diretoria/CISO] |

---

**Documento controlado.** Cópias impressas são consideradas não controladas. A versão vigente é a mantida no repositório oficial de políticas da LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA / [NOME FANTASIA: GLOP]. Dúvidas sobre acessos: lemoncapsencapsulados@gmail.com.
