> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# ACORDO DE NÍVEL DE SERVIÇO (SLA)
## Plataforma GLOP — Global Logistics Platform

**Documento:** Acordo de Nível de Serviço (Service Level Agreement — SLA)
**Anexo a:** Contrato de Prestação de Serviços de SaaS / Termos de Uso da Plataforma GLOP
**Versão:** 1.0
**Vigência a partir de:** 16 de julho de 2026
**Classificação:** Documento Contratual — Público (para CONTRATANTES ativos)
**Responsável pelo documento:** a ser designado pela administração / Encarregado(a) de Dados (DPO) — lemoncapsencapsulados@gmail.com

---

## Sumário

1. Preâmbulo e Qualificação das Partes
2. Objeto e Finalidade do SLA
3. Definições e Glossário Técnico
4. Escopo dos Serviços Cobertos
5. Indicadores de Nível de Serviço (SLIs) e Metas (SLOs)
6. Disponibilidade Mensal (Uptime)
7. Classificação de Severidade de Incidentes
8. Tempos de Resposta e Resolução por Severidade
9. Suporte, Canais e Horários de Atendimento
10. Janela de Manutenção Programada e Emergencial
11. Exclusões do SLA
12. Dependência de Sub-Operadores e Serviços de Terceiros
13. Medição, Monitoramento e Relatórios
14. Créditos de Serviço, Penalidades e Compensações
15. Procedimento de Solicitação de Créditos
16. Continuidade de Negócios, Backup e Recuperação de Desastres
17. Segurança da Informação e Proteção de Dados no Contexto do SLA
18. Comunicação de Incidentes e Transparência
19. Limitação de Responsabilidade
20. Vigência, Revisão e Reajuste de Metas
21. Rescisão por Descumprimento Reiterado
22. Disposições Gerais e Foro
23. Engenharia Jurídica & Governança

---

## 1. Preâmbulo e Qualificação das Partes

**1.1.** O presente Acordo de Nível de Serviço (doravante "SLA") é parte integrante e indissociável do Contrato de Prestação de Serviços de Software como Serviço (SaaS) e/ou dos Termos de Uso celebrados entre as partes abaixo qualificadas, aos quais se vincula, complementa e regula quanto aos níveis de qualidade, disponibilidade e desempenho dos serviços da plataforma GLOP.

**1.2. CONTRATADA / PROVEDORA:**
LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, sociedade empresária inscrita no CNPJ sob o nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, operadora do sistema [NOME FANTASIA: GLOP] — Global Logistics Platform, doravante denominada "GLOP", "PROVEDORA" ou "CONTRATADA".

**1.3. CONTRATANTE / CLIENTE:**
[CONTRATANTE], pessoa física ou jurídica devidamente qualificada no Contrato principal e/ou no cadastro da plataforma, doravante denominada "CONTRATANTE", "CLIENTE" ou "[PARTE]".

**1.4.** As partes acima são, em conjunto, denominadas "Partes" e, individualmente, "Parte".

**1.5.** Este SLA prevalece sobre disposições genéricas do Contrato principal exclusivamente quanto à matéria aqui tratada (níveis de serviço, disponibilidade, suporte, créditos e penalidades). Em caso de conflito sobre outras matérias, prevalece o Contrato principal.

**1.6.** A aceitação eletrônica dos Termos de Uso, a assinatura do Contrato principal, o pagamento da primeira fatura ou o uso continuado da plataforma implicam adesão integral às condições deste SLA.

---

## 2. Objeto e Finalidade do SLA

**2.1.** O objeto deste SLA é estabelecer, de forma objetiva, mensurável e verificável, os níveis mínimos de qualidade dos serviços prestados pela GLOP — Global Logistics Platform, plataforma SaaS de logística e ERP (WMS/TMS/YMS/gestão de pedidos, expedição e rastreio) voltada a operações de dropshipping e infoprodutos no Brasil.

**2.2.** O SLA disciplina, em especial:

- a) os Indicadores de Nível de Serviço (SLIs) e as respectivas Metas (SLOs);
- b) a disponibilidade mensal garantida (uptime);
- c) a classificação de severidade de incidentes e os prazos de resposta e resolução;
- d) as janelas de manutenção programada e emergencial;
- e) as exclusões e hipóteses de suspensão da apuração;
- f) os mecanismos de medição, monitoramento e emissão de relatórios;
- g) os créditos de serviço, penalidades e compensações por descumprimento;
- h) os canais, horários e níveis de suporte técnico;
- i) o procedimento de revisão e reajuste das metas.

**2.3.** A finalidade é assegurar previsibilidade operacional às operações logísticas do CONTRATANTE, cuja atividade depende da continuidade dos fluxos críticos da plataforma, tais como: ingestão de pedidos via API e e-commerce, geração de pré-postagem nos Correios (PPN), rastreamento (SRO), emissão de NF-e via VHSYS, apuração de comissões e split de pagamentos, e notificação ao comprador.

---

## 3. Definições e Glossário Técnico

Para os fins deste SLA, os termos abaixo têm os seguintes significados, aplicando-se subsidiariamente as definições da Lei nº 13.709/2018 (LGPD), do Contrato principal e do Data Processing Agreement (DPA).

**3.1. Plataforma / Serviço:** o sistema GLOP acessível via navegador (aplicação Next.js hospedada em SSR na Netlify), incluindo o backend de dados e autenticação (Supabase — PostgreSQL, Auth, Storage, Realtime, Edge Functions), APIs, painéis, portais e integrações descritas na cláusula 4.

**3.2. Disponibilidade (Uptime):** percentual de tempo, em um Mês de Apuração, no qual a Plataforma está acessível e operacional em seus Serviços Cobertos, conforme fórmula da cláusula 6.

**3.3. Indisponibilidade (Downtime):** período no qual um Serviço Coberto está inoperante por causa atribuível à GLOP, impedindo o uso de funcionalidade essencial, e não enquadrado nas Exclusões (cláusula 11).

**3.4. Mês de Apuração:** período de referência para cálculo dos indicadores, correspondente ao mês-calendário (do primeiro ao último dia, horário de Brasília — UTC-3).

**3.5. SLI (Service Level Indicator):** métrica quantitativa que mede um aspecto do serviço (ex.: disponibilidade, latência, taxa de erro).

**3.6. SLO (Service Level Objective):** meta-alvo estabelecida para cada SLI, cujo descumprimento aciona os créditos e penalidades deste SLA.

**3.7. Incidente:** evento não planejado que causa interrupção ou degradação de um Serviço Coberto.

