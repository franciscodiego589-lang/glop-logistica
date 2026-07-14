"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (n: number | null | undefined) => n == null ? "—" : n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });

type Sugg = { id: string; product_id: string; on_hand: number | null; reorder_point: number | null; suggested_quantity: number | null; reason: string | null; status: string };
type Stock = { id: string; name: string; sku: string | null; abc_class: string | null; cost_price: number | null; reorder_point: number | null; on_hand: number };

const ABC_CLS: Record<string, string> = { A: "bg-green-500/15 text-green-500", B: "bg-amber-500/15 text-amber-500", C: "bg-slate-500/15 text-slate-400" };

export default function EstoqueWorkbench({ suggestions, stock, prodName }: { suggestions: Sugg[]; stock: Stock[]; prodName: Record<string, string> }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [q, setQ] = useState("");

  async function runRpc(fn: string, label: string) {
    if (!supabase) return;
    setBusy(fn); setMsg(null); setErr(null);
    const { data, error } = await supabase.rpc(fn, { p_company: COMPANY });
    setBusy(null);
    if (error) { setErr(`${label}: ${error.message}`); return; }
    setMsg(`${label}: ${data} ${fn === "calculate_abc" ? "produtos classificados" : "sugestões geradas"} ✓`);
    router.refresh();
  }

  async function suggStatus(id: string, status: string) {
    if (!supabase) return;
    await supabase.from("reorder_suggestions").update({ status }).eq("id", id);
    router.refresh();
  }

  const filtered = useMemo(() => {
    const s = q.trim().toLowerCase();
    return s ? stock.filter((r) => r.name.toLowerCase().includes(s) || (r.sku ?? "").toLowerCase().includes(s)) : stock;
  }, [q, stock]);

  const openSugg = suggestions.filter((s) => s.status === "open");

  return (
    <div className="space-y-4">
      <div className="card p-4 flex flex-wrap gap-3 items-center">
        <div className="font-semibold">Inteligência de estoque</div>
        <button onClick={() => runRpc("calculate_abc", "Curva ABC")} disabled={!!busy}
          className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold disabled:opacity-60">
          {busy === "calculate_abc" ? "Calculando…" : "↻ Recalcular curva ABC"}</button>
        <button onClick={() => runRpc("generate_reorder_suggestions", "Ressuprimento")} disabled={!!busy}
          className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold disabled:opacity-60">
          {busy === "generate_reorder_suggestions" ? "Gerando…" : "⚡ Gerar sugestões de ressuprimento"}</button>
        {msg && <span className="text-sm text-green-500">{msg}</span>}
        {err && <span className="text-sm text-red-500">{err}</span>}
      </div>

      {/* Sugestões de ressuprimento */}
      <div className="card p-4">
        <div className="font-semibold mb-3">Sugestões de ressuprimento <span className="muted font-normal">({openSugg.length} abertas)</span></div>
        {openSugg.length === 0 ? (
          <p className="text-sm muted">Nenhuma sugestão aberta. Gere sugestões acima — o motor compara o saldo com o ponto de pedido de cada produto.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase"><th className="py-1.5 pr-3">Produto</th><th className="pr-3">Saldo</th><th className="pr-3">Ponto pedido</th><th className="pr-3">Sugerido</th><th className="pr-3">Motivo</th><th></th></tr></thead>
              <tbody>
                {openSugg.map((s) => (
                  <tr key={s.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                    <td className="py-1.5 pr-3">{prodName[s.product_id] ?? "—"}</td>
                    <td className="pr-3 tabular-nums text-red-500">{s.on_hand ?? 0}</td>
                    <td className="pr-3 tabular-nums">{s.reorder_point ?? "—"}</td>
                    <td className="pr-3 tabular-nums font-semibold">{s.suggested_quantity ?? "—"}</td>
                    <td className="pr-3 muted text-xs">{s.reason ?? "—"}</td>
                    <td className="text-right whitespace-nowrap">
                      <button onClick={() => suggStatus(s.id, "ordered")} className="text-xs text-brand-500 hover:underline mr-3">marcar pedido</button>
                      <Link href="/compras" className="text-xs text-brand-500 hover:underline mr-3">comprar →</Link>
                      <button onClick={() => suggStatus(s.id, "dismissed")} className="text-xs text-red-500 hover:underline">descartar</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Saldo por produto + ABC */}
      <div className="card p-4">
        <div className="flex items-center gap-3 mb-3">
          <div className="font-semibold">Saldo por produto <span className="muted font-normal">({stock.length})</span></div>
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Buscar…"
            className="ml-auto border rounded-lg px-3 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500 w-48" style={{ borderColor: "var(--border)" }} />
        </div>
        {stock.length === 0 ? (
          <p className="text-sm muted">Nenhum produto com saldo. Receba pedidos de compra (módulo Compras) para dar entrada no estoque.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase"><th className="py-1.5 pr-3">Produto</th><th className="pr-3">SKU</th><th className="pr-3">ABC</th><th className="pr-3">Saldo</th><th className="pr-3">Ponto pedido</th><th className="pr-3">Custo</th><th className="pr-3">Valor em estoque</th></tr></thead>
              <tbody>
                {filtered.slice(0, 400).map((r) => {
                  const low = r.reorder_point != null && r.on_hand < r.reorder_point;
                  return (
                    <tr key={r.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                      <td className="py-1.5 pr-3">{r.name}</td>
                      <td className="pr-3 font-mono text-xs muted">{r.sku ?? "—"}</td>
                      <td className="pr-3">{r.abc_class ? <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${ABC_CLS[r.abc_class] ?? ""}`}>{r.abc_class}</span> : "—"}</td>
                      <td className={`pr-3 tabular-nums ${low ? "text-red-500 font-semibold" : ""}`}>{r.on_hand}{low ? " ⚠" : ""}</td>
                      <td className="pr-3 tabular-nums muted">{r.reorder_point ?? "—"}</td>
                      <td className="pr-3 tabular-nums">{money(r.cost_price)}</td>
                      <td className="pr-3 tabular-nums">{money((r.cost_price ?? 0) * r.on_hand)}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
            {filtered.length > 400 && <div className="text-xs muted mt-2">Mostrando 400 de {filtered.length}.</div>}
          </div>
        )}
      </div>
    </div>
  );
}
