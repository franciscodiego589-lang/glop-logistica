> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# CONTRATO DE LICENCIAMENTO DE PLATAFORMA SOB MARCA DO PARCEIRO (WHITE LABEL) — GLOP (GLOBAL LOGISTICS PLATFORM)

**Versão:** 1.0 · **Data-base:** 16 de julho de 2026 · **Referência interna:** GLOP-WL-[NÚMERO]

Este Contrato de Licenciamento de Plataforma sob Marca do Parceiro ("**Contrato White Label**", "**Contrato**") tem por finalidade regular a licença de uso, sob marca e identidade visual do Parceiro, da plataforma SaaS de logística e gestão de pedidos denominada **GLOP — Global Logistics Platform**, destinada a operações de dropshipping, infoprodutos, e-commerce, expedição e rastreamento no Brasil.

---

## 1. QUALIFICAÇÃO DAS PARTES

### 1.1. LICENCIANTE (proprietária e mantenedora da plataforma GLOP)

**LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA**, sociedade empresária inscrita no CNPJ sob o nº **55.836.075/0001-07**, com sede em **Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190**, doravante denominada "**LICENCIANTE**", "**GLOP**" ou "**Fornecedora**", detentora dos direitos sobre a plataforma **[NOME FANTASIA: GLOP]**, neste ato representada na forma de seus atos constitutivos.

### 1.2. LICENCIADO / PARCEIRO WHITE LABEL

**[CONTRATANTE]**, inscrito(a) no CNPJ/CPF sob o nº **55.836.075/0001-07**, com sede/domicílio em **Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190**, doravante denominado(a) "**PARCEIRO**", "**LICENCIADO**" ou "**Revendedor White Label**", neste ato representado(a) na forma de seus atos constitutivos ou por si.

### 1.3. Denominação conjunta

LICENCIANTE e PARCEIRO, quando referidos em conjunto, serão denominados "**Partes**" e, isoladamente, "**Parte**".

### 1.4. Declarações de capacidade

Cada **[PARTE]** declara que: (a) possui plena capacidade jurídica e poderes para celebrar este Contrato; (b) seus representantes signatários estão devidamente autorizados; (c) inexiste impedimento legal, contratual ou regulatório à assinatura e execução deste instrumento; e (d) as informações cadastrais fornecidas são verdadeiras, completas e atualizadas.

---

## 2. DEFINIÇÕES

Para os fins deste Contrato, os termos abaixo, no singular ou plural, terão os seguintes significados:

| Termo | Definição |
|---|---|
| **Plataforma GLOP** | Sistema SaaS multi-tenant de logística/ERP desenvolvido em Next.js (App Router) sobre Supabase (PostgreSQL) com RLS multi-tenant (Tenant→Company→Branch→Membership), Supabase Auth (JWT) e Storage, hospedado em ambiente SSR na Netlify, incluindo módulos de ingestão de pedidos, expedição, rastreamento, coprodução/split e emissão fiscal. |
| **White Label / Marca do Parceiro** | Modo de disponibilização da Plataforma sob marca, logotipo, cores, domínio e identidade visual do PARCEIRO, sem exibição ostensiva da marca GLOP ao usuário final do PARCEIRO. |
| **Cliente Final** | Pessoa física ou jurídica (produtor, lojista, dropshipper, infoprodutor) que contrata o PARCEIRO e utiliza a Plataforma sob a marca do PARCEIRO. |
| **Comprador** | Consumidor final que adquire produtos/serviços do Cliente Final e cujos dados pessoais (nome, CPF/CNPJ, e-mail, telefone, endereço, produto, valor) são tratados na Plataforma para fins logísticos. |
| **Tenant** | Espaço lógico isolado por RLS que agrega as empresas (Company) e filiais (Branch) de um mesmo grupo/organização na Plataforma. |
| **Sub-operadores / Suboperadores** | Terceiros contratados pela LICENCIANTE para viabilizar a operação: Supabase e Netlify (infraestrutura/hospedagem), VHSYS (NF-e), Correios (transporte, PPN/SRO), gateways de pagamento (Monetizze, AppMax, Hotmart, Kiwify) e provedores de notificação (WhatsApp/e-mail). |
| **Instância White Label** | Ambiente configurado para o PARCEIRO, com sua marca, domínio e conjunto de Clientes Finais/tenants. |
| **Customização** | Ajustes permitidos de identidade visual, textos, domínio, e-mails transacionais e parâmetros de configuração, nos limites da Cláusula 6. |
| **Dados Pessoais**, **Controlador**, **Operador**, **Titular**, **Tratamento**, **Incidente** | Terão o significado atribuído pela Lei nº 13.709/2018 (LGPD). |
| **DPA** | Acordo/Adendo de Proteção de Dados (Data Processing Agreement) que integra este Contrato como anexo, disciplinando papéis de Controlador/Operador, subtratamento e segurança. |
| **Portal Público de Rastreio** | Página pública, sem autenticação, que expõe exclusivamente status neutro de entrega, sem PII do Comprador. |
| **Uptime / Disponibilidade** | Percentual de tempo em que a Plataforma está operacional, apurado conforme o SLA da Cláusula 9. |
| **Taxa de Licenciamento** | Contraprestação financeira devida pelo PARCEIRO pela licença White Label, conforme Cláusula 11. |

---

## 3. OBJETO

### 3.1. Objeto principal

Constitui objeto deste Contrato a concessão, pela LICENCIANTE ao PARCEIRO, de **licença de uso não exclusiva, intransferível e temporária** da Plataforma GLOP, disponibilizada no modelo **White Label** — isto é, sob a marca, identidade visual e domínio do PARCEIRO — para que o PARCEIRO a comercialize e disponibilize aos seus Clientes Finais como se fosse solução própria, nos limites e condições aqui pactuados.

### 3.2. Natureza do licenciamento

A licença abrange o **direito de acesso e uso** da Plataforma como serviço (SaaS), não implicando: (a) cessão ou transferência de titularidade sobre o software, código-fonte, arquitetura, banco de dados ou propriedade intelectual da LICENCIANTE; (b) entrega de código-fonte, salvo cláusula de custódia (escrow) expressa; nem (c) qualquer direito além do estritamente licenciado nesta avença.

