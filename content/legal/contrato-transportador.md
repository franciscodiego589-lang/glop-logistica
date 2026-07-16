> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# CONTRATO DE PRESTAÇÃO DE SERVIÇOS DE TRANSPORTE E LOGÍSTICA DE ENTREGA (TRANSPORTADOR / CORREIOS / ÚLTIMA MILHA)

**Instrumento particular de prestação de serviços de transporte rodoviário de cargas e entrega de encomendas, com tratamento de dados pessoais do destinatário na condição de suboperador**

---

## Preâmbulo

O presente Contrato de Prestação de Serviços de Transporte e Logística de Entrega ("Contrato") é celebrado no âmbito da plataforma **[NOME FANTASIA: GLOP]** — *Global Logistics Platform* —, SaaS de logística e ERP voltado à operação de dropshipping e infoprodutos no Brasil, que orquestra, por meio de tecnologia (Next.js + Supabase, com isolamento multi-tenant por RLS), a captura de pedidos, a geração de documentos fiscais e de pré-postagem, o rastreio, a comunicação com o destinatário e a apuração logística de seus clientes (produtores, lojistas e infoprodutores).

Este Contrato regula a relação entre a plataforma e/ou o embarcante e o prestador de serviços de transporte contratado (transportadora rodoviária de cargas, Empresa Brasileira de Correios e Telégrafos – ECT, operador de última milha, *courier* ou transportador autônomo de cargas), disciplinando a coleta, o transporte, a entrega, os prazos e níveis de serviço (SLA), as tarifas de frete, o seguro e a responsabilidade por avaria e extravio, o rastreamento e a comprovação de entrega (POD), as obrigações regulatórias aplicáveis (ANTT, ANATEL, legislação postal) e, de forma destacada, a proteção dos dados pessoais do destinatário, nos termos da Lei nº 13.709/2018 (Lei Geral de Proteção de Dados Pessoais – LGPD).

---

## Cláusula 1ª — Qualificação das Partes

**1.1. CONTRATANTE / EMBARCANTE / OPERADOR DA PLATAFORMA:**

**LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA**, sociedade empresária inscrita no CNPJ sob nº **55.836.075/0001-07**, com sede em **Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190**, doravante designada **"CONTRATANTE"**, **"GLOP"** ou **"Plataforma"**, neste ato representada na forma de seus atos constitutivos.

**1.2. CONTRATADA / TRANSPORTADORA:**

**[RAZÃO SOCIAL DA TRANSPORTADORA]**, pessoa jurídica inscrita no CNPJ sob nº **[CNPJ DA TRANSPORTADORA]**, com sede em **[ENDEREÇO DA TRANSPORTADORA]**, inscrita, quando aplicável, no Registro Nacional de Transportadores Rodoviários de Cargas (**RNTRC**) sob nº **[RNTRC]** perante a Agência Nacional de Transportes Terrestres (ANTT), doravante designada **"CONTRATADA"**, **"TRANSPORTADORA"** ou **"TRANSPORTADOR"**, neste ato representada na forma de seus atos constitutivos.

**1.3.** Quando a CONTRATADA for a **Empresa Brasileira de Correios e Telégrafos (ECT/Correios)**, empresa pública federal, o presente Contrato observará, de forma complementar e prevalente naquilo que for específico, o contrato de prestação de serviços postais, o(s) cartão(ões) de postagem, os manuais técnicos (SIGEP/PPN – Pré-Postagem, SRO – Sistema de Rastreamento de Objetos) e as normas do serviço postal (Lei nº 6.538/1978 e regulamentação da ANATEL/Ministério das Comunicações), integrando este Contrato como anexo.

**1.4.** Quando a CONTRATADA for **Transportador Autônomo de Cargas (TAC)** ou **Empresa de Transporte Rodoviário de Cargas (ETC)**, aplicar-se-ão a Lei nº 11.442/2007 (transporte rodoviário de cargas por conta de terceiros) e a Resolução ANTT nº 5.867/2019 e atualizações (RNTRC), sendo condição de eficácia deste Contrato a manutenção de registro válido.

**1.5.** As Partes reconhecem que a Plataforma pode atuar (i) em nome próprio, como embarcante/contratante direto do frete, ou (ii) como **intermediária tecnológica** que integra a CONTRATADA aos seus clientes finais (produtores/lojistas), hipótese em que as obrigações operacionais deste Contrato beneficiam também o embarcante efetivo indicado em cada ordem de transporte, na forma da Cláusula 4ª.

---

## Cláusula 2ª — Definições

Para os fins deste Contrato, aplicam-se as seguintes definições:

1. **Encomenda / Objeto / Carga:** bem físico a ser transportado, resultante de pedido capturado pela Plataforma (produtos físicos de dropshipping; materiais físicos vinculados a infoprodutos, quando houver).
2. **Ordem de Transporte / Etiqueta / Pré-Postagem (PPN):** instrução eletrônica de coleta e entrega gerada pela Plataforma, contendo remetente, destinatário, endereço, dimensões, peso e serviço contratado, materializada em etiqueta/declaração de conteúdo/documento fiscal.
3. **POD (*Proof of Delivery*) / Comprovante de Entrega:** conjunto de evidências que atestam a entrega — data, hora, geolocalização quando disponível, nome e/ou documento de quem recebeu, assinatura física ou eletrônica, código de rastreio e código de confirmação (OTP), quando aplicável.
4. **SLA (*Service Level Agreement*):** níveis de serviço acordados, especialmente prazos de coleta e de entrega.
5. **SRO / Rastreio:** evento de rastreamento (status neutro) devolvido pela CONTRATADA e consumido pela Plataforma para atualização do pedido e notificação ao destinatário.
6. **Destinatário / Comprador:** pessoa física ou jurídica que recebe a Encomenda; **titular** dos dados pessoais tratados para a entrega.
7. **Controlador:** o produtor/lojista/infoprodutor cliente da Plataforma, que determina as finalidades do tratamento dos dados do comprador (art. 5º, VI, LGPD).
8. **Operador:** a Plataforma GLOP, que trata os dados do comprador em nome do Controlador (art. 5º, VII, LGPD).
9. **Suboperador:** a CONTRATADA (transportadora/Correios/última milha), que trata os dados do destinatário por conta e ordem do Operador, exclusivamente para executar a entrega (art. 39, LGPD).
10. **Avaria:** dano, deterioração, quebra, molhamento, amassamento ou violação parcial da Encomenda.
11. **Extravio:** perda total ou parcial, furto, roubo, desaparecimento ou não localização definitiva da Encomenda.
12. **Última Milha (*last mile*):** etapa final da entrega, do centro de distribuição local até o endereço do destinatário.

