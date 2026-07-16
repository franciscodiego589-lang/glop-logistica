> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# CONTRATO DE PRESTAÇÃO DE SERVIÇOS LOGÍSTICOS E TECNOLÓGICOS (SaaS) — PLATAFORMA GLOP

**Instrumento Particular de Prestação de Serviços de Tecnologia (Software como Serviço), Orquestração Logística e Intermediação de Integrações**

---

## PREÂMBULO

Pelo presente instrumento particular e na melhor forma de direito, as partes adiante qualificadas — de um lado a prestadora dos serviços de tecnologia e orquestração logística, doravante denominada **CONTRATADA** ou **GLOP**, e de outro a pessoa jurídica ou física contratante dos serviços, doravante denominada **CONTRATANTE** ou **CLIENTE** — têm entre si, justo e contratado, o presente **Contrato de Prestação de Serviços Logísticos e Tecnológicos** (o "**Contrato**"), que se regerá pelas cláusulas e condições seguintes, com fundamento no Código Civil (Lei nº 10.406/2002), na Lei do Software (Lei nº 9.609/1998), na Lei de Direitos Autorais (Lei nº 9.610/1998), na Lei Geral de Proteção de Dados Pessoais — LGPD (Lei nº 13.709/2018), no Marco Civil da Internet (Lei nº 12.965/2014) e, quando aplicável, no Código de Defesa do Consumidor (Lei nº 8.078/1990).

---

## CLÁUSULA 1 — DAS PARTES E QUALIFICAÇÃO

### 1.1. Da CONTRATADA

**LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA**, nome fantasia **[NOME FANTASIA: GLOP]**, pessoa jurídica de direito privado, inscrita no CNPJ sob o nº **55.836.075/0001-07**, com sede em **Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190**, neste ato representada na forma de seus atos constitutivos, provedora da plataforma **GLOP (Global Logistics Platform)**, um sistema SaaS de logística e ERP (WMS/TMS/gestão de pedidos) voltado a operações de dropshipping e infoprodutos no Brasil.

### 1.2. Da CONTRATANTE

**[CONTRATANTE — RAZÃO SOCIAL / NOME]**, inscrita no CNPJ/CPF sob o nº **[CNPJ/CPF]**, com sede/domicílio em **Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190**, neste ato representada na forma de seus atos constitutivos ou por si própria, doravante **CLIENTE**.

### 1.3. Da definição das partes

As partes acima poderão ser referidas, individualmente, como **PARTE** e, em conjunto, como **PARTES**. Cada PARTE declara e garante possuir plena capacidade civil e legitimidade para celebrar o presente Contrato, bem como que os signatários detêm poderes bastantes para tanto.

### 1.4. Da natureza jurídica das partes no tratamento de dados

Para os fins da LGPD e das cláusulas de proteção de dados deste Contrato:

- A **CONTRATANTE (CLIENTE)** figura como **CONTROLADORA** dos dados pessoais dos compradores finais (titulares) ingeridos e tratados por meio da plataforma GLOP, competindo-lhe as decisões sobre a finalidade e os meios essenciais do tratamento;
- A **GLOP (CONTRATADA)** figura como **OPERADORA**, tratando tais dados pessoais em nome e por conta da CONTRATANTE, exclusivamente conforme as instruções documentadas desta e nos limites do presente Contrato e do respectivo **Acordo de Tratamento de Dados (DPA)**, que integra este instrumento;
- Quanto aos dados dos próprios usuários, colaboradores e representantes da CONTRATANTE que acessam a plataforma (dados de conta, autenticação, faturamento e suporte), a GLOP atua como **CONTROLADORA** para as finalidades de prestação, segurança, cobrança e cumprimento de obrigações legais.

---

## CLÁUSULA 2 — DAS DEFINIÇÕES

Para os efeitos deste Contrato, os termos abaixo terão o significado a seguir atribuído:

- **Plataforma / GLOP:** o software como serviço (SaaS) de logística e ERP disponibilizado pela CONTRATADA, incluindo módulos de ingestão de pedidos, gestão logística (WMS/TMS), pré-postagem, rastreio, coprodução/split, emissão de documentos fiscais e portal público de rastreio.
- **Comprador / Titular:** a pessoa natural adquirente de produtos/infoprodutos da CONTRATANTE, cujos dados pessoais são tratados na Plataforma.
- **PII / Dados Pessoais:** nome, CPF/CNPJ, e-mail, telefone, endereço completo, dados do produto, valores e demais dados relacionados a pessoa natural identificada ou identificável.
- **Sub-operadores / Subcontratados:** terceiros contratados pela GLOP para viabilizar a prestação, tais como Supabase e Netlify (infraestrutura/hospedagem), VHSYS (emissão de NF-e), Correios (transporte, pré-postagem e rastreio) e gateways de pagamento (Monetizze, AppMax, Hotmart, Kiwify), além de provedores de mensageria (WhatsApp/e-mail).
- **Tenant / Company / Branch / Membership:** a hierarquia multi-tenant de isolamento lógico dos dados, na qual cada CONTRATANTE opera em ambiente segregado por RLS (Row Level Security).
- **RLS:** mecanismo de segurança em nível de linha do banco de dados PostgreSQL/Supabase que assegura o isolamento por empresa, impedindo acesso cruzado entre tenants.
- **RBAC:** controle de acesso baseado em papéis (has_permission), que define permissões por função do usuário.
- **DPA:** Acordo de Tratamento de Dados Pessoais, anexo e parte integrante deste Contrato.
- **SLA:** Acordo de Nível de Serviço, que define metas de disponibilidade e suporte.
- **Portal Público de Rastreio:** interface acessível sem login que expõe exclusivamente status neutro de entrega, sem PII do comprador.

