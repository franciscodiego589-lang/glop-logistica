# POLÍTICA DE RETENÇÃO E ELIMINAÇÃO DE DADOS — GLOP (Global Logistics Platform)

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

**Controladora / Operadora:** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, nome fantasia [NOME FANTASIA: GLOP], inscrita no CNPJ sob nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190.
**Encarregado pelo Tratamento de Dados (DPO):** a ser designado pela administração — lemoncapsencapsulados@gmail.com.
**Versão:** 1.0 — **Vigência a partir de:** 16 de julho de 2026.
**Classificação do documento:** Interno / Confidencial.

---

## 1. Objetivo

1. Esta Política de Retenção e Eliminação de Dados (a "Política") estabelece, de forma vinculante para toda a operação da [NOME FANTASIA: GLOP], os **prazos máximos e mínimos de guarda** de cada categoria de dado pessoal e não pessoal tratado pela plataforma, a **base legal** que justifica cada período de retenção, os **gatilhos e critérios de eliminação** (anonimização, pseudonimização, descarte físico e lógico) e o regime de **retenção sob custódia legal (legal holds)**.
2. A Política operacionaliza o princípio da **necessidade** e da **limitação de armazenamento** previstos no art. 6º, III (necessidade) e no art. 15 e 16 da Lei nº 13.709/2018 (Lei Geral de Proteção de Dados Pessoais — "LGPD"), segundo os quais os dados pessoais devem ser eliminados após o término de seu tratamento, ressalvadas as hipóteses de guarda autorizadas por lei.
3. A Política dá concretude ao mapeamento de fluxos do GLOP: ingestão de pedidos via API (Monetizze, Hotmart, Kiwify) e via e-commerces (Shopify, WooCommerce, Nuvemshop, Mercado Livre); emissão de NF-e via VHSYS; pré-postagem e rastreio junto aos Correios (PPN/SRO); coprodução, split e repasse de comissões (AppMax); notificação ao comprador por e-mail e WhatsApp; e o portal público de rastreio sem login.

## 2. Escopo

1. Aplica-se a **todos** os ambientes, sistemas, bancos de dados, backups, filas, caches, logs, storage de objetos e integrações da [NOME FANTASIA: GLOP], notadamente: banco Supabase (PostgreSQL) com RLS multi-tenant (Tenant → Company → Branch → Membership), Supabase Auth (JWT), Supabase Storage, hospedagem SSR na Netlify, e os sub-operadores VHSYS (NF-e), Correios (transporte), gateways de pagamento (Monetizze, AppMax, Hotmart, Kiwify) e provedores de mensageria (WhatsApp / e-mail).
2. Aplica-se a **todos os agentes de tratamento**: colaboradores, prestadores, estagiários, administradores de sistema, desenvolvedores e sub-operadores contratados.
3. Aplica-se às **duas naturezas jurídicas** simultâneas do GLOP em face da LGPD:
   - **a) GLOP como OPERADOR** — quando trata dados pessoais do **comprador final** (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor) **por conta e ordem** do produtor/lojista, que atua como **CONTROLADOR**. Nessa hipótese, os prazos de retenção seguem, como regra, a instrução documentada do Controlador (o cliente da plataforma) e o respectivo Contrato / Acordo de Tratamento de Dados (DPA), salvo obrigação legal de guarda própria da Operadora.
   - **b) GLOP como CONTROLADOR** — quando trata dados dos **próprios usuários da plataforma, colaboradores, contatos comerciais e coprodutores/afiliados vinculados diretamente à GLOP**, hipótese em que a GLOP define as finalidades e os prazos.
4. **Fora do escopo:** dados que nunca são coletados pela plataforma e ambientes de terceiros que não estejam sob operação ou custódia da GLOP.

## 3. Definições

