> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# Contrato e Termo de Uso de API — GLOP (Global Logistics Platform)

**Documento:** Termo de Uso de Interface de Programação de Aplicações (API) e Credenciais de Integração
**Versão:** 1.0
**Vigência a partir de:** 16 de julho de 2026
**Plataforma:** [NOME FANTASIA: GLOP]
**Controlador/Operador da Plataforma:** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, inscrita no CNPJ sob nº 55.836.075/0001-07

---

## Preâmbulo

O presente Termo de Uso de API ("Termo", "Contrato de API" ou simplesmente "API Terms") regula, de forma vinculante, o acesso e a utilização das interfaces de programação de aplicações (APIs), credenciais, chaves de acesso, webhooks, SDKs, endpoints REST e demais recursos técnicos de integração ("API" ou "APIs") disponibilizados pela plataforma **[NOME FANTASIA: GLOP]** (Global Logistics Platform), um Software como Serviço (SaaS) de logística e ERP voltado a operações de dropshipping e infoprodutos no mercado brasileiro.

Este Termo é acessório e complementar aos Termos de Uso gerais da plataforma, à Política de Privacidade, ao Acordo de Processamento de Dados (DPA) e ao Contrato de Prestação de Serviços (SaaS) firmado entre as Partes, integrando-os por referência. Em caso de conflito entre este Termo e o Contrato de Prestação de Serviços quanto a matérias especificamente técnicas de API, prevalece este Termo; nas demais matérias, prevalece o Contrato principal.

O aceite deste Termo ocorre por qualquer das seguintes formas, o que primeiro se verificar: (i) geração ou solicitação da primeira chave/credencial de API no painel do GLOP; (ii) primeira chamada autenticada a qualquer endpoint da API; (iii) aceite eletrônico expresso (clique em "Li e concordo"); ou (iv) uso continuado da API após a comunicação de nova versão deste Termo. A ausência de assinatura física não afasta a validade e a executoriedade deste instrumento, nos termos do art. 10, §2º, da Medida Provisória nº 2.200-2/2001 e do art. 425 do Código Civil.

---

## Capítulo I — Qualificação das Partes e Definições

### Cláusula 1ª — Das Partes

**1.1. FORNECEDORA (LICENCIANTE DA API):**
LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, pessoa jurídica de direito privado, inscrita no CNPJ sob nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, operadora da plataforma **[NOME FANTASIA: GLOP]**, doravante denominada "GLOP", "Fornecedora", "Plataforma" ou "Licenciante".

**1.2. CONTRATANTE (DESENVOLVEDORA / INTEGRADORA):**
[CONTRATANTE], pessoa física ou jurídica que solicita, obtém ou utiliza credenciais de API do GLOP, para si ou por conta de terceiros, doravante denominada "Contratante", "Desenvolvedora", "Integradora" ou "Usuária da API".

**1.3.** GLOP e Contratante são individualmente denominadas "Parte" ([PARTE]) e, em conjunto, "Partes".

### Cláusula 2ª — Das Definições

Para os fins deste Termo, aplicam-se as seguintes definições, sem prejuízo daquelas constantes do Contrato principal e da legislação:

- **API:** conjunto de endpoints, métodos, esquemas de autenticação, webhooks e contratos de dados expostos pelo GLOP para integração programática.
- **Chave/Credencial de API:** par de identificação e segredo (API Key, Client ID/Secret, token JWT, chave de assinatura de webhook) que autentica e autoriza chamadas em nome de uma empresa (Company) e escopo específico.
- **Escopo (Scope):** conjunto de permissões atreladas a uma credencial, alinhado ao modelo RBAC do GLOP (has_permission) e ao isolamento multi-tenant (Tenant → Company → Branch → Membership).
- **Rate Limit:** limite de taxa de requisições por unidade de tempo aplicável a uma credencial, empresa ou endpoint.
- **Webhook:** notificação HTTP assíncrona enviada pelo GLOP para um endpoint da Contratante mediante eventos (ex.: pedido importado, status de rastreio SRO atualizado, NF-e emitida).
- **Dados Pessoais do Comprador:** dados pessoais de consumidores finais tratados no fluxo logístico (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor), em relação aos quais o GLOP atua majoritariamente como **Operador** por conta do produtor/lojista **Controlador**.
- **Dados do Usuário da Plataforma:** dados pessoais dos próprios contratantes, colaboradores e desenvolvedores, em relação aos quais o GLOP atua como **Controlador**.
- **Sub-operadores:** terceiros que suportam a operação, incluindo Supabase e Netlify (infraestrutura), VHSYS (NF-e), Correios (transporte/PPN/SRO), gateways de pagamento (Monetizze, AppMax, Hotmart, Kiwify) e provedores de comunicação (WhatsApp/e-mail).
- **LGPD:** Lei nº 13.709/2018 (Lei Geral de Proteção de Dados Pessoais).
- **DPA:** Acordo de Processamento de Dados (Data Processing Agreement) firmado entre as Partes.
- **Ambiente de Produção / Sandbox:** ambiente com dados reais versus ambiente de testes com dados fictícios.

