"use client";
import { useState, useMemo } from "react";
import { createClient } from "@/lib/supabase/client";

const STATUS_LABEL: Record<string, string> = {
  draft: "Criado", planned: "Planejado", dispatched: "Despachado", in_transit: "Em trânsito", out_for_delivery: "Saiu para entrega",
  delivered: "Entregue", returned: "Devolvido", canceled: "Cancelado", posted: "Postado", accepted: "Aceito", awaiting_pickup: "Aguardando retirada",
  // status público de pedidos de loja (rastreio_publico já normaliza os estados internos)
  processando: "Em preparação", postado: "Postado", em_transito: "Em trânsito", saiu_entrega: "Saiu para entrega",
  entregue: "Entregue", cancelado: "Cancelado", devolvido: "Devolvido",
};
const EVENT_LABEL: Record<string, string> = {
  created: "Objeto criado", picked_up: "Coletado", in_transit: "Em trânsito", out_for_delivery: "Saiu para entrega",
  delivered: "Entregue", delivery_failed: "Tentativa de entrega", returned: "Devolvido", exception: "Ocorrência", posted: "Postado",
};

export default function RastreioPage() {
  const supabase = useMemo(() => createClient(), []);
  const [code, setCode] = useState("");
  const [res, setRes] = useState<any>(null);
  const [res2, setRes2] = useState<any>(null);
  const [busy, setBusy] = useState(false);
  const [searched, setSearched] = useState(false);
  const [err, setErr] = useState(false);

  async function track() {
    if (!supabase || !code.trim()) return;
    setBusy(true); setSearched(true); setRes2(null); setErr(false);
    const { data, error } = await supabase.rpc("public_track", { p_code: code.trim() });
    setRes(data);
    // Fallback: pedidos de loja (store_orders) rastreados pelo código dos Correios
    let d2: any = null, err2: any = null;
    if (!data || !(data as any).found) {
      const r2 = await supabase.rpc("rastreio_publico", { p_codigo: code.trim() });
      d2 = r2.data; err2 = r2.error;
      setRes2(d2);
    }
    setErr((!!error && data == null) && (!!err2 && d2 == null)); // só é erro se as duas falharam
    setBusy(false);
  }
  const events = (res?.events ?? []) as any[];
  const delivered = res?.status === "delivered";

  return (
    <div className="min-h-screen" style={{ background: "var(--bg)" }}>
      <div className="max-w-2xl mx-auto p-6">
        <div className="flex items-center gap-2 mb-6">
          <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center font-bold text-lg">L</div>
          <div><div className="font-bold">Rastreamento</div><div className="text-xs muted">Acompanhe seu pedido</div></div>
        </div>

        <div className="card p-4 flex gap-2">
          <input value={code} onChange={(e) => setCode(e.target.value)} onKeyDown={(e) => e.key === "Enter" && track()}
            placeholder="Digite o código de rastreio (ex.: BR123...)"
            className="flex-1 border rounded-lg px-3 py-2.5 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
          <button onClick={track} disabled={busy} className="px-5 py-2.5 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Buscando…" : "Rastrear"}</button>
        </div>

        {searched && !busy && err && (
          <div className="card p-6 mt-4 text-center" style={{ color: "var(--danger)" }}>Falha ao consultar o rastreio. Tente novamente em instantes.</div>
        )}
        {searched && !busy && !err && (!res || !res.found) && (!res2 || !res2.found) && (
          <div className="card p-6 mt-4 text-center muted">Nenhum objeto encontrado com esse código. Confira e tente novamente.</div>
        )}

        {/* Pedido de loja rastreado pelos Correios (rastreio_publico) */}
        {res2?.found && (
          <div className="card p-5 mt-4">
            <div className="flex items-center justify-between flex-wrap gap-2">
              <div>
                <div className="text-xs uppercase muted font-semibold">Status atual</div>
                <div className={`text-xl font-bold ${res2.status === "entregue" ? "text-green-500" : "text-brand-500"}`}>{STATUS_LABEL[res2.status] ?? res2.status}</div>
              </div>
              <div className="text-right text-sm">
                {res2.destino && <div>{res2.destino}</div>}
                <div className="muted text-xs font-mono">{res2.codigo}</div>
              </div>
            </div>
            {res2.produto && <div className="mt-3 text-sm"><span className="muted">Produto:</span> {res2.produto}</div>}
            {res2.cliente && <div className="text-sm"><span className="muted">Destinatário:</span> {res2.cliente}</div>}
            <div className="mt-3 text-xs muted">
              Postado em {res2.criado_em ? new Date(res2.criado_em).toLocaleDateString("pt-BR") : "—"} · atualizado {res2.atualizado_em ? new Date(res2.atualizado_em).toLocaleString("pt-BR") : "—"}
            </div>
          </div>
        )}

        {res?.found && (
          <div className="card p-5 mt-4">
            <div className="flex items-center justify-between flex-wrap gap-2">
              <div>
                <div className="text-xs uppercase muted font-semibold">Status atual</div>
                <div className={`text-xl font-bold ${delivered ? "text-green-500" : "text-brand-500"}`}>{STATUS_LABEL[res.status] ?? res.status}</div>
              </div>
              <div className="text-right text-sm">
                {res.city && <div>{res.city}{res.uf ? "/" + res.uf : ""}</div>}
                {!delivered && res.eta && <div className="muted text-xs">Previsão: {new Date(res.eta + "T00:00:00").toLocaleDateString("pt-BR")}</div>}
                {delivered && res.delivered_at && <div className="muted text-xs">Entregue em {new Date(res.delivered_at).toLocaleString("pt-BR")}</div>}
              </div>
            </div>

            <div className="mt-5 space-y-0">
              {events.length === 0 && <div className="text-sm muted">Ainda sem movimentações registradas.</div>}
              {events.slice().reverse().map((e, i) => (
                <div key={i} className="flex gap-3">
                  <div className="flex flex-col items-center">
                    <div className={`h-3 w-3 rounded-full ${i === 0 ? "bg-brand-600" : "bg-black/20 dark:bg-white/20"}`} />
                    {i < events.length - 1 && <div className="w-px flex-1 bg-black/10 dark:bg-white/10" />}
                  </div>
                  <div className="pb-4">
                    <div className="text-sm font-medium">{EVENT_LABEL[e.type] ?? e.description ?? e.type}</div>
                    {e.location && <div className="text-xs muted">{e.location}</div>}
                    <div className="text-xs muted">{new Date(e.at).toLocaleString("pt-BR")}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        <div className="text-center text-xs muted mt-6">Powered by GLOP</div>
      </div>
    </div>
  );
}