---

## Cláusula 3ª — Objeto

**3.1.** O objeto deste Contrato é a **prestação, pela CONTRATADA, de serviços de coleta, transporte e entrega de Encomendas** — incluindo transporte rodoviário de cargas, serviços postais/de encomenda expressa e/ou operação de última milha — geradas e orquestradas por meio da Plataforma GLOP, mediante remuneração (frete), na forma, prazos e condições aqui pactuados e nos Anexos.

**3.2.** Compreendem-se no objeto, conforme a modalidade contratada:
1. **Coleta** (*pickup*) das Encomendas no(s) endereço(s) de origem indicado(s) na Ordem de Transporte, ou postagem em agência/ponto de aceitação;
2. **Transporte** da origem ao destino, com movimentação, triagem, transbordo e armazenagem transitória inerentes;
3. **Entrega** ao destinatário no endereço informado, com coleta do POD;
4. **Rastreamento** e devolução de eventos (SRO) para consumo pela Plataforma;
5. **Logística reversa / devolução**, quando contratada (retorno ao remetente por recusa, ausência, endereço não localizado ou solicitação do embarcante);
6. **Reentregas** dentro dos limites de tentativas acordados.

**3.3.** A integração técnica entre a Plataforma e a CONTRATADA dá-se por **API** (geração de pré-postagem/etiqueta, cotação de frete, consulta de rastreio e retorno de eventos). As credenciais de integração da CONTRATADA são armazenadas pela Plataforma em modo **write-only** (segredo não legível após gravação), com trilha de auditoria, na forma da Cláusula 12ª.

**3.4.** O objeto **não abrange** o transporte de bens ilícitos, proibidos ou restritos (armas, explosivos, drogas, produtos perecíveis não declarados, valores em espécie acima de limite, animais vivos, resíduos perigosos e demais itens vedados pela regulação postal/de transporte e pela política de itens proibidos da CONTRATADA), cabendo ao embarcante a licitude e a correta declaração do conteúdo.

---

## Cláusula 4ª — Natureza da Relação e Papéis (Embarcante, Plataforma e Cliente)

**4.1.** A Plataforma GLOP atua como **provedor de tecnologia logística** que integra a CONTRATADA aos seus clientes (produtores/lojistas). Conforme a configuração comercial de cada operação, a CONTRATANTE do frete perante a CONTRATADA poderá ser (i) a própria Plataforma, ou (ii) o cliente da Plataforma (embarcante efetivo), com a Plataforma atuando como mandatária/intermediária para geração de etiquetas e consolidação.

**4.2.** Independentemente do modelo, a CONTRATADA obriga-se a cumprir os SLAs, as regras de manuseio, de proteção de dados e de comprovação de entrega deste Contrato em relação a **toda** Ordem de Transporte originada pela Plataforma.

**4.3.** A relação entre as Partes é de **prestação de serviços autônoma**, inexistindo vínculo societário, associativo, de representação, de consórcio ou empregatício. Cada Parte é integralmente responsável por seus empregados, prepostos, subcontratados, encargos trabalhistas, previdenciários, fiscais e tributários, na forma da Cláusula 15ª.

---

## Cláusula 5ª — Coleta e Aceitação da Encomenda

**5.1. Geração da Ordem.** A Plataforma disponibilizará à CONTRATADA, por API ou etiqueta, os dados mínimos da Ordem de Transporte: identificação do remetente/embarcante, dados do destinatário (nome, endereço completo, CEP, telefone e/ou e-mail para contato de entrega), descrição, peso, dimensões, valor declarado e serviço/modalidade contratada.

**5.2. Coleta / Postagem.** A CONTRATADA realizará a coleta no endereço de origem ou receberá a Encomenda em ponto de aceitação/agência, conferindo, no ato:
1. integridade externa da embalagem;
2. compatibilidade de peso e dimensões com o declarado;
3. presença de etiqueta/pré-postagem (PPN) válida e legível;
4. presença de documento fiscal (NF-e) ou declaração de conteúdo, quando exigível.

**5.3. Aceitação e ressalvas.** A coleta sem ressalva formal registrada no evento de rastreio presume o recebimento da Encomenda **íntegra e conforme** o declarado, iniciando a responsabilidade de guarda e transporte da CONTRATADA (custódia). Divergências devem ser registradas no ato como ressalva, sob pena de preclusão do direito de alegá-las posteriormente contra o embarcante.

**5.4. Janela de coleta.** A CONTRATADA cumprirá a janela de coleta definida no Anexo I (SLA). O não comparecimento à coleta agendada sujeita a CONTRATADA às penalidades da Cláusula 17ª, ressalvado motivo de força maior comprovado.

**5.5. Embalagem.** A adequação da embalagem à natureza do bem e ao modal é responsabilidade do embarcante; a CONTRATADA, contudo, deverá recusar ou ressalvar Encomendas com embalagem manifestamente inadequada ou violada, comunicando a Plataforma.

**5.6. Recusa legítima.** A CONTRATADA poderá recusar a coleta de Encomendas que contenham itens proibidos/restritos (Cláusula 3.4), que estejam sem documentação fiscal exigível ou que representem risco à segurança, registrando o motivo no evento de rastreio.

---

## Cláusula 6ª — Transporte, Manuseio e Custódia

**6.1.** A CONTRATADA obriga-se a transportar a Encomenda com **diligência de transportador profissional**, respondendo pela guarda, conservação e integridade do objeto desde a coleta até a entrega ao destinatário ou a devolução ao remetente (custódia contínua), nos termos dos arts. 749 a 756 do Código Civil (contrato de transporte de coisas).

