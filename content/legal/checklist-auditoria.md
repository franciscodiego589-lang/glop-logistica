# Checklist de Auditoria — LGPD + Segurança da Informação

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

**Plataforma auditada:** [NOME FANTASIA: GLOP] — Global Logistics Platform
**Controlador / Operador (conforme o fluxo):** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, inscrita no CNPJ sob nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190
**Encarregado pelo Tratamento de Dados (DPO):** a ser designado pela administração — lemoncapsencapsulados@gmail.com
**Responsável pela auditoria:** [PARTE]
**Data de referência da auditoria:** 16 de julho de 2026
**Ciclo / versão do checklist:** v1.0

---

## 1. Objetivo

Este Checklist de Auditoria estabelece o conjunto de itens verificáveis, por domínio de controle, para aferir o grau de conformidade do [NOME FANTASIA: GLOP] com a Lei nº 13.709/2018 (Lei Geral de Proteção de Dados Pessoais — LGPD), o Marco Civil da Internet (Lei nº 12.965/2014), o Decreto nº 8.771/2016, o Código de Defesa do Consumidor (Lei nº 8.078/1990) e com as boas práticas e normas de Segurança da Informação reconhecidas internacionalmente (ISO/IEC 27001, 27701, 22301, 31000, NIST Cybersecurity Framework, OWASP ASVS/Top 10 e, subsidiariamente, o GDPR — Regulamento (UE) 2016/679 — para fluxos com titulares ou infraestrutura no exterior).

O checklist serve como instrumento de:

1. Autoavaliação periódica (primeira e segunda linha de defesa).
2. Auditoria independente (terceira linha de defesa) e due diligence de terceiros.
3. Preparação para fiscalização da Autoridade Nacional de Proteção de Dados (ANPD).
4. Suporte probatório em caso de incidente de segurança ou requisição de titular/autoridade.

## 2. Escopo

Aplica-se a **todo o tratamento de dados pessoais** realizado no âmbito do [NOME FANTASIA: GLOP], SaaS de logística/ERP para dropshipping e infoprodutos, considerando expressamente:

- **Stack e infraestrutura:** Next.js (App Router), Supabase (PostgreSQL com RLS multi-tenant — Tenant → Company → Branch → Membership), Supabase Auth (JWT), Supabase Storage, hospedagem SSR em Netlify.
- **Ingestão de pedidos** via API de gateways/infoprodutos (Monetizze, Hotmart, Kiwify) e e-commerces/marketplaces (Shopify, WooCommerce, Nuvemshop, Mercado Livre), contendo PII do COMPRADOR: nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor.
- **Fluxo Correios:** pré-postagem (PPN), rastreio (SRO) e notificação ao comprador por e-mail/WhatsApp.
- **Coprodução & Split:** coprodutores/afiliados, comissão, apuração, repasses e split (AppMax), incluindo dados de PIX/bancários.
- **NF-e via VHSYS** e demais documentos fiscais.
- **Portal público de rastreio** (sem login, expondo apenas status neutro).
- **Dados dos próprios usuários/colaboradores** da plataforma (cadastro, autenticação, RBAC).
- **Dupla natureza jurídica:** [NOME FANTASIA: GLOP] atua como **OPERADOR** dos dados do comprador (tratados em nome do produtor/lojista, que é o CONTROLADOR) e como **CONTROLADOR** dos dados de seus próprios usuários/colaboradores e de dados de negócio da plataforma.

**Fora de escopo (registrar exceções):** [PARTE] deverá listar sistemas de terceiros não integrados, ambientes de laboratório sem PII e quaisquer tratamentos expressamente excluídos.

## 3. Metodologia e escala de conformidade

Cada item é avaliado quanto à **conformidade** e deve ser acompanhado da **evidência** correspondente. Adota-se a seguinte escala:

- **Conforme (C):** controle implementado, documentado, operante e evidenciado. Atende integralmente ao requisito.
- **Parcial (P):** controle existente porém incompleto, não documentado, não testado, aplicado a parte do escopo ou sem evidência suficiente. Requer plano de ação.
- **Não Conforme (NC):** controle inexistente, inoperante ou contrário ao requisito. Exige remediação prioritária.
- **Não Aplicável (N/A):** requisito não incide sobre o fluxo (justificar por escrito).

