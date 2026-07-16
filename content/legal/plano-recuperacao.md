# Plano de Recuperação de Desastres (DRP) — GLOP (Global Logistics Platform)

> ⚠️ MINUTA — documento gerado por IA, pendente de revisão e validação por advogado(a) habilitado(a) antes de uso em produção. A legislação muda; adapte à operação real e revise periodicamente.

---

## 1. Identificação, Qualificação e Titularidade do Plano

**1.1. Titular do Plano (Operadora da Plataforma / Controladora quanto aos dados próprios).**
Este Plano de Recuperação de Desastres ("DRP" ou "Plano") é instituído por LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA, sociedade empresária inscrita no CNPJ sob o nº 55.836.075/0001-07, com sede em Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190, mantenedora e operadora da plataforma [NOME FANTASIA: GLOP] — Global Logistics Platform, doravante designada "GLOP", "Plataforma" ou "Operadora".

**1.2. Natureza da Plataforma.**
A GLOP é solução SaaS (Software as a Service) de logística e ERP voltada a operações de dropshipping e infoprodutos no Brasil, construída sobre arquitetura Next.js (App Router) e Supabase (PostgreSQL), com isolamento multi-tenant por RLS (Row Level Security) na hierarquia Tenant → Company → Branch → Membership, autenticação via Supabase Auth (JWT) e armazenamento em Supabase Storage, hospedada em modo SSR na Netlify.

**1.3. Dupla natureza sob a LGPD.**
Para os fins deste Plano, reconhece-se que a Operadora atua em **dupla natureza** perante a Lei nº 13.709/2018 (LGPD):
- **a) OPERADORA** (art. 5º, VII, LGPD) — quando trata dados pessoais do COMPRADOR (nome, CPF/CNPJ, e-mail, telefone, endereço completo, produto e valor) por conta e ordem do produtor, lojista ou marketplace, que figuram como CONTROLADORES;
- **b) CONTROLADORA** (art. 5º, VI, LGPD) — quando trata dados pessoais dos próprios usuários-clientes, colaboradores, coprodutores e afiliados da Plataforma.

Ambas as naturezas impõem o dever de **segurança, prevenção e recomposição** dos dados diante de incidentes, do qual este DRP é instrumento operacional (art. 6º, VII e VIII, e arts. 46 a 49 da LGPD).

**1.4. Encarregado (DPO).**
O acionamento, a supervisão de conformidade e a comunicação a titulares e autoridades relacionadas a incidentes que envolvam dados pessoais competem ao Encarregado pelo Tratamento de Dados Pessoais (DPO): a ser designado pela administração, e-mail lemoncapsencapsulados@gmail.com.

---

## 2. Objetivo

**2.1.** Estabelecer os procedimentos técnicos, organizacionais e de governança para a **recuperação ordenada, tempestiva e auditável** dos serviços, dados e infraestrutura da GLOP diante de eventos disruptivos (desastres), assegurando a continuidade das operações logísticas críticas e a preservação da integridade, disponibilidade e confidencialidade dos dados.

**2.2.** Definir metas mensuráveis de **RTO (Recovery Time Objective)** e **RPO (Recovery Point Objective)** por serviço, a **ordem de recuperação**, os **responsáveis**, os **procedimentos de restauração de backups e failover**, e o **regime de testes periódicos**.

**2.3.** Instrumentalizar o cumprimento das obrigações de segurança da informação e continuidade de negócio decorrentes da LGPD, das normas ISO/IEC 27001, 27701, 22301 e 31000, do NIST SP 800-34 (Contingency Planning) e das boas práticas OWASP e do Marco Civil da Internet (Lei nº 12.965/2014).

---

## 3. Escopo e Abrangência

