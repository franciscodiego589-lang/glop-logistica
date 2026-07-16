> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

# POLÍTICA DE BACKUP E RESTAURAÇÃO DE DADOS

**[NOME FANTASIA: GLOP] — Global Logistics Platform**

**Documento:** POL-BKP-001 — Política de Backup, Retenção e Restauração
**Classificação da informação:** Interno / Confidencial
**Versão:** 1.0
**Data de emissão:** 16 de julho de 2026
**Aprovação:** a ser designado pela administração / Diretoria de Tecnologia
**Controlador / Operador:** LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, inscrita no CNPJ sob nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, doravante denominada **[NOME FANTASIA: GLOP]** ou "Plataforma".

---

## 1. Objetivo

1.1. Esta Política estabelece as diretrizes, procedimentos, responsabilidades e controles técnicos e organizacionais aplicáveis à **realização, armazenamento, criptografia, retenção, teste e restauração de cópias de segurança (backups)** de todos os dados, sistemas e configurações que suportam a operação da plataforma **[NOME FANTASIA: GLOP]** — SaaS de logística e ERP para dropshipping e infoprodutos.

1.2. A Política visa a assegurar a **continuidade operacional**, a **integridade**, a **disponibilidade** e a **confidencialidade** das informações, incluindo os dados pessoais de compradores, produtores, lojistas, coprodutores, afiliados, colaboradores e demais titulares tratados pela Plataforma, em conformidade com a **Lei nº 13.709/2018 (LGPD)**, o **Marco Civil da Internet (Lei nº 12.965/2014)** e as normas técnicas **ISO/IEC 27001, ISO/IEC 27701, ISO 22301 e ISO 31000**.

1.3. Constitui objetivo específico garantir que a Plataforma seja capaz de **recuperar dados e restabelecer serviços** dentro de metas mensuráveis de tempo (**RTO**) e de perda máxima tolerável de dados (**RPO**), preservando as **trilhas de auditoria** e o isolamento **multi-tenant** (Tenant → Company → Branch → Membership) mesmo em cenários de restauração.

---

## 2. Escopo

2.1. Esta Política aplica-se a **todos os ativos de informação** sob gestão da **[NOME FANTASIA: GLOP]**, próprios ou operados por sub-operadores contratados, incluindo, sem limitação:

- **Banco de dados transacional**: instância **Supabase (PostgreSQL)**, contemplando todos os schemas (`public`, `app`, `auth`, `storage`) e as tabelas de negócio com colunas-padrão de auditoria (`created_at`, `updated_at`, `deleted_at`, `deleted_by`, `version`, `metadata`).
- **Identidade e autenticação**: base **Supabase Auth** (`auth.users`), tokens, hashes de senha e metadados de sessão.
- **Objetos e arquivos**: **Supabase Storage** (buckets por domínio), incluindo documentos fiscais, comprovantes, etiquetas de pré-postagem (PPN/Correios) e anexos de importação inteligente de pedidos.
- **Configuração e segredos**: variáveis de ambiente da hospedagem **SSR Netlify**, credenciais de API write-only dos gateways (**Monetizze, AppMax, Hotmart, Kiwify**), integrações de e-commerce (**Shopify, WooCommerce, Nuvemshop, Mercado Livre**), emissor de **NF-e (VHSYS)** e transporte (**Correios — PPN/SRO**).
- **Código, migrations e infraestrutura como código**: repositório de código-fonte, arquivos de **migrations Supabase** (fonte da verdade do schema), políticas de **RLS/RBAC**, funções `app.*` e Edge Functions.
- **Registros de auditoria e logs**: trilhas geradas por triggers (`tg_write_audit`), logs de acesso, logs de aplicação e evidências de restauração.

2.2. **Fora de escopo direto** (regidos por instrumentos próprios, com remissão nesta Política): backups mantidos autonomamente pelos **sub-operadores** em suas camadas de infraestrutura (por exemplo, snapshots gerenciados pelo Supabase/Netlify), os quais **complementam**, mas **não substituem**, os controles aqui definidos; e dados pessoais tratados pela Plataforma na condição de **OPERADOR** em nome de produtores/lojistas **CONTROLADORES**, cuja retenção e eliminação seguem, adicionalmente, as instruções documentadas do Controlador e o respectivo **DPA (Acordo de Tratamento de Dados)**.

