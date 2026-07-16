> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# Política de Senhas e Autenticação — GLOP (Global Logistics Platform)

**Controlador / Editor da Política:** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, inscrita no CNPJ sob o nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, operadora da plataforma [NOME FANTASIA: GLOP].
**Encarregado pelo Tratamento de Dados Pessoais (DPO):** a ser designado pela administração — contato: lemoncapsencapsulados@gmail.com.
**Classificação do documento:** Interno — Confidencial (aplicável a colaboradores, prestadores e usuários da plataforma).
**Versão:** 1.0 · **Data de emissão:** 16 de julho de 2026 · **Próxima revisão:** 16 de julho de 2026.

---

## 1. Objetivo

1.1. Esta Política de Senhas e Autenticação (a "Política") estabelece as regras obrigatórias de **credenciais, autenticação, autorização e gestão do ciclo de vida de identidades** aplicáveis ao acesso ao GLOP — Global Logistics Platform, plataforma SaaS de logística e ERP voltada a operações de dropshipping e infoprodutos no Brasil, construída sobre Next.js (App Router) e Supabase (PostgreSQL) com Row Level Security (RLS) multi-tenant.

1.2. A Política visa a:

- a) proteger a **confidencialidade, integridade e disponibilidade** dos dados tratados no GLOP, com destaque para os dados pessoais do **comprador final** (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor), tratados pelo GLOP na qualidade de **Operador**, em nome do produtor/lojista **Controlador**;
- b) proteger os dados pessoais dos **próprios usuários, colaboradores e prestadores** do GLOP, tratados na qualidade de **Controlador**;
- c) reduzir o risco de acesso não autorizado, sequestro de conta (account takeover), vazamento de dados, fraude em split/repasses financeiros e comprometimento de credenciais de integração com sub-operadores (Supabase, Netlify, VHSYS, Correios, Monetizze, AppMax, Hotmart, Kiwify, provedores de WhatsApp e e-mail);
- d) demonstrar **conformidade** com a Lei nº 13.709/2018 (LGPD), especialmente seu art. 46 (medidas de segurança, técnicas e administrativas), e com as normas técnicas de referência (ISO/IEC 27001, 27701, 27002, NIST SP 800-63B, OWASP ASVS).

1.3. Esta Política é **complementar** à Política de Segurança da Informação, à Política de Privacidade, ao Acordo de Tratamento de Dados (DPA) e aos Termos de Uso do GLOP, com os quais deve ser lida de forma harmônica. Em caso de conflito aparente, prevalece a regra **mais restritiva** em favor da proteção dos dados.

---

## 2. Escopo e Abrangência

2.1. **Abrangência subjetiva.** Esta Política vincula:

- a) **colaboradores** (empregados e estagiários) de LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA;
- b) **prestadores de serviço, terceiros e consultores** com acesso a qualquer ambiente do GLOP;
- c) **usuários da plataforma** — produtores, lojistas, coprodutores, afiliados e seus operadores — quanto às contas de acesso ao painel multi-tenant;
- d) **administradores técnicos** (superadmin, DevOps, engenharia) com acesso a Supabase, Netlify, repositórios, segredos e infraestrutura;
- e) **contas de serviço / não humanas** (service accounts, chaves de API, tokens de integração, cron jobs, Edge Functions).

2.2. **Abrangência objetiva.** A Política se aplica a **todo mecanismo de autenticação e autorização** do ecossistema GLOP, incluindo, sem limitação:

- a) autenticação de usuários via **Supabase Auth (JWT)** sobre a tabela auth.users;
- b) controle de acesso via **RLS** (isolamento por empresa/company_id) e **RBAC** (função app.has_permission, papéis de Membership na hierarquia Tenant → Company → Branch);
- c) **credenciais de API** dos sub-operadores e gateways armazenadas de forma **write-only** (segredo inserido, nunca relido pela aplicação nem exibido em tela);
- d) tokens de sessão, refresh tokens, chaves de recuperação e fatores de MFA/passkeys;
- e) o **Portal Público de Rastreio** (sem login), cujo endpoint expõe apenas status neutro e não realiza autenticação de comprador — sujeito às vedações específicas do item 12.

2.3. **Não abrangência.** A senha e as credenciais dos serviços dos sub-operadores permanecem sujeitas também às políticas próprias de cada fornecedor; esta Política estabelece o **piso mínimo** de segurança exigido pelo GLOP, que nunca poderá ser reduzido por acordo com terceiros.

---

## 3. Definições

