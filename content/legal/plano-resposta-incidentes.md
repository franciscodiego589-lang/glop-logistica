> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# Plano de Resposta a Incidentes de Segurança da Informação e Privacidade (PRI)

## Plataforma GLOP — [NOME FANTASIA: GLOP] — Global Logistics Platform

**Documento:** Plano de Resposta a Incidentes (PRI) — Segurança e Privacidade
**Versão:** 1.0
**Classificação da informação:** CONFIDENCIAL — uso interno restrito
**Controlador/Operador:** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, inscrita no CNPJ sob nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190
**Encarregado pelo Tratamento de Dados (DPO/Encarregado):** a ser designado pela administração — lemoncapsencapsulados@gmail.com
**Aprovado por:** [NOME DO RESPONSÁVEL — Diretoria/CEO]
**Data de vigência:** 16 de julho de 2026
**Próxima revisão obrigatória:** [DATA + 12 meses]

---

## Sumário

1. Objetivo
2. Escopo e Abrangência
3. Definições
4. Fundamentos Legais e Normativos
5. Princípios Reitores da Resposta
6. Papéis e Responsabilidades — Equipe de Resposta a Incidentes (CSIRT)
7. Classificação e Severidade de Incidentes
8. Ciclo de Vida da Resposta a Incidentes (Fases)
   - 8.1 Preparação
   - 8.2 Detecção e Análise
   - 8.3 Contenção
   - 8.4 Erradicação
   - 8.5 Recuperação
   - 8.6 Atividades Pós-Incidente (Lições Aprendidas)
9. Comunicação de Incidente à ANPD e aos Titulares (LGPD, art. 48)
10. Dupla Natureza GLOP: Operador x Controlador — Cadeia de Notificação
11. Playbooks Operacionais
    - 11.1 Vazamento de Dados Pessoais (PII do Comprador e de Usuários)
    - 11.2 Comprometimento de Credenciais e Acessos
    - 11.3 Ransomware / Software Malicioso
    - 11.4 Comprometimento de Sub-operador (Supabase, Netlify, VHSYS, Correios, Gateways)
    - 11.5 Exposição do Portal Público de Rastreio
    - 11.6 Fraude em Split/Repasses e Dados Bancários/PIX
12. Registro e Preservação de Evidências (Cadeia de Custódia)
13. Comunicação Interna e Externa
14. Métricas, Indicadores e Melhoria Contínua
15. Treinamento, Testes e Simulações (Tabletop)
16. Anexos e Modelos
17. Engenharia Jurídica & Governança

---

## 1. Objetivo

Este Plano de Resposta a Incidentes (PRI) estabelece a estrutura de governança, os papéis, os procedimentos, os prazos e os fluxos de comunicação que a LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, operadora da plataforma [NOME FANTASIA: GLOP] (Global Logistics Platform), adotará para **prevenir, detectar, conter, erradicar, recuperar e aprender** com incidentes de segurança da informação e com incidentes de segurança envolvendo dados pessoais.

O objetivo é assegurar:

1. A **preservação da confidencialidade, integridade, disponibilidade e resiliência** dos sistemas e dos dados tratados na plataforma GLOP, notadamente as PII do comprador (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor) ingeridas via API de gateways (Monetizze, Hotmart, Kiwify, AppMax) e e-commerces (Shopify, WooCommerce, Nuvemshop, Mercado Livre).
2. O **cumprimento tempestivo** dos deveres de comunicação de incidente previstos no art. 48 da Lei nº 13.709/2018 (LGPD), na Resolução CD/ANPD nº 15/2024 (Regulamento de Comunicação de Incidente de Segurança) e demais normas aplicáveis.
3. A **mitigação de danos** a titulares, a produtores/lojistas contratantes ([CONTRATANTE]) e à própria plataforma.
4. A **rastreabilidade e a defensabilidade jurídica** de todas as decisões e ações, mediante registro de evidências e trilha de auditoria.

## 2. Escopo e Abrangência

### 2.1 Abrangência material

Este PRI aplica-se a todo e qualquer evento que comprometa ou ameace comprometer a segurança da informação ou a proteção de dados pessoais no ambiente GLOP, incluindo, sem limitação:

- Acesso não autorizado, exfiltração, alteração, perda ou destruição de dados pessoais ou corporativos.
- Comprometimento de credenciais (JWT do Supabase Auth, credenciais de API dos gateways, tokens de integração write-only, chaves de serviço, segredos de ambiente Netlify).
- Falhas de controle de acesso (RLS/RBAC) que resultem em vazamento cross-tenant (isolamento por empresa).
- Infecção por software malicioso, ransomware, criptomineração ou comprometimento de cadeia de suprimentos de software.
- Indisponibilidade relevante (ataques de negação de serviço, falha de sub-operador de infraestrutura Supabase/Netlify).
- Exposição indevida de documentos fiscais (NF-e via VHSYS), dados bancários/PIX de coprodutores e afiliados, ou dados do portal público de rastreio.
- Incidentes originados em sub-operadores/terceiros (Supabase, Netlify, VHSYS, Correios, gateways de pagamento, provedores de WhatsApp/e-mail).

### 2.2 Abrangência subjetiva

Vincula todos os colaboradores, prepostos, prestadores de serviço, estagiários, administradores de sistema e terceiros com acesso — lógico ou físico — aos ativos, aos ambientes e aos dados da plataforma GLOP, independentemente de vínculo empregatício.

### 2.3 Abrangência temporal

Aplica-se de forma permanente, 24 horas por dia, 7 dias por semana, com plantão de acionamento conforme item 6.

### 2.4 Exclusões

Não são objeto deste PRI eventos meramente operacionais sem qualquer nexo com segurança ou privacidade (ex.: erro de digitação de um usuário sem exposição de dado a terceiro), os quais seguem os fluxos ordinários de suporte. Havendo dúvida sobre o enquadramento, aplica-se o princípio da precaução: o evento é tratado como incidente até prova em contrário.

## 3. Definições