Para cada achado **P** ou **NC**, registrar: descrição da lacuna, risco associado, severidade (Baixa/Média/Alta/Crítica), responsável, prazo (SLA) e status. Recomenda-se anexar hash/carimbo de data das evidências para integridade probatória.

---

## 4. Domínio A — Governança e Programa de Privacidade

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| A.1 | Encarregado (DPO) formalmente nomeado, com identidade e canal de contato publicados (art. 41, LGPD) | | Ato de nomeação de a ser designado pela administração; publicação de lemoncapsencapsulados@gmail.com na Política de Privacidade e no rodapé do site |
| A.2 | Existência de Programa de Governança em Privacidade documentado (art. 50, LGPD) | | Política corporativa aprovada, com data e versão |
| A.3 | Papéis e responsabilidades de privacidade definidos (RACI) e comunicados | | Matriz RACI; organograma; atas de treinamento |
| A.4 | Políticas internas de privacidade e segurança aprovadas por instância competente | | Política de Privacidade, Política de Segurança da Informação, Política de Uso Aceitável, com registro de aprovação |
| A.5 | Distinção documentada dos papéis de OPERADOR e CONTROLADOR por fluxo de dados | | Mapa de papéis por fluxo (comprador vs. usuário/colaborador) |
| A.6 | Programa de treinamento e conscientização periódico (art. 50, §2º, I, "h") | | Grade de treinamento, listas de presença, métricas de conclusão |
| A.7 | Indicadores (KPIs) de privacidade monitorados e reportados à gestão | | Painel/relatório de indicadores (nº de requisições, incidentes, prazos) |
| A.8 | Orçamento e recursos alocados para o programa de privacidade e segurança | | Plano orçamentário; contratos de ferramentas/serviços |

## 5. Domínio B — Bases Legais do Tratamento

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| B.1 | Base legal identificada e registrada para **cada** operação de tratamento (arts. 7º e 11, LGPD) | | Mapeamento de bases legais por atividade (ROPA) |
| B.2 | Tratamento de PII do comprador (nome, CPF/CNPJ, e-mail, telefone, endereço) fundamentado em execução de contrato/procedimentos preliminares e cumprimento de obrigação legal (art. 7º, V e II) | | Contrato produtor/lojista; ROPA do fluxo de ingestão de pedidos |
| B.3 | Como OPERADOR, [NOME FANTASIA: GLOP] trata dados do comprador **sob instruções documentadas** do CONTROLADOR (produtor/lojista) — art. 39 | | Contrato de Operador/DPA assinado com cada Company (controlador) |
| B.4 | Notificações ao comprador (Correios/e-mail/WhatsApp) com base legal definida (execução de contrato e/ou legítimo interesse, art. 7º, V e IX) | | Registro da base; teste de legítimo interesse (LIA) quando aplicável |
| B.5 | Comunicações de marketing/transacionais em WhatsApp/e-mail com consentimento ou opt-out adequados (LGPD + CDC + boas práticas anti-spam) | | Fluxo de consentimento/opt-out; logs de opt-in/opt-out |
| B.6 | Dados fiscais (NF-e/VHSYS) tratados por obrigação legal e regulatória (art. 7º, II; legislação tributária) | | ROPA fiscal; retenção conforme prazos fiscais |
| B.7 | Dados financeiros de split/PIX/bancários (coprodutores/afiliados) com base legal e minimização (art. 7º, V) | | ROPA de repasses; contrato de coprodução/afiliação |
| B.8 | Legítimo interesse, quando usado, acompanhado de teste de balanceamento (LIA) e salvaguardas (art. 10) | | Documento de LIA por finalidade |
| B.9 | Ausência de tratamento de dados sensíveis; se houver, base específica do art. 11 e proteção reforçada | | Declaração de não coleta de dados sensíveis ou base do art. 11 |
| B.10 | Vedação de uso secundário incompatível com a finalidade original (princípio da finalidade, art. 6º, I) | | Política de finalidade; revisão de novos usos |

