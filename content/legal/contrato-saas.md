> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# Contrato de Licença de Uso e Assinatura de Software como Serviço (SaaS) — Plataforma GLOP

**Instrumento Particular de Licenciamento de Software na Modalidade Software as a Service, Prestação de Serviços de Hospedagem, Processamento e Suporte, e Outras Avenças**

---

## Preâmbulo

Pelo presente **Instrumento Particular de Contrato de Licença de Uso e Assinatura de Software como Serviço** (doravante o **"Contrato"**), as partes abaixo qualificadas, de um lado a **CONTRATADA** (fornecedora da plataforma GLOP) e, de outro, o **CONTRATANTE** (produtor, infoprodutor, lojista, dropshipper ou empresa de e-commerce assinante), doravante em conjunto denominadas **"Partes"** e, individualmente, **"Parte"**, têm, entre si, justo e contratado o quanto segue, que mutuamente aceitam e outorgam, por si, seus herdeiros e sucessores, a qualquer título.

Este Contrato rege a disponibilização, o acesso e o uso da plataforma **GLOP (Global Logistics Platform)** — solução de logística, gestão de pedidos e ERP operacional, disponibilizada na modalidade Software as a Service (SaaS), voltada às operações de **dropshipping, infoprodutos, e-commerce e marketplaces** no território brasileiro.

Ao clicar em "Li e aceito", ao criar conta, ao efetuar o primeiro pagamento, ou ao efetivamente utilizar a plataforma, o CONTRATANTE declara ter lido, compreendido e aceito integralmente as cláusulas deste Contrato e dos documentos a ele incorporados por referência, na forma dos artigos 425 e 427 do Código Civil e do artigo 30 do Código de Defesa do Consumidor, quando aplicável.

---

## Cláusula 1ª — Qualificação das Partes

### 1.1. CONTRATADA (Licenciante / Fornecedora)

**LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA**, pessoa jurídica de direito privado, inscrita no CNPJ sob o nº **55.836.075/0001-07**, com sede em **Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190**, neste ato representada na forma de seus atos constitutivos, doravante denominada **"GLOP"**, **"CONTRATADA"** ou **"Licenciante"**, titular e mantenedora da plataforma tecnológica identificada pelo nome fantasia **[NOME FANTASIA: GLOP]**.

### 1.2. CONTRATANTE (Licenciada / Assinante)

**[CONTRATANTE]**, pessoa física ou jurídica identificada no ato de contratação (cadastro, painel de assinatura, proposta comercial ou pedido eletrônico), cujos dados de qualificação — razão social ou nome civil, CNPJ ou CPF, endereço, representante legal e contatos — integram este Contrato por referência e constam do registro eletrônico de contratação mantido pela CONTRATADA, doravante denominada **"CONTRATANTE"**, **"Assinante"** ou **"Licenciada"**.

### 1.3. Declarações de capacidade

1. O CONTRATANTE declara possuir plena capacidade civil e/ou poderes de representação para celebrar este Contrato, sendo maior de 18 (dezoito) anos quando pessoa física.
2. O signatário do aceite declara deter poderes para vincular o CONTRATANTE, respondendo pessoalmente por eventual excesso de mandato, na forma do artigo 673 do Código Civil.
3. As Partes reconhecem a validade, eficácia e força probante da contratação eletrônica, das assinaturas eletrônicas e dos registros de aceite (log de data, hora, IP e identificação de usuário), nos termos da Medida Provisória nº 2.200-2/2001 e da Lei nº 14.063/2020.

---

## Cláusula 2ª — Definições

Para os fins deste Contrato, os termos abaixo, quando iniciados por letra maiúscula, terão os seguintes significados:

1. **Plataforma / GLOP:** o software na modalidade SaaS de logística e ERP operacional disponibilizado pela CONTRATADA, incluindo módulos de ingestão de pedidos, gestão logística (WMS/TMS), pré-postagem e rastreio, emissão fiscal, coprodução/split, portal público de rastreio, painéis e integrações.
2. **Conta / Tenant:** a instância lógica isolada do CONTRATANTE na Plataforma, correspondente à hierarquia multi-tenant **Tenant → Company → Branch → Membership**, com isolamento de dados por Row Level Security (RLS).
3. **Usuário Autorizado:** pessoa física (colaborador, preposto, sócio, contador) a quem o CONTRATANTE concede credenciais de acesso à sua Conta, sob sua exclusiva responsabilidade e controle de permissões (RBAC).
4. **Comprador / Titular Final:** pessoa física ou jurídica que adquire produtos/serviços do CONTRATANTE e cujos dados pessoais (nome, CPF/CNPJ, e-mail, telefone, endereço, produto e valor) são tratados na Plataforma por conta e ordem do CONTRATANTE.
5. **Dados do Comprador:** os dados pessoais dos Compradores, ingeridos via API de gateways e e-commerces, tratados pela CONTRATADA na qualidade de **Operadora**, sendo o CONTRATANTE o **Controlador**.
6. **Dados do Assinante:** os dados pessoais dos próprios Usuários Autorizados e representantes do CONTRATANTE, quanto aos quais a CONTRATADA atua como **Controladora** (cadastro, autenticação, cobrança, suporte).
7. **DPA (Data Processing Agreement):** o **Acordo de Tratamento de Dados Pessoais** que disciplina, de forma detalhada, o tratamento dos Dados do Comprador na relação Controlador–Operador, incorporado a este Contrato por referência (Cláusula 12).
8. **Sub-operadores:** terceiros contratados pela CONTRATADA para viabilizar o serviço, notadamente Supabase e Netlify (infraestrutura/hospedagem), VHSYS (NF-e), Correios (transporte e rastreio), gateways de pagamento (Monetizze, AppMax, Hotmart, Kiwify) e provedores de mensageria (WhatsApp/e-mail).
9. **Plano:** o conjunto de funcionalidades, limites de uso, franquias e preço aplicável à assinatura, conforme tabela vigente e/ou proposta comercial aceita.
10. **Ciclo de Faturamento:** o período (mensal, trimestral ou anual) de cobrança recorrente da assinatura.
11. **SLA (Service Level Agreement):** o Acordo de Nível de Serviço que define metas de disponibilidade, suporte e créditos de serviço, incorporado por referência (Cláusula 6).
12. **PPN / SRO:** respectivamente, a Pré-Postagem Nacional e o Sistema de Rastreamento de Objetos dos Correios, integrados à Plataforma.
13. **PII:** informações de identificação pessoal (Personally Identifiable Information).
14. **Documentos Incorporados:** SLA, DPA, Política de Privacidade, Política de Uso Aceitável, tabela de Planos e Termos de Uso, que integram este Contrato como se nele transcritos.

