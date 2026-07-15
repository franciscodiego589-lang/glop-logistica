"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const PLAT: Record<string, string> = { ios: "📱 iOS", android: "🤖 Android", windows: "🪟 Windows", macos: "🖥 macOS", linux: "🐧 Linux", web: "🌐 Web/PWA" };

const TABS = ["Painel", "Dispositivos", "Sincronização", "Notificações", "Modos Operacionais"] as const;
type Tab = typeof TABS[number];

export default function ESAPWorkbench({ dash, devices, syncItems, notifications, profiles }: {
  dash: any; devices: any[]; syncItems: any[]; notifications: any[]; profiles: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Enterprise+ · Super App</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Super App & Dispositivos (ESAP)</h1>
        <p className="text-sm muted mt-0.5">O GLOP é um <strong>PWA instalável</strong> (celular/desktop, offline). Aqui você administra dispositivos, sincronização de campo e notificações.</p>
      </div>
      <div className="card p-4 flex items-center gap-3" style={{ background: "var(--brand-soft)" }}>
        <span className="text-2xl">📲</span>
        <div className="text-sm"><strong>Instale o GLOP:</strong> no celular, abra pelo navegador e toque em “Adicionar à tela de início”. No desktop (Chrome/Edge), clique no ícone de instalar na barra de endereço. Funciona offline nas telas já visitadas.</div>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Dispositivos" && <Dispositivos devices={devices} />}
      {tab === "Sincronização" && <Sync syncItems={syncItems} devices={devices} />}
      {tab === "Notificações" && <Notificacoes notifications={notifications} />}
      {tab === "Modos Operacionais" && <Modos profiles={profiles} />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash }: { dash: any }) {
  const d = dash ?? {}; const bp: Record<string, number> = d.by_platform ?? {};
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <KPI label="Dispositivos" value={String(d.devices ?? 0)} hint={`${d.devices_active ?? 0} ativos (7d)`} />
        <KPI label="Sync pendente" value={String(d.sync_pending ?? 0)} tone={d.sync_pending ? "var(--warning)" : undefined} />
        <KPI label="Sincronizados" value={String(d.sync_synced ?? 0)} tone="var(--success)" />
        <KPI label="Conflitos de sync" value={String(d.sync_conflicts ?? 0)} tone={d.sync_conflicts ? "var(--danger)" : undefined} />
        <KPI label="Push (hoje)" value={String(d.push_sent_today ?? 0)} />
        <KPI label="Não lidas" value={String(d.push_unread ?? 0)} />
        <KPI label="Modos operacionais" value={String(d.profiles ?? 0)} />
      </div>
      <div className="card p-5">
        <div className="font-semibold mb-3">Dispositivos por plataforma</div>
        {Object.keys(bp).length === 0 ? <p className="text-sm muted">Nenhum dispositivo registrado.</p> : (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            {Object.entries(bp).map(([p, c]) => (<div key={p} className="surface-2 rounded-xl p-3" style={{ border: "1px solid var(--border)" }}><div className="text-xs muted font-semibold">{PLAT[p] ?? p}</div><div className="text-lg font-bold tabular-nums mt-1">{c}</div></div>))}
          </div>
        )}
      </div>
    </div>
  );
}

