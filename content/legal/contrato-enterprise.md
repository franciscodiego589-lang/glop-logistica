# Contrato Enterprise de Prestação de Serviços de Plataforma (SaaS) — GLOP (Global Logistics Platform)

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

**Instrumento Particular de Contrato Enterprise de Licenciamento e Prestação de Serviços de Software como Serviço (SaaS), Suporte, Onboarding e Serviços Correlatos**

**Contrato nº:** [Nº DO CONTRATO] — **Data de assinatura:** 16 de julho de 2026 — **Versão do instrumento:** 1.0

Pelo presente instrumento particular e na melhor forma de direito, as partes a seguir qualificadas:

**FORNECEDORA / CONTRATADA:** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, nome fantasia [NOME FANTASIA: GLOP], pessoa jurídica de direito privado inscrita no CNPJ sob o nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, neste ato representada na forma de seus atos constitutivos, doravante denominada **"GLOP"**, **"Fornecedora"** ou **"Contratada"**; e

**CLIENTE / CONTRATANTE:** [CONTRATANTE — RAZÃO SOCIAL], pessoa jurídica de direito privado inscrita no CNPJ sob o nº [CNPJ DO CONTRATANTE], com sede em [ENDEREÇO DO CONTRATANTE], neste ato representada na forma de seus atos constitutivos, doravante denominada **"Cliente"**, **"Contratante"** ou **"Parte"**;

GLOP e Cliente, quando referidas em conjunto, são denominadas **"Partes"** e, individualmente, **"Parte"**.

**Encarregado pelo Tratamento de Dados Pessoais (DPO) da GLOP:** a ser designado pela administração — contato: lemoncapsencapsulados@gmail.com.

**RESOLVEM** as Partes celebrar o presente Contrato Enterprise de Prestação de Serviços de Plataforma ("Contrato"), que se regerá pelas cláusulas e condições seguintes, além dos Anexos e documentos acessórios referidos na Cláusula 3.

---

## Considerandos

**CONSIDERANDO** que a GLOP é titular e mantenedora da plataforma Global Logistics Platform ("Plataforma" ou "GLOP"), um software como serviço (SaaS) de logística e ERP (WMS, TMS, YMS, gestão de pedidos/OMS, MRP/APS, PCP, torre de controle, BI e inteligência artificial LOGIA) voltado a operações de dropshipping e infoprodutos no Brasil, construído sobre arquitetura Next.js (App Router) e Supabase (PostgreSQL), com isolamento multi-tenant por RLS (Row Level Security) e RBAC, autenticação por JWT e hospedagem SSR em nuvem;

**CONSIDERANDO** que o Cliente é operação de grande porte que demanda escopo customizado, níveis de serviço reforçados (SLA), gerenciamento dedicado de conta, requisitos específicos de segurança, auditoria e conformidade, bem como participação em roadmap de produto;

**CONSIDERANDO** que a operação do Cliente envolve a ingestão de pedidos e de dados pessoais de compradores finais a partir de gateways de pagamento e checkouts (Monetizze, AppMax, Hotmart, Kiwify) e de e-commerces/marketplaces (Shopify, WooCommerce, Nuvemshop, Mercado Livre), o processamento logístico (pré-postagem PPN e rastreio SRO junto aos Correios), a emissão de documentos fiscais (NF-e) via VHSYS, a notificação a compradores por e-mail e WhatsApp, o portal público de rastreio e a gestão de coprodução, comissões e split de pagamentos;

**CONSIDERANDO** que, no tratamento de dados pessoais, a GLOP atua em dupla natureza — como **Operadora** quanto aos dados dos compradores finais tratados em nome e sob instrução do Cliente (Controlador), e como **Controladora** quanto aos dados de cadastro, faturamento e uso dos próprios usuários/colaboradores do Cliente — nos termos do Acordo de Tratamento de Dados Pessoais (DPA) que integra este Contrato;

**CONSIDERANDO** que as Partes desejam disciplinar de forma exaustiva o escopo, os níveis de serviço, as penalidades, as obrigações de segurança e auditoria, as condições comerciais e a governança da relação enterprise;

**RESOLVEM** contratar o quanto segue.

---

## Sumário

1. Definições
2. Objeto do Contrato
3. Documentos Integrantes e Ordem de Prevalência
4. Escopo Customizado, Módulos e Order Form
5. Onboarding, Implantação e Marcos de Aceite
6. Provisionamento, Licença de Uso e Restrições
7. Integrações, Sub-operadores e Credenciais de API
8. Níveis de Serviço (SLA) Reforçados e Penalidades
9. Suporte Técnico, Escalonamento e Gerente de Conta
10. Segurança da Informação
11. Direito de Auditoria e Verificação de Conformidade
12. Roadmap, Evolução do Produto e Solicitações de Mudança
13. Condições Comerciais, Preço, Faturamento e Reajuste
14. Inadimplência, Suspensão e Retomada
15. Obrigações do Cliente
16. Obrigações da GLOP
17. Confidencialidade
18. Proteção de Dados Pessoais (Remissão ao DPA e à LGPD)
19. Propriedade Intelectual e Licenciamento
20. Dados Agregados, Anonimizados e Melhoria do Serviço
21. Garantias, Isenções e Disponibilidade
22. Responsabilidade Civil e Limitação de Responsabilidade
23. Indenização (Hold Harmless)
24. Prazo, Vigência e Renovação
25. Rescisão, Hipóteses e Efeitos
26. Reversibilidade, Portabilidade e Eliminação de Dados
27. Penalidades e Multas Contratuais
28. Força Maior e Caso Fortuito
29. Não Solicitação e Não Aliciamento
30. Cessão, Subcontratação e Sucessão
31. Comunicações e Notificações
32. Anticorrupção, Compliance e Sanções
33. Disposições Gerais
34. Lei Aplicável e Foro
35. Engenharia Jurídica & Governança

---

## 1. Definições

Para os fins deste Contrato, os termos abaixo, no singular ou no plural, têm o significado a seguir atribuído, complementando as definições da LGPD (art. 5º), do CDC e do Marco Civil da Internet:

- **Plataforma / GLOP:** o software como serviço (SaaS) de logística e ERP Global Logistics Platform, incluindo módulos de WMS, TMS, YMS, OMS, MRP/APS, PCP, torre de controle, BI, IA (LOGIA), APIs, webhooks, painéis, o portal público de rastreio e a documentação técnica correlata.
- **Order Form / Proposta Comercial:** o documento comercial assinado pelas Partes (Anexo I) que descreve o escopo contratado, módulos, volumetria, preços, prazos, ambiente e parâmetros específicos, prevalecendo quanto aos dados ali expressos.
- **Escopo Customizado:** conjunto de módulos, configurações, integrações, parametrizações, relatórios e desenvolvimentos específicos contratados pelo Cliente, descritos no Order Form e no Plano de Onboarding.
- **Ambiente:** instância lógica multi-tenant (Tenant → Company → Branch → Membership) provisionada ao Cliente, isolada por RLS e RBAC, incluindo, quando contratados, ambientes de homologação (staging) e produção.
- **Usuário Autorizado:** pessoa física vinculada ao Cliente (colaborador, preposto, coprodutor ou prestador), a quem o Cliente concede acesso ao Ambiente sob credenciais individuais e papel (role) definido.
- **Comprador / Titular / Consumidor final:** pessoa física ou jurídica que adquire produtos/serviços do Cliente e cujos dados pessoais (nome, CPF/CNPJ, e-mail, telefone, endereço completo, itens e valores do pedido) são ingeridos na Plataforma a partir dos gateways e e-commerces integrados.
- **Coprodutor / Afiliado:** terceiro vinculado ao Cliente, participante de regras de comissão, coprodução e/ou split de pagamentos, cujos dados de identificação e bancários (incluindo chave PIX e dados de conta) podem ser tratados na Plataforma.
- **Integrações de Terceiros:** serviços externos conectados à Plataforma por API ou webhook, incluindo, sem limitação, Monetizze, AppMax, Hotmart e Kiwify (checkout/pagamento), Shopify, WooCommerce, Nuvemshop e Mercado Livre (e-commerce/marketplace), Correios (pré-postagem PPN e rastreio SRO), VHSYS (NF-e) e canais de notificação (WhatsApp/e-mail).
- **Sub-operadores de Infraestrutura:** fornecedores de infraestrutura tecnológica utilizados pela Plataforma, notadamente Supabase (banco de dados PostgreSQL, autenticação e armazenamento) e Netlify (hospedagem SSR).
- **SLA (Service Level Agreement):** os níveis de serviço, metas de disponibilidade, tempos de resposta e resolução, e respectivas penalidades pactuados na Cláusula 8.
- **Disponibilidade / Uptime:** percentual de tempo em que a Plataforma está operacional e acessível, apurado mensalmente conforme a Cláusula 8.
- **Janela de Manutenção Programada:** período previamente comunicado destinado a manutenções, atualizações e evoluções, excluído do cálculo de indisponibilidade.
- **Incidente:** evento não programado que degrada ou interrompe o serviço, classificado por severidade (P1 a P4) na Cláusula 9.
- **Gerente de Conta (Customer Success Manager):** ponto focal dedicado designado pela GLOP para a relação com o Cliente enterprise.
- **DPA:** o Acordo de Tratamento de Dados Pessoais (Data Processing Agreement) celebrado entre as Partes, parte integrante deste Contrato (arquivo dpa.md).
- **Dados do Cliente:** todos os dados inseridos, importados ou gerados pelo Cliente e seus Usuários Autorizados no Ambiente, incluindo dados de pedidos, cadastros, PII de compradores e configurações, dos quais o Cliente é titular ou controlador.
- **LGPD:** Lei nº 13.709/2018. **CDC:** Lei nº 8.078/1990. **Marco Civil:** Lei nº 12.965/2014. **Código Civil:** Lei nº 10.406/2002.
- **Créditos de Serviço (Service Credits):** abatimentos financeiros devidos pela GLOP ao Cliente em razão de descumprimento de SLA, na forma da Cláusula 8.
- **Dia Útil:** dia de expediente bancário na praça da sede da GLOP, exceto sábados, domingos e feriados nacionais.

