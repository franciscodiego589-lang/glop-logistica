# Registro das Operações de Tratamento (ROPA) e Relatório de Impacto à Proteção de Dados Pessoais (RIPD/DPIA)

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

---

## Identificação do Documento

| Campo | Conteúdo |
|---|---|
| Título | Registro das Operações de Tratamento (ROPA) e Relatório de Impacto à Proteção de Dados Pessoais (RIPD/DPIA) |
| Plataforma | [NOME FANTASIA: GLOP] — Global Logistics Platform |
| Controladora / Operadora | LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, inscrita no CNPJ sob nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190 |
| Encarregado (DPO) | a ser designado pela administração — lemoncapsencapsulados@gmail.com |
| Site institucional | https://glop-logistica.netlify.app |
| Versão | 1.0 |
| Data de emissão | 16 de julho de 2026 |
| Classificação | Confidencial — uso interno e regulatório |
| Base normativa | Lei nº 13.709/2018 (LGPD), art. 37 e art. 38; Resoluções e Guias da ANPD; Lei nº 12.965/2014 (Marco Civil da Internet); Lei nº 8.078/1990 (CDC); Lei nº 10.406/2002 (Código Civil); Regulamento (UE) 2016/679 (GDPR), art. 30 e art. 35, quando aplicável a titulares/operações na UE |

### Sumário

1. Considerações iniciais e escopo
2. Papéis LGPD do GLOP (dualidade Operador/Controlador)
3. Glossário mínimo
4. **Parte A — Registro das Operações de Tratamento (ROPA)**
   - A.0 Legenda dos campos e critérios
   - A.1 a A.8 — Fichas por atividade de tratamento
   - A.9 Consolidado de bases legais, retenção e transferência internacional
5. **Parte B — Relatório de Impacto à Proteção de Dados Pessoais (RIPD/DPIA)**
   - B.1 Metodologia e critérios de risco
   - B.2 Operação 1 — Ingestão de PII de compradores em escala
   - B.3 Operação 2 — Dados bancários de coprodutores (split/repasses)
   - B.4 Operação 3 — Portal público de rastreio
   - B.5 Matriz consolidada de riscos
   - B.6 Plano de tratamento de riscos e risco residual
   - B.7 Parecer do Encarregado
6. **Engenharia Jurídica & Governança**

---

## 1. Considerações iniciais e escopo

Este documento cumpre a obrigação de manter **registro das operações de tratamento de dados pessoais** (LGPD, art. 37) e, quanto às operações de maior risco, o **Relatório de Impacto à Proteção de Dados Pessoais** (LGPD, art. 5º, XVII, e art. 38). Aplica-se a toda a operação da plataforma **[NOME FANTASIA: GLOP]**, SaaS de logística/ERP voltado a operações de dropshipping e infoprodutos no Brasil.

O escopo abrange os fluxos reais implementados no produto:

- Ingestão automatizada de pedidos, por API, das plataformas de pagamento/checkout **Monetizze, Hotmart e Kiwify** e dos e-commerces **Shopify, WooCommerce, Nuvemshop e Mercado Livre**, com captura de PII do **comprador** (nome, CPF/CNPJ, e-mail, telefone, endereço completo — CEP, logradouro, número, bairro, cidade, UF — produto e valor).
- Integração com os **Correios**: geração de pré-postagem (PPN), consulta de rastreio (SRO), atribuição de código de rastreio e notificação ao comprador.
- **Notificação de rastreio** ao comprador por e-mail e WhatsApp.
- **Coprodução e split**: cadastro de coprodutores/afiliados, regras de comissão, apuração, repasses e split de pagamento via **AppMax**, incluindo dados de PIX/bancários de coprodutores.
- Emissão de **NF-e** via **VHSYS** e demais documentos fiscais (NF-e/CT-e/MDF-e/NFS-e).
- **Portal público de rastreio** (sem login), no qual o comprador consulta o status pelo código de rastreio.
- **Webhooks** de entrada/saída, **logs de API**, e credenciais de API armazenadas em modo write-only.

Arquitetura de suporte: **Next.js (App Router)** no frontend; **Supabase (PostgreSQL)** como backend único, com **RLS multi-tenant** na hierarquia Tenant → Company → Branch → Membership, **Supabase Auth (JWT)** e **Supabase Storage**; hospedagem SSR na **Netlify**. Sub-operadores de infraestrutura: **Supabase** (banco de dados, autenticação e storage) e **Netlify** (hospedagem). Controles de segurança: RLS por empresa, RBAC por permissão (has_permission), soft-delete, trilha de auditoria por triggers e colunas de auditoria (created_by/updated_by/deleted_at, tenant_id/company_id) em todo registro.

Este registro é **dinâmico**: deve ser atualizado a cada nova atividade de tratamento, alteração de finalidade, inclusão de novo operador/suboperador, mudança de base legal ou de fluxo de dados (ver Plano de revisão, na seção final).

---

## 2. Papéis LGPD do GLOP — a dualidade Operador/Controlador

A natureza jurídica do GLOP em matéria de proteção de dados é **dupla e depende do fluxo concreto**. Essa distinção é determinante para a alocação de responsabilidades (LGPD, arts. 5º, VI e VII; 37; 39; 42).

### 2.1 GLOP como OPERADOR

O GLOP atua como **operador** (LGPD, art. 5º, VII) quando trata dados pessoais **em nome e por conta** do produtor/lojista (cliente do GLOP), seguindo suas instruções documentadas. É o caso central da plataforma: os dados do **comprador final** (nome, CPF/CNPJ, contato, endereço, pedido) ingressam para permitir que o produtor/lojista cumpra o contrato de compra e venda e realize a logística de entrega. Nesses fluxos:

- **Controlador** = produtor/lojista (o cliente do GLOP), que decide as finalidades e os meios essenciais do tratamento dos dados dos seus compradores.
- **Operador** = GLOP, que executa o tratamento (ingestão, geração de pré-postagem, rastreio, notificação, emissão de NF-e por sua conta e ordem) conforme instruções e conforme o **Contrato/Termo de Operador (DPA — Data Processing Agreement)** anexo ao contrato SaaS.
- **Suboperadores** = Supabase e Netlify (infraestrutura), Correios (transporte e rastreio), VHSYS (emissão fiscal), AppMax (split de pagamento), provedores de e-mail e de API de WhatsApp — todos autorizados por escrito e vinculados a obrigações equivalentes (LGPD, art. 39).

### 2.2 GLOP como CONTROLADOR

O GLOP atua como **controlador** (LGPD, art. 5º, VI) quanto:

- aos **dados dos seus próprios usuários** — produtores/lojistas, coprodutores e afiliados — coletados para cadastro, autenticação, faturamento, prevenção a fraude e cumprimento de obrigações legais; e
- aos **dados de seus colaboradores** e prestadores.

Nesse âmbito, o GLOP define finalidades e meios, responde diretamente aos titulares e à ANPD e é o responsável primário pelas bases legais.

### 2.3 Zona de atenção — coprodutores e dados bancários

No fluxo de **coprodução/split**, o GLOP coleta e trata dados bancários/PIX de coprodutores e afiliados para viabilizar repasses. Aqui o GLOP tende a atuar como **controlador** (define a finalidade de execução do contrato de coprodução e prevenção à fraude no repasse), atuando a AppMax como operador/parceiro de pagamento. A qualificação exata deve constar do contrato de coprodução e do DPA com a AppMax.

> Regra prática de governança: para cada tabela/registro do banco, o campo que identifica a **empresa titular do dado** (company_id) e o **tenant** (tenant_id) permite reconstruir, a qualquer tempo, quem é o controlador de cada linha — o que sustenta a operação como operador multi-tenant sem vazamento cruzado.

---

## 3. Glossário mínimo

- **PII** — dado pessoal que identifica ou torna identificável o titular (LGPD, art. 5º, I).
- **Titular** — pessoa natural a quem se referem os dados (art. 5º, V).
- **Controlador / Operador** — arts. 5º, VI e VII.
- **RLS (Row Level Security)** — política de segurança em nível de linha do PostgreSQL/Supabase que restringe cada consulta às linhas da empresa/tenant do usuário autenticado.
- **RBAC (has_permission)** — controle de acesso baseado em papéis e permissões por recurso/ação.
- **DPA** — Data Processing Agreement / Acordo de Tratamento de Dados entre controlador e operador.
- **PPN / SRO** — serviços dos Correios de pré-postagem e de rastreamento de objetos.
- **Soft-delete** — exclusão lógica (deleted_at) sem remoção física imediata.

---

# Parte A — Registro das Operações de Tratamento (ROPA)

## A.0 Legenda dos campos e critérios

Cada ficha descreve uma atividade de tratamento com os campos exigidos pela ANPD e pelo art. 30 do GDPR (quando aplicável): papel do GLOP (controlador/operador); finalidade; base legal (LGPD, arts. 7º e 11); categorias de titulares; categorias de dados; destinatários/compartilhamento; transferência internacional; prazo de retenção; e medidas de segurança. As bases legais mais usadas neste registro:

- **Art. 7º, V** — execução de contrato ou de procedimentos preliminares a pedido do titular.
- **Art. 7º, II** — cumprimento de obrigação legal ou regulatória (ex.: guarda fiscal, Marco Civil art. 15).
- **Art. 7º, VI** — exercício regular de direitos em processo.
- **Art. 7º, IX** — legítimo interesse do controlador ou de terceiro, com teste de proporcionalidade e salvaguardas.
- **Art. 7º, I / Art. 11, I** — consentimento (uso residual e específico).

---

## A.1 Ingestão de pedidos das plataformas (PII do comprador)

**Referência interna:** ROPA-01 · **Fluxo real:** pull via API de Monetizze/Hotmart/Kiwify e Shopify/WooCommerce/Nuvemshop/Mercado Livre.

| Campo | Descrição |
|---|---|
| Papel do GLOP | **Operador** (em nome do produtor/lojista, que é o **controlador**) |
| Finalidade | Receber e consolidar pedidos de venda para permitir o processamento logístico (separação, expedição, entrega) e o cumprimento do contrato de compra e venda celebrado entre comprador e produtor/lojista |
| Base legal | Para o controlador (produtor/lojista): **art. 7º, V** (execução do contrato de compra e venda com o comprador). Tratamento pelo GLOP amparado no **art. 39** (execução por conta do controlador). Guarda posterior: **art. 7º, II** (obrigações fiscais/consumeristas) e **art. 16, I** |
| Categorias de titulares | Compradores finais (pessoas naturais); eventualmente PJ/MEI compradoras (dados de representante) |
| Categorias de dados | Nome/razão social; **CPF/CNPJ**; e-mail; telefone; endereço completo (CEP, logradouro, número, complemento, bairro, cidade, UF); descrição do produto; valor da compra; identificador do pedido; plataforma de origem. **Não há tratamento de dados sensíveis** nesta atividade |
| Volume / escala | **Alto** — ingestão automatizada e contínua, potencialmente milhares de pedidos/dia por empresa cliente |
| Destinatários / compartilhamento | Produtor/lojista (controlador); Correios (para postagem/rastreio); VHSYS (para NF-e); Supabase (armazenamento); Netlify (hospedagem SSR). Compartilhamento restrito por RLS ao company_id/tenant_id de origem |
| Transferência internacional | **Possível** — Supabase e Netlify podem processar/armazenar em infraestrutura fora do Brasil, a depender da região do projeto. Salvaguardas: cláusulas contratuais de proteção equivalente e verificação da região de hospedagem (art. 33, I e IX). Recomenda-se fixar região e formalizar cláusulas-padrão |
| Prazo de retenção | Enquanto durar a relação de operação com o produtor/lojista e o processamento do pedido; após, guarda pelo prazo legal aplicável (prescrição do CDC — 5 anos, art. 27; guarda fiscal). Depois, anonimização ou eliminação. Soft-delete com deleted_at e posterior expurgo definitivo |
| Medidas de segurança | RLS multi-tenant por company_id/tenant_id; RBAC (has_permission) por recurso; JWT (Supabase Auth); credenciais de API das plataformas guardadas **write-only**; TLS em trânsito; criptografia em repouso do provedor; trilha de auditoria por triggers; colunas created_by/updated_by/deleted_at; minimização (só campos necessários à logística) |

---

## A.2 Geração de pré-postagem e rastreio Correios

**Referência interna:** ROPA-02 · **Fluxo real:** PPN (pré-postagem), atribuição de código de rastreio e consulta SRO.

