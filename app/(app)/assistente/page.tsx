"use client";
import { useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const kpi = (d: any, label: string) => (d?.kpis ?? []).find((k: any) => k.label === label)?.valor;

type Pergunta = { icon: string; label: string; run: (sb: any) => Promise<string> };

const PERGUNTAS: Pergunta[] = [
  {
    icon: "📊", label: "Como está o negócio? (30 dias)",
    run: async (sb) => {
      const { data } = await sb.rpc("rel_consolidado", { p_company: COMPANY, p_days: 30 });
      if (!data) return "Não consegui consultar agora.";
      return `Nos últimos 30 dias: **${money(kpi(data, "Receita"))}** de receita em **${kpi(data, "Pedidos")}** pedidos (ticket ${money(kpi(data, "Ticket médio"))}). A processar: ${kpi(data, "A processar")} · Sem plano: ${kpi(data, "Sem plano")} · Bloqueados: ${kpi(data, "Bloqueados")}. Comissão a repassar: ${money(kpi(data, "Comissão a repassar"))}.`;
    },
  },
  {
    icon: "🗓", label: "Quanto vendi nos últimos 7 dias?",
    run: async (sb) => {
      const { data } = await sb.rpc("rel_vendas", { p_company: COMPANY, p_days: 7 });
      if (!data) return "Não consegui consultar agora.";
      return `Últimos 7 dias: **${money(kpi(data, "Receita"))}** em **${kpi(data, "Pedidos")}** pedidos, ticket médio ${money(kpi(data, "Ticket médio"))}. Entregues: ${kpi(data, "Entregues")} · Cancelados: ${kpi(data, "Cancelados")}.`;
    },
  },
  {
    icon: "🚨", label: "O que está travado agora?",
    run: async (sb) => {
      const { data } = await sb.rpc("alertas_resumo", { p_company: COMPANY });
      const itens = (data?.itens ?? []).filter((i: any) => i.n > 0);
      if (!itens.length) return "✅ Nada travado no momento — tudo em ordem!";
      return "Precisam de atenção:\n" + itens.map((i: any) => `• ${i.label}: **${i.n}**`).join("\n");
    },
  },
  {
    icon: "📈", label: "Qual meu lucro? (30 dias)",
    run: async (sb) => {
      const { data } = await sb.rpc("rel_lucro", { p_company: COMPANY, p_days: 30 });
      if (!data) return "Não consegui consultar agora.";
      return `Resultado (30d): receita ${money(kpi(data, "Receita"))} → **${money(kpi(data, "= Resultado"))}** de resultado, margem ${kpi(data, "Margem")}%. (Cadastre custos em Custos & Despesas para maior precisão.)`;
    },
  },
  {
    icon: "🏭", label: "Tem lote vencendo?",
    run: async (sb) => {
      const { data } = await sb.rpc("rel_producao", { p_company: COMPANY, p_days: 0 });
      if (!data) return "Não consegui consultar agora.";
      const venc = kpi(data, "Vencidos"), v30 = kpi(data, "Vencem em 30 dias");
      if (!venc && !v30) return "Nenhum lote vencido ou vencendo em 30 dias. 👍";
      return `⚠️ **${venc}** lote(s) vencido(s) e **${v30}** vencendo em 30 dias. Veja o painel de Produção & Validade.`;
    },
  },
  {
    icon: "🤝", label: "Quanto tenho de comissão a repassar?",
    run: async (sb) => {
      const { data } = await sb.rpc("rel_coproducao", { p_company: COMPANY, p_days: 3650 });
      if (!data) return "Não consegui consultar agora.";
      return `Comissão pendente de repasse: **${money(kpi(data, "A repassar (pendente)"))}** (total apurado ${money(kpi(data, "Comissão total"))}).`;
    },
  },
  {
    icon: "🎧", label: "Como está o atendimento?",
    run: async (sb) => {
      const { data } = await sb.rpc("rel_atendimento", { p_company: COMPANY, p_days: 30 });
      if (!data) return "Não consegui consultar agora.";
      return `SAC (30d): **${kpi(data, "Em aberto")}** chamado(s) em aberto, ${kpi(data, "Urgentes")} urgente(s), ${kpi(data, "Resolvidos")} resolvido(s).`;
    },
  },
];

function render(md: string) {
  const parts = md.split(/(\*\*[^*]+\*\*)/g);
  return parts.map((p, i) => p.startsWith("**") ? <b key={i}>{p.slice(2, -2)}</b> : <span key={i}>{p}</span>);
}

export default function AssistentePage() {
  const supabase = useMemo(() => createClient(), []);
  const [chat, setChat] = useState<{ q: string; a: string }[]>([]);
  const [busy, setBusy] = useState<string>("");
  const [q, setQ] = useState("");
  const [busyFree, setBusyFree] = useState(false);

  async function ask(p: Pergunta) {
    if (!supabase) return;
    setBusy(p.label);
    let a = "Não consegui consultar agora.";
    try { a = await p.run(supabase); } catch (e: any) { a = "Erro: " + (e?.message ?? "falha"); }
    setChat((c) => [{ q: p.label, a }, ...c]);
    setBusy("");
  }

  // Pergunta em texto livre → IA (rota /api/ia/perguntar, com os dados reais como contexto).
  async function askFree(e?: React.FormEvent) {
    e?.preventDefault();
    const pergunta = q.trim();
    if (!pergunta || busyFree) return;
    setBusyFree(true); setQ("");
    let a = "Não consegui responder agora.";
    try {
      const res = await fetch("/api/ia/perguntar", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ question: pergunta }) });
      const j = await res.json();
      a = j.answer ?? j.error ?? a;
    } catch (err: any) { a = "Erro de rede: " + (err?.message ?? "falha"); }
    setChat((c) => [{ q: pergunta, a }, ...c]);
    setBusyFree(false);
  }

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>INTELIGÊNCIA · ASSISTENTE OPERACIONAL</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Assistente</h1>
        <p className="text-sm muted mt-0.5">Pergunte com um clique — o assistente consulta seus dados na hora e responde.</p>
      </div>

      {/* Pergunta em texto livre (IA) */}
      <form onSubmit={askFree} className="card p-4">
        <div className="font-bold text-sm mb-2">💬 Pergunte o que quiser</div>
        <div className="flex gap-2">
          <input value={q} onChange={(e) => setQ(e.target.value)} disabled={busyFree}
            placeholder="ex.: qual produto mais vendeu essa semana? tem algo travando meu envio?"
            className="input flex-1 text-sm" />
          <button type="submit" disabled={busyFree || !q.trim()} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-50 whitespace-nowrap">
            {busyFree ? "Pensando…" : "Perguntar"}
          </button>
        </div>
        <p className="text-[11px] muted mt-1.5">A IA responde com base nos seus dados reais. Precisa da chave da Anthropic configurada (server).</p>
      </form>

      <div className="card p-4">
        <div className="font-bold text-sm mb-2">Perguntas rápidas</div>
        <div className="flex flex-wrap gap-2">
          {PERGUNTAS.map((p) => (
            <button key={p.label} onClick={() => ask(p)} disabled={!!busy}
              className="px-3 py-2 rounded-lg border text-sm font-medium hover:bg-black/5 dark:hover:bg-white/5 disabled:opacity-50" style={{ borderColor: "var(--border)" }}>
              {p.icon} {p.label}{busy === p.label ? " …" : ""}
            </button>
          ))}
        </div>
      </div>

      {chat.length === 0 ? (
        <div className="card p-6 text-center muted text-sm">Clique em uma pergunta acima para começar.</div>
      ) : (
        <div className="space-y-3">
          {chat.map((c, i) => (
            <div key={i} className="space-y-1.5">
              <div className="flex justify-end"><div className="px-3 py-2 rounded-2xl rounded-br-sm bg-brand-600 text-white text-sm max-w-[80%]">{c.q}</div></div>
              <div className="flex justify-start"><div className="px-3 py-2 rounded-2xl rounded-bl-sm card text-sm max-w-[85%] whitespace-pre-line">{render(c.a)}</div></div>
            </div>
          ))}
        </div>
      )}
      <p className="text-xs muted">💡 As respostas vêm dos seus dados reais (via RPC seguro). As perguntas em texto livre usam IA (Claude) no servidor — sua chave nunca sai do backend.</p>
    </div>
  );
}
