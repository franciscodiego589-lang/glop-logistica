# Política de Segurança da Informação (PSI) — GLOP (Global Logistics Platform)

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

**Controlador / Operador:** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, inscrita no CNPJ sob o nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, operadora da plataforma [NOME FANTASIA: GLOP], acessível em https://glop-logistica.netlify.app.

**Encarregado pelo Tratamento de Dados Pessoais (DPO):** a ser designado pela administração — lemoncapsencapsulados@gmail.com.

**Data de vigência:** 16 de julho de 2026 · **Classificação deste documento:** Interno — Uso Restrito · **Versão:** 1.0

---

## 1. Objetivo

1.1. Esta Política de Segurança da Informação (doravante "PSI" ou "Política") estabelece os princípios, diretrizes, controles, responsabilidades e requisitos mínimos obrigatórios para a proteção da **confidencialidade, integridade, disponibilidade, autenticidade e não repúdio** (pilares CIA + AR) das informações tratadas, processadas, armazenadas, transmitidas ou custodiadas pela LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA no âmbito da operação da plataforma **GLOP — Global Logistics Platform**.

1.2. O GLOP é uma plataforma SaaS (Software as a Service) de logística e ERP voltada a operações de dropshipping e infoprodutos no Brasil, que trata volumes relevantes de **dados pessoais de compradores finais** (nome, CPF/CNPJ, e-mail, telefone, endereço completo), **dados financeiros e bancários de coprodutores/afiliados** (PIX, contas para repasse e split de pagamento), **documentos fiscais** (NF-e, CT-e, MDF-e, NFS-e) e **credenciais de integração** com plataformas de terceiros. Essa natureza torna a segurança da informação um requisito **crítico, contratual e legal**, e não meramente técnico.

1.3. Esta PSI tem por finalidades específicas:

1. Proteger os ativos de informação do GLOP e de seus clientes contra ameaças internas e externas, acidentais ou intencionais;
2. Assegurar a conformidade com a **Lei nº 13.709/2018 (Lei Geral de Proteção de Dados Pessoais — LGPD)**, a **Lei nº 12.965/2014 (Marco Civil da Internet)**, o **Código de Defesa do Consumidor (Lei nº 8.078/1990)**, o **Código Civil (Lei nº 10.406/2002)**, as Resoluções e orientações da **Autoridade Nacional de Proteção de Dados (ANPD)** e, quando aplicável, o **GDPR (Regulamento (UE) 2016/679)**;
3. Alinhar a governança de segurança aos referenciais internacionais **ISO/IEC 27001** (Sistema de Gestão de Segurança da Informação — SGSI), **ISO/IEC 27701** (Sistema de Gestão de Privacidade da Informação — PIMS), **ISO/IEC 27002** (controles), **ISO/IEC 27017/27018** (nuvem e PII em nuvem), **ISO/IEC 22301** (continuidade de negócios), **ISO 31000** (gestão de riscos), **NIST Cybersecurity Framework (CSF 2.0)**, **CIS Controls v8** e **OWASP** (Top 10, ASVS, SAMM);
4. Definir papéis, responsabilidades e mecanismos de accountability (prestação de contas) exigidos pelo art. 50 da LGPD;
5. Estabelecer o regime de sanções aplicável ao descumprimento.

---

## 2. Escopo e Público

### 2.1. Escopo material

Esta Política aplica-se à totalidade do ambiente de informação do GLOP, incluindo, sem limitação:

- **Aplicação e infraestrutura:** frontend Next.js (App Router), backend e banco de dados **Supabase (PostgreSQL)** com RLS (Row Level Security) multi-tenant, **Supabase Auth (JWT)**, **Supabase Storage**, **Supabase Edge Functions**, hospedagem SSR na **Netlify**;
- **Fluxos de ingestão de pedidos:** puxada (pull) de pedidos via API de plataformas de pagamento/checkout (**Monetizze, Hotmart, Kiwify**) e de e-commerces (**Shopify, WooCommerce, Nuvemshop, Mercado Livre**), com PII do comprador (nome, CPF/CNPJ, e-mail, telefone, endereço completo — CEP, rua, número, bairro, cidade, UF), produto e valor;
- **Integração logística:** pré-postagem (**PPN**) e rastreio (**SRO**) junto aos **Correios**, geração de código de rastreio e notificação ao comprador por e-mail/WhatsApp;
- **Coprodução & Split:** cadastro de coprodutores/afiliados, regras de comissão, apuração, repasses e **split de pagamento (AppMax)**, incluindo tratamento de dados de **PIX e bancários** de coprodutores;
- **Emissão fiscal:** geração de **NF-e via VHSYS** e demais documentos fiscais (NF-e/CT-e/MDF-e/NFS-e);
- **Portal público de rastreio (sem login):** consulta de status pelo comprador mediante código de rastreio, com exposição restrita a status neutro;
- **Interfaces de integração:** webhooks de entrada e saída, logs de API, e cofre de credenciais de API guardadas em modo **write-only**;
- Todos os ambientes (produção, homologação, desenvolvimento), backups, repositórios de código, segredos, chaves criptográficas, estações de trabalho, contas de nuvem e canais de comunicação corporativos.

### 2.2. Escopo pessoal (público-alvo)

Esta Política é de observância **obrigatória** por:

| Público | Aplicabilidade |
|---|---|
| Sócios, administradores e diretoria | Integral — responsáveis pela aprovação, patrocínio e prestação de contas |
| Colaboradores (CLT), estagiários e aprendizes | Integral |
| Prestadores de serviço, terceirizados e consultores | Integral, mediante termo de confidencialidade |
| Desenvolvedores, DevOps e administradores de sistema | Integral, com controles reforçados de acesso privilegiado |
| Produtores/lojistas (clientes do GLOP) | Parcial — deveres de uso seguro, custódia de credenciais e responsabilidade como Controladores |
| Coprodutores/afiliados | Parcial — deveres de custódia de suas credenciais e dados |
| Fornecedores e sub-operadores (Supabase, Netlify, VHSYS, Correios, AppMax e plataformas de checkout) | Por vínculo contratual, cláusulas de segurança e DPA (Data Processing Agreement) |

### 2.3. Natureza dupla LGPD (Controlador × Operador)

O GLOP possui **natureza jurídica dupla** perante a LGPD, e esta dualidade orienta toda a Política:

1. **GLOP como OPERADOR (art. 5º, VII, LGPD):** quando trata dados pessoais do **comprador final** por conta e ordem do **produtor/lojista** (Controlador). Exemplos: puxar pedidos com PII da Monetizze, gerar pré-postagem nos Correios, emitir NF-e via VHSYS, notificar rastreio. Nesses fluxos, o GLOP atua conforme instruções documentadas do Controlador e não pode tratar os dados para finalidade própria distinta.
2. **GLOP como CONTROLADOR (art. 5º, VI, LGPD):** quando trata dados pessoais de seus **próprios usuários** (produtores/lojistas, coprodutores/afiliados), **colaboradores** e visitantes do site, definindo as finalidades e os meios do tratamento (cadastro, cobrança, suporte, segurança, marketing próprio).

Esta PSI aplica controles proporcionais em ambas as posições, com **segregação lógica por tenant/company** garantindo que dados de um Controlador jamais sejam acessíveis a outro (isolamento por RLS — Row Level Security).

---

## 3. Princípios Fundamentais

Toda decisão de arquitetura, desenvolvimento, operação e tratamento de dados no GLOP observa os seguintes princípios, cumulativamente:

### 3.1. Security by Design & by Default (Segurança desde a concepção e por padrão)
A segurança e a privacidade são requisitos incorporados desde a fase de concepção de qualquer funcionalidade, e não adicionados posteriormente. O estado padrão de qualquer recurso é o **mais restritivo** (fail-safe defaults): RLS habilitado em todas as tabelas de `public`, credenciais write-only, portal de rastreio expondo apenas status neutro. Fundamento: art. 46, §2º e art. 6º, VII e VIII da LGPD; ISO/IEC 27701; GDPR art. 25.

### 3.2. Least Privilege (Menor privilégio)
Cada usuário, serviço, processo ou integração recebe **apenas** os privilégios estritamente necessários para desempenhar sua função, pelo tempo estritamente necessário. Materializa-se no RBAC (`app.has_permission('resource.action', company_id)`), na segregação de recursos (`master_data, inventory, wms, tms, ..., admin`) e no princípio de que **nada confia no frontend** — toda autorização é reavaliada no banco via RLS.

### 3.3. Need to Know (Necessidade de conhecer)
O acesso à informação é concedido em função da necessidade real e demonstrável de conhecê-la para o exercício da atividade. Dados de PII do comprador, dados bancários de coprodutores e credenciais de API só são acessíveis a papéis e serviços com necessidade comprovada, sempre limitados ao respectivo `tenant_id`/`company_id`.

### 3.4. Defense in Depth (Defesa em profundidade)
Múltiplas camadas independentes de controle protegem cada ativo, de modo que a falha de uma camada não comprometa a segurança do conjunto: TLS 1.3 na borda (Netlify) → autenticação JWT (Supabase Auth) → autorização RBAC → isolamento RLS por tenant → criptografia em repouso → auditoria imutável → monitoramento → backup criptografado.

### 3.5. Zero Trust (Confiança zero)
Nenhuma requisição, usuário, dispositivo ou serviço é confiável por padrão, esteja dentro ou fora do perímetro. Todo acesso é **autenticado, autorizado e continuamente verificado** ("never trust, always verify"). A RLS do PostgreSQL reforça esse princípio: mesmo uma requisição autenticada só enxerga os registros permitidos por política, independentemente do que o frontend solicite.

### 3.6. Princípios complementares
- **Minimização (art. 6º, III, LGPD):** coletar e reter apenas o dado necessário à finalidade.
- **Segregação de funções (Separation of Duties):** nenhuma pessoa detém controle único sobre um processo crítico ponta a ponta.
- **Accountability (art. 6º, X, LGPD):** capacidade de demonstrar conformidade por meio de registros, logs e trilhas de auditoria.
- **Resiliência:** capacidade de resistir, absorver e recuperar-se de incidentes.
- **Transparência (art. 6º, VI, LGPD):** clareza quanto ao tratamento realizado.

---

## 4. Classificação da Informação

### 4.1. Níveis de classificação

Toda informação do GLOP é classificada em um dos quatro níveis abaixo, cabendo ao **proprietário do ativo (data owner)** a classificação inicial e sua revisão:

| Nível | Definição | Exemplos no GLOP | Impacto de vazamento |
|---|---|---|---|
| **Público** | Divulgação livre, sem dano | Material de marketing, status neutro do portal público de rastreio, documentação pública | Nulo |
| **Interno** | Uso interno; divulgação indevida causa dano moderado | Documentação técnica, esta PSI, métricas operacionais agregadas, logs sem PII | Moderado |
| **Confidencial** | Acesso restrito por necessidade; dano relevante | PII do comprador (nome, CPF/CNPJ, e-mail, telefone, endereço), pedidos, dados de contrato de clientes, código-fonte | Alto |
| **Restrito / Crítico** | Máxima proteção; dano grave, legal ou financeiro | Dados bancários e PIX de coprodutores, credenciais de API de terceiros, chaves criptográficas, segredos, hashes de senha, certificados digitais (NF-e), tokens JWT | Severo |

### 4.2. Dados pessoais e dados pessoais sensíveis

- **Dados pessoais (art. 5º, I, LGPD):** nome, CPF/CNPJ, e-mail, telefone e endereço do comprador são classificados **no mínimo como Confidencial**.
- **Dados financeiros:** dados bancários/PIX de coprodutores são classificados como **Restrito/Crítico**. Embora o CPF, isoladamente, não seja "dado sensível" no sentido do art. 5º, II, da LGPD, seu tratamento em massa e o vínculo a dados financeiros elevam o risco e exigem controles de nível Restrito.
- **Dados de menores:** caso identificado tratamento de dados de crianças e adolescentes, aplicam-se as salvaguardas do art. 14 da LGPD; o padrão é **não coletar** e bloquear tais fluxos.

### 4.3. Regras de manuseio por nível

| Ação | Público | Interno | Confidencial | Restrito/Crítico |
|---|---|---|---|---|
| Armazenamento | Livre | Ambiente corporativo | Criptografado (AES-256), RLS | Criptografado, RLS, tokenização/mascaramento, cofre de segredos |
| Transmissão | Livre | TLS | TLS 1.3 obrigatório | TLS 1.3 + minimização + mascaramento |
| Acesso | Todos | Colaboradores | Need to know + RBAC | Need to know + RBAC + MFA + log reforçado |
| Compartilhamento externo | Livre | Autorização gestor | Contrato + DPA | Vedado, salvo exceção formal aprovada |
| Descarte | Livre | Exclusão lógica | Soft-delete + expurgo programado | Exclusão segura + registro de descarte |