**3.8. Severidade:** grau de impacto de um Incidente, classificado de S1 (Crítico) a S4 (Baixo), conforme cláusula 7.

**3.9. Tempo de Resposta:** intervalo entre a abertura/registro válido do chamado (ou detecção automática pela GLOP) e a primeira interação humana qualificada da equipe de suporte confirmando ciência e início de tratativa.

**3.10. Tempo de Resolução (ou Restabelecimento):** intervalo entre a abertura/detecção do Incidente e o restabelecimento do serviço (solução definitiva ou contorno — workaround — que remova o impacto crítico).

**3.11. Janela de Manutenção:** período previamente comunicado, ou emergencial, destinado a atualizações, correções e melhorias, durante o qual poderá haver indisponibilidade programada, não computada como Downtime.

**3.12. Crédito de Serviço:** compensação financeira, expressa em percentual da mensalidade, concedida ao CONTRATANTE em caso de descumprimento das metas, na forma da cláusula 14.

**3.13. Sub-Operadores / Terceiros:** provedores de infraestrutura e serviços dos quais a Plataforma depende, notadamente: Supabase e Netlify (infraestrutura), VHSYS (emissão de NF-e), Correios (transporte, PPN e SRO), gateways de pagamento (Monetizze, AppMax, Hotmart, Kiwify) e provedores de mensageria (WhatsApp/e-mail).

**3.14. Portal Público de Rastreio:** interface de consulta de status de entrega, sem autenticação, que expõe apenas status neutro, sem PII do comprador.

**3.15. PII (dados pessoais):** informações relativas a pessoa natural identificada ou identificável, nos termos da LGPD — incluindo, no fluxo GLOP, dados do comprador (nome, CPF/CNPJ, e-mail, telefone, endereço completo) e dados de coprodutores/afiliados (PIX/bancários).

**3.16. Dias Úteis:** dias de segunda a sexta-feira, exceto feriados nacionais brasileiros e feriados na sede da CONTRATADA.

**3.17. Horário Comercial:** das 9h00 às 18h00 (horário de Brasília), em Dias Úteis, salvo indicação diversa no plano contratado.

**3.18. Contorno (Workaround):** solução paliativa que restabelece a operação essencial ainda que a causa-raiz permaneça pendente de correção definitiva.

**3.19. Causa-Raiz (Root Cause):** origem técnica fundamental de um Incidente, objeto de análise pós-incidente (RCA — Root Cause Analysis).

---

## 4. Escopo dos Serviços Cobertos

**4.1.** Este SLA aplica-se aos seguintes Serviços Cobertos, considerados críticos ou essenciais à operação logística do CONTRATANTE:

- a) **Acesso à Plataforma (aplicação web):** autenticação (Supabase Auth/JWT), painéis de gestão e navegação principal;
- b) **Ingestão de Pedidos:** recepção e processamento de pedidos via API (Monetizze, Hotmart, Kiwify) e via e-commerce (Shopify, WooCommerce, Nuvemshop, Mercado Livre);
- c) **Módulo de Expedição e Correios:** geração de pré-postagem (PPN) e consulta de rastreio (SRO);
- d) **Emissão de Documentos Fiscais:** integração de NF-e via VHSYS (sujeita às exclusões da cláusula 11 e 12);
- e) **Coprodução, Comissões e Split:** apuração de comissões, repasses e split de pagamentos (AppMax);
- f) **Notificação ao Comprador:** disparo de e-mail e WhatsApp de status de entrega (sujeito à disponibilidade dos provedores de mensageria);
- g) **Portal Público de Rastreio:** consulta de status neutro sem autenticação;
- h) **Persistência e Integridade de Dados:** banco de dados PostgreSQL (Supabase) com RLS multi-tenant, trilha de auditoria e soft-delete.

**4.2. Classificação de criticidade dos serviços cobertos:**

| Serviço Coberto | Criticidade | SLO de Disponibilidade Aplicável |
|---|---|---|
| Acesso/Autenticação à Plataforma | Crítico | Conforme plano (cláusula 6.2) |
| Ingestão de Pedidos (API/e-commerce) | Crítico | Conforme plano (cláusula 6.2) |
| Persistência/Integridade de Dados | Crítico | Conforme plano (cláusula 6.2) |
| Expedição / PPN Correios | Essencial | SLO reduzido — dependência Correios (cláusula 12) |
| Rastreio / SRO Correios | Essencial | SLO reduzido — dependência Correios |
| Emissão de NF-e (VHSYS) | Essencial | SLO reduzido — dependência VHSYS |
| Split de Pagamentos (AppMax) | Essencial | SLO reduzido — dependência gateway |
| Notificação Comprador (WhatsApp/e-mail) | Padrão | Melhor esforço — dependência mensageria |
| Portal Público de Rastreio | Padrão | Melhor esforço |

**4.3.** Os serviços classificados como "melhor esforço" ou de "SLO reduzido" não geram crédito de serviço quando a causa da falha for atribuível exclusivamente ao Sub-Operador ou Terceiro, na forma das cláusulas 11 e 12, mas a GLOP obriga-se a diligenciar ativamente o restabelecimento junto ao terceiro e a comunicar o CONTRATANTE.

---

## 5. Indicadores de Nível de Serviço (SLIs) e Metas (SLOs)

**5.1.** A GLOP monitora e reporta os seguintes SLIs, com os respectivos SLOs-padrão. Metas superiores podem ser contratadas em planos Enterprise (cláusula 6.2).

| Cód. | Indicador (SLI) | Definição da Medição | Meta (SLO) padrão |
|---|---|---|---|
| SLI-01 | Disponibilidade mensal da Plataforma | % de tempo operacional no Mês de Apuração (cláusula 6) | ≥ 99,5% |
| SLI-02 | Disponibilidade da Ingestão de Pedidos | % de janelas de coleta/recepção processadas com sucesso | ≥ 99,5% |
| SLI-03 | Latência de resposta da aplicação (p95) | Tempo de resposta do servidor (SSR/API) no percentil 95 | ≤ 1.500 ms |
| SLI-04 | Taxa de erro de requisições (error rate) | % de respostas HTTP 5xx atribuíveis à GLOP sobre o total | ≤ 0,5% |
| SLI-05 | Sucesso de processamento de pedidos | % de pedidos válidos ingeridos e persistidos sem falha da GLOP | ≥ 99,0% |
| SLI-06 | Sucesso de geração de PPN (Correios) | % de solicitações de pré-postagem concluídas (excl. falha Correios) | ≥ 98,0% |
| SLI-07 | Atualização de rastreio (SRO) | % de eventos de rastreio sincronizados dentro da janela definida | ≥ 97,0% |
| SLI-08 | Integridade e durabilidade de dados | Perda de dados confirmados (RPO) | RPO ≤ 24h; meta de perda zero em confirmados |
| SLI-09 | Cumprimento de prazo de resposta ao suporte | % de chamados respondidos dentro do SLA de severidade | ≥ 95% |
| SLI-10 | Disponibilidade do Portal Público de Rastreio | % de tempo operacional (melhor esforço) | ≥ 99,0% |

