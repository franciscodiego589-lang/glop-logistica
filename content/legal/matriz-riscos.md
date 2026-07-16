> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# MATRIZ DE RISCOS — GLOP (Global Logistics Platform)

**Documento:** Matriz Corporativa de Riscos Jurídicos, de Proteção de Dados (LGPD), de Segurança da Informação e Operacionais
**Controladora / Editora:** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, inscrita no CNPJ sob o nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, operadora da plataforma [NOME FANTASIA: GLOP]
**Classificação da informação:** Confidencial — Interno (uso restrito à alta direção, Comitê de Riscos, Encarregado/DPO, Compliance e Segurança da Informação)
**Aprovação:** [ÓRGÃO/PESSOA APROVADORA] em 16 de julho de 2026
**Vigência:** a partir de 16 de julho de 2026
**Versão:** 1.0
**Responsável pela guarda e atualização:** Comitê de Gestão de Riscos, com apoio do Encarregado de Dados (a ser designado pela administração) e do Responsável pela Segurança da Informação (CISO)
**Contato do Encarregado (DPO):** lemoncapsencapsulados@gmail.com

---

## Sumário

1. Objetivo
2. Definições e Glossário
3. Escopo e Aplicabilidade
4. Fundamentos Legais e Normativos
5. Metodologia de Avaliação de Riscos
6. Escalas de Probabilidade, Impacto e Nível de Risco
7. Apetite e Tolerância a Riscos
8. Categorias de Risco
9. Matriz de Riscos Jurídicos, Contratuais e Regulatórios
10. Matriz de Riscos de Proteção de Dados (LGPD)
11. Matriz de Riscos de Segurança da Informação
12. Matriz de Riscos Operacionais e de Continuidade de Negócio
13. Matriz de Riscos de Terceiros e Sub-operadores
14. Matriz de Riscos de Consumidor, Marketplace e Financeiros
15. Riscos Específicos e Críticos do GLOP (Aprofundamento)
16. Mapa de Calor (Heat Map) e Priorização
17. Estratégias de Tratamento e Planos de Ação
18. Monitoramento, Indicadores (KRIs) e Reavaliação
19. Comunicação, Escalonamento e Gestão de Incidentes
20. Papéis e Responsabilidades
21. Engenharia Jurídica & Governança

---

## 1. Objetivo

1.1. Esta Matriz de Riscos ("Matriz") tem por objetivo identificar, analisar, avaliar, priorizar, tratar e monitorar os riscos jurídicos, de proteção de dados pessoais (LGPD), de segurança da informação e operacionais a que está exposta a operação da plataforma [NOME FANTASIA: GLOP] — Software as a Service (SaaS) de logística e ERP voltado a operações de dropshipping e comercialização de infoprodutos no Brasil.

1.2. A Matriz visa a:

- **a)** fornecer visão consolidada e priorizada dos riscos, permitindo a alocação racional de recursos de tratamento;
- **b)** documentar os controles existentes e as lacunas de controle, subsidiando decisões da alta direção;
- **c)** demonstrar diligência, prestação de contas (accountability) e conformidade perante a Autoridade Nacional de Proteção de Dados (ANPD), o Poder Judiciário, órgãos de defesa do consumidor, clientes controladores e auditores;
- **d)** servir de insumo direto ao Relatório de Impacto à Proteção de Dados Pessoais (RIPD/DPIA), ao Registro de Operações de Tratamento (ROPA), ao Plano de Resposta a Incidentes e ao Plano de Continuidade de Negócio;
- **e)** endereçar de forma específica os riscos inerentes ao modelo de negócio do GLOP, tais como o vazamento de dados pessoais (PII) na ingestão de pedidos, a exposição indevida no portal público de rastreio, o tratamento de dados bancários de coprodutores e afiliados, a dependência de sub-operadores e a indisponibilidade de serviço.

1.3. Esta Matriz integra o arcabouço documental de governança do GLOP e deve ser lida de forma harmônica com a Política de Privacidade, o Acordo de Tratamento de Dados (DPA), a Política de Segurança da Informação, a Política de Compliance, o ROPA/RIPD, a Política de Backup, a Política de Retenção e Descarte e os Termos de Uso.

---

## 2. Definições e Glossário

- **Risco:** efeito da incerteza sobre os objetivos, expresso pela combinação da probabilidade de um evento e de suas consequências (ISO 31000; ISO Guia 73).
- **Risco inerente:** nível de risco antes da aplicação de qualquer controle.
- **Risco residual:** nível de risco remanescente após a aplicação dos controles existentes.
- **Probabilidade:** medida da chance de materialização do evento de risco em um horizonte definido.
- **Impacto (Consequência):** magnitude do efeito adverso caso o risco se materialize (jurídico, financeiro, reputacional, regulatório, operacional).
- **Nível de risco:** produto Probabilidade × Impacto, classificado em faixas (Baixo, Médio, Alto, Crítico).
- **Controle:** medida técnica, administrativa ou jurídica que reduz a probabilidade e/ou o impacto de um risco.
- **KRI (Key Risk Indicator):** indicador-chave de risco, métrica que sinaliza a evolução da exposição.
- **Tratamento:** decisão sobre o risco — Mitigar (reduzir), Transferir (compartilhar, ex.: seguro/contrato), Evitar (eliminar a atividade) ou Aceitar (reter conscientemente).
- **Apetite a risco:** nível de risco que a organização está disposta a assumir na busca de seus objetivos.
- **PII (Personally Identifiable Information):** dado pessoal que identifica ou torna identificável pessoa natural (art. 5º, I, da LGPD).
- **Controlador / Operador / Suboperador:** conforme arts. 5º, VI, VII e 39 da LGPD; o GLOP atua como **Operador** dos dados dos compradores (em nome do produtor/lojista **Controlador**) e como **Controlador** dos dados de seus próprios usuários/colaboradores.
- **RLS (Row-Level Security):** segurança em nível de linha do PostgreSQL/Supabase que isola dados por empresa (multi-tenant).
- **RBAC:** controle de acesso baseado em papéis (has_permission).
- **PPN / SRO:** pré-postagem e rastreamento dos Correios.
- **Split:** divisão automática de pagamentos entre produtor, coprodutores e afiliados (via gateway, ex.: AppMax).

---

## 3. Escopo e Aplicabilidade

3.1. Esta Matriz abrange todos os processos, ativos, fluxos de dados, integrações e relações contratuais da operação do GLOP, incluindo, sem limitação:

- **a)** ingestão de pedidos via API de gateways de pagamento e infoprodutos (Monetizze, Hotmart, Kiwify, AppMax) e de e-commerces/marketplaces (Shopify, WooCommerce, Nuvemshop, Mercado Livre), com PII do comprador (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor);
- **b)** integração logística com os Correios: pré-postagem (PPN), rastreamento (SRO) e notificação ao comprador por e-mail e WhatsApp;
- **c)** emissão de documentos fiscais (NF-e) via VHSYS;
- **d)** módulo de coprodução, afiliação e split: comissionamento, apuração, repasses e tratamento de dados bancários e chaves PIX de coprodutores/afiliados;
- **e)** portal público de rastreio (sem autenticação);
- **f)** hospedagem SSR na Netlify e backend Supabase (PostgreSQL, Auth, Storage), com RLS multi-tenant (Tenant → Company → Branch → Membership), RBAC, soft-delete, trilha de auditoria por triggers e credenciais de API write-only;
- **g)** relações com sub-operadores e provedores: Supabase, Netlify, VHSYS, Correios, gateways de pagamento, provedores de e-mail e WhatsApp.

3.2. Aplica-se a sócios, administradores, colaboradores, prestadores de serviço, terceiros e sub-operadores, no que couber às respectivas atribuições.

---

## 4. Fundamentos Legais e Normativos

4.1. **Proteção de dados e privacidade:** Lei nº 13.709/2018 (LGPD), em especial arts. 6º (princípios), 37 (registro), 38 (RIPD), 39 (suboperador), 42 a 45 (responsabilidade e ressarcimento), 46 a 49 (segurança e boas práticas), 48 (comunicação de incidente); Regulamentos e Resoluções da ANPD (inclusive dosimetria de sanções — Resolução CD/ANPD nº 4/2023 — e comunicação de incidente de segurança — Resolução CD/ANPD nº 15/2024).

4.2. **Consumidor:** Lei nº 8.078/1990 (CDC); Decreto nº 7.962/2013 (e-commerce); Lei nº 14.181/2021 (superendividamento, no que couber).

4.3. **Civil e empresarial:** Lei nº 10.406/2002 (Código Civil), especialmente responsabilidade civil (arts. 186, 187, 927 e parágrafo único — risco da atividade); Lei nº 12.965/2014 (Marco Civil da Internet), arts. 7º, 10 a 15 (guarda de registros e responsabilidade de provedores).

4.4. **Fiscal e financeiro:** legislação de NF-e (ajustes SINIEF, obrigações acessórias estaduais); Lei nº 9.613/1998 (PLD/FT); regulamentação do Banco Central sobre arranjos de pagamento e PIX (no que couber aos gateways).

4.5. **Anticorrupção e concorrencial:** Lei nº 12.846/2013 e Decreto nº 11.129/2022; Lei nº 12.529/2011.

4.6. **Normas técnicas e frameworks:** ISO/IEC 27001 (SGSI) e 27002 (controles); ISO/IEC 27701 (gestão de privacidade); ISO 22301 (continuidade de negócio); ISO 31000 e ISO Guia 73 (gestão de riscos); NIST Cybersecurity Framework e NIST SP 800-30 (avaliação de risco); OWASP Top 10 e OWASP ASVS (segurança de aplicações); RGPD/GDPR (referência para operações e clientes internacionais).

---

## 5. Metodologia de Avaliação de Riscos

5.1. A metodologia adota o ciclo da ISO 31000 e do NIST SP 800-30:

1. **Estabelecimento do contexto** — mapeamento do negócio, ativos, fluxos de dados e partes interessadas.
2. **Identificação de riscos** — levantamento de eventos, causas e fontes de risco por categoria.
3. **Análise de riscos** — atribuição de Probabilidade (P) e Impacto (I) ao risco residual (considerando os controles existentes).
4. **Avaliação de riscos** — cálculo do Nível (N = P × I) e comparação com o apetite a risco.
5. **Tratamento de riscos** — escolha da estratégia (Mitigar, Transferir, Evitar, Aceitar) e definição de planos de ação, responsável e prazo.
6. **Monitoramento e análise crítica** — acompanhamento por KRIs e reavaliação periódica.
7. **Comunicação e consulta** — reporte à alta direção, ao Comitê de Riscos e às partes interessadas.

5.2. A pontuação é atribuída de forma consensual pelo Comitê de Riscos, com apoio das áreas técnicas, jurídica e de privacidade, e documentada nesta Matriz. Salvo indicação em contrário, os níveis registrados nas tabelas referem-se ao **risco residual** (após os controles existentes).

---

## 6. Escalas de Probabilidade, Impacto e Nível de Risco

### 6.1. Escala de Probabilidade (P)

| Grau | Nível | Descrição | Referência de frequência |
|---|---|---|---|
| 1 | Rara | Evento excepcional, sem histórico | Menos de 1 vez a cada 5 anos |
| 2 | Improvável | Pouco provável, mas possível | Cerca de 1 vez a cada 2 a 5 anos |
| 3 | Possível | Pode ocorrer em condições normais | Cerca de 1 vez ao ano |
| 4 | Provável | Espera-se que ocorra | Várias vezes ao ano |
| 5 | Quase certa | Ocorrência recorrente ou iminente | Mensal ou mais frequente |

### 6.2. Escala de Impacto (I)

| Grau | Nível | Jurídico/Regulatório | Financeiro | Reputacional | Operacional/Dados |
|---|---|---|---|---|---|
| 1 | Insignificante | Sem exposição relevante | Perda irrelevante | Sem repercussão | Sem impacto a dados |
| 2 | Menor | Notificação simples | Perda baixa | Reclamações isoladas | Indisponibilidade curta |
| 3 | Moderado | Autuação/ação individual | Perda moderada | Repercussão local | Incidente de dados contido |
| 4 | Maior | Sanção ANPD/ações coletivas | Perda alta | Repercussão nacional | Vazamento de PII em escala |
| 5 | Catastrófico | Sanção máxima/interdição | Perda que ameaça a continuidade | Dano reputacional grave e duradouro | Vazamento massivo/perda de dados |

### 6.3. Faixas de Nível de Risco (N = P × I)

| Faixa (N) | Classificação | Postura exigida |
|---|---|---|
| 1 a 4 | **Baixo** | Aceitar/monitorar; controle de rotina |
| 5 a 9 | **Médio** | Tratar em prazo planejado; monitoramento ativo |
| 10 a 14 | **Alto** | Tratamento prioritário; plano de ação formal e prazo definido |
| 15 a 25 | **Crítico** | Tratamento imediato; reporte à alta direção; não aceitável sem redução |

---

## 7. Apetite e Tolerância a Riscos

7.1. A organização declara **baixo apetite** para riscos de proteção de dados pessoais, segurança da informação e conformidade legal, e **apetite moderado** para riscos operacionais controláveis por redundância e SLA.