### 4.4. Rotulagem
Ativos digitais devem carregar metadados de classificação sempre que tecnicamente viável (por exemplo, tags em buckets do Supabase Storage, campo `metadata` jsonb nas tabelas, cabeçalhos em documentos).

---

## 5. Controle de Acesso e Gestão de Identidades (IAM)

### 5.1. Modelo de identidade
A identidade dos usuários da aplicação é gerida pelo **Supabase Auth**, com emissão de **tokens JWT** e vínculo a `auth.users`. A autorização é implementada em duas camadas complementares e inseparáveis:

1. **RBAC (Role-Based Access Control):** permissões concedidas por papel e recurso, verificadas pela função `app.has_permission('resource.action', company_id)`, com recursos semeados (`master_data, inventory, wms, tms, yms, purchasing, demand, mrp, production, shipping, distribution, controltower, logia, bi, admin`).
2. **RLS (Row Level Security) multi-tenant:** políticas no PostgreSQL que restringem cada operação (SELECT/INSERT/UPDATE/DELETE) ao escopo do usuário, apoiadas nas funções `app.is_superadmin()`, `app.user_tenant_ids()`, `app.user_company_ids()`, `app.can_access_company(uuid)`. **Todo registro carrega `tenant_id` e `company_id`**, e nenhuma leitura retorna dados de outro tenant.

> **Princípio inegociável:** nada confia no frontend. A ausência de um botão ou de uma rota na interface **nunca** é considerada controle de segurança; o controle efetivo é a RLS/RBAC no banco.

### 5.2. Ciclo de vida da identidade (Joiner-Mover-Leaver)
- **Provisionamento (Joiner):** criação de conta mediante solicitação formal e aprovação do gestor, com atribuição de papel de menor privilégio.
- **Alteração (Mover):** mudança de função implica revisão imediata de permissões (revogação do que não é mais necessário).
- **Desprovisionamento (Leaver):** desligamento ou fim de contrato implica **revogação imediata** (idealmente automatizada) de todos os acessos, incluindo tokens, chaves de API e acessos a Supabase, Netlify, repositórios e cofres de segredos.
- **Revisão periódica de acessos (access recertification):** no mínimo **trimestral** para acessos privilegiados e **semestral** para os demais, com evidência documentada.

### 5.3. Autenticação Multifator (MFA)
- **MFA obrigatório** para: contas administrativas do Supabase e da Netlify, acesso a repositórios de código, cofre de segredos, consoles de fornecedores e para qualquer papel com acesso a dados Restrito/Crítico.
- **MFA fortemente recomendado** para todos os produtores/lojistas e coprodutores no acesso ao GLOP, com incentivo à adoção por padrão.
- Fatores aceitos: aplicativo TOTP, chaves de segurança FIDO2/WebAuthn. **SMS é desencorajado** como segundo fator, admitido apenas como fallback.

### 5.4. Gestão de credenciais e senhas
- Senhas de usuários **nunca** são armazenadas em texto claro; são protegidas por **hash com algoritmo forte e salt** (bcrypt/scrypt/Argon2, conforme provido/configurado no Supabase Auth).
- Política mínima: comprimento adequado, verificação contra listas de senhas vazadas, bloqueio progressivo após tentativas falhas, e vedação de reuso.
- **Credenciais de integração de terceiros** (chaves de API de Monetizze, Hotmart, Kiwify, Shopify, WooCommerce, Nuvemshop, Mercado Livre, VHSYS, AppMax, Correios) são armazenadas em modo **write-only**: podem ser gravadas e utilizadas por serviços de backend, mas **não podem ser lidas de volta pela interface** por nenhum usuário. Sua exposição em logs, telas ou respostas de API é vedada; devem ser mascaradas.

### 5.5. Segregação de funções (Separation of Duties)
- Quem desenvolve não aprova o próprio deploy em produção sem revisão de par (ver §7).
- Quem administra o banco não acumula, sem controle compensatório, a função de auditoria dos próprios acessos.
- Operações financeiras críticas (regras de split, repasses a coprodutores) exigem dupla verificação e trilha de auditoria.

### 5.6. Acesso privilegiado (PAM)
- Contas administrativas são nominais (vedadas contas compartilhadas), com MFA, e uso registrado.
- O papel `superadmin` (`app.is_superadmin()`) é concedido a um número mínimo de pessoas, com justificativa formal, e todo uso é logado e monitorado.
- Acessos de emergência ("break-glass") seguem procedimento formal com registro, aprovação posterior e revisão obrigatória.

### 5.7. Sessões
Tokens JWT possuem expiração, rotação de refresh token e revogação em logout/desligamento. Sessões inativas expiram. O portal público de rastreio **não estabelece sessão autenticada** e expõe apenas status neutro do envio, sem qualquer PII sensível (sem CPF, sem endereço, sem telefone).

---

## 6. Criptografia

### 6.1. Criptografia em repouso (data at rest)
- Dados armazenados no banco (Supabase/PostgreSQL) e no Supabase Storage são protegidos por criptografia em repouso de padrão **AES-256** (provida pela infraestrutura do fornecedor de nuvem).
- Dados de nível **Restrito/Crítico** (bancários/PIX de coprodutores, credenciais de API, chaves, certificados NF-e) recebem proteção adicional (tokenização, mascaramento e/ou criptografia em camada de aplicação com chave gerida separadamente).

### 6.2. Criptografia em trânsito (data in transit)
- Toda comunicação externa utiliza **TLS 1.3** (mínimo TLS 1.2 quando 1.3 não estiver disponível na contraparte), com cifras fortes, HSTS habilitado e redirecionamento forçado de HTTP para HTTPS na borda (Netlify).
- Chamadas às APIs de terceiros (Monetizze, Correios, VHSYS, AppMax, checkouts) e webhooks trafegam exclusivamente por canais TLS; conexões sem TLS são bloqueadas.
- Webhooks de entrada são autenticados (assinatura/HMAC ou segredo compartilhado) e validados quanto à origem e integridade antes de processamento.

