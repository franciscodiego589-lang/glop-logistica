> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# CONTRATO / TERMO DE INTEGRAÇÃO TÉCNICA — WEBHOOKS E CONECTORES COM PLATAFORMAS DE PAGAMENTO E E-COMMERCE

**Plataforma:** [NOME FANTASIA: GLOP] — Global Logistics Platform
**Documento:** Termo de Integração Técnica (TIT) — Anexo Técnico ao Contrato de Prestação de Serviços SaaS
**Versão:** 1.0
**Vigência a partir de:** 16 de julho de 2026

---

## PREÂMBULO

Este Contrato/Termo de Integração Técnica ("**Termo**" ou "**TIT**") regula, de forma acessória e complementar ao Contrato de Prestação de Serviços de Software como Serviço (SaaS) e ao respectivo Acordo de Tratamento de Dados (DPA), as condições técnicas, operacionais, de segurança e de proteção de dados sob as quais o [CONTRATANTE] ("**Cliente**", "**Usuário GLOP**", "**Controlador**") habilita, configura e mantém integrações automatizadas entre a plataforma [NOME FANTASIA: GLOP] e plataformas de terceiros de pagamento, checkout, infoprodutos e e-commerce, por meio de **webhooks**, **conectores por API (REST/GraphQL)**, **polling agendado**, **chaves de plataforma** e demais mecanismos de troca de dados descritos neste instrumento.

O presente Termo NÃO cria, entre a GLOP e as plataformas de terceiros (Monetizze, AppMax, Hotmart, Kiwify, Shopify, WooCommerce, Nuvemshop, Mercado Livre, VHSYS, Correios, provedores de WhatsApp/e-mail, entre outros), qualquer relação contratual, mandato, representação, agência ou solidariedade. As plataformas de terceiros são operadas e disponibilizadas por seus respectivos titulares, sob termos próprios, sobre os quais a GLOP não detém controle.

---

## CLÁUSULA 1 — DAS PARTES E QUALIFICAÇÃO

### 1.1. CONTRATADA / OPERADORA DA PLATAFORMA (GLOP)

**LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA**, sociedade empresária inscrita no CNPJ sob o nº **55.836.075/0001-07**, com sede em **Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190**, doravante designada "**GLOP**", "**Contratada**" ou "**Plataforma**", desenvolvedora e mantenedora do software Global Logistics Platform, SaaS de logística e ERP voltado a operações de dropshipping e infoprodutos no Brasil.

### 1.2. CONTRATANTE / CLIENTE USUÁRIO (CONTROLADOR)

**[CONTRATANTE]**, pessoa física ou jurídica identificada no ato de contratação e no cadastro (tenant/company) da Plataforma, doravante "**Cliente**" ou "**Controlador**", produtor(a), lojista, infoprodutor(a) ou operador(a) logístico(a) que utiliza a GLOP para ingestão, processamento e cumprimento (fulfillment) de pedidos originados nas plataformas de terceiros.

### 1.3. TERCEIROS INTEGRADOS (NÃO PARTES)

Para os fins deste Termo, consideram-se "**Plataformas de Terceiros**" ou "**Provedores Externos**" os sistemas com os quais a GLOP se integra, incluindo, sem limitação:

| Categoria | Provedores (exemplificativo) | Papel funcional |
|---|---|---|
| Gateways / Pagamento / Infoprodutos | Monetizze, AppMax, Hotmart, Kiwify | Origem de pedidos, transações, comissões e split |
| E-commerce / Checkout | Shopify, WooCommerce, Nuvemshop, Mercado Livre | Origem de pedidos e dados do comprador |
| Emissão fiscal | VHSYS | Emissão de NF-e / documentos fiscais |
| Transporte | Correios (PPN pré-postagem, SRO rastreio) | Postagem e rastreamento |
| Notificação | Provedores de WhatsApp e e-mail | Comunicação ao comprador |
| Infraestrutura (sub-operadores) | Supabase, Netlify | Banco de dados, autenticação, storage e hospedagem SSR |

As Plataformas de Terceiros **não são partes** deste Termo e não anuem a ele.

---

## CLÁUSULA 2 — DEFINIÇÕES

Para interpretação uniforme deste Termo, aplicam-se as definições abaixo, sem prejuízo daquelas constantes do Contrato SaaS e do DPA:

1. **Webhook:** requisição HTTP(S) enviada de forma assíncrona por uma Plataforma de Terceiro à GLOP (endpoint receptor), notificando um evento (ex.: pedido pago, pedido cancelado, chargeback, reembolso, atualização de status).
2. **Conector / Adaptador:** componente de software da GLOP responsável por autenticar-se, consultar (pull) e normalizar dados de uma Plataforma de Terceiro por meio de sua API (ex.: adaptador Monetizze API 2.1 com autenticação em duas etapas X_CONSUMER_KEY → TOKEN, endpoint /transactions, campo "dados", paginação page/pages).
3. **Chave da Plataforma / Credencial de Integração:** conjunto de segredos (API key, consumer key, token, client secret, chave de assinatura de webhook, OAuth) fornecido pelo Cliente ou pela Plataforma de Terceiro para autenticar a integração. Armazenadas na GLOP em modo **write-only** (não recuperáveis em texto claro pela interface).
4. **Assinatura de Webhook (HMAC/signature):** mecanismo criptográfico (ex.: HMAC-SHA256 sobre o corpo bruto da requisição, com segredo compartilhado) que permite à GLOP verificar autenticidade e integridade do payload recebido.
5. **Retry:** política de novas tentativas automáticas de processamento diante de falha transitória.
6. **DLQ (Dead Letter Queue):** fila de mensagens não processadas após esgotadas as tentativas, para inspeção, reprocessamento manual ou descarte controlado.
7. **Idempotência:** garantia de que a reentrega do mesmo evento (mesmo identificador/idempotency key) não gere duplicidade de pedido, cobrança ou movimentação.
8. **PII do Comprador:** dados pessoais do comprador final trafegados na integração — nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor.
9. **Controlador / Operador:** na acepção da Lei nº 13.709/2018 (LGPD). Ver Cláusula 9 quanto à dupla natureza da GLOP.
10. **Portal Público de Rastreio:** página sem autenticação que expõe apenas status neutro do envio, sem PII do comprador.
11. **Multi-tenant / RLS:** isolamento lógico por empresa (Tenant → Company → Branch → Membership) aplicado no banco (Row Level Security), nunca confiando no frontend.

---

## CLÁUSULA 3 — DO OBJETO

### 3.1. Objeto

Constitui objeto deste Termo estabelecer as condições técnicas, de segurança, de responsabilidade e de proteção de dados para a **habilitação, configuração, operação, monitoramento e descontinuação** de integrações automatizadas entre a GLOP e as Plataformas de Terceiros, compreendendo:

1. Ingestão de pedidos via **API** (Monetizze, Hotmart, Kiwify) e via **e-commerces** (Shopify, WooCommerce, Nuvemshop, Mercado Livre), com recepção de PII do comprador (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor);
2. Recepção de **webhooks** de eventos transacionais (pago, cancelado, estornado, chargeback, atualização) e execução de **polling agendado** quando o provedor não oferecer webhook confiável;
3. **Pré-postagem (PPN)** e **rastreio (SRO)** junto aos Correios, com **notificação ao comprador** por e-mail/WhatsApp e exposição de status neutro no **Portal Público de Rastreio**;
4. **Coprodução & Split:** apuração de comissões de coprodutores/afiliados, repasses e split (AppMax), com tratamento de dados de PIX/bancários dos beneficiários;
5. Emissão de **NF-e** e documentos fiscais via **VHSYS**;
6. Normalização, deduplicação (idempotência), roteamento e persistência dos dados no banco multi-tenant da GLOP, sob RLS/RBAC.

### 3.2. Natureza acessória

Este Termo é acessório e integra o Contrato SaaS. Em caso de conflito, prevalecem, nesta ordem: (i) normas de ordem pública e a LGPD; (ii) o DPA; (iii) o Contrato SaaS; (iv) este Termo; (v) documentação técnica e políticas da GLOP.

### 3.3. Configuração pelo Cliente

A habilitação de cada integração é ato **voluntário e sob controle do Cliente**, realizado mediante inserção das respectivas Chaves da Plataforma e parâmetros no workbench de integrações da GLOP (Store Integration Hub / Carrier Integration Hub / EIP Workbench). O Cliente declara possuir legitimidade e autorização para conectar cada conta de terceiro.

---

## CLÁUSULA 4 — ESCOPO DA INTEGRAÇÃO

### 4.1. Direção e modalidades do fluxo

| # | Fluxo | Origem → Destino | Mecanismo | Dados |
|---|---|---|---|---|
| 1 | Ingestão de pedido (infoproduto) | Monetizze/Hotmart/Kiwify → GLOP | Webhook + pull API | PII do comprador, produto, valor, status |
| 2 | Ingestão de pedido (e-commerce) | Shopify/WooCommerce/Nuvemshop/Mercado Livre → GLOP | Webhook + pull API | PII do comprador, itens, valor |
| 3 | Split / comissão | AppMax → GLOP | Webhook + API | Beneficiários, comissão, PIX/bancário |
| 4 | Pré-postagem | GLOP → Correios (PPN) | API | Remetente, destinatário, dimensões |
| 5 | Rastreio | Correios (SRO) → GLOP → Comprador | API + notificação | Código de rastreio, status |
| 6 | Notificação | GLOP → WhatsApp/e-mail → Comprador | API | Nome, contato, status do envio |
| 7 | Fiscal | GLOP → VHSYS | API | Dados fiscais do pedido |
| 8 | Rastreio público | GLOP → Público | Portal sem login | Somente status neutro |

### 4.2. Limites do escopo

1. A GLOP integra-se **exclusivamente** às Plataformas de Terceiros e eventos expressamente habilitados pelo Cliente. Nenhum acesso é presumido.
2. A GLOP acessa apenas os **campos necessários** ao propósito logístico/fiscal (minimização — art. 6º, III, LGPD). Campos sensíveis do provedor não pertinentes ao fulfillment não são solicitados nem persistidos deliberadamente.
3. Não integra o escopo: (i) armazenamento de dados de cartão de crédito completos (PAN/CVV) — a GLOP **não** captura nem processa dados de cartão, que permanecem na esfera do gateway; (ii) execução de cobranças/estornos financeiros diretamente pela GLOP; (iii) suporte às contas de terceiro do Cliente perante os respectivos provedores.

