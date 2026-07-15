"use client";
import { useMemo, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

const TABS = ["Assistente", "Painel", "Provedores", "Modelos", "Prompts", "Ferramentas", "Uso & Custos"] as const;
type Tab = typeof TABS[number];

export default function EAAFWorkbench({ dash, providers, models, prompts, tools, usage }: {
  dash: any; providers: any[]; models: any[]; prompts: any[]; tools: any[]; usage: any[];
}) {
  const [tab, setTab] = useState<Tab>("Assistente");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Plataforma · Inteligência & Automação (opcional)</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">IA & Automação (EAAF)</h1>
        <p className="text-sm muted mt-0.5">Camada de IA <strong>desacoplada e multi-provedor</strong>. O ERP funciona 100% sem IA — o assistente responde direto dos dados; pluge qualquer provedor quando quiser.</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Assistente" && <Assistente />}
      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Provedores" && <Provedores providers={providers} />}
      {tab === "Modelos" && <Modelos models={models} providers={providers} />}
      {tab === "Prompts" && (
        <CrudPanel table="ai_prompts" title="Biblioteca de Prompts"
          fields={[
            { key: "prompt_key", label: "Chave", required: true },
            { key: "name", label: "Nome", required: true },
            { key: "category", label: "Categoria" },
            { key: "template", label: "Template", placeholder: "Use {{variavel}}" },
          ]}
          columns={[{ key: "name", label: "Prompt" }, { key: "prompt_key", label: "Chave" }, { key: "category", label: "Categoria" }]}
          rows={prompts} emptyHint="Templates versionados, independentes de provedor." />
      )}
      {tab === "Ferramentas" && <Ferramentas tools={tools} />}
      {tab === "Uso & Custos" && <Uso usage={usage} />}
    </div>
  );
}

function Assistente() {
  const supabase = useMemo(() => createClient(), []);
  const [msgs, setMsgs] = useState<{ role: string; text: string }[]>([
    { role: "assistant", text: "Olá! Sou o assistente do ERP. Pergunte sobre receita, resultado, pipeline, estoque, headcount, folha, pedidos, tributos ou seus maiores problemas — respondo direto dos seus dados, sem custo." },
  ]);
  const [q, setQ] = useState("");
  const [busy, setBusy] = useState(false);
  const [conv, setConv] = useState<string | null>(null);
  const endRef = useRef<HTMLDivElement>(null);
  const suggestions = ["Qual a minha receita?", "Quais meus maiores problemas?", "Quantos funcionários eu tenho?", "Qual o valor em estoque?"];

  async function ask(text: string) {
    if (!supabase || !text.trim() || busy) return;
    setMsgs((m) => [...m, { role: "user", text }]); setQ(""); setBusy(true);
    const { data } = await supabase.rpc("ai_ask", { p_company: COMPANY, p_question: text, p_conversation: conv });
    setBusy(false);
    if (data?.conversation_id) setConv(data.conversation_id);
    setMsgs((m) => [...m, { role: "assistant", text: data?.answer ?? "Não consegui responder agora." }]);
    setTimeout(() => endRef.current?.scrollIntoView({ behavior: "smooth" }), 50);
  }
  return (
    <div className="card p-0 flex flex-col" style={{ height: "60vh" }}>
      <div className="flex-1 overflow-y-auto p-4 space-y-3">
        {msgs.map((m, i) => (
          <div key={i} className={`flex ${m.role === "user" ? "justify-end" : ""}`}>
            <div className="rounded-2xl px-4 py-2.5 max-w-[80%] text-sm" style={m.role === "user" ? { background: "linear-gradient(150deg,#2f56e6,#1a336f)", color: "#fff" } : { background: "var(--surface-3)" }}>
              {m.role === "assistant" && <span className="text-brand-600 mr-1">✦</span>}{m.text}
            </div>
          </div>
        ))}
        {busy && <div className="text-sm muted px-2">✦ consultando os dados…</div>}
        <div ref={endRef} />
      </div>
      <div className="p-3 border-t" style={{ borderColor: "var(--border)" }}>
        <div className="flex gap-1.5 flex-wrap mb-2">{suggestions.map((s) => <button key={s} onClick={() => ask(s)} className="text-xs px-2.5 py-1 rounded-full surface-2" style={{ border: "1px solid var(--border)" }}>{s}</button>)}</div>
        <div className="flex gap-2">
          <input value={q} onChange={(e) => setQ(e.target.value)} onKeyDown={(e) => e.key === "Enter" && ask(q)} className="input" placeholder="Pergunte sobre o seu ERP…" />
          <button onClick={() => ask(q)} disabled={busy || !q.trim()} className="btn btn-primary">Enviar</button>
        </div>
      </div>
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
      <KPI label="Provedores" value={`${d.providers_enabled ?? 0}/${d.providers ?? 0}`} hint={`padrão: ${d.default_provider ?? "—"}`} />
      <KPI label="Modelos" value={String(d.models ?? 0)} />
      <KPI label="Agentes" value={String(d.agents ?? 0)} hint="LAIOS" />
      <KPI label="Ferramentas" value={String(d.tools ?? 0)} />
      <KPI label="Automações" value={String(d.automations ?? 0)} />
      <KPI label="Chamadas (30d)" value={String(d.calls_30d ?? 0)} />
      <KPI label="Tokens (30d)" value={String(d.tokens_30d ?? 0)} />
      <KPI label="Custo (30d)" value={`US$ ${Number(d.cost_30d ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2 })}`} tone={Number(d.cost_30d) > 0 ? "var(--warning)" : "var(--success)"} />
    </div>
  );
}

