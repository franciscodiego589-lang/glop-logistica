"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const MSTATUS: Record<string, string> = { queued: "Na fila", delivered: "Entregue", failed: "Falhou", dead_letter: "DLQ" };
const MBADGE: Record<string, string> = { queued: "badge-warning", delivered: "badge-success", failed: "badge-danger", dead_letter: "badge-danger" };

const TABS = ["Painel", "API Marketplace", "Conectores", "Event Bus & Webhooks", "Fila de Mensagens", "Fluxos ETL", "Chaves de API"] as const;
type Tab = typeof TABS[number];

export default function EIPWorkbench({ dash, apis, connectors, webhooks, events, messages, flows, apiKeys }: {
  dash: any; apis: any[]; connectors: any[]; webhooks: any[]; events: any[]; messages: any[]; flows: any[]; apiKeys: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Plataforma · Integração Corporativa</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Integrações (iPaaS / API Gateway)</h1>
        <p className="text-sm muted mt-0.5">Barramento corporativo: catálogo de APIs, conectores, event bus com webhooks, fila com retry/DLQ e ETL.</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "API Marketplace" && <Marketplace apis={apis} />}
      {tab === "Conectores" && <Conectores connectors={connectors} />}
      {tab === "Event Bus & Webhooks" && <EventBus webhooks={webhooks} events={events} />}
      {tab === "Fila de Mensagens" && <Fila messages={messages} />}
      {tab === "Fluxos ETL" && <Fluxos flows={flows} />}
      {tab === "Chaves de API" && <ApiKeys apiKeys={apiKeys} />}
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
      <KPI label="APIs publicadas" value={String(d.apis ?? 0)} />
      <KPI label="Conectores" value={`${d.connectors_connected ?? 0}/${d.connectors ?? 0}`} hint="conectados" />
      <KPI label="Webhooks" value={String(d.webhooks ?? 0)} />
      <KPI label="Eventos (total)" value={String(d.events_total ?? 0)} hint={`${d.events_today ?? 0} hoje`} />
      <KPI label="Na fila" value={String(d.msg_queued ?? 0)} tone={d.msg_queued ? "var(--warning)" : undefined} />
      <KPI label="Entregues" value={String(d.msg_delivered ?? 0)} tone="var(--success)" />
      <KPI label="Dead Letter Queue" value={String(d.msg_dlq ?? 0)} tone={d.msg_dlq ? "var(--danger)" : undefined} />
      <KPI label="Chaves de API" value={String(d.api_keys ?? 0)} />
    </div>
  );
}

function Marketplace({ apis }: { apis: any[] }) {
  const mColor = (m: string) => ({ GET: "var(--success)", POST: "var(--brand)", PUT: "var(--warning)", DELETE: "var(--danger)" } as any)[m] ?? "var(--muted)";
  return (
    <div className="grid md:grid-cols-2 gap-3">
      {apis.map((a) => (
        <div key={a.id} className="card p-4">
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold px-2 py-0.5 rounded" style={{ background: "var(--surface-3)", color: mColor(a.method) }}>{a.method}</span>
            <code className="text-sm">{a.path}</code>
            <span className="badge badge-neutral ml-auto">{a.protocol} {a.api_version}</span>
          </div>
          <div className="font-semibold text-sm mt-2">{a.name}</div>
          <div className="text-xs muted">{a.description}</div>
          <div className="text-xs muted mt-2">{a.category} · auth: {a.auth_type} · {a.calls_count} chamadas</div>
        </div>
      ))}
      {apis.length === 0 && <p className="text-sm muted">Nenhuma API publicada.</p>}
    </div>
  );
}

