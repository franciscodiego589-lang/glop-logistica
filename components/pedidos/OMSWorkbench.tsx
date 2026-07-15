"use client";
import { Fragment, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const brl = (n: number) => (n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const k = (n: number) => (n ?? 0).toLocaleString("pt-BR", { maximumFractionDigits: 0 });

const STATUS_LABEL: Record<string, string> = {
  new: "Novo", credit_hold: "Bloqueio crédito", approved: "Aprovado", reserved: "Reservado",
  awaiting_production: "Aguard. produção", picking: "Separação", shipped: "Expedido",
  delivered: "Entregue", invoiced: "Faturado", canceled: "Cancelado", returned: "Devolvido",
};
const STATUS_BADGE: Record<string, string> = {
  new: "badge-neutral", credit_hold: "badge-danger", approved: "badge-brand", reserved: "badge-brand",
  awaiting_production: "badge-warning", picking: "badge-warning", shipped: "badge-success",
  delivered: "badge-success", invoiced: "badge-success", canceled: "badge-danger", returned: "badge-warning",
};

const TABS = ["Painel", "Pedidos", "Consulta ATP"] as const;
type Tab = typeof TABS[number];

export default function OMSWorkbench({ dash, orders, items, events, products, accounts }: {
  dash: any; orders: any[]; items: any[]; events: any[]; products: any[]; accounts: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Core Comercial · O Maestro</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Gestão de Pedidos (OMS)</h1>
        <p className="text-sm muted mt-0.5">Ciclo completo: receber → validar (crédito/ATP) → reservar → expedir (baixa estoque) → faturar (NF-e + GL).</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>
      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Pedidos" && <Pedidos orders={orders} items={items} events={events} products={products} accounts={accounts} />}
      {tab === "Consulta ATP" && <ATP products={products} />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}

function Painel({ dash }: { dash: any }) {
  const d = dash ?? {};
  const bs: Record<string, number> = d.by_status ?? {};
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <KPI label="Pedidos" value={String(d.orders_total ?? 0)} />
        <KPI label="Em aberto" value={String(d.open ?? 0)} hint={`R$ ${k(Number(d.open_value ?? 0))}`} />
        <KPI label="Bloqueio de crédito" value={String(d.credit_hold ?? 0)} tone={d.credit_hold ? "var(--danger)" : undefined} />
        <KPI label="Aguardando produção" value={String(d.awaiting_production ?? 0)} tone={d.awaiting_production ? "var(--warning)" : undefined} />
        <KPI label="Expedidos+" value={String(d.shipped ?? 0)} tone="var(--success)" />
        <KPI label="Cancelados" value={String(d.canceled ?? 0)} />
        <KPI label="Receita faturada" value={`R$ ${k(Number(d.revenue_invoiced ?? 0))}`} tone="var(--success)" />
      </div>
      <div className="card p-5">
        <div className="font-semibold mb-3">Pedidos por status</div>
        {Object.keys(bs).length === 0 ? <p className="text-sm muted">Sem pedidos ainda.</p> : (
          <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3">
            {Object.entries(bs).map(([s, c]) => (
              <div key={s} className="surface-2 rounded-xl p-3" style={{ border: "1px solid var(--border)" }}>
                <div className="text-xs muted font-semibold">{STATUS_LABEL[s] ?? s}</div>
                <div className="text-lg font-bold tabular-nums mt-1">{c}</div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function Pedidos({ orders, items, events, products, accounts }: { orders: any[]; items: any[]; events: any[]; products: any[]; accounts: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState<string | null>(null);
  const [expand, setExpand] = useState<string | null>(null);
  const [hdr, setHdr] = useState({ customer_name: "", account_id: "", channel: "b2b" });
  const [lines, setLines] = useState<{ product_id: string; quantity: string }[]>([{ product_id: "", quantity: "1" }]);

  const sellable = useMemo(() => products.filter((p) => p.is_sellable !== false), [products]);
  const prodName = (id: string) => products.find((p) => p.id === id)?.name ?? "—";

  async function createOrder() {
    if (!supabase) return;
    const payload = lines.filter((l) => l.product_id && Number(l.quantity) > 0).map((l) => ({ product_id: l.product_id, quantity: Number(l.quantity) }));
    if (!hdr.customer_name || payload.length === 0) return;
    setBusy("create");
    await supabase.rpc("create_sales_order", { p_company: COMPANY, p_header: { customer_name: hdr.customer_name, account_id: hdr.account_id || null, channel: hdr.channel }, p_items: payload });
    setBusy(null); setOpen(false); setHdr({ customer_name: "", account_id: "", channel: "b2b" }); setLines([{ product_id: "", quantity: "1" }]); router.refresh();
  }
  async function act(id: string, fn: "reserve" | "ship" | "invoice" | "cancel") {
    if (!supabase) return;
    setBusy(id);
    if (fn === "reserve") await supabase.rpc("reserve_order_stock", { p_order: id });
    else if (fn === "ship") await supabase.rpc("advance_order", { p_order: id, p_status: "shipped" });
    else if (fn === "invoice") await supabase.rpc("advance_order", { p_order: id, p_status: "invoiced" });
    else if (fn === "cancel") await supabase.rpc("cancel_order", { p_order: id, p_reason: "cancelado na tela" });
    setBusy(null); router.refresh();
  }

  const nextAction = (s: string) => {
    if (["new", "approved"].includes(s)) return { fn: "reserve" as const, label: "Reservar" };
    if (["reserved", "awaiting_production", "picking"].includes(s)) return { fn: "ship" as const, label: "Expedir" };
    if (["shipped", "delivered"].includes(s)) return { fn: "invoice" as const, label: "Faturar" };
    return null;
  };

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Pedidos <span className="badge badge-neutral ml-1">{orders.length}</span></div>
        <button onClick={() => setOpen((o) => !o)} className={`btn btn-sm ${open ? "" : "btn-primary"}`}>{open ? "Cancelar" : "+ Novo pedido"}</button>
      </div>

      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div className="md:col-span-2"><label className="label">Cliente</label>
              <input value={hdr.customer_name} onChange={(e) => setHdr((p) => ({ ...p, customer_name: e.target.value }))} className="input" placeholder="Nome do cliente" list="acc" />
              <datalist id="acc">{accounts.map((a) => <option key={a.id} value={a.name} />)}</datalist>
            </div>
            <div><label className="label">Canal</label><select value={hdr.channel} onChange={(e) => setHdr((p) => ({ ...p, channel: e.target.value }))} className="select">
              <option value="b2b">B2B</option><option value="b2c">B2C</option><option value="marketplace">Marketplace</option><option value="whatsapp">WhatsApp</option></select></div>
          </div>
          <div className="space-y-2">
            {lines.map((l, i) => (
              <div key={i} className="flex gap-2">
                <select value={l.product_id} onChange={(e) => setLines((p) => p.map((x, j) => j === i ? { ...x, product_id: e.target.value } : x))} className="select flex-1">
                  <option value="">— produto —</option>{sellable.map((p) => <option key={p.id} value={p.id}>{p.name} (R$ {brl(Number(p.sale_price || 0))})</option>)}
                </select>
                <input type="number" value={l.quantity} onChange={(e) => setLines((p) => p.map((x, j) => j === i ? { ...x, quantity: e.target.value } : x))} className="input w-24" placeholder="qtd" />
                {lines.length > 1 && <button onClick={() => setLines((p) => p.filter((_, j) => j !== i))} className="btn btn-sm" style={{ color: "var(--danger)" }}>✕</button>}
              </div>
            ))}
            <button onClick={() => setLines((p) => [...p, { product_id: "", quantity: "1" }])} className="btn btn-sm">+ Item</button>
          </div>
          <button onClick={createOrder} disabled={busy === "create" || !hdr.customer_name} className="btn btn-primary btn-sm">{busy === "create" ? "Criando…" : "Criar pedido"}</button>
        </div>
      )}

      {orders.length === 0 ? <p className="text-sm muted px-1">Nenhum pedido ainda.</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead><tr><th>Nº</th><th>Cliente</th><th>Canal</th><th className="text-right">Total</th><th>Status</th><th></th></tr></thead>
            <tbody>
              {orders.map((o) => {
                const na = nextAction(o.status);
                const oItems = items.filter((it) => it.order_id === o.id);
                const oEvents = events.filter((e) => e.order_id === o.id);
                return (
                  <Fragment key={o.id}>
                    <tr>
                      <td className="tabular-nums font-semibold">#{o.order_number}</td>
                      <td>{o.customer_name ?? "—"}</td>
                      <td className="uppercase text-xs muted">{o.channel}</td>
                      <td className="text-right tabular-nums font-medium">{brl(Number(o.total_amount))}</td>
                      <td><span className={`badge ${STATUS_BADGE[o.status]}`}>{STATUS_LABEL[o.status] ?? o.status}</span></td>
                      <td className="text-right whitespace-nowrap">
                        <button onClick={() => setExpand(expand === o.id ? null : o.id)} className="text-xs muted hover:underline mr-2">ver</button>
                        {na && <button onClick={() => act(o.id, na.fn)} disabled={busy === o.id} className="btn btn-primary btn-sm mr-1">{busy === o.id ? "…" : na.label}</button>}
                        {!["invoiced", "delivered", "canceled"].includes(o.status) && <button onClick={() => act(o.id, "cancel")} disabled={busy === o.id} className="text-xs font-semibold hover:underline" style={{ color: "var(--danger)" }}>cancelar</button>}
                      </td>
                    </tr>
                    {expand === o.id && (
                      <tr><td colSpan={6} className="surface-2">
                        <div className="p-3 grid md:grid-cols-2 gap-4">
                          <div>
                            <div className="text-xs font-semibold muted uppercase mb-1">Itens</div>
                            {oItems.map((it) => <div key={it.id} className="text-sm flex justify-between py-0.5"><span>{prodName(it.product_id)} × {Number(it.quantity)}</span><span className="tabular-nums">R$ {brl(Number(it.line_total))} · res {Number(it.reserved_qty)}</span></div>)}
                            {o.metadata?.nfe_number && <div className="text-xs mt-2">NF-e nº <strong>{o.metadata.nfe_number}</strong></div>}
                          </div>
                          <div>
                            <div className="text-xs font-semibold muted uppercase mb-1">Linha do tempo</div>
                            {oEvents.map((e) => <div key={e.id} className="text-xs flex gap-2 py-0.5"><span className="muted tabular-nums">{new Date(e.created_at).toLocaleString("pt-BR")}</span><span>{STATUS_LABEL[e.status_to] ?? e.event_type}{e.notes ? " — " + e.notes : ""}</span></div>)}
                          </div>
                        </div>
                      </td></tr>
                    )}
                  </Fragment>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function ATP({ products }: { products: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const [prod, setProd] = useState("");
  const [qty, setQty] = useState("10");
  const [res, setRes] = useState<any>(null);
  const [busy, setBusy] = useState(false);
  async function run() {
    if (!supabase || !prod) return;
    setBusy(true);
    const { data } = await supabase.rpc("check_atp", { p_company: COMPANY, p_product: prod, p_qty: Number(qty) || 0 });
    setBusy(false); setRes(data);
  }
  return (
    <div className="grid lg:grid-cols-2 gap-4">
      <div className="card p-4 space-y-3">
        <div className="font-semibold">Available to Promise (ATP)</div>
        <div><label className="label">Produto</label><select value={prod} onChange={(e) => setProd(e.target.value)} className="select"><option value="">—</option>{products.map((p) => <option key={p.id} value={p.id}>{p.name}</option>)}</select></div>
        <div><label className="label">Quantidade desejada</label><input type="number" value={qty} onChange={(e) => setQty(e.target.value)} className="input" /></div>
        <button onClick={run} disabled={busy || !prod} className="btn btn-primary btn-sm">{busy ? "Consultando…" : "Consultar disponibilidade"}</button>
      </div>
      <div className="card p-5">
        <div className="font-semibold mb-2">Resultado</div>
        {!res ? <p className="text-sm muted">Selecione um produto e consulte.</p> : Object.keys(res).length === 0 ? <p className="text-sm muted">—</p> : (
          <div className="space-y-1.5 text-sm">
            <div className="flex justify-between"><span className="muted">Em estoque (on-hand)</span><span className="tabular-nums">{Number(res.on_hand)}</span></div>
            <div className="flex justify-between"><span className="muted">Reservado</span><span className="tabular-nums">{Number(res.reserved)}</span></div>
            <div className="flex justify-between font-semibold"><span>Disponível</span><span className="tabular-nums">{Number(res.available)}</span></div>
            <div className="flex justify-between pt-2 mt-1 border-t" style={{ borderColor: "var(--border)" }}>
              <span className="muted">Pode prometer {qty}?</span>
              <span className={`badge ${res.can_promise ? "badge-success" : "badge-danger"}`}>{res.can_promise ? "Sim" : "Falta " + Number(res.shortfall)}</span>
            </div>
            <div className="flex justify-between"><span className="muted">Fonte</span><span>{res.source}</span></div>
            <div className="flex justify-between"><span className="muted">Data de promessa</span><span className="tabular-nums">{res.promise_date ? new Date(res.promise_date + "T00:00:00").toLocaleDateString("pt-BR") : "—"}</span></div>
          </div>
        )}
      </div>
    </div>
  );
}