---

## Cláusula 3ª — Objeto

### 3.1. Do objeto

Constitui objeto deste Contrato a **concessão, pela CONTRATADA ao CONTRATANTE, de licença de uso não exclusiva, intransferível, temporária, onerosa e revogável** da Plataforma GLOP, na modalidade Software as a Service, acessível remotamente via navegador/internet, bem como a prestação dos serviços correlatos de **hospedagem, processamento, armazenamento, integração e suporte técnico**, nos termos, limites e condições deste instrumento e dos Documentos Incorporados.

### 3.2. Natureza da contratação

1. A contratação **não** implica venda, cessão ou transferência de propriedade do software, de código-fonte ou de qualquer direito de propriedade intelectual, mas tão somente o direito de acesso e uso, na extensão do Plano contratado, enquanto vigente e adimplente a assinatura.
2. Trata-se de licenciamento de software com prestação de serviço continuado, regido pela Lei nº 9.609/1998 (Lei do Software), pelo Código Civil e, subsidiariamente, pelo Código de Defesa do Consumidor, quando caracterizada relação de consumo.

### 3.3. Escopo funcional (fluxos reais da Plataforma)

A licença abrange, conforme o Plano, os seguintes módulos e fluxos operacionais efetivamente disponibilizados pela GLOP:

1. **Ingestão e importação de pedidos** via API de gateways (Monetizze, Hotmart, Kiwify) e de e-commerces/marketplaces (Shopify, WooCommerce, Nuvemshop, Mercado Livre), com captura de PII do Comprador (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor).
2. **Gestão logística operacional** (WMS/TMS): organização de pedidos, separação, expedição e acompanhamento.
3. **Integração com os Correios:** geração de Pré-Postagem Nacional (PPN), consulta de rastreio (SRO) e envio de **notificações ao Comprador** por e-mail e/ou WhatsApp.
4. **Emissão de documentos fiscais (NF-e)** por meio da integração com a VHSYS.
5. **Coprodução & Split:** gestão de coprodutores e afiliados, cálculo de comissões, apuração, repasses e split de pagamentos (via AppMax), incluindo tratamento de dados de PIX e dados bancários.
6. **Portal público de rastreio**, acessível sem login, que expõe exclusivamente **status neutro** de entrega, sem exposição de PII sensível.
7. **Recursos de segurança e governança:** isolamento multi-tenant por RLS, controle de acesso por papéis (RBAC / has_permission), soft-delete, trilha de auditoria por triggers e colunas de auditoria em todo registro.
8. **Painéis, relatórios e indicadores** operacionais e de BI, conforme disponibilidade do Plano.

### 3.4. Do que NÃO integra o objeto

Salvo contratação específica e por escrito, **não** integram o objeto: desenvolvimento sob encomenda, customizações exclusivas, migração de dados legados, integrações não catalogadas, consultoria tributária/fiscal, contábil ou jurídica, atuação como instituição financeira ou de pagamento, e responsabilidade pela veracidade dos dados inseridos pelo CONTRATANTE ou por terceiros.

---

## Cláusula 4ª — Licença de Uso: Extensão e Restrições

### 4.1. Concessão

Sujeita ao adimplemento e às condições deste Contrato, a CONTRATADA concede ao CONTRATANTE licença **não exclusiva, não sublicenciável, intransferível, revogável e limitada** para acessar e utilizar a Plataforma, exclusivamente para os fins internos da operação logística e comercial do próprio CONTRATANTE, no território nacional, pelos Usuários Autorizados e dentro dos limites do Plano.

### 4.2. Vedações (condutas proibidas)

É expressamente vedado ao CONTRATANTE e a seus Usuários Autorizados:

1. Ceder, sublicenciar, alugar, emprestar, revender ou disponibilizar a Plataforma a terceiros não autorizados, no todo ou em parte.
2. Realizar engenharia reversa, descompilação, desmontagem ou tentativa de obtenção do código-fonte, salvo nas hipóteses legalmente irrenunciáveis.
3. Copiar, reproduzir, traduzir, adaptar, modificar ou criar obras derivadas da Plataforma.
4. Remover, ocultar ou alterar avisos de propriedade, marcas, logotipos ou créditos.
5. Utilizar a Plataforma para fins ilícitos, fraudulentos, contra a ordem pública, os bons costumes ou em violação a direitos de terceiros.
6. Realizar acessos automatizados não autorizados (scraping, bots), testes de intrusão sem consentimento prévio e por escrito, ou qualquer ação que comprometa a segurança, a integridade ou a disponibilidade da Plataforma.
7. Exceder deliberadamente os limites de uso do Plano, contornar controles técnicos, cotas, autenticação ou o isolamento multi-tenant.
8. Utilizar a Plataforma para tratar dados de Compradores sem base legal, ou para finalidades incompatíveis com aquelas informadas aos titulares.
9. Inserir na Plataforma malware, código malicioso ou conteúdo que viole direitos de terceiros.

