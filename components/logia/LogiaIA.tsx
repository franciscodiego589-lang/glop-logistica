"use client";
import { useState } from "react";

type Insight = { titulo: string; gravidade: "alta" | "media" | "baixa"; achado: string; acao: string };
const TONE: Record<string, { bg: string; label: string }> = {
  alta: { bg: "var(--danger)", label: "ALTA" },
  media: { bg: "var(--warning)", label: "MÉDIA" },
  baixa: { bg: "var(--brand)", label: "BAIXA" },
};

export default function LogiaIA() {
  const [busy, setBusy] = useState(false);
  const [insights, setInsights] = useState<Insight[] | null>(null);
  const [msg, setMsg] = useState<string>("");

  async function gerar() {
    setBusy(true); setMsg("");
    try {
      const res = await fetch("/api/ia/insights", { method: "POST" });
      const j = await res.json();
      if (j.configured === false) { setMsg(j.message ?? "IA não configurada."); setInsights([]); }
      else if (j.error) { setMsg("Erro: " + j.error); }
      else { setInsights(j.insights ?? []); if (!(j.insights ?? []).length) setMsg("A IA não encontrou pontos relevantes agora."); }
    } catch (e: any) { setMsg("Erro de rede: " + (e?.message ?? "falha")); }
    setBusy(false);
  }

  return (
    <div className="card p-4">
      <div className="flex items-center justify-between flex-wrap gap-2">
        <div className="font-bold text-sm">🧠 Insights com IA (Claude)</div>
        <button onClick={gerar} disabled={busy} className="px-3 py-1.5 rounded-lg bg-brand-600 text-white text-xs font-semibold disabled:opacity-50">
          {busy ? "Analisando…" : insights ? "Gerar de novo" : "Gerar insights com IA"}
        </button>
      </div>
      {msg && <p className="text-xs muted mt-2">{msg}</p>}
      {insights && insights.length > 0 && (
        <div className="space-y-2 mt-3">
          {insights.map((i, k) => {
            const t = TONE[i.gravidade] ?? TONE.baixa;
            return (
              <div key={k} className="rounded-lg p-3" style={{ background: "var(--surface-2)", borderLeft: `3px solid ${t.bg}` }}>
                <div className="flex items-center gap-2">
                  <span className="text-[10px] font-bold px-1.5 py-0.5 rounded text-white" style={{ background: t.bg }}>{t.label}</span>
                  <span className="font-semibold text-sm">{i.titulo}</span>
                </div>
                {i.achado && <p className="text-xs muted mt-1">{i.achado}</p>}
                {i.acao && <p className="text-xs mt-1">👉 <b>Fazer:</b> {i.acao}</p>}
              </div>
            );
          })}
        </div>
      )}
      {!insights && !busy && <p className="text-[11px] muted mt-2">Clique para a IA ler seus dados (vendas, anomalias, validade, regiões, ABC, coprodução) e sugerir ações priorizadas. Requer a chave da Anthropic no servidor.</p>}
    </div>
  );
}