| Termo | Definição |
|---|---|
| **Incidente de segurança** | Evento adverso, confirmado ou sob suspeita, que compromete a confidencialidade, integridade, disponibilidade ou autenticidade de ativos de informação. |
| **Incidente de segurança com dados pessoais** | Incidente que possa acarretar risco ou dano relevante aos titulares, nos termos do art. 48 da LGPD e da Resolução CD/ANPD nº 15/2024. |
| **Evento de segurança** | Ocorrência identificável que pode indicar violação de política ou falha de controle, ainda sem confirmação de impacto. |
| **Titular** | Pessoa natural a quem se referem os dados pessoais tratados (comprador final, colaborador, coprodutor pessoa física, afiliado). |
| **Controlador** | Agente a quem competem as decisões sobre o tratamento (art. 5º, VI, LGPD). |
| **Operador** | Agente que trata dados em nome do controlador (art. 5º, VII, LGPD). |
| **CSIRT** | Computer Security Incident Response Team — equipe de resposta a incidentes, definida no item 6. |
| **DPO/Encarregado** | Pessoa indicada como canal de comunicação entre controlador, titulares e ANPD (art. 5º, VIII, e art. 41, LGPD): a ser designado pela administração. |
| **ANPD** | Autoridade Nacional de Proteção de Dados. |
| **PII** | Personally Identifiable Information — dados pessoais que identificam ou tornam identificável o titular. |
| **RLS / RBAC** | Row Level Security e Role-Based Access Control — controles de isolamento por empresa (tenant) e por permissão (has_permission) da plataforma. |
| **Sub-operador** | Terceiro contratado pelo operador para tratar dados em cadeia (Supabase, Netlify, VHSYS, Correios, gateways, provedores de mensageria). |
| **RTO / RPO** | Recovery Time Objective / Recovery Point Objective — metas de tempo e de perda máxima de dados na recuperação. |
| **IoC** | Indicator of Compromise — indicador técnico de comprometimento (hash, IP, domínio, artefato). |
| **Cadeia de custódia** | Registro documentado e íntegro do ciclo de vida de cada evidência. |

## 4. Fundamentos Legais e Normativos

Este PRI fundamenta-se, entre outros:

1. **Lei nº 13.709/2018 (LGPD)** — arts. 6º (princípios de segurança e prevenção), 44, 46, 47 e 48 (dever de comunicar incidente à ANPD e ao titular); art. 49 (segurança dos sistemas); art. 50 (boas práticas e governança).
2. **Resolução CD/ANPD nº 15, de 24 de abril de 2024** — Regulamento de Comunicação de Incidente de Segurança: prazo, forma e conteúdo da comunicação.
3. **Resolução CD/ANPD nº 2/2022** — critérios de agentes de tratamento de pequeno porte (aplicável se for o caso da LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA).
4. **Decreto nº 10.474/2020** e Regimento Interno da ANPD.
5. **Lei nº 12.965/2014 (Marco Civil da Internet)** — guarda de registros e segurança.
6. **Lei nº 8.078/1990 (CDC)** — dever de segurança e informação ao consumidor comprador.
7. **Lei nº 12.737/2012 (Lei Carolina Dieckmann)** e Código Penal — crimes cibernéticos (subsídio a notitia criminis).
8. **ABNT NBR ISO/IEC 27001 e 27002** — Sistema de Gestão de Segurança da Informação e controles.
9. **ABNT NBR ISO/IEC 27035** — Gestão de Incidentes de Segurança da Informação.
10. **ABNT NBR ISO/IEC 27701** — Extensão de privacidade (PIMS).
11. **ABNT NBR ISO 22301** — Gestão de Continuidade de Negócios.
12. **ABNT NBR ISO 31000** — Gestão de Riscos.
13. **NIST SP 800-61 Rev. 2** — Computer Security Incident Handling Guide.
14. **OWASP** — práticas de segurança de aplicações web.
15. **Regulamento (UE) 2016/679 (GDPR)** — arts. 33 e 34 (subsidiariamente, para titulares/operações sujeitas à norma europeia).

## 5. Princípios Reitores da Resposta

1. **Precaução e prevenção** — na dúvida, trata-se como incidente e comunica-se internamente.
2. **Tempestividade** — prazos legais são improrrogáveis; a comunicação parcial precede a completa.
3. **Proporcionalidade** — a resposta é dimensionada à severidade (item 7).
4. **Minimização** — durante a resposta, o acesso a dados pessoais restringe-se ao estritamente necessário.
5. **Rastreabilidade e defensabilidade** — toda ação é registrada com autor, data/hora e justificativa (aproveitando a trilha de auditoria por triggers e as colunas de auditoria de cada registro).
6. **Preservação de evidências** — a contenção não pode destruir prova (item 12).
7. **Transparência responsável** — comunica-se o necessário, sem expor detalhes técnicos que ampliem o risco.
8. **Segregação de funções** — quem investiga não é, em regra, quem aprova a comunicação externa.
9. **Continuidade do negócio** — restabelecer o serviço com segurança, respeitando RTO/RPO.

## 6. Papéis e Responsabilidades — Equipe de Resposta a Incidentes (CSIRT)

### 6.1 Composição do CSIRT