1. **Dado pessoal:** informação relacionada a pessoa natural identificada ou identificável (art. 5º, I, LGPD).
2. **Dado pessoal sensível:** dado sobre origem racial/étnica, convicção religiosa, opinião política, saúde, vida sexual, genético ou biométrico (art. 5º, II, LGPD). *A GLOP, por concepção, não trata dados sensíveis de compradores.*
3. **Titular:** a pessoa natural a quem se referem os dados (comprador final, coprodutor pessoa física, colaborador, usuário).
4. **Controlador / Operador / Encarregado:** conforme art. 5º, VI, VII e VIII, LGPD.
5. **Retenção:** período durante o qual o dado permanece armazenado e acessível para uma finalidade legítima.
6. **Eliminação:** exclusão definitiva do dado (art. 5º, XIV, LGPD), por meios físicos e/ou lógicos, ou sua **anonimização** irreversível (art. 5º, XI e XII, LGPD), de modo que o titular não possa mais ser identificado.
7. **Soft-delete:** marcação lógica de exclusão (deleted_at, reason_deleted, deleted_by) que retira o registro das leituras correntes sem apagá-lo fisicamente de imediato; **não** equivale à eliminação definitiva para fins desta Política.
8. **Hard-delete / expurgo:** remoção física e definitiva do registro e de suas cópias (réplicas, backups elegíveis, storage).
9. **Legal hold (custódia legal):** suspensão temporária e excepcional de qualquer rotina de eliminação sobre um conjunto de dados, por determinação legal, judicial, administrativa ou por necessidade de exercício regular de direito.
10. **Gatilho de eliminação:** evento objetivo e verificável que inicia a contagem do prazo de retenção (ex.: cancelamento da conta, encerramento do contrato, entrega confirmada do pedido, transcurso do prazo fiscal).

## 4. Princípios que orientam a retenção

1. **Necessidade e minimização (art. 6º, III, LGPD):** guarda-se apenas o dado necessário, pelo tempo necessário, para a finalidade declarada.
2. **Limitação de armazenamento (art. 15 e 16, LGPD):** encerrada a finalidade, o dado é eliminado, salvo hipótese legal de guarda.
3. **Prazo definido e documentado:** todo dado tem prazo máximo de retenção pré-estabelecido nesta Política; não se admite retenção indefinida "por precaução".
4. **Segregação de finalidades:** o mesmo dado pode ter prazos distintos conforme a finalidade (ex.: um CPF em um pedido tem prazo operacional/consumerista; o mesmo CPF em uma NF-e tem prazo fiscal).
5. **Prevalência do maior prazo legalmente exigível:** quando um mesmo dado servir a mais de uma finalidade com prazos distintos, prevalece, para a guarda, o **maior prazo legalmente exigido**, extinguindo-se progressivamente cada finalidade.
6. **Reversibilidade zero após expurgo:** a eliminação é irreversível; por isso é precedida de conferência e de verificação de inexistência de legal hold.

## 5. Tabela-mestra de prazos de retenção por categoria

> Legenda de gatilho: **G1** encerramento/entrega do pedido; **G2** encerramento da relação contratual com o cliente da plataforma (produtor/lojista); **G3** emissão do documento fiscal; **G4** desligamento do colaborador; **G5** revogação/rotação da credencial; **G6** solicitação de eliminação pelo titular; **G7** cancelamento/inativação da conta.