- **Autenticação:** processo de comprovação da identidade alegada por um sujeito (usuário ou serviço).
- **Autorização:** determinação do que uma identidade autenticada pode fazer (RBAC + RLS).
- **MFA (Autenticação Multifator):** exigência de dois ou mais fatores independentes — algo que se sabe (senha), algo que se tem (dispositivo/token/passkey), algo que se é (biometria).
- **Passkey (WebAuthn/FIDO2):** credencial criptográfica resistente a phishing, baseada em par de chaves assimétricas vinculado ao domínio, sem segredo compartilhado transmitido.
- **Hash de senha:** transformação criptográfica unidirecional de senha em resumo, com sal (salt) único, por algoritmo de derivação de chave com custo computacional deliberado.
- **Credencial write-only:** segredo (chave/token de API) que, uma vez armazenado cifrado, **não é relido** pela aplicação nem exibido; usado apenas em memória no momento da chamada ao sub-operador, jamais devolvido ao frontend.
- **JWT (JSON Web Token):** token de sessão emitido pelo Supabase Auth, portador das claims de identidade e do escopo de acesso.
- **Sub-operador:** terceiro contratado que trata dados por conta do GLOP (Supabase, Netlify, VHSYS, Correios, gateways, provedores de mensageria).
- **Account takeover (ATO):** apropriação indevida de conta legítima por terceiro.
- **Superadmin:** papel técnico de máximo privilégio (app.is_superadmin()), sujeito às regras reforçadas do item 8.

---

## 4. Princípios Norteadores

4.1. **Nada confia no frontend.** Toda decisão de autenticação e autorização é validada no backend (Supabase/RLS/RBAC). O frontend nunca é fonte de verdade de identidade ou permissão.

4.2. **Menor privilégio (least privilege).** Cada identidade recebe o mínimo de acesso necessário à sua função, pelo menor tempo necessário.

4.3. **Defesa em profundidade.** Senha forte, MFA, RLS, RBAC, auditoria por triggers, soft-delete e credenciais write-only atuam em camadas independentes e cumulativas.

4.4. **Segurança e privacidade desde a concepção (privacy/security by design and by default).** Controles habilitados por padrão; configuração insegura exige exceção formal e justificada.

4.5. **Segregação de funções (segregation of duties).** Quem concede acesso não é, em regra, quem audita; quem desenvolve não detém, sozinho, chaves de produção.

4.6. **Isolamento multi-tenant.** A separação entre empresas (tenants) é garantida por RLS no banco, jamais apenas pela camada de aplicação; nenhuma credencial pode permitir travessia horizontal entre companies não autorizadas.

4.7. **Auditabilidade.** Todo evento relevante de autenticação e de acesso é registrado em trilha de auditoria imutável (triggers de auditoria e colunas de auditoria em cada registro).

---

## 5. Política de Senhas

### 5.1. Complexidade e composição

5.1.1. **Comprimento mínimo.** As senhas de usuários e colaboradores devem ter, no mínimo, **12 (doze) caracteres**. Para papéis privilegiados (superadmin, DevOps, administradores de empresa), o mínimo é de **16 (dezesseis) caracteres**.

5.1.2. **Comprimento máximo.** Deve ser suportado comprimento de, no mínimo, **64 caracteres**, permitindo o uso de frases-senha (passphrases). É vedado truncar silenciosamente a senha.

5.1.3. **Conjunto de caracteres.** Devem ser aceitos letras maiúsculas e minúsculas, dígitos, espaços e caracteres especiais/Unicode. Alinhado ao NIST SP 800-63B, **não se exige** obrigatoriedade rígida de composição (ex.: "1 maiúscula + 1 número + 1 símbolo"); privilegia-se **comprimento e imprevisibilidade**. Contudo, o GLOP recomenda fortemente a mistura de tipos e a adota como **default** no medidor de força.

5.1.4. **Verificação contra senhas vazadas e fracas.** No cadastro e na troca de senha, a candidata deve ser confrontada contra:

- a) listas de senhas comprometidas / vazadas (breached passwords), preferencialmente via verificação com privacidade (k-anonymity), sem transmitir a senha em claro;
- b) dicionário de senhas comuns e sequências óbvias (ex.: "123456", "senha", "qwerty");
- c) informações contextuais do usuário (nome, e-mail, nome da empresa, nome do produto), que não podem compor a senha;
- d) repetições e sequências triviais (ex.: "aaaaaa", "abcabc").

Senha reprovada deve ser rejeitada com orientação clara, sem revelar regras que facilitem enumeração.

### 5.2. Rotação de senhas

5.2.1. **Rotação por evento, não por calendário.** Alinhado ao NIST SP 800-63B e à ISO/IEC 27002, **não se impõe** expiração periódica compulsória de senha de usuário quando há senha forte + MFA, pois a rotação forçada tende a produzir senhas mais fracas. A troca é **obrigatória** nas seguintes hipóteses:

- a) suspeita ou confirmação de comprometimento da conta ou da senha;
- b) inclusão da senha em base de vazamento identificada;
- c) primeiro acesso e acessos com senha temporária;
- d) desligamento/rotatividade de membro de equipe com quem a senha possa ter sido compartilhada (o que, de todo modo, é vedado — item 13);
- e) determinação do time de Segurança em resposta a incidente.

5.2.2. **Papéis privilegiados.** Para superadmin e contas de infraestrutura sem passkey, admite-se rotação periódica reforçada a cada **90 (noventa) dias**, sem prejuízo da rotação por evento.

5.2.3. **Histórico.** É vedada a reutilização das últimas **5 (cinco)** senhas. A troca de senha invalida todas as sessões ativas e refresh tokens, exigindo reautenticação.

### 5.3. Recuperação e redefinição de senha

5.3.1. A recuperação de senha ocorre por **link de uso único, de curta validade (máximo 60 minutos)**, enviado ao e-mail cadastrado, via fluxo nativo do Supabase Auth, sem jamais transmitir a senha atual ou nova por e-mail/WhatsApp em texto claro.

5.3.2. As mensagens de erro dos fluxos de login e recuperação devem ser **neutras** ("credenciais inválidas"), sem revelar se o e-mail existe (proteção contra enumeração de contas).

5.3.3. A redefinição bem-sucedida gera evento de auditoria e notificação ao titular ("sua senha foi alterada"), com canal para contestação em caso de não reconhecimento.

### 5.4. Armazenamento e hash seguro

5.4.1. **Proibição absoluta de texto claro.** Senhas **jamais** são armazenadas, registradas em log, versionadas em repositório, incluídas em URL, exibidas em tela após digitação ou trafegadas fora de canal TLS.

5.4.2. **Algoritmo de hash.** O armazenamento de senhas é delegado ao **Supabase Auth**, que utiliza algoritmo de hash com sal único por credencial e custo computacional adequado (função de derivação de chave resistente a força bruta e a GPU, da família **bcrypt/scrypt/Argon2**, conforme provisionado pelo provedor). Parâmetros de custo devem ser revistos periodicamente para acompanhar a evolução do poder computacional.

5.4.3. **Sal e pimenta.** Cada senha possui **sal (salt) único e aleatório**. Segredos adicionais de servidor (pepper), quando aplicáveis, são mantidos fora da base de dados de senhas.

5.4.4. **Comparação em tempo constante.** A verificação de senhas e de tokens sensíveis deve empregar comparação resistente a ataques de temporização (timing-safe).

5.4.5. **TLS obrigatório.** Toda autenticação ocorre exclusivamente sobre HTTPS/TLS; conexões não cifradas são rejeitadas.

---

## 6. Autenticação Multifator (MFA) e Passkeys

6.1. **Exigência de MFA.** O MFA é **obrigatório** para:

- a) todos os papéis privilegiados: superadmin, DevOps/engenharia com acesso a produção, administradores de empresa (company admin) e qualquer papel com permissão de escrita sobre dados financeiros (split, repasses, dados de PIX/bancários de coprodutores e afiliados);
- b) acesso aos consoles de infraestrutura (Supabase, Netlify), repositórios de código e cofres de segredos;
- c) operações sensíveis (step-up authentication): alteração de dados bancários/PIX de repasse, exportação em massa de PII de compradores, alteração de credenciais de integração, concessão/elevação de permissões.

6.2. **MFA para usuários gerais.** O MFA é **fortemente recomendado e disponibilizado por padrão** a todos os usuários da plataforma, com incentivo ativo à adesão. Poderá tornar-se obrigatório por decisão do Controlador para operações de maior risco.

6.3. **Fatores aceitos**, em ordem de preferência:

1. **Passkeys (WebAuthn/FIDO2)** — método preferencial por serem **resistentes a phishing**; recomendadas para papéis privilegiados sempre que suportadas pelo dispositivo.
2. **Aplicativos autenticadores TOTP** (RFC 6238), com segredo provisionado e armazenado de forma cifrada.
3. **Chaves de segurança físicas** (FIDO2/U2F).

6.4. **Fatores desencorajados.** O **SMS** e a ligação telefônica são **desencorajados** como segundo fator (risco de SIM swap e interceptação), admitidos apenas como fallback transitório e nunca como único MFA de papel privilegiado. O e-mail não é considerado segundo fator independente quando é também o canal de recuperação.

6.5. **Códigos de recuperação (backup codes).** No cadastro do MFA, são gerados códigos de recuperação de uso único, exibidos **uma única vez**, que o usuário deve guardar em local seguro. Seu uso é auditado e, quando exauridos ou expostos, exige regeneração.

