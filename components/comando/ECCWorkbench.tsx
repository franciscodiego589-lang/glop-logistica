"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const brl = (n: number) => "R$ " + (n ?? 0).toLocaleString("pt-BR", { maximumFractionDigits: 0 });
const sevColor = (s: string) => ({ critical: "var(--danger)", high: "var(--warning)", medium: "var(--brand)", low: "var(--muted)", info: "var(--muted)", warning: "var(--warning)" } as any)[s] ?? "var(--muted)";
const sevBadge = (s: string) => ({ critical: "badge-danger", high: "badge-warning", medium: "badge-brand", low: "badge-neutral", info: "badge-neutral", warning: "badge-warning" } as any)[s] ?? "badge-neutral";

const TABS = ["Mission Control", "Central de Alertas", "Sala de Crise"] as const;
type Tab = typeof TABS[number];

export default function ECCWorkbench({ overview, dash, alerts, crises, updates }: {
  overview: any; dash: any; alerts: any[]; crises: any[]; updates: any[];
}) {
  const [tab, setTab] = useState<Tab>("Mission Control");
  const router = useRouter();
  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <div className="text-xs muted font-semibold uppercase tracking-wider">Enterprise+ · Torre de Controle</div>
          <h1 className="text-2xl font-extrabold tracking-tight mt-0.5 flex items-center gap-2"><span style={{ color: "var(--danger)" }}>◉</span> Enterprise Command Center</h1>
          <p className="text-sm muted mt-0.5">Monitoramento em tempo real de toda a operação · atualizado {overview?.as_of ? new Date(overview.as_of).toLocaleTimeString("pt-BR") : "—"}</p>
        </div>
        <button onClick={() => router.refresh()} className="btn btn-sm">↻ Atualizar</button>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Mission Control" && <MissionControl overview={overview} />}
      {tab === "Central de Alertas" && <Alertas alerts={alerts} />}
      {tab === "Sala de Crise" && <Crise crises={crises} updates={updates} />}
    </div>
  );
}