7.2. São **inaceitáveis** (apetite zero), exigindo tratamento imediato: vazamento massivo de PII; exposição de dados sensíveis, financeiros ou bancários; quebra do isolamento multi-tenant (cross-tenant); descumprimento de determinação da ANPD ou do Judiciário; e violação dolosa de sigilo.

7.3. Riscos classificados como **Alto** ou **Crítico** não podem ser simplesmente aceitos: exigem plano de tratamento formal, responsável e prazo, com reporte ao Comitê de Riscos e à alta direção.

---

## 8. Categorias de Risco

- **A. Riscos Jurídicos, Contratuais e Regulatórios** — código JUR.
- **B. Riscos de Proteção de Dados (LGPD)** — código LGPD.
- **C. Riscos de Segurança da Informação** — código SEG.
- **D. Riscos Operacionais e de Continuidade de Negócio** — código OPS.
- **E. Riscos de Terceiros e Sub-operadores** — código TER.
- **F. Riscos de Consumidor, Marketplace e Financeiros** — código CMF.

As tabelas a seguir apresentam, para cada risco: código, descrição, categoria, probabilidade (P), impacto (I), nível (N = P × I), classificação, controles existentes, tratamento (estratégia + ação), responsável e prazo.

---

## 9. Matriz de Riscos Jurídicos, Contratuais e Regulatórios

| Cód. | Risco | Cat. | P | I | N | Classe | Controles existentes | Tratamento (estratégia + ação) | Responsável | Prazo |
|---|---|---|---|---|---|---|---|---|---|
| JUR-01 | Ausência ou insuficiência de contrato/DPA com produtores e lojistas (Controladores), gerando indefinição sobre papéis e responsabilidades LGPD | JUR | 3 | 4 | 12 | Alto | DPA e Termos de Uso minutados; cláusula de proteção de dados | Mitigar: exigir aceite eletrônico do DPA no onboarding; versionar e registrar aceite com trilha de auditoria | Jurídico / Compliance | 30 dias |
| JUR-02 | Responsabilização solidária do Operador por dano a titular (arts. 42 a 45 da LGPD) decorrente de falha atribuível ao GLOP | JUR | 3 | 4 | 12 | Alto | Controles de segurança (RLS/RBAC/auditoria); DPA com repartição de responsabilidades | Transferir/Mitigar: cláusula de limitação e regresso no DPA; seguro de responsabilidade civil/cyber; evidências de diligência | Jurídico / Diretoria | 90 dias |
| JUR-03 | Descumprimento do dever de guarda de registros de acesso a aplicações (art. 15 do Marco Civil) por prazo inferior a 6 meses | JUR | 2 | 3 | 6 | Médio | Trilha de auditoria por triggers; logs de aplicação | Mitigar: política de retenção de logs alinhada ao MCI; retenção mínima de 6 meses em ambiente íntegro | CTO / Segurança | 60 dias |
| JUR-04 | Cláusulas abusivas ou não conformes ao CDC/Decreto 7.962 nos Termos de Uso e fluxos de contratação eletrônica | JUR | 2 | 3 | 6 | Médio | Termos de Uso e Política de Privacidade minutados | Mitigar: revisão jurídica dos Termos; destaque de cláusulas limitativas; canal de atendimento e arrependimento | Jurídico | 60 dias |
| JUR-05 | Litígios trabalhistas/terceirização irregular envolvendo prestadores e afiliados | JUR | 2 | 3 | 6 | Médio | Contratos de prestação de serviços; ausência de subordinação | Mitigar: padronizar contratos; evitar elementos de vínculo; due diligence de terceiros | Jurídico / RH | 90 dias |
| JUR-06 | Sanção administrativa da ANPD (advertência, multa até 2% do faturamento limitada a R$ 50 mi por infração, publicização, bloqueio/eliminação de dados) | JUR | 2 | 5 | 10 | Alto | Programa de privacidade; ROPA/RIPD; DPO nomeado; controles técnicos | Mitigar: manter evidências de conformidade e governança; plano de resposta a fiscalização; canal com a ANPD | DPO / Compliance | Contínuo |
| JUR-07 | Descumprimento de obrigações fiscais/acessórias de NF-e (rejeição, contingência, inconsistência) com reflexo em autuação | JUR | 3 | 3 | 9 | Médio | Emissão via VHSYS; conferência de retorno | Mitigar: monitorar rejeições; conciliação fiscal; contrato de nível de serviço com o VHSYS | Financeiro/Fiscal | 90 dias |
| JUR-08 | Uso indevido de propriedade intelectual de terceiros (marcas, logotipos de transportadoras/gateways) ou violação de licenças de software | JUR | 2 | 3 | 6 | Médio | Controle de dependências; contratos de integração | Mitigar: inventário de licenças; autorização de uso de marcas dos parceiros | Jurídico / CTO | 90 dias |
| JUR-09 | Transferência internacional de dados sem base/salvaguarda adequada (infraestrutura de sub-operadores fora do Brasil) | JUR | 3 | 4 | 12 | Alto | Contratos com Supabase/Netlify; cláusulas de proteção de dados | Mitigar: mapear localização dos dados; adotar cláusulas-padrão/garantias; observar normas da ANPD sobre transferência internacional | DPO / Jurídico | 90 dias |
| JUR-10 | Publicidade enganosa ou promessas de resultado de infoprodutos veiculadas por produtores usando a infraestrutura do GLOP | JUR | 3 | 3 | 9 | Médio | Termos de Uso com vedações; política de uso aceitável | Mitigar: cláusula de responsabilidade do produtor; canal de denúncia; suspensão por abuso | Jurídico / Compliance | 60 dias |

---

## 10. Matriz de Riscos de Proteção de Dados (LGPD)