## 6. Domínio C — Princípios e Minimização

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| C.1 | Coleta limitada ao mínimo necessário por finalidade (art. 6º, III — necessidade) | | Inventário de campos coletados vs. finalidade |
| C.2 | Campos recebidos dos gateways/e-commerces filtrados para descartar dados excessivos | | Mapeamento de payload de entrada; regras de descarte |
| C.3 | Qualidade e exatidão dos dados asseguradas e atualizáveis (art. 6º, V) | | Rotinas de atualização; canal de correção |
| C.4 | Transparência: Política de Privacidade clara, acessível e específica ao GLOP (art. 6º, VI; art. 9º) | | Política publicada com data de vigência |
| C.5 | Prevenção e segurança aplicadas desde a concepção (privacy by design/default, art. 46, §2º) | | Registros de design/review de novas features |
| C.6 | Não discriminação no tratamento (art. 6º, IX) | | Revisão de regras automatizadas/segmentações |

## 7. Domínio D — Direitos dos Titulares

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| D.1 | Canal de atendimento ao titular disponível e divulgado (art. 18, §1º) | | lemoncapsencapsulados@gmail.com; formulário/portal de requisições |
| D.2 | Procedimento documentado para confirmação de existência e acesso aos dados (art. 18, I e II) | | SOP de atendimento; SLA definido |
| D.3 | Procedimento de correção de dados incompletos/inexatos (art. 18, III) | | Registro de correções realizadas |
| D.4 | Anonimização, bloqueio ou eliminação de dados desnecessários/excessivos/ilícitos (art. 18, IV) | | Rotina técnica de anonimização/eliminação; logs |
| D.5 | Portabilidade dos dados a outro fornecedor, quando aplicável (art. 18, V) | | Mecanismo de exportação estruturada |
| D.6 | Eliminação de dados tratados com consentimento (art. 18, VI) e revogação de consentimento (art. 8º, §5º) | | Fluxo de revogação; logs |
| D.7 | Informação sobre compartilhamento e sobre negativa de consentimento (art. 18, VII e VIII) | | Modelo de resposta ao titular |
| D.8 | Encaminhamento correto: como OPERADOR, requisições do comprador são repassadas/atendidas em conjunto com o CONTROLADOR (produtor/lojista) | | Procedimento de triagem Operador→Controlador; registro |
| D.9 | Prazos de resposta controlados (imediato/simplificado; até 15 dias para declaração completa — art. 19) | | Métrica de tempo de resposta; tickets |
| D.10 | Autenticação/verificação de identidade do requisitante para evitar acesso indevido | | Procedimento de verificação; logs de validação |
| D.11 | Revisão de decisões automatizadas, quando existirem (art. 20) | | Descrição de critérios; canal de revisão humana |
| D.12 | Registro (log) de todas as requisições de titulares e respectivos desfechos | | Base de tickets com data, tipo e resultado |

## 8. Domínio E — Retenção e Descarte

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| E.1 | Tabela de temporalidade (matriz de retenção) definida por tipo de dado e finalidade (art. 15 e 16) | | Política de retenção com prazos justificados |
| E.2 | Prazos fiscais/contábeis observados para NF-e e documentos fiscais (legislação tributária — em regra 5 anos) | | Matriz de retenção fiscal |
| E.3 | Guarda de registros de conexão/acesso a aplicação conforme Marco Civil (art. 15, Lei 12.965/2014) | | Configuração de logs; prazo de guarda |
| E.4 | Descarte seguro ao fim do prazo (eliminação ou anonimização irreversível — art. 16) | | Rotina automatizada de expurgo; evidência de execução |
| E.5 | Soft-delete não confundido com eliminação definitiva; existência de expurgo físico ao término do prazo legal | | Política de soft-delete + expurgo; scripts/documentação |
| E.6 | Dados de compradores retornados ou eliminados ao término do contrato com o CONTROLADOR (art. 15, IV) | | Cláusula contratual + procedimento de devolução/eliminação |
| E.7 | Backups incluídos na política de retenção e descarte (ciclo de vida e criptografia) | | Política de backup; rotação/expurgo |
| E.8 | Dados em ambientes de teste/homologação anonimizados ou mascarados | | Procedimento de mascaramento; verificação em amostragem |