---

## CLÁUSULA 3 — DO OBJETO

### 3.1. Objeto principal

Constitui objeto deste Contrato a **prestação, pela CONTRATADA à CONTRATANTE, de serviços de tecnologia da informação na modalidade Software como Serviço (SaaS) e de orquestração logística**, mediante disponibilização de acesso à plataforma **GLOP**, hospedada em nuvem, para gestão do ciclo logístico de pedidos de dropshipping e infoprodutos, compreendendo, conforme o plano contratado:

1. **Ingestão e centralização de pedidos** provenientes de gateways de pagamento e plataformas de e-commerce, via integração por API — notadamente **Monetizze, Hotmart e Kiwify** (gateways/checkouts) e **Shopify, WooCommerce, Nuvemshop e Mercado Livre** (e-commerces/marketplaces);
2. **Gestão logística (WMS/TMS)** dos pedidos, incluindo organização, separação, status e roteirização das informações de expedição;
3. **Pré-postagem junto aos Correios (PPN)** e **rastreamento (SRO)**, com atualização de status de entrega;
4. **Notificação ao comprador** por e-mail e/ou WhatsApp acerca do andamento da entrega;
5. **Módulo de coprodução e split**, com cadastro de coprodutores/afiliados, cálculo de comissão, apuração, repasses e split de pagamentos (incluindo integração com AppMax e tratamento de dados de PIX/bancários para repasse);
6. **Emissão e gestão de documentos fiscais (NF-e) via VHSYS** e correlatos;
7. **Portal público de rastreio** sem necessidade de login, que expõe apenas status neutro de entrega, sem exposição de PII do comprador;
8. **Recursos de segurança e governança** nativos da Plataforma: isolamento por RLS por empresa, controle de acesso por RBAC (has_permission), soft-delete, trilha de auditoria por triggers, colunas de auditoria em todos os registros e armazenamento de credenciais de integração em modo write-only.

### 3.2. Natureza dos serviços

Os serviços prestados são de **meio, e não de fim**, no que se refere à intermediação de integrações e à orquestração de terceiros (Correios, gateways, VHSYS, mensageria). A GLOP disponibiliza a tecnologia e a orquestração; **a decisão comercial, a responsabilidade fiscal, a política de preços, o cumprimento das obrigações perante o comprador final e a decisão sobre o tratamento de dados dos compradores permanecem com a CONTRATANTE**, na qualidade de fornecedora dos produtos e controladora dos dados.

### 3.3. Não exclusividade

O presente Contrato é celebrado **sem exclusividade** para qualquer das PARTES, ressalvadas obrigações específicas de confidencialidade e de não concorrência eventualmente pactuadas em instrumento apartado.

---

## CLÁUSULA 4 — DO ESCOPO DOS SERVIÇOS E SUAS EXCLUSÕES

### 4.1. Escopo incluído

Conforme o plano e as condições comerciais contratadas (Anexo de Planos), o escopo incluído compreende: acesso à Plataforma em ambiente multi-tenant isolado; provisionamento de tenant/company/branch; configuração de integrações suportadas; disponibilização de atualizações e correções da Plataforma; suporte técnico conforme o SLA; e disponibilização de logs e trilhas de auditoria pertinentes ao ambiente da CONTRATANTE.

### 4.2. Escopo expressamente excluído

Salvo previsão diversa em anexo, **não integram** o objeto deste Contrato:

1. Consultoria fiscal, contábil ou jurídica da CONTRATANTE;
2. A relação da CONTRATANTE com os gateways de pagamento, com os Correios, com a VHSYS e demais terceiros, cujas contas, credenciais, tarifas e condições são de titularidade e responsabilidade da CONTRATANTE;
3. O transporte físico das mercadorias, executado pelos Correios ou transportadora contratada, cabendo à GLOP apenas a orquestração de pré-postagem e rastreio;
4. A veracidade, licitude e completude dos dados inseridos pela CONTRATANTE ou por ela ingeridos de suas próprias fontes;
5. Desenvolvimento de customizações, integrações não suportadas ou funcionalidades sob demanda, que dependerão de proposta e aceite específicos;
6. Recuperação de dados perdidos por ato ou omissão exclusiva da CONTRATANTE.

### 4.3. Requisitos e cooperação da CONTRATANTE

A prestação depende de a CONTRATANTE fornecer, manter válidas e atualizadas as credenciais/tokens de integração (armazenadas em modo write-only), manter conexão de internet adequada, designar usuários e papéis (RBAC) e cumprir os requisitos técnicos mínimos informados pela GLOP.

---

## CLÁUSULA 5 — DA IMPLANTAÇÃO, PRAZOS E CRONOGRAMA

### 5.1. Ativação