| # | Categoria de dado | Exemplos no fluxo GLOP | Papel da GLOP | Prazo de retenção | Gatilho de início da contagem | Base legal da retenção |
|---|---|---|---|---|---|---|
| 1 | **PII do comprador nos pedidos** | Nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto, valor — ingeridos via Monetizze/Hotmart/Kiwify/Shopify/WooCommerce/Nuvemshop/Mercado Livre | **Operador** (por conta do produtor/lojista Controlador) | **5 anos** após a conclusão do pedido, para atender pretensões de reparação e cobrança | G1 (entrega/encerramento do pedido) | Art. 206, §5º, I, Código Civil (cobrança de dívidas líquidas) e art. 27 do CDC (prazo de reparação por fato do produto/serviço) c/c art. 7º, X e art. 16, I, LGPD |
| 2 | **PII do comprador — relação de consumo** | Mesmos dados acima, para fins de defesa em reclamações/PROCON/ações consumeristas | **Operador** | **5 anos** após o encerramento do pedido | G1 | Art. 26 e 27 do CDC; art. 7º, VI (exercício regular de direitos), LGPD |
| 3 | **Dados de contato para rastreio e notificação** | E-mail/telefone/WhatsApp usados para notificar status de entrega (SRO) | **Operador** | **Até 90 dias** após a confirmação de entrega, quando não vinculados a pedido em guarda por outro prazo | G1 | Art. 7º, V (execução de contrato) e art. 15, I, LGPD (fim do tratamento) |
| 4 | **Dados fiscais — NF-e** | XML da NF-e, dados do destinatário, chave de acesso, DANFE — via VHSYS | **Controlador/Corresponsável fiscal** | **5 anos** (regra geral), estendendo-se até o trânsito em julgado de eventual processo administrativo/tributário | G3 (emissão) | Art. 173 e 174 do CTN (decadência/prescrição tributária); art. 195, parágrafo único do CTN; legislação do ICMS/estadual e Convênio ICMS aplicável à guarda do XML |
| 5 | **Comprovantes e documentos fiscais acessórios** | Notas de serviço, comprovantes de recolhimento, obrigações acessórias | **Controlador** | **5 anos**, no mínimo | G3 | Art. 173/174 do CTN; art. 37 da Lei nº 9.430/1996 |
| 6 | **Logs e trilha de auditoria de acesso** | Logs de autenticação (Supabase Auth), logs de acesso a registros, trilha por triggers de auditoria | **Controlador** | **Mínimo de 6 meses** (registros de conexão) a **até 5 anos** para eventos relevantes à segurança e à defesa em processos | Data do evento | Art. 15 do Marco Civil da Internet (Lei nº 12.965/2014 — guarda de registros de acesso a aplicação por 6 meses); art. 7º, VI e art. 37, LGPD (comprovação de conformidade) |
| 7 | **Logs de auditoria de negócio (tg_write_audit)** | Trilha de INSERT/UPDATE/DELETE por triggers; colunas created_by, updated_by, deleted_by, version | **Controlador** | **5 anos**, alinhado ao maior prazo prescricional das operações auditadas | Data do evento | Art. 37, LGPD (demonstração de conformidade — accountability); art. 206 do Código Civil |
| 8 | **Dados de coprodutores e afiliados** | Nome, CPF/CNPJ, dados de contato, percentual de comissão, apuração e repasse | **Controlador** (relação direta GLOP/coprodutor) | **5 anos** após o encerramento da relação de coprodução | G2 | Art. 206, §5º, I e §3º, do Código Civil; art. 7º, V e IX, LGPD |
| 9 | **Dados bancários / PIX para split e repasse** | Chave PIX, agência/conta, titularidade — para split via AppMax | **Controlador/Operador** conforme a relação | **5 anos** após o último repasse (para conciliação e prova de pagamento) | Último repasse | Art. 206, §5º, I, Código Civil; art. 7º, V, LGPD; obrigações antifraude/PLD-FT quando aplicáveis |
| 10 | **Registros de pagamento e conciliação** | Transações, comissões, apuração de split, status de liquidação | **Controlador** | **5 anos** | Liquidação/encerramento | Art. 173/174 do CTN; art. 206, §5º, Código Civil |
| 11 | **Credenciais de API dos clientes** | Chaves/tokens de Monetizze, Hotmart, Kiwify, Shopify, WooCommerce, Nuvemshop, Mercado Livre, Correios, VHSYS (armazenadas write-only) | **Operador** | **Eliminação imediata** na revogação/rotação; retenção somente enquanto a integração estiver ativa | G5 (revogação/rotação) ou G7 | Art. 6º, VII e VIII, LGPD (segurança e prevenção); art. 46, LGPD (medidas de segurança) |
| 12 | **Dados cadastrais dos usuários da plataforma** | Cadastro do produtor/lojista, colaboradores, membros (Membership), perfis e permissões (RBAC) | **Controlador** | Durante a vigência da conta + **5 anos** após o encerramento (defesa e obrigações contratuais) | G7 | Art. 7º, V (contrato) e VI (exercício de direitos), LGPD; art. 206, §5º, Código Civil |
| 13 | **Dados de colaboradores (trabalhistas/RH)** | Registros de admissão, jornada, folha, quando aplicável | **Controlador** | Conforme legislação trabalhista/previdenciária — em regra **até 5 anos** (verbas), documentos de FGTS por **30 anos** (observada a jurisprudência do STF), eSocial conforme norma vigente | G4 | CLT (art. 11); Lei nº 8.036/1990 (FGTS); legislação previdenciária; art. 7º, II, LGPD (obrigação legal) |
| 14 | **Comunicações com o comprador** | E-mails/WhatsApp transacionais (rastreio, confirmação, atualização de status) | **Operador** | **Até 90 dias** após o encerramento do pedido, salvo prova necessária de entrega | G1 | Art. 7º, V, LGPD; art. 15, LGPD |
| 15 | **Dados do portal público de rastreio** | Exposição de status neutro sem login (sem PII exposta ao público) | **Operador** | Enquanto o pedido estiver ativo; **status neutro** anonimizável após G1 | G1 | Art. 6º, I e VII, LGPD (finalidade e segurança); minimização |
| 16 | **Backups e réplicas** | Snapshots do PostgreSQL, backups do Storage | **Controlador/Operador** | Ciclo de backup de **até 35 dias** (retenção rotativa); dado eliminado no primário sai do backup ao expirar o ciclo | Data do snapshot | Art. 16, LGPD (guarda técnica transitória); art. 46, LGPD (segurança) |
| 17 | **Dados de leads / marketing (base própria GLOP)** | Contatos comerciais, prospecção | **Controlador** | **Até 12 meses** após o último contato/interação, ou até a revogação do consentimento | G6 ou último contato | Art. 7º, I (consentimento) e IX (legítimo interesse), LGPD |
| 18 | **Cookies, identificadores e telemetria de sessão** | Cookies de sessão (SSR Netlify), tokens JWT, dados de navegação essenciais | **Controlador** | JWT/sessão: expiração conforme configuração; telemetria: **até 12 meses** | Coleta | Art. 7º, IX, LGPD; Marco Civil da Internet |
| 19 | **Documentos de exercício de direitos do titular** | Requerimentos LGPD, provas de identidade, respostas e decisões | **Controlador/Operador** | **5 anos** após o atendimento, como prova de conformidade | Atendimento do pedido | Art. 18 e art. 37, LGPD (accountability) |
| 20 | **Dados sob legal hold** | Qualquer categoria alcançada por ordem/lei | Conforme o caso | **Suspensão do expurgo** até a liberação formal do hold | Instauração do hold | Art. 7º, VI, LGPD; dever legal de preservação de prova |