function Conectores({ connectors }: { connectors: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  async function toggle(id: string, status: string) {
    if (!supabase) return;
    const next = status === "connected" ? "disconnected" : "connected";
    await supabase.from("integration_connectors").update({ status: next, last_sync_at: next === "connected" ? new Date().toISOString() : null }).eq("id", id);
    router.refresh();
  }
  const dot = (s: string) => s === "connected" ? "var(--success)" : s === "error" ? "var(--danger)" : "var(--muted)";
  return (
    <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
      {connectors.map((c) => (
        <div key={c.id} className="card p-4">
          <div className="flex items-center gap-2">
            <span className="dot" style={{ background: dot(c.status) }} />
            <div className="font-semibold text-sm flex-1">{c.name}</div>
            <button onClick={() => toggle(c.id, c.status)} className="btn btn-sm">{c.status === "connected" ? "Desconectar" : "Conectar"}</button>
          </div>
          <div className="text-xs muted mt-1">{c.connector_type} · {c.direction}</div>
          <div className="text-xs muted mt-0.5">{c.status === "connected" && c.last_sync_at ? "Última sync: " + new Date(c.last_sync_at).toLocaleString("pt-BR") : c.status}</div>
        </div>
      ))}
      {connectors.length === 0 && <p className="text-sm muted">Nenhum conector.</p>}
    </div>
  );
}

function EventBus({ webhooks, events }: { webhooks: any[]; events: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [evt, setEvt] = useState("order.created");
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  async function publish() {
    if (!supabase || !evt) return;
    setBusy(true); setMsg(null);
    const { data } = await supabase.rpc("publish_event", { p_company: COMPANY, p_event_type: evt, p_payload: { test: true, at: new Date().toISOString() }, p_source: "manual" });
    setBusy(false);
    setMsg(`✓ Evento publicado · ${data?.subscribers_notified ?? 0} webhook(s) notificado(s)`); router.refresh();
  }
  return (
    <div className="space-y-4">
      <div className="card p-4 flex flex-wrap items-end gap-3">
        <div className="flex-1 min-w-[200px]"><label className="label">Publicar evento no barramento</label>
          <input value={evt} onChange={(e) => setEvt(e.target.value)} className="input" placeholder="order.created" list="evtlist" />
          <datalist id="evtlist"><option value="order.created" /><option value="order.canceled" /><option value="payment.confirmed" /><option value="nfe.issued" /><option value="production.finished" /><option value="batch.released" /></datalist>
        </div>
        <button onClick={publish} disabled={busy || !evt} className="btn btn-primary btn-sm">Publicar evento</button>
        {msg && <span className="text-xs muted">{msg}</span>}
      </div>
      <div className="grid lg:grid-cols-2 gap-4">
        <CrudPanel table="webhooks" title="Webhooks (assinaturas)"
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "event_type", label: "Evento", required: true, placeholder: "order.created (ou * para todos)" },
            { key: "target_url", label: "URL de destino", required: true },
            { key: "secret", label: "Segredo (HMAC)" },
          ]}
          columns={[{ key: "name", label: "Webhook" }, { key: "event_type", label: "Evento" }, { key: "target_url", label: "Destino" }, { key: "failure_count", label: "Falhas" }]}
          rows={webhooks} emptyHint="Assine eventos e envie para sistemas externos." />
        <div>
          <div className="font-semibold text-sm mb-2">Fluxo de eventos (recentes)</div>
          {events.length === 0 ? <p className="text-sm muted">Nenhum evento ainda.</p> : (
            <div className="card p-0 overflow-x-auto"><table className="tbl">
              <thead><tr><th>Evento</th><th>Origem</th><th>Assinantes</th><th>Quando</th></tr></thead>
              <tbody>{events.slice(0, 20).map((e) => (<tr key={e.id}><td className="font-mono text-xs">{e.event_type}</td><td className="text-xs muted">{e.source_module ?? "—"}</td><td className="tabular-nums">{e.subscribers_notified}</td><td className="text-xs muted tabular-nums">{new Date(e.occurred_at).toLocaleString("pt-BR")}</td></tr>))}</tbody>
            </table></div>
          )}
        </div>
      </div>
    </div>
  );
}

