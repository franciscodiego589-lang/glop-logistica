> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# Código de Ética e Conduta — GLOP (Global Logistics Platform)

**Razão Social:** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA
**Nome Fantasia:** [NOME FANTASIA: GLOP]
**CNPJ:** 55.836.075/0001-07
**Endereço:** Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190
**Encarregado de Dados (DPO):** a ser designado pela administração — lemoncapsencapsulados@gmail.com
**Vigência a partir de:** 16 de julho de 2026
**Aprovado por:** [ÓRGÃO/DIRETORIA APROVADORA]

---

## Sumário

1. Preâmbulo e Mensagem da Direção
2. Objetivo
3. Abrangência e Escopo
4. Público-Alvo e Destinatários
5. Definições
6. Valores e Princípios Fundamentais
7. Conduta Profissional Geral
8. Conflitos de Interesse
9. Anticorrupção e Antissuborno
10. Antifraude, Prevenção à Lavagem de Dinheiro e Integridade Financeira
11. Uso de Recursos, Ativos e Sistemas
12. Uso e Tratamento de Informações e Dados Pessoais (LGPD)
13. Confidencialidade e Sigilo
14. Segurança da Informação e Cibersegurança
15. Relações com Clientes (Produtores, Lojistas e Infoprodutores)
16. Relações com Compradores e Titulares de Dados (Consumidores)
17. Relações com Fornecedores e Sub-operadores
18. Relações com Transportadores e Parceiros Logísticos
19. Relações com Coprodutores, Afiliados e Parceiros de Split
20. Relações Institucionais, Concorrência e Poder Público
21. Comunicação, Redes Sociais e Uso de Marca
22. Diversidade, Inclusão, Assédio e Ambiente de Trabalho
23. Direitos Humanos, Trabalho e Sustentabilidade
24. Uso Responsável de Inteligência Artificial (LOGIA)
25. Canal de Ética e Denúncias
26. Investigação, Apuração e Não Retaliação
27. Medidas Disciplinares e Consequências
28. Termo de Ciência e Adesão
29. Vigência, Divulgação e Revisão
30. Engenharia Jurídica & Governança

---

## 1. Preâmbulo e Mensagem da Direção

A [NOME FANTASIA: GLOP], operada por LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, é uma plataforma SaaS de logística e ERP (Global Logistics Platform) voltada ao mercado brasileiro de dropshipping e infoprodutos. A GLOP integra e automatiza o ciclo logístico completo — da ingestão de pedidos via gateways e e-commerces, passando pela emissão de documentos fiscais, pré-postagem e rastreamento junto aos Correios, até a comunicação com o comprador e a apuração de comissões, coproduções e repasses financeiros.

Por manipular dados pessoais sensíveis do ponto de vista econômico e de identificação (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto adquirido e valor), por operar com fluxos financeiros de terceiros (split, PIX, dados bancários) e por atuar simultaneamente como **Operadora** (dados de compradores tratados em nome dos produtores/lojistas Controladores) e como **Controladora** (dados dos próprios usuários e colaboradores), a GLOP assume responsabilidade jurídica, técnica e ética elevada.

Este Código de Ética e Conduta é a expressão formal do compromisso da GLOP com a integridade, a legalidade, a transparência e o respeito às pessoas. Ele não é um documento decorativo: é norma interna de observância obrigatória, cujo descumprimento acarreta consequências previstas neste instrumento, na legislação aplicável e nos contratos vigentes.

A Direção da GLOP declara tolerância zero à corrupção, à fraude, ao vazamento de dados, ao uso indevido de informação privilegiada e a qualquer conduta que comprometa a confiança de clientes, compradores, parceiros e da sociedade.

## 2. Objetivo

Este Código tem por objetivo:

1. Estabelecer os valores, princípios e padrões de conduta ética esperados de todos os destinatários no exercício de suas atividades relacionadas à GLOP.
2. Orientar a tomada de decisão diante de dilemas éticos, conflitos de interesse e situações de risco.
3. Prevenir, detectar e remediar condutas ilícitas ou antiéticas, com destaque para corrupção, fraude, uso indevido de dados pessoais e quebra de confidencialidade.
4. Assegurar a conformidade com o ordenamento jurídico brasileiro, em especial a Lei nº 13.709/2018 (LGPD), a Lei nº 12.846/2013 (Lei Anticorrupção), a Lei nº 8.078/1990 (Código de Defesa do Consumidor) e demais normas aplicáveis.
5. Sustentar a cultura de integridade e o Programa de Compliance da GLOP, servindo de referência para políticas específicas (privacidade, segurança da informação, anticorrupção, conflitos de interesse e canal de ética).

## 3. Abrangência e Escopo

Este Código aplica-se a todas as atividades, unidades, ambientes e sistemas da GLOP, incluindo, sem limitação:

1. A operação da plataforma SaaS (Next.js + Supabase/PostgreSQL, com RLS multi-tenant na hierarquia Tenant → Company → Branch → Membership, Supabase Auth/JWT e Supabase Storage), hospedada em ambiente SSR na Netlify.
2. Os fluxos de ingestão de pedidos via API (Monetizze, Hotmart, Kiwify) e via e-commerces e marketplaces (Shopify, WooCommerce, Nuvemshop, Mercado Livre).
3. Os fluxos logísticos junto aos Correios: pré-postagem (PPN), rastreamento (SRO) e notificação ao comprador por e-mail e WhatsApp.
4. Os fluxos fiscais de emissão de NF-e via VHSYS e demais documentos fiscais.
5. Os fluxos financeiros de coprodução, afiliação, comissionamento, apuração, repasses e split (incluindo integração com AppMax e dados de PIX/bancários).
6. O Portal Público de Rastreio (acesso sem login, que expõe apenas status neutro).
7. A relação com todos os sub-operadores e fornecedores de infraestrutura e serviços: Supabase, Netlify, VHSYS, Correios, gateways de pagamento e provedores de mensageria (WhatsApp/e-mail).

O Código aplica-se em qualquer local (presencial, remoto ou híbrido), em qualquer dispositivo (corporativo ou pessoal utilizado para fins de trabalho) e em qualquer horário em que se atue em nome da GLOP.

## 4. Público-Alvo e Destinatários

São destinatários deste Código, obrigados à sua observância integral:

1. Sócios, administradores, membros de conselhos e diretoria da LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA.
2. Empregados, estagiários, aprendizes e trainees.
3. Prestadores de serviço, terceirizados, consultores, autônomos (PJ e PF) e temporários.
4. Fornecedores, sub-operadores e parceiros contratados, no que couber e nos termos dos respectivos contratos.
5. Clientes usuários da plataforma (produtores, lojistas, infoprodutores) quanto ao uso ético e lícito das funcionalidades da GLOP, conforme os Termos de Uso.
6. Coprodutores, afiliados e parceiros de split, no que se refere à integridade das relações comerciais e financeiras intermediadas pela plataforma.

A adesão a este Código é condição para o vínculo com a GLOP e para o uso da plataforma, formalizada por meio do Termo de Ciência e Adesão (Seção 28) ou por cláusula contratual de remissão.

## 5. Definições

Para os fins deste Código, considera-se:

- **Agente Público:** quem exerce cargo, emprego ou função pública, ainda que transitoriamente ou sem remuneração, inclusive em empresas estatais e sob concessão.
- **Colaborador:** qualquer pessoa física com vínculo empregatício, estatutário, de estágio ou de prestação de serviço com a GLOP.
- **Comprador:** pessoa física ou jurídica que adquire produto ou serviço do Cliente da GLOP e cujos dados pessoais são tratados pela plataforma.
- **Controlador:** a quem competem as decisões referentes ao tratamento de dados pessoais (art. 5º, VI, LGPD). Em regra, o Cliente produtor/lojista quanto aos dados do Comprador; a GLOP quanto aos dados de seus próprios usuários e colaboradores.
- **Operador:** quem realiza o tratamento de dados pessoais em nome do Controlador (art. 5º, VII, LGPD). Papel exercido pela GLOP em relação aos dados dos Compradores.
- **Sub-operador:** terceiro contratado pela GLOP que trata dados por conta e ordem desta, no cumprimento do serviço (Supabase, Netlify, VHSYS, Correios, gateways, mensageria).
- **Dado Pessoal:** informação relacionada a pessoa natural identificada ou identificável (art. 5º, I, LGPD), incluindo nome, CPF, e-mail, telefone e endereço do Comprador.
- **Conflito de Interesse:** situação em que interesses pessoais, familiares ou de terceiros interferem, ou aparentam interferir, na isenção das decisões tomadas em nome da GLOP.
- **Informação Confidencial:** toda informação não pública a que se tenha acesso em razão da atividade, inclusive dados de clientes, compradores, credenciais, código-fonte, chaves de API, estratégias comerciais e dados financeiros.
- **Canal de Ética:** meio formal e seguro para reporte de violações a este Código, à lei ou às políticas internas.
- **Vantagem Indevida:** qualquer benefício, pagamento, presente, favor ou promessa dado ou recebido para obter tratamento privilegiado ou influenciar decisão.

## 6. Valores e Princípios Fundamentais

A GLOP orienta sua conduta pelos seguintes valores e princípios inegociáveis:

1. **Integridade:** agir com honestidade e coerência entre o que se diz e o que se faz, mesmo quando ninguém está observando.
2. **Legalidade:** cumprir a Constituição, as leis, os regulamentos e as normas internas aplicáveis.
3. **Transparência:** prestar informações claras, verdadeiras e tempestivas a clientes, compradores, parceiros e autoridades, respeitados os limites de sigilo.
4. **Proteção de Dados por Concepção e por Padrão (Privacy by Design/Default):** tratar dados pessoais com a menor exposição possível, finalidade legítima e segurança adequada.
5. **Segurança da Informação:** proteger a confidencialidade, integridade e disponibilidade dos dados e sistemas, alinhada a boas práticas (ISO/IEC 27001, 27701, 22301, 31000, NIST, OWASP).
6. **Respeito às Pessoas:** tratar todos com dignidade, sem discriminação, assédio ou violência.
7. **Confiança Fiduciária:** reconhecer que operar dados e valores de terceiros exige diligência de guardião, não de mero prestador.
8. **Responsabilidade e Prestação de Contas (Accountability):** documentar decisões, manter trilhas de auditoria e responder pelos próprios atos.
9. **Concorrência Leal:** competir por mérito, qualidade e preço, jamais por meios ilícitos.
10. **Sustentabilidade e Responsabilidade Social:** considerar o impacto ambiental, social e econômico das decisões.

## 7. Conduta Profissional Geral

Todo destinatário deve:

1. Conhecer e cumprir este Código, os Termos de Uso, a Política de Privacidade, a Política de Segurança da Informação e demais normas internas.
2. Exercer suas atribuições com zelo, competência, diligência e boa-fé.
3. Recusar-se a praticar, encobrir ou compactuar com qualquer ato ilícito ou antiético, ainda que sob ordem superior ou pressão de meta.
4. Reportar, pelo Canal de Ética, condutas suspeitas de violação a este Código ou à lei.
5. Preservar a imagem e a reputação da GLOP, evitando manifestações ou condutas que a comprometam.
6. Buscar orientação, em caso de dúvida, junto ao gestor imediato, ao Compliance ou ao Encarregado de Dados, antes de agir.

**Teste ético da decisão.** Diante de dúvida, o destinatário deve perguntar-se: (a) É legal? (b) Está de acordo com este Código e com as políticas? (c) Resistiria à divulgação pública e à análise de um auditor? (d) Protege — e não expõe — os dados de compradores e clientes? Se qualquer resposta for negativa ou incerta, a conduta deve ser evitada e a situação levada ao Compliance.

## 8. Conflitos de Interesse

### 8.1. Diretriz geral

Decisões tomadas em nome da GLOP devem visar exclusivamente aos interesses legítimos da empresa, de seus clientes e dos titulares de dados, jamais a interesses pessoais, familiares ou de terceiros.

### 8.2. Situações típicas de conflito

Constituem, exemplificativamente, conflitos de interesse:

1. Manter participação, vínculo ou interesse econômico em fornecedor, sub-operador, gateway, transportadora, concorrente, cliente ou parceiro de split da GLOP, sem declaração prévia.
2. Contratar, favorecer ou beneficiar familiares e pessoas próximas em processos de compra, contratação, comissionamento ou repasse.
3. Utilizar posição ou acesso a sistemas para obter vantagem pessoal — por exemplo, consultar dados de compradores ou de clientes sem necessidade operacional legítima.
4. Explorar oportunidade de negócio identificada em razão do cargo em proveito próprio.
5. Atuar simultaneamente para concorrente ou desenvolver produto concorrente utilizando conhecimento, código-fonte ou dados da GLOP.
6. Receber remuneração de terceiros por decisão que afete a GLOP (comissões, kickbacks).

### 8.3. Deveres de declaração e abstenção

1. Todo conflito, real ou potencial, deve ser declarado por escrito ao gestor e ao Compliance assim que identificado.
2. O envolvido deve abster-se de participar de deliberações e decisões sobre a matéria em que exista conflito.
3. O Compliance avaliará a situação e definirá medidas de mitigação (segregação de funções, reassignment, supervisão adicional ou vedação).
4. A omissão de conflito é, por si só, infração a este Código.

## 9. Anticorrupção e Antissuborno

### 9.1. Tolerância zero

A GLOP repudia e proíbe qualquer forma de corrupção, suborno, propina, tráfico de influência, fraude em licitação e financiamento de atividade ilícita, em conformidade com a Lei nº 12.846/2013 (Lei Anticorrupção), o Decreto nº 11.129/2022, a Lei nº 8.429/1992 (Improbidade Administrativa), o Código Penal e padrões internacionais (FCPA e UK Bribery Act) quando aplicáveis.

### 9.2. Condutas proibidas

É vedado a qualquer destinatário, direta ou indiretamente, por si ou por interposta pessoa:

1. Prometer, oferecer, dar, autorizar, solicitar ou receber vantagem indevida a/de agente público ou privado, nacional ou estrangeiro.
2. Realizar pagamentos de facilitação (facilitation payments) para agilizar atos de rotina.
3. Financiar, custear ou patrocinar a prática de atos ilícitos.
4. Fraudar ou frustrar licitações e contratos administrativos.
5. Utilizar terceiros (consultores, despachantes, parceiros) para intermediar pagamentos indevidos.

### 9.3. Brindes, presentes, hospitalidade e patrocínios

1. É permitido oferecer e receber brindes institucionais de valor simbólico e caráter promocional, sem intenção de influenciar decisões.
2. É vedado oferecer ou aceitar presentes, viagens, hospitalidades ou entretenimento de valor que possa configurar vantagem indevida ou comprometer a isenção.
3. Qualquer oferta a agente público sujeita-se a análise prévia do Compliance.
4. Doações e patrocínios devem ser formalizados, transparentes, contabilizados e aprovados conforme alçada.

### 9.4. Relações governamentais e devida diligência

1. Interações com o Poder Público (por exemplo, junto aos Correios como empresa pública, à administração fazendária ou à ANPD) devem ser registradas e conduzidas com transparência.
2. A contratação de fornecedores, sub-operadores e parceiros deve ser precedida de devida diligência de integridade (due diligence) proporcional ao risco.
3. Contratos com terceiros devem conter cláusulas anticorrupção e de conformidade com este Código.

## 10. Antifraude, Prevenção à Lavagem de Dinheiro e Integridade Financeira

### 10.1. Diretriz

Por intermediar fluxos financeiros de terceiros — comissões, apurações, repasses e split via AppMax, com uso de dados de PIX e bancários —, a GLOP adota controles rigorosos de prevenção à fraude e à lavagem de dinheiro (Lei nº 9.613/1998) e ao financiamento do terrorismo.

### 10.2. Condutas proibidas