**Nota interpretativa da tabela:** os prazos de 5 anos ancorados no CDC e no Código Civil são **prazos-teto de segurança jurídica** para defesa em litígios; encerrado o prazo e inexistindo legal hold, o dado deve ser eliminado ou anonimizado. Para dados tratados na condição de **Operador**, a instrução documentada do Controlador (cliente da plataforma) pode determinar prazo **menor**; nunca poderá determinar guarda que viole obrigação legal própria da GLOP nem exigir retenção sem base legal.

## 6. Base legal para a retenção — detalhamento

1. **Obrigação legal e regulatória (art. 7º, II, LGPD):** guarda de documentos fiscais (NF-e e acessórios) por força do art. 173 e 174 do CTN (prazos de decadência e prescrição tributária, em regra 5 anos), da legislação do ICMS/estadual e das normas de guarda do XML da NF-e; guarda de registros de acesso à aplicação por, no mínimo, 6 meses (art. 15 do Marco Civil da Internet); guarda trabalhista/previdenciária (CLT, FGTS, eSocial).
2. **Execução de contrato (art. 7º, V, LGPD):** retenção de dados do comprador e do cliente da plataforma enquanto necessária para prestar o serviço logístico contratado (pré-postagem PPN, rastreio SRO, notificação, split de comissões).
3. **Exercício regular de direitos em processo (art. 7º, VI, LGPD):** guarda por até 5 anos alinhada ao art. 27 do CDC (reparação por fato do produto/serviço), ao art. 26 do CDC (vícios) e ao art. 206 do Código Civil (prescrições, notadamente §5º, I — cobrança de dívidas líquidas — quinquenal).
4. **Legítimo interesse (art. 7º, IX, LGPD):** prevenção a fraude, segurança da informação e conciliação financeira, com teste de proporcionalidade documentado (LIA) e salvaguarda dos direitos do titular.
5. **Consentimento (art. 7º, I, LGPD):** somente para finalidades específicas (ex.: marketing da base própria GLOP), com retenção limitada e cessação imediata na revogação.
6. **Cumprimento de accountability (art. 37, LGPD):** guarda das trilhas de auditoria e dos registros de atendimento a direitos como prova de conformidade.