function Fila({ messages }: { messages: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  async function processAll() { if (!supabase) return; setBusy("all"); await supabase.rpc("process_queue", { p_company: COMPANY }); setBusy(null); router.refresh(); }
  async function retry(id: string) { if (!supabase) return; setBusy(id); await supabase.rpc("deliver_message", { p_message: id, p_success: true, p_error: null }); setBusy(null); router.refresh(); }
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Fila de Mensagens <span className="badge badge-neutral ml-1">{messages.length}</span></div>
        <button onClick={processAll} disabled={busy === "all"} className="btn btn-primary btn-sm">{busy === "all" ? "Processando…" : "Processar fila"}</button>
      </div>
      {messages.length === 0 ? <p className="text-sm muted px-1">Fila vazia.</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead><tr><th>Destino</th><th>Canal</th><th>Tentativas</th><th>Status</th><th></th></tr></thead>
            <tbody>
              {messages.map((m) => (
                <tr key={m.id}>
                  <td className="text-xs">{m.target}</td>
                  <td className="text-xs muted">{m.channel}</td>
                  <td className="tabular-nums">{m.attempts}/{m.max_attempts}</td>
                  <td><span className={`badge ${MBADGE[m.status]}`}>{MSTATUS[m.status] ?? m.status}</span></td>
                  <td className="text-right">{["failed", "dead_letter"].includes(m.status) && <button onClick={() => retry(m.id)} disabled={busy === m.id} className="text-xs font-semibold text-brand-600 hover:underline">reprocessar</button>}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function Fluxos({ flows }: { flows: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  async function run(id: string) { if (!supabase) return; setBusy(id); await supabase.rpc("run_integration_flow", { p_flow: id, p_records: Math.floor(50 + Math.random() * 200) }); setBusy(null); router.refresh(); }
  return (
    <div className="grid md:grid-cols-2 gap-3">
      {flows.map((f) => (
        <div key={f.id} className="card p-4">
          <div className="flex items-center justify-between"><div className="font-semibold text-sm">{f.name}</div><span className="badge badge-neutral">{f.flow_type}</span></div>
          <div className="text-xs muted mt-1"><code>{f.source_ref}</code> → <code>{f.target_ref}</code> · cron <code>{f.schedule}</code></div>
          <div className="text-xs muted mt-1">{f.runs_count} execuções · {f.records_processed} registros{f.last_run_at ? " · última " + new Date(f.last_run_at).toLocaleString("pt-BR") : ""}</div>
          <button onClick={() => run(f.id)} disabled={busy === f.id} className="btn btn-primary btn-sm w-full mt-3">{busy === f.id ? "Executando…" : "Executar agora"}</button>
        </div>
      ))}
      {flows.length === 0 && <p className="text-sm muted">Nenhum fluxo ETL.</p>}
    </div>
  );
}

function ApiKeys({ apiKeys }: { apiKeys: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [name, setName] = useState("");
  const [busy, setBusy] = useState(false);
  const [created, setCreated] = useState<any>(null);
  async function generate() {
    if (!supabase || !name) return;
    setBusy(true);
    const { data } = await supabase.rpc("generate_api_key", { p_company: COMPANY, p_name: name, p_scopes: ["read", "write"] });
    setBusy(false); setCreated(data); setName(""); router.refresh();
  }
  return (
    <div className="space-y-3">
      <div className="card p-4 flex flex-wrap items-end gap-3">
        <div className="flex-1 min-w-[200px]"><label className="label">Nova chave de API</label><input value={name} onChange={(e) => setName(e.target.value)} className="input" placeholder="Nome (ex.: Integração Marketplace)" /></div>
        <button onClick={generate} disabled={busy || !name} className="btn btn-primary btn-sm">Gerar chave</button>
      </div>
      {created && (
        <div className="card p-4" style={{ background: "var(--success-soft)" }}>
          <div className="text-sm font-semibold" style={{ color: "var(--success)" }}>Chave criada — copie agora, não será exibida novamente:</div>
          <code className="block mt-1 text-sm break-all">{created.api_key}</code>
        </div>
      )}
      {apiKeys.length > 0 && (
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Nome</th><th>Prefixo</th><th>Escopos</th><th>Criada</th></tr></thead>
          <tbody>{apiKeys.map((k) => (<tr key={k.id}><td>{k.name}</td><td><code className="text-xs">{k.key_prefix}…</code></td><td className="text-xs muted">{(k.scopes ?? []).join(", ")}</td><td className="text-xs muted tabular-nums">{new Date(k.created_at).toLocaleDateString("pt-BR")}</td></tr>))}</tbody>
        </table></div>
      )}
    </div>
  );
}
