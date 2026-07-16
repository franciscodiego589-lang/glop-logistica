# Política de Auditoria e Logs — GLOP (Global Logistics Platform)

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

**Controlador / Operador:** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, inscrita no CNPJ sob o nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, operadora da plataforma [NOME FANTASIA: GLOP], acessível em https://glop-logistica.netlify.app.

**Encarregado pelo Tratamento de Dados Pessoais (DPO):** a ser designado pela administração — lemoncapsencapsulados@gmail.com.

**Data de vigência:** 16 de julho de 2026 · **Classificação deste documento:** Interno — Uso Restrito · **Versão:** 1.0

---

## 1. Objetivo

1.1. Esta Política de Auditoria e Logs (doravante "Política") estabelece as diretrizes, os requisitos mínimos obrigatórios, os papéis e as responsabilidades para a **geração, coleta, formatação, transporte, armazenamento, proteção, imutabilidade, retenção, monitoramento, correlação, análise e descarte** de registros de auditoria (trilhas de auditoria) e de logs técnicos e de segurança gerados, custodiados ou processados pela LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA no âmbito da operação da plataforma **GLOP — Global Logistics Platform**.

1.2. O GLOP é uma plataforma SaaS de logística e ERP para operações de **dropshipping e infoprodutos no Brasil**, com natureza jurídica **dupla** perante a LGPD (OPERADOR dos dados do comprador em nome do produtor/lojista CONTROLADOR; e CONTROLADOR dos dados de seus próprios usuários e colaboradores). Essa dualidade, somada ao tratamento de **PII do comprador final** (nome, CPF/CNPJ, e-mail, telefone, endereço completo), **dados bancários e PIX de coprodutores/afiliados**, **documentos fiscais** e **credenciais de integração**, eleva a rastreabilidade e a prestação de contas (accountability) a requisito **legal, contratual e probatório** — não meramente técnico-operacional.

1.3. São finalidades específicas desta Política:

1. Assegurar a **prestação de contas (accountability)** exigida pelo art. 6º, X, e pelo art. 50 da **Lei nº 13.709/2018 (LGPD)**, demonstrando de forma verificável a adoção de medidas eficazes de governança e de segurança;
2. Prover **trilha de auditoria completa, íntegra e recuperável** de toda criação, alteração e exclusão lógica de registros de negócio, atendendo aos arts. 37, 46, 47 e 48 da LGPD;
3. Cumprir a obrigação de **guarda de registros de acesso a aplicações de internet** pelo prazo mínimo de 6 (seis) meses, nos termos do art. 15 da **Lei nº 12.965/2014 (Marco Civil da Internet — MCI)**;
4. Habilitar a **detecção, resposta e forense** de incidentes de segurança, subsidiando a comunicação à ANPD e aos titulares (art. 48 da LGPD) e a investigação de causa-raiz;
5. Fornecer **evidências** para auditorias internas e externas, certificações (ISO/IEC 27001, 27701), due diligence de clientes e sub-operadores, e defesa em eventuais litígios ou processos administrativos sancionadores;
6. Alinhar-se aos referenciais **ISO/IEC 27001** (controles A.8.15 Logging, A.8.16 Monitoring activities, A.8.17 Clock synchronization), **ISO/IEC 27701** (PIMS), **NIST CSF 2.0** (funções DETECT e RESPOND), **NIST SP 800-92** (Guide to Computer Security Log Management), **CIS Controls v8** (Control 8 — Audit Log Management) e **OWASP** (ASVS V7 — Error Handling and Logging, e Logging Cheat Sheet).

---

## 2. Escopo e Público

### 2.1. Escopo material

Esta Política aplica-se a **todos** os registros de auditoria e logs gerados em qualquer camada do ecossistema GLOP, incluindo, sem limitação:

- **Trilha de auditoria de negócio (banco de dados):** registros produzidos automaticamente pelos triggers de auditoria (`app.tg_write_audit()`) em toda operação de INSERT, UPDATE e DELETE nas tabelas de `public`, e pelos triggers de atualização de registro (`app.tg_touch_row()`) que mantêm `updated_at`/`updated_by`/`version`;
- **Colunas de auditoria por registro:** `created_at`, `created_by`, `updated_at`, `updated_by`, `version`, `deleted_at`, `deleted_by`, `reason_deleted` presentes em toda tabela de negócio (rastreabilidade em nível de linha);
- **Logs de aplicação (Next.js / App Router):** logs de requisição, autenticação, autorização (RLS/RBAC), erros de aplicação e exceções, gerados no runtime SSR hospedado na **Netlify**;
- **Logs de autenticação e identidade (Supabase Auth):** login, logout, falhas de login, emissão e revogação de JWT, redefinição de senha, MFA, criação/exclusão de usuários;
- **Logs de banco de dados (Supabase/PostgreSQL):** logs de conexão, consultas relevantes, erros, alterações de privilégio e de política RLS, execução de migrations;
- **Logs de API e webhook (ingestão de pedidos):** chamadas de entrada (pull) às APIs de **Monetizze, Hotmart, Kiwify** e e-commerces (**Shopify, WooCommerce, Nuvemshop, Mercado Livre**), incluindo o endpoint interno de puxada (`/api/lojas/pull`), com metadados de requisição/resposta e correlação ao pedido;
- **Logs de webhook de entrada e saída:** recebimento de eventos de pagamento/pedido, verificação de assinatura/HMAC, idempotência, reprocessamento e falhas de entrega;
- **Logs de integração logística:** pré-postagem (**PPN**) e rastreio (**SRO**) junto aos **Correios**, geração de código de rastreio, e disparo de notificações ao comprador por **e-mail/WhatsApp**;
- **Logs de emissão fiscal:** geração de **NF-e via VHSYS** e demais documentos fiscais, com retorno de autorização/rejeição;
- **Logs de coprodução & split:** apuração de comissões, repasses e **split de pagamento (AppMax)**, acesso e alteração de dados de **PIX/bancários** de coprodutores/afiliados;
- **Logs do portal público de rastreio (sem login):** acessos ao portal, consultas por código de rastreio, com registro estritamente minimizado e neutro;
- **Logs de infraestrutura e segurança:** eventos da **Netlify** (deploys, funções SSR), da **Supabase** (Storage, Edge Functions), cofre de credenciais de API em modo **write-only**, e eventos de configuração/segredos;
- **Logs de acesso administrativo e privilegiado:** ações de superadmin (`app.is_superadmin()`), alterações de RBAC (`app.has_permission`), exportações de dados, e operações de descarte/anonimização.

### 2.2. Escopo pessoal (público-alvo)

Esta Política é de observância **obrigatória** por:

| Público | Aplicabilidade |
|---|---|
| Sócios, administradores e diretoria | Integral — patrocínio, aprovação e prestação de contas |
| Colaboradores (CLT), estagiários e aprendizes | Integral |
| Desenvolvedores, DevOps e administradores de banco/sistema | Integral, com controles reforçados sobre acesso privilegiado e proibição de manipular logs |
| Encarregado (DPO) e time de Segurança/Privacidade | Integral — governança, revisão e resposta a incidentes |
| Prestadores de serviço e consultores | Integral, mediante termo de confidencialidade |
| Produtores/lojistas (clientes/Controladores) | Parcial — direito a trilhas de suas próprias operações e dever de custódia de credenciais |
| Sub-operadores (Supabase, Netlify, VHSYS, Correios, gateways) | Por vínculo contratual, cláusulas de logging e DPA |

### 2.3. Escopo temporal

Aplica-se a todo log ou registro de auditoria produzido a partir da data de vigência, e retroativamente aos registros já existentes na medida em que estejam sob custódia da LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, observados os prazos de retenção do item 8.

---

## 3. Princípios da Auditoria e do Registro