### 3.3. Escopo funcional licenciado

A licença compreende, conforme o plano contratado, os seguintes fluxos reais da Plataforma:

1. **Ingestão de pedidos via API** dos gateways e e-commerces integrados (Monetizze, Hotmart, Kiwify) e plataformas de e-commerce (Shopify, WooCommerce, Nuvemshop, Mercado Livre), com recebimento de dados do Comprador (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor);
2. **Módulo de expedição e Correios**: pré-postagem (PPN), rastreamento (SRO) e notificação ao Comprador por e-mail/WhatsApp;
3. **Coprodução e Split**: gestão de coprodutores/afiliados, comissões, apuração, repasses e split (via AppMax), incluindo dados bancários/PIX quando aplicável;
4. **Emissão de documentos fiscais (NF-e)** via VHSYS;
5. **Portal Público de Rastreio** sem login, exibindo somente status neutro;
6. Recursos de segurança e governança: isolamento por RLS por empresa, RBAC (has_permission), soft-delete, trilha de auditoria por triggers, colunas de auditoria em todo registro e credenciais de API armazenadas em modo write-only.

### 3.4. Modelo multi-tenant sob a marca do Parceiro

A Plataforma será disponibilizada respeitando a arquitetura multi-tenant **Tenant→Company→Branch→Membership**, de modo que a Instância White Label do PARCEIRO e cada Cliente Final permaneçam isolados logicamente por RLS, sem que o frontend seja fonte de confiança para segregação de dados.

### 3.5. Exclusões do objeto

Salvo pactuação expressa em Anexo, **não integram** o objeto: desenvolvimento sob demanda de novos módulos, integrações com sistemas de terceiros não listados, migração de dados legados, consultoria de negócio, marketing do PARCEIRO, atendimento direto aos Compradores e obtenção de licenças/credenciais junto a gateways, Correios ou VHSYS em nome do PARCEIRO.

---

## 4. FORMA DE DISPONIBILIZAÇÃO E PROVISIONAMENTO

### 4.1. Provisionamento da Instância White Label

A LICENCIANTE provisionará a Instância White Label em prazo de até **[NÚMERO] dias úteis** contados da confirmação do pagamento do setup (quando houver) e do recebimento, pelo PARCEIRO, dos elementos de marca (Cláusula 6) e das credenciais/integrações necessárias.

### 4.2. Domínio e certificados

O PARCEIRO poderá apontar domínio/subdomínio próprio para a Instância White Label. A emissão e renovação de certificados TLS observarão a infraestrutura SSR da Netlify. O PARCEIRO é responsável pela titularidade e manutenção do registro de seu domínio.

### 4.3. Ambiente e infraestrutura

A Plataforma é hospedada em ambiente SSR na Netlify, com banco de dados e autenticação em Supabase (PostgreSQL). A LICENCIANTE poderá, a seu critério técnico, alterar sub-operadores de infraestrutura, mantendo padrão de segurança e disponibilidade equivalente ou superior e observando o procedimento de subtratamento do DPA (Cláusula 8).

### 4.4. Credenciais e integrações

As credenciais de API de gateways, Correios e VHSYS utilizadas pelo PARCEIRO/Clientes Finais são armazenadas em modo **write-only** na Plataforma, não sendo recuperáveis em texto claro. O PARCEIRO declara possuir contratos e autorizações válidas junto a esses provedores, respondendo por sua regularidade.

---

## 5. PROPRIEDADE INTELECTUAL

### 5.1. Titularidade da LICENCIANTE

Todos os direitos de propriedade intelectual e industrial sobre a Plataforma GLOP — incluindo, sem limitação, código-fonte e objeto, arquitetura de software, esquema e migrações de banco de dados, estrutura multi-tenant/RLS, lógica de RBAC, funções, triggers, algoritmos, APIs, documentação técnica, fluxos, know-how, marca "GLOP" e sinais distintivos da LICENCIANTE — são e permanecerão de **titularidade exclusiva da LICENCIANTE**, protegidos pela Lei nº 9.609/1998 (Software), Lei nº 9.610/1998 (Direitos Autorais) e Lei nº 9.279/1996 (Propriedade Industrial).

### 5.2. Reserva de direitos

Nenhuma disposição deste Contrato transfere, cede ou licencia ao PARCEIRO qualquer direito de propriedade intelectual da LICENCIANTE além do direito de uso limitado descrito na Cláusula 3. Todos os direitos não expressamente concedidos permanecem reservados à LICENCIANTE.

### 5.3. Marca do Parceiro

A marca, logotipo, identidade visual, nome de domínio e sinais distintivos do PARCEIRO são e permanecerão de titularidade do PARCEIRO. O PARCEIRO concede à LICENCIANTE licença limitada, não exclusiva e temporária, restrita ao estritamente necessário para aplicar tais elementos na Instância White Label e operá-la (branding, e-mails transacionais, portal de rastreio).

### 5.4. Vedação à marca GLOP no White Label

No modo White Label, a LICENCIANTE não exibirá ostensivamente a marca GLOP ao usuário final do PARCEIRO, ressalvadas: (a) referências técnicas internas; (b) menções exigidas por lei ou por sub-operadores; e (c) marca d'água/rodapé discreto de "powered by" quando expressamente pactuado em Anexo.

### 5.5. Melhorias, feedbacks e trabalhos derivados

Toda evolução, correção, nova funcionalidade, integração ou melhoria da Plataforma, ainda que sugerida, solicitada ou custeada pelo PARCEIRO, incorpora-se à Plataforma e pertence exclusivamente à LICENCIANTE, salvo pactuação diversa por escrito. O PARCEIRO cede à LICENCIANTE, em caráter gratuito e irrevogável, os direitos sobre feedbacks e sugestões que fornecer.

### 5.6. Vedação a engenharia reversa

É vedado ao PARCEIRO e a seus Clientes Finais: descompilar, desmontar, aplicar engenharia reversa, extrair código-fonte, copiar a arquitetura, criar obras derivadas não autorizadas, remover avisos de propriedade ou tentar burlar mecanismos de RLS/RBAC, salvo nos estritos limites do art. 6º da Lei nº 9.609/1998.

