> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# CONTRATO DE PRESTAÇÃO DE SERVIÇOS DE OPERAÇÃO LOGÍSTICA (3PL / FULFILLMENT)

**Armazenagem, Gestão de Estoque, Picking/Packing, Expedição, Inventário, Responsabilidade sobre a Mercadoria, KPIs/SLA, Seguro e Proteção de Dados**

Instrumento particular de prestação de serviços de operação logística integrada (*third-party logistics* — 3PL), celebrado na plataforma **[NOME FANTASIA: GLOP]** (Global Logistics Platform), que se regerá pelas cláusulas e condições a seguir, com fundamento no Código Civil (Lei nº 10.406/2002), no Código de Defesa do Consumidor (Lei nº 8.078/1990), na Lei Geral de Proteção de Dados (Lei nº 13.709/2018 — LGPD), na Lei do Marco Civil da Internet (Lei nº 12.965/2014) e demais normas aplicáveis.

---

## PREÂMBULO

Este Contrato disciplina a relação entre o tomador dos serviços logísticos e o operador logístico que opera por meio da plataforma **GLOP**, um SaaS de logística/ERP voltado a operações de dropshipping e de infoprodutos no Brasil. A plataforma integra, de ponta a ponta, o fluxo `Ingestão de Pedido → Conferência Fiscal → Estoque/Lotes → Picking/Packing → Expedição → Rastreio → Pós-venda`, com arquitetura multi-tenant (Tenant → Company → Branch → Membership), segregação lógica por *Row Level Security* (RLS), controle de acesso baseado em papéis (RBAC), *soft delete* e trilha de auditoria por *triggers* de banco.

As Partes reconhecem que a operação envolve tratamento de dados pessoais de terceiros (compradores/consumidores finais), razão pela qual o presente Contrato é integrado, de forma indissociável, pelo **Acordo de Tratamento de Dados (DPA)** referido na Cláusula Décima Sexta.

---

## CLÁUSULA PRIMEIRA — DAS PARTES (QUALIFICAÇÃO)

### 1.1. CONTRATADA (Operador Logístico)

**LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA**, pessoa jurídica de direito privado, inscrita no CNPJ sob o nº **55.836.075/0001-07**, com sede em **Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190**, neste ato representada na forma de seu contrato/estatuto social, doravante denominada **CONTRATADA**, **OPERADOR LOGÍSTICO** ou simplesmente **OPERADOR**, operadora e/ou usuária da plataforma **[NOME FANTASIA: GLOP]**.

### 1.2. CONTRATANTE (Tomador dos Serviços)

**[CONTRATANTE]**, pessoa **[física/jurídica]**, inscrita no **[CPF/CNPJ]** sob o nº **55.836.075/0001-07**, com sede/endereço em **Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190**, neste ato representada na forma de seus atos constitutivos, doravante denominada **CONTRATANTE**, **EMBARCADOR** ou **DEPOSITANTE**, na qualidade de produtor, lojista, coprodutor ou anunciante de produtos físicos e/ou infoprodutos.

### 1.3. Denominação conjunta

CONTRATADA e CONTRATANTE, quando referidas em conjunto, denominam-se **Partes** e, isoladamente, **[PARTE]**.

### 1.4. Declarações de capacidade

Cada **[PARTE]** declara que: (i) possui plena capacidade jurídica e legitimidade para celebrar este Contrato; (ii) seus signatários detêm poderes de representação suficientes; (iii) o objeto contratado é lícito, possível e determinado; e (iv) não há impedimento legal, contratual ou regulatório à assunção das obrigações aqui previstas.

---

## CLÁUSULA SEGUNDA — DAS DEFINIÇÕES

Para os fins deste Contrato, os termos abaixo, no singular ou plural, terão os seguintes significados:

| Termo | Definição |
|---|---|
| **3PL / Operação Logística** | Prestação terceirizada e integrada de armazenagem, gestão de estoque, manuseio, picking/packing, expedição, inventário e serviços correlatos. |
| **Plataforma GLOP** | SaaS de logística/ERP (Next.js + Supabase/PostgreSQL, RLS multi-tenant) por meio do qual a operação é executada, monitorada e auditada. |
| **Mercadoria / Bens** | Produtos físicos de titularidade ou responsabilidade da CONTRATANTE, custodiados pela CONTRATADA. |
| **SKU** | Unidade de manutenção de estoque; menor unidade identificável de produto (código, lote, validade, dimensão, peso). |
| **Lote** | Conjunto de itens com origem/fabricação/validade comuns, rastreável na plataforma. |
| **Pedido** | Ordem de venda ingerida na plataforma via API (Monetizze, Hotmart, Kiwify) ou e-commerce (Shopify, WooCommerce, Nuvemshop, Mercado Livre). |
| **Picking** | Separação física dos itens do pedido no endereço de estoque. |
| **Packing** | Conferência, embalagem, etiquetagem e preparação da expedição. |
| **Expedição** | Emissão de pré-postagem (Correios PPN), coleta/postagem e liberação ao transportador. |
| **PPN** | Pré-Postagem Nacional dos Correios (geração de etiqueta e objeto). |
| **SRO** | Sistema de Rastreamento de Objetos dos Correios (eventos de rastreio). |
| **Inventário** | Contagem física periódica ou cíclica para conciliação com o saldo lógico. |
| **KPI** | Indicador-chave de desempenho (Cláusula Décima Terceira). |
| **SLA** | Acordo de Nível de Serviço; metas quantitativas de prazo, acuracidade e disponibilidade. |
| **PII / Dados Pessoais** | Dados do comprador/consumidor final: nome, CPF/CNPJ, e-mail, telefone, endereço, itens, valor. |
| **DPA** | Acordo de Tratamento de Dados anexo, que rege o tratamento de dados pessoais sob a LGPD. |
| **Sub-operadores** | Terceiros de infraestrutura e integração: Supabase e Netlify (infra), VHSYS (NF-e), Correios (transporte), gateways (Monetizze/AppMax/Hotmart/Kiwify), provedores de WhatsApp/e-mail. |
| **Portal de Rastreio** | Página pública, sem login, que expõe apenas status neutro de entrega. |
| **Divergência** | Diferença entre saldo físico e saldo lógico, ou entre pedido e item expedido. |
| **Avaria / Sinistro** | Dano, perda, extravio, subtração ou deterioração da Mercadoria. |
| **Dia Útil** | Dia de expediente bancário na praça da sede da CONTRATADA, exceto sábados, domingos e feriados. |

---

## CLÁUSULA TERCEIRA — DO OBJETO

3.1. O objeto deste Contrato é a prestação, pela CONTRATADA, dos **serviços de operação logística integrada (3PL/fulfillment)** em favor da CONTRATANTE, compreendendo, de forma não exaustiva:

- a) **Recebimento e conferência** de mercadorias (Cláusula Quarta);
- b) **Armazenagem e custódia** em ambiente controlado (Cláusula Quinta);
- c) **Gestão de estoque, lotes e validades** com espelhamento na plataforma GLOP (Cláusula Sexta);
- d) **Picking e packing** por pedido, com conferência e etiquetagem (Cláusula Sétima);
- e) **Expedição** via Correios (pré-postagem PPN) e/ou demais transportadores, com rastreio SRO e notificação ao comprador (Cláusula Oitava);
- f) **Inventário** cíclico e geral, com conciliação e relatório (Cláusula Nona);
- g) **Gestão de divergências, avarias, devoluções e logística reversa** (Cláusulas Décima e Décima Segunda);
- h) **Emissão/gestão de documentos fiscais** de acompanhamento, quando contratado, via integração VHSYS (NF-e).

3.2. Os serviços são executados, registrados e auditados por meio da plataforma **GLOP**, com rastreabilidade por SKU, lote e pedido, e trilha de auditoria imutável por *triggers* de banco de dados.

3.3. **Do que NÃO integra o objeto.** Salvo previsão em Termo de Serviço específico ou Aditivo, não integram o objeto: (i) a comercialização ou marketing dos produtos; (ii) o atendimento SAC ao consumidor final da CONTRATANTE; (iii) a responsabilidade fiscal principal (emissão em nome próprio de tributos devidos pela CONTRATANTE); (iv) o transporte próprio com frota da CONTRATADA (o transporte é executado por transportador terceiro — Correios ou congênere); e (v) o processamento de infoprodutos (entrega digital), que não demanda operação física.

3.4. **Autonomia e forma da execução.** A CONTRATADA executa os serviços com autonomia técnica, meios próprios, organização empresarial e pessoal subordinado exclusivamente a si, inexistindo qualquer vínculo empregatício, societário ou de agência entre as Partes ou entre a CONTRATANTE e os colaboradores da CONTRATADA.

---

## CLÁUSULA QUARTA — DO RECEBIMENTO E CONFERÊNCIA DE MERCADORIAS

4.1. A CONTRATANTE providenciará o envio das mercadorias ao endereço de recebimento da CONTRATADA, acompanhadas de **Nota Fiscal** hábil (NF-e de remessa para armazém/depósito) e, quando aplicável, de **romaneio/packing list**.

4.2. No recebimento, a CONTRATADA realizará **conferência quantitativa e qualitativa** (contagem, conferência de SKU, lote, validade e integridade da embalagem), registrando o resultado na plataforma GLOP e gerando comprovante de entrada.

4.3. **Prazo de conferência.** A conferência será concluída em até **[__] Dia(s) Útil(eis)** contados do recebimento físico. A ausência de manifestação de divergência nesse prazo presume a conformidade quantitativa da carga, ressalvados **vícios ocultos** e avarias não aparentes.

4.4. **Divergências no recebimento.** Constatada divergência (falta, sobra, avaria aparente, produto vencido, embalagem violada ou item não catalogado), a CONTRATADA registrará a ocorrência com evidências (foto/laudo) na plataforma e notificará a CONTRATANTE em até **[__] Dia(s) Útil(eis)**, abstendo-se de armazenar itens em desconformidade sanitária, de validade ou de identificação até deliberação da CONTRATANTE.

4.5. **Recusa de recebimento.** A CONTRATADA poderá recusar, motivadamente, o recebimento de mercadorias: (i) sem documentação fiscal idônea; (ii) que representem risco à saúde, à segurança ou ao patrimônio; (iii) ilícitas, perigosas, perecíveis fora das condições contratadas, ou que exijam licença/condições especiais não previstas; ou (iv) que excedam a capacidade contratada sem aviso prévio.

4.6. **Produtos vedados.** É vedado o envio, para custódia, de: armas, munições, explosivos, inflamáveis, produtos controlados sem autorização, substâncias entorpecentes, produtos falsificados/contrafeitos, itens que violem direitos de terceiros, animais vivos, valores/moeda, e produtos cuja comercialização seja proibida por lei. A CONTRATANTE responde integral e regressivamente por qualquer envio em desacordo.

---

## CLÁUSULA QUINTA — DA ARMAZENAGEM E CUSTÓDIA

5.1. A CONTRATADA armazenará as mercadorias em **ambiente adequado** ao tipo de produto, observando boas práticas de estocagem, segregação por SKU/lote/validade, controle de acesso físico e medidas razoáveis de prevenção a incêndio, alagamento, furto e infestação.

5.2. **Contrato de depósito.** A relação de guarda observa, no que couber, os artigos 627 a 652 do Código Civil (depósito), obrigando-se a CONTRATADA à custódia, conservação e restituição das mercadorias no estado em que recebidas, ressalvado o desgaste natural e as condições intrínsecas do produto.

5.3. **Endereçamento.** Cada item recebe endereço lógico e físico na plataforma GLOP, garantindo rastreabilidade FEFO/FIFO (primeiro que vence / primeiro que entra — primeiro que sai), conforme parametrização definida no **Anexo I — Termo de Serviço**.

5.4. **Propriedade das mercadorias.** As mercadorias custodiadas permanecem, a todo tempo, de **titularidade da CONTRATANTE**, não integram o patrimônio da CONTRATADA e não respondem por dívidas desta, ressalvado o direito de retenção previsto na Cláusula 17.

5.5. **Segregação de estoque.** O estoque da CONTRATANTE será logicamente segregado, na plataforma, por *tenant/company* (RLS), impedindo o acesso cruzado por outros tomadores. A segregação física dar-se-á conforme o **Anexo I**.

5.6. **Condições especiais.** Produtos com exigência de temperatura, umidade, validade curta, fracionamento ou manuseio especial somente serão custodiados mediante previsão expressa no **Anexo I**, com preço e SLA próprios.

---

## CLÁUSULA SEXTA — DA GESTÃO DE ESTOQUE, LOTES E VALIDADES

6.1. A CONTRATADA manterá o **saldo lógico** de estoque atualizado em tempo real na plataforma GLOP, refletindo entradas, saídas, reservas, bloqueios, transferências e ajustes, com rastreabilidade por SKU e lote.

6.2. **Reserva e alocação.** A ingestão de um Pedido (via API dos gateways/e-commerces) gera reserva automática do saldo, evitando *overselling*. Na indisponibilidade de saldo, a plataforma sinaliza *backorder*/ruptura para deliberação da CONTRATANTE.

6.3. **Controle de validade.** Para produtos com validade, a CONTRATADA adotará política FEFO e notificará a CONTRATANTE, com antecedência mínima de **[__] dias**, sobre lotes próximos ao vencimento, para decisão de escoamento, remanejo ou descarte.