### 4.3. Alterações de escopo

Ativação/desativação de conectores, eventos ou campos adicionais constitui alteração de escopo e fica registrada na trilha de auditoria (Cláusula 8.6), com efeitos a partir do salvamento da configuração.

---

## CLÁUSULA 5 — RESPONSABILIDADES SOBRE CREDENCIAIS E CHAVES DE INTEGRAÇÃO

### 5.1. Obrigações do Cliente (titular das contas de terceiro)

1. **Titularidade e legitimidade:** fornecer somente Chaves da Plataforma de contas das quais seja titular ou esteja autorizado a operar, respeitando os termos de uso de cada provedor.
2. **Escopo mínimo (least privilege):** gerar credenciais com o menor escopo/permissão suficiente (preferencialmente somente leitura de pedidos e escrita restrita à operação necessária).
3. **Rotação e revogação:** rotacionar periodicamente as chaves e revogá-las imediatamente em caso de suspeita de comprometimento, desligamento de colaborador ou encerramento da integração, comunicando a GLOP.
4. **Segregação de segredo de webhook:** configurar, quando o provedor permitir, o segredo de assinatura de webhook e informá-lo à GLOP pelos canais seguros da Plataforma.
5. **Veracidade:** responder pela exatidão das chaves e parâmetros inseridos.

### 5.2. Obrigações da GLOP (custódia técnica)

1. **Armazenamento seguro (write-only):** armazenar Chaves da Plataforma de forma **cifrada** e **write-only**, sem exibição em texto claro na interface após o cadastro; acesso restrito ao processo de integração.
2. **Isolamento multi-tenant:** vincular cada credencial ao respectivo tenant/company sob **RLS**, impedindo acesso cruzado entre clientes.
3. **Controle de acesso (RBAC):** restringir a gestão de credenciais por permissão (has_permission), com trilha de auditoria de quem cadastrou, alterou ou removeu.
4. **Uso vinculado ao propósito:** empregar as credenciais **exclusivamente** para os fluxos habilitados neste Termo, jamais para finalidade estranha ao serviço.
5. **Transmissão cifrada:** trafegar credenciais e payloads sobre **TLS** (HTTPS), sem registro de segredos em logs em texto claro.
6. **Notificação:** comunicar o Cliente sobre falhas de autenticação recorrentes que indiquem chave inválida, expirada ou revogada.

### 5.3. Limitação

A GLOP não é responsável por bloqueios, suspensões, limitações de taxa (rate limit), tarifação, alteração de escopo ou revogação de chaves determinadas pelas próprias Plataformas de Terceiros, nem por uso indevido de credenciais que o Cliente tenha mantido fora do ambiente da GLOP.

---

## CLÁUSULA 6 — SEGURANÇA DA INTEGRAÇÃO (WEBHOOK, RETRY, DLQ)

### 6.1. Autenticação e verificação de webhooks

1. Todo endpoint receptor de webhook opera exclusivamente sobre **HTTPS/TLS**.
2. Quando o provedor oferecer assinatura, a GLOP **verifica a assinatura** (ex.: HMAC-SHA256 sobre o corpo bruto, comparação em tempo constante) antes de processar o payload; requisições com assinatura ausente ou inválida são **rejeitadas** (HTTP 401/403) e registradas.
3. Quando o provedor não oferecer assinatura, a GLOP aplica controles compensatórios: **segredo em URL/rota não previsível**, **allowlist de origem** quando disponível, **validação de esquema** do payload e **reconciliação por pull** (consulta à API do provedor para confirmar o evento antes de efeitos irreversíveis).
4. **Proteção anti-replay:** verificação de timestamp/nonce e janela de tolerância; rejeição de eventos fora da janela.

### 6.2. Idempotência

1. Cada evento é identificado por chave idempotente (id do provedor + tipo de evento). A GLOP **deduplica** reentregas, garantindo que um mesmo pedido não gere duplicidade de registro, postagem ou notificação.
2. Operações com efeito externo (pré-postagem, emissão de NF-e, notificação ao comprador) são protegidas por trava de idempotência.

### 6.3. Política de Retry

1. Falhas **transitórias** (timeout, 5xx do provedor, indisponibilidade momentânea) disparam **novas tentativas automáticas** com **backoff exponencial** e *jitter*, respeitando limite máximo de tentativas.
2. Falhas **permanentes** (payload inválido, 4xx não recuperável, assinatura inválida) **não** são reprocessadas automaticamente e seguem para a DLQ.
3. A GLOP respeita cabeçalhos de controle de taxa do provedor (ex.: Retry-After) e limites de paginação (ex.: page/pages) para evitar bloqueio.

### 6.4. Dead Letter Queue (DLQ)

1. Eventos não processados após esgotadas as tentativas são preservados em **DLQ**, com metadados (motivo, tentativas, timestamps), para inspeção, **reprocessamento manual** ou descarte controlado.
2. Payloads em DLQ observam a mesma proteção de dados dos demais registros (cifra em repouso, RLS, retenção limitada).
3. A GLOP disponibiliza ao Cliente visibilidade sobre pendências relevantes (ex.: pedidos não ingeridos) por painel ou alerta.

