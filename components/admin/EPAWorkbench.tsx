"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Configurações", "Feature Flags", "Moedas", "Idiomas", "Módulos", "Ambientes & Licença"] as const;
type Tab = typeof TABS[number];

export default function EPAWorkbench({ dash, settings, changedKeys, flags, currencies, languages, environments, modules, license }: {
  dash: any; settings: any[]; changedKeys: string[]; flags: any[]; currencies: any[]; languages: any[]; environments: any[]; modules: any[]; license: any;
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Plataforma · Administração Global</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Administração da Plataforma</h1>
        <p className="text-sm muted mt-0.5">O "SAP IMG" do ERP: centro de configuração parametrizável (com histórico + rollback), feature flags, multimoeda, multilíngue, módulos e licenças.</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Configurações" && <ConfigCenter settings={settings} changedKeys={changedKeys} />}
      {tab === "Feature Flags" && <Flags flags={flags} />}
      {tab === "Moedas" && <Moedas currencies={currencies} />}
      {tab === "Idiomas" && <Idiomas languages={languages} />}
      {tab === "Módulos" && <Modulos modules={modules} />}
      {tab === "Ambientes & Licença" && <AmbientesLicenca environments={environments} license={license} />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash }: { dash: any }) {
  const d = dash ?? {}; const lic = d.license;
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <KPI label="Empresas (grupo)" value={String(d.companies ?? 0)} />
        <KPI label="Usuários" value={String(d.users ?? 0)} />
        <KPI label="Parâmetros" value={String(d.settings ?? 0)} />
        <KPI label="Módulos ativos" value={`${d.modules_enabled ?? 0}/${d.modules_total ?? 0}`} />
        <KPI label="Feature flags on" value={String(d.feature_flags_on ?? 0)} />
        <KPI label="Moedas" value={String(d.currencies ?? 0)} />
        <KPI label="Idiomas" value={String(d.languages ?? 0)} />
        <KPI label="Mudanças (7d)" value={String(d.config_changes_7d ?? 0)} />
      </div>
      {lic && (
        <div className="card p-5 flex items-center gap-4">
          <span className="h-12 w-12 rounded-2xl grid place-items-center text-2xl" style={{ background: "var(--brand-soft)", color: "var(--brand)" }}>🔑</span>
          <div className="flex-1">
            <div className="font-semibold">Licença <span className="uppercase">{lic.plan}</span> <span className="badge badge-success ml-1">{lic.status}</span></div>
            <div className="text-sm muted">Até {lic.users_limit} usuários · válida até {lic.valid_until ? new Date(lic.valid_until + "T00:00:00").toLocaleDateString("pt-BR") : "—"}</div>
          </div>
        </div>
      )}
    </div>
  );
}