6.4. **Estoque de segurança e reposição.** Os parâmetros de estoque mínimo, ponto de pedido e ruptura são definidos no **Anexo I**. A responsabilidade pela **decisão de reposição** e pelo abastecimento é da CONTRATANTE.

6.5. **Ajustes de estoque.** Todo ajuste (perda, quebra, vencimento, sinistro, reclassificação) é registrado com motivo, responsável e evidência na plataforma, sob *soft delete* e trilha de auditoria, sendo vedada a exclusão física de registros.

6.6. **Descarte.** O descarte de produtos vencidos, avariados ou impróprios dependerá de autorização prévia e escrita da CONTRATANTE, ressalvadas as hipóteses de risco iminente à saúde/segurança ou determinação de autoridade, observada a legislação ambiental e sanitária.

---

## CLÁUSULA SÉTIMA — DO PICKING E PACKING

7.1. A partir do Pedido ingerido e reservado, a CONTRATADA executará o **picking** (separação dos itens no endereço de estoque) e o **packing** (conferência, embalagem, proteção, etiquetagem e preparação para expedição).

7.2. **Conferência de saída (dupla checagem).** Antes do fechamento do volume, a CONTRATADA conferirá SKU, quantidade, lote e integridade contra o Pedido, mitigando erro de expedição. A conferência é registrada na plataforma e vincula-se ao Pedido e ao objeto de rastreio.

7.3. **Materiais de embalagem.** Salvo disposição em contrário no **Anexo I**, os insumos de embalagem (caixas, plástico bolha, fitas, etiquetas) serão fornecidos pela **[CONTRATANTE/CONTRATADA]**, com repasse de custo conforme a Cláusula Décima Quinta.

7.4. **Personalização.** Serviços de valor agregado (*kitting*, montagem de combos, brinde, encarte, embalagem personalizada, *unboxing* especial) constituem **serviços adicionais**, precificados à parte no **Anexo I**.

7.5. **Cut-off (corte diário).** Pedidos recebidos e liberados (aprovação de pagamento e conferência fiscal) até o horário de corte de **[__]h** em Dia Útil serão expedidos no mesmo dia; após esse horário, no Dia Útil seguinte, ressalvadas as metas de SLA da Cláusula Décima Terceira.

7.6. **Bloqueio à expedição.** A CONTRATADA não expedirá pedidos: (i) sem confirmação de pagamento pelo gateway; (ii) com suspeita fundada de fraude/chargeback; (iii) sem documento fiscal quando exigível; ou (iv) com dados de entrega inválidos/incompletos, notificando a CONTRATANTE para regularização.

---

## CLÁUSULA OITAVA — DA EXPEDIÇÃO, TRANSPORTE E RASTREIO

8.1. A expedição será realizada por meio de **pré-postagem Correios (PPN)** e/ou por transportador definido no **Anexo I**, com geração de etiqueta, número de objeto e vinculação ao Pedido na plataforma GLOP.

8.2. **Contratação do transporte.** O contrato de transporte é celebrado com o transportador (Correios ou congênere), sendo a **CONTRATADA responsável pela correta emissão da pré-postagem, tarifação e entrega ao transportador**, e o **transportador responsável pelo deslocamento e entrega ao destinatário**. A responsabilidade da CONTRATADA sobre a Mercadoria encerra-se com a **entrega/postagem comprovada ao transportador** (Cláusula Décima).

8.3. **Rastreio (SRO).** A plataforma capturará os eventos de rastreamento (SRO) e os disponibilizará à CONTRATANTE, mantendo o status atualizado por Pedido.

8.4. **Notificação ao comprador.** Mediante instrução da CONTRATANTE (na qualidade de Controladora dos dados do comprador — Cláusula Décima Sexta), a CONTRATADA, por meio da plataforma, enviará **notificações transacionais** ao comprador por **e-mail e/ou WhatsApp** (postagem, trânsito, saiu para entrega, entregue, tentativa frustrada), restringindo-se a conteúdo transacional-logístico.

8.5. **Portal público de rastreio.** A plataforma disponibiliza portal de rastreio **sem login**, que expõe **apenas status neutro** de entrega, sem exibir dados pessoais sensíveis, endereço completo ou informações que permitam identificação indevida do destinatário, em observância ao princípio da minimização (LGPD, art. 6º, III).

8.6. **Documento fiscal de transporte.** Quando exigível, a NF-e/documento de acompanhamento será gerado via integração **VHSYS**, sob responsabilidade fiscal da CONTRATANTE, cabendo à CONTRATADA a correta associação do documento ao volume expedido.

8.7. **Extravio/atraso do transportador.** Extravios, atrasos e avarias ocorridos **após** a postagem ao transportador são de responsabilidade do transportador, cabendo à CONTRATADA prestar apoio à abertura de reclamação/indenização (PAC/SEDEX/reclamação SRO), sem que isso importe assunção de responsabilidade própria, ressalvado dolo ou culpa comprovada da CONTRATADA na emissão/preparação.

---

## CLÁUSULA NONA — DO INVENTÁRIO

9.1. A CONTRATADA realizará **inventário cíclico** (contagens rotativas por classe/curva ABC) e **inventário geral** com periodicidade **[mensal/trimestral/semestral]**, conforme o **Anexo I**, conciliando o saldo físico ao saldo lógico da plataforma.

9.2. **Acuracidade de estoque.** A meta de acuracidade é de **[__]%** (Cláusula Décima Terceira). Divergências serão registradas, investigadas e tratadas com plano de ação, sob trilha de auditoria.

9.3. **Direito de auditoria da CONTRATANTE.** A CONTRATANTE poderá, mediante aviso prévio de **[__] Dia(s) Útil(eis)** e sem prejuízo à operação, acompanhar inventário e auditar os registros de estoque, presencialmente ou por meio dos relatórios da plataforma.

9.4. **Apuração de perdas.** As perdas apuradas em inventário serão classificadas em: (i) **perda normal** (quebra operacional dentro da tolerância do Anexo I — de risco compartilhado/ CONTRATANTE); e (ii) **perda anormal** por culpa da CONTRATADA (falha de custódia, furto interno, erro de manuseio — indenizável pela CONTRATADA nos termos da Cláusula Décima).

9.5. **Tolerância de quebra.** A tolerância de quebra/perda normal é de **[__]%** sobre o volume movimentado no período. Perdas acima desse limite, imputáveis à CONTRATADA, ensejam indenização conforme Cláusula Décima.

---

## CLÁUSULA DÉCIMA — DA RESPONSABILIDADE SOBRE A MERCADORIA