**3.1. Escopo material.** Aplica-se a todos os componentes de infraestrutura, dados e serviços que suportam a operação da GLOP, especificamente:
- **a) Banco de dados** — instância Supabase (PostgreSQL gerenciado), schemas `public` e `app`, políticas RLS, funções `security definer`, triggers de auditoria (`app.tg_write_audit`) e de atualização (`app.tg_touch_row`), enums de negócio e materialized views de BI;
- **b) Autenticação** — Supabase Auth (`auth.users`), tokens JWT, RBAC via `app.has_permission`;
- **c) Armazenamento** — Supabase Storage (buckets por domínio: documentos fiscais, comprovantes, mídias de rastreio);
- **d) Aplicação / Hospedagem** — build e deploy Next.js SSR na Netlify (funções serverless, edge, variáveis de ambiente, plugin Next.js);
- **e) Sub-operadores e integrações críticas** — VHSYS (emissão de NF-e), Correios (pré-postagem PPN e rastreio SRO), gateways de pagamento (Monetizze, AppMax, Hotmart, Kiwify), e-commerces (Shopify, WooCommerce, Nuvemshop, Mercado Livre), canais de notificação (WhatsApp, e-mail);
- **f) Fluxos de negócio dependentes** — ingestão de pedidos via API, split e repasse de comissões a coprodutores/afiliados (dados de PIX/bancários), emissão fiscal, expedição, rastreio e portal público de rastreio (sem login, expõe apenas status neutro).

**3.2. Escopo pessoal.** Vincula todos os colaboradores, prestadores, integradores e sub-operadores com acesso ou responsabilidade sobre a infraestrutura, na medida de suas atribuições.

**3.3. Exclusões.** Não integram o escopo deste Plano: (i) sistemas internos dos CONTROLADORES-clientes fora do ambiente GLOP; (ii) infraestrutura própria de sub-operadores, cuja continuidade é regida por seus respectivos SLAs e planos, aos quais este Plano se articula por dependência.

---

## 4. Definições

- **Desastre:** evento — acidental ou intencional, físico ou lógico — que compromete de forma significativa a disponibilidade, integridade ou confidencialidade de um ou mais serviços críticos, exigindo procedimentos extraordinários de recuperação.
- **RTO (Recovery Time Objective):** tempo máximo tolerável, contado do reconhecimento do incidente, para restabelecer um serviço a nível operacional aceitável.
- **RPO (Recovery Point Objective):** volume máximo tolerável de perda de dados, expresso em janela temporal, entre o último ponto de recuperação íntegro e o momento do desastre.
- **Failover:** comutação, automática ou manual, da operação para um recurso, região ou provedor redundante.
- **Failback:** retorno controlado à configuração primária após a normalização.
- **Backup PITR (Point-in-Time Recovery):** capacidade de restaurar o banco a um instante arbitrário dentro da janela de retenção, via WAL (Write-Ahead Log).
- **Runbook:** roteiro operacional passo a passo para execução de um procedimento de recuperação.
- **Incidente de dados pessoais:** evento de segurança que possa acarretar risco ou dano relevante aos titulares (art. 48, LGPD).

---

## 5. Classificação de Severidade e Cenários de Desastre

### 5.1. Níveis de severidade

| Nível | Denominação | Descrição | Exemplo GLOP |
|---|---|---|---|
| **SEV-1** | Crítico / Total | Indisponibilidade total da Plataforma ou perda/corrupção de dados primários | Perda da instância Supabase; corrupção do banco; ransomware |
| **SEV-2** | Alto / Parcial | Indisponibilidade de serviço crítico ou de sub-operador essencial | Falha de deploy Netlify; indisponibilidade de gateway de pagamento |
| **SEV-3** | Moderado | Degradação de desempenho ou falha de serviço não crítico | Latência elevada; falha temporária de notificação WhatsApp |
| **SEV-4** | Baixo | Falha isolada, contornável, sem impacto operacional relevante | Erro pontual em job de rastreio SRO |

### 5.2. Cenários mapeados

1. **Perda ou corrupção do banco Supabase (SEV-1).** Falha lógica, exclusão acidental em massa, corrupção de índice/tabela ou comprometimento por malware.
2. **Indisponibilidade regional do Supabase (SEV-1/SEV-2).** Queda de região do provedor de infraestrutura do Supabase.
3. **Falha de hospedagem Netlify (SEV-2).** Build quebrado, deploy defeituoso, indisponibilidade de funções SSR/edge ou da CDN.
4. **Comprometimento de segurança / vazamento (SEV-1).** Acesso não autorizado, exfiltração de PII de comprador, vazamento de credenciais de API ou dados de PIX/bancários de coprodutores.
5. **Indisponibilidade de sub-operador crítico (SEV-2/SEV-3).** VHSYS (NF-e), Correios (PPN/SRO) ou gateway de pagamento fora do ar.
6. **Erro humano / configuração indevida (SEV-2).** Alteração destrutiva de RLS, migration defeituosa, exclusão de bucket.
7. **Perda de credenciais / segredos (SEV-2).** Vazamento ou perda de variáveis de ambiente, chaves de service role, tokens de integração.

