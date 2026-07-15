"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

const TABS = ["Painel", "Construtor (Apps ao vivo)", "Templates", "Meus Apps", "Componentes"] as const;
type Tab = typeof TABS[number];

export default function ELCPWorkbench({ dash, apps, entities, records, templates, components }: {
  dash: any; apps: any[]; entities: any[]; records: any[]; templates: any[]; components: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Enterprise+ · Low-Code / No-Code</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Studio (Low-Code / No-Code)</h1>
        <p className="text-sm muted mt-0.5">Crie apps, entidades e formulários sem código — <strong>sem tocar no núcleo do ERP</strong> (dados em camada genérica, sobrevivem a atualizações).</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Construtor (Apps ao vivo)" && <Construtor entities={entities} records={records} apps={apps} />}
      {tab === "Templates" && <Templates templates={templates} />}
      {tab === "Meus Apps" && <Apps apps={apps} entities={entities} />}
      {tab === "Componentes" && <Componentes components={components} />}
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
      <KPI label="Apps" value={String(d.apps ?? 0)} hint={`${d.apps_published ?? 0} publicados`} />
      <KPI label="Entidades" value={String(d.entities ?? 0)} />
      <KPI label="Registros" value={String(d.records ?? 0)} />
      <KPI label="Formulários" value={String(d.forms ?? 0)} />
      <KPI label="Componentes" value={String(d.components ?? 0)} />
      <KPI label="Templates" value={String(d.templates ?? 0)} />
      <KPI label="Publicações" value={String(d.deployments ?? 0)} />
    </div>
  );
}

function Construtor({ entities, records, apps }: { entities: any[]; records: any[]; apps: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [sel, setSel] = useState<string>(entities[0]?.id ?? "");
  const [form, setForm] = useState<Record<string, any>>({});
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const entity = entities.find((e) => e.id === sel);
  const fields: any[] = entity?.fields ?? [];
  const appName = (id: string) => apps.find((a) => a.id === id)?.name ?? "";
  const rows = records.filter((r) => r.entity_id === sel);

  async function submit() {
    if (!supabase || !entity) return;
    setBusy(true); setErr(null);
    const { data, error } = await supabase.rpc("create_custom_record", { p_company: COMPANY, p_entity: sel, p_data: form });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setForm({}); router.refresh();
  }

  if (entities.length === 0) return <p className="text-sm muted px-1">Nenhuma entidade ainda. Vá em <strong>Templates</strong> e use um template para criar seu primeiro app.</p>;
  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <label className="label mb-0">Entidade:</label>
        <select value={sel} onChange={(e) => { setSel(e.target.value); setForm({}); }} className="select h-9 w-72">
          {entities.map((e) => <option key={e.id} value={e.id}>{appName(e.app_id)} · {e.name}</option>)}
        </select>
      </div>
      <div className="grid lg:grid-cols-2 gap-4">
        {/* formulário dinâmico gerado dos campos */}
        <div className="card p-4 space-y-3">
          <div className="font-semibold">{entity?.name} <span className="badge badge-neutral ml-1">formulário no-code</span></div>
          {fields.map((f) => (
            <div key={f.key}>
              <label className="label">{f.label}{f.required ? " *" : ""}</label>
              {f.type === "boolean" ? (
                <label className="flex items-center gap-2 text-sm mt-1"><input type="checkbox" checked={!!form[f.key]} onChange={(e) => setForm((p) => ({ ...p, [f.key]: e.target.checked }))} /> Sim</label>
              ) : (
                <input type={f.type === "number" ? "number" : f.type === "date" ? "date" : "text"} value={form[f.key] ?? ""} onChange={(e) => setForm((p) => ({ ...p, [f.key]: f.type === "number" ? Number(e.target.value) : e.target.value }))} className="input" />
              )}
            </div>
          ))}
          {err && <div className="text-sm rounded-xl px-3 py-2" style={{ background: "var(--danger-soft)", color: "var(--danger)" }}>{err}</div>}
          <button onClick={submit} disabled={busy} className="btn btn-primary btn-sm">{busy ? "Salvando…" : "Adicionar registro"}</button>
        </div>
        {/* registros ao vivo */}
        <div>
          <div className="font-semibold text-sm mb-2">Registros ({rows.length})</div>
          {rows.length === 0 ? <p className="text-sm muted">Nenhum registro. Use o formulário ao lado.</p> : (
            <div className="card p-0 overflow-x-auto"><table className="tbl">
              <thead><tr>{fields.slice(0, 4).map((f) => <th key={f.key}>{f.label}</th>)}</tr></thead>
              <tbody>{rows.map((r) => (
                <tr key={r.id}>{fields.slice(0, 4).map((f) => <td key={f.key}>{f.type === "boolean" ? (r.data?.[f.key] ? "✓" : "—") : String(r.data?.[f.key] ?? "—")}</td>)}</tr>
              ))}</tbody>
            </table></div>
          )}
        </div>
      </div>
    </div>
  );
}

