> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# Política de Descarte e Eliminação Segura de Dados e Mídias

**LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA** — Nome fantasia **[NOME FANTASIA: GLOP]** (Global Logistics Platform)
**CNPJ:** 55.836.075/0001-07 — **Endereço:** Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190
**Encarregado pelo Tratamento de Dados (DPO):** a ser designado pela administração — **E-mail:** lemoncapsencapsulados@gmail.com
**Versão:** 1.0 — **Data de vigência:** 16 de julho de 2026 — **Classificação:** Interno / Confidencial

---

## 1. Objetivo

Esta Política estabelece as regras, os métodos técnicos, os prazos e as evidências obrigatórias para o **descarte, a eliminação, a anonimização e a sanitização segura** de dados pessoais, dados fiscais, mídias e demais ativos de informação tratados pela plataforma **GLOP (Global Logistics Platform)**, SaaS de logística e ERP voltado a operações de dropshipping e infoprodutos no Brasil.

Os objetivos específicos são:

1. Garantir que dados pessoais e sensíveis não permaneçam armazenados por prazo superior ao necessário à finalidade que justificou sua coleta, em observância aos princípios da **necessidade**, **adequação** e **finalidade** (art. 6º, I, II e III, da Lei nº 13.709/2018 — LGPD).
2. Assegurar que a **eliminação a pedido do titular** (art. 18, VI, da LGPD) seja atendida de forma tempestiva, rastreável e tecnicamente irreversível, ressalvadas as hipóteses de guarda obrigatória.
3. Definir os métodos de descarte aplicáveis à arquitetura real do GLOP — **soft-delete** com trilha de auditoria, **hard-delete** físico, **anonimização** e **pseudonimização** — e os critérios de escolha entre eles.
4. Estabelecer a **sanitização de mídias** (arquivos em Supabase Storage, documentos fiscais, comprovantes, etiquetas de pré-postagem) e de dispositivos.
5. Documentar a **dupla natureza** do GLOP perante a LGPD: **OPERADOR** (quando trata dados do COMPRADOR em nome do produtor/lojista CONTROLADOR) e **CONTROLADOR** (quando trata dados de seus próprios usuários, colaboradores e prospects).
6. Produzir e conservar **registro e evidência de descarte** aptos a demonstrar conformidade (accountability — art. 6º, X, da LGPD).

---

## 2. Escopo

### 2.1. Escopo material

Esta Política aplica-se a todo dado pessoal, dado pessoal sensível, dado fiscal, credencial, log, backup e mídia armazenados, processados ou transmitidos por meio do GLOP, independentemente do meio (banco de dados **Supabase/PostgreSQL**, **Supabase Storage**, logs de aplicação, backups, caches, arquivos exportados, e-mails, notificações via WhatsApp/e-mail e cópias em ambientes dos sub-operadores).

Abrange, de modo não exaustivo, as seguintes categorias tratadas pelos fluxos reais da plataforma:

| Categoria de dado | Origem / fluxo GLOP | Natureza LGPD do GLOP |
|---|---|---|
| PII do COMPRADOR (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto, valor) | Ingestão via API de gateways (Monetizze, Hotmart, Kiwify) e e-commerces (Shopify, WooCommerce, Nuvemshop, Mercado Livre) | Operador (em nome do produtor/lojista) |
| Dados de transporte e rastreio (pré-postagem PPN, código SRO, endereço de entrega) | Integração Correios; notificação ao comprador por e-mail/WhatsApp | Operador |
| Documentos fiscais (NF-e, DANFE, chave de acesso) | Emissão via VHSYS | Operador (dado do emitente/destinatário) |
| Dados financeiros de coprodução e split (coprodutores, afiliados, comissão, apuração, repasses, PIX, dados bancários) | Módulo de Coprodução & Split; split via AppMax | Operador e/ou Controlador conforme o titular |
| Dados de usuários e colaboradores do GLOP (login, e-mail, perfil, permissões, logs de acesso) | Supabase Auth (JWT), RBAC, memberships | Controlador |
| Logs, trilhas de auditoria e metadados | Triggers de auditoria, colunas de auditoria em todo registro | Controlador (do log) |
| Mídias e arquivos (comprovantes, etiquetas, uploads, exportações) | Supabase Storage (bucket por domínio) | Operador e/ou Controlador |