A ativação do ambiente da CONTRATANTE (provisionamento de tenant) ocorrerá em até **[X] dias úteis** contados da confirmação da contratação e do fornecimento das informações e credenciais necessárias.

### 5.2. Onboarding de integrações

A habilitação de cada integração (gateway, e-commerce, Correios, VHSYS, mensageria) observará prazo de até **[X] dias úteis** por integração, condicionada à entrega, pela CONTRATANTE, das credenciais válidas e à disponibilidade dos serviços de terceiros.

### 5.3. Marcos e homologação

Sempre que houver etapa de implantação, as PARTES poderão estabelecer marcos (kick-off, configuração, testes e homologação). A ausência de manifestação da CONTRATANTE em **[X] dias úteis** após a comunicação de conclusão de um marco importará homologação tácita daquela etapa.

### 5.4. Fatores fora do controle da GLOP

Atrasos decorrentes de indisponibilidade, alteração de API, mudança de política ou falha de terceiros (Supabase, Netlify, Correios, VHSYS, gateways, provedores de WhatsApp/e-mail), bem como de mora da CONTRATANTE, não configuram inadimplemento da GLOP e suspendem os prazos correspondentes.

---

## CLÁUSULA 6 — DO PREÇO E DAS CONDIÇÕES DE PAGAMENTO

### 6.1. Remuneração

Pela prestação dos serviços, a CONTRATANTE pagará à CONTRATADA os valores previstos no **Anexo de Planos e Preços**, na modalidade contratada, que poderá incluir: **(i)** assinatura mensal/anual (SaaS); **(ii)** tarifação por volume (por pedido processado, integração ativa, notificação enviada ou documento emitido); **(iii)** valores de implantação/setup; e **(iv)** eventuais serviços adicionais sob demanda.

### 6.2. Forma e vencimento

O pagamento será efetuado por **[MEIO DE PAGAMENTO]**, com vencimento no dia **[X]** de cada ciclo. A emissão do respectivo documento fiscal observará a legislação aplicável.

### 6.3. Repasses de terceiros (pass-through)

Custos de terceiros (por exemplo, postagem dos Correios, tarifas de gateways ou de emissão fiscal) que sejam eventualmente adiantados ou intermediados pela GLOP serão repassados à CONTRATANTE pelo valor de custo, acrescidos, se houver, da taxa de intermediação prevista no Anexo de Planos. Os valores de **split e repasses a coprodutores/afiliados** transitam por conta e ordem da CONTRATANTE e/ou do gateway responsável (AppMax), não constituindo receita da GLOP, salvo a tarifa de serviço expressamente pactuada.

### 6.4. Reajuste

Os valores serão reajustados anualmente pela variação do **[ÍNDICE: IPCA/IGP-M]** ou, na sua falta, por índice que o substitua, contado da data-base **16 de julho de 2026**.

### 6.5. Mora e inadimplemento

O atraso no pagamento sujeitará a CONTRATANTE a: **(i)** multa moratória de **2%** sobre o valor devido; **(ii)** juros de mora de **1% ao mês**, pro rata die; e **(iii)** correção monetária. Persistindo o inadimplemento por mais de **[X] dias**, a GLOP poderá **suspender o acesso à Plataforma** mediante aviso prévio de **[X] dias**, sem prejuízo da cobrança e da rescisão.

### 6.6. Tributos

Cada PARTE é responsável pelos tributos que a lei lhe atribuir. Os preços não incluem tributos que venham a ser exigidos e que possam ser legalmente repassados.

---

## CLÁUSULA 7 — DAS OBRIGAÇÕES DA CONTRATADA (GLOP)

Constituem obrigações da CONTRATADA:

1. Disponibilizar a Plataforma GLOP em ambiente multi-tenant, com isolamento lógico por RLS por empresa, mantendo os padrões de segurança descritos neste Contrato;
2. Envidar os melhores esforços para manter a disponibilidade da Plataforma conforme o SLA (Cláusula 9);
3. Tratar os dados pessoais dos compradores **exclusivamente como OPERADORA**, seguindo as instruções documentadas da CONTRATANTE e o DPA, adotando medidas técnicas e organizacionais adequadas (RLS, RBAC/has_permission, soft-delete, trilha de auditoria por triggers, colunas de auditoria, credenciais write-only, criptografia em trânsito e segregação por tenant);
4. Manter registro (logs) e trilha de auditoria das operações relevantes no ambiente da CONTRATANTE, disponibilizando-os conforme aplicável;
5. Assegurar que o **Portal Público de Rastreio** exponha apenas status neutro de entrega, sem PII do comprador;
6. Comunicar à CONTRATANTE, sem demora injustificada, incidentes de segurança que possam acarretar risco ou dano relevante aos titulares, nos termos do DPA e da LGPD;
7. Prestar suporte técnico nos canais e prazos do SLA;
8. Disponibilizar atualizações, correções e melhorias de segurança da Plataforma;
9. Contratar sub-operadores idôneos, impondo-lhes obrigações de proteção de dados compatíveis com este Contrato (Cláusula 10);
10. Colaborar com a CONTRATANTE no atendimento a requisições de titulares e de autoridades, na medida de sua atuação como Operadora;
11. Ao término do Contrato, restituir e/ou eliminar os dados nos termos da Cláusula 15 e do DPA.