### 5.7. Propriedade dos dados

Os dados de negócio, cadastros e Dados Pessoais tratados na Instância White Label pertencem ao respectivo Cliente Final/Comprador (conforme titularidade e papel de Controlador), não constituindo propriedade intelectual da LICENCIANTE. A titularidade do software não se confunde com a titularidade dos dados nele armazenados.

---

## 6. LIMITES DE CUSTOMIZAÇÃO

### 6.1. Customizações permitidas

O PARCEIRO poderá customizar, dentro dos parâmetros disponibilizados pela LICENCIANTE:

1. Logotipo, favicon, paleta de cores, tipografia e identidade visual da interface;
2. Nome/domínio da Instância White Label;
3. Textos institucionais, rótulos e conteúdos de e-mails/WhatsApp transacionais (respeitados os campos técnicos obrigatórios);
4. Layout do Portal Público de Rastreio, mantida a exibição exclusiva de status neutro, sem PII do Comprador;
5. Parâmetros de configuração de negócio expostos na Plataforma (regras de expedição, políticas de notificação, perfis de RBAC dentro dos papéis disponíveis).

### 6.2. Customizações vedadas ou condicionadas

Salvo pactuação específica por escrito, é vedado ao PARCEIRO:

1. Alterar código-fonte, banco de dados, políticas de RLS, funções ou triggers da Plataforma;
2. Modificar a arquitetura multi-tenant ou os mecanismos de RBAC/auditoria;
3. Expor, no Portal Público de Rastreio, quaisquer dados além do status neutro (nome do Comprador, endereço, itens, valores ou CPF são expressamente vedados);
4. Inserir scripts, pixels ou integrações que comprometam a segurança, a LGPD ou o isolamento de tenants;
5. Customizar textos de forma a induzir o Comprador a erro, violar o CDC ou a legislação de proteção de dados.

### 6.3. Customizações sob demanda

Personalizações que demandem desenvolvimento (novos módulos, integrações adicionais, relatórios específicos) serão objeto de proposta técnica e comercial apartada, com preço, prazo e titularidade regidos pela Cláusula 5.5.

### 6.4. Padrão de segurança inalterável

As customizações não poderão, em hipótese alguma, degradar os controles de segurança da Plataforma (RLS por empresa, RBAC, soft-delete, trilha de auditoria por triggers, colunas de auditoria e credenciais write-only), que constituem núcleo indissociável do serviço.

---

## 7. OBRIGAÇÕES DAS PARTES

### 7.1. Obrigações da LICENCIANTE

1. Disponibilizar a Plataforma GLOP no modo White Label, operacional e conforme o escopo da Cláusula 3;
2. Provisionar e manter a Instância White Label, aplicando a identidade visual do PARCEIRO;
3. Manter os fluxos reais (ingestão de pedidos, expedição/Correios, coprodução/split, NF-e, portal de rastreio) em funcionamento conforme SLA (Cláusula 9);
4. Adotar e manter as medidas técnicas e organizacionais de segurança descritas neste Contrato e no DPA (RLS, RBAC, soft-delete, auditoria por triggers, credenciais write-only, colunas de auditoria);
5. Prestar suporte de 2º nível (backend/plataforma) ao PARCEIRO, conforme Cláusula 10;
6. Comunicar ao PARCEIRO incidentes de segurança e indisponibilidades relevantes, nos prazos do DPA e da Cláusula 9;
7. Manter contratos válidos com os sub-operadores de infraestrutura e observar o procedimento de subtratamento;
8. Fornecer documentação de uso e materiais técnicos necessários à operação do PARCEIRO;
9. Preservar a confidencialidade (Cláusula 12) e cumprir a LGPD no papel que lhe couber (Cláusula 8).

### 7.2. Obrigações do PARCEIRO

1. Pagar pontualmente a Taxa de Licenciamento e demais valores (Cláusula 11);
2. Comercializar a Plataforma aos Clientes Finais de forma lícita, verídica e conforme o CDC, sem prometer funcionalidades inexistentes ou desempenho não garantido;
3. Prestar suporte de 1º nível aos seus Clientes Finais (atendimento, dúvidas de uso, triagem), escalando à LICENCIANTE apenas o que exceder sua alçada (Cláusula 10);
4. Fornecer credenciais e autorizações válidas junto a gateways (Monetizze, AppMax, Hotmart, Kiwify), Correios e VHSYS, respondendo por sua regularidade;
5. Cumprir a LGPD e o DPA no papel de Controlador ou de intermediário perante seus Clientes Finais (Cláusula 8), obtendo bases legais e transparência adequadas junto aos Titulares;
6. Não realizar customizações vedadas (Cláusula 6.2) nem burlar mecanismos de segurança/RLS;
7. Manter seus cadastros atualizados e utilizar a Plataforma conforme a Política de Uso Aceitável (Cláusula 7.3);
8. Responder pela relação jurídica e pelo faturamento com seus Clientes Finais, incluindo tributos incidentes sobre sua própria receita;
9. Preservar a confidencialidade e a propriedade intelectual da LICENCIANTE (Cláusulas 5 e 12);
10. Repassar aos Clientes Finais, por escrito, os termos, limitações e responsabilidades pertinentes decorrentes deste Contrato (efeito back-to-back).

### 7.3. Política de Uso Aceitável (PUA)

O PARCEIRO e seus Clientes Finais não poderão utilizar a Plataforma para: (a) atividades ilícitas, fraudulentas ou que violem direitos de terceiros; (b) comercialização de produtos proibidos ou de origem ilícita; (c) envio de comunicações em desacordo com a LGPD/legislação anti-spam; (d) sobrecarga proposital, testes de intrusão não autorizados ou tentativas de acesso a dados de outros tenants; (e) tratamento de Dados Pessoais sem base legal. O descumprimento autoriza suspensão imediata (Cláusula 13.4).

---

## 8. PROTEÇÃO DE DADOS PESSOAIS (LGPD) — REMISSÃO AO DPA