### 2.2. Escopo subjetivo

Vincula todos os colaboradores, prestadores, administradores de sistema, desenvolvedores, encarregado (DPO) e quaisquer terceiros com acesso lógico ou físico aos ativos do GLOP, bem como os **sub-operadores** contratados (Supabase e Netlify — infraestrutura; VHSYS — NF-e; Correios — transporte; gateways Monetizze/AppMax/Hotmart/Kiwify; provedores de WhatsApp/e-mail), no que se refere às obrigações repassadas contratualmente.

### 2.3. Exclusões

Não estão no escopo desta Política os dados anonimizados de forma irreversível (que, nos termos do art. 12 da LGPD, deixam de ser dados pessoais), salvo quanto à validação do próprio processo de anonimização.

---

## 3. Definições

1. **Descarte / Eliminação:** término do tratamento de um dado, com exclusão do ambiente de produção, observado o método técnico aplicável.
2. **Soft-delete (exclusão lógica):** marcação do registro como inativo mediante preenchimento das colunas `deleted_at`, `deleted_by` e `reason_deleted`, mantendo o dado fisicamente no banco para fins de integridade referencial, reversão e auditoria, com filtragem obrigatória `deleted_at is null` em toda leitura. **Não** constitui eliminação para fins de LGPD.
3. **Hard-delete (exclusão física):** remoção definitiva e irreversível do registro do banco de dados, dos backups elegíveis, dos caches e das mídias associadas.
4. **Anonimização:** processo pelo qual um dado perde a possibilidade de associação, direta ou indireta, a um indivíduo, considerados meios técnicos razoáveis e disponíveis (art. 5º, XI, da LGPD). Resultado irreversível; dado deixa de ser pessoal.
5. **Pseudonimização:** tratamento pelo qual o dado perde a possibilidade de associação direta a um titular sem o uso de informação adicional mantida em ambiente controlado e segregado (art. 13, §4º, da LGPD). É **reversível** e permanece dado pessoal.
6. **Sanitização de mídia:** processo de tornar irrecuperável a informação contida em arquivos, objetos de storage ou dispositivos (ex.: clear, purge, destruição — referência NIST SP 800-88).
7. **Retenção:** período durante o qual um dado deve ser conservado por exigência legal, regulatória, contratual ou de exercício de direitos.
8. **Titular:** pessoa natural a quem se referem os dados pessoais (art. 5º, V, da LGPD).
9. **Controlador / Operador:** conforme art. 5º, VI e VII, da LGPD.

---

## 4. Princípios de Governança do Descarte

O descarte no GLOP observa:

1. **Minimização e necessidade:** eliminar tão logo cesse a finalidade e o prazo legal de guarda.
2. **Irreversibilidade proporcional:** o método deve ser adequado à sensibilidade do dado e ao risco. Dados sensíveis e financeiros (PIX, bancários, CPF) exigem hard-delete ou anonimização, não apenas soft-delete.
3. **Segregação de funções:** quem solicita o descarte não é, em regra, quem o executa e o valida (ver Matriz RACI).
4. **Prestação de contas (accountability):** todo descarte gera evidência conservável.
5. **Segurança por padrão e desde a concepção** (art. 46 e 47 da LGPD; privacy by design): rotinas de expurgo automatizadas e credenciais de API write-only.
6. **Continuidade e auditabilidade:** o descarte não pode comprometer a integridade referencial nem apagar trilhas de auditoria exigíveis.

---

## 5. Métodos de Descarte no GLOP

### 5.1. Soft-delete (exclusão lógica) — padrão operacional interno

O GLOP adota, por padrão arquitetural, o **soft-delete**: nenhum registro de negócio sofre `DELETE` físico em operação rotineira. A exclusão é realizada por:

- `UPDATE ... SET deleted_at = now(), deleted_by = <uuid>, reason_deleted = '<motivo>'`;
- filtragem obrigatória `deleted_at is null` em toda leitura da aplicação;
- disparo automático dos triggers de auditoria (`tg_write_audit`) e de atualização (`tg_touch_row`).