function MissionControl({ overview }: { overview: any }) {
  const o = overview?.ops ?? {}; const a = overview?.alerts ?? {}; const k = overview?.kpis ?? {}; const feed: any[] = overview?.feed ?? [];
  const Tile = ({ label, value, tone }: { label: string; value: any; tone?: string }) => (
    <div className="rounded-xl p-3 text-center" style={{ background: "var(--surface-2)", border: "1px solid var(--border)" }}>
      <div className="text-2xl font-bold tabular-nums" style={{ color: tone }}>{value}</div>
      <div className="text-[11px] muted font-semibold uppercase mt-0.5">{label}</div>
    </div>
  );
  return (
    <div className="space-y-4">
      {/* faixa de alertas */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
        <div className="card p-4 text-center" style={{ borderColor: a.critical ? "var(--danger)" : "var(--border)" }}>
          <div className="text-3xl font-black tabular-nums" style={{ color: "var(--danger)" }}>{a.critical ?? 0}</div><div className="text-xs muted font-semibold uppercase">Críticos</div>
        </div>
        <div className="card p-4 text-center"><div className="text-3xl font-black tabular-nums" style={{ color: "var(--warning)" }}>{a.high ?? 0}</div><div className="text-xs muted font-semibold uppercase">Altos</div></div>
        <div className="card p-4 text-center"><div className="text-3xl font-black tabular-nums">{a.open_total ?? 0}</div><div className="text-xs muted font-semibold uppercase">Alertas abertos</div></div>
        <div className="card p-4 text-center" style={{ borderColor: a.crises ? "var(--danger)" : "var(--border)" }}><div className="text-3xl font-black tabular-nums" style={{ color: a.crises ? "var(--danger)" : undefined }}>{a.crises ?? 0}</div><div className="text-xs muted font-semibold uppercase">Crises ativas</div></div>
        <div className="card p-4 text-center"><div className="text-3xl font-black tabular-nums" style={{ color: "var(--danger)" }}>{o.sec_incidents ?? 0}</div><div className="text-xs muted font-semibold uppercase">Incid. segurança</div></div>
      </div>

      <div className="grid lg:grid-cols-3 gap-4">
        {/* operação em tempo real */}
        <div className="card p-4 lg:col-span-2">
          <div className="font-semibold mb-3">Operação em tempo real</div>
          <div className="grid grid-cols-3 md:grid-cols-4 gap-2">
            <Tile label="Pedidos abertos" value={o.orders_open ?? 0} />
            <Tile label="Aguard. produção" value={o.awaiting_production ?? 0} tone={o.awaiting_production ? "var(--warning)" : undefined} />
            <Tile label="Expedidos hoje" value={o.shipped_today ?? 0} tone="var(--success)" />
            <Tile label="Faturados hoje" value={o.invoiced_today ?? 0} tone="var(--success)" />
            <Tile label="Aprovações pend." value={o.tasks_pending ?? 0} />
            <Tile label="Chamados abertos" value={o.tickets_open ?? 0} />
            <Tile label="Fila DLQ" value={o.dlq ?? 0} tone={o.dlq ? "var(--danger)" : undefined} />
            <Tile label="SKUs zerados" value={o.low_stock ?? 0} tone={o.low_stock ? "var(--warning)" : undefined} />
          </div>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-2 mt-3">
            <Tile label="Receita 12m" value={brl(Number(k.revenue_12m ?? 0))} tone="var(--brand)" />
            <Tile label="Resultado mês" value={brl(Number(k.net_income ?? 0))} tone={Number(k.net_income) >= 0 ? "var(--success)" : "var(--danger)"} />
            <Tile label="Pipeline" value={brl(Number(k.pipeline ?? 0))} />
            <Tile label="Estoque" value={brl(Number(k.stock_value ?? 0))} />
            <Tile label="Headcount" value={k.headcount ?? 0} />
            <Tile label="Tributos a recolher" value={brl(Number(k.tax_payable ?? 0))} tone={Number(k.tax_payable) > 0 ? "var(--warning)" : undefined} />
          </div>
        </div>

        {/* feed vivo */}
        <div className="card p-4">
          <div className="font-semibold mb-3 flex items-center gap-2"><span className="dot" style={{ background: "var(--success)" }} /> Feed ao vivo</div>
          <div className="space-y-2 max-h-96 overflow-y-auto">
            {feed.length === 0 ? <p className="text-sm muted">Sem eventos recentes.</p> : feed.map((f, i) => (
              <div key={i} className="flex items-start gap-2 text-sm">
                <span className="mt-1.5 dot shrink-0" style={{ background: sevColor(f.severity) }} />
                <div className="min-w-0"><div className="truncate">{f.title}</div><div className="text-[10px] muted">{f.kind} · {new Date(f.at).toLocaleString("pt-BR")}</div></div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function Alertas({ alerts }: { alerts: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  async function sync() { if (!supabase) return; setBusy("sync"); await supabase.rpc("sync_command_alerts", { p_company: COMPANY }); setBusy(null); router.refresh(); }
  async function act(id: string, resolve: boolean) { if (!supabase) return; setBusy(id); await supabase.rpc("ack_alert", { p_alert: id, p_resolve: resolve }); setBusy(null); router.refresh(); }
  const open = alerts.filter((a) => a.status !== "resolved").sort((a, b) => ({ critical: 0, high: 1, medium: 2, low: 3 } as any)[a.severity] - ({ critical: 0, high: 1, medium: 2, low: 3 } as any)[b.severity]);
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Central de Alertas <span className="badge badge-neutral ml-1">{open.length}</span></div>
        <button onClick={sync} disabled={busy === "sync"} className="btn btn-primary btn-sm">{busy === "sync" ? "Sincronizando…" : "↻ Sincronizar (IA + segurança)"}</button>
      </div>
      {open.length === 0 ? <p className="text-sm muted px-1">🎉 Nenhum alerta aberto.</p> : open.map((a) => (
        <div key={a.id} className="card p-4 flex items-start gap-3" style={{ borderLeft: `3px solid ${sevColor(a.severity)}` }}>
          <div className="flex-1">
            <div className="flex items-center gap-2 flex-wrap">
              <span className={`badge ${sevBadge(a.severity)}`}>{a.severity}</span>
              <span className="text-xs muted">{a.source_module}</span>
              {a.status === "acknowledged" && <span className="badge badge-neutral">reconhecido</span>}
              <span className="font-semibold text-sm">{a.title}</span>
            </div>
            {a.impact && <div className="text-xs muted mt-1">{a.impact}</div>}
            {a.recommendation && <div className="text-xs mt-0.5">→ {a.recommendation}</div>}
          </div>
          <div className="flex flex-col gap-1.5">
            {a.status === "open" && <button onClick={() => act(a.id, false)} disabled={busy === a.id} className="btn btn-sm">Reconhecer</button>}
            <button onClick={() => act(a.id, true)} disabled={busy === a.id} className="btn btn-sm" style={{ background: "var(--success)", color: "#fff", borderColor: "transparent" }}>Resolver</button>
          </div>
        </div>
      ))}
    </div>
  );
}

function Crise({ crises, updates }: { crises: any[]; updates: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [expand, setExpand] = useState<string | null>(null);
  const [note, setNote] = useState("");
  const [busy, setBusy] = useState<string | null>(null);
  const [f, setF] = useState({ type: "incident", title: "", severity: "high", plan: "", commander: "" });
  async function create() {
    if (!supabase || !f.title) return;
    setBusy("create");
    await supabase.rpc("open_crisis", { p_company: COMPANY, p_type: f.type, p_title: f.title, p_severity: f.severity, p_plan: f.plan || null, p_commander: f.commander || null });
    setBusy(null); setOpen(false); setF({ type: "incident", title: "", severity: "high", plan: "", commander: "" }); router.refresh();
  }
  async function upd(id: string, status: string | null) {
    if (!supabase || (!note && !status)) return;
    setBusy(id);
    await supabase.rpc("update_crisis", { p_crisis: id, p_note: note || (status === "closed" ? "Crise encerrada." : "Atualização"), p_status: status });
    setBusy(null); setNote(""); router.refresh();
  }
  const TYPE: Record<string, string> = { incident: "Incidente", stockout: "Ruptura", recall: "Recall", fiscal: "Fiscal", outage: "Parada sistêmica", logistics: "Atraso logístico" };
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Salas de Crise</div>
        <button onClick={() => setOpen((o) => !o)} className={`btn btn-sm ${open ? "" : "btn-danger"}`}>{open ? "Cancelar" : "🚨 Abrir crise"}</button>
      </div>
      {open && (
        <div className="card p-4 grid md:grid-cols-2 gap-3">
          <div><label className="label">Tipo</label><select value={f.type} onChange={(e) => setF((p) => ({ ...p, type: e.target.value }))} className="select">{Object.entries(TYPE).map(([v, l]) => <option key={v} value={v}>{l}</option>)}</select></div>
          <div><label className="label">Severidade</label><select value={f.severity} onChange={(e) => setF((p) => ({ ...p, severity: e.target.value }))} className="select"><option value="critical">Crítica</option><option value="high">Alta</option><option value="medium">Média</option></select></div>
          <div className="md:col-span-2"><label className="label">Título</label><input value={f.title} onChange={(e) => setF((p) => ({ ...p, title: e.target.value }))} className="input" /></div>
          <div><label className="label">Comandante</label><input value={f.commander} onChange={(e) => setF((p) => ({ ...p, commander: e.target.value }))} className="input" /></div>
          <div><label className="label">Plano de ação</label><input value={f.plan} onChange={(e) => setF((p) => ({ ...p, plan: e.target.value }))} className="input" /></div>
          <button onClick={create} disabled={busy === "create" || !f.title} className="btn btn-danger btn-sm md:col-span-2 md:w-40">Abrir sala de crise</button>
        </div>
      )}
      {crises.length === 0 ? <p className="text-sm muted px-1">🛡️ Nenhuma crise. Operação sob controle.</p> : crises.map((c) => (
        <div key={c.id} className="card p-4" style={{ borderLeft: `3px solid ${sevColor(c.severity)}` }}>
          <div className="flex items-center gap-2 flex-wrap">
            <span className={`badge ${sevBadge(c.severity)}`}>{c.severity}</span>
            <span className="badge badge-neutral">{TYPE[c.crisis_type] ?? c.crisis_type}</span>
            <span className="font-semibold">{c.title}</span>
            <span className={`badge ${c.status === "active" ? "badge-danger" : "badge-success"} ml-auto`}>{c.status === "active" ? "ativa" : c.status}</span>
          </div>
          {c.action_plan && <div className="text-sm mt-2"><span className="muted">Plano:</span> {c.action_plan}</div>}
          <div className="text-xs muted mt-1">Comandante: {c.commander ?? "—"} · aberta {new Date(c.opened_at).toLocaleString("pt-BR")}</div>
          <button onClick={() => setExpand(expand === c.id ? null : c.id)} className="text-xs text-brand-600 hover:underline mt-2">timeline ({updates.filter((u) => u.crisis_id === c.id).length})</button>
          {expand === c.id && (
            <div className="mt-2 space-y-1 surface-2 rounded-xl p-3" style={{ border: "1px solid var(--border)" }}>
              {updates.filter((u) => u.crisis_id === c.id).map((u) => (
                <div key={u.id} className="text-xs flex gap-2"><span className="muted tabular-nums">{new Date(u.created_at).toLocaleString("pt-BR")}</span><span>{u.note}{u.status_to ? ` (→ ${u.status_to})` : ""}</span></div>
              ))}
              {c.status === "active" && (
                <div className="flex gap-2 pt-2">
                  <input value={expand === c.id ? note : ""} onChange={(e) => setNote(e.target.value)} className="input h-8 flex-1" placeholder="Nova atualização…" />
                  <button onClick={() => upd(c.id, null)} disabled={busy === c.id} className="btn btn-sm">Registrar</button>
                  <button onClick={() => upd(c.id, "closed")} disabled={busy === c.id} className="btn btn-sm" style={{ background: "var(--success)", color: "#fff", borderColor: "transparent" }}>Encerrar</button>
                </div>
              )}
            </div>
          )}
        </div>
      ))}
    </div>
  );
}
