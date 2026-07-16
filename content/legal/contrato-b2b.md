> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# CONTRATO DE PRESTAÇÃO DE SERVIÇOS DE PLATAFORMA (SAAS) E LICENÇA DE USO — GLOP (GLOBAL LOGISTICS PLATFORM)

**Contrato B2B (Business-to-Business) — Uso da Plataforma e Serviços de Logística/ERP**

**Número do Contrato:** [Nº DO CONTRATO]
**Data de assinatura:** 16 de julho de 2026
**Local:** Cuiabá/MT

---

## Preâmbulo

Este Contrato de Prestação de Serviços de Plataforma como Serviço (SaaS), Licença de Uso e Operação de Dados ("**Contrato**") é celebrado entre as partes abaixo qualificadas, tendo por finalidade regular a contratação, o acesso e o uso da plataforma **GLOP — Global Logistics Platform**, solução SaaS de logística e ERP (WMS/TMS/gestão de pedidos, expedição, coprodução e split) voltada a operações de dropshipping e infoprodutos no Brasil.

Considerando que:

1. A **CONTRATADA** desenvolveu, mantém e opera a plataforma GLOP, disponibilizada em regime de multi-tenant sobre arquitetura Next.js e Supabase (PostgreSQL), com isolamento lógico por Row Level Security (RLS) e controle de acesso baseado em papéis (RBAC);
2. A **CONTRATANTE** é pessoa jurídica que atua no mercado de comércio eletrônico, dropshipping e/ou infoprodutos e deseja utilizar a plataforma para gestão de pedidos, expedição, rastreio, emissão de documentos fiscais, coprodução, apuração de comissões e repasses;
3. As Partes desejam disciplinar direitos e obrigações recíprocos, incluindo condições comerciais, níveis de serviço, confidencialidade, proteção de dados pessoais (LGPD), propriedade intelectual e responsabilidade;

resolvem as Partes celebrar o presente Contrato, que se regerá pelas cláusulas e condições seguintes.

---

## Cláusula 1 — Qualificação das Partes

### 1.1. CONTRATADA (Prestadora / Fornecedora da Plataforma)

**LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA**, sociedade empresária inscrita no CNPJ sob nº **55.836.075/0001-07**, com sede em **Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190**, doravante denominada "**CONTRATADA**", "**GLOP**" ou "**Plataforma**", neste ato representada na forma de seus atos constitutivos, nome fantasia **[NOME FANTASIA: GLOP]**.

### 1.2. CONTRATANTE (Cliente / Usuária dos Serviços)

**[CONTRATANTE — RAZÃO SOCIAL]**, sociedade empresária inscrita no CNPJ sob nº **[CNPJ DO CONTRATANTE]**, com sede em **[ENDEREÇO DO CONTRATANTE]**, doravante denominada "**CONTRATANTE**", neste ato representada na forma de seus atos constitutivos.

### 1.3. Denominação conjunta

CONTRATADA e CONTRATANTE são designadas, em conjunto, "**Partes**" e, individualmente, "**Parte**". As Partes declaram que os representantes signatários detêm poderes bastantes para a celebração deste Contrato.

### 1.4. Natureza empresarial da relação

As Partes reconhecem tratar-se de relação **estritamente empresarial (B2B)**, entre agentes econômicos com igualdade material de condições e assessoria própria, não se aplicando, entre si, a proteção do Código de Defesa do Consumidor (Lei nº 8.078/1990), sem prejuízo dos direitos dos consumidores finais (compradores) atendidos pela CONTRATANTE, cuja tutela é de responsabilidade desta última.

---

## Cláusula 2 — Definições

Para os fins deste Contrato, os termos abaixo, quando iniciados em maiúscula, têm os seguintes significados:

| Termo | Definição |
|---|---|
| **Plataforma / GLOP** | Software SaaS de logística e ERP disponibilizado pela CONTRATADA, incluindo módulos de ingestão de pedidos, expedição, rastreio, NF-e, coprodução, split e portal público de rastreio. |
| **Tenant** | Unidade lógica de isolamento de dados no topo da hierarquia multi-tenant (Tenant → Company → Branch → Membership). |
| **Company / Branch** | Empresa e filial da CONTRATANTE cadastradas na Plataforma, sujeitas a isolamento por RLS. |
| **Usuário Autorizado** | Colaborador, preposto ou terceiro da CONTRATANTE credenciado via Supabase Auth com papel (role) atribuído. |
| **Comprador** | Cliente final da CONTRATANTE, titular dos dados pessoais tratados na operação (nome, CPF/CNPJ, e-mail, telefone, endereço, produto, valor). |
| **Dados do Comprador** | Dados pessoais dos Compradores tratados pela CONTRATADA por conta e ordem da CONTRATANTE. |
| **Sub-operadores** | Terceiros contratados pela CONTRATADA para viabilizar o serviço: Supabase e Netlify (infraestrutura), VHSYS (NF-e), Correios (transporte), gateways (Monetizze, AppMax, Hotmart, Kiwify), e provedores de mensageria (WhatsApp/e-mail). |
| **Gateways / Checkouts** | Plataformas de pagamento e venda integradas (Monetizze, AppMax, Hotmart, Kiwify) e e-commerces (Shopify, WooCommerce, Nuvemshop, Mercado Livre). |
| **RLS** | Row Level Security — isolamento de linhas por empresa no PostgreSQL. |
| **RBAC** | Role-Based Access Control — controle de acesso por papéis e permissões (has_permission). |
| **DPA** | Data Processing Agreement — Acordo de Tratamento de Dados anexo, que integra este Contrato. |
| **LGPD** | Lei nº 13.709/2018 — Lei Geral de Proteção de Dados Pessoais. |
| **SLA** | Service Level Agreement — Acordo de Nível de Serviço (Cláusula 9). |
| **Dados de Serviço** | Dados operacionais, cadastros, credenciais de API e configurações inseridos pela CONTRATANTE na Plataforma. |
| **Credenciais de API** | Chaves e tokens de integração (gateways, Correios, VHSYS), armazenados em modo write-only. |
| **PPN / SRO** | Pré-postagem (PPN) e rastreamento (SRO) junto aos Correios. |