**Função e limites:** o soft-delete atende à reversibilidade operacional (correção de erro, retorno de pedido, estorno) e preserva integridade referencial em cadeias como *Entrada → Financeiro → Estoque → Expedição → CRM*. **Contudo, o soft-delete NÃO satisfaz, por si só, o direito de eliminação do art. 18, VI, da LGPD**, pois o dado permanece armazenado. Registros em soft-delete permanecem sujeitos aos prazos de retenção e, ao término destes, passam obrigatoriamente por **hard-delete ou anonimização** (Seção 8).

### 5.2. Hard-delete (exclusão física)

Aplicável quando:

1. o titular exerce o direito de eliminação e não incide hipótese de guarda obrigatória (Seção 7);
2. expira o prazo de retenção de um registro previamente em soft-delete;
3. determinação legal, judicial ou do controlador (nas operações em que o GLOP atua como operador).

**Procedimento:** remoção do registro em produção via rotina controlada (Edge Function/rotina administrativa com credencial de execução restrita), incluindo (a) o registro na tabela de origem; (b) linhas dependentes em tabelas relacionadas quando não anonimizáveis; (c) objetos de mídia associados no Supabase Storage; (d) entradas em caches e exportações; (e) propagação de purga aos backups conforme o ciclo definido na Seção 8.5. O hard-delete preserva, quando exigível, o **registro de evidência de descarte** (Seção 9), que não contém o dado eliminado, apenas metadados da operação.

### 5.3. Anonimização

Empregada quando há interesse legítimo ou obrigação de conservar dados para **estatística, BI, faturamento agregado e melhoria do serviço**, mas sem necessidade de identificar o titular. Técnicas admitidas:

- supressão de identificadores diretos (nome, CPF/CNPJ, e-mail, telefone, endereço);
- generalização (ex.: CEP reduzido a região; data reduzida a mês/ano);
- agregação e supressão de outliers para evitar reidentificação;
- substituição irreversível de chaves de correlação.

A anonimização deve resistir a tentativas razoáveis de reidentificação (art. 12, §1º, LGPD). Dados anonimizados alimentam KPIs/BI via **RPC e materialized views** com anon/authenticated revogados para não vazar cross-tenant. O processo de anonimização é validado e documentado antes de considerar o dado fora do regime da LGPD.

### 5.4. Pseudonimização

Utilizada em ambientes de **desenvolvimento, homologação, testes e análise** e como medida de segurança em produção, quando a identificação plena não é necessária de forma contínua. A tabela de correspondência (informação adicional) é mantida em ambiente segregado, cifrado e com acesso restrito por RBAC. Por ser reversível, o dado pseudonimizado **permanece dado pessoal** e sujeito a esta Política e aos prazos de retenção.

### 5.5. Critério de escolha do método

| Situação | Método padrão |
|---|---|
| Exclusão rotineira reversível (erro, estorno, retorno) | Soft-delete |
| Eliminação a pedido do titular sem guarda obrigatória | Hard-delete (+ anonimização de registros dependentes não elimináveis) |
| Fim de prazo de retenção com utilidade estatística | Anonimização |
| Dado necessário só de forma agregada em BI | Anonimização |
| Uso em dev/homologação/testes | Pseudonimização |
| Dado sensível/financeiro (PIX, bancário) fora de guarda obrigatória | Hard-delete |

---

## 6. Sanitização de Mídias e Dispositivos

### 6.1. Objetos no Supabase Storage

Mídias tratadas pelo GLOP incluem comprovantes, etiquetas de pré-postagem (PPN), DANFE/NF-e, uploads de usuários e exportações. Ao descarte:

1. remoção do objeto do bucket de origem (bucket por domínio);
2. eliminação de versões e cópias derivadas (miniaturas, renders, exportações temporárias);
3. invalidação de URLs assinadas eventualmente emitidas;
4. propagação da remoção ao ciclo de backup do Storage (Seção 8.5);
5. registro de evidência (Seção 9).

### 6.2. Arquivos exportados e temporários