## 9. Domínio F — Segurança da Informação e Criptografia

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| F.1 | Criptografia em trânsito (TLS/HTTPS) em todas as interfaces (app, APIs, portal de rastreio, integrações) | | Configuração TLS; relatório de scanner (ex.: SSL Labs) |
| F.2 | Criptografia em repouso no banco e no Storage (Supabase/Netlify) | | Configuração de encryption-at-rest do provedor |
| F.3 | Credenciais de API de terceiros armazenadas de forma **write-only**/segredo, nunca expostas ao cliente | | Revisão de código; configuração de secrets; teste de leitura |
| F.4 | Segregação de segredos em cofre/variáveis de ambiente (não versionadas em repositório) | | Verificação de .env fora do versionamento; secret scanning |
| F.5 | Dados sensíveis de pagamento (PIX/bancários) minimizados, tokenizados quando possível e com acesso restrito | | Modelo de dados; controle de acesso ao campo |
| F.6 | Práticas de desenvolvimento seguro (OWASP Top 10 / ASVS) aplicadas | | Padrões de código; SAST/DAST; revisões de PR |
| F.7 | Gestão de vulnerabilidades e patches (dependências Next.js/Supabase, libs) | | Relatórios de dependabot/scanner; SLA de correção |
| F.8 | Proteção contra injeção, XSS, CSRF e SSRF nas rotas de API e ingestão | | Testes de segurança; validação de entrada |
| F.9 | Rate limiting e proteção anti-abuso nas APIs de ingestão e no portal público | | Configuração de rate limit/WAF; logs |
| F.10 | Portal público de rastreio expõe **apenas status neutro**, sem PII (nome, endereço, CPF) | | Inspeção do endpoint público; revisão de payload retornado |
| F.11 | Identificadores de rastreio não sequenciais/adivinháveis (proteção contra enumeração/IDOR) | | Verificação de geração de tokens de rastreio |
| F.12 | Testes periódicos de intrusão (pentest) e/ou varreduras automatizadas | | Relatório de pentest; plano de correção |
| F.13 | Hardening de configuração (headers de segurança, CSP, cookies HttpOnly/Secure/SameSite) | | Scanner de headers; configuração |
| F.14 | Gestão de chaves criptográficas (geração, rotação, revogação) | | Política de gestão de chaves; evidência de rotação |

## 10. Domínio G — Controle de Acesso (RLS / RBAC)

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| G.1 | RLS (Row Level Security) habilitado em **todas** as tabelas de negócio (isolamento por company_id) | | Migrations; consulta de políticas ativas; teste cross-tenant |
| G.2 | Isolamento multi-tenant não depende do frontend — enforcement no banco (Tenant → Company → Branch → Membership) | | Teste de acesso com token de outro tenant retornando vazio |
| G.3 | RBAC por permissão (has_permission / resource.action) aplicado a operações de escrita | | Definição de policies; testes de permissão |
| G.4 | Princípio do menor privilégio nos papéis (roles) de usuário e colaborador | | Matriz de papéis x permissões |
| G.5 | Autenticação via Supabase Auth (JWT); política de senha e expiração de token | | Configuração de Auth; política de senha |
| G.6 | Autenticação multifator (MFA) para acessos administrativos/privilegiados | | Configuração de MFA; cobertura |
| G.7 | Processo de provisionamento/desprovisionamento de acessos (joiners/movers/leavers) | | SOP de gestão de acessos; logs de baixa |
| G.8 | Revisão periódica de acessos e recertificação de privilégios | | Ata de revisão de acessos; evidência de recertificação |
| G.9 | Chaves de serviço (service_role) restritas ao backend e nunca expostas ao cliente | | Revisão de uso da chave; segregação client/server |
| G.10 | Contas de integração (gateways, VHSYS, Correios) com escopo mínimo e credenciais próprias por company | | Inventário de credenciais; segregação por tenant |
| G.11 | Segregação de ambientes (produção, homologação, desenvolvimento) com acessos distintos | | Configuração de ambientes; matriz de acesso |