---

## 2. Objeto do Contrato

2.1. Constitui objeto deste Contrato a prestação, pela GLOP ao Cliente, dos seguintes serviços, na modalidade enterprise:

- **a)** licenciamento de uso, não exclusivo e intransferível, da Plataforma GLOP na modalidade SaaS, com o escopo customizado descrito no Order Form (Anexo I);
- **b)** serviços de onboarding, implantação, migração e configuração assistida do Ambiente (Cláusula 5);
- **c)** prestação de suporte técnico com gerenciamento dedicado de conta e escalonamento (Cláusula 9);
- **d)** garantia de níveis de serviço reforçados (SLA), com penalidades e créditos de serviço (Cláusula 8);
- **e)** hospedagem, processamento e armazenamento dos Dados do Cliente na infraestrutura contratada, com as medidas de segurança da Cláusula 10;
- **f)** disponibilização de integrações com gateways, e-commerces, Correios e VHSYS, conforme a Cláusula 7;
- **g)** participação em roadmap de produto e recebimento de evoluções e correções (Cláusula 12).

2.2. O objeto **não** compreende: (i) a atividade de checkout, gateway de pagamento, adquirência ou custódia de valores; (ii) a atividade de transporte físico, que é executada pelos Correios e/ou transportadoras contratadas pelo Cliente; (iii) a emissão fiscal, que é realizada por meio da VHSYS sob responsabilidade tributária do Cliente; (iv) consultoria jurídica, contábil ou tributária; (v) a decisão sobre finalidades do tratamento de dados dos compradores, que compete ao Cliente na qualidade de Controlador.

2.3. A GLOP presta serviço de meio (obrigação de meio) quanto à disponibilização de ferramenta tecnológica, e obrigação de resultado apenas quanto aos parâmetros expressamente quantificados neste Contrato (notadamente os do SLA).

---

## 3. Documentos Integrantes e Ordem de Prevalência

3.1. Integram este Contrato, para todos os fins, os seguintes documentos, que o complementam:

1. **Anexo I** — Order Form / Proposta Comercial (escopo, módulos, volumetria, preços, prazos);
2. **Anexo II** — Plano de Onboarding e Cronograma de Implantação;
3. **Anexo III** — Acordo de Nível de Serviço (SLA) detalhado, quando expandido além da Cláusula 8;
4. **Anexo IV** — Acordo de Tratamento de Dados Pessoais (DPA);
5. **Anexo V** — Descritivo Técnico de Segurança e Sub-operadores;
6. **Anexo VI** — Matriz de Papéis (RBAC) e Perfis de Acesso;
7. **Termos de Uso**, **Política de Privacidade**, **Política de Segurança**, **Política de Retenção**, **Política de Backup**, **Política de Descarte**, **Política de Auditoria** e **Política de Cookies** da GLOP.

3.2. **Ordem de prevalência.** Em caso de conflito entre os documentos, prevalecerá, na ordem: (i) este Contrato quanto às condições jurídicas gerais; (ii) o DPA quanto à matéria exclusiva de proteção de dados pessoais; (iii) o Order Form (Anexo I) quanto a preços, volumetria e escopo comercial; (iv) o Plano de Onboarding quanto a marcos e cronograma; (v) as Políticas e Termos de Uso quanto às regras gerais de uso. Cláusulas específicas prevalecem sobre gerais.

3.3. Alterações a qualquer documento integrante somente vinculam as Partes quando formalizadas por aditivo escrito assinado por ambas, ressalvadas as atualizações unilaterais de Políticas admitidas nos respectivos instrumentos, que não poderão reduzir direitos essenciais do Cliente sem aviso prévio de 30 (trinta) dias.

---

## 4. Escopo Customizado, Módulos e Order Form

4.1. O escopo contratado é o descrito no Order Form (Anexo I), que especificará, no mínimo: (i) os módulos habilitados (WMS, TMS, YMS, OMS, MRP/APS, PCP, torre de controle, BI, LOGIA); (ii) as integrações ativadas (gateways, e-commerces, Correios, VHSYS, canais de notificação); (iii) a volumetria contratada (número de pedidos/mês, usuários, empresas/filiais, chamadas de API, volume de armazenamento); (iv) os ambientes (produção e, se aplicável, homologação); (v) os SLAs aplicáveis; (vi) o preço e a forma de pagamento.

4.2. **Multi-tenant e multi-empresa.** O Ambiente do Cliente observa a hierarquia Tenant → Company → Branch → Membership. O Cliente poderá administrar múltiplas empresas (Company) e filiais (Branch) dentro do limite do Order Form, com isolamento lógico por RLS e controle de permissões por RBAC (has_permission por recurso e empresa).

4.3. **Desenvolvimentos específicos.** Customizações, relatórios sob medida, integrações não padronizadas e desenvolvimentos exclusivos serão objeto de Ordem de Serviço (OS) ou aditivo, com escopo, prazo, aceite e preço próprios, aplicando-se a disciplina de propriedade intelectual da Cláusula 19.

4.4. **Volumetria e excedentes.** Caso a operação do Cliente exceda de forma sustentada a volumetria contratada, a GLOP notificará o Cliente e as Partes negociarão, de boa-fé, a adequação do plano. Excedentes eventuais poderão ser cobrados conforme a tabela do Order Form, sem interrupção imediata do serviço, observado o aviso prévio de 15 (quinze) dias.

---

## 5. Onboarding, Implantação e Marcos de Aceite

5.1. **Plano de Onboarding.** A implantação seguirá o cronograma do Anexo II, contemplando, tipicamente, as fases: (i) **Kickoff** e levantamento de requisitos; (ii) **provisionamento** do Ambiente (Tenant/Company/Branch) e configuração de RBAC; (iii) **conexão das integrações** (gateways, e-commerces, Correios, VHSYS, notificações) e teste de credenciais write-only; (iv) **migração/importação** de dados históricos e cadastros; (v) **parametrização** de fluxos (ingestão de pedidos, pré-postagem, rastreio, split, notificação); (vi) **homologação assistida (UAT)**; (vii) **go-live**; (viii) **hypercare** (acompanhamento intensivo pós go-live pelo período definido no Anexo II).

5.2. **Responsabilidades de insumos.** O Cliente fornecerá, tempestivamente, credenciais das Integrações de Terceiros, bases de dados a migrar, informações fiscais e definição de papéis dos Usuários Autorizados. Atrasos imputáveis ao Cliente prorrogam automaticamente os marcos correspondentes, sem penalidade à GLOP.

5.3. **Aceite por marcos.** Cada marco relevante do Anexo II será submetido a aceite formal pelo Cliente. Considerar-se-á aceito o marco: (i) mediante manifestação expressa; ou (ii) tacitamente, se decorridos 10 (dez) Dias Úteis da entrega sem apontamento fundamentado. Apontamentos serão corrigidos e reapresentados dentro do prazo acordado.

5.4. **Go-live.** O go-live em produção depende da conclusão da homologação (UAT) e do aceite do respectivo marco. A partir do go-live, passam a incidir integralmente os SLAs da Cláusula 8.