---

## 6. Metas de Recuperação por Serviço (RTO / RPO)

**6.1.** As metas abaixo são compromissos internos de recuperação e **não substituem** os SLAs contratuais firmados com CONTROLADORES-clientes, que prevalecem quando mais rigorosos.

| # | Serviço / Componente | Criticidade | RTO (alvo) | RPO (alvo) | Estratégia primária |
|---|---|---|---|---|---|
| 1 | Banco de dados Supabase (PostgreSQL, RLS, auth) | Crítica | 4 h | 5 min | PITR (WAL) + backup diário |
| 2 | Autenticação (Supabase Auth / JWT / RBAC) | Crítica | 4 h | 5 min | Restaura junto ao banco |
| 3 | Aplicação SSR (Netlify / Next.js) | Crítica | 1 h | 0 (código em Git) | Redeploy do último build íntegro |
| 4 | Supabase Storage (buckets: fiscal, rastreio, comprovantes) | Alta | 8 h | 24 h | Backup versionado de objetos |
| 5 | Ingestão de pedidos via API (gateways/e-commerces) | Alta | 4 h | 15 min | Reprocessamento idempotente + fila |
| 6 | Emissão de NF-e (VHSYS) | Alta | 8 h | 1 h | Reprocessamento / contingência fiscal |
| 7 | Pré-postagem e rastreio Correios (PPN/SRO) | Média | 12 h | 1 h | Fila de reenvio idempotente |
| 8 | Split e repasse de comissões (AppMax / PIX) | Alta | 8 h | 15 min | Recomposição a partir do razão + conciliação |
| 9 | Notificações (WhatsApp / e-mail) | Média | 12 h | 4 h | Reenfileiramento; degradação graciosa |
| 10 | Portal público de rastreio (sem login) | Média | 4 h | 24 h | Servido pela app; status neutro |
| 11 | BI / Materialized Views | Baixa | 24 h | 24 h | Refresh pós-recuperação do banco |
| 12 | Trilha de auditoria (triggers) | Alta | 4 h | 5 min | Restaura junto ao banco |

**6.2.** As metas são revisadas, no mínimo, anualmente e após qualquer teste que evidencie desvio material, conforme Seção 12.

---

## 7. Estratégia de Backup e Retenção

### 7.1. Banco de dados (Supabase / PostgreSQL)

**7.1.1.** Adota-se **backup diário automatizado** (snapshot lógico/físico) somado a **PITR baseado em WAL**, permitindo restauração a qualquer instante dentro da janela de retenção contratada com o Supabase.

**7.1.2. Retenção mínima:**
- **a)** Backups diários — retenção de, no mínimo, **[30] dias**;
- **b)** Janela PITR — mínimo de **[7] dias**;
- **c)** Backup mensal de longo prazo (cold) — retenção de **[12] meses**, exportado para armazenamento independente e geograficamente distinto (defesa contra falha correlata do provedor).

**7.1.3.** Os backups de longo prazo são **cifrados em repouso** (AES-256 ou equivalente) e mantidos com controle de acesso restrito ao papel de Administrador de Banco, com registro de acesso.

**7.1.4.** Dados especialmente sensíveis (PII de comprador, CPF/CNPJ, dados de PIX/bancários de coprodutores) permanecem sujeitos, mesmo em backup, às políticas de minimização e retenção da LGPD; a exclusão a pedido de titular (art. 18, LGPD) é registrada e reprocessada nos backups conforme o procedimento da Seção 11.6.

### 7.2. Storage (buckets)