1. Manipular apurações, comissionamentos, splits ou repasses para desviar valores ou beneficiar indevidamente coprodutores, afiliados ou terceiros.
2. Adulterar, inserir ou omitir lançamentos, registros fiscais (NF-e), documentos ou dados nos sistemas.
3. Criar cadastros, contas, pedidos ou chaves PIX fictícios ou de laranjas.
4. Facilitar operações que aparentem fracionamento, ocultação de origem de recursos ou uso da plataforma para lavagem de dinheiro.
5. Utilizar a plataforma para comercialização de produtos ilícitos, falsificados, contrabandeados ou que violem direitos de terceiros.

### 10.3. Controles

1. Segregação de funções entre quem registra, aprova e concilia operações financeiras.
2. Trilha de auditoria por triggers em todo registro, com colunas de auditoria e soft-delete, preservando o histórico.
3. Monitoramento de indícios de fraude (Know Your Customer/Business, sinais de abuso, inconsistência entre pedido, valor e destinatário).
4. Comunicação de operações suspeitas às autoridades competentes, quando exigido por lei.
5. Vedação a qualquer alteração de dado financeiro fora dos fluxos, controles e permissões (RBAC) previstos.

## 11. Uso de Recursos, Ativos e Sistemas

### 11.1. Ativos da GLOP

Equipamentos, licenças, credenciais, código-fonte, bases de dados, infraestrutura (Supabase, Netlify), contas de serviço, marcas e demais ativos destinam-se exclusivamente às finalidades da atividade profissional.

### 11.2. Diretrizes

1. Utilizar os ativos de forma responsável, econômica e lícita, preservando sua integridade e segurança.
2. É vedado o uso de recursos da GLOP para fins pessoais que gerem custo relevante, ganho privado ou risco à segurança.
3. É vedado instalar software não autorizado, contornar controles de segurança ou desativar mecanismos de proteção (RLS, RBAC, logs).
4. Credenciais e chaves de API são pessoais e intransferíveis; devem ser mantidas em cofre de segredos, nunca compartilhadas, versionadas em repositório ou expostas em código, mensagens ou registros.
5. Acessos são concedidos pelo princípio do menor privilégio (least privilege) e da necessidade de conhecer (need to know), e revogados quando cessar a finalidade ou o vínculo.
6. O acesso a bases de produção com dados pessoais de compradores exige justificativa operacional e é registrado em trilha de auditoria.

### 11.3. Monitoramento

A GLOP pode monitorar, nos limites legais e com transparência, o uso de seus sistemas e ativos para fins de segurança, auditoria e conformidade, respeitados os direitos de privacidade dos colaboradores.

## 12. Uso e Tratamento de Informações e Dados Pessoais (LGPD)

### 12.1. Dupla natureza e responsabilidade

A GLOP reconhece sua **dupla natureza** sob a LGPD:

1. Como **Operadora**, trata dados pessoais dos Compradores (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor) por conta e ordem dos Clientes produtores/lojistas, que são os **Controladores** dessas informações, seguindo suas instruções lícitas e o Contrato de Tratamento de Dados (DPA).
2. Como **Controladora**, trata dados pessoais de seus próprios usuários e colaboradores, definindo finalidades e meios.

### 12.2. Princípios de tratamento (art. 6º, LGPD)

Todo tratamento observa: finalidade, adequação, necessidade (minimização), livre acesso, qualidade dos dados, transparência, segurança, prevenção, não discriminação e responsabilização e prestação de contas.

### 12.3. Diretrizes obrigatórias

1. Tratar dados pessoais apenas para finalidades legítimas, específicas e informadas, com base legal adequada (art. 7º e art. 11, LGPD).
2. Coletar e acessar somente os dados necessários (minimização); é vedado o acesso curioso, exploratório ou pessoal a dados de compradores e clientes.
3. Não utilizar, copiar, extrair, cruzar, comercializar ou compartilhar dados pessoais fora das finalidades e instruções autorizadas.
4. Respeitar a segregação multi-tenant (RLS por empresa): dados de um Cliente jamais podem ser expostos, misturados ou acessados por outro.
5. O Portal Público de Rastreio deve expor apenas status neutro, sem PII; é vedado ampliar sua exposição.
6. Atender os direitos dos titulares (confirmação, acesso, correção, anonimização, portabilidade, eliminação, informação sobre compartilhamento — art. 18, LGPD), encaminhando as solicitações ao fluxo definido e ao Encarregado.
7. Comunicar imediatamente ao Encarregado e ao Compliance qualquer incidente de segurança envolvendo dados pessoais, para avaliação de comunicação à ANPD e aos titulares (art. 48, LGPD).
8. Observar as regras de transferência internacional quando sub-operadores tratarem dados fora do Brasil (arts. 33 a 36, LGPD).
9. Garantir que a contratação de sub-operadores (Supabase, Netlify, VHSYS, Correios, gateways, mensageria) seja formalizada por instrumento com cláusulas de proteção de dados e nível de segurança equivalente.

### 12.4. Remissão

O detalhamento operacional deste tema consta da Política de Privacidade, do Contrato de Tratamento de Dados (DPA) e da Política de Segurança da Informação, que integram o arcabouço normativo da GLOP.

## 13. Confidencialidade e Sigilo

### 13.1. Dever de sigilo