6.6. **Anti-automação.** Fluxos de login, cadastro, recuperação e MFA são protegidos por limitação de taxa (rate limiting), detecção de bot e, quando necessário, desafio (CAPTCHA), sem prejuízo do item 7.

---

## 7. Bloqueio por Tentativas e Proteção contra Abuso

7.1. **Limitação de taxa.** Tentativas de autenticação são limitadas por **conta, por IP e por dispositivo**, com contadores independentes para dificultar tanto ataques direcionados quanto pulverizados (password spraying).

7.2. **Bloqueio progressivo (throttling).** Após **5 (cinco)** tentativas malsucedidas consecutivas na mesma conta, aplica-se atraso incremental (backoff exponencial). Após **10 (dez)** tentativas, a conta entra em **bloqueio temporário de, no mínimo, 15 (quinze) minutos**, prorrogável progressivamente.

7.3. **Antienumeração.** Mensagens de erro são neutras; o tempo de resposta é normalizado para não revelar existência de conta.

7.4. **Detecção de anomalias.** Acessos de geolocalização/dispositivo/horário atípicos podem disparar **step-up authentication** (novo fator), notificação ao titular e, conforme severidade, bloqueio preventivo e abertura de incidente.

7.5. **Proteção contra credential stuffing.** Combina-se verificação de senhas vazadas (item 5.1.4), MFA e monitoramento de picos de falha de login como indicadores de ataque por reutilização de credenciais.

7.6. **Desbloqueio.** O desbloqueio ocorre por decurso do prazo, por fluxo seguro de recuperação (item 5.3) ou por ação do Suporte/Segurança mediante verificação de identidade documentada e auditada.

7.7. **Registro.** Todo bloqueio, desbloqueio, sucesso e falha de autenticação gera evento na trilha de auditoria (item 11), preservado pelo prazo definido em política de retenção.

---

## 8. Autenticação e Autorização no Supabase (Arquitetura GLOP)

8.1. **Provedor de identidade.** A autenticação de usuários é realizada pelo **Supabase Auth**, com emissão de **JWT** sobre a tabela auth.users. O GLOP não implementa mecanismo paralelo de senha próprio.

8.2. **Sessões e tokens.**

- a) Os **access tokens (JWT)** têm vida curta; a renovação ocorre por **refresh token** com rotação e detecção de reuso (reuse detection), invalidando a cadeia em caso de reutilização suspeita.
- b) Tokens são armazenados no cliente de forma segura conforme melhores práticas do @supabase/ssr (cookies HttpOnly/Secure/SameSite no contexto SSR do Next.js), nunca em local acessível a scripts de terceiros de forma indevida.
- c) O **logout** e a troca de senha revogam sessões e refresh tokens.

8.3. **Autorização em duas camadas.**

- a) **RLS (Row Level Security):** habilitada em todas as tabelas do schema public; o isolamento por empresa se dá por company_id e pelas funções de apoio do schema app (app.is_superadmin(), app.user_tenant_ids(), app.user_company_ids(), app.can_access_company(uuid), app.has_permission('recurso.acao', company_id)).
- b) **RBAC (Role-Based Access Control):** as permissões são verificadas por app.has_permission sobre recursos semeados (master_data, inventory, wms, tms, yms, purchasing, demand, mrp, production, shipping, distribution, controltower, logia, bi, admin), respeitando a hierarquia Tenant → Company → Branch → Membership.

8.4. **Vedação de escalonamento.** Nenhum papel, exceto processos legítimos e auditados, pode invocar funções security definer do schema app para elevar privilégios. A concessão de superadmin é excepcional, nominal, temporária quando possível, e sempre auditada.

8.5. **Reforços para superadmin e infraestrutura.**

- a) MFA obrigatório (passkey preferencial);
- b) acesso just-in-time e/ou break-glass documentado para operações emergenciais, com revisão posterior;
- c) revisão trimestral de quem detém o papel;
- d) segregação entre credenciais de desenvolvimento e de produção.

8.6. **Chaves de serviço do Supabase.** A **service_role key** e demais segredos de servidor:

- a) nunca são expostos ao frontend nem embarcados em código cliente;
- b) residem apenas em variáveis de ambiente do servidor (Netlify) / cofre de segredos;
- c) são tratados como credenciais de altíssimo privilégio, com rotação e auditoria de uso.

---

## 9. Gestão de Credenciais de API (Write-Only) e Integrações

9.1. **Modelo write-only.** As credenciais de integração com sub-operadores e gateways — **VHSYS (NF-e), Correios (PPN/SRO), Monetizze, AppMax, Hotmart, Kiwify, Shopify, WooCommerce, Nuvemshop, Mercado Livre, provedores de WhatsApp e e-mail** — são armazenadas em modelo **write-only**:

- a) o segredo é **inserido cifrado** pelo usuário/empresa;
- b) **nunca é relido** pela aplicação para exibição, nem devolvido ao frontend em qualquer resposta de API;
- c) é utilizado apenas **em memória, no lado servidor**, no instante exato da chamada ao sub-operador;
- d) na interface, o campo mostra apenas estado ("configurada" / "não configurada") e, no máximo, um sufixo mascarado, jamais o valor íntegro.

9.2. **Cifragem em repouso.** Segredos de integração são cifrados em repouso; a chave de cifragem é gerida fora da tabela de segredos e sujeita a rotação. O acesso ao segredo em claro é restrito a processos de servidor estritamente necessários, e cada uso é auditado (item 11).

9.3. **Escopo mínimo e chaves dedicadas.** Cada integração usa credencial de **menor escopo possível** e, quando o provedor permitir, **chave dedicada ao GLOP** (não compartilhada com outros sistemas do cliente). Recomenda-se, quando disponível, credenciais somente-leitura para ingestão e credenciais separadas para operações de escrita.

9.3.1. **Autenticação em duas etapas de gateways.** Onde o provedor exigir handshake em múltiplas etapas (ex.: Monetizze — troca de X_CONSUMER_KEY por TOKEN antes das chamadas a /transactions), a etapa de troca ocorre exclusivamente no servidor, e o token derivado segue o mesmo regime write-only e de cifragem deste item 9.

9.4. **Rotação e revogação.** As credenciais de API são rotacionadas periodicamente (recomendado a cada **90 dias** ou conforme política do provedor) e **imediatamente revogadas/substituídas** em caso de suspeita de comprometimento, desligamento de responsável técnico ou encerramento da integração.

9.5. **Proibição de credenciais em código.** É **terminantemente vedado** versionar segredos em repositório, arquivos de configuração públicos, logs, tickets, e-mails ou canais de mensageria. Varreduras automáticas de segredos (secret scanning) devem estar ativas; qualquer segredo exposto é tratado como comprometido e rotacionado.

9.6. **Webhooks.** Endpoints que recebem eventos de gateways e e-commerces validam a **assinatura/segredo do webhook** e a origem antes de processar, prevenindo injeção de pedidos ou de eventos financeiros forjados (impactando split, repasses e conciliação).

9.7. **Tokens de notificação ao comprador.** Chaves dos provedores de e-mail/WhatsApp usadas para notificação de rastreio (SRO) e status de pedido seguem o mesmo regime write-only, com escopo mínimo de envio.

---

## 10. Contas de Serviço, Cron e Edge Functions

10.1. Contas não humanas (service accounts, tokens de cron, Edge Functions) possuem identidade própria, escopo mínimo e **não** utilizam credenciais de pessoas físicas.

10.2. Seus segredos residem em cofre/variáveis de ambiente de servidor, são rotacionados e auditados, e nunca trafegam para o cliente.

10.3. Processos automatizados que acessam PII de comprador operam sob o mesmo regime de RLS/RBAC e registram trilha de auditoria, preservando a natureza de **Operador** do GLOP frente ao Controlador.

---

## 11. Registro, Monitoramento e Auditoria

11.1. **Eventos registrados.** São registrados, no mínimo: logins bem-sucedidos e falhos, bloqueios/desbloqueios, cadastro e uso de MFA, redefinições de senha, criação/rotação/revogação de credenciais de API, concessão/elevação/revogação de permissões (RBAC), acessos de superadmin e uso de segredos de servidor.

11.2. **Trilha imutável.** A auditoria é sustentada por **triggers de auditoria** e **colunas de auditoria em todo registro** (created_by, updated_by, deleted_by, timestamps e versão), com **soft-delete** (nunca DELETE físico) e filtragem de deleted_at is null nas leituras.

11.3. **Proteção de logs.** Logs de autenticação **não** contêm senhas, tokens em claro, segredos de API nem PII além do estritamente necessário à investigação; o acesso aos logs é restrito e auditado.

11.4. **Retenção.** Os registros de autenticação e auditoria são retidos por prazo compatível com obrigações legais, contratuais e de investigação de incidentes, conforme a política de retenção e a Política de Privacidade.

11.5. **Alertas.** Padrões anômalos (picos de falha, novos dispositivos em contas privilegiadas, uso incomum de service_role) geram alertas ao time de Segurança.

---

## 12. Portal Público de Rastreio (Sem Login)

12.1. O **Portal Público de Rastreio** não autentica o comprador e expõe **apenas status neutro** do envio, sem PII sensível (sem CPF, endereço completo, valor ou dados de terceiros).