**7.2.1.** Buckets do Supabase Storage operam com **versionamento de objetos** e **cópia periódica** (mínimo diária para documentos fiscais e comprovantes) para armazenamento redundante independente. Documentos fiscais (NF-e) observam o prazo legal de guarda fiscal aplicável (regra geral, 5 anos).

### 7.3. Aplicação e configuração

**7.3.1.** O **código-fonte** é a fonte da verdade e reside em repositório Git versionado; RPO efetivo = 0, pois todo estado da aplicação é reconstruível a partir do commit.

**7.3.2.** As **migrations** em `supabase/migrations/` são a fonte da verdade do schema e permitem reconstrução determinística da estrutura do banco.

**7.3.3. Segredos e variáveis de ambiente** (chaves service role, tokens de VHSYS, Correios, gateways, credenciais de API write-only) são mantidos em cofre de segredos e replicados em backup cifrado, **nunca** versionados em texto claro no repositório.

### 7.4. Princípio 3-2-1

Adota-se a regra **3-2-1**: no mínimo **3 cópias** dos dados críticos, em **2 mídias/tecnologias distintas**, com **1 cópia geograficamente separada** e logicamente isolada (air-gapped/imutável quando possível, como defesa contra ransomware).

### 7.5. Verificação de integridade

Todo backup é submetido a **verificação automática de integridade** (checksum) e a **teste de restauração amostral** periódico (Seção 12); backup não testado é considerado backup inexistente.

---

## 8. Procedimentos Técnicos de Recuperação

### 8.1. Recuperação do Banco de Dados Supabase (SEV-1)

**Runbook DB-01 — Restauração PITR / snapshot:**
1. **Declarar incidente** e acionar o Comitê de Crise (Seção 10); registrar horário de reconhecimento (marco T0).
2. **Isolar** a origem: suspender jobs de ingestão de pedidos e integrações de escrita para evitar propagação de corrupção; colocar a aplicação em modo de manutenção/somente-leitura, se possível.
3. **Diagnosticar** a natureza (corrupção lógica, exclusão em massa, comprometimento) e determinar o **ponto de recuperação alvo** (timestamp íntegro imediatamente anterior ao evento).
4. **Provisionar** o alvo de restauração (novo projeto/instância Supabase ou restauração in-place, conforme orientação do provedor), preferindo restauração em instância paralela para preservar evidências forenses quando houver suspeita de incidente de segurança.
5. **Executar** a restauração via PITR (para o timestamp alvo) ou via snapshot diário mais próximo, conforme o RPO da Seção 6.
6. **Reaplicar migrations** pendentes a partir de `supabase/migrations/` para garantir consistência de schema, RLS, funções `security definer` e triggers de auditoria.
7. **Validar integridade pós-restauração** (Seção 8.6): contagem de registros por tenant, integridade de FKs, funcionamento das políticas RLS por empresa, triggers `tg_touch_row`/`tg_write_audit` ativos, e amostragem de dados sensíveis.
8. **Reapontar** a aplicação (variáveis de ambiente/connection string) para a instância recuperada.
9. **Reprocessar** filas retidas de ingestão de pedidos de forma **idempotente** (evitar duplicidade de pedidos/split).
10. **Encerrar** o modo manutenção, monitorar e registrar o marco de recuperação (T-recuperado) para aferição de RTO/RPO.

**Runbook DB-02 — Indisponibilidade regional (SEV-1/SEV-2):**
1. Confirmar a natureza (falha de região do provedor) via status oficial do Supabase.
2. Se a janela de indisponibilidade projetada exceder o RTO, promover a **restauração do último backup íntegro em região/projeto alternativo** (conforme disponibilidade do provedor) e seguir os passos 6 a 10 do Runbook DB-01.
3. Comunicar CONTROLADORES-clientes impactados sobre a degradação e a estimativa de recuperação.

### 8.2. Recuperação da Hospedagem Netlify (SEV-2)