---

## CLÁUSULA 8 — DAS OBRIGAÇÕES DA CONTRATANTE (CLIENTE)

Constituem obrigações da CONTRATANTE:

1. Utilizar a Plataforma de forma lícita, conforme este Contrato, a legislação vigente e a Política de Uso Aceitável;
2. Na qualidade de **CONTROLADORA**, definir as finalidades e os meios do tratamento dos dados dos compradores, dispor de **base legal adequada** (execução de contrato, cumprimento de obrigação legal, legítimo interesse ou consentimento, conforme o caso) e prestar as informações e obter os consentimentos eventualmente necessários perante os titulares;
3. Fornecer e manter válidas e atualizadas as credenciais/tokens das integrações (gateways, e-commerces, Correios, VHSYS, mensageria), respondendo por sua titularidade e regularidade;
4. Garantir a veracidade, licitude, exatidão e atualização dos dados inseridos ou ingeridos por meio de suas fontes;
5. Responder integralmente pela relação com o **comprador final** (qualidade do produto, entrega, trocas, devoluções, cobranças, SAC e obrigações do CDC quando aplicável);
6. Cumprir suas **obrigações fiscais e tributárias**, sendo a emissão de NF-e via VHSYS mera ferramenta, cuja correção do conteúdo fiscal é de responsabilidade da CONTRATANTE;
7. Gerir adequadamente os acessos de seus usuários, papéis e permissões (RBAC), preservando o sigilo das credenciais;
8. Não realizar, nem permitir, engenharia reversa, cópia não autorizada, sublicenciamento, revenda não autorizada, testes de intrusão sem autorização prévia por escrito, ou uso que comprometa a segurança e o isolamento entre tenants;
9. Efetuar os pagamentos nos prazos pactuados;
10. Comunicar à GLOP, sem demora, suspeita de uso indevido, comprometimento de credenciais ou incidente de sua alçada;
11. Obter e manter as autorizações necessárias para envio de comunicações a compradores por e-mail/WhatsApp, observando as normas de mensageria e de proteção de dados.

---

## CLÁUSULA 9 — DOS NÍVEIS DE SERVIÇO (SLA)

### 9.1. Disponibilidade

A CONTRATADA envidará seus melhores esforços para manter a Plataforma disponível com meta de **[99,X]% ao mês**, apurada mensalmente, excluídas da base de cálculo as janelas de manutenção programada e os eventos de força maior/terceiros (Cláusula 9.4).

### 9.2. Manutenção programada

Manutenções programadas serão comunicadas com antecedência mínima de **[X] horas**, preferencialmente em horários de menor uso.

### 9.3. Suporte e prazos de resposta

O atendimento observará os seguintes prazos-alvo, contados em horário útil, conforme severidade:

| Severidade | Descrição | Tempo-alvo de 1ª resposta | Tempo-alvo de contorno/solução |
|---|---|---|---|
| **P1 — Crítica** | Indisponibilidade total da Plataforma ou falha que impeça o processamento de pedidos | **[X] h** | **[X] h** |
| **P2 — Alta** | Falha relevante em módulo essencial (ingestão, pré-postagem, split) com contorno parcial | **[X] h** | **[X] h úteis** |
| **P3 — Média** | Falha não crítica ou intermitente, sem bloqueio da operação | **[X] h úteis** | **[X] dias úteis** |
| **P4 — Baixa** | Dúvidas, solicitações de melhoria e questões cosméticas | **[X] dias úteis** | Conforme roadmap |

### 9.4. Exclusões do SLA

Não configuram indisponibilidade imputável à GLOP as interrupções decorrentes de: **(i)** falha, manutenção, alteração de API ou indisponibilidade de terceiros (Supabase, Netlify, Correios, VHSYS, gateways, provedores de WhatsApp/e-mail); **(ii)** ato ou omissão da CONTRATANTE, uso indevido ou credenciais inválidas; **(iii)** força maior/caso fortuito; **(iv)** ataques cibernéticos externos apesar das medidas razoáveis de segurança; **(v)** suspensão por inadimplência.

### 9.5. Créditos de serviço

O descumprimento das metas de disponibilidade, apurado e comprovado, poderá ensejar **crédito de serviço** conforme escala do Anexo de SLA, o qual constitui **remédio exclusivo** da CONTRATANTE por indisponibilidade, salvo dolo ou culpa grave.

---

## CLÁUSULA 10 — DA SUBCONTRATAÇÃO E DOS SUB-OPERADORES

### 10.1. Autorização geral

A CONTRATANTE **autoriza expressamente** a GLOP a subcontratar terceiros (subcontratados/sub-operadores) para a execução dos serviços, incluindo, sem limitação: **Supabase e Netlify** (infraestrutura, banco de dados e hospedagem SSR), **VHSYS** (emissão de NF-e), **Correios** (transporte, pré-postagem PPN e rastreio SRO), **gateways de pagamento** (Monetizze, AppMax, Hotmart, Kiwify) e **provedores de mensageria** (WhatsApp e e-mail).

### 10.2. Responsabilidade e diligência