| Campo | Descrição |
|---|---|
| Papel do GLOP | **Operador** (por conta do produtor/lojista, **controlador**) |
| Finalidade | Gerar a pré-postagem junto aos Correios, atribuir o código de rastreio ao pedido e acompanhar o status de entrega, viabilizando o cumprimento da obrigação de entrega |
| Base legal | **Art. 7º, V** (execução do contrato de transporte/entrega, essencial à compra e venda); **art. 7º, II** para obrigações acessórias de transporte |
| Categorias de titulares | Compradores finais (destinatários da encomenda); remetente (produtor/lojista) |
| Categorias de dados | Nome do destinatário; endereço completo de entrega; CEP; telefone/e-mail para aviso; dados do objeto (peso/dimensão declarados, valor); código de rastreio; CPF quando exigido para postagem |
| Destinatários / compartilhamento | **Correios** (ECT), como operador/suboperador de transporte e rastreio; produtor/lojista |
| Transferência internacional | Correios: tratamento nacional. Supabase/Netlify: ver ROPA-01 (possível transferência internacional na camada de infraestrutura) |
| Prazo de retenção | Vinculado ao ciclo logístico e à comprovação de entrega; código de rastreio e comprovantes mantidos pelo prazo de prescrição consumerista (5 anos, CDC art. 27) para defesa em reclamações; após, eliminação/anonimização |
| Medidas de segurança | Transmissão via API autenticada aos Correios; RLS por empresa; RBAC; logs de chamada com mascaramento de PII quando possível; retenção mínima do endereço apenas enquanto necessário à entrega e à comprovação |

---

## A.3 Notificação de rastreio ao comprador (e-mail/WhatsApp)

**Referência interna:** ROPA-03 · **Fluxo real:** disparo de e-mail e mensagem WhatsApp com status/código de rastreio.

| Campo | Descrição |
|---|---|
| Papel do GLOP | **Operador** (por conta do produtor/lojista, **controlador**) |
| Finalidade | Informar o comprador sobre o andamento da entrega (código de rastreio, mudanças de status, tentativa de entrega), reduzindo insucesso de entrega e demanda de atendimento |
| Base legal | **Art. 7º, V** (comunicação necessária à execução do contrato de entrega). Para mensagens transacionais de logística, **não** se trata de marketing; comunicações promocionais eventuais exigiriam base própria (art. 7º, IX ou consentimento) e opt-out |
| Categorias de titulares | Compradores finais |
| Categorias de dados | Nome; e-mail; número de telefone/WhatsApp; código de rastreio; status da entrega; identificador do pedido |
| Destinatários / compartilhamento | Provedor de envio de e-mail (SMTP/serviço transacional); provedor de API de WhatsApp (ex.: WhatsApp Cloud API/BSP); produtor/lojista |
| Transferência internacional | **Provável** — provedores de e-mail e de WhatsApp podem processar dados no exterior. Exigir cláusulas de proteção equivalente e/ou hipótese do art. 33; registrar o provedor efetivamente contratado |
| Prazo de retenção | Registro de envio (log de notificação) mantido pelo tempo necessário à comprovação de comunicação e à defesa de reclamações; conteúdo transacional expurgado conforme política; telefone/e-mail seguem a retenção do pedido (ROPA-01) |
| Medidas de segurança | Envio apenas de dados mínimos na mensagem (status + código, sem PII sensível); canais autenticados; supressão de destinatários inválidos; controle de opt-out para comunicações não transacionais; logs de disparo auditáveis |

---

## A.4 Coprodução, split e repasses (dados bancários de coprodutores)

**Referência interna:** ROPA-04 · **Fluxo real:** cadastro de coprodutores/afiliados, regras de comissão, apuração, repasse e split via AppMax.

| Campo | Descrição |
|---|---|
| Papel do GLOP | **Controlador** (define a finalidade do repasse e a prevenção à fraude); **AppMax** como operador/parceiro de pagamento; Supabase como suboperador |
| Finalidade | Apurar comissões de coprodutores/afiliados, executar o split de pagamento e realizar repasses financeiros; prevenir fraudes e erros de repasse; cumprir obrigações contratuais e fiscais |
| Base legal | **Art. 7º, V** (execução do contrato de coprodução/afiliação); **art. 7º, II** (obrigações fiscais e de prevenção à lavagem/fraude, quando aplicável); **art. 7º, IX** (legítimo interesse na prevenção à fraude no repasse), com teste de proporcionalidade |
| Categorias de titulares | Coprodutores; afiliados; representantes de PJ coprodutoras |
| Categorias de dados | Nome/razão social; CPF/CNPJ; **chave PIX**; dados bancários (banco, agência, conta, tipo); e-mail; telefone; percentual/valor de comissão; histórico de repasses. **Dados financeiros — categoria de maior sensibilidade prática** (risco de fraude/estelionato), embora não sejam "sensíveis" no sentido do art. 5º, II |
| Destinatários / compartilhamento | **AppMax** (processamento do split/repasse); instituição financeira/arranjo de pagamento; Supabase (armazenamento); autoridades fiscais quando exigido |
| Transferência internacional | AppMax: processamento nacional (verificar). Infraestrutura Supabase: possível transferência internacional — aplicar salvaguardas do art. 33 |
| Prazo de retenção | Dados bancários mantidos enquanto vigente a relação de coprodução e enquanto houver repasses pendentes; após o encerramento, guarda pelo prazo de prescrição civil/fiscal (obrigações do art. 7º, II; prescrição do CC art. 206) e depois eliminação. Chave PIX/conta devem ser expurgadas assim que cesse a finalidade |
| Medidas de segurança | Armazenamento com criptografia; acesso restrito por RBAC a papéis financeiros; RLS por empresa; mascaramento de conta/chave PIX na interface (exibir apenas dígitos finais); segregação de função (quem cadastra não autoriza repasse); trilha de auditoria reforçada; tokenização junto ao parceiro de pagamento sempre que disponível |

---

## A.5 Emissão de NF-e (VHSYS)

**Referência interna:** ROPA-05 · **Fluxo real:** emissão de NF-e e documentos fiscais (NF-e/CT-e/MDF-e/NFS-e) via VHSYS.

| Campo | Descrição |
|---|---|
| Papel do GLOP | **Operador** (emissão por conta do produtor/lojista **controlador** e emitente fiscal); **VHSYS** como operador/suboperador de emissão |
| Finalidade | Emitir documentos fiscais eletrônicos exigidos para a comercialização e o transporte das mercadorias, cumprindo a legislação tributária |
| Base legal | **Art. 7º, II** (cumprimento de obrigação legal/regulatória fiscal) — base preponderante; **art. 7º, V** de forma acessória |
| Categorias de titulares | Compradores finais (destinatários da NF-e); coprodutores quando emitida nota de comissão; representantes de PJ |
| Categorias de dados | Nome/razão social; CPF/CNPJ; endereço fiscal; itens/produtos; valores; dados fiscais (NCM, tributos); chave de acesso da NF-e |
| Destinatários / compartilhamento | **SEFAZ** e administrações tributárias; **VHSYS**; produtor/lojista; comprador (DANFE); Supabase (armazenamento dos XML/registros) |
| Transferência internacional | Emissão fiscal e SEFAZ: nacional. Infraestrutura de armazenamento: possível transferência internacional (Supabase/Netlify) |
| Prazo de retenção | Documentos fiscais e XML mantidos pelo **prazo legal de guarda fiscal** (regra geral 5 anos, podendo ser maior conforme a legislação tributária aplicável), contados do fato gerador; retenção obrigatória por lei prevalece sobre pedido de eliminação (LGPD, art. 16, I) |
| Medidas de segurança | Integração autenticada com VHSYS; certificado digital protegido; XML armazenado com controle de acesso e RLS; auditoria; retenção segregada dos documentos fiscais |