**Runbook APP-01 — Deploy defeituoso / indisponibilidade SSR:**
1. Identificar se a falha decorre de build/deploy recente ou de indisponibilidade da plataforma Netlify.
2. **Rollback imediato** para o último deploy publicado e estável (deploy anterior atômico), restabelecendo a versão íntegra em minutos.
3. Se indisponibilidade da própria Netlify: acionar plano de **contingência de hospedagem** — redeploy do build a partir do repositório Git em provedor SSR alternativo compatível com Next.js (previamente homologado), reapontando DNS.
4. **Restaurar variáveis de ambiente** a partir do cofre de segredos no ambiente de destino.
5. Validar conectividade com o banco Supabase, com Supabase Auth e com os sub-operadores.
6. Confirmar funcionamento do **portal público de rastreio** (deve expor apenas status neutro, sem PII) e das rotas autenticadas.
7. Se necessário, ajustar DNS/CDN e monitorar propagação.

### 8.3. Recuperação do Storage (SEV-2)

**Runbook STG-01:**
1. Identificar buckets/objetos afetados.
2. Restaurar objetos a partir da versão íntegra anterior (versionamento) ou da cópia redundante independente.
3. Priorizar documentos fiscais (NF-e) e comprovantes por implicação legal de guarda.
4. Reconciliar referências no banco (metadados apontando para objetos) e revalidar links do portal de rastreio.

### 8.4. Recuperação de Integrações e Sub-operadores (SEV-2/SEV-3)

**Runbook INT-01:**
1. Verificar status do sub-operador (VHSYS, Correios, gateways) via health-check/status page.
2. Enquanto indisponível, **enfileirar** as operações pendentes (emissão de NF-e, PPN/SRO, split/repasse) com controle de idempotência, aplicando **degradação graciosa** (a Plataforma segue operando; a operação dependente fica pendente, não perdida).
3. Restabelecido o sub-operador, **reprocessar a fila** em ordem, verificando duplicidade e conciliando (especialmente split/repasse financeiro — nunca duplicar repasse a coprodutor/afiliado).
4. Registrar na trilha de auditoria o reprocessamento.

### 8.5. Recuperação de Credenciais/Segredos (SEV-2)

**Runbook SEC-01:**
1. Em caso de perda: restaurar do cofre/backup cifrado.
2. Em caso de comprometimento: **rotacionar imediatamente** todas as chaves afetadas (service role Supabase, tokens de VHSYS/Correios/gateways, chaves de API write-only), revogar as anteriores e reemitir no cofre e nas variáveis de ambiente.
3. Acionar o Runbook de Incidente de Segurança (Seção 11) se houver indício de acesso não autorizado a dados pessoais.

### 8.6. Validação Pós-Recuperação (obrigatória em todos os cenários)

Antes de declarar serviço recuperado, verificar:
- **a)** Integridade referencial e contagem de registros por tenant (ausência de perda/duplicidade além do RPO);
- **b)** Efetividade das políticas **RLS** — testar isolamento cross-tenant (uma empresa não enxerga dados de outra);
- **c)** RBAC — `app.has_permission` operando; papéis e permissões íntegros;
- **d)** Triggers de auditoria e de atualização ativos e gravando;
- **e)** Soft-delete preservado (registros com `deleted_at` não reaparecem em leituras);
- **f)** Autenticação (login/JWT) funcional;
- **g)** Fluxo ponta a ponta: ingestão de pedido → estoque → NF-e → expedição → rastreio → notificação;
- **h)** Portal público de rastreio expondo **apenas status neutro**, sem exposição de PII;
- **i)** Conciliação financeira de split/repasse sem duplicidade.

---

## 9. Ordem de Recuperação de Serviços

**9.1.** Diante de desastre de amplo espectro, a recuperação segue **ordem de precedência por dependência e criticidade**, do fundamento à periferia:

1. **Camada de dados e identidade** — Banco Supabase (PostgreSQL, RLS, funções, triggers) e Supabase Auth. *Fundamento de tudo; sem ele nenhum serviço opera com segurança.*
2. **Segredos e configuração** — restauração/rotação de variáveis de ambiente e chaves de integração.
3. **Aplicação SSR** — redeploy Next.js na Netlify (ou contingência), reapontada ao banco recuperado.
4. **Storage** — buckets (priorizando documentos fiscais e comprovantes).
5. **Ingestão de pedidos** — reativação das integrações de entrada (gateways, e-commerces) com reprocessamento idempotente.
6. **Serviços fiscais e logísticos** — NF-e (VHSYS), pré-postagem e rastreio (Correios).
7. **Financeiro / split** — apuração e repasse a coprodutores/afiliados, com conciliação.
8. **Notificações** — WhatsApp/e-mail ao comprador.
9. **Portal público de rastreio** — validado quanto à exposição mínima.
10. **BI / Materialized Views** — refresh após estabilização do banco.