---

## Capítulo II — Objeto e Escopo de Acesso

### Cláusula 3ª — Do Objeto

**3.1.** Constitui objeto deste Termo a concessão à Contratante de uma **licença limitada, revogável, não exclusiva, intransferível e não sublicenciável** de acesso e uso da API do GLOP, exclusivamente para integrar seus próprios sistemas, aplicações ou operações autorizadas à Plataforma, nos limites do escopo concedido a cada credencial.

**3.2.** A API do GLOP viabiliza, entre outras funcionalidades, conforme o escopo contratado e as permissões RBAC:

1. **Ingestão de pedidos** provenientes de gateways e APIs (Monetizze, Hotmart, Kiwify) e de e-commerces/checkouts (Shopify, WooCommerce, Nuvemshop, Mercado Livre), com os dados do comprador e do pedido;
2. **Gestão logística** (WMS/TMS/YMS), separação, expedição e movimentação de estoque;
3. **Integração com Correios**: pré-postagem (PPN), rastreamento (SRO) e disparo de notificações ao comprador por e-mail/WhatsApp;
4. **Coprodução e Split**: cadastro de coprodutores/afiliados, apuração de comissões, repasses e split de pagamento (AppMax), incluindo dados de PIX/bancários dos beneficiários;
5. **Emissão de documentos fiscais** (NF-e) via VHSYS;
6. **Consulta de status de rastreio** e alimentação do Portal Público de Rastreio (sem login, exibindo somente status neutro).

**3.3.** A licença não transfere qualquer titularidade sobre a API, seu código, arquitetura, esquemas de dados, documentação ou marcas, os quais permanecem de propriedade exclusiva da GLOP e/ou de seus licenciadores (vide Cláusula 20ª).

### Cláusula 4ª — Do Escopo de Acesso e do Isolamento Multi-Tenant

**4.1.** Todo acesso à API é **escopado por empresa (Company)** e por permissão (RBAC — has_permission), respeitando rigorosamente o isolamento multi-tenant da Plataforma (Tenant → Company → Branch → Membership) e as políticas de Row Level Security (RLS) do banco de dados.

**4.2.** Uma credencial de API somente pode ler, gravar ou modificar registros da(s) empresa(s) à(s) qual(is) esteja vinculada. É **absolutamente vedado** à Contratante:

1. Tentar acessar, inferir, enumerar ou correlacionar dados de outra empresa (tenant), ainda que por falha, exploração de identificadores sequenciais (IDOR) ou manipulação de parâmetros;
2. Utilizar uma credencial fora do escopo de permissões a ela atribuído;
3. Compartilhar, revender, sublicenciar ou expor credenciais a terceiros não autorizados.

**4.3.** As credenciais de escrita (write) são configuradas como **write-only** sempre que tecnicamente aplicável, não permitindo a recuperação posterior do segredo, que deve ser armazenado com segurança pela Contratante no momento da emissão.

**4.4.** O escopo concedido pode incluir, de forma granular: `orders.read`, `orders.create`, `shipping.write`, `tracking.read`, `fiscal.read`, `split.read`, entre outros, conforme o catálogo de recursos da Plataforma (master_data, inventory, wms, tms, yms, purchasing, shipping, distribution, controltower, bi, admin).

---

## Capítulo III — Chaves, Credenciais e Segurança

### Cláusula 5ª — Da Emissão e Gestão de Credenciais

**5.1.** As credenciais de API são emitidas pelo painel do GLOP mediante autenticação do usuário (Supabase Auth/JWT) com permissão administrativa (has_permission) na empresa correspondente. Cada credencial recebe identificação única, escopo, data de emissão e, quando aplicável, data de expiração.

**5.2.** A Contratante é **integral e exclusivamente responsável** por:

1. Manter as credenciais em sigilo, armazenadas de forma cifrada (em repouso e em trânsito) e nunca em código-fonte público, repositórios, logs, front-end, aplicativos móveis descompiláveis ou canais inseguros;
2. Restringir o acesso às credenciais ao mínimo necessário (princípio do menor privilégio);
3. Rotacionar (rotate) as credenciais periodicamente e imediatamente após qualquer suspeita de comprometimento;
4. Revogar credenciais de colaboradores desligados ou de integrações descontinuadas.

