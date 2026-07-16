> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# Questionário de Due Diligence de Fornecedores, Sub-Operadores e Sub-Contratados

## Instrumento de Avaliação de Conformidade em Segurança da Informação, Proteção de Dados (LGPD/GDPR) e Continuidade de Negócio

**Controlador/Operador contratante:** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, nome fantasia [NOME FANTASIA: GLOP], inscrita no CNPJ sob o nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, neste ato representada por seu Encarregado pelo Tratamento de Dados Pessoais (DPO), a ser designado pela administração, contato lemoncapsencapsulados@gmail.com.

**Fornecedor/Sub-operador avaliado (PARTE respondente):** [RAZÃO SOCIAL DO FORNECEDOR], CNPJ 55.836.075/0001-07, endereço Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, representante [PARTE], contato [E-MAIL].

**Data de emissão do questionário:** 16 de julho de 2026 · **Prazo de devolução:** 16 de julho de 2026 · **Versão do questionário:** 1.0

---

## 1. Objetivo

1. Este Questionário de Due Diligence (doravante "Questionário") tem por objetivo avaliar, de forma estruturada, documentada e auditável, a capacidade técnica, organizacional, jurídica e financeira de fornecedores, prestadores de serviço, sub-operadores e sub-contratados (doravante, indistintamente, "Fornecedor") que tratam, hospedam, transmitem, processam ou têm acesso — ainda que potencial ou incidental — a dados pessoais, dados pessoais sensíveis, credenciais, documentos fiscais ou segredos de negócio da plataforma **GLOP (Global Logistics Platform)**, SaaS de logística/ERP para dropshipping e infoprodutos.
2. O Questionário integra o processo de **homologação prévia** de fornecedores e a **reavaliação periódica** de fornecedores já contratados, servindo de base para a decisão de contratar, manter, condicionar ou rescindir a relação, e para o registro da devida diligência exigida pela Lei nº 13.709/2018 (LGPD) e demais normas aplicáveis.
3. As respostas prestadas neste Questionário integram, para todos os efeitos, o **Contrato de Prestação de Serviços** e o respectivo **Acordo de Tratamento de Dados (DPA — Data Processing Agreement)** celebrados entre as partes, e valem como declaração de veracidade, sujeitando o Fornecedor às penalidades contratuais e legais em caso de falsidade, omissão ou inexatidão material.

## 2. Escopo

1. Aplica-se a **todo** Fornecedor cuja atividade se enquadre em, ao menos, uma das hipóteses abaixo, com destaque para os sub-operadores atuais do GLOP:
   - Infraestrutura e hospedagem: **Supabase** (banco PostgreSQL, Auth/JWT, Storage, Edge Functions, Realtime) e **Netlify** (hospedagem SSR Next.js).
   - Emissão de documentos fiscais: **VHSYS** (NF-e).
   - Transporte e rastreamento: **Correios** (pré-postagem/PPN, rastreio/SRO).
   - Gateways de pagamento e recebíveis: **Monetizze**, **AppMax** (split de pagamento e repasses PIX/bancários), **Hotmart**, **Kiwify**.
   - Ingestão de pedidos e plataformas de e-commerce: **Shopify**, **WooCommerce**, **Nuvemshop**, **Mercado Livre**.
   - Canais de comunicação com o comprador: provedores de **WhatsApp** e **e-mail** transacional/marketing.
   - Qualquer outro fornecedor que trate PII do comprador (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor), dados de coprodutores/afiliados, dados bancários/PIX de repasse ou credenciais de API.
2. **Fica fora do escopo** apenas o fornecedor que comprovadamente não acessa, não hospeda e não transmite dados pessoais, credenciais ou dados fiscais do GLOP, hipótese que deverá ser formalmente declarada e validada pelo DPO.
3. O Questionário deve ser respondido **integralmente**. Perguntas assinaladas como "Não aplicável" exigem justificativa objetiva no campo de evidências, sob pena de serem tratadas como resposta negativa.

## 3. Como responder e como pontuar

1. Cada pergunta possui: (i) enunciado; (ii) coluna de **Resposta** (Sim / Parcial / Não / N/A); (iii) coluna de **Evidência exigida** (documento, política, certificado, print, cláusula); (iv) **Critério de aceite**.
2. **Classificação de criticidade** de cada item:
   - **C — Crítico (bloqueante):** reprovação impede a contratação/manutenção até saneamento.
   - **A — Alto:** exige plano de ação com prazo antes da contratação.
   - **M — Médio:** admite contratação com ressalva monitorada.