| Cód. | Risco | Cat. | P | I | N | Classe | Controles existentes | Tratamento (estratégia + ação) | Responsável | Prazo |
|---|---|---|---|---|---|---|---|---|---|
| LGPD-01 | Vazamento de PII do comprador na ingestão de pedidos via API/e-commerces (nome, CPF/CNPJ, e-mail, telefone, endereço, valor) | LGPD | 3 | 5 | 15 | Crítico | RLS multi-tenant; RBAC; credenciais de API write-only; TLS; trilha de auditoria | Mitigar: cifrar PII em repouso; minimizar payloads; validar origem/assinatura de webhooks; segregar segredos; DLP e alertas | DPO / CISO / CTO | 30 dias |
| LGPD-02 | Quebra de isolamento multi-tenant (acesso cross-company a dados de outro Controlador) | LGPD | 2 | 5 | 10 | Alto | RLS por company_id; RBAC has_permission; revisão de policies | Mitigar: testes automatizados de RLS por tenant; revisão de código de policies; pentest focado em IDOR/cross-tenant | CTO / CISO | 60 dias |
| LGPD-03 | Tratamento sem base legal adequada ou com finalidade excessiva (uso secundário de PII do comprador além do necessário à logística) | LGPD | 3 | 4 | 12 | Alto | ROPA/RIPD; princípio da finalidade nos Termos | Mitigar: mapear bases legais no ROPA; limitar finalidades no DPA; bloquear uso secundário sem base | DPO | 60 dias |
| LGPD-04 | Falha no atendimento a direitos do titular (acesso, correção, eliminação, portabilidade) nos prazos legais | LGPD | 3 | 3 | 9 | Médio | Soft-delete; trilha de auditoria; DPO nomeado | Mitigar: fluxo de requisições de titular (canal, SLA, roteamento ao Controlador quando Operador); registro de atendimento | DPO | 60 dias |
| LGPD-05 | Retenção excessiva de PII além do necessário (ausência de expurgo por ciclo de vida) | LGPD | 3 | 3 | 9 | Médio | Política de Retenção e Descarte; soft-delete | Mitigar: rotinas de anonimização/expurgo por prazo; revisar retenção de dados fiscais x logísticos | DPO / CTO | 90 dias |
| LGPD-06 | Comunicação intempestiva de incidente à ANPD e aos titulares (art. 48; Resolução CD/ANPD nº 15/2024) | LGPD | 2 | 4 | 8 | Médio | Plano de resposta a incidentes; trilha de auditoria | Mitigar: playbook de notificação com prazos; template de comunicação; teste anual | DPO / CISO | 60 dias |
| LGPD-07 | Ausência/insuficiência de RIPD (DPIA) para tratamentos de alto risco (ingestão em massa, portal público, split bancário) | LGPD | 2 | 4 | 8 | Médio | RIPD/ROPA iniciados | Mitigar: concluir RIPD dos fluxos de alto risco; revisar a cada mudança relevante | DPO | 90 dias |
| LGPD-08 | Compartilhamento com sub-operadores sem contrato de operador nos termos do art. 39 da LGPD | LGPD | 2 | 4 | 8 | Médio | Contratos com sub-operadores; DPA | Mitigar: exigir cláusulas de operador de todos os sub-operadores; inventário e due diligence de privacidade | DPO / Jurídico | 90 dias |
| LGPD-09 | Tratamento de dados de crianças/adolescentes de forma inadvertida (compradores menores) | LGPD | 2 | 3 | 6 | Médio | Termos vedando público infantil | Mitigar: avaliar necessidade de dado; não coletar dados de menores sem base; alertar Controlador | DPO | 90 dias |
| LGPD-10 | Uso de dados de contato do comprador para notificação (e-mail/WhatsApp) além do estritamente logístico, configurando marketing sem consentimento | LGPD | 3 | 3 | 9 | Médio | Notificação restrita a status de entrega | Mitigar: limitar mensagens ao interesse legítimo logístico; opt-out; segregar de campanhas de marketing | DPO / Produto | 60 dias |
| LGPD-11 | Exposição de PII em logs, telemetria ou mensagens de erro | LGPD | 3 | 4 | 12 | Alto | Trilha de auditoria estruturada | Mitigar: mascaramento/hash de PII em logs; revisão de níveis de log; proibir PII em telemetria | CTO / CISO | 60 dias |
| LGPD-12 | Portal público de rastreio revelando dado pessoal ou permitindo enumeração de pedidos/CPF | LGPD | 3 | 4 | 12 | Alto | Portal expõe apenas status neutro, sem login | Mitigar: usar identificadores não sequenciais/opacos; rate limit e anti-scraping; nunca exibir PII; auditoria de payload | CTO / CISO / DPO | 30 dias |

---

## 11. Matriz de Riscos de Segurança da Informação

| Cód. | Risco | Cat. | P | I | N | Classe | Controles existentes | Tratamento (estratégia + ação) | Responsável | Prazo |
|---|---|---|---|---|---|---|---|---|---|
| SEG-01 | Vulnerabilidades de aplicação (OWASP Top 10: injeção, quebra de controle de acesso, SSRF) na camada Next.js/API | SEG | 3 | 4 | 12 | Alto | Revisão de código; RBAC; validação de entrada | Mitigar: SAST/DAST no CI; dependabot; pentest anual; padrões OWASP ASVS | CISO / CTO | 90 dias |
| SEG-02 | Vazamento/rotação inadequada de segredos (chaves de API de gateways, tokens de webhook, service_role do Supabase) | SEG | 3 | 5 | 15 | Crítico | Credenciais de API write-only; segregação de ambientes | Mitigar: cofre de segredos; rotação periódica; proibir segredos no repositório; escopos mínimos; detecção de segredos no CI | CISO / DevOps | 30 dias |
| SEG-03 | Comprometimento de conta por credenciais fracas/sem MFA (Supabase Auth) | SEG | 3 | 4 | 12 | Alto | Supabase Auth (JWT); Política de Senhas | Mitigar: exigir MFA para papéis privilegiados; política de senha forte; detecção de anomalia de login | CISO | 60 dias |
| SEG-04 | Escalada de privilégio por configuração indevida de RBAC/RLS (permissão excessiva) | SEG | 2 | 5 | 10 | Alto | RBAC has_permission; RLS; princípio do menor privilégio | Mitigar: revisão periódica de papéis; testes de permissão; segregação de funções (SoD) | CISO / CTO | 60 dias |
| SEG-05 | Falsificação/replay de webhooks de pagamento (pedido forjado, injeção de dados) | SEG | 3 | 4 | 12 | Alto | Endpoints de ingestão autenticados | Mitigar: verificar assinatura HMAC/segredo do gateway; idempotência; allowlist de IP; validação de esquema | CTO / CISO | 30 dias |
| SEG-06 | Ataque de negação de serviço (DDoS) ou abuso de rate no portal público e endpoints de ingestão | SEG | 3 | 3 | 9 | Médio | Hospedagem Netlify (CDN/edge) | Mitigar: WAF/rate limiting; proteção de bot; caching; circuit breaker | CISO / DevOps | 90 dias |
| SEG-07 | Ausência de criptografia adequada de dados sensíveis em repouso (PII, dados bancários/PIX) | SEG | 3 | 5 | 15 | Crítico | TLS em trânsito; storage gerenciado Supabase | Mitigar: cifragem em nível de coluna para dados bancários/PIX; gestão de chaves; tokenização quando viável | CISO / CTO | 60 dias |
| SEG-08 | Gestão deficiente de vulnerabilidades e patches (dependências desatualizadas) | SEG | 3 | 3 | 9 | Médio | Controle de dependências | Mitigar: SLA de correção por severidade; varredura contínua; inventário de componentes (SBOM) | DevOps / CISO | 90 dias |
| SEG-09 | Log/monitoramento insuficiente para detecção de intrusão e resposta | SEG | 3 | 4 | 12 | Alto | Trilha de auditoria por triggers | Mitigar: SIEM/centralização de logs; alertas de segurança; correlação; retenção protegida | CISO | 90 dias |
| SEG-10 | Acesso indevido de colaborador/insider a dados de produção | SEG | 2 | 4 | 8 | Médio | RBAC; auditoria; segregação de ambientes | Mitigar: acesso just-in-time; mascaramento em não produção; revisão de acessos; termo de sigilo | CISO / RH | 90 dias |
| SEG-11 | Exposição de bucket/Storage mal configurado (documentos fiscais, anexos) | SEG | 2 | 4 | 8 | Médio | Storage por domínio; RLS/policies | Mitigar: revisar políticas de bucket; URLs assinadas de curta duração; negar leitura anônima | CTO / CISO | 60 dias |
| SEG-12 | Falha no ciclo de resposta a incidentes (ausência de plano testado, papéis indefinidos) | SEG | 2 | 4 | 8 | Médio | Plano de resposta minutado | Mitigar: exercícios de mesa (tabletop) semestrais; runbook; equipe de resposta designada | CISO | 90 dias |