### 4.3. Credenciais e responsabilidade de acesso

1. O CONTRATANTE é integralmente responsável pela guarda, sigilo e uso das credenciais de acesso à sua Conta e às integrações (chaves de API), respondendo por todos os atos praticados sob suas credenciais.
2. As credenciais de integração com terceiros são armazenadas em modo **write-only** (não recuperáveis em texto claro pela interface), cabendo ao CONTRATANTE zelar por sua rotação e revogação.
3. O CONTRATANTE deve notificar imediatamente a CONTRATADA sobre qualquer uso não autorizado, comprometimento de credenciais ou incidente de segurança de que tenha conhecimento.

---

## Cláusula 5ª — Planos, Preços, Pagamento e Reajuste

### 5.1. Planos e preços

1. Os Planos, funcionalidades, franquias, limites de uso e respectivos preços são os constantes da **tabela vigente** publicada pela CONTRATADA e/ou da **proposta comercial** aceita pelo CONTRATANTE, que integram este Contrato por referência.
2. O Plano contratado, o Ciclo de Faturamento e o valor da assinatura constam do registro eletrônico de contratação.

### 5.2. Forma e condições de pagamento

1. A assinatura é **pré-paga e recorrente**, cobrada no início de cada Ciclo de Faturamento, pelos meios de pagamento disponibilizados (cartão de crédito, PIX, boleto ou outro).
2. O CONTRATANTE autoriza a cobrança recorrente automática no meio de pagamento cadastrado, enquanto vigente a assinatura.
3. Eventuais tributos incidentes sobre o preço serão suportados na forma da lei; retenções legais, quando cabíveis, serão observadas.

### 5.3. Franquias, excedentes e uso variável

1. Consumos que excedam as franquias do Plano (por exemplo, volume de pedidos processados, notificações enviadas, chamadas de API, armazenamento) poderão ser cobrados como **excedente**, conforme tabela vigente, mediante informação prévia no painel.
2. Custos de terceiros repassados de forma transparente (por exemplo, tarifas dos Correios, do gateway ou de mensageria) não integram o preço da licença, salvo disposição expressa.

### 5.4. Inadimplemento

1. O atraso no pagamento sujeita o CONTRATANTE a **multa moratória de 2% (dois por cento)**, **juros de mora de 1% (um por cento) ao mês**, pro rata die, e **correção monetária** pelo IPCA/IBGE ou índice que o substitua, além de despesas de cobrança.
2. Persistindo a inadimplência por prazo superior a **[NÚMERO] dias** contados do vencimento, a CONTRATADA poderá **suspender o acesso** à Plataforma, na forma da Cláusula 13, sem prejuízo da cobrança dos valores devidos.
3. A suspensão por inadimplemento não exime o CONTRATANTE do pagamento das mensalidades do período de vigência remanescente, quando aplicável.

### 5.5. Reajuste

1. Os preços serão reajustados **anualmente**, a cada 12 (doze) meses contados do início da vigência ou do último reajuste, pela variação positiva acumulada do **IPCA/IBGE** ou, na sua falta, do **IGP-M/FGV** ou outro índice legalmente admitido.
2. Reajustes ou revisões de preço **acima da variação do índice** (revisão comercial) somente produzirão efeitos mediante comunicação prévia com antecedência mínima de **30 (trinta) dias**, facultado ao CONTRATANTE, quando consumidor, resilir sem ônus antes da vigência do novo preço.

### 5.6. Período de teste e cortesias

Eventuais períodos de teste gratuito (trial), cortesias ou descontos promocionais são temporários, condicionados e revogáveis, não gerando direito adquirido, e cessam automaticamente ao término do prazo estipulado, migrando a assinatura para o Plano pago correspondente, salvo cancelamento prévio pelo CONTRATANTE.

---

## Cláusula 6ª — Disponibilidade e Nível de Serviço (SLA)

### 6.1. Remissão ao SLA

A disponibilidade da Plataforma, as metas de suporte, as janelas de manutenção e os eventuais créditos de serviço são regidos pelo **Acordo de Nível de Serviço (SLA)**, documento incorporado a este Contrato por referência, cujos termos as Partes declaram conhecer e aceitar.

### 6.2. Metas gerais (referência, prevalecendo o SLA)

1. A CONTRATADA envidará seus melhores esforços para manter disponibilidade mensal de **[PERCENTUAL, ex.: 99,5%]**, apurada conforme metodologia do SLA, excluídas as exceções nele previstas.
2. **Manutenções programadas** serão comunicadas com antecedência razoável e, sempre que possível, realizadas em janelas de menor impacto.
3. **Exclusões de indisponibilidade:** não são computadas como indisponibilidade as interrupções decorrentes de (i) manutenção programada; (ii) caso fortuito ou força maior; (iii) falhas de terceiros/Sub-operadores (Supabase, Netlify, Correios, VHSYS, gateways, WhatsApp/e-mail) fora do controle da CONTRATADA; (iv) falhas de conectividade, equipamentos ou configurações do CONTRATANTE; (v) uso em desacordo com este Contrato; (vi) suspensão legítima por inadimplemento ou violação.

### 6.3. Créditos de serviço

O descumprimento das metas de disponibilidade, quando comprovado na forma do SLA, poderá ensejar **créditos de serviço** (abatimento em faturas futuras) como **remédio único e exclusivo**, nos limites e condições do SLA, não se convertendo em indenização, restituição em dinheiro ou obrigação adicional.

### 6.4. Dependência de terceiros