A GLOP permanece responsável perante a CONTRATANTE pela execução das obrigações delegadas a seus sub-operadores, na medida de sua atuação, obrigando-se a selecioná-los com diligência e a lhes impor, por contrato, deveres de proteção de dados e segurança **não menos protetivos** do que os deste Contrato e do DPA.

### 10.3. Alteração de sub-operadores

A GLOP poderá alterar, incluir ou substituir sub-operadores, comunicando a CONTRATANTE com antecedência razoável quando a mudança for material para o tratamento de dados. A CONTRATANTE poderá opor-se a novo sub-operador por **motivo legítimo e fundamentado** relativo à proteção de dados; não sendo possível solução alternativa razoável, faculta-se a rescisão do módulo afetado, sem penalidade, na forma da Cláusula 15.

### 10.4. Relação direta com terceiros

Sempre que a integração dependa de conta própria da CONTRATANTE junto a terceiros (por exemplo, contrato de postagem com Correios, conta em gateway, cadastro na VHSYS), tais relações são regidas pelos respectivos termos daqueles terceiros, aos quais a CONTRATANTE deve aderir diretamente, não respondendo a GLOP por seus atos, tarifas ou políticas.

---

## CLÁUSULA 11 — DA PROTEÇÃO DE DADOS PESSOAIS (LGPD)

### 11.1. Remissão ao DPA

O tratamento de dados pessoais no âmbito deste Contrato rege-se pelo **Acordo de Tratamento de Dados Pessoais (DPA)**, anexo e parte integrante e indissociável deste instrumento. Em caso de conflito sobre matéria de proteção de dados, prevalece o DPA.

### 11.2. Papéis (dupla natureza)

Conforme a Cláusula 1.4: a CONTRATANTE é **CONTROLADORA** dos dados dos compradores; a GLOP é **OPERADORA** desses dados e **CONTROLADORA** dos dados de conta/usuários da CONTRATANTE para as finalidades de prestação, segurança e cobrança.

### 11.3. Objeto, natureza, finalidade e duração do tratamento

A GLOP tratará os dados dos compradores (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto, valor e, no módulo de split, dados de PIX/bancários de coprodutores/afiliados) para as finalidades de **ingestão de pedidos, orquestração logística, pré-postagem e rastreio, notificação ao comprador, apuração e repasse de split e emissão de documentos fiscais**, pelo prazo de vigência do Contrato e pelos prazos legais de retenção subsequentes.

### 11.4. Instruções e finalidade

A GLOP tratará os dados **somente conforme instruções documentadas** da CONTRATANTE e para as finalidades contratuais, não os utilizando para fins próprios incompatíveis, ressalvado o cumprimento de obrigação legal/regulatória, hipótese em que informará a CONTRATANTE, salvo vedação legal.

### 11.5. Medidas de segurança

A GLOP adota, no mínimo: isolamento por **RLS** por empresa; controle de acesso por **RBAC/has_permission**; **soft-delete**; **trilha de auditoria por triggers** e colunas de auditoria em todo registro; **credenciais de API em modo write-only**; criptografia em trânsito; segregação por **tenant/company/branch**; e o **Portal Público de Rastreio** limitado a status neutro, sem PII.

### 11.6. Direitos dos titulares

A GLOP auxiliará a CONTRATANTE, na medida técnica possível e como Operadora, no atendimento a requisições dos titulares (confirmação, acesso, correção, anonimização, portabilidade, eliminação e informações sobre compartilhamento), competindo à CONTRATANTE, como Controladora, a decisão e a resposta ao titular.

### 11.7. Incidentes de segurança

A GLOP comunicará à CONTRATANTE, sem demora injustificada, a ocorrência de incidente de segurança que possa acarretar risco ou dano relevante aos titulares, fornecendo as informações necessárias para que a CONTRATANTE cumpra seus deveres de comunicação à ANPD e aos titulares, quando cabível.

### 11.8. Transferência internacional

Havendo tratamento por sub-operadores fora do território nacional (por exemplo, infraestrutura de nuvem), a GLOP adotará salvaguardas compatíveis com a LGPD (cláusulas-padrão, garantias contratuais e demais mecanismos admitidos pela ANPD).

### 11.9. Eliminação/devolução

Encerrado o tratamento, a GLOP eliminará ou devolverá os dados pessoais conforme a Cláusula 15 e o DPA, ressalvada a guarda legal obrigatória (por exemplo, registros de conexão nos termos do Marco Civil da Internet e obrigações fiscais).

---

## CLÁUSULA 12 — DA PROPRIEDADE INTELECTUAL

### 12.1. Titularidade da Plataforma

A Plataforma GLOP, seu código-fonte e objeto, arquitetura, banco de dados, telas, marcas, nome, layout, documentação e todo material correlato são de **titularidade exclusiva da CONTRATADA** (ou de seus licenciadores), protegidos pela Lei nº 9.609/1998, Lei nº 9.610/1998 e legislação de propriedade industrial. Este Contrato **não transfere** qualquer direito de propriedade sobre a Plataforma.

### 12.2. Licença de uso

A GLOP concede à CONTRATANTE licença **não exclusiva, intransferível, não sublicenciável e revogável** de uso da Plataforma, limitada à vigência e às finalidades deste Contrato.

### 12.3. Dados da CONTRATANTE

