> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# CONTRATO DE MARKETPLACE E DE PRESTAÇÃO DE SERVIÇOS DE INTERMEDIAÇÃO LOGÍSTICO-DIGITAL — PLATAFORMA GLOP

**Instrumento particular de adesão para credenciamento de vendedor (seller/lojista) e uso da plataforma de logística e gestão de pedidos GLOP**

---

## PREÂMBULO E QUALIFICAÇÃO DAS PARTES

Pelo presente **Contrato de Marketplace e de Prestação de Serviços de Intermediação Logístico-Digital** (doravante "**Contrato**"), de um lado:

**LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA**, sociedade empresária inscrita no CNPJ sob o nº **55.836.075/0001-07**, com sede em **Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190**, mantenedora e operadora da plataforma denominada **[NOME FANTASIA: GLOP]** — *Global Logistics Platform* (doravante "**GLOP**", "**Plataforma**" ou "**CONTRATADA**"); e, de outro lado:

**[CONTRATANTE]**, pessoa física ou jurídica qualificada no ato eletrônico de cadastro e aceite (formulário de credenciamento e *checkout* de adesão), cujos dados de qualificação — razão social ou nome, CPF/CNPJ, endereço, representante legal e dados de contato — integram este Contrato como se aqui transcritos estivessem (doravante "**SELLER**", "**Lojista**", "**Vendedor**" ou "**CONTRATANTE**").

GLOP e SELLER são individualmente denominados "**Parte**" e, em conjunto, "**Partes**".

**Considerando que:**

1. A GLOP é uma plataforma **SaaS** (*Software as a Service*) de logística e gestão empresarial (ERP/WMS/TMS) voltada às operações de **dropshipping** e **infoprodutos** no mercado brasileiro, construída sobre arquitetura **multi-tenant** (Tenant → Company → Branch → Membership), com isolamento lógico de dados por **RLS** (*Row-Level Security*), controle de acesso baseado em papéis (**RBAC**), trilha de auditoria e **soft-delete**;

2. A GLOP disponibiliza serviços de **ingestão automatizada de pedidos** via API e integrações com gateways de pagamento e checkouts (Monetizze, Hotmart, Kiwify, AppMax) e com plataformas de e-commerce (Shopify, WooCommerce, Nuvemshop, Mercado Livre), bem como serviços de **pré-postagem, rastreamento e notificação** integrados aos Correios (PPN/SRO), **emissão de documentos fiscais** via VHSYS, **portal público de rastreio** e módulos de **coprodução, comissionamento, apuração e split de pagamentos**;

3. O SELLER deseja utilizar a Plataforma para gerir seus pedidos, processos logísticos, fiscais e financeiros, expondo ou não seus produtos por meio dos canais integrados, na condição de responsável primário pelos produtos, ofertas e entregas comercializados sob sua conta;

4. As Partes reconhecem que a operação envolve tratamento de dados pessoais de compradores (terceiros) e de colaboradores, sujeitando-se à **Lei nº 13.709/2018 (LGPD)**, ao **Código de Defesa do Consumidor (Lei nº 8.078/1990 — CDC)**, ao **Marco Civil da Internet (Lei nº 12.965/2014)** e demais normas aplicáveis;

**Resolvem** celebrar o presente Contrato, que se regerá pelas cláusulas e condições seguintes.

---

## CLÁUSULA 1 — DEFINIÇÕES

Para os fins deste Contrato, os termos abaixo terão os significados a seguir atribuídos, no singular ou no plural:

| Termo | Definição |
|---|---|
| **Plataforma / GLOP** | Ambiente SaaS de logística e ERP disponibilizado pela CONTRATADA, incluindo painéis, APIs, integrações e o portal público de rastreio. |
| **SELLER / Lojista** | Pessoa física ou jurídica credenciada que utiliza a Plataforma para operar vendas, logística e gestão de pedidos sob sua conta e responsabilidade. |
| **Comprador / Consumidor** | Destinatário final do produto ou serviço adquirido do SELLER, cujos dados pessoais são tratados no âmbito da operação. |
| **Pedido** | Registro de uma transação de venda ingerida na Plataforma via API, integração de checkout/e-commerce ou inserção manual. |
| **Coprodutor / Afiliado** | Terceiro que participa da comissão ou do resultado de uma venda mediante regras de split configuradas pelo SELLER. |
| **Gateway** | Provedor de pagamento e/ou checkout integrado (Monetizze, Hotmart, Kiwify, AppMax e outros). |
| **Sub-operador / Suboperador** | Terceiro contratado pela GLOP para viabilizar o serviço (Supabase, Netlify, VHSYS, Correios, gateways, provedores de WhatsApp/e-mail). |
| **PII** | Dados pessoais e/ou dados pessoais sensíveis (nome, CPF/CNPJ, e-mail, telefone, endereço, dados bancários/PIX, entre outros). |
| **Controlador / Operador** | Nos termos do art. 5º da LGPD, conforme a natureza do tratamento em cada fluxo. |
| **DPA** | *Data Processing Agreement* / Acordo de Tratamento de Dados anexo e complementar a este Contrato. |
| **Tenant / Company / Branch** | Níveis da hierarquia multi-tenant de isolamento de dados na Plataforma. |
| **Painel do Seller** | Interface autenticada por meio da qual o SELLER opera sua conta. |
| **Taxa / Comissão** | Remuneração devida à GLOP e/ou a terceiros pela intermediação e serviços, na forma da Cláusula 7. |
| **Repasse** | Transferência ao SELLER (ou a coprodutores/afiliados) dos valores líquidos apurados, quando aplicável. |