| Papel | Responsável (titular / suplente) | Atribuições centrais |
|---|---|---|
| **Coordenador de Resposta a Incidentes (Incident Commander)** | [NOME] / [SUPLENTE] | Declara o incidente, ativa o CSIRT, decide contenção e escalonamento, é a autoridade única de decisão durante o incidente. |
| **Encarregado/DPO** | a ser designado pela administração — lemoncapsencapsulados@gmail.com | Avalia risco a titulares, decide sobre comunicação à ANPD e aos titulares (art. 48), interage com a Autoridade, mantém o registro do incidente. |
| **Líder Técnico de Segurança (SecOps)** | [NOME] / [SUPLENTE] | Conduz análise forense, contenção técnica, erradicação, coleta de IoCs e evidências. |
| **Engenharia/Infraestrutura (Supabase/Netlify)** | [NOME] / [SUPLENTE] | Executa ações em banco (RLS, rotação de chaves), aplicação, hospedagem SSR, backups e restauração. |
| **Jurídico/Compliance** | [NOME] / [SUPLENTE] | Avalia obrigações legais, contratos com [CONTRATANTE] e sub-operadores, orienta notitia criminis, valida comunicações externas. |
| **Comunicação/Relações Institucionais** | [NOME] / [SUPLENTE] | Redige e coordena comunicados a clientes contratantes, titulares, imprensa e canais oficiais. |
| **Relacionamento com Clientes/Suporte** | [NOME] / [SUPLENTE] | Canaliza a comunicação com produtores/lojistas contratantes e atende titulares afetados. |
| **Patrocinador Executivo (Sponsor)** | [NOME — Diretoria/CEO] | Aloca recursos, aprova decisões de alto impacto e comunicações públicas. |

### 6.2 Regras de operação do CSIRT

1. **Acionamento:** canal único de acionamento — [E-MAIL/TELEFONE DE PLANTÃO DO CSIRT] — disponível 24x7.
2. **Autoridade:** durante um incidente ativo, o Coordenador de Resposta tem autoridade funcional sobre as equipes envolvidas, inclusive para determinar isolamento de sistemas.
3. **Quórum mínimo** para incidentes de severidade alta/crítica: Coordenador, Líder Técnico e Encarregado/DPO.
4. **Rotatividade e suplência:** todo papel possui suplente designado; nenhuma decisão crítica depende de pessoa única.
5. **Confidencialidade:** todos os membros firmam termo de confidencialidade específico do CSIRT.
6. **Sala de guerra (war room):** canal seguro dedicado (fora dos sistemas potencialmente comprometidos) para coordenação.

## 7. Classificação e Severidade de Incidentes

### 7.1 Critérios de severidade

A severidade combina **impacto** (dado pessoal envolvido, volume, sensibilidade, criticidade do sistema) e **abrangência** (nº de titulares/tenants afetados, indisponibilidade).

| Severidade | Descrição | Exemplos GLOP | Prazo interno de acionamento |
|---|---|---|---|
| **SEV-1 — Crítico** | Comprometimento confirmado com risco relevante a titulares em larga escala, ou parada total, ou exfiltração massiva de PII. | Exfiltração da base de compradores (CPF, endereço, telefone) de múltiplos tenants; ransomware cifrando produção; vazamento de dados bancários/PIX de coprodutores. | Imediato (até 30 min) — CSIRT completo + Sponsor. |
| **SEV-2 — Alto** | Comprometimento confirmado ou altamente provável, escopo limitado, com risco a titulares. | Falha de RLS expondo pedidos de um tenant a outro; comprometimento de credencial de API de um gateway; acesso não autorizado a documentos fiscais de uma empresa. | Até 1 hora — Coordenador, Líder Técnico, DPO. |
| **SEV-3 — Médio** | Evento suspeito ou incidente contido sem exposição confirmada de PII. | Tentativa de acesso indevido bloqueada por RBAC; varredura anômala; token write-only exposto e rotacionado antes de uso. | Até 4 horas úteis. |
| **SEV-4 — Baixo** | Evento de baixo impacto, sem dado pessoal, sem indisponibilidade relevante. | Alerta isolado de segurança sem exploração; má configuração corrigida preventivamente. | Até 1 dia útil. |

### 7.2 Reclassificação

A severidade é dinâmica. À medida que a análise avança, o Coordenador reavalia e documenta cada mudança de classificação, com data/hora e justificativa. A elevação de severidade nunca depende de aprovação hierárquica; o rebaixamento sim.

### 7.3 Gatilho de avaliação LGPD (art. 48)

Todo incidente SEV-1 e SEV-2 aciona **obrigatoriamente** a avaliação do Encarregado/DPO quanto ao dever de comunicar à ANPD e aos titulares (item 9), sem prejuízo de avaliação em SEV-3 quando houver PII envolvida.

## 8. Ciclo de Vida da Resposta a Incidentes (Fases)

Adota-se o ciclo alinhado à ISO/IEC 27035 e ao NIST SP 800-61.

### 8.1 Preparação

Atividades permanentes que antecedem qualquer incidente:

1. **Inventário de ativos e de dados** — mapa atualizado de sistemas (Next.js/App Router, Supabase, Netlify), fluxos de dados (ingestão via API de gateways e e-commerces; PPN/SRO Correios; NF-e VHSYS; split AppMax) e categorias de PII, com registro das operações de tratamento (ROPA — art. 37 LGPD).
2. **Controles preventivos** já implementados e a manter: RLS por empresa, RBAC (has_permission), soft-delete, trilha de auditoria por triggers, colunas de auditoria em todo registro, credenciais de API write-only, segregação de segredos.
3. **Detecção** — logs de aplicação e de banco, alertas de acesso anômalo, monitoramento de disponibilidade e de integridade; retenção de logs por prazo definido em política.
4. **Backups e continuidade** — rotina de backup testada, com RTO e RPO definidos por criticidade; cópias segregadas e imutáveis quando possível.
5. **Contratos e DPAs** — cláusulas de segurança, de notificação de incidente e de auditoria em todos os contratos com sub-operadores (Supabase, Netlify, VHSYS, Correios, gateways, mensageria) e com produtores/lojistas contratantes ([CONTRATANTE]).
6. **Capacitação** — treinamento periódico, simulações tabletop (item 15) e revisão dos playbooks.
7. **Ferramentaria pronta** — acessos de quebra de vidro (break-glass) controlados, kit forense, canais de comunicação alternativos e templates de comunicação (item 16).

### 8.2 Detecção e Análise