---

## 12. Matriz de Riscos Operacionais e de Continuidade de Negócio

| Cód. | Risco | Cat. | P | I | N | Classe | Controles existentes | Tratamento (estratégia + ação) | Responsável | Prazo |
|---|---|---|---|---|---|---|---|---|---|
| OPS-01 | Indisponibilidade da plataforma (queda de Supabase, Netlify ou da própria aplicação) impedindo processamento de pedidos e rastreio | OPS | 3 | 4 | 12 | Alto | Infraestrutura gerenciada; SSR/CDN | Mitigar: monitoramento de disponibilidade; SLA com provedores; página de status; degradação graciosa | DevOps / CTO | 60 dias |
| OPS-02 | Perda de dados por falha de backup/restauração não testada | OPS | 2 | 5 | 10 | Alto | Política de Backup; backups gerenciados Supabase | Mitigar: testes periódicos de restauração; RPO/RTO definidos; backup imutável off-site | DevOps / CTO | 60 dias |
| OPS-03 | Falha na sincronização de estoque/pedidos entre integrações causando overselling ou pedido órfão | OPS | 3 | 3 | 9 | Médio | Ingestão idempotente; reconciliação | Mitigar: filas com retry/dead-letter; conciliação periódica; alertas de divergência | CTO / Produto | 90 dias |
| OPS-04 | Erro em geração de pré-postagem (PPN) ou etiqueta dos Correios gerando extravio/atraso | OPS | 3 | 3 | 9 | Médio | Integração SRO/PPN; validação de endereço | Mitigar: validação de CEP/endereço; fallback manual; monitorar taxa de erro | Operações Logísticas | 90 dias |
| OPS-05 | Falha de notificação ao comprador (e-mail/WhatsApp indisponível) prejudicando experiência e gerando reclamações | OPS | 3 | 2 | 6 | Médio | Provedores de e-mail/WhatsApp | Mitigar: provedor alternativo; fila de reenvio; status consultável no portal | Produto / Operações | 90 dias |
| OPS-06 | Dependência de pessoa-chave (conhecimento concentrado em poucos desenvolvedores) | OPS | 3 | 3 | 9 | Médio | Documentação parcial; versionamento | Mitigar: documentar runbooks; matriz de sucessão; revisão por pares | CTO / RH | 90 dias |
| OPS-07 | Ausência de Plano de Continuidade de Negócio (BCP/DRP) formal e testado (ISO 22301) | OPS | 3 | 4 | 12 | Alto | Backups; infraestrutura redundante do provedor | Mitigar: elaborar e testar BCP/DRP; definir BIA, RTO/RPO; plano de comunicação de crise | CTO / Diretoria | 120 dias |
| OPS-08 | Erros de configuração em deploy (mudança sem revisão) causando incidente em produção | OPS | 3 | 3 | 9 | Médio | Versionamento; ambientes segregados | Mitigar: CI/CD com aprovação; rollback automatizado; feature flags; janela de mudança | DevOps | 60 dias |
| OPS-09 | Sobrecarga em picos de vendas (datas promocionais) degradando desempenho | OPS | 3 | 3 | 9 | Médio | Escalonamento gerenciado | Mitigar: testes de carga; auto-scaling; caching; plano de capacidade | DevOps / CTO | 90 dias |
| OPS-10 | Migrations de banco com efeito destrutivo ou sem rollback (fonte da verdade do schema) | OPS | 2 | 4 | 8 | Médio | Migrations versionadas; revisão | Mitigar: revisão obrigatória de migration; backup pré-migration; ambiente de homologação | CTO / DevOps | 60 dias |

---

## 13. Matriz de Riscos de Terceiros e Sub-operadores

| Cód. | Risco | Cat. | P | I | N | Classe | Controles existentes | Tratamento (estratégia + ação) | Responsável | Prazo |
|---|---|---|---|---|---|---|---|---|---|
| TER-01 | Incidente de segurança/vazamento originado em sub-operador (Supabase, Netlify, VHSYS, gateways) atingindo dados do GLOP | TER | 2 | 5 | 10 | Alto | Contratos; provedores maduros | Mitigar/Transferir: due diligence de segurança; cláusulas de notificação de incidente; direito de auditoria; seguro cyber | DPO / CISO / Jurídico | 90 dias |
| TER-02 | Ausência de cláusula de operador (art. 39 LGPD) ou de SLA/segurança nos contratos com sub-operadores | TER | 2 | 4 | 8 | Médio | DPA; contratos de integração | Mitigar: padronizar adendo de proteção de dados; exigir subcontratação controlada | Jurídico / DPO | 90 dias |
| TER-03 | Descontinuação, mudança de termos ou lock-in de provedor crítico (ex.: gateway ou VHSYS) | TER | 2 | 4 | 8 | Médio | Arquitetura modular por adaptadores | Mitigar: estratégia multi-fornecedor; abstração de integrações; plano de saída/portabilidade | CTO / Diretoria | 120 dias |
| TER-04 | Falha/instabilidade de gateway de pagamento (Monetizze/AppMax/Hotmart/Kiwify) interrompendo ingestão e split | TER | 3 | 3 | 9 | Médio | Múltiplos gateways; ingestão idempotente | Mitigar: fila resiliente; reprocessamento; monitorar status; contrato de nível de serviço | CTO / Financeiro | 90 dias |
| TER-05 | Falha dos Correios (SRO/PPN) ou greve afetando rastreio e expedição | TER | 3 | 3 | 9 | Médio | Integração de rastreio | Mitigar: transportadora alternativa; comunicação proativa ao cliente; SLA operacional | Operações Logísticas | 90 dias |
| TER-06 | Repasse de conformidade insuficiente: sub-operador não atende exigências regulatórias transferíveis | TER | 2 | 3 | 6 | Médio | Contratos | Mitigar: cláusulas de conformidade e cooperação; questionário anual de risco de fornecedor | Compliance / Jurídico | 120 dias |
| TER-07 | Concentração de PII de compradores em infraestrutura de terceiro sem visibilidade total de controles | TER | 3 | 4 | 12 | Alto | Provedores certificados; RLS na aplicação | Mitigar: obter relatórios de certificação (ISO 27001/SOC 2); revisar responsabilidade compartilhada | CISO / DPO | 90 dias |