**6.2.** A CONTRATADA deverá:
1. observar as condições de manuseio indicadas na etiqueta (frágil, este lado para cima, temperatura, quando aplicável);
2. manter a Encomenda em ambiente adequado, protegida de intempéries, umidade e violação;
3. utilizar veículos, equipamentos e instalações em condições regulares, com manutenção e, quando exigido, licenciamento e vistoria em dia;
4. adotar plano de segurança e gerenciamento de risco proporcional ao valor transportado, incluindo, quando aplicável, escolta, rastreamento veicular e isca.

**6.3.** É **vedado** à CONTRATADA abrir, inspecionar o conteúdo (salvo determinação legal/fiscalização competente), reutilizar, copiar ou desviar a Encomenda de sua finalidade, bem como reter indevidamente o objeto.

**6.4. Subcontratação.** A CONTRATADA poderá subcontratar etapas do transporte (redespacho, transbordo, última milha) **desde que** garanta que o subcontratado observe os mesmos padrões de SLA, segurança e proteção de dados deste Contrato, permanecendo a CONTRATADA **solidariamente responsável** perante a CONTRATANTE pelos atos do subcontratado. Subcontratação de tratamento de dados observa a Cláusula 13ª.

---

## Cláusula 7ª — Prazos e SLA de Entrega

**7.1. Prazos.** Os prazos de coleta e de entrega são os definidos no **Anexo I (Tabela de SLA)**, por modalidade de serviço, faixa de CEP/região e tipo de Encomenda, contados em dias úteis, salvo estipulação diversa. Para os Correios, prevalecem os prazos oficiais publicados por serviço (PAC, SEDEX e correlatos) e faixa de origem/destino.

**7.2. Indicadores mínimos de nível de serviço.** A CONTRATADA compromete-se, apurados mensalmente, aos seguintes indicadores de referência (a ajustar no Anexo I):

| Indicador | Definição | Meta de referência |
|---|---|---|
| **OTD — On Time Delivery** | % de Encomendas entregues dentro do prazo SLA | ≥ **[95]%** |
| **Taxa de coleta no prazo** | % de coletas realizadas na janela agendada | ≥ **[97]%** |
| **Taxa de avaria** | % de Encomendas entregues com avaria | ≤ **[0,5]%** |
| **Taxa de extravio** | % de Encomendas extraviadas | ≤ **[0,2]%** |
| **Taxa de sucesso na 1ª tentativa** | % de entregas concluídas na primeira tentativa | ≥ **[85]%** |
| **Atualização de rastreio** | % de eventos SRO disponibilizados em até **[6]h** do fato | ≥ **[98]%** |
| **Tempo de resposta a chamados** | Prazo médio de tratativa de ocorrências | ≤ **[24]h úteis** |

**7.3. Tentativas de entrega e reentrega.** A CONTRATADA realizará até **[3]** tentativas de entrega. Em caso de ausência do destinatário, deixará aviso e/ou registrará evento de rastreio, comunicando a Plataforma para reagendamento, retenção em ponto de retirada ou logística reversa.

**7.4. Suspensão de prazos.** Os prazos suspendem-se por: (i) endereço incorreto/insuficiente informado pelo embarcante; (ii) ausência reiterada do destinatário; (iii) recusa de recebimento; (iv) exigência de fiscalização/alfândega; (v) força maior/caso fortuito (Cláusula 16ª); (vi) áreas de risco/entrega restrita oficialmente reconhecidas. Tais eventos serão registrados no rastreio como justificativa objetiva.

**7.5. Descumprimento de SLA.** O não atingimento dos indicadores mínimos por **[2]** meses consecutivos ou **[3]** alternados em **[6]** meses caracteriza descumprimento material, autorizando a aplicação das penalidades da Cláusula 17ª e/ou a rescisão motivada (Cláusula 18ª), sem prejuízo da indenização por danos comprovados.

---

## Cláusula 8ª — Tarifas, Frete e Condições de Pagamento

**8.1. Tabela de frete.** As tarifas são as constantes do **Anexo II (Tabela de Frete)**, por modalidade, peso real/cubado, faixa de CEP, valor declarado e serviços adicionais (aviso de recebimento, mão própria, seguro adicional, reentrega, logística reversa, armazenagem).

**8.2. Peso cubado.** Quando aplicável, o frete considerará o maior entre o peso real e o peso cubado, pelo fator volumétrico definido no Anexo II.

**8.3. Cotação em tempo real.** Quando a integração por API oferecer cotação dinâmica, o valor apresentado no momento da geração da etiqueta prevalece para aquela Ordem, salvo erro material evidente.

**8.4. Faturamento.** A CONTRATADA emitirá **Conhecimento de Transporte Eletrônico (CT-e)** e/ou fatura/nota fiscal de serviço, conforme a natureza e a legislação aplicável, com o detalhamento das Ordens de Transporte do período. Para os Correios, prevalece o faturamento por cartão de postagem/contrato ECT.

**8.5. Prazo e forma de pagamento.** O pagamento será realizado em **[ex.: até 15 dias]** contados do recebimento e aceite da fatura/CT-e, por **[transferência/PIX/boleto]**, na conta indicada pela CONTRATADA, condicionado à regularidade fiscal e ao cumprimento do SLA no período.

**8.6. Glosas e compensações.** A CONTRATANTE poderá glosar da fatura: fretes de Ordens não entregues por culpa da CONTRATADA, cobranças em duplicidade, divergências de peso/dimensão não comprovadas, multas e penalidades apuradas na forma da Cláusula 17ª e créditos de indenização por avaria/extravio (Cláusula 10ª), mediante comunicação com memória de cálculo e direito de contraditório em **[10]** dias.

**8.7. Reajuste.** As tarifas serão reajustadas anualmente pela variação do **[IPCA/IGP-M]** acumulado, ou por índice setorial oficial de transporte (piso mínimo de frete da ANTT, quando aplicável), mediante aditivo. Nenhum reajuste retroage a Ordens já geradas.

**8.8. Tributos.** Cada Parte arca com os tributos de sua responsabilidade legal (ISS/ICMS-transporte, PIS/COFINS, etc.), vedada a transferência de encargos não previstos em lei ou neste Contrato.

**8.9. Piso mínimo (ANTT).** No transporte rodoviário de cargas sujeito à Política Nacional de Pisos Mínimos do Transporte Rodoviário de Cargas (Lei nº 13.703/2018 e Resoluções ANTT), as tarifas observarão o piso mínimo vigente, sendo nulo o pactuado abaixo do piso legal.