1. **Recepção do alerta** — de origem interna (monitoramento, colaborador), do titular, de sub-operador ou de terceiro (pesquisador, autoridade).
2. **Triagem inicial** pelo primeiro respondedor: registrar data/hora de detecção, fonte, descrição, sistemas e dados potencialmente envolvidos.
3. **Abertura de ticket de incidente** com identificador único e início do registro de evidências (item 12).
4. **Validação** — o evento é falso positivo, evento de segurança ou incidente confirmado?
5. **Classificação de severidade** (item 7) e **declaração do incidente** pelo Coordenador.
6. **Análise de impacto e escopo:** identificar quais tenants/empresas, quais titulares, quais categorias de dados (PII do comprador, dados de colaborador, dados bancários/PIX, documentos fiscais), volume estimado e vetor.
7. **Determinação da natureza LGPD:** o dado afetado é tratado pela GLOP como **operador** (PII de comprador em nome do produtor/lojista controlador) ou como **controlador** (dados dos próprios usuários/colaboradores)? Isso define a cadeia de notificação (item 10).
8. **Notificação interna** ao Encarregado/DPO e Jurídico para início do relógio de avaliação do art. 48.

### 8.3 Contenção

Objetivo: **estancar** a propagação sem destruir prova.

1. **Contenção de curto prazo (imediata):** isolar sistemas ou contas comprometidas, revogar sessões/JWT, desabilitar credenciais de API comprometidas, bloquear IPs/agentes maliciosos, suspender integrações afetadas (gateway ou e-commerce específico).
2. **Preservação:** antes de desligar/limpar, capturar imagens, snapshots, logs e estados voláteis (item 12).
3. **Contenção de longo prazo:** aplicar correções temporárias que permitam operar com segurança (ex.: reforço de policy RLS, revogação de permissão RBAC indevida, rotação em massa de segredos) enquanto se prepara a erradicação.
4. **Isolamento de tenant:** em falha de isolamento cross-tenant, restringir imediatamente o acesso da(s) empresa(s) envolvida(s) e validar as policies de RLS.
5. **Comunicação preliminar** ao Coordenador e, quando cabível, ao produtor/lojista controlador cujos dados foram afetados.

### 8.4 Erradicação

1. Identificar e **remover a causa-raiz** (vulnerabilidade explorada, credencial vazada, malware, má configuração de RLS/RBAC).
2. Eliminar artefatos maliciosos, contas fraudulentas, persistências e backdoors.
3. **Rotação definitiva** de todas as credenciais potencialmente expostas: chaves de serviço Supabase, JWT secrets, tokens de gateways, segredos de ambiente Netlify, credenciais VHSYS/Correios.
4. Aplicar **correções e hardening** (patches, endurecimento de policies, revisão de permissões, validação OWASP).
5. Verificação de que nenhum vestígio do comprometimento permanece antes da recuperação.

### 8.5 Recuperação

1. **Restauração** dos sistemas a partir de fontes confiáveis (backups verificados e livres de comprometimento), respeitando RPO/RTO.
2. **Validação de integridade** dos dados restaurados e reconciliação (pedidos, NF-e, repasses/split).
3. **Monitoramento reforçado** por período de observação definido (ex.: 14 a 30 dias) para detectar recorrência.
4. **Restabelecimento gradual** das integrações (gateways, e-commerces, Correios, VHSYS) com testes de segurança.
5. **Encerramento formal** do incidente pelo Coordenador, com registro da data/hora e do estado final.

### 8.6 Atividades Pós-Incidente (Lições Aprendidas)

1. **Reunião post-mortem** em até [10] dias úteis do encerramento, sem cultura de culpa (blameless).
2. **Relatório final de incidente** com: linha do tempo, causa-raiz, impacto, dados/titulares afetados, ações de contenção/erradicação/recuperação, comunicações realizadas (ANPD, titulares, contratantes) e evidências.
3. **Plano de ação corretivo** com responsáveis e prazos (melhoria de controles, ajustes de RLS/RBAC, novos alertas).
4. **Atualização** deste PRI, dos playbooks e do ROPA quando aplicável.
5. **Retenção** do dossiê do incidente pelo prazo legal e para eventual apresentação à ANPD (a Resolução CD/ANPD nº 15/2024 exige manutenção de registro dos incidentes, comunicados ou não).

## 9. Comunicação de Incidente à ANPD e aos Titulares (LGPD, art. 48)

### 9.1 Dever legal

Nos termos do art. 48 da LGPD e da Resolução CD/ANPD nº 15/2024, o **controlador** deve comunicar à ANPD e ao titular afetado a ocorrência de incidente de segurança que possa acarretar **risco ou dano relevante** aos titulares.

**Importante — natureza do GLOP (item 10):** quando a GLOP atua como **operador** (PII do comprador em nome do produtor/lojista controlador), o dever primário de comunicar à ANPD e aos titulares é do **controlador**. A GLOP, como operador, deve **comunicar o incidente ao controlador sem demora injustificada**, prestar informações e apoio, e cumprir o previsto no DPA. Quando a GLOP atua como **controlador** (dados de seus usuários/colaboradores), o dever de comunicar à ANPD e aos titulares é da própria GLOP.

### 9.2 Prazo

A comunicação à ANPD e ao titular deve ser feita **em prazo razoável, não superior a 3 (três) dias úteis contados da data do conhecimento** do incidente com risco ou dano relevante, conforme a Resolução CD/ANPD nº 15/2024. Havendo impossibilidade de reunir todas as informações, admite-se **comunicação preliminar** dentro do prazo, seguida de **comunicação complementar** assim que os dados estiverem disponíveis, justificando-se a incompletude.

**Contagem interna GLOP:** o relógio de 3 dias úteis inicia no **conhecimento pelo Encarregado/DPO** (ou por quem deveria dar-lhe ciência). Por isso, todo incidente SEV-1/SEV-2 e todo incidente com PII deve chegar ao DPO **imediatamente** (item 8.2).

### 9.3 Conteúdo mínimo da comunicação à ANPD

A comunicação à ANPD deve conter, no mínimo (art. 48, §1º, LGPD, e Resolução CD/ANPD nº 15/2024):

