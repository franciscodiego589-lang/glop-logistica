# Termos de Uso / Condições Gerais de Uso — GLOP (Global Logistics Platform)

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

**Controladora / Fornecedora da plataforma:** [RAZÃO SOCIAL], nome fantasia [NOME FANTASIA: GLOP], inscrita no CNPJ sob o nº [CNPJ], com sede em [ENDEREÇO COMPLETO] ("GLOP", "Plataforma", "nós" ou "Fornecedora").

**Encarregado pelo Tratamento de Dados Pessoais (DPO):** [NOME DO ENCARREGADO] — contato: [E-MAIL DO DPO/ENCARREGADO].

**Site oficial:** [URL DO SITE].

**Versão:** 1.0 — **Vigência a partir de:** [DATA].

---

## Sumário

1. Definições
2. Objeto e Descrição do Serviço
3. Aceite, Capacidade e Formação do Contrato
4. Cadastro, Conta, Credenciais e Segurança de Acesso
5. Licença de Uso do Software (SaaS)
6. Planos, Preços, Pagamento, Reajuste, Inadimplência e Suspensão
7. Obrigações e Responsabilidades do Usuário
8. Proteção de Dados Pessoais e a Dualidade Controlador/Operador
9. Obrigações do GLOP e Níveis de Serviço (SLA)
10. Integrações de Terceiros e Isenção de Responsabilidade
11. Propriedade Intelectual
12. Dados Agregados, Anonimizados e Melhoria do Serviço
13. Vedações e Uso Proibido
14. Limitação de Responsabilidade e Exclusões
15. Garantias e Disponibilidade
16. Suspensão, Rescisão e Efeitos
17. Portabilidade, Devolução e Eliminação de Dados no Encerramento
18. Relação com o Código de Defesa do Consumidor
19. Alterações destes Termos
20. Comunicações e Notificações
21. Disposições Gerais
22. Lei Aplicável e Foro
23. Documentos Acessórios e Ordem de Prevalência
24. Contato
25. Engenharia Jurídica & Governança

---

## 1. Definições

Para os fins destes Termos de Uso ("Termos"), os vocábulos abaixo, no singular ou no plural, têm o significado a seguir atribuído:

- **GLOP / Plataforma:** o software como serviço (SaaS) de logística e ERP denominado Global Logistics Platform, disponibilizado pela Fornecedora, incluindo módulos de WMS (gestão de armazém), TMS (gestão de transporte), OMS (gestão de pedidos), MRP/APS/PCP, torre de controle, BI e inteligência artificial (LOGIA), bem como suas integrações, APIs, webhooks e o portal público de rastreio.
- **Usuário / Produtor / Lojista / Cliente:** a pessoa jurídica ou pessoa física empresária que contrata e utiliza o GLOP para operar seu negócio de logística, dropshipping e/ou infoprodutos, atuando como titular da conta e como Controlador dos dados dos Compradores que ingressa na Plataforma.
- **Coprodutor / Afiliado:** terceiro vinculado ao Usuário, participante de regras de comissão, coprodução e/ou split de pagamentos, cujos dados de identificação e bancários (incluindo chave PIX e dados de conta) podem ser tratados na Plataforma.
- **Comprador / Titular / Consumidor final:** a pessoa física ou jurídica que adquire produtos/serviços do Usuário e cujos dados pessoais (nome, CPF/CNPJ, e-mail, telefone, endereço completo, itens e valores do pedido) são ingeridos na Plataforma a partir das plataformas de pagamento/checkout e e-commerces integrados.
- **Transportador:** operador logístico responsável pelo transporte e entrega, notadamente os Correios (Empresa Brasileira de Correios e Telégrafos), por meio das APIs de pré-postagem (PPN) e de rastreio (SRO).
- **Integrações de Terceiros:** serviços externos conectados ao GLOP por API ou webhook, incluindo, sem limitação, Monetizze, Hotmart e Kiwify (checkout/pagamento de infoprodutos), Shopify, WooCommerce, Nuvemshop e Mercado Livre (e-commerce/marketplace), Correios (logística), AppMax (split de pagamento) e VHSYS (emissão de documentos fiscais — NF-e/CT-e/MDF-e/NFS-e).
- **Sub-operadores de Infraestrutura:** fornecedores de infraestrutura tecnológica utilizados pela Plataforma, notadamente Supabase (banco de dados PostgreSQL, autenticação e armazenamento) e Netlify (hospedagem SSR).
- **Conta:** o ambiente lógico multi-tenant (Tenant → Company → Branch → Membership) provisionado ao Usuário, isolado por RLS (Row Level Security) e RBAC (controle de acesso baseado em papéis).
- **Dados do Comprador / PII do Comprador:** dados pessoais de titulares Compradores tratados pelo GLOP em nome e sob instrução do Usuário-Controlador.
- **LGPD:** Lei nº 13.709/2018 (Lei Geral de Proteção de Dados Pessoais).
- **CDC:** Lei nº 8.078/1990 (Código de Defesa do Consumidor).
- **Marco Civil:** Lei nº 12.965/2014 (Marco Civil da Internet).
- **Política de Privacidade:** o documento que descreve o tratamento de dados pessoais pelo GLOP, disponível em [URL DO SITE].
- **DPA / Acordo de Tratamento de Dados:** o Data Processing Agreement que rege a relação Controlador–Operador entre Usuário e GLOP.
- **SLA:** o Acordo de Nível de Serviço aplicável à disponibilidade e ao suporte da Plataforma.

---

## 2. Objeto e Descrição do Serviço

### 2.1. Objeto

Estes Termos regem o acesso e o uso do GLOP, plataforma SaaS B2B (empresa para empresa) de logística e ERP voltada a operações de dropshipping e infoprodutos no Brasil, disponibilizada pela Fornecedora ao Usuário mediante licença de uso não exclusiva, intransferível e por prazo determinado ou indeterminado, conforme o plano contratado.

### 2.2. Funcionalidades

O GLOP disponibiliza, conforme o plano contratado e a evolução da Plataforma, os seguintes módulos e fluxos:

1. **ERP/WMS/TMS/OMS logístico:** gestão de armazém, estoque, lotes, expedição, transporte, roteirização, gestão de pedidos e torre de controle operacional.
2. **Ingestão (pull) de pedidos:** captação automatizada de pedidos, via API, das plataformas de pagamento/checkout (Monetizze, Hotmart, Kiwify) e dos e-commerces/marketplaces (Shopify, WooCommerce, Nuvemshop, Mercado Livre). A ingestão inclui dados pessoais do Comprador — nome, CPF/CNPJ, e-mail, telefone, endereço completo (CEP, logradouro, número, bairro, cidade, UF), produto e valor — estritamente para a finalidade de processamento logístico e fiscal do pedido em nome do Usuário.
3. **Integração com os Correios:** geração de pré-postagem (PPN), obtenção e gestão de códigos de rastreio (SRO) e notificação ao Comprador por e-mail e/ou WhatsApp sobre o status da entrega.
4. **Coprodução e Split de Pagamentos:** cadastro de coprodutores/afiliados, definição de regras de comissão, apuração, repasses e split de pagamento (via AppMax), com tratamento de dados de PIX/bancários de coprodutores para viabilizar os repasses.
5. **Emissão de Documentos Fiscais:** emissão de NF-e (e, conforme o caso, CT-e, MDF-e e NFS-e) por meio de integração com a VHSYS.
6. **Portal público de rastreio:** ambiente sem necessidade de login em que o Comprador consulta o status de sua entrega pelo código de rastreio, com exibição de status neutro e sem exposição de dados pessoais sensíveis.
7. **Webhooks, logs e credenciais:** recebimento e emissão de webhooks, registro de logs de API e armazenamento de credenciais de integração em modo write-only (gravação sem leitura posterior em texto claro).
8. **Segurança e governança:** isolamento multi-tenant por RLS por empresa, RBAC (controle por permissão — has_permission), soft-delete (exclusão lógica), trilha de auditoria por gatilhos (triggers) e colunas de auditoria (created_by, updated_by, deleted_at) em todo registro, com tenant_id e company_id em cada registro.

### 2.3. Natureza do serviço

O GLOP é uma **ferramenta tecnológica de gestão e intermediação técnica**. O GLOP **não é**: (i) instituição financeira, de pagamento ou adquirente; (ii) transportadora; (iii) plataforma de checkout ou de venda; (iv) emissora de documentos fiscais por conta própria; (v) parte nas relações de consumo ou comerciais entre o Usuário e seus Compradores, coprodutores, afiliados ou fornecedores. As operações de pagamento, transporte, checkout e emissão fiscal são executadas por terceiros integrados, sob responsabilidade do Usuário e dos respectivos prestadores.

### 2.4. Evolução e disponibilidade de módulos

A Fornecedora pode adicionar, alterar, descontinuar ou condicionar funcionalidades a determinados planos, mediante comunicação prévia razoável quando a alteração for materialmente relevante e desfavorável ao Usuário, ressalvadas alterações exigidas por lei, segurança ou por terceiros integrados.

---

## 3. Aceite, Capacidade e Formação do Contrato

### 3.1. Aceite

O uso do GLOP pressupõe a leitura, compreensão e aceite integral destes Termos, da Política de Privacidade e do DPA. O aceite ocorre por meio de manifestação eletrônica inequívoca — clique em "li e aceito", conclusão do cadastro, ativação de plano ou uso efetivo da Plataforma — o que constitui contrato válido, vinculante e exequível, nos termos dos artigos 104 e seguintes do Código Civil e do art. 10, §2º, da MP 2.200-2/2001 (validade de documentos eletrônicos).

### 3.2. Capacidade e legitimidade

Ao aceitar, o Usuário declara e garante que: (i) é maior de 18 anos e plenamente capaz, ou é pessoa jurídica regularmente constituída; (ii) a pessoa física que realiza o aceite tem poderes para vincular a pessoa jurídica titular da conta; (iii) as informações prestadas são verdadeiras, exatas e atualizadas; e (iv) utilizará a Plataforma para finalidades empresariais lícitas.

### 3.3. Contratação empresarial

Estes Termos regem relação **B2B**. O Usuário atua como profissional/empresário e não como consumidor perante o GLOP. A eventual incidência do CDC restringe-se às hipóteses do item 18 e à relação entre o Usuário e seus próprios Compradores.

---

## 4. Cadastro, Conta, Credenciais e Segurança de Acesso

### 4.1. Cadastro

O acesso depende de cadastro com dados verídicos. O Usuário é responsável por manter seus dados cadastrais completos e atualizados e por informar prontamente qualquer alteração relevante.

### 4.2. Conta e organização multi-tenant

A conta é provisionada em arquitetura multi-tenant (Tenant → Company → Branch → Membership), com isolamento lógico por RLS. O Usuário administrador é responsável por gerir os membros (memberships), atribuir papéis (RBAC) e definir permissões, respondendo pelos atos praticados por seus usuários e colaboradores autorizados.

### 4.3. Credenciais

As credenciais de acesso (login, senha, tokens, chaves de API) são pessoais e intransferíveis. O Usuário compromete-se a: (i) proteger a confidencialidade das credenciais; (ii) não compartilhá-las com terceiros não autorizados; (iii) adotar autenticação forte e boas práticas de segurança; e (iv) comunicar imediatamente ao GLOP qualquer uso não autorizado ou incidente de segurança de que tome conhecimento.

### 4.4. Credenciais de integração write-only

As credenciais de Integrações de Terceiros (por exemplo, chaves de API de Monetizze, Hotmart, Kiwify, Correios, VHSYS, AppMax) são armazenadas em modo write-only, não sendo recuperáveis em texto claro após a gravação. O Usuário é responsável pela obtenção, legitimidade e regularidade dessas credenciais junto aos respectivos provedores.

### 4.5. Responsabilidade por acessos

Presumem-se realizados pelo Usuário todos os atos praticados mediante suas credenciais, salvo comprovação inequívoca de fraude ou falha atribuível exclusivamente ao GLOP. A trilha de auditoria por gatilhos e as colunas de auditoria registram autoria e momento das operações relevantes.

---