**5.2.** As medições dos SLIs são realizadas conforme a cláusula 13 (Medição, Monitoramento e Relatórios).

**5.3.** Os SLOs de indicadores dependentes de Sub-Operadores (SLI-06, SLI-07 e correlatos) são apurados líquidos das falhas exclusivamente imputáveis ao terceiro, na forma das cláusulas 11 e 12.

---

## 6. Disponibilidade Mensal (Uptime)

**6.1. Fórmula de cálculo.** A Disponibilidade mensal é apurada pela seguinte fórmula, com arredondamento a duas casas decimais:

Disponibilidade (%) = ((Minutos Totais do Mês − Minutos de Downtime Elegível) ÷ Minutos Totais do Mês) × 100

Onde:
- **Minutos Totais do Mês** = número de dias do mês × 24 × 60;
- **Minutos de Downtime Elegível** = soma dos minutos de Indisponibilidade atribuível à GLOP, excluídos os períodos das cláusulas 10 (manutenção) e 11 (exclusões).

**6.2. Metas de disponibilidade por plano contratado.** A meta aplicável ao CONTRATANTE é definida no plano indicado no Contrato principal ou na proposta comercial:

| Plano | SLO de Disponibilidade mensal | Downtime máximo mensal (referência 30 dias) |
|---|---|---|
| Essencial / Starter | ≥ 99,0% | ≈ 7h18min |
| Profissional / Business | ≥ 99,5% | ≈ 3h39min |
| Enterprise | ≥ 99,9% | ≈ 43min48s |
| Enterprise Plus (sob contrato específico) | ≥ 99,95% | ≈ 21min54s |

**6.3.** Na ausência de indicação expressa de plano, aplica-se o SLO padrão de **99,5%** (SLI-01).

**6.4.** A Indisponibilidade é considerada iniciada no momento da detecção automatizada pelos sistemas de monitoramento da GLOP ou da abertura de chamado válido de severidade S1/S2 pelo CONTRATANTE, o que ocorrer primeiro, e encerrada no restabelecimento do serviço (solução ou contorno).

**6.5.** Indisponibilidades parciais (degradação que afete subconjunto de funcionalidades ou de tenants) poderão ser computadas proporcionalmente, mediante critério técnico documentado no relatório mensal.

---

## 7. Classificação de Severidade de Incidentes

**7.1.** Todo Incidente é classificado, na abertura, em um dos quatro níveis de severidade. A classificação inicial poderá ser reavaliada de comum acordo conforme evolução do impacto real.

| Severidade | Denominação | Descrição do impacto | Exemplos no contexto GLOP |
|---|---|---|---|
| **S1** | Crítico | Plataforma totalmente indisponível ou funcionalidade crítica inoperante, sem contorno, afetando a operação do CONTRATANTE (ou múltiplos tenants). Impacto financeiro/operacional imediato. | Falha total de login/autenticação; banco de dados inacessível; parada completa da ingestão de pedidos; perda ou risco iminente de perda de dados; vazamento de PII em investigação. |
| **S2** | Alto | Funcionalidade essencial severamente degradada ou parcialmente indisponível, com contorno limitado ou inexistente; impacto operacional relevante. | Ingestão de pedidos de um canal específico falhando; falha na geração de PPN Correios em massa; split de pagamento não processando; erros 5xx recorrentes em módulo central. |
| **S3** | Médio | Funcionalidade não essencial degradada, ou funcionalidade essencial com contorno estável disponível; impacto moderado. | Atraso na atualização de rastreio (SRO); lentidão pontual; falha intermitente de notificação por e-mail/WhatsApp; erro em relatório específico. |
| **S4** | Baixo | Impacto mínimo, questão cosmética, dúvida, solicitação de melhoria ou item sem efeito operacional relevante. | Ajuste visual; dúvida de uso; sugestão de funcionalidade; inconsistência estética sem prejuízo funcional. |

**7.2.** Incidentes envolvendo suspeita ou confirmação de incidente de segurança com dados pessoais (LGPD) são tratados com prioridade S1, acionando adicionalmente o Plano de Resposta a Incidentes e as obrigações do DPA e da cláusula 17.

---

## 8. Tempos de Resposta e Resolução por Severidade

**8.1.** Os prazos abaixo contam-se a partir da abertura de chamado válido pelo CONTRATANTE nos canais oficiais (cláusula 9) ou da detecção automatizada pela GLOP, o que ocorrer primeiro.

| Severidade | Tempo de Resposta (alvo) | Tempo de Resolução/Contorno (alvo) | Janela de atendimento | Cadência de atualização ao CONTRATANTE |
|---|---|---|---|---|
| **S1 — Crítico** | ≤ 30 minutos | ≤ 4 horas | 24×7 | A cada 60 minutos |
| **S2 — Alto** | ≤ 1 hora (em Horário Comercial) | ≤ 8 horas úteis | 24×7 para deteção; tratativa priorizada | A cada 4 horas |
| **S3 — Médio** | ≤ 4 horas úteis | ≤ 3 Dias Úteis | Horário Comercial | Diária |
| **S4 — Baixo** | ≤ 1 Dia Útil | ≤ 10 Dias Úteis ou próxima release | Horário Comercial | Conforme necessidade |

**8.2.** Os prazos de resolução para planos Enterprise podem ser reduzidos conforme contrato específico. Os prazos S1 aplicam-se em regime 24×7 independentemente do plano, dada a criticidade.

**8.3.** O "Tempo de Resolução" é considerado cumprido quando restabelecida a operação essencial, ainda que por contorno (workaround), permanecendo a GLOP obrigada a entregar correção definitiva de causa-raiz em prazo razoável e a fornecer RCA (Root Cause Analysis) para incidentes S1 e S2 em até 5 (cinco) Dias Úteis após o restabelecimento.

**8.4.** A GLOP poderá reclassificar a severidade mediante justificativa técnica documentada e comunicação ao CONTRATANTE. Divergências de classificação são resolvidas pela via de escalonamento (cláusula 9.4).

**8.5.** O descumprimento reiterado dos prazos de resposta/resolução (SLI-09) sujeita a GLOP aos créditos da cláusula 14, cumulativamente com os créditos por indisponibilidade quando cabível, observado o teto da cláusula 14.6.