1. Descrição da natureza e da categoria dos dados pessoais afetados.
2. Número de titulares afetados (ou estimativa), discriminando, quando possível, crianças/adolescentes e dados sensíveis.
3. Descrição das medidas técnicas e de segurança adotadas antes e após o incidente.
4. Os riscos relacionados ao incidente.
5. O motivo da demora, caso a comunicação não tenha sido imediata.
6. As medidas que foram ou serão adotadas para reverter ou mitigar os efeitos do prejuízo.
7. Data do conhecimento do incidente e data da ocorrência (se conhecida).
8. Identificação e contato do Encarregado/DPO: a ser designado pela administração — lemoncapsencapsulados@gmail.com.
9. Identificação do agente de tratamento comunicante e sua natureza (controlador/operador).

A comunicação é feita pelos canais oficiais da ANPD (formulário/peticionamento eletrônico vigente).

### 9.4 Conteúdo mínimo da comunicação ao titular

A comunicação ao titular deve ser em **linguagem clara e acessível** e conter, no mínimo:

1. Descrição do incidente, de forma compreensível.
2. As categorias de dados pessoais dele afetados.
3. Os possíveis riscos e consequências.
4. As medidas adotadas ou disponíveis para mitigação e o que o titular pode fazer para se proteger (ex.: atenção a phishing usando seu nome/CPF/endereço, troca de senhas, monitoramento).
5. Os canais de contato para esclarecimentos, incluindo o do Encarregado/DPO.

**Canais de comunicação ao titular no GLOP:** preferencialmente por **e-mail e/ou WhatsApp** já utilizados no fluxo de notificação de rastreio ao comprador, e/ou aviso no portal, sempre respeitando a minimização. Quando a comunicação individual for desproporcional ou inviável, admite-se **comunicação ampla** (aviso público/meios de comunicação), conforme orientação da ANPD.

### 9.5 Critérios de risco/dano relevante (avaliação do DPO)

A avaliação considera, entre outros: natureza e volume dos dados; sensibilidade (dados financeiros/PIX, documentos fiscais, CPF em massa); facilidade de identificação; existência de medidas de mitigação (ex.: dados cifrados/pseudonimizados que reduzam o risco); consequências (fraude, discriminação, dano material/moral, roubo de identidade); e a escala de titulares afetados. A ausência de comunicação, quando decidida, é **fundamentada e registrada** no dossiê.

### 9.6 Fluxo de decisão (art. 48)

1. Confirmação do incidente e do escopo (item 8.2).
2. DPO avalia risco/dano relevante (9.5).
3. Se **operador**: notifica o(s) controlador(es) contratante(s) e apoia; controlador decide sobre ANPD/titulares.
4. Se **controlador**: DPO + Jurídico preparam e submetem a comunicação à ANPD e aos titulares dentro do prazo (9.2).
5. Registro de tudo (item 12) e no registro de incidentes.

## 10. Dupla Natureza GLOP: Operador x Controlador — Cadeia de Notificação

| Cenário | Papel da GLOP | Controlador | Quem comunica ANPD/titular | Dever da GLOP |
|---|---|---|---|---|
| Vazamento de PII do **comprador** (nome, CPF, endereço, telefone, valor) ingerida de gateway/e-commerce | **Operador** | Produtor/lojista [CONTRATANTE] | Controlador | Comunicar o incidente ao controlador sem demora, prestar informações do art. 48 e apoio, conforme DPA. |
| Vazamento de dados de **usuários/colaboradores** da própria GLOP | **Controlador** | GLOP | GLOP | Comunicar à ANPD e aos titulares diretamente. |
| Comprometimento de **credenciais de integração** que afeta múltiplos controladores | **Operador (multi)** | Cada [CONTRATANTE] afetado | Cada controlador | Notificar cada controlador afetado, individualizando o escopo por tenant. |
| Dados de **coprodutores/afiliados** cadastrados diretamente na plataforma (PIX/bancários) | A definir no DPA — frequentemente **controlador** quanto ao cadastro | Conforme DPA | Conforme papel | Avaliar caso a caso com Jurídico/DPO. |

**Regra prática:** o isolamento por empresa (RLS/tenant_id) permite delimitar, com precisão, quais controladores foram afetados, viabilizando notificação individualizada e proporcional. A trilha de auditoria por triggers sustenta a reconstituição do escopo por tenant.

## 11. Playbooks Operacionais

Cada playbook segue as fases do item 8. Todos exigem abertura de ticket e registro de evidências (item 12).

### 11.1 Playbook — Vazamento de Dados Pessoais (PII do Comprador e de Usuários)

**Gatilhos:** exposição de base de compradores; consulta anômala retornando dados de múltiplos tenants; PII indexada indevidamente; extração via credencial comprometida; falha de RLS.

**Detecção/Análise:**
1. Confirmar o vetor: falha de RLS/RBAC, credencial vazada, injeção, exposição de endpoint, erro de configuração de bucket de Storage.
2. Delimitar tenants/empresas afetados via tenant_id e trilha de auditoria; quantificar titulares e categorias (CPF/CNPJ, endereço, telefone, e-mail, valor).
3. Classificar severidade (em regra SEV-1/SEV-2).

**Contenção:**
1. Revogar sessões/JWT e desabilitar credencial/endpoint explorado.
2. Corrigir/reforçar a policy RLS ou a permissão RBAC indevida; bloquear a query/rota vulnerável.
3. Preservar logs de acesso ao banco e à aplicação.

**Erradicação:** remover causa-raiz (corrigir policy, rotacionar segredos, patch); validar que nenhuma outra rota expõe o mesmo dado.

**Recuperação:** revalidar isolamento por empresa; monitoramento reforçado; reabilitar acessos.

**Privacidade (art. 48):** DPO avalia risco/dano relevante; se operador, notificar controlador(es) [CONTRATANTE]; se controlador, notificar ANPD e titulares no prazo (item 9). Preparar orientação antifraude aos titulares (alerta a golpes usando seus dados).