O CONTRATANTE reconhece que funcionalidades essenciais dependem de serviços de terceiros (transporte pelos Correios, emissão fiscal pela VHSYS, processamento e split por gateways, mensageria por WhatsApp/e-mail, infraestrutura por Supabase/Netlify) e que indisponibilidades, alterações de API, tarifas ou descontinuações por parte desses terceiros estão fora do controle da CONTRATADA, não lhe sendo imputáveis.

---

## Cláusula 7ª — Suporte Técnico

1. O suporte técnico será prestado pelos canais e nos horários definidos no SLA e/ou no painel da Plataforma, limitado ao escopo funcional contratado.
2. O suporte compreende esclarecimento de dúvidas de uso, orientação sobre funcionalidades e recebimento de relatos de erro; **não** compreende consultoria de negócio, fiscal, contábil ou jurídica, tampouco desenvolvimento sob demanda.
3. A CONTRATADA poderá disponibilizar documentação, base de conhecimento e materiais de apoio, cujo uso é recomendado antes da abertura de chamados.

---

## Cláusula 8ª — Obrigações da CONTRATADA

Constituem obrigações da CONTRATADA:

1. Disponibilizar a Plataforma conforme o Plano contratado e os níveis do SLA, envidando esforços comercialmente razoáveis para sua continuidade, integridade e desempenho.
2. Manter medidas técnicas e organizacionais de segurança compatíveis com o estado da técnica, incluindo isolamento multi-tenant por RLS, controle de acesso por papéis (RBAC), trilha de auditoria, soft-delete, armazenamento write-only de credenciais e criptografia em trânsito e, quando aplicável, em repouso, na forma do artigo 46 da LGPD.
3. Tratar os Dados do Comprador exclusivamente na qualidade de **Operadora**, segundo as instruções documentadas do CONTRATANTE e o DPA (Cláusula 12).
4. Prestar suporte técnico nos termos da Cláusula 7.
5. Comunicar ao CONTRATANTE, sem demora injustificada, incidentes de segurança que possam acarretar risco ou dano relevante, na forma do DPA e do artigo 48 da LGPD.
6. Manter cópias de segurança (backups) conforme política interna e o SLA, sem que isso transfira à CONTRATADA a responsabilidade primária pela conservação dos dados do CONTRATANTE.
7. Disponibilizar mecanismos de **portabilidade/exportação** e de **eliminação** de dados ao término do Contrato, na forma da Cláusula 14.
8. Manter documentação sobre o funcionamento da Plataforma e sobre os Sub-operadores relevantes.

---

## Cláusula 9ª — Obrigações do CONTRATANTE

Constituem obrigações do CONTRATANTE:

1. Pagar pontualmente os valores da assinatura e eventuais excedentes.
2. Utilizar a Plataforma conforme este Contrato, a legislação vigente e a Política de Uso Aceitável, respondendo pelo uso feito por seus Usuários Autorizados.
3. **Atuar como CONTROLADOR** dos Dados do Comprador, definindo finalidades e meios do tratamento, e assegurar **base legal adequada** (execução de contrato, cumprimento de obrigação legal, legítimo interesse ou consentimento, conforme o caso) para a coleta, a importação via gateways/e-commerces e o compartilhamento desses dados com a Plataforma.
4. Fornecer aos Compradores as **informações de transparência** exigidas pela LGPD (finalidade, compartilhamento com operador logístico, prazos), inclusive quanto ao envio de notificações de rastreio por e-mail/WhatsApp e à exibição de status no portal público de rastreio.
5. Garantir a **veracidade, exatidão e licitude** dos dados inseridos ou importados, incluindo dados fiscais (para NF-e via VHSYS), de endereço (para PPN/Correios) e bancários/PIX (para split via AppMax).
6. Manter a confidencialidade e a segurança das credenciais de acesso e das chaves de integração, e gerir adequadamente as permissões (RBAC) de seus Usuários Autorizados.
7. Cumprir as obrigações fiscais, tributárias, trabalhistas, consumeristas e regulatórias inerentes à sua própria operação, incluindo emissão correta de documentos fiscais e cumprimento do direito de arrependimento e das regras do CDC perante seus Compradores.
8. Responder perante os titulares (Compradores) e a Autoridade Nacional de Proteção de Dados (ANPD) na qualidade de Controlador, cooperando com a CONTRATADA no atendimento a requisições de titulares.
9. Não utilizar a Plataforma para atividades vedadas (Cláusula 4.2) e responder por infrações cometidas em sua Conta.
10. Manter dados cadastrais e de contato atualizados, especialmente para fins de notificação e cobrança.

---

## Cláusula 10ª — Confidencialidade

### 10.1. Informações Confidenciais

Consideram-se **Informações Confidenciais** todas as informações, técnicas, comerciais, financeiras, operacionais, estratégicas, dados pessoais, segredos de negócio, código, arquitetura, credenciais e documentação, reveladas por uma Parte (Reveladora) à outra (Receptora), por qualquer meio, em razão deste Contrato, independentemente de estarem marcadas como confidenciais.

### 10.2. Deveres da Parte Receptora

A Parte Receptora obriga-se a: (i) manter sigilo e não divulgar as Informações Confidenciais a terceiros sem autorização prévia e por escrito; (ii) utilizá-las estritamente para o cumprimento deste Contrato; (iii) restringir o acesso a colaboradores e prepostos com necessidade de conhecer, sob iguais obrigações de sigilo; (iv) empregar padrão de proteção não inferior ao dispensado às suas próprias informações confidenciais de igual relevância.

### 10.3. Exceções