**9.2.** Nenhuma camada superior é declarada recuperada antes da validação da camada da qual depende. A ordem pode ser ajustada pelo Comitê de Crise mediante registro fundamentado.

---

## 10. Papéis, Responsáveis e Governança de Crise

**10.1. Comitê de Crise (DR Team).** Órgão de acionamento e decisão durante o desastre, composto por:
- **Coordenador de Recuperação (DR Coordinator)** — [PARTE], conduz o Plano, declara início/fim do desastre, arbitra prioridades.
- **Administrador de Banco de Dados** — executa Runbooks DB-01/DB-02 e a validação de integridade.
- **Engenheiro de Aplicação/DevOps** — executa Runbooks APP-01 e SEC-01, deploy e configuração.
- **Encarregado (DPO)** — a ser designado pela administração — avalia impacto sobre dados pessoais, conduz comunicação a titulares e à ANPD (art. 48, LGPD) e a CONTROLADORES-clientes.
- **Responsável de Segurança da Informação (CISO/SecOps)** — conduz contenção, forense e rotação de credenciais.
- **Comunicação / Relacionamento** — comunica clientes, sub-operadores e stakeholders.

**10.2.** Cada papel possui **suplente designado** para garantir cobertura ininterrupta. Os contatos (nome, telefone, e-mail, sobreaviso) constam do **Anexo I — Cadeia de Acionamento**, mantido atualizado e de acesso restrito.

**10.3.** A Matriz RACI detalhada consta da Seção 14(d).

---

## 11. Interface com Gestão de Incidentes de Dados Pessoais

**11.1.** Quando o desastre envolver, ainda que potencialmente, dados pessoais (PII de comprador, dados de colaboradores, dados de PIX/bancários de coprodutores), este DRP articula-se com o **Plano de Resposta a Incidentes** e com a **Política de Privacidade / DPA**.

**11.2. Contenção e preservação de evidências.** Priorizar a contenção sem destruir evidências; quando houver suspeita de comprometimento, preferir restauração em instância paralela (Seção 8.1, passo 4).

**11.3. Avaliação de risco.** O DPO e o SecOps avaliam se o incidente pode acarretar risco ou dano relevante aos titulares (art. 48, LGPD).

**11.4. Comunicação à ANPD e aos titulares.** Havendo risco relevante, comunicar a Autoridade Nacional de Proteção de Dados e os titulares afetados em **prazo razoável**, observado o entendimento vigente da ANPD sobre prazo (referência atual: até 3 dias úteis do conhecimento), com o conteúdo mínimo do art. 48, §1º, LGPD.

**11.5. Dupla natureza — dever de informar o CONTROLADOR.** Quando a GLOP atuar como **OPERADORA**, comunicar imediatamente ao CONTROLADOR (produtor/lojista/marketplace) o incidente que afete os dados por ele controlados, cabendo a este a comunicação à ANPD e aos titulares, sem prejuízo do suporte da Operadora (arts. 39 e 48, LGPD; cláusulas do DPA).

**11.6. Direito de exclusão em backups.** Pedidos de exclusão de titular (art. 18, LGPD) já atendidos em produção são reprocessados quando um backup que contenha o dado é restaurado, mantendo-se registro da anonimização/eliminação, salvo hipóteses legais de guarda (art. 16, LGPD; guarda fiscal de NF-e).

---

## 12. Testes Periódicos, Simulações e Manutenção do Plano

**12.1. Regime mínimo de testes:**