### 11.2 Playbook — Comprometimento de Credenciais e Acessos

**Gatilhos:** vazamento de chave de serviço Supabase, JWT secret, token de API de gateway (Monetizze/Hotmart/Kiwify/AppMax), segredo de ambiente Netlify, credencial VHSYS/Correios, ou acesso privilegiado indevido.

**Detecção/Análise:**
1. Identificar qual credencial, seu escopo e onde foi exposta (repositório, log, terceiro, phishing).
2. Verificar uso indevido nos logs (chamadas anômalas, horários atípicos, origem estrangeira).

**Contenção (imediata):**
1. **Rotacionar/revogar** a credencial comprometida sem demora.
2. Invalidar sessões associadas; revogar tokens dependentes.
3. Recordar que credenciais de API são **write-only** — avaliar se houve tentativa de leitura por outro vetor.
4. Bloquear origem maliciosa.

**Erradicação:** rotação em cascata de segredos relacionados; revisar como o segredo vazou (pipeline, variável de ambiente, log) e corrigir; reforçar gestão de segredos e princípio do menor privilégio.

**Recuperação:** reemitir credenciais, testar integrações, monitorar.

**Privacidade:** avaliar se o comprometimento resultou em acesso a PII; em caso positivo, seguir 11.1 e item 9.

### 11.3 Playbook — Ransomware / Software Malicioso

**Gatilhos:** arquivos cifrados, nota de resgate, indisponibilidade abrupta, alerta de EDR/antimalware, comportamento anômalo em cargas de trabalho.

**Detecção/Análise:**
1. Identificar sistemas afetados e vetor de entrada (phishing, credencial, dependência comprometida).
2. Determinar se houve **exfiltração** de dados antes da cifragem (dupla extorsão) — crítico para o art. 48.

**Contenção:**
1. **Isolar** imediatamente os sistemas afetados da rede e das integrações (gateways, VHSYS, Correios).
2. Preservar amostras do malware, logs e imagens forenses **antes** de qualquer limpeza.
3. **Não pagar resgate** sem deliberação de Jurídico/Sponsor; o pagamento não é a estratégia primária e não substitui a resposta.

**Erradicação:** remover o malware e persistências; reconstruir a partir de fontes limpas; rotacionar todos os segredos.

**Recuperação:** restaurar de **backups verificados e imutáveis** (respeitando RPO/RTO); validar integridade; monitorar recorrência.

**Privacidade/Legal:** se houve exfiltração de PII, acionar item 9; avaliar **notitia criminis** à autoridade policial e comunicação a sub-operadores/seguradora cibernética, se houver.

### 11.4 Playbook — Comprometimento de Sub-operador (Supabase, Netlify, VHSYS, Correios, Gateways, Mensageria)

**Gatilhos:** comunicação de incidente por sub-operador; indisponibilidade de serviço de terceiro; vazamento noticiado de fornecedor.

**Ações:**
1. Registrar a notificação recebida (data/hora, conteúdo, escopo informado).
2. Avaliar impacto sobre dados/tenants da GLOP e obrigações contratuais (DPA do sub-operador).
3. Exigir do sub-operador informações do art. 48 e cooperação.
4. Repassar, na condição de operador, a informação ao(s) controlador(es) [CONTRATANTE] afetado(s); se controlador, avaliar ANPD/titulares (item 9).
5. Ativar contingência (ex.: rota alternativa de transporte, gateway secundário, backup de dados fiscais) conforme continuidade (ISO 22301).
6. Registrar no dossiê e cobrar RCA (Root Cause Analysis) do fornecedor.

### 11.5 Playbook — Exposição do Portal Público de Rastreio

**Contexto:** o portal público de rastreio é **sem login** e deve expor **apenas status neutro**, jamais PII.

**Gatilhos:** enumeração de códigos de rastreio; retorno de dado além do status neutro; correlação que revele destinatário/endereço.

**Ações:**
1. Confirmar se o portal vazou algo além do status neutro (nome, endereço, telefone, CPF).
2. Contenção: limitar taxa (rate limit), impedir enumeração previsível de códigos, remover qualquer campo de PII da resposta pública.
3. Erradicação: revisar o endpoint público para garantir **exposição mínima** (só status neutro), sem identificadores diretos.
4. Se houve exposição de PII: seguir 11.1 e item 9.

### 11.6 Playbook — Fraude em Split/Repasses e Dados Bancários/PIX

**Contexto:** coprodução, comissões, apuração, repasses e split (AppMax) tratam **dados bancários/PIX** de coprodutores e afiliados — alta sensibilidade.

**Gatilhos:** alteração indevida de chave PIX/dados bancários; repasse a destino não autorizado; acesso anômalo aos dados de repasse.

**Ações:**
1. **Congelar** repasses suspeitos e a alteração de dados bancários afetados.
2. Verificar trilha de auditoria (quem alterou, quando, de onde) — colunas de auditoria e triggers.
3. Contenção: exigir reautenticação/confirmação para alterações de chave PIX; revogar acessos indevidos.
4. Erradicação: reverter alterações fraudulentas; corrigir a falha de autorização.
5. Legal/Privacidade: avaliar dano financeiro, comunicação aos titulares afetados (art. 48), notitia criminis e acionamento do gateway (AppMax).

## 12. Registro e Preservação de Evidências (Cadeia de Custódia)

### 12.1 Princípios

Toda evidência deve ser **íntegra, autêntica, rastreável e preservada** para fins de investigação interna, prestação de contas à ANPD e eventual uso judicial.

### 12.2 O que preservar

1. Logs de aplicação, de banco (Supabase), de hospedagem (Netlify) e de integrações.
2. Trilha de auditoria por triggers e colunas de auditoria (created_by, updated_by, updated_at, version, metadata) dos registros envolvidos.
3. Snapshots/imagens de sistemas, dumps de memória volátil quando aplicável.
4. IoCs (hashes, IPs, domínios, artefatos), amostras de malware em ambiente isolado.
5. Comunicações do incidente (e-mails, tickets, notificações de sub-operadores).
6. Configurações relevantes (policies de RLS, papéis RBAC) no estado do incidente.