## 5. Licença de Uso do Software (SaaS)

### 5.1. Concessão

Sujeito ao cumprimento destes Termos e ao pagamento das contraprestações devidas, o GLOP concede ao Usuário uma **licença de uso pessoal, limitada, revogável, não exclusiva, intransferível e não sublicenciável** do software, no modelo SaaS, acessível remotamente pela internet, durante a vigência do contrato.

### 5.2. Natureza SaaS

O software é licenciado, não vendido. Não há transferência de titularidade, código-fonte, propriedade intelectual ou direito de exploração econômica do software ao Usuário. O acesso ocorre exclusivamente na modalidade de serviço hospedado.

### 5.3. Vedações de licença

É vedado ao Usuário, direta ou indiretamente: (i) copiar, reproduzir, modificar, traduzir ou criar obras derivadas do software; (ii) realizar engenharia reversa, descompilação ou desmontagem, salvo na estrita medida permitida por lei imperativa; (iii) sublicenciar, alugar, revender, ceder ou disponibilizar o acesso a terceiros não autorizados; (iv) remover avisos de propriedade intelectual; (v) contornar mecanismos de segurança, limites técnicos, cotas ou controles de acesso.

### 5.4. Reserva de direitos

Todos os direitos não expressamente concedidos permanecem reservados ao GLOP e/ou a seus licenciadores.

---

## 6. Planos, Preços, Pagamento, Reajuste, Inadimplência e Suspensão

### 6.1. Planos e preços

Os planos, limites de uso (por exemplo, número de pedidos, empresas, usuários, integrações e volume de armazenamento), funcionalidades incluídas e preços são os vigentes no ato da contratação e/ou os descritos na proposta comercial, pedido ou tabela publicada em [URL DO SITE], que integram estes Termos.

### 6.2. Pagamento

As contraprestações são devidas na periodicidade contratada (mensal, anual ou outra), por meio dos instrumentos de pagamento disponibilizados. O não pagamento na data de vencimento caracteriza inadimplência, independentemente de notificação, sem prejuízo das comunicações de cobrança.

### 6.3. Tributos

Os preços não incluem tributos incidentes, salvo indicação em contrário. Tributos retidos ou devidos por força de lei serão suportados pela parte a quem a legislação atribuir o encargo.

### 6.4. Reajuste

Os valores serão reajustados anualmente, ou na menor periodicidade permitida por lei, pela variação positiva do **IPCA/IBGE** ou, na sua falta ou extinção, por índice que o substitua. Reajustes por alteração relevante de custos de terceiros integrados ou de infraestrutura serão comunicados com antecedência mínima de 30 (trinta) dias.

### 6.5. Inadimplência

Em caso de inadimplência, incidirão sobre o valor em atraso: (i) multa moratória de 2% (dois por cento); (ii) juros de mora de 1% (um por cento) ao mês, pro rata die; e (iii) atualização monetária pelo índice do item 6.4. O GLOP poderá, ainda, encaminhar o débito a órgãos de proteção ao crédito e/ou a cobrança, observada a legislação aplicável.

### 6.6. Suspensão por inadimplência

Persistindo a inadimplência por mais de [15] dias do vencimento, o GLOP poderá **suspender o acesso** à Plataforma, mediante aviso prévio, sem prejuízo da cobrança dos valores devidos. Durante a suspensão, os dados permanecerão preservados pelo prazo do item 17, ressalvada a hipótese de rescisão. A reativação fica condicionada à quitação integral, podendo ser cobrada taxa de reativação, quando prevista.

### 6.7. Teste gratuito e cortesias

Eventual período de teste gratuito (trial) ou cortesia é concedido por mera liberalidade, pode ser alterado ou encerrado a qualquer tempo e não gera direito adquirido à sua manutenção.

---

## 7. Obrigações e Responsabilidades do Usuário

### 7.1. Uso lícito

O Usuário obriga-se a utilizar o GLOP de forma lícita, ética e em conformidade com estes Termos, a legislação aplicável (incluindo LGPD, CDC, Marco Civil, legislação tributária e aduaneira) e os termos das Integrações de Terceiros.

### 7.2. Veracidade e legitimidade dos dados

O Usuário é responsável pela veracidade, exatidão, legalidade e origem lícita de todos os dados e conteúdos que insere, importa ou processa na Plataforma, incluindo os dados de Compradores ingeridos das integrações e os dados de coprodutores/afiliados.

### 7.3. Responsabilidade como Controlador dos dados do Comprador

O Usuário reconhece e concorda que, quanto aos **dados pessoais dos Compradores** que ingressa na Plataforma (via pull de Monetizze, Hotmart, Kiwify, Shopify, WooCommerce, Nuvemshop, Mercado Livre e demais integrações), atua como **CONTROLADOR** na acepção do art. 5º, VI, da LGPD, cabendo-lhe, com exclusividade:

1. definir as finalidades e os meios do tratamento;
2. **obter e manter as bases legais adequadas** (art. 7º e, se aplicável, art. 11 da LGPD), incluindo, quando cabível, o **consentimento** ou outra base legal (execução de contrato, cumprimento de obrigação legal/regulatória, legítimo interesse) junto ao Comprador;
3. prestar informações e garantir os direitos dos titulares (arts. 9º e 18 da LGPD);
4. manter registro das operações de tratamento e, quando exigível, relatório de impacto (RIPD);
5. responder a requisições de titulares e da ANPD relativas ao seu tratamento;
6. assegurar a licitude da coleta dos dados nas plataformas de origem e a existência de base legal para a transferência a operadores logísticos (Correios) e fiscais (VHSYS).

O GLOP, quanto a esses dados, atua como **OPERADOR**, tratando-os em nome e sob as instruções documentadas do Usuário, nos termos do DPA.

### 7.4. Notificações ao Comprador

O Usuário é responsável por assegurar que as notificações ao Comprador (por e-mail e/ou WhatsApp sobre pré-postagem, código de rastreio e status de entrega) possuem base legal e não configuram comunicação não solicitada (spam) ou infração às normas de proteção de dados e de defesa do consumidor.

### 7.5. Coprodutores e dados bancários