### 6.3. Gestão e rotação de chaves
- Chaves criptográficas e segredos são armazenados em **cofre de segredos** (variáveis de ambiente protegidas da Netlify/Supabase e/ou gerenciador de segredos dedicado), **nunca** no código-fonte, em repositórios ou em texto claro.
- **Rotação periódica** de chaves e segredos (no mínimo anual, e imediata em caso de suspeita de comprometimento).
- Separação entre chaves de ambientes de produção, homologação e desenvolvimento.
- Certificados digitais para emissão de NF-e (via VHSYS) são custodiados com controle de acesso reforçado e monitoramento de validade.

### 6.4. Hash de senhas e tokens
- Senhas: hash forte com salt (ver §5.4). É **vedado** reversibilizar ou registrar senhas em claro em qualquer log.
- Tokens (JWT, refresh, tokens de webhook) são tratados como segredos e não são logados em texto integral.

### 6.5. Tokenização e mascaramento de PII
- Em telas, relatórios, logs e mensagens, dados como CPF/CNPJ, e-mail, telefone e dados bancários são **mascarados** por padrão (ex.: `***.***.**9-00`), com exibição integral apenas mediante necessidade comprovada e permissão específica.
- Notificações ao comprador (e-mail/WhatsApp de rastreio) contêm o **mínimo** de dados pessoais necessário à finalidade.

---

## 7. Segurança de Aplicações (AppSec)

### 7.1. Ciclo de Desenvolvimento Seguro (S-SDLC)
A segurança é integrada a todas as fases: requisitos → design → codificação → testes → deploy → operação → descomissionamento. Referenciais: **OWASP SAMM**, **NIST SSDF (SP 800-218)**, ISO/IEC 27001 (A.8/A.14).

### 7.2. OWASP Top 10 e ASVS
O desenvolvimento mitiga, no mínimo, as categorias do **OWASP Top 10** vigente, com atenção especial a:
- **A01 Broken Access Control:** endereçado por RLS + RBAC no banco (não no frontend); testes específicos de isolamento **cross-tenant** (garantir que company A jamais leia dados de company B).
- **A02 Cryptographic Failures:** TLS 1.3, AES-256, hash de senhas, mascaramento (§6).
- **A03 Injection:** uso de queries parametrizadas/ORM, validação e sanitização de entrada, incluindo dados vindos de webhooks e pulls de checkout.
- **A04 Insecure Design:** modelagem de ameaças (threat modeling) em funcionalidades sensíveis (pull de PII, split de pagamento, portal público).
- **A05 Security Misconfiguration:** hardening de Supabase/Netlify, RLS habilitado por padrão, revogação de `anon/authenticated` em materialized views para evitar vazamento cross-tenant.
- **A07 Identification & Authentication Failures:** MFA, políticas de senha, gestão de sessão.
- **A08 Software & Data Integrity Failures:** verificação de integridade de webhooks (HMAC), controle de dependências.
- **A09 Security Logging & Monitoring Failures:** trilha de auditoria por triggers (§9).
- **A10 SSRF:** validação de URLs de destino em integrações e webhooks de saída.

### 7.3. Gestão de segredos
Segredos jamais são versionados. Uso de varredura automatizada de segredos (secret scanning) nos repositórios; qualquer segredo exposto é imediatamente rotacionado e o incidente registrado.

### 7.4. Revisão de código e controle de mudanças
- Toda alteração em produção passa por **revisão de código por par (peer review)** e aprovação, com segregação entre autor e aprovador.
- Uso de controle de versão (Git) com histórico auditável; **migrations do Supabase são a fonte da verdade do schema** e seguem o mesmo rito de revisão.
- Proibida a introdução de credenciais, dados reais de produção ou PII em ambientes de teste; dados de teste devem ser sintéticos ou anonimizados.

### 7.5. Testes de segurança
- **SAST** (análise estática) e **SCA** (análise de dependências/composição) integrados ao pipeline de CI/CD.
- **DAST** (análise dinâmica) em homologação para fluxos expostos.
- **Pentest** (teste de intrusão) por terceiro independente, no mínimo **anual** e a cada mudança arquitetural relevante, cobrindo especialmente o isolamento multi-tenant, o portal público de rastreio e as integrações de pagamento/split.
- Correção de achados priorizada por severidade, com SLA definido (ver §10).

### 7.6. Ambientes
Segregação estrita entre produção, homologação e desenvolvimento, com credenciais, chaves e dados distintos. Acesso a produção é restrito e logado.

---

## 8. Segurança de Dados e Privacidade

### 8.1. Minimização (art. 6º, III, LGPD)
O GLOP coleta e trata apenas os dados necessários a cada finalidade: dados do comprador limitados ao imprescindível para faturamento, logística e cumprimento fiscal; dados bancários de coprodutores limitados ao necessário para repasse/split.

### 8.2. Finalidade e adequação (art. 6º, I e II, LGPD)
Como **Operador**, o GLOP trata dados do comprador **estritamente conforme instruções documentadas** do produtor/lojista (Controlador) e para as finalidades do serviço (ingestão de pedido, emissão fiscal, logística, rastreio). É vedado o tratamento para finalidade própria incompatível.

### 8.3. Retenção
- Dados são retidos apenas pelo período necessário à finalidade ou por obrigação legal/regulatória (ex.: guarda de documentos fiscais e registros pelo prazo fiscal aplicável; guarda de registros de acesso a aplicações por **6 meses**, conforme art. 15 do Marco Civil da Internet).
- Períodos de retenção por categoria de dado são definidos em **Tabela de Temporalidade** mantida pelo DPO.

### 8.4. Descarte seguro
- Findo o prazo de retenção ou mediante solicitação legítima de eliminação, os dados são descartados de forma segura.
- Aplica-se **soft-delete** (nunca `DELETE` físico imediato): `deleted_at`, `deleted_by`, `reason_deleted`, com toda leitura filtrando `deleted_at is null`, seguido de **expurgo programado** ao fim da temporalidade.
- O descarte é registrado, garantindo demonstrabilidade (accountability).

### 8.5. Anonimização e pseudonimização
- Para BI, métricas e treinamento de modelos (LOGIA/IA), os dados são preferencialmente **anonimizados ou pseudonimizados**; KPIs são calculados via RPC/materialized views agregadas, com revogação de acesso `anon/authenticated` para não vazar dados cross-tenant.
- Dado efetivamente anonimizado (art. 12, LGPD), sem possibilidade razoável de reversão, deixa de ser dado pessoal.