2.3. Esta Política vincula **todos os colaboradores, prestadores, administradores e sub-operadores** com acesso aos ativos descritos, independentemente de vínculo empregatício.

---

## 3. Definições

- **Backup (cópia de segurança):** réplica de dados/configurações armazenada de forma segregada, apta a restaurar o estado da informação em um ponto no tempo.
- **Backup Full (completo):** cópia integral de todo o conjunto de dados no momento de execução.
- **Backup Incremental:** cópia apenas das alterações ocorridas desde o último backup (full ou incremental).
- **Backup Diferencial:** cópia de todas as alterações ocorridas desde o último backup full.
- **PITR (Point-in-Time Recovery):** recuperação a um instante arbitrário via reprodução de WAL (Write-Ahead Logging) do PostgreSQL.
- **Snapshot:** imagem consistente do estado do banco/volume em um instante.
- **RPO (Recovery Point Objective):** volume máximo de dados (medido em tempo) que a organização tolera perder em um incidente.
- **RTO (Recovery Time Objective):** tempo máximo aceitável para restabelecer um serviço após interrupção.
- **Retenção:** período durante o qual uma cópia é mantida antes de sua eliminação segura.
- **Restauração:** processo de recompor dados/serviços a partir de um backup.
- **AES-256:** algoritmo de cifragem simétrica de bloco com chave de 256 bits.
- **Controlador / Operador:** conforme art. 5º, VI e VII, da LGPD.

---

## 4. Princípios Norteadores

4.1. **Confidencialidade, Integridade e Disponibilidade (CID):** todo backup deve preservar as três propriedades, sendo cifrado em repouso e em trânsito.

4.2. **Regra 3-2-1:** manter, no mínimo, **3 cópias** dos dados, em **2 tipos de mídia/serviço distintos**, com **1 cópia geograficamente separada (off-site)** da produção.

4.3. **Minimização e finalidade (art. 6º, I e III, LGPD):** backups contêm apenas os dados necessários; não se criam cópias adicionais para finalidades não previstas.

4.4. **Segregação multi-tenant:** a restauração jamais pode misturar dados entre `tenant_id`/`company_id` distintos; o isolamento por **RLS** deve ser reestabelecido integralmente após qualquer restauração.

4.5. **Rastreabilidade:** toda operação de backup e restauração gera **evidência** registrada e auditável.

4.6. **Menor privilégio:** o acesso às cópias e às chaves de cifragem é restrito a funções estritamente necessárias.

4.7. **Testabilidade:** um backup só é considerado válido após **teste de restauração** bem-sucedido.

---

## 5. Diretrizes de Backup

### 5.1. Tipos de backup adotados

| Tipo | Descrição | Aplicação na [NOME FANTASIA: GLOP] |
|---|---|---|
| **Full** | Cópia integral do banco e dos buckets | Diário, do banco Supabase (PostgreSQL) e do Supabase Storage |
| **Incremental** | Somente alterações desde a última cópia | Contínuo, via arquivamento de WAL / PITR do PostgreSQL |
| **Diferencial** | Alterações desde o último full | Semanal, como camada intermediária de recuperação |
| **Snapshot** | Imagem consistente do estado | Antes de cada deploy, migration ou alteração de schema |
| **Cópia lógica (dump)** | `pg_dump` lógico versionado | Semanal, para portabilidade e retenção de longo prazo off-site |
| **Migrations (IaC)** | Versionamento do schema | Contínuo, no repositório de código (fonte da verdade) |

### 5.2. Frequência

| Ativo | Full | Incremental / Contínuo | Snapshot pontual |
|---|---|---|---|
| Banco Supabase (PostgreSQL) | Diário (janela 00h–04h BRT) | WAL contínuo (PITR) | Pré-deploy / pré-migration |
| Supabase Auth (`auth.users`) | Diário (junto ao banco) | WAL contínuo | Pré-migration de identidade |
| Supabase Storage (buckets) | Diário | Sincronização por objeto ao gravar | Pré-alteração de bucket |
| Segredos / variáveis (Netlify) | A cada alteração | — | A cada rotação de credencial |
| Código / migrations | A cada commit | Push contínuo | Tag de release |
| Logs / trilha de auditoria | Diário | Streaming contínuo | — |