5.5. **Serviços profissionais.** Os serviços de onboarding, migração e customização, quando cobrados à parte, são remunerados conforme o Order Form (valor fixo, por marco ou por hora técnica), independentemente da assinatura recorrente do SaaS.

---

## 6. Provisionamento, Licença de Uso e Restrições

6.1. **Licença.** A GLOP concede ao Cliente, durante a vigência e adimplente o Cliente, licença de uso da Plataforma **não exclusiva, intransferível, revogável e limitada** ao escopo do Order Form, para uso na operação própria do Cliente e de suas empresas/filiais cadastradas.

6.2. **Credenciais e responsabilidade.** O acesso se dá por credenciais individuais dos Usuários Autorizados (Supabase Auth, JWT). O Cliente é responsável pela guarda das credenciais, pela definição de papéis (RBAC), pela ativação de autenticação forte quando disponível e por todo ato praticado sob suas credenciais, ressalvada falha comprovadamente imputável à GLOP.

6.3. **Restrições de uso.** É vedado ao Cliente e aos Usuários Autorizados: (i) sublicenciar, revender, ceder ou disponibilizar a Plataforma a terceiros fora do escopo; (ii) realizar engenharia reversa, descompilação ou tentativa de extração do código-fonte, salvo na medida permitida por lei imperativa; (iii) contornar limites técnicos, RLS, RBAC ou controles de segurança; (iv) usar a Plataforma para fins ilícitos, fraude, lavagem de dinheiro ou violação de direitos de terceiros; (v) realizar testes de intrusão, varredura ou carga sem autorização prévia e por escrito da GLOP (vide Cláusula 11).

6.4. **Uso pretendido.** A Plataforma destina-se a operações logísticas de dropshipping e infoprodutos lícitas. O Cliente declara que sua operação é lícita e que detém base legal para o tratamento dos dados de compradores que ingressa na Plataforma.

---

## 7. Integrações, Sub-operadores e Credenciais de API

7.1. **Integrações de Terceiros.** A GLOP disponibiliza conectores para as Integrações de Terceiros. O funcionamento, a disponibilidade, as tarifas e as políticas desses serviços são de responsabilidade dos respectivos provedores. A GLOP não responde por indisponibilidade, alteração de API, suspensão de conta ou falha originada exclusivamente na Integração de Terceiro, sem prejuízo de envidar esforços de contorno e comunicação.

7.2. **Credenciais write-only.** As credenciais das Integrações de Terceiros são armazenadas de modo protegido e utilizadas em regime write-only (não recuperáveis em texto claro pela interface), sendo o Cliente responsável por sua validade e renovação. A revogação de credencial pelo provedor externo pode interromper o fluxo correspondente até a reconfiguração.

7.3. **Sub-operadores de infraestrutura.** O Cliente reconhece e autoriza a utilização dos Sub-operadores Supabase (banco de dados, autenticação e storage) e Netlify (hospedagem SSR), bem como dos demais sub-operadores relacionados no Anexo V e no DPA. A contratação, substituição ou inclusão de sub-operadores observa as regras do DPA, inclusive quanto a aviso prévio e direito de objeção fundamentada.

7.4. **Fluxos suportados.** As integrações suportam, conforme o escopo: (i) ingestão de pedidos e PII do comprador via API (Monetizze, Hotmart, Kiwify) e e-commerces (Shopify, WooCommerce, Nuvemshop, Mercado Livre); (ii) pré-postagem (PPN) e rastreio (SRO) junto aos Correios; (iii) emissão de NF-e via VHSYS; (iv) split de pagamento e repasses a coprodutores/afiliados (AppMax), inclusive dados de PIX/bancários; (v) notificação ao comprador por e-mail e WhatsApp; (vi) portal público de rastreio sem login, que expõe somente status neutro, sem PII.

7.5. **Portal público de rastreio.** O Cliente reconhece que o portal público de rastreio é acessível sem autenticação e, por decisão de segurança e privacidade, expõe apenas status logístico neutro do objeto, sem dados pessoais do comprador. O Cliente não configurará o portal para expor PII.

---

## 8. Níveis de Serviço (SLA) Reforçados e Penalidades

8.1. **Disponibilidade mensal.** A GLOP compromete-se com disponibilidade mínima da Plataforma em produção de **[SLA UPTIME, ex.: 99,7%]** por mês-calendário ("Uptime Garantido"), apurada sobre o total de minutos do mês, excluídas as exceções da Cláusula 8.5.

8.2. **Cálculo.** Disponibilidade (%) = ((Minutos Totais no Mês − Minutos de Indisponibilidade) ÷ Minutos Totais no Mês) × 100. Considera-se **Indisponibilidade** a impossibilidade de acesso ou de uso das funções essenciais da Plataforma, comprovada por monitoramento e/ou registros de suporte.

8.3. **Tempos de resposta e resolução (suporte técnico).** A GLOP observará, por severidade, as metas abaixo, contadas a partir do registro do chamado:

| Severidade | Descrição | Tempo de Resposta (meta) | Tempo de Resolução / Contorno (meta) |
|---|---|---|---|
| **P1 — Crítica** | Plataforma inoperante ou fluxo crítico (ingestão de pedidos, expedição) parado, sem contorno | 30 minutos | 4 horas |
| **P2 — Alta** | Função importante degradada, com impacto relevante, mas com contorno parcial | 2 horas | 8 horas úteis |
| **P3 — Média** | Falha localizada, sem impacto crítico, com contorno disponível | 8 horas úteis | 5 Dias Úteis |
| **P4 — Baixa** | Dúvida, solicitação de melhoria ou impacto mínimo | 1 Dia Útil | Conforme roadmap/planejamento |

8.4. **Créditos de Serviço (penalidades por descumprimento).** Não atingido o Uptime Garantido no mês, o Cliente fará jus a Créditos de Serviço, aplicáveis como abatimento na fatura subsequente, na forma da tabela abaixo, calculados sobre a mensalidade recorrente do mês afetado:

| Disponibilidade apurada no mês | Crédito de Serviço (% da mensalidade) |
|---|---|
| Igual ou superior ao Uptime Garantido | 0% |
| Abaixo do Garantido e ≥ 99,0% | 5% |
| < 99,0% e ≥ 98,0% | 10% |
| < 98,0% e ≥ 95,0% | 20% |
| < 95,0% | 30% |

8.4.1. O descumprimento reiterado das metas de resposta/resolução P1/P2 por 3 (três) chamados no mesmo mês gera Crédito de Serviço adicional de 5% da mensalidade, limitado o total de créditos do mês a 40% (quarenta por cento) da mensalidade.

8.4.2. **Solicitação.** O Cliente deverá solicitar o Crédito de Serviço em até 30 (trinta) dias do fechamento do mês afetado, apresentando os registros. Os Créditos de Serviço constituem o remédio primário por descumprimento de SLA, sem prejuízo dos casos de rescisão por descumprimento grave (Cláusula 25) e da reparação por danos comprovados quando cabível.

8.5. **Exclusões do cálculo de indisponibilidade.** Não são computados como Indisponibilidade nem geram penalidade: (i) Janelas de Manutenção Programada comunicadas com antecedência mínima de 48 (quarenta e oito) horas; (ii) manutenções emergenciais de segurança, com comunicação tão logo possível; (iii) falhas de Integrações de Terceiros ou de Sub-operadores de Infraestrutura fora do controle da GLOP; (iv) força maior ou caso fortuito (Cláusula 28); (v) uso em desacordo com este Contrato, culpa ou ato do Cliente/Usuário; (vi) falhas de conectividade, equipamento ou rede do Cliente; (vii) suspensão legítima por inadimplência (Cláusula 14).

8.6. **Janela de Manutenção Programada.** As manutenções programadas serão realizadas, preferencialmente, em horários de menor movimento e comunicadas ao Gerente de Conta do Cliente. A GLOP envidará esforços para minimizar impacto e duração.

8.7. **Relatório de SLA.** A GLOP disponibilizará ao Cliente, mensalmente ou mediante solicitação, relatório de disponibilidade e de atendimento aos SLAs de suporte.

---

## 9. Suporte Técnico, Escalonamento e Gerente de Conta

9.1. **Canais de suporte.** O suporte enterprise é prestado pelos canais definidos no Order Form (portal de chamados, e-mail dedicado e/ou canal prioritário), em horário [HORÁRIO DE COBERTURA, ex.: 8x5 ou 24x7 conforme plano].