1. **Accountability (prestação de contas):** todo tratamento de dado pessoal e toda operação crítica de negócio devem ser demonstráveis por evidência registrada (art. 6º, X, e art. 50 da LGPD).
2. **Rastreabilidade (quem, o quê, quando, onde, como):** todo evento relevante deve permitir reconstruir o agente, a ação, o instante, a origem e o objeto afetado.
3. **Imutabilidade e integridade:** logs e trilhas são registros **append-only** — nunca editados nem apagados durante seu ciclo de retenção; qualquer alteração deve ser, ela própria, detectável.
4. **Minimização no log:** registra-se o **necessário e suficiente** para auditoria e segurança, evitando gravar dados sensíveis ou PII em excesso dentro do corpo do log (art. 6º, III, da LGPD).
5. **Segregação de funções:** quem opera o sistema não deve poder adulterar ou suprimir a própria trilha que o audita (separação entre produtor e custodiante do log).
6. **Confidencialidade do log:** logs contêm informação sensível de segurança e, por vezes, PII — devem ser protegidos com o mesmo (ou maior) rigor dos dados que descrevem.
7. **Sincronização temporal:** todos os relógios usam fonte confiável (NTP) e carimbos em **UTC** com fuso registrado, garantindo ordenação forense confiável (ISO/IEC 27001 A.8.17).
8. **Isolamento multi-tenant:** trilhas e logs de negócio carregam `tenant_id`/`company_id` e são segregados por RLS, de modo que nenhum Controlador acesse a trilha de outro.
9. **Proporcionalidade:** o nível de detalhe e o rigor do monitoramento são proporcionais à criticidade e à sensibilidade do ativo (PII, dados bancários, credenciais → nível máximo).

---

## 4. O Que Registrar (Eventos Auditáveis)

### 4.1. Trilha de auditoria de negócio (triggers no PostgreSQL)

Toda tabela de negócio possui os dois gatilhos obrigatórios:

- `trg_<t>_touch` (BEFORE INSERT OR UPDATE) → executa `app.tg_touch_row()`: mantém `updated_at`, `updated_by` e incrementa `version`;
- `trg_<t>_audit` (AFTER INSERT OR UPDATE OR DELETE) → executa `app.tg_write_audit()`: grava o evento na tabela central de auditoria.

Cada registro de auditoria de negócio deve conter, no mínimo:

| Campo | Descrição |
|---|---|
| `audit_id` | Identificador único do evento (UUID) |
| `occurred_at` | Timestamp UTC do evento |
| `tenant_id` / `company_id` / `branch_id` | Contexto multi-tenant do registro afetado |
| `actor_user_id` | Usuário autenticado (`auth.users`) que originou a ação |
| `actor_role` | Papel/perfil efetivo no momento (RBAC) |
| `table_name` | Tabela afetada |
| `record_id` | PK do registro afetado |
| `operation` | INSERT / UPDATE / DELETE (lógico) |
| `old_values` / `new_values` | Estado anterior e posterior (diff), com mascaramento de campos sensíveis conforme item 6 |
| `record_version` | Versão do registro após a operação |
| `origin` | Origem (UI, API, webhook, job, migration) |
| `request_id` / `correlation_id` | Correlação com a requisição/transação |

Observações obrigatórias:

- O GLOP **não realiza DELETE físico** — a exclusão é lógica (soft delete: `deleted_at`, `deleted_by`, `reason_deleted`), e essa operação **também** gera registro de auditoria com o motivo declarado;
- A trilha registra alterações de **RBAC/RLS** (concessão/revogação de permissão, mudança de papel, criação de membership) como eventos de segurança de prioridade elevada;
- Toda execução de **migration** (fonte da verdade do schema) é registrada com versão, autor e hash.

### 4.2. Eventos de autenticação e acesso (identity)

- Login bem-sucedido e malsucedido (com motivo e contagem de tentativas);
- Logout, expiração e revogação de sessão/JWT;
- Redefinição de senha, ativação/desativação de MFA;
- Criação, bloqueio, reativação e exclusão de usuários;
- Elevação para superadmin e uso de acesso privilegiado;
- Tentativas de acesso negadas por RLS/RBAC (violação de autorização) — evento de segurança.

### 4.3. Eventos de acesso e tratamento de dados pessoais

- Leitura em massa/exportação de PII do comprador ou de dados bancários de coprodutores (quem exportou, quantos registros, para qual finalidade e destino);
- Atendimento a requisições de titulares (acesso, correção, eliminação, portabilidade — arts. 18 e 19 da LGPD): registro do pedido, decisão e execução;
- Anonimização/pseudonimização e descarte de dados ao fim da retenção;
- Compartilhamento/transmissão de dados a sub-operadores (Correios, VHSYS, gateways) por fluxo e finalidade.