Os **dados inseridos e ingeridos pela CONTRATANTE** (pedidos, dados de compradores e conteúdos) permanecem de titularidade/responsabilidade da CONTRATANTE. A GLOP recebe apenas os direitos necessários para tratá-los na execução dos serviços.

### 12.4. Feedback

Sugestões e feedbacks fornecidos pela CONTRATANTE poderão ser utilizados pela GLOP para aprimorar a Plataforma, sem gerar obrigação de contrapartida.

### 12.5. Dados agregados/anonimizados

A GLOP poderá gerar e utilizar dados **estatísticos, agregados e efetivamente anonimizados** (que não permitam reidentificação), para operação, segurança e melhoria da Plataforma, sem que isso configure tratamento de dados pessoais.

---

## CLÁUSULA 13 — DA CONFIDENCIALIDADE

### 13.1. Dever de sigilo

Cada PARTE obriga-se a manter em sigilo e a não divulgar a terceiros as **Informações Confidenciais** da outra a que tiver acesso, utilizando-as apenas para os fins deste Contrato. Consideram-se confidenciais dados técnicos, comerciais, financeiros, credenciais, dados pessoais, código, arquitetura e quaisquer informações identificadas como confidenciais ou que, por sua natureza, assim devam ser tratadas.

### 13.2. Exceções

Não se sujeitam ao dever de sigilo informações que: **(i)** sejam ou se tornem públicas sem violação deste Contrato; **(ii)** já fossem legitimamente conhecidas; **(iii)** sejam desenvolvidas de forma independente; ou **(iv)** devam ser reveladas por ordem legal/judicial, hipótese em que a PARTE requisitada notificará a outra, quando permitido.

### 13.3. Vigência do dever

O dever de confidencialidade subsiste durante a vigência e por **[5] anos** após o término do Contrato, e por prazo indeterminado quanto a segredos de negócio e dados pessoais.

---

## CLÁUSULA 14 — DA RESPONSABILIDADE E DA LIMITAÇÃO

### 14.1. Responsabilidade por culpa

Cada PARTE responde pelos danos diretos e comprovados a que der causa, por dolo ou culpa, no âmbito de suas obrigações.

### 14.2. Exclusões de responsabilidade da GLOP

A GLOP não responde por: **(i)** conteúdo, licitude, veracidade e consequências fiscais dos dados e documentos inseridos/emitidos pela CONTRATANTE (incluindo NF-e via VHSYS); **(ii)** relação da CONTRATANTE com o comprador final (produto, entrega física, devoluções, CDC); **(iii)** atos, falhas, indisponibilidades, tarifas ou políticas de terceiros/sub-operadores (Supabase, Netlify, Correios, VHSYS, gateways, mensageria); **(iv)** decisões de tratamento de dados tomadas pela CONTRATANTE na qualidade de Controladora; **(v)** uso indevido, credenciais comprometidas por culpa da CONTRATANTE ou lucros cessantes decorrentes de fatores fora de seu controle.

### 14.3. Limitação de responsabilidade

Ressalvados os casos de dolo, culpa grave, violação de confidencialidade e danos a que a lei impuser responsabilidade não limitável, a **responsabilidade total agregada** da GLOP por quaisquer danos decorrentes deste Contrato fica **limitada ao valor total efetivamente pago pela CONTRATANTE nos [12] meses anteriores ao fato gerador**.

### 14.4. Danos indiretos

Nenhuma PARTE responderá por **lucros cessantes, perda de dados por culpa exclusiva da outra, danos indiretos, incidentais ou consequenciais**, salvo dolo ou culpa grave.

### 14.5. Ressarcimento (indenização) entre as partes

A CONTRATANTE indenizará a GLOP por perdas decorrentes de: uso ilícito da Plataforma; violação de direitos de titulares por decisão sua como Controladora; inveracidade de dados; e reclamações de compradores ou de autoridades imputáveis à sua operação. A GLOP indenizará a CONTRATANTE por perdas decorrentes de violação comprovada de suas obrigações de Operadora e de segurança, nos limites da Cláusula 14.3.

### 14.6. Força maior

Nenhuma PARTE responde por inadimplemento decorrente de caso fortuito ou força maior (art. 393 do Código Civil), inclusive falhas generalizadas de terceiros essenciais, ataques cibernéticos apesar de medidas razoáveis, e determinações de autoridade.

---

## CLÁUSULA 15 — DA VIGÊNCIA E DA RESCISÃO

### 15.1. Vigência

O Contrato vigora por prazo **[determinado de [X] meses / indeterminado]**, a partir de **16 de julho de 2026**, renovando-se automaticamente por períodos iguais e sucessivos, salvo denúncia por qualquer PARTE com antecedência mínima de **[30] dias**.

### 15.2. Resilição imotivada

Qualquer PARTE poderá resilir o Contrato imotivadamente, mediante aviso prévio por escrito de **[30] dias**, sem penalidade, ressalvado o pagamento dos serviços prestados até a efetiva desativação.

### 15.3. Rescisão por justa causa