### 8.1. Marco legal

O tratamento de Dados Pessoais na Plataforma observa a Lei nº 13.709/2018 (LGPD), a Lei nº 12.965/2014 (Marco Civil da Internet), o CDC e, quando aplicável, o GDPR, sendo regido em detalhe pelo **DPA — Acordo de Proteção de Dados**, anexo e parte integrante deste Contrato. Em caso de conflito sobre proteção de dados, prevalece o DPA.

### 8.2. Papéis das Partes (dupla natureza)

A Plataforma opera em dupla natureza quanto à proteção de dados:

1. **Operador**: em relação aos dados do **Comprador** (nome, CPF/CNPJ, e-mail, telefone, endereço, produto, valor) tratados para fins logísticos, a LICENCIANTE atua como **Operador** e o Cliente Final (produtor/lojista), intermediado pelo PARCEIRO, como **Controlador**. O PARCEIRO, ao ofertar a solução a seus Clientes Finais, atua como elo da cadeia, devendo assegurar que cada Cliente Final assuma formalmente a posição de Controlador;
2. **Controlador**: em relação aos dados de cadastro e acesso dos próprios usuários/colaboradores do PARCEIRO e de seus Clientes Finais (identificação, login, permissões), cada Parte é Controladora dos dados que coleta para gestão da própria relação.

### 8.3. Sub-operadores autorizados

O PARCEIRO autoriza, de forma geral e prévia, a contratação, pela LICENCIANTE, dos sub-operadores necessários à prestação: Supabase e Netlify (infraestrutura/hospedagem), VHSYS (NF-e), Correios (transporte, PPN/SRO), gateways (Monetizze, AppMax, Hotmart, Kiwify) e provedores de WhatsApp/e-mail. A LICENCIANTE manterá lista atualizada dos sub-operadores no DPA e comunicará alterações relevantes, garantindo obrigações de proteção equivalentes.

### 8.4. Medidas de segurança

A LICENCIANTE adota, no mínimo: isolamento por RLS por empresa (multi-tenant), controle de acesso por RBAC (has_permission), soft-delete (vedado DELETE físico), trilha de auditoria por triggers, colunas de auditoria em todo registro, credenciais de API armazenadas em modo write-only e minimização de dados no Portal Público de Rastreio (status neutro, sem PII). As Partes comprometem-se a manter medidas técnicas e organizacionais compatíveis com o art. 46 da LGPD.

### 8.5. Incidentes de segurança

Verificado incidente com Dados Pessoais, a LICENCIANTE notificará o PARCEIRO sem demora injustificada e, quando atuar como Operador, prestará apoio ao Controlador para as comunicações à ANPD e aos Titulares, conforme o DPA. Os prazos, o conteúdo mínimo da notificação e as responsabilidades de cada Parte constam do DPA.

### 8.6. Direitos dos Titulares e Encarregado

Requisições de Titulares (acesso, correção, eliminação, portabilidade, oposição) serão encaminhadas ao Controlador competente, cabendo à LICENCIANTE, como Operador, apoiar tecnicamente o atendimento. O Encarregado (DPO) da LICENCIANTE é **a ser designado pela administração**, contato **lemoncapsencapsulados@gmail.com**. O PARCEIRO indicará seu próprio Encarregado quando atuar como Controlador.

### 8.7. Transferência internacional e retenção

Eventuais transferências internacionais decorrentes dos sub-operadores observarão os arts. 33 a 36 da LGPD e as salvaguardas do DPA. A retenção e a eliminação dos dados após o término contratual seguem a Cláusula 14 e o DPA.

---

## 9. NÍVEL DE SERVIÇO (SLA) E DISPONIBILIDADE

### 9.1. Meta de disponibilidade

A LICENCIANTE envidará esforços para manter a Plataforma com disponibilidade mensal de **[NÚMERO]% (por exemplo, 99,5%)**, apurada mensalmente, excluídas as janelas de manutenção programada e as hipóteses de exclusão da Cláusula 9.4.

### 9.2. Manutenções programadas

Manutenções programadas serão comunicadas com antecedência mínima de **[NÚMERO] horas**, preferencialmente em horário de menor uso, e não serão computadas como indisponibilidade.

### 9.3. Créditos de serviço

O descumprimento da meta de disponibilidade, apurado mensalmente, poderá ensejar crédito de serviço na fatura subsequente, conforme tabela do Anexo de SLA, limitado a **[NÚMERO]%** da mensalidade do período afetado, constituindo tal crédito o remédio exclusivo por indisponibilidade, sem prejuízo do disposto na Cláusula 15.

### 9.4. Exclusões de SLA

Não configuram indisponibilidade imputável à LICENCIANTE: (a) falhas de sub-operadores de terceiros fora de seu controle razoável (gateways, Correios, VHSYS, provedores de WhatsApp/e-mail); (b) caso fortuito ou força maior; (c) uso indevido, customização vedada ou culpa do PARCEIRO/Cliente Final; (d) falhas de conectividade, domínio ou infraestrutura do PARCEIRO; (e) suspensão legítima por inadimplência ou violação da PUA.

### 9.5. Dependência de terceiros

As Partes reconhecem que fluxos como emissão de NF-e (VHSYS), postagem/rastreio (Correios) e liquidação/split (gateways) dependem de sistemas de terceiros, cujas falhas ou indisponibilidades não são imputáveis à LICENCIANTE, ressalvada a obrigação de comunicação e de esforço razoável de contorno.

---

## 10. SUPORTE TÉCNICO

### 10.1. Modelo de suporte em camadas

O suporte observará o modelo em camadas:

1. **1º nível (PARCEIRO)**: atendimento direto aos Clientes Finais e Compradores, triagem, dúvidas de uso, orientação sobre customizações permitidas e primeira resposta;
2. **2º nível (LICENCIANTE)**: suporte de backend/plataforma ao PARCEIRO, para incidentes técnicos, falhas de integração, indisponibilidades e questões que excedam a alçada do PARCEIRO.

### 10.2. Canais e horário