---

## 9. Suporte, Canais e Horários de Atendimento

**9.1. Canais oficiais de suporte.** O registro válido de chamados dá-se exclusivamente pelos canais oficiais, únicos hábeis a marcar o início da contagem dos prazos:

- a) **Portal/central de chamados** (sistema de tickets) — canal primário e de registro formal;
- b) **E-mail de suporte:** lemoncapsencapsulados@gmail.com (ou endereço de suporte indicado no plano);
- c) **Canal prioritário S1** (telefone/WhatsApp/hotline) — disponível conforme plano, exclusivo para severidade crítica;
- d) **Status Page pública** — para acompanhamento de incidentes em curso e manutenções (cláusula 18).

**9.2. Requisitos do chamado válido.** Para início da contagem, o chamado deve conter: identificação do CONTRATANTE/tenant; descrição do problema; funcionalidade afetada; severidade sugerida; horário de início; e evidências (prints, IDs de pedido, mensagens de erro, logs quando disponíveis). Chamados incompletos podem ter a contagem suspensa até complementação.

**9.3. Níveis de suporte.**

- **N1 — Atendimento inicial:** triagem, classificação de severidade, orientação e resolução de questões conhecidas.
- **N2 — Suporte técnico especializado:** análise técnica, reprodução, contorno e correções operacionais.
- **N3 — Engenharia/Desenvolvimento:** correção de causa-raiz, ajustes de código, migrações e coordenação com Sub-Operadores.

**9.4. Escalonamento (matriz de escalada).** Não cumpridos os prazos, ou a critério do CONTRATANTE em incidentes S1/S2, aplica-se escalonamento:

| Nível de escalada | Acionamento | Contato / Papel |
|---|---|---|
| 1º nível | Vencido o Tempo de Resposta | Coordenação de Suporte |
| 2º nível | Vencido 50% do Tempo de Resolução | Gerência Técnica / Líder de Engenharia |
| 3º nível | Vencido o Tempo de Resolução ou incidente de segurança | Diretoria Técnica / Encarregado (DPO) — a ser designado pela administração |

**9.5. Horários.** Suporte S1 em regime 24×7. Suporte S2 a S4 em Horário Comercial, salvo condição diversa contratada. Feriados observam a definição da cláusula 3.16.

**9.6. Idioma.** O atendimento é prestado em português (PT-BR).

---

## 10. Janela de Manutenção Programada e Emergencial

**10.1. Manutenção programada.** A GLOP poderá realizar manutenções planejadas (atualizações de versão, migrações de banco, aplicação de patches de segurança na stack Supabase/Netlify, ajustes de infraestrutura), preferencialmente em janela de baixo tráfego:

- a) **Janela preferencial:** domingos e feriados, entre 00h00 e 06h00 (horário de Brasília), ou outra janela comunicada;
- b) **Aviso prévio mínimo:** 48 (quarenta e oito) horas, via Status Page, e-mail e/ou painel da Plataforma;
- c) **Duração máxima esperada por evento:** 4 (quatro) horas, salvo migrações de maior porte previamente comunicadas com janela estendida.

**10.2.** O tempo de indisponibilidade decorrente de manutenção programada e regularmente comunicada **não** é computado como Downtime para fins de disponibilidade (cláusula 6) nem gera créditos, desde que respeitados o aviso prévio e a janela anunciada.

**10.3. Manutenção emergencial.** Em situações que exijam ação imediata para preservar segurança, integridade de dados ou estabilidade (ex.: correção de vulnerabilidade crítica, mitigação de ataque, falha em Sub-Operador), a GLOP poderá executar manutenção emergencial com aviso no menor prazo possível, ainda que inferior a 48 horas, ou concomitante/posterior quando a urgência assim exigir.

**10.4.** Manutenções emergenciais estritamente necessárias e razoáveis, comunicadas conforme possível, não são computadas como Downtime elegível, salvo se a necessidade decorrer de falha ou negligência imputável exclusivamente à GLOP, hipótese em que serão consideradas para efeito de disponibilidade.

**10.5.** A GLOP envidará esforços para que manutenções não impactem, sempre que possível, os fluxos críticos de ingestão de pedidos e persistência de dados, priorizando estratégias de baixa indisponibilidade (deploys graduais, migrações compatíveis com versão em produção).

---

## 11. Exclusões do SLA

**11.1.** **Não** são computados como Downtime elegível, nem geram créditos ou penalidades, os períodos de indisponibilidade ou degradação decorrentes de:

- a) **Manutenções programadas** regularmente comunicadas (cláusula 10) e emergenciais razoáveis (cláusula 10.4);
- b) **Força maior e caso fortuito** (art. 393 do Código Civil): desastres naturais, pandemias, guerras, greves gerais, atos governamentais, apagões elétricos de larga escala, falhas sistêmicas de backbone de internet;
- c) **Falha de Sub-Operadores ou Terceiros** fora do controle razoável da GLOP, quando a causa for exclusivamente imputável ao terceiro (Supabase, Netlify, VHSYS, Correios, gateways de pagamento, provedores de WhatsApp/e-mail), observada a cláusula 12;
- d) **Ações, omissões ou uso indevido do CONTRATANTE ou de seus usuários**: configuração incorreta, uso fora das especificações, chaves/credenciais de API inválidas ou revogadas, exclusão indevida de dados, violação dos Termos de Uso, uso abusivo de recursos além dos limites do plano;
- e) **Conectividade, equipamentos, rede local ou navegadores do CONTRATANTE**, incluindo bloqueios por firewall, proxy, antivírus ou extensões;
- f) **Suspensão legítima do serviço** por inadimplência, ordem judicial/autoridade competente, ou violação contratual/legal pelo CONTRATANTE;
- g) **Ataques cibernéticos de terceiros** (DDoS, exploração de zero-day não conhecido) que, apesar das medidas razoáveis de segurança adotadas pela GLOP (RLS, RBAC, hardening, monitoramento), tenham causado indisponibilidade — sem prejuízo do dever de mitigação e comunicação;
- h) **Testes, ambientes de homologação/sandbox, versões beta ou funcionalidades experimentais** rotuladas como tais;
- i) **Suspensão ou bloqueio de integrações por decisão do próprio Terceiro** (ex.: revogação de token pelo gateway, banimento de conta em marketplace, alteração unilateral de API por Shopify/WooCommerce/Nuvemshop/Mercado Livre);
- j) **Indisponibilidade decorrente de solicitação expressa do CONTRATANTE** (ex.: pausa a pedido, congelamento de conta, exportação/migração de dados).