### 4.4. Logs de API e webhook (ingestão e integrações)

Para cada chamada de entrada (pull) ou webhook recebido/enviado, registrar:

- Timestamp UTC, `correlation_id`, `tenant_id`/`company_id`, endpoint/rota (ex.: `/api/lojas/pull`), método e origem (Monetizze, Hotmart, Kiwify, Shopify, WooCommerce, Nuvemshop, Mercado Livre);
- Resultado da **verificação de assinatura/HMAC** e da **idempotência** (evento novo × duplicado);
- Código de status, latência, tamanho de payload e identificador do pedido resultante;
- **Nunca** registrar segredos/tokens de API em claro — as credenciais são **write-only** e mascaradas no log;
- Falhas, retentativas (retry), backoff e envio à fila de mensagens mortas (dead-letter), quando aplicável.

### 4.5. Logs de fluxo logístico e fiscal

- **Correios:** requisição de pré-postagem (PPN), retorno de código de rastreio, consultas de rastreio (SRO), e disparo de notificação (e-mail/WhatsApp) — com status de entrega da notificação;
- **VHSYS/NF-e:** requisição de emissão, protocolo de autorização/rejeição, número/chave do documento fiscal;
- **Split/AppMax:** cálculo de comissão, apuração, ordem de repasse e status de liquidação, sem expor dados bancários completos no corpo do log.

### 4.6. Portal público de rastreio (sem login)

- Registra acessos e consultas com **minimização máxima**: código consultado (ou seu hash), timestamp, IP/porta e user-agent para fins de segurança e de guarda do art. 15 do MCI;
- **Não** correlaciona, no log do portal público, o código a PII do comprador; a página expõe apenas **status neutro**, e o log observa essa mesma neutralidade.

### 4.7. Eventos que NÃO devem ser registrados (proibições)

É **vedado** gravar em logs, em texto claro:

- Senhas, tokens, chaves de API, segredos, cookies de sessão ou cabeçalhos `Authorization`;
- Número completo de cartão, CVV ou dados de meio de pagamento sensíveis;
- CPF/CNPJ, dados bancários/PIX e demais PII em corpo de log de aplicação sem necessidade — quando indispensáveis à auditoria, devem ser **mascarados** ou **tokenizados** (item 6);
- Conteúdo de mensagens pessoais além do necessário para comprovar a entrega da notificação.

---

## 5. Formato, Padronização e Correlação

5.1. **Formato estruturado:** logs de aplicação e de integração devem ser gerados em formato estruturado (JSON), com esquema de campos padronizado, para permitir ingestão, busca e correlação por ferramentas de SIEM.

5.2. **Campos mínimos comuns:** `timestamp` (UTC/ISO 8601), `level` (DEBUG/INFO/WARN/ERROR/SECURITY), `service`, `environment` (prod/homolog/dev), `tenant_id`, `company_id`, `actor_user_id`, `request_id`/`correlation_id`, `event_type`, `outcome` (success/failure) e `message`.

5.3. **Correlação ponta a ponta:** um mesmo `correlation_id` deve atravessar UI → API → banco → integração externa, permitindo reconstruir toda a jornada de um pedido (do webhook do gateway à pré-postagem nos Correios e à emissão da NF-e).

5.4. **Sincronização de tempo:** todos os componentes usam NTP; carimbos em UTC. Divergências relevantes de relógio são, elas próprias, um evento monitorado (ISO/IEC 27001 A.8.17).

5.5. **Níveis de severidade:** eventos de segurança (violação de RLS/RBAC, falhas de assinatura de webhook, acessos privilegiados, exportações de PII) recebem nível `SECURITY` e roteamento prioritário ao monitoramento.

---

## 6. Minimização, Mascaramento e Proteção de PII no Log

6.1. Aplica-se ao próprio log o princípio da **necessidade** (art. 6º, III, LGPD): registra-se o mínimo suficiente para auditoria, detecção e resposta.

6.2. **Mascaramento obrigatório** em corpo de log e em `old_values`/`new_values` da trilha, salvo campo cujo valor íntegro seja indispensável e o registro esteja restrito por acesso:

- CPF/CNPJ → exibir apenas parciais (ex.: `***.***.***-12`);
- E-mail → mascarar usuário (ex.: `j****@dominio.com`);
- Telefone → mascarar dígitos intermediários;
- Endereço → registrar UF/cidade/CEP parcial quando o log não exigir o endereço completo;
- Dados bancários/PIX → tokenizar ou referenciar por ID, nunca gravar a chave/conta completa em claro.

6.3. **Credenciais write-only:** tokens e chaves de integração são armazenados de forma que a aplicação escreve mas não relê o segredo em claro; nos logs, aparecem apenas mascarados ou por referência.

6.4. **Confidencialidade e acesso ao log:** o acesso às trilhas e logs segue **need to know** e **menor privilégio** (RBAC), é ele mesmo auditado (log-of-log), e a leitura de trilhas de negócio respeita o isolamento por `tenant_id`/`company_id`.

6.5. **Criptografia:** logs em trânsito trafegam por TLS; logs em repouso e backups de auditoria são cifrados (at rest), conforme a Política de Segurança da Informação.

---

## 7. Imutabilidade e Integridade

7.1. **Append-only:** registros de auditoria e logs de segurança são **somente-adição**. Nenhum papel operacional (inclusive desenvolvedores e superadmins) tem permissão para editar ou remover registros de trilha dentro do período de retenção.

7.2. **Controle por RLS/permissão:** a tabela de auditoria não expõe políticas de UPDATE/DELETE a papéis autenticados; a escrita ocorre exclusivamente via trigger security definer (`app.tg_write_audit()`), e não por caminho de aplicação editável pelo usuário.

7.3. **Integridade verificável:** recomenda-se encadeamento de integridade (hash chain / hash do registro anterior) e/ou selagem periódica (assinatura ou digest publicado em repositório separado) para tornar **detectável** qualquer adulteração retroativa — atendendo ao valor probatório da evidência.

7.4. **Segregação de custódia:** cópias de logs de segurança são replicadas para armazenamento com controle de acesso distinto do ambiente de produção (ex.: bucket dedicado no Supabase Storage com revogação de anon/authenticated, ou destino externo append-only), de modo que o comprometimento do ambiente não permita apagar a trilha.

7.5. **Proteção contra supressão:** tentativas de desabilitar triggers, alterar políticas de auditoria ou expurgar logs antes do prazo constituem evento de segurança de máxima prioridade e violação disciplinar grave (item 12).

7.6. **WORM/retenção legal:** para evidências sujeitas a litígio ou investigação (legal hold), aplica-se retenção estendida e, quando possível, armazenamento WORM (write once, read many), suspendendo qualquer rotina de expurgo até liberação formal.

---

## 8. Retenção e Descarte de Logs

8.1. Os prazos de retenção equilibram a obrigação legal de guarda, a utilidade forense e o princípio da **necessidade** (não reter além do necessário — art. 15 e art. 16 da LGPD). Prazos de referência:

| Categoria de log/registro | Retenção mínima de referência | Fundamento principal |
|---|---|---|
| Registros de acesso a aplicação de internet (MCI) | **6 meses** (mínimo legal) | Art. 15, Lei 12.965/2014 |
| Trilha de auditoria de negócio (INSERT/UPDATE/DELETE) | **5 anos** (alinhado à prescrição civil/consumerista) | Art. 27, CDC; art. 205/206, CC; accountability LGPD |
| Logs de autenticação e segurança | 12 a 24 meses | ISO/IEC 27001 A.8.15/A.8.16; forense |
| Logs de API/webhook e integrações | 12 meses | Conciliação de pedidos, disputas de gateway |
| Logs fiscais (NF-e/VHSYS) e correlatos | Conforme prazo fiscal aplicável (comumente **5 anos**) | Legislação tributária; guarda de documentos fiscais |
| Logs do portal público de rastreio | 6 meses (mínimo MCI), minimizados | Art. 15, MCI |
| Evidências sob legal hold | Até liberação formal | Interesse legítimo/defesa em processo |

8.2. Os prazos acima são **referenciais** e devem ser confirmados pelo jurídico à luz da operação real, dos contratos com Controladores e da legislação vigente. Em caso de conflito, prevalece o **maior** prazo legalmente exigido; findos todos os fundamentos, procede-se ao descarte ou à anonimização.