Exportações (CSV/PDF/planilhas) geradas para o usuário têm prazo de vida curto e são expurgadas automaticamente. Arquivos temporários de processamento (ingestão de pedidos, geração de etiquetas) são eliminados ao fim do processamento.

### 6.3. Dispositivos, mídia física e níveis de sanitização (NIST SP 800-88)

Como a infraestrutura é majoritariamente gerenciada (Supabase e Netlify), a sanitização de mídia física é, em regra, responsabilidade contratual dos sub-operadores, exigindo-se evidência/atestado. Para quaisquer dispositivos próprios da **LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA** (estações de trabalho, discos, backups locais):

| Nível NIST 800-88 | Aplicação | Método |
|---|---|---|
| **Clear** | Reuso interno | Sobrescrita lógica / reset seguro |
| **Purge** | Reaproveitamento externo | Criptográfico (destruição de chave) / apagamento seguro do dispositivo |
| **Destroy** | Fim de vida | Destruição física (trituração/incineração) com certificado |

### 6.4. Sanitização criptográfica (crypto-shredding)

Onde os dados estejam cifrados em repouso, a **destruição segura das chaves de criptografia** torna o dado irrecuperável e é método aceito de eliminação, especialmente para backups cujo hard-delete pontual é inviável (Seção 8.5).

---

## 7. Eliminação a Pedido do Titular (LGPD art. 18)

### 7.1. Direitos atendidos

O titular pode requerer, quanto aos seus dados, a **eliminação** (art. 18, VI), a **anonimização/bloqueio de dados desnecessários ou excessivos** (art. 18, IV) e a confirmação/acesso (art. 18, I e II). Esta Seção disciplina o fluxo operacional de eliminação.

### 7.2. Papel do GLOP conforme a titularidade

1. **Dados do COMPRADOR (GLOP como OPERADOR):** o GLOP trata esses dados **em nome do produtor/lojista CONTROLADOR**. O pedido de eliminação do comprador deve ser encaminhado ao/atendido pelo **controlador**; o GLOP executa a eliminação **sob instrução documentada** do controlador ou conforme o DPA (Data Processing Agreement) vigente, no prazo pactuado. Caso o comprador dirija o pedido diretamente ao GLOP, este o redireciona ao controlador competente e registra o encaminhamento.
2. **Dados dos próprios usuários/colaboradores (GLOP como CONTROLADOR):** o GLOP atende diretamente, pelos canais do DPO.

### 7.3. Canais e identificação

Solicitações são recebidas pelo e-mail do DPO (lemoncapsencapsulados@gmail.com) ou canal equivalente. Antes da execução, valida-se a **identidade do requerente** por medida proporcional, evitando eliminação indevida ou fraude.

### 7.4. Fluxo operacional

1. **Recebimento e protocolo** da solicitação, com data/hora.
2. **Triagem de titularidade** (operador x controlador) e **verificação de hipóteses de guarda obrigatória** (Seção 7.5).
3. **Localização dos dados** nos módulos afetados (pedidos, transporte/rastreio, fiscal, coprodução/split, CRM, storage, logs).
4. **Execução do método** adequado: hard-delete dos dados elimináveis; anonimização de registros que devam permanecer por integridade (ex.: linha de pedido vinculada a NF-e sob guarda fiscal, cujo CPF é anonimizado quando legalmente possível).
5. **Sanitização de mídias** correlatas (Seção 6).
6. **Registro de evidência** (Seção 9) e **resposta ao requerente** com confirmação e eventuais ressalvas legais.
7. **Notificação a sub-operadores** para expurgo correspondente, quando aplicável.

### 7.5. Hipóteses de recusa/retenção parcial (art. 16 da LGPD)

A eliminação pode ser negada ou postergada, no todo ou em parte, quando os dados forem necessários para: (i) **cumprimento de obrigação legal ou regulatória** — notadamente **guarda de documentos fiscais** (NF-e) e escrituração; (ii) **estudo por órgão de pesquisa**, com anonimização quando possível; (iii) **transferência a terceiro** observados os requisitos legais; e (iv) **uso exclusivo do controlador**, vedado o acesso por terceiro e desde que anonimizados. Nesses casos, mantém-se apenas o **mínimo necessário**, sob bloqueio e acesso restrito, eliminando-se o excedente. A recusa é sempre motivada e comunicada ao titular.