Ao cadastrar coprodutores/afiliados e configurar split e repasses, o Usuário declara possuir autorização e base legal para tratar os dados bancários e chaves PIX desses terceiros, respondendo pela exatidão das regras de comissão e pela legitimidade dos repasses.

### 7.6. Documentos fiscais

O Usuário é o responsável tributário pela emissão, conteúdo, veracidade e regularidade dos documentos fiscais (NF-e/CT-e/MDF-e/NFS-e) gerados via VHSYS, cabendo-lhe a correta parametrização fiscal, a guarda dos documentos e o cumprimento das obrigações acessórias. O GLOP apenas intermedia tecnicamente a emissão.

### 7.7. Conformidade nas integrações

O Usuário é responsável por obter, manter e utilizar de forma regular as credenciais e autorizações das Integrações de Terceiros, respeitando os respectivos termos de uso, limites de API e políticas.

### 7.8. Indenização (hold harmless)

O Usuário obriga-se a defender, indenizar e manter indene o GLOP, seus administradores, colaboradores e sub-operadores, de quaisquer reclamações, perdas, danos, multas (inclusive da ANPD, Procon e autoridades fiscais) e despesas (incluindo honorários advocatícios) decorrentes de: (i) violação destes Termos; (ii) uso ilícito ou irregular da Plataforma; (iii) inexistência ou insuficiência de base legal para o tratamento de dados de Compradores ou coprodutores; (iv) conteúdo, produtos ou práticas comerciais do Usuário; e (v) reclamações de Compradores, coprodutores, afiliados ou terceiros relacionadas à operação do Usuário.

---

## 8. Proteção de Dados Pessoais e a Dualidade Controlador/Operador

### 8.1. Marco regulatório

O tratamento de dados pessoais observa a LGPD, o Marco Civil da Internet, as normas e resoluções da ANPD e, quando aplicável a titulares ou operações na União Europeia, o GDPR (Regulamento (UE) 2016/679).

### 8.2. Dupla natureza do GLOP

O GLOP atua em **dupla qualidade**, de forma explícita:

1. **Como OPERADOR:** quanto aos dados pessoais dos **Compradores** (e dos coprodutores/afiliados enquanto tratados por conta do Usuário), tratados em nome e sob instrução do Usuário-CONTROLADOR, nos termos do art. 39 da LGPD e do DPA.
2. **Como CONTROLADOR:** quanto aos dados dos seus **próprios usuários** (produtores/lojistas, contatos, administradores) e de seus **colaboradores**, coletados para cadastro, faturamento, prevenção a fraudes, segurança, cumprimento de obrigações legais e melhoria do serviço, conforme a Política de Privacidade.

### 8.3. Remissão à Política de Privacidade e ao DPA

O detalhamento das operações, finalidades, bases legais, prazos de retenção, direitos dos titulares, transferências internacionais, medidas de segurança e sub-operadores consta da **Política de Privacidade** e do **DPA**, que integram e complementam estes Termos.

### 8.4. Sub-operadores

O Usuário autoriza, de forma geral, a subcontratação de sub-operadores de infraestrutura, notadamente **Supabase** (banco/autenticação/armazenamento) e **Netlify** (hospedagem), e dos terceiros necessários à execução dos fluxos (Correios, VHSYS, AppMax e provedores de checkout), nos termos e limites do DPA, comprometendo-se o GLOP a impor a esses sub-operadores obrigações de proteção de dados compatíveis.

### 8.5. Segurança da informação

O GLOP adota medidas técnicas e organizacionais compatíveis com o estado da técnica, incluindo isolamento multi-tenant por RLS, RBAC, soft-delete, trilha de auditoria, armazenamento write-only de credenciais e minimização de exposição de PII (por exemplo, o portal público de rastreio expõe apenas status neutro), sem prejuízo das diretrizes de referência de segurança (ISO/IEC 27001, 27701, 22301, 31000; NIST; OWASP; SOC 2; Zero Trust) na medida de sua adoção.

### 8.6. Incidentes de segurança

Em caso de incidente de segurança envolvendo dados pessoais, o GLOP comunicará o Usuário sem demora indevida e cooperará com as medidas de contenção, mitigação e, quando cabível, com a comunicação à ANPD e aos titulares, observadas as responsabilidades de cada parte conforme sua qualificação (Controlador/Operador) e o DPA.

---

## 9. Obrigações do GLOP e Níveis de Serviço (SLA)

### 9.1. Obrigações do GLOP

O GLOP compromete-se a: (i) disponibilizar a Plataforma conforme o plano contratado; (ii) empregar esforços comercialmente razoáveis para manter a disponibilidade e a segurança; (iii) tratar os dados do Comprador estritamente conforme as instruções do Usuário e o DPA; (iv) prestar suporte nos termos do plano; e (v) informar alterações relevantes conforme estes Termos.

### 9.2. Remissão ao SLA

Os índices de disponibilidade (uptime), janelas de manutenção, tempos de resposta de suporte, severidades e eventuais créditos de serviço são regidos pelo **SLA** aplicável, publicado em [URL DO SITE], que integra estes Termos. Na ausência de SLA específico, aplicam-se as práticas de melhor esforço, sem garantia de disponibilidade ininterrupta.

### 9.3. Manutenções

O GLOP poderá realizar manutenções programadas, preferencialmente em horários de menor impacto, com aviso prévio quando viável, e manutenções emergenciais sem aviso prévio quando necessárias à segurança ou à integridade do serviço.

---

## 10. Integrações de Terceiros e Isenção de Responsabilidade

### 10.1. Papel do GLOP

As Integrações de Terceiros (Monetizze, Hotmart, Kiwify, Shopify, WooCommerce, Nuvemshop, Mercado Livre, Correios, AppMax, VHSYS) e os Sub-operadores de Infraestrutura (Supabase, Netlify) são serviços **operados por terceiros independentes**, sujeitos aos seus próprios termos, políticas, preços, disponibilidade e níveis de serviço.

### 10.2. Isenção