12.2. O identificador de consulta deve ser **não sequencial e não adivinhável** (evitar enumeração), com limitação de taxa por IP para impedir varredura em massa e correlação indevida.

12.3. É vedado que o Portal Público exponha qualquer dado que permita reidentificação ou vinculação a dados financeiros, mantendo o princípio da minimização (LGPD, art. 6º, III).

---

## 13. Vedações (Condutas Proibidas)

São **expressamente proibidos**, sujeitos às sanções do item 15:

- a) **compartilhar** senha, token, passkey, código de MFA ou credencial de API com terceiros, inclusive entre colegas de equipe;
- b) **reutilizar** a senha do GLOP em outros serviços;
- c) **armazenar** senhas/segredos em texto claro, planilhas, blocos de notas, e-mail, mensageria, código-fonte ou repositórios;
- d) **anotar** credenciais em locais físicos acessíveis (post-it, quadro);
- e) **contornar** ou desabilitar MFA, RLS, RBAC, rate limiting ou trilhas de auditoria;
- f) **utilizar** contas genéricas/compartilhadas para acesso a produção (cada acesso é nominal e rastreável);
- g) **elevar privilégios** sem autorização formal ou explorar funções security definer indevidamente;
- h) **expor** service_role key ou qualquer segredo de servidor ao frontend, a clientes ou a terceiros;
- i) **coletar, exportar ou tratar** PII de comprador fora do escopo autorizado pelo Controlador e pela finalidade contratada (violação da posição de Operador — LGPD, arts. 39 e 42);
- j) **transmitir** senha atual/nova ou segredo por canais não cifrados;
- k) **inserir** segredos em URLs, logs, prints, tickets ou anexos;
- l) **utilizar** credenciais de outrem, ainda que fornecidas voluntariamente;
- m) **manter** credenciais ativas após desligamento, fim de contrato ou fim da finalidade (obrigatória a revogação imediata — item 14);
- n) **ignorar** alertas de segurança, ou deixar de reportar suspeita de comprometimento ao time de Segurança sem demora.

---

## 14. Ciclo de Vida de Identidades (Provisionamento e Desprovisionamento)

14.1. **Admissão / onboarding.** Concessão de acesso mediante solicitação formal do gestor, com atribuição de papel RBAC de menor privilégio, MFA configurado antes do primeiro acesso a dados sensíveis e senha temporária de troca obrigatória.

14.2. **Mudança de função.** Revisão imediata de permissões (princípio do menor privilégio); permissões residuais de função anterior são removidas.

14.3. **Desligamento / fim de contrato.** Revogação **imediata** (idealmente no mesmo dia) de todas as credenciais, sessões, tokens, chaves de API sob responsabilidade da pessoa e acessos de infraestrutura, com registro em auditoria.

14.4. **Revisão periódica de acessos.** Recertificação, no mínimo **trimestral** para papéis privilegiados e **semestral** para os demais, confirmando a pertinência de cada acesso e de cada credencial de integração ativa.

14.5. **Contas inativas.** Contas sem uso por período definido são sinalizadas, revisadas e, quando cabível, suspensas.

---

## 15. Papéis, Responsabilidades e Sanções

### 15.1. Papéis

- **Titular da conta (usuário/colaborador):** manter suas credenciais secretas, ativar MFA, reportar suspeitas, seguir esta Política.
- **Gestor da área:** solicitar, revisar e cessar acessos; garantir aderência da equipe.
- **Administrador de empresa (company admin):** gerir usuários e permissões dentro de sua company, respeitando o isolamento multi-tenant.
- **Time de Segurança da Informação:** definir controles, monitorar, responder a incidentes, conduzir revisões de acesso e testes.
- **Engenharia / DevOps:** implementar e manter os controles técnicos (Supabase Auth, RLS, RBAC, write-only, rate limiting, auditoria, rotação).
- **Encarregado (DPO):** supervisionar conformidade com a LGPD, atuar como ponto de contato com titulares e ANPD, orientar sobre riscos.
- **Alta Direção:** aprovar a Política, prover recursos e patrocinar a cultura de segurança.

### 15.2. Sanções

15.2.1. O descumprimento desta Política sujeita **colaboradores e prestadores** a medidas disciplinares proporcionais à gravidade, incluindo advertência, suspensão, rescisão do contrato de trabalho/prestação por justa causa e responsabilização civil e criminal, sem prejuízo da comunicação às autoridades quando cabível.

15.2.2. O descumprimento por **usuários da plataforma** pode ensejar suspensão ou encerramento do acesso, nos termos dos Termos de Uso, além das responsabilidades legais aplicáveis.