---

## A.6 Cadastro e autenticação de usuários do GLOP

**Referência interna:** ROPA-06 · **Fluxo real:** Supabase Auth (JWT), auth.users, memberships e RBAC.

| Campo | Descrição |
|---|---|
| Papel do GLOP | **Controlador** (dados dos próprios usuários — produtores/lojistas, coprodutores, colaboradores) |
| Finalidade | Criar e autenticar contas; gerir acesso, papéis e permissões (RBAC); faturar o SaaS; prestar suporte; garantir a segurança da plataforma |
| Base legal | **Art. 7º, V** (execução do contrato de uso da plataforma/SaaS); **art. 7º, II** (obrigações legais, ex.: guarda de registros de acesso — Marco Civil, art. 15); **art. 7º, IX** (legítimo interesse em segurança e prevenção a fraude) |
| Categorias de titulares | Usuários da plataforma: produtores/lojistas, coprodutores/afiliados, colaboradores/administradores |
| Categorias de dados | Nome; e-mail; senha (armazenada como **hash** pelo Supabase Auth, não em texto claro); telefone; identificadores de tenant/company/branch; papel/permissões; dados de faturamento; registros de login (IP, timestamp, user agent) |
| Destinatários / compartilhamento | **Supabase** (Auth/banco); provedor de e-mail transacional (confirmação/recuperação); processador de pagamento do SaaS (faturamento) |
| Transferência internacional | **Provável** — Supabase Auth pode processar dados fora do Brasil conforme a região; aplicar salvaguardas do art. 33 e cláusulas contratuais |
| Prazo de retenção | Enquanto vigente a conta; após o encerramento, dados de conta eliminados/anonimizados, ressalvados os **registros de acesso a aplicações de internet**, guardados por **6 meses** (Marco Civil, art. 15) e dados necessários à defesa/obrigações legais |
| Medidas de segurança | Autenticação JWT; senhas com hash; RBAC granular; RLS; MFA recomendado para papéis administrativos; política de senha; expiração/rotação de tokens; auditoria de acessos; princípio do menor privilégio |

---

## A.7 Logs, auditoria e segurança

**Referência interna:** ROPA-07 · **Fluxo real:** trilha de auditoria por triggers, logs de API, webhooks de entrada/saída, colunas de auditoria.

| Campo | Descrição |
|---|---|
| Papel do GLOP | **Controlador** para logs de segurança/auditoria da própria plataforma; **Operador** quanto a logs que refletem tratamentos feitos por conta do produtor/lojista |
| Finalidade | Registrar operações para segurança da informação, detecção e resposta a incidentes, rastreabilidade, prevenção a fraude, auditoria e cumprimento de obrigações legais (Marco Civil) |
| Base legal | **Art. 7º, II** (guarda de registros — Marco Civil, art. 15); **art. 7º, IX** (legítimo interesse em segurança); **art. 7º, VI** (exercício de direitos em processo) |
| Categorias de titulares | Usuários da plataforma; compradores (quando o log referencia o pedido); coprodutores |
| Categorias de dados | Identificadores de usuário (created_by/updated_by/deleted_by); tenant_id/company_id; ação executada; timestamps; endereço IP; payloads de webhook (podem conter PII do pedido); metadados de requisição de API |
| Destinatários / compartilhamento | Equipe interna de segurança/TI (acesso restrito); Supabase (armazenamento); autoridades mediante ordem legal |
| Transferência internacional | Possível na camada de infraestrutura (Supabase/Netlify); aplicar salvaguardas |
| Prazo de retenção | Registros de acesso a aplicações de internet: **mínimo 6 meses** (Marco Civil, art. 15), podendo ser estendido por determinação; logs de auditoria de segurança conforme política interna e necessidade de defesa; expurgo programado após o prazo |
| Medidas de segurança | Acesso a logs restrito por RBAC ao papel de segurança; imutabilidade/append-only da trilha de auditoria (triggers); mascaramento de PII em payloads de log sempre que viável; retenção mínima; monitoramento e alertas |

---

## A.8 Portal público de rastreio (sem login)

**Referência interna:** ROPA-08 · **Fluxo real:** consulta pública de status por código de rastreio, sem autenticação, expondo apenas status neutro.

| Campo | Descrição |
|---|---|
| Papel do GLOP | **Operador** (disponibiliza a consulta por conta do produtor/lojista **controlador**) |
| Finalidade | Permitir que o comprador acompanhe o status da entrega sem necessidade de conta, informando o código de rastreio, reduzindo atrito e demanda de atendimento |
| Base legal | **Art. 7º, V** (execução do contrato de entrega — informação ao comprador sobre o andamento) |
| Categorias de titulares | Compradores finais (consulentes) |
| Categorias de dados | Entrada: **código de rastreio** (informado pelo consulente). Saída: **status neutro da entrega** (ex.: "em trânsito", "saiu para entrega", "entregue"), **sem exposição de PII** (sem nome, CPF, endereço, telefone) |
| Destinatários / compartilhamento | Público consulente que detenha o código; nenhum compartilhamento adicional de PII |
| Transferência internacional | Página servida via Netlify (SSR) — possível processamento em infraestrutura no exterior; contudo, o dado exposto é minimizado (status neutro) |
| Prazo de retenção | O portal não cria novo repositório de PII: consulta pontual; o status deriva dos registros do pedido (ROPA-01/02). Logs de consulta minimizados e retidos por prazo curto para segurança |
| Medidas de segurança | **Minimização por design**: retorna apenas status neutro; **não** expõe nome, CPF, endereço nem telefone; código de rastreio com entropia suficiente para dificultar enumeração; **rate limiting / anti-enumeração**; ausência de listagem/índice; sem indexação de PII por buscadores; monitoramento de acessos anômalos |

---

## A.9 Consolidado — bases legais, retenção e transferência internacional

