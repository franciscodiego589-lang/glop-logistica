# Política de Cookies e Tecnologias de Rastreamento — GLOP (Global Logistics Platform)

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

**Controladora / Operadora:** [RAZÃO SOCIAL], inscrita no CNPJ sob o nº [CNPJ], com sede em [ENDEREÇO COMPLETO], operadora da plataforma [NOME FANTASIA: GLOP] (Global Logistics Platform), acessível em [URL DO SITE].

**Encarregado pelo Tratamento de Dados Pessoais (DPO):** [NOME DO ENCARREGADO] — [E-MAIL DO DPO/ENCARREGADO].

**Versão:** 1.0 · **Vigência a partir de:** [DATA] · **Última atualização:** [DATA].

---

## Sumário

1. Introdução e objetivo desta Política
2. A quem esta Política se aplica
3. Definições — o que são cookies e tecnologias similares
4. Papéis do GLOP na LGPD (dupla natureza: Controlador e Operador)
5. Por que utilizamos cookies e tecnologias de rastreamento
6. Bases legais para o uso de cookies
7. Categorias de cookies e tecnologias que utilizamos (tabela detalhada)
8. Como o GLOP utiliza cookies e o armazenamento local do navegador
9. Cookies e tecnologias de terceiros
10. Portal público de rastreio (consulta sem login)
11. Transferência internacional de dados relacionada a cookies
12. Gestão, configuração e revogação do consentimento
13. Configurações do navegador e outras ferramentas de controle
14. Impacto de desabilitar cookies
15. Prazos de retenção
16. Segurança da informação aplicada aos cookies e identificadores
17. Cookies e crianças e adolescentes
18. Direitos do titular de dados pessoais
19. Atualizações desta Política
20. Como falar conosco e com o Encarregado (DPO)
21. Modelo de banner e central de gestão de consentimento (texto de referência)
22. Engenharia Jurídica & Governança

---

## 1. Introdução e objetivo desta Política

Esta Política de Cookies e Tecnologias de Rastreamento ("Política") descreve, de forma transparente, como a plataforma [NOME FANTASIA: GLOP] — um SaaS de logística e ERP voltado a operações de dropshipping e infoprodutos no Brasil — utiliza cookies, armazenamento local do navegador e tecnologias correlatas quando você acessa e utiliza nossos ambientes web, o painel autenticado (dashboard operacional), o portal público de rastreamento e demais interfaces.

O GLOP integra pedidos de plataformas de pagamento/checkout e de e-commerces, executa pré-postagem e rastreio junto aos Correios, gerencia coprodução, comissionamento e split de pagamentos, emite documentos fiscais e oferece um portal público de acompanhamento de entregas. Em razão dessa arquitetura, tratamos dados pessoais em diferentes qualidades jurídicas e utilizamos tecnologias de armazenamento no seu dispositivo que precisam ser explicadas de modo claro e específico.

Esta Política integra e deve ser lida em conjunto com a **Política de Privacidade** e os **Termos de Uso** do GLOP. Em caso de conflito aparente sobre o tema "cookies e tecnologias de rastreamento", prevalece o disposto nesta Política.

Nosso objetivo é atender aos princípios da **Lei nº 13.709/2018 (Lei Geral de Proteção de Dados Pessoais — LGPD)**, em especial os da finalidade, adequação, necessidade, livre acesso, transparência, segurança, prevenção e responsabilização; à **Lei nº 12.965/2014 (Marco Civil da Internet)** e seu regulamento; à **Lei nº 8.078/1990 (Código de Defesa do Consumidor — CDC)** no que toca às relações de consumo; e, quando aplicável a titulares na União Europeia/EEE, ao **Regulamento (UE) 2016/679 (GDPR)** e à Diretiva 2002/58/CE (ePrivacy).

## 2. A quem esta Política se aplica

Esta Política se aplica a todo indivíduo que interage com os ambientes digitais do GLOP, considerando os diferentes papéis existentes na plataforma:

- **Produtor / lojista (cliente do GLOP):** contrata o GLOP e opera o painel autenticado. É, em regra, o **Controlador** dos dados dos compradores finais.
- **Coprodutor / afiliado:** participa de esquemas de coprodução, comissionamento e split, podendo acessar o painel e fornecer dados bancários/PIX para repasses.
- **Colaborador do produtor/lojista:** usuário operacional convidado, com papel (role) e permissões (RBAC) atribuídos.
- **Comprador final (titular dos dados):** pessoa cujos dados pessoais (nome, CPF/CNPJ, e-mail, telefone, endereço) são ingeridos a partir das plataformas de checkout/e-commerce e tratados no fluxo logístico. Em regra, o comprador **não faz login** no GLOP; interage sobretudo com o **portal público de rastreio** e com notificações de e-mail/WhatsApp.
- **Operador da plataforma GLOP:** nossa equipe interna, que administra a infraestrutura e o produto.
- **Visitante:** qualquer pessoa que acesse páginas públicas (site institucional, páginas de login, portal de rastreio) sem necessariamente ser usuário cadastrado.

## 3. Definições — o que são cookies e tecnologias similares