O suporte de 2º nível será prestado pelos canais **[E-MAIL / PORTAL / CANAL]**, em horário comercial **[HORÁRIO E FUSO]**, salvo plantão para incidentes críticos conforme Anexo de SLA.

### 10.3. Prazos de resposta (indicativos)

| Severidade | Descrição | Prazo-alvo de 1ª resposta | Prazo-alvo de contorno |
|---|---|---|---|
| **Crítica (P1)** | Plataforma indisponível ou fluxo essencial parado (ingestão, expedição, split) | [NÚMERO] h | [NÚMERO] h |
| **Alta (P2)** | Degradação relevante sem parada total | [NÚMERO] h | [NÚMERO] h úteis |
| **Média (P3)** | Falha pontual com contorno disponível | [NÚMERO] h úteis | [NÚMERO] dias úteis |
| **Baixa (P4)** | Dúvida, melhoria, item cosmético | [NÚMERO] dias úteis | conforme roadmap |

### 10.4. Responsabilidades sobre dados no suporte

No atendimento, as Partes tratarão Dados Pessoais estritamente conforme a LGPD e o DPA, com registro em trilha de auditoria. A LICENCIANTE não acessará dados de tenant além do necessário à resolução do chamado, observado o princípio da minimização.

### 10.5. Exclusões de suporte

Não integram o suporte: treinamento extensivo, desenvolvimento sob demanda, correção de erros causados por customização vedada ou por integrações/credenciais do PARCEIRO, e atendimento a Compradores (que compete ao Cliente Final/PARCEIRO).

---

## 11. CONDIÇÕES COMERCIAIS, PREÇO E PAGAMENTO

### 11.1. Modelo de remuneração

A remuneração pela licença White Label observará o(s) seguinte(s) componente(s), conforme o Anexo Comercial:

1. **Taxa de setup/implantação** (única): R$ **[VALOR]**;
2. **Taxa de Licenciamento recorrente** (mensal/anual): R$ **[VALOR]** por **[Instância / tenant / Cliente Final / faixa de pedidos]**;
3. **Componente variável** (opcional): R$ **[VALOR]** ou **[PERCENTUAL]%** por **[pedido processado / postagem / NF-e emitida / volume]**, conforme métrica de uso;
4. **Customizações sob demanda**: conforme proposta específica (Cláusula 6.3).

### 11.2. Reajuste

Os valores serão reajustados anualmente pela variação do **[IPCA/IGP-M ou índice pactuado]**, ou pelo índice que o substituir, a contar da data-base deste Contrato, na menor periodicidade permitida em lei.

### 11.3. Faturamento e vencimento

O faturamento será **[mensal/anual]**, com vencimento no dia **[NÚMERO]**, mediante **[boleto / PIX / cartão / gateway]**. A apuração do componente variável considerará os registros da Plataforma (métricas de uso), disponibilizados ao PARCEIRO para conferência.

### 11.4. Tributos

Os preços **[incluem/não incluem]** tributos incidentes sobre a prestação. Cada Parte é responsável pelos tributos que a lei lhe atribuir. Havendo retenção legal, observar-se-á a legislação aplicável, com os devidos comprovantes.

### 11.5. Inadimplência

O atraso no pagamento sujeita o PARCEIRO a: (a) multa moratória de **[NÚMERO]%** sobre o valor em aberto; (b) juros de mora de **1% ao mês** (ou o pactuado); (c) correção monetária; e (d) após **[NÚMERO] dias** de atraso, faculta à LICENCIANTE suspender o acesso (Cláusula 13.4), sem prejuízo da rescisão por inadimplemento (Cláusula 13.3).

### 11.6. Repasses, split e dados financeiros

Quando o PARCEIRO/Clientes Finais operarem coprodução, comissões e split (via AppMax), com dados de PIX/bancários, a LICENCIANTE atua apenas como provedora da funcionalidade de apuração/repasse na Plataforma, **não sendo instituição de pagamento** nem responsável pela liquidação financeira, que compete ao gateway e às Partes envolvidas. A conformidade regulatória financeira é de responsabilidade do PARCEIRO/Cliente Final.

---

## 12. CONFIDENCIALIDADE

### 12.1. Informações Confidenciais

Consideram-se confidenciais todas as informações técnicas, comerciais, financeiras, operacionais e de negócio a que as Partes tenham acesso em razão deste Contrato, incluindo, sem limitação: arquitetura, código, esquema de banco, políticas de RLS/RBAC, credenciais, dados de Clientes Finais e Compradores, preços, métricas, roadmap e know-how.

### 12.2. Deveres

Cada Parte obriga-se a: (a) manter sigilo; (b) usar as Informações Confidenciais apenas para os fins deste Contrato; (c) restringir o acesso a colaboradores/subcontratados com necessidade de conhecer, sob idênticos deveres; e (d) adotar medidas de segurança compatíveis.

### 12.3. Exceções

Não se sujeitam ao dever de sigilo informações que: (a) sejam ou se tornem públicas sem violação; (b) já eram legitimamente conhecidas; (c) sejam desenvolvidas de forma independente; ou (d) devam ser reveladas por ordem legal/judicial, hipótese em que a Parte notificará a outra, quando permitido.

### 12.4. Vigência do sigilo

O dever de confidencialidade vigora durante o Contrato e por **[NÚMERO] anos** após seu término, e por prazo indeterminado quanto a segredos de negócio e Dados Pessoais protegidos por lei.

### 12.5. Dados Pessoais

O tratamento de Dados Pessoais recebidos sob sigilo observa, adicionalmente, a Cláusula 8 e o DPA, prevalecendo estes em caso de conflito quanto a Dados Pessoais.

---

## 13. VIGÊNCIA, RENOVAÇÃO, SUSPENSÃO E RESCISÃO

### 13.1. Prazo e vigência

Este Contrato vigora por prazo de **[NÚMERO] meses**, a contar de **16 de julho de 2026**, renovando-se automaticamente por iguais períodos, salvo denúncia por qualquer Parte com antecedência mínima de **[NÚMERO] dias** do termo.

### 13.2. Resilição imotivada

Qualquer Parte poderá resilir imotivadamente o Contrato mediante aviso prévio por escrito de **[NÚMERO] dias**, sem penalidade, ressalvados os valores devidos até a data da efetiva rescisão e as obrigações de saída (Cláusula 14).