## 7. Gatilhos e critérios de eliminação

### 7.1. Fluxo de eliminação
1. **Identificação do gatilho** (G1 a G7) por rotina automatizada que consulta as colunas de auditoria (created_at, updated_at, deleted_at) e os marcadores de status do registro.
2. **Cálculo do prazo residual** conforme a categoria da Seção 5, aplicando o maior prazo legalmente exigível entre as finalidades ativas.
3. **Verificação de legal hold** (Seção 8): se houver hold ativo sobre o registro ou seu conjunto, o expurgo é **bloqueado** e o registro é marcado como "retido por custódia legal".
4. **Soft-delete** (deleted_at = now(), reason_deleted, deleted_by) como etapa intermediária, retirando o dado das leituras correntes (todas as leituras filtram deleted_at is null).
5. **Hard-delete / anonimização** após o transcurso do prazo, executado em janela controlada, com registro na trilha de auditoria (quem, quando, qual base) — a própria eliminação é um evento auditado.
6. **Propagação aos backups e sub-operadores:** o dado eliminado no primário sai naturalmente do ciclo rotativo de backups (até 35 dias) e, quando aplicável, é solicitada a eliminação correspondente aos sub-operadores (VHSYS, Correios, gateways, mensageria) conforme os respectivos contratos/DPAs.

### 7.2. Critérios de escolha entre eliminação e anonimização
1. **Anonimização** é preferível quando houver interesse legítimo em manter **dados agregados/estatísticos** (BI, métricas logísticas) sem identificar titulares — o dado anonimizado deixa de ser dado pessoal (art. 12, LGPD) e pode ser retido sem prazo.
2. **Eliminação física (hard-delete)** é obrigatória quando o dado não tiver mais qualquer finalidade legítima e não for anonimizável de forma útil, ou quando houver ordem de eliminação do titular sem base legal concorrente para retenção.
3. **Credenciais de API** (categoria 11) são eliminadas de imediato na revogação/rotação — nunca são anonimizadas nem retidas "por histórico".

### 7.3. Solicitação de eliminação pelo titular (G6)
1. Recebido pedido de eliminação (art. 18, VI, LGPD), o Encarregado verifica se há base legal concorrente que imponha guarda (fiscal, consumerista, processual).
2. Havendo base legal, informa-se o titular sobre a **retenção parcial e seu fundamento**, eliminando-se o que exceder a finalidade legal.
3. Quando a GLOP atua como **Operador**, o pedido do titular é encaminhado ao **Controlador** (produtor/lojista), a quem cabe a decisão, salvo instrução prévia documentada.
4. Prazo de atendimento e resposta: conforme art. 18, §§, LGPD e regulamentação da ANPD.

## 8. Retenção sob custódia legal (legal holds)

1. **Instauração:** o legal hold é instaurado por determinação judicial, requisição de autoridade competente, notificação de litígio iminente/em curso, investigação de incidente de segurança ou necessidade de preservação de prova para exercício regular de direito.
2. **Efeito:** **suspende toda rotina de eliminação** (soft e hard-delete) sobre o conjunto de dados alcançado, ainda que o prazo ordinário de retenção da Seção 5 já tenha se esgotado.
3. **Escopo mínimo necessário:** o hold deve alcançar apenas os dados estritamente relacionados ao objeto da custódia, evitando bloqueio desproporcional.
4. **Registro:** todo hold é registrado com identificação do responsável, fundamento, data de início, escopo (tenant/company/branch/registros) e previsão de revisão.
5. **Preservação da integridade:** os dados sob hold são preservados em seu estado, vedada alteração ou exclusão; o acesso é restrito e auditado (RBAC + RLS).
6. **Liberação:** encerrada a causa, o hold é formalmente liberado pelo Encarregado/Jurídico e os dados retornam ao fluxo ordinário de retenção/eliminação, com reprocessamento do gatilho de expurgo.
7. **Precedência:** o legal hold **prevalece** sobre qualquer prazo desta Política e sobre pedidos de eliminação do titular, nos limites da ordem/lei que o fundamenta.