**Cookies.** São pequenos arquivos de texto que um site grava no seu navegador (ou dispositivo) quando você o acessa. A cada nova requisição ao mesmo domínio, o navegador reenvia esses arquivos, permitindo reconhecer o dispositivo, manter a sessão ativa, lembrar preferências e coletar informações estatísticas. Podem ser classificados por origem (próprios ou de terceiros) e por duração (de sessão ou persistentes).

- **Cookies próprios (first-party):** definidos pelo domínio do GLOP ([URL DO SITE]).
- **Cookies de terceiros (third-party):** definidos por domínios distintos do GLOP (por exemplo, provedores de infraestrutura, gateways, aplicativos de mensageria).
- **Cookies de sessão:** existem apenas durante a navegação e são apagados ao fechar o navegador.
- **Cookies persistentes:** permanecem por um período determinado (ou até serem apagados manualmente).

**Armazenamento local do navegador (Web Storage).** Tecnologias que gravam dados diretamente no navegador, sem serem reenviadas automaticamente ao servidor a cada requisição:

- **localStorage:** persiste dados no navegador sem prazo de expiração automático (permanece até ser removido). O GLOP o utiliza majoritariamente para **preferências de interface** (tema claro/escuro, estado do menu lateral encolhido, tutoriais/ajuda já vistos, alertas já visualizados).
- **sessionStorage:** persiste dados apenas durante a aba/sessão atual, sendo descartado ao fechá-la.
- **IndexedDB:** banco de dados no navegador usado para cache estruturado de dados da aplicação, quando aplicável.

**Tokens.** Cadeias de caracteres usadas para **autenticação e manutenção de sessão**. No GLOP, a autenticação é feita via **Supabase Auth (JWT)**; tokens de acesso e de atualização (access token / refresh token) são gerenciados pela biblioteca oficial `@supabase/ssr` e podem ser armazenados em **cookies próprios** e/ou no armazenamento local, conforme a estratégia de renderização (SSR/CSR). Esses tokens são **estritamente necessários** para manter você autenticado e para aplicar as regras de isolamento multi-tenant (RLS por empresa) e de permissões (RBAC).

**Pixels de rastreamento (web beacons / tracking pixels).** Imagens minúsculas (frequentemente 1x1) ou trechos de código embarcados em páginas ou e-mails, que sinalizam eventos como abertura de mensagem, carregamento de página ou conversão. Podem ser utilizados por serviços de e-mail transacional, analytics ou marketing quando ativados.

**SDKs, tags e scripts de terceiros.** Códigos fornecidos por terceiros (por exemplo, ferramentas de analytics ou widgets de atendimento) que, ao serem carregados, podem gravar cookies ou identificadores próprios.

**Fingerprinting (identificação por características do dispositivo).** Técnica que combina atributos do navegador/dispositivo (idioma, resolução, fontes, etc.) para inferir um identificador. **O GLOP não emprega fingerprinting para fins de rastreamento publicitário.** Caso venha a utilizar qualquer técnica semelhante para segurança antifraude, esta Política será atualizada e a base legal, informada.

Para fins de consentimento, o GLOP trata **cookies, Web Storage, pixels, tags/SDKs e identificadores equivalentes de forma isonômica**: se a finalidade não for estritamente necessária, aplicam-se as mesmas exigências de consentimento, independentemente da tecnologia empregada.

## 4. Papéis do GLOP na LGPD (dupla natureza: Controlador e Operador)

O GLOP possui **dupla natureza** perante a LGPD, e isso se reflete no tratamento de cookies e identificadores:

**a) GLOP como Operador (art. 5º, VII, da LGPD).** Quando o GLOP trata **dados pessoais do comprador final** (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor), ingeridos das plataformas de checkout/pagamento (Monetizze, Hotmart, Kiwify) e dos e-commerces (Shopify, WooCommerce, Nuvemshop, Mercado Livre) **em nome e por conta do produtor/lojista**, o produtor/lojista é o **Controlador** e o GLOP atua como **Operador**, seguindo suas instruções e o contrato de prestação de serviços / adendo de proteção de dados (DPA). Nesse contexto, decisões sobre cookies que atinjam os titulares compradores (por exemplo, no portal de rastreio) são adotadas de forma coordenada, cabendo ao GLOP implementar salvaguardas técnicas.

**b) GLOP como Controlador (art. 5º, VI, da LGPD).** Quando o GLOP trata dados dos **seus próprios usuários** (produtores/lojistas, coprodutores/afiliados e colaboradores) para operar, autenticar, dar suporte, faturar, prevenir fraudes e melhorar a plataforma — inclusive por meio de **cookies de sessão/autenticação, preferências de interface e, se ativados, analíticos** —, o GLOP é o **Controlador** e determina as finalidades e os meios do tratamento.

Essa distinção define **quem responde pela escolha das finalidades dos cookies** e **quem deve prestar informações e coletar consentimento** em cada camada. Sempre que o GLOP agir como Operador, seguirá as instruções documentadas do Controlador; quando agir como Controlador, responderá diretamente pelas escolhas descritas nesta Política.

## 5. Por que utilizamos cookies e tecnologias de rastreamento

Utilizamos cookies e tecnologias correlatas para, entre outras finalidades legítimas e específicas:

- **Autenticar e manter sua sessão** no painel operacional (login via Supabase Auth/JWT), inclusive aplicando o isolamento multi-tenant (RLS por empresa) e o controle de permissões (RBAC via `has_permission`).
- **Proteger a plataforma** contra fraudes, acessos não autorizados, ataques automatizados (CSRF, session hijacking) e uso indevido, preservando a integridade dos webhooks de entrada/saída e das credenciais de API guardadas em modo write-only.
- **Lembrar suas preferências de interface**, como tema claro/escuro, menu lateral encolhido/expandido, itens de ajuda/tutorial já visualizados e alertas já lidos, para que sua experiência seja consistente entre visitas.
- **Garantir o funcionamento de recursos essenciais**, como balanceamento de carga, roteamento e entrega das páginas via hospedagem SSR na Netlify e comunicação segura com o backend Supabase.
- **Compreender o uso da plataforma** (quando você consentir com cookies analíticos), de forma agregada, para corrigir erros e priorizar melhorias.
- **Executar comunicações operacionais**, como o disparo de e-mails/WhatsApp de notificação ao comprador com o código de rastreio — sendo que provedores de e-mail/mensageria podem empregar pixels para registrar entrega/abertura, conforme sua própria configuração.

Não utilizamos cookies para tomar decisões automatizadas com efeitos jurídicos relevantes sobre o titular sem a devida base legal e informação. Não vendemos dados pessoais e não empregamos cookies para publicidade comportamental de terceiros sem consentimento válido e específico.

## 6. Bases legais para o uso de cookies

O uso de cada tecnologia observa uma base legal da LGPD (arts. 7º e 11) e, quando aplicável, do GDPR:

**a) Cookies estritamente necessários (essenciais).** Dispensam consentimento prévio. Fundamentam-se na **execução de contrato e de procedimentos preliminares** (art. 7º, V, LGPD), no **legítimo interesse** para segurança e prevenção à fraude (art. 7º, IX, LGPD) e no **cumprimento de obrigação legal/regulatória** quando cabível (art. 7º, II, LGPD). Sem esses cookies, a plataforma não funciona (por exemplo, você não consegue permanecer autenticado). No GDPR, equivalem a cookies "estritamente necessários" isentos de consentimento nos termos da Diretiva ePrivacy.

**b) Cookies e tecnologias não essenciais (funcionais opcionais, analíticos e de marketing).** Dependem do seu **consentimento livre, informado, inequívoco e destacado** (art. 7º, I, e art. 8º da LGPD; art. 6(1)(a) do GDPR). O consentimento é coletado por meio de banner/central de gestão, é granular por categoria, pode ser recusado sem prejuízo do acesso às funções essenciais e pode ser **revogado a qualquer tempo** com a mesma facilidade com que foi concedido (art. 8º, §5º, LGPD).

**c) Preferências de interface salvas no navegador (tema, menu, ajuda, alertas vistos).** Quando armazenadas **apenas localmente** (localStorage/sessionStorage), sem identificar você para além do necessário e sem finalidade de rastreamento, são tratadas como **funcionais necessárias à experiência solicitada por você**, com respaldo na **execução do serviço** e no seu **legítimo interesse** em manter as preferências escolhidas. Ainda assim, informamos essas tecnologias nesta Política em nome da transparência.

Sempre que a base legal for o **legítimo interesse**, realizamos (e mantemos registrado) o **teste de proporcionalidade / balanceamento (LIA)**, ponderando finalidade, necessidade e impacto sobre o titular, assegurando-lhe o direito de oposição (art. 18, LGPD).

## 7. Categorias de cookies e tecnologias que utilizamos (tabela detalhada)

A tabela a seguir descreve as **categorias**, sua **finalidade**, **exemplos técnicos**, **origem** (próprio/terceiro), **duração típica** e **base legal**. Os nomes técnicos são exemplificativos e podem variar conforme atualizações da plataforma e dos provedores; a **central de gestão de consentimento** exibe a lista vigente.