**5.3.** Toda e qualquer requisição autenticada com uma credencial válida presume-se realizada pela Contratante titular, que responde por todos os atos praticados sob suas credenciais, ainda que por terceiros, salvo comprovação inequívoca de comprometimento previamente comunicado à GLOP.

### Cláusula 6ª — Das Obrigações de Segurança da Informação

**6.1.** A Contratante obriga-se a observar padrões mínimos de segurança compatíveis com as normas ISO/IEC 27001 e 27701, o NIST Cybersecurity Framework e as diretrizes OWASP, incluindo, sem limitação:

1. **Transporte seguro:** todas as chamadas devem usar TLS 1.2 ou superior (HTTPS). Requisições em texto claro serão recusadas;
2. **Autenticação e assinatura:** validação obrigatória da assinatura dos webhooks (HMAC/chave de assinatura) para garantir autenticidade e integridade, rejeitando payloads não assinados ou com assinatura inválida;
3. **Proteção contra replay:** verificação de timestamp e/ou nonce em webhooks;
4. **Validação de entrada:** sanitização e validação de todos os dados recebidos, prevenindo injeção (SQLi), XSS e desserialização insegura;
5. **Registro e monitoramento:** manutenção de logs de suas próprias chamadas e do consumo de webhooks, sem armazenar segredos em texto claro;
6. **Segregação de ambientes:** uso do ambiente de sandbox para testes, jamais empregando dados reais de compradores em ambiente de teste.

**6.2.** A Plataforma adota, do seu lado, RLS por empresa, RBAC (has_permission), soft-delete, trilha de auditoria por triggers e colunas de auditoria em todos os registros, credenciais de API write-only e demais controles descritos na Política de Segurança da Informação.

### Cláusula 7ª — Da Notificação de Incidentes

**7.1.** A Contratante deverá **comunicar a GLOP em até 24 (vinte e quatro) horas** da ciência de qualquer incidente de segurança que envolva ou possa envolver credenciais do GLOP, dados obtidos via API ou dados pessoais de compradores, pelos canais lemoncapsencapsulados@gmail.com e/ou canal de suporte técnico.

**7.2.** A comunicação deve conter, na medida do disponível: natureza do incidente, dados e titulares potencialmente afetados, medidas adotadas e ponto de contato técnico. A cooperação mútua para contenção, investigação e, se aplicável, comunicação à ANPD e aos titulares (art. 48 da LGPD) é obrigatória, observando-se os papéis de Controlador e Operador definidos no DPA.

---

## Capítulo IV — Casos de Uso, Limites e Disponibilidade

### Cláusula 8ª — Dos Casos de Uso Permitidos

**8.1.** A API destina-se exclusivamente a finalidades legítimas de integração logística e operacional, notadamente:

1. Sincronização de pedidos entre lojas/gateways e o GLOP;
2. Automação de pré-postagem, geração de etiquetas e rastreio junto aos Correios;
3. Consulta de status de expedição e alimentação de painéis próprios;
4. Emissão e consulta de documentos fiscais (NF-e via VHSYS) no interesse da própria empresa;
5. Apuração e conciliação de coprodução, comissões e split de pagamento;
6. Disparo autorizado de notificações transacionais ao comprador (status de entrega).

### Cláusula 9ª — Dos Casos de Uso Vedados

**9.1.** É **expressamente vedado** à Contratante, sob pena de suspensão imediata e responsabilização civil e criminal:

1. **Raspagem/scraping massivo**, mineração ou extração sistemática de dados além do estritamente necessário à integração autorizada;
2. **Criação de base de dados paralela** de compradores para fins de marketing próprio, revenda, enriquecimento ou compartilhamento com terceiros, em violação à LGPD e ao DPA;
3. **Uso das notificações** (e-mail/WhatsApp) para envio de mensagens publicitárias, promocionais ou não transacionais não autorizadas (SPAM), em desacordo com o Marco Civil da Internet e a política do provedor de mensageria;
4. **Contornar rate limits**, controles de escopo, RLS, RBAC ou quaisquer medidas técnicas de proteção (inclusive por rotação abusiva de credenciais ou distribuição de carga entre múltiplas chaves para o mesmo fim);
5. **Engenharia reversa**, descompilação, teste de intrusão não autorizado, fuzzing ou varredura de vulnerabilidades da API sem autorização prévia, específica e por escrito da GLOP (programa de divulgação responsável, se existente);
6. **Uso da API para atividade ilícita**, fraude, lavagem de dinheiro, comercialização de produtos proibidos, violação de direitos de terceiros ou concorrência desleal;
7. **Revenda, sublicenciamento ou disponibilização** da API a terceiros como se fosse serviço próprio, sem autorização;
8. **Sobrecarga deliberada** da infraestrutura (DoS/DDoS), testes de estresse não autorizados ou padrões de tráfego que degradem a Plataforma;
9. **Tratamento de dados de compradores** em desacordo com a finalidade logística/fiscal e com as instruções do Controlador.

