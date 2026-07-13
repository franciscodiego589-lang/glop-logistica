# ERP Logístico Mundial — Diretrizes do Projeto

> Carregado em toda sessão. Regras **obrigatórias** para qualquer código gerado.
> Este é um ERP de logística Enterprise (WMS/TMS/YMS/MRP/APS/PCP/BI/IA), novo e independente.

## Stack Oficial

| Camada | Tecnologia |
|---|---|
| Banco | **Supabase (PostgreSQL)** — backend único |
| Auth | Supabase Auth (JWT), `auth.users` |
| Segurança | RLS + RBAC (nada confia no frontend) |
| Storage | Supabase Storage (bucket por domínio) |
| Lógica crítica | Supabase Edge Functions |
| Realtime | Supabase Realtime (agenda, docas, torre de controle, alertas) |
| IA | pgvector + Edge Functions (LOGIA) |
| Frontend | **Next.js (App Router) + TypeScript** + `@supabase/ssr` |

**Proibido:** Firebase, MySQL, MongoDB. Só Supabase/PostgreSQL.

## Filosofia (Volume 01)

Mesmo banco. Nada duplicado. Toda movimentação atualiza todos os setores em tempo real:
`Entrada Fiscal → Financeiro → Compras → Estoque → Lotes → Qualidade → Custos → Produção → Expedição → CRM → BI`.

## Multi-Tenant (desde a origem)

Hierarquia: **Tenant → Company → Branch → Membership (user+role)**. Isolamento por **RLS**, nunca pelo frontend. Todo registro carrega `tenant_id`, `company_id` (e `branch_id` quando aplicável).

## Colunas-padrão (toda tabela de negócio)

```sql
id uuid pk default gen_random_uuid(), tenant_id uuid not null, company_id uuid,
branch_id uuid, active boolean not null default true, version integer not null default 1,
metadata jsonb not null default '{}'::jsonb, created_at timestamptz not null default now(),
updated_at timestamptz not null default now(), deleted_at timestamptz,
deleted_by uuid references auth.users(id), reason_deleted text,
created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
```

Sempre ligar os dois triggers:
```sql
create trigger trg_<t>_touch before insert or update on public.<t> for each row execute function app.tg_touch_row();
create trigger trg_<t>_audit after insert or update or delete on public.<t> for each row execute function app.tg_write_audit();
```

## Soft delete

Nunca `DELETE` físico. `UPDATE ... SET deleted_at = now(), reason_deleted = '...'`. Toda leitura filtra `deleted_at is null`.

## RBAC / RLS

RLS habilitado em **todas** as tabelas de `public`. Funções auxiliares (schema `app`, security definer):
`app.is_superadmin()`, `app.user_tenant_ids()`, `app.user_company_ids()`, `app.can_access_company(uuid)`, `app.has_permission('resource.action', company_id)`.

Template de policy por tabela nova:
```sql
alter table public.<t> enable row level security;
create policy <t>_select on public.<t> for select to authenticated
  using (app.is_superadmin() or company_id in (select app.user_company_ids()));
create policy <t>_insert on public.<t> for insert to authenticated
  with check (app.can_access_company(company_id) and app.has_permission('<res>.create', company_id));
create policy <t>_update on public.<t> for update to authenticated
  using (app.can_access_company(company_id) and app.has_permission('<res>.update', company_id))
  with check (app.can_access_company(company_id));
create policy <t>_delete on public.<t> for delete to authenticated using (app.is_superadmin());
```
Recursos (resource) já semeados: `master_data, inventory, wms, tms, yms, purchasing, demand, mrp, production, shipping, distribution, controltower, logia, bi, admin`.

## Convenções

- `snake_case`, inglês, tabelas no **plural**. UUID em toda PK. Toda FK **indexada**.
- Enums de negócio em `public`; funções internas em `app`.
- Sem `SELECT *` na aplicação. Sempre paginar. Sem N+1.
- KPIs/BI via **RPC** (não somar em JS). Relatórios pesados via materialized view (revogar anon/authenticated na MV para não vazar cross-tenant).

## Volumes (roadmap)

01 Fundação · 02 Cadastro Mestre · 03 WMS · 04 TMS · 05 YMS · 06 Compras · 07 Demand Planning ·
08 MRP/APS · 09 PCP/Produção · 10 Estoque Inteligente · 11 Inventário/Rastreabilidade ·
12 Expedição/Shipping · 13 Distribuição/Last Mile · 14 Torre de Controle · 15 LOGIA (IA) ·
16 BI/Dashboards · 17 Frontend Enterprise.

## Estado atual

Vol 01 (fundação) e Vol 02 (cadastro mestre) escritos em `supabase/migrations/`. Migrations = fonte da verdade do schema.