## 11. Domínio H — Logs, Trilha de Auditoria e Monitoramento

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| H.1 | Trilha de auditoria por triggers registrando insert/update/delete em tabelas de negócio | | Definição dos triggers de auditoria; amostra de registros |
| H.2 | Colunas de auditoria presentes em todo registro (created_by, updated_by, deleted_by, timestamps, reason_deleted) | | Esquema das tabelas; migrations |
| H.3 | Soft-delete implementado (deleted_at / reason_deleted) e leituras filtrando deleted_at is null | | Padrão de código; verificação de queries |
| H.4 | Logs de acesso/autenticação e de conexão retidos conforme Marco Civil | | Configuração de logs; prazo de retenção |
| H.5 | Logs protegidos contra adulteração (integridade) e com acesso restrito | | Controle de acesso a logs; imutabilidade/append-only |
| H.6 | Logs **não** armazenam dados sensíveis/credenciais em texto claro (masking) | | Amostragem de logs; política de mascaramento |
| H.7 | Monitoramento e alertas para eventos anômalos (acessos, falhas, picos, exfiltração) | | Configuração de alertas; runbook |
| H.8 | Sincronização de tempo (NTP) e carimbo confiável nos registros | | Configuração; consistência de timestamps |
| H.9 | Capacidade de reconstruir "quem fez o quê, quando" para fins probatórios | | Demonstração de trilha end-to-end em amostra |

## 12. Domínio I — Gestão de Incidentes de Segurança

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| I.1 | Plano de Resposta a Incidentes (PRI) documentado, com papéis e fluxo de escalonamento | | Documento de PRI aprovado |
| I.2 | Procedimento de comunicação à ANPD e aos titulares em prazo razoável (art. 48, LGPD) | | Modelo de comunicação; SLA interno; canal ANPD |
| I.3 | Critérios de avaliação de risco/relevância do incidente definidos | | Matriz de classificação de incidentes |
| I.4 | Registro/base de incidentes com histórico, causa-raiz e lições aprendidas | | Base de incidentes; relatórios post-mortem |
| I.5 | Fluxo específico para incidentes envolvendo dados de comprador: notificação ao CONTROLADOR (produtor/lojista) sem demora (art. 39/48) | | Cláusula contratual de notificação; procedimento |
| I.6 | Testes/simulações periódicas (tabletop) do plano de incidentes | | Ata de simulação; plano de melhoria |
| I.7 | Integração com sub-operadores para notificação de incidentes na cadeia (Supabase, Netlify, gateways, VHSYS, Correios) | | Cláusulas contratuais; contatos de segurança |
| I.8 | Preservação de evidências (forense) e cadeia de custódia | | Procedimento forense; ferramentas |

## 13. Domínio J — Sub-operadores, Terceiros e Cadeia de Tratamento

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| J.1 | Inventário completo de sub-operadores e terceiros com acesso a dados (Supabase, Netlify, VHSYS, Correios, Monetizze, AppMax, Hotmart, Kiwify, WhatsApp, e-mail, marketplaces) | | Lista de sub-operadores com finalidade e dados acessados |
| J.2 | Contrato de tratamento (DPA) firmado com cada operador/sub-operador (art. 39) | | DPAs assinados / termos de tratamento dos provedores |
| J.3 | Due diligence de segurança e privacidade prévia à contratação | | Questionário de avaliação; certificações do fornecedor |
| J.4 | Cláusulas de confidencialidade, segurança, incidentes e auditoria nos contratos | | Contratos com cláusulas específicas |
| J.5 | Autorização prévia do CONTROLADOR para uso de sub-operadores na cadeia | | Cláusula de autorização; lista aprovada |
| J.6 | Verificação da localização de armazenamento/processamento de cada terceiro (data residency) | | Documentação do provedor; mapa de fluxos |
| J.7 | Segregação de credenciais por tenant e escopo mínimo nas integrações | | Configuração; inventário de credenciais |
| J.8 | Reavaliação periódica dos terceiros e monitoramento de mudanças de subcontratados | | Cronograma de reavaliação; registro |