10.1. **Guarda e conservação.** Durante o período de custódia (do recebimento conferido até a postagem ao transportador), a CONTRATADA responde pela guarda e conservação das mercadorias, respondendo por perdas, avarias, extravios e subtrações decorrentes de **dolo ou culpa** (negligência, imprudência ou imperícia) sua ou de seus prepostos.

10.2. **Marco de transferência de risco.** O risco sobre a Mercadoria:
- a) transfere-se à CONTRATADA no momento do **recebimento com conferência concluída** (Cláusula Quarta); e
- b) cessa para a CONTRATADA no momento da **postagem/entrega comprovada ao transportador** (Cláusula Oitava), quando o risco passa ao transportador/comprador conforme a modalidade de venda.

10.3. **Excludentes de responsabilidade.** A CONTRATADA não responde por perdas ou avarias decorrentes de: (i) **caso fortuito ou força maior** (art. 393 do Código Civil); (ii) **vício intrínseco, natureza perecível ou defeito próprio** da mercadoria; (iii) embalagem inadequada de origem fornecida pela CONTRATANTE; (iv) informação incorreta de SKU, lote, validade, dimensão ou peso prestada pela CONTRATANTE; (v) fato de terceiro (inclusive transportador) após a postagem; ou (vi) determinação de autoridade competente.

10.4. **Base de indenização.** A indenização por perda/avaria imputável à CONTRATADA terá por base o **custo de aquisição/reposição** da mercadoria comprovado pela CONTRATANTE (nota fiscal de entrada), **excluídos** lucros cessantes, margem de revenda, valor de venda ao consumidor e danos indiretos, ressalvado dolo, observado o limite global da Cláusula Décima Oitava e a cobertura de seguro da Cláusula Décima Primeira.

10.5. **Dever de mitigação.** Ocorrido sinistro, a CONTRATADA comunicará a CONTRATANTE em até **[__] hora(s)**, registrará a ocorrência com evidências na plataforma, adotará medidas de contenção e, quando cabível, acionará o seguro e as autoridades (boletim de ocorrência).

10.6. **Responsabilidade da CONTRATANTE.** A CONTRATANTE responde por: (i) veracidade e completude dos dados de produto e do comprador; (ii) licitude e regularidade fiscal das mercadorias; (iii) fornecimento de embalagem/insumo quando a seu cargo; (iv) instruções de expedição e de notificação ao comprador; e (v) obrigações perante o consumidor final decorrentes da relação de consumo, da qual a CONTRATADA não é parte.

---

## CLÁUSULA DÉCIMA PRIMEIRA — DO SEGURO

11.1. A CONTRATADA manterá vigente, às suas expensas, apólice de **seguro de responsabilidade civil do operador de transporte/armazém e/ou seguro de armazenagem (incêndio, roubo, avaria)** cobrindo as mercadorias sob sua custódia, no limite mínimo de **R$ [__]** por evento e **R$ [__]** por período de vigência.

11.2. **Comprovação.** A CONTRATADA apresentará à CONTRATANTE, quando solicitado, cópia da apólice e comprovante de pagamento de prêmio, mantendo a cobertura ativa durante toda a vigência contratual.

11.3. **Seguro de transporte.** O seguro do transporte (pós-postagem) observa a cobertura do transportador (Correios/congênere) e/ou seguro de transporte contratado conforme o **Anexo I**, cabendo à CONTRATANTE avaliar a contratação de cobertura adicional (valor declarado) para bens de alto valor.

11.4. **Franquia e limites.** Valores de franquia, sublimites e exclusões da apólice constam do **Anexo II** e são de conhecimento das Partes. A indenização securitária não exime a Parte responsável do complemento eventualmente devido, respeitados os limites da Cláusula Décima Oitava.

11.5. **Bens de alto valor.** Mercadorias cujo valor unitário exceda **R$ [__]** somente serão custodiadas mediante comunicação prévia e eventual ajuste de cobertura/prêmio, sob pena de a indenização limitar-se ao teto da apólice padrão.

---

## CLÁUSULA DÉCIMA SEGUNDA — DAS DEVOLUÇÕES E LOGÍSTICA REVERSA

12.1. A CONTRATADA processará devoluções (arrependimento — art. 49 do CDC —, troca, recusa, endereço não localizado, sinistro) mediante recebimento do objeto reverso, **conferência** de integridade, registro na plataforma e reintegração ao estoque ou segregação (avariado/descarte), conforme instrução da CONTRATANTE.

12.2. **Prazo de tratamento.** A conferência do reverso ocorrerá em até **[__] Dia(s) Útil(eis)** do recebimento, com atualização do status na plataforma e comunicação à CONTRATANTE.

12.3. **Reintegração condicionada.** Somente serão reintegrados ao estoque itens íntegros, dentro da validade e revendáveis. Itens avariados/vencidos serão segregados para decisão da CONTRATANTE.

12.4. **Custos.** Os custos de logística reversa (frete reverso, manuseio, reembalagem) observam a tabela do **Anexo I**, ressalvadas as hipóteses de responsabilidade do consumidor/transportador.

---

## CLÁUSULA DÉCIMA TERCEIRA — DOS KPIs E NÍVEIS DE SERVIÇO (SLA)

13.1. A CONTRATADA obriga-se a observar os seguintes indicadores mínimos, apurados mensalmente na plataforma GLOP:

| Indicador (KPI) | Definição | Meta (SLA) |
|---|---|---|
| **Prazo de expedição (*lead time* interno)** | % de pedidos elegíveis expedidos até o cut-off ou D+1 | ≥ **[__]%** |
| **Acuracidade de picking** | % de pedidos expedidos sem erro de item/quantidade | ≥ **[99,__]%** |
| **Acuracidade de estoque (inventário)** | Aderência saldo físico × lógico | ≥ **[__]%** |
| **Prazo de conferência de recebimento** | Recebimento processado dentro do prazo da Cláusula 4.3 | ≥ **[__]%** |
| **Índice de avaria interna** | % de itens avariados sob custódia | ≤ **[__]%** |
| **Tratamento de reverso** | Reverso conferido no prazo da Cláusula 12.2 | ≥ **[__]%** |
| **Disponibilidade da operação/plataforma** | *Uptime* da operação logística mensal | ≥ **[__]%** |
| **Tempo de resposta a incidentes** | Comunicação de sinistro/divergência à CONTRATANTE | ≤ **[__]h** |

13.2. **Apuração e relatório.** Os KPIs serão apurados por relatórios da plataforma (RPC/materialized views), com fechamento até o **[__]º Dia Útil** do mês subsequente, disponibilizados à CONTRATANTE.

13.3. **Descumprimento de SLA.** O descumprimento reiterado de metas enseja: (i) plano de ação corretiva em até **[__] Dia(s) Útil(eis)**; (ii) aplicação de *service credits*/multa (Cláusula Décima Nona); e (iii) em caso de descumprimento grave e reincidente, rescisão motivada (Cláusula Décima Sétima).

