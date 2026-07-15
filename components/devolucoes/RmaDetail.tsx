"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { RMA_STATUS } from "./RmaWorkbench";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const FLOW: Record<string, [string, string][]> = {
  open: [["received", "Registrar recebimento"], ["canceled", "Cancelar"]],
  in_transit: [["received", "Registrar recebimento"]],
  received: [["inspecting", "Iniciar inspeção"]],
  inspecting: [["approved", "Aprovar"], ["rejected", "Rejeitar"]],
  approved: [["closed", "Encerrar"]], partially_approved: [["closed", "Encerrar"]],
  rejected: [["closed", "Encerrar"]], refunded: [["closed", "Encerrar"]],
};
const CHECKS: [string, string][] = [
  ["received", "Produto recebido"], ["qty_ok", "Quantidade correta"], ["packaging_ok", "Embalagem íntegra"],
  ["seal_ok", "Lacre intacto"], ["opened", "Produto aberto"], ["used", "Produto usado"],
  ["contaminated", "Contaminado"], ["expired", "Vencido"], ["near_expiry", "Próx. vencimento"],
  ["damages", "Avarias"], ["stains", "Manchas"], ["humidity", "Umidade"], ["odor", "Odor"],
  ["color_changed", "Cor alterada"], ["weight_ok", "Peso correto"], ["volume_ok", "Volume correto"],
];
const DISPOSITIONS: [string, string][] = [
  ["approved_stock", "Aprovado p/ estoque"], ["quarantine", "Quarentena"], ["rework", "Retrabalho"],
  ["quality", "Qualidade"], ["lab", "Laboratório"], ["disposal", "Descarte"], ["supplier", "Fornecedor"],
  ["tech_assistance", "Assistência téc."], ["analysis", "Análise"], ["recycling", "Reciclagem"], ["rejected", "Rejeitado"],
];

// sugere disposição pela conferência
function suggest(chk: Record<string, boolean>): string {
  if (chk.contaminated || chk.expired) return "disposal";
  if (chk.damages || chk.color_changed || chk.odor || chk.humidity) return "quality";
  if (chk.opened || chk.used) return "rework";
  if (chk.received && chk.packaging_ok && chk.seal_ok && chk.qty_ok) return "approved_stock";
  return "analysis";
}