function ConfigCenter({ settings, changedKeys }: { settings: any[]; changedKeys: string[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [q, setQ] = useState("");
  const [edits, setEdits] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState<string | null>(null);
  const cats = useMemo(() => Array.from(new Set(settings.map((s) => s.category))), [settings]);
  const [cat, setCat] = useState<string>("todos");

  const filtered = settings.filter((s) => (cat === "todos" || s.category === cat) && (!q || (s.name ?? s.setting_key).toLowerCase().includes(q.toLowerCase()) || s.setting_key.toLowerCase().includes(q.toLowerCase())));

  async function save(key: string) {
    if (!supabase || edits[key] === undefined) return;
    setBusy(key);
    await supabase.rpc("set_setting", { p_company: COMPANY, p_key: key, p_value: edits[key], p_category: "geral" });
    setBusy(null); setEdits((p) => { const n = { ...p }; delete n[key]; return n; }); router.refresh();
  }
  async function rollback(key: string) {
    if (!supabase) return;
    setBusy(key);
    await supabase.rpc("rollback_setting", { p_company: COMPANY, p_key: key });
    setBusy(null); router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap items-center gap-2">
        <div className="relative">
          <span className="absolute left-2.5 top-1/2 -translate-y-1/2 muted text-sm pointer-events-none">⌕</span>
          <input value={q} onChange={(e) => setQ(e.target.value)} className="input h-9 pl-8 w-56" placeholder="Buscar parâmetro…" />
        </div>
        <select value={cat} onChange={(e) => setCat(e.target.value)} className="select h-9 w-44"><option value="todos">Todas as categorias</option>{cats.map((c) => <option key={c} value={c}>{c}</option>)}</select>
      </div>
      <div className="card p-0 overflow-x-auto">
        <table className="tbl">
          <thead><tr><th>Parâmetro</th><th>Categoria</th><th>Valor</th><th></th></tr></thead>
          <tbody>
            {filtered.map((s) => {
              const dirty = edits[s.setting_key] !== undefined && edits[s.setting_key] !== s.value;
              return (
                <tr key={s.id}>
                  <td><div className="font-medium">{s.name ?? s.setting_key}</div><code className="text-[11px] muted">{s.setting_key}</code></td>
                  <td><span className="badge badge-neutral">{s.category}</span></td>
                  <td style={{ minWidth: 180 }}>
                    <input value={edits[s.setting_key] ?? s.value ?? ""} onChange={(e) => setEdits((p) => ({ ...p, [s.setting_key]: e.target.value }))} className="input h-8" />
                  </td>
                  <td className="text-right whitespace-nowrap">
                    {dirty && <button onClick={() => save(s.setting_key)} disabled={busy === s.setting_key} className="btn btn-primary btn-sm mr-1">Salvar</button>}
                    {changedKeys.includes(s.setting_key) && <button onClick={() => rollback(s.setting_key)} disabled={busy === s.setting_key} className="text-xs font-semibold hover:underline" style={{ color: "var(--warning)" }}>rollback</button>}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function Flags({ flags }: { flags: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  async function toggle(id: string, on: boolean) { if (!supabase) return; await supabase.from("feature_flags").update({ enabled: !on }).eq("id", id); router.refresh(); }
  return (
    <div className="grid md:grid-cols-2 gap-3">
      {flags.map((f) => (
        <div key={f.id} className="card p-4 flex items-center gap-3">
          <div className="flex-1">
            <div className="font-semibold text-sm">{f.name ?? f.flag_key} {f.stage === "beta" && <span className="badge badge-warning ml-1">beta</span>}</div>
            <code className="text-[11px] muted">{f.flag_key}</code>
          </div>
          <button onClick={() => toggle(f.id, f.enabled)} className="relative w-12 h-6 rounded-full transition-colors" style={{ background: f.enabled ? "var(--success)" : "var(--surface-3)" }}>
            <span className="absolute top-0.5 h-5 w-5 rounded-full bg-white transition-all" style={{ left: f.enabled ? "26px" : "2px" }} />
          </button>
        </div>
      ))}
    </div>
  );
}

function Moedas({ currencies }: { currencies: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const [f, setF] = useState({ amount: "1000", from: "USD", to: "BRL" });
  const [res, setRes] = useState<any>(null);
  async function convert() {
    if (!supabase) return;
    const { data } = await supabase.rpc("convert_currency", { p_company: COMPANY, p_amount: Number(f.amount) || 0, p_from: f.from, p_to: f.to });
    setRes(data);
  }
  return (
    <div className="grid lg:grid-cols-2 gap-4">
      <div className="card p-0 overflow-x-auto">
        <table className="tbl"><thead><tr><th>Moeda</th><th>Código</th><th className="text-right">Taxa → base</th><th>Base</th></tr></thead>
          <tbody>{currencies.map((c) => (<tr key={c.id}><td>{c.symbol} {c.name}</td><td><code>{c.code}</code></td><td className="text-right tabular-nums">{Number(c.rate_to_base).toLocaleString("pt-BR", { minimumFractionDigits: 4 })}</td><td>{c.is_base ? <span className="badge badge-brand">base</span> : "—"}</td></tr>))}</tbody>
        </table>
      </div>
      <div className="card p-4 space-y-3">
        <div className="font-semibold">Conversor multimoeda</div>
        <div className="grid grid-cols-3 gap-2 items-end">
          <div><label className="label">Valor</label><input type="number" value={f.amount} onChange={(e) => setF((p) => ({ ...p, amount: e.target.value }))} className="input" /></div>
          <div><label className="label">De</label><select value={f.from} onChange={(e) => setF((p) => ({ ...p, from: e.target.value }))} className="select">{currencies.map((c) => <option key={c.id} value={c.code}>{c.code}</option>)}</select></div>
          <div><label className="label">Para</label><select value={f.to} onChange={(e) => setF((p) => ({ ...p, to: e.target.value }))} className="select">{currencies.map((c) => <option key={c.id} value={c.code}>{c.code}</option>)}</select></div>
        </div>
        <button onClick={convert} className="btn btn-primary btn-sm">Converter</button>
        {res?.result != null && <div className="text-2xl font-bold tabular-nums">{Number(res.result).toLocaleString("pt-BR", { minimumFractionDigits: 2 })} <span className="text-sm muted">{f.to}</span></div>}
      </div>
    </div>
  );
}

function Idiomas({ languages }: { languages: any[] }) {
  return (
    <div className="grid md:grid-cols-3 gap-3">
      {languages.map((l) => (
        <div key={l.id} className="card p-4">
          <div className="flex items-center justify-between"><div className="font-semibold text-sm">{l.name}</div>{l.is_default && <span className="badge badge-brand">padrão</span>}</div>
          <code className="text-[11px] muted">{l.code}</code>
          <div className="mt-2 h-2 rounded-full overflow-hidden" style={{ background: "var(--surface-3)" }}><div className="h-full rounded-full" style={{ width: `${l.completion_pct}%`, background: "var(--brand)" }} /></div>
          <div className="text-xs muted mt-1">{l.completion_pct}% traduzido</div>
        </div>
      ))}
    </div>
  );
}

function Modulos({ modules }: { modules: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  async function toggle(id: string, on: boolean) { if (!supabase) return; await supabase.from("module_registry").update({ enabled: !on }).eq("id", id); router.refresh(); }
  const byCat = useMemo(() => { const m: Record<string, any[]> = {}; modules.forEach((x) => { (m[x.category] = m[x.category] || []).push(x); }); return Object.entries(m); }, [modules]);
  return (
    <div className="space-y-4">
      {byCat.map(([c, ms]) => (
        <div key={c}>
          <div className="text-xs font-semibold uppercase tracking-wider muted mb-2">{c}</div>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
            {ms.map((m) => (
              <div key={m.id} className="card p-3 flex items-center gap-2">
                <span className="dot" style={{ background: m.enabled ? "var(--success)" : "var(--muted)" }} />
                <div className="flex-1 min-w-0"><div className="text-sm font-medium truncate">{m.name}</div><div className="text-[10px] muted">v{m.module_version}</div></div>
                <button onClick={() => toggle(m.id, m.enabled)} className="text-xs font-semibold" style={{ color: m.enabled ? "var(--danger)" : "var(--success)" }}>{m.enabled ? "off" : "on"}</button>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}

function AmbientesLicenca({ environments, license }: { environments: any[]; license: any }) {
  return (
    <div className="grid lg:grid-cols-2 gap-4">
      <div>
        <div className="font-semibold text-sm mb-2">Ambientes</div>
        <div className="space-y-2">
          {environments.map((e) => (
            <div key={e.id} className="card p-3 flex items-center gap-2">
              <span className="dot" style={{ background: e.status === "active" ? "var(--success)" : "var(--muted)" }} />
              <div className="flex-1"><div className="font-medium text-sm">{e.name}</div><div className="text-[11px] muted">{e.env_type}</div></div>
              <span className={`badge ${e.status === "active" ? "badge-success" : "badge-neutral"}`}>{e.status}</span>
            </div>
          ))}
        </div>
      </div>
      {license && (
        <div className="card p-5">
          <div className="font-semibold mb-3">Licença</div>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between"><span className="muted">Plano</span><span className="font-semibold uppercase">{license.plan}</span></div>
            <div className="flex justify-between"><span className="muted">Status</span><span className="badge badge-success">{license.status}</span></div>
            <div className="flex justify-between"><span className="muted">Limite de usuários</span><span className="tabular-nums">{license.users_limit}</span></div>
            <div className="flex justify-between"><span className="muted">Válida até</span><span className="tabular-nums">{license.valid_until ? new Date(license.valid_until + "T00:00:00").toLocaleDateString("pt-BR") : "—"}</span></div>
          </div>
        </div>
      )}
    </div>
  );
}