---

## Cláusula 9ª — Seguro

**9.1. Seguro obrigatório do transportador.** A CONTRATADA, quando transportadora rodoviária de cargas, obriga-se a manter vigentes, durante toda a execução, as apólices de seguro legalmente exigíveis, notadamente:
1. **RCTR-C** — Responsabilidade Civil do Transportador Rodoviário de Cargas (cobre perdas e danos por colisão, capotagem, tombamento, incêndio e correlatos);
2. **RCF-DC** — Responsabilidade Civil Facultativa por Desaparecimento de Carga (roubo/furto), quando o perfil de risco exigir;
3. seguros exigidos pela regulação específica do modal.

**9.2. Comprovação.** A CONTRATADA apresentará, no início e à renovação anual, cópias das apólices e comprovantes de pagamento, indicando importâncias seguradas compatíveis com o valor das Encomendas transportadas. A Plataforma poderá exigir apólice adicional ou ampliação de cobertura para operações de maior valor.

**9.3. Seguro por Encomenda / valor declarado.** Independentemente das apólices próprias da CONTRATADA, o embarcante poderá contratar seguro adicional por Ordem, com base no valor declarado, cuja cobertura observará o Anexo II. Nos Correios, aplicam-se as regras de valor declarado e indenização do serviço postal.

**9.4.** A existência de seguro **não exime** a CONTRATADA de suas responsabilidades contratuais e legais perante a CONTRATANTE, o embarcante e o destinatário; o seguro é garantia adicional, não substitutiva.

---

## Cláusula 10ª — Responsabilidade por Avaria e Extravio

**10.1. Responsabilidade do transportador.** A CONTRATADA responde objetivamente pela integridade da Encomenda desde a coleta até a entrega/devolução (arts. 749 e 750 do Código Civil), indenizando avaria e extravio ocorridos sob sua custódia, com base no **valor declarado/valor da mercadoria constante da NF-e**, limitado, quando houver, ao teto de indenização do Anexo II ou às regras do serviço postal.

**10.2. Registro e abertura de ocorrência.** Constatada avaria ou extravio:
1. o destinatário/embarcante registrará ressalva no ato da entrega e/ou abrirá ocorrência pela Plataforma;
2. a CONTRATADA abrirá processo de indenização, apurando causa e responsabilidade;
3. a Plataforma fornecerá evidências (POD, fotos, NF-e, eventos de rastreio) para instrução.

**10.3. Prazos de tratativa e indenização.** A CONTRATADA concluirá a apuração em até **[10]** dias úteis e efetuará a indenização em até **[30]** dias corridos da constatação, salvo prazo específico do serviço postal, sob pena das penalidades da Cláusula 17ª.

**10.4. Excludentes de responsabilidade.** A CONTRATADA não responde quando comprovar (ônus seu): (i) vício próprio/natureza perecível não informada da mercadoria; (ii) embalagem inadequada ou insuficiente de responsabilidade do embarcante; (iii) informação de endereço/destinatário incorreta fornecida pelo embarcante; (iv) caso fortuito ou força maior (Cláusula 16ª); (v) culpa exclusiva do destinatário/terceiro; (vi) itens proibidos/não declarados. As excludentes não se presumem e dependem de prova.

**10.5. Sub-rogação e repasse ao destinatário.** Quando a Encomenda for de consumo e a relação embarcante-destinatário reger-se pelo Código de Defesa do Consumidor (Lei nº 8.078/1990), a CONTRATANTE/embarcante poderá responder perante o consumidor de forma solidária e, uma vez indenizado o consumidor, sub-rogar-se-á nos direitos contra a CONTRATADA na medida da culpa desta, com direito de regresso integral.

**10.6. Ausência de limitação para dolo/culpa grave.** Os tetos e limites indenizatórios **não se aplicam** aos danos decorrentes de dolo, fraude, apropriação indevida, violação da Encomenda ou culpa grave da CONTRATADA ou de seus prepostos/subcontratados.

---

## Cláusula 11ª — Rastreamento (SRO) e Comprovação de Entrega (POD)

**11.1. Rastreamento contínuo.** A CONTRATADA disponibilizará, por API/webhook, os eventos de rastreio (SRO) de cada Encomenda — postagem/coleta, trânsito, saiu para entrega, entregue, tentativa frustrada, devolução —, com data, hora e unidade, para consumo em tempo hábil pela Plataforma.

**11.2. Uso pela Plataforma.** A Plataforma utilizará os eventos para: (i) atualizar o status do pedido em seus módulos; (ii) notificar o destinatário por **e-mail e/ou WhatsApp**; e (iii) alimentar o **portal público de rastreio, que opera SEM login e expõe apenas status neutro**, sem PII do destinatário além do estritamente necessário para localização do objeto, na forma da Cláusula 12ª.

**11.3. Comprovação de entrega (POD).** A CONTRATADA fornecerá, para cada Encomenda entregue, o **Comprovante de Entrega (POD)** contendo, no mínimo: código de rastreio, data e hora, identificação da unidade/entregador, nome e/ou documento de quem recebeu e assinatura (física ou eletrônica). Quando disponível, incluirá geolocalização do ponto de entrega e código de confirmação (OTP) enviado ao destinatário.

**11.4. Retenção e disponibilização do POD.** A CONTRATADA armazenará o POD por prazo não inferior a **[5]** anos (ou pelo prazo legal aplicável às relações de consumo/prescrição) e o disponibilizará à CONTRATANTE em até **[5]** dias úteis quando solicitado, para instruir contestações, chargebacks, reclamações consumeristas e processos de indenização.

**11.5. Valor probatório.** O POD é a prova primária da entrega. Na sua ausência ou insuficiência, presume-se, salvo prova em contrário produzida pela CONTRATADA, a **não entrega**, respondendo a CONTRATADA como em caso de extravio (Cláusula 10ª).

**11.6. Confirmação de recebimento por dado biométrico/documento.** Caso a CONTRATADA colete documento de identidade ou assinatura do destinatário como POD, tais dados serão tratados exclusivamente para comprovação da entrega, observadas as Cláusulas 12ª e 13ª e o princípio da minimização.

---

