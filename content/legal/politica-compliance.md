> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# POLÍTICA DE COMPLIANCE E INTEGRIDADE — GLOP (Global Logistics Platform)

**Documento:** Política Corporativa de Compliance, Integridade e Ética Empresarial
**Controladora / Editora:** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, inscrita no CNPJ sob o nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, operadora da plataforma [NOME FANTASIA: GLOP]
**Classificação da informação:** Interno — de observância obrigatória por todos os destinatários
**Aprovação:** [ÓRGÃO/PESSOA APROVADORA] em 16 de julho de 2026
**Vigência:** a partir de 16 de julho de 2026
**Versão:** 1.0
**Responsável pela guarda e atualização:** Comitê de Compliance / Encarregado de Compliance (a ser designado pela administração)

---

## Sumário

1. Objetivo
2. Definições e Glossário
3. Escopo e Destinatários
4. Fundamentos Legais e Normativos
5. Princípios e Valores de Integridade
6. Estrutura de Governança de Compliance
7. Programa de Integridade (Lei nº 12.846/2013 e Decreto nº 11.129/2022)
8. Avaliação e Gestão de Riscos de Integridade
9. Prevenção à Corrupção, Suborno e Fraude
10. Relações com Agentes Públicos e Poder Público
11. Brindes, Presentes, Hospitalidades, Patrocínios e Doações
12. Conflito de Interesses
13. Due Diligence de Terceiros (Sub-operadores, Parceiros e Fornecedores)
14. Prevenção à Lavagem de Dinheiro e ao Financiamento do Terrorismo (PLD/FT) e COAF
15. Compliance Concorrencial (CADE)
16. Compliance de Proteção de Dados (LGPD) — Interface com o DPO
17. Compliance Setorial: Logística, Marketplace, Consumidor e Fiscal
18. Canal de Denúncias e Não Retaliação
19. Investigações Internas e Medidas Disciplinares
20. Controles Internos, Livros e Registros Contábeis
21. Monitoramento, Auditoria e Testes de Efetividade
22. Treinamento, Comunicação e Cultura de Integridade
23. Sanções e Consequências pelo Descumprimento
24. Gestão de Terceiros e Cláusulas Contratuais de Integridade
25. Papéis e Responsabilidades
26. Vigência, Revisão e Disposições Gerais
27. Termo de Ciência e Adesão
28. Engenharia Jurídica & Governança

---

## 1. Objetivo

1.1. Esta Política de Compliance e Integridade ("Política") tem por objetivo estabelecer os princípios, diretrizes, controles, papéis e responsabilidades que compõem o Programa de Integridade de LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA ("Empresa" ou "GLOP"), operadora da plataforma [NOME FANTASIA: GLOP] — Software as a Service (SaaS) de logística e ERP voltado a operações de dropshipping e comercialização de infoprodutos no Brasil.

1.2. A Política visa a:

- **a)** prevenir, detectar e remediar atos de corrupção, suborno, fraude, lavagem de dinheiro, financiamento do terrorismo, conflitos de interesse e demais ilícitos contra a Administração Pública e o setor privado;
- **b)** assegurar a conformidade com a Lei nº 12.846/2013 (Lei Anticorrupção), o Decreto nº 11.129/2022, a Lei nº 9.613/1998 (PLD/FT), a Lei nº 12.529/2011 (Defesa da Concorrência), a Lei nº 13.709/2018 (LGPD) e a Lei nº 8.078/1990 (CDC), no que couber à operação do GLOP;
- **c)** proteger a integridade dos dados pessoais de compradores tratados na plataforma (nome, CPF/CNPJ, e-mail, telefone, endereço, produto e valor), reforçando os controles técnicos já existentes (RLS multi-tenant, RBAC, soft-delete, trilha de auditoria e credenciais de API write-only);
- **d)** disseminar cultura de ética, transparência e responsabilidade entre sócios, administradores, colaboradores e terceiros;
- **e)** demonstrar o comprometimento da alta direção com a integridade ("tone at the top"), servindo de parâmetro objetivo de conduta e de eventual mitigação de responsabilidade nos termos da lei.

1.3. Esta Política integra o arcabouço documental de governança do GLOP e deve ser lida de forma harmônica com o Código de Ética e Conduta, a Política de Privacidade e Proteção de Dados, o Acordo de Tratamento de Dados (DPA), a Política de Segurança da Informação, os Termos de Uso e demais normativos internos.

---

## 2. Definições e Glossário

Para fins desta Política, aplicam-se as seguintes definições:

- **Programa de Integridade:** conjunto de mecanismos e procedimentos internos de integridade, auditoria, aplicação de códigos de ética e incentivo à denúncia de irregularidades, com aplicação efetiva no dia a dia da Empresa, nos termos do art. 41 do Decreto nº 11.129/2022.
- **Alta Direção:** sócios, administradores, diretoria e órgãos equivalentes de comando estratégico da Empresa.
- **Colaborador:** qualquer pessoa que mantenha vínculo de trabalho, estágio, aprendizagem ou prestação de serviço pessoal e habitual com a Empresa.
- **Terceiro:** pessoa física ou jurídica que atue em nome, em benefício ou no interesse da Empresa, incluindo sub-operadores, fornecedores, prestadores, parceiros de integração, coprodutores, afiliados, representantes, consultores e intermediários.
- **Sub-operadores:** terceiros que tratam dados pessoais ou executam funções operacionais críticas por conta do GLOP, tais como Supabase e Netlify (infraestrutura/hospedagem SSR e banco), VHSYS (emissão de NF-e), Correios (transporte, pré-postagem PPN e rastreio SRO), gateways de pagamento (Monetizze, AppMax, Hotmart, Kiwify) e provedores de mensageria (WhatsApp/e-mail).
- **Agente Público:** quem exerce, ainda que transitoriamente ou sem remuneração, cargo, emprego ou função pública, em qualquer esfera ou Poder, bem como agentes de empresas estatais e de organismos internacionais.
- **Vantagem Indevida:** qualquer bem, benefício, valor, favor, serviço, brinde desproporcional, promessa ou outra utilidade oferecida, prometida ou entregue com o propósito de influenciar ato ou decisão.
- **Ato Lesivo:** condutas descritas no art. 5º da Lei nº 12.846/2013 praticadas contra a Administração Pública nacional ou estrangeira.
- **PLD/FT:** Prevenção à Lavagem de Dinheiro e ao Financiamento do Terrorismo.
- **COAF:** Conselho de Controle de Atividades Financeiras, unidade de inteligência financeira do Brasil.
- **PEP (Pessoa Exposta Politicamente):** conforme definição da regulamentação de PLD/FT aplicável.
- **Due Diligence de Integridade:** procedimento de avaliação prévia e periódica de idoneidade e riscos de terceiros.
- **Red Flags:** sinais de alerta indicativos de risco de irregularidade.
- **Canal de Denúncias:** mecanismo seguro e confidencial para reporte de suspeitas de violação.
- **DPO / Encarregado:** a ser designado pela administração, responsável pelo tratamento de dados pessoais, contato lemoncapsencapsulados@gmail.com.
- **Controlador / Operador:** conforme art. 5º, VI e VII, da LGPD. O GLOP atua com **dupla natureza**: como **Operador** ao tratar dados de compradores em nome do produtor/lojista (Controlador), e como **Controlador** ao tratar dados de seus próprios usuários e colaboradores.

---

## 3. Escopo e Destinatários

3.1. Esta Política aplica-se, de forma integral e sem exceção, a:

- **a)** sócios, acionistas, administradores e membros da Alta Direção;
- **b)** todos os Colaboradores, em qualquer nível hierárquico, unidade ou modalidade de contratação;
- **c)** estagiários, aprendizes, trainees e voluntários;
- **d)** Terceiros que atuem em nome ou benefício da Empresa, na medida das obrigações contratuais de integridade a eles estendidas (Seção 24).

3.2. **Abrangência material.** A Política alcança todas as atividades, processos e fluxos operacionais do GLOP, incluindo, sem limitação:

- ingestão de pedidos via API de gateways (Monetizze, Hotmart, Kiwify) e de e-commerces/marketplaces (Shopify, WooCommerce, Nuvemshop, Mercado Livre), com tratamento de PII do comprador;
- integração logística com os Correios (pré-postagem PPN, rastreio SRO e notificação ao comprador por e-mail/WhatsApp);
- coprodução, afiliação e **split** de pagamentos (via AppMax), incluindo apuração de comissões, repasses e dados de PIX/bancários;
- emissão de documentos fiscais/NF-e via VHSYS;
- disponibilização do portal público de rastreio (sem login, com exposição de status neutro).

3.3. **Abrangência territorial.** Aplica-se às operações realizadas no território nacional e, no que couber, a relações com contrapartes ou plataformas estrangeiras, observadas as leis anticorrupção com efeito extraterritorial que venham a incidir.

3.4. O desconhecimento desta Política não escusa seu descumprimento. Todos os destinatários firmarão o Termo de Ciência e Adesão (Seção 27).

---

## 4. Fundamentos Legais e Normativos

4.1. Esta Política observa, no que aplicável, o seguinte arcabouço:

- **Lei nº 12.846/2013** (Lei Anticorrupção Empresarial) e **Decreto nº 11.129/2022** (regulamento, com parâmetros de Programa de Integridade — art. 57);
- **Lei nº 8.429/1992** (Improbidade Administrativa);
- **Decreto-Lei nº 2.848/1940** (Código Penal — crimes contra a Administração Pública, corrupção ativa, tráfico de influência);
- **Lei nº 9.613/1998** (Lavagem de Dinheiro) e regulamentação do **COAF**;
- **Lei nº 13.260/2016** (Financiamento do Terrorismo) e **Lei nº 13.810/2019** (indisponibilidade de ativos — sanções ONU);
- **Lei nº 12.529/2011** (Sistema Brasileiro de Defesa da Concorrência — CADE);
- **Lei nº 13.709/2018** (LGPD) e regulamentos da **ANPD**;
- **Lei nº 8.078/1990** (Código de Defesa do Consumidor) e **Decreto nº 7.962/2013** (e-commerce);
- **Lei nº 12.965/2014** (Marco Civil da Internet) e **Decreto nº 8.771/2016**;
- **Lei nº 14.478/2022** (ativos virtuais), quando aplicável a fluxos de pagamento;
- normas fiscais e de emissão de documentos eletrônicos (NF-e) pertinentes à intermediação via VHSYS;
- padrões internacionais de referência: **ISO 37001** (antissuborno), **ISO 37301** (compliance), **ISO 31000** (gestão de riscos), **ISO/IEC 27001, 27701, 22301** (segurança da informação, privacidade e continuidade), **NIST** e **OWASP**, e, quando houver contraparte ou tratamento sujeito, o **GDPR** e a **U.S. FCPA / UK Bribery Act**.

4.2. Em caso de conflito entre esta Política e norma legal cogente, prevalece a lei. Havendo padrão interno mais rigoroso que a lei, prevalece o padrão interno.

---

## 5. Princípios e Valores de Integridade

5.1. O GLOP pauta sua atuação pelos seguintes princípios:

1. **Tolerância zero à corrupção e à fraude** — nenhuma meta de negócio justifica ato ilícito.
2. **Legalidade e conformidade** — cumprir a lei e os compromissos regulatórios em todas as jurisdições de atuação.
3. **Transparência e prestação de contas** — registros fidedignos, rastreáveis e auditáveis (reforçados pela trilha de auditoria por triggers e colunas de auditoria em todo registro).
4. **Proteção de dados e privacidade desde a concepção** — privacy by design e by default, com minimização e segregação por empresa (RLS multi-tenant).
5. **Isonomia e livre concorrência** — competição leal, sem cartel, conluio ou abuso.
6. **Responsabilidade da alta direção** — comprometimento visível e contínuo com a integridade.
7. **Confidencialidade e não retaliação** — proteção de quem reporta de boa-fé.
8. **Melhoria contínua** — o Programa é dinâmico e evolui conforme riscos e aprendizados.