---

## Cláusula 3 — Objeto

### 3.1. Objeto principal

Constitui objeto deste Contrato a concessão, pela CONTRATADA à CONTRATANTE, de **licença de uso, não exclusiva, intransferível e temporária**, da plataforma GLOP em regime de SaaS (Software as a Service), bem como a prestação dos serviços de operação, suporte e integrações a ela associados, na modalidade e no plano contratados.

### 3.2. Escopo funcional

A Plataforma disponibiliza, conforme plano contratado, os seguintes fluxos operacionais reais:

1. **Ingestão de pedidos via API** a partir de gateways (Monetizze, Hotmart, Kiwify) e e-commerces (Shopify, WooCommerce, Nuvemshop, Mercado Livre), com captura de dados do pedido e do Comprador (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor);
2. **Expedição e transporte** junto aos Correios, incluindo pré-postagem (PPN), rastreamento (SRO) e notificação ao Comprador por e-mail e/ou WhatsApp;
3. **Emissão de documentos fiscais (NF-e)** por meio da integração com a VHSYS;
4. **Coprodução e Split**, com gestão de coprodutores e afiliados, cálculo e apuração de comissões, repasses e split de pagamentos (via AppMax), incluindo o tratamento de dados bancários e de chaves PIX quando necessário;
5. **Portal público de rastreio**, sem necessidade de login, exibindo exclusivamente status neutro de entrega, sem exposição de dados pessoais sensíveis;
6. **Gestão multi-tenant, RBAC e auditoria**, com isolamento por empresa (RLS), controle de permissões (has_permission), soft-delete, colunas de auditoria e trilha por triggers.

### 3.3. Modelo de disponibilização

O acesso se dá exclusivamente via nuvem (cloud), com hospedagem SSR em Netlify e backend em Supabase, sem cessão de código-fonte, sem instalação local e sem transferência de titularidade de qualquer elemento de software.

### 3.4. Exclusões de escopo

Salvo previsão expressa em Ordem de Serviço ou Anexo, **não integram** o objeto: (a) desenvolvimento sob demanda de funcionalidades customizadas; (b) migração de dados legados; (c) integrações com sistemas não listados na Cláusula 3.2; (d) consultoria fiscal, contábil ou jurídica; (e) fornecimento de equipamentos, links de internet ou conectividade da CONTRATANTE; (f) obrigações tributárias, trabalhistas ou de transporte perante terceiros que sejam próprias da CONTRATANTE.

---

## Cláusula 4 — Condições Comerciais, Preço e Pagamento

### 4.1. Plano e preço

A CONTRATANTE contratará o plano descrito no **Anexo I — Plano e Preços** ou na Proposta Comercial aceita, obrigando-se ao pagamento da remuneração ali estabelecida ("**Remuneração**"), que poderá compreender: (a) mensalidade/assinatura fixa; (b) valores por volume (pedidos processados, etiquetas, envios, NF-e emitidas); (c) taxas de setup ou de integração; e (d) serviços adicionais eventualmente contratados.

### 4.2. Forma e vencimento

A Remuneração será faturada em ciclos **[mensais/anuais]**, com vencimento no dia **[DIA]** de cada período, mediante **[boleto/PIX/cartão/débito recorrente]**, conforme Anexo I. O primeiro ciclo será cobrado proporcionalmente (pro rata die) a partir da ativação.

### 4.3. Reajuste

Os valores serão reajustados anualmente, ou na menor periodicidade permitida em lei, pela variação positiva do **IPCA/IBGE** (ou índice que o substitua) acumulado no período, independentemente de aviso, mantido o mesmo período de referência da assinatura.

### 4.4. Impostos e tributos

Os preços não incluem tributos incidentes sobre a prestação (ISS, PIS, COFINS e outros), que serão acrescidos e destacados conforme legislação vigente. Cada Parte é responsável pelos tributos de sua própria atividade e faturamento.

### 4.5. Inadimplemento