Todo destinatário obriga-se a manter absoluto sigilo sobre Informações Confidenciais a que tenha acesso, durante e após o vínculo com a GLOP, por prazo indeterminado enquanto a informação mantiver caráter reservado.

### 13.2. Abrangência

Consideram-se confidenciais, entre outras:

1. Dados pessoais de compradores, clientes, colaboradores e parceiros.
2. Dados financeiros: comissões, splits, apurações, repasses, chaves PIX e dados bancários.
3. Credenciais, chaves de API (mantidas em regime write-only), segredos, tokens e configurações de segurança.
4. Código-fonte, arquitetura, migrations, esquema de banco, regras de RLS/RBAC e propriedade intelectual.
5. Estratégias comerciais, precificação, contratos, roadmap e informações de negócio.

### 13.3. Deveres

1. Não divulgar, reproduzir, transmitir ou permitir acesso a Informação Confidencial a quem não tenha necessidade legítima e autorização.
2. Não utilizar Informação Confidencial em proveito próprio ou de terceiros.
3. Adotar cuidado com telas, documentos, mensagens e conversas em ambientes públicos e canais não corporativos.
4. Devolver ou eliminar, ao término do vínculo, toda informação e ativo em posse, conforme instrução da GLOP.
5. Firmar Termo de Confidencialidade (NDA) quando exigido pela função ou pela relação contratual.

## 14. Segurança da Informação e Cibersegurança

Em alinhamento às normas ISO/IEC 27001, 27701, 22301 e 31000, ao NIST Cybersecurity Framework e às práticas OWASP, todo destinatário deve:

1. Proteger a confidencialidade, integridade e disponibilidade das informações e sistemas.
2. Utilizar autenticação forte (Supabase Auth/JWT), senhas robustas e, quando disponível, múltiplo fator; nunca compartilhar credenciais.
3. Respeitar os controles de acesso (RLS multi-tenant, RBAC/has_permission, soft-delete e trilha de auditoria por triggers), jamais tentando contorná-los.
4. Tratar credenciais de API como write-only, mantidas em cofre de segredos, nunca expostas em código, logs ou mensagens.
5. Reportar imediatamente vulnerabilidades, incidentes, phishing, malware, perda de dispositivo ou suspeita de acesso indevido.
6. Não introduzir código, dependência ou configuração que fragilize a segurança da plataforma ou dos sub-operadores.
7. Observar as diretrizes de continuidade de negócios (ISO 22301) e de gestão de riscos (ISO 31000) definidas pela GLOP.

O detalhamento consta da Política de Segurança da Informação e do Plano de Resposta a Incidentes.

## 15. Relações com Clientes (Produtores, Lojistas e Infoprodutores)

1. Atuar com transparência, boa-fé e cumprimento dos Termos de Uso e do DPA, respeitando o papel de Controlador do Cliente sobre os dados de seus compradores.
2. Não acessar, utilizar ou compartilhar dados ou operações de um Cliente para finalidade estranha à prestação do serviço.
3. Prestar informações verídicas sobre funcionalidades, limitações, disponibilidade e status de conformidade (sem alegar como pronto o que está em roadmap).
4. Zelar pela isonomia entre Clientes, respeitando a segregação multi-tenant e vedando favorecimentos indevidos.
5. Comunicar de forma tempestiva incidentes, indisponibilidades relevantes e mudanças que afetem o Cliente.
6. Recusar solicitações de Clientes que impliquem ilegalidade, fraude, uso indevido de dados ou violação a este Código, escalando ao Compliance.

## 16. Relações com Compradores e Titulares de Dados (Consumidores)

1. Respeitar os direitos dos consumidores (Lei nº 8.078/1990) e dos titulares de dados (LGPD), ainda que a relação primária seja com o Cliente Controlador.
2. Assegurar comunicação clara e não abusiva nas notificações por e-mail e WhatsApp (rastreio, status), respeitando as normas de comunicação e antispam.
3. Manter o Portal Público de Rastreio restrito a status neutro, sem exposição de PII, protegendo o comprador.
4. Encaminhar solicitações de titulares (art. 18, LGPD) ao fluxo adequado, articulando-se com o Cliente Controlador e o Encarregado.
5. Tratar os dados do comprador com segurança e minimização, sem uso secundário não autorizado.

## 17. Relações com Fornecedores e Sub-operadores

1. Selecionar e contratar fornecedores e sub-operadores (Supabase, Netlify, VHSYS, Correios, gateways, mensageria) por critérios objetivos de qualidade, preço, segurança e integridade, com devida diligência proporcional ao risco.
2. Exigir, nos contratos, cláusulas de proteção de dados, segurança da informação, anticorrupção e adesão a este Código.
3. Vedar recebimento de vantagens indevidas de fornecedores e coibir conflitos de interesse na cadeia de suprimentos.
4. Monitorar o desempenho e a conformidade dos sub-operadores, especialmente quanto ao tratamento de dados pessoais e à segurança.
5. Formalizar todo compartilhamento de dados com sub-operadores e garantir nível de proteção equivalente ao da GLOP.

## 18. Relações com Transportadores e Parceiros Logísticos

1. Interagir com os Correios e demais transportadores com transparência, cumprindo as regras de pré-postagem (PPN) e rastreamento (SRO).
2. Compartilhar com transportadores somente os dados necessários à entrega (minimização), com base legal e finalidade adequada.
3. Registrar e auditar as integrações logísticas, preservando a rastreabilidade e a integridade dos dados de entrega.
4. Coibir fraudes logísticas (extravios simulados, adulteração de status, uso indevido de etiquetas ou contratos de frete).
5. Observar, na relação com os Correios (empresa pública), as diretrizes anticorrupção e de relações governamentais deste Código.