function Dispositivos({ devices }: { devices: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [f, setF] = useState({ name: "", platform: "ios", os: "" });
  const [busy, setBusy] = useState(false);
  async function register() {
    if (!supabase || !f.name) return;
    setBusy(true);
    await supabase.rpc("register_device", { p_company: COMPANY, p_name: f.name, p_platform: f.platform, p_version: "1.0.0", p_push_token: null, p_os: f.os || null });
    setBusy(false); setF({ name: "", platform: "ios", os: "" }); router.refresh();
  }
  async function wipe(id: string) {
    if (!supabase) return;
    await supabase.from("devices").update({ status: "wiped" }).eq("id", id);
    router.refresh();
  }
  return (
    <div className="space-y-3">
      <div className="card p-4 grid md:grid-cols-4 gap-3 items-end">
        <div className="md:col-span-2"><label className="label">Nome do dispositivo</label><input value={f.name} onChange={(e) => setF((p) => ({ ...p, name: e.target.value }))} className="input" placeholder="iPhone do João" /></div>
        <div><label className="label">Plataforma</label><select value={f.platform} onChange={(e) => setF((p) => ({ ...p, platform: e.target.value }))} className="select">{Object.entries(PLAT).map(([v, l]) => <option key={v} value={v}>{l}</option>)}</select></div>
        <button onClick={register} disabled={busy || !f.name} className="btn btn-primary btn-sm">Registrar</button>
      </div>
      {devices.length === 0 ? <p className="text-sm muted px-1">Nenhum dispositivo.</p> : (
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Dispositivo</th><th>Plataforma</th><th>Versão</th><th>Último acesso</th><th>Status</th><th></th></tr></thead>
          <tbody>{devices.map((dv) => (
            <tr key={dv.id}>
              <td className="font-medium">{dv.name}</td><td>{PLAT[dv.platform] ?? dv.platform}</td><td className="text-xs muted">{dv.app_version ?? "—"}</td>
              <td className="text-xs muted tabular-nums">{dv.last_seen_at ? new Date(dv.last_seen_at).toLocaleString("pt-BR") : "—"}</td>
              <td><span className={`badge ${dv.status === "active" ? "badge-success" : dv.status === "wiped" ? "badge-danger" : "badge-neutral"}`}>{dv.status}</span></td>
              <td className="text-right">{dv.status !== "wiped" && <button onClick={() => wipe(dv.id)} className="text-xs font-semibold hover:underline" style={{ color: "var(--danger)" }}>limpar remoto</button>}</td>
            </tr>
          ))}</tbody>
        </table></div>
      )}
    </div>
  );
}

function Sync({ syncItems, devices }: { syncItems: any[]; devices: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const devName = (id: string) => devices.find((d) => d.id === id)?.name ?? "—";
  async function process() { if (!supabase) return; setBusy(true); await supabase.rpc("process_sync", { p_company: COMPANY, p_device: null }); setBusy(false); router.refresh(); }
  const badge = (s: string) => ({ pending: "badge-warning", synced: "badge-success", conflict: "badge-danger", failed: "badge-danger" } as any)[s] ?? "badge-neutral";
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Fila de Sincronização (offline)</div>
        <button onClick={process} disabled={busy} className="btn btn-primary btn-sm">{busy ? "Sincronizando…" : "↻ Processar fila"}</button>
      </div>
      {syncItems.length === 0 ? <p className="text-sm muted px-1">Fila vazia — tudo sincronizado.</p> : (
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Entidade</th><th>Operação</th><th>Dispositivo</th><th>Direção</th><th>Tentativas</th><th>Status</th></tr></thead>
          <tbody>{syncItems.map((s) => (
            <tr key={s.id}><td>{s.entity} <code className="text-[11px] muted">{s.payload?.ref}</code></td><td className="text-xs">{s.operation}</td><td className="text-xs muted">{devName(s.device_id)}</td><td className="text-xs">{s.direction === "up" ? "↑ envio" : "↓ recepção"}</td><td className="tabular-nums">{s.attempts}</td><td><span className={`badge ${badge(s.status)}`}>{s.status}</span></td></tr>
          ))}</tbody>
        </table></div>
      )}
    </div>
  );
}

function Notificacoes({ notifications }: { notifications: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [f, setF] = useState({ title: "", body: "", category: "info" });
  const [busy, setBusy] = useState(false);
  async function send() {
    if (!supabase || !f.title) return;
    setBusy(true);
    await supabase.rpc("send_push", { p_company: COMPANY, p_title: f.title, p_body: f.body || null, p_category: f.category, p_device: null, p_deep_link: null });
    setBusy(false); setF({ title: "", body: "", category: "info" }); router.refresh();
  }
  const icon = (c: string) => ({ approval: "✅", alert: "🚨", reminder: "⏰", message: "💬", info: "ℹ️" } as any)[c] ?? "🔔";
  return (
    <div className="space-y-3">
      <div className="card p-4 grid md:grid-cols-4 gap-3 items-end">
        <div className="md:col-span-2"><label className="label">Título</label><input value={f.title} onChange={(e) => setF((p) => ({ ...p, title: e.target.value }))} className="input" /></div>
        <div><label className="label">Categoria</label><select value={f.category} onChange={(e) => setF((p) => ({ ...p, category: e.target.value }))} className="select"><option value="info">Informativo</option><option value="approval">Aprovação</option><option value="alert">Alerta</option><option value="reminder">Lembrete</option></select></div>
        <button onClick={send} disabled={busy || !f.title} className="btn btn-primary btn-sm">Enviar push</button>
        <div className="md:col-span-4"><input value={f.body} onChange={(e) => setF((p) => ({ ...p, body: e.target.value }))} className="input" placeholder="Mensagem…" /></div>
      </div>
      {notifications.length === 0 ? <p className="text-sm muted px-1">Nenhuma notificação enviada.</p> : (
        <div className="space-y-2">{notifications.map((n) => (
          <div key={n.id} className="card p-3 flex items-center gap-3">
            <span className="text-lg">{icon(n.category)}</span>
            <div className="flex-1"><div className="font-medium text-sm">{n.title}</div><div className="text-xs muted">{n.body}</div></div>
            <span className="text-xs muted tabular-nums">{new Date(n.sent_at ?? n.created_at).toLocaleString("pt-BR")}</span>
            <span className={`badge ${n.read_at ? "badge-neutral" : "badge-success"}`}>{n.read_at ? "lida" : "enviada"}</span>
          </div>
        ))}</div>
      )}
    </div>
  );
}

function Modos({ profiles }: { profiles: any[] }) {
  return (
    <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
      {profiles.map((p) => (
        <div key={p.id} className="card p-4">
          <div className="flex items-center gap-2"><span className="text-xl">{p.icon}</span><div className="font-semibold text-sm">{p.name}</div></div>
          <div className="text-xs muted mt-2">Módulos disponíveis:</div>
          <div className="flex flex-wrap gap-1 mt-1">{(p.allowed_modules ?? []).map((m: string) => <span key={m} className="badge badge-neutral">{m}</span>)}</div>
        </div>
      ))}
      {profiles.length === 0 && <p className="text-sm muted">Nenhum modo operacional.</p>}
    </div>
  );
}