## 9. Papéis e responsabilidades

1. **Encarregado (DPO) — a ser designado pela administração:** guardião desta Política; aprova exceções, supervisiona holds, responde a titulares e à ANPD, revisa a tabela de prazos.
2. **Jurídico:** define bases legais, instaura/libera legal holds, valida prazos frente à legislação vigente.
3. **Engenharia / DBA:** implementa e executa as rotinas de soft-delete, expurgo e anonimização; mantém as colunas e triggers de auditoria; gerencia o ciclo de backups.
4. **Segurança da Informação:** garante a eliminação segura, a proteção das credenciais write-only e o controle de acesso (RLS/RBAC).
5. **Fiscal / Financeiro:** define e valida os prazos de guarda de NF-e, documentos fiscais e conciliação de repasses/split.
6. **Gestores de área:** identificam gatilhos de negócio (encerramento de contrato, desligamento) e comunicam ao fluxo de retenção.
7. **Todos os colaboradores:** cumprem a Política, não criam cópias não autorizadas e reportam desvios.

## 10. Sanções por descumprimento

1. O descumprimento desta Política sujeita o colaborador ou prestador a medidas disciplinares proporcionais à gravidade — advertência, suspensão, rescisão por justa causa (art. 482 da CLT quando aplicável) e rescisão contratual — sem prejuízo da responsabilização civil e criminal.
2. Retenção indevida, eliminação não autorizada de dados sob legal hold ou vazamento decorrente de guarda excessiva podem gerar responsabilização da GLOP perante titulares e a ANPD (art. 52, LGPD), com direito de regresso contra o agente causador.

## 11. Revisão e vigência

1. Esta Política entra em vigor em 16 de julho de 2026 e deve ser **revisada, no mínimo, anualmente** ou sempre que houver: alteração legislativa, novo fluxo/integração, incidente de segurança relevante, orientação da ANPD ou decisão judicial impactante.
2. Alterações são versionadas (Seção 12.f) e comunicadas às áreas afetadas.

---

## 12. Engenharia Jurídica & Governança

### a) Fundamentação das cláusulas (lei/norma que embasa)

1. **LGPD (Lei nº 13.709/2018):** art. 5º (definições); art. 6º, III (necessidade) e I (finalidade); art. 7º (bases legais de tratamento); art. 12 (anonimização); art. 15 e 16 (término do tratamento e hipóteses de conservação); art. 18 (direitos do titular, incl. eliminação); art. 37 (registro/accountability); art. 46 (segurança); art. 52 (sanções).
2. **Código Tributário Nacional (Lei nº 5.172/1966):** art. 173 e 174 (decadência e prescrição — 5 anos) e art. 195, parágrafo único (guarda de documentos fiscais) — fundamentam a retenção de NF-e e documentos fiscais.
3. **Código de Defesa do Consumidor (Lei nº 8.078/1990):** art. 26 (vícios) e art. 27 (reparação por fato do produto/serviço — 5 anos) — fundamentam a guarda de PII do comprador para defesa em relações de consumo.
4. **Código Civil (Lei nº 10.406/2002):** art. 206, §5º, I (prescrição quinquenal de dívidas líquidas) e §3º — fundamentam prazos de guarda de pedidos, comissões e repasses.
5. **Marco Civil da Internet (Lei nº 12.965/2014):** art. 15 (guarda de registros de acesso a aplicação por, no mínimo, 6 meses) — fundamenta a retenção de logs de acesso.
6. **CLT, Lei nº 8.036/1990 (FGTS) e legislação previdenciária/eSocial:** fundamentam prazos de guarda de dados trabalhistas.
7. **Normas técnicas de referência:** ISO/IEC 27001 (SGSI), ISO/IEC 27701 (privacidade), ISO 22301 (continuidade — backups), ISO 31000 (gestão de riscos), NIST e OWASP (segurança) — orientam os controles técnicos de eliminação segura e de retenção de backups.

### b) Riscos mitigados