## 19. Relações com Coprodutores, Afiliados e Parceiros de Split

1. Conduzir apurações, comissionamentos, repasses e split (via AppMax) com exatidão, transparência e rastreabilidade.
2. Proteger os dados de PIX e bancários de coprodutores e afiliados com sigilo e segurança reforçados.
3. Vedar manipulação de percentuais, hierarquias de afiliação, atribuição de vendas ou splits para favorecer ou prejudicar partes.
4. Prevenir fraudes de afiliação (autocompra, cookie stuffing, atribuição fraudulenta) e comunicar indícios ao Compliance.
5. Tratar todos os parceiros com isonomia, boa-fé contratual e clareza nas regras de remuneração.

## 20. Relações Institucionais, Concorrência e Poder Público

1. Competir de forma leal, com base em mérito, inovação, qualidade e preço, em conformidade com a Lei nº 12.529/2011 (Defesa da Concorrência).
2. É vedado obter informações de concorrentes por meios ilícitos, praticar concorrência desleal ou firmar acordos anticompetitivos (cartel, divisão de mercado).
3. Não denegrir concorrentes com informações falsas; críticas devem ser verídicas e comprováveis.
4. Interações com autoridades, órgãos reguladores (ANPD) e Poder Público devem ser transparentes, documentadas e conduzidas por pessoas autorizadas.
5. Cooperar com autoridades e fiscalizações nos limites legais, preservando o sigilo e os direitos dos titulares.

## 21. Comunicação, Redes Sociais e Uso de Marca

1. Manifestações públicas em nome da GLOP somente por pessoas autorizadas.
2. É vedado divulgar Informação Confidencial, dados de clientes/compradores ou detalhes de arquitetura e segurança em redes sociais, fóruns, repositórios públicos ou eventos.
3. Em manifestações pessoais, deixar claro que não representam a posição da GLOP.
4. Uso de marca, identidade visual e materiais da GLOP conforme as diretrizes de marca e mediante autorização.
5. Não publicar conteúdo discriminatório, difamatório ou que exponha a GLOP, clientes, compradores ou parceiros.

## 22. Diversidade, Inclusão, Assédio e Ambiente de Trabalho

1. A GLOP promove ambiente respeitoso, diverso e inclusivo, com igualdade de oportunidades.
2. São proibidas todas as formas de discriminação (raça, cor, etnia, gênero, orientação sexual, identidade de gênero, religião, deficiência, idade, origem, condição social).
3. São vedados assédio moral, assédio sexual, intimidação, bullying e qualquer forma de violência ou humilhação.
4. Condutas de assédio e discriminação devem ser reportadas ao Canal de Ética e serão apuradas com proteção à vítima e não retaliação.
5. A GLOP observa a legislação trabalhista e as normas de saúde e segurança do trabalho.

## 23. Direitos Humanos, Trabalho e Sustentabilidade

1. A GLOP repudia trabalho infantil, trabalho forçado, análogo ao escravo e qualquer violação a direitos humanos, exigindo o mesmo de sua cadeia de fornecedores.
2. Compromete-se com práticas de responsabilidade social e com a redução de impactos ambientais em suas operações.
3. Estimula o consumo consciente de recursos computacionais e a eficiência energética da infraestrutura.

## 24. Uso Responsável de Inteligência Artificial (LOGIA)

1. Os recursos de IA da GLOP (LOGIA e correlatos) devem ser utilizados de forma ética, transparente, explicável e não discriminatória.
2. É vedado alimentar modelos com dados pessoais em desacordo com a base legal, a finalidade e as instruções do Controlador.
3. Decisões automatizadas que afetem titulares devem observar o direito à revisão (art. 20, LGPD) e a supervisão humana adequada.
4. Modelos e prompts não devem expor Informação Confidencial nem burlar controles de segurança e segregação multi-tenant.
5. O uso de IA deve preservar a qualidade, a acurácia e a não perpetuação de vieses.

## 25. Canal de Ética e Denúncias

### 25.1. Finalidade

A GLOP mantém Canal de Ética para o reporte de violações a este Código, à legislação ou às políticas internas, incluindo corrupção, fraude, conflitos de interesse, vazamento de dados, assédio e discriminação.

### 25.2. Meios de acesso

- **E-mail do Canal de Ética:** [E-MAIL DO CANAL DE ÉTICA]
- **Formulário/Plataforma:** [URL/PLATAFORMA DO CANAL]
- **Telefone/WhatsApp:** [TELEFONE DO CANAL]
- **Encarregado de Dados (DPO), para incidentes com dados pessoais:** a ser designado pela administração — lemoncapsencapsulados@gmail.com

### 25.3. Características

1. **Anonimato facultativo:** o denunciante pode identificar-se ou permanecer anônimo, quando o meio permitir.
2. **Confidencialidade:** a identidade e o conteúdo são tratados com sigilo, restritos aos responsáveis pela apuração.
3. **Acessibilidade:** disponível a colaboradores, clientes, parceiros e terceiros.
4. **Boa-fé:** o relato deve ser feito de boa-fé; denúncias comprovadamente falsas e mal-intencionadas sujeitam o autor a medidas cabíveis.