O GLOP **não responde** por: (i) falhas, indisponibilidade, latência, erros, alterações de API, descontinuação ou mudanças de política de terceiros integrados; (ii) atrasos, extravios, avarias ou falhas de entrega imputáveis aos Correios ou a transportadores; (iii) recusas, glosas, chargebacks, bloqueios, split incorreto ou falhas de repasse imputáveis a provedores de pagamento/checkout ou à AppMax; (iv) rejeições, inconsistências ou indisponibilidade na emissão de documentos fiscais imputáveis à VHSYS ou às autoridades fiscais (SEFAZ); e (v) consequências de o Usuário fornecer credenciais inválidas ou parametrização incorreta.

### 10.3. Continuidade

A eventual descontinuação ou alteração de uma integração por decisão do terceiro não constitui inadimplemento do GLOP, que empregará esforços razoáveis para mitigar impactos e, quando possível, oferecer alternativas.

---

## 11. Propriedade Intelectual

### 11.1. Titularidade do GLOP

Todo o software, código-fonte e objeto, arquitetura, layout, telas, fluxos, marcas, nomes, logotipos, sinais distintivos, documentação, know-how e demais elementos do GLOP são de titularidade exclusiva da Fornecedora e/ou de seus licenciadores, protegidos pela Lei nº 9.610/1998 (Direitos Autorais), Lei nº 9.609/1998 (Software), Lei nº 9.279/1996 (Propriedade Industrial) e legislação correlata.

### 11.2. Marca

A marca [NOME FANTASIA: GLOP] e demais sinais distintivos não podem ser usados pelo Usuário sem autorização prévia e por escrito, salvo referência estritamente necessária ao uso do serviço.

### 11.3. Conteúdo e dados do Usuário

Os dados, conteúdos e informações inseridos pelo Usuário permanecem de sua titularidade (ou de terceiros de quem os obteve licitamente). O Usuário concede ao GLOP licença limitada, não exclusiva e pelo prazo do contrato, para hospedar, processar, transmitir e exibir tais dados exclusivamente para prestar o serviço, nos termos do DPA.

### 11.4. Feedback

Sugestões, ideias e feedback fornecidos pelo Usuário poderão ser utilizados livremente pelo GLOP para aprimorar o serviço, sem obrigação de contraprestação e sem que isso implique transferência de dados pessoais fora das bases legais aplicáveis.

---

## 12. Dados Agregados, Anonimizados e Melhoria do Serviço

### 12.1. Uso de dados agregados/anonimizados

O GLOP poderá gerar e utilizar **dados estatísticos, agregados e anonimizados** (que não permitam a identificação de titulares nem de Usuários), derivados do uso da Plataforma, para fins de operação, segurança, benchmarking, desenvolvimento de funcionalidades e inteligência (LOGIA), respeitado o art. 12 da LGPD (dado anonimizado não é dado pessoal, salvo reversão).

### 12.2. Vedação de reidentificação

O GLOP compromete-se a adotar técnicas adequadas de anonimização e a não empregar esforços razoáveis para reidentificar titulares a partir de dados anonimizados.

---

## 13. Vedações e Uso Proibido

É vedado ao Usuário, e a qualquer pessoa sob sua responsabilidade:

1. utilizar a Plataforma para fins ilícitos, fraudulentos, enganosos ou que violem direitos de terceiros;
2. comercializar, importar ou logistizar produtos proibidos, contrabandeados, falsificados, ou sujeitos a restrição sem a devida autorização;
3. inserir dados falsos, de terceiros sem autorização, ou obtidos de forma ilícita;
4. tratar dados de Compradores sem base legal, ou para finalidade diversa da logística/fiscal contratada;
5. enviar comunicações não solicitadas (spam) ou em desacordo com a LGPD e o CDC;
6. tentar burlar limites técnicos, cotas, mecanismos de segurança, RLS, RBAC ou realizar acesso não autorizado a dados de outros tenants;
7. introduzir malware, realizar ataques (DoS/DDoS, injeção, scraping abusivo) ou comprometer a integridade, o desempenho ou a segurança da Plataforma;
8. realizar engenharia reversa, cópia, revenda ou sublicenciamento vedados pelo item 5;
9. usar a Plataforma para lavagem de dinheiro, financiamento ilícito, evasão fiscal ou qualquer prática criminosa;
10. sobrecarregar as Integrações de Terceiros em violação a seus limites de API.

A violação a qualquer vedação autoriza suspensão imediata e/ou rescisão, sem prejuízo das responsabilidades civis e penais.

---

## 14. Limitação de Responsabilidade e Exclusões

### 14.1. Serviço "no estado em que se encontra"

Ressalvadas as garantias legais imperativas, a Plataforma é fornecida no estado em que se encontra e conforme disponibilidade, não havendo garantia de que atenderá a todos os requisitos específicos do Usuário, de que operará ininterruptamente ou de que estará livre de erros.

### 14.2. Danos excluídos

Na máxima extensão permitida em lei, o GLOP não responde por danos indiretos, lucros cessantes, perda de chance, perda de receita, perda de dados decorrente de ato do Usuário ou de terceiros, danos reputacionais ou consequenciais, ainda que advertido da possibilidade.

### 14.3. Teto de responsabilidade

A responsabilidade agregada do GLOP, por qualquer causa relacionada a estes Termos, no período de 12 (doze) meses, limita-se ao **valor efetivamente pago pelo Usuário ao GLOP nos 12 (doze) meses anteriores ao evento** que deu origem à responsabilidade, salvo vedação legal expressa.

### 14.4. Exclusões de responsabilidade

O GLOP não responde por eventos atribuíveis a: (i) terceiros integrados e sub-operadores (item 10); (ii) atos ou omissões do Usuário, de seus colaboradores, coprodutores, afiliados ou Compradores; (iii) uso indevido de credenciais; (iv) caso fortuito e força maior (item 21.5); (v) inexistência de base legal para tratamento de dados de responsabilidade do Usuário-Controlador.

### 14.5. Preservação de direitos indisponíveis

Nenhuma cláusula destes Termos exclui ou limita responsabilidades que não possam ser excluídas ou limitadas por lei imperativa, notadamente em matéria de dolo, fraude e direitos indisponíveis.

---

## 15. Garantias e Disponibilidade

### 15.1. Garantias mútuas