Não se sujeitam ao dever de sigilo as informações que: (i) sejam ou se tornem de domínio público sem culpa da Receptora; (ii) já fossem legitimamente conhecidas antes da revelação; (iii) sejam obtidas licitamente de terceiro sem dever de sigilo; (iv) devam ser reveladas por ordem judicial, administrativa ou legal, hipótese em que a Receptora notificará previamente a Reveladora, quando permitido.

### 10.4. Vigência do dever

O dever de confidencialidade vigora durante a vigência do Contrato e por **5 (cinco) anos** após seu término, ressalvados os prazos legais mais longos aplicáveis a segredos de negócio e dados pessoais.

---

## Cláusula 11ª — Propriedade Intelectual

1. A Plataforma GLOP, incluindo seu **código-fonte e objeto, arquitetura, banco de dados, algoritmos, interfaces, layouts, telas, fluxos, marcas, nome, logotipos, documentação e melhorias**, é de titularidade exclusiva da CONTRATADA e/ou de seus licenciadores, protegida pela Lei nº 9.609/1998, pela Lei nº 9.610/1998, pela Lei nº 9.279/1996 e demais normas aplicáveis.
2. Este Contrato **não transfere** ao CONTRATANTE qualquer direito de propriedade intelectual, exceto a licença de uso limitada da Cláusula 4.
3. **Dados do CONTRATANTE e Dados do Comprador:** permanecem de titularidade do CONTRATANTE e/ou dos respectivos titulares; a CONTRATADA detém apenas o direito de tratá-los para prestar o serviço, na forma deste Contrato e do DPA.
4. **Feedback:** sugestões, ideias e comentários fornecidos pelo CONTRATANTE sobre a Plataforma poderão ser livremente utilizados pela CONTRATADA, sem ônus ou obrigação de contraprestação, para aprimoramento do serviço.
5. **Dados agregados e anonimizados:** a CONTRATADA poderá utilizar métricas e estatísticas agregadas e anonimizadas (que não permitam a identificação de titulares nem do CONTRATANTE) para fins de melhoria, benchmark e desenvolvimento da Plataforma, observado o artigo 12 da LGPD.
6. É vedado ao CONTRATANTE registrar, em seu nome ou de terceiros, marcas, domínios ou direitos que reproduzam ou imitem sinais distintivos da GLOP.

---

## Cláusula 12ª — Proteção de Dados Pessoais (LGPD) e Remissão ao DPA

### 12.1. Dupla natureza do tratamento

As Partes reconhecem a **dupla natureza** do tratamento de dados na relação:

1. **Quanto aos Dados do Comprador** (nome, CPF/CNPJ, e-mail, telefone, endereço, produto, valor, dados de PIX/bancários para split), ingeridos via gateways (Monetizze, Hotmart, Kiwify, AppMax) e e-commerces (Shopify, WooCommerce, Nuvemshop, Mercado Livre): o **CONTRATANTE é o CONTROLADOR** e a **CONTRATADA é a OPERADORA**, tratando tais dados por conta e ordem do CONTRATANTE, segundo suas instruções documentadas.
2. **Quanto aos Dados do Assinante** (dados dos Usuários Autorizados e representantes do CONTRATANTE, para cadastro, autenticação via Supabase Auth, cobrança, suporte e segurança): a **CONTRATADA é a CONTROLADORA**, na forma de sua Política de Privacidade.

### 12.2. Remissão ao DPA

O tratamento dos Dados do Comprador rege-se, de forma detalhada, pelo **Acordo de Tratamento de Dados Pessoais (DPA)**, incorporado a este Contrato por referência e dele parte integrante, que disciplina, no mínimo: objeto e duração do tratamento, natureza e finalidade, tipos de dados e categorias de titulares, obrigações e direitos do Controlador, instruções ao Operador, segurança da informação, sub-operadores e autorização geral, transferências, atendimento a titulares, notificação de incidentes, auditoria, e eliminação/devolução ao término.

### 12.3. Obrigações essenciais da CONTRATADA como Operadora

Sem prejuízo do DPA, a CONTRATADA, como Operadora: (i) tratará os Dados do Comprador apenas conforme as instruções do CONTRATANTE e para as finalidades do serviço (processamento de pedidos, PPN/rastreio, notificações, NF-e, split, portal de rastreio); (ii) manterá segurança e sigilo; (iii) auxiliará o CONTRATANTE no atendimento a requisições de titulares e da ANPD; (iv) comunicará incidentes de segurança sem demora; (v) manterá registro das operações de tratamento (artigo 37 da LGPD).

### 12.4. Sub-operadores

O CONTRATANTE **autoriza**, de forma geral e específica, a subcontratação dos Sub-operadores necessários à prestação do serviço (Supabase, Netlify, VHSYS, Correios, gateways e provedores de WhatsApp/e-mail), comprometendo-se a CONTRATADA a impor a esses terceiros obrigações de proteção de dados compatíveis com as deste Contrato e com o DPA. A lista de Sub-operadores poderá ser atualizada mediante comunicação, facultando-se objeção fundamentada na forma do DPA.

### 12.5. Portal público de rastreio

As Partes reconhecem que o **portal público de rastreio** foi concebido sob o princípio da **minimização** (artigo 6º, III, da LGPD), expondo, sem necessidade de login, apenas **status neutro** de entrega, sem revelar PII sensível do Comprador, cabendo ao CONTRATANTE informar tal funcionalidade aos titulares.

### 12.6. Encarregado (DPO)

A CONTRATADA indica como Encarregado pelo Tratamento de Dados Pessoais **a ser designado pela administração**, contatável em **lemoncapsencapsulados@gmail.com**, canal para comunicações da ANPD e dos titulares, sem prejuízo de o CONTRATANTE indicar seu próprio Encarregado perante seus Compradores.

### 12.7. Responsabilidade por base legal e transparência