---

## 6. Estrutura de Governança de Compliance

6.1. **Modelo de linhas de defesa.** O GLOP adota o modelo de três linhas:

- **1ª linha — Gestores e áreas operacionais:** responsáveis por executar controles no dia a dia (integrações, logística, financeiro/split, fiscal, atendimento).
- **2ª linha — Compliance, Riscos e DPO:** define políticas, monitora, orienta e supervisiona a efetividade dos controles.
- **3ª linha — Auditoria Interna/Independente:** avalia, de forma isenta, a adequação e efetividade do Programa.

6.2. **Encarregado de Compliance / Comitê de Compliance.** A Empresa designa Encarregado de Compliance (ou Comitê, em colegiado) com **autonomia, independência, autoridade e recursos** adequados, com acesso direto e reporte à Alta Direção, nos termos do art. 57, II e III, do Decreto nº 11.129/2022. Enquanto não instituído Comitê formal, as atribuições concentram-se no Encarregado de Compliance designado por [ÓRGÃO/PESSOA APROVADORA].

6.3. **Independência.** O responsável por Compliance não pode ocupar posição que gere conflito com sua função de supervisão e não pode ser subordinado às áreas que fiscaliza.

6.4. **Interfaces.** Compliance atua de forma integrada com o DPO (a ser designado pela administração), com a área de Segurança da Informação, Jurídico, Financeiro e Recursos Humanos, respeitadas as competências de cada função.

---

## 7. Programa de Integridade (Lei nº 12.846/2013 e Decreto nº 11.129/2022)

7.1. O Programa de Integridade do GLOP estrutura-se sobre os **parâmetros do art. 57 do Decreto nº 11.129/2022**, adaptados ao porte, ao risco e às particularidades de um SaaS de logística que atua como Operador e Controlador de dados. São seus pilares:

1. comprometimento e apoio inequívoco da Alta Direção;
2. padrões de conduta, código de ética e políticas aplicáveis a todos, inclusive terceiros;
3. treinamentos e comunicações periódicas;
4. gestão adequada de riscos, com avaliação e revisão periódica;
5. registros contábeis e controles internos que assegurem confiabilidade dos relatórios;
6. procedimentos específicos de prevenção a fraudes e ilícitos em licitações, contratos e interações com o setor público (quando houver);
7. independência, estrutura e autoridade da instância de compliance;
8. canais de denúncia acessíveis, com proteção ao denunciante de boa-fé;
9. medidas disciplinares em caso de violação;
10. procedimentos de interrupção de irregularidades e remediação tempestiva;
11. due diligence para contratação e supervisão de terceiros;
12. verificação de integridade em reorganizações societárias (M&A), quando aplicável;
13. monitoramento contínuo e aperfeiçoamento do Programa;
14. transparência quanto a doações a candidatos e partidos, se houver.

7.2. **Proporcionalidade.** A extensão de cada mecanismo é calibrada conforme o perfil de risco do GLOP, priorizando as áreas de maior exposição: pagamentos/split, integrações de dados de terceiros e tratamento de PII de compradores.

7.3. **Efetividade real.** O Programa não é meramente formal ("programa de papel"): sua aplicação é evidenciada por logs, trilhas de auditoria, registros de treinamento, atas, relatórios de monitoramento e histórico do canal de denúncias.

---

## 8. Avaliação e Gestão de Riscos de Integridade

8.1. **Metodologia (ISO 31000).** A Empresa mantém processo estruturado de identificação, análise, avaliação, tratamento, monitoramento e comunicação de riscos de integridade, revisado, no mínimo, anualmente ou em caso de mudança relevante de negócio, tecnologia ou regulação.

8.2. **Riscos inerentes ao GLOP mapeados (rol exemplificativo):**

| Categoria | Descrição do risco | Fluxo/ativo afetado | Nível |
|---|---|---|---|
| Corrupção/suborno | Vantagem indevida a agente público (fiscal, regulatório, aduaneiro) para facilitar operação | Interações com órgãos, tributos, NF-e | Médio |
| Fraude financeira | Manipulação de split, comissões e repasses; desvio via PIX/dados bancários | Coprodução, afiliados, split AppMax | Alto |
| PLD/FT | Uso da plataforma para ocultar origem de recursos via pedidos/pagamentos | Ingestão de pedidos, gateways | Médio/Alto |
| Proteção de dados | Vazamento/uso indevido de PII de compradores (CPF, endereço, telefone) | APIs de ingestão, banco, portal de rastreio | Alto |
| Concorrencial | Troca de informação sensível com concorrentes; conluio | Relações comerciais | Baixo/Médio |
| Consumerista | Publicidade enganosa, cobrança indevida, falha de rastreio | Portal público, notificações | Médio |
| Terceiros | Sub-operador sem idoneidade ou sem conformidade de segurança | Supabase, Netlify, VHSYS, Correios, gateways | Médio |

8.3. **Tratamento.** Para cada risco relevante, define-se resposta (evitar, mitigar, transferir ou aceitar), controle associado, responsável (owner) e prazo. Riscos residuais altos exigem aprovação da Alta Direção.

8.4. **Matriz de risco documentada.** O resultado é consolidado em Matriz de Riscos de Integridade, mantida sob guarda de Compliance e submetida à Alta Direção.

---

## 9. Prevenção à Corrupção, Suborno e Fraude

9.1. **Vedação absoluta.** É terminantemente proibido oferecer, prometer, autorizar, entregar, solicitar ou receber, direta ou indiretamente, qualquer Vantagem Indevida a Agente Público ou a particular, com o fim de obter ou manter negócio ou vantagem imprópria.