## 26. Investigação, Apuração e Não Retaliação

1. Toda denúncia recebida é registrada, triada e apurada de forma imparcial, célere e sigilosa pelo Compliance e/ou Comitê de Ética.
2. Assegura-se ao investigado o contraditório e a ampla defesa, na medida do processo interno.
3. **Não retaliação:** é terminantemente proibida qualquer retaliação contra quem, de boa-fé, reporta violação ou colabora com a apuração. A retaliação é, por si só, infração grave a este Código.
4. Concluída a apuração, aplicam-se as medidas cabíveis (Seção 27) e adotam-se ações corretivas e preventivas.
5. Mantém-se registro das apurações e das decisões, resguardado o sigilo e a proteção de dados dos envolvidos.

## 27. Medidas Disciplinares e Consequências

### 27.1. Gradação

A violação a este Código sujeita o infrator a medidas proporcionais à gravidade, à reincidência e ao dano causado, sem prejuízo das responsabilidades civil, criminal, administrativa e regulatória.

| Natureza do vínculo | Medidas aplicáveis |
|---|---|
| Colaboradores (CLT) | Orientação formal, advertência verbal, advertência escrita, suspensão, demissão sem justa causa ou por justa causa (art. 482, CLT). |
| Estagiários/aprendizes | Orientação, advertência, desligamento do programa. |
| Prestadores/terceiros (PJ/PF) | Notificação, suspensão de atividades, rescisão contratual, aplicação de penalidades e cláusula penal. |
| Fornecedores/sub-operadores | Advertência, plano de ação, rescisão contratual, bloqueio e reporte a autoridades. |
| Clientes usuários | Notificação, suspensão ou encerramento de conta/acesso, rescisão dos Termos de Uso, retenção de repasses sob apuração e reporte legal. |
| Coprodutores/afiliados/split | Suspensão de comissionamento, bloqueio de repasses sob apuração, exclusão do programa e responsabilização. |

### 27.2. Agravantes e outras providências

1. São agravantes: dolo, reincidência, abuso de posição, dano a dados pessoais, prejuízo financeiro e ocultação.
2. Constatado ilícito, a GLOP poderá comunicar autoridades competentes (ANPD, Ministério Público, Polícia, órgãos fiscais) e buscar reparação de danos.
3. As medidas disciplinares observarão o devido processo interno, a proporcionalidade e a legislação aplicável.

## 28. Termo de Ciência e Adesão

Ao ingressar ou manter vínculo com a GLOP, o destinatário declara ter lido, compreendido e aderido integralmente a este Código, comprometendo-se a observá-lo. A adesão formaliza-se por assinatura (física ou eletrônica) do Termo abaixo ou por cláusula contratual de remissão.

**Termo:** Declaro que recebi, li e compreendi o Código de Ética e Conduta da [NOME FANTASIA: GLOP], operado por LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, e comprometo-me a cumpri-lo integralmente, ciente das consequências de seu descumprimento.

- Nome: [PARTE]
- Documento: [CPF/CNPJ]
- Função/Relação: [CARGO/RELAÇÃO]
- Local e Data: Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190 / 16 de julho de 2026
- Assinatura: ______________________________

## 29. Vigência, Divulgação e Revisão

1. Este Código entra em vigor na data de sua aprovação (16 de julho de 2026) e permanece vigente por prazo indeterminado, até revisão ou revogação formal.
2. Será amplamente divulgado a todos os destinatários e disponibilizado em canal de acesso permanente.
3. Será revisado periodicamente (no mínimo anualmente) e sempre que houver alteração legislativa, regulatória, tecnológica ou operacional relevante.
4. A responsabilidade pela guarda, atualização e interpretação é do Compliance, com apoio do Encarregado de Dados e da assessoria jurídica.

---

## 30. Engenharia Jurídica & Governança

### (a) Fundamentação das Cláusulas

| Tema / Seção | Fundamento legal e normativo |
|---|---|
| Proteção de dados, dupla natureza Operador/Controlador, direitos dos titulares, incidentes (Seções 12, 16) | Lei nº 13.709/2018 (LGPD), arts. 5º, 6º, 7º, 11, 18, 20, 33-36, 37-40, 42-45, 46-49; Decreto nº 11.871/2024; Regulamentos da ANPD; GDPR (referência internacional) |
| Anticorrupção, brindes, relações governamentais (Seção 9) | Lei nº 12.846/2013 (Lei Anticorrupção); Decreto nº 11.129/2022; Lei nº 8.429/1992 (Improbidade); Código Penal (arts. 317, 333); FCPA e UK Bribery Act (referência) |
| Antifraude e prevenção à lavagem (Seção 10) | Lei nº 9.613/1998; Código Penal; normas de PLD/FT aplicáveis a arranjos e intermediação financeira |
| Relações de consumo e comunicação ao comprador (Seções 15, 16) | Lei nº 8.078/1990 (CDC); Marco Civil da Internet (Lei nº 12.965/2014); normas antispam e de comunicação |
| Concorrência leal (Seção 20) | Lei nº 12.529/2011 (Defesa da Concorrência); Lei nº 9.279/1996 (Propriedade Industrial, concorrência desleal) |
| Confidencialidade e propriedade intelectual (Seções 13, 21) | Lei nº 9.279/1996; Lei nº 9.610/1998 (Direitos Autorais); Lei nº 9.609/1998 (Software); Código Civil (boa-fé, arts. 421-422) |
| Segurança da informação e continuidade (Seção 14) | ISO/IEC 27001 e 27701, ISO 22301, ISO 31000; NIST CSF; OWASP; art. 46-49 LGPD |
| Trabalho, assédio, diversidade (Seções 22, 23) | CLT (art. 482); CF/1988 (arts. 1º, 3º, 5º, 7º); Lei nº 9.029/1995; normas de saúde e segurança do trabalho |
| Canal de ética, não retaliação, apuração (Seções 25, 26) | Lei nº 12.846/2013 e Decreto nº 11.129/2022 (elementos de programa de integridade); boas práticas de compliance |
| IA responsável (Seção 24) | Art. 20 LGPD (decisões automatizadas); princípios de transparência e não discriminação |