### 12.3 Cadeia de custódia

Para cada evidência, registrar:

| Campo | Descrição |
|---|---|
| Identificador da evidência | Código único. |
| Descrição | O que é. |
| Origem | Sistema/fonte. |
| Data/hora da coleta | Com fuso horário. |
| Responsável pela coleta | Nome/função. |
| Método de coleta | Ferramenta/procedimento. |
| Hash de integridade | Algoritmo e valor. |
| Local de armazenamento | Repositório seguro e de acesso restrito. |
| Movimentações | Quem acessou, quando e por quê. |

### 12.4 Regras

1. **Não alterar** o original; trabalhar sobre cópias verificadas por hash.
2. **Acesso restrito** ao repositório de evidências (menor privilégio, log de acesso).
3. **Retenção** pelo prazo legal/prescricional e enquanto durar eventual procedimento perante a ANPD ou o Judiciário.
4. **Soft-delete e imutabilidade:** aproveitar a política de nunca fazer DELETE físico para preservar histórico; evidências não são apagadas durante o incidente.

## 13. Comunicação Interna e Externa

### 13.1 Matriz de comunicação

| Destinatário | Quando | Responsável | Canal |
|---|---|---|---|
| CSIRT | Na detecção | Primeiro respondedor | Canal de plantão 24x7 |
| Sponsor Executivo | SEV-1/SEV-2 | Coordenador | Direto/seguro |
| Encarregado/DPO | Todo incidente com PII | Coordenador | Direto |
| Produtor/lojista [CONTRATANTE] afetado | Quando GLOP é operador | Relacionamento + Jurídico | E-mail/canal contratual |
| Titulares afetados | Conforme art. 48 | DPO + Comunicação | E-mail/WhatsApp/portal |
| ANPD | Conforme art. 48 (controlador) | DPO + Jurídico | Canal oficial ANPD |
| Sub-operadores | Quando envolvidos | Líder Técnico/Jurídico | Canal contratual |
| Autoridade policial | Suspeita de crime | Jurídico | Notitia criminis |
| Imprensa/público | Se necessário | Comunicação + Sponsor | Comunicado oficial |

### 13.2 Regras de comunicação

1. **Fonte única da verdade:** apenas porta-vozes designados falam externamente.
2. **Nada por canais comprometidos:** se o e-mail/sistema estiver comprometido, usar canal alternativo pré-definido.
3. **Sem especulação:** comunicar fatos confirmados; distinguir preliminar de complementar.
4. **Consistência:** as comunicações a ANPD, titulares e contratantes devem ser coerentes entre si.

## 14. Métricas, Indicadores e Melhoria Contínua

Indicadores mínimos monitorados:

1. **MTTD** (tempo médio de detecção).
2. **MTTR** (tempo médio de resposta/recuperação).
3. Tempo entre conhecimento e comunicação à ANPD/titulares (aderência ao prazo do art. 48).
4. Nº de incidentes por severidade e por tipo (playbook).
5. Nº de incidentes com PII e volume de titulares afetados.
6. Percentual de ações corretivas concluídas no prazo.
7. Resultado das simulações (item 15).

Os indicadores são revisados periodicamente pelo DPO e pela Diretoria e alimentam a melhoria contínua (PDCA), a atualização do PRI e o programa de governança de privacidade (art. 50, LGPD).

## 15. Treinamento, Testes e Simulações (Tabletop)

1. **Treinamento** de todos os colaboradores em reconhecimento e reporte de incidentes, no mínimo anual e no onboarding.
2. **Capacitação específica** do CSIRT nos playbooks.
3. **Simulações tabletop** ao menos [semestrais], exercitando cenários (vazamento de PII, ransomware, credencial comprometida, incidente de sub-operador).
4. **Teste de restauração** de backups ao menos [trimestral], validando RTO/RPO.
5. **Revisão** dos playbooks após cada simulação e após cada incidente real.

## 16. Anexos e Modelos

- **Anexo A** — Formulário de Registro de Incidente (ticket).
- **Anexo B** — Modelo de Comunicação de Incidente à ANPD (art. 48).
- **Anexo C** — Modelo de Comunicação ao Titular.
- **Anexo D** — Modelo de Notificação da GLOP (operador) ao Controlador [CONTRATANTE].
- **Anexo E** — Registro de Cadeia de Custódia de Evidências.
- **Anexo F** — Lista de Contatos do CSIRT e Plantão 24x7.
- **Anexo G** — Relatório Final de Incidente (post-mortem).
- **Anexo H** — Matriz de Sub-operadores e canais de acionamento (Supabase, Netlify, VHSYS, Correios, gateways, mensageria).

---

## 17. Engenharia Jurídica & Governança

### (a) Fundamentação das Cláusulas

| Seção do PRI | Fundamento legal/normativo |
|---|---|
| Dever de segurança e prevenção (itens 5, 8.1) | LGPD, arts. 6º, VII e VIII, 46, 47, 49; ISO/IEC 27001/27002. |
| Gestão de incidentes por fases (item 8) | ISO/IEC 27035; NIST SP 800-61 Rev. 2. |
| Comunicação à ANPD e ao titular; prazo de 3 dias úteis; conteúdo mínimo (item 9) | LGPD, art. 48 e §§; Resolução CD/ANPD nº 15/2024. |
| Papel do Encarregado (itens 6, 9) | LGPD, arts. 5º, VIII, e 41. |
| Distinção controlador/operador e cadeia de notificação (item 10) | LGPD, arts. 5º, VI e VII, 39, 48; obrigações contratuais (DPA). |
| Governança e boas práticas; melhoria contínua (itens 14, 15) | LGPD, art. 50; ISO/IEC 27701; ISO 31000. |
| Continuidade e recuperação; RTO/RPO; backups (itens 8.5, 11.3, 15) | ISO 22301. |
| Preservação de evidências e cadeia de custódia (item 12) | Marco Civil da Internet (Lei 12.965/2014); ISO/IEC 27037 (evidência digital); CPC (prova). |
| Notitia criminis; crimes cibernéticos (itens 11.3, 13) | Lei 12.737/2012; Código Penal. |
| Segurança de aplicação (RLS/RBAC, portal público, endpoints) | OWASP; LGPD, art. 46; NIST. |
| Dever de informação ao consumidor comprador | CDC, arts. 6º, III, e 8º. |
| Referência subsidiária a operações internacionais | GDPR, arts. 33 e 34. |