O atraso no pagamento sujeita a CONTRATANTE, independentemente de notificação, a: (a) **multa moratória de 2%** sobre o valor em atraso; (b) **juros de mora de 1% ao mês**, pro rata die; e (c) **atualização monetária pelo IPCA**. O inadimplemento superior a **[15/30] dias** autoriza a **suspensão do acesso** à Plataforma, mediante aviso prévio de **[5] dias**, sem prejuízo da cobrança e da rescisão prevista na Cláusula 12.

### 4.6. Suspensão por inadimplência

Durante a suspensão, os Dados de Serviço e Dados do Comprador permanecerão armazenados, sem processamento ativo, pelo prazo de retenção da Cláusula 12.6, após o qual poderão ser eliminados observado o DPA e a legislação fiscal aplicável.

### 4.7. Repasses e split

Nas operações de coprodução e split, a CONTRATADA atua como **provedora de meios tecnológicos de apuração e conciliação**, não sendo instituição de pagamento nem responsável pela liquidação financeira, a qual é executada pelo gateway (AppMax e demais). A CONTRATANTE é a única responsável pela exatidão das regras de comissão, dos beneficiários e das chaves PIX/dados bancários cadastrados.

---

## Cláusula 5 — Obrigações da CONTRATADA

A CONTRATADA obriga-se a:

1. Disponibilizar a Plataforma conforme o plano contratado e os níveis de serviço da Cláusula 9;
2. Manter a arquitetura multi-tenant com **isolamento lógico por RLS** entre empresas, impedindo acesso cruzado de dados (cross-tenant);
3. Aplicar controle de acesso por papéis (**RBAC / has_permission**), trilha de auditoria por triggers, soft-delete e colunas de auditoria em todos os registros de negócio;
4. Armazenar credenciais de API de terceiros em modo **write-only**, sem exposição de segredos à interface ou a terceiros não autorizados;
5. Operar os Dados do Comprador **estritamente como Operadora**, segundo instruções documentadas da CONTRATANTE e os termos do DPA (Cláusula 8);
6. Adotar medidas técnicas e organizacionais de segurança da informação compatíveis com as normas de referência (ISO/IEC 27001, 27701, 22301, 31000, NIST, OWASP) e com o art. 46 da LGPD;
7. Manter os sub-operadores listados na Cláusula 2 sob contratos que assegurem nível de proteção adequado, comunicando alterações relevantes com antecedência razoável;
8. Prestar suporte técnico nos canais e horários definidos na Cláusula 9;
9. Comunicar a CONTRATANTE, sem demora, sobre incidentes de segurança que possam acarretar risco relevante aos titulares, na forma da Cláusula 8 e do DPA;
10. Disponibilizar meios de **exportação dos Dados de Serviço** em formato estruturado e interoperável, na vigência e no encerramento do Contrato;
11. Manter registro das operações de tratamento de dados pessoais sob sua responsabilidade (art. 37 da LGPD);
12. Cumprir a legislação aplicável à sua atividade, incluindo LGPD, Marco Civil da Internet (Lei nº 12.965/2014) e normas de segurança da informação.

---

## Cláusula 6 — Obrigações da CONTRATANTE

A CONTRATANTE obriga-se a:

1. Utilizar a Plataforma conforme este Contrato, a legislação vigente e a boa-fé, respondendo pelos atos de seus Usuários Autorizados;
2. Fornecer dados cadastrais, fiscais e de integração **verídicos, completos e atualizados**, respondendo por sua exatidão (regras de comissão, beneficiários, chaves PIX, dados bancários, dados fiscais para NF-e);
3. **Atuar como CONTROLADORA** dos Dados do Comprador, definindo as finalidades e possuindo a **base legal adequada** (art. 7º da LGPD, notadamente execução de contrato e legítimo interesse) para a coleta e o repasse desses dados à Plataforma;
4. Fornecer aos Compradores as informações de transparência exigidas (art. 9º da LGPD), inclusive quanto ao compartilhamento operacional com a CONTRATADA e sub-operadores (Correios, gateways, VHSYS, mensageria);
5. Obter e manter as bases legais para as **comunicações ao Comprador** por e-mail e WhatsApp (notificações de rastreio), observadas as políticas das plataformas de mensageria;
6. Guardar sigilo e zelar pela segurança das credenciais de acesso de seus Usuários Autorizados, comunicando imediatamente qualquer uso não autorizado;
7. Não realizar engenharia reversa, descompilação, cópia, sublicenciamento, revenda ou exploração não autorizada da Plataforma (Cláusula 10);
8. Responder integralmente pelas **obrigações fiscais, tributárias e de transporte** decorrentes de suas vendas, inclusive a correta emissão de NF-e e a licitude dos produtos comercializados;
9. Não inserir na Plataforma conteúdo ilícito, produtos proibidos, dados de terceiros sem base legal ou dados pessoais sensíveis desnecessários à operação;
10. Pagar pontualmente a Remuneração (Cláusula 4);
11. Cooperar com a CONTRATADA no atendimento a requisições de titulares e de autoridades, na condição de Controladora;
12. Manter ambiente próprio (dispositivos, redes e credenciais) em condições adequadas de segurança.