9.2. **Gerente de Conta (Customer Success Manager).** A GLOP designará um Gerente de Conta dedicado, ponto focal para: (i) acompanhamento da adoção e saúde da conta; (ii) reuniões periódicas de acompanhamento (QBR — revisões [trimestrais/semestrais]); (iii) coordenação de escalonamento de incidentes; (iv) intermediação de solicitações de roadmap; (v) gestão de renovação e expansão. A substituição do Gerente de Conta será comunicada ao Cliente com transição ordenada.

9.3. **Matriz de escalonamento.** Incidentes P1/P2 seguem escalonamento: (i) **N1** — triagem e primeiro atendimento; (ii) **N2** — suporte técnico especializado; (iii) **N3** — engenharia/produto; (iv) **gestão** — Gerente de Conta e liderança técnica, para P1 não resolvido no prazo. A matriz nominal de contatos consta do Anexo II.

9.4. **Obrigações do Cliente no suporte.** O Cliente designará interlocutores técnicos aptos, fornecerá informações e evidências necessárias à reprodução do incidente e colaborará na validação das correções.

9.5. **Fora de escopo do suporte.** Não integram o suporte: (i) desenvolvimento de customizações (que seguem a Cláusula 4.3/12); (ii) suporte a produtos de terceiros; (iii) treinamento além do previsto no onboarding; (iv) correção de problemas decorrentes de uso indevido, salvo mediante Ordem de Serviço específica.

---

## 10. Segurança da Informação

10.1. **Medidas técnicas e organizacionais.** A GLOP mantém, no mínimo, as seguintes medidas, alinhadas a boas práticas (ISO/IEC 27001, 27701, 22301, 31000, NIST e OWASP) e à Política de Segurança da GLOP:

- **a)** isolamento multi-tenant por **RLS** (Row Level Security) por empresa, com negação por padrão;
- **b)** controle de acesso por **RBAC** (has_permission por recurso e empresa) e princípio do menor privilégio;
- **c)** autenticação por **JWT** (Supabase Auth) e gestão de sessão;
- **d)** **soft-delete** (vedado o apagamento físico como regra) e **trilha de auditoria por triggers** de banco;
- **e)** **colunas de auditoria** em todo registro (created_by, updated_by, deleted_at, deleted_by, reason_deleted, version, timestamps);
- **f)** credenciais de API de terceiros em regime **write-only**;
- **g)** criptografia em trânsito (TLS) e em repouso conforme capacidades da infraestrutura;
- **h)** rotinas de **backup** e recuperação conforme a Política de Backup e a Política de Retenção;
- **i)** segregação de ambientes, controle de mudanças e registro de logs.

10.2. **Gestão de vulnerabilidades.** A GLOP mantém processo de identificação, classificação e correção de vulnerabilidades, priorizando correções críticas, e adota práticas de desenvolvimento seguro (OWASP).

10.3. **Resposta a incidentes de segurança.** A GLOP mantém plano de resposta a incidentes. Incidente de segurança envolvendo Dados Pessoais é tratado na forma do DPA e da LGPD (art. 48), com comunicação ao Cliente sem demora injustificada e apoio às obrigações de notificação à ANPD e aos titulares, quando cabível.

10.4. **Continuidade de negócios.** A GLOP mantém medidas de continuidade e recuperação (alinhadas a ISO 22301), incluindo backup e planos de restauração, com objetivos de recuperação (RTO/RPO) definidos no Anexo V ou na Política de Backup.

10.5. **Segurança do lado do Cliente.** O Cliente é responsável pela segurança de seus dispositivos, redes e da concessão/revogação tempestiva de acessos de seus Usuários Autorizados, notadamente no desligamento de colaboradores.

10.6. **Certificações.** As certificações e atestados eventualmente detidos pela GLOP ou por seus Sub-operadores serão indicados no Anexo V. A ausência de certificação específica não afasta as obrigações de segurança aqui pactuadas.

---

## 11. Direito de Auditoria e Verificação de Conformidade

11.1. **Auditoria de conformidade.** O Cliente, diretamente ou por auditor independente sujeito a confidencialidade, poderá verificar o cumprimento das obrigações de segurança e proteção de dados, no máximo **1 (uma) vez por ano** (salvo incidente relevante ou determinação de autoridade), mediante aviso prévio de 30 (trinta) dias, em horário comercial, sem interromper a operação e preservando a segurança e a confidencialidade de dados de outros clientes.

11.2. **Modalidades.** A auditoria observará a seguinte ordem de suficiência: (i) fornecimento de relatórios, atestados, certificações e evidências documentais; (ii) resposta a questionário de segurança (due diligence); (iii) somente se as anteriores forem insuficientes e houver motivo fundado, auditoria assistida remota; e (iv) inspeção presencial limitada, em último caso, acompanhada pela GLOP. A auditoria não dará acesso a dados de outros clientes, a segredos de negócio ou a código-fonte proprietário.

11.3. **Trilha de auditoria interna.** Independentemente da auditoria do Cliente, a Plataforma mantém trilha de auditoria por triggers e colunas de auditoria em todo registro, disponibilizando ao Cliente, conforme a Política de Auditoria, os logs pertinentes à sua própria operação.

11.4. **Custos.** Os custos da auditoria correm por conta do Cliente, salvo se a auditoria constatar descumprimento material imputável à GLOP, hipótese em que a GLOP arcará com os custos razoáveis e implementará plano de ação corretiva.

11.5. **Testes de intrusão.** Testes de intrusão, varredura de vulnerabilidades ou testes de carga pelo Cliente dependem de autorização prévia, escopo e janela acordados por escrito, para não afetar terceiros e a estabilidade do serviço.

---

## 12. Roadmap, Evolução do Produto e Solicitações de Mudança

12.1. **Evolução contínua.** A GLOP evolui a Plataforma de forma contínua, disponibilizando correções, melhorias e novas funcionalidades, sem custo adicional quando integrantes do plano contratado, exceto módulos e integrações novos comercializados à parte.

12.2. **Participação no roadmap.** Na condição enterprise, o Cliente participa do processo de priorização por meio do Gerente de Conta e das reuniões periódicas (QBR), podendo submeter solicitações de funcionalidade. A GLOP considerará tais solicitações de boa-fé, sem, contudo, obrigar-se a implementá-las em prazo determinado, salvo compromisso específico formalizado em aditivo ou Ordem de Serviço.

12.3. **Solicitações de mudança (Change Requests).** Customizações e desenvolvimentos específicos seguem processo de Change Request com descrição de escopo, estimativa, prazo, preço e aceite, formalizados por Ordem de Serviço, aplicando-se a Cláusula 19 quanto à propriedade intelectual do resultado.

12.4. **Depreciação de funcionalidades.** A GLOP poderá descontinuar funcionalidades por razões técnicas, de segurança ou de mercado, com aviso prévio razoável (mínimo de 60 dias para funcionalidades essenciais em uso pelo Cliente) e, quando possível, oferta de alternativa equivalente. Alterações de API observarão política de versionamento e período de compatibilidade razoável.

12.5. **Compatibilidade de integrações.** Alterações promovidas por Integrações de Terceiros ou Sub-operadores podem exigir adaptações; a GLOP envidará esforços para manter a continuidade, sem responder por descontinuidades impostas por terceiros.

---

## 13. Condições Comerciais, Preço, Faturamento e Reajuste

13.1. **Preço.** O Cliente pagará à GLOP os valores previstos no Order Form (Anexo I), que poderão compreender: (i) mensalidade/assinatura recorrente do SaaS; (ii) valores de onboarding/implantação; (iii) valores de serviços profissionais e customizações; (iv) valores por excedentes de volumetria; (v) tributos aplicáveis.

13.2. **Faturamento e pagamento.** O faturamento observará a periodicidade do Order Form (mensal, trimestral ou anual). O pagamento é devido no vencimento indicado na fatura/nota fiscal, pelos meios ali previstos. A recorrência inicia-se conforme o Order Form (tipicamente no go-live), independentemente da eventual continuidade de fases de onboarding.

13.3. **Tributos.** Os preços não incluem tributos incidentes sobre a operação, salvo se expressamente indicado, sendo cada Parte responsável pelos tributos que lhe couberem por lei.

13.4. **Reajuste.** Os valores recorrentes serão reajustados anualmente, a contar da data-base do Contrato, pela variação positiva do **[ÍNDICE, ex.: IPCA/IGP-M]** acumulado no período, ou por outro índice que legalmente o substitua. Reajustes por revisão de escopo/volumetria seguem o Order Form.

13.5. **Inadimplência (encargos).** O atraso no pagamento sujeita o Cliente a: (i) **multa moratória de 2% (dois por cento)**; (ii) **juros de mora de 1% (um por cento) ao mês**, pro rata die; e (iii) atualização monetária pelo índice da Cláusula 13.4, sem prejuízo da suspensão prevista na Cláusula 14.