### 5.3. Consistência

5.3.1. Backups do banco devem ser **transacionalmente consistentes** (snapshot consistente ou dump com nível de isolamento adequado), garantindo integridade referencial das FKs e coerência das colunas de auditoria e de `version`.

5.3.2. Backups de Storage e banco devem ser **correlacionáveis por timestamp**, de modo que a restauração conjunta preserve a integridade entre registros (por exemplo, um pedido e sua etiqueta PPN, ou uma NF-e e seu documento fiscal armazenado).

### 5.4. Criptografia (AES-256)

5.4.1. **Em repouso:** todas as cópias de segurança são cifradas com **AES-256** (padrão simétrico de 256 bits). Os volumes gerenciados pelo Supabase utilizam cifragem em repouso pelo provedor; as cópias lógicas exportadas (dumps) e as cópias off-site são adicionalmente cifradas com **AES-256** antes do transporte e do armazenamento.

5.4.2. **Em trânsito:** toda transferência de backup ocorre sobre **TLS 1.2+**.

5.4.3. **Gestão de chaves:** as chaves de cifragem são armazenadas em cofre de segredos apartado dos dados, com **rotação periódica**, controle de acesso por **menor privilégio** e segregação de funções entre quem opera o backup e quem custodia a chave. É **vedado** armazenar chaves em texto claro no repositório de código, em variáveis de log ou junto às próprias cópias.

5.4.4. **Segredos de integração:** credenciais de API dos gateways e integrações são mantidas **write-only** na operação; nas cópias, permanecem cifradas e são tratadas como dado crítico de segurança.

### 5.5. Armazenamento

5.5.1. **Camada primária:** infraestrutura gerenciada do **Supabase** (banco PostgreSQL e Storage), com backups automáticos e PITR conforme plano contratado.

5.5.2. **Camada off-site (3-2-1):** cópia lógica cifrada replicada para armazenamento **geograficamente distinto** da produção, sob controle da **[NOME FANTASIA: GLOP]**, com acesso restrito e logado.

5.5.3. **Imutabilidade:** as cópias off-site devem, quando tecnicamente viável, ser mantidas em modo **WORM/objeto imutável (retenção travada)** para resistir a ransomware e exclusão acidental ou maliciosa.

5.5.4. **Localização e transferência internacional:** eventual armazenamento de cópias fora do território nacional observa os arts. 33 a 36 da LGPD (transferência internacional de dados), com salvaguardas contratuais adequadas junto aos sub-operadores **Supabase** e **Netlify**, e registro no inventário de tratamento.

---

## 6. Retenção e Eliminação

### 6.1. Tabela de retenção

| Camada de backup | Retenção mínima | Retenção máxima | Justificativa |
|---|---|---|---|
| WAL / PITR | 7 dias | 14 dias | Recuperação a instante recente (RPO baixo) |
| Full diário | 30 dias | 35 dias | Rollback operacional de curto prazo |
| Diferencial / Full semanal | 8 semanas | 12 semanas | Recuperação de médio prazo |
| Full mensal (arquivo) | 12 meses | 13 meses | Sazonalidade e auditoria anual |
| Documentos fiscais / NF-e (VHSYS) | 5 anos | Prazo legal aplicável | Legislação fiscal/tributária |
| Trilha de auditoria (logs) | 6 meses | Conforme obrigação legal | Marco Civil / segurança / prova |
| Cópia legal específica (litígio) | Enquanto durar a necessidade | Até trânsito em julgado | Preservação de prova (legal hold) |

6.2. **Guarda de registros de conexão (Marco Civil):** logs de aplicação e registros de acesso observam os prazos e as garantias do art. 13 e seguintes da Lei nº 12.965/2014, quando aplicável.