### 6.1. Uso aceitável

É vedado à CONTRATANTE, direta ou indiretamente: (a) sobrecarregar deliberadamente a infraestrutura (ataques, scraping massivo, testes de carga não autorizados); (b) burlar limites de plano ou controles de RLS/RBAC; (c) utilizar a Plataforma para fraude, lavagem de dinheiro, evasão fiscal ou práticas anticoncorrenciais; (d) violar direitos de propriedade intelectual de terceiros.

---

## Cláusula 7 — Confidencialidade

### 7.1. Informações Confidenciais

Consideram-se "**Informações Confidenciais**" todas as informações técnicas, comerciais, financeiras, operacionais, de segurança, de arquitetura, credenciais, dados de clientes, condições comerciais e quaisquer dados não públicos a que uma Parte tenha acesso em razão deste Contrato, independentemente de suporte ou marcação de sigilo.

### 7.2. Obrigações

Cada Parte compromete-se a: (a) manter sigilo absoluto sobre as Informações Confidenciais da outra; (b) utilizá-las apenas para a execução deste Contrato; (c) restringir o acesso a colaboradores com necessidade de conhecer (need to know), vinculados a deveres de sigilo equivalentes; e (d) empregar padrão de cuidado não inferior ao aplicado às próprias informações confidenciais.

### 7.3. Exceções

Não se sujeitam ao dever de sigilo as informações que: (a) sejam ou se tornem públicas sem violação deste Contrato; (b) já estivessem legitimamente em poder da Parte receptora; (c) sejam desenvolvidas de forma independente; ou (d) devam ser reveladas por ordem judicial ou de autoridade competente, hipótese em que a Parte notificará previamente a outra, quando legalmente admitido.

### 7.4. Vigência do sigilo

O dever de confidencialidade vigora durante o Contrato e por **5 (cinco) anos** após seu término, e por prazo indeterminado quanto a segredos de negócio e dados pessoais, na forma da lei.

---

## Cláusula 8 — Proteção de Dados Pessoais (LGPD)

### 8.1. Papéis e dupla natureza

As Partes reconhecem a **dupla natureza** do tratamento de dados na operação GLOP:

1. **Quanto aos Dados do Comprador** (dados dos clientes finais ingeridos dos gateways e e-commerces): a **CONTRATANTE é CONTROLADORA** e a **CONTRATADA é OPERADORA**, tratando tais dados por conta e ordem da CONTRATANTE, para viabilizar expedição, rastreio, NF-e, notificação e apuração de split;
2. **Quanto aos dados dos próprios Usuários Autorizados e colaboradores da CONTRATANTE** (cadastro, autenticação, logs de acesso): a **CONTRATADA atua como CONTROLADORA** para as finalidades de segurança, faturamento e cumprimento legal, sem prejuízo das responsabilidades da CONTRATANTE quanto aos dados que insere.

### 8.2. Remissão ao DPA

O tratamento de dados pessoais rege-se pelo **Acordo de Tratamento de Dados (DPA)**, anexo que integra este Contrato para todos os fins. Em caso de conflito quanto à proteção de dados, prevalecem as disposições do DPA.

### 8.3. Instruções e finalidade

A CONTRATADA tratará os Dados do Comprador **exclusivamente** conforme instruções documentadas da CONTRATANTE e para as finalidades da Cláusula 3.2, sendo vedado o uso para finalidades próprias, comercialização ou enriquecimento de base.

### 8.4. Sub-operadores

A CONTRATANTE **autoriza expressamente** a subcontratação dos sub-operadores listados na Cláusula 2 (Supabase, Netlify, VHSYS, Correios, gateways e provedores de mensageria), como condição para a prestação. Novos sub-operadores que tratem Dados do Comprador serão informados com antecedência razoável, facultada objeção fundamentada.

### 8.5. Segurança

A CONTRATADA manterá medidas técnicas e organizacionais compatíveis com o art. 46 da LGPD e as normas de referência (ISO 27001/27701, NIST, OWASP), incluindo isolamento por RLS, RBAC, criptografia em trânsito, credenciais write-only, soft-delete, trilha de auditoria e minimização de dados no portal público (status neutro).

### 8.6. Incidentes

Em caso de incidente de segurança com Dados do Comprador, a CONTRATADA comunicará a CONTRATANTE **sem demora injustificada**, com as informações do art. 48 da LGPD, cabendo à CONTRATANTE, como Controladora, a comunicação à ANPD e aos titulares quando exigível.

### 8.7. Direitos dos titulares

A CONTRATADA auxiliará a CONTRATANTE no atendimento a requisições de titulares (arts. 18 e 19 da LGPD), fornecendo meios técnicos de acesso, correção, exportação e eliminação, na medida de sua atuação como Operadora.

### 8.8. Transferência internacional

Havendo transferência internacional decorrente da infraestrutura dos sub-operadores, a CONTRATADA adotará salvaguardas adequadas (cláusulas-padrão, decisões de adequação ou mecanismos previstos nos arts. 33 a 36 da LGPD).