### 8.6. Direitos dos titulares (arts. 18-22, LGPD)
- O GLOP mantém processo para atender solicitações de titulares (confirmação, acesso, correção, anonimização, portabilidade, eliminação, informação sobre compartilhamento).
- Como **Operador**, o GLOP **redireciona/apoia** o Controlador (produtor/lojista) no atendimento dos pedidos relativos aos compradores, conforme o contrato e o DPA; como **Controlador**, atende diretamente os pedidos de seus usuários e colaboradores.
- Canal do titular: lemoncapsencapsulados@gmail.com.

### 8.7. Transferência internacional
Caso fornecedores/sub-operadores processem dados fora do Brasil, aplicam-se as salvaguardas dos arts. 33 a 36 da LGPD (cláusulas contratuais, adequação, garantias). O uso de Supabase/Netlify deve ser avaliado quanto à localização de processamento e às garantias contratuais correspondentes.

---

## 9. Logging, Trilha de Auditoria e Monitoramento

### 9.1. Trilha de auditoria imutável
- **Toda tabela de negócio** carrega colunas de auditoria: `created_by`, `updated_by`, `deleted_by`, `created_at`, `updated_at`, `deleted_at`, `version`, além de `tenant_id`/`company_id`.
- Os triggers `trg_<t>_touch` (touch de linha) e `trg_<t>_audit` (escrita de auditoria via `app.tg_write_audit()`) registram INSERT/UPDATE/DELETE, produzindo trilha de auditoria.
- A trilha é **append-only / imutável**: registros de auditoria não podem ser alterados nem removidos por usuários da aplicação; alterações são vedadas por política e privilégio.

### 9.2. Logs de segurança e de API
- Logs de acesso, autenticação, autorização negada, chamadas às integrações (Monetizze, Correios, VHSYS, AppMax, checkouts) e webhooks são coletados.
- **PII e segredos são mascarados nos logs** (§6.5); credenciais write-only e tokens **nunca** são logados em claro.
- Registros de acesso a aplicações de internet são mantidos por no mínimo **6 meses** (art. 15, Marco Civil).

### 9.3. Monitoramento, SIEM/SOC e alertas
- Centralização e correlação de eventos (SIEM) e monitoramento contínuo (SOC ou função equivalente, própria ou terceirizada).
- Alertas para: múltiplas falhas de autenticação, tentativas de acesso cross-tenant, picos anômalos de pull de pedidos, exportações incomuns de PII, uso de conta privilegiada, falhas de webhook, e indisponibilidade de integrações críticas.
- Sincronização de relógio (NTP) para consistência forense dos registros.

### 9.4. Integridade e proteção dos logs
Logs são protegidos contra adulteração, com controle de acesso restrito e retenção definida; a alteração indevida de logs é falta grave sujeita a sanção.

---

## 10. Gestão de Vulnerabilidades e Patching

### 10.1. Identificação
- Varredura contínua de vulnerabilidades (infraestrutura, dependências, contêineres/funções, aplicação).
- Monitoramento de avisos de segurança dos fornecedores (Supabase, Netlify, bibliotecas Next.js e demais dependências).
- Canal para recebimento de reportes de segurança (ver §12/§17), com possibilidade de política de divulgação responsável.

### 10.2. Classificação e SLA de correção
Vulnerabilidades são priorizadas por severidade (base CVSS), com prazos-alvo:

| Severidade | Prazo-alvo de correção/mitigação |
|---|---|
| Crítica | 24-72 horas |
| Alta | Até 7 dias |
| Média | Até 30 dias |
| Baixa | Até 90 dias ou próximo ciclo |

### 10.3. Patching
- Atualizações de segurança aplicadas de forma tempestiva, priorizando componentes expostos e que tratam dados Restrito/Crítico.
- Gestão de dependências (SCA) com bloqueio de builds contendo vulnerabilidades críticas conhecidas.
- Mudanças emergenciais de segurança seguem procedimento acelerado com registro posterior.

---

## 11. Backup, Disaster Recovery e Continuidade de Negócios

### 11.1. Backup
- Backups regulares e **criptografados** do banco (Supabase/PostgreSQL) e do Storage, com retenção definida e armazenamento segregado.
- **Teste periódico de restauração** (no mínimo semestral) para validar a recuperabilidade — backup não testado não é backup.
- Aplicação da regra de resiliência (múltiplas cópias, meios/localizações distintos).

### 11.2. Objetivos de recuperação (RTO/RPO)
- **RTO (Recovery Time Objective):** [DEFINIR — sugestão inicial: até 4 horas para serviços críticos].
- **RPO (Recovery Point Objective):** [DEFINIR — sugestão inicial: até 1 hora de perda máxima de dados].
- Valores devem ser homologados pela direção conforme criticidade de cada serviço (ingestão de pedidos, emissão fiscal, rastreio).

### 11.3. Disaster Recovery e Continuidade (ISO 22301)
- Plano de Continuidade de Negócios (PCN) e Plano de Recuperação de Desastres (PRD) documentados, cobrindo indisponibilidade de Supabase, Netlify e integrações críticas (Correios, VHSYS, AppMax, checkouts).
- Procedimentos de failover, comunicação de crise e ativação de contingências.
- **BIA (Business Impact Analysis)** periódica para priorizar processos e recursos.
- Exercícios/testes de continuidade no mínimo anuais.

---

## 12. Resposta a Incidentes de Segurança e Comunicação (LGPD art. 48)

### 12.1. Definição
Considera-se **incidente de segurança** qualquer evento, confirmado ou suspeito, que comprometa a confidencialidade, integridade ou disponibilidade de informações ou sistemas do GLOP, incluindo acesso não autorizado, vazamento, alteração indevida, indisponibilidade relevante, ransomware, exposição de credenciais e falha de isolamento cross-tenant.

### 12.2. Plano de Resposta a Incidentes (IRP) — fases (NIST SP 800-61)
1. **Preparação:** equipe de resposta (CSIRT/time de segurança), papéis, contatos, ferramentas, playbooks.
2. **Detecção e análise:** triagem a partir de alertas (SIEM/SOC), classificação de severidade e escopo (quais dados, quantos titulares, quais tenants/companies).
3. **Contenção:** isolar sistemas/contas afetados, revogar credenciais/tokens, bloquear integrações comprometidas.
4. **Erradicação:** remover a causa raiz (vulnerabilidade, credencial vazada, configuração indevida).
5. **Recuperação:** restaurar serviços a partir de backups íntegros e monitorar reincidência.
6. **Lições aprendidas (pós-incidente):** relatório, correções estruturais e atualização de controles/esta PSI.