---

## CLÁUSULA 2 — OBJETO

**2.1.** O objeto deste Contrato é a **concessão de licença de uso, não exclusiva e intransferível, da Plataforma GLOP**, aliada à **prestação de serviços de intermediação logístico-digital**, compreendendo, conforme os módulos contratados e ativados:

1. **Ingestão e gestão de pedidos** provenientes de gateways (Monetizze, Hotmart, Kiwify, AppMax) e de e-commerces (Shopify, WooCommerce, Nuvemshop, Mercado Livre), com centralização, deduplicação e enriquecimento de dados;
2. **Processos logísticos** de pré-postagem (PPN), geração de etiquetas, rastreamento (SRO) e **notificação ao comprador** por e-mail e/ou WhatsApp;
3. **Emissão de documentos fiscais** (NF-e) por meio da integração com a VHSYS, sob responsabilidade fiscal do SELLER;
4. **Coprodução, comissionamento, apuração e split de pagamentos**, incluindo tratamento de dados de PIX/bancários de coprodutores e afiliados quando configurados pelo SELLER;
5. **Portal público de rastreio**, sem autenticação, expondo apenas status neutro da entrega;
6. Recursos de **segurança, auditoria e governança** (RLS, RBAC, soft-delete, trilha de auditoria por *triggers*, credenciais de API *write-only*, colunas de auditoria em todo registro).

**2.2.** A GLOP atua como **provedora de aplicação de internet e prestadora de serviços de intermediação e apoio logístico**. A GLOP **não é** fabricante, importadora, produtora, vendedora, transportadora nem parte na relação de consumo estabelecida entre o SELLER e o Comprador, ressalvadas as hipóteses de responsabilidade previstas em lei e na Cláusula 9.

**2.3.** A adesão a este Contrato **não** cria vínculo societário, associativo, empregatício, de mandato geral, de franquia ou de sociedade de fato entre as Partes. Cada Parte responde por suas próprias obrigações legais, tributárias, trabalhistas e regulatórias.

---

## CLÁUSULA 3 — CADASTRO E CREDENCIAMENTO DO SELLER

**3.1. Requisitos de cadastro.** O credenciamento do SELLER exige o fornecimento de dados verídicos, completos e atualizados, incluindo, no mínimo:

1. Qualificação completa (nome/razão social, CPF/CNPJ, endereço, representante legal);
2. Dados de contato válidos (e-mail e telefone);
3. Dados de recebimento (conta bancária e/ou chave PIX), quando aplicável ao fluxo de repasse/split;
4. Aceite eletrônico deste Contrato, do DPA, dos Termos de Uso e da Política de Privacidade da Plataforma.

**3.2. Veracidade e atualização.** O SELLER declara, sob as penas da lei, que as informações prestadas são verdadeiras, e obriga-se a mantê-las atualizadas. A GLOP poderá, a qualquer tempo, solicitar documentação comprobatória (*KYC/KYB*) e condicionar a ativação ou continuidade da conta à sua apresentação.

**3.3. Elegibilidade.** O SELLER declara possuir capacidade civil plena e/ou regularidade jurídica e fiscal para exercer a atividade, bem como todas as licenças, registros e autorizações exigíveis para os produtos que comercializa (incluindo, quando aplicável, ANVISA, INMETRO, registros sanitários e demais órgãos competentes).

**3.4. Credenciais e responsabilidade pela conta.** O acesso é individualizado por **Membership** (usuário + papel) dentro da hierarquia multi-tenant. O SELLER é integralmente responsável pela guarda e sigilo das credenciais, pela concessão de acessos a seus colaboradores via RBAC e por todos os atos praticados sob sua conta, ainda que por terceiros a quem tenha concedido acesso. As credenciais de API integradas são armazenadas em modo *write-only*, não sendo exibidas após o cadastro.

**3.5. Recusa e aprovação.** A GLOP reserva-se o direito de **recusar, condicionar ou revogar** o credenciamento, de forma motivada, em casos de suspeita de fraude, indícios de ilicitude, produtos proibidos (Cláusula 6.4), inconsistência cadastral, restrição em listas de sanções/compliance ou risco reputacional e regulatório.

---

## CLÁUSULA 4 — OBRIGAÇÕES DA GLOP (CONTRATADA)