### 8.9. Encarregado (DPO)

O canal do Encarregado pela Proteção de Dados da CONTRATADA é **lemoncapsencapsulados@gmail.com**, sendo o Encarregado **a ser designado pela administração**. A CONTRATANTE indicará seu próprio Encarregado quando aplicável.

---

## Cláusula 9 — Níveis de Serviço (SLA) e Suporte

### 9.1. Disponibilidade

A CONTRATADA envidará seus melhores esforços para manter a Plataforma disponível em **[99,5%]** por mês-calendário, medida sobre o tempo total do período, excluídas as janelas de manutenção programada e as exclusões da Cláusula 9.4.

### 9.2. Manutenção programada

Manutenções programadas serão comunicadas com antecedência mínima de **[24/48] horas** e, sempre que possível, realizadas em janelas de menor uso.

### 9.3. Suporte e tempos de resposta

O suporte técnico será prestado por **[e-mail/portal/chat]**, em **[horário comercial / 24x7 conforme plano]**, observando os seguintes prazos-alvo de primeira resposta por severidade:

| Severidade | Descrição | Primeira resposta (alvo) | Restabelecimento (alvo) |
|---|---|---|---|
| **S1 — Crítica** | Indisponibilidade total ou falha que impede a operação | [1] hora | [4] horas |
| **S2 — Alta** | Falha grave com contorno parcial | [4] horas | [1] dia útil |
| **S3 — Média** | Falha pontual sem impacto crítico | [1] dia útil | [3] dias úteis |
| **S4 — Baixa** | Dúvida, melhoria ou baixo impacto | [2] dias úteis | Conforme roadmap |

### 9.4. Exclusões do SLA

Não computam como indisponibilidade os eventos decorrentes de: (a) força maior ou caso fortuito; (b) falhas de terceiros/sub-operadores fora do controle da CONTRATADA (Supabase, Netlify, Correios, gateways, VHSYS, mensageria); (c) falhas de conectividade, equipamentos ou credenciais da CONTRATANTE; (d) uso em desacordo com o Contrato; (e) suspensão por inadimplência ou por ordem de autoridade.

### 9.5. Créditos de serviço

Descumprido o índice de disponibilidade, e mediante solicitação da CONTRATANTE em até **[30] dias**, aplicar-se-ão créditos proporcionais na fatura seguinte, conforme escala do **Anexo II — SLA**, os quais constituem **remédio único e exclusivo** por indisponibilidade, limitados a **[20%]** do valor mensal.

---

## Cláusula 10 — Propriedade Intelectual

### 10.1. Titularidade da CONTRATADA

A Plataforma GLOP, seu código-fonte, arquitetura, bancos de dados, modelos, interfaces, marcas, nome fantasia, know-how, documentação e quaisquer melhorias são de **titularidade exclusiva da CONTRATADA** (ou de seus licenciadores), protegidos pela Lei de Software (Lei nº 9.609/1998), pela Lei de Direitos Autorais (Lei nº 9.610/1998) e pela Lei de Propriedade Industrial (Lei nº 9.279/1996).

### 10.2. Licença concedida

A CONTRATADA concede à CONTRATANTE licença **não exclusiva, intransferível, não sublicenciável e limitada** ao prazo e ao escopo do plano contratado, exclusivamente para uso interno na operação da CONTRATANTE. Nenhuma disposição transfere titularidade de software.

### 10.3. Restrições

É vedado à CONTRATANTE: (a) copiar, modificar, distribuir, sublicenciar ou revender a Plataforma; (b) realizar engenharia reversa, descompilação ou desmontagem, salvo nos limites imperativos da lei; (c) remover avisos de propriedade; (d) usar as marcas da CONTRATADA sem autorização escrita.

### 10.4. Dados da CONTRATANTE

Os **Dados de Serviço** e **Dados do Comprador** inseridos permanecem de titularidade da CONTRATANTE e/ou dos respectivos titulares, cabendo à CONTRATADA apenas o direito de tratá-los para a prestação, na forma da Cláusula 8 e do DPA.

### 10.5. Feedback

Sugestões e feedbacks fornecidos pela CONTRATANTE poderão ser incorporados à Plataforma pela CONTRATADA, de forma livre e perpétua, sem gerar direito de propriedade ou remuneração à CONTRATANTE.

---

## Cláusula 11 — Responsabilidade e Limitações

### 11.1. Responsabilidade da CONTRATANTE

A CONTRATANTE é integral e exclusivamente responsável por: (a) a licitude dos produtos e das vendas; (b) a exatidão dos dados fiscais, de comissão e de repasse; (c) as obrigações perante seus Compradores, coprodutores, afiliados e autoridades; (d) as bases legais de tratamento dos Dados do Comprador; e (e) o uso da Plataforma por seus Usuários Autorizados.

### 11.2. Responsabilidade da CONTRATADA

A CONTRATADA responde pelos danos diretos comprovadamente decorrentes de dolo ou culpa na prestação dos serviços, observadas as limitações desta Cláusula.