### Cláusula 10ª — Dos Limites de Taxa (Rate Limiting)

**10.1.** A GLOP aplica limites de taxa por credencial, empresa e/ou endpoint, com o objetivo de assegurar estabilidade, isonomia entre clientes e proteção da infraestrutura. Os limites vigentes constam da documentação técnica e podem variar conforme o plano contratado.

**10.2.** Parâmetros de referência (indicativos, sujeitos à documentação oficial):

| Categoria de endpoint | Limite padrão (indicativo) | Janela | Comportamento ao exceder |
|---|---|---|---|
| Leitura (read) | 600 requisições | por minuto/credencial | HTTP 429 + cabeçalho Retry-After |
| Escrita (write) | 120 requisições | por minuto/credencial | HTTP 429 + backoff exponencial recomendado |
| Ingestão em lote (bulk) | 20 requisições | por minuto/credencial | HTTP 429 |
| Webhooks (recebimento) | conforme evento | evento a evento | reentrega com backoff |
| Consultas fiscais/NF-e | 60 requisições | por minuto/credencial | HTTP 429 |

**10.3.** Ao receber resposta HTTP **429 (Too Many Requests)**, a Contratante deverá respeitar o cabeçalho `Retry-After` e implementar recuo exponencial com *jitter*. A tentativa reiterada de burlar o limite caracteriza abuso (Cláusula 9ª) e enseja suspensão.

**10.4.** A GLOP poderá ajustar limites, aplicar limites dinâmicos ou impor cotas emergenciais para preservar a integridade da Plataforma, comunicando alterações relevantes com antecedência razoável, salvo situações de risco iminente.

### Cláusula 11ª — Da Disponibilidade e Níveis de Serviço (SLA)

**11.1.** A GLOP empreenderá esforços comercialmente razoáveis para manter a API disponível, observado o SLA aplicável ao plano contratado no Contrato principal. A disponibilidade da API depende, ainda, de sub-operadores (Supabase, Netlify) e de integrações de terceiros (Correios, VHSYS, gateways), cujas indisponibilidades **não são imputáveis** à GLOP.

**11.2.** Excluem-se do cômputo de indisponibilidade: (i) manutenções programadas comunicadas com antecedência; (ii) manutenções emergenciais de segurança; (iii) falhas de terceiros/sub-operadores; (iv) casos fortuitos e de força maior (art. 393 do Código Civil); (v) uso indevido pela Contratante; e (vi) suspensões por abuso ou inadimplência.

**11.3.** A API é fornecida em regime de melhores esforços quanto a integrações de terceiros. A GLOP não garante que os serviços dos Correios, VHSYS ou gateways estarão sempre disponíveis, íntegros ou livres de erros de origem.

---

## Capítulo V — Versionamento, Depreciação e Evolução

### Cláusula 12ª — Do Versionamento

**12.1.** A API adota versionamento explícito (ex.: prefixo `/v1`, `/v2` ou cabeçalho de versão). Alterações são classificadas em:

1. **Não disruptivas (backward-compatible):** adição de campos opcionais, novos endpoints, novos eventos — podem ser implantadas sem aviso prévio formal;
2. **Disruptivas (breaking changes):** remoção/renomeação de campos, alteração de tipos, mudança de semântica ou de contrato — implicam nova versão e seguem a política de depreciação.

**12.2.** A Contratante deve programar suas integrações de forma tolerante, ignorando campos desconhecidos e não presumindo ordem ou exaustividade de listas.

### Cláusula 13ª — Da Depreciação (Deprecation) e Descontinuação

**13.1.** Quando da depreciação de uma versão ou recurso, a GLOP envidará esforços para conceder **prazo mínimo de 90 (noventa) dias** de aviso prévio, contado da comunicação oficial (painel, e-mail e/ou documentação), durante o qual a versão depreciada permanecerá operante em modo de manutenção, salvo:

1. Necessidade imperiosa de correção de vulnerabilidade de segurança;
2. Exigência legal, regulatória ou de sub-operador/terceiro;
3. Risco iminente à integridade ou à proteção de dados.

Nessas hipóteses, o prazo poderá ser reduzido, com comunicação tão tempestiva quanto possível.

**13.2.** Após o término do prazo de depreciação, a versão descontinuada poderá responder com HTTP 410 (Gone) ou redirecionar para a versão vigente. A GLOP não responde por falhas decorrentes da não migração tempestiva pela Contratante.

---

## Capítulo VI — Proteção de Dados Pessoais

### Cláusula 14ª — Da Dupla Natureza e Remissão ao DPA

**14.1.** O tratamento de dados pessoais no âmbito da API observa a **dupla natureza** do GLOP:

1. **Como OPERADOR (art. 5º, VII, LGPD):** quanto aos dados pessoais dos **compradores** (nome, CPF/CNPJ, e-mail, telefone, endereço, produto, valor, dados de PIX/bancários de beneficiários de split), tratados **por conta e sob instruções** do produtor/lojista **Controlador** (o cliente do GLOP). O tratamento se limita à finalidade logística, fiscal e de repasse;
2. **Como CONTROLADOR (art. 5º, VI, LGPD):** quanto aos dados dos próprios usuários da plataforma, contratantes, desenvolvedores e colaboradores (credenciais, dados cadastrais, logs de acesso à API, telemetria de uso).

**14.2.** O tratamento de dados pessoais por meio da API rege-se pelo **Acordo de Processamento de Dados (DPA)** firmado entre as Partes, que integra este Termo por referência e prevalece em matéria de proteção de dados. A Contratante que, ao usar a API, atue como Controladora ou Operadora de dados de compradores, assume as obrigações correlatas da LGPD e do DPA.

**14.3.** São bases legais típicas dos fluxos: execução de contrato e procedimentos preliminares (art. 7º, V), cumprimento de obrigação legal/regulatória — inclusive fiscal (art. 7º, II), e legítimo interesse para prevenção a fraudes e segurança (art. 7º, IX e art. 10), sempre com minimização e finalidade específica.

### Cláusula 15ª — Das Obrigações de Proteção de Dados da Contratante

**15.1.** A Contratante obriga-se a:

1. Tratar os dados pessoais obtidos via API **exclusivamente** para as finalidades autorizadas e conforme instruções do Controlador;
2. Não reutilizar, comercializar, enriquecer ou compartilhar dados de compradores com terceiros sem base legal e autorização;
3. Aplicar medidas técnicas e organizacionais adequadas (art. 46 da LGPD), incluindo cifragem, controle de acesso e minimização;
4. Respeitar e viabilizar os **direitos dos titulares** (arts. 18 e 19 da LGPD): confirmação, acesso, correção, anonimização, portabilidade, eliminação e informação sobre compartilhamento, encaminhando ao GLOP as solicitações que dependam da Plataforma;
5. Observar a **eliminação/retenção** conforme finalidade e prazos legais (art. 15 e 16 da LGPD), respeitado o soft-delete e a trilha de auditoria da Plataforma;
6. Não transferir dados internacionalmente sem observar o Capítulo V da LGPD.

**15.2.** O **Portal Público de Rastreio** expõe apenas status neutro, sem login e sem PII sensível, em atenção à minimização de dados; é vedado à Contratante ampliar esse escopo ou correlacionar o link público a dados pessoais completos de forma a expô-los publicamente.

### Cláusula 16ª — Do Encarregado (DPO)

**16.1.** O Encarregado pelo Tratamento de Dados Pessoais (DPO) da GLOP é **a ser designado pela administração**, contatável em **lemoncapsencapsulados@gmail.com**, canal para exercício de direitos de titulares e comunicação de incidentes, nos termos do art. 41 da LGPD.

---

## Capítulo VII — Responsabilidade, Suspensão e Encerramento

### Cláusula 17ª — Da Responsabilidade e Limitação

**17.1.** Cada Parte responde pelos danos a que der causa por dolo ou culpa, no exercício de suas obrigações, observada a legislação aplicável.

**17.2.** A Contratante é integralmente responsável por: (i) o uso das credenciais e por toda atividade sob elas realizada; (ii) a conformidade de sua integração com este Termo, o DPA e a legislação; (iii) danos causados a compradores, terceiros ou à GLOP decorrentes de uso indevido, vazamento por sua culpa ou tratamento irregular de dados.