**4.1.** Constituem obrigações da GLOP:

1. Disponibilizar a Plataforma e os módulos contratados de forma diligente, empregando as melhores práticas de mercado, na modalidade de **melhores esforços** (obrigação de meio quanto à disponibilidade, ressalvado o disposto na Cláusula 10);
2. Manter a arquitetura de segurança descrita no preâmbulo (RLS multi-tenant, RBAC, soft-delete, trilha de auditoria, criptografia em trânsito e em repouso conforme padrões dos sub-operadores);
3. Processar a ingestão de pedidos, a geração de pré-postagem, o rastreamento e as notificações conforme as integrações ativas e a disponibilidade dos sub-operadores (Correios, gateways, VHSYS, provedores de mensageria);
4. Operar o **portal público de rastreio** expondo somente **status neutro** da entrega, sem revelar PII do comprador a terceiros não autorizados;
5. Prestar suporte técnico pelos canais indicados, nos níveis de serviço eventualmente pactuados em plano ou anexo;
6. Tratar os dados pessoais na condição de **Operador** (dados do comprador tratados em nome do SELLER Controlador) e/ou **Controlador** (dados dos próprios usuários/colaboradores), nos termos do DPA e da Cláusula 10;
7. Notificar o SELLER, sem demora injustificada, sobre incidentes de segurança relevantes que afetem seus dados, na forma da LGPD e do DPA;
8. Comunicar, com antecedência razoável e pelos canais oficiais, alterações materiais de funcionalidades, integrações ou preços, ressalvadas as alterações emergenciais de segurança.

**4.2. Limites do serviço.** A GLOP **não garante** disponibilidade ininterrupta, nem se responsabiliza por indisponibilidades, atrasos, erros ou falhas originados em **sub-operadores** e terceiros (Correios, gateways, VHSYS, Supabase, Netlify, provedores de WhatsApp/e-mail), em força maior, caso fortuito, ataques cibernéticos de terceiros ou uso indevido pelo SELLER. A GLOP não responde pela veracidade, qualidade, legalidade ou entrega dos produtos comercializados pelo SELLER.

---

## CLÁUSULA 5 — OBRIGAÇÕES DO SELLER (CONTRATANTE)

**5.1.** Constituem obrigações do SELLER:

1. Utilizar a Plataforma exclusivamente para fins lícitos, em conformidade com este Contrato, com a legislação aplicável e com as políticas da GLOP;
2. Ser o **único e integral responsável** pelos produtos e serviços que comercializa: existência, qualidade, segurança, conformidade, precificação, ofertas, propaganda, prazos e efetiva entrega;
3. Cumprir integralmente o **Código de Defesa do Consumidor** perante os Compradores, inclusive quanto a informação clara e adequada, direito de arrependimento (art. 49 do CDC), garantia legal e contratual, trocas, devoluções e atendimento pós-venda (SAC);
4. Emitir e recolher corretamente todos os **tributos** e documentos fiscais devidos, sendo o único responsável fiscal pela NF-e emitida via integração VHSYS, mesmo quando gerada por meio da Plataforma;
5. Fornecer e manter dados cadastrais e de pedidos **verídicos, íntegros e atualizados**, respondendo por informações incorretas que causem falha de entrega ou dano;
6. Obter **base legal** e consentimento adequados dos Compradores para o tratamento e o compartilhamento de PII com a Plataforma e sub-operadores, na qualidade de **Controlador** dos dados dos seus Compradores;
7. Manter as credenciais de integração seguras e revogá-las em caso de comprometimento;
8. Atender às determinações de órgãos de defesa do consumidor, PROCON, autoridades administrativas, ANPD e Poder Judiciário relativas às suas operações;
9. Não utilizar a Plataforma para práticas vedadas (Cláusula 6.4), fraude, lavagem de dinheiro, evasão de divisas, comercialização de produtos proibidos ou lesão a direitos de terceiros;
10. Manter comunicação e atendimento adequados aos Compradores, responsabilizando-se pelo pós-venda e pela resolução de reclamações.

**5.2. Indenidade.** O SELLER obriga-se a **manter a GLOP indene** (defesa e reembolso) de quaisquer reclamações, autuações, condenações, custas e honorários decorrentes de: (i) produtos, ofertas ou entregas sob sua responsabilidade; (ii) descumprimento do CDC ou de normas fiscais/regulatórias; (iii) violação de direitos de terceiros; (iv) tratamento indevido de dados pessoais sob sua condição de Controlador.

---

## CLÁUSULA 6 — RESPONSABILIDADES SOBRE PRODUTOS, ENTREGAS E QUALIDADE

**6.1. Titularidade da oferta.** O SELLER é o **titular e responsável primário** por toda oferta veiculada sob sua conta, respondendo pela conformidade legal, sanitária, técnica e publicitária dos produtos, bem como pela exatidão das descrições, imagens, preços e prazos.