13.6. **Não compensação indevida.** Salvo os Créditos de Serviço da Cláusula 8, o Cliente não poderá reter ou compensar valores unilateralmente sem decisão judicial/arbitral ou acordo escrito.

---

## 14. Inadimplência, Suspensão e Retomada

14.1. **Suspensão por inadimplência.** Verificado atraso superior a **[Nº, ex.: 15]** dias no pagamento de qualquer valor devido, a GLOP notificará o Cliente e, persistindo a inadimplência por mais **[Nº, ex.: 10]** dias após a notificação, poderá **suspender** o acesso à Plataforma, no todo ou em parte, sem que isso configure rescisão ou afaste a dívida.

14.2. **Preservação de dados na suspensão.** Durante a suspensão por inadimplência, os Dados do Cliente serão preservados por prazo razoável (mínimo compatível com a Política de Retenção), permitindo a retomada mediante quitação. Persistindo a inadimplência, aplicam-se as Cláusulas 25 e 26.

14.3. **Retomada.** Quitados os valores em aberto e respectivos encargos, o acesso será restabelecido em prazo razoável. A GLOP poderá condicionar a retomada à regularização integral do débito.

14.4. **Suspensão por risco.** A GLOP poderá suspender de imediato, no todo ou em parte, o acesso, em caso de: (i) risco iminente à segurança, integridade ou disponibilidade da Plataforma ou de terceiros; (ii) uso ilícito ou fraudulento; (iii) ordem de autoridade competente. A suspensão será a mínima necessária e comunicada tão logo possível.

---

## 15. Obrigações do Cliente

15.1. Sem prejuízo das demais obrigações deste Contrato, o Cliente obriga-se a:

- **a)** utilizar a Plataforma conforme este Contrato, os Termos de Uso, as Políticas e a legislação;
- **b)** pagar pontualmente os valores devidos;
- **c)** fornecer, no onboarding e durante a operação, informações e insumos verídicos, completos e tempestivos;
- **d)** gerir seus Usuários Autorizados, definindo papéis (RBAC), controlando concessão e revogação de acessos e mantendo a confidencialidade das credenciais;
- **e)** atuar como **Controlador** dos dados dos compradores, definindo finalidades e bases legais, atendendo aos direitos dos titulares e observando a LGPD, na forma do DPA;
- **f)** garantir a licitude e a base legal dos dados que ingressa na Plataforma (via gateways, e-commerces e cadastros);
- **g)** responsabilizar-se pela emissão fiscal (NF-e via VHSYS) e por suas obrigações tributárias;
- **h)** responsabilizar-se pela relação com os compradores/consumidores, inclusive quanto ao CDC, entrega, trocas e reclamações;
- **i)** manter contatos técnicos e administrativos atualizados;
- **j)** não praticar as vedações da Cláusula 6.3 e das Políticas;
- **k)** comunicar à GLOP, sem demora, incidentes de segurança ou uso indevido de que tomar conhecimento.

---

## 16. Obrigações da GLOP

16.1. Sem prejuízo das demais obrigações deste Contrato, a GLOP obriga-se a:

- **a)** prestar os serviços com diligência, observando os SLAs da Cláusula 8;
- **b)** disponibilizar o Ambiente provisionado, com isolamento multi-tenant (RLS) e RBAC;
- **c)** manter as medidas de segurança da Cláusula 10 e das Políticas;
- **d)** disponibilizar suporte e Gerente de Conta na forma da Cláusula 9;
- **e)** tratar dados pessoais na qualidade de Operadora (dados dos compradores) e de Controladora (dados dos usuários/colaboradores do Cliente) conforme o DPA e a LGPD;
- **f)** manter trilha de auditoria e disponibilizar logs pertinentes à operação do Cliente conforme a Política de Auditoria;
- **g)** comunicar Janelas de Manutenção Programada e incidentes relevantes;
- **h)** evoluir a Plataforma e disponibilizar correções conforme a Cláusula 12;
- **i)** apoiar a reversibilidade e a portabilidade no encerramento (Cláusula 26);
- **j)** manter sigilo sobre as Informações Confidenciais do Cliente (Cláusula 17).

16.2. As obrigações da GLOP são de meio quanto à ferramenta e de resultado apenas quanto aos parâmetros quantificados (SLA), não abrangendo resultados comerciais do Cliente nem atos de terceiros.

---

## 17. Confidencialidade

17.1. **Definição.** Consideram-se **Informações Confidenciais** todas as informações, técnicas, comerciais, financeiras, operacionais, de segurança, de dados e de negócio, em qualquer forma, reveladas por uma Parte (Reveladora) à outra (Receptora) em razão deste Contrato, inclusive o próprio conteúdo comercial do Order Form, a arquitetura e os controles de segurança da Plataforma, e os Dados do Cliente.

17.2. **Exceções.** Não são confidenciais informações que: (i) sejam ou se tornem públicas sem violação deste Contrato; (ii) já eram legitimamente conhecidas pela Receptora sem obrigação de sigilo; (iii) sejam desenvolvidas de forma independente; ou (iv) sejam obtidas legitimamente de terceiro sem dever de sigilo.

17.3. **Obrigações.** A Receptora obriga-se a: (i) manter sigilo e usar as Informações Confidenciais apenas para a execução do Contrato; (ii) restringir o acesso a colaboradores/prestadores com necessidade de conhecer, sob dever de sigilo equivalente; (iii) adotar medidas de proteção não inferiores às aplicadas às próprias informações sensíveis.

17.4. **Divulgação legal.** A revelação exigida por lei, ordem judicial ou autoridade competente não viola esta cláusula, devendo a Receptora, quando lícito, comunicar previamente a Reveladora para adoção de medidas cabíveis e limitar a revelação ao mínimo exigido.

17.5. **Vigência.** As obrigações de confidencialidade vigoram durante o Contrato e por **5 (cinco) anos** após seu término, e, quanto a segredos de negócio e dados pessoais, enquanto perdurar a proteção legal.

17.6. **Devolução/destruição.** Encerrado o Contrato, a Receptora devolverá ou destruirá as Informações Confidenciais da Reveladora, ressalvadas cópias exigidas por lei ou por rotinas de backup, que permanecerão sob sigilo até seu descarte natural.

---

## 18. Proteção de Dados Pessoais (Remissão ao DPA e à LGPD)

18.1. **Regência.** O tratamento de dados pessoais no âmbito deste Contrato rege-se pelo **DPA** (Anexo IV), pela **LGPD** e, quando aplicável, pelo **GDPR**, prevalecendo o DPA em caso de conflito quanto à matéria de proteção de dados.

18.2. **Dupla natureza.** A GLOP atua: (i) como **Operadora**, no tratamento dos dados dos compradores finais e demais titulares vinculados à operação do Cliente, em nome e sob instrução documentada do Cliente (Controlador); e (ii) como **Controladora**, quanto aos dados de cadastro, contato, faturamento e uso dos próprios Usuários Autorizados/colaboradores do Cliente, na medida necessária à gestão da relação e à segurança, conforme a Política de Privacidade.

18.3. **Instruções e finalidades.** A GLOP tratará os dados dos compradores exclusivamente conforme as instruções do Cliente e as finalidades da operação logística (ingestão de pedidos, expedição, pré-postagem, rastreio, notificação, split e emissão fiscal), não os utilizando para finalidades próprias incompatíveis, ressalvado o disposto na Cláusula 20.

18.4. **Direitos dos titulares.** Requisições de titulares recebidas pela GLOP que digam respeito a dados tratados como Operadora serão encaminhadas ao Cliente, a quem compete respondê-las, com o apoio técnico razoável da GLOP, nos termos do DPA.

18.5. **Incidentes.** Incidentes de segurança com dados pessoais seguem o DPA e a LGPD (art. 48), com comunicação sem demora injustificada e cooperação para notificações à ANPD e aos titulares, quando cabível.

18.6. **Transferências internacionais.** Eventuais transferências internacionais decorrentes do uso de Sub-operadores observam as salvaguardas do DPA e da LGPD (arts. 33 a 36).

---

## 19. Propriedade Intelectual e Licenciamento

19.1. **Titularidade da Plataforma.** A Plataforma, seu código-fonte, arquitetura, banco de dados, estruturas, telas, marcas, nome, know-how, documentação e quaisquer melhorias são e permanecem de titularidade exclusiva da GLOP (e/ou de seus licenciadores), sendo concedido ao Cliente apenas o direito de uso da Cláusula 6.