13.4. **Governança.** As Partes realizarão reunião de acompanhamento **[mensal/trimestral]** (comitê operacional) para revisão de KPIs, incidentes, capacidade e plano de melhoria contínua.

13.5. **Exclusões de SLA.** Não computam para efeito de SLA os eventos de força maior, indisponibilidade dos Sub-operadores (Supabase, Netlify, Correios, gateways, VHSYS), falha de dados imputável à CONTRATANTE e janelas de manutenção programada previamente comunicadas.

---

## CLÁUSULA DÉCIMA QUARTA — DAS OBRIGAÇÕES DAS PARTES

### 14.1. Obrigações da CONTRATADA

- a) Executar os serviços com diligência, boa técnica e observância dos SLAs;
- b) Custodiar, conservar e restituir as mercadorias, mantendo segregação lógica (RLS) e física adequada;
- c) Manter os registros de entrada, estoque, expedição e inventário atualizados e auditáveis na plataforma GLOP;
- d) Comunicar tempestivamente divergências, avarias, sinistros e rupturas;
- e) Manter seguro vigente (Cláusula Décima Primeira) e cumprir a legislação trabalhista, previdenciária, sanitária, ambiental e de segurança do trabalho relativa a seus colaboradores e instalações;
- f) Tratar dados pessoais estritamente conforme instruções da CONTRATANTE e o DPA (Cláusula Décima Sexta);
- g) Adotar medidas técnicas e administrativas de segurança da informação (RLS, RBAC, credenciais *write-only*, *soft delete*, auditoria por *triggers*);
- h) Não expedir pedidos em desconformidade (fraude, sem pagamento, dados inválidos).

### 14.2. Obrigações da CONTRATANTE

- a) Fornecer mercadorias lícitas, regulares e acompanhadas de documentação fiscal idônea;
- b) Prestar informações completas e verídicas de produto (SKU, lote, validade, peso, dimensão) e de expedição;
- c) Manter abastecimento/reposição de estoque e deliberar sobre rupturas, vencimentos e descartes;
- d) Efetuar os pagamentos nos prazos da Cláusula Décima Quinta;
- e) Na qualidade de **Controladora** dos dados do comprador, definir as finalidades e instruções de tratamento, obter bases legais e responder às titulares perante os consumidores;
- f) Responder por tributos, obrigações fiscais e pela relação de consumo com o comprador final;
- g) Não utilizar a operação para fins ilícitos, fraudulentos ou vedados por lei.

### 14.3. Obrigações comuns

- a) Boa-fé objetiva, cooperação e transparência (arts. 421 e 422 do Código Civil);
- b) Sigilo e proteção de dados;
- c) Cumprimento das leis anticorrupção (Lei nº 12.846/2013) e de prevenção à lavagem de dinheiro (Lei nº 9.613/1998);
- d) Manutenção de regularidade fiscal e trabalhista, mediante apresentação de certidões quando solicitadas.

---

## CLÁUSULA DÉCIMA QUINTA — DO PREÇO E DAS CONDIÇÕES DE PAGAMENTO

15.1. Pela prestação dos serviços, a CONTRATANTE pagará à CONTRATADA a remuneração constante do **Anexo I — Tabela de Preços**, que poderá compreender, isolada ou cumulativamente:

| Componente | Base de cobrança |
|---|---|
| **Setup/implantação** | Valor único de *onboarding* e cadastro |
| **Armazenagem** | Por posição-palete/m²/SKU/volume ocupado, por período |
| **Recebimento** | Por item/volume/nota conferida |
| **Picking/Packing** | Por pedido e/ou por item separado |
| **Expedição** | Por volume expedido + repasse de frete (Correios/transportador) |
| **Insumos de embalagem** | Por consumo, quando a cargo da CONTRATADA |
| **Serviços de valor agregado** | *Kitting*, brinde, encarte, personalização |
| **Logística reversa** | Por reverso conferido/reintegrado |
| **Inventário extraordinário** | Por evento solicitado pela CONTRATANTE |

15.2. **Faturamento.** O faturamento é **[mensal/quinzenal]**, com fechamento no dia **[__]** e vencimento em **[__]** dias, mediante nota fiscal de serviço e relatório analítico extraído da plataforma.

15.3. **Repasses de terceiros.** Fretes (Correios/transportador), tributos e custos de Sub-operadores diretamente atribuíveis à operação da CONTRATANTE serão repassados com a devida comprovação.

15.4. **Reajuste.** Os preços serão reajustados anualmente pela variação do **[IPCA/IGP-M]** acumulado, ou por índice que o substitua, a contar da data-base **16 de julho de 2026**.

15.5. **Inadimplemento.** O atraso no pagamento sujeita a CONTRATANTE a: (i) **multa de 2%** (art. 52, §1º, do CDC quando aplicável); (ii) **juros de mora de 1% ao mês**; e (iii) **correção monetária** pelo índice da Cláusula 15.4, sem prejuízo do direito de retenção (Cláusula 17.6) e da suspensão dos serviços após notificação.

15.6. **Suspensão por inadimplência.** Persistindo a inadimplência por mais de **[__] dias**, a CONTRATADA poderá suspender novos processamentos (recebimento, picking, expedição), preservada a custódia das mercadorias e a segurança dos dados, mediante notificação prévia.

---

## CLÁUSULA DÉCIMA SEXTA — DA PROTEÇÃO DE DADOS PESSOAIS (LGPD)

16.1. **Dupla natureza.** As Partes reconhecem que, no âmbito da operação via plataforma GLOP, o tratamento de dados pessoais assume dupla natureza:
- a) **Dados do comprador/consumidor final** (nome, CPF/CNPJ, e-mail, telefone, endereço, itens, valor): a **CONTRATANTE atua como CONTROLADORA** (define finalidades e meios da venda) e a **CONTRATADA/GLOP atua como OPERADORA**, tratando tais dados **exclusivamente** para executar a operação logística (ingestão de pedido, picking/packing, expedição, rastreio SRO e notificação transacional ao comprador por e-mail/WhatsApp);
- b) **Dados dos próprios usuários/colaboradores** de cada Parte (contas, credenciais, logs de acesso): cada Parte atua como **CONTROLADORA** dos dados de seus respectivos usuários.

16.2. **Remissão ao DPA.** O tratamento de dados pessoais é regido, de forma integrada e indissociável, pelo **Acordo de Tratamento de Dados (DPA)** anexo a este Contrato, que prevalece em matéria de proteção de dados. Na ausência de DPA formalizado, aplicam-se subsidiariamente as disposições desta Cláusula.