## Cláusula 12ª — Proteção de Dados Pessoais do Destinatário (LGPD) — Enquadramento

**12.1. Cadeia de tratamento.** Para a execução da entrega, há tratamento de dados pessoais do destinatário na seguinte cadeia:
- **Controlador:** o produtor/lojista/infoprodutor cliente, que determina as finalidades (venda e entrega ao seu comprador);
- **Operador:** a Plataforma GLOP, que trata os dados do comprador em nome do Controlador;
- **Suboperador:** a CONTRATADA (transportadora/Correios/última milha), que trata os dados do destinatário por conta e ordem do Operador, exclusivamente para transportar e entregar a Encomenda.

**12.2. Enquadramento da CONTRATADA.** No âmbito deste Contrato, a CONTRATADA atua como **OPERADORA/SUBOPERADORA** dos dados pessoais do destinatário (art. 39 da LGPD), tratando-os **somente** conforme as instruções documentadas da CONTRATANTE e para as finalidades logísticas aqui previstas, sendo-lhe **vedado** qualquer tratamento para finalidade própria (marketing, enriquecimento, revenda, perfilamento comercial).

**12.3. Dados tratados (minimização).** O tratamento limita-se aos dados **necessários** à entrega: nome do destinatário, endereço completo e CEP, telefone e/ou e-mail de contato de entrega, referências de localização, código de rastreio e, quando exigível, CPF/CNPJ para fins fiscais/aduaneiros e documento/assinatura para POD. É vedado tratar dados excedentes ao objeto.

**12.4. Bases legais.** O tratamento fundamenta-se na **execução de contrato** e diligências pré-contratuais a pedido do titular (art. 7º, V, LGPD), no **cumprimento de obrigação legal/regulatória** (art. 7º, II — obrigações fiscais e postais) e, subsidiariamente, no **legítimo interesse** para comunicação transacional de entrega (art. 7º, IX), sempre sob determinação do Controlador.

**12.5. Portal público de rastreio.** As Partes reconhecem que o portal público de rastreio da Plataforma opera **sem autenticação** e deve expor **apenas status neutro** do objeto (situação e etapa logística), sem revelar PII do destinatário além do mínimo indispensável. A CONTRATADA não incluirá, em eventos de rastreio destinados ao portal público, dados pessoais sensíveis, endereço completo ou documento do destinatário.

**12.6. DPA.** O detalhamento das obrigações de proteção de dados, medidas de segurança, sub-operadores, transferências e notificação de incidentes consta do **Acordo de Tratamento de Dados (DPA)** vigente entre as Partes (remissão ao documento `dpa.md`), que integra este Contrato como anexo. Em caso de conflito sobre matéria de dados, prevalece o DPA.

---

## Cláusula 13ª — Obrigações da CONTRATADA quanto aos Dados Pessoais

**13.1.** A CONTRATADA, na qualidade de suboperadora, obriga-se a:
1. **Tratar** os dados do destinatário **estritamente** para coleta, transporte, entrega, rastreio, POD e logística reversa, conforme instruções documentadas da CONTRATANTE;
2. **Não** compartilhar, vender, ceder, alugar, publicar ou usar os dados para finalidade própria ou de terceiros;
3. **Minimizar** o acesso, restringindo-o a prepostos e entregadores estritamente necessários, sob dever de sigilo formalizado;
4. **Adotar medidas técnicas e administrativas de segurança** adequadas (controle de acesso, criptografia em trânsito e repouso quando aplicável, registro de acessos, hardening), proporcionais ao risco;
5. **Auxiliar** a CONTRATANTE e o Controlador no atendimento a requisições de titulares (acesso, correção, eliminação, informação sobre compartilhamento) em até **[5]** dias úteis;
6. **Auxiliar** no cumprimento das obrigações dos arts. 48 e 50 da LGPD, inclusive relatórios de impacto quando exigidos;
7. **Notificar** a CONTRATANTE sobre **incidente de segurança** envolvendo dados do destinatário em prazo não superior a **[24 (vinte e quatro) horas]** da ciência, com as informações do art. 48 da LGPD (natureza, dados afetados, medidas, riscos), colaborando na comunicação à ANPD e aos titulares quando cabível;
8. **Eliminar ou devolver** os dados ao término do tratamento/Contrato, salvo retenção legal (fiscal, POD, prescrição), conforme Cláusula 20ª e política de retenção da Plataforma;
9. **Manter registro** das operações de tratamento que realizar (art. 37, LGPD);
10. **Garantir** que subcontratados/redespachantes que tratem dados do destinatário assumam obrigações **não menos protetivas** que as deste Contrato, mediante contrato escrito, permanecendo a CONTRATADA responsável.

**13.2. Transferência internacional.** Havendo transferência internacional de dados do destinatário (ex.: uso de infraestrutura fora do Brasil por subcontratado), a CONTRATADA observará os arts. 33 a 36 da LGPD, informando previamente a CONTRATANTE e adotando salvaguardas adequadas (cláusulas-padrão/garantias).

**13.3. Autonomia como Controladora.** Quanto aos dados de **seus próprios** empregados, prepostos e da relação comercial com a Plataforma, a CONTRATADA atua como **Controladora independente**, respondendo por conformidade própria.

**13.4. Auditoria.** A CONTRATANTE poderá auditar (diretamente ou por terceiro independente sob confidencialidade), mediante aviso prévio de **[10]** dias, a conformidade da CONTRATADA às obrigações de segurança e proteção de dados, sem interromper a operação.

---

## Cláusula 14ª — Obrigações Regulatórias e Conformidade

**14.1. Registro e habilitação.** A CONTRATADA declara e garante manter, durante toda a vigência, as habilitações exigíveis à sua atividade, notadamente:
1. **RNTRC/ANTT** válido, para transporte rodoviário de cargas por conta de terceiros (Lei nº 11.442/2007; Resolução ANTT nº 5.867/2019);
2. observância da **Política Nacional de Pisos Mínimos** (Lei nº 13.703/2018), quando aplicável;
3. para serviço postal, contrato/credenciamento ECT e normas do setor (Lei nº 6.538/1978; regulação ANATEL/Ministério das Comunicações);
4. licenças ambientais, sanitárias e de segurança veicular exigíveis ao modal e à carga;
5. emissão regular de **CT-e/MDF-e** e demais documentos fiscais de transporte.