| Teste | Objetivo | Frequência mínima |
|---|---|---|
| Verificação de integridade de backup (checksum) | Garantir backup restaurável | Automática / diária |
| Restauração amostral de backup | Confirmar recuperabilidade real dos dados | Mensal |
| Teste de PITR (restauração a timestamp) | Aferir RPO efetivo do banco | Trimestral |
| Simulação de rollback/redeploy Netlify | Aferir RTO da aplicação | Trimestral |
| Simulação de failover regional/hospedagem | Validar contingência de provedor | Semestral |
| Tabletop / simulação de crise (Comitê) | Exercitar governança e cadeia de acionamento | Semestral |
| Teste integral de DR (end-to-end) | Validar Plano completo, ordem e metas | Anual |
| Rotação de credenciais (drill) | Validar Runbook SEC-01 | Semestral |

**12.2.** Todo teste gera **relatório** com: escopo, RTO/RPO aferidos vs. metas, desvios, lições aprendidas e plano de ação corretiva. Backup ou procedimento que falhe em teste gera não conformidade tratada como prioritária.

**12.3.** Este Plano é **revisado**: (i) anualmente; (ii) após todo teste integral; (iii) após todo incidente real (post-mortem sem culpabilização); (iv) diante de mudança material de arquitetura, provedor, sub-operador ou legislação.

---

## 13. Comunicação, Confidencialidade e Registro

**13.1. Confidencialidade.** Este Plano, seus anexos, runbooks, contatos e detalhes de infraestrutura são **informação confidencial**; o acesso é restrito, por RBAC e need-to-know, ao Comitê de Crise e a pessoal autorizado. A divulgação indevida sujeita o infrator às penalidades da Seção 13.3 e à responsabilização civil.

**13.2. Registro e auditabilidade.** Toda ativação do Plano é registrada (marcos temporais, decisões, ações, responsáveis), integrando a trilha de auditoria e servindo de evidência de conformidade (accountability — art. 6º, X, LGPD).

**13.3. Sanções.** O descumprimento deste Plano por colaborador ou prestador — inclusive omissão de acionamento, falha em manter backups testáveis ou violação de confidencialidade — sujeita o responsável a medidas disciplinares proporcionais, contratuais e, quando cabível, à responsabilização civil e criminal, sem prejuízo das sanções administrativas da LGPD à Operadora.

---

## 14. Engenharia Jurídica & Governança

### (a) Fundamentação das cláusulas

- **LGPD (Lei nº 13.709/2018):** art. 6º, VII (segurança) e VIII (prevenção); art. 6º, X (responsabilização e prestação de contas); arts. 46 a 49 (medidas de segurança, boas práticas e governança); art. 48 (comunicação de incidente à ANPD e a titulares); arts. 39 e distinção controlador/operador (art. 5º, VI e VII) fundamentam a dupla natureza e os deveres de recuperação, comunicação e continuidade.
- **Marco Civil da Internet (Lei nº 12.965/2014):** arts. 7º, 10 e 13 — guarda, segurança e sigilo de registros e dados.
- **Código de Defesa do Consumidor (Lei nº 8.078/1990):** arts. 6º, 14 e 20 — dever de segurança e continuidade do serviço prestado ao consumidor final (comprador), fundamentando RTO/RPO e disponibilidade.
- **Legislação fiscal:** guarda de documentos fiscais eletrônicos (NF-e), justificando retenção diferenciada de backups de Storage.
- **ISO/IEC 27001** (SGSI — controles de continuidade e backup — Anexo A, cópias de segurança e redundâncias) e **ISO/IEC 27701** (extensão de privacidade) embasam controles técnicos e organizacionais.
- **ISO 22301** (Continuidade de Negócio — BCMS): fundamenta análise de impacto, RTO/RPO, estratégias de recuperação e testes.
- **ISO 31000** (Gestão de Riscos): classificação de severidade e tratamento de cenários.
- **NIST SP 800-34** (Contingency Planning) e **NIST CSF** (funções Protect/Respond/Recover): estrutura de runbooks, ordem de recuperação e testes.
- **OWASP:** boas práticas de segurança de aplicação (gestão de segredos, autenticação, rotação de credenciais).

### (b) Riscos mitigados