9.2. **Pagamentos de facilitação ("graxa").** São proibidos, ainda que de pequeno valor e ainda que usuais no mercado.

9.3. **Intermediários.** É vedado usar terceiros (consultores, despachantes, representantes) para praticar, por interposta pessoa, ato vedado a Colaborador. A contratação de intermediários exige due diligence (Seção 13) e contrato com cláusula de integridade.

9.4. **Fraude interna.** São proibidos: desvio de recursos, manipulação de repasses/split, criação de coprodutores/afiliados fictícios, alteração indevida de comissões, adulteração de registros fiscais/NF-e e falsificação de documentos. Os controles técnicos do GLOP — RBAC (has_permission), segregação por empresa (RLS), soft-delete e trilha de auditoria por triggers — funcionam como salvaguardas de detecção e devem ser preservados e monitorados.

9.5. **Segregação de funções.** Operações sensíveis de pagamento, cadastro de dados bancários/PIX e configuração de split observam segregação de funções e dupla checagem, vedada a concentração de aprovação e execução na mesma pessoa.

---

## 10. Relações com Agentes Públicos e Poder Público

10.1. Toda interação com Agente Público (fiscalizações, exigências regulatórias, tributárias, aduaneiras ou de proteção de dados) deve ser conduzida com transparência, formalidade e registro documental.

10.2. É proibido oferecer qualquer vantagem para acelerar, obter ou evitar ato de ofício.

10.3. **Licitações e contratos públicos.** Caso o GLOP venha a participar de contratações públicas, aplicam-se controles reforçados de prevenção a fraude em licitações (art. 5º, IV, da Lei nº 12.846/2013), incluindo vedação a conluio, frustração do caráter competitivo e obtenção de vantagem indevida em contratos.

10.4. **Registro de contatos.** Reuniões e comunicações relevantes com autoridades devem ser registradas e, quando exigível, comunicadas ao Compliance.

---

## 11. Brindes, Presentes, Hospitalidades, Patrocínios e Doações

11.1. **Regra geral.** Brindes e hospitalidades só são admitidos quando: (a) de valor modesto e razoável; (b) sem intenção de influenciar decisão; (c) esporádicos; (d) transparentes e registráveis; (e) não vedados pela política da contraparte.

11.2. **Limites.** Fica estabelecido limite de valor de referência de [VALOR-LIMITE R$] por brinde/hospitalidade. Acima do limite, exige-se aprovação prévia e registro pelo Compliance.

11.3. **Vedações.** É proibido, em qualquer valor: dinheiro ou equivalente (cartões, PIX, criptoativos); presente durante processo decisório, licitação ou fiscalização em curso; e presente a Agente Público quando a lei o vedar.

11.4. **Patrocínios e doações.** Só podem ocorrer de forma transparente, com contraparte idônea (due diligence), finalidade legítima, documentação formal e sem contrapartida indevida. **Doações político-partidárias** somente se e quando permitidas por lei e com aprovação da Alta Direção e registro contábil transparente.

---

## 12. Conflito de Interesses

12.1. Configura conflito de interesses a situação em que interesses pessoais, familiares ou financeiros de um destinatário possam influenciar, ou aparentar influenciar, sua atuação em nome da Empresa.

12.2. **Exemplos:** contratar como sub-operador, coprodutor, afiliado ou fornecedor pessoa ligada a Colaborador; participação societária em concorrente, gateway ou parceiro; favorecimento na definição de comissões/split a parte relacionada.

12.3. **Dever de divulgação.** Todo conflito, real ou potencial, deve ser comunicado imediatamente ao Compliance, que definirá medidas de mitigação (abstenção, realocação, aprovação por instância superior).

12.4. É vedado ao Colaborador em conflito participar da decisão correspondente.

---

## 13. Due Diligence de Terceiros (Sub-operadores, Parceiros e Fornecedores)

13.1. **Princípio.** A Empresa responde, no âmbito de seu Programa, pela idoneidade dos Terceiros que atuam em seu nome ou benefício. Nenhum Terceiro relevante é contratado sem due diligence de integridade prévia, proporcional ao risco.

13.2. **Escopo obrigatório.** Sub-operadores e parceiros críticos — **Supabase, Netlify, VHSYS, Correios, Monetizze, AppMax, Hotmart, Kiwify, provedores de WhatsApp/e-mail** — e coprodutores/afiliados com repasse financeiro estão sujeitos a avaliação.

13.3. **Níveis de due diligence:**

- **Nível 1 (básico) — baixo risco:** identificação, situação cadastral (CNPJ/CPF), verificação de regularidade e listas restritivas públicas.
- **Nível 2 (intermediário) — risco moderado:** Nível 1 + verificação de sanções, processos relevantes, reputação, mídia adversa e conformidade de proteção de dados/segurança.
- **Nível 3 (aprofundado) — alto risco / manejo de dados de pagamento ou grande volume de PII:** Nível 2 + análise de estrutura societária, beneficiários finais, PEP, avaliação de controles de segurança (ISO 27001/27701), cláusulas contratuais reforçadas e, para sub-operadores de dados, celebração de DPA.

13.4. **Red flags que exigem aprofundamento ou reprovação:**

- recusa em firmar cláusulas de integridade ou DPA;
- estrutura societária opaca ou beneficiário final oculto;
- histórico de corrupção, fraude, sanção regulatória ou vazamento de dados;
- solicitação de pagamentos atípicos, em jurisdição de risco ou a terceiro não relacionado;
- ausência de capacidade técnica ou de conformidade de segurança compatível.

13.5. **Contratação condicionada.** A contratação de sub-operadores que tratem dados pessoais de compradores exige a existência de **DPA** e de garantias de segurança compatíveis com a LGPD e com a Política de Segurança da Informação. Remete-se ao Acordo de Tratamento de Dados (DPA) e à Política de Privacidade para o detalhamento das obrigações de proteção de dados.