O CONTRATANTE, como Controlador, é o único responsável por assegurar base legal, transparência e legitimidade da coleta e do compartilhamento dos Dados do Comprador com a Plataforma, isentando a CONTRATADA de responsabilidade decorrente da ausência ou insuficiência dessas providências.

---

## Cláusula 13ª — Suspensão, Vigência, Rescisão e Penalidades

### 13.1. Vigência

1. Este Contrato vigora por **prazo indeterminado**, iniciando-se na data do aceite/primeiro pagamento, salvo se a proposta comercial estipular **prazo determinado** (ex.: fidelidade de plano anual), hipótese em que prevalecerá o prazo pactuado.
2. Nos Planos com Ciclo de Faturamento recorrente, a assinatura renova-se automaticamente a cada ciclo, salvo cancelamento prévio.

### 13.2. Suspensão do acesso

A CONTRATADA poderá **suspender**, total ou parcialmente, o acesso à Plataforma, mediante notificação (quando viável), nas hipóteses de: (i) inadimplemento não sanado no prazo da Cláusula 5.4; (ii) violação das vedações da Cláusula 4.2; (iii) risco iminente à segurança, à integridade da Plataforma ou a terceiros; (iv) determinação legal ou judicial; (v) uso que exponha a CONTRATADA a responsabilidade. A suspensão cessará com o saneamento da causa, quando possível.

### 13.3. Rescisão sem justa causa (resilição)

1. Qualquer das Partes poderá resilir o Contrato imotivadamente, mediante aviso prévio de **30 (trinta) dias**.
2. Nos Planos pré-pagos sem prazo determinado, a resilição pelo CONTRATANTE produz efeitos ao término do Ciclo de Faturamento já pago, sem restituição proporcional, salvo direito de arrependimento aplicável ao consumidor (artigo 49 do CDC) nas contratações à distância, no prazo de 7 (sete) dias.
3. Nos Planos com prazo determinado/fidelidade, a resilição antecipada pelo CONTRATANTE poderá sujeitá-lo à **multa compensatória** proporcional ao período remanescente, na forma da proposta comercial, respeitados os limites legais.

### 13.4. Rescisão por justa causa

Poderá qualquer Parte rescindir o Contrato, de pleno direito, independentemente de notificação prévia (ou após o prazo de cura, quando cabível), nas hipóteses de: (i) descumprimento de obrigação essencial não sanado em **[NÚMERO] dias** da notificação; (ii) inadimplemento persistente; (iii) violação grave de confidencialidade, de propriedade intelectual ou de proteção de dados; (iv) decretação de falência, recuperação judicial que comprometa a execução, ou insolvência; (v) prática de ato ilícito relacionado ao objeto.

### 13.5. Efeitos da rescisão

Com a rescisão, cessa imediatamente a licença de uso, devendo o CONTRATANTE cessar o acesso e liquidar valores devidos até a data da extinção. A extinção não afasta obrigações de confidencialidade, proteção de dados, propriedade intelectual e responsabilidade, que subsistem por sua natureza.

### 13.6. Penalidades

Sem prejuízo das perdas e danos e das medidas cabíveis, a violação de obrigações de confidencialidade, propriedade intelectual, proteção de dados ou das vedações da Cláusula 4.2 sujeita a Parte infratora à **multa não compensatória de [VALOR ou PERCENTUAL]**, exigível independentemente de comprovação de prejuízo e cumulável com a indenização pelo dano excedente.

---

## Cláusula 14ª — Portabilidade e Eliminação de Dados no Encerramento

1. **Janela de portabilidade:** encerrado o Contrato por qualquer motivo, a CONTRATADA disponibilizará ao CONTRATANTE, por prazo não inferior a **[NÚMERO, ex.: 30] dias**, mecanismo de **exportação** dos dados do CONTRATANTE e dos Dados do Comprador sob sua controladoria, em formato estruturado e interoperável (ex.: CSV/JSON), na forma do artigo 18, V, da LGPD.
2. **Eliminação:** decorrida a janela de portabilidade, a CONTRATADA procederá à **eliminação** dos dados pessoais, salvo: (i) os que deva conservar por obrigação legal ou regulatória; (ii) os necessários ao exercício regular de direitos em processo (artigo 16 da LGPD); e (iii) dados anonimizados. O soft-delete e as trilhas de auditoria serão observados nos prazos legais de guarda.
3. **Confirmação:** a pedido, a CONTRATADA fornecerá declaração de eliminação, ressalvadas as retenções legais.
4. **Backups:** dados residentes em backups serão eliminados conforme o ciclo natural de rotação das cópias de segurança, permanecendo isolados e inacessíveis para uso operacional nesse ínterim.

---

## Cláusula 15ª — Garantias e Isenções

1. A Plataforma é fornecida **"no estado em que se encontra" e "conforme disponibilidade"**, dentro dos parâmetros do SLA, não garantindo a CONTRATADA que o funcionamento será ininterrupto ou totalmente isento de erros.
2. A CONTRATADA **não garante** resultados comerciais, faturamento, conversão, prazos de entrega dos Correios, aprovação de transações pelos gateways, nem a exatidão de dados fornecidos por terceiros ou pelo próprio CONTRATANTE.
3. O CONTRATANTE é o único responsável pela adequação da Plataforma às suas necessidades específicas, tendo tido a oportunidade de avaliá-la previamente.

---

## Cláusula 16ª — Limitação de Responsabilidade