**17.3. Limitação de responsabilidade da GLOP:** salvo dolo, culpa grave ou disposição legal cogente em contrário (notadamente relações de consumo e proteção de dados), a responsabilidade agregada da GLOP perante a Contratante, por qualquer causa relacionada à API, fica limitada ao valor efetivamente pago pela Contratante pelos serviços do GLOP nos **12 (doze) meses** anteriores ao evento, excluídos lucros cessantes, danos indiretos, perda de dados imputável a terceiros/sub-operadores e danos punitivos.

**17.4.** A API é fornecida **"no estado em que se encontra" (as is)** e **"conforme disponibilidade" (as available)** quanto a aspectos não cobertos por SLA, sem garantia implícita de adequação a finalidade específica da Contratante, ressalvadas as garantias legais inafastáveis.

**17.5. Indenização (indenização/hold harmless):** a Contratante manterá a GLOP indene de reclamações, autuações ou condenações de terceiros (inclusive titulares de dados e órgãos como ANPD e Procon) decorrentes de seu uso indevido da API, violação deste Termo, do DPA ou da legislação.

### Cláusula 18ª — Da Suspensão por Abuso e da Rescisão

**18.1. Suspensão imediata:** a GLOP poderá **suspender ou revogar credenciais e/ou o acesso à API, imediatamente e independentemente de aviso prévio**, quando constatar:

1. Abuso de rate limit ou tentativa de contorná-lo;
2. Violação de escopo, tentativa de acesso cross-tenant (IDOR) ou exploração de vulnerabilidade;
3. Uso vedado (Cláusula 9ª), atividade ilícita ou risco à segurança/integridade da Plataforma ou de dados de compradores;
4. Comprometimento de credenciais;
5. Ordem judicial ou determinação de autoridade competente;
6. Inadimplência do Contrato principal.

**18.2.** Sempre que a suspensão não decorrer de risco iminente, a GLOP comunicará a Contratante e, quando cabível, concederá prazo razoável para saneamento. Cessada a causa, o acesso poderá ser restabelecido a critério técnico da GLOP.

**18.3. Rescisão:** este Termo vige por prazo indeterminado, acompanhando o Contrato principal, e pode ser **denunciado por qualquer das Partes**, imotivadamente, mediante aviso com **30 (trinta) dias** de antecedência; ou **rescindido imotivadamente por justa causa** em caso de violação não sanada no prazo de **10 (dez) dias** da notificação, ou imediatamente nas hipóteses da Cláusula 18.1.

**18.4.** Encerrado o acesso, a Contratante deverá cessar todo uso da API, destruir as credenciais e eliminar ou devolver os dados pessoais obtidos, conforme o DPA e a legislação, salvo retenção legal obrigatória.

### Cláusula 19ª — Das Penalidades

**19.1.** Sem prejuízo da suspensão, da rescisão e da reparação integral dos danos, a violação a este Termo poderá ensejar: (i) revogação definitiva do acesso; (ii) cobrança de multa contratual conforme previsto no Contrato principal; (iii) comunicação às autoridades competentes; e (iv) responsabilização civil e criminal cabível.

---

## Capítulo VIII — Propriedade Intelectual, Confidencialidade e Disposições Gerais

### Cláusula 20ª — Da Propriedade Intelectual

**20.1.** A API, sua documentação, esquemas de dados, SDKs, marcas, logotipos e o nome **[NOME FANTASIA: GLOP]** são de titularidade exclusiva da GLOP e/ou de seus licenciadores, protegidos pela Lei nº 9.279/1996 (Propriedade Industrial) e Lei nº 9.610/1998 (Direitos Autorais), aplicando-se ainda a Lei nº 9.609/1998 (Programa de Computador).

**20.2.** Este Termo não confere à Contratante qualquer direito sobre tais ativos além da licença de uso limitada da Cláusula 3ª. É vedado o uso das marcas da GLOP sem autorização escrita, ressalvada menção factual de compatibilidade/integração.

**20.3.** Eventual *feedback* fornecido pela Contratante sobre a API poderá ser livremente utilizado pela GLOP, sem ônus e sem gerar direitos à Contratante.

### Cláusula 21ª — Da Confidencialidade

**21.1.** Cada Parte manterá em sigilo as informações confidenciais da outra a que tiver acesso (inclusive segredos de credenciais, arquitetura, dados de compradores, condições comerciais), usando-as apenas para os fins deste Termo, durante a vigência e por **5 (cinco) anos** após seu término, ressalvadas informações públicas, obtidas licitamente de terceiros ou de divulgação obrigatória por lei/ordem judicial (com comunicação prévia, quando possível).