| ROPA | Atividade | Papel GLOP | Base legal principal | Retenção-chave | Transf. internacional |
|---|---|---|---|---|---|
| 01 | Ingestão de pedidos (PII comprador) | Operador | Art. 7º, V | 5 anos (CDC) + guarda fiscal | Possível (infra) |
| 02 | Pré-postagem e rastreio Correios | Operador | Art. 7º, V | Ciclo logístico + 5 anos p/ comprovação | Possível (infra) |
| 03 | Notificação de rastreio (e-mail/WhatsApp) | Operador | Art. 7º, V | Log de envio p/ comprovação | Provável (provedores) |
| 04 | Coprodução/split (dados bancários) | Controlador | Art. 7º, V + IX | Vigência + prescrição civil/fiscal | Possível (infra) |
| 05 | Emissão de NF-e (VHSYS) | Operador | Art. 7º, II | Guarda fiscal (5+ anos) | Nacional (fisco) + infra |
| 06 | Cadastro/autenticação de usuários | Controlador | Art. 7º, V + II | Vigência + 6 meses (Marco Civil) | Provável (Supabase) |
| 07 | Logs/auditoria/segurança | Controlador/Operador | Art. 7º, II + IX | Mín. 6 meses (Marco Civil) | Possível (infra) |
| 08 | Portal público de rastreio | Operador | Art. 7º, V | Sem novo repositório de PII | Possível (infra, dado minimizado) |

**Nota sobre transferência internacional (LGPD, art. 33):** onde houver processamento por Supabase/Netlify e provedores de e-mail/WhatsApp fora do Brasil, adotar como salvaguardas: (i) cláusulas contratuais específicas de proteção equivalente (art. 33, VIII); (ii) fixação de região de hospedagem quando possível; (iii) avaliação de adequação; e (iv) atualização deste registro a cada mudança de subprocessador. Manter lista de subprocessadores publicada e versionada.

---

# Parte B — Relatório de Impacto à Proteção de Dados Pessoais (RIPD/DPIA)

## B.1 Metodologia e critérios de risco

Este RIPD segue o art. 5º, XVII, e o art. 38 da LGPD, o Guia de RIPD da ANPD e, subsidiariamente, o art. 35 do GDPR. Foram selecionadas as **três operações de maior risco** do GLOP:

1. **Ingestão de PII de compradores em escala** (ROPA-01);
2. **Dados bancários de coprodutores no split/repasses** (ROPA-04);
3. **Portal público de rastreio** (ROPA-08).

O risco de cada cenário é medido pelo produto **Probabilidade × Impacto**, cada eixo em escala 1–5:

| Nível | Probabilidade | Impacto ao titular |
|---|---|---|
| 1 | Raro | Insignificante |
| 2 | Improvável | Baixo |
| 3 | Possível | Moderado |
| 4 | Provável | Alto |
| 5 | Quase certo | Grave/irreversível |

Classificação do risco (score = P × I): **1–4 Baixo · 5–9 Moderado · 10–14 Alto · 15–25 Crítico**. Cada risco é avaliado **antes** (inerente) e **depois** (residual) das medidas mitigatórias.

Critérios de **necessidade e proporcionalidade** aplicados a cada operação: (a) a finalidade é legítima, específica e informada? (b) o tratamento é adequado e necessário à finalidade (minimização)? (c) há base legal válida? (d) os riscos ao titular são proporcionais ao benefício e mitigáveis?

---

## B.2 Operação 1 — Ingestão de PII de compradores em escala

### B.2.1 Descrição
O GLOP puxa, por API, pedidos de Monetizze/Hotmart/Kiwify e Shopify/WooCommerce/Nuvemshop/Mercado Livre, capturando nome, CPF/CNPJ, e-mail, telefone e endereço completo de milhares de compradores, para viabilizar a logística. Trata-se de tratamento de **grande volume**, contínuo e automatizado, sob o papel de **operador** por conta de múltiplos produtores/lojistas (multi-tenant).

### B.2.2 Necessidade e proporcionalidade
- **Finalidade legítima e específica:** processar e entregar pedidos (art. 7º, V). ✅
- **Necessidade/minimização:** os campos coletados (identificação, contato e endereço) são os **estritamente necessários** à separação, emissão fiscal e entrega. Não se coletam dados sensíveis. Recomenda-se **não** importar campos irrelevantes disponibilizados pelas plataformas. ✅ (com ressalva de auditoria periódica de campos)
- **Base legal:** válida (execução de contrato). ✅
- **Proporcionalidade:** o benefício (entrega e cumprimento contratual) justifica o tratamento; o risco decorre principalmente da **escala** e do **isolamento multi-tenant**, mitigável por RLS/criptografia. ✅

### B.2.3 Riscos aos titulares

| # | Risco | Prob. | Impacto | Score | Nível |
|---|---|---|---|---|---|
| R1.1 | Vazamento de PII por falha de isolamento multi-tenant (acesso cruzado entre empresas) | 2 | 5 | 10 | Alto |
| R1.2 | Acesso indevido por credencial comprometida / escalonamento de privilégio | 3 | 4 | 12 | Alto |
| R1.3 | Uso secundário indevido dos dados (finalidade diversa, ex.: marketing sem base) | 3 | 3 | 9 | Moderado |
| R1.4 | Comprometimento de credencial de API das plataformas de origem | 2 | 4 | 8 | Moderado |
| R1.5 | Transferência internacional sem salvaguarda adequada (infra no exterior) | 3 | 3 | 9 | Moderado |
| R1.6 | Retenção excessiva de PII após cessada a finalidade | 3 | 3 | 9 | Moderado |

### B.2.4 Medidas mitigatórias
- **RLS multi-tenant** por company_id/tenant_id em todas as tabelas de negócio — cada consulta só enxerga as linhas da empresa do usuário autenticado (mitiga R1.1).
- **RBAC (has_permission)** por recurso/ação e princípio do menor privilégio; MFA para papéis administrativos (mitiga R1.2).
- **Credenciais de API guardadas write-only** e cifradas; rotação periódica; ausência de leitura em claro na interface (mitiga R1.4).
- **Minimização de campos** na ingestão e revisão periódica do mapa de campos importados; vedação de uso secundário sem base legal e sem instrução do controlador (mitiga R1.3).
- **Criptografia** em trânsito (TLS) e em repouso; segregação de ambientes.
- **Transferência internacional:** cláusulas contratuais de proteção equivalente e fixação de região (mitiga R1.5).
- **Política de retenção e expurgo** com soft-delete + eliminação definitiva ao fim do prazo legal; anonimização para BI (mitiga R1.6).
- **Trilha de auditoria** por triggers e monitoramento de acessos anômalos.

### B.2.5 Risco residual
| # | Score inerente | Score residual | Nível residual |
|---|---|---|---|
| R1.1 | 10 | 3 | Baixo |
| R1.2 | 12 | 6 | Moderado |
| R1.3 | 9 | 4 | Baixo |
| R1.4 | 8 | 4 | Baixo |
| R1.5 | 9 | 6 | Moderado |
| R1.6 | 9 | 4 | Baixo |