### 6.5. Demais controles

1. **Validação de esquema** e sanitização de todo payload antes da persistência.
2. **Rate limiting** e proteção contra abuso no endpoint receptor.
3. **Menor privilégio** nos processos que consomem webhooks.
4. **Segregação de logs:** logs operacionais sem PII sensível desnecessária e sem segredos.
5. **Observabilidade:** métricas de recebimento, sucesso, falha, latência e volume de DLQ.

---

## CLÁUSULA 7 — DISPONIBILIDADE, DESEMPENHO E CONTINUIDADE

### 7.1. Esforço de disponibilidade

A GLOP empregará esforços comercialmente razoáveis para manter os endpoints de integração e conectores disponíveis, observados o Contrato SaaS e eventual SLA nele pactuado. A disponibilidade da recepção de webhooks depende, no lado da GLOP, da infraestrutura de sub-operadores (Supabase e Netlify — hospedagem SSR), e, no lado externo, das Plataformas de Terceiros, sobre as quais a GLOP não tem ingerência.

### 7.2. Janelas de manutenção

Manutenções programadas serão, sempre que possível, comunicadas com antecedência e realizadas em janelas de menor impacto. Durante manutenções, a política de **Retry/DLQ** preserva eventos recebíveis para processamento posterior, minimizando perda.

### 7.3. Degradação de provedor externo

Indisponibilidade, lentidão, alteração de API, deprecação de endpoint, mudança de contrato de dados (schema) ou bloqueio por parte de Plataforma de Terceiro **não** constituem inadimplemento da GLOP. A GLOP envidará esforços razoáveis para adaptar conectores a mudanças anunciadas, sem garantia de continuidade quando a alteração for imposta unilateralmente pelo terceiro.

### 7.4. Continuidade e resiliência

A GLOP mantém mecanismos de recuperação (reprocessamento por pull, DLQ, reconciliação) para reduzir o impacto de falhas transitórias, alinhados às boas práticas de continuidade (referência ISO 22301). Não há garantia de zero perda diante de falha exclusiva e prolongada de terceiro.

---

## CLÁUSULA 8 — SEGURANÇA DA INFORMAÇÃO E CONTROLES TÉCNICOS

### 8.1. Isolamento multi-tenant (RLS)

Todo dado trafegado e persistido carrega tenant_id/company_id e é isolado por **Row Level Security**, jamais confiando no frontend. O acesso entre empresas é vedado por política de banco.

### 8.2. Controle de acesso (RBAC)

Operações sobre integrações, credenciais e dados são autorizadas por permissão (has_permission), com papéis segregados.

### 8.3. Criptografia

**TLS** em trânsito; cifra em repouso conforme capacidades da infraestrutura (Supabase). Segredos de integração em modo **write-only**.

### 8.4. Soft-delete

Nenhuma exclusão física: registros são marcados (deleted_at, reason_deleted); toda leitura filtra deleted_at is null, preservando rastreabilidade e reversibilidade controlada.

### 8.5. Colunas de auditoria

Todo registro de negócio carrega colunas de auditoria (created_by/updated_by/deleted_by, timestamps, version), permitindo reconstrução da linha do tempo.

### 8.6. Trilha de auditoria por triggers

Alterações são registradas por **triggers** de auditoria (tg_write_audit), gerando trilha imutável de INSERT/UPDATE/DELETE, inclusive das configurações de integração.

### 8.7. Minimização e portal público neutro

O **Portal Público de Rastreio** (sem login) expõe **apenas status neutro**, sem PII do comprador, evitando exposição de dados pessoais a não autorizados.

### 8.8. Referenciais

Os controles orientam-se por boas práticas reconhecidas (ISO/IEC 27001, ISO/IEC 27701, NIST CSF, OWASP ASVS/Top 10), sem que a citação implique certificação salvo declaração formal em anexo.

---

## CLÁUSULA 9 — PROTEÇÃO DE DADOS PESSOAIS (LGPD)

### 9.1. Dupla natureza da GLOP

A GLOP atua sob **dupla natureza**, conforme o fluxo:

1. **OPERADORA (art. 5º, VII, LGPD):** ao tratar **PII do comprador** por conta e ordem do Cliente (produtor/lojista), que é o **CONTROLADOR** desses dados. A GLOP trata tais dados **conforme as instruções documentadas** do Cliente e os propósitos deste Termo (ingestão, fulfillment, rastreio, notificação, fiscal).
2. **CONTROLADORA (art. 5º, VI, LGPD):** quanto aos dados dos **próprios usuários/colaboradores** do Cliente que operam a Plataforma (cadastro, autenticação, logs de uso, faturamento do SaaS), definindo finalidades e meios próprios.

### 9.2. Papéis das Plataformas de Terceiros

As Plataformas de Terceiros que originam os dados (gateways/e-commerces) atuam como Controladores/Operadores em suas próprias esferas, sob termos próprios. A GLOP não responde pela licitude da coleta feita fora do seu ambiente (ex.: consentimento/base legal obtidos pelo Cliente no checkout do provedor).