### 7.6. Portal público de rastreio

O portal público de rastreio expõe **apenas status neutro**, **sem login** e **sem PII**, de modo que não constitui, por si, ativo a eliminar; a eliminação incide sobre os dados de origem (pedido/rastreio) no backend.

---

## 8. Prazos de Retenção e Expurgo

### 8.1. Regra geral

Cada categoria de dado tem prazo definido pela finalidade e por exigência legal. **Ao término do prazo, executa-se automaticamente hard-delete ou anonimização.** Os prazos abaixo são **referenciais e devem ser confirmados pela assessoria jurídica** à luz da legislação vigente e dos contratos com controladores.

### 8.2. Tabela de retenção referencial

| Categoria | Base / finalidade | Prazo de retenção referencial | Ação ao término |
|---|---|---|---|
| PII do comprador (pedido) | Execução do contrato de logística/entrega | Enquanto ativo o vínculo + período do controlador (via DPA) | Devolução/eliminação conforme instrução do controlador |
| Dados de rastreio/transporte | Prova de entrega, SAC | Referência: até 5 anos (prazo do CDC) — confirmar | Anonimização ou hard-delete |
| Documentos fiscais (NF-e/DANFE) | Obrigação fiscal/tributária | Referência: 5 anos (decadência tributária) — confirmar | Hard-delete após decurso |
| Dados de coprodução/split e financeiros (PIX, bancários) | Apuração, repasse, prova de pagamento | Referência: 5 anos — confirmar | Hard-delete / anonimização |
| Dados de usuários/colaboradores | Relação contratual/cadastral | Duração do vínculo + prazo legal aplicável | Hard-delete / anonimização |
| Logs e trilhas de auditoria | Segurança, defesa de direitos (art. 7º, VI, LGPD) | Referência: 6 meses a 5 anos conforme finalidade — confirmar | Hard-delete / anonimização |
| Registros de consentimento/solicitações do titular | Prova de accountability | Enquanto necessário à demonstração + prazo legal | Conservar metadados; eliminar PII excedente |
| Backups | Continuidade/recuperação | Conforme ciclo de rotação (Seção 8.5) | Expiração natural do backup |
| Exportações e arquivos temporários | Uso pontual | Curtíssimo prazo (expurgo automático) | Hard-delete/sanitização |

### 8.3. Registros em soft-delete

Registros marcados com `deleted_at` **não são permanentes**: entram na fila de expurgo e, decorrido o prazo de retenção da respectiva categoria (ou o período de reversibilidade operacional definido para o módulo), são convertidos em **hard-delete ou anonimização** por rotina automatizada.

### 8.4. Automação de expurgo

O GLOP mantém rotinas periódicas (Edge Functions/jobs agendados) que varrem as tabelas por `deleted_at` e por data-limite de retenção, executam o método aplicável, propagam a remoção às mídias e geram o registro de evidência. As rotinas respeitam RLS, multi-tenant e credenciais de execução restritas.

### 8.5. Backups

Backups seguem **ciclo de rotação** próprio; o hard-delete pontual de um registro nem sempre é aplicável ao backup histórico. Adota-se: (i) **expiração natural** do backup dentro da janela de retenção; e/ou (ii) **crypto-shredding** (Seção 6.4) para tornar irrecuperável dado sensível antes da expiração, quando exigido pela criticidade. Dados restaurados de backup que já deveriam ter sido eliminados são **reexpurgados** imediatamente após a restauração, por controle específico.

---

## 9. Registro e Evidência de Descarte

### 9.1. Conteúdo do registro

Toda operação de eliminação, anonimização ou sanitização gera **registro de evidência** contendo, sem incluir o dado eliminado:

1. identificador da operação e da rotina/executor (usuário ou job);
2. categoria e volume de registros afetados;
3. método aplicado (soft/hard-delete, anonimização, pseudonimização, sanitização, crypto-shredding);
4. base do descarte (fim de retenção, pedido do titular, instrução do controlador, ordem legal);
5. módulos/tabelas e buckets impactados;
6. data/hora e resultado (sucesso/falha);
7. no caso de pedido do titular: protocolo da solicitação e eventual motivação de retenção parcial.