3. **Escala de pontuação** por resposta: Sim = 2 · Parcial = 1 · Não = 0 · N/A = neutro (removido do denominador).
4. **Índice de Conformidade (IC)** = (soma dos pontos obtidos ÷ soma dos pontos possíveis) × 100.
5. **Régua de decisão:**

| Índice de Conformidade (IC) | Itens Críticos reprovados | Decisão |
|---|---|---|
| IC ≥ 85% | Nenhum | **Aprovado** para contratação |
| 70% ≤ IC < 85% | Nenhum | **Aprovado com ressalvas** e plano de ação (prazo até 90 dias) |
| IC < 70% | Nenhum | **Reprovado** — reapresentação após saneamento |
| Qualquer IC | 1 ou mais | **Reprovado (bloqueante)** — vedada a contratação |

6. Nenhuma pontuação favorável supera a reprovação em item **Crítico**: item Crítico "Não" veda a contratação independentemente do IC global.

---

# BLOCO A — IDENTIFICAÇÃO E QUALIFICAÇÃO DO FORNECEDOR

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| A.1 | Informe razão social, nome fantasia, CNPJ (ou registro equivalente no país de origem) e natureza jurídica. | C | | Cartão CNPJ / contrato social / registro estrangeiro | Dados válidos, ativos e verificáveis em fonte oficial |
| A.2 | Endereço da sede e dos estabelecimentos que tratarão dados do GLOP (país, estado, cidade). | C | | Comprovante de endereço / contrato social | Localidades identificadas; datacenters informados |
| A.3 | Indique o representante legal e o preposto técnico-comercial da relação. | M | | Procuração / ato societário | Poderes de representação comprovados |
| A.4 | Há Encarregado (DPO) formalmente nomeado? Informe nome e canal de contato. | C | | Nomeação e página pública de contato | DPO nomeado e canal ativo (art. 41, LGPD) |
| A.5 | Tempo de operação no mercado e porte (faturamento/nº de colaboradores em faixas). | M | | Demonstrações / declaração | Operação compatível com a criticidade do serviço |
| A.6 | Descreva objetivamente o serviço a ser prestado ao GLOP e os fluxos que tocará (ex.: hospedagem de PII do comprador, emissão de NF-e, split de pagamento, envio de WhatsApp/e-mail). | C | | Proposta técnica / escopo | Escopo aderente aos fluxos reais do GLOP |
| A.7 | Situação de regularidade fiscal, trabalhista e previdenciária. | A | | Certidões negativas (federal, FGTS, trabalhista) | Certidões válidas ou justificativa de regularização |
| A.8 | Existência de processos judiciais/administrativos relevantes envolvendo vazamento de dados, sanção da ANPD/autoridade estrangeira, ou quebra de SLA. | A | | Declaração + consulta pública | Ausência de passivo material não sanado |
| A.9 | Estrutura de governança corporativa (grupo econômico, controladora, país da matriz). | A | | Organograma societário | Cadeia de controle transparente |
| A.10 | Cobertura de seguro de responsabilidade civil e/ou cyber (limite e escopo). | M | | Apólice vigente | Cobertura compatível com o risco do serviço |
| A.11 | Declara não estar em lista de sanções, embargos ou restrições (compliance/PLD-FT)? | A | | Declaração + screening | Ausência de apontamentos em listas restritivas |

---

# BLOCO B — SEGURANÇA DA INFORMAÇÃO (ISO 27001 / SOC 2 / NIST / OWASP)

## B.1 Governança e política de segurança

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| B.1.1 | Possui Política de Segurança da Informação (PSI) formal, aprovada pela alta direção e revisada ao menos anualmente? | C | | PSI vigente + ata/registro de aprovação | Documento datado, versionado e revisado ≤ 12 meses |
| B.1.2 | Existe função/área de segurança da informação com responsável designado (CISO ou equivalente)? | A | | Organograma / job description | Responsável formal e independente da área de TI operacional |
| B.1.3 | Há programa de gestão de riscos de SI aderente à ISO 31000 / ISO 27005? | A | | Matriz de riscos / metodologia | Riscos identificados, tratados e reavaliados periodicamente |
| B.1.4 | Colaboradores assinam termo de confidencialidade e recebem treinamento de segurança/privacidade? | A | | Termos + registros de treinamento | Treinamento ≤ 12 meses e NDA para todos com acesso |
| B.1.5 | Há política de mesa limpa, uso aceitável e classificação da informação? | M | | Políticas internas | Documentos vigentes e comunicados |