---

## 14. Matriz de Riscos de Consumidor, Marketplace e Financeiros

| Cód. | Risco | Cat. | P | I | N | Classe | Controles existentes | Tratamento (estratégia + ação) | Responsável | Prazo |
|---|---|---|---|---|---|---|---|---|---|
| CMF-01 | Vazamento/uso indevido de dados bancários e chaves PIX de coprodutores e afiliados no módulo de split | CMF | 2 | 5 | 10 | Alto | RLS/RBAC; auditoria; split via gateway (AppMax) | Mitigar: cifrar/tokenizar dados bancários; minimizar armazenamento; delegar liquidação ao gateway; acesso restrito | CISO / Financeiro / DPO | 60 dias |
| CMF-02 | Erro na apuração/repasse de comissões e split gerando prejuízo e litígio com coprodutores/afiliados | CMF | 3 | 3 | 9 | Médio | Regras de comissão; trilha de auditoria | Mitigar: conciliação automática; extrato auditável; contestação; contrato de coprodução claro | Financeiro / Produto | 90 dias |
| CMF-03 | Reclamações e ações de consumidores por atraso/extravio de entrega (CDC) | CMF | 3 | 3 | 9 | Médio | Rastreio SRO; notificações | Mitigar: SLA de entrega; canal de atendimento; política de reembolso; registro de tratativas | Operações / Jurídico | 90 dias |
| CMF-04 | Uso da plataforma para fraude/lavagem por produtor mal-intencionado (produtos ilícitos, estelionato) | CMF | 2 | 4 | 8 | Médio | Termos de Uso; KYC do gateway | Mitigar: due diligence de onboarding; monitoramento de padrões; suspensão; comunicação a autoridades (PLD/FT) | Compliance / Jurídico | 120 dias |
| CMF-05 | Chargeback/estorno em massa e reflexo no split já repassado | CMF | 3 | 3 | 9 | Médio | Conciliação com gateway | Mitigar: reserva/retenção; regras de repasse condicionadas à liquidação; contrato prevendo estorno | Financeiro | 90 dias |
| CMF-06 | Inconsistência fiscal na NF-e (dados divergentes do pedido) gerando problema ao consumidor e ao produtor | CMF | 2 | 3 | 6 | Médio | Emissão via VHSYS; validação | Mitigar: validar dados antes da emissão; conciliação pedido x NF-e; correção tempestiva | Fiscal / Produto | 90 dias |
| CMF-07 | Violação de direito de arrependimento (art. 49 CDC) em compras a distância não operacionalizada | CMF | 2 | 3 | 6 | Médio | Termos; fluxo de cancelamento | Mitigar: fluxo de arrependimento em 7 dias; logística reversa; registro | Produto / Jurídico | 90 dias |

---

## 15. Riscos Específicos e Críticos do GLOP (Aprofundamento)

### 15.1. Vazamento de PII na ingestão de pedidos (LGPD-01, SEG-05)

15.1.1. **Cenário:** os fluxos de ingestão recebem, por API e webhooks de gateways/e-commerces, pacotes de dados contendo nome, CPF/CNPJ, e-mail, telefone e endereço completo do comprador. A superfície de ataque inclui endpoints públicos de webhook, credenciais de integração e o transporte dos dados até o banco.

15.1.2. **Fatores de risco:** webhook sem verificação de assinatura; segredos expostos; payload com mais dados do que o necessário; PII trafegando para logs.

15.1.3. **Controles existentes:** RLS multi-tenant por company_id; RBAC (has_permission); credenciais de API write-only; TLS em trânsito; trilha de auditoria por triggers; colunas de auditoria em todo registro; soft-delete.

15.1.4. **Tratamento prioritário:** verificação de assinatura/segredo dos webhooks e idempotência; cifragem de PII em repouso; minimização de dados; mascaramento de PII em logs e telemetria; segregação e rotação de segredos; alertas de acesso anômalo; **classificação Crítico (N=15) — tratamento imediato.**

### 15.2. Portal público de rastreio (LGPD-12, SEG-06)

15.2.1. **Cenário:** o portal de rastreio é acessível sem autenticação e exibe apenas status neutro. Ainda assim, há risco de enumeração de identificadores, correlação e scraping, além do risco de, por erro de implementação, expor PII.

15.2.2. **Controles existentes:** exposição limitada a status neutro; ausência de dados pessoais na tela pública; sem login.

15.2.3. **Tratamento:** identificadores opacos e não sequenciais (evitar enumeração); rate limiting e proteção anti-bot; jamais retornar PII no payload (inclusive em respostas de API subjacentes); auditoria periódica do que é efetivamente servido; cabeçalhos de segurança. **Classificação Alto (N=12).**

### 15.3. Dados bancários de coprodutores e split (CMF-01, SEG-07)

15.3.1. **Cenário:** o módulo de coprodução/afiliação apura comissões e realiza repasses; envolve dados bancários e chaves PIX. A liquidação financeira do split ocorre via gateway (AppMax), mas o GLOP pode reter identificadores financeiros para conciliação.

15.3.2. **Controles existentes:** RLS/RBAC; trilha de auditoria; delegação da liquidação ao gateway.

15.3.3. **Tratamento:** minimizar o armazenamento de dados bancários; tokenização/cifragem em nível de coluna; acesso estritamente restrito e auditado; preferir manter a custódia do dado sensível no gateway; extrato auditável e contrato de coprodução com regras claras de repasse. **Classificação Alto (N=10).**

### 15.4. Dependência de sub-operadores (TER-01, TER-07)