### 12.3. Comunicação à ANPD e aos titulares (art. 48, LGPD)
- **Gatilho:** incidente de segurança que **possa acarretar risco ou dano relevante** aos titulares.
- **Prazo:** comunicação à **ANPD** e aos **titulares afetados** em **prazo razoável**, conforme regulamentação da ANPD vigente — parâmetro operacional interno de **até 3 (três) dias úteis** a contar do conhecimento do incidente, salvo prazo distinto fixado em norma da ANPD, que prevalecerá.
- **Conteúdo mínimo da comunicação (art. 48, §1º, LGPD):** descrição da natureza dos dados afetados; informações sobre os titulares envolvidos; medidas técnicas e de segurança adotadas; riscos relacionados; motivos de eventual demora; e medidas que foram ou serão adotadas para reverter ou mitigar os efeitos.
- **Papéis LGPD no incidente:**
  - Se o incidente atingir **dados de compradores** (posição de **Operador**), o GLOP **notifica sem demora o produtor/lojista (Controlador)**, apoia a avaliação de risco e a comunicação, cabendo a comunicação formal à ANPD/titulares conforme divisão de responsabilidades definida no contrato/DPA.
  - Se o incidente atingir **dados de usuários/colaboradores do GLOP** (posição de **Controlador**), o GLOP conduz diretamente a comunicação à ANPD e aos titulares.
- Registro completo de todos os incidentes (inclusive os não comunicáveis) para fins de accountability e eventual requisição da ANPD.

### 12.4. Canal de reporte interno
Qualquer pessoa que identifique ou suspeite de incidente deve reportar **imediatamente** ao time de segurança/DPO por lemoncapsencapsulados@gmail.com. A omissão de reporte é falta disciplinar.

---

## 13. Segurança de Fornecedores e Sub-operadores

### 13.1. Princípio
O GLOP responde pela segurança da cadeia de fornecimento e adota diligência (due diligence) na contratação e no monitoramento de fornecedores que tratam ou hospedam informações, especialmente os **sub-operadores** de dados pessoais.

### 13.2. Sub-operadores e fornecedores críticos

| Fornecedor | Função | Dados envolvidos | Exigências mínimas |
|---|---|---|---|
| **Supabase** | Banco (PostgreSQL), Auth, Storage, Edge Functions | Todos os dados da aplicação, PII, credenciais | DPA, criptografia em repouso/trânsito, isolamento, avaliação de localização de dados |
| **Netlify** | Hospedagem SSR (frontend/borda) | Tráfego, variáveis de ambiente/segredos | TLS 1.3, proteção de variáveis, DPA |
| **VHSYS** | Emissão de NF-e e documentos fiscais | Dados fiscais, PII do comprador, certificado digital | Contrato, segurança do certificado, TLS |
| **Correios** | Pré-postagem (PPN) e rastreio (SRO) | Nome, endereço do comprador, código de rastreio | Uso conforme finalidade logística, TLS |
| **AppMax** | Split de pagamento/repasses | Dados de PIX/bancários de coprodutores, valores | Conformidade de meios de pagamento, TLS, contrato |
| **Monetizze / Hotmart / Kiwify / Shopify / WooCommerce / Nuvemshop / Mercado Livre** | Origem dos pedidos (checkout/e-commerce) | PII do comprador, pedido, valor | Autenticação de API, webhooks assinados, TLS |

### 13.3. Requisitos contratuais
- **DPA / cláusulas de proteção de dados** (arts. 39 e 46, LGPD) com todo sub-operador, incluindo obrigação de sigilo, notificação de incidentes, restrição de finalidade e permissão de auditoria.
- Autorização e transparência quanto à cadeia de sub-operadores perante os Controladores (produtores/lojistas).
- Cláusulas de segurança, SLA, direito de auditoria e obrigações em caso de término (devolução/eliminação de dados).

### 13.4. Monitoramento
Avaliação periódica de postura de segurança dos fornecedores (certificações ISO 27001/SOC 2, relatórios de conformidade, avisos de incidentes) e reavaliação em caso de incidente relevante na cadeia.

---

## 14. Segurança de Endpoints e de Pessoas

### 14.1. Endpoints
- Estações de trabalho e dispositivos com acesso a dados corporativos devem ter: sistema atualizado, disco criptografado, antimalware ativo, firewall, bloqueio automático de tela e proteção por senha/biometria + MFA para acesso a sistemas.
- Vedado o armazenamento local não autorizado de PII ou dados Restrito/Crítico.
- Dispositivos móveis com acesso corporativo seguem controles equivalentes (MDM quando aplicável).

### 14.2. Rede e acesso remoto
Acesso remoto a recursos administrativos apenas por canais seguros (TLS/VPN quando aplicável), sob Zero Trust — cada acesso reautenticado e autorizado.

### 14.3. Pessoas — conscientização e cultura
- **Termo de confidencialidade (NDA)** e ciência desta PSI por todos os colaboradores e prestadores no ingresso.
- **Treinamento de conscientização** em segurança e privacidade no onboarding e **reciclagem anual**, cobrindo phishing, engenharia social, manuseio de PII, senhas/MFA e reporte de incidentes.
- Campanhas periódicas e testes simulados de phishing.
- **Política de mesa limpa e tela limpa** (clean desk/clean screen).

---

## 15. Conformidade e Exceções

### 15.1. Conformidade
- O cumprimento desta PSI é obrigatório e verificado por auditorias internas periódicas e, quando aplicável, externas.
- A área de segurança/DPO mantém o mapa de conformidade honesto (✅ pronto / 🟡 parcial / 🔴 roadmap), sendo **vedado** declarar como implementado (✅) qualquer controle que esteja em estágio parcial (🟡) ou apenas planejado (🔴).
- Referenciais de auditoria: ISO/IEC 27001/27701, NIST CSF, CIS Controls v8, OWASP, LGPD.

