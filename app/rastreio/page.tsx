"use client";
import { useState, useMemo } from "react";
import { createClient } from "@/lib/supabase/client";

const STATUS_LABEL: Record<string, string> = {
  draft: "Criado", planned: "Planejado", dispatched: "Despachado", in_transit: "Em trânsito", out_for_delivery: "Saiu para entrega",
  delivered: "Entregue", returned: "Devolvido", canceled: "Cancelado", posted: "Postado", accepted: "Aceito", awaiting_pickup: "Aguardando retirada",
};
const EVENT_LABEL: Record<string, string> = {
  created: "Objeto criado", picked_up: "Coletado", in_transit: "Em trânsito", out_for_delivery: "Saiu para entrega",
  delivered: "Entregue", delivery_failed: "Tentativa de entrega", returned: "Devolvido", exception: "Ocorrência", posted: "Postado",
};

export default function RastreioPage() {
  const supabase = useMemo(() => createClient(), []);
  const [code, setCode] = useState("");
  const [res, setRes] = useState<any>(null);
  const [busy, setBusy] = useState(false);
  const [searched, setSearched] = useState(false);

  async function track() {
    if (!supabase || !code.trim()) return;
    setBusy(true); setSearched(true);
    const { data } = await supabase.rpc("public_track", { p_code: code.trim() });
    setRes(data); setBusy(false);
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

        {searched && !busy && res && !res.found && (
          <div className="card p-6 mt-4 text-center muted">Nenhum objeto encontrado com esse código. Confira e tente novamente.</div>
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

        <div className="text-center text-xs muted mt-6">Powered by Cargyon</div>
      </div>
    </div>
  );
}