**21.2.** Dados pessoais recebem, adicionalmente, o tratamento do Capítulo VI e do DPA, cuja obrigação de proteção subsiste enquanto houver retenção legítima.

### Cláusula 22ª — Do Preço

**22.1.** O acesso à API integra o plano contratado no Contrato principal, cujas condições de preço, forma e prazo de pagamento ali se aplicam. Eventual cobrança específica por volume de chamadas, cotas premium ou add-ons será definida em proposta comercial ou tabela vigente, comunicada previamente.

**22.2.** A inadimplência autoriza a suspensão do acesso à API, sem prejuízo dos encargos moratórios previstos no Contrato principal.

### Cláusula 23ª — Das Disposições Gerais

**23.1. Alterações:** a GLOP poderá atualizar este Termo, comunicando por painel/e-mail; o uso continuado após a vigência da nova versão implica aceite. Alterações que reduzam materialmente direitos da Contratante observarão aviso prévio razoável.

**23.2. Independência das cláusulas:** a nulidade de uma cláusula não prejudica as demais.

**23.3. Não renúncia:** a tolerância quanto a qualquer descumprimento não implica novação ou renúncia.

**23.4. Cessão:** a Contratante não poderá ceder este Termo sem anuência escrita da GLOP; a GLOP poderá cedê-lo a sucessoras ou coligadas, mediante comunicação.

**23.5. Comunicações:** consideram-se válidas as comunicações enviadas aos endereços eletrônicos cadastrados e ao lemoncapsencapsulados@gmail.com para matérias de dados/segurança.

**23.6. Sub-operadores:** a Contratante reconhece e concorda com o emprego dos sub-operadores indicados (Supabase, Netlify, VHSYS, Correios, Monetizze, AppMax, Hotmart, Kiwify, provedores de WhatsApp/e-mail), obrigando-se a GLOP a exigir deles padrão de proteção compatível, conforme o DPA.

### Cláusula 24ª — Do Foro e Legislação Aplicável

**24.1.** Este Termo rege-se pelas leis da República Federativa do Brasil, em especial o Código Civil, o Marco Civil da Internet (Lei nº 12.965/2014), a LGPD (Lei nº 13.709/2018) e, quando aplicável, o Código de Defesa do Consumidor (Lei nº 8.078/1990).

**24.2.** Fica eleito o foro da Comarca de **[ENDEREÇO — Comarca da sede da GLOP]** para dirimir controvérsias, com renúncia a qualquer outro, ressalvado o foro do domicílio do consumidor nas relações de consumo e as competências legais cogentes.

E, por estarem assim justas e contratadas, as Partes obrigam-se ao fiel cumprimento deste Termo, que passa a vigorar a partir do aceite eletrônico ou da primeira utilização da API.

16 de julho de 2026

**LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA — [NOME FANTASIA: GLOP]**
55.836.075/0001-07

**[CONTRATANTE]**

---

## Engenharia Jurídica & Governança

### (a) Fundamentação das Cláusulas

| Cláusula / Tema | Fundamento legal e normativo |
|---|---|
| Aceite eletrônico e validade | MP nº 2.200-2/2001 (ICP-Brasil), art. 425 do Código Civil (contratos atípicos) |
| Licença de uso da API / PI | Lei nº 9.609/1998 (software), Lei nº 9.610/1998 (autoral), Lei nº 9.279/1996 (marcas) |
| Escopo, RLS, RBAC, multi-tenant | Princípio da segurança e minimização — art. 6º, VII e III, e art. 46 da LGPD; boas práticas ISO 27001 |
| Segurança da informação e webhooks | Art. 46-49 da LGPD; ISO/IEC 27001/27701; NIST CSF; OWASP API Security Top 10 |
| Notificação de incidentes (24h) | Art. 48 da LGPD; art. 50 (boas práticas e governança) |
| Casos de uso vedados / anti-scraping | Marco Civil (Lei 12.965/2014), CDC quanto a SPAM, concorrência desleal (Lei 9.279/96, art. 195) |
| Rate limiting e disponibilidade | Autonomia privada; art. 393 CC (força maior); previsão de SLA no Contrato principal |
| Versionamento e depreciação | Boa-fé objetiva e função social do contrato (arts. 421 e 422 CC); dever de informação |
| Dupla natureza (Controlador/Operador) | Art. 5º, VI e VII, e art. 39 da LGPD; remissão ao DPA (art. 39) |
| Direitos dos titulares | Arts. 17-22 da LGPD |
| Encarregado/DPO | Art. 5º, VIII e art. 41 da LGPD |
| Limitação de responsabilidade | Arts. 393, 402-405 e 944 do Código Civil; ressalvas do CDC (arts. 25 e 51) |
| Suspensão por abuso | Exercício regular de direito (art. 188, I, CC); autotutela contratual; segurança da rede (Marco Civil) |
| Rescisão e denúncia | Arts. 473, 474 e 475 do Código Civil |
| Confidencialidade | Art. 195 da Lei 9.279/96; dever anexo de sigilo (boa-fé, art. 422 CC) |
| Foro | Art. 63 do CPC; art. 101, I, do CDC (foro do consumidor) |