### 11.3. Exclusão de danos indiretos

Salvo dolo ou culpa grave, **nenhuma Parte** responderá por danos indiretos, lucros cessantes, perda de receita, perda de chance, danos reputacionais ou de imagem, ou danos não previsíveis na data da contratação.

### 11.4. Limitação de valor

Ressalvadas as hipóteses da Cláusula 11.6, a **responsabilidade agregada** da CONTRATADA, por qualquer causa relacionada a este Contrato, limita-se ao **valor total efetivamente pago** pela CONTRATANTE nos **12 (doze) meses** anteriores ao fato gerador.

### 11.5. Terceiros e sub-operadores

A CONTRATADA não responde por indisponibilidades, atrasos, erros ou falhas atribuíveis a terceiros e sub-operadores (Correios, gateways de pagamento, VHSYS, provedores de mensageria, Supabase, Netlify), cujos serviços se sujeitam a termos próprios; responde apenas pela diligência na seleção e no acompanhamento razoável desses parceiros.

### 11.6. Não limitação

As limitações desta Cláusula **não se aplicam** a: (a) violação de confidencialidade dolosa; (b) violação de direitos de propriedade intelectual; (c) danos por dolo; e (d) obrigações de indenização por violação comprovada da LGPD imputável exclusivamente à Parte infratora, respeitada a repartição de responsabilidades entre Controladora e Operadora (art. 42 da LGPD).

### 11.7. Indenização (hold harmless)

Cada Parte manterá a outra indene de reclamações de terceiros decorrentes de seu próprio descumprimento contratual ou legal. A CONTRATANTE, em especial, indenizará a CONTRATADA por reclamações de Compradores, coprodutores, afiliados ou autoridades relativas ao conteúdo, licitude ou base legal dos dados e vendas por ela inseridos.

---

## Cláusula 12 — Vigência, Renovação e Rescisão

### 12.1. Vigência

Este Contrato vigora por prazo **[determinado de 12 meses / indeterminado]**, a contar da data de assinatura ou da ativação, o que ocorrer primeiro.

### 12.2. Renovação

Sendo por prazo determinado, o Contrato renova-se **automaticamente** por períodos iguais e sucessivos, salvo manifestação em contrário de qualquer Parte com antecedência mínima de **[30/60] dias** do término.

### 12.3. Rescisão imotivada (denúncia)

Qualquer Parte poderá denunciar o Contrato imotivadamente, mediante aviso prévio escrito de **[30] dias**, sem penalidade, quitadas as obrigações vencidas e os serviços prestados até a data de encerramento.

### 12.4. Rescisão por justa causa

Poderá ser rescindido, de pleno direito, por notificação, em caso de: (a) descumprimento de obrigação relevante não sanado no prazo de **[10/15] dias** da notificação; (b) inadimplemento financeiro na forma da Cláusula 4.5; (c) violação de confidencialidade, propriedade intelectual ou LGPD; (d) uso indevido ou ilícito da Plataforma; (e) falência, recuperação judicial deferida com risco à execução, ou insolvência de qualquer Parte.

### 12.5. Efeitos da rescisão

Encerrado o Contrato: (a) cessa a licença de uso e o acesso à Plataforma; (b) tornam-se exigíveis os valores devidos; (c) subsistem as cláusulas que, por natureza, sobrevivem (confidencialidade, PI, proteção de dados, responsabilidade e foro).

### 12.6. Reversão e portabilidade de dados

Pelo prazo de **[30] dias** após o encerramento, a CONTRATADA disponibilizará à CONTRATANTE a **exportação dos Dados de Serviço** em formato estruturado. Decorrido esse prazo, os dados serão **eliminados ou anonimizados**, ressalvadas as retenções legais (obrigações fiscais, art. 16 da LGPD) e as previstas no DPA.

### 12.7. Penalidade por rescisão antecipada

Na rescisão por justa causa provocada pela CONTRATANTE, ou na denúncia antecipada de contrato por prazo determinado com desconto de fidelidade, incidirá multa correspondente a **[50%]** das mensalidades vincendas até o termo, sem prejuízo dos valores vencidos, das perdas e danos e das penalidades legais.

---

## Cláusula 13 — Disposições Gerais

### 13.1. Independência das Partes

As Partes são contratantes independentes; nada neste Contrato cria vínculo societário, associativo, trabalhista, de mandato ou de representação entre elas ou entre seus colaboradores.

### 13.2. Cessão

Nenhuma Parte poderá ceder ou transferir este Contrato sem anuência escrita da outra, salvo a CONTRATADA, em caso de reorganização societária, incorporação, cisão ou fusão, mediante comunicação.

### 13.3. Novação e tolerância

A tolerância quanto ao descumprimento de qualquer obrigação não implica novação, renúncia ou alteração do pactuado.

### 13.4. Nulidade parcial

A eventual nulidade ou inexequibilidade de qualquer cláusula não afeta as demais, que permanecem válidas, comprometendo-se as Partes a substituir a cláusula viciada por outra de efeito equivalente.

### 13.5. Comunicações