### 9.3. Bases legais e finalidade

O tratamento pela GLOP fundamenta-se, conforme o caso, em **execução de contrato** (art. 7º, V), **cumprimento de obrigação legal/regulatória** (art. 7º, II — ex.: obrigações fiscais/NF-e), **legítimo interesse** (art. 7º, IX, com teste de proporcionalidade e minimização) e nas instruções do Controlador. A GLOP **não** utiliza a PII do comprador para finalidade própria estranha ao serviço.

### 9.4. Sub-operadores

O Cliente autoriza, de forma geral, a subcontratação dos sub-operadores necessários à prestação (Supabase, Netlify — infraestrutura; e provedores estritamente instrumentais à execução dos fluxos, como Correios, VHSYS e provedores de WhatsApp/e-mail, nos limites da finalidade). A GLOP mantém lista atualizada de sub-operadores e assegura, por contrato, deveres de segurança compatíveis. Alterações relevantes de sub-operadores serão comunicadas, facultando objeção fundamentada.

### 9.5. Transferência internacional

Havendo tratamento/armazenamento fora do Brasil por sub-operador, a GLOP adotará salvaguardas compatíveis com a LGPD (arts. 33-36) e regulamentação da ANPD, informando o Cliente quando aplicável.

### 9.6. Direitos dos titulares

A GLOP auxiliará o Cliente (Controlador) a atender requisições de titulares (acesso, correção, eliminação, portabilidade, informação sobre compartilhamento — arts. 18-20), repassando prontamente solicitações recebidas diretamente e disponibilizando meios técnicos (soft-delete, exportação) proporcionais ao serviço.

### 9.7. Incidentes de segurança

A GLOP notificará o Cliente **sem demora injustificada** ao tomar conhecimento de incidente de segurança envolvendo dados tratados sob este Termo, fornecendo informações para que o Controlador cumpra os arts. 48 da LGPD e regulamentos da ANPD. A comunicação inicial não constitui reconhecimento de culpa.

### 9.8. Remissão ao DPA

As obrigações de proteção de dados detalham-se no **Acordo de Tratamento de Dados (DPA)**, que prevalece sobre este Termo em matéria de dados pessoais. Encarregado/DPO: **a ser designado pela administração** — **lemoncapsencapsulados@gmail.com**.

### 9.9. Retenção e eliminação

Os dados são retidos pelo tempo necessário às finalidades e a obrigações legais (ex.: guarda fiscal), findo o qual são eliminados ou anonimizados. DLQ e logs seguem retenção limitada e proporcional.

---

## CLÁUSULA 10 — ISENÇÃO QUANTO A PLATAFORMAS DE TERCEIROS

### 10.1. Ausência de controle

As Plataformas de Terceiros são serviços independentes, operados por seus titulares, sob termos, disponibilidade, políticas de segurança, tarifação e roadmap próprios. A GLOP **não controla, não garante e não responde** por: disponibilidade, exatidão, integridade, latência, formato ou continuidade dos dados e eventos por elas fornecidos; alterações unilaterais de API/webhook; bloqueios, suspensões ou rate limits impostos ao Cliente; falhas de pagamento, chargeback, fraude, estorno ou split processados no ambiente do gateway; extravio, avaria ou atraso na esfera dos Correios.

### 10.2. Eventos incorretos ou duplicados de terceiros

A GLOP não responde por decisões operacionais tomadas com base em eventos **incorretos, duplicados, atrasados ou fraudulentos** originados no terceiro, ressalvada a aplicação dos controles de idempotência, verificação de assinatura e reconciliação previstos na Cláusula 6.

### 10.3. Conformidade do Cliente perante o terceiro

Cabe ao Cliente observar os termos de uso, políticas antifraude e regras de API de cada Plataforma de Terceiro. A GLOP não se responsabiliza por penalidades aplicadas ao Cliente por violação a tais termos.

### 10.4. Links e marcas

Menções a marcas de terceiros neste Termo são meramente descritivas/interoperáveis, sem vínculo, patrocínio ou endosso.

---

## CLÁUSULA 11 — OBRIGAÇÕES DO CLIENTE

1. Fornecer credenciais legítimas, de contas próprias/autorizadas, com escopo mínimo, e mantê-las atualizadas e rotacionadas.
2. Definir corretamente as finalidades e bases legais do tratamento da PII do comprador, na qualidade de Controlador, e assegurar a licitude da coleta no checkout do provedor.
3. Configurar corretamente os conectores, eventos e parâmetros; validar os fluxos ativados.
4. Não utilizar a integração para finalidade ilícita, fraude, envio de spam ou comunicação não autorizada ao comprador.
5. Manter seus próprios controles de acesso, papéis (RBAC) e higiene de credenciais dos colaboradores.
6. Comunicar prontamente à GLOP suspeitas de comprometimento de chave ou incidentes na sua esfera.
7. Responder por requisições de titulares e por sua conformidade regulatória (LGPD, fiscal, consumerista) na condição de Controlador.
8. Manter dados de contato do comprador atualizados quando aplicável às notificações.

---

## CLÁUSULA 12 — OBRIGAÇÕES DA GLOP