### 13.3. Rescisão por inadimplemento (justa causa)

Poderá ser rescindido por justa causa, mediante notificação, em caso de: (a) descumprimento de obrigação relevante não sanada em **[NÚMERO] dias** da notificação; (b) inadimplência financeira reiterada; (c) violação de propriedade intelectual, confidencialidade ou da LGPD/DPA; (d) uso da Plataforma para fins ilícitos ou em violação à PUA; (e) falência, recuperação judicial deferida com risco à execução, ou insolvência.

### 13.4. Suspensão do acesso

A LICENCIANTE poderá suspender, total ou parcialmente, o acesso à Plataforma, mediante aviso quando possível, em caso de: (a) inadimplência conforme Cláusula 11.5; (b) risco iminente à segurança, à integridade dos dados ou a outros tenants; (c) violação grave da PUA; ou (d) determinação legal/judicial. A suspensão não constitui rescisão nem afasta as contraprestações do período.

### 13.5. Rescisão por fato regulatório

Caso alteração legislativa/regulatória torne ilícita ou inviável a prestação (por exemplo, mudança em regras de proteção de dados, fiscal ou de meios de pagamento), qualquer Parte poderá rescindir sem penalidade, negociando de boa-fé eventual adaptação.

---

## 14. EFEITOS DA RESCISÃO E OBRIGAÇÕES DE SAÍDA

### 14.1. Cessação de uso

Extinto o Contrato, cessa imediatamente o direito de uso da Plataforma pelo PARCEIRO e por seus Clientes Finais, ressalvado o período de transição da Cláusula 14.2.

### 14.2. Transição assistida

A LICENCIANTE manterá, por até **[NÚMERO] dias** após o término, acesso em modo restrito para exportação de dados e transição, mediante quitação de eventuais valores em aberto. Serviços de transição adicionais poderão ser cobrados conforme proposta.

### 14.3. Devolução e eliminação de dados

Findo o período de transição, a LICENCIANTE, conforme instrução do Controlador e o DPA: (a) disponibilizará a exportação dos dados em formato estruturado; e (b) procederá à eliminação ou anonimização dos Dados Pessoais, ressalvadas as hipóteses de guarda obrigatória por lei (por exemplo, documentos fiscais e registros de auditoria) e o disposto no art. 16 da LGPD. A trilha de auditoria e os registros exigidos por lei poderão ser retidos pelos prazos legais.

### 14.4. Marca e desprovisionamento

O PARCEIRO deixará de utilizar quaisquer elementos da Plataforma e a LICENCIANTE removerá a identidade visual do PARCEIRO de sua infraestrutura, desprovisionando a Instância White Label após a transição.

### 14.5. Sobrevivência

Sobrevivem à extinção: propriedade intelectual (Cláusula 5), confidencialidade (Cláusula 12), proteção de dados/DPA (Cláusula 8), responsabilidade e limitação (Cláusula 15), obrigações financeiras vencidas e foro (Cláusula 19).

---

## 15. RESPONSABILIDADE E LIMITAÇÃO

### 15.1. Responsabilidade por culpa

Cada Parte responde pelos danos diretos que comprovadamente causar à outra por dolo ou culpa, nos limites deste Contrato e da lei.

### 15.2. Limitação de responsabilidade

Ressalvadas as hipóteses de dolo, violação de propriedade intelectual, violação de confidencialidade e responsabilidades indeclináveis em matéria de proteção de dados e consumo, a responsabilidade agregada da LICENCIANTE, por qualquer causa, fica limitada ao **valor total efetivamente pago pelo PARCEIRO nos [NÚMERO] meses anteriores ao fato gerador**.

### 15.3. Exclusão de danos indiretos

Nenhuma Parte responderá por lucros cessantes, perda de chance, danos indiretos, incidentais ou consequenciais, salvo dolo, na medida permitida pela legislação aplicável.

### 15.4. Responsabilidade perante Compradores e Clientes Finais

O PARCEIRO é o responsável pela relação com seus Clientes Finais e, na cadeia, perante os Compradores quanto à oferta, ao produto e ao cumprimento do CDC. A LICENCIANTE fornece a ferramenta tecnológica, não sendo parte nas relações de consumo do PARCEIRO/Clientes Finais, ressalvada responsabilidade que decorra diretamente de falha comprovada da Plataforma.

### 15.5. Responsabilidade solidária afastada

Salvo disposição legal cogente, não há solidariedade entre as Partes por obrigações da outra perante terceiros. Cada Parte indenizará a outra por perdas decorrentes de reclamações de terceiros imputáveis a seu próprio descumprimento (indenização regressiva).

### 15.6. Terceiros e sub-operadores

A LICENCIANTE não responde por falhas, indisponibilidades ou atos de sub-operadores/terceiros (gateways, Correios, VHSYS, provedores de mensageria) fora de seu controle razoável, sem prejuízo do dever de diligência na sua seleção e do procedimento de subtratamento do DPA.

### 15.7. Força maior

Nenhuma Parte responde por inadimplemento decorrente de caso fortuito ou força maior (art. 393 do Código Civil), incluindo falhas graves de infraestrutura de terceiros, ataques cibernéticos de larga escala e atos de autoridade, devendo comunicar a outra Parte e mitigar efeitos.

---

## 16. NÃO CONCORRÊNCIA, NÃO ALICIAMENTO E EXCLUSIVIDADE

### 16.1. Não exclusividade

Salvo Anexo em contrário, a licença é **não exclusiva**, podendo a LICENCIANTE licenciar a Plataforma a outros parceiros, inclusive concorrentes do PARCEIRO, e o PARCEIRO utilizar outras soluções.

### 16.2. Não aliciamento

Durante a vigência e por **[NÚMERO] meses** após, as Partes abster-se-ão de aliciar diretamente colaboradores-chave uma da outra envolvidos na execução deste Contrato, salvo consentimento por escrito.

### 16.3. Vedação a contorno