13.6. **Monitoramento contínuo.** A idoneidade dos Terceiros é reavaliada periodicamente (Nível 3: anual; demais: conforme risco) e sempre que houver red flag superveniente. O descumprimento por Terceiro autoriza suspensão/rescisão (Seções 23 e 24).

---

## 14. Prevenção à Lavagem de Dinheiro e ao Financiamento do Terrorismo (PLD/FT) e COAF

14.1. **Aplicabilidade.** O GLOP, como SaaS de logística, não é, em regra, instituição financeira; contudo, por processar **ingestão de pedidos** e por integrar-se a gateways com **split, repasses e dados de PIX/bancários**, adota, no que couber e por diligência, controles de prevenção à lavagem de dinheiro e ao financiamento do terrorismo, alinhados à Lei nº 9.613/1998 e às boas práticas do COAF.

14.2. **Abordagem baseada em risco.** Os controles são proporcionais ao risco e concentram-se nos fluxos financeiros (coprodução, afiliação, split via AppMax) e na ingestão de pedidos.

14.3. **Conheça seu Parceiro/Cliente (KYP/KYC).** Antes de habilitar coprodutores/afiliados a repasses, a Empresa verifica identificação, regularidade e, quando cabível, condição de PEP e presença em listas restritivas (nacionais, ONU e sanções internacionais aplicáveis, conforme Lei nº 13.810/2019).

14.4. **Monitoramento e sinais de alerta:**

- fracionamento de operações para evitar limites;
- incompatibilidade entre volume/valor de pedidos e o perfil do parceiro;
- pedidos e pagamentos com dados inconsistentes ou de terceiros não relacionados;
- solicitação de repasse a conta/PIX diverso do titular cadastrado;
- uso da plataforma para produtos/valores atípicos.

14.5. **Comunicação ao COAF.** Identificada operação suspeita que se enquadre em dever legal de comunicação, a Empresa avalia, com apoio jurídico, a necessidade e a forma de comunicação ao COAF, preservando a confidencialidade legalmente exigida e vedada a "tipping-off" (aviso ao investigado).

14.6. **Vedação de sanções.** É proibido operar com pessoas ou entidades submetidas a sanções de indisponibilidade de ativos ou a listas de terrorismo aplicáveis.

14.7. **Guarda de registros.** Registros de operações e de diligências de PLD/FT são conservados pelo prazo legal, com trilha de auditoria.

---

## 15. Compliance Concorrencial (CADE)

15.1. É vedada qualquer conduta anticompetitiva (Lei nº 12.529/2011), incluindo cartel, fixação concertada de preços/comissões, divisão de mercado, troca de informação concorrencialmente sensível e abuso de posição dominante.

15.2. Em interações com concorrentes (eventos, associações, integrações), é proibido tratar de preços, margens, condições de split, estratégias comerciais ou dados de clientes.

15.3. Suspeitas de infração concorrencial devem ser reportadas ao Compliance para avaliação, inclusive quanto a eventual programa de leniência.

---

## 16. Compliance de Proteção de Dados (LGPD) — Interface com o DPO

16.1. O tratamento de dados pessoais no GLOP observa a LGPD e é supervisionado pelo DPO/Encarregado (a ser designado pela administração, lemoncapsencapsulados@gmail.com). Esta Política não substitui a Política de Privacidade, o DPA nem o Programa de Governança de Privacidade, aos quais remete.

16.2. **Dupla natureza reconhecida.** O GLOP atua como **Operador** ao tratar dados de compradores por conta e ordem do produtor/lojista (Controlador) e como **Controlador** dos dados de seus próprios usuários e colaboradores. As responsabilidades de compliance acompanham essa dupla natureza.

16.3. **Controles de integridade de dados.** Reforçam o Programa: segregação multi-tenant por RLS (Tenant→Company→Branch→Membership), RBAC via has_permission, soft-delete, trilha de auditoria por triggers, colunas de auditoria em todo registro, credenciais de API write-only e minimização de exposição no portal público de rastreio (apenas status neutro, sem PII, sem login).

16.4. **Incidentes.** Incidentes de segurança com dados pessoais seguem o Plano de Resposta a Incidentes, com avaliação de comunicação à ANPD e aos titulares nos termos legais, articulados entre Compliance, DPO e Segurança da Informação.

16.5. **Compartilhamento com sub-operadores.** O compartilhamento com Supabase, Netlify, VHSYS, Correios, gateways e mensageria observa base legal, finalidade específica e DPA (Seção 13.5).

---

## 17. Compliance Setorial: Logística, Marketplace, Consumidor e Fiscal

17.1. **Logística e transporte.** As integrações com os Correios (pré-postagem PPN, rastreio SRO e notificações) devem preservar a exatidão da informação ao comprador, sem promessa enganosa de prazo e sem exposição indevida de dados no portal público.

17.2. **Marketplace e e-commerce.** Nas integrações com Shopify, WooCommerce, Nuvemshop e Mercado Livre, respeitam-se os termos das plataformas, a titularidade dos dados e as vedações a uso indevido de informação de compradores.

17.3. **Consumidor (CDC e Decreto nº 7.962/2013).** É vedada publicidade enganosa ou abusiva, cobrança indevida e obstrução ao direito de informação e arrependimento. As notificações de rastreio devem ser verídicas e claras.

17.4. **Fiscal (NF-e via VHSYS).** A intermediação de emissão de documentos fiscais deve refletir a realidade das operações, vedada emissão fria, simulação ou omissão. Registros fiscais devem ser fidedignos e auditáveis (Seção 20).

---

## 18. Canal de Denúncias e Não Retaliação

18.1. **Instituição.** A Empresa mantém Canal de Denúncias acessível a Colaboradores, Terceiros e ao público, para reporte de suspeitas de violação a esta Política, ao Código de Ética ou à legislação.