16.3. **Deveres da CONTRATADA/Operadora.** A CONTRATADA obriga-se a: (i) tratar dados **somente conforme instruções documentadas** da Controladora e as finalidades logísticas; (ii) aplicar medidas de segurança compatíveis (RLS multi-tenant, RBAC/`has_permission`, credenciais de API *write-only*, *soft delete*, trilha de auditoria por *triggers*, criptografia em trânsito e repouso conforme o provedor); (iii) observar o princípio da **minimização** (ex.: portal público de rastreio expõe apenas status neutro); (iv) **não** utilizar os dados para finalidades próprias, marketing ou enriquecimento; e (v) manter registro das operações de tratamento (art. 37 da LGPD).

16.4. **Sub-operadores.** A CONTRATANTE autoriza, de forma geral e prévia, a subcontratação dos **Sub-operadores** necessários à operação — **Supabase** e **Netlify** (infraestrutura/hospedagem), **VHSYS** (NF-e), **Correios** (transporte/rastreio), **gateways** (Monetizze, AppMax, Hotmart, Kiwify) e provedores de **WhatsApp/e-mail** —, obrigando-se a CONTRATADA a impor a estes deveres de proteção não inferiores aos deste Contrato e a comunicar a inclusão/substituição de Sub-operador relevante.

16.5. **Transferência internacional.** Havendo transferência internacional de dados (ex.: infraestrutura de nuvem hospedada no exterior), a CONTRATADA adotará garantias adequadas nos termos dos arts. 33 a 36 da LGPD (cláusulas-padrão, adequação ou outra base legal válida).

16.6. **Incidentes de segurança.** Em caso de incidente com dados pessoais, a CONTRATADA comunicará a CONTRATANTE (Controladora) em até **[__] horas** da ciência, com as informações do art. 48 da LGPD, apoiando a Controladora na comunicação à ANPD e às titulares quando exigível.

16.7. **Direitos das titulares.** A CONTRATADA auxiliará a Controladora no atendimento aos direitos das titulares (arts. 18 e 19 da LGPD — confirmação, acesso, correção, anonimização, portabilidade, eliminação), repassando à Controladora, sem cumprir diretamente, os pedidos recebidos, salvo instrução em contrário.

16.8. **Encarregado (DPO).** As comunicações relativas à proteção de dados serão dirigidas ao Encarregado da CONTRATADA, Sr(a). **a ser designado pela administração**, pelo canal **lemoncapsencapsulados@gmail.com**.

16.9. **Eliminação ao término.** Encerrado o Contrato, a CONTRATADA eliminará ou devolverá os dados pessoais tratados por conta da Controladora, ressalvada a **retenção mínima legal** (obrigações fiscais, trilha de auditoria e defesa em processo — art. 16 da LGPD e art. 15 do Marco Civil da Internet).

---

## CLÁUSULA DÉCIMA SÉTIMA — DA VIGÊNCIA, RENOVAÇÃO E RESCISÃO

17.1. **Vigência.** O Contrato vigora por prazo **[determinado de __ meses / indeterminado]**, a contar da data de assinatura **16 de julho de 2026**.

17.2. **Renovação.** Havendo prazo determinado, o Contrato renova-se automaticamente por iguais períodos, salvo denúncia por qualquer das Partes com antecedência mínima de **[__] dias** do termo.

17.3. **Resilição imotivada (denúncia).** Qualquer das Partes poderá resilir imotivadamente, mediante notificação com antecedência mínima de **[__] dias**, período durante o qual persistem as obrigações, incluindo a **retirada ordenada** das mercadorias pela CONTRATANTE.

17.4. **Resolução por justa causa.** O Contrato poderá ser resolvido, de pleno direito, por notificação, em caso de: (i) descumprimento de obrigação relevante não sanado no prazo de cura de **[__] dias** após notificação; (ii) inadimplemento financeiro; (iii) descumprimento grave e reincidente de SLA; (iv) incidente grave de proteção de dados por culpa da Parte; (v) recuperação judicial/falência/insolvência; ou (vi) prática de ato ilícito, fraude ou violação das leis anticorrupção/lavagem.

17.5. **Efeitos da rescisão.** Rescindido o Contrato: (i) a CONTRATANTE providenciará a **retirada das mercadorias** em até **[__] Dia(s) Útil(eis)**; (ii) apuram-se valores devidos até a data efetiva; (iii) aplica-se o previsto na Cláusula 16.9 (dados); e (iv) sobrevivem as cláusulas de confidencialidade, proteção de dados, responsabilidade, propriedade intelectual e foro.

17.6. **Direito de retenção.** Enquanto pendente o pagamento de serviços comprovadamente prestados, a CONTRATADA poderá exercer o **direito de retenção** sobre as mercadorias custodiadas (arts. 644 e 681 do Código Civil), na proporção do crédito, comunicando a CONTRATANTE, vedada a retenção abusiva ou desproporcional.

17.7. **Abandono de mercadoria.** Não retiradas as mercadorias no prazo, persistindo a inércia após notificação, a CONTRATADA poderá cobrar armazenagem adicional e, esgotados os meios, adotar as providências legais cabíveis para destinação, observada a legislação aplicável.

---

## CLÁUSULA DÉCIMA OITAVA — DA RESPONSABILIDADE E DA LIMITAÇÃO

18.1. Cada **[PARTE]** responde pelos danos **diretos e comprovados** a que der causa por dolo ou culpa, no âmbito deste Contrato.

18.2. **Exclusão de danos indiretos.** Ressalvado o dolo, nenhuma das Partes responderá por **lucros cessantes, danos indiretos, perda de chance, perda de receita/margem, dano de imagem ou danos incidentais/consequenciais**.

18.3. **Limitação global (*cap*).** Ressalvados (a) dolo ou culpa grave; (b) danos a dados pessoais e violação do DPA/LGPD; e (c) violação de sigilo, a responsabilidade agregada da CONTRATADA fica limitada ao **valor total dos serviços efetivamente pagos pela CONTRATANTE nos últimos [12] meses** anteriores ao evento, sem prejuízo da cobertura de seguro da Cláusula Décima Primeira.

18.4. **Responsabilidade perante o consumidor.** A relação de consumo é estabelecida entre a CONTRATANTE e o comprador final; eventual responsabilização da CONTRATADA por falha exclusiva na custódia/expedição observa a natureza de sua prestação e as excludentes da Cláusula 10.3, cabendo **direito de regresso** entre as Partes conforme a origem da falha.

18.5. **Força maior.** Nenhuma Parte responde por descumprimento decorrente de caso fortuito ou força maior (art. 393 do Código Civil), inclusive greves gerais, apagões, falhas sistêmicas dos Sub-operadores, desastres, atos de autoridade e eventos pandêmicos, enquanto perdurar o evento e desde que comunicado tempestivamente.