O PARCEIRO não contatará os sub-operadores da LICENCIANTE com o intuito de reproduzir a Plataforma ou de contornar o licenciamento, tampouco reproduzirá a arquitetura para criar solução concorrente com base nas Informações Confidenciais.

---

## 17. COMPLIANCE, ANTICORRUPÇÃO E SEGURANÇA DA INFORMAÇÃO

### 17.1. Anticorrupção

As Partes cumprirão a Lei nº 12.846/2013 (Anticorrupção) e normas correlatas, abstendo-se de práticas ilícitas, e manterão controles internos compatíveis.

### 17.2. Segurança da informação

A LICENCIANTE mantém programa de segurança orientado a boas práticas de mercado (por exemplo, ISO/IEC 27001/27701, NIST e OWASP), incluindo controle de acesso (RBAC), isolamento por RLS, gestão de segredos (credenciais write-only), trilha de auditoria e resposta a incidentes, sem que a menção a tais referências constitua certificação, salvo declaração formal em contrário.

### 17.3. Continuidade

A LICENCIANTE adota medidas de backup e continuidade compatíveis com a criticidade do serviço, alinhadas a princípios de gestão de continuidade (por exemplo, ISO 22301) e de gestão de riscos (ISO 31000), detalhadas em Anexo quando aplicável.

---

## 18. DISPOSIÇÕES GERAIS

### 18.1. Independência das Partes

As Partes são independentes; este Contrato não cria sociedade, associação, mandato, franquia, vínculo empregatício ou responsabilidade solidária não prevista em lei.

### 18.2. Cessão

O PARCEIRO não poderá ceder este Contrato sem anuência prévia e por escrito da LICENCIANTE. A LICENCIANTE poderá ceder a operação a empresa do mesmo grupo ou sucessora, mantidas as condições, mediante comunicação.

### 18.3. Comunicações

As comunicações formais serão feitas por escrito, aos endereços/e-mails informados no preâmbulo (incluindo **lemoncapsencapsulados@gmail.com** para assuntos de dados), presumindo-se recebidas conforme comprovante de envio.

### 18.4. Alterações

Alterações a este Contrato só terão validade se formalizadas por escrito e assinadas por ambas as Partes (aditivo), ressalvadas atualizações de Anexos técnicos comunicadas na forma aqui prevista.

### 18.5. Novação e tolerância

A tolerância quanto ao descumprimento de qualquer cláusula não implica novação, renúncia ou alteração do pactuado.

### 18.6. Nulidade parcial

A nulidade ou invalidade de qualquer cláusula não prejudica as demais, comprometendo-se as Partes a substituir a cláusula viciada por outra de efeito equivalente.

### 18.7. Anexos

Integram este Contrato, como se nele transcritos: (a) DPA — Acordo de Proteção de Dados; (b) Anexo de SLA; (c) Anexo Comercial; (d) Política de Uso Aceitável; e (e) demais anexos pactuados. Em caso de conflito, prevalece o corpo do Contrato, salvo quanto a proteção de dados, em que prevalece o DPA.

### 18.8. Integralidade

Este Contrato e seus Anexos constituem o entendimento integral entre as Partes quanto ao objeto, substituindo tratativas anteriores.

---

## 19. FORO E LEGISLAÇÃO APLICÁVEL

### 19.1. Legislação

Este Contrato rege-se pelas leis da República Federativa do Brasil.

### 19.2. Solução de controvérsias

As Partes buscarão solução amigável e, subsidiariamente, poderão adotar **[mediação/arbitragem, se pactuado]**. Não havendo composição, fica eleito o **foro da Comarca de Cuiabá/MT**, com renúncia a qualquer outro, por mais privilegiado que seja.

E, por estarem assim justas e contratadas, as Partes assinam este instrumento, em via eletrônica ou física, na data de **16 de julho de 2026**.

**LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA — LICENCIANTE (GLOP)**
Nome: ______________________ · Cargo: __________ · CPF: __________

**[CONTRATANTE] — PARCEIRO (LICENCIADO WHITE LABEL)**
Nome: ______________________ · Cargo: __________ · CPF: __________

**Testemunhas:**
1. Nome: __________ · CPF: __________
2. Nome: __________ · CPF: __________

---

## Engenharia Jurídica & Governança

### (a) Fundamentação das cláusulas (lei/norma que embasa)

| Cláusula | Tema | Fundamentação legal/normativa |
|---|---|---|
| 1 e 19 | Qualificação, foro e legislação | Código Civil (Lei nº 10.406/2002), arts. 421-425 (função social e liberdade contratual); CPC (Lei nº 13.105/2015), art. 63 (eleição de foro) |
| 3 e 4 | Objeto e licenciamento SaaS | Lei nº 9.609/1998 (Software), art. 9º (licença de uso); Código Civil, contratos atípicos |
| 5 | Propriedade intelectual | Lei nº 9.609/1998; Lei nº 9.610/1998 (Direitos Autorais); Lei nº 9.279/1996 (Propriedade Industrial), marcas e concorrência desleal |
| 6 | Limites de customização | Lei nº 9.609/1998, art. 6º (limites à engenharia reversa); autonomia privada (CC, art. 421) |
| 7 | Obrigações e PUA | Código Civil, arts. 389 e 422 (boa-fé objetiva); CDC (Lei nº 8.078/1990) na relação com Compradores |
| 8 | Proteção de dados / DPA | LGPD (Lei nº 13.709/2018), arts. 5º, 6º, 37-39 (Operador/Controlador), 46-49 (segurança), 33-36 (transferência internacional); Marco Civil (Lei nº 12.965/2014) |
| 9 | SLA e disponibilidade | Código Civil, arts. 393 (força maior) e 475 (resolução); boas práticas contratuais de SaaS |
| 10 | Suporte | Código Civil, art. 422 (cooperação e boa-fé); LGPD (minimização no atendimento) |
| 11 | Preço e pagamento | Código Civil, arts. 315-319, 389, 395 e 406 (mora, juros, correção) |
| 12 | Confidencialidade | Lei nº 9.279/1996, art. 195 (segredo de negócio); Código Civil, art. 422; LGPD |
| 13 e 14 | Vigência, suspensão, rescisão e saída | Código Civil, arts. 472-474 (distrato/denúncia), 475 (resolução); LGPD, art. 16 (eliminação e guarda) |
| 15 | Responsabilidade e limitação | Código Civil, arts. 393, 402-405 (perdas e danos), 927; limites conforme CDC e LGPD (responsabilidades indeclináveis) |
| 16 | Não concorrência/aliciamento | Livre iniciativa (CF, art. 170); Lei nº 9.279/1996, art. 195 (concorrência desleal) |
| 17 | Compliance e segurança | Lei nº 12.846/2013 (Anticorrupção); referências ISO/IEC 27001/27701/22301/31000, NIST, OWASP (boas práticas) |
| 18 | Disposições gerais | Código Civil, arts. 286-298 (cessão), 425 (contratos atípicos) |