Cada parte declara e garante que tem capacidade e poderes para celebrar e cumprir estes Termos e que atuará conforme a legislação aplicável.

### 15.2. Ausência de garantia de resultado

O GLOP não garante resultados comerciais, aumento de vendas, redução de custos logísticos ou qualquer desempenho de negócio do Usuário, cuja obtenção depende de fatores fora do controle da Plataforma.

### 15.3. Disponibilidade

A disponibilidade é regida pelo SLA (item 9.2). O GLOP empregará esforços comercialmente razoáveis para manter a continuidade, ressalvadas manutenções, indisponibilidades de terceiros e eventos de força maior.

---

## 16. Suspensão, Rescisão e Efeitos

### 16.1. Suspensão

O GLOP poderá suspender, total ou parcialmente, o acesso, imediatamente e independentemente de notificação prévia, em caso de: (i) risco à segurança, à integridade ou à disponibilidade da Plataforma; (ii) suspeita fundada de fraude, ilicitude ou violação destes Termos; (iii) ordem de autoridade competente; ou (iv) inadimplência (item 6.6).

### 16.2. Rescisão pelo Usuário

O Usuário pode rescindir a qualquer tempo, mediante solicitação pelos canais oficiais, observados eventuais compromissos de prazo mínimo (fidelidade) e a quitação de valores devidos até o encerramento.

### 16.3. Rescisão pelo GLOP

O GLOP pode rescindir: (i) por justa causa, em caso de violação não sanada em prazo razoável após notificação; (ii) imediatamente, em caso de violação grave, ilícito, fraude ou risco; ou (iii) sem justa causa, mediante aviso prévio de [30] dias.

### 16.4. Efeitos

Com a rescisão: (i) cessa a licença de uso; (ii) tornam-se imediatamente exigíveis os valores devidos; (iii) aplica-se o procedimento de portabilidade e eliminação de dados do item 17; e (iv) subsistem as cláusulas que, por sua natureza, devam permanecer vigentes (propriedade intelectual, confidencialidade, limitação de responsabilidade, proteção de dados, foro).

---

## 17. Portabilidade, Devolução e Eliminação de Dados no Encerramento

### 17.1. Janela de exportação

Encerrada a relação, o GLOP disponibilizará ao Usuário, por prazo de [15] a [30] dias, a possibilidade de **exportar seus dados e os dados sob sua controladoria** em formato estruturado e interoperável (por exemplo, CSV/JSON), na medida da viabilidade técnica.

### 17.2. Eliminação

Decorrida a janela de exportação, e ressalvadas as retenções obrigatórias, o GLOP procederá à **eliminação ou anonimização** dos dados pessoais tratados como Operador, nos termos do art. 15 e do art. 16 da LGPD e do DPA.

### 17.3. Retenções legais

O GLOP poderá reter dados pelo prazo necessário ao cumprimento de obrigação legal ou regulatória (por exemplo, guarda de registros de acesso a aplicações por 6 meses, art. 15 do Marco Civil; prazos fiscais e prescricionais; exercício regular de direitos em processo), mantendo-os com acesso restrito.

### 17.4. Backups

Cópias em backups seguros serão sobrescritas conforme os ciclos de retenção técnica, período durante o qual permanecerão inacessíveis para uso operacional.

---

## 18. Relação com o Código de Defesa do Consumidor

### 18.1. Natureza B2B

A relação entre o GLOP e o Usuário (produtor/lojista) é, em regra, **empresarial (B2B)**, não se qualificando o Usuário como consumidor final, salvo hipótese excepcional de vulnerabilidade reconhecida judicialmente (teoria finalista mitigada), caso em que se aplicarão as normas cogentes do CDC no que couber.

### 18.2. Relação de consumo do Usuário com o Comprador

Nas relações entre o **Usuário e seus Compradores**, quando configurada relação de consumo, aplica-se o **CDC**, sendo o Usuário o **fornecedor** responsável perante o Comprador por produto, informação, entrega, trocas, devoluções, direito de arrependimento (art. 49 do CDC) e atendimento. O GLOP é mero prestador de ferramenta tecnológica e não integra a cadeia de fornecimento perante o Comprador.

### 18.3. Portal de rastreio

O portal público de rastreio destina-se a fornecer ao Comprador informação de status de entrega, em observância ao dever de informação (art. 6º, III, do CDC), expondo apenas status neutro, sem PII sensível, cabendo ao Usuário garantir a licitude e a adequação das notificações que dispara.

---

## 19. Alterações destes Termos

### 19.1. Direito de alteração

O GLOP pode alterar estes Termos para refletir mudanças legais, regulatórias, técnicas, de segurança, de integrações ou de modelo de negócio.

### 19.2. Comunicação

Alterações materialmente relevantes serão comunicadas com antecedência mínima de [30] dias, por e-mail e/ou aviso na Plataforma, indicando a nova versão e a data de vigência.

### 19.3. Aceite tácito

O uso continuado da Plataforma após a vigência da nova versão implica aceite. Caso não concorde, o Usuário poderá rescindir sem ônus antes da vigência, observado o item 17.

---

## 20. Comunicações e Notificações

### 20.1. Canais

As comunicações do GLOP ao Usuário serão feitas por e-mail cadastrado, avisos na Plataforma ou notificação in-app. As comunicações do Usuário ao GLOP serão feitas pelos canais oficiais indicados em [URL DO SITE] e no item 24.

### 20.2. Validade

As partes reconhecem a validade jurídica das comunicações eletrônicas para todos os fins destes Termos, presumindo-se recebidas quando enviadas ao endereço cadastrado, salvo falha comprovada de entrega.

### 20.3. Atualização de contato

O Usuário deve manter seus dados de contato atualizados, respondendo pelas consequências da desatualização.

---

## 21. Disposições Gerais

### 21.1. Cessão

O Usuário não poderá ceder ou transferir estes Termos sem anuência prévia e escrita do GLOP. O GLOP poderá cedê-los, no todo ou em parte, a empresas do seu grupo econômico ou em operações societárias, mediante comunicação, preservados os direitos do Usuário.

### 21.2. Independência das cláusulas (nulidade parcial)