## 14. Domínio K — Transferência Internacional de Dados

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| K.1 | Identificação de transferências internacionais (infra/processamento fora do Brasil — Supabase/Netlify) — arts. 33–36, LGPD | | Mapa de fluxos transfronteiriços |
| K.2 | Mecanismo de adequação aplicado (cláusulas-padrão, garantias contratuais, adequação da ANPD) | | Cláusulas contratuais; instrumentos de garantia |
| K.3 | Informação ao titular sobre transferência internacional (transparência) | | Política de Privacidade com seção de transferência |
| K.4 | Compatibilidade com GDPR quando houver titulares/infra na UE (bases e SCCs) | | Documentação GDPR; SCCs |
| K.5 | Avaliação de risco do país/terceiro receptor | | Análise de adequação; registro |

## 15. Domínio L — ROPA e RIPD

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| L.1 | Registro das Operações de Tratamento (ROPA) mantido e atualizado (art. 37, LGPD) | | ROPA por atividade, com base legal, finalidade, dados, retenção e compartilhamento |
| L.2 | ROPA cobre os fluxos-chave: ingestão de pedidos, Correios/rastreio, notificações, split/repasses, NF-e, cadastro de usuários/colaboradores | | ROPA detalhado por fluxo |
| L.3 | Relatório de Impacto à Proteção de Dados (RIPD/DPIA) elaborado para tratamentos de alto risco (art. 38) | | RIPD assinado, com metodologia e medidas mitigadoras |
| L.4 | RIPD contempla tratamento em larga escala de PII de compradores e dados financeiros de split | | RIPD dos fluxos de ingestão e de repasses |
| L.5 | Metodologia de avaliação de risco consistente (ISO 31000 / metodologia própria) | | Documento de metodologia; matriz de risco |
| L.6 | ROPA e RIPD prontos para apresentação à ANPD mediante requisição | | Versões consolidadas e datadas |
| L.7 | Diferenciação no ROPA entre atividades como OPERADOR e como CONTROLADOR | | ROPA segmentado por papel |

## 16. Domínio M — Fluxos Específicos do GLOP

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| M.1 | Ingestão de pedidos: validação e sanitização do payload de gateways/e-commerces antes da persistência | | Código de validação; testes |
| M.2 | Ingestão: idempotência e prevenção de duplicidade/injeção de pedidos forjados | | Chaves de idempotência; assinatura/verificação de webhooks |
| M.3 | Webhooks dos gateways autenticados (assinatura/segredo) e sobre HTTPS | | Configuração de verificação de assinatura |
| M.4 | Correios (PPN/SRO): dados do comprador enviados no mínimo necessário para postagem e rastreio | | Mapeamento de campos enviados |
| M.5 | Notificações a comprador (e-mail/WhatsApp) com conteúdo mínimo e link de rastreio seguro | | Modelos de mensagem; revisão de conteúdo |
| M.6 | Portal público de rastreio: sem login, expõe **apenas** status neutro, sem PII nem valor/produto identificável | | Inspeção do endpoint; teste de enumeração |
| M.7 | Split/coprodução: dados de PIX/bancários acessíveis somente a papéis autorizados e mascarados na UI | | Controle de acesso; masking na interface |
| M.8 | NF-e/VHSYS: documentos fiscais armazenados com controle de acesso e retenção legal | | Configuração de Storage; matriz de retenção |
| M.9 | Segregação total entre tenants nos fluxos acima (nenhum vazamento cross-company) | | Testes de isolamento por fluxo |
| M.10 | Dados de comprador tratados exclusivamente sob instrução do CONTROLADOR respectivo (sem uso próprio) | | Cláusula de instrução; ausência de uso secundário |

## 17. Domínio N — Continuidade de Negócios e Resiliência (ISO 22301)

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| N.1 | Plano de Continuidade de Negócios (PCN) e de Recuperação de Desastres (DRP) documentados | | PCN/DRP aprovados |
| N.2 | Backups regulares, criptografados e testados (restore test) | | Política de backup; evidência de teste de restauração |
| N.3 | RTO e RPO definidos por serviço crítico | | Documento com RTO/RPO |
| N.4 | Dependência de provedores (Supabase/Netlify) avaliada quanto a disponibilidade e saída (exit plan) | | Análise de dependência; plano de portabilidade |
| N.5 | Testes periódicos de contingência | | Ata de teste; plano de melhoria |

## 18. Domínio O — Gestão de Riscos (ISO 31000 / NIST CSF)