19.2. **Dados do Cliente.** Os **Dados do Cliente** (cadastros, pedidos, PII de compradores, configurações e conteúdos inseridos) são e permanecem de titularidade do Cliente ou dos respectivos titulares. A GLOP não adquire titularidade sobre tais dados, tratando-os conforme este Contrato e o DPA.

19.3. **Customizações e desenvolvimentos específicos.** Salvo disposição diversa em Ordem de Serviço, os desenvolvimentos, customizações, integrações e melhorias produzidos pela GLOP — ainda que sob demanda e custeados pelo Cliente — incorporam-se à Plataforma e permanecem de titularidade da GLOP, ficando o Cliente licenciado a usá-los na forma deste Contrato. Requisitos específicos de exclusividade ou cessão de titularidade dependem de previsão expressa e de contrapartida no Order Form/Ordem de Serviço.

19.4. **Feedback.** Sugestões, ideias e feedback fornecidos pelo Cliente poderão ser livremente utilizados pela GLOP para aprimorar a Plataforma, sem gerar direito de propriedade, remuneração ou exclusividade ao Cliente.

19.5. **Uso de marca.** O uso da marca, nome ou logotipo de uma Parte pela outra (inclusive como caso de sucesso) depende de autorização prévia e por escrito, revogável.

19.6. **Software de terceiros e código aberto.** Componentes de terceiros e de código aberto eventualmente empregados observam suas próprias licenças, prevalecendo estas quanto a tais componentes.

---

## 20. Dados Agregados, Anonimizados e Melhoria do Serviço

20.1. A GLOP poderá gerar e utilizar **dados agregados e anonimizados** (que não permitam a identificação de titulares nem a reidentificação do Cliente ou de compradores) para fins de: (i) operação, segurança e melhoria da Plataforma; (ii) estatísticas, benchmarks e desenvolvimento de funcionalidades, inclusive de IA (LOGIA); e (iii) relatórios de mercado. Dados anonimizados não são dados pessoais para os fins da LGPD (art. 12), observados os cuidados contra reidentificação.

20.2. A GLOP não comercializará dados pessoais do Cliente ou de compradores identificáveis, tampouco os utilizará para finalidades incompatíveis com este Contrato e o DPA.

---

## 21. Garantias, Isenções e Disponibilidade

21.1. **Garantia de serviço.** A GLOP garante que envidará esforços profissionais e diligentes para prestar os serviços conforme este Contrato e os SLAs, mantendo as medidas de segurança da Cláusula 10.

21.2. **Isenções.** Salvo o expressamente pactuado, a Plataforma é fornecida "no estado em que se encontra" (as is) quanto a características não quantificadas, não havendo garantia de que atenderá a toda e qualquer expectativa não especificada, de que operará ininterruptamente além do SLA, ou de resultado comercial do Cliente. A GLOP não garante o funcionamento de Integrações de Terceiros nem de infraestrutura de Sub-operadores fora de seu controle.

21.3. **Ambiente do Cliente.** A GLOP não responde por falhas decorrentes de equipamentos, redes, navegadores, credenciais ou configurações sob controle do Cliente, nem por uso em desacordo com este Contrato.

---

## 22. Responsabilidade Civil e Limitação de Responsabilidade

22.1. **Responsabilidade.** Cada Parte responde pelos danos diretos e comprovados que causar à outra por descumprimento de suas obrigações, na medida de sua culpa, observados os limites desta Cláusula.

22.2. **Exclusão de danos indiretos.** Nenhuma Parte responderá por **lucros cessantes, perda de receita, perda de dados não imputável, perda de oportunidade, danos indiretos, incidentais, especiais ou consequenciais**, ainda que advertida de sua possibilidade, salvo dolo ou culpa grave.

22.3. **Limite global (cap).** Ressalvadas as exceções da Cláusula 22.4, a responsabilidade total agregada da GLOP perante o Cliente, por quaisquer causas relacionadas a este Contrato em cada período de 12 (doze) meses, fica limitada ao **valor total efetivamente pago pelo Cliente à GLOP nos 12 (doze) meses anteriores** ao fato gerador (ou, se a relação for inferior, ao total pago no período).

22.4. **Exceções ao limite.** O limite da Cláusula 22.3 não se aplica a: (i) violação de confidencialidade dolosa; (ii) danos decorrentes de dolo ou culpa grave; (iii) violação de direitos de propriedade intelectual de terceiros imputável à Parte; (iv) sanções aplicadas por autoridade em razão de conduta exclusivamente imputável a uma Parte; e (v) obrigações de indenização da Cláusula 23, observados, nesses casos, os limites da lei.

22.5. **Proteção de dados.** A responsabilidade em matéria de proteção de dados observa a LGPD e a repartição de responsabilidades do DPA, respondendo cada Parte na medida de sua atuação (Controlador/Operador) e de sua culpa.

22.6. **Consumidor.** Perante os compradores/consumidores, o Cliente é o fornecedor da relação de consumo e responde nos termos do CDC, ficando a GLOP como prestadora de ferramenta ao Cliente, sem relação de consumo direta com os compradores, salvo disposição legal em contrário.

---

## 23. Indenização (Hold Harmless)

23.1. **Pelo Cliente.** O Cliente indenizará e manterá a GLOP indene de reclamações de terceiros (inclusive compradores, autoridades e Integrações de Terceiros) decorrentes de: (i) ilicitude, falta de base legal ou inexatidão dos dados que ingressou na Plataforma; (ii) descumprimento de obrigações fiscais, consumeristas ou de entrega perante compradores; (iii) uso da Plataforma em desacordo com este Contrato ou com a lei; (iv) conteúdo, produtos ou práticas comerciais do Cliente.

23.2. **Pela GLOP.** A GLOP indenizará e manterá o Cliente indene de reclamações de terceiros que aleguem que a Plataforma (em sua forma padrão e usada conforme o Contrato) viola direitos de propriedade intelectual de terceiros, cabendo à GLOP, à sua escolha: (i) obter o direito de continuidade de uso; (ii) modificar/substituir a funcionalidade infratora; ou (iii) rescindir a parte afetada, com reembolso proporcional. Excluem-se as reclamações decorrentes de customizações a pedido do Cliente, uso indevido ou combinação com itens de terceiros.

23.3. **Procedimento.** A Parte demandada notificará prontamente a outra, prestará cooperação razoável e não fará acordo que a vincule sem anuência, preservando-se o direito de defesa conjunta.

---

## 24. Prazo, Vigência e Renovação

24.1. **Prazo.** Este Contrato vigora pelo prazo de **[Nº, ex.: 12/24/36] meses**, contados de [DATA DE INÍCIO / do go-live], salvo prazo diverso no Order Form.

24.2. **Renovação automática.** Findo o prazo, o Contrato renova-se automaticamente por períodos iguais e sucessivos, salvo manifestação de não renovação por qualquer Parte, por escrito, com antecedência mínima de **[Nº, ex.: 60/90] dias** do término do período em curso.

24.3. **Reajuste na renovação.** A cada renovação aplicam-se os reajustes da Cláusula 13.4, podendo as Partes revisar escopo e condições comerciais mediante aditivo.

---

## 25. Rescisão, Hipóteses e Efeitos

25.1. **Resilição imotivada.** Qualquer Parte poderá resilir este Contrato sem justa causa, mediante aviso prévio por escrito de **[Nº, ex.: 60/90] dias**, respeitados: (i) o pagamento dos valores devidos até o término; (ii) eventuais compromissos de fidelidade/carência do Order Form; e (iii) a reversibilidade da Cláusula 26.

25.2. **Rescisão por justa causa.** Qualquer Parte poderá rescindir, independentemente de indenização à outra, na hipótese de descumprimento de obrigação material não sanado no prazo de **15 (quinze) dias** contados de notificação escrita, notadamente: (i) inadimplência não regularizada (Cláusula 14); (ii) violação de confidencialidade ou de proteção de dados; (iii) uso ilícito da Plataforma; (iv) descumprimento reiterado de SLA que, mesmo após créditos, torne inviável a operação; (v) violação de propriedade intelectual.

25.3. **Rescisão de pleno direito (independente de notificação).** O Contrato poderá ser rescindido de pleno direito em caso de: (i) decretação de falência, recuperação judicial deferida com risco à continuidade, insolvência ou dissolução de uma Parte; (ii) ordem de autoridade competente que impeça a execução; (iii) prática de ato de fraude, corrupção ou ilícito grave relacionado ao Contrato.