1. Na máxima extensão permitida pela legislação aplicável, a responsabilidade total e agregada da CONTRATADA, por qualquer causa relacionada a este Contrato, fica **limitada ao valor efetivamente pago pelo CONTRATANTE nos 12 (doze) meses anteriores** ao fato gerador da responsabilidade.
2. A CONTRATADA **não responde** por danos indiretos, lucros cessantes, perda de chance, perda de dados decorrente de ato do CONTRATANTE ou de terceiros, danos por indisponibilidade de Sub-operadores, nem por decisões de negócio do CONTRATANTE.
3. As limitações **não se aplicam** a: (i) dolo ou culpa grave; (ii) violação de confidencialidade; (iii) violação de direitos de propriedade intelectual; (iv) danos a que a lei vede a limitação, notadamente direitos indisponíveis do consumidor e responsabilidades imperativas da LGPD.
4. **Responsabilidade em matéria de dados pessoais:** cada Parte responde na medida de sua atuação (Controlador ou Operador), nos termos dos artigos 42 a 45 da LGPD e do DPA; o CONTRATANTE, como Controlador, responde perante os titulares e a ANPD por suas próprias decisões de tratamento.
5. **Regresso e indenidade:** o CONTRATANTE manterá a CONTRATADA indene (indenidade) por reclamações de terceiros, titulares, Compradores ou autoridades decorrentes de (i) dados inseridos/importados pelo CONTRATANTE; (ii) ausência de base legal ou de transparência; (iii) uso indevido da Plataforma; (iv) descumprimento de obrigações fiscais, consumeristas ou regulatórias próprias.

---

## Cláusula 17ª — Alterações da Plataforma e do Contrato

1. A CONTRATADA poderá **evoluir, atualizar, modificar ou descontinuar** funcionalidades, visando à melhoria, à segurança ou à conformidade legal, preservando as funcionalidades essenciais do Plano contratado.
2. Alterações materiais deste Contrato ou dos Documentos Incorporados serão comunicadas com antecedência razoável, presumindo-se a aceitação pela continuidade de uso após a vigência, ressalvado ao consumidor o direito de resilir sem ônus em caso de alteração desvantajosa relevante.

---

## Cláusula 18ª — Disposições Gerais

1. **Comunicações:** as notificações serão válidas quando enviadas aos endereços eletrônicos cadastrados e ao **lemoncapsencapsulados@gmail.com** para assuntos de dados, presumindo-se recebidas na data do envio com confirmação.
2. **Cessão:** o CONTRATANTE não poderá ceder este Contrato sem anuência prévia e por escrito da CONTRATADA; a CONTRATADA poderá cedê-lo a empresa do mesmo grupo ou em operações societárias, mediante comunicação.
3. **Independência das cláusulas:** a nulidade ou ineficácia de qualquer cláusula não prejudica as demais, que permanecem em vigor.
4. **Tolerância:** a tolerância quanto a descumprimentos não implica novação, renúncia ou alteração do pactuado.
5. **Força maior e caso fortuito:** nenhuma Parte responde por descumprimento decorrente de eventos alheios ao seu controle (artigo 393 do Código Civil), incluindo falhas graves de terceiros/Sub-operadores, ataques cibernéticos de grande escala, indisponibilidade de infraestrutura de internet, atos de autoridade e desastres.
6. **Integralidade:** este Contrato e os Documentos Incorporados (SLA, DPA, Política de Privacidade, Política de Uso Aceitável, tabela de Planos e Termos de Uso) constituem o acordo integral entre as Partes, prevalecendo, em caso de conflito, este Contrato quanto às condições comerciais e o DPA quanto ao tratamento de dados.
7. **Idioma e legislação:** o Contrato é regido pelas leis da **República Federativa do Brasil**.
8. **Anticorrupção e sanções:** as Partes obrigam-se a cumprir a Lei nº 12.846/2013 (Anticorrupção) e normas correlatas, abstendo-se de práticas ilícitas relacionadas ao objeto.

---

## Cláusula 19ª — Foro

Fica eleito o foro da Comarca de **[COMARCA / CIDADE-UF]**, com renúncia a qualquer outro, por mais privilegiado que seja, para dirimir controvérsias oriundas deste Contrato. **Tratando-se de relação de consumo**, prevalecerá o foro do domicílio do CONTRATANTE consumidor, na forma do artigo 101, I, do Código de Defesa do Consumidor.

E, por estarem assim justas e contratadas, as Partes celebram o presente Contrato, aceito por meio eletrônico e/ou assinado, na **16 de julho de 2026**, produzindo seus efeitos legais.

**LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA — [NOME FANTASIA: GLOP]** (CONTRATADA)

**[CONTRATANTE]** (CONTRATANTE)

Testemunhas: **[PARTE]** e **[PARTE]** (quando aplicável).

---

## Engenharia Jurídica & Governança

### (a) Fundamentação das cláusulas (lei/norma que embasa)

| Cláusula | Fundamento legal/normativo | Racional |
|---|---|---|
| 1 e 19 (Partes, aceite eletrônico, foro) | Código Civil, arts. 421, 425, 427, 673; MP 2.200-2/2001; Lei 14.063/2020; CDC arts. 30, 49, 101, I | Validade da contratação e assinatura eletrônica; proteção do foro do consumidor |
| 3 e 4 (Objeto e Licença) | Lei 9.609/1998 (Software); Lei 9.610/1998; Código Civil (locação/serviços) | Licença de uso, não venda; vedações de engenharia reversa |
| 5 (Preços/Reajuste) | Código Civil arts. 315, 389, 395; Lei 10.192/2001 (periodicidade anual de reajuste) | Recorrência, mora, correção e reajuste anual por índice |
| 6 e 7 (SLA/Suporte) | Código Civil (obrigação de meio); CDC arts. 20 e 22 (serviços) | Disponibilidade, créditos de serviço como remédio, exclusões |
| 10 (Confidencialidade) | Lei 9.279/1996, art. 195 (segredo de negócio); Código Civil art. 422 (boa-fé) | Sigilo recíproco e sobrevivência do dever |
| 11 (Propriedade Intelectual) | Lei 9.609/1998; Lei 9.610/1998; Lei 9.279/1996; LGPD art. 12 (anonimização) | Titularidade do software; dados agregados anonimizados |
| 12 e 14 (LGPD/DPA/Portabilidade/Eliminação) | Lei 13.709/2018 — arts. 6º, 7º, 16, 18, 37, 38, 39, 46, 48; art. 42-45 (responsabilidade) | Dupla natureza Controlador/Operador; minimização no portal; eliminação/portabilidade |
| 13 (Suspensão/Rescisão/Penalidades) | Código Civil arts. 472-475, 408-416 (cláusula penal); CDC art. 49 | Resilição, resolução por inadimplemento, multas |
| 16 (Limitação de Responsabilidade) | Código Civil arts. 393, 402-404, 944; LGPD arts. 42-45; limites do CDC | Teto indenizatório e exceções imperativas |
| 18 (Anticorrupção, força maior) | Lei 12.846/2013; Código Civil art. 393 | Compliance e exclusão por eventos alheios ao controle |