**11.2.** O ônus de demonstrar o enquadramento em hipótese de exclusão é da GLOP, que o fará mediante evidências técnicas no relatório mensal ou na resposta à solicitação de crédito.

**11.3.** As exclusões não afastam o dever geral de diligência, mitigação, transparência e comunicação da GLOP, tampouco suas obrigações legais em matéria de proteção de dados.

---

## 12. Dependência de Sub-Operadores e Serviços de Terceiros

**12.1.** O CONTRATANTE reconhece que a Plataforma GLOP opera sobre e integra serviços de terceiros essenciais, cuja disponibilidade condiciona parte dos fluxos:

| Sub-Operador / Terceiro | Função no fluxo GLOP | Impacto de sua indisponibilidade |
|---|---|---|
| **Supabase** | Banco de dados PostgreSQL, Auth (JWT), Storage, Realtime, Edge Functions | Crítico — pode afetar toda a Plataforma |
| **Netlify** | Hospedagem SSR da aplicação Next.js | Crítico — pode afetar acesso à aplicação |
| **VHSYS** | Emissão de NF-e e documentos fiscais | Essencial — afeta emissão fiscal |
| **Correios** | Pré-postagem (PPN) e rastreamento (SRO) | Essencial — afeta expedição e rastreio |
| **Gateways (Monetizze, AppMax, Hotmart, Kiwify)** | Ingestão de pedidos e split de pagamentos | Essencial — afeta pedidos e repasses |
| **Provedores de mensageria (WhatsApp/e-mail)** | Notificação ao comprador | Padrão — afeta notificações |
| **E-commerces (Shopify, WooCommerce, Nuvemshop, Mercado Livre)** | Origem de pedidos | Essencial — afeta ingestão do canal |

**12.2.** A GLOP compromete-se a: (i) contratar Sub-Operadores de infraestrutura reconhecidamente maduros; (ii) monitorar ativamente a saúde das integrações; (iii) implementar, quando tecnicamente viável, mecanismos de resiliência (retentativas com backoff, filas, degradação graciosa, cache de leitura); (iv) diligenciar o restabelecimento junto ao terceiro; e (v) comunicar o CONTRATANTE sobre incidentes de terceiros que o afetem.

**12.3.** A GLOP **não** garante os SLAs próprios dos Sub-Operadores nem se responsabiliza por metas que estes não cumpram, mas responde pela adequada implementação, monitoramento e resiliência das integrações sob seu controle.

**12.4.** Falhas exclusivamente imputáveis a Sub-Operador não geram crédito de serviço, salvo se a GLOP tiver deixado de adotar medidas de resiliência razoáveis e comprovadamente exigíveis, ou de comunicar/mitigar tempestivamente, hipótese em que a indisponibilidade poderá ser considerada elegível.

---

## 13. Medição, Monitoramento e Relatórios

**13.1. Fonte de medição.** Os indicadores são medidos com base nas ferramentas de observabilidade da GLOP e de seus provedores, incluindo: métricas de disponibilidade e latência da camada de aplicação (Netlify/SSR), métricas do banco e Auth (Supabase), logs estruturados, monitoramento sintético (health checks periódicos), trilha de auditoria por triggers no PostgreSQL e telemetria de integrações (PPN/SRO Correios, gateways, VHSYS).

**13.2. Regra de precedência de dados.** Em caso de divergência, prevalecem os registros de monitoramento e logs da GLOP e de seus provedores de infraestrutura, ressalvado ao CONTRATANTE o direito de apresentar evidências próprias (prints com timestamp, IDs, correlação de eventos) que serão analisadas de boa-fé.

**13.3. Relatório mensal de nível de serviço.** A GLOP disponibilizará, mediante solicitação ou automaticamente conforme o plano, relatório mensal contendo, no mínimo:

- a) disponibilidade apurada (SLI-01) e comparação com o SLO;
- b) resumo de incidentes S1/S2 do período (data, duração, severidade, causa-raiz, status);
- c) tempos médios de resposta e resolução por severidade;
- d) períodos de manutenção realizados;
- e) períodos excluídos e respectiva fundamentação (cláusula 11);
- f) créditos aplicáveis, se houver.

**13.4. Status Page.** A GLOP manterá página pública de status com o estado atual dos serviços, histórico de incidentes e manutenções agendadas, para transparência em tempo quase real.

**13.5. Retenção de evidências.** Os dados de monitoramento e logs relevantes para apuração de SLA são retidos por, no mínimo, 12 (doze) meses, observadas as políticas de retenção e a LGPD.

**13.6.** O monitoramento e os relatórios não expõem PII do comprador de forma indevida, observando os princípios de minimização e o Portal Público de Rastreio (status neutro).

---

## 14. Créditos de Serviço, Penalidades e Compensações

**14.1. Natureza.** O crédito de serviço é a compensação exclusiva e pré-fixada pelo descumprimento das metas de disponibilidade e de prazos deste SLA, sem prejuízo das demais obrigações legais e do disposto na cláusula 19 (limitação de responsabilidade) e na cláusula 21 (rescisão por descumprimento reiterado).

**14.2. Créditos por descumprimento da disponibilidade mensal (SLI-01).** Apurada disponibilidade inferior ao SLO do plano, aplica-se crédito percentual sobre a mensalidade do serviço afetado no Mês de Apuração:

| Disponibilidade apurada vs. SLO | Crédito de serviço (% da mensalidade) |
|---|---|
| Igual ou acima do SLO | 0% |
| Abaixo do SLO até 1,0 ponto percentual (p.p.) | 10% |
| Abaixo do SLO entre 1,01 e 2,0 p.p. | 20% |
| Abaixo do SLO entre 2,01 e 4,0 p.p. | 35% |
| Abaixo do SLO acima de 4,0 p.p. | 50% |

**14.3. Créditos por descumprimento de prazos de suporte (S1/S2).** Sem prejuízo do item 14.2, o descumprimento reiterado dos prazos de resposta/resolução de incidentes críticos e altos gera crédito adicional:

| Situação | Crédito adicional (% da mensalidade) |
|---|---|
| Cada incidente S1 com Tempo de Resposta excedido | 5% |
| Cada incidente S1 com Tempo de Resolução excedido | 10% |
| Cada incidente S2 com Tempo de Resolução excedido | 5% |
| Cumprimento de SLI-09 (prazos) abaixo de 90% no mês | 10% |

**14.4. Base de cálculo.** O percentual incide sobre o valor da mensalidade (ou fração mensal de contrato anual) referente ao Serviço Coberto efetivamente afetado, no Mês de Apuração em que ocorreu o descumprimento.