**Risco residual global da operação: Moderado**, aceitável mediante manutenção contínua dos controles e auditoria periódica do isolamento multi-tenant.

---

## B.3 Operação 2 — Dados bancários de coprodutores (split/repasses)

### B.3.1 Descrição
O GLOP trata **chave PIX e dados bancários** de coprodutores/afiliados para apurar comissões e executar repasses/split via AppMax. Embora não sejam dados "sensíveis" no sentido do art. 5º, II, são **dados financeiros de alto valor de ataque** (fraude, estelionato, desvio de repasse). O GLOP tende a atuar como **controlador**.

### B.3.2 Necessidade e proporcionalidade
- **Finalidade:** executar repasses devidos por contrato de coprodução (art. 7º, V) e prevenir fraude (art. 7º, IX). ✅
- **Necessidade/minimização:** os dados bancários são indispensáveis ao repasse; deve-se coletar **apenas** o necessário (uma chave PIX ou um conjunto bancário), evitando redundância. ✅
- **Proporcionalidade:** o legítimo interesse na prevenção à fraude no repasse (art. 7º, IX) passa no teste — finalidade legítima, necessidade (evitar desvio a conta de terceiro) e balanceamento (medidas de segurança e transparência ao coprodutor). ✅

### B.3.3 Riscos aos titulares

| # | Risco | Prob. | Impacto | Score | Nível |
|---|---|---|---|---|---|
| R2.1 | Vazamento/exfiltração de chave PIX e dados bancários | 2 | 5 | 10 | Alto |
| R2.2 | Fraude no repasse (adulteração de conta de destino) | 3 | 5 | 15 | Crítico |
| R2.3 | Acesso interno indevido (ausência de segregação de função) | 3 | 4 | 12 | Alto |
| R2.4 | Exposição na interface (dados bancários em claro na tela) | 3 | 4 | 12 | Alto |
| R2.5 | Compartilhamento com parceiro de pagamento sem base/DPA | 2 | 4 | 8 | Moderado |
| R2.6 | Retenção de dados bancários após fim da relação | 3 | 3 | 9 | Moderado |

### B.3.4 Medidas mitigatórias
- **Criptografia em repouso** dos campos bancários/PIX e, quando disponível, **tokenização** junto ao parceiro de pagamento (mitiga R2.1).
- **Segregação de função (SoD):** quem cadastra a conta não autoriza o repasse; **dupla aprovação** para alteração de dados bancários; alerta e período de segurança após troca de chave/conta (mitiga R2.2, R2.3).
- **Mascaramento na interface:** exibir apenas dígitos finais da conta/chave; RBAC restrito a papel financeiro (mitiga R2.4).
- **DPA com AppMax** e verificação de conformidade do parceiro; base legal e finalidade documentadas (mitiga R2.5).
- **RLS** por empresa; **trilha de auditoria reforçada** de todo acesso e alteração de dados bancários.
- **Política de retenção:** expurgo da chave/conta assim que cesse a finalidade e cumprido o prazo fiscal/prescricional (mitiga R2.6).
- **Notificação ao coprodutor** sobre alteração de dados bancários (detecção de fraude).

### B.3.5 Risco residual
| # | Score inerente | Score residual | Nível residual |
|---|---|---|---|
| R2.1 | 10 | 4 | Baixo |
| R2.2 | 15 | 6 | Moderado |
| R2.3 | 12 | 4 | Baixo |
| R2.4 | 12 | 3 | Baixo |
| R2.5 | 8 | 3 | Baixo |
| R2.6 | 9 | 3 | Baixo |

**Risco residual global da operação: Moderado**, condicionado à implementação efetiva de dupla aprovação e notificação de troca de conta — controles indispensáveis à mitigação do risco crítico de fraude no repasse (R2.2).

---

## B.4 Operação 3 — Portal público de rastreio

### B.4.1 Descrição
Página pública, **sem login**, onde o comprador informa o código de rastreio e recebe o **status neutro** da entrega. O risco típico de portais públicos é a **exposição de PII a qualquer pessoa que detenha (ou adivinhe) o identificador** e a **enumeração** de códigos.

### B.4.2 Necessidade e proporcionalidade
- **Finalidade:** informar o comprador sobre a entrega sem atrito de cadastro (art. 7º, V). ✅
- **Necessidade/minimização:** a consulta pública **só** deve retornar status neutro; **nenhum** dado pessoal (nome, CPF, endereço, telefone) deve ser exposto. Essa minimização por design é o que torna o portal proporcional. ✅
- **Proporcionalidade:** benefício claro ao titular (autoatendimento) com risco baixo quando a saída é minimizada e há proteção anti-enumeração. ✅

### B.4.3 Riscos aos titulares

| # | Risco | Prob. | Impacto | Score | Nível |
|---|---|---|---|---|---|
| R3.1 | Exposição de PII do comprador na resposta pública | 2 | 5 | 10 | Alto |
| R3.2 | Enumeração de códigos de rastreio (varredura para obter status/PII de terceiros) | 3 | 3 | 9 | Moderado |
| R3.3 | Indexação por buscadores de páginas com PII | 2 | 4 | 8 | Moderado |
| R3.4 | Correlação status + código para inferência sobre o titular | 2 | 2 | 4 | Baixo |
| R3.5 | Abuso/scraping automatizado (DoS/coleta em massa) | 3 | 2 | 6 | Moderado |

### B.4.4 Medidas mitigatórias
- **Minimização por design:** a resposta pública retorna **apenas status neutro**, sem nome, CPF, endereço ou telefone (mitiga R3.1, elimina a causa raiz).
- **Códigos com entropia suficiente** e não sequenciais, dificultando adivinhação (mitiga R3.2).
- **Rate limiting / anti-enumeração** por IP e por sessão; CAPTCHA/desafio em volume anômalo (mitiga R3.2, R3.5).
- **Ausência de indexação:** noindex/robots e ausência de listagem, evitando cache de PII em buscadores (mitiga R3.3).
- **Sem repositório novo de PII:** o portal apenas deriva status dos registros existentes; logs de consulta minimizados e de retenção curta.
- **Monitoramento** de padrões de acesso anômalos.

### B.4.5 Risco residual
| # | Score inerente | Score residual | Nível residual |
|---|---|---|---|
| R3.1 | 10 | 2 | Baixo |
| R3.2 | 9 | 4 | Baixo |
| R3.3 | 8 | 2 | Baixo |
| R3.4 | 4 | 2 | Baixo |
| R3.5 | 6 | 3 | Baixo |