| Categoria | Finalidade | Exemplos (tecnologia / identificador) | Origem | Duração típica | Base legal |
|---|---|---|---|---|---|
| **Estritamente necessários** | Autenticação, manutenção de sessão, segurança, isolamento multi-tenant (RLS) e roteamento. Sem eles, a plataforma não funciona. | Cookies/token de sessão do **Supabase Auth (JWT)** (ex.: `sb-<projeto>-auth-token`, `sb-access-token`, `sb-refresh-token`); token **CSRF**; cookie de balanceamento/roteamento da **Netlify**; identificador de sessão do servidor. | Próprio e provedores de infraestrutura (Supabase, Netlify) atuando como suboperadores | Sessão a ~1 ano (refresh token), conforme renovação | Execução de contrato (art. 7º, V) + legítimo interesse em segurança (art. 7º, IX) |
| **Funcionais (preferências)** | Lembrar preferências de interface e escolhas do usuário para personalizar a experiência solicitada. | **localStorage**/**sessionStorage** com: tema claro/escuro; estado do menu lateral (encolhido/expandido); tutoriais/ajuda já vistos; **alertas já visualizados**; idioma; última empresa/branch selecionada. | Próprio | Persistente (até limpeza pelo usuário) ou sessão | Execução do serviço + legítimo interesse; consentimento quando não essenciais |
| **Analíticos / de desempenho** | Medir uso de forma agregada, identificar erros, entender fluxos e priorizar melhorias. **Somente com consentimento.** | Cookies/identificadores de ferramenta de analytics (ex.: `_ga`, `_gid`, `_ga_<id>` — Google Analytics; ou solução equivalente/privacy-friendly); pixels de medição; identificador anônimo de sessão de produto. | Próprio e/ou terceiro (provedor de analytics) | Sessão a ~2 anos, conforme provedor | Consentimento (art. 7º, I; art. 8º) |
| **De marketing / comunicação** | Medir efetividade de campanhas e comunicações; atribuição de conversão; remarketing, se e quando ativado. **Somente com consentimento.** | Pixels de campanha; cookies de plataformas de anúncios; **pixels de e-mail** para registrar entrega/abertura das notificações de rastreio; parâmetros de UTM associados. | Terceiro (plataformas de anúncio/e-mail) | Sessão a ~13 meses, conforme provedor | Consentimento (art. 7º, I; art. 8º) |

Observações relevantes:

- Os cookies **estritamente necessários** ficam sempre ativos e não podem ser desabilitados pela central de consentimento, pois sem eles não é possível autenticar, isolar dados por empresa (RLS) nem entregar as páginas com segurança.
- Categorias **analíticas e de marketing só são ativadas após consentimento** e permanecem **desligadas por padrão** (opt-in). Nenhum cookie não essencial é gravado antes da sua manifestação de vontade, ressalvados os estritamente necessários.
- O GLOP prioriza **minimização**: só coleta o necessário para a finalidade declarada e evita, no ambiente autenticado, cookies de terceiros de publicidade.

## 8. Como o GLOP utiliza cookies e o armazenamento local do navegador

**8.1. Sessão autenticada (login).** Ao acessar o painel do GLOP, a autenticação ocorre via **Supabase Auth (JWT)**. Um **token de acesso** de curta duração e um **token de atualização** (refresh) são gerenciados pela biblioteca `@supabase/ssr` e podem residir em **cookies próprios** e/ou no armazenamento do navegador. Esses tokens permitem: (i) manter você logado sem digitar credenciais a cada página; (ii) aplicar as políticas de **Row-Level Security (RLS)** que isolam os dados por `tenant_id`/`company_id`; e (iii) fazer valer as **permissões (RBAC)** que definem o que cada papel pode ver e fazer. São **estritamente necessários** e sensíveis do ponto de vista de segurança — nunca compartilhamos esses tokens com terceiros para fins de marketing.

**8.2. Preferências salvas no navegador.** O GLOP grava, no seu navegador, preferências que **não saem do seu dispositivo** salvo quando necessário para operar a conta:

- **Tema** (claro/escuro) — para respeitar sua escolha visual;
- **Estado do menu lateral** (encolhido/expandido) — para preservar seu layout de trabalho;
- **Ajuda/tutoriais já vistos** — para não repetir dicas que você já dispensou;
- **Alertas já visualizados** — para não reexibir avisos que você já leu;
- **Contexto de trabalho** — por exemplo, última empresa/filial (branch) selecionada e preferências de listagem/paginação.

Essas preferências melhoram a usabilidade e, por serem armazenadas majoritariamente em **localStorage/sessionStorage**, não são reenviadas automaticamente ao servidor a cada requisição.

**8.3. Segurança e integridade.** Utilizamos cookies/identificadores para proteção contra **CSRF**, detecção de sessões inválidas, controle de expiração e reforço das trilhas de auditoria (a plataforma registra `created_by`/`updated_by`/`deleted_at` e mantém auditoria por triggers no banco). Esses mecanismos são indispensáveis para a segurança dos dados sensíveis que trafegam pelos fluxos (por exemplo, PII de compradores e dados bancários/PIX de coprodutores).

**8.4. Operação e comunicações.** Ao processar os fluxos do GLOP — **pull de pedidos** de plataformas como **Monetizze/Hotmart/Kiwify** e e-commerces (**Shopify/WooCommerce/Nuvemshop/Mercado Livre**), **pré-postagem e rastreio nos Correios (PPN/SRO)**, **coprodução/split de pagamentos (AppMax)** e **emissão de NF-e via VHSYS** — o tratamento de dados ocorre predominantemente **no backend** (servidor/banco), e **não depende de cookies de navegação** do titular comprador. Cookies e Web Storage atuam sobretudo na **camada de interface** de quem opera o painel. Já as **notificações ao comprador** por e-mail/WhatsApp podem envolver **pixels** de entrega/abertura, conforme o provedor de mensageria configurado.

## 9. Cookies e tecnologias de terceiros

Determinadas funcionalidades dependem de terceiros que podem gravar cookies ou identificadores próprios, sujeitos às **políticas de privacidade e de cookies desses terceiros**. Entre os principais contextos:

- **Infraestrutura (suboperadores):** **Supabase** (banco de dados, autenticação e storage) e **Netlify** (hospedagem SSR). Podem definir cookies **estritamente necessários** de sessão, segurança e roteamento.
- **Plataformas de pagamento/checkout e e-commerces:** **Monetizze, Hotmart, Kiwify, Shopify, WooCommerce, Nuvemshop, Mercado Livre**. A integração de pedidos ocorre via **API/webhooks no backend**; contudo, se você for redirecionado a páginas desses provedores ou embutir componentes deles, poderão ser gravados cookies próprios desses ambientes, regidos por suas respectivas políticas.
- **Split e repasses:** **AppMax** (split de pagamentos e tratamento de dados de PIX/bancários de coprodutores). O tratamento ocorre por integração de backend; eventuais páginas/redirecionamentos do provedor seguem suas políticas.
- **Emissão fiscal:** **VHSYS** (NF-e/CT-e/MDF-e/NFS-e), por integração de backend.
- **Correios:** integração de **pré-postagem (PPN)** e **rastreio (SRO)** por API; o **portal público de rastreio** do GLOP consome dados de status.
- **Mensageria e e-mail:** provedores de **WhatsApp** e de **e-mail transacional** para notificar o comprador com o código de rastreio; podem empregar **pixels** de entrega/abertura conforme sua configuração.
- **Analytics/Marketing (se ativados):** ferramentas de medição e campanhas, ativadas **somente mediante consentimento**.

O GLOP não controla os cookies definidos diretamente por esses terceiros em seus próprios domínios. Recomendamos a leitura das políticas de cada provedor. Quando o terceiro atuar como **suboperador** do GLOP, exigimos contratos e salvaguardas compatíveis com a LGPD.

## 10. Portal público de rastreio (consulta sem login)

O GLOP disponibiliza um **portal público de rastreamento** em que o comprador consulta o status da entrega **pelo código de rastreio, sem realizar login**. Nesse portal:

- Exibimos **apenas status neutro da entrega** (por exemplo, "postado", "em trânsito", "saiu para entrega", "entregue"), **sem expor PII sensível** do comprador.
- Utilizamos **apenas cookies/armazenamento estritamente necessários** ao funcionamento e à segurança da página (por exemplo, prevenção de abuso e roteamento), evitando cookies de marketing.
- Eventuais cookies analíticos só serão utilizados **mediante consentimento** obtido no próprio portal, quando aplicável.

O objetivo é permitir a consulta com **mínima coleta** e **sem rastreamento desnecessário**, em coerência com o princípio da necessidade (art. 6º, III, LGPD).

## 11. Transferência internacional de dados relacionada a cookies

Alguns provedores de infraestrutura e ferramentas (por exemplo, **Supabase**, **Netlify** e eventuais serviços de analytics/mensageria) podem processar dados em **servidores localizados fora do Brasil**. Quando o uso de cookies/identificadores implicar **transferência internacional de dados pessoais**, observamos os requisitos dos **arts. 33 a 36 da LGPD**, adotando salvaguardas como cláusulas contratuais adequadas e verificação do nível de proteção, conforme regulamentação da **ANPD**. Detalhes sobre transferências internacionais constam também da **Política de Privacidade** do GLOP.

## 12. Gestão, configuração e revogação do consentimento

Você controla os cookies não essenciais das seguintes formas:

1. **Banner de consentimento (primeiro acesso).** Ao acessar o GLOP, exibimos um banner com opções de **Aceitar todos**, **Rejeitar não essenciais** e **Personalizar/Gerenciar preferências**. Nenhum cookie não essencial é ativado antes da sua escolha.
2. **Central de Preferências de Cookies.** Disponível a qualquer momento (por exemplo, em rodapé, menu de configurações ou link "Preferências de Cookies"), permite **ativar/desativar por categoria** (funcionais, analíticos, marketing), com informações sobre finalidade e duração. Os estritamente necessários permanecem sempre ativos.
3. **Revogação a qualquer tempo.** Você pode **retirar o consentimento** com a mesma facilidade com que o concedeu (art. 8º, §5º, LGPD). A revogação não afeta a licitude do tratamento realizado antes dela.
4. **Registro de consentimento.** Mantemos **registro (prova) das manifestações de consentimento** — categorias aceitas/recusadas, data/hora e versão da Política vigente —, em atenção ao princípio da responsabilização (art. 6º, X, LGPD).
5. **Renovação periódica.** Poderemos solicitar nova manifestação quando houver mudança relevante de finalidades, inclusão de novas ferramentas ou decurso de prazo razoável.

## 13. Configurações do navegador e outras ferramentas de controle

Além da nossa central, você pode gerenciar cookies diretamente no navegador — bloquear, limitar a cookies de terceiros, apagar os existentes ou receber avisos antes da gravação. Os caminhos variam por navegador (Google Chrome, Mozilla Firefox, Microsoft Edge, Apple Safari, entre outros); consulte a seção de **privacidade/segurança** do seu navegador. Você também pode:

- **Limpar o localStorage/sessionStorage** pelas ferramentas do navegador (isso apagará preferências como tema e menu, que serão recriadas conforme seu uso).
- Utilizar o modo de **navegação anônima/privada**, que descarta cookies e armazenamento ao encerrar a sessão.
- Ativar sinais de preferência de privacidade quando suportados.

Atenção: bloquear cookies **estritamente necessários** pode impedir o login e o funcionamento do painel.

## 14. Impacto de desabilitar cookies

Desabilitar categorias de cookies pode afetar sua experiência:

- **Estritamente necessários desabilitados:** você **não conseguirá se autenticar** nem permanecer logado; recursos de segurança (CSRF, sessão) e o isolamento por empresa podem falhar; partes do painel deixarão de funcionar.
- **Funcionais desabilitados:** suas **preferências não serão lembradas** (tema volta ao padrão, menu não preserva o estado, dicas de ajuda e alertas podem reaparecer, contexto de empresa/filial pode não ser retido).
- **Analíticos desabilitados:** deixamos de coletar estatísticas de uso; **você continua usando normalmente**, mas perdemos sinais que ajudam a melhorar a plataforma e corrigir erros.
- **Marketing desabilitados:** comunicações/campanhas podem ficar **menos relevantes** e a medição de conversão fica limitada; **não há impacto no acesso** às funções contratadas.

O acesso às **funcionalidades essenciais** contratadas nunca é condicionado à aceitação de cookies **não essenciais**.

## 15. Prazos de retenção

Cookies persistentes e identificadores têm prazos de expiração definidos por categoria e provedor (ver tabela da Seção 7). Como regra:

- **Estritamente necessários:** duram o tempo da sessão ou o necessário para renovar a autenticação com segurança (tokens de atualização podem durar até ~1 ano, conforme configuração).
- **Funcionais (preferências):** persistem no dispositivo até você limpá-los.
- **Analíticos/Marketing:** seguem os prazos do provedor (tipicamente de meses a ~2 anos), e são apagados/desativados ao revogar o consentimento.

Dados pessoais eventualmente derivados de cookies são retidos **apenas pelo tempo necessário** às finalidades ou por obrigação legal, findos os quais são eliminados ou anonimizados (arts. 15 e 16, LGPD), observado o **soft-delete** e as trilhas de auditoria da plataforma.

## 16. Segurança da informação aplicada aos cookies e identificadores

Adotamos medidas técnicas e organizacionais compatíveis com boas práticas de segurança (referências como ISO/IEC 27001, ISO/IEC 27701, NIST, OWASP e princípios de Zero Trust), incluindo:

- **Transmissão criptografada (HTTPS/TLS)** e uso de atributos de segurança em cookies sensíveis quando aplicável (por exemplo, `Secure`, `HttpOnly`, `SameSite`).
- **Isolamento multi-tenant por RLS** e **controle de acesso por RBAC**, de modo que tokens de sessão só concedam acesso aos dados da empresa correta.
- **Credenciais de API guardadas em modo write-only**, **webhooks** com verificação e **logs de API**.
- **Trilha de auditoria por triggers** e colunas de auditoria (`created_by`, `updated_by`, `deleted_at`) em todo registro.
- **Minimização e segregação**: cookies de interface não carregam dados sensíveis; PII de compradores e dados bancários/PIX de coprodutores são tratados no backend, sob controles reforçados.

Nenhum método é 100% infalível; em caso de incidente de segurança relevante, seguimos nosso plano de resposta e as obrigações de comunicação à **ANPD** e aos titulares, quando exigível (art. 48, LGPD).

## 17. Cookies e crianças e adolescentes

O GLOP destina-se a **uso profissional/empresarial** por produtores, lojistas, coprodutores e colaboradores maiores de idade. Não direcionamos cookies de marketing a crianças e adolescentes. Caso venhamos a tratar dados de menores em algum contexto, observaremos o **melhor interesse** e as exigências do **art. 14 da LGPD**.

## 18. Direitos do titular de dados pessoais

Nos termos do **art. 18 da LGPD**, você pode requerer: confirmação da existência de tratamento; acesso aos dados; correção; anonimização, bloqueio ou eliminação de dados desnecessários/excessivos; portabilidade; informação sobre compartilhamento; informação sobre a possibilidade de não consentir e as consequências; e **revogação do consentimento**. Titulares no EEE têm direitos correspondentes no **GDPR** (incluindo oposição e restrição).

Importante: quando o GLOP atua como **Operador** (dados dos compradores tratados em nome do produtor/lojista), os pedidos de titulares podem ser **encaminhados ao respectivo Controlador** (o produtor/lojista) ou atendidos de forma coordenada, conforme o contrato. Quando o GLOP atua como **Controlador** (dados de seus usuários), atendemos diretamente. Em ambos os casos, o canal do Encarregado está na Seção 20.

## 19. Atualizações desta Política

Esta Política pode ser atualizada a qualquer tempo em razão de mudanças legislativas, decisões e orientações da **ANPD**, evolução tecnológica, novas integrações (por exemplo, novos gateways, e-commerces ou ferramentas de analytics) ou aprimoramentos de produto. Alterações relevantes serão comunicadas por meios adequados (aviso na plataforma, banner ou e-mail) e, quando exigirem, solicitaremos **nova manifestação de consentimento**. A data da última atualização consta no cabeçalho e no controle de versão (Seção 22.f). Recomendamos a consulta periódica.

## 20. Como falar conosco e com o Encarregado (DPO)

- **Controladora/Operadora:** [RAZÃO SOCIAL] — [NOME FANTASIA: GLOP], CNPJ [CNPJ], [ENDEREÇO COMPLETO].
- **Encarregado(a) pelo Tratamento de Dados Pessoais (DPO):** [NOME DO ENCARREGADO].
- **E-mail para assuntos de privacidade/cookies:** [E-MAIL DO DPO/ENCARREGADO].
- **Site:** [URL DO SITE].

Responderemos às solicitações nos prazos e formas previstos na LGPD. Você também pode peticionar à **Autoridade Nacional de Proteção de Dados (ANPD)**.

---

## 21. Modelo de banner e central de gestão de consentimento (texto de referência)

O texto abaixo é um **modelo** para implementação do banner e da central de preferências. Deve ser adaptado à identidade visual e revisado juridicamente.

### 21.1. Banner (primeira camada — exibido no primeiro acesso)

**Título:** Nós usamos cookies

**Corpo:** O GLOP utiliza cookies e tecnologias similares **estritamente necessários** para autenticar sua sessão, manter a segurança e fazer a plataforma funcionar. Com o seu consentimento, também usamos cookies **funcionais, analíticos e de marketing** para melhorar sua experiência e nossos serviços. Você pode aceitar, recusar os não essenciais ou personalizar suas escolhas. Saiba mais na nossa Política de Cookies e na Política de Privacidade.

**Botões:**
- **Aceitar todos**
- **Rejeitar não essenciais**
- **Personalizar preferências**

**Links:** Política de Cookies · Política de Privacidade

### 21.2. Central de Preferências (segunda camada — granular por categoria)

**Título:** Central de Preferências de Cookies

**Introdução:** Gerencie suas preferências por categoria. Os cookies estritamente necessários permanecem sempre ativos porque, sem eles, a plataforma não funciona. Você pode alterar suas escolhas a qualquer momento nesta central.

- **Estritamente necessários — Sempre ativos.** Autenticação (Supabase Auth/JWT), segurança (CSRF/sessão), isolamento por empresa (RLS) e roteamento (Netlify). [Interruptor bloqueado em "Ativado"]
- **Funcionais — [Ativar/Desativar].** Lembram preferências como tema, estado do menu, ajuda/tutoriais e alertas já vistos, e o contexto de empresa/filial.
- **Analíticos — [Ativar/Desativar].** Coletam estatísticas agregadas de uso para melhorar a plataforma e corrigir erros. Desativados por padrão.
- **Marketing — [Ativar/Desativar].** Medem campanhas e comunicações (incluindo pixels de e-mail de notificação) e atribuição de conversão. Desativados por padrão.

**Botões:** **Salvar preferências** · **Aceitar todos** · **Rejeitar não essenciais**

**Rodapé da central:** Para exercer seus direitos ou falar com nosso Encarregado (DPO), contate [E-MAIL DO DPO/ENCARREGADO]. Versão da Política: 1.0 — [DATA].

### 21.3. Aviso do portal público de rastreio (sem login)

**Corpo:** Esta página de rastreamento usa apenas cookies estritamente necessários para funcionar com segurança e exibe somente o status da sua entrega, sem dados pessoais sensíveis. Se utilizarmos medição de uso, pediremos seu consentimento. Consulte a Política de Cookies.

---

## 22. Engenharia Jurídica & Governança

### 22.a. Fundamentação — por que as principais cláusulas existem

- **Dupla natureza Controlador/Operador (Seção 4):** decorre dos conceitos dos **arts. 5º, VI e VII, e 39 da LGPD**. O GLOP é Operador ao tratar PII do comprador em nome do produtor/lojista (que é Controlador) e Controlador quanto a seus próprios usuários. Definir isso delimita responsabilidades, deveres de informação e coleta de consentimento em cada camada.
- **Definições de cookies e tecnologias equivalentes (Seção 3):** transparência e informação adequada (**art. 6º, VI, e art. 9º da LGPD**; **art. 7º, VIII, do Marco Civil**). Tratar Web Storage, pixels e tokens de forma isonômica ao cookie segue a lógica do **GDPR/Diretiva ePrivacy (art. 5(3))** e orientações da ANPD.
- **Bases legais diferenciadas (Seção 6):** essenciais amparados em **execução de contrato (art. 7º, V)**, **legítimo interesse (art. 7º, IX)** e **obrigação legal (art. 7º, II)**; não essenciais em **consentimento (art. 7º, I, e art. 8º)**. O legítimo interesse exige **teste de balanceamento (LIA)** e direito de oposição (**art. 18**).
- **Consentimento granular, opt-in e revogável (Seções 6, 12 e 21):** cumpre o **art. 8º, §§4º e 5º**, exigindo consentimento destacado, específico e tão fácil de retirar quanto de conceder; alinhado ao **GDPR (arts. 4(11) e 7)**.
- **Necessidade e minimização no portal público de rastreio (Seção 10):** princípios da **necessidade e finalidade (art. 6º, I e III)**; evita exposição de PII e rastreamento desnecessário.
- **Transferência internacional (Seção 11):** **arts. 33 a 36 da LGPD**, pois Supabase/Netlify podem processar fora do Brasil.
- **Segurança (Seção 16):** **arts. 6º, VII, 46 a 49 da LGPD**; boas práticas ISO 27001/27701, NIST, OWASP.
- **Relação de consumo (portal e notificações):** **CDC (arts. 6º, III, e 43)** quanto à informação clara e ao tratamento de dados do consumidor; deveres de boa-fé objetiva do **Código Civil (arts. 421 e 422)**.
- **Direitos do titular (Seção 18):** **art. 18 da LGPD** e correspondentes do **GDPR**.

### 22.b. Riscos que o documento mitiga

- **Sanções da ANPD** por uso de cookies não essenciais sem consentimento válido (advertência, multa até 2% do faturamento limitada a R$ 50 milhões por infração, publicização).
- **Ações judiciais e coletivas** por violação de privacidade e por informação inadequada ao consumidor (CDC).
- **Responsabilização por gravar cookies antes do consentimento** (ausência de opt-in) e por dificultar a revogação.
- **Confusão de papéis** Controlador/Operador, que geraria omissão no atendimento a titulares e no acordo de tratamento (DPA).
- **Transferência internacional irregular** sem salvaguardas.
- **Vazamento por tokens de sessão** mal protegidos (session hijacking, CSRF).
- **Falta de prova de consentimento** (accountability), enfraquecendo defesa em fiscalizações.
- **Dano reputacional** perante produtores/lojistas e compradores.

### 22.c. Checklist de implementação

1. Preencher todos os placeholders ([RAZÃO SOCIAL], [CNPJ], [ENDEREÇO COMPLETO], [E-MAIL DO DPO/ENCARREGADO], [NOME DO ENCARREGADO], [URL DO SITE], [DATA]).
2. Implementar **Consent Management Platform (CMP)** com opt-in por categoria e bloqueio de cookies não essenciais antes do consentimento.
3. Garantir que **nenhum script analítico/marketing** carregue antes do consentimento (revisar tags e SDKs).
4. Configurar atributos **Secure/HttpOnly/SameSite** nos cookies de sessão do Supabase/servidor onde aplicável.
5. Realizar **inventário/varredura de cookies e Web Storage** (scan periódico) e manter a tabela da Seção 7 atualizada.
6. Documentar o **teste de legítimo interesse (LIA)** para cookies essenciais/funcionais.
7. Registrar e armazenar **provas de consentimento** (categorias, timestamp, versão da Política).
8. Publicar a Política e vincular no **rodapé, tela de login e portal de rastreio**; disponibilizar link "Preferências de Cookies".
9. Alinhar o **DPA com produtores/lojistas** (papéis, cookies do portal, atendimento a titulares).
10. Revisar contratos/salvaguardas de **suboperadores** (Supabase, Netlify, provedores de e-mail/WhatsApp, analytics).
11. Mapear **transferências internacionais** e adotar cláusulas adequadas.
12. Validar o **portal público de rastreio** para não expor PII e usar apenas cookies necessários.
13. Testar fluxo de **revogação** (deve ser tão fácil quanto conceder) e de renovação periódica.
14. Treinar suporte/produto sobre **impacto de desabilitar** e sobre respostas a titulares.
15. Submeter a **minuta à revisão de advogado(a) habilitado(a)** antes de produção.

### 22.d. Matriz RACI

| Atividade | DPO/Encarregado | Jurídico | Engenharia/Produto | Segurança da Informação | Marketing |
|---|---|---|---|---|---|
| Redação e revisão da Política | A | R | C | C | I |
| Implementação da CMP e opt-in | C | C | R | C | I |
| Bloqueio de scripts antes do consentimento | I | C | R | A | C |
| Inventário/scan de cookies e Web Storage | A | I | R | C | C |
| Configuração de segurança de cookies/tokens | C | I | C | R/A | I |
| Registro/prova de consentimento | A | C | R | C | I |
| DPA com produtores/lojistas | A | R | C | C | I |
| Gestão de suboperadores e transferência internacional | A | R | C | C | I |
| Atendimento a direitos de titulares | R/A | C | C | C | I |
| Campanhas e pixels de marketing (pós-consentimento) | C | C | C | I | R/A |
| Aprovação final para produção | A | R | C | C | I |

Legenda: R = Responsável pela execução; A = Aprovador (accountable); C = Consultado; I = Informado.

### 22.e. Plano de revisão (periodicidade e gatilhos)

- **Periodicidade mínima:** revisão **semestral** da Política e do inventário de cookies; **scan trimestral** de cookies/Web Storage.
- **Gatilhos de revisão extraordinária:**
  - Nova legislação, regulamento ou orientação da **ANPD**; decisões relevantes de tribunais.
  - Inclusão/troca de **integrações** (novos gateways, e-commerces, provedores de e-mail/WhatsApp, analytics, split).
  - Mudança de **provedor de infraestrutura** (Supabase/Netlify) ou de local de processamento (transferência internacional).
  - Novo recurso que grave cookies/identificadores ou altere finalidades.
  - **Incidente de segurança** envolvendo sessões/tokens.
  - Reclamações recorrentes de titulares ou fiscalização.

### 22.f. Controle de versão

| Versão | Data | Autor | Mudança |
|---|---|---|---|
| 1.0 | [DATA] | Chief Legal AI (minuta) — revisão pendente por [NOME DO ENCARREGADO] | Criação da Política de Cookies e Tecnologias de Rastreamento do GLOP, com categorias, bases legais, dupla natureza Controlador/Operador, portal público de rastreio, terceiros/suboperadores, gestão de consentimento e modelo de banner/central. |
| | | | |

---

*Documento pertencente a [RAZÃO SOCIAL] — [NOME FANTASIA: GLOP]. Uso interno e publicação sujeitos à revisão jurídica final.*