A eventual nulidade ou ineficácia de qualquer cláusula não prejudica as demais, que permanecem válidas, comprometendo-se as partes a substituir a cláusula inválida por outra que preserve, na medida do possível, o seu efeito econômico e jurídico.

### 21.3. Tolerância

A tolerância quanto ao descumprimento de qualquer obrigação não constitui novação, renúncia ou alteração do pactuado, podendo a parte exigir o cumprimento a qualquer tempo.

### 21.4. Acordo integral

Estes Termos, com a Política de Privacidade, o DPA, o SLA e a proposta/plano contratado, constituem o acordo integral entre as partes quanto ao objeto, prevalecendo sobre entendimentos anteriores.

### 21.5. Força maior

Nenhuma parte responde por inadimplemento decorrente de caso fortuito ou força maior (art. 393 do Código Civil), incluindo, sem limitação, falhas generalizadas de internet, energia, ataques cibernéticos de larga escala, atos de autoridade, greves, pandemias e indisponibilidades de Sub-operadores de Infraestrutura (Supabase, Netlify) ou de terceiros integrados fora do controle razoável.

### 21.6. Ausência de vínculo

Estes Termos não criam vínculo societário, empregatício, de mandato, franquia ou responsabilidade solidária entre as partes, que atuam de forma independente.

### 21.7. Idioma

A versão em português do Brasil prevalece sobre eventuais traduções.

---

## 22. Lei Aplicável e Foro

### 22.1. Lei aplicável

Estes Termos são regidos e interpretados conforme as leis da República Federativa do Brasil.

### 22.2. Solução amigável

As partes envidarão esforços para solucionar controvérsias de forma amigável, admitindo-se mediação prévia.

### 22.3. Foro

Fica eleito o foro da Comarca de [CIDADE/UF DA SEDE], com renúncia a qualquer outro, por mais privilegiado que seja, para dirimir controvérsias oriundas destes Termos, ressalvadas as hipóteses de competência legal cogente (por exemplo, foro do consumidor, quando aplicável).

---

## 23. Documentos Acessórios e Ordem de Prevalência

Integram estes Termos: (i) a Política de Privacidade; (ii) o DPA; (iii) o SLA; e (iv) a proposta comercial/plano contratado. Em caso de conflito, prevalece, quanto à matéria específica: o DPA para proteção de dados; o SLA para níveis de serviço; a proposta/plano para preços e limites; e estes Termos para as demais matérias.

---

## 24. Contato

- **Suporte e assuntos contratuais:** [E-MAIL DO DPO/ENCARREGADO] ou canais indicados em [URL DO SITE].
- **Encarregado (DPO):** [NOME DO ENCARREGADO] — [E-MAIL DO DPO/ENCARREGADO].
- **Endereço:** [ENDEREÇO COMPLETO].

---

## 25. Engenharia Jurídica & Governança

### (a) Fundamentação — por que as principais cláusulas existem e qual lei/norma as embasa

- **Dualidade Controlador/Operador (itens 7.3 e 8):** decorre dos arts. 5º (VI, VII), 37, 39 e 42 da **LGPD**. O GLOP é Operador quanto ao dado do Comprador (trata "em nome" do Usuário) e Controlador quanto aos dados dos seus próprios clientes/colaboradores. Definir isso por escrito é exigência prática para alocar responsabilidade solidária/subsidiária (art. 42) e para a defesa perante a ANPD.
- **Base legal e consentimento a cargo do Usuário (item 7.3):** arts. 7º, 8º, 9º, 11 e 18 da **LGPD**. Como o Usuário define finalidades e meios da coleta nos checkouts (Monetizze, Hotmart, Kiwify) e e-commerces, é dele o ônus da base legal; a cláusula transfere corretamente esse dever e sustenta o hold harmless (item 7.8).
- **Licença SaaS não exclusiva/intransferível (item 5):** **Lei 9.609/1998** (proteção do software) e **Lei 9.610/1998**. Software é licenciado, não vendido; veda-se engenharia reversa e sublicenciamento.
- **Propriedade intelectual (item 11):** Leis 9.279/1996 (marca), 9.609/1998 e 9.610/1998. Protege marca GLOP, código e layout.
- **Preços, reajuste e mora (item 6):** arts. 315, 317, 389, 394, 395 e 406 do **Código Civil**; liberdade de contratar (art. 421); reajuste por índice (IPCA) por analogia à prática contratual e à Lei 10.192/2001 (periodicidade anual).
- **Limitação de responsabilidade e teto (item 14):** arts. 393, 402, 403 e 944 do **Código Civil**; em contrato empresarial paritário (B2B), cláusulas limitativas são válidas, ressalvados dolo e direitos indisponíveis. A ressalva do item 14.5 evita nulidade por abusividade.
- **Isenção quanto a terceiros integrados (item 10):** art. 393 do CC e princípio da responsabilidade por fato próprio; o GLOP não responde por Correios (falhas de entrega), AppMax (split/repasse), VHSYS/SEFAZ (fisco) e provedores de checkout.
- **CDC (item 18):** **Lei 8.078/1990**, arts. 2º, 3º, 6º (III), 14 e 49. A relação GLOP–Usuário é B2B (teoria finalista); a relação Usuário–Comprador é de consumo, com o Usuário como fornecedor.
- **Marco Civil (itens 8, 17.3, 20):** **Lei 12.965/2014**, arts. 7º, 10, 11 e 15 (guarda de registros de acesso por 6 meses; validade de comunicações eletrônicas).
- **Alterações e aceite eletrônico (itens 3.1 e 19):** **MP 2.200-2/2001** (validade jurídica de documentos eletrônicos) e arts. 104 e ss. do CC.
- **Foro e solução de conflitos (item 22):** art. 63 do CPC (eleição de foro em contrato empresarial), ressalvado o foro do consumidor.
- **GDPR (item 8.1):** Regulamento (UE) 2016/679 — aplicável se houver titulares/operações na UE (arts. 3, 28, 44-49 para operador e transferências internacionais).
- **Referências de segurança (item 8.5):** ISO/IEC 27001, 27701, 22301, 31000; NIST CSF; OWASP; SOC 2; Zero Trust — sustentam a alegação de "medidas compatíveis com o estado da técnica" (art. 46 da LGPD) sem prometer certificação não detida.