1. Operar os conectores e endpoints de webhook conforme escopo habilitado, com segurança compatível com boas práticas.
2. Custodiar credenciais em modo write-only, cifradas, isoladas por tenant.
3. Verificar assinatura de webhook quando disponível e aplicar controles compensatórios quando não.
4. Implementar idempotência, retry com backoff e DLQ, com visibilidade de pendências relevantes.
5. Manter RLS, RBAC, soft-delete, colunas de auditoria e trilha por triggers.
6. Tratar PII do comprador apenas conforme instruções do Controlador e finalidades deste Termo (papel de Operadora).
7. Notificar o Cliente sobre incidentes de segurança e falhas recorrentes de autenticação.
8. Manter documentação técnica dos conectores e comunicar mudanças relevantes com antecedência razoável.

---

## CLÁUSULA 13 — PREÇO E CONDIÇÕES FINANCEIRAS

13.1. A remuneração pela utilização da Plataforma, incluindo o módulo de integrações, rege-se pelo **Contrato SaaS** e respectivo plano contratado, não havendo, salvo disposição em contrário, cobrança autônoma por este Termo.

13.2. Custos de terceiros (tarifas de gateway, split, postagem dos Correios, emissão fiscal VHSYS, envio de mensagens WhatsApp/e-mail) são de responsabilidade do Cliente e cobrados pelos respectivos provedores, ainda que intermediados operacionalmente pela GLOP.

13.3. Eventuais limites de volume, chamadas de API ou eventos processados observam o plano contratado; excedentes seguem a política comercial vigente.

---

## CLÁUSULA 14 — CONFIDENCIALIDADE

14.1. Cada Parte obriga-se a manter sigilo sobre informações confidenciais da outra a que tenha acesso em razão deste Termo, incluindo credenciais, segredos de webhook, arquitetura, payloads e dados pessoais, utilizando-as apenas para os fins deste instrumento.

14.2. O dever de confidencialidade subsiste durante a vigência e por **5 (cinco) anos** após o término, e, quanto a dados pessoais e segredos de negócio, enquanto perdurar a proteção legal aplicável.

14.3. Excetuam-se informações comprovadamente públicas, de posse prévia lícita, ou cuja divulgação seja exigida por autoridade competente, hipótese em que a Parte notificará a outra quando legalmente admissível.

---

## CLÁUSULA 15 — PROPRIEDADE INTELECTUAL

15.1. A GLOP detém todos os direitos sobre a Plataforma, conectores, adaptadores, código, arquitetura, esquemas de banco, fluxos de integração e documentação, protegidos pela Lei nº 9.610/1998 e Lei nº 9.609/1998.

15.2. Este Termo **não** transfere titularidade; concede-se licença de uso limitada, não exclusiva, intransferível e revogável, restrita à vigência e às finalidades contratadas.

15.3. Os **dados** do Cliente e a **PII do comprador** permanecem de titularidade/controle do Cliente e dos titulares, respectivamente; a GLOP não adquire direitos sobre eles além do necessário à prestação.

15.4. Marcas de terceiros pertencem a seus titulares; a interoperabilidade não implica cessão ou licença de marca.

---

## CLÁUSULA 16 — RESPONSABILIDADE E LIMITAÇÃO

16.1. Cada Parte responde por perdas e danos diretos comprovadamente causados por dolo ou culpa no cumprimento deste Termo.

16.2. **Exclusão de danos indiretos:** salvo dolo ou culpa grave, nenhuma Parte responde por danos indiretos, lucros cessantes, perda de chance, perda de receita, dano reputacional ou consequenciais.

16.3. **Limitação de valor:** ressalvadas hipóteses de dolo, violação de confidencialidade ou de deveres de proteção de dados que gerem responsabilidade legal própria, a responsabilidade agregada da GLOP fica limitada, no período de 12 (doze) meses, ao valor pago pelo Cliente pela Plataforma nesse período, conforme o Contrato SaaS.

16.4. **Isenção por terceiros:** a GLOP não responde por falhas, indisponibilidades, dados incorretos, fraudes ou penalidades originadas nas Plataformas de Terceiros ou por descumprimento, pelo Cliente, dos termos desses provedores (Cláusula 10).

16.5. **Força maior:** nenhuma Parte responde por inadimplemento decorrente de caso fortuito ou força maior (art. 393, CC), incluindo falhas generalizadas de infraestrutura de terceiros, ataques cibernéticos não imputáveis a culpa e determinações de autoridade.

16.6. A responsabilidade em matéria de dados pessoais observa a repartição da LGPD (arts. 42-45) e do DPA, conforme o papel (Operadora/Controladora) de cada tratamento.

---

## CLÁUSULA 17 — VIGÊNCIA E TÉRMINO

### 17.1. Vigência

Este Termo vigora a partir de **16 de julho de 2026** e enquanto vigente o Contrato SaaS, ou até a desativação de todas as integrações pelo Cliente, o que ocorrer primeiro.

### 17.2. Rescisão

1. **Por conveniência:** por qualquer Parte, mediante aviso prévio nos termos do Contrato SaaS.
2. **Por justa causa:** por descumprimento não sanado no prazo de **[15]** dias após notificação; imediata em caso de violação de confidencialidade, de proteção de dados ou de uso ilícito da integração.
3. **Por imposição de terceiro:** descontinuação de conector quando a Plataforma de Terceiro encerrar ou inviabilizar a integração, sem que isso caracterize inadimplemento da GLOP.