15.2.3. Condutas que violem a LGPD podem gerar responsabilização nos termos dos arts. 42 a 45 da Lei nº 13.709/2018, além das sanções administrativas do art. 52 aplicáveis ao Controlador.

---

## 16. Gestão de Incidentes de Credenciais

16.1. Suspeita ou confirmação de comprometimento de senha, token, passkey ou credencial de API deve ser reportada **imediatamente** ao time de Segurança pelo canal lemoncapsencapsulados@gmail.com ou pelo canal interno de incidentes.

16.2. Resposta mínima: revogação/rotação da credencial afetada, invalidação de sessões, investigação por trilha de auditoria, avaliação de impacto e, se houver risco a dados pessoais, acionamento do plano de resposta a incidentes e das obrigações de comunicação (LGPD, art. 48; deveres do Operador de informar o Controlador — art. 39/DPA).

16.3. Registro completo do incidente, causa-raiz e lições aprendidas, com atualização de controles.

---

## 17. Exceções

17.1. Qualquer desvio desta Política exige **exceção formal**, com justificativa, avaliação de risco, controles compensatórios, prazo de validade e aprovação do time de Segurança e do DPO quando houver impacto a dados pessoais. Exceções são registradas, revisadas e revogadas ao fim do prazo.

---

## 18. Vigência e Revisão

18.1. Esta Política entra em vigor na data de sua publicação (16 de julho de 2026) e vigora por prazo indeterminado, até substituição por versão posterior.

18.2. Será revisada, no mínimo, **anualmente**, e sempre que houver alteração legislativa/regulatória relevante, mudança arquitetural (novo sub-operador, novo gateway, mudança no Supabase/Netlify), incidente relevante ou recomendação de auditoria.

---

## Engenharia Jurídica & Governança

### (a) Fundamentação das Cláusulas

| Cláusula / Tema | Fundamento legal / normativo |
|---|---|
| Dever de adotar medidas de segurança, técnicas e administrativas | LGPD (Lei 13.709/2018), art. 46; art. 47 (segurança em todas as fases); art. 49 (sistemas estruturados para atender segurança) |
| Prevenção e boas práticas / governança | LGPD, arts. 6º, VII e VIII (segurança e prevenção), 50 (regras de boas práticas e governança) |
| Posição de Operador (dados do comprador) | LGPD, arts. 37, 39 e 42 (responsabilidade do operador; seguir instruções do controlador) |
| Comunicação de incidente | LGPD, art. 48; dever do operador de informar o controlador (art. 39) e DPA |
| Sanções e responsabilização | LGPD, arts. 42 a 45 (reparação) e 52 (sanções administrativas) |
| Minimização e finalidade (Portal Público de Rastreio) | LGPD, art. 6º, I, II e III |
| Complexidade, verificação de senha vazada, hash, sem rotação forçada, MFA/passkeys, comparação em tempo constante | NIST SP 800-63B (Digital Identity Guidelines — Authentication) |
| Requisitos de verificação de autenticação, gestão de segredos, anti-automação | OWASP ASVS (V2 Authentication, V6 Cryptography/Secrets) e OWASP Top 10 (A07 Identification & Authentication Failures) |
| Controles de acesso, gestão de credenciais, segregação de funções, gestão do ciclo de vida | ISO/IEC 27001 (SGSI) e ISO/IEC 27002 (controles: 5.15 controle de acesso, 5.16 gestão de identidade, 5.17 informação de autenticação, 8.5 autenticação segura) |
| Extensão de privacidade ao SGSI | ISO/IEC 27701 (PIMS) |
| Continuidade e resiliência de acesso | ISO 22301 (continuidade) e ISO 31000 (gestão de riscos) |
| Nada confia no frontend / RLS-RBAC / write-only | Boas práticas Supabase (RLS, service_role, @supabase/ssr) e princípios de defesa em profundidade e menor privilégio |

### (b) Riscos Mitigados

- **Sequestro de conta (ATO)** — via MFA/passkeys, verificação de senha vazada, bloqueio por tentativas e detecção de anomalia.
- **Credential stuffing / password spraying** — rate limiting por conta/IP/dispositivo + senhas vazadas + MFA.
- **Vazamento de PII do comprador** (nome, CPF, endereço, valor) — RLS multi-tenant, menor privilégio, auditoria, minimização no portal público.
- **Exposição de segredos de integração** — modelo write-only, cifragem em repouso, proibição de segredos em código, secret scanning, rotação.
- **Fraude financeira em split/repasses/PIX** — MFA obrigatório e step-up em operações financeiras, validação de webhooks, auditoria.
- **Escalonamento de privilégio / travessia entre tenants** — RLS no banco, RBAC, controle de superadmin, vedação a security definer indevido.
- **Phishing** — preferência por passkeys resistentes a phishing; desencorajo de SMS.
- **Enumeração de contas** — mensagens neutras, tempo de resposta normalizado.
- **Quebra de hash** — algoritmo com sal único e custo alto, revisão de parâmetros, TLS.
- **Persistência de acesso indevido** — desprovisionamento imediato, revisão periódica, rotação de refresh token com reuse detection.
- **Não conformidade LGPD** — demonstração de medidas do art. 46 e governança do art. 50.