## B.2 Controle de acesso e identidade

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| B.2.1 | Aplica princípio do menor privilégio e segregação de funções (RBAC)? | C | | Política de acesso / matriz de perfis | Acessos baseados em papel e revisados periodicamente |
| B.2.2 | Exige autenticação multifator (MFA) para acessos administrativos e a sistemas que tocam dados do GLOP? | C | | Configuração / print / política | MFA obrigatório para admins e acessos remotos |
| B.2.3 | Realiza revisão periódica de acessos (recertificação) e revogação imediata no desligamento? | A | | Logs de recertificação / procedimento | Recertificação ≤ 6 meses; revogação ≤ 24h do desligamento |
| B.2.4 | Credenciais de integração (ex.: chaves de API do GLOP) são armazenadas de forma cifrada e tratadas como write-only, sem exposição em logs? | C | | Descrição técnica / cofre de segredos | Segredos em cofre (KMS/Vault), nunca em texto claro nem em log |
| B.2.5 | Há gestão de contas privilegiadas (PAM) e monitoramento de sessão administrativa? | A | | Ferramenta/PAM / logs | Contas privilegiadas rastreáveis e monitoradas |

## B.3 Criptografia e proteção de dados

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| B.3.1 | Dados em trânsito são cifrados (TLS 1.2+ / mTLS quando aplicável)? | C | | Configuração / relatório SSL | TLS 1.2+ obrigatório; protocolos legados desabilitados |
| B.3.2 | Dados em repouso (PII do comprador, CPF/CNPJ, dados bancários/PIX, documentos fiscais) são cifrados? | C | | Descrição do modelo de criptografia | Cifragem em repouso com gestão de chaves segregada |
| B.3.3 | Há gestão de ciclo de vida de chaves criptográficas (geração, rotação, revogação)? | A | | Política de chaves / KMS | Rotação definida e custódia controlada |
| B.3.4 | Aplica técnicas de minimização, pseudonimização ou anonimização quando cabível? | A | | Descrição técnica | Minimização documentada por fluxo |
| B.3.5 | O portal público de rastreio expõe apenas status neutro, sem PII do comprador (à semelhança do modelo do GLOP)? | C | | Especificação da interface pública | Nenhum dado pessoal em endpoint público sem autenticação |

## B.4 Desenvolvimento seguro e vulnerabilidades (OWASP)

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| B.4.1 | Adota práticas de desenvolvimento seguro (SDLC seguro, revisão de código, referência OWASP Top 10 / ASVS)? | A | | Política de SDLC / evidência de revisão | Controles OWASP incorporados ao ciclo |
| B.4.2 | Executa testes de vulnerabilidade (SAST/DAST/SCA) e testes de intrusão (pentest) periódicos? | C | | Relatórios (sumário executivo) | Pentest ≤ 12 meses; vulnerabilidades altas/críticas tratadas |
| B.4.3 | Possui processo de gestão de patches e correções com SLA por severidade? | A | | Política de patch management | Críticas corrigidas em prazo definido e curto |
| B.4.4 | Ambientes de produção, homologação e desenvolvimento são segregados, sem uso de dados reais em ambientes de teste? | A | | Arquitetura / política de dados de teste | Segregação efetiva; dados de produção não usados em teste |
| B.4.5 | Mantém inventário de ativos e de dependências (SBOM) e monitora componentes vulneráveis? | M | | Inventário / SBOM | Inventário atualizado e monitorado |