### (b) Riscos mitigados

1. **Confusão de papéis LGPD** (Controlador x Operador) — mitigado pela Cláusula 12 e remissão ao DPA, alinhando ingestão via gateways/e-commerces à controladoria do CONTRATANTE.
2. **Exposição de PII no portal público de rastreio** — mitigado pelo princípio da minimização (status neutro, sem login expondo PII).
3. **Responsabilidade por terceiros/Sub-operadores** (Correios, VHSYS, gateways, Supabase, Netlify) — mitigado por exclusões de SLA, força maior e limitação de responsabilidade.
4. **Inadimplência e churn** — mitigado por mora, suspensão e regras de reajuste/fidelidade.
5. **Uso indevido/engenharia reversa/revenda** — mitigado pelas vedações da Cláusula 4 e penalidades.
6. **Perda/retenção de dados no encerramento** — mitigado pela janela de portabilidade e regras de eliminação (Cláusula 14).
7. **Ausência de base legal do cliente** — mitigado por obrigação e indenidade (Cláusulas 9, 12.7 e 16.5).
8. **Alteração unilateral abusiva** — mitigado por comunicação prévia e direito de resilição do consumidor (Cláusula 17).

### (c) Checklist de conformidade

- [ ] Preencher todos os placeholders entre colchetes (razão social, CNPJ, endereço, DPO, datas, comarca, valores/percentuais/prazos).
- [ ] Anexar/vincular efetivamente SLA, DPA, Política de Privacidade, Política de Uso Aceitável e tabela de Planos.
- [ ] Confirmar percentual de disponibilidade e metodologia de apuração no SLA.
- [ ] Definir prazos de cura, de suspensão por inadimplência e janela de portabilidade.
- [ ] Validar cláusula de fidelidade/multa compensatória frente ao CDC quando houver consumidor.
- [ ] Publicar e manter atualizada a lista de Sub-operadores.
- [ ] Registrar o encarregado (DPO) e canal de contato ativo.
- [ ] Garantir logs de aceite (data, hora, IP, usuário) e versionamento do Contrato aceito.
- [ ] Revisão final por advogado(a) habilitado(a) antes da produção.

### (d) Matriz RACI

| Atividade | CONTRATADA (GLOP) | CONTRATANTE | DPO/Encarregado | Jurídico |
|---|---|---|---|---|
| Disponibilizar a Plataforma e SLA | R/A | I | C | C |
| Definir finalidades e base legal do tratamento dos Dados do Comprador | C | R/A | C | C |
| Tratar dados como Operador conforme instruções | R/A | C | C | I |
| Atender requisições de titulares (Compradores) | C (auxílio) | R/A | R | C |
| Notificar incidentes de segurança | R | A | R | C |
| Gestão de credenciais e permissões (RBAC) dos Usuários | C | R/A | I | I |
| Emissão fiscal (NF-e via VHSYS) e obrigações tributárias | C | R/A | I | C |
| Reajuste e cobrança | R/A | I | I | C |
| Portabilidade e eliminação no encerramento | R | A | C | C |
| Revisão jurídica e versionamento do Contrato | C | I | C | R/A |

Legenda: R = Responsável executa; A = Aprova/Accountable; C = Consultado; I = Informado.

### (e) Plano de revisão

1. **Periodicidade:** revisão ordinária **anual** ou sempre que houver alteração legislativa (LGPD/ANPD, CDC, tributária), mudança de Sub-operadores, novo módulo/fluxo ou incidente relevante.
2. **Gatilhos extraordinários:** edição de norma da ANPD, decisão judicial vinculante, alteração de gateways/integrações, mudança de política de preços.
3. **Fluxo:** Jurídico revisa → DPO valida aspectos de dados → Produto confirma fluxos reais → aprovação e publicação de nova versão → comunicação aos CONTRATANTES → registro de novo aceite quando material.
4. **Responsável:** Departamento Jurídico com apoio do Encarregado (DPO).

### (f) Controle de versão

| Versão | Data | Autor | Descrição das alterações | Status |
|---|---|---|---|---|
| 0.1 | 16 de julho de 2026 | Chief Legal AI | Minuta inicial do Contrato SaaS GLOP (licença, planos, SLA, LGPD/DPA, PI, limitação, rescisão, portabilidade, foro) | Minuta — pendente de revisão jurídica |
| 0.2 | 16 de julho de 2026 | [PARTE] | Preenchimento de placeholders e vinculação dos Documentos Incorporados | Pendente |
| 1.0 | 16 de julho de 2026 | [PARTE] | Versão aprovada por advogado(a) habilitado(a) para produção | Pendente |

---

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.