### (b) Riscos Mitigados

1. **Sanção administrativa da ANPD** (advertência, multa de até 2% do faturamento limitada a R$ 50 milhões por infração, publicização) por comunicação intempestiva ou omissa (art. 52, LGPD).
2. **Responsabilidade civil** por danos materiais e morais a titulares (arts. 42 a 45, LGPD) e ao consumidor (CDC).
3. **Vazamento cross-tenant** e quebra de isolamento, mitigados por resposta rápida e reforço de RLS/RBAC.
4. **Descontrole de escopo** em incidentes multi-controlador, mitigado pela individualização por tenant_id e trilha de auditoria.
5. **Perda de prova** e indefensabilidade, mitigadas pela cadeia de custódia e pela política de soft-delete/imutabilidade.
6. **Indisponibilidade prolongada** (dano reputacional e contratual), mitigada por continuidade, backups e RTO/RPO.
7. **Fraude financeira** em split/PIX, mitigada por congelamento, reautenticação e auditoria.
8. **Risco de terceiros/sub-operadores**, mitigado por DPAs, cláusulas de notificação e contingência.
9. **Dano a titulares por phishing** com dados vazados, mitigado por orientação antifraude na comunicação.
10. **Descumprimento contratual** com produtores/lojistas [CONTRATANTE], mitigado pela cadeia de notificação operador→controlador.

### (c) Checklist de Implementação

1. [ ] CSIRT nomeado, com titulares e suplentes e termo de confidencialidade assinado.
2. [ ] Canal de plantão 24x7 ativo e testado.
3. [ ] Encarregado/DPO indicado e publicado (a ser designado pela administração / lemoncapsencapsulados@gmail.com).
4. [ ] Inventário de ativos e ROPA atualizados (fluxos de gateways, e-commerces, Correios, VHSYS, split).
5. [ ] Controles preventivos verificados: RLS, RBAC, soft-delete, triggers de auditoria, credenciais write-only, gestão de segredos.
6. [ ] Logs e monitoramento com retenção definida.
7. [ ] Backups testados; RTO/RPO documentados por criticidade.
8. [ ] DPAs com todos os sub-operadores contendo cláusula de notificação de incidente.
9. [ ] Templates de comunicação (ANPD, titular, controlador) prontos (Anexos B, C, D).
10. [ ] Portal público de rastreio auditado para expor apenas status neutro.
11. [ ] Repositório seguro de evidências com controle de acesso.
12. [ ] Plano de simulação tabletop agendado.
13. [ ] Métricas (MTTD, MTTR, aderência ao art. 48) instrumentadas.
14. [ ] Revisão jurídica final por advogado(a) habilitado(a).

### (d) Matriz RACI

Legenda: **R** = Responsável executa; **A** = Aprova/responde final; **C** = Consultado; **I** = Informado.

| Atividade | Coord. Incidente | DPO/Encarregado | Líder Técnico | Eng./Infra | Jurídico | Comunicação | Sponsor |
|---|---|---|---|---|---|---|---|
| Declarar incidente e ativar CSIRT | A/R | C | C | I | I | I | I |
| Classificar severidade | A/R | C | C | I | I | I | I |
| Análise forense e coleta de evidências | A | I | R | C | C | I | I |
| Contenção técnica | A | I | R | R | I | I | I |
| Erradicação e rotação de segredos | A | I | R | R | I | I | I |
| Recuperação/restauração | A | I | C | R | I | I | I |
| Avaliar risco/dano relevante (art. 48) | C | A/R | C | I | C | I | I |
| Comunicar à ANPD | I | A/R | I | I | R | C | I |
| Comunicar aos titulares | I | A/R | I | I | C | R | I |
| Notificar controlador [CONTRATANTE] | I | C | I | I | C | R | A |
| Comunicação pública/imprensa | I | C | I | I | C | R | A |
| Notitia criminis | I | C | C | I | R/A | I | C |
| Post-mortem e plano corretivo | R | A | R | C | C | I | A |
| Aprovar recursos/decisões de alto impacto | C | C | I | I | C | I | A/R |

### (e) Plano de Revisão

1. **Periodicidade:** revisão ordinária **anual** (até [DATA + 12 meses]).
2. **Gatilhos de revisão extraordinária:** ocorrência de incidente SEV-1/SEV-2; mudança legislativa ou nova resolução da ANPD; alteração relevante de arquitetura (novo sub-operador, novo gateway/e-commerce); resultado crítico de simulação ou auditoria; recomendação da ANPD.
3. **Responsável pela revisão:** Encarregado/DPO, com apoio de Jurídico e Líder Técnico; aprovação da Diretoria.
4. **Registro:** toda revisão é versionada (tabela abaixo) e comunicada ao CSIRT.

### (f) Controle de Versão

| Versão | Data | Autor | Aprovação | Descrição da alteração |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | [AUTOR] | [NOME DO RESPONSÁVEL] | Emissão inicial do Plano de Resposta a Incidentes GLOP. |
| [1.1] | 16 de julho de 2026 | [AUTOR] | [APROVADOR] | [Descrição] |
| [2.0] | 16 de julho de 2026 | [AUTOR] | [APROVADOR] | [Descrição] |

---

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente. Este PRI não constitui aconselhamento jurídico; sua eficácia depende da implementação efetiva dos controles descritos e da validação por profissional habilitado.