**6.2. Entrega e prazos.** O SELLER é responsável pelo correto processamento logístico e pelo cumprimento dos prazos de manuseio, expedição e entrega. A GLOP disponibiliza os meios (pré-postagem PPN, etiquetas, rastreio SRO e notificação), porém **a obrigação de entrega perante o Comprador é do SELLER**, ainda que executada por transportadora (Correios ou outra). Atrasos, extravios ou avarias imputáveis à transportadora serão tratados conforme as regras do transportador, sem que isso exima o SELLER de sua responsabilidade perante o Comprador nos termos do CDC.

**6.3. Política de qualidade.** O SELLER compromete-se a manter padrões mínimos de qualidade, medidos por indicadores como: índice de reclamações, índice de chargeback/estorno, prazo médio de manuseio, taxa de entrega no prazo (*on-time delivery*), taxa de cancelamento e volume de disputas. A GLOP poderá estabelecer **limiares de qualidade** e adotar medidas graduais (advertência, restrição de funcionalidades, suspensão ou descredenciamento) em caso de reiterado descumprimento, conforme a Cláusula 12.

**6.4. Produtos e condutas proibidos.** É vedado ao SELLER comercializar ou promover, por meio da Plataforma, entre outros: produtos ilícitos, falsificados ou contrabandeados; armas, munições e explosivos sem autorização; drogas ilícitas; medicamentos e produtos de saúde sem registro/autorização; produtos que violem propriedade intelectual de terceiros; conteúdos que incitem violência, discriminação ou ódio; esquemas de pirâmide ou fraude; e quaisquer bens ou serviços cuja comercialização exija licença que o SELLER não possua.

**6.5. Coprodução e afiliação.** Quando o SELLER configurar coprodutores e afiliados, responsabiliza-se pela licitude das regras de comissionamento e split, pela veracidade dos dados de terceiros inseridos e pela legalidade dos repasses, isentando a GLOP de disputas entre o SELLER e seus coprodutores/afiliados.

---

## CLÁUSULA 7 — COMISSÕES, TAXAS, APURAÇÃO, REPASSES E SPLIT

**7.1. Remuneração.** Pela licença de uso e pelos serviços, o SELLER pagará à GLOP as **taxas, mensalidades e/ou comissões** definidas no plano contratado, na tabela de preços vigente ou em anexo comercial, que integram este Contrato.

**7.2. Estrutura de valores.** A remuneração poderá compreender, isolada ou cumulativamente: (i) mensalidade/assinatura do SaaS; (ii) taxa por pedido processado; (iii) comissão sobre o valor transacionado (*take rate*); (iv) custos repassados de sub-operadores (frete Correios, emissão de NF-e, mensageria). Os valores, alíquotas e bases de cálculo constarão do anexo comercial.

**7.3. Apuração e split.** Quando o fluxo financeiro transitar por gateway com funcionalidade de **split** (ex.: AppMax), a apuração e a distribuição de valores entre SELLER, coprodutores e afiliados observarão as regras configuradas pelo SELLER e as condições do gateway. A GLOP atua como **camada de orquestração e registro** da apuração, **não** como instituição de pagamento, custódia ou *escrow*, salvo se e quando expressamente contratado e licenciado para tanto.

**7.4. Responsabilidade financeira.** Os repasses ao SELLER e a terceiros dependem da efetiva liquidação pelo gateway e da inexistência de estornos, chargebacks, bloqueios ou disputas. A GLOP não responde por valores não liquidados, retidos ou estornados pelo gateway, tampouco por decisões de risco das instituições de pagamento.

**7.5. Tributos.** Cada Parte é responsável pelos tributos incidentes sobre suas próprias receitas e operações. Retenções legais aplicáveis serão observadas na forma da lei.

**7.6. Reajuste.** Os valores poderão ser reajustados anualmente pela variação do **IPCA/IBGE** (ou índice que o substitua) ou conforme condições comerciais comunicadas com antecedência mínima de **30 (trinta) dias**.

**7.7. Inadimplência.** O atraso no pagamento sujeitará o SELLER a **multa de 2% (dois por cento)**, **juros de mora de 1% (um por cento) ao mês** e correção monetária, além de facultar à GLOP a suspensão dos serviços (Cláusula 12) até a regularização.

---

## CLÁUSULA 8 — POLÍTICA DE QUALIDADE, ATENDIMENTO E MONITORAMENTO

**8.1.** O SELLER deverá manter canais de atendimento ao Comprador eficazes e responder tempestivamente a reclamações, disputas e solicitações de troca/devolução, em conformidade com o CDC.

**8.2.** A GLOP poderá disponibilizar painéis e indicadores de desempenho (qualidade, prazos, reclamações) e **monitorar métricas operacionais** para fins de saúde da Plataforma, prevenção a fraude e proteção da experiência dos Compradores, respeitada a LGPD.

**8.3.** A reiterada violação dos padrões de qualidade, o excesso de reclamações, disputas ou chargebacks, ou a prática de condutas lesivas a Compradores autorizam a adoção das medidas graduais previstas na Cláusula 12.

