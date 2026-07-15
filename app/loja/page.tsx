"use client";
import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const brl = (n: number) => (n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });

type Product = { id: string; name: string; description?: string; price: number; category?: string };
type Line = { product: Product; qty: number };

export default function LojaPage() {
  const supabase = useMemo(() => createClient(), []);
  const [catalog, setCatalog] = useState<Product[]>([]);
  const [cart, setCart] = useState<Line[]>([]);
  const [openCart, setOpenCart] = useState(false);
  const [checkout, setCheckout] = useState(false);
  const [f, setF] = useState({ name: "", email: "", coupon: "" });
  const [busy, setBusy] = useState(false);
  const [done, setDone] = useState<any>(null);
  const [coupon, setCoupon] = useState<any>(null);

  useEffect(() => {
    if (!supabase) return;
    supabase.rpc("commerce_catalog", { p_company: COMPANY, p_store: null }).then(({ data }) => setCatalog(data ?? []));
  }, [supabase]);

  const subtotal = cart.reduce((s, l) => s + l.product.price * l.qty, 0);
  const discount = coupon?.valid ? Number(coupon.discount || 0) : 0;
  const total = Math.max(subtotal - discount, 0);
  const count = cart.reduce((s, l) => s + l.qty, 0);

  function add(p: Product) {
    setCart((c) => { const e = c.find((l) => l.product.id === p.id); return e ? c.map((l) => l.product.id === p.id ? { ...l, qty: l.qty + 1 } : l) : [...c, { product: p, qty: 1 }]; });
    setOpenCart(true);
  }
  function setQty(id: string, q: number) { setCart((c) => q <= 0 ? c.filter((l) => l.product.id !== id) : c.map((l) => l.product.id === id ? { ...l, qty: q } : l)); }

  async function checkCoupon() {
    if (!supabase || !f.coupon) { setCoupon(null); return; }
    const { data } = await supabase.rpc("apply_coupon", { p_company: COMPANY, p_code: f.coupon, p_order_total: subtotal });
    setCoupon(data);
  }
  async function finish() {
    if (!supabase || !f.name || cart.length === 0) return;
    setBusy(true);
    const items = cart.map((l) => ({ product_id: l.product.id, quantity: l.qty }));
    const { data } = await supabase.rpc("storefront_order", { p_company: COMPANY, p_store: null, p_customer: f.name, p_email: f.email, p_items: items, p_coupon: coupon?.valid ? f.coupon : null });
    setBusy(false);
    if (data?.order_number) { setDone(data); setCart([]); setCheckout(false); setOpenCart(false); }
  }

  if (done) {
    return (
      <div className="min-h-screen grid place-items-center p-4" style={{ background: "var(--bg)" }}>
        <div className="card p-8 max-w-md text-center animate-in">
          <div className="h-14 w-14 rounded-full grid place-items-center text-2xl mx-auto mb-4" style={{ background: "var(--success-soft)", color: "var(--success)" }}>✓</div>
          <h1 className="text-xl font-extrabold">Pedido confirmado!</h1>
          <p className="text-sm muted mt-1">Seu pedido <strong>#{done.order_number}</strong> foi recebido e já está sendo processado.</p>
          <div className="text-2xl font-bold tabular-nums mt-3">R$ {brl(Number(done.total))}</div>
          <button onClick={() => setDone(null)} className="btn btn-primary w-full mt-5">Voltar à loja</button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen" style={{ background: "var(--bg)" }}>
      <header className="h-16 px-6 flex items-center gap-3 border-b sticky top-0 z-20" style={{ borderColor: "var(--border)", background: "var(--surface)" }}>
        <div className="h-9 w-9 rounded-xl grid place-items-center font-black text-white" style={{ background: "linear-gradient(150deg,#2f56e6,#1a336f)" }}>◈</div>
        <div className="flex-1 font-bold">Loja Oficial</div>
        <button onClick={() => setOpenCart(true)} className="btn btn-sm relative">
          🛒 Carrinho {count > 0 && <span className="badge badge-brand ml-1">{count}</span>}
        </button>
      </header>

      <main className="max-w-5xl mx-auto p-6">
        <h1 className="text-2xl font-extrabold tracking-tight mb-1">Suplementos & Bem-estar</h1>
        <p className="text-sm muted mb-5">Use o cupom <strong>BEMVINDO10</strong> e ganhe 10% na primeira compra.</p>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          {catalog.map((p) => (
            <div key={p.id} className="card p-4 card-hover flex flex-col">
              <div className="h-28 rounded-xl mb-3 grid place-items-center text-3xl" style={{ background: "var(--surface-3)" }}>💊</div>
              {p.category && <div className="text-[10px] muted font-semibold uppercase">{p.category}</div>}
              <div className="font-semibold text-sm leading-tight">{p.name}</div>
              <div className="text-xs muted mt-0.5 line-clamp-2 flex-1">{p.description}</div>
              <div className="text-lg font-bold tabular-nums mt-2">R$ {brl(Number(p.price))}</div>
              <button onClick={() => add(p)} className="btn btn-primary btn-sm w-full mt-2">Adicionar</button>
            </div>
          ))}
        </div>
      </main>

      {openCart && (
        <>
          <div className="fixed inset-0 z-30" style={{ background: "rgba(0,0,0,.4)" }} onClick={() => setOpenCart(false)} />
          <aside className="fixed right-0 top-0 bottom-0 w-full max-w-sm z-40 flex flex-col" style={{ background: "var(--surface)" }}>
            <div className="h-16 px-5 flex items-center border-b" style={{ borderColor: "var(--border)" }}>
              <div className="font-bold flex-1">Seu carrinho</div>
              <button onClick={() => setOpenCart(false)} className="btn btn-ghost btn-sm">✕</button>
            </div>
            <div className="flex-1 overflow-y-auto p-4 space-y-3">
              {cart.length === 0 ? <p className="text-sm muted">Carrinho vazio.</p> : cart.map((l) => (
                <div key={l.product.id} className="flex gap-3 items-center">
                  <div className="h-12 w-12 rounded-lg grid place-items-center text-lg shrink-0" style={{ background: "var(--surface-3)" }}>💊</div>
                  <div className="flex-1 min-w-0">
                    <div className="text-sm font-medium truncate">{l.product.name}</div>
                    <div className="text-xs muted">R$ {brl(Number(l.product.price))}</div>
                  </div>
                  <div className="flex items-center gap-1">
                    <button onClick={() => setQty(l.product.id, l.qty - 1)} className="btn btn-sm !px-2">−</button>
                    <span className="w-6 text-center text-sm tabular-nums">{l.qty}</span>
                    <button onClick={() => setQty(l.product.id, l.qty + 1)} className="btn btn-sm !px-2">+</button>
                  </div>
                </div>
              ))}
            </div>
            {cart.length > 0 && (
              <div className="border-t p-4 space-y-3" style={{ borderColor: "var(--border)" }}>
                {!checkout ? (
                  <>
                    <div className="flex justify-between font-semibold"><span>Subtotal</span><span className="tabular-nums">R$ {brl(subtotal)}</span></div>
                    <button onClick={() => setCheckout(true)} className="btn btn-primary w-full">Finalizar compra</button>
                  </>
                ) : (
                  <>
                    <input value={f.name} onChange={(e) => setF((p) => ({ ...p, name: e.target.value }))} className="input" placeholder="Seu nome" />
                    <input value={f.email} onChange={(e) => setF((p) => ({ ...p, email: e.target.value }))} className="input" placeholder="E-mail" />
                    <div className="flex gap-2">
                      <input value={f.coupon} onChange={(e) => setF((p) => ({ ...p, coupon: e.target.value }))} className="input" placeholder="Cupom" />
                      <button onClick={checkCoupon} className="btn btn-sm">Aplicar</button>
                    </div>
                    {coupon && <div className="text-xs" style={{ color: coupon.valid ? "var(--success)" : "var(--danger)" }}>{coupon.valid ? `Cupom aplicado: −R$ ${brl(discount)}` : coupon.message}</div>}
                    <div className="flex justify-between text-sm"><span className="muted">Subtotal</span><span className="tabular-nums">R$ {brl(subtotal)}</span></div>
                    {discount > 0 && <div className="flex justify-between text-sm" style={{ color: "var(--success)" }}><span>Desconto</span><span className="tabular-nums">−R$ {brl(discount)}</span></div>}
                    <div className="flex justify-between font-bold text-lg"><span>Total</span><span className="tabular-nums">R$ {brl(total)}</span></div>
                    <button onClick={finish} disabled={busy || !f.name} className="btn btn-primary w-full">{busy ? "Processando…" : "Confirmar pedido (PIX)"}</button>
                  </>
                )}
              </div>
            )}
          </aside>
        </>
      )}
    </div>
  );
}