- Perda ou corrupção irreversível de dados (mitigado por 3-2-1, PITR e testes de restauração).
- Indisponibilidade prolongada de serviço crítico e quebra de SLA (mitigado por RTO/RPO, rollback atômico e contingência de hospedagem).
- Vazamento/exfiltração de PII de comprador e dados financeiros de coprodutores (mitigado por rotação de credenciais, restauração forense e interface com resposta a incidentes).
- Duplicidade financeira em split/repasse após recuperação (mitigado por reprocessamento idempotente e conciliação).
- Vazamento cross-tenant após restauração (mitigado por validação obrigatória de RLS/RBAC).
- Exposição indevida no portal público de rastreio (mitigado por validação de status neutro).
- Falha correlata de provedor único (mitigado por cópia geograficamente separada e contingência multiprovedor).
- Descumprimento de prazos regulatórios de comunicação de incidente (mitigado pela Seção 11).
- Backup não recuperável (mitigado por verificação de integridade e testes periódicos).

### (c) Checklist de conformidade

- [ ] Backups diários + PITR ativos e monitorados no Supabase.
- [ ] Cópia de longo prazo cifrada e geograficamente separada (regra 3-2-1).
- [ ] Segredos em cofre, replicados em backup cifrado, fora do Git.
- [ ] Runbooks DB-01/02, APP-01, STG-01, INT-01, SEC-01 documentados e acessíveis ao Comitê.
- [ ] Matriz RTO/RPO revisada e alinhada aos SLAs contratuais.
- [ ] Ordem de recuperação por dependência definida e ensaiada.
- [ ] Comitê de Crise com titulares e suplentes; Anexo I de contatos atualizado.
- [ ] Testes periódicos executados e relatados (mensal/trimestral/semestral/anual).
- [ ] Validação pós-recuperação (RLS, RBAC, triggers, soft-delete, portal público) padronizada.
- [ ] Fluxo de comunicação de incidente (ANPD, titulares, CONTROLADORES) integrado.
- [ ] Procedimento de exclusão de titular em backups definido.
- [ ] Confidencialidade do Plano assegurada por RBAC e need-to-know.
- [ ] Plano revisado no último ciclo e versão controlada.

### (d) Matriz RACI

Legenda: **R** = Responsável (executa) · **A** = Autoridade (presta contas/aprova) · **C** = Consultado · **I** = Informado.

| Atividade | DR Coordinator | Admin. Banco | DevOps/App | DPO | SecOps/CISO | Comunicação |
|---|---|---|---|---|---|---|
| Declarar desastre / ativar Plano | A/R | C | C | C | C | I |
| Restaurar banco (PITR/snapshot) | A | R | C | I | C | I |
| Redeploy / contingência Netlify | A | C | R | I | C | I |
| Restaurar Storage | A | C | R | I | C | I |
| Reprocessar integrações/filas | A | R | R | I | C | I |
| Rotacionar/restaurar credenciais | A | C | C | I | R | I |
| Validação pós-recuperação (RLS/RBAC) | A | R | C | C | C | I |
| Avaliar impacto a dados pessoais | C | C | C | A/R | C | I |
| Comunicar ANPD / titulares | I | I | I | A/R | C | C |
| Comunicar CONTROLADORES / clientes | A | I | I | C | I | R |
| Executar testes periódicos de DR | A | R | R | C | C | I |
| Revisar e versionar o Plano | A/R | C | C | C | C | I |

### (e) Plano de revisão

- **Gatilhos:** revisão anual obrigatória; pós-teste integral; pós-incidente real (post-mortem); mudança de arquitetura, provedor (Supabase/Netlify), sub-operador (VHSYS/Correios/gateways) ou legislação.
- **Responsável:** DR Coordinator, com validação do DPO (privacidade) e do jurídico.
- **Método:** aferição de RTO/RPO reais vs. metas; atualização de runbooks, contatos e matriz; registro no controle de versão.
- **Evidência:** relatórios de teste e atas arquivados para fins de accountability.

### (f) Controle de versão

| Versão | Data | Autor / Responsável | Descrição da alteração | Aprovação |
|---|---|---|---|---|
| 0.1 (minuta) | 16 de julho de 2026 | Chief Legal AI (IA) | Elaboração inicial do DRP GLOP | Pendente — advogado(a) habilitado(a) |
| | | | | |

---

*Documento anexo referenciado (mantido em separado, acesso restrito): Anexo I — Cadeia de Acionamento e Contatos do Comitê de Crise.*