8.3. **Descarte seguro:** ao término da retenção, os logs são eliminados de forma segura e irreversível (destruição de mídia lógica, remoção de backups correspondentes), com **registro do próprio descarte** (data, escopo, responsável) para preservar a cadeia de accountability.

8.4. **Anonimização como alternativa:** quando houver interesse analítico legítimo, dados de log podem ser **anonimizados** (art. 5º, XI, LGPD) em vez de descartados, desde que a reversão seja inviável por meios razoáveis.

8.5. **Instruções do Controlador:** nos fluxos em que o GLOP é OPERADOR, a retenção e o descarte de logs que contenham PII do comprador observam as instruções documentadas do Controlador e o DPA, sem prejuízo dos prazos legais mínimos de guarda.

---

## 9. Monitoramento, Detecção e Resposta (SIEM/SOC)

9.1. **Coleta centralizada:** logs das camadas (Netlify, Supabase Auth/DB/Storage/Edge Functions, aplicação Next.js, integrações) são centralizados em solução de gestão de logs/SIEM para correlação, retenção e alerta.

9.2. **Monitoramento contínuo:** o ambiente é monitorado de forma contínua ([24x7 / horário comercial — conforme maturidade]) por função de SOC (interna ou terceirizada), com painéis, métricas e alertas.

9.3. **Regras de detecção (mínimas):**

- Picos de falhas de login, força bruta e acessos de origem anômala;
- Violações de RLS/RBAC (tentativas de acesso cross-tenant);
- Falhas de verificação de assinatura/HMAC de webhook e replays;
- Exportação ou leitura em massa de PII/dados bancários fora do padrão;
- Uso de acesso privilegiado/superadmin fora de janela ou sem chamado;
- Tentativa de alterar/desabilitar triggers de auditoria ou expurgar logs;
- Divergência de relógio (NTP) e interrupção de coleta de logs (log gap).

9.4. **Alertas e SLA de triagem:** eventos `SECURITY` geram alerta e triagem conforme SLA definido na Política de Resposta a Incidentes; incidentes com dados pessoais acionam o fluxo de comunicação à **ANPD** e aos titulares quando houver risco relevante (art. 48, LGPD).

9.5. **Métricas e KPIs:** cobertura de logging por serviço, MTTD (tempo médio de detecção), MTTR (tempo médio de resposta), volume de eventos de segurança, taxa de falso-positivo, e disponibilidade da coleta. KPIs de segurança são apurados por consulta agregada (RPC), não somados manualmente.

9.6. **Revisão periódica:** logs de segurança e acessos privilegiados são revisados periodicamente (revisão de acessos), com evidência da revisão registrada.

---

## 10. Auditorias Internas e Externas

### 10.1. Auditorias internas

- Realizadas periodicamente (mínimo **anual**, ou a cada mudança relevante) pelo time de Segurança/Privacidade sob supervisão do DPO;
- Escopo: aderência a esta Política, cobertura de logging, integridade da trilha, prazos de retenção, mascaramento de PII, segregação de custódia e eficácia das regras de detecção;
- Produzem relatório com achados classificados por severidade, plano de ação e prazos, com acompanhamento até a remediação.

### 10.2. Auditorias externas e certificação

- A LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA pode submeter-se a auditorias independentes e a certificações (ISO/IEC 27001, ISO/IEC 27701), disponibilizando evidências de logging e monitoramento aos auditores sob confidencialidade;
- Relatórios de sub-operadores (ex.: SOC 2 / ISO da Supabase e Netlify) integram o programa de gestão de fornecedores.

### 10.3. Direito de auditoria dos Controladores

- Nos fluxos em que o GLOP é OPERADOR, os Controladores (produtores/lojistas) têm, nos termos do DPA, o direito de auditar ou receber evidências (relatórios, atestados) sobre o tratamento e o logging de seus dados, respeitados o isolamento multi-tenant e a confidencialidade de terceiros;
- O acesso a evidências não pode expor dados ou trilhas de outro Controlador (garantia de RLS).

### 10.4. Cooperação com autoridades