**14.5. Forma de concessão.** O crédito é concedido preferencialmente como abatimento na fatura subsequente. A critério das Partes e conforme o Contrato principal, poderá ser convertido em extensão de vigência equivalente. O crédito não é convertido em dinheiro (não reembolsável em espécie), salvo previsão contratual expressa ou na hipótese de rescisão.

**14.6. Teto de créditos.** O total de créditos de serviço concedidos em um mesmo Mês de Apuração está limitado a **50% (cinquenta por cento)** da mensalidade do respectivo mês, ainda que a soma dos itens 14.2 e 14.3 supere esse valor.

**14.7. Condições para elegibilidade do crédito.** O crédito somente é devido se, cumulativamente: (i) o CONTRATANTE estiver adimplente; (ii) o descumprimento não decorrer de hipótese de exclusão (cláusula 11); (iii) o CONTRATANTE solicitar o crédito no prazo da cláusula 15; e (iv) o incidente estiver registrado nos canais oficiais ou detectado pela GLOP.

**14.8. Exclusividade do remédio.** Os créditos de serviço constituem o remédio único e exclusivo do CONTRATANTE pelo simples descumprimento das metas deste SLA, ressalvadas (i) as hipóteses de rescisão por descumprimento reiterado (cláusula 21); (ii) danos decorrentes de dolo, culpa grave, violação de dados por falha da GLOP, ou descumprimento de deveres legais de proteção de dados; e (iii) o que a legislação imperativa (LGPD, CDC quando aplicável) não permitir afastar.

---

## 15. Procedimento de Solicitação de Créditos

**15.1.** Para pleitear crédito, o CONTRATANTE deve submeter solicitação formal, pelos canais oficiais (cláusula 9), em até **30 (trinta) dias corridos** contados do encerramento do Mês de Apuração em que ocorreu o descumprimento, contendo:

- a) identificação do CONTRATANTE/tenant e do plano;
- b) período e serviço afetado;
- c) referência aos chamados/incidentes relacionados (números de ticket);
- d) evidências disponíveis (timestamps, IDs de pedido, prints, mensagens de erro);
- e) indicador (SLI) que se alega descumprido.

**15.2.** A GLOP analisará a solicitação em até **15 (quinze) Dias Úteis**, confrontando com seus registros de monitoramento (cláusula 13), e responderá deferindo (com indicação do crédito) ou indeferindo de forma fundamentada.

**15.3.** A ausência de solicitação no prazo do item 15.1 implica renúncia ao crédito referente àquele mês, salvo créditos que a GLOP reconheça e aplique de ofício com base em seus próprios registros.

**15.4.** Eventual controvérsia sobre a apuração será submetida ao escalonamento (cláusula 9.4) e, subsidiariamente, à resolução de disputas do Contrato principal.

---

## 16. Continuidade de Negócios, Backup e Recuperação de Desastres

**16.1. Backup.** A GLOP mantém rotina de backup do banco de dados PostgreSQL (Supabase), com cópias regulares, visando objetivo de ponto de recuperação (RPO) de **até 24 horas** para dados confirmados, buscando meta de perda zero para transações efetivadas.

**16.2. Recuperação (RTO).** Em evento de desastre, a GLOP envidará esforços para restabelecer os Serviços Cobertos críticos dentro de objetivo de tempo de recuperação (RTO) compatível com a severidade S1 (contorno/restabelecimento em até 4 horas quando tecnicamente viável; recuperação plena conforme complexidade do evento).

**16.3.** As rotinas de backup, restauração e testes periódicos observam a Política de Backup e a Política de Retenção da GLOP, integrando o presente SLA por remissão.

**16.4.** A integridade e a durabilidade dos dados são reforçadas por soft-delete (proibição de exclusão física indevida), trilha de auditoria por triggers e isolamento por RLS multi-tenant, o que reduz risco de perda e de acesso indevido cross-tenant.

**16.5.** Este SLA não substitui as obrigações específicas de continuidade e segurança previstas no DPA, na Política de Segurança da Informação e no Plano de Continuidade de Negócios (alinhados às boas práticas ISO 22301/27001), que prevalecem quanto às respectivas matérias.

---

## 17. Segurança da Informação e Proteção de Dados no Contexto do SLA

**17.1.** A GLOP atua, no fluxo de dados do comprador, como **OPERADORA** (tratando dados em nome do produtor/lojista CONTROLADOR) e, quanto aos dados de seus próprios usuários/colaboradores, como **CONTROLADORA**, nos termos da LGPD, do DPA e da Política de Privacidade, que este SLA não altera.

**17.2. Incidentes de segurança.** Incidente que envolva dados pessoais é tratado, para fins de prazos deste SLA, com severidade **S1**, acionando adicionalmente: (i) o Plano de Resposta a Incidentes; (ii) as obrigações de comunicação do DPA; e (iii) o dever de comunicação ao titular e à ANPD quando cabível, nos prazos e condições da LGPD (art. 48) e regulamentação da ANPD, sob responsabilidade do CONTROLADOR com o suporte da OPERADORA.

**17.3.** As medidas de segurança de referência da Plataforma — RLS por empresa, RBAC (has_permission), soft-delete, trilha de auditoria por triggers, credenciais de API write-only, colunas de auditoria em todo registro, JWT (Supabase Auth) — são consideradas controles de disponibilidade e integridade que sustentam os indicadores deste SLA.

**17.4.** O Portal Público de Rastreio, sem login, expõe apenas status neutro, sem PII, princípio de minimização que também vale para relatórios e Status Page (cláusula 13.6).

**17.5.** Nada neste SLA limita, reduz ou afasta direitos dos titulares de dados nem obrigações legais da GLOP sob a LGPD.

---

## 18. Comunicação de Incidentes e Transparência

**18.1.** Em incidentes S1/S2, a GLOP comunica proativamente o CONTRATANTE, no menor tempo razoável, informando: natureza do incidente, serviços afetados, severidade, ações em curso e previsão de restabelecimento (quando estimável), com atualizações na cadência da cláusula 8.1.

**18.2.** A Status Page (cláusula 13.4) é o canal público oficial de acompanhamento de incidentes e manutenções em tempo quase real.

**18.3.** Para incidentes S1 e S2, a GLOP entrega Análise de Causa-Raiz (RCA) em até 5 (cinco) Dias Úteis após o restabelecimento, contendo: linha do tempo, causa-raiz, impacto, medidas corretivas e ações preventivas.

