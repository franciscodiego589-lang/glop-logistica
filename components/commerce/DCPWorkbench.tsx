"use client";
import { useState } from "react";
import CrudPanel from "@/components/ui/CrudPanel";

const brl = (n: number) => (n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const k = (n: number) => (n ?? 0).toLocaleString("pt-BR", { maximumFractionDigits: 0 });

const TABS = ["Painel", "Lojas", "Catálogo & Vitrine", "Preços", "Promoções", "Assinaturas", "Marketplace", "CMS & SEO"] as const;
type Tab = typeof TABS[number];

export default function DCPWorkbench({ dash, stores, priceLists, promotions, subscriptions, listings, pages, products, accounts }: {
  dash: any; stores: any[]; priceLists: any[]; promotions: any[]; subscriptions: any[]; listings: any[]; pages: any[]; products: any[]; accounts: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <div className="text-xs muted font-semibold uppercase tracking-wider">Core Comercial · Comércio Digital</div>
          <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Loja & Comércio Digital (DCP)</h1>
          <p className="text-sm muted mt-0.5">Catálogo, preços por canal, promoções, assinaturas e marketplace — a venda nasce aqui e desce para o OMS.</p>
        </div>
        <a href="/loja" target="_blank" className="btn btn-sm">Ver a loja ↗</a>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Lojas" && (
        <CrudPanel table="stores" title="Lojas / Marcas"
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "slug", label: "Slug (URL)", placeholder: "loja-oficial" },
            { key: "domain", label: "Domínio" },
            { key: "channel_type", label: "Canal", type: "select", options: [["b2c","B2C"],["b2b","B2B"],["d2c","D2C"],["marketplace","Marketplace"]], default: "b2c" },
            { key: "currency", label: "Moeda", default: "BRL" }, { key: "locale", label: "Idioma", default: "pt-BR" },
          ]}
          columns={[{ key: "name", label: "Loja" }, { key: "slug", label: "Slug" }, { key: "channel_type", label: "Canal" }, { key: "domain", label: "Domínio" }]}
          rows={stores} emptyHint="Crie lojas, marcas e canais." />
      )}
      {tab === "Catálogo & Vitrine" && <Catalogo products={products} />}
      {tab === "Preços" && (
        <CrudPanel table="price_lists" title="Tabelas de Preço (por canal / cliente)"
          fields={[
            { key: "name", label: "Nome", required: true, placeholder: "Preço Distribuidor" },
            { key: "channel", label: "Canal", type: "select", options: [["b2c","B2C"],["b2b","B2B"],["marketplace","Marketplace"]] },
            { key: "account_id", label: "Cliente específico", type: "fk", fkTable: "crm_accounts", fkLabel: "name" },
            { key: "priority", label: "Prioridade", type: "number", default: "1" },
          ]}
          columns={[{ key: "name", label: "Tabela" }, { key: "channel", label: "Canal" }, { key: "account_id", label: "Cliente" }, { key: "priority", label: "Prio" }]}
          rows={priceLists} emptyHint="Defina tabelas por canal/cliente. Itens de preço por SKU/volume via API/importação." />
      )}
      {tab === "Promoções" && (
        <CrudPanel table="promotions" title="Promoções & Cupons"
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "code", label: "Código do cupom", placeholder: "BEMVINDO10" },
            { key: "promo_type", label: "Tipo", type: "select", options: [["percent","Percentual"],["fixed","Valor fixo"],["free_shipping","Frete grátis"],["bxgy","Leve X Pague Y"],["gift","Brinde"]], default: "percent" },
            { key: "value", label: "Valor (% ou R$)", type: "number" },
            { key: "min_order", label: "Pedido mínimo", type: "number", default: "0" },
            { key: "starts_at", label: "Início", type: "date" }, { key: "ends_at", label: "Fim", type: "date" },
            { key: "usage_limit", label: "Limite de uso", type: "number" },
          ]}
          columns={[
            { key: "code", label: "Cupom" }, { key: "name", label: "Nome" }, { key: "promo_type", label: "Tipo" },
            { key: "value", label: "Valor" }, { key: "used_count", label: "Usos" }, { key: "ends_at", label: "Válido até" },
          ]}
          rows={promotions} emptyHint="Cupons, cashback, frete grátis, campanhas." />
      )}
      {tab === "Assinaturas" && (
        <CrudPanel table="subscriptions" title="Assinaturas / Recorrência"
          fields={[
            { key: "account_id", label: "Cliente", type: "fk", fkTable: "crm_accounts", fkLabel: "name", required: true },
            { key: "product_id", label: "Produto", type: "fk", fkTable: "products", fkLabel: "name" },
            { key: "plan_name", label: "Plano" },
            { key: "frequency", label: "Frequência", type: "select", options: [["monthly","Mensal"],["bimonthly","Bimestral"],["quarterly","Trimestral"],["yearly","Anual"]], default: "monthly" },
            { key: "amount", label: "Valor", type: "number" },
            { key: "next_charge", label: "Próxima cobrança", type: "date" },
            { key: "status", label: "Status", type: "select", options: [["active","Ativa"],["paused","Pausada"],["canceled","Cancelada"]], default: "active" },
          ]}
          columns={[
            { key: "plan_name", label: "Plano" }, { key: "account_id", label: "Cliente" },
            { key: "amount", label: "Valor", fmt: (v) => brl(Number(v)) }, { key: "frequency", label: "Freq." },
            { key: "next_charge", label: "Próx. cobrança" }, { key: "status", label: "Status" },
          ]}
          rows={subscriptions} emptyHint="Programas recorrentes de suplementos e estéticos." />
      )}
      {tab === "Marketplace" && (
        <CrudPanel table="marketplace_listings" title="Anúncios em Marketplaces"
          fields={[
            { key: "product_id", label: "Produto", type: "fk", fkTable: "products", fkLabel: "name", required: true },
            { key: "marketplace", label: "Marketplace", type: "select", options: [["mercadolivre","Mercado Livre"],["amazon","Amazon"],["shopee","Shopee"],["magalu","Magalu"],["americanas","Americanas"]], required: true },
            { key: "external_id", label: "ID externo" },
            { key: "price", label: "Preço", type: "number" },
            { key: "status", label: "Status", type: "select", options: [["draft","Rascunho"],["active","Ativo"],["paused","Pausado"]], default: "draft" },
          ]}
          columns={[
            { key: "product_id", label: "Produto" }, { key: "marketplace", label: "Marketplace" },
            { key: "price", label: "Preço", fmt: (v) => v ? brl(Number(v)) : "—" }, { key: "status", label: "Status" },
          ]}
          rows={listings} emptyHint="Publique produtos em ML/Amazon/Shopee/Magalu (integração via API)." />
      )}
      {tab === "CMS & SEO" && (
        <CrudPanel table="cms_pages" title="Conteúdo & SEO"
          fields={[
            { key: "title", label: "Título", required: true },
            { key: "slug", label: "Slug (URL)" },
            { key: "page_type", label: "Tipo", type: "select", options: [["landing","Landing Page"],["blog","Blog"],["banner","Banner"],["page","Página"]], default: "landing" },
            { key: "meta_title", label: "Meta Title (SEO)" },
            { key: "meta_description", label: "Meta Description (SEO)" },
            { key: "status", label: "Status", type: "select", options: [["draft","Rascunho"],["published","Publicado"]], default: "draft" },
            { key: "content", label: "Conteúdo" },
          ]}
          columns={[{ key: "title", label: "Página" }, { key: "page_type", label: "Tipo" }, { key: "slug", label: "Slug" }, { key: "status", label: "Status" }]}
          rows={pages} emptyHint="Landing pages, blog, banners com SEO." />
      )}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash }: { dash: any }) {
  const d = dash ?? {};
  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
      <KPI label="Receita e-commerce" value={`R$ ${k(Number(d.ecom_revenue ?? 0))}`} tone="var(--success)" />
      <KPI label="Pedidos online" value={String(d.ecom_orders ?? 0)} />
      <KPI label="Ticket médio" value={`R$ ${k(Number(d.ecom_aov ?? 0))}`} />
      <KPI label="Lojas" value={String(d.stores ?? 0)} />
      <KPI label="Promoções ativas" value={String(d.promotions_active ?? 0)} tone="var(--brand)" />
      <KPI label="Carrinhos abandonados" value={String(d.carts_abandoned ?? 0)} tone={d.carts_abandoned ? "var(--warning)" : undefined} />
      <KPI label="Assinaturas ativas" value={String(d.subscriptions_active ?? 0)} />
      <KPI label="Anúncios marketplace" value={String(d.listings ?? 0)} />
    </div>
  );
}

function Catalogo({ products }: { products: any[] }) {
  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
      {products.map((p) => (
        <div key={p.id} className="card p-4 card-hover">
          <div className="h-24 rounded-xl mb-2 grid place-items-center text-2xl" style={{ background: "var(--surface-3)" }}>💊</div>
          <div className="font-semibold text-sm leading-tight">{p.name}</div>
          <div className="text-xs muted">{p.sku}</div>
          <div className="text-base font-bold tabular-nums mt-1">R$ {brl(Number(p.sale_price || 0))}</div>
          <div className="mt-1"><span className={`badge ${p.is_sellable !== false ? "badge-success" : "badge-neutral"}`}>{p.is_sellable !== false ? "à venda" : "inativo"}</span></div>
        </div>
      ))}
      {products.length === 0 && <p className="text-sm muted">Sem produtos no catálogo.</p>}
    </div>
  );
}