### (b) Riscos mitigados

1. **Vazamento/uso indevido de PII do Comprador** (nome, CPF, endereço) — mitigado por remissão ao DPA, RLS multi-tenant, RBAC, credenciais write-only, minimização no Portal Público de Rastreio e cláusula de incidentes;
2. **Confusão de papéis LGPD** (Operador x Controlador) — mitigado pela Cláusula 8.2, que define a dupla natureza e o efeito back-to-back com Clientes Finais;
3. **Apropriação indevida de propriedade intelectual/arquitetura** — mitigado por reserva de direitos, vedação a engenharia reversa e titularidade de melhorias (Cláusula 5);
4. **Desvirtuamento do White Label** (customização que quebre segurança ou exponha dados) — mitigado pelos limites da Cláusula 6 e pelo núcleo de segurança inalterável;
5. **Responsabilização por falha de terceiros** (gateways, Correios, VHSYS, mensageria) — mitigado pelas exclusões de SLA e pela Cláusula 15.6;
6. **Inadimplência e uso após rescisão** — mitigado por suspensão, obrigações de saída, sobrevivência e retenção legal de documentos fiscais/auditoria;
7. **Exposição financeira ilimitada** — mitigado pela limitação de responsabilidade e exclusão de danos indiretos (Cláusula 15);
8. **Enquadramento como instituição de pagamento** no split/PIX — afastado pela Cláusula 11.6;
9. **Reclamações de consumo** — canalizadas ao PARCEIRO/Cliente Final (Cláusula 15.4), preservando a LICENCIANTE como fornecedora de tecnologia.

### (c) Checklist de implementação

- [ ] Preencher todos os placeholders entre colchetes (razão social, CNPJ, endereço, DPO, datas, valores, prazos, foro).
- [ ] Anexar e assinar o DPA (Acordo de Proteção de Dados) com lista atualizada de sub-operadores.
- [ ] Anexar o Anexo de SLA (metas, créditos, plantão) e o Anexo Comercial (preços/métricas).
- [ ] Anexar a Política de Uso Aceitável e obter aceite do PARCEIRO.
- [ ] Validar bases legais LGPD de cada Cliente Final (efeito back-to-back).
- [ ] Confirmar titularidade do domínio do PARCEIRO e certificados TLS.
- [ ] Validar credenciais de gateways/Correios/VHSYS em nome do PARCEIRO/Clientes Finais.
- [ ] Revisão por advogado(a) habilitado(a) antes da assinatura.
- [ ] Definir Encarregado (DPO) de cada Parte e canais de contato.
- [ ] Registrar versão e data no Controle de Versão.

### (d) Matriz RACI

| Atividade | LICENCIANTE (GLOP) | PARCEIRO | Cliente Final | DPO/Encarregado |
|---|---|---|---|---|
| Provisionar Instância White Label | R/A | C | I | I |
| Manter Plataforma e segurança (RLS/RBAC/auditoria) | R/A | I | I | C |
| Aplicar identidade visual/customização permitida | R | A | I | I |
| Comercializar aos Clientes Finais | I | R/A | C | I |
| Suporte 1º nível (Clientes Finais/Compradores) | I | R/A | C | I |
| Suporte 2º nível (backend/plataforma) | R/A | C | I | I |
| Definir bases legais LGPD (Comprador) | C | R | A | C |
| Notificação de incidente à ANPD/Titulares | C (apoio, como Operador) | R | A (Controlador) | R |
| Fornecer credenciais gateways/Correios/VHSYS | I | R/A | C | I |
| Pagamento da Taxa de Licenciamento | I | R/A | I | I |
| Eliminação/retenção de dados na saída | R (executa) | C | A | R |

Legenda: R = Responsável (executa) · A = Aprovador (presta contas) · C = Consultado · I = Informado.

### (e) Plano de revisão

1. **Revisão ordinária anual** do Contrato e Anexos, com foco em preços, SLA e sub-operadores.
2. **Revisão extraordinária** disparada por: alteração legislativa (LGPD/ANPD, fiscal, meios de pagamento), troca de sub-operador relevante, incidente de segurança significativo ou mudança material na arquitetura da Plataforma.
3. **Revisão do DPA** sempre que houver novo sub-operador, nova finalidade de tratamento ou orientação da ANPD.
4. **Responsável pela revisão**: Departamento Jurídico/Compliance da LICENCIANTE, com validação por advogado(a) habilitado(a) e ciência do Encarregado.
5. **Registro**: toda revisão gera nova versão na tabela de Controle de Versão e comunicação formal ao PARCEIRO.

### (f) Controle de versão

| Versão | Data | Autor/Responsável | Alterações | Status |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | Chief Legal AI (minuta) | Redação inicial do Contrato White Label GLOP | Minuta — pendente de revisão jurídica |
| [x.x] | 16 de julho de 2026 | a ser designado pela administração / Jurídico | [descrever alterações] | [rascunho/aprovado/vigente] |

---

> Documento sujeito a revisão por advogado(a) habilitado(a). As referências normativas (LGPD, CDC, Código Civil, Leis nº 9.609/1998, 9.610/1998, 9.279/1996, 12.846/2013, ISO/IEC 27001/27701/22301/31000, NIST, OWASP, GDPR) devem ser confirmadas quanto à vigência e aplicabilidade à operação real do GLOP na data de uso.