6.3. **Eliminação segura:** ao término do período de retenção, as cópias são **eliminadas de forma segura e irreversível** (destruição de chave de cifragem — *crypto-shredding* — e/ou remoção lógica com sobrescrita, conforme a mídia). A eliminação é **registrada** com data, responsável e conjunto eliminado.

6.4. **Retenção sob a ótica LGPD:** os prazos acima não afastam o direito de eliminação do titular (art. 18, VI) nem o dever de eliminação ao fim do tratamento (art. 16). Backups são conservados pelo prazo estritamente necessário; havendo pedido de eliminação, a **[NOME FANTASIA: GLOP]** aplica bloqueio lógico imediato na produção e assegura que o dado não retorne em restaurações futuras, promovendo a eliminação definitiva no ciclo de expurgo das cópias, ressalvadas as hipóteses do art. 16 (cumprimento de obrigação legal/regulatória, estudo, exercício de direitos, entre outras).

6.5. **Papel de OPERADOR:** quando a **[NOME FANTASIA: GLOP]** atua como Operador (dados de compradores tratados em nome de produtores/lojistas Controladores), a retenção e a eliminação de backups seguem, adicionalmente, as instruções do Controlador e o **DPA** correspondente.

---

## 7. Restauração de Dados

### 7.1. Modalidades de restauração

- **Restauração pontual (PITR):** recuperação do banco a um instante específico dentro da janela de WAL, para reverter incidentes de corrupção lógica ou exclusão indevida.
- **Restauração completa (full):** recomposição integral do ambiente a partir da última cópia full válida.
- **Restauração seletiva:** recomposição de subconjunto (tabela, `tenant_id`/`company_id`, bucket ou objeto específico), preservando o isolamento multi-tenant.
- **Restauração para ambiente isolado (sandbox):** recuperação em ambiente segregado para teste, perícia ou extração pontual, sem impacto na produção.

### 7.2. Autorização

7.2.1. Toda restauração em produção exige **autorização formal** do responsável de plantão e do **a ser designado pela administração** (ou substituto designado), com registro de motivo, escopo e janela.

7.2.2. Restaurações que envolvam dados pessoais tratados como **OPERADOR** requerem observância das instruções do Controlador; restaurações que possam reintroduzir dados objeto de pedido de eliminação exigem validação prévia de conformidade (item 6.4).

### 7.3. Procedimento de restauração (fluxo padrão)

1. **Abertura de ocorrência** e classificação do incidente (severidade, escopo, RTO/RPO-alvo).
2. **Seleção da cópia** válida mais recente compatível com o RPO desejado.
3. **Restauração em ambiente isolado** para validação de integridade antes do corte de produção, quando o tempo permitir.
4. **Verificação de integridade:** checagem de FKs, contagem de registros, `version`, colunas de auditoria, políticas de **RLS/RBAC** e correlação banco ↔ Storage.
5. **Reaplicação de segredos** e reconexão das integrações (gateways, VHSYS, Correios) com validação de credenciais write-only.
6. **Corte para produção** (cutover) e **smoke tests** dos fluxos críticos: ingestão de pedidos, emissão de NF-e, pré-postagem/rastreio, split/repasses e portal público de rastreio.
7. **Registro de evidência** (item 10) e **comunicação** aos stakeholders; se houver incidente com dados pessoais, acionar o **Plano de Resposta a Incidentes** e avaliar comunicação à **ANPD** e aos titulares (art. 48, LGPD).

### 7.4. Integridade pós-restauração

7.4.1. Após qualquer restauração, é **obrigatória** a revalidação de que **RLS está habilitada em todas as tabelas de `public`** e de que as funções `app.*` (`is_superadmin`, `user_company_ids`, `can_access_company`, `has_permission`) operam corretamente, sob pena de vazamento cross-tenant.

7.4.2. O portal público de rastreio deve permanecer restrito a **status neutro**, sem exposição de PII, também após restaurações.

---

## 8. RTO e RPO

### 8.1. Metas por serviço