O Contrato poderá ser rescindido de pleno direito, independentemente de aviso ou indenização à PARTE infratora, em caso de: **(i)** descumprimento de obrigação relevante não sanada em **[15] dias** após notificação; **(ii)** inadimplemento de pagamento superior a **[X] dias**; **(iii)** uso ilícito da Plataforma ou violação de confidencialidade/proteção de dados; **(iv)** recuperação judicial, falência, insolvência ou dissolução.

### 15.4. Efeitos da rescisão

Com o término: **(i)** cessa a licença de uso e o acesso à Plataforma; **(ii)** tornam-se exigíveis os valores devidos até a data; **(iii)** cada PARTE devolve/elimina Informações Confidenciais, ressalvada a guarda legal.

### 15.5. Portabilidade e devolução de dados

Por período de até **[X] dias** após o término, a GLOP disponibilizará à CONTRATANTE a **exportação dos dados** em formato estruturado e de uso comum. Findo esse prazo, e observados os prazos legais de retenção (fiscais e do Marco Civil da Internet), a GLOP procederá à **eliminação** dos dados, salvo instrução em contrário admitida em lei.

### 15.6. Sobrevivência

Sobrevivem ao término as cláusulas que, por sua natureza, assim exijam, notadamente as de confidencialidade, proteção de dados, propriedade intelectual, responsabilidade, foro e as obrigações pecuniárias pendentes.

---

## CLÁUSULA 16 — DAS PENALIDADES

### 16.1. Multa por descumprimento

O descumprimento de obrigação contratual não pecuniária, não sanado no prazo da notificação, sujeitará a PARTE infratora a multa de **[10]% sobre o valor de [12] meses de serviço / valor fixo de [R$ X]**, sem prejuízo das perdas e danos apuradas e da rescisão.

### 16.2. Cumulatividade

As multas moratórias e compensatórias não se confundem e poderão ser cumuladas com juros, correção e perdas e danos, na forma da lei.

### 16.3. Suspensão como medida acautelatória

A suspensão de acesso por inadimplência ou por uso ilícito/risco à segurança não constitui penalidade, mas medida acautelatória legítima, e não afasta a exigibilidade dos valores devidos.

---

## CLÁUSULA 17 — DAS DISPOSIÇÕES GERAIS

1. **Independência das partes:** o Contrato não gera vínculo societário, associativo, empregatício, de consórcio ou de mandato entre as PARTES, que atuam de forma autônoma.
2. **Cessão:** a CONTRATANTE não poderá ceder o Contrato sem anuência prévia e por escrito da GLOP; a GLOP poderá cedê-lo a empresas do seu grupo ou em caso de reorganização societária, mediante comunicação.
3. **Comunicações:** as comunicações serão válidas quando feitas por escrito aos endereços e e-mails indicados no preâmbulo ou ao **lemoncapsencapsulados@gmail.com** para assuntos de proteção de dados.
4. **Novação e tolerância:** a tolerância quanto a qualquer descumprimento não implica novação, renúncia ou alteração do pactuado.
5. **Nulidade parcial:** a eventual nulidade de uma cláusula não prejudica as demais, que permanecem válidas.
6. **Integralidade:** este Contrato, com seus Anexos (Planos e Preços, SLA e DPA), constitui o acordo integral entre as PARTES, prevalecendo sobre entendimentos anteriores.
7. **Alterações:** alterações somente por termo aditivo escrito; ajustes de funcionalidades da Plataforma e de sub-operadores poderão ser comunicados na forma das Cláusulas 5 e 10.
8. **Assinatura eletrônica:** as PARTES admitem a assinatura eletrônica/digital, reconhecendo sua validade nos termos da legislação vigente e da MP 2.200-2/2001.

---

## CLÁUSULA 18 — DO FORO

As PARTES elegem o foro da Comarca de **[COMARCA/CIDADE-UF]**, com renúncia a qualquer outro, por mais privilegiado que seja, para dirimir as controvérsias oriundas deste Contrato, ressalvadas as hipóteses de competência legal cogente, inclusive a do domicílio do consumidor quando aplicável a relação com o comprador final. As PARTES poderão, facultativamente, buscar solução por **mediação/arbitragem** conforme cláusula compromissória em anexo, se pactuada.

E, por estarem assim justas e contratadas, as PARTES firmam o presente instrumento em via eletrônica.

**[CIDADE-UF]**, **16 de julho de 2026**.

_______________________________________
**[RAZÃO SOCIAL — GLOP]** — CONTRATADA

_______________________________________
**[CONTRATANTE]** — CONTRATANTE

**Testemunhas:**
1. Nome: __________________ CPF: __________________
2. Nome: __________________ CPF: __________________

---

# Engenharia Jurídica & Governança

## (a) Fundamentação das cláusulas

