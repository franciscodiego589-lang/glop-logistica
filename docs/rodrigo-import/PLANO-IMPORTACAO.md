# Importação do Banco "Logística Rodrigo" (lemonlog) → ERP GLOP

Fonte: `lemonlog_260715.backup` (pg_dump custom 1.16, Supabase). Extração fiel em
`rodrigo_schema_extraido.sql`. Miolo de negócio no schema `public`: **~90 tabelas,
6 funções, 10 enums, 142 policies, 39 triggers**. (Schemas `auth/storage/realtime/
vault/graphql/pgbouncer` são infra do Supabase — já temos, não se importa.)

## Regra do dono
Trazer **TUDO**, sem deixar nenhuma tabela/função/módulo de fora. **Melhorar** as
funções é permitido; **remover/excluir nada**. Adaptar ao nosso padrão (multi-tenant
`tenant_id`/`company_id`, RLS via `app.*`, colunas-padrão, triggers de audit) conta
como melhoria — é o "melhorar ainda mais".

## Mapeamento de tenancy
Rodrigo usa **`produtor_id`** como dimensão (via `current_produtor_id()` → `produtor_usuarios`).
No GLOP: **produtor = entidade de negócio sob `tenant/company`**. Cada tabela portada
ganha `tenant_id`+`company_id` (padrão) e preserva `produtor_id` como FK para a nova
`producers`. RLS por company (nosso padrão) + filtro por produtor quando aplicável.

## Módulos (cada um vira 1 migration adaptada)

| # | Módulo | Tabelas Rodrigo | Overlap c/ GLOP |
|---|---|---|---|
| M0 | **Fundação** (enums, produtores, roles) | produtores_integracao, produtor_usuarios, produtor_api_keys, profiles, user_roles; enums app_role, status_logistico_enum | parcial (RBAC nosso) |
| M1 | **Planos & Preços do Produtor** | produtor_planos, produtor_produto_precos, produto_precos, produto_regras, produtor_frete_faixas, produtor_peso_faixas | novo |
| M2 | **Pedidos & Vendas** | pedidos, pedidos_importados, pedidos_xls, pedido_regra_logs, monetizze_vendas, braip_vendas_xls, vendas_ml, ml_tokens | store_hub (superset) |
| M3 | **Coprodução & Split** ⭐ | coprodutores, coproducao_configuracoes/regras/vendas/repasses/repasse_itens/auditoria/webhook_logs, appmax_split_config/logs; 7 enums coproducao_* | novo (joia) |
| M4 | **Correios & Prepostagem** | prepostagens, prepostagens_ppn, prepostagem_auto_logs, prep_massa_logs, conferencias_postagem, correios_api_logs, correios_token_cache, cep_correcao_logs | carrier_hub (superset) |
| M5 | **Envios & Rastreamento** | envios, tracking_events, clientes_envio, notificacoes_carteiro_ausente | parcial |
| M6 | **Reenvios** | reenvios, reenvio_pagamentos | novo |
| M7 | **Estoque** | estoque_produtos, estoque_locais, estoque_movimentos, estoque_baixa_config, registro_estoque | inventory (merge) |
| M8 | **Integração VHSYS** | vhsys_estoque_movimentos, vhsys_estoque_saldos, vhsys_locais_estoque | novo |
| M9 | **NFe** | nfe_emissoes, nfe_baixa_estoque_config | novo |
| M10 | **Comunicação** (email/whatsapp) | email_envios_log, email_template_rastreio, whatsapp_envios_log, whatsapp_template, whatsapp_template_carteiro | novo |
| M11 | **Regras, Contratos & Remetentes** | regras_logisticas, remetente_config, contratos_logisticos, sislog_remetentes | parcial |
| M12 | **Webhooks & Integrações** | produtor_webhooks, produtor_webhook_entregas, produtores_integracao, sislogica_* (envios_log, webhook_recebidos, webhook_tokens), api_logs, webhook_logs | eip (merge) |

## Funções (6) — portar/adaptar
`current_produtor_id` → helper de produtor; `has_role`/`app_role` → mapear ao nosso RBAC;
`handle_new_user`, `update_updated_at_column` → nosso `app.tg_touch_row`;
`contagem_pedidos_logistica`, `limpar_pedidos_logistica` → RPCs de BI/manutenção.

## Execução
Migrations sequenciais a partir de **090** (M0 fundação) → 091.. (um módulo por vez),
cada uma no nosso padrão. Fonte da verdade = migrations. Cada migration precisa ser
aplicada no Supabase (como as 088/089). Ordem respeita FKs (M0 → M1/M3 → resto).