| Serviço / dado | RPO (perda máx.) | RTO (tempo máx. de recuperação) | Criticidade |
|---|---|---|---|
| Banco transacional (pedidos, PII do comprador) | ≤ 15 min (via PITR) | ≤ 4 h | Crítica |
| Supabase Auth (identidade) | ≤ 15 min | ≤ 4 h | Crítica |
| Supabase Storage (documentos, etiquetas, NF-e) | ≤ 1 h | ≤ 8 h | Alta |
| Split / repasses / dados bancários-PIX | ≤ 15 min | ≤ 4 h | Crítica |
| Integrações (gateways, VHSYS, Correios) | ≤ 1 h | ≤ 6 h | Alta |
| Trilha de auditoria / logs | ≤ 1 h | ≤ 12 h | Média |
| Portal público de rastreio | ≤ 1 h | ≤ 8 h | Média |

8.2. As metas de **RTO/RPO** são **revisadas ao menos anualmente** e após qualquer mudança arquitetural relevante ou incidente com lição aprendida.

8.3. As metas devem ser **compatibilizadas** com os compromissos de disponibilidade assumidos com clientes (SLA) e com os limites técnicos dos sub-operadores (Supabase/Netlify); divergências são registradas como risco aceito e comunicadas.

---

## 9. Testes Periódicos de Restauração

9.1. Backup **não testado não é backup**. A **[NOME FANTASIA: GLOP]** executa testes de restauração conforme o cronograma:

| Teste | Frequência | Objetivo | Métrica aferida |
|---|---|---|---|
| Restauração pontual (PITR) em sandbox | Mensal | Validar recuperação a instante recente | RPO efetivo |
| Restauração full em ambiente isolado | Trimestral | Validar cópia full e integridade | RTO efetivo, integridade |
| Restauração seletiva por tenant | Trimestral | Validar isolamento multi-tenant | Ausência de vazamento cross-tenant |
| Simulação de desastre (DR drill) | Semestral | Exercitar o plano de continuidade (ISO 22301) | RTO/RPO agregados |
| Restauração de Storage/objetos | Trimestral | Validar recuperação de arquivos e NF-e | Integridade de objetos |
| Verificação de restauração de segredos | Semestral | Reconstituir integrações com segurança | Tempo de reconexão |

9.2. Cada teste produz **relatório de evidência** contendo: data/hora, cópia utilizada, ambiente, RTO/RPO medidos, checagens de integridade, não conformidades detectadas e plano de ação.

9.3. **Não conformidade** identificada em teste é tratada como risco e acompanhada até a remediação, com reteste.

9.4. Os resultados alimentam a **melhoria contínua** (ISO 31000) e a revisão desta Política.

---

## 10. Evidências e Registros

10.1. Constituem **evidências obrigatórias**, retidas por, no mínimo, **12 meses**:

- **Logs de execução de backup** (sucesso/falha, duração, volume, tipo).
- **Manifestos de cópia** (identificador, checksum/hash de integridade, timestamp, escopo, `tenant`/`company` quando seletivo).
- **Relatórios de teste de restauração** (item 9.2).
- **Registros de rotação e custódia de chaves** de cifragem.
- **Registros de eliminação segura** de cópias vencidas (item 6.3).
- **Autorizações de restauração** em produção (item 7.2).
- **Trilha de auditoria** gerada pelos triggers (`tg_write_audit`) relacionada às operações.

10.2. As evidências são **imutáveis** (à prova de adulteração), com controle de acesso e podem ser exigidas em auditorias internas, certificações (ISO 27001/27701), fiscalizações da **ANPD** ou processos judiciais.

10.3. **Verificação de integridade:** cada cópia possui **hash/checksum** registrado no momento da criação e reverificado antes de restaurações, para detectar corrupção silenciosa.

---

## 11. Papéis e Responsabilidades

11.1. **Encarregado pelo Tratamento de Dados (DPO) — a ser designado pela administração, contato lemoncapsencapsulados@gmail.com:** zela pela conformidade da retenção/eliminação de cópias com a LGPD; atua no ciclo de resposta a incidentes; interlocução com a ANPD e titulares.

11.2. **Gestor de Tecnologia / Infraestrutura:** proprietário desta Política; garante execução, monitoramento e evolução dos controles; aprova restaurações em produção.

11.3. **Time de Operações / DevOps:** executa backups, monitora janelas e falhas, realiza testes de restauração, mantém IaC/migrations e custodia segredos sob menor privilégio.