**Risco residual global da operação: Baixo**, desde que mantida a minimização da resposta (status neutro) e a proteção anti-enumeração como invariantes do produto.

---

## B.5 Matriz consolidada de riscos (visão executiva)

| Operação | Maior risco identificado | Score inerente | Score residual | Nível residual |
|---|---|---|---|---|
| Ingestão de PII em escala (ROPA-01) | Acesso indevido / falha de isolamento (R1.2/R1.1) | 12 | 6 | Moderado |
| Dados bancários de coprodutores (ROPA-04) | Fraude no repasse (R2.2) | 15 | 6 | Moderado |
| Portal público de rastreio (ROPA-08) | Exposição de PII pública (R3.1) | 10 | 2 | Baixo |

Mapa de calor (após medidas):

| Impacto \ Prob. | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| **5 (Grave)** | | | | | |
| **4 (Alto)** | | | | | |
| **3 (Moderado)** | | R1.1 | R1.2, R1.5, R2.2 | | |
| **2 (Baixo)** | R3.1, R3.3, R3.4 | R1.3, R1.4, R1.6, R2.1, R2.3-R2.6, R3.2, R3.5 | | | |
| **1 (Insignif.)** | | | | | |

Nenhum risco residual permanece nas faixas **Alto** ou **Crítico** após as medidas, desde que os controles sejam efetivamente implementados e mantidos.

---

## B.6 Plano de tratamento de riscos e risco residual

| Prioridade | Ação de tratamento | Operação | Responsável | Prazo sugerido |
|---|---|---|---|---|
| 1 | Implementar dupla aprovação + notificação de troca de dados bancários | ROPA-04 | Engenharia + Financeiro | 16 de julho de 2026 |
| 2 | Auditoria periódica de políticas RLS e teste de isolamento multi-tenant | ROPA-01/07 | Segurança/DevOps | Trimestral |
| 3 | Confirmar minimização (status neutro) e anti-enumeração no portal público | ROPA-08 | Engenharia | 16 de julho de 2026 |
| 4 | Formalizar DPAs e lista de subprocessadores (Supabase, Netlify, VHSYS, AppMax, e-mail, WhatsApp) | Todas | Jurídico/DPO | 16 de julho de 2026 |
| 5 | Definir e automatizar política de retenção/expurgo por atividade | Todas | Engenharia + DPO | 16 de julho de 2026 |
| 6 | Fixar região de hospedagem e salvaguardas de transferência internacional | Todas | DevOps/Jurídico | 16 de julho de 2026 |
| 7 | Mascaramento de PII em logs/webhooks | ROPA-07 | Engenharia | 16 de julho de 2026 |

**Conclusão sobre risco residual:** após a implementação das medidas, o risco residual das três operações críticas situa-se entre **Baixo e Moderado**, considerado **aceitável** e proporcional às finalidades, sob monitoramento contínuo e revisão periódica deste RIPD.

---

## B.7 Parecer do Encarregado (DPO)

Na qualidade de Encarregado pelo Tratamento de Dados Pessoais de LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA / [NOME FANTASIA: GLOP], após análise das operações de tratamento descritas neste registro e da avaliação de impacto das operações de maior risco, **manifesto o seguinte parecer**:

1. As operações possuem **finalidades legítimas, específicas e informadas** e **bases legais adequadas** (predominância do art. 7º, V, e art. 7º, II, com uso fundamentado do art. 7º, IX para segurança e prevenção à fraude), atendendo aos princípios do art. 6º da LGPD, em especial **finalidade, adequação, necessidade e segurança**.
2. A arquitetura multi-tenant com **RLS por company_id/tenant_id**, **RBAC (has_permission)**, **soft-delete**, **trilha de auditoria por triggers** e **credenciais de API write-only** constitui base de segurança **compatível** com o art. 46 da LGPD, desde que submetida a **testes periódicos de isolamento** e a **gestão de retenção** ativa.
3. O **portal público de rastreio** é considerado **conforme** por adotar **minimização por design** (exposição apenas de status neutro) e proteção **anti-enumeração** — invariantes que **não podem** ser flexibilizados sem novo RIPD.
4. O tratamento de **dados bancários de coprodutores** é o de maior risco intrínseco (fraude no repasse). Recomendo, como **condição** para a manutenção do risco em nível aceitável, a implementação efetiva de **dupla aprovação, notificação de alteração de conta e mascaramento**, além de DPA com o parceiro de pagamento.
5. Nas **transferências internacionais** decorrentes da infraestrutura (Supabase/Netlify) e de provedores de e-mail/WhatsApp, recomendo **cláusulas contratuais de proteção equivalente**, fixação de região quando viável, e **atualização deste registro a cada mudança de subprocessador** (art. 33).

**Parecer final:** as operações podem prosseguir, com **risco residual aceitável (Baixo a Moderado)**, **condicionado** à execução do Plano de tratamento de riscos (seção B.6) e à revisão periódica deste documento. Determino a reavaliação em caso de mudança material de finalidade, fluxo, subprocessador ou incidente relevante.

_____________________________________
a ser designado pela administração — Encarregado (DPO)
lemoncapsencapsulados@gmail.com
16 de julho de 2026

---

# Engenharia Jurídica & Governança

## (a) Fundamentação — por que as cláusulas existem e qual norma as embasa