### (c) Checklist de Conformidade

- [ ] Comprimento mínimo (12 / 16 privilegiado) e máximo ≥ 64 implementados no Supabase Auth.
- [ ] Verificação contra senhas vazadas e comuns ativa no cadastro e troca.
- [ ] Hash com sal único e custo adequado (bcrypt/scrypt/Argon2) confirmado no provedor.
- [ ] MFA obrigatório para papéis privilegiados e operações financeiras; passkeys disponíveis.
- [ ] SMS não é único fator de conta privilegiada.
- [ ] Rate limiting + bloqueio progressivo (5 → backoff, 10 → 15 min) configurados.
- [ ] Mensagens de erro neutras (antienumeração).
- [ ] RLS habilitada em todas as tabelas public; funções app.* em uso.
- [ ] RBAC (app.has_permission) cobrindo os recursos semeados.
- [ ] service_role key fora do frontend; apenas em ambiente de servidor/cofre.
- [ ] Credenciais de API em modelo write-only, cifradas, com estado mascarado na UI.
- [ ] Webhooks de gateways/e-commerces validam assinatura.
- [ ] Rotação de credenciais de API (≤ 90 dias) e revogação por evento.
- [ ] Trilha de auditoria por triggers + colunas de auditoria + soft-delete ativos.
- [ ] Logs sem senhas/tokens/segredos em claro.
- [ ] Portal público expõe só status neutro; identificador não sequencial.
- [ ] Desprovisionamento imediato no desligamento; revisão trimestral/semestral de acessos.
- [ ] Secret scanning ativo no repositório.
- [ ] Plano de resposta a incidentes de credenciais testado.

### (d) Matriz RACI

| Atividade | Titular da conta | Gestor da área | Segurança da Informação | Engenharia/DevOps | DPO | Alta Direção |
|---|---|---|---|---|---|---|
| Definir/aprovar a Política | I | C | R | C | C | A |
| Implementar controles técnicos (Auth, RLS, RBAC, write-only) | I | I | C | R | C | A |
| Ativar/manter MFA na própria conta | R | C | A | C | I | I |
| Conceder/revisar/cessar acessos (RBAC) | I | R | A | C | C | I |
| Rotacionar/revogar credenciais de API | I | C | A | R | I | I |
| Monitorar login/anomalias e auditoria | I | I | R | C | A | I |
| Responder a incidente de credencial | C | C | R | C | A | I |
| Revisão periódica de acessos | I | R | A | C | C | I |
| Conformidade LGPD e contato com titulares/ANPD | I | I | C | I | R | A |
| Aprovar exceções | I | C | R | C | A | I |

Legenda: R = Responsável (executa) · A = Aprovador (responde) · C = Consultado · I = Informado.

### (e) Plano de Revisão

- **Periodicidade ordinária:** anual, conduzida pelo time de Segurança com validação do DPO e aprovação da Alta Direção.
- **Gatilhos de revisão extraordinária:** alteração da LGPD ou de normas técnicas (NIST/ISO/OWASP); inclusão/troca de sub-operador ou gateway; mudança arquitetural no Supabase/Netlify; incidente de segurança relevante; achado de auditoria ou pentest; recomendação da ANPD.
- **Método:** análise de aderência (checklist), teste dos controles (MFA, rate limiting, RLS/RBAC, write-only), revisão de logs e de exceções vigentes, atualização da matriz de risco.
- **Registro:** cada revisão gera nova entrada no controle de versão e comunicação às partes afetadas.

### (f) Controle de Versão

| Versão | Data | Autor / Responsável | Descrição das alterações | Aprovação |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | a ser designado pela administração / Segurança da Informação | Emissão inicial da Política de Senhas e Autenticação do GLOP (minuta) | [PARTE] / Alta Direção |
| 1.1 | 16 de julho de 2026 | [PARTE] | (reservado para próxima revisão) | [PARTE] |

---

*Documento de propriedade de LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA — uso interno e confidencial. Distribuição controlada. Este documento é uma minuta e deve ser validado por advogado(a) habilitado(a) e pelo time de Segurança antes do uso em produção.*