### 17.3. Efeitos do término

1. Desativação dos conectores e endpoints de webhook do Cliente; cessação de novas ingestões.
2. **Revogação/eliminação segura** das Chaves da Plataforma custodiadas, salvo retenção mínima exigida por lei.
3. **Reversibilidade de dados:** por prazo de **[30]** dias, a GLOP disponibilizará meios de exportação dos dados do Cliente em formato estruturado; findo o prazo, os dados serão eliminados ou anonimizados, ressalvada guarda legal (ex.: fiscal) e a preservação por soft-delete estritamente necessária a obrigações legais e auditoria.
4. Processamento residual controlado de eventos pendentes/DLQ apenas para conclusão segura ou descarte.
5. Subsistem as cláusulas de confidencialidade, proteção de dados, propriedade intelectual, responsabilidade e foro.

---

## CLÁUSULA 18 — PENALIDADES

18.1. O uso das integrações para fins ilícitos, fraude, violação de termos de terceiros, envio de comunicação não autorizada ao comprador ou violação de proteção de dados autoriza a **suspensão imediata** da integração e/ou rescisão por justa causa, sem prejuízo de perdas e danos.

18.2. A tentativa de burlar controles de segurança (assinatura de webhook, RLS, RBAC, idempotência) ou de acessar dados de outro tenant sujeita o infrator às sanções contratuais e legais cabíveis (cíveis e penais).

18.3. Multas e sanções específicas, se houver, seguem o Contrato SaaS.

---

## CLÁUSULA 19 — DISPOSIÇÕES GERAIS

1. **Independência das Partes:** este Termo não cria sociedade, mandato, agência ou vínculo empregatício.
2. **Não solidariedade com terceiros:** inexiste solidariedade entre GLOP e Plataformas de Terceiros.
3. **Cessão:** vedada sem anuência escrita, salvo reorganização societária com continuidade de obrigações.
4. **Comunicações:** por escrito, pelos canais oficiais e e-mails cadastrados, incluindo **lemoncapsencapsulados@gmail.com** para temas de dados.
5. **Novação/Tolerância:** a tolerância não constitui novação nem renúncia.
6. **Independência das cláusulas:** a nulidade de uma cláusula não invalida as demais.
7. **Alterações:** por aditivo escrito ou atualização de versão comunicada com antecedência razoável; o uso continuado após o prazo implica anuência.
8. **Integração documental:** este Termo integra o Contrato SaaS, o DPA e as políticas de segurança e privacidade da GLOP.

---

## CLÁUSULA 20 — LEGISLAÇÃO E FORO

20.1. Este Termo rege-se pelas leis da República Federativa do Brasil, em especial: Lei nº 13.709/2018 (LGPD), Lei nº 12.965/2014 (Marco Civil da Internet), Lei nº 8.078/1990 (CDC), Código Civil, Lei nº 9.609/1998 e Lei nº 9.610/1998.

20.2. As Partes elegem o foro da Comarca de **[ENDEREÇO — Comarca]**, com renúncia a qualquer outro por mais privilegiado que seja, ressalvado, em relações de consumo, o foro do domicílio do consumidor.

---

**E, por estarem de acordo, as Partes firmam o presente Termo.**

**[ENDEREÇO — Cidade/UF]**, **16 de julho de 2026**.

| GLOP (Operadora da Plataforma) | [CONTRATANTE] (Cliente / Controlador) |
|---|---|
| **LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA** | **[CONTRATANTE]** |
| CNPJ: **55.836.075/0001-07** | CNPJ/CPF: **55.836.075/0001-07** |
| Nome: ____________________ | Nome: ____________________ |
| Cargo: ____________________ | Cargo: ____________________ |
| Assinatura: ______________ | Assinatura: ______________ |

Encarregado/DPO GLOP: **a ser designado pela administração** — **lemoncapsencapsulados@gmail.com**

---

## Engenharia Jurídica & Governança

### (a) Fundamentação das cláusulas (lei/norma que embasa)

| Cláusula | Fundamento legal/normativo |
|---|---|
| Objeto / Escopo (3, 4) | Autonomia da vontade e função social do contrato — arts. 421, 422 e 425, CC; liberdade contratual atípica |
| Credenciais e chaves (5) | Dever de segurança — art. 46, LGPD; boas práticas ISO/IEC 27001 (A.5/A.8/A.9 — controle de acesso e criptografia) |
| Segurança webhook/retry/DLQ (6) | Art. 46-49, LGPD (segurança e boas práticas); OWASP ASVS (verificação de integridade/autenticação); NIST CSF (Protect/Detect) |
| Disponibilidade/continuidade (7) | Boa-fé objetiva — art. 422, CC; referência ISO 22301 (continuidade); SLA do Contrato SaaS |
| Controles técnicos (8) | Art. 46-49, LGPD; ISO/IEC 27001 e 27701; Marco Civil — art. 13-15 (guarda de logs) |
| Proteção de dados / dupla natureza (9) | Arts. 5º (VI, VII), 6º, 7º, 18-20, 33-36, 39, 42-45, 48, LGPD; regulamentos ANPD |
| Isenção de terceiros (10) | Ausência de solidariedade — arts. 265 e 927, CC; art. 14, §3º, CDC (excludentes); art. 19, Marco Civil |
| Confidencialidade (14) | Sigilo contratual; art. 5º, XII, CF; LGPD; segredo de empresa — Lei nº 9.279/1996, art. 195 |
| Propriedade intelectual (15) | Lei nº 9.609/1998 (software) e Lei nº 9.610/1998 (direitos autorais) |
| Responsabilidade/limitação (16) | Arts. 389, 393, 402-404, 927, CC; repartição LGPD arts. 42-45; força maior art. 393, CC |
| Vigência/término (17) | Arts. 472-474, CC; direito à portabilidade/eliminação — art. 18, LGPD |
| Foro (20) | Art. 63, CPC; art. 101, I, CDC (foro do consumidor) |