- Requisições de autoridades competentes (ANPD, Poder Judiciário, autoridades fiscais) são atendidas mediante fundamento legal válido, ordem competente e registro da requisição e do que foi fornecido (accountability), com preservação da cadeia de custódia.

---

## 11. Accountability LGPD e Valor Probatório das Evidências

11.1. **Demonstrabilidade (art. 6º, X, e art. 50, LGPD):** as trilhas e logs constituem a evidência primária de que o GLOP adota medidas eficazes de governança, segurança e privacidade, servindo à defesa em processos administrativos e judiciais.

11.2. **Suporte a obrigações específicas:** as evidências subsidiam o Relatório de Impacto à Proteção de Dados (RIPD/DPIA), o Registro das Operações de Tratamento (ROPA), a resposta a requisições de titulares e a comunicação de incidentes.

11.3. **Cadeia de custódia:** para uso probatório, as evidências são coletadas e preservadas com registro de quem coletou, quando, de onde e com qual hash de integridade, evitando contestação sobre autenticidade.

11.4. **Reconstrução de fluxo:** por meio do `correlation_id` e da trilha por linha, é possível reconstruir integralmente a jornada de um pedido — do webhook do gateway à baixa/entrega — demonstrando licitude e regularidade do tratamento.

11.5. **Segregação Operador × Controlador:** as evidências distinguem os fluxos em que o GLOP atua como OPERADOR (dados do comprador) daqueles em que atua como CONTROLADOR (usuários e colaboradores), delimitando responsabilidades.

---

## 12. Papéis, Responsabilidades e Sanções

### 12.1. Papéis

- **Diretoria/Administração:** patrocina o programa, aprova a Política e provê recursos;
- **Encarregado (DPO):** supervisiona a aderência à LGPD, valida prazos de retenção e responde perante ANPD/titulares;
- **Segurança da Informação/SOC:** opera SIEM, define regras de detecção, responde a incidentes e conduz auditorias internas;
- **Engenharia/DevOps:** implementa os triggers, o logging estruturado, o mascaramento e a segregação de custódia; não manipula trilhas;
- **DBA/Plataforma:** garante integridade dos triggers, do NTP e dos backups de auditoria;
- **Todos os usuários:** cumprem a Política e comunicam anomalias.

### 12.2. Sanções

O descumprimento desta Política — em especial a tentativa de **suprimir, adulterar ou desabilitar** trilhas/logs, a gravação indevida de PII/segredos ou o acesso não autorizado a logs — sujeita o infrator a medidas **disciplinares** (advertência, suspensão, justa causa), **contratuais** (rescisão, multa) e **legais** (responsabilização civil e criminal), proporcionais à gravidade, sem prejuízo das sanções da LGPD e do MCI aplicáveis à LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA.

---

## 13. Disposições Finais

13.1. Esta Política integra o corpo normativo de segurança e privacidade do GLOP e complementa a Política de Segurança da Informação, a Política de Privacidade, o DPA e o Plano de Resposta a Incidentes.

13.2. Casos omissos são decididos pelo DPO em conjunto com a Segurança da Informação e o jurídico.

13.3. Eventuais litígios decorrentes desta Política, quando não resolvidos administrativamente, submetem-se ao foro da comarca de [ENDEREÇO/COMARCA], com renúncia a qualquer outro por mais privilegiado que seja.

---

## Engenharia Jurídica & Governança

### (a) Fundamentação das cláusulas (lei/norma que embasa)

| Tema da cláusula | Fundamento legal/normativo |
|---|---|
| Accountability e demonstrabilidade | Art. 6º, X, e art. 50 da LGPD (Lei 13.709/2018) |
| Guarda de registros de acesso a aplicações | Art. 15 da Lei 12.965/2014 (Marco Civil da Internet) |
| Segurança e integridade dos dados/registros | Arts. 46, 47 e 48 da LGPD |
| Minimização no log e finalidade | Art. 6º, I, III e V, da LGPD |
| Retenção e término do tratamento | Arts. 15 e 16 da LGPD |
| Prazos prescricionais (retenção da trilha) | Art. 27 do CDC (Lei 8.078/1990); arts. 205 e 206 do Código Civil |
| Comunicação de incidentes | Art. 48 da LGPD e regulamentação da ANPD |
| Direitos dos titulares (evidência de atendimento) | Arts. 18 e 19 da LGPD |
| Guarda fiscal de documentos (NF-e) | Legislação tributária aplicável |
| Controles técnicos de logging/monitoramento | ISO/IEC 27001 (A.8.15, A.8.16, A.8.17), ISO/IEC 27701, NIST CSF 2.0, NIST SP 800-92, CIS Control 8, OWASP ASVS V7 |
| Transferência a operador/sub-operador | Arts. 39 e 40 da LGPD; DPA |