| Cláusula | Fundamento legal/normativo |
|---|---|
| Objeto, obrigações, prazo, rescisão, foro | Código Civil (Lei nº 10.406/2002), arts. 421-480 (contratos), 393 (força maior) |
| Licença e propriedade intelectual (Cl. 12) | Lei do Software (Lei nº 9.609/1998) e Lei de Direitos Autorais (Lei nº 9.610/1998) |
| Proteção de dados / dupla natureza / DPA (Cl. 1.4, 11) | LGPD (Lei nº 13.709/2018), arts. 5º, 6º, 7º, 37, 39, 46-49, 48 (incidentes), 33 (transferência internacional) |
| Retenção de logs e guarda legal (Cl. 11.9, 15.5) | Marco Civil da Internet (Lei nº 12.965/2014), arts. 13-15 |
| Relação com comprador final (Cl. 3.2, 8, 14.2) | Código de Defesa do Consumidor (Lei nº 8.078/1990) |
| Subcontratação/sub-operadores (Cl. 10) | LGPD art. 39 e responsabilidade solidária dos arts. 42-43 (mitigada por diligência) |
| Confidencialidade e segredo de negócio (Cl. 13) | Lei de Propriedade Industrial (Lei nº 9.279/1996), art. 195 |
| Assinatura eletrônica (Cl. 17.8) | MP 2.200-2/2001 (ICP-Brasil) e Lei nº 14.063/2020 |
| Limitação de responsabilidade (Cl. 14) | Código Civil, arts. 389, 402-404, 927; autonomia da vontade em relações B2B |
| Boas práticas de segurança (RLS/RBAC/auditoria) | Referência a ISO 27001/27701, NIST CSF, OWASP; LGPD art. 46 (medidas de segurança) |

## (b) Riscos mitigados

- **Confusão de papéis na LGPD:** a Cláusula 1.4 delimita GLOP como Operadora (dados do comprador) e Controladora (dados de conta), reduzindo risco de responsabilização indevida.
- **Responsabilidade por terceiros:** Cláusulas 4.2, 10 e 14.2 isolam falhas de Correios, VHSYS, gateways, Supabase/Netlify e mensageria.
- **Risco fiscal (NF-e/VHSYS):** Cláusula 8.6 e 14.2 atribuem o conteúdo fiscal à CONTRATANTE.
- **Exposição de PII no rastreio público:** Cláusulas 7.5 e 11.5 fixam status neutro, sem PII.
- **Inadimplência:** Cláusulas 6.5 e 16.3 permitem suspensão acautelatória e cobrança.
- **Vazamento/incidentes:** Cláusulas 11.5 e 11.7 estabelecem medidas técnicas e dever de comunicação.
- **Perda de dados no offboarding:** Cláusula 15.5 garante portabilidade antes da eliminação.
- **Relação de consumo:** Cláusula 3.2 e 8.5 mantêm com a CONTRATANTE a responsabilidade perante o comprador (CDC).

## (c) Checklist de conformidade

- [ ] Preencher todos os placeholders entre colchetes (partes, valores, prazos, índice, foro).
- [ ] Anexar e assinar o DPA (Acordo de Tratamento de Dados).
- [ ] Anexar o Anexo de Planos e Preços e o Anexo de SLA.
- [ ] Validar a lista atual de sub-operadores e as salvaguardas de transferência internacional.
- [ ] Confirmar base legal do tratamento pela CONTRATANTE (Controladora).
- [ ] Definir metas de SLA e créditos de serviço realistas.
- [ ] Revisar limites de responsabilidade com a área jurídica/seguros.
- [ ] Verificar consentimento/opt-in para mensageria WhatsApp/e-mail.
- [ ] Confirmar prazos legais de retenção (fiscal e Marco Civil).
- [ ] Validar cláusula de eleição de foro x competência do consumidor.

## (d) Matriz RACI

| Atividade | GLOP (Operadora/Prestadora) | CONTRATANTE (Controladora/Cliente) | Sub-operadores | DPO/Encarregado |
|---|---|---|---|---|
| Definir finalidade/base legal do tratamento | C | R/A | I | C |
| Disponibilizar e operar a Plataforma | R/A | I | R | I |
| Manter credenciais de integração válidas | I | R/A | I | I |
| Segurança técnica (RLS/RBAC/auditoria) | R/A | C | R | C |
| Emissão fiscal (conteúdo NF-e) | C (ferramenta) | R/A | R (VHSYS) | I |
| Atender direitos de titulares | R (apoio) | A | I | C |
| Comunicar incidente à ANPD/titulares | R (notifica) | A | I | R/A |
| Repasse/split a coprodutores | C | A | R (AppMax) | I |
| Portabilidade/eliminação no offboarding | R/A | A | R | C |

R = Responsável · A = Aprovador · C = Consultado · I = Informado

## (e) Plano de revisão

- **Revisão ordinária:** anual, ou a cada reajuste (data-base).
- **Revisão extraordinária:** a cada alteração legislativa relevante (LGPD/ANPD, CDC, Marco Civil), mudança material de sub-operadores, incidente de segurança ou alteração de escopo/planos.
- **Responsável:** DPO/Encarregado (a ser designado pela administração, lemoncapsencapsulados@gmail.com) em conjunto com o jurídico.
- **Gatilhos técnicos:** nova integração de gateway/e-commerce, mudança de infraestrutura (Supabase/Netlify) ou de política de mensageria.

## (f) Controle de versão

| Versão | Data | Autor | Alterações | Status |
|---|---|---|---|---|
| 0.1 | 16 de julho de 2026 | Chief Legal AI (minuta) | Redação inicial da minuta | Pendente de revisão jurídica |
| 1.0 | 16 de julho de 2026 | [REVISOR JURÍDICO] | Validação e ajustes finais | [Aprovado/Vigente] |