function Provedores({ providers }: { providers: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  async function toggle(id: string, on: boolean) { if (!supabase) return; await supabase.from("ai_providers").update({ enabled: !on }).eq("id", id); router.refresh(); }
  async function setDefault(id: string) { if (!supabase) return; await supabase.rpc("set_default_provider", { p_provider: id }); router.refresh(); }
  return (
    <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
      {providers.map((p) => (
        <div key={p.id} className="card p-4">
          <div className="flex items-center gap-2">
            <span className="dot" style={{ background: p.enabled ? "var(--success)" : "var(--muted)" }} />
            <div className="font-semibold text-sm flex-1">{p.name}</div>
            {p.is_default && <span className="badge badge-brand">padrão</span>}
          </div>
          <div className="text-xs muted mt-1">{p.notes}</div>
          <div className="flex gap-2 mt-3">
            <button onClick={() => toggle(p.id, p.enabled)} className="btn btn-sm flex-1">{p.enabled ? "Desativar" : "Ativar"}</button>
            {!p.is_default && <button onClick={() => setDefault(p.id)} className="btn btn-primary btn-sm flex-1">Tornar padrão</button>}
          </div>
        </div>
      ))}
    </div>
  );
}

function Modelos({ models, providers }: { models: any[]; providers: any[] }) {
  const provName = (id: string) => providers.find((p) => p.id === id)?.name ?? "—";
  return (
    <div className="card p-0 overflow-x-auto">
      <table className="tbl">
        <thead><tr><th>Modelo</th><th>Provedor</th><th>Tipo</th><th className="text-right">Contexto</th><th className="text-right">Custo in/out (1k)</th></tr></thead>
        <tbody>{models.map((m) => (
          <tr key={m.id}><td className="font-medium">{m.name} <code className="text-[11px] muted">{m.model_key}</code></td><td className="text-xs muted">{provName(m.provider_id)}</td><td><span className="badge badge-neutral">{m.model_type}</span></td><td className="text-right tabular-nums">{m.context_window ? (m.context_window / 1000) + "k" : "—"}</td><td className="text-right tabular-nums text-xs">US$ {Number(m.cost_in).toFixed(4)} / {Number(m.cost_out).toFixed(4)}</td></tr>
        ))}</tbody>
      </table>
    </div>
  );
}

function Ferramentas({ tools }: { tools: any[] }) {
  return (
    <div className="grid md:grid-cols-2 gap-3">
      {tools.map((t) => (
        <div key={t.id} className="card p-4">
          <div className="flex items-center gap-2">
            <div className="font-semibold text-sm flex-1">{t.name}</div>
            {t.requires_approval && <span className="badge badge-warning">requer aprovação</span>}
            <span className="badge badge-neutral">{t.module}</span>
          </div>
          <div className="text-xs muted mt-1">Chama <code>{t.target_rpc}</code></div>
        </div>
      ))}
      {tools.length === 0 && <p className="text-sm muted">Nenhuma ferramenta registrada.</p>}
    </div>
  );
}

function Uso({ usage }: { usage: any[] }) {
  if (usage.length === 0) return <p className="text-sm muted px-1">Sem uso registrado ainda.</p>;
  return (
    <div className="card p-0 overflow-x-auto">
      <table className="tbl">
        <thead><tr><th>Quando</th><th>Provedor</th><th>Modelo</th><th>Feature</th><th className="text-right">Tokens</th><th className="text-right">Custo</th><th className="text-right">Latência</th></tr></thead>
        <tbody>{usage.map((u) => (
          <tr key={u.id}><td className="text-xs tabular-nums">{new Date(u.created_at).toLocaleString("pt-BR")}</td><td>{u.provider}</td><td className="text-xs muted">{u.model}</td><td className="text-xs">{u.feature}</td><td className="text-right tabular-nums">{(u.tokens_in ?? 0) + (u.tokens_out ?? 0)}</td><td className="text-right tabular-nums">US$ {Number(u.cost).toFixed(4)}</td><td className="text-right tabular-nums">{u.latency_ms ?? "—"}ms</td></tr>
        ))}</tbody>
      </table>
    </div>
  );
}