18.2. **Meios de acesso:** e-mail dedicado [E-MAIL CANAL DE DENÚNCIAS], e/ou formulário/hotline [CANAL/URL], disponíveis [24x7 / horário].

18.3. **Confidencialidade e anonimato.** É garantido sigilo da identidade do denunciante. Admite-se denúncia anônima, que será apurada na medida das informações prestadas.

18.4. **Não retaliação.** É **terminantemente proibida** qualquer forma de retaliação (demissão, rebaixamento, assédio, isolamento, prejuízo contratual) contra quem denuncie de boa-fé ou colabore com apuração. A retaliação é, em si, infração grave sujeita a sanção.

18.5. **Boa-fé.** A proteção não alcança denúncia comprovadamente falsa e dolosa, que constitui infração autônoma.

18.6. **Recebimento e triagem.** As denúncias são recebidas por Compliance (ou, em conflito, por instância independente), com registro, classificação de risco e prazo de tratamento. Denúncias envolvendo a Alta Direção são escaladas a instância isenta.

18.7. **Retorno.** Sempre que possível, o denunciante recebe confirmação de recebimento e desfecho geral, respeitados sigilo e proteção de dados.

---

## 19. Investigações Internas e Medidas Disciplinares

19.1. **Devido processo.** As apurações observam imparcialidade, confidencialidade, contraditório proporcional, preservação de provas (inclusive logs e trilha de auditoria) e proteção de dados dos envolvidos.

19.2. **Condução.** As investigações são conduzidas por Compliance, com apoio do Jurídico e, quando necessário, de terceiros independentes, evitando conflito de interesses.

19.3. **Medidas cautelares.** Durante a apuração, podem ser adotadas medidas como suspensão de acessos (RBAC), afastamento preventivo ou bloqueio de repasses/split, de forma proporcional.

19.4. **Conclusão.** O relatório de investigação recomenda medidas de remediação, disciplinares e de aprimoramento de controles, submetido à instância competente.

19.5. **Medidas disciplinares.** Conforme gravidade: advertência, suspensão, rescisão por justa causa, exclusão de terceiro, além de responsabilização civil e criminal cabível (Seção 23).

---

## 20. Controles Internos, Livros e Registros Contábeis

20.1. A Empresa mantém livros, registros contábeis e financeiros **completos, precisos e fidedignos**, que reflitam a realidade das operações, incluindo repasses, comissões, split e documentos fiscais.

20.2. É proibida a criação de caixa dois, contas ou lançamentos não registrados, documentos falsos ou classificações contábeis enganosas.

20.3. Os controles internos são desenhados para prevenir e detectar irregularidades, com segregação de funções, alçadas de aprovação, conciliações e preservação de trilhas de auditoria (triggers) e colunas de auditoria em todo registro.

20.4. **Retenção.** Documentos e registros são conservados pelos prazos legais e regulatórios aplicáveis, com integridade e disponibilidade asseguradas.

---

## 21. Monitoramento, Auditoria e Testes de Efetividade

21.1. **Monitoramento contínuo.** Compliance monitora indicadores de integridade (KPIs de compliance), red flags, alertas de PLD/FT, exceções de acesso (RBAC) e anomalias em fluxos de pagamento/split.

21.2. **Auditorias.** São realizadas auditorias periódicas (mínimo anual) e pontuais, internas ou independentes, sobre processos críticos: split e repasses, ingestão de PII, due diligence de terceiros, controles de segurança e registros fiscais.

21.3. **Testes de efetividade.** O Programa é submetido a testes que verificam se os controles funcionam na prática (não apenas no papel), com plano de ação para deficiências identificadas.

21.4. **Reporte.** Resultados são reportados à Alta Direção, com acompanhamento de planos de ação até o encerramento.

21.5. **Métricas de referência (exemplos):** nº de denúncias e tempo médio de tratamento; % de terceiros com due diligence válida; % de colaboradores treinados; nº de red flags tratadas; nº de incidentes e reincidências.

---

## 22. Treinamento, Comunicação e Cultura de Integridade

22.1. **Obrigatoriedade.** Todos os Colaboradores realizam treinamento de integridade na admissão (onboarding) e, no mínimo, **anualmente** em reciclagem. Funções de maior risco (financeiro/split, integrações de dados, atendimento) recebem treinamento específico.

22.2. **Terceiros.** Sub-operadores e parceiros críticos recebem comunicação das expectativas de integridade e, quando pertinente, materiais de conscientização.

22.3. **Conteúdo mínimo:** esta Política, Código de Ética, anticorrupção, conflito de interesses, brindes, PLD/FT, LGPD/segurança de dados, uso do Canal de Denúncias e não retaliação.

22.4. **Registro.** A participação é registrada (data, conteúdo, aproveitamento) e serve de evidência de efetividade do Programa.

22.5. **Comunicação contínua.** Campanhas periódicas, comunicados da Alta Direção ("tone at the top") e disponibilização permanente dos normativos em repositório acessível.

---

## 23. Sanções e Consequências pelo Descumprimento

23.1. **Colaboradores.** O descumprimento sujeita o infrator, conforme gravidade e reincidência, a: advertência verbal ou escrita; suspensão; rescisão do contrato de trabalho por **justa causa** (art. 482 da CLT); além de responsabilização civil (perdas e danos) e comunicação às autoridades para responsabilização criminal cabível.

23.2. **Administradores e sócios.** Sujeitam-se às medidas societárias, civis e criminais aplicáveis, sem prejuízo da responsabilização da própria Empresa.

23.3. **Terceiros.** O descumprimento autoriza suspensão imediata da relação, rescisão por justa causa/motivada, execução de penalidades contratuais, retenção de repasses pendentes de apuração e cobrança de perdas e danos, além de comunicação às autoridades (Seção 24).

23.4. **Proporcionalidade e devido processo.** As sanções observam proporcionalidade, contraditório proporcional e registro documental.

23.5. **Independência das esferas.** A responsabilização administrativa/disciplinar não exclui a civil e a criminal, que são independentes entre si.