### (b) Riscos Mitigados

1. **Vazamento e uso indevido de dados pessoais** de compradores/clientes, com sanções da ANPD e responsabilidade civil (LGPD).
2. **Corrupção e suborno**, com responsabilização objetiva da pessoa jurídica (Lei Anticorrupção) e sanções administrativas e judiciais.
3. **Fraude financeira e lavagem de dinheiro** nos fluxos de split, comissões e repasses.
4. **Conflitos de interesse** não declarados, com favorecimentos e perdas reputacionais.
5. **Quebra de confidencialidade** e exposição de código-fonte, credenciais e chaves de API.
6. **Concorrência desleal** e infrações antitruste.
7. **Assédio, discriminação e passivo trabalhista.**
8. **Descumprimento contratual** com clientes, sub-operadores e parceiros.
9. **Uso indevido de IA** e decisões automatizadas sem supervisão/revisão.
10. **Dano reputacional e perda de confiança** de clientes, compradores e mercado.

### (c) Checklist de Conformidade

- [ ] Código aprovado pela Direção e datado (16 de julho de 2026).
- [ ] Placeholders preenchidos com dados reais (LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, 55.836.075/0001-07, Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, DPO, canais).
- [ ] Canal de Ética operante, com meios divulgados e testados.
- [ ] Termo de Ciência e Adesão coletado de todos os destinatários.
- [ ] Políticas correlatas publicadas (Privacidade, Segurança da Informação, Anticorrupção, Conflitos de Interesse, DPA com sub-operadores).
- [ ] Cláusulas anticorrupção e de proteção de dados inseridas em contratos com fornecedores/sub-operadores.
- [ ] Devida diligência de integridade de terceiros implementada.
- [ ] Controles técnicos ativos: RLS multi-tenant, RBAC, soft-delete, trilha de auditoria, credenciais write-only, cofre de segredos.
- [ ] Plano de resposta a incidentes e fluxo de notificação à ANPD definidos.
- [ ] Treinamento e comunicação do Código realizados e registrados.
- [ ] Ciclo de revisão anual agendado.

### (d) Matriz RACI

Legenda: R = Responsável pela execução; A = Aprovador/prestador de contas; C = Consultado; I = Informado.

| Atividade | Diretoria | Compliance | Encarregado (DPO) | Jurídico | Segurança da Informação | RH | Gestores | Colaboradores |
|---|---|---|---|---|---|---|---|---|
| Aprovar e revisar o Código | A | R | C | C | C | I | I | I |
| Divulgar e treinar | I | R | C | C | C | R | R | I |
| Operar o Canal de Ética | I | R | C | C | I | C | I | I |
| Investigar denúncias | A | R | C | C | C | C | I | I |
| Gerir conflitos de interesse | I | R | I | C | I | C | R | I |
| Anticorrupção e due diligence de terceiros | A | R | I | C | C | I | C | I |
| Proteção de dados e incidentes | I | C | R | C | R | I | C | I |
| Segurança da informação (RLS/RBAC/logs) | I | C | C | I | R | I | C | I |
| Aplicar medidas disciplinares | A | R | I | C | I | R | R | I |
| Adesão ao Código (Termo) | I | C | I | I | I | R | R | R |

### (e) Plano de Revisão

1. **Periodicidade:** revisão ordinária anual; revisões extraordinárias diante de mudança legislativa (LGPD/ANPD, Lei Anticorrupção), novo sub-operador, novo fluxo (gateway, marketplace) ou incidente relevante.
2. **Responsáveis:** Compliance (condução), Jurídico e Encarregado (validação), Diretoria (aprovação).
3. **Insumos:** relatórios do Canal de Ética, resultados de auditorias, incidentes, atualizações normativas e feedback das áreas.
4. **Registro:** toda alteração documentada no Controle de Versão, com comunicação e nova coleta de adesão quando houver mudança material.

### (f) Controle de Versão

| Versão | Data | Autor/Responsável | Descrição da alteração | Aprovação |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | [RESPONSÁVEL — COMPLIANCE] | Emissão inicial do Código de Ética e Conduta da GLOP (minuta gerada por IA, pendente de validação jurídica). | [ÓRGÃO/DIRETORIA APROVADORA] |
| [X.Y] | 16 de julho de 2026 | [RESPONSÁVEL] | [Descrição da revisão] | [APROVADOR] |

---

> Documento de observância obrigatória. Em caso de dúvida sobre a aplicação deste Código, consulte o Compliance ou o Encarregado de Dados (a ser designado pela administração — lemoncapsencapsulados@gmail.com) antes de agir.