As comunicações serão feitas por escrito, por e-mail com confirmação, aos endereços indicados no preâmbulo ou ao canal **lemoncapsencapsulados@gmail.com** para assuntos de dados. Alterações de endereço devem ser comunicadas por escrito.

### 13.6. Força maior

Nenhuma Parte responde por descumprimento causado por caso fortuito ou força maior (art. 393 do Código Civil), enquanto perdurar o evento, obrigando-se a comunicá-lo e a mitigar seus efeitos.

### 13.7. Integralidade e anexos

Este Contrato, seus Anexos e o DPA constituem o acordo integral entre as Partes, prevalecendo sobre entendimentos anteriores. Em caso de conflito, a ordem de prevalência é: (1) DPA (matéria de dados); (2) Corpo do Contrato; (3) Anexos comerciais.

### 13.8. Alterações

Alterações somente serão válidas por instrumento escrito assinado pelas Partes, admitida a **assinatura eletrônica** (MP nº 2.200-2/2001 e Lei nº 14.063/2020).

---

## Cláusula 14 — Lei Aplicável e Foro

### 14.1. Lei aplicável

Este Contrato rege-se pelas leis da República Federativa do Brasil.

### 14.2. Solução de controvérsias

As Partes buscarão solução amigável, por negociação direta, no prazo de **[15] dias**. Não havendo acordo, fica eleito o foro da Comarca de **Cuiabá/MT**, com renúncia a qualquer outro, por mais privilegiado que seja. **[Opcional: cláusula compromissória de arbitragem, conforme Lei nº 9.307/1996, na câmara [NOME DA CÂMARA], sede [CIDADE], em língua portuguesa.]**

---

E, por estarem justas e contratadas, as Partes firmam o presente Contrato, admitida a assinatura eletrônica, em face de duas testemunhas.

**Cuiabá/MT, 16 de julho de 2026.**

| CONTRATADA | CONTRATANTE |
|---|---|
| **LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA** | **[CONTRATANTE — RAZÃO SOCIAL]** |
| Nome: [NOME DO REPRESENTANTE] | Nome: [NOME DO REPRESENTANTE] |
| Cargo: [CARGO] | Cargo: [CARGO] |
| CPF: [CPF] | CPF: [CPF] |

**Testemunhas:**

1. Nome: [NOME] — CPF: [CPF]
2. Nome: [NOME] — CPF: [CPF]

---

## Anexos (referência)

- **Anexo I — Plano e Preços:** modalidade, valores fixos e variáveis, ciclo de faturamento, forma de pagamento.
- **Anexo II — SLA:** metas de disponibilidade, severidades, créditos de serviço.
- **Anexo III — DPA (Acordo de Tratamento de Dados):** papéis, sub-operadores, medidas de segurança, incidentes, direitos de titulares, transferência internacional, retenção e eliminação.
- **Anexo IV — Lista de Sub-operadores:** Supabase, Netlify, VHSYS, Correios, Monetizze, AppMax, Hotmart, Kiwify, provedores de WhatsApp/e-mail.

---

# Engenharia Jurídica & Governança

## (a) Fundamentação das cláusulas (lei/norma que embasa)

| Cláusula | Fundamento legal/normativo |
|---|---|
| 1 e 14 — Qualificação e Foro | Código Civil (Lei nº 10.406/2002), arts. 421-422 (função social e boa-fé), art. 78 (foro de eleição); CPC art. 63. |
| 1.4 — Relação B2B | CDC (Lei nº 8.078/1990) — afastamento entre empresárias com paridade; teoria finalista mitigada. |
| 3 e 10 — Objeto e Licença de Software | Lei de Software (Lei nº 9.609/1998); Lei de Direitos Autorais (Lei nº 9.610/1998); LPI (Lei nº 9.279/1996). |
| 4 — Preço e Pagamento | Código Civil, arts. 315-333 (pagamento), 389 e 395 (mora), 406-407 (juros); liberdade contratual. |
| 4.7 — Split e Repasses | Regulação de arranjos de pagamento (Lei nº 12.865/2013) — delimitação de que a CONTRATADA não é instituição de pagamento. |
| 7 — Confidencialidade | Lei de Segredo de Negócio / concorrência desleal (Lei nº 9.279/1996, art. 195, XI-XII); Código Civil, arts. 186 e 927. |
| 8 — Proteção de Dados | LGPD (Lei nº 13.709/2018): arts. 5º, 6º, 7º, 9º, 37, 39, 42-45, 46, 48; Marco Civil (Lei nº 12.965/2014). |
| 9 — SLA | Autonomia contratual; Código Civil, art. 389 (perdas e danos); boa-fé objetiva. |
| 11 — Responsabilidade | Código Civil, arts. 389, 393 (força maior), 402-405 (perdas e danos), 927; LGPD art. 42-45 (responsabilidade solidária Controlador/Operador). |
| 12 — Vigência e Rescisão | Código Civil, arts. 472-480 (extinção), 473 (denúncia), 474-475 (resolução); Lei nº 11.101/2005 (insolvência). |
| 13.8 — Assinatura eletrônica | MP nº 2.200-2/2001 (ICP-Brasil); Lei nº 14.063/2020. |
| Normas de segurança | ISO/IEC 27001, 27701, 22301, 31000; NIST CSF; OWASP; GDPR (referência para transferência internacional). |