### 15.2. Exceções
- Qualquer exceção a esta Política deve ser **formalmente solicitada, justificada, avaliada quanto ao risco e aprovada** pela alçada competente (CISO/segurança e, para riscos altos, direção/DPO).
- Exceções são **temporárias**, registradas em inventário de exceções, com prazo de validade, controle compensatório e reavaliação obrigatória.
- Nenhuma exceção pode violar a LGPD ou obrigações legais/contratuais.

---

## 16. Papéis e Responsabilidades

| Papel | Responsabilidades principais |
|---|---|
| **Direção / Administradores** | Patrocinar e aprovar a PSI, prover recursos, prestar contas (accountability art. 50 LGPD), assumir o risco residual. |
| **CISO / Responsável de Segurança** | Governar o SGSI, manter e revisar a PSI, coordenar riscos, vulnerabilidades, incidentes e auditorias. |
| **Encarregado/DPO (a ser designado pela administração)** | Ser canal com titulares e ANPD (art. 41, LGPD), orientar sobre privacidade, conduzir comunicação de incidentes, manter RIPD/registros. |
| **DevOps / Administradores de sistema** | Implementar e operar controles técnicos (RLS, MFA, criptografia, backup, monitoramento, hardening de Supabase/Netlify). |
| **Desenvolvedores** | Aplicar S-SDLC, OWASP, revisão de código, gestão de segredos, RLS/RBAC em cada tabela e rota. |
| **Time de Resposta a Incidentes (CSIRT)** | Executar o IRP: detecção, contenção, erradicação, recuperação e lições aprendidas. |
| **Gestores de área** | Aprovar acessos, garantir treinamento e observância pela equipe. |
| **Todos os colaboradores/prestadores** | Cumprir a PSI, proteger credenciais, reportar incidentes, manter sigilo. |
| **Produtores/lojistas (clientes/Controladores)** | Definir finalidades do tratamento dos compradores, custodiar suas credenciais, atender titulares no que lhes cabe. |
| **Fornecedores/sub-operadores** | Cumprir cláusulas contratuais/DPA, notificar incidentes, manter controles equivalentes. |

---

## 17. Sanções

17.1. O descumprimento desta Política sujeita o infrator a medidas proporcionais à gravidade, à intenção e ao dano, sem prejuízo das responsabilidades civil, criminal e administrativa:

- **Colaboradores/estagiários:** medidas disciplinares na forma da CLT e do regulamento interno — advertência, suspensão e, em faltas graves, **dispensa por justa causa** (art. 482 da CLT), especialmente em casos de violação de sigilo, acesso indevido a PII, vazamento ou adulteração de logs.
- **Prestadores/terceiros/fornecedores:** aplicação das penalidades contratuais, incluindo multa, suspensão e **rescisão por justa causa**, além de responsabilização por perdas e danos.
- **Usuários da plataforma (produtores/coprodutores):** suspensão ou encerramento de acesso conforme os Termos de Uso, sem prejuízo de responsabilização.

17.2. Condutas dolosas que resultem em vazamento, fraude no split/repasses, uso indevido de credenciais de terceiros ou dano a titulares poderão configurar ilícitos previstos no **Código Penal** (ex.: art. 154-A — invasão de dispositivo informático), na **LGPD** e no **Marco Civil**, ensejando comunicação às autoridades competentes.

17.3. A aplicação de sanções observa o contraditório e a ampla defesa, com registro formal.

---

## Engenharia Jurídica & Governança

### (a) Fundamentação — por que as cláusulas existem e qual norma as embasa

- **Objetivo, escopo e princípios (§§1-3):** materializam o dever de adotar medidas de segurança "aptas a proteger os dados pessoais" do **art. 46 da LGPD** e a **segurança/prevenção** dos **incisos VII e VIII do art. 6º**. Security by Design e by Default espelham o **art. 46, §2º da LGPD** e o **art. 25 do GDPR**. Os princípios de Least Privilege, Need to Know, Defense in Depth e Zero Trust são a tradução operacional dos controles de acesso da **ISO/IEC 27001 (Anexo A)**, do **NIST CSF (funções Protect/Detect)** e do **CIS Controls v8**.
- **Classificação da informação (§4):** decorre do dever de tratar dado conforme sua criticidade (**ISO/IEC 27002**) e da distinção legal entre dado pessoal, sensível (**art. 5º, I e II, LGPD**) e não pessoal, orientando proporcionalidade de controles.
- **IAM, RBAC/RLS, MFA e segregação (§5):** concretizam o **art. 46 e art. 6º, VII, da LGPD** e o controle de acesso da ISO 27001; o isolamento multi-tenant por RLS previne acesso cross-tenant, endereçando **OWASP A01 (Broken Access Control)** e o dever de confidencialidade.
- **Criptografia (§6):** o **art. 46, caput, da LGPD** e o **Guia de Segurança da ANPD** recomendam criptografia e pseudonimização; AES-256 e TLS 1.3 são padrões de mercado que sustentam a demonstração de adequação.
- **AppSec / S-SDLC (§7):** operacionaliza segurança preventiva (**NIST SSDF SP 800-218**, **OWASP SAMM/ASVS/Top 10**), reduzindo a superfície de falhas que poderiam configurar tratamento inseguro (art. 44, parágrafo único, LGPD — tratamento irregular por falta de segurança esperada).
- **Dados e privacidade (§8):** aplica minimização, finalidade, adequação e necessidade (**art. 6º, I, II, III, LGPD**), retenção e eliminação (**art. 15 e 16, LGPD**), direitos do titular (**arts. 18-22**) e anonimização (**arts. 5º, XI e 12**). A retenção de logs por 6 meses observa o **art. 15 do Marco Civil (Lei 12.965/2014)**.
- **Logging e auditoria imutável (§9):** sustenta a **accountability (art. 6º, X, e art. 50, LGPD)** e a rastreabilidade exigida em auditorias e requisições da ANPD; endereça **OWASP A09**.
- **Vulnerabilidades e patching (§10):** dever de manter a segurança ao longo do tempo (art. 46/50 LGPD; ISO 27001 A.8; CIS Controls 7).
- **Backup, DR e continuidade (§11):** disponibilidade é pilar da segurança (art. 46 LGPD) e objeto da **ISO/IEC 22301**; RTO/RPO tornam mensurável a resiliência.
- **Resposta a incidentes e comunicação (§12):** cumpre o **art. 48 da LGPD** e a regulamentação da ANPD sobre comunicação de incidentes, além do **NIST SP 800-61**; a dualidade Operador/Controlador reflete os **arts. 5º VI/VII, 39 e 42-45 da LGPD**.
- **Fornecedores/sub-operadores (§13):** decorre da responsabilidade solidária/subsidiária e do dever de diligência na cadeia (**arts. 42 a 44 e 46, LGPD**), exigindo DPA com Supabase, Netlify, VHSYS, Correios e AppMax.
- **Endpoints e pessoas (§14):** o fator humano é vetor primário de incidentes; treinamento e NDA endereçam **ISO 27001 A.6/A.7** e o dever de segurança organizacional.
- **Conformidade, exceções, papéis e sanções (§§15-17):** estruturam governança e enforcement, ancorados no **poder diretivo do empregador (arts. 2º e 482 da CLT)**, na liberdade contratual (**Código Civil, arts. 421 e 422**), nos Termos de Uso (relação de consumo — **CDC**) e na tipificação penal correlata (**art. 154-A do Código Penal**).