15.4.1. **Cenário:** a operação depende de Supabase e Netlify (infra), VHSYS (NF-e), Correios (transporte), gateways (Monetizze/AppMax/Hotmart/Kiwify) e provedores de e-mail/WhatsApp. Um incidente, indisponibilidade ou descontinuação em qualquer um deles pode paralisar a operação ou vazar dados.

15.4.2. **Tratamento:** modelo de responsabilidade compartilhada documentado; due diligence e questionários de segurança/privacidade; cláusulas de operador (art. 39), notificação de incidente e direito de auditoria; estratégia multi-fornecedor e plano de saída; obtenção de certificações (ISO 27001/SOC 2) dos provedores. **Classificação Alto (N=10 a 12).**

### 15.5. Indisponibilidade e continuidade (OPS-01, OPS-02, OPS-07)

15.5.1. **Cenário:** a indisponibilidade do SaaS impede ingestão de pedidos, geração de pré-postagem e rastreio; a perda de dados sem backup testado é potencialmente catastrófica.

15.5.2. **Tratamento:** monitoramento de disponibilidade e página de status; SLA com provedores; RPO/RTO definidos; testes de restauração de backup; elaboração e teste de BCP/DRP (ISO 22301) com análise de impacto no negócio (BIA). **Classificação Alto (N=10 a 12).**

---

## 16. Mapa de Calor (Heat Map) e Priorização

16.1. Distribuição dos riscos por faixa (risco residual):

- **Críticos (N 15-25):** LGPD-01, SEG-02, SEG-07.
- **Altos (N 10-14):** JUR-01, JUR-02, JUR-06, JUR-09, LGPD-02, LGPD-03, LGPD-11, LGPD-12, SEG-01, SEG-03, SEG-04, SEG-05, SEG-09, OPS-01, OPS-02, OPS-07, TER-01, TER-07, CMF-01.
- **Médios (N 5-9):** JUR-03, JUR-04, JUR-05, JUR-07, JUR-08, JUR-10, LGPD-04 a LGPD-10, SEG-06, SEG-08, SEG-10, SEG-11, SEG-12, OPS-03 a OPS-06, OPS-08 a OPS-10, TER-02 a TER-06, CMF-02 a CMF-07.
- **Baixos (N 1-4):** nenhum risco relevante mantido nesta faixa após avaliação; itens de rotina são geridos pelos controles operacionais correntes.

16.2. **Ordem de priorização de tratamento:** (1) Críticos — imediato; (2) Altos ligados a PII/dados sensíveis e continuidade; (3) demais Altos; (4) Médios conforme plano.

16.3. Representação matricial (Impacto nas linhas, Probabilidade nas colunas). Cada célula indica a classificação resultante:

| Impacto \ Prob. | 1 Rara | 2 Improvável | 3 Possível | 4 Provável | 5 Quase certa |
|---|---|---|---|---|---|
| 5 Catastrófico | Médio | Alto | Crítico | Crítico | Crítico |
| 4 Maior | Baixo | Médio | Alto | Alto | Crítico |
| 3 Moderado | Baixo | Médio | Médio | Alto | Alto |
| 2 Menor | Baixo | Baixo | Médio | Médio | Alto |
| 1 Insignificante | Baixo | Baixo | Baixo | Baixo | Médio |

---

## 17. Estratégias de Tratamento e Planos de Ação

17.1. **Mitigar (reduzir):** estratégia predominante — aplicação de controles técnicos, administrativos e jurídicos que reduzam P e/ou I (ex.: cifragem, MFA, verificação de webhook, testes de RLS, BCP).

17.2. **Transferir (compartilhar):** contratação de seguro de responsabilidade civil e cibernética; cláusulas de responsabilidade, regresso e indenização no DPA e contratos com sub-operadores; delegação de custódia de dados financeiros ao gateway.

17.3. **Evitar (eliminar):** não coletar dados desnecessários (minimização); não expor PII no portal público; não armazenar dado bancário quando a liquidação puder ser integralmente delegada.

17.4. **Aceitar (reter):** apenas para riscos Baixo/Médio dentro do apetite, com registro formal da decisão, responsável e monitoramento. Riscos Alto/Crítico não podem ser aceitos sem plano de redução.

17.5. Cada risco Alto e Crítico deverá ter **plano de ação formal** contendo: ação, responsável (owner), recursos, marco/prazo, indicador de conclusão e risco residual esperado após tratamento.

---

## 18. Monitoramento, Indicadores (KRIs) e Reavaliação

18.1. Indicadores-chave de risco (exemplos):

- número de tentativas de acesso não autorizado e de logins anômalos;
- taxa de webhooks rejeitados por falha de assinatura;
- número de incidentes de segurança/privacidade e tempo médio de detecção e resposta (MTTD/MTTR);
- percentual de segredos rotacionados dentro do prazo;
- cobertura de testes automatizados de RLS por tenant;
- disponibilidade mensal (uptime) e aderência a RPO/RTO em testes de restauração;
- número de requisições de titulares atendidas no prazo;
- vulnerabilidades abertas por severidade e aderência ao SLA de correção;
- percentual de sub-operadores com adendo de proteção de dados e certificação vigente.

18.2. **Reavaliação:** a Matriz é revista, no mínimo, **semestralmente** e, extraordinariamente, sempre que: houver incidente relevante; entrar em operação novo fluxo/integração; ocorrer mudança legislativa ou orientação da ANPD; ou houver alteração material de sub-operador.

18.3. Os resultados de monitoramento e reavaliação são reportados ao Comitê de Riscos e à alta direção, com registro em ata.

---

## 19. Comunicação, Escalonamento e Gestão de Incidentes

19.1. Riscos **Críticos** e incidentes com potencial de dano a titulares são escalonados **imediatamente** ao DPO, ao CISO e à alta direção, acionando o Plano de Resposta a Incidentes.

19.2. Em caso de incidente de segurança com risco/dano relevante a titulares, observa-se o dever de comunicação à ANPD e aos titulares em prazo razoável (art. 48 da LGPD e Resolução CD/ANPD nº 15/2024), com registro de todo o tratamento do incidente.

19.3. O fluxo de escalonamento, os canais e os prazos internos são detalhados no Plano de Resposta a Incidentes e na Política de Segurança da Informação, aos quais esta Matriz se remete.

---

## 20. Papéis e Responsabilidades