## (b) Riscos mitigados

1. **Vazamento e acesso cross-tenant** — mitigado por RLS + RBAC + credenciais write-only + trilha de auditoria (Cláusulas 5, 8.5).
2. **Confusão de papéis LGPD** — a Cláusula 8.1 fixa a dupla natureza (Operadora dos Dados do Comprador; Controladora dos dados de usuários), evitando responsabilização indevida.
3. **Responsabilização por falha de terceiros** (Correios, gateways, VHSYS, mensageria) — isolada na Cláusula 11.5 e excluída do SLA (9.4).
4. **Inadimplência** — suspensão gradual, multa/juros e rescisão (Cláusulas 4.5, 4.6, 12.4).
5. **Exposição de PII no portal público** — mitigada pela previsão de status neutro (Cláusulas 3.2.5, 8.5 — minimização).
6. **Uso indevido/ilícito de produtos e dados** — responsabilidade e indenização transferidas à CONTRATANTE (Cláusulas 6, 11.1, 11.7).
7. **Perda de dados no encerramento** — portabilidade e prazo de exportação garantidos (Cláusula 12.6).
8. **Responsabilidade ilimitada** — cap de 12 meses e exclusão de danos indiretos (Cláusulas 11.3-11.4).
9. **Subcontratação sem consentimento** — autorização expressa de sub-operadores e dever de aviso (Cláusula 8.4).
10. **Transferência internacional** — salvaguardas dos arts. 33-36 da LGPD (Cláusula 8.8).

## (c) Checklist de conformidade pré-assinatura

- [ ] Placeholders preenchidos (razão social, CNPJ, endereços, representantes, datas).
- [ ] Anexo I (plano e preços) anexado e coerente com a proposta comercial.
- [ ] Anexo II (SLA) com índices e créditos definidos.
- [ ] DPA (Anexo III) firmado e alinhado à Cláusula 8.
- [ ] Lista de sub-operadores (Anexo IV) atualizada.
- [ ] Encarregado (DPO) e canal lemoncapsencapsulados@gmail.com indicados.
- [ ] Bases legais da CONTRATANTE (Controladora) documentadas.
- [ ] Índice de reajuste e foro validados pelo jurídico.
- [ ] Validação por advogado(a) habilitado(a) concluída (retirar aviso de MINUTA).
- [ ] Poderes dos signatários conferidos (contrato social/procuração).

## (d) Matriz RACI

| Atividade | CONTRATANTE (Controladora) | CONTRATADA (Operadora/GLOP) | DPO / Encarregado | Jurídico |
|---|---|---|---|---|
| Definir finalidade e base legal do tratamento | R/A | C | C | C |
| Coletar consentimento/informar Compradores | R/A | I | C | C |
| Operar dados (expedição, NF-e, rastreio, split) | A | R | I | I |
| Manter segurança (RLS, RBAC, criptografia) | C | R/A | C | I |
| Gerir sub-operadores | I | R/A | C | C |
| Responder a titulares (arts. 18-19 LGPD) | A/R | R (suporte técnico) | C | C |
| Notificar incidente à ANPD e titulares | R/A | R (comunica a Controladora) | A | C |
| Faturamento e cobrança | A (pagar) | R | I | I |
| Cumprir SLA e suporte | I | R/A | I | I |
| Encerramento e portabilidade de dados | A | R | C | C |
| Revisão contratual e legal | C | C | C | R/A |

Legenda: R = Responsável (executa), A = Aprovador (responde), C = Consultado, I = Informado.

## (e) Plano de revisão

1. **Periodicidade:** revisão ordinária a cada **12 meses** ou sempre que houver alteração legislativa relevante (LGPD/ANPD, regulação de pagamentos, normas de transporte).
2. **Gatilhos extraordinários:** novo sub-operador; incidente de segurança relevante; mudança de arquitetura; alteração de plano/preço; decisão da ANPD ou jurisprudência aplicável.
3. **Responsável:** área Jurídica com apoio do DPO e da área de Segurança da Informação.
4. **Registro:** toda revisão versionada na tabela de Controle de Versão e comunicada às Partes com antecedência mínima de 30 dias quando impactar direitos.

## (f) Controle de versão

| Versão | Data | Autor | Alterações | Status |
|---|---|---|---|---|
| 0.1 | 16 de julho de 2026 | Chief Legal AI | Minuta inicial B2B (SaaS GLOP) | MINUTA — pendente de revisão jurídica |
| 1.0 | 16 de julho de 2026 | [ADVOGADO(A) RESPONSÁVEL] | Revisão e validação; retirada do aviso de minuta | [pendente] |

---

> ⚠️ Documento gerado por IA. Antes do uso em produção, submeta à revisão de advogado(a) habilitado(a), preencha todos os placeholders e valide a aderência à operação real do GLOP e à legislação vigente.