### (b) Riscos que o documento mitiga

- Vazamento de PII do comprador (pull Monetizze/checkouts) e de dados bancários/PIX de coprodutores (split AppMax).
- Acesso cross-tenant (um Controlador enxergar dados de outro) por falha de RLS/RBAC.
- Exposição de credenciais de API de terceiros e segredos em código, logs ou telas.
- Sanções da ANPD (art. 52, LGPD: advertência, multa até 2% do faturamento limitada a R$ 50 milhões por infração, publicização, bloqueio/eliminação de dados).
- Responsabilização civil por danos a titulares e ações consumeristas (CDC).
- Indisponibilidade de serviços críticos (emissão fiscal, rastreio) sem plano de recuperação.
- Comunicação intempestiva de incidente à ANPD/titulares (descumprimento do art. 48).
- Risco de cadeia de fornecimento (incidente em Supabase/Netlify/VHSYS/Correios/AppMax) sem DPA e sem plano.
- Fraude interna em repasses/split por ausência de segregação de funções e auditoria.

### (c) Checklist de implementação

1. Aprovar formalmente a PSI pela direção e registrar vigência (16 de julho de 2026).
2. Nomear formalmente o Encarregado/DPO e publicar o canal lemoncapsencapsulados@gmail.com.
3. Confirmar RLS habilitada em 100% das tabelas de `public` e testar isolamento cross-tenant.
4. Ativar e exigir MFA em Supabase, Netlify, repositórios e cofre de segredos.
5. Migrar todos os segredos e credenciais write-only para cofre; remover segredos do código; ativar secret scanning.
6. Confirmar AES-256 em repouso e TLS 1.3 na borda (Netlify); habilitar HSTS.
7. Validar mascaramento de PII em telas, logs e notificações de rastreio; confirmar que o portal público expõe só status neutro.
8. Assinar/atualizar DPA com Supabase, Netlify, VHSYS, Correios, AppMax e plataformas de checkout.
9. Definir e homologar Tabela de Temporalidade, RTO/RPO e testar restauração de backup.
10. Publicar e testar o Plano de Resposta a Incidentes e o fluxo de comunicação à ANPD (≤ prazo regulatório).
11. Integrar SAST/SCA/DAST ao CI/CD e contratar pentest anual com foco multi-tenant.
12. Realizar treinamento de conscientização e coletar NDAs de todos os colaboradores/prestadores.
13. Configurar SIEM/alertas e revisar acessos privilegiados trimestralmente.
14. Elaborar o RIPD (Relatório de Impacto à Proteção de Dados) dos fluxos de maior risco (pull de PII, split, portal público).

### (d) Matriz RACI

**Legenda:** R = Responsável (executa) · A = Aprovador (responde) · C = Consultado · I = Informado

| Atividade / Processo | Direção | CISO/Segurança | DPO/Encarregado | DevOps | Devs | Jurídico |
|---|---|---|---|---|---|---|
| Aprovar e patrocinar a PSI | A | R | C | I | I | C |
| Manter RLS/RBAC multi-tenant | I | A | C | R | R | I |
| Gestão de MFA e acessos privilegiados | I | A | I | R | C | I |
| Criptografia e gestão de chaves | I | A | C | R | C | I |
| S-SDLC, revisão de código e pentest | I | A | I | C | R | I |
| Minimização, retenção e descarte | I | C | A | R | C | C |
| Trilha de auditoria e monitoramento (SIEM) | I | A | C | R | C | I |
| Vulnerabilidades e patching | I | A | I | R | C | I |
| Backup, DR e continuidade (RTO/RPO) | A | C | I | R | I | I |
| Resposta a incidentes | A | R | C | R | C | C |
| Comunicação à ANPD e titulares (art. 48) | A | C | R | I | I | C |
| Gestão de sub-operadores e DPA | A | C | R | C | I | R |
| Treinamento e conscientização | I | C | R | I | I | C |
| Conformidade, exceções e sanções | A | R | C | I | I | R |

### (e) Plano de revisão

- **Periodicidade ordinária:** revisão integral **anual**.
- **Gatilhos de revisão extraordinária:**
  - Alteração legislativa/regulatória (nova resolução da ANPD, mudança na LGPD/Marco Civil/CDC);
  - Incidente de segurança relevante ou requisição da ANPD;
  - Mudança arquitetural significativa (novo sub-operador, nova integração de checkout/pagamento, migração de infraestrutura);
  - Resultado de auditoria, pentest ou avaliação de risco que aponte lacuna;
  - Lançamento de novo módulo que trate dados pessoais (ex.: novos fluxos de PII ou financeiros).
- **Responsável pela condução:** CISO/Segurança com o DPO; aprovação pela Direção.

### (f) Controle de versão

| Versão | Data | Autor | Mudança |
|---|---|---|---|
| 1.0 | 16 de julho de 2026 | Chief Legal AI (minuta) | Emissão inicial da Política de Segurança da Informação do GLOP, alinhada a ISO 27001/27701, NIST CSF, OWASP, CIS Controls e LGPD; pendente de revisão por advogado(a) habilitado(a). |

---

*Documento de propriedade de LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA — [NOME FANTASIA: GLOP]. Classificação: Interno — Uso Restrito. A distribuição não autorizada é vedada. Dúvidas: lemoncapsencapsulados@gmail.com.*