---

## 24. Gestão de Terceiros e Cláusulas Contratuais de Integridade

24.1. **Qualificação das partes.** Todo contrato relevante identifica: de um lado, **[CONTRATANTE]** — LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, CNPJ 55.836.075/0001-07, sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, operadora do [NOME FANTASIA: GLOP]; de outro, o **[PARTE]** (terceiro/sub-operador), devidamente qualificado (razão social, CNPJ/CPF, endereço, representante legal).

24.2. **Objeto.** Prestação de serviços/integração/parceria descrita no instrumento, com submissão do Terceiro a esta Política e ao Código de Ética.

24.3. **Obrigações do Terceiro.** Cumprir a legislação anticorrupção, de PLD/FT, concorrencial, consumerista e de proteção de dados; não oferecer/receber Vantagem Indevida; manter registros fidedignos; permitir auditoria e verificação de conformidade (right to audit); comunicar red flags; e, quando tratar dados de compradores, celebrar e observar o **DPA** e as medidas de segurança compatíveis.

24.4. **Obrigações do GLOP.** Fornecer canais de reporte, orientar quanto às expectativas de integridade e tratar dados compartilhados conforme a LGPD e o DPA.

24.5. **Preço/pagamento.** Quando aplicável, condições de preço, forma e prazo de pagamento e regras de repasse/split são definidas no instrumento, vedados pagamentos atípicos e a terceiros não relacionados (Seção 14).

24.6. **Prazo/vigência.** Conforme instrumento específico, com possibilidade de renovação e de rescisão por descumprimento de integridade.

24.7. **Confidencialidade.** As partes mantêm sigilo sobre informações confidenciais e dados pessoais a que tiverem acesso, inclusive após o término da relação.

24.8. **Proteção de dados.** Remissão expressa ao DPA/LGPD e à Política de Privacidade, que integram o contrato para todos os fins.

24.9. **Propriedade intelectual.** Preservação da titularidade da Empresa sobre a plataforma, marcas, software e materiais; o Terceiro não adquire direitos além do estritamente licenciado.

24.10. **Responsabilidade e limitação.** Cada parte responde por seus atos; o Terceiro indeniza a Empresa por perdas decorrentes de violação de integridade/dados, observadas as limitações de responsabilidade pactuadas no instrumento, ressalvados dolo, fraude e violação de proteção de dados.

24.11. **Rescisão.** A Empresa pode rescindir imediatamente, sem ônus, em caso de violação de integridade, ato lesivo, inclusão em listas restritivas ou perda de idoneidade do Terceiro.

24.12. **Penalidades.** Aplicáveis multas, retenção e demais penalidades previstas no instrumento, sem prejuízo de perdas e danos.

24.13. **Foro.** Elege-se o foro da Comarca de [FORO/COMARCA], com renúncia a qualquer outro, para dirimir controvérsias, sem prejuízo de convenção de arbitragem, se pactuada.

24.14. **Cláusula-modelo de integridade (a inserir nos contratos):** "O [PARTE] declara conhecer e obriga-se a cumprir a Lei nº 12.846/2013, o Decreto nº 11.129/2022, a Lei nº 9.613/1998, a Lei nº 13.709/2018 e a Política de Compliance e Integridade do [CONTRATANTE], abstendo-se de qualquer ato lesivo, corrupção, fraude ou lavagem de dinheiro, sob pena de rescisão imediata e responsabilização, autorizando verificações de conformidade e comprometendo-se a comunicar irregularidades."

---

## 25. Papéis e Responsabilidades

25.1. **Alta Direção:** patrocinar o Programa, aprovar políticas e recursos, dar exemplo, decidir sobre riscos residuais altos e casos que a envolvam (por instância isenta).

25.2. **Encarregado/Comitê de Compliance:** manter e evoluir o Programa, gerir riscos, conduzir due diligence e investigações, operar o Canal de Denúncias, monitorar e reportar.

25.3. **DPO/Encarregado (a ser designado pela administração):** supervisionar a proteção de dados, articular incidentes e DPAs, interface com a ANPD e titulares.

25.4. **Segurança da Informação:** manter controles técnicos (RLS, RBAC, auditoria, credenciais write-only), detectar e responder a incidentes.

25.5. **Jurídico:** assessorar em enquadramento legal, contratos, investigações e comunicações a autoridades.

25.6. **Financeiro:** operar controles de repasses/split com segregação de funções e prevenção a fraude/PLD.

25.7. **RH:** apoiar treinamentos, onboarding, aplicação de medidas disciplinares e registros.

25.8. **Gestores (1ª linha):** executar controles, reportar red flags e assegurar conformidade em suas áreas.

25.9. **Todos os destinatários:** conhecer e cumprir a Política, reportar suspeitas e cooperar com apurações.

---

## 26. Vigência, Revisão e Disposições Gerais

26.1. Esta Política entra em vigor em 16 de julho de 2026 e permanece vigente por prazo indeterminado, até revisão ou revogação formal.

26.2. Será revisada, no mínimo, **anualmente**, e extraordinariamente diante de mudança legislativa, incidente relevante, alteração de negócio/tecnologia ou determinação de autoridade.

26.3. Casos omissos serão dirimidos pelo Compliance, com apoio do Jurídico, à luz dos princípios desta Política e da legislação.

26.4. A eventual invalidade de uma cláusula não prejudica as demais.

26.5. Esta Política não gera direito adquirido a práticas anteriores incompatíveis com a integridade.

---

## 27. Termo de Ciência e Adesão

Declaro que recebi, li, compreendi e me comprometo a cumprir integralmente a Política de Compliance e Integridade do [NOME FANTASIA: GLOP], estando ciente de que seu descumprimento sujeita-me às sanções nela previstas e à responsabilização legal cabível.

- **Nome:** ______________________________
- **CPF/Documento:** ____________________
- **Função/Vínculo:** ____________________
- **Local e Data:** _____________, 16 de julho de 2026
- **Assinatura:** ________________________