11.4. **Segurança da Informação:** define e audita a cifragem AES-256, a gestão de chaves, a imutabilidade e a segregação de funções; conduz DR drills.

11.5. **Sub-operadores (Supabase, Netlify):** mantêm os controles de backup/cifragem contratados em sua camada, sob os respectivos termos e DPAs; não substituem os controles próprios da Plataforma.

11.6. **Colaboradores e prestadores:** cumprem esta Política e reportam falhas ou incidentes de backup/restauração pelos canais oficiais.

11.7. Ver **Matriz RACI** na seção de Engenharia Jurídica & Governança.

---

## 12. Segurança, Segregação e Continuidade

12.1. **Segregação de funções:** quem executa o backup não custodia, isoladamente, a chave de cifragem; restaurações em produção exigem dupla autorização (item 7.2).

12.2. **Anti-ransomware:** cópias off-site imutáveis (WORM), MFA obrigatório para acesso ao console de backup e alertas para operações anômalas de exclusão em massa.

12.3. **Monitoramento:** falhas de backup geram alerta imediato (e-mail/WhatsApp/canal operacional) e ocorrência; a ausência de backup válido por período superior ao RPO é tratada como **incidente**.

12.4. **Integração com o Plano de Continuidade de Negócios (ISO 22301):** esta Política é insumo do BCP/DRP; os DR drills validam a capacidade de recuperação end-to-end.

---

## 13. Sanções

13.1. O descumprimento desta Política sujeita colaboradores e prestadores a medidas disciplinares proporcionais à gravidade, nos termos da legislação trabalhista e contratual aplicável, incluindo advertência, suspensão, rescisão por justa causa e responsabilização civil e/ou criminal.

13.2. O descumprimento por **sub-operador** enseja as penalidades previstas no contrato e no DPA, incluindo rescisão e indenização por perdas e danos.

13.3. Falhas que resultem em incidente com dados pessoais são apuradas e podem gerar responsabilização perante a **ANPD** (arts. 52 a 54, LGPD), sem prejuízo do direito de regresso.

---

## 14. Vigência e Revisão

14.1. Esta Política entra em vigor na data de sua aprovação e vigora por prazo indeterminado, até revisão ou revogação formal.

14.2. É **revisada, no mínimo, anualmente**, e sempre que houver: alteração legislativa/regulatória; mudança arquitetural relevante; troca de sub-operador; incidente de segurança; ou não conformidade recorrente em testes.

14.3. Alterações são registradas no **Controle de Versão** e comunicadas às partes afetadas.

---

## Engenharia Jurídica & Governança

### (a) Fundamentação das cláusulas

| Cláusula / Tema | Fundamento legal / normativo |
|---|---|
| Segurança, disponibilidade e integridade dos dados | Art. 6º, VII e VIII (segurança e prevenção) e art. 46 da **LGPD** (medidas técnicas e administrativas) |
| Retenção e eliminação de dados | Arts. 15 e 16 da **LGPD** (término do tratamento e eliminação) |
| Direito de eliminação do titular | Art. 18, VI, da **LGPD** |
| Comunicação de incidentes | Art. 48 da **LGPD** (comunicação à ANPD e ao titular) |
| Responsabilidade Controlador/Operador | Arts. 5º (VI, VII), 39 e 42 da **LGPD** |
| Transferência internacional (cópias off-site) | Arts. 33 a 36 da **LGPD** |
| Guarda de registros/logs | Arts. 13, 15 e 16 do **Marco Civil da Internet (Lei nº 12.965/2014)** |
| Retenção de documentos fiscais | Legislação tributária aplicável (guarda quinquenal) |
| Sistema de gestão de segurança e continuidade | **ISO/IEC 27001** (SGSI, controles A.8.13 backup, A.5.29 continuidade), **ISO/IEC 27701** (privacidade), **ISO 22301** (continuidade de negócios), **ISO 31000** (gestão de riscos) |
| Boas práticas de cifragem e chaves | **NIST SP 800-57** (gestão de chaves), **NIST SP 800-34** (contingência), **OWASP** (proteção de dados sensíveis) |