---

## CLÁUSULA 9 — RESPONSABILIDADE PERANTE O CONSUMIDOR (CDC), SOLIDÁRIA E SUBSIDIÁRIA

**9.1. Responsabilidade primária do SELLER.** Perante o Comprador, o **SELLER é o fornecedor** do produto/serviço, respondendo, na forma dos arts. 12, 14, 18 e 20 do CDC, por vícios e fatos do produto e do serviço, informação, entrega e garantia.

**9.2. Natureza da atuação da GLOP.** A GLOP atua como **provedora de plataforma e prestadora de serviços de intermediação e apoio logístico**, não integrando, em regra, a cadeia de fornecimento do produto do SELLER como fornecedora direta.

**9.3. Responsabilidade solidária e subsidiária.** As Partes reconhecem que a jurisprudência e a doutrina admitem, em determinadas circunstâncias, a **responsabilidade solidária** de plataformas/marketplaces perante o consumidor (art. 7º, parágrafo único, e art. 25, §1º, do CDC), especialmente quando a plataforma aufere vantagem econômica da transação e participa da cadeia de consumo. Assim:

1. Sem prejuízo do reconhecimento legal e da eventual solidariedade perante o consumidor — que não pode ser afastada por acordo entre as Partes em detrimento do Comprador —, **na relação interna entre GLOP e SELLER**, o SELLER assume a **responsabilidade primária e final** por produtos, ofertas, entregas e vícios;
2. Caso a GLOP venha a ser condenada, autuada ou obrigada a ressarcir Comprador ou autoridade por fato imputável ao SELLER, assiste à GLOP **direito de regresso integral** contra o SELLER, incluindo o principal, custas, honorários e demais despesas;
3. A responsabilidade da GLOP, quando reconhecida, poderá ser **subsidiária** relativamente às obrigações do SELLER, quando assim admitido em direito.

**9.4. Cooperação em demandas.** O SELLER obriga-se a prestar, sem demora, todas as informações e documentos necessários à defesa em reclamações administrativas (PROCON, consumidor.gov.br), judiciais e de órgãos reguladores relativas às suas operações, e a assumir sua defesa quando cabível.

**9.5. Não afastamento de direitos do consumidor.** Nenhuma disposição deste Contrato pode ser interpretada como renúncia, limitação ou exclusão de direitos do Comprador previstos em normas de ordem pública, notadamente o CDC. As alocações de responsabilidade aqui pactuadas produzem efeitos **entre as Partes** (relação interna), sem oponibilidade ao consumidor.

---

## CLÁUSULA 10 — PROTEÇÃO DE DADOS PESSOAIS (LGPD) E REMISSÃO AO DPA

**10.1. Dupla natureza.** As Partes reconhecem a natureza dupla do tratamento na Plataforma:

1. **GLOP como Operadora:** ao tratar **dados pessoais de Compradores** (nome, CPF/CNPJ, e-mail, telefone, endereço, produto e valor) por conta e ordem do SELLER, este atua como **Controlador**;
2. **GLOP como Controladora:** ao tratar dados de seus próprios usuários, colaboradores e administradores da conta do SELLER para finalidades próprias de operação, segurança, faturamento e cumprimento legal.

**10.2. Acordo de Tratamento de Dados (DPA).** O tratamento de dados rege-se pelo **DPA — Acordo de Tratamento de Dados** anexo, que integra este Contrato para todos os fins e prevalece em caso de conflito quanto à matéria de proteção de dados. O SELLER, como Controlador, é responsável por definir finalidades e bases legais (art. 7º e art. 11 da LGPD) e por atender às requisições dos titulares (Compradores).

**10.3. Sub-operadores.** O SELLER autoriza a GLOP a subcontratar os sub-operadores necessários à prestação (Supabase e Netlify para infraestrutura; VHSYS para NF-e; Correios para transporte, pré-postagem e rastreio; gateways Monetizze/AppMax/Hotmart/Kiwify; provedores de WhatsApp e e-mail), obrigando-se a GLOP a exigir deles padrão de proteção compatível com a LGPD.

**10.4. Segurança.** A GLOP mantém medidas técnicas e organizacionais compatíveis com o art. 46 da LGPD: isolamento por **RLS multi-tenant**, **RBAC** (has_permission), **soft-delete**, **trilha de auditoria por triggers**, **colunas de auditoria** em todo registro, credenciais de API **write-only** e criptografia conforme padrões dos sub-operadores.

**10.5. Portal público de rastreio.** O portal público **não expõe PII** do Comprador; apenas status neutro da entrega, mitigando riscos de vazamento e enumeração de dados.

**10.6. Incidentes.** Em caso de incidente de segurança relevante, a GLOP comunicará o SELLER sem demora injustificada, cooperando na avaliação de risco e nas comunicações à ANPD e aos titulares, quando exigível, nos termos do DPA e do art. 48 da LGPD.