| Item | Verificação | Conformidade (C/P/NC/NA) | Evidência esperada |
|---|---|---|---|
| O.1 | Processo estruturado de identificação, análise, avaliação e tratamento de riscos | | Metodologia de risco; registro de riscos |
| O.2 | Matriz de riscos de privacidade e segurança mantida e revisada | | Risk register com donos e prazos |
| O.3 | Riscos residuais aceitos formalmente por instância competente | | Registro de aceitação de risco |
| O.4 | Mapeamento de controles às funções do NIST CSF (Identificar, Proteger, Detectar, Responder, Recuperar) | | Matriz de mapeamento |
| O.5 | Indicadores de risco monitorados e reportados | | Painel de riscos |

## 19. Consolidação dos Resultados (Scorecard)

| Domínio | Itens totais | Conforme | Parcial | Não Conforme | N/A | % Conformidade |
|---|---|---|---|---|---|---|
| A. Governança e Programa | 8 | | | | | |
| B. Bases Legais | 10 | | | | | |
| C. Princípios e Minimização | 6 | | | | | |
| D. Direitos dos Titulares | 12 | | | | | |
| E. Retenção e Descarte | 8 | | | | | |
| F. Segurança e Criptografia | 14 | | | | | |
| G. Controle de Acesso | 11 | | | | | |
| H. Logs e Auditoria | 9 | | | | | |
| I. Gestão de Incidentes | 8 | | | | | |
| J. Sub-operadores e Terceiros | 8 | | | | | |
| K. Transferência Internacional | 5 | | | | | |
| L. ROPA e RIPD | 7 | | | | | |
| M. Fluxos Específicos GLOP | 10 | | | | | |
| N. Continuidade | 5 | | | | | |
| O. Gestão de Riscos | 5 | | | | | |
| **Total** | **126** | | | | | |

**Parecer geral da auditoria:** [PARTE] deve consolidar aqui o grau de maturidade global, os achados críticos e o plano de remediação priorizado por risco.

---

## 20. Engenharia Jurídica & Governança

### (a) Fundamentação das cláusulas e itens (lei/norma que embasa)

- **LGPD (Lei nº 13.709/2018):** art. 6º (princípios), art. 7º e 11 (bases legais), art. 8º (consentimento), art. 9º (transparência), art. 10 (legítimo interesse), art. 15 e 16 (término e descarte), art. 18 e 19 (direitos e prazos), art. 20 (decisões automatizadas), art. 33–36 (transferência internacional), art. 37 (ROPA), art. 38 (RIPD), art. 39 (operador e instruções do controlador), art. 41 (encarregado), art. 46–49 (segurança e boas práticas), art. 48 (comunicação de incidentes), art. 50 (governança), art. 52 (sanções administrativas).
- **Marco Civil da Internet (Lei nº 12.965/2014) e Decreto nº 8.771/2016:** guarda de registros de conexão e de acesso a aplicações, padrões de segurança.
- **Código de Defesa do Consumidor (Lei nº 8.078/1990):** transparência, informação e comunicação ao consumidor comprador.
- **Legislação tributária/fiscal:** prazos de guarda de documentos fiscais (NF-e), aplicável ao fluxo VHSYS.
- **ISO/IEC 27001** (SGSI), **ISO/IEC 27701** (extensão de privacidade/PIMS), **ISO/IEC 22301** (continuidade), **ISO 31000** (gestão de riscos), **NIST Cybersecurity Framework** (funções de segurança) e **OWASP ASVS/Top 10** (desenvolvimento seguro).
- **GDPR (Regulamento (UE) 2016/679):** aplicável subsidiariamente a fluxos com titulares na UE ou infraestrutura no exterior (SCCs, DPIA, base legal).

### (b) Riscos mitigados