**18.4.** As comunicações formais entre as Partes referentes a este SLA seguem os canais e endereços indicados no Contrato principal e nesta minuta (lemoncapsencapsulados@gmail.com).

---

## 19. Limitação de Responsabilidade

**19.1.** Ressalvadas as hipóteses de dolo, culpa grave e as obrigações legais imperativas (notadamente LGPD e, quando aplicável, o Código de Defesa do Consumidor), a responsabilidade da GLOP por descumprimento das metas deste SLA limita-se à concessão dos créditos de serviço da cláusula 14, que constituem o remédio exclusivo previsto no item 14.8.

**19.2.** A GLOP não responde por lucros cessantes, danos indiretos, perda de chance ou danos emergentes decorrentes exclusivamente de indisponibilidade coberta por crédito, salvo vedação legal imperativa.

**19.3.** A responsabilidade agregada da GLOP relativa a este SLA, em cada período, observa o limite global de responsabilidade estabelecido no Contrato principal.

**19.4.** As limitações desta cláusula não se aplicam a: (i) violação de dados pessoais decorrente de falha imputável à GLOP; (ii) descumprimento de deveres legais de proteção de dados; (iii) danos causados por dolo ou culpa grave.

**19.5.** Nas relações regidas pelo CDC, prevalecem as normas de ordem pública protetivas do consumidor, não podendo esta cláusula ser interpretada de modo a afastá-las.

---

## 20. Vigência, Revisão e Reajuste de Metas

**20.1. Vigência.** Este SLA vigora a partir de 16 de julho de 2026 e permanece válido enquanto vigente o Contrato principal, do qual é acessório.

**20.2. Revisão periódica.** As metas (SLOs), os prazos e as tabelas de crédito são revisados **anualmente**, ou extraordinariamente quando houver: (i) mudança material na arquitetura/stack (ex.: alteração de provedores Supabase/Netlify); (ii) alteração legislativa/regulatória relevante; (iii) evolução do portfólio de serviços; ou (iv) recomendação de auditoria/RCA.

**20.3.** Alterações que aumentem obrigações do CONTRATANTE ou reduzam garantias exigem comunicação prévia com antecedência mínima de **30 (trinta) dias**, facultando ao CONTRATANTE manifestar-se; alterações que ampliem garantias podem ser aplicadas imediatamente.

**20.4.** Metas superiores (planos Enterprise/Enterprise Plus) podem ser negociadas em aditivo específico, prevalecendo sobre as metas-padrão desta minuta.

**20.5.** O uso continuado da Plataforma após a comunicação de alterações, decorrido o prazo do item 20.3, implica aceitação da versão revisada, salvo manifestação em contrário.

---

## 21. Rescisão por Descumprimento Reiterado

**21.1.** Constitui descumprimento reiterado, autorizando a rescisão motivada pelo CONTRATANTE sem multa rescisória a seu cargo:

- a) disponibilidade mensal inferior ao SLO por **3 (três) meses consecutivos** ou **4 (quatro) meses alternados** em período de 12 meses; ou
- b) descumprimento do Tempo de Resolução de incidentes S1 em **3 (três) ocorrências** dentro de 12 meses; ou
- c) incidente de segurança grave com dados pessoais causado por falha imputável exclusivamente à GLOP, não sanado adequadamente.

**21.2.** A rescisão motivada não afasta o direito do CONTRATANTE aos créditos apurados e a eventual indenização nos limites da cláusula 19, tampouco os deveres de portabilidade/exportação e eliminação de dados previstos no DPA e nas Políticas aplicáveis.

**21.3.** Na rescisão, a GLOP disponibilizará ao CONTRATANTE, em formato estruturado e interoperável, os dados que lhe pertençam ou que trate na condição de OPERADORA, conforme prazos do DPA, ressalvadas obrigações legais de retenção.

---

## 22. Disposições Gerais e Foro

**22.1. Independência das cláusulas.** A nulidade ou inexequibilidade de qualquer cláusula não prejudica as demais, que permanecem válidas.

**22.2. Hierarquia documental.** Em conflito, prevalece: (1) legislação imperativa; (2) DPA e Políticas de proteção de dados; (3) Contrato principal; (4) este SLA; (5) documentos comerciais acessórios.

**22.3. Cessão.** Este SLA acompanha a cessão do Contrato principal, nas condições nele previstas.

**22.4. Tolerância.** A tolerância de qualquer Parte quanto ao cumprimento de obrigações não constitui novação nem renúncia.

**22.5. Notificações.** As comunicações relativas a este SLA são feitas pelos canais oficiais (cláusula 9) e endereços de contato das Partes.

**22.6. Lei aplicável.** Este SLA rege-se pelas leis da República Federativa do Brasil, em especial o Código Civil, a LGPD (Lei nº 13.709/2018), o Marco Civil da Internet (Lei nº 12.965/2014) e, quando aplicável, o CDC (Lei nº 8.078/1990).

**22.7. Foro.** Fica eleito o foro da Comarca de Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, com renúncia a qualquer outro por mais privilegiado que seja, ressalvada, nas relações de consumo, a competência do domicílio do consumidor e as regras de ordem pública.

---

## 23. Engenharia Jurídica & Governança

### 23.1. Fundamentação das Cláusulas (base legal e normativa)

| Cláusula / Tema | Fundamento jurídico e normativo |
|---|---|
| Natureza contratual e força obrigatória do SLA | Código Civil (CC), arts. 421, 421-A (função social e paritária dos contratos) e 425 (contratos atípicos); autonomia privada. |
| Definições, SLIs/SLOs, obrigações de meio e resultado | CC, arts. 389 e 475 (inadimplemento); boa-fé objetiva (art. 422). |
| Disponibilidade, medição e transparência | Marco Civil da Internet (Lei 12.965/2014), arts. 3º, 7º e 10 (padrões de qualidade, guarda de registros e segurança); boa-fé e dever de informação. |
| Exclusões — força maior/caso fortuito | CC, art. 393. |
| Dependência de Sub-Operadores | LGPD (Lei 13.709/2018), art. 5º, VII (operador) e arts. 39-40 (relação controlador-operador); DPA acessório. |
| Créditos de serviço e cláusula penal/limitação | CC, arts. 408-416 (cláusula penal) e 944, parágrafo único (redução equitativa); pré-fixação de perdas e danos. |
| Segurança e incidentes com dados pessoais | LGPD, arts. 6º (princípios: segurança, prevenção), 46-49 (segurança e boas práticas) e 48 (comunicação de incidente à ANPD e ao titular); Resoluções/Regulamento de incidentes da ANPD. |
| Backup, continuidade e RPO/RTO | LGPD, art. 46; boas práticas ISO/IEC 27001, 27701 (privacidade), 22301 (continuidade), 31000 (gestão de riscos), NIST CSF. |
| Suporte, severidade e escalonamento | Boas práticas ITIL (gestão de incidentes e níveis de serviço); boa-fé contratual. |
| Limitação de responsabilidade | CC, arts. 393, 402-404 e 944; ressalva de normas imperativas. |
| Relação de consumo (quando aplicável) | CDC (Lei 8.078/1990), arts. 6º, 14, 20, 39 e 51 (vedação de cláusulas abusivas e responsabilidade por vício/fato do serviço). |
| Foro e lei aplicável | CC; CPC; CDC (foro do consumidor). |