**10.7. Transferência internacional.** Eventuais transferências internacionais decorrentes de sub-operadores observarão os arts. 33 a 36 da LGPD e as salvaguardas contratuais aplicáveis.

**10.8. Encarregado (DPO).** Comunicações relativas a dados pessoais deverão ser dirigidas ao Encarregado: **a ser designado pela administração**, e-mail **lemoncapsencapsulados@gmail.com**.

---

## CLÁUSULA 11 — PROPRIEDADE INTELECTUAL, CONFIDENCIALIDADE E MARCA

**11.1. Propriedade da Plataforma.** Todo o software, código-fonte, arquitetura, bancos de dados, layouts, marcas, *know-how* e demais elementos da GLOP são de titularidade exclusiva da CONTRATADA (ou de seus licenciadores), protegidos pela **Lei nº 9.279/1996 (Propriedade Industrial)** e **Lei nº 9.610/1998 (Direitos Autorais)** e pela **Lei nº 9.609/1998 (Software)**. A licença concedida é **não exclusiva, intransferível, revogável** e restrita à vigência deste Contrato.

**11.2. Conteúdo do SELLER.** O SELLER mantém a titularidade de suas marcas, conteúdos, catálogos e dados de negócio, concedendo à GLOP licença limitada para hospedá-los, processá-los e exibi-los estritamente para a execução dos serviços.

**11.3. Vedações.** É vedado ao SELLER: realizar engenharia reversa, descompilar, sublicenciar, revender, copiar ou explorar a Plataforma fora do escopo autorizado; utilizar a marca **[NOME FANTASIA: GLOP]** sem autorização; e acessar dados de outros tenants.

**11.4. Confidencialidade.** As Partes obrigam-se a manter sigilo sobre informações confidenciais a que tiverem acesso (dados técnicos, comerciais, financeiros, de segurança e pessoais), pelo prazo da vigência e por **5 (cinco) anos** após o término, ressalvadas informações públicas, exigências legais ou ordem de autoridade competente.

---

## CLÁUSULA 12 — SUSPENSÃO, RESTRIÇÃO E DESCREDENCIAMENTO

**12.1. Medidas graduais.** Diante de violação contratual, risco à Plataforma, a Compradores ou a terceiros, a GLOP poderá adotar, de forma proporcional e, sempre que possível, gradual:

1. **Advertência** e solicitação de correção em prazo determinado;
2. **Restrição** de funcionalidades ou integrações;
3. **Suspensão** temporária da conta e dos serviços;
4. **Descredenciamento** (rescisão) com bloqueio de acesso.

**12.2. Suspensão imediata.** A GLOP poderá suspender **imediatamente**, independentemente de aviso prévio, em casos de: (i) suspeita fundada de fraude, ilicitude ou lavagem de dinheiro; (ii) comercialização de produtos proibidos (Cláusula 6.4); (iii) risco iminente de segurança, incidente de dados ou ordem de autoridade; (iv) inadimplência não sanada; (v) grave lesão a Compradores.

**12.3. Descredenciamento motivado.** Constituem causas de descredenciamento, entre outras: reincidência em violações de qualidade; descumprimento reiterado do CDC; fornecimento de dados falsos; prática de fraude; violação da LGPD; uso indevido da Plataforma; e inadimplência persistente.

**12.4. Efeitos.** A suspensão ou o descredenciamento não eximem o SELLER de cumprir obrigações pendentes perante Compradores, coprodutores, afiliados, autoridades e a própria GLOP, tampouco geram direito a indenização por medidas legítimas. Pedidos já em curso serão tratados conforme a etapa logística em que se encontrarem, sem prejuízo dos direitos dos Compradores.

**12.5. Portabilidade e exclusão de dados.** Após o término, o SELLER poderá solicitar, em prazo razoável, a exportação de seus dados de negócio; os dados pessoais serão eliminados ou anonimizados conforme o DPA e a LGPD, ressalvadas as hipóteses de guarda legal obrigatória (ex.: art. 15 do Marco Civil, obrigações fiscais).

---

## CLÁUSULA 13 — LIMITAÇÃO DE RESPONSABILIDADE

**13.1.** Na máxima extensão permitida pela lei aplicável e **sem prejuízo de direitos de ordem pública e do consumidor**, a responsabilidade agregada da GLOP perante o SELLER, por qualquer causa relacionada a este Contrato, limita-se ao **valor total efetivamente pago pelo SELLER à GLOP nos 12 (doze) meses anteriores ao fato gerador**.

**13.2.** A GLOP **não responde** por danos indiretos, lucros cessantes, perda de chance, perda de dados por causa não imputável a ela, nem por atos, falhas ou indisponibilidades de **sub-operadores e terceiros** (Correios, gateways, VHSYS, Supabase, Netlify, provedores de mensageria).

**13.3.** As limitações desta cláusula **não se aplicam** a hipóteses de dolo, fraude ou culpa grave da GLOP, nem afastam responsabilidades irrenunciáveis por lei.