### (b) Riscos que o documento mitiga

1. **Responsabilização do GLOP por tratamento ilícito do Usuário** — mitigado ao fixar a controladoria do Usuário e o dever de base legal (itens 7.3, 8.2, 7.8).
2. **Solidariedade indevida em ações da ANPD/Procon** — mitigado pela delimitação Operador/Controlador e pela indenização (item 7.8).
3. **Responsabilização por falhas de Correios, AppMax, VHSYS e checkouts** — mitigado pela isenção quanto a terceiros (item 10) e força maior (21.5).
4. **Exposição indevida de PII no portal público** — mitigado pela restrição a status neutro (itens 2.2.6, 8.5, 18.3).
5. **Vazamento cross-tenant** — endereçado por RLS/RBAC e trilha de auditoria (itens 2.2.8, 4.5, 8.5).
6. **Inadimplência sem previsão de suspensão** — mitigado pelos itens 6.5 e 6.6.
7. **Cópia/engenharia reversa do software** — vedado (item 5.3).
8. **Litígio sobre alteração unilateral de termos** — mitigado por comunicação prévia e aceite tácito (item 19).
9. **Perda/lock-in de dados no encerramento** — mitigado por portabilidade e eliminação (item 17).
10. **Nulidade de cláusula limitativa** — mitigado pela ressalva de direitos indisponíveis (item 14.5) e nulidade parcial (item 21.2).
11. **Comunicações não solicitadas (spam) a Compradores** — dever transferido ao Usuário (itens 7.4, 18.3).
12. **Uso do serviço para fins ilícitos** — vedações e rescisão imediata (itens 13, 16.1, 16.3).

### (c) Checklist de implementação

- [ ] Preencher todos os placeholders ([RAZÃO SOCIAL], [CNPJ], [ENDEREÇO COMPLETO], [E-MAIL DO DPO/ENCARREGADO], [NOME DO ENCARREGADO], [URL DO SITE], [CIDADE/UF DA SEDE], [DATA], prazos entre colchetes).
- [ ] Publicar e vincular a Política de Privacidade, o DPA e o SLA (itens 8.3, 9.2, 23).
- [ ] Implementar registro de aceite eletrônico com data, versão, IP e identificação do aceitante (item 3.1).
- [ ] Configurar fluxo de comunicação de novas versões com antecedência mínima (item 19.2).
- [ ] Validar tela do portal público de rastreio para não expor PII sensível (itens 2.2.6, 18.3).
- [ ] Confirmar armazenamento write-only de credenciais de integração (item 4.4).
- [ ] Documentar sub-operadores no DPA (Supabase, Netlify, Correios, VHSYS, AppMax, checkouts) e cláusulas de transferência internacional, se houver (itens 8.4, 8.1).
- [ ] Implementar exportação de dados (CSV/JSON) e rotina de eliminação/anonimização pós-encerramento (item 17).
- [ ] Parametrizar multa/juros/reajuste e gatilho de suspensão por inadimplência no faturamento (item 6).
- [ ] Revisão final por advogado(a) habilitado(a) antes de produção (aviso da minuta).
- [ ] Definir índice de disponibilidade e severidades no SLA (item 9.2).
- [ ] Validar conformidade das notificações a Compradores (e-mail/WhatsApp) com LGPD e CDC (itens 7.4, 18.3).

### (d) Matriz RACI

| Atividade | Jurídico | DPO/Encarregado | Produto/Eng. | Comercial/Financeiro | CEO/Diretoria |
|---|---|---|---|---|---|
| Redação e revisão dos Termos | A/R | C | C | C | I |
| Preenchimento de placeholders e dados societários | R | I | I | C | A |
| Política de Privacidade e DPA | C | A/R | C | I | I |
| Definição e publicação do SLA | C | I | A/R | C | I |
| Implementação de aceite eletrônico e versionamento | C | C | A/R | I | I |
| Configuração de RLS/RBAC/auditoria/write-only | I | C | A/R | I | I |
| Faturamento, reajuste, mora e suspensão | C | I | C | A/R | I |
| Gestão de sub-operadores e transferências internacionais | C | A/R | C | I | I |
| Resposta a incidentes de dados | C | A/R | R | I | A |
| Portabilidade e eliminação no encerramento | C | A/R | R | C | I |
| Aprovação final para produção | A | C | I | I | R |

Legenda: R = Responsável (executa); A = Aprovador (responde); C = Consultado; I = Informado.

### (e) Plano de revisão

- **Periodicidade ordinária:** revisão a cada 12 meses.
- **Gatilhos de revisão extraordinária:**
  - alteração legislativa ou regulatória (novas resoluções da ANPD, reforma do CDC/Marco Civil, mudanças no GDPR);
  - inclusão, alteração ou descontinuação de integração ou sub-operador (ex.: novo checkout, troca de gateway de split, mudança de hospedagem);
  - lançamento de novo módulo ou funcionalidade com impacto em dados ou responsabilidade;
  - incidente de segurança relevante ou determinação de autoridade;
  - alteração de modelo comercial, planos ou política de preços;
  - decisão judicial/administrativa que afete cláusula do documento.
- **Responsável pelo monitoramento:** DPO/Encarregado, com apoio do Jurídico.

### (f) Controle de versão

| Versão | Data | Autor | Mudança |
|---|---|---|---|
| 1.0 | [DATA] | Chief Legal AI (minuta) | Elaboração inicial dos Termos de Uso do GLOP (SaaS logístico B2B), cobrindo objeto, licença SaaS, planos e inadimplência, obrigações do Usuário e dualidade Controlador/Operador, integrações de terceiros, PI, limitação de responsabilidade, CDC, rescisão e eliminação de dados. |
| — | — | [NOME DO REVISOR] | Revisão jurídica humana pendente antes de produção. |

---

Documento sujeito a revisão jurídica humana. As referências normativas refletem a legislação brasileira vigente na data de elaboração e devem ser reavaliadas periodicamente.