### (b) Riscos Mitigados

1. **Vazamento cross-tenant (IDOR):** vedação expressa, escopo por Company, RLS/RBAC e suspensão imediata.
2. **Vazamento de credenciais:** obrigações de custódia, rotação, write-only e notificação em 24h.
3. **Uso indevido de PII de compradores:** finalidade estrita, remissão ao DPA, vedação a base paralela e SPAM.
4. **Sobrecarga/abuso de infraestrutura:** rate limits, HTTP 429, suspensão por abuso e cláusula de força maior.
5. **Quebra de integrações por mudança:** política de versionamento e depreciação com 90 dias de aviso.
6. **Responsabilização por falha de terceiros:** exclusão de indisponibilidade de sub-operadores do SLA.
7. **Exposição indevida no Portal Público:** limitação a status neutro e vedação de correlação com PII.
8. **Litígios de responsabilidade:** limitação de responsabilidade, indenização e foro definido.
9. **Descumprimento da LGPD:** dupla natureza clara, bases legais, direitos de titulares e DPO.

### (c) Checklist de Conformidade

- [ ] Placeholders preenchidos (LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, 55.836.075/0001-07, Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, lemoncapsencapsulados@gmail.com, a ser designado pela administração, 16 de julho de 2026).
- [ ] DPA e Contrato principal firmados e referenciados corretamente.
- [ ] Catálogo de escopos (scopes) documentado e alinhado ao RBAC real.
- [ ] Tabela de rate limits conferida com a configuração de produção.
- [ ] Política de versionamento/depreciação publicada na documentação técnica.
- [ ] Lista de sub-operadores atualizada (Supabase, Netlify, VHSYS, Correios, gateways, mensageria).
- [ ] Canal de notificação de incidentes (lemoncapsencapsulados@gmail.com) operante e monitorado.
- [ ] Assinatura de webhooks (HMAC) implementada e documentada.
- [ ] Ambiente sandbox disponível e segregado da produção.
- [ ] Revisão jurídica final por advogado(a) habilitado(a).

### (d) Matriz RACI

| Atividade | GLOP (Fornecedora) | Contratante (Integradora) | DPO/Encarregado | Jurídico |
|---|---|---|---|---|
| Emissão/revogação de credenciais | A/R | C | I | I |
| Custódia e rotação de segredos | C | A/R | I | I |
| Definição e ajuste de rate limits | A/R | I | I | C |
| Versionamento e aviso de depreciação | A/R | I | I | C |
| Tratamento conforme LGPD/DPA | A (Operador) | R (conforme papel) | C/A | C |
| Notificação de incidente | R | R | A | C |
| Resposta a direitos de titulares | R | R | A | C |
| Suspensão por abuso | A/R | I | C | C |
| Revisão contratual periódica | C | I | C | A/R |

Legenda: R = Responsável executa; A = Aprova/presta contas; C = Consultado; I = Informado.

### (e) Plano de Revisão

1. **Periodicidade:** revisão ordinária **anual** e sempre que houver (i) alteração legislativa/regulatória (LGPD, ANPD, CDC, Marco Civil); (ii) mudança material na arquitetura da API, escopos ou sub-operadores; (iii) incidente de segurança relevante; ou (iv) lançamento de nova versão da API com breaking changes.
2. **Responsáveis:** Jurídico (condução), DPO (aderência à LGPD), Engenharia/Segurança (aderência técnica), Produto (escopos e planos).
3. **Registro:** toda revisão gera nova entrada no Controle de Versão e comunicação às Contratantes com o aviso prévio aplicável.

### (f) Controle de Versão

| Versão | Data | Autor/Responsável | Descrição das alterações | Status |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | Chief Legal AI (minuta) | Elaboração inicial do Termo de Uso de API do GLOP | Minuta — pendente de revisão jurídica |
| — | — | a ser designado pela administração | Revisão de aderência à LGPD/DPA | Pendente |
| — | — | Jurídico [PARTE] | Validação final e publicação | Pendente |