function Templates({ templates }: { templates: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  async function use(key: string) { if (!supabase) return; setBusy(key); await supabase.rpc("instantiate_template", { p_company: COMPANY, p_template: key }); setBusy(null); router.refresh(); }
  return (
    <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
      {templates.map((t) => (
        <div key={t.id} className="card p-4 card-hover flex flex-col">
          <div className="flex items-center gap-2"><span className="text-2xl">{t.icon}</span><div className="font-semibold text-sm flex-1">{t.name}</div><span className="badge badge-neutral">{t.category}</span></div>
          <div className="text-xs muted mt-2 flex-1">{t.description}</div>
          <div className="text-[11px] muted mt-1">{t.installs} instalação(ões)</div>
          <button onClick={() => use(t.template_key)} disabled={busy === t.template_key} className="btn btn-primary btn-sm w-full mt-3">{busy === t.template_key ? "Criando…" : "Usar template"}</button>
        </div>
      ))}
      {templates.length === 0 && <p className="text-sm muted">Nenhum template.</p>}
    </div>
  );
}

function Apps({ apps, entities }: { apps: any[]; entities: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  async function publish(id: string) { if (!supabase) return; setBusy(id); await supabase.rpc("publish_app", { p_app: id, p_environment: "production", p_changelog: "publicado via Studio" }); setBusy(null); router.refresh(); }
  const entCount = (appId: string) => entities.filter((e) => e.app_id === appId).length;
  return (
    <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
      {apps.map((a) => (
        <div key={a.id} className="card p-4">
          <div className="flex items-center gap-2"><span className="text-2xl">{a.icon}</span><div className="font-semibold text-sm flex-1">{a.name}</div><span className={`badge ${a.status === "published" ? "badge-success" : "badge-warning"}`}>{a.status === "published" ? "publicado v" + a.app_version : "rascunho"}</span></div>
          <div className="text-xs muted mt-2">{a.category ?? "—"} · {entCount(a.id)} entidade(s)</div>
          {a.status !== "published" && <button onClick={() => publish(a.id)} disabled={busy === a.id} className="btn btn-primary btn-sm w-full mt-3">Publicar</button>}
        </div>
      ))}
      {apps.length === 0 && <p className="text-sm muted">Nenhum app ainda — comece pelos Templates.</p>}
    </div>
  );
}

function Componentes({ components }: { components: any[] }) {
  const ico = (t: string) => ({ widget: "🧩", chart: "📊", field: "✏️" } as any)[t] ?? "🔧";
  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
      {components.map((c) => (
        <div key={c.id} className="card p-4 flex items-center gap-2">
          <span className="text-xl">{ico(c.component_type)}</span>
          <div className="min-w-0"><div className="text-sm font-medium truncate">{c.name}</div><div className="text-[10px] muted">{c.component_type}{c.is_shared ? " · compartilhado" : ""}</div></div>
        </div>
      ))}
    </div>
  );
}