25.4. **Efeitos da rescisão.** Rescindido o Contrato: (i) cessa a licença de uso e o acesso, observado o período de reversibilidade; (ii) tornam-se exigíveis os valores devidos até a data efetiva; (iii) aplicam-se as Cláusulas 26 (reversibilidade), 17 (confidencialidade), 18/DPA (dados), 19 (PI) e 22/23 (responsabilidade/indenização), que sobrevivem ao término no que couber.

25.5. **Multa por rescisão antecipada com carência.** Havendo prazo de carência/fidelidade no Order Form, a resilição antecipada imotivada pelo Cliente sujeita-o à multa/compensação ali prevista, proporcional ao período remanescente, sem prejuízo dos valores já devidos.

---

## 26. Reversibilidade, Portabilidade e Eliminação de Dados

26.1. **Exportação/portabilidade.** No término, e por um período de reversibilidade de **[Nº, ex.: 30] dias** (salvo prazo diverso no Order Form), a GLOP disponibilizará ao Cliente os Dados do Cliente em formato estruturado e interoperável de uso comum (por exemplo, CSV/JSON), e/ou apoiará a migração, conforme a Política de Retenção e o DPA. Serviços extraordinários de migração poderão ser cobrados conforme tabela.

26.2. **Eliminação.** Findo o período de reversibilidade, a GLOP eliminará ou anonimizará os Dados do Cliente sob seu controle, na qualidade de Operadora, ressalvadas as retenções exigidas por lei, por obrigação regulatória ou por rotinas de backup (que seguem seu ciclo natural de descarte), conforme a Política de Descarte e a Política de Backup. A eliminação observa a regra de soft-delete e o subsequente descarte definitivo.

26.3. **Comprovação.** Mediante solicitação, a GLOP fornecerá declaração de eliminação/anonimização dos Dados do Cliente.

26.4. **Continuidade mínima.** Durante a reversibilidade, a GLOP não interromperá abruptamente o acesso essencial à exportação, salvo suspensão legítima por inadimplência ou risco (Cláusulas 14 e 25.3).

---

## 27. Penalidades e Multas Contratuais

27.1. **SLA.** O descumprimento de SLA gera Créditos de Serviço na forma da Cláusula 8, remédio primário, sem prejuízo da rescisão por descumprimento grave e da reparação por danos comprovados nos limites da Cláusula 22.

27.2. **Mora.** A mora no pagamento gera multa de 2%, juros de 1% ao mês e atualização monetária (Cláusula 13.5).

27.3. **Multa por infração a obrigações não pecuniárias relevantes.** A violação de obrigações materiais não pecuniárias — notadamente confidencialidade, proteção de dados, propriedade intelectual e não aliciamento — sujeita a Parte infratora, além da reparação por perdas e danos comprovados, à multa de **[Nº, ex.: 10 a 20]% do valor anual do Contrato** por evento, sem prejuízo da rescisão por justa causa.

27.4. **Não cumulação indevida.** As multas não se acumulam sobre o mesmo fato de forma a configurar bis in idem; a multa moratória e a compensatória por rescisão têm naturezas distintas e podem coexistir quando cabível.

27.5. **Perdas e danos.** As multas previstas não impedem a cobrança de perdas e danos que as excedam, quando comprovados e observados os limites da Cláusula 22, salvo nas hipóteses excepcionadas na Cláusula 22.4.

---

## 28. Força Maior e Caso Fortuito

28.1. Nenhuma Parte responderá por descumprimento decorrente de força maior ou caso fortuito (Código Civil, art. 393), incluindo, exemplificativamente: catástrofes, pandemias, falhas generalizadas de telecomunicações ou energia, ataques cibernéticos de larga escala não evitáveis com diligência razoável, atos de autoridade e indisponibilidades impostas por Sub-operadores/Integrações de Terceiros fora de controle.

28.2. A Parte afetada comunicará o evento e seus efeitos tão logo possível e envidará esforços para mitigar impactos e restabelecer a normalidade. Persistindo o evento por prazo superior a **[Nº, ex.: 30] dias** consecutivos com inviabilização do objeto, qualquer Parte poderá rescindir sem penalidade, com acerto proporcional.

---

## 29. Não Solicitação e Não Aliciamento

29.1. Durante a vigência e por **12 (doze) meses** após o término, nenhuma Parte, direta ou indiretamente, aliciará ou contratará colaborador-chave da outra envolvido na execução deste Contrato, salvo consentimento escrito, ressalvadas contratações decorrentes de processos seletivos públicos e amplos não direcionados. A violação sujeita a Parte infratora à multa da Cláusula 27.3.

---

## 30. Cessão, Subcontratação e Sucessão

30.1. **Cessão.** O Cliente não poderá ceder este Contrato sem anuência prévia e escrita da GLOP. A GLOP poderá ceder o Contrato a empresa de seu grupo econômico ou em razão de reorganização societária, mediante comunicação, preservados os direitos do Cliente.

30.2. **Subcontratação.** A GLOP poderá subcontratar terceiros e Sub-operadores para a execução dos serviços, permanecendo responsável perante o Cliente na forma deste Contrato e do DPA quanto a sub-operadores de dados.

30.3. **Sucessão.** O Contrato obriga as Partes e seus sucessores a qualquer título.

---

## 31. Comunicações e Notificações

31.1. As comunicações contratuais entre as Partes serão feitas por escrito, aos endereços e e-mails indicados no preâmbulo/Order Form, admitido o e-mail com confirmação de recebimento e as ferramentas oficiais de suporte para comunicações operacionais.

31.2. Notificações relativas a rescisão, descumprimento e proteção de dados serão feitas por meio que comprove o recebimento (e-mail com confirmação, carta, notificação eletrônica ou cartório). Alterações de endereço/contato devem ser comunicadas em até 5 (cinco) Dias Úteis.

31.3. Comunicações em matéria de proteção de dados poderão ser dirigidas ao DPO da GLOP: a ser designado pela administração — lemoncapsencapsulados@gmail.com.

---

## 32. Anticorrupção, Compliance e Sanções

32.1. As Partes declaram cumprir a legislação anticorrupção aplicável (Lei nº 12.846/2013 e correlatas) e obrigam-se a não oferecer, prometer ou receber vantagem indevida no âmbito deste Contrato.

32.2. As Partes obrigam-se a observar a legislação de proteção de dados, defesa do consumidor, propriedade intelectual, trabalhista e de sanções aplicáveis, mantendo, cada uma, seus programas de integridade compatíveis com seu porte.

32.3. A violação comprovada de obrigação anticorrupção ou de compliance por uma Parte autoriza a rescisão por justa causa pela outra, sem prejuízo das perdas e danos.

---

## 33. Disposições Gerais

33.1. **Independência das Partes.** Este Contrato não cria vínculo societário, associativo, trabalhista, de consórcio ou de mandato entre as Partes, que atuam de forma autônoma e independente.

33.2. **Não exclusividade.** Salvo disposição expressa no Order Form, não há exclusividade entre as Partes.

33.3. **Novação e tolerância.** A tolerância quanto a qualquer descumprimento não implica novação, renúncia ou alteração do pactuado.

33.4. **Independência das cláusulas.** A nulidade ou ineficácia de qualquer cláusula não prejudica as demais, que permanecem válidas, comprometendo-se as Partes a substituir a cláusula afetada por outra de efeito equivalente e válido.

33.5. **Integralidade.** Este Contrato, seus Anexos e documentos integrantes constituem o acordo integral entre as Partes quanto ao objeto, substituindo entendimentos anteriores.

33.6. **Alterações.** Alterações a este Contrato somente valem por aditivo escrito assinado por ambas as Partes, ressalvadas as atualizações de Políticas admitidas nos respectivos instrumentos.

33.7. **Assinatura eletrônica.** As Partes reconhecem a validade da assinatura eletrônica/digital deste Contrato e de seus aditivos, nos termos da legislação aplicável (inclusive MP 2.200-2/2001 e Lei nº 14.063/2020, quando cabíveis).

33.8. **Contagem de prazos.** Salvo indicação diversa, os prazos em dias contam-se em dias corridos, excluído o dia do começo e incluído o do vencimento; prazos em "Dias Úteis" observam a definição da Cláusula 1.

---

## 34. Lei Aplicável e Foro

34.1. Este Contrato é regido e interpretado conforme as leis da **República Federativa do Brasil**.

34.2. As Partes elegem o **foro da Comarca de Comarca de Cuiabá/MT** para dirimir controvérsias oriundas deste Contrato, com renúncia a qualquer outro, por mais privilegiado que seja, ressalvada a faculdade de as Partes preverem, em aditivo, cláusula compromissória de arbitragem.