---

## CLÁUSULA DÉCIMA NONA — DAS PENALIDADES

19.1. **Multa por descumprimento de SLA (*service credit*).** O descumprimento das metas da Cláusula Décima Terceira sujeita a CONTRATADA a crédito/abatimento de **[__]%** sobre o valor mensal dos serviços por indicador descumprido, limitado a **[__]%** do faturamento do mês.

19.2. **Multa por avaria/perda.** Perdas anormais imputáveis à CONTRATADA (Cláusula 9.4) serão indenizadas pelo custo de reposição, acrescido de multa de **[__]%** em caso de reincidência, observado o *cap* da Cláusula 18.3 e o seguro.

19.3. **Multa por descumprimento contratual geral.** O descumprimento de obrigação relevante não sanada no prazo de cura sujeita a Parte infratora à multa de **[__]%** sobre o valor **[mensal/do contrato]**, sem prejuízo de perdas e danos e da rescisão.

19.4. **Multa por violação de sigilo/dados.** A violação das Cláusulas de Confidencialidade (Vigésima) e de Proteção de Dados (Décima Sexta)/DPA sujeita a Parte infratora à multa de **R$ [__]** por evento, sem prejuízo da indenização integral pelos danos e das sanções da LGPD (art. 52).

19.5. **Não exclusividade.** As multas não são excludentes entre si nem afastam a indenização por perdas e danos que as excederem, ressalvado o *cap* da Cláusula 18.3.

---

## CLÁUSULA VIGÉSIMA — DA CONFIDENCIALIDADE

20.1. As Partes obrigam-se a manter sigilo sobre toda **Informação Confidencial** a que tiverem acesso (dados operacionais, comerciais, tabelas de preço, volumes, dados de compradores, código, credenciais, *know-how* logístico da plataforma GLOP), utilizando-a exclusivamente para a execução deste Contrato.

20.2. **Exceções.** Não se considera confidencial a informação que: (i) seja ou se torne pública sem violação; (ii) já fosse conhecida licitamente; (iii) seja desenvolvida de forma independente; ou (iv) deva ser divulgada por ordem de autoridade, hipótese em que a Parte comunicará previamente a outra, quando legalmente possível.

20.3. **Prazo.** A obrigação de sigilo vigora durante o Contrato e por **[__] anos** após seu término, e por prazo indeterminado quanto a dados pessoais e segredos de negócio.

---

## CLÁUSULA VIGÉSIMA PRIMEIRA — DA PROPRIEDADE INTELECTUAL

21.1. **Titularidade da plataforma.** A plataforma **GLOP**, seu código-fonte, arquitetura, banco de dados, integrações, marca, *layout* e documentação são de titularidade exclusiva da **LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA** (ou de seus licenciantes), não se transferindo qualquer direito de propriedade à CONTRATANTE, que recebe apenas **licença de uso limitada, não exclusiva e intransferível** para operar a logística objeto deste Contrato.

21.2. **Titularidade da CONTRATANTE.** As marcas, produtos, conteúdos, layouts de embalagem e bases de dados de clientes da CONTRATANTE permanecem de sua exclusiva titularidade.

21.3. **Dados operacionais.** Os dados operacionais gerados na plataforma pertencem à respectiva Parte titular, podendo a CONTRATADA/GLOP utilizar **dados agregados e anonimizados** (sem identificação de pessoas ou de tenant) para métricas, *benchmark* e melhoria do serviço, em conformidade com a LGPD.

21.4. **Vedações.** É vedado à CONTRATANTE: (i) copiar, descompilar ou realizar engenharia reversa da plataforma; (ii) revender/sublicenciar o acesso sem autorização; e (iii) contornar controles de segurança (RLS, RBAC).

---

## CLÁUSULA VIGÉSIMA SEGUNDA — DAS DISPOSIÇÕES GERAIS

22.1. **Independência das Partes.** Este Contrato não cria vínculo empregatício, societário, de agência, consórcio ou representação, respondendo cada Parte por seus tributos, encargos e colaboradores.

22.2. **Cessão.** É vedada a cessão da posição contratual sem anuência prévia e escrita da outra Parte, ressalvada a cessão a empresa do mesmo grupo econômico mediante comunicação.

22.3. **Novação e tolerância.** A tolerância quanto ao descumprimento de qualquer cláusula não implica novação, renúncia ou alteração do pactuado.

22.4. **Nulidade parcial.** A eventual nulidade de uma cláusula não contamina as demais, que permanecem válidas e eficazes.

22.5. **Comunicações.** As comunicações formais serão feitas por escrito, por e-mail com confirmação de recebimento aos endereços indicados no preâmbulo, ou pelos canais da plataforma GLOP com registro auditável.

22.6. **Anexos.** Integram este Contrato, para todos os efeitos: **Anexo I** (Termo de Serviço, escopo, parâmetros e Tabela de Preços); **Anexo II** (Apólice de Seguro e limites); e o **DPA — Acordo de Tratamento de Dados**.

22.7. **Assinatura eletrônica.** As Partes reconhecem a validade da assinatura eletrônica/digital (art. 10, §2º, da MP nº 2.200-2/2001 e Lei nº 14.063/2020), inclusive por plataformas de assinatura.

22.8. **Integralidade.** Este Contrato e seus anexos constituem o entendimento integral entre as Partes, substituindo tratativas anteriores.

---

## CLÁUSULA VIGÉSIMA TERCEIRA — DO FORO

23.1. As Partes elegem o foro da comarca de **[ENDEREÇO — Comarca/UF]** para dirimir controvérsias oriundas deste Contrato, com renúncia a qualquer outro, por mais privilegiado que seja.

23.2. **Consumidor.** Sendo a CONTRATANTE consumidora, prevalece o foro de seu domicílio, nos termos do art. 101, I, do CDC.

23.3. **Solução amigável / mediação.** As Partes envidarão esforços de composição amigável e poderão submeter o litígio à **mediação/arbitragem** conforme **[câmara / regulamento]**, previamente à via judicial, quando assim ajustarem em Aditivo.

---

E, por estarem justas e contratadas, as Partes assinam o presente instrumento.

**[ENDEREÇO — Local]**, **16 de julho de 2026**.

|  |  |
|---|---|
| _______________________________ | _______________________________ |
| **CONTRATADA — LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA** | **CONTRATANTE — [CONTRATANTE]** |
| Operador Logístico ([NOME FANTASIA: GLOP]) | Tomador dos Serviços |
| CNPJ: 55.836.075/0001-07 | CPF/CNPJ: 55.836.075/0001-07 |

**Testemunhas:**

1. Nome: __________________ CPF: __________________
2. Nome: __________________ CPF: __________________

---

## Engenharia Jurídica & Governança