---

## CLÁUSULA 14 — VIGÊNCIA E RESCISÃO

**14.1. Vigência.** Este Contrato vigora por **prazo indeterminado** a partir do aceite eletrônico, enquanto ativa a conta do SELLER.

**14.2. Rescisão imotivada.** Qualquer Parte poderá rescindir mediante aviso prévio de **30 (trinta) dias**, sem ônus, respeitadas as obrigações pendentes e os pedidos em curso.

**14.3. Rescisão motivada.** Poderá haver rescisão imediata por justa causa nas hipóteses da Cláusula 12 e por descumprimento não sanado em **10 (dez) dias** após notificação.

**14.4. Sobrevivência.** Sobrevivem ao término as cláusulas de confidencialidade, proteção de dados, propriedade intelectual, responsabilidade, indenidade, regresso e foro.

---

## CLÁUSULA 15 — DISPOSIÇÕES GERAIS

**15.1. Alterações.** A GLOP poderá alterar este Contrato e as políticas, comunicando o SELLER pelos canais oficiais; o uso continuado após a vigência das alterações implica aceite. Alterações que reduzam materialmente direitos do SELLER serão comunicadas com antecedência mínima de **30 (trinta) dias**, facultada a rescisão sem ônus.

**15.2. Aceite eletrônico.** As Partes reconhecem a validade do aceite eletrônico e dos registros de log como prova da contratação, nos termos do **art. 10, §2º, da MP 2.200-2/2001** e do **art. 441 do CPC**.

**15.3. Cessão.** O SELLER não poderá ceder este Contrato sem anuência da GLOP; a GLOP poderá cedê-lo a empresas de seu grupo econômico.

**15.4. Comunicações.** As comunicações formais dar-se-ão pelos e-mails cadastrados e pelos painéis da Plataforma.

**15.5. Independência das cláusulas.** A eventual nulidade de uma cláusula não prejudica as demais.

**15.6. Tolerância.** A tolerância quanto a descumprimentos não constitui novação nem renúncia de direitos.

**15.7. Anexos.** Integram este Contrato: (i) **DPA — Acordo de Tratamento de Dados**; (ii) **Termos de Uso**; (iii) **Política de Privacidade**; (iv) **Anexo Comercial / Tabela de Preços**; (v) **Política de Produtos Proibidos**.

---

## CLÁUSULA 16 — LEI APLICÁVEL E FORO

**16.1.** Este Contrato rege-se pelas leis da **República Federativa do Brasil**, em especial CDC, LGPD, Marco Civil da Internet, Código Civil e legislação de propriedade intelectual.

**16.2.** As Partes elegem o foro da comarca de **Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190** (sede da GLOP) para dirimir controvérsias, com renúncia a qualquer outro, por mais privilegiado que seja, **ressalvado**, nas relações com Compradores consumidores, o foro do domicílio do consumidor (art. 101, I, do CDC), norma de ordem pública que prevalece.

E, por estarem justas e contratadas, as Partes manifestam sua concordância por meio do **aceite eletrônico** deste instrumento, em **16 de julho de 2026**.

**LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA — [NOME FANTASIA: GLOP]** (CONTRATADA)

**[CONTRATANTE]** (SELLER / CONTRATANTE)

---

# Engenharia Jurídica & Governança

## (a) Fundamentação das Cláusulas (lei/norma que embasa)

| Cláusula / Tema | Fundamentação legal e normativa |
|---|---|
| Qualificação e objeto | Código Civil (arts. 421, 422, 425 — atipicidade e boa-fé objetiva) |
| Cadastro / KYC-KYB | Lei nº 9.613/1998 (PLD/FT); boa-fé objetiva; dever de veracidade |
| Intermediação / natureza da plataforma | Marco Civil da Internet (Lei nº 12.965/2014, arts. 15, 18 e 19) |
| Responsabilidade do fornecedor (SELLER) | CDC (Lei nº 8.078/1990), arts. 12, 14, 18, 20, 49 |
| Solidariedade e regresso | CDC, art. 7º, parágrafo único; art. 25, §1º; Código Civil, arts. 264, 275 e 934 (regresso) |
| Direito de arrependimento | CDC, art. 49 |
| Foro do consumidor | CDC, art. 101, I |
| Proteção de dados (Operador/Controlador) | LGPD (Lei nº 13.709/2018), arts. 5º, 7º, 11, 37, 39, 46, 48, 33-36 |
| Segurança da informação | LGPD, art. 46; boas práticas ISO 27001/27701, NIST, OWASP |
| Propriedade intelectual | Lei nº 9.279/1996; Lei nº 9.610/1998; Lei nº 9.609/1998 (software) |
| Confidencialidade | Código Civil, art. 422; Lei nº 9.279/1996, art. 195 (concorrência desleal) |
| Aceite eletrônico | MP 2.200-2/2001, art. 10, §2º; CPC, art. 441 |
| Reajuste / mora | Código Civil, arts. 389, 395, 406; índice IPCA/IBGE |
| Limitação de responsabilidade | Código Civil, arts. 393, 944; ressalva de dolo/culpa grave |
| Continuidade / guarda de logs | Marco Civil, art. 15; legislação fiscal (guarda de documentos) |