export default function RmaDetail({ rma, items: initial, reasons, products, warehouses }:
  { rma: any; items: any[]; reasons: any[]; products: any[]; warehouses: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [items, setItems] = useState<any[]>(initial);
  const [status, setStatus] = useState<string>(rma.status);
  const [err, setErr] = useState<string | null>(null);
  const [busy, setBusy] = useState<string | null>(null);
  const [add, setAdd] = useState({ product_id: "", reason_id: "", quantity_requested: "1" });
  const prodName = useMemo(() => Object.fromEntries(products.map((p) => [p.id, p])), [products]);

  async function reload() {
    const { data } = await supabase!.from("rma_items").select("*").eq("rma_id", rma.id).is("deleted_at", null).order("created_at");
    setItems(data ?? []);
  }
  async function setRmaStatus(s: string) {
    if (!supabase) return;
    setBusy("status"); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    await supabase.from("rma_requests").update({ status: s, closed_at: s === "closed" ? new Date().toISOString() : null }).eq("id", rma.id);
    await supabase.from("rma_events").insert({ tenant_id: (comp as any)?.tenant_id, company_id: COMPANY, rma_id: rma.id, event_type: "status_change", to_status: s });
    setBusy(null); setStatus(s); router.refresh();
  }
  async function addItem() {
    if (!supabase || !add.product_id) { setErr("Selecione o produto."); return; }
    setBusy("add"); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const p = prodName[add.product_id];
    const { error } = await supabase.from("rma_items").insert({
      tenant_id: (comp as any)?.tenant_id, company_id: COMPANY, rma_id: rma.id, product_id: add.product_id,
      sku: p?.sku ?? null, reason_id: add.reason_id || null, quantity_requested: Number(add.quantity_requested) || 1,
    });
    setBusy(null);
    if (error) { setErr(error.message); return; }
    setAdd({ product_id: "", reason_id: "", quantity_requested: "1" }); reload();
  }

  return (
    <div className="space-y-4 max-w-4xl">
      <div className="flex items-center gap-3">
        <Link href="/devolucoes" className="muted hover:underline text-sm">← Devoluções</Link>
        <h1 className="text-xl font-bold">{rma.code ?? "RMA"}</h1>
        <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${RMA_STATUS[status]?.cls ?? ""}`}>{RMA_STATUS[status]?.label ?? status}</span>
        <div className="ml-auto flex gap-2">
          {(FLOW[status] ?? []).map(([s, l]) => (
            <button key={s} onClick={() => setRmaStatus(s)} disabled={busy === "status"}
              className={`text-sm px-3 py-1.5 rounded-lg font-semibold ${s === "canceled" || s === "rejected" ? "border text-red-500" : "bg-brand-600 text-white hover:bg-brand-700"}`}
              style={s === "canceled" || s === "rejected" ? { borderColor: "var(--border)" } : {}}>{l}</button>
          ))}
        </div>
      </div>

      <div className="card p-4 grid md:grid-cols-4 gap-3 text-sm">
        <div><div className="text-xs muted font-semibold">Canal</div>{rma.channel}</div>
        <div><div className="text-xs muted font-semibold">Nota fiscal</div>{rma.invoice_number ?? "—"}</div>
        <div><div className="text-xs muted font-semibold">Rastreio reverso</div>{rma.reverse_tracking_code ?? "—"}</div>
        <div><div className="text-xs muted font-semibold">Valor</div>{rma.total_value ? Number(rma.total_value).toLocaleString("pt-BR", { style: "currency", currency: "BRL" }) : "—"}</div>
      </div>

      {err && <div className="text-sm text-red-500">{err}</div>}

      <div className="space-y-3">
        <div className="font-semibold">Itens ({items.length})</div>
        {items.map((it) => <ItemCard key={it.id} item={it} prodName={prodName} reasons={reasons} warehouses={warehouses} onDone={reload} />)}
        {items.length === 0 && <p className="text-sm muted">Sem itens. Adicione abaixo.</p>}

        <div className="card p-4 grid md:grid-cols-4 gap-2 items-end">
          <div className="md:col-span-2"><label className="text-xs font-semibold muted">Produto</label>
            <select value={add.product_id} onChange={(e) => setAdd({ ...add, product_id: e.target.value })} className="w-full mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="">— selecione —</option>{products.map((p) => <option key={p.id} value={p.id}>{p.sku ? p.sku + " · " : ""}{p.name}</option>)}
            </select></div>
          <div><label className="text-xs font-semibold muted">Motivo</label>
            <select value={add.reason_id} onChange={(e) => setAdd({ ...add, reason_id: e.target.value })} className="w-full mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="">—</option>{reasons.map((r) => <option key={r.id} value={r.id}>{r.name}</option>)}
            </select></div>
          <div className="flex gap-2 items-end">
            <div className="flex-1"><label className="text-xs font-semibold muted">Qtd</label>
              <input type="number" value={add.quantity_requested} onChange={(e) => setAdd({ ...add, quantity_requested: e.target.value })} className="w-full mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <button onClick={addItem} disabled={busy === "add"} className="px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold disabled:opacity-60">+</button>
          </div>
        </div>
      </div>
    </div>
  );
}

function ItemCard({ item, prodName, reasons, warehouses, onDone }: { item: any; prodName: any; reasons: any[]; warehouses: any[]; onDone: () => void }) {
  const supabase = useMemo(() => createClient(), []);
  const [chk, setChk] = useState<Record<string, boolean>>(item.metadata?.checklist ?? {});
  const [qtyRec, setQtyRec] = useState(String(item.quantity_received || item.quantity_requested));
  const [disp, setDisp] = useState(item.disposition !== "pending" ? item.disposition : "");
  const [wh, setWh] = useState("");
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [showChk, setShowChk] = useState(false);
  const reasonName = reasons.find((r) => r.id === item.reason_id)?.name;

  async function saveInspection() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const suggested = suggest(chk);
    await supabase.from("rma_items").update({ quantity_received: Number(qtyRec) || 0, metadata: { ...(item.metadata || {}), checklist: chk } }).eq("id", item.id);
    await supabase.from("rma_inspections").insert({ tenant_id: (comp as any)?.tenant_id, company_id: COMPANY, rma_item_id: item.id, checklist: chk, verdict: suggested });
    setDisp((d: string) => d || suggested);
    setBusy(false); setMsg(`Conferência salva. Sugestão da IA: ${DISPOSITIONS.find(([v]) => v === suggested)?.[1]}`);
    onDone();
  }
  async function process() {
    if (!supabase || !disp) { setErr("Escolha a disposição."); return; }
    if ((disp === "approved_stock" || disp === "quarantine") && !wh) { setErr("Escolha o armazém para reintegrar."); return; }
    setBusy(true); setErr(null);
    const { error } = await supabase.rpc("process_rma_item", { p_item: item.id, p_disposition: disp, p_warehouse: wh || null, p_quantity: Number(qtyRec) || null });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setMsg(disp === "approved_stock" || disp === "quarantine" ? "Processado ✓ — estoque reintegrado" : "Processado ✓"); onDone();
  }

  return (
    <div className="card p-4 space-y-3">
      <div className="flex items-center gap-2">
        <div className="font-medium">{prodName[item.product_id]?.name ?? "—"}</div>
        <span className="text-xs muted">{reasonName ? "· " + reasonName : ""}</span>
        <span className={`ml-auto text-xs px-2 py-0.5 rounded-md font-semibold ${item.disposition === "pending" ? "bg-slate-500/15 text-slate-400" : item.disposition === "approved_stock" ? "bg-green-500/15 text-green-500" : "bg-amber-500/15 text-amber-500"}`}>
          {DISPOSITIONS.find(([v]) => v === item.disposition)?.[1] ?? item.disposition}
        </span>
      </div>
      <div className="flex flex-wrap gap-3 items-end text-sm">
        <div><label className="text-xs font-semibold muted">Qtd solicitada</label><div className="mt-1">{item.quantity_requested}</div></div>
        <div><label className="text-xs font-semibold muted">Qtd recebida</label>
          <input type="number" value={qtyRec} onChange={(e) => setQtyRec(e.target.value)} className="w-24 mt-1 border rounded-lg px-2 py-1.5 bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
        <button onClick={() => setShowChk((s) => !s)} className="px-3 py-2 rounded-lg border text-sm" style={{ borderColor: "var(--border)" }}>{showChk ? "Ocultar conferência" : "Conferência"}</button>
      </div>

      {showChk && (
        <div className="border rounded-lg p-3" style={{ borderColor: "var(--border)" }}>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-2 text-sm">
            {CHECKS.map(([k, l]) => (
              <label key={k} className="flex items-center gap-2 cursor-pointer">
                <input type="checkbox" checked={!!chk[k]} onChange={(e) => setChk((c) => ({ ...c, [k]: e.target.checked }))} />{l}
              </label>
            ))}
          </div>
          <button onClick={saveInspection} disabled={busy} className="mt-3 px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold disabled:opacity-60">Salvar conferência (IA sugere disposição)</button>
        </div>
      )}

      <div className="flex flex-wrap gap-2 items-end border-t pt-3" style={{ borderColor: "var(--border)" }}>
        <div><label className="text-xs font-semibold muted">Disposição</label>
          <select value={disp} onChange={(e) => setDisp(e.target.value)} className="mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
            <option value="">—</option>{DISPOSITIONS.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
          </select></div>
        {(disp === "approved_stock" || disp === "quarantine") && (
          <div><label className="text-xs font-semibold muted">Armazém (reintegrar)</label>
            <select value={wh} onChange={(e) => setWh(e.target.value)} className="mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="">—</option>{warehouses.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
            </select></div>
        )}
        <button onClick={process} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold disabled:opacity-60">Processar item</button>
      </div>
      {msg && <div className="text-sm text-green-500">{msg}</div>}
      {err && <div className="text-sm text-red-500">{err}</div>}
    </div>
  );
}