### (a) Fundamentação das cláusulas (lei/norma que embasa)

| Cláusula | Fundamento legal/normativo |
|---|---|
| Qualificação e capacidade das Partes | Arts. 104 e 421 do Código Civil (Lei nº 10.406/2002) |
| Objeto e autonomia da prestação | Arts. 594 e 610 (prestação de serviços/empreitada); ausência de vínculo — art. 3º da CLT (a contrario sensu) |
| Recebimento, custódia e restituição | Arts. 627 a 652 do Código Civil (contrato de depósito) |
| Responsabilidade sobre a mercadoria | Arts. 186, 389, 392, 393 e 927 do Código Civil (responsabilidade e força maior) |
| Base de indenização (dano direto) | Arts. 402 a 404 do Código Civil (perdas e danos, exclusão de lucros cessantes por acordo) |
| Direito de retenção | Arts. 644 e 681 do Código Civil |
| Seguro | Arts. 757 e ss. do Código Civil (contrato de seguro) |
| Devolução/arrependimento | Art. 49 do CDC (Lei nº 8.078/1990) |
| Relação de consumo / foro do consumidor | Arts. 101, I, e 6º do CDC |
| Proteção de dados (Controlador/Operador, incidentes, direitos) | Arts. 5º, 6º, 16, 18, 33-36, 37, 39, 42-45, 46-48 e 52 da LGPD (Lei nº 13.709/2018) |
| Guarda de logs / retenção mínima | Art. 15 do Marco Civil da Internet (Lei nº 12.965/2014); art. 16 da LGPD |
| Assinatura eletrônica | MP nº 2.200-2/2001; Lei nº 14.063/2020 |
| Compliance/anticorrupção/PLD | Lei nº 12.846/2013; Lei nº 9.613/1998 |
| Reajuste, mora e encargos | Arts. 315, 389, 394-395 e 406 do Código Civil; art. 52, §1º, do CDC |
| Segurança da informação (medidas) | Referência a ISO 27001/27701/22301/31000, NIST, OWASP; art. 46 da LGPD |

### (b) Riscos mitigados

- **Perda/avaria de mercadoria sob custódia** — marcos claros de transferência de risco (recebimento conferido → postagem), seguro obrigatório e base de indenização definida.
- **Overselling e ruptura** — reserva automática de saldo na ingestão do pedido; sinalização de backorder.
- **Erro de expedição** — dupla conferência de saída vinculada ao pedido e à trilha de auditoria.
- **Extravio do transportador** — delimitação de responsabilidade pós-postagem e apoio à reclamação, evitando assunção indevida de risco alheio.
- **Vazamento de PII do comprador** — enquadramento Controlador/Operador, DPA, minimização (portal neutro), notificação de incidente e medidas técnicas (RLS, RBAC, credenciais write-only).
- **Reclassificação como vínculo empregatício** — cláusula de independência e autonomia.
- **Inadimplência** — direito de retenção, suspensão de novos processamentos e encargos.
- **Responsabilização em cadeia perante o consumidor** — direito de regresso e delimitação da relação de consumo.
- **Descumprimento de SLA** — KPIs mensuráveis, service credits e gatilho de rescisão motivada.
- **Uso indevido da plataforma / engenharia reversa** — cláusulas de propriedade intelectual e vedações.

### (c) Checklist de implantação

- [ ] Preencher todos os placeholders (razão social, CNPJ, endereços, valores, prazos, percentuais).
- [ ] Anexar e assinar o **DPA — Acordo de Tratamento de Dados**.
- [ ] Elaborar **Anexo I** (escopo, parâmetros FEFO/FIFO, cut-off, tabela de preços).
- [ ] Elaborar **Anexo II** (apólice de seguro, limites, franquias, exclusões).
- [ ] Definir metas numéricas de SLA e tolerância de quebra.
- [ ] Validar bases legais LGPD junto ao Controlador e canais do Encarregado.
- [ ] Confirmar lista atualizada de Sub-operadores e cláusulas de repasse de deveres.
- [ ] Definir foro/mediação e verificar hipótese de consumidor.
- [ ] Revisão final por advogado(a) habilitado(a) antes do uso em produção.

### (d) Matriz RACI

| Atividade | CONTRATANTE | CONTRATADA (Operador/GLOP) | Encarregado (DPO) | Jurídico |
|---|---|---|---|---|
| Fornecer mercadoria e dados de produto | R/A | C | I | I |
| Recebimento e conferência | I | R/A | I | - |
| Armazenagem e custódia | I | R/A | I | - |
| Gestão de estoque/lotes/validade | C | R/A | I | - |
| Decisão de reposição/ruptura | R/A | C | I | - |
| Picking/Packing e expedição | I | R/A | I | - |
| Notificação ao comprador (transacional) | A (instrui) | R | C | I |
| Inventário e conciliação | C | R/A | I | - |
| Tratamento de incidente de dados | C | R | A/R | C |
| Atendimento a direitos de titulares | A | R (auxílio) | R | C |
| Gestão de seguro e sinistro | I | R/A | - | C |
| Apuração de KPIs/SLA | C | R/A | - | - |
| Faturamento e pagamento | R/A (paga) | R (fatura) | - | - |
| Revisão jurídica e conformidade | C | C | C | R/A |

Legenda: **R** = Responsável (executa) · **A** = *Accountable* (aprova/presta contas) · **C** = Consultado · **I** = Informado.

### (e) Plano de revisão

- **Trimestral:** revisão operacional de KPIs/SLA, capacidade e incidentes (comitê operacional).
- **Semestral:** revisão da tabela de preços, cobertura de seguro e lista de Sub-operadores.
- **Anual:** revisão jurídica integral (LGPD, CDC, Código Civil), reajuste e atualização de anexos.
- **Ad hoc:** a cada alteração legislativa relevante (ANPD, atualizações da LGPD), mudança de fluxo na plataforma GLOP, novo gateway/integração, ou incidente de segurança material.

### (f) Controle de versão

| Versão | Data | Autor | Alterações | Status |
|---|---|---|---|---|
| 0.1 | 16 de julho de 2026 | Chief Legal AI (minuta) | Redação inicial da minuta 3PL/fulfillment | Minuta — pendente de revisão |
| 0.2 | 16 de julho de 2026 | [Revisor jurídico] | Preenchimento de placeholders e ajustes à operação real | Em revisão |
| 1.0 | 16 de julho de 2026 | [Advogado(a) responsável] | Validação final e liberação para produção | Aprovado |

> ⚠️ MINUTA — este documento é um modelo técnico gerado por IA e NÃO substitui a análise de advogado(a) habilitado(a). Preencha os campos entre colchetes, anexe o DPA e os Anexos I e II, e submeta à revisão jurídica antes de qualquer uso em produção.