## B.5 Operação, monitoramento e resiliência de infraestrutura

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| B.5.1 | Mantém trilhas de auditoria/logs imutáveis de acesso e operações sobre dados, com retenção definida? | C | | Política de logs / amostra | Logs íntegros, protegidos e retidos por prazo definido |
| B.5.2 | Possui monitoramento contínuo, detecção de intrusão e resposta (SIEM/SOC 24x7 ou equivalente)? | A | | Descrição do monitoramento | Monitoramento ativo com alertas e triagem |
| B.5.3 | Aplica hardening, segmentação de rede e proteção de borda (WAF, firewall, anti-DDoS)? | A | | Padrões de hardening / arquitetura | Controles de rede implementados e documentados |
| B.5.4 | Realiza backups cifrados, com testes de restauração periódicos? | C | | Política de backup / evidência de teste de restore | Backup cifrado + restauração testada ≤ 12 meses |
| B.5.5 | Datacenters/nuvem possuem controles físicos e certificações (ISO 27001, SOC 2, Tier)? | A | | Certificados do provedor | Certificações vigentes comprovadas |

## B.6 Certificações e auditorias independentes

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| B.6.1 | Possui certificação ISO/IEC 27001 (SGSI) vigente? | A | | Certificado + escopo + validade | Certificado válido e escopo cobrindo o serviço |
| B.6.2 | Possui ISO/IEC 27701 (Privacidade — PIMS)? | M | | Certificado | Certificado válido ou plano de adequação |
| B.6.3 | Possui relatório SOC 2 Tipo II (ou SOC 1, quando aplicável)? | A | | Relatório SOC 2 Tipo II ≤ 12 meses | Relatório recente sem exceções materiais não sanadas |
| B.6.4 | Possui ISO 22301 (Continuidade) e/ou ISO 31000 (Riscos)? | M | | Certificado / metodologia | Comprovação ou processo equivalente maduro |
| B.6.5 | Aderente a frameworks reconhecidos (NIST CSF/800-53, CIS Controls, PCI-DSS quando trata cartão)? | A | | Declaração de aderência / atestado | Aderência demonstrável; PCI-DSS obrigatório se processa cartão |
| B.6.6 | Autoriza auditoria pelo GLOP ou por terceiro independente, mediante aviso prévio razoável? | C | | Cláusula de direito de auditoria | Direito de auditoria previsto contratualmente |

---

# BLOCO C — PROTEÇÃO DE DADOS PESSOAIS (LGPD / GDPR) E TRANSFERÊNCIA INTERNACIONAL

## C.1 Papéis, base legal e finalidade

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| C.1.1 | Reconhece atuar como **Operador** (art. 5º, VII, LGPD), tratando dados apenas conforme instruções documentadas do GLOP (Controlador), sem uso próprio? | C | | Aceite ao DPA / cláusula | Adesão expressa; vedação de uso para finalidade própria |
| C.1.2 | Compreende que o GLOP possui dupla natureza — Operador perante o produtor/lojista (Controlador dos dados do comprador) e Controlador dos dados de seus próprios usuários — e respeita a cadeia de tratamento? | C | | Declaração de ciência | Cadeia Controlador→Operador→Sub-operador compreendida |
| C.1.3 | Trata apenas os dados estritamente necessários à finalidade (minimização), sem coleta excessiva? | A | | Mapeamento de dados por fluxo | Escopo limitado ao necessário (art. 6º, III) |
| C.1.4 | Mantém registro das operações de tratamento (ROPA / art. 37, LGPD)? | A | | ROPA / relatório | Registro atualizado das operações |
| C.1.5 | Tem processo para tratar dados sensíveis/atenção especial (ex.: CPF associado a compra), respeitando bases legais adequadas? | A | | Política de dados sensíveis | Tratamento com salvaguardas reforçadas |

## C.2 Direitos dos titulares e ciclo de vida do dado

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| C.2.1 | Coopera com o GLOP no atendimento a requisições de titulares (acesso, correção, eliminação, portabilidade, oposição — art. 18, LGPD) dentro dos prazos? | C | | Procedimento de atendimento a titulares | Suporte a requisições com SLA compatível |
| C.2.2 | Possui política de retenção e eliminação segura ao fim do contrato/finalidade, com devolução ou destruição comprovada dos dados do GLOP? | C | | Política de retenção + modelo de atestado de destruição | Devolução/eliminação garantida e comprovável |
| C.2.3 | Garante que dados do comprador (nome, CPF/CNPJ, e-mail, telefone, endereço, produto, valor) não sejam reutilizados, vendidos ou compartilhados fora do escopo? | C | | Cláusula de não reuso / declaração | Vedação absoluta de reuso não autorizado |
| C.2.4 | Aplica prazos legais de guarda de documentos fiscais (ex.: NF-e via VHSYS) sem exceder o necessário? | A | | Tabela de temporalidade | Retenção fiscal fundamentada em obrigação legal |
| C.2.5 | Notifica o GLOP sobre ordens de autoridades/terceiros que exijam divulgação de dados, salvo vedação legal? | A | | Procedimento de resposta a requisições legais | Notificação prévia sempre que juridicamente possível |