**14.2. Documentação fiscal de acompanhamento.** A CONTRATADA transportará a Encomenda acompanhada da documentação fiscal exigível (NF-e/DANFE emitida via VHSYS pela Plataforma/embarcante, CT-e, declaração de conteúdo), respondendo por autuações decorrentes de falha operacional própria (ex.: transporte sem CT-e por sua omissão).

**14.3. Jornada e segurança do motorista.** A CONTRATADA observará a legislação de jornada e descanso do motorista (Lei nº 13.103/2015) e as normas de segurança no transporte, sendo integralmente responsável por infrações de trânsito e sinistros ocorridos na execução.

**14.4. Trabalho digno e cadeia responsável.** A CONTRATADA declara não empregar trabalho infantil, forçado ou análogo à escravidão em sua cadeia, e observar as normas anticorrupção (Lei nº 12.846/2013), sob pena de rescisão imediata (Cláusula 18ª).

**14.5. Atualização regulatória.** Alterações legais/regulatórias supervenientes que afetem prazos, tarifas ou obrigações serão refletidas por aditivo, sem retroação a Ordens em curso, salvo imposição legal em contrário.

---

## Cláusula 15ª — Obrigações das Partes

**15.1. São obrigações da CONTRATADA**, além das demais previstas neste Contrato:
1. Executar coleta, transporte e entrega com qualidade, segurança e nos prazos do SLA;
2. Fornecer eventos de rastreio (SRO) e POD íntegros e tempestivos;
3. Manter apólices de seguro e habilitações vigentes;
4. Guardar sigilo e proteger os dados do destinatário (Cláusulas 12ª a 13ª);
5. Indenizar avarias/extravios sob sua custódia (Cláusula 10ª);
6. Disponibilizar canal de atendimento e SLA de resposta a ocorrências;
7. Cumprir a legislação trabalhista, previdenciária, fiscal, ambiental e de trânsito aplicável;
8. Manter integração de API estável e comunicar, com antecedência de **[30]** dias, mudanças que impactem a integração (endpoints, autenticação, layout de etiqueta).

**15.2. São obrigações da CONTRATANTE:**
1. Fornecer Ordens de Transporte com dados corretos, completos e legíveis (endereço, destinatário, peso/dimensões, valor declarado);
2. Garantir a licitude e a correta declaração do conteúdo transportado e a adequação da embalagem pelo embarcante;
3. Disponibilizar NF-e/documentação fiscal exigível;
4. Pagar o frete devido nas condições da Cláusula 8ª;
5. Manter as credenciais de integração da CONTRATADA em ambiente seguro (write-only), com trilha de auditoria;
6. Repassar à CONTRATADA apenas os dados do destinatário necessários à entrega (minimização);
7. Instruir a CONTRATADA por escrito quanto ao tratamento de dados e comunicar alterações relevantes.

**15.3. Independência.** Cada Parte responde exclusivamente por seus empregados, prepostos e encargos, inexistindo solidariedade ou subsidiariedade trabalhista entre as Partes, que reciprocamente se garantem indenes (Cláusula 16ª).

---

## Cláusula 16ª — Responsabilidade, Limitação e Indenização Recíproca (Hold Harmless)

**16.1. Responsabilidade da CONTRATADA.** A CONTRATADA responde por perdas e danos diretos comprovadamente causados por descumprimento contratual, falha na custódia, avaria, extravio, atraso culposo, violação de dados sob sua responsabilidade e infrações regulatórias que lhe sejam imputáveis.

**16.2. Limitação de responsabilidade.** Ressalvadas as hipóteses do item 16.3, a responsabilidade agregada de cada Parte por danos indiretos limita-se, quando cabível, ao **[valor equivalente aos fretes pagos nos últimos 12 (doze) meses]** ou ao teto indenizatório por Encomenda do Anexo II, o que a operação definir. Não há limitação para a indenização de avaria/extravio da Encomenda até o valor declarado/NF-e.

**16.3. Não incidência de limites.** Os limites do item 16.2 **não se aplicam** a: (i) dolo, fraude ou culpa grave; (ii) violação de sigilo/proteção de dados e sanções da LGPD; (iii) danos a terceiros/consumidores por fato do serviço; (iv) infrações anticorrupção; (v) danos morais ao destinatário por conduta da CONTRATADA.

**16.4. Indenização recíproca (hold harmless).** Cada Parte manterá a outra indene de reclamações, autuações e condenações decorrentes exclusivamente de atos, omissões ou descumprimentos de sua própria responsabilidade, incluindo demandas trabalhistas de seus empregados/prepostos e sanções regulatórias próprias, com direito de regresso e denunciação da lide.

**16.5. Força maior e caso fortuito.** Nenhuma Parte responde por inadimplemento decorrente de força maior ou caso fortuito (art. 393 do Código Civil): calamidades, fenômenos climáticos extremos, bloqueios de vias, greves gerais, atos de autoridade, apagões, indisponibilidade de terceiros essenciais. A Parte afetada comunicará o evento e mitigará os efeitos; persistindo por mais de **[30]** dias, faculta-se a rescisão sem penalidade.

---

## Cláusula 17ª — Penalidades e Níveis de Serviço (SLA Penalties)

**17.1.** O descumprimento de obrigações contratuais sujeita a CONTRATADA, sem prejuízo da indenização por perdas e danos, às seguintes penalidades (a calibrar no Anexo I):

| Infração | Penalidade de referência |
|---|---|
| Coleta não realizada na janela | **[R$ ___]** por ocorrência ou isenção do frete correspondente |
| Entrega fora do prazo SLA (por Encomenda) | Desconto de **[__%]** a **[100%]** do frete daquela Ordem |
| OTD mensal abaixo da meta | Multa de **[__%]** sobre o faturamento do mês |
| Extravio não indenizado no prazo | Indenização + multa de **[__%]** ao mês sobre o valor devido |
| POD ausente/insuficiente | Frete não devido + tratamento como não entrega |
| Evento de rastreio não atualizado | **[R$ ___]** por Encomenda / mês, acima do limite tolerado |
| Incidente de dados por culpa da CONTRATADA | Ressarcimento integral + penalidades da LGPD repassadas |
| Transporte de item proibido por negligência | Rescisão + indenização |