1. **Retenção excessiva / indefinida** → violação da minimização e do art. 15/16 da LGPD e ampliação da superfície de vazamento — mitigado por prazos-teto e expurgo automatizado.
2. **Eliminação prematura de dado sob obrigação legal** → autuação fiscal ou perda de prova em litígio — mitigado pela tabela de prazos e pela precedência do maior prazo legal.
3. **Destruição de prova sob litígio** → responsabilização por embaraço/destruição de prova — mitigado pelo regime de legal holds.
4. **Vazamento de credenciais de integração** → acesso indevido a gateways e Correios — mitigado por armazenamento write-only e eliminação imediata na rotação.
5. **Não atendimento a direito de eliminação do titular** → sanção da ANPD e dano reputacional — mitigado pelo fluxo do item 7.3.
6. **Guarda descoordenada com sub-operadores** → dado "esquecido" em VHSYS/Correios/gateways/mensageria — mitigado pela propagação contratual de eliminação (DPA).
7. **Inconsistência entre soft-delete e expurgo real** → falsa sensação de eliminação — mitigado pela distinção explícita e pela etapa de hard-delete auditada.

### c) Checklist de conformidade

1. [ ] Toda categoria de dado possui prazo, gatilho e base legal mapeados na Seção 5.
2. [ ] Rotina automatizada de identificação de gatilhos ativa e testada.
3. [ ] Verificação de legal hold ocorre **antes** de qualquer expurgo.
4. [ ] Soft-delete distinto de hard-delete, ambos auditados por trigger.
5. [ ] Ciclo de backup com retenção rotativa definida (até 35 dias) e documentada.
6. [ ] Credenciais de API armazenadas write-only e eliminadas na rotação.
7. [ ] Pedidos de eliminação de titular tratados conforme papel (Controlador vs. Operador).
8. [ ] DPA/contratos com sub-operadores preveem eliminação/retorno de dados no encerramento.
9. [ ] Prazos fiscais validados pela área Fiscal e alinhados ao CTN/ICMS.
10. [ ] Registro de holds ativos revisado periodicamente.
11. [ ] Trilha de auditoria da própria eliminação preservada como prova de conformidade.
12. [ ] Política revisada no ciclo previsto e versionada.

### d) Matriz RACI

| Atividade | Encarregado (DPO) | Jurídico | Engenharia/DBA | Segurança | Fiscal/Financeiro | Gestor de área |
|---|---|---|---|---|---|---|
| Definir prazos e bases legais | A | R | C | C | C | I |
| Manter tabela de retenção | R | C | C | I | C | I |
| Executar soft/hard-delete | I | I | R | A | I | I |
| Anonimização de bases estatísticas | C | C | R | A | I | I |
| Instaurar/liberar legal hold | A | R | C | C | I | I |
| Validar prazos fiscais (NF-e) | C | C | I | I | R/A | I |
| Gerir credenciais de API | I | I | C | R/A | I | I |
| Atender pedido de eliminação do titular | R/A | C | C | C | C | I |
| Propagar eliminação a sub-operadores | A | C | R | C | I | I |
| Revisar a Política | A | R | C | C | C | C |

Legenda: **R** Responsável pela execução · **A** Aprovador/Accountable · **C** Consultado · **I** Informado.

### e) Plano de revisão

1. **Revisão ordinária anual** conduzida pelo Encarregado, com parecer do Jurídico e Fiscal.
2. **Revisão extraordinária** disparada por: alteração legislativa (LGPD, CTN, CDC, CC, Marco Civil), nova integração (novo gateway/marketplace/transportadora), incidente de segurança relevante, orientação/deliberação da ANPD ou decisão judicial.
3. **Registro de cada revisão** na tabela de controle de versão (item f) e comunicação às áreas afetadas.
4. **Métrica de acompanhamento:** percentual de registros expurgados dentro do prazo, número de holds ativos, tempo médio de atendimento a pedidos de eliminação.

### f) Controle de versão

| Versão | Data | Autor/Responsável | Descrição da alteração | Aprovação |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | a ser designado pela administração | Emissão inicial da Política de Retenção e Eliminação de Dados do GLOP | [PARTE] |
| 1.1 | 16 de julho de 2026 | a ser designado pela administração | (reservado para revisão) | [PARTE] |

---

*Documento interno da LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA — [NOME FANTASIA: GLOP]. Dúvidas sobre retenção e eliminação de dados devem ser encaminhadas ao Encarregado (DPO): lemoncapsencapsulados@gmail.com.*