- **Existência do ROPA e do RIPD** — LGPD, art. 37 (o controlador e o operador devem manter registro das operações de tratamento) e art. 38 (a ANPD pode determinar RIPD); art. 5º, XVII (conceito de RIPD). Análogos ao art. 30 e art. 35 do GDPR. Fundamentam a **estrutura por atividade** e a **avaliação de impacto das operações de risco**.
- **Definição de papéis Operador/Controlador** — LGPD, art. 5º, VI e VII, e arts. 39 e 42. Justifica a **seção 2** (dualidade) e a exigência de **DPA** com clientes e subprocessadores. A correta qualificação define quem responde perante o titular e a ANPD.
- **Bases legais** — LGPD, art. 7º (dados comuns) e art. 11 (sensíveis). O uso predominante do **art. 7º, V** (execução de contrato) reflete a natureza logística; o **art. 7º, II** ancora guarda fiscal e registros do **Marco Civil (Lei 12.965/2014, art. 15)**; o **art. 7º, IX** (legítimo interesse) fundamenta segurança e prevenção à fraude, sempre com teste de proporcionalidade e salvaguardas (art. 10).
- **Minimização e finalidade** — LGPD, art. 6º, I (finalidade), II (adequação) e III (necessidade). Embasam a **minimização da resposta do portal público** e a **auditoria de campos importados** na ingestão.
- **Segurança e prevenção** — LGPD, art. 6º, VII e VIII, e art. 46. Fundamentam RLS, RBAC, criptografia, mascaramento, segregação de função e trilha de auditoria.
- **Retenção e eliminação** — LGPD, art. 15 e art. 16 (a conservação é admitida para cumprimento de obrigação legal, estudo por órgão de pesquisa, uso exclusivo do controlador vedado o acesso de terceiro, e exercício regular de direitos). Justifica a guarda fiscal e o prazo do Marco Civil, prevalecendo sobre pedidos de eliminação quando houver dever legal.
- **Direitos do titular** — LGPD, art. 18. O registro sustenta a capacidade de responder a acesso, correção, portabilidade e eliminação.
- **Relação de consumo** — CDC (Lei 8.078/1990): prazo prescricional de 5 anos (art. 27) fundamenta a retenção de comprovantes de entrega e de pedidos para defesa; deveres de informação (arts. 6º e 31).
- **Transferência internacional** — LGPD, art. 33 e art. 34. Fundamenta as salvaguardas contratuais para Supabase/Netlify e provedores estrangeiros.
- **Responsabilidade civil** — Código Civil (Lei 10.406/2002), arts. 186, 187 e 927, e LGPD arts. 42-45, embasam a alocação de responsabilidade entre controlador e operador.
- **GDPR (quando aplicável)** — arts. 30 e 35, para titulares/operações sujeitas ao regulamento europeu.

## (b) Riscos que o documento mitiga

- **Sanções da ANPD** por ausência de registro de operações e de RIPD (LGPD, art. 52).
- **Responsabilização por incidentes** por falta de demonstração de governança e de medidas de segurança (accountability, art. 6º, X).
- **Vazamento cross-tenant** e acesso indevido, ao formalizar e testar RLS/RBAC.
- **Fraude no repasse** de coprodutores, ao exigir segregação de função e dupla aprovação.
- **Exposição de PII em portal público**, ao fixar minimização e anti-enumeração como invariantes.
- **Transferência internacional irregular**, ao impor salvaguardas e lista de subprocessadores.
- **Retenção indevida/excessiva**, ao definir prazos e expurgo por atividade.
- **Insegurança na relação com clientes (produtores/lojistas)**, ao deixar clara a divisão de papéis e a necessidade de DPA.

## (c) Checklist de implementação

- [ ] Preencher todos os placeholders (LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, 55.836.075/0001-07, Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, a ser designado pela administração, lemoncapsencapsulados@gmail.com, https://glop-logistica.netlify.app, 16 de julho de 2026).
- [ ] Formalizar e nomear o Encarregado (DPO) e publicar canal de contato (LGPD, art. 41).
- [ ] Celebrar **DPA** com cada cliente produtor/lojista (GLOP operador).
- [ ] Celebrar/atualizar DPA com subprocessadores: Supabase, Netlify, VHSYS, AppMax, provedor de e-mail, provedor de WhatsApp.
- [ ] Publicar e versionar **lista de subprocessadores**.
- [ ] Verificar e fixar **região de hospedagem** (Supabase/Netlify); registrar salvaguardas de transferência internacional.
- [ ] Confirmar **políticas RLS** em todas as tabelas de negócio e criar teste automatizado de isolamento multi-tenant.
- [ ] Confirmar **RBAC (has_permission)** e menor privilégio; habilitar **MFA** para papéis administrativos.
- [ ] Garantir **credenciais de API write-only** e rotação.
- [ ] Implementar **dupla aprovação + notificação** para alteração de dados bancários de coprodutores.
- [ ] Implementar **mascaramento** de dados bancários/PIX na interface.
- [ ] Confirmar **minimização (status neutro)** e **anti-enumeração/rate limiting** no portal público; aplicar noindex.
- [ ] Implementar **mascaramento de PII em logs/webhooks**.
- [ ] Definir e automatizar **política de retenção/expurgo** por atividade (soft-delete + eliminação definitiva).
- [ ] Estabelecer **plano de resposta a incidentes** e fluxo de comunicação à ANPD e aos titulares (LGPD, art. 48).
- [ ] Definir fluxo de atendimento aos **direitos do titular** (art. 18).
- [ ] Validação final por **advogado(a) habilitado(a)**.

## (d) Matriz RACI

| Atividade / Entregável | DPO/Encarregado | Jurídico | Engenharia/DevOps | Segurança | Financeiro | Diretoria |
|---|---|---|---|---|---|---|
| Manutenção do ROPA | A | R | C | C | I | I |
| Elaboração/revisão do RIPD | A | R | C | C | I | I |
| DPAs com clientes e subprocessadores | C | A/R | I | I | I | I |
| Políticas RLS e teste de isolamento | C | I | R | A | I | I |
| RBAC / MFA / menor privilégio | C | I | R | A | I | I |
| Controles de dados bancários (SoD, mascaramento) | C | C | R | C | A | I |
| Portal público (minimização/anti-enumeração) | A | I | R | C | I | I |
| Retenção e expurgo | A | C | R | C | C | I |
| Transferência internacional / região | C | A | R | C | I | I |
| Resposta a incidentes | A | C | R | R | I | I |
| Atendimento a direitos do titular | A/R | C | C | I | I | I |
| Aprovação final e orçamento | I | C | I | I | I | A/R |

Legenda: **R** = Responsável (executa); **A** = Aprovador (responde final); **C** = Consultado; **I** = Informado.

## (e) Plano de revisão

- **Periodicidade ordinária:** revisão **anual** completa do ROPA e do RIPD.
- **Revisão trimestral** dos controles de segurança (teste de isolamento RLS, RBAC, retenção).
- **Gatilhos de revisão extraordinária (imediata):**
  - Nova atividade de tratamento, nova finalidade ou nova categoria de dado.
  - Inclusão/substituição de subprocessador (ex.: novo provedor de pagamento, e-mail, WhatsApp, mudança de região de hospedagem).
  - Alteração de fluxo com dados bancários ou com o portal público.
  - **Incidente de segurança** ou comunicação à ANPD.
  - Mudança legislativa/regulatória (nova resolução da ANPD, alteração da LGPD, CDC, Marco Civil).
  - Determinação da ANPD ou decisão judicial.
- **Registro:** toda revisão gera nova versão na tabela de Controle de versão.

## (f) Controle de versão

| Versão | Data | Autor | Mudança |
|---|---|---|---|
| 1.0 | 16 de julho de 2026 | a ser designado pela administração / Chief Legal AI (minuta) | Emissão inicial do ROPA (8 atividades) e do RIPD (3 operações de risco) |
| | | | |

---

_Fim do documento. Minuta sujeita a revisão jurídica antes de uso em produção._