**17.2.** As multas são independentes entre si e cumuláveis com a obrigação de indenizar e com a rescisão motivada. A aplicação observará **contraditório prévio** de **[10]** dias, com memória de cálculo.

**17.3.** As penalidades pecuniárias poderão ser compensadas com créditos da CONTRATADA (glosa), na forma da Cláusula 8.6.

---

## Cláusula 18ª — Vigência, Rescisão e Efeitos

**18.1. Vigência.** Este Contrato vigora por **[12 (doze) meses]** a contar de **16 de julho de 2026**, renovável automaticamente por iguais períodos, salvo denúncia por qualquer Parte com aviso prévio de **[30]** dias.

**18.2. Resilição imotivada.** Qualquer Parte poderá resilir sem justa causa, mediante aviso prévio de **[60]** dias, honradas as Ordens de Transporte já geradas/em curso e os fretes devidos.

**18.3. Rescisão motivada (resolução).** Faculta-se a rescisão imediata, independentemente de aviso, em caso de:
1. descumprimento material de SLA (Cláusula 7.5) não sanado em **[10]** dias após notificação;
2. avarias/extravios recorrentes acima do tolerado ou não indenizados;
3. violação de sigilo ou de proteção de dados do destinatário;
4. perda/suspensão de habilitação regulatória (RNTRC, credenciamento postal, apólices);
5. violação de normas anticorrupção, trabalhistas graves ou trabalho análogo à escravidão;
6. falência, recuperação judicial que inviabilize a operação, ou insolvência;
7. cessão do Contrato sem anuência (Cláusula 22ª).

**18.4. Efeitos da rescisão.** Extinto o Contrato, a CONTRATADA:
1. concluirá ou devolverá com segurança as Encomendas em trânsito;
2. entregará todos os POD e eventos de rastreio pendentes;
3. **eliminará ou devolverá** os dados pessoais do destinatário, salvo retenção legal (Cláusula 20ª);
4. prestará contas de fretes e indenizações pendentes.

**18.5. Sobrevivência.** Sobrevivem à extinção as cláusulas de confidencialidade, proteção de dados, responsabilidade/indenização, POD/retenção, foro e as obrigações por sua natureza perenes.

---

## Cláusula 19ª — Confidencialidade

**19.1.** As Partes obrigam-se a manter sigilo sobre informações confidenciais a que tiverem acesso — dados de destinatários, tabelas de frete, volumes, credenciais de API, dados operacionais e comerciais —, usando-as apenas para executar este Contrato, por prazo de **[5]** anos após a extinção.

**19.2.** Não são confidenciais informações públicas, de conhecimento prévio lícito ou exigidas por autoridade competente, hipótese em que a Parte comunicará a outra, quando legalmente possível.

**19.3.** Dados pessoais recebem, além da confidencialidade, a proteção reforçada das Cláusulas 12ª e 13ª e do DPA.

---

## Cláusula 20ª — Retenção e Eliminação de Dados e Documentos

**20.1.** A CONTRATADA reterá POD, CT-e e registros de transporte pelos prazos legais (fiscal/prescricional) e por, no mínimo, **[5]** anos, para instruir contestações e defesas.

**20.2.** Encerrado o tratamento e vencidos os prazos legais de guarda, os dados pessoais do destinatário serão **eliminados** de forma segura e irreversível, ou anonimizados, comunicando-se a CONTRATANTE, ressalvadas as hipóteses do art. 16 da LGPD (obrigação legal, exercício de direitos em processo).

---

## Cláusula 21ª — Propriedade Intelectual e Marca

**21.1.** Cada Parte mantém a titularidade de suas marcas, sistemas, software, layouts de etiqueta e APIs. A integração não transfere propriedade intelectual.

**21.2.** A CONTRATADA poderá usar a marca **[NOME FANTASIA: GLOP]** e vice-versa apenas para a execução operacional (etiquetas, portais de rastreio, materiais de entrega), vedado uso publicitário sem autorização escrita.

**21.3.** Dados agregados e anonimizados de desempenho logístico gerados pela Plataforma pertencem à CONTRATANTE, que poderá usá-los para BI e melhoria de serviço, sem reidentificação.

---

## Cláusula 22ª — Disposições Gerais

**22.1. Cessão.** Nenhuma Parte cederá este Contrato sem anuência escrita da outra, salvo reorganização societária com manutenção das garantias.

**22.2. Independência das cláusulas.** A nulidade de uma cláusula não contamina as demais, que permanecem válidas.

**22.3. Tolerância.** A tolerância a descumprimento não implica novação nem renúncia de direitos.

**22.4. Notificações.** As comunicações serão feitas por escrito, aos endereços/e-mails das Partes (para dados: **lemoncapsencapsulados@gmail.com**; Encarregado: **a ser designado pela administração**), presumindo-se recebidas em **[2]** dias úteis do envio.

**22.5. Anexos.** Integram este Contrato: **Anexo I — SLA e Penalidades**; **Anexo II — Tabela de Frete, Seguro e Tetos de Indenização**; **Anexo III — Especificação Técnica de Integração (API, PPN/SRO, POD)**; **DPA — Acordo de Tratamento de Dados**; e, se Correios, o **contrato/cartões ECT**.

**22.6. Integralidade.** Este Contrato e seus Anexos representam o acordo integral entre as Partes, prevalecendo sobre entendimentos anteriores; alterações somente por aditivo escrito.

---

## Cláusula 23ª — Foro e Legislação Aplicável

**23.1.** Este Contrato rege-se pelas leis da República Federativa do Brasil, em especial o Código Civil (contrato de transporte), a LGPD, o CDC (nas relações de consumo subjacentes), a Lei nº 11.442/2007, a regulação da ANTT e a legislação postal.

**23.2.** As Partes elegem o foro da comarca de **Comarca de Cuiabá/MT** para dirimir controvérsias, com renúncia a qualquer outro, ressalvada a competência de foro protetivo do consumidor quando a lide envolver o destinatário na condição de consumidor.

**23.3.** Faculta-se às Partes, previamente à via judicial, tentativa de composição por mediação/arbitragem, conforme **[cláusula compromissória a definir]**, sem prejuízo de medidas de urgência.