### 9.2. Fonte da evidência

As evidências apoiam-se na **trilha de auditoria nativa** do GLOP (triggers `tg_write_audit`, colunas de auditoria em todo registro, `deleted_by`/`reason_deleted`) e nos logs das rotinas de expurgo. As trilhas de auditoria são protegidas contra alteração e sujeitas a prazo de retenção próprio.

### 9.3. Conservação e finalidade

Os registros de evidência são conservados pelo prazo necessário à **demonstração de conformidade** (accountability) e à defesa em processos administrativos (ANPD) ou judiciais, sendo eles próprios objeto de expurgo ao fim de seu prazo. Não devem conter PII do titular eliminado — apenas metadados da operação.

### 9.4. Relatório

O DPO pode emitir, a partir desses registros, comprovante de eliminação ao titular ou ao controlador e relatórios periódicos de descarte para a governança.

---

## 10. Papéis e Responsabilidades

1. **DPO / Encarregado (a ser designado pela administração):** ponto focal de solicitações de titulares; decide sobre retenção/recusa motivada; valida evidências; interlocução com a ANPD.
2. **Administrador de Sistemas / DevOps:** executa e mantém rotinas de expurgo, hard-delete, sanitização de storage e ciclo de backup; garante segregação de credenciais.
3. **Desenvolvimento:** implementa e testa soft-delete, anonimização, pseudonimização e automações de retenção conforme esta Política.
4. **Segurança da Informação:** define níveis de sanitização, gestão de chaves (crypto-shredding), monitora conformidade (ISO 27001/27701, NIST).
5. **Jurídico/Compliance:** confirma prazos legais, valida DPAs com controladores e sub-operadores, revisa esta Política.
6. **Colaboradores:** cumprem os procedimentos; não realizam exclusões físicas fora das rotinas homologadas.

---

## 11. Sanções por Descumprimento

O descumprimento desta Política sujeita o infrator (colaborador, prestador ou sub-operador) às medidas cabíveis: advertência, suspensão, rescisão contratual/laboral por justa causa, responsabilização civil e criminal, além das penalidades administrativas da LGPD (art. 52 — advertência, multa de até 2% do faturamento limitada a R$ 50 milhões por infração, publicização, bloqueio e eliminação dos dados) aplicáveis à organização. Sub-operadores respondem regressivamente nos termos dos respectivos contratos/DPAs.

---

## 12. Interação com Outros Documentos

Esta Política integra o arcabouço de governança do GLOP e deve ser lida em conjunto com: Política de Privacidade; Política de Segurança da Informação; Política de Retenção de Dados; Contratos de Operador/DPA com produtores e lojistas (controladores); Contratos com sub-operadores (Supabase, Netlify, VHSYS, Correios, gateways); Plano de Resposta a Incidentes; e a Constituição da Logística (Volume 01) do projeto.

---

## 13. Vigência e Revisão

Esta Política entra em vigor em 16 de julho de 2026 e vige por prazo indeterminado, com **revisão mínima anual** ou sempre que houver alteração legislativa, regulatória, contratual, tecnológica ou de arquitetura do GLOP que a impacte.

---

## Engenharia Jurídica & Governança

### (a) Fundamentação das cláusulas