34.3. **Resolução amigável.** As Partes buscarão resolver amigavelmente, por seus interlocutores e Gerente de Conta, eventuais divergências, no prazo de 30 (trinta) dias, antes de recorrer às vias judiciais, sem que isso obste medidas urgentes.

---

## 35. Engenharia Jurídica & Governança

### 35.1. Fundamentação das cláusulas (lei/norma que embasa)

| Tema / Cláusula | Fundamento legal e normativo |
|---|---|
| Formação e validade do contrato | Código Civil (Lei nº 10.406/2002), arts. 104, 421-425 (função social e liberdade contratual) |
| Licença de software / SaaS | Lei de Software (Lei nº 9.609/1998); Lei de Direitos Autorais (Lei nº 9.610/1998) |
| Propriedade intelectual (Cláusulas 19 e 23.2) | Lei nº 9.609/1998, Lei nº 9.610/1998, Lei nº 9.279/1996 (marcas) |
| Proteção de dados (Cláusulas 18, 26; DPA) | LGPD (Lei nº 13.709/2018), arts. 5º, 6º, 7º, 37, 39, 46-49; GDPR (art. 28) quando aplicável |
| Relação de consumo com o comprador (Cláusula 22.6) | CDC (Lei nº 8.078/1990); a GLOP presta ferramenta ao Cliente, que é o fornecedor |
| Marco Civil / logs / guarda | Lei nº 12.965/2014 (Marco Civil da Internet) |
| SLA, obrigação de meio/resultado (Cláusulas 2 e 8) | Código Civil, arts. 389-393 (inadimplemento, mora, caso fortuito) |
| Mora, juros e multa (Cláusulas 13, 27) | Código Civil, arts. 394-395, 406-407, 408-416 (cláusula penal) |
| Limitação de responsabilidade (Cláusula 22) | Código Civil, arts. 393, 402-405; validade entre empresários (relação B2B) |
| Confidencialidade / segredo de negócio (Cláusula 17) | Lei nº 9.279/1996 (concorrência desleal); dever de boa-fé (CC art. 422) |
| Segurança da informação (Cláusula 10) | LGPD art. 46-49; boas práticas ISO/IEC 27001, 27701, 22301, 31000, NIST, OWASP |
| Auditoria (Cláusula 11) | LGPD art. 39 (verificação); boas práticas de governança |
| Anticorrupção (Cláusula 32) | Lei nº 12.846/2013 |
| Assinatura eletrônica (Cláusula 33.7) | MP 2.200-2/2001; Lei nº 14.063/2020 |
| Foro / arbitragem (Cláusula 34) | CPC (Lei nº 13.105/2015); Lei de Arbitragem (Lei nº 9.307/1996) |
| Força maior (Cláusula 28) | Código Civil, art. 393 |

### 35.2. Riscos mitigados

- **Indefinição de escopo enterprise:** mitigado por Order Form, Plano de Onboarding e aceite por marcos (Cláusulas 4 e 5).
- **Indisponibilidade e falha de serviço:** mitigado por SLA com Uptime Garantido, tempos de resposta/resolução por severidade e Créditos de Serviço (Cláusula 8).
- **Dependência de terceiros (gateways, Correios, VHSYS, Supabase, Netlify):** isenção e regime de sub-operadores/credenciais write-only (Cláusulas 7 e 21).
- **Vazamento/uso indevido de PII de compradores:** remissão ao DPA, dupla natureza Operador/Controlador, incidentes conforme LGPD (Cláusulas 10, 18).
- **Perda de dados no encerramento / lock-in:** reversibilidade, portabilidade e eliminação comprovada (Cláusula 26).
- **Inadimplência:** suspensão gradual com preservação de dados e encargos (Cláusulas 13-14).
- **Responsabilidade ilimitada:** cap de responsabilidade e exclusão de danos indiretos com exceções legais (Cláusula 22).
- **Confusão de responsabilidade consumerista/fiscal:** alocação clara ao Cliente (Cláusulas 2, 15, 22.6, 23.1).
- **Apropriação indevida de PI / código:** titularidade da GLOP e regime de customizações (Cláusula 19).
- **Aliciamento de equipe-chave:** não solicitação com multa (Cláusula 29).
- **Descontinuidade abrupta de funcionalidades/API:** política de depreciação com aviso prévio (Cláusula 12.4).
- **Litígios:** tentativa de solução amigável e foro/arbitragem definidos (Cláusula 34).

### 35.3. Checklist de implementação

- [ ] Preencher todos os placeholders entre colchetes (razão social, CNPJ, endereço, DPO, datas, índices, prazos, percentuais).
- [ ] Anexar e assinar o Order Form (Anexo I) com módulos, volumetria, preços e SLA aplicável.
- [ ] Anexar o Plano de Onboarding (Anexo II) com cronograma, marcos e matriz de escalonamento nominal.
- [ ] Celebrar/anexar o DPA (Anexo IV) e conferir a lista de sub-operadores (Anexo V).
- [ ] Definir Uptime Garantido, tempos por severidade e faixas de Créditos de Serviço no SLA.
- [ ] Definir índice de reajuste, periodicidade de faturamento, prazo, carência e avisos de renovação/rescisão.
- [ ] Designar Gerente de Conta e cadência de QBR.
- [ ] Validar cláusulas de limitação de responsabilidade e multas com o jurídico (adequação B2B).
- [ ] Revisar conformidade com LGPD, CDC e Marco Civil junto ao DPO.
- [ ] Colher assinaturas (eletrônicas) das partes e testemunhas, se aplicável.

### 35.4. Matriz RACI

Legenda: **R** = Responsável por executar · **A** = Aprova/presta contas · **C** = Consultado · **I** = Informado.

| Atividade / Entregável | GLOP (Fornecedora) | Cliente (Contratante) | Gerente de Conta | DPO GLOP |
|---|---|---|---|---|
| Definição de escopo (Order Form) | C | A | R | I |
| Onboarding e implantação | R | A | C | I |
| Provisionamento do Ambiente (RLS/RBAC) | R | C | I | I |
| Conexão de Integrações e credenciais | R | A | C | I |
| Definição de finalidades/base legal (dados de compradores) | I | R/A | I | C |
| Cumprimento do SLA e Créditos de Serviço | R | I | A | I |
| Suporte e escalonamento de incidentes | R | C | A | I |
| Segurança da informação | R | C | I | C |
| Resposta a incidente com dados pessoais | R | C | I | A |
| Direitos dos titulares (compradores) | C | R/A | I | C |
| Auditoria de conformidade | C | R | I | A |
| Faturamento e pagamento | R | A | I | I |
| Roadmap e change requests | R | C | A | I |
| Reversibilidade e eliminação de dados | R | A | C | C |
| Renovação / rescisão | C | A | R | I |

### 35.5. Plano de revisão

- **Periodicidade ordinária:** revisão contratual a cada **12 (doze) meses**, alinhada às QBRs.
- **Gatilhos extraordinários:** alteração legislativa relevante (LGPD/ANPD, CDC, tributário); mudança de sub-operador ou de infraestrutura; incidente de segurança relevante; alteração material de escopo/volumetria; fusão/aquisição de qualquer das Partes; recomendação de auditoria.
- **Responsável:** Gerente de Conta (coordenação) com Jurídico e DPO (validação).
- **Registro:** toda revisão gera nova versão no controle da Cláusula 35.6 e, quando material, aditivo assinado.

### 35.6. Controle de versão

| Versão | Data | Autor/Responsável | Alterações |
|---|---|---|---|
| 1.0 | 16 de julho de 2026 | [ÁREA JURÍDICA / DPO] | Emissão inicial da minuta do Contrato Enterprise (SaaS) do GLOP |
| [1.1] | 16 de julho de 2026 | [RESPONSÁVEL] | [Descrever alterações] |
| [2.0] | 16 de julho de 2026 | [RESPONSÁVEL] | [Revisão material / aditivo] |

---

**E, por estarem assim justas e contratadas, as Partes firmam o presente Contrato Enterprise, por meio eletrônico, obrigando-se por si e seus sucessores.**

[LOCAL], 16 de julho de 2026.

**FORNECEDORA / CONTRATADA**
LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA — [NOME FANTASIA: GLOP]
CNPJ: 55.836.075/0001-07
Representante: __________________________________

**CLIENTE / CONTRATANTE**
[CONTRATANTE — RAZÃO SOCIAL]
CNPJ: [CNPJ DO CONTRATANTE]
Representante: __________________________________

**Testemunhas:**
1. Nome: ____________________ — CPF: [CPF]
2. Nome: ____________________ — CPF: [CPF]

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.