## C.3 Transferência internacional de dados

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| C.3.1 | Há transferência internacional de dados do GLOP? Indique países, datacenters e provedores envolvidos (ex.: nuvem do Supabase/Netlify, gateways). | C | | Mapa de fluxos transfronteiriços | Rotas internacionais mapeadas e informadas |
| C.3.2 | A transferência observa hipótese válida da LGPD (arts. 33 a 36) e/ou do GDPR (país adequado, cláusulas-padrão/SCC, normas corporativas globais/BCR)? | C | | SCC / atestado de adequação / BCR | Mecanismo legal de transferência formalizado |
| C.3.3 | Oferece opção de residência de dados no Brasil ou região específica, quando exigido pelo GLOP? | A | | Documentação de região de hospedagem | Possibilidade de restringir região quando requisitado |
| C.3.4 | Adota salvaguardas adicionais para transferências (cifragem, controles de acesso jurisdicional, avaliação de risco do país de destino)? | A | | Descrição de salvaguardas | Salvaguardas técnicas e organizacionais adicionais |
| C.3.5 | Está sujeito a legislação estrangeira que possa obrigar acesso governamental aos dados? Em caso positivo, descreva mitigação. | A | | Análise jurídica / declaração | Riscos de acesso governamental avaliados e mitigados |

## C.4 Privacy by Design, DPIA e conformidade documental

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| C.4.1 | Incorpora Privacy by Design & by Default nos produtos/serviços? | A | | Política / evidência de projeto | Privacidade considerada desde a concepção |
| C.4.2 | Elabora Relatório de Impacto à Proteção de Dados (RIPD/DPIA) quando o tratamento apresenta alto risco? | A | | RIPD/DPIA aplicável | Metodologia de RIPD existente e aplicada |
| C.4.3 | Aceita firmar Acordo de Tratamento de Dados (DPA) com o GLOP, com cláusulas de sub-operação, auditoria e notificação de incidentes? | C | | DPA assinado | DPA celebrado como anexo contratual |
| C.4.4 | Mantém canal do titular e do Encarregado ativos e responde à ANPD/autoridades quando demandado? | A | | Canal + fluxo de resposta | Canais operantes e responsivos |

---

# BLOCO D — SUBCONTRATAÇÃO E CADEIA DE SUB-OPERADORES

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| D.1 | Utiliza sub-operadores/sub-contratados para prestar o serviço ao GLOP? Liste-os (nome, país, finalidade). | C | | Lista de sub-operadores | Cadeia completa divulgada e mantida atualizada |
| D.2 | Obtém autorização prévia (específica ou geral com direito de objeção) do GLOP antes de incluir/substituir sub-operador? | C | | Cláusula / procedimento de aviso | Aviso prévio com prazo para objeção do Controlador |
| D.3 | Impõe contratualmente aos sub-operadores obrigações **no mínimo** equivalentes às assumidas perante o GLOP (flow-down)? | C | | Modelo contratual / DPA back-to-back | Obrigações espelhadas em toda a cadeia |
| D.4 | Responde solidária/integralmente perante o GLOP pelos atos e omissões de seus sub-operadores? | C | | Cláusula de responsabilidade | Responsabilidade do Operador pela cadeia assegurada |
| D.5 | Realiza due diligence e reavaliação periódica de seus próprios sub-operadores? | A | | Procedimento / evidência | Programa de gestão de terceiros ativo |
| D.6 | Garante que gateways e provedores de recebíveis (ex.: split/AppMax, PIX, dados bancários) tratem dados financeiros com padrão PCI/segurança reforçada? | C | | Atestados dos sub-operadores financeiros | Segurança financeira comprovada na cadeia |
| D.7 | Notifica o GLOP sobre mudança material na cadeia (troca de datacenter, fusão/aquisição, mudança de país)? | A | | Procedimento de notificação | Comunicação tempestiva de mudanças relevantes |

---