E, por estarem de acordo, as Partes assinam o presente instrumento.

**[LOCAL], 16 de julho de 2026.**

_______________________________________
**[CONTRATANTE]** — LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA / [NOME FANTASIA: GLOP]

_______________________________________
**[CONTRATADA]** — [RAZÃO SOCIAL DA TRANSPORTADORA]

**Testemunhas:**
1. Nome: __________________ CPF: __________________
2. Nome: __________________ CPF: __________________

---

## Engenharia Jurídica & Governança

### (a) Fundamentação das Cláusulas (lei/norma que embasa)

| Cláusula | Fundamento legal/normativo |
|---|---|
| Objeto, custódia, transporte de coisas | Código Civil, arts. 730 e 749 a 756 (contrato de transporte) |
| Responsabilidade objetiva do transportador por avaria/extravio | CC arts. 749–750; jurisprudência consolidada |
| Relação de consumo subjacente e regresso | CDC (Lei nº 8.078/1990), arts. 12, 14, 18 e 25 |
| Transporte rodoviário de cargas por terceiros / RNTRC | Lei nº 11.442/2007; Resolução ANTT nº 5.867/2019 |
| Pisos mínimos de frete | Lei nº 13.703/2018 e Resoluções ANTT |
| Jornada do motorista | Lei nº 13.103/2015 |
| Serviço postal (Correios) | Lei nº 6.538/1978; regulação ANATEL/MCom |
| Proteção de dados do destinatário (Operador/Suboperador) | LGPD (Lei nº 13.709/2018), arts. 5º, 7º, 16, 33–39, 46–50 |
| Incidentes de segurança | LGPD art. 48; Resoluções ANPD |
| Documentos fiscais de transporte (CT-e/MDF-e) | Legislação tributária (ICMS-transporte, Ajuste SINIEF) |
| Anticorrupção e cadeia responsável | Lei nº 12.846/2013 |
| Força maior/caso fortuito | CC art. 393 |
| Foro e legislação | CC; CDC (foro protetivo); CPC |

### (b) Riscos Mitigados

1. **Extravio/avaria sem cobertura** — mitigado por responsabilidade objetiva, seguro obrigatório (RCTR-C/RCF-DC) e tetos com base em valor declarado/NF-e.
2. **Atraso e má qualidade** — mitigado por SLA mensurável (OTD, coleta, 1ª tentativa) e penalidades/glosas.
3. **Não comprovação de entrega (chargeback/consumidor)** — mitigado por POD obrigatório, retenção mínima e presunção de não entrega na ausência.
4. **Vazamento de PII do destinatário** — mitigado por enquadramento como suboperador, minimização, sigilo, notificação de incidente em 24h e DPA.
5. **Exposição no portal público de rastreio** — mitigado por restrição a status neutro, sem PII.
6. **Irregularidade regulatória (RNTRC, piso, postal)** — mitigado por declarações, comprovação e rescisão motivada.
7. **Passivo trabalhista/solidariedade** — mitigado por cláusula de independência e hold harmless.
8. **Uso indevido de credenciais de API** — mitigado por armazenamento write-only e trilha de auditoria.
9. **Subcontratação descontrolada** — mitigada por responsabilidade solidária e flow-down de obrigações.

### (c) Checklist de Implementação

- [ ] Preencher todos os placeholders entre colchetes (partes, CNPJ, endereços, DPO, comarca, datas).
- [ ] Anexar e calibrar Anexo I (SLA/penalidades) e Anexo II (frete/seguro/tetos).
- [ ] Coletar e validar RNTRC/ANTT e apólices RCTR-C/RCF-DC vigentes.
- [ ] Vincular o DPA (`dpa.md`) e checar coerência com ROPA/RIPD (`ropa-ripd.md`).
- [ ] Definir layout do POD e prazos de disponibilização por API.
- [ ] Configurar filtro de PII no portal público de rastreio (só status neutro).
- [ ] Testar integração PPN (pré-postagem) e SRO (eventos) em homologação.
- [ ] Definir fluxo de notificação de incidente (24h) e contatos do Encarregado.
- [ ] Validar cláusulas fiscais (CT-e/MDF-e) com a contabilidade.
- [ ] Revisão final por advogado(a) habilitado(a).

### (d) Matriz RACI

| Atividade | GLOP/Plataforma | Transportadora | Cliente/Embarcante (Controlador) | DPO/Encarregado |
|---|---|---|---|---|
| Geração da Ordem/etiqueta (PPN) | **R** | C | A | I |
| Coleta e custódia | I | **R/A** | I | — |
| Cumprimento de SLA de entrega | C | **R/A** | I | — |
| Fornecimento de POD | A | **R** | I | I |
| Notificação de rastreio ao comprador | **R/A** | C | I | I |
| Indenização por avaria/extravio | C | **R/A** | I | — |
| Tratamento de dados do destinatário | **A** (Operador) | **R** (Suboperador) | **A** (Controlador) | C |
| Notificação de incidente de dados | A | **R** | A | **C/A** |
| Conformidade regulatória (RNTRC/postal) | I | **R/A** | I | — |
| Auditoria de segurança/dados | **R/A** | C | I | C |

(R = Responsável executa; A = Aprova/presta contas; C = Consultado; I = Informado.)

### (e) Plano de Revisão

- **Trimestral:** indicadores de SLA, avaria/extravio, tempestividade de POD e rastreio.
- **Semestral:** revisão de tabelas de frete, tetos de seguro e penalidades.
- **Anual:** revisão jurídica integral (LGPD, ANTT, postal, tributário) e renovação de apólices/habilitações.
- **Sob evento:** alteração legal/regulatória, incidente de dados relevante, mudança de sub-operador, mudança de integração de API ou incorporação de nova transportadora/última milha.

### (f) Controle de Versão

| Versão | Data | Autor | Alterações | Status |
|---|---|---|---|---|
| 0.1 | 16 de julho de 2026 | Chief Legal AI (IA) | Minuta inicial — estrutura completa, cláusulas 1ª a 23ª e governança | Minuta — pendente revisão jurídica |
| 1.0 | 16 de julho de 2026 | [ADVOGADO(A) RESPONSÁVEL] | Validação, preenchimento de placeholders e Anexos | Pendente |