## (b) Riscos Mitigados

1. **Responsabilização direta e ilimitada da GLOP perante o consumidor** — mitigada pela definição clara da natureza de intermediária, alocação interna de responsabilidade, direito de regresso e cláusula de indenidade, sem afastar direitos de ordem pública.
2. **Vazamento de dados / sanções da ANPD** — mitigado por RLS multi-tenant, RBAC, soft-delete, auditoria, credenciais write-only, portal público sem PII, DPA e plano de incidentes.
3. **Confusão de papéis Controlador/Operador** — mitigada pela distinção expressa da dupla natureza e remissão ao DPA.
4. **Fraude, lavagem e produtos proibidos** — mitigados por KYC/KYB, lista de vedações, suspensão imediata e descredenciamento.
5. **Inadimplência e disputas financeiras (chargeback/split)** — mitigadas pela definição de que a GLOP não é instituição de pagamento/escrow e pela condicionamento do repasse à liquidação.
6. **Indisponibilidade de sub-operadores** — mitigada por obrigação de meio, exclusão de responsabilidade por terceiros e limitação de responsabilidade.
7. **Uso indevido de PI / engenharia reversa** — mitigado por cláusula de licença restrita e vedações expressas.
8. **Descontinuidade e portabilidade** — mitigadas por regras de exportação, eliminação/anonimização e guarda legal obrigatória.

## (c) Checklist de Conformidade

- [ ] Placeholders substituídos (LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, 55.836.075/0001-07, Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, lemoncapsencapsulados@gmail.com, a ser designado pela administração, 16 de julho de 2026).
- [ ] DPA, Termos de Uso, Política de Privacidade, Anexo Comercial e Política de Produtos Proibidos elaborados e vinculados.
- [ ] Fluxo de aceite eletrônico com registro de log, IP e timestamp implementado.
- [ ] Rotina de KYC/KYB e checagem em listas de sanções ativa.
- [ ] Tabela de preços/comissões e regras de split versionadas e anexadas.
- [ ] Encarregado (DPO) nomeado e canal de contato publicado.
- [ ] Fluxo de atendimento a titulares (Compradores) definido com o SELLER Controlador.
- [ ] Procedimento de resposta a incidentes e comunicação à ANPD testado.
- [ ] Portal público de rastreio auditado para não exposição de PII.
- [ ] Revisão por advogado(a) habilitado(a) antes da produção.

## (d) Matriz RACI

| Atividade | GLOP | SELLER | DPO/Encarregado | Jurídico |
|---|---|---|---|---|
| Disponibilização e segurança da Plataforma | R/A | I | C | I |
| Veracidade cadastral e conformidade do produto | I | R/A | I | C |
| Cumprimento do CDC perante o Comprador | C | R/A | I | C |
| Emissão fiscal (NF-e via VHSYS) | C (meio) | R/A | I | I |
| Definição de bases legais e consentimento (Compradores) | C | R/A | C | C |
| Tratamento de dados como Operador | R/A | C (Controlador) | C | I |
| Resposta a incidentes de segurança | R/A | C | R | C |
| Apuração, repasse e split | R (registro) | A | I | C |
| Suspensão/descredenciamento | R/A | I | C | C |
| Revisão jurídica e versionamento | I | I | C | R/A |

Legenda: R = Responsável (executa); A = *Accountable* (aprova); C = Consultado; I = Informado.

## (e) Plano de Revisão

1. **Periodicidade ordinária:** revisão a cada **12 meses**.
2. **Revisão extraordinária (gatilhos):** alteração legislativa (LGPD/CDC/Marco Civil), nova orientação da ANPD, mudança de sub-operadores, novo módulo/integração, incidente de segurança relevante, decisão judicial ou administrativa que impacte o modelo de responsabilidade.
3. **Responsáveis:** Jurídico (titular), DPO (proteção de dados), Produto/Engenharia (aderência técnica dos controles descritos).
4. **Registro:** toda alteração deve ser refletida no Controle de Versão abaixo e comunicada aos SELLERS na forma da Cláusula 15.1.

## (f) Controle de Versão

| Versão | Data | Autor | Descrição das alterações | Status |
|---|---|---|---|---|
| 0.1 | 16 de julho de 2026 | Chief Legal AI (minuta) | Elaboração inicial da minuta do Contrato de Marketplace GLOP | Pendente de revisão jurídica |
| — | — | [Jurídico] | Revisão por advogado(a) habilitado(a) | A realizar |
| — | — | [DPO] | Validação de aderência ao DPA/LGPD | A realizar |
| 1.0 | 16 de julho de 2026 | [Jurídico] | Versão aprovada para produção | A publicar |