# BLOCO E — GESTÃO DE INCIDENTES E VIOLAÇÃO DE DADOS

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| E.1 | Possui Plano de Resposta a Incidentes (PRI) formal, com papéis, fluxos e classificação de severidade? | C | | PRI vigente | Plano documentado, testado e atribuído |
| E.2 | Compromete-se a notificar o GLOP sobre incidente de segurança/violação de dados **sem demora injustificada** e em prazo máximo definido? | C | | Cláusula de notificação | Notificação em prazo curto e definido (ex.: até 24–48h da ciência) |
| E.3 | A notificação de incidente inclui natureza dos dados, titulares afetados, causa provável, impacto e medidas de contenção/remediação? | C | | Modelo de comunicação de incidente | Conteúdo mínimo compatível com o art. 48 da LGPD |
| E.4 | Apoia o GLOP na comunicação à ANPD e aos titulares, quando exigível, dentro do prazo regulatório? | A | | Procedimento conjunto | Cooperação formal em comunicações regulatórias |
| E.5 | Mantém registro de incidentes, análise de causa raiz e lições aprendidas? | A | | Registro / relatórios pós-incidente | Histórico documentado e ações corretivas |
| E.6 | Realiza simulações/exercícios de resposta a incidente periodicamente? | M | | Evidência de exercício | Simulação ≤ 12 meses |
| E.7 | Possui canal 24x7 (ou SLA definido) para acionamento de incidentes pelo GLOP? | A | | Contato de emergência / SLA | Canal e SLA de acionamento formalizados |

---

# BLOCO F — CONTINUIDADE DE NEGÓCIO E DISPONIBILIDADE

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| F.1 | Possui Plano de Continuidade de Negócio (PCN/BCP) e Plano de Recuperação de Desastres (DRP) formais? | C | | PCN/DRP vigentes | Planos documentados e aprovados |
| F.2 | Define RTO (tempo de recuperação) e RPO (perda máxima de dados) para o serviço prestado ao GLOP? | A | | Documento de RTO/RPO | Métricas definidas e compatíveis com a criticidade |
| F.3 | Oferece SLA de disponibilidade com metas mensuráveis e penalidades por descumprimento? | A | | SLA contratual | Uptime alvo (ex.: ≥ 99,9%) e remédios definidos |
| F.4 | Possui redundância, alta disponibilidade e failover para os componentes que suportam o GLOP? | A | | Arquitetura de resiliência | Redundância comprovada em pontos críticos |
| F.5 | Testa o PCN/DRP periodicamente e registra resultados? | A | | Evidência de teste | Teste ≤ 12 meses com resultados registrados |
| F.6 | Garante portabilidade e reversibilidade (exit plan): devolução de dados em formato interoperável ao término? | C | | Plano de saída / formato de exportação | Dados exportáveis em formato aberto e reutilizável |
| F.7 | Possui plano de comunicação de crise para acionar o GLOP durante indisponibilidade relevante? | M | | Procedimento de comunicação | Comunicação de crise definida |

---

# BLOCO G — REFERÊNCIAS, REPUTAÇÃO E SUSTENTABILIDADE

| # | Pergunta | Criticidade | Resposta | Evidência exigida | Critério de aceite |
|---|---|---|---|---|---|
| G.1 | Forneça ao menos 2 (duas) referências de clientes de porte/segmento similar. | M | | Contatos / cartas de referência | Referências verificáveis e positivas |
| G.2 | Apresente indicadores públicos de disponibilidade (status page) e histórico de incidentes divulgados. | M | | Link/status page / histórico | Transparência operacional demonstrada |
| G.3 | Possui código de conduta/ética, política anticorrupção e canal de denúncias? | A | | Documentos / canal | Governança ética formalizada |
| G.4 | Adota práticas de compliance PLD-FT e checagem de sanções internacionais? | A | | Política de compliance | Programa de integridade ativo |
| G.5 | Possui saúde financeira compatível com a continuidade do serviço (sem risco iminente de descontinuidade)? | A | | Demonstrações / declaração | Estabilidade financeira razoável |
| G.6 | Adota práticas de ESG/sustentabilidade relevantes ao serviço (quando aplicável)? | M | | Relatório / política | Práticas informadas quando pertinentes |

---

# BLOCO H — DECLARAÇÕES FINAIS E COMPROMISSOS