### (b) Riscos mitigados

- **Sanções da ANPD** por ausência de accountability e de trilha demonstrável;
- **Responsabilização civil** por incidente sem capacidade de investigação/forense;
- **Repúdio (não repúdio)** de operações críticas (repasses, exclusões, exportações de PII);
- **Adulteração de evidências** por insiders (mitigada por imutabilidade append-only e segregação de custódia);
- **Vazamento via log** de PII/segredos (mitigado por mascaramento e credenciais write-only);
- **Cross-tenant** em trilhas (mitigado por isolamento RLS por `tenant_id`/`company_id`);
- **Perda de guarda legal** (mitigada pelos prazos mínimos e legal hold);
- **Descoberta tardia de incidente** (mitigada por SIEM/SOC e regras de detecção).

### (c) Checklist de conformidade

1. Triggers `trg_<t>_touch` e `trg_<t>_audit` ativos em todas as tabelas de negócio;
2. Colunas de auditoria (`created_by`/`updated_by`/`version`/`deleted_at`/`reason_deleted`) presentes e populadas;
3. Logging estruturado (JSON) com campos mínimos e `correlation_id` ponta a ponta;
4. Mascaramento de CPF/CNPJ, e-mail, telefone, endereço e dados bancários no log;
5. Credenciais de API write-only e nunca em claro no log;
6. Trilha append-only, sem UPDATE/DELETE por papéis autenticados;
7. Integridade verificável (hash chain/selagem) implementada ou planejada (marcar status);
8. Segregação de custódia dos logs de segurança;
9. NTP/UTC configurado e monitorado;
10. Prazos de retenção definidos por categoria e revisados pelo jurídico;
11. Descarte/anonimização seguros ao fim da retenção, com registro do descarte;
12. SIEM/SOC com regras de detecção e alertas para eventos `SECURITY`;
13. Auditoria interna anual e evidências prontas para auditoria externa/Controladores;
14. Fluxo de legal hold para evidências sob litígio.

### (d) Matriz RACI

| Atividade | Diretoria | DPO | Segurança/SOC | Engenharia/DevOps | DBA/Plataforma |
|---|---|---|---|---|---|
| Aprovar a Política | A | R | C | I | I |
| Definir prazos de retenção | I | A | C | I | R |
| Implementar triggers e logging | I | C | C | R | R |
| Mascaramento de PII no log | I | A | C | R | I |
| Operar SIEM e detecção | I | C | R/A | I | C |
| Garantir imutabilidade/custódia | I | C | A | R | R |
| Auditoria interna | I | A | R | C | C |
| Responder a incidente/ANPD | C | A | R | C | C |
| Descarte/anonimização | I | A | C | R | R |

(R = Responsável pela execução; A = Aprovador/Prestador de contas; C = Consultado; I = Informado.)

### (e) Plano de revisão

- **Periodicidade:** revisão **anual** obrigatória e revisão **extraordinária** a cada: mudança legislativa/regulatória (ANPD), incidente relevante, novo fluxo/integração (nova plataforma ou gateway), mudança de arquitetura de logging ou de sub-operador;
- **Responsável:** DPO em conjunto com Segurança da Informação e jurídico;
- **Registro:** cada revisão é documentada no controle de versão e comunicada às partes interessadas.

### (f) Controle de versão

| Versão | Data | Autor/Responsável | Descrição da alteração | Aprovação |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | a ser designado pela administração | Emissão inicial da Política de Auditoria e Logs | [DIRETORIA/DPO] |
| 1.1 | 16 de julho de 2026 | [RESPONSÁVEL] | [Descrição] | [APROVADOR] |