---

## 28. Engenharia Jurídica & Governança

### (a) Fundamentação das cláusulas

| Seção/Tema | Fundamento legal/normativo |
|---|---|
| Programa de Integridade (Seções 7 e 1) | Lei nº 12.846/2013, arts. 7º, VIII, e 41-42; Decreto nº 11.129/2022, arts. 41 e 57 |
| Anticorrupção/atos lesivos (Seções 9-11) | Lei nº 12.846/2013, art. 5º; Código Penal (corrupção ativa, tráfico de influência); Lei nº 8.429/1992 |
| PLD/FT e COAF (Seção 14) | Lei nº 9.613/1998; regulamentação COAF; Lei nº 13.810/2019; Lei nº 13.260/2016 |
| Concorrencial (Seção 15) | Lei nº 12.529/2011 |
| Proteção de dados (Seções 16 e 24.8) | Lei nº 13.709/2018 (LGPD); regulamentos ANPD; ISO 27701; GDPR (quando aplicável) |
| Consumidor/e-commerce (Seção 17) | Lei nº 8.078/1990; Decreto nº 7.962/2013; Lei nº 12.965/2014 |
| Registros contábeis (Seção 20) | Lei nº 12.846/2013, art. 7º, VIII; boas práticas contábeis; FCPA (books & records) |
| Canal de denúncias/não retaliação (Seção 18) | Decreto nº 11.129/2022, art. 57, X e XVI; ISO 37001/37301 |
| Medidas disciplinares (Seções 19 e 23) | CLT, art. 482; Decreto nº 11.129/2022, art. 57, XI |
| Due diligence de terceiros (Seções 13 e 24) | Decreto nº 11.129/2022, art. 57, XIII e XV; ISO 37001 |
| Governança/linhas de defesa (Seção 6) | ISO 37301; ISO 31000; boas práticas de governança |

### (b) Riscos mitigados

- Responsabilização objetiva da Empresa por ato lesivo (Lei nº 12.846/2013), com o Programa como fator atenuante da sanção (art. 7º, VIII).
- Fraude em split/repasses e desvio via PIX/dados bancários (controles de segregação, RBAC, auditoria).
- Lavagem de dinheiro e financiamento do terrorismo por meio de pedidos/pagamentos.
- Vazamento e uso indevido de PII de compradores; sanções da ANPD (interface com DPO/DPA).
- Infrações concorrenciais e consumeristas.
- Contratação de terceiros/sub-operadores sem idoneidade ou conformidade de segurança.
- Retaliação a denunciantes e "programa de papel" (efetividade evidenciada).
- Registros fiscais/NF-e inexatos e caixa dois.

### (c) Checklist de implementação

- [ ] Aprovação formal pela Alta Direção e definição de vigência.
- [ ] Designação do Encarregado/Comitê de Compliance com autonomia e recursos.
- [ ] Preenchimento de todos os placeholders entre colchetes.
- [ ] Publicação em repositório acessível e divulgação a todos.
- [ ] Coleta dos Termos de Ciência e Adesão.
- [ ] Elaboração/atualização da Matriz de Riscos de Integridade.
- [ ] Due diligence dos sub-operadores críticos (Supabase, Netlify, VHSYS, Correios, Monetizze, AppMax, Hotmart, Kiwify, mensageria) e DPAs firmados.
- [ ] Ativação do Canal de Denúncias e teste de não retaliação.
- [ ] Plano de treinamento (onboarding + reciclagem anual) com registro.
- [ ] Definição de KPIs de compliance e rotina de monitoramento/auditoria.
- [ ] Cláusulas de integridade inseridas nos contratos de terceiros.
- [ ] Rotina de PLD/FT (KYP/KYC, listas restritivas, análise de operação suspeita).
- [ ] Integração com Plano de Resposta a Incidentes e políticas de dados/segurança.

### (d) Matriz RACI

| Atividade | Alta Direção | Compliance | DPO | Seg. Info | Jurídico | Financeiro | RH | Gestores |
|---|---|---|---|---|---|---|---|---|
| Aprovar e patrocinar a Política | A/R | C | C | I | C | I | I | I |
| Gerir riscos de integridade | A | R | C | C | C | C | I | R |
| Due diligence de terceiros | I | R | C | C | C | C | I | C |
| Operar Canal de Denúncias | I | R | C | C | C | I | C | I |
| Conduzir investigações | A | R | C | C | R | C | C | I |
| Controles de PLD/FT e split | A | R | I | C | C | R | I | R |
| Proteção de dados (LGPD/DPA) | A | C | R | R | C | I | I | C |
| Treinamento e comunicação | I | R | C | C | C | I | R | C |
| Monitoramento e auditoria | A | R | C | C | C | C | I | C |
| Aplicar medidas disciplinares | A | C | I | I | C | I | R | C |

Legenda: **R** = Responsável executa; **A** = Autoridade/aprova; **C** = Consultado; **I** = Informado.

### (e) Plano de revisão

- **Periodicidade ordinária:** anual, sob condução do Compliance.
- **Gatilhos extraordinários:** mudança legislativa (Lei 12.846, LGPD, PLD/FT), incidente ou denúncia relevante, alteração de sub-operadores/fluxos (novos gateways, integrações), reorganização societária, apontamento de auditoria/autoridade.
- **Fluxo:** revisão técnica (Compliance/Jurídico/DPO) → validação da Alta Direção → atualização do controle de versão → recomunicação e novo aceite quando houver mudança material.

### (f) Controle de versão

| Versão | Data | Autor/Responsável | Descrição da alteração | Aprovação |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | Compliance / a ser designado pela administração | Emissão inicial da Política de Compliance e Integridade | [ÓRGÃO/PESSOA APROVADORA] |
| [x.x] | 16 de julho de 2026 | [AUTOR] | [DESCRIÇÃO] | [APROVADOR] |

---

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.