1. O Fornecedor declara que as informações prestadas são **verdadeiras, completas e atuais**, ciente de que a falsidade ou omissão material constitui infração contratual grave, autorizando a rescisão por justa causa e a responsabilização por perdas e danos.
2. O Fornecedor compromete-se a **comunicar ao GLOP**, em até 30 (trinta) dias, qualquer alteração material que afete as respostas deste Questionário (mudança de datacenter, sub-operador, certificação, incidente relevante, alteração de controle societário).
3. O Fornecedor autoriza a **reavaliação periódica** e o **direito de auditoria** previstos no Contrato e no DPA.
4. As obrigações de **confidencialidade** e **proteção de dados** sobrevivem ao término da relação pelos prazos legais e contratuais aplicáveis.

**Local e data:** Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, 16 de julho de 2026.

Fornecedor (respondente): _______________________________ [PARTE] — [RAZÃO SOCIAL DO FORNECEDOR]

Encarregado (DPO) do Fornecedor: _______________________________

Recebido e analisado pelo GLOP: _______________________________ a ser designado pela administração — DPO [NOME FANTASIA: GLOP]

---

# Engenharia Jurídica & Governança

## (a) Fundamentação das cláusulas

1. **Papel de Operador e instruções documentadas (Bloco C.1):** art. 5º, VII, art. 6º e art. 39 da LGPD (Lei nº 13.709/2018) — o operador trata dados em nome do controlador e conforme suas instruções. Reflete a cadeia real do GLOP (Controlador do produtor/lojista → GLOP Operador → sub-operadores Supabase/Netlify/VHSYS/Correios/gateways).
2. **Registro de operações e ROPA (C.1.4):** art. 37 da LGPD; art. 30 do GDPR.
3. **Direitos dos titulares (C.2.1):** art. 18 da LGPD; arts. 15–22 do GDPR.
4. **Segurança e boas práticas (Bloco B):** arts. 46 a 49 da LGPD; controles da ISO/IEC 27001 (SGSI), ISO/IEC 27701 (PIMS), SOC 2 (Trust Services Criteria), NIST CSF/800-53, CIS Controls e OWASP (Top 10/ASVS) para desenvolvimento seguro.
5. **Transferência internacional (Bloco C.3):** arts. 33 a 36 da LGPD; Capítulo V do GDPR (decisão de adequação, SCC, BCR). Pertinente aos provedores de nuvem e gateways com processamento fora do Brasil.
6. **Comunicação de incidentes (Bloco E):** art. 48 da LGPD (comunicação à ANPD e ao titular em prazo razoável) e Regulamento de Comunicação de Incidente da ANPD; arts. 33 e 34 do GDPR (72 horas).
7. **Subcontratação/flow-down (Bloco D):** art. 39 da LGPD e art. 28, §§ 2º a 4º do GDPR — o operador só subcontrata com autorização e impõe obrigações equivalentes.
8. **Continuidade (Bloco F):** ISO 22301 (SGCN) e ISO 31000 (gestão de riscos); dever de segurança e disponibilidade decorrente do art. 46 da LGPD.
9. **Direito de auditoria e reavaliação (B.6.6, H.3):** dever de accountability/prestação de contas (art. 6º, X, LGPD) e prática contratual de vendor risk management.
10. **Regularidade e integridade (Blocos A e G):** Lei nº 12.846/2013 (Anticorrupção), normas de PLD-FT (Lei nº 9.613/1998) e boa-fé objetiva (arts. 421 e 422 do Código Civil). Para dados de cartão na cadeia de pagamento, PCI-DSS.
11. **Responsabilidade solidária (D.4):** art. 42, §1º da LGPD — controlador e operador respondem solidariamente pelos danos, o que justifica exigir a mesma cadeia de garantias dos sub-operadores.

## (b) Riscos mitigados

1. **Vazamento/uso indevido de PII do comprador** (nome, CPF/CNPJ, e-mail, telefone, endereço) — mitigado por B.2, B.3, C.2.3 e E.
2. **Exposição de dados financeiros** (PIX/bancários de repasse, split AppMax, dados de cartão em gateways) — mitigado por B.3, D.6 e exigência de PCI-DSS.
3. **Vazamento de credenciais de API** (chaves write-only do GLOP) — mitigado por B.2.4.
4. **Transferência internacional sem base legal** — mitigado por C.3.
5. **Cadeia de sub-operadores opaca** (nuvem, gateways, WhatsApp/e-mail) — mitigado por Bloco D e flow-down.
6. **Incidente sem notificação tempestiva**, expondo o GLOP a sanção da ANPD — mitigado por Bloco E.
7. **Indisponibilidade e perda de dados fiscais/operacionais** — mitigado por Bloco F (RTO/RPO, backup, exit plan).
8. **Exposição indevida no portal público de rastreio** — mitigado por B.3.5 (status neutro, sem PII).
9. **Responsabilização solidária do GLOP** por ato de terceiro — mitigado por D.3, D.4 e direito de auditoria.
10. **Falsidade nas respostas / fornecedor inidôneo** — mitigado pelo Bloco A e pelas declarações do Bloco H.