| Cláusula / tema | Fundamento legal/normativo |
|---|---|
| Princípios (necessidade, finalidade, adequação) e término do tratamento | LGPD art. 6º, I–III; art. 15 e 16 |
| Eliminação a pedido do titular | LGPD art. 18, VI; art. 18, IV (anonimização/bloqueio) |
| Hipóteses de retenção mesmo após pedido | LGPD art. 16, I–IV |
| Guarda de documentos fiscais | Legislação tributária (decadência — CTN art. 173/174); confirmar prazos |
| Anonimização (dado deixa de ser pessoal) | LGPD art. 5º, XI; art. 12 |
| Pseudonimização | LGPD art. 13, §4º |
| Papéis Controlador/Operador e dupla natureza | LGPD art. 5º, VI e VII; art. 39 |
| Segurança, prevenção e boas práticas | LGPD art. 46, 47, 48, 50 |
| Accountability / evidência de descarte | LGPD art. 6º, X; art. 37 |
| Encarregado (DPO) | LGPD art. 41 |
| Sanções | LGPD art. 52; CLT (justa causa); Código Civil (responsabilidade) |
| Prazo de guarda de logs / defesa de direitos | LGPD art. 7º, VI; art. 16, I |
| Direitos do consumidor (rastreio/entrega) | CDC (Lei nº 8.078/1990) |
| Sanitização de mídia (níveis Clear/Purge/Destroy) | NIST SP 800-88 |
| Gestão de segurança e continuidade | ISO/IEC 27001, 27701, 22301; ISO 31000; GDPR (referência para transferências) |

### (b) Riscos mitigados

1. **Retenção excessiva** de PII e dados financeiros (multa ANPD, exposição em incidente).
2. **Soft-delete tratado como eliminação** — risco de considerar cumprido o art. 18, VI sem efetiva remoção.
3. **Reidentificação** de dados supostamente anonimizados.
4. **Persistência em backups** após eliminação (mitigado por expiração natural e crypto-shredding).
5. **Eliminação indevida/fraudulenta** por falta de verificação de identidade.
6. **Falha de segregação** entre operador e controlador (execução de pedido sem instrução).
7. **Ausência de evidência** para demonstrar conformidade perante a ANPD.
8. **Mídias órfãs** no Storage após descarte do registro principal.

### (c) Checklist de conformidade

- [ ] Inventário de dados por categoria e finalidade atualizado.
- [ ] Prazos de retenção confirmados pelo Jurídico.
- [ ] Rotina automática de expurgo (soft→hard/anonimização) ativa e monitorada.
- [ ] Fluxo de pedido do titular documentado, com verificação de identidade.
- [ ] Triagem operador/controlador definida com DPAs vigentes.
- [ ] Sanitização de Storage e propagação a backups testada.
- [ ] Registro de evidência de descarte gerado e conservado (sem PII eliminada).
- [ ] Ciclo de backup e crypto-shredding definidos.
- [ ] Sub-operadores notificados e obrigados contratualmente ao expurgo.
- [ ] Revisão anual agendada.

### (d) Matriz RACI

| Atividade | DPO | DevOps/Sysadmin | Desenvolvimento | Segurança | Jurídico |
|---|---|---|---|---|---|
| Receber/triagem de pedido do titular | R/A | I | I | C | C |
| Definir prazos de retenção | A | I | I | C | R |
| Implementar soft/hard-delete e anonimização | C | C | R | C | I |
| Executar hard-delete e sanitização de Storage | I | R | C | A | I |
| Gestão de backups e crypto-shredding | I | R | C | A | I |
| Gerar/conservar evidência de descarte | A | R | C | C | I |
| Notificar sub-operadores | R | C | I | C | A |
| Recusa/retenção parcial motivada | A/R | I | I | C | C |
| Revisão da Política | R | C | C | C | A |

(R=Responsável, A=Aprovador, C=Consultado, I=Informado)

### (e) Plano de revisão

1. **Periodicidade:** revisão ordinária anual; extraordinária a cada mudança legal/regulatória (ANPD), contratual (novo controlador/sub-operador) ou de arquitetura (novo módulo, nova mídia).
2. **Gatilhos:** incidente de segurança; auditoria interna/externa; nova integração (gateway/e-commerce/transportadora); alteração de prazos fiscais.
3. **Responsável:** DPO com apoio de Jurídico, Segurança e DevOps.
4. **Registro:** toda revisão consta no Controle de Versão abaixo.

### (f) Controle de versão

| Versão | Data | Autor | Descrição | Aprovação |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | Chief Legal AI (minuta) | Emissão inicial da Política de Descarte e Eliminação Segura | Pendente — a ser designado pela administração / Jurídico |
| | | | | |

---

*Documento sujeito a controle de acesso. Distribuição interna. Revisar antes de qualquer uso em produção conforme aviso de minuta no topo.*