### (b) Riscos mitigados

- **Perda de dados** por falha, corrupção lógica, exclusão acidental ou maliciosa (mitigado por full+incremental+PITR e regra 3-2-1).
- **Ransomware / adulteração de cópias** (mitigado por imutabilidade WORM, MFA e segregação de chaves).
- **Vazamento cross-tenant em restaurações** (mitigado por revalidação obrigatória de RLS/RBAC e restauração seletiva por tenant).
- **Exposição de PII e de segredos** em cópias (mitigado por AES-256, TLS 1.2+ e write-only de credenciais).
- **Indisponibilidade prolongada** (mitigado por metas RTO/RPO e DR drills).
- **Não conformidade LGPD** por retenção indevida ou impossibilidade de eliminar (mitigado pela política de retenção e pelo fluxo do item 6.4).
- **Backup inválido/não recuperável** (mitigado por testes periódicos e verificação de checksum).
- **Falha de sub-operador** (mitigado por controles próprios que não dependem exclusivamente de Supabase/Netlify).

### (c) Checklist

- [ ] Backups full diários do banco Supabase configurados e monitorados.
- [ ] PITR/WAL ativo com janela compatível com RPO ≤ 15 min.
- [ ] Backups do Supabase Storage correlacionados por timestamp com o banco.
- [ ] Cifragem AES-256 em repouso e TLS 1.2+ em trânsito, validadas.
- [ ] Chaves custodiadas em cofre apartado, com rotação e segregação de funções.
- [ ] Cópia off-site imutável (WORM) em localidade geograficamente distinta.
- [ ] Tabela de retenção aplicada e expurgo seguro registrado.
- [ ] Teste de restauração PITR (mensal) executado e evidenciado.
- [ ] Teste full e por tenant (trimestral) executado e evidenciado.
- [ ] DR drill semestral executado; RTO/RPO medidos e comparados às metas.
- [ ] RLS/RBAC revalidados após toda restauração.
- [ ] Segredos de integração reconstituídos e testados após restauração.
- [ ] Evidências (logs, manifestos, relatórios, autorizações) retidas ≥ 12 meses.
- [ ] Alinhamento com DPA para dados tratados como Operador.
- [ ] Política revisada no último ciclo (≤ 12 meses).

### (d) Matriz RACI

Legenda: **R** = Responsável executa · **A** = Aprova/Presta contas · **C** = Consultado · **I** = Informado.

| Atividade | DevOps/Operações | Gestor de TI | Segurança da Informação | DPO / Encarregado | Sub-operadores |
|---|---|---|---|---|---|
| Executar backups (full/incremental) | R | A | C | I | R (camada infra) |
| Definir/manter cifragem AES-256 e chaves | R | A | R | C | C |
| Definir retenção e expurgo | C | A | C | R | I |
| Autorizar restauração em produção | R | A | C | C | I |
| Executar restauração | R | A | C | I | C |
| Testes periódicos de restauração / DR drill | R | A | R | C | I |
| Revalidar RLS/RBAC pós-restauração | R | A | R | C | I |
| Tratar incidente com dados pessoais | C | C | R | A | I |
| Manter evidências e auditoria | R | A | C | C | I |
| Revisar esta Política | C | A | C | R | I |

### (e) Plano de revisão

- **Revisão ordinária:** anual, conduzida pelo Gestor de TI com o DPO, aprovada pela Diretoria.
- **Revisão extraordinária:** disparada por incidente, mudança legislativa, troca de sub-operador, alteração de arquitetura ou não conformidade recorrente.
- **Fontes de melhoria:** relatórios de teste/DR drill, auditorias ISO, recomendações da ANPD, indicadores de RTO/RPO efetivos.
- **Registro:** toda revisão é lançada no Controle de Versão, com aprovação nominal e data.

### (f) Controle de versão

| Versão | Data | Autor / Responsável | Descrição da alteração | Aprovação |
|---|---|---|---|---|
| 1.0 | 16 de julho de 2026 | a ser designado pela administração | Emissão inicial da Política de Backup e Restauração | [PARTE] |
| | | | | |

---

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.