## (c) Checklist de aplicação do Questionário

- [ ] Fornecedor classificado quanto ao escopo (toca ou não dados/credenciais/documentos fiscais do GLOP).
- [ ] Criticidade do serviço definida (C/A/M) e prazo de resposta comunicado.
- [ ] Questionário respondido integralmente, com evidências anexadas.
- [ ] Itens Críticos verificados um a um (nenhum "Não" pendente).
- [ ] Índice de Conformidade (IC) calculado e enquadrado na régua de decisão.
- [ ] DPA e cláusulas de auditoria/notificação/subcontratação assinados.
- [ ] Base legal de transferência internacional validada, quando aplicável.
- [ ] Lista de sub-operadores registrada e aprovada.
- [ ] Plano de ação definido para itens "Parcial"/"Alto" com prazos.
- [ ] Decisão registrada (Aprovado / Aprovado com ressalvas / Reprovado) e comunicada.
- [ ] Data da próxima reavaliação agendada.

## (d) Matriz RACI

| Atividade | DPO GLOP | Jurídico/Compliance | Segurança da Informação | Área Contratante (negócio) | Fornecedor |
|---|---|---|---|---|---|
| Definir escopo e criticidade do fornecedor | A | C | C | R | I |
| Enviar e coletar o Questionário | R | C | I | C | R |
| Analisar segurança da informação (Bloco B) | C | I | R/A | I | C |
| Analisar LGPD e transferência internacional (Bloco C) | R/A | C | C | I | C |
| Avaliar subcontratação e cadeia (Bloco D) | A | R | C | I | R |
| Validar incidentes e continuidade (Blocos E e F) | C | C | R/A | I | C |
| Calcular IC e emitir decisão | A | R | C | C | I |
| Assinar DPA e cláusulas contratuais | C | R/A | I | C | R |
| Registrar e arquivar evidências | R | C | C | I | I |
| Reavaliação periódica | A | C | R | C | R |

Legenda: **R** = Responsável pela execução · **A** = Aprovador/Accountable · **C** = Consultado · **I** = Informado.

## (e) Plano de revisão

1. **Reavaliação por criticidade:** fornecedores Críticos a cada 12 meses; Altos a cada 18 meses; Médios a cada 24 meses.
2. **Reavaliação por gatilho (event-driven):** incidente de segurança, mudança de sub-operador/datacenter, alteração de controle societário, perda/vencimento de certificação, mudança regulatória (ANPD/GDPR) ou reclamação de titular.
3. **Revisão do próprio Questionário:** revisão anual do instrumento pelo DPO e Jurídico, para incorporar novas normas, orientações da ANPD e evolução dos fluxos do GLOP.
4. **Responsáveis:** DPO (coordenação), Segurança da Informação (avaliação técnica), Jurídico/Compliance (avaliação legal e contratual).
5. **Registro:** todas as decisões, evidências e planos de ação arquivados por prazo mínimo de 5 (cinco) anos após o término da relação, respeitados prazos legais superiores.

## (f) Controle de versão

| Versão | Data | Autor/Responsável | Descrição da alteração |
|---|---|---|---|
| 1.0 | 16 de julho de 2026 | a ser designado pela administração (DPO) | Emissão inicial do Questionário de Due Diligence de fornecedores/sub-operadores do GLOP |
| 1.1 | 16 de julho de 2026 | [PARTE] | [Descrição da revisão] |
| 2.0 | 16 de julho de 2026 | [PARTE] | [Descrição da revisão maior] |

---

> Documento de uso interno e confidencial de [NOME FANTASIA: GLOP] / LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA. Distribuição restrita ao processo de homologação de fornecedores. Minuta sujeita à validação jurídica antes do uso em produção.