1. **Sanções da ANPD** (advertência, multa de até 2% do faturamento limitada a R$ 50 milhões por infração, publicização, bloqueio/eliminação — art. 52, LGPD) por ausência de bases legais, ROPA, RIPD ou de encarregado.
2. **Vazamento de PII de compradores** em larga escala (nome, CPF, endereço) por falha de RLS/RBAC, credenciais expostas ou portal público inseguro — mitigado pelos domínios F, G, H e M.
3. **Responsabilização solidária/regressiva** como operador perante o controlador (art. 42, LGPD) por descumprimento de instruções — mitigado por DPA e domínio B.
4. **Enumeração/IDOR no portal de rastreio** expondo status/PII — mitigado por F.10, F.11 e M.6.
5. **Comprometimento de dados financeiros de split/PIX** — mitigado por F.5, G.10 e M.7.
6. **Não comunicação tempestiva de incidente** à ANPD/titulares/controlador — mitigado pelo domínio I.
7. **Transferência internacional irregular** por uso de infra no exterior sem mecanismo de adequação — mitigado pelo domínio K.
8. **Retenção indevida/descarte inseguro** — mitigado pelo domínio E.
9. **Indisponibilidade e perda de dados** — mitigado pelos domínios N e O.
10. **Danos morais/materiais ao titular** e ações civis (arts. 42–45, LGPD; CDC) — mitigados pelo conjunto de controles.

### (c) Checklist de aplicação deste instrumento

1. Confirmar identificação de partes, DPO e escopo (seções 1 a 3).
2. Levantar evidências de cada item **antes** de atribuir conformidade.
3. Preencher a coluna de conformidade (C/P/NC/NA) com justificativa para NA.
4. Registrar plano de ação (responsável, prazo/SLA, severidade) para todo P/NC.
5. Consolidar o scorecard (seção 19) e emitir parecer.
6. Submeter o relatório ao DPO e à gestão; arquivar com controle de versão.
7. Reavaliar na periodicidade definida no plano de revisão.

### (d) Matriz RACI

| Atividade | DPO/Encarregado | Segurança da Informação | Jurídico | Engenharia/DevOps | Gestão/Diretoria | Auditoria Independente |
|---|---|---|---|---|---|---|
| Manutenção do ROPA/RIPD | A/R | C | C | C | I | I |
| Definição de bases legais | A | I | R | I | I | C |
| Atendimento a titulares | A/R | I | C | C | I | I |
| Controles de segurança/criptografia | C | A/R | I | R | I | C |
| RLS/RBAC e controle de acesso | I | A | I | R | I | C |
| Gestão de logs e auditoria | C | A/R | I | R | I | C |
| Resposta a incidentes | A | R | C | R | I | I |
| Gestão de sub-operadores/DPA | A | C | R | C | I | C |
| Retenção e descarte | A | C | C | R | I | C |
| Continuidade e backups | I | A | I | R | C | C |
| Gestão de riscos | A | R | C | C | C | C |
| Aprovação do relatório de auditoria | C | C | C | I | A | R |

Legenda: **R** = Responsável (executa); **A** = Aprovador (responde); **C** = Consultado; **I** = Informado.

### (e) Plano de revisão

- **Revisão ordinária:** a cada 12 meses ou a cada ciclo de auditoria, o que ocorrer primeiro.
- **Revisão extraordinária (gatilhos):** alteração legislativa/regulatória (LGPD, ANPD, normas ISO/NIST); novo fluxo de tratamento ou nova integração (novo gateway/marketplace/transportadora); incidente de segurança relevante; mudança de sub-operador ou de infraestrutura; requisição da ANPD; conclusão de plano de remediação.
- **Responsável pela revisão:** a ser designado pela administração (DPO), com apoio de Segurança da Informação e Jurídico.
- **Registro:** toda revisão gera nova versão registrada no controle de versão abaixo.

### (f) Controle de versão

| Versão | Data | Autor/Responsável | Descrição da alteração | Aprovação |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | [PARTE] | Emissão inicial do Checklist de Auditoria (LGPD + Segurança da Informação) para o [NOME FANTASIA: GLOP] | a ser designado pela administração |
| | | | | |
| | | | | |

---

**Encerramento.** Este checklist é instrumento vivo de conformidade e não substitui parecer jurídico individualizado nem auditoria técnica especializada. Recomenda-se sua aplicação por profissionais habilitados, com preservação das evidências, e sua articulação com a Política de Privacidade, a Política de Segurança da Informação, os Contratos de Operador (DPA), o ROPA e o RIPD do [NOME FANTASIA: GLOP].