- **Alta Direção / Diretoria:** aprova o apetite a risco, provê recursos, decide sobre riscos Críticos, presta contas.
- **Comitê de Gestão de Riscos:** conduz o processo, consolida a Matriz, prioriza e monitora tratamentos.
- **Encarregado / DPO (a ser designado pela administração):** responde por riscos de proteção de dados, RIPD/ROPA, direitos de titulares e interlocução com a ANPD.
- **CISO / Segurança da Informação:** responde por riscos e controles de segurança, resposta a incidentes e KRIs técnicos.
- **CTO / Engenharia:** implementa controles técnicos (RLS, cifragem, verificação de webhook, testes), gestão de mudanças e continuidade.
- **DevOps / SRE:** disponibilidade, backup/restauração, segredos, deploy seguro.
- **Jurídico:** riscos contratuais, regulatórios, consumidor e propriedade intelectual.
- **Compliance:** integridade, PLD/FT, due diligence de terceiros, canal de denúncias.
- **Financeiro / Fiscal:** riscos de split, repasses, chargeback e NF-e.
- **Operações Logísticas:** riscos de expedição, rastreio e transportadoras.
- **Todos os colaboradores e terceiros:** identificam e reportam riscos e eventos, observando as políticas aplicáveis.

---

## 21. Engenharia Jurídica & Governança

### 21.1. Fundamentação das cláusulas (lei/norma que embasa)

- **Metodologia e escalas (seções 5 e 6):** ISO 31000, ISO Guia 73 e NIST SP 800-30 — processo de gestão de risco, terminologia e avaliação P×I.
- **Riscos e controles de proteção de dados (seção 10):** LGPD, arts. 6º (princípios da finalidade, necessidade, segurança e prevenção), 37 (ROPA), 38 (RIPD), 39 (suboperador), 42 a 45 (responsabilidade), 46 a 49 (segurança, boas práticas e comunicação de incidente); Resoluções CD/ANPD nº 4/2023 (dosimetria) e nº 15/2024 (incidentes).
- **Guarda de registros e responsabilidade de provedor (JUR-03):** Marco Civil da Internet (Lei nº 12.965/2014), arts. 10 a 15.
- **Responsabilidade civil pela atividade de risco (JUR-02):** Código Civil, arts. 927, parágrafo único, e 186/187.
- **Riscos de consumidor (seção 14):** CDC (Lei nº 8.078/1990), arts. 6º, 14 (fato do serviço), 49 (arrependimento); Decreto nº 7.962/2013 (e-commerce).
- **Riscos de terceiros/sub-operadores (seção 13):** LGPD art. 39; ISO/IEC 27001/27002 (gestão de fornecedores); modelo de responsabilidade compartilhada.
- **Riscos de segurança (seção 11):** ISO/IEC 27001/27002, ISO/IEC 27701, OWASP Top 10/ASVS, NIST CSF.
- **Continuidade (seção 12):** ISO 22301 (BCM), com BIA, RTO e RPO.
- **Fraude/PLD (CMF-04):** Lei nº 9.613/1998; Lei nº 12.846/2013 e Decreto nº 11.129/2022.

### 21.2. Riscos mitigados por este documento

- Alegação de ausência de governança de riscos e de accountability perante a ANPD e o Judiciário.
- Tratamento reativo e não priorizado de vulnerabilidades e incidentes.
- Falta de rastreabilidade das decisões de aceitação/tratamento de risco.
- Exposição a responsabilização por não demonstrar diligência (defesa e mitigação de sanção).
- Descoordenação entre áreas (jurídico, privacidade, segurança, operações) na resposta a eventos.

### 21.3. Checklist de implementação

1. Aprovar a Matriz pela alta direção e registrar o apetite a risco.
2. Concluir o tratamento imediato dos riscos Críticos (LGPD-01, SEG-02, SEG-07).
3. Implantar verificação de assinatura de webhooks e idempotência na ingestão.
4. Cifrar/tokenizar PII e dados bancários/PIX em repouso; mascarar PII em logs.
5. Exigir MFA para papéis privilegiados e revisar RBAC/RLS por tenant com testes automatizados.
6. Implantar cofre de segredos e rotação; remover segredos de repositórios.
7. Concluir RIPD dos fluxos de alto risco e atualizar o ROPA.
8. Firmar adendo de proteção de dados (art. 39) e questionário de risco com todos os sub-operadores.
9. Elaborar e testar o BCP/DRP; testar restauração de backups (RPO/RTO).
10. Definir KRIs, dashboards e cadência de reavaliação semestral.
11. Contratar/avaliar seguro de responsabilidade civil e cibernética.
12. Integrar a Matriz ao Plano de Resposta a Incidentes e às políticas correlatas.

### 21.4. Matriz RACI (Responsável, Aprovador, Consultado, Informado)

| Atividade | Diretoria | Comitê de Riscos | DPO | CISO | CTO/DevOps | Jurídico/Compliance |
|---|---|---|---|---|---|---|
| Definir apetite a risco | A | R | C | C | I | C |
| Manter e consolidar a Matriz | I | R | C | C | C | C |
| Tratar riscos de dados (LGPD) | I | C | R/A | C | C | C |
| Tratar riscos de segurança | I | C | C | R/A | R | I |
| Tratar riscos operacionais/continuidade | A | C | I | C | R | I |
| Tratar riscos jurídicos/contratuais | I | C | C | I | I | R/A |
| Gestão de sub-operadores | I | C | C | C | C | R/A |
| Reavaliação periódica | A | R | C | C | C | C |
| Resposta a incidentes | A | I | R | R | C | C |

(R = Responsável pela execução; A = Aprova/presta contas; C = Consultado; I = Informado.)

### 21.5. Plano de revisão

- **Revisão ordinária:** semestral, conduzida pelo Comitê de Riscos.
- **Revisão extraordinária:** em até 15 dias após incidente relevante, novo fluxo/integração, mudança legislativa/regulatória (ANPD) ou troca material de sub-operador.
- **Registro:** toda revisão gera nova versão, com ata e histórico de alterações.
- **Validação jurídica:** revisão por advogado(a) habilitado(a) antes da publicação de nova versão.

### 21.6. Controle de versão

| Versão | Data | Autor/Responsável | Descrição da alteração | Aprovação |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | Comitê de Riscos / DPO (a ser designado pela administração) | Emissão inicial da Matriz de Riscos do GLOP | [ÓRGÃO/PESSOA APROVADORA] |
| [VERSÃO] | 16 de julho de 2026 | [PARTE] | [Descrição] | [APROVAÇÃO] |

---

> Documento de uso interno e confidencial. Esta Matriz não substitui parecer jurídico ou técnico específico. Recomenda-se leitura conjunta com a Política de Privacidade, o DPA, a Política de Segurança da Informação, o ROPA/RIPD, a Política de Backup, a Política de Retenção e Descarte, a Política de Compliance e o Plano de Resposta a Incidentes.