### (b) Riscos mitigados

1. **Vazamento/uso indevido de credenciais** — mitigado por armazenamento write-only, cifra, RLS, RBAC e rotação (Cl. 5, 8).
2. **Falsificação/replay de webhook** — mitigado por verificação de assinatura HMAC, anti-replay e reconciliação por pull (Cl. 6.1).
3. **Duplicidade de pedidos/cobranças** — mitigado por idempotência (Cl. 6.2).
4. **Perda de eventos por falha transitória** — mitigado por retry com backoff e DLQ (Cl. 6.3-6.4).
5. **Responsabilização por falha de terceiro** — mitigado por cláusula de isenção e não solidariedade (Cl. 10, 16.4).
6. **Não conformidade LGPD (papéis)** — mitigado pela definição de dupla natureza Operadora/Controladora e remissão ao DPA (Cl. 9).
7. **Exposição de PII no rastreio público** — mitigado por status neutro sem login (Cl. 8.7).
8. **Acesso cross-tenant** — mitigado por RLS e trilha de auditoria por triggers (Cl. 8.1, 8.6).
9. **Lock-in / término abrupto** — mitigado por reversibilidade e exportação de dados (Cl. 17.3).
10. **Uso ilícito da integração** — mitigado por suspensão imediata e penalidades (Cl. 18).

### (c) Checklist de implementação e conformidade

- [ ] Preencher todos os placeholders (LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, 55.836.075/0001-07, Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, lemoncapsencapsulados@gmail.com, a ser designado pela administração, 16 de julho de 2026, [CONTRATANTE]).
- [ ] Confirmar existência e vínculo do DPA e do Contrato SaaS referenciados.
- [ ] Validar verificação de assinatura de webhook por provedor (quais oferecem HMAC/segredo).
- [ ] Mapear controles compensatórios para provedores sem assinatura.
- [ ] Confirmar armazenamento write-only e cifra das chaves em produção.
- [ ] Testar idempotência (reentrega de evento) em ambiente de homologação.
- [ ] Validar backoff, limites de retry e visibilidade da DLQ.
- [ ] Publicar/atualizar lista de sub-operadores e política de comunicação de mudanças.
- [ ] Definir prazos reais de aviso prévio, cura e exportação de dados.
- [ ] Confirmar que o portal público não expõe PII.
- [ ] Revisão por advogado(a) habilitado(a) antes de produção.

### (d) Matriz RACI

| Atividade | Cliente (Controlador) | GLOP (Operadora) | DPO/Encarregado | Provedor Terceiro |
|---|---|---|---|---|
| Fornecer/rotacionar credenciais | R/A | C | I | C |
| Custódia segura das chaves | I | R/A | C | - |
| Verificação de assinatura de webhook | I | R/A | I | C |
| Idempotência / Retry / DLQ | I | R/A | I | - |
| Definir base legal do tratamento da PII | R/A | C | C | I |
| Atender direitos de titulares | R/A | R (apoio) | C | I |
| Notificar incidente de segurança | C | R | A | I |
| Manutenção/atualização de conectores | I | R/A | I | C |
| Exportação/eliminação no término | A | R | C | - |
| Conformidade com termos do provedor | R/A | I | I | A |

(R=Responsável executa; A=Aprova/responde; C=Consultado; I=Informado)

### (e) Plano de revisão

1. **Periodicidade:** revisão ordinária a cada **12 meses**.
2. **Gatilhos extraordinários:** alteração legislativa (LGPD/ANPD, CDC, Marco Civil); mudança relevante de API/webhook de provedor; novo sub-operador; incidente de segurança relevante; nova modalidade de integração ou split.
3. **Responsável:** Encarregado/DPO em conjunto com jurídico e engenharia de integrações.
4. **Registro:** toda revisão gera nova entrada no Controle de Versão e comunicação aos Clientes quando houver impacto material.

### (f) Controle de versão

| Versão | Data | Autor/Área | Descrição da alteração |
|---|---|---|---|
| 1.0 | 16 de julho de 2026 | Jurídico/DPO (minuta IA) | Emissão inicial do Termo de Integração Técnica (webhooks e conectores) |
| | | | Preenchimento de placeholders e validação jurídica |
| | | | Revisão pós-implementação técnica (assinatura, DLQ, idempotência) |