### 23.2. Riscos Mitigados

- **Litígio por indisponibilidade e falta de parâmetro objetivo:** mitigado por SLIs/SLOs mensuráveis, fórmula de uptime e regras de medição (cláusulas 5, 6, 13).
- **Responsabilização por falha de terceiros (Supabase, Netlify, Correios, VHSYS, gateways):** mitigado pela cláusula de dependência de Sub-Operadores e exclusões (11 e 12), preservando dever de diligência e mitigação.
- **Exposição financeira ilimitada:** mitigada por créditos pré-fixados, teto de 50% e exclusividade do remédio (cláusula 14), com ressalva de dolo/culpa grave e LGPD.
- **Discussão sobre início/fim de indisponibilidade:** mitigada por definições de resposta/resolução, precedência de logs e retenção de evidências (3, 8, 13).
- **Incidente de segurança/vazamento de PII:** mitigado por tratamento S1, remissão ao DPA/LGPD e deveres de comunicação (17, 18).
- **Manutenções gerando falso Downtime:** mitigado por regras de janela, aviso prévio e não computação (cláusula 10).
- **Abuso de pedidos de crédito ou perda de prazo:** mitigado por procedimento formal e prazo decadencial de 30 dias (cláusula 15).
- **Perda de dados e descontinuidade:** mitigada por RPO/RTO, backup, soft-delete e trilha de auditoria (16).
- **Assimetria em relação de consumo:** mitigada por ressalvas expressas ao CDC e a normas imperativas (19, 22).
- **Obsolescência do documento:** mitigada por plano de revisão anual e gatilhos extraordinários (20).

### 23.3. Checklist de Implementação e Conformidade

- [ ] Preencher todos os placeholders (LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, 55.836.075/0001-07, Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, lemoncapsencapsulados@gmail.com, a ser designado pela administração, 16 de julho de 2026, [CONTRATANTE]).
- [ ] Definir o plano contratado e a meta de disponibilidade aplicável (cláusula 6.2).
- [ ] Validar tabelas de crédito e teto com a área financeira/comercial.
- [ ] Implementar monitoramento sintético (health checks) dos Serviços Cobertos.
- [ ] Configurar Status Page pública e canais oficiais de suporte.
- [ ] Definir hotline/canal prioritário S1 (24×7) e escala de plantão.
- [ ] Estabelecer rotina automatizada de relatório mensal de SLA.
- [ ] Documentar procedimento de RCA para S1/S2 (prazo de 5 dias úteis).
- [ ] Validar retenção mínima de 12 meses de logs e evidências.
- [ ] Alinhar SLA ↔ DPA ↔ Política de Segurança ↔ Política de Backup ↔ Plano de Continuidade.
- [ ] Confirmar mecanismos de resiliência das integrações (retentativa, fila, degradação graciosa).
- [ ] Testar procedimento de backup/restauração (RPO/RTO) periodicamente.
- [ ] Submeter a minuta a advogado(a) habilitado(a) antes do uso em produção.

### 23.4. Matriz RACI

Legenda: R = Responsável (executa); A = Aprovador (presta contas); C = Consultado; I = Informado.

| Atividade / Entregável | Diretoria/Jurídico | Encarregado (DPO) | Engenharia/SRE | Suporte/CS | Comercial/Financeiro | CONTRATANTE |
|---|---|---|---|---|---|---|
| Aprovar e publicar o SLA | A | C | C | I | C | I |
| Definir/ajustar SLOs e metas | A | C | R | C | C | C |
| Monitorar SLIs e disponibilidade | I | I | R | C | I | I |
| Classificar severidade de incidentes | I | C | C | R | I | C |
| Tratar incidente S1 (24×7) | I | C | R | A | I | I |
| Emitir RCA (S1/S2) | I | C | R | C | I | I |
| Emitir relatório mensal de SLA | I | I | R | C | A | I |
| Analisar e conceder créditos | A | I | C | C | R | I |
| Solicitar créditos | I | I | I | C | I | R |
| Comunicar incidente de dados (LGPD) | A | R | C | C | I | C |
| Revisar SLA (anual/extraordinária) | A | C | C | C | C | I |
| Gerir Sub-Operadores e integrações | I | C | R | I | C | I |

### 23.5. Plano de Revisão

- **Ciclo ordinário:** revisão anual completa do SLA, com reavaliação de SLIs/SLOs, tabelas de crédito, prazos e exclusões.
- **Gatilhos extraordinários:** mudança de provedor de infraestrutura (Supabase/Netlify); alteração de API por terceiros (Correios/VHSYS/gateways/e-commerces); incidente S1 relevante ou padrão recorrente identificado em RCA; alteração legislativa/regulatória (LGPD/ANPD/CDC); lançamento de novos serviços cobertos.
- **Responsável:** Encarregado (DPO) a ser designado pela administração, com Engenharia/SRE e Jurídico.
- **Aprovação:** Diretoria/Jurídico.
- **Registro:** toda alteração é versionada na tabela de controle de versão (23.6) e comunicada conforme cláusula 20.3.
- **Métrica de saúde do plano:** acompanhamento trimestral dos SLIs para antecipar necessidade de reajuste de metas.

### 23.6. Controle de Versão

| Versão | Data | Autor / Responsável | Descrição da alteração | Aprovação |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | a ser designado pela administração / Jurídico | Emissão inicial da minuta do SLA da Plataforma GLOP (stack Supabase/Netlify; fluxos de ingestão, expedição, rastreio, fiscal e split). | 16 de julho de 2026 — pendente de validação por advogado(a) habilitado(a) |
| — | — | — | (Próximas revisões conforme Plano de Revisão 23.5) | — |

---

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. Ajuste as metas (SLOs), tabelas de crédito e prazos à realidade operacional efetiva da GLOP e de seus Sub-Operadores, e harmonize com o Contrato principal, o DPA e as Políticas de Segurança, Backup e Continuidade.
