"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const scoreTone = (s: number) => s == null ? "var(--muted)" : s >= 85 ? "var(--success)" : s >= 70 ? "var(--warning)" : "var(--danger)";
const DEDUP_DOMAINS = [["products", "Produtos"], ["customers", "Clientes"], ["employees", "Colaboradores"], ["suppliers", "Fornecedores"]] as [string, string][];

const TABS = ["Painel", "Domínios & Qualidade", "Duplicidades (Match & Merge)", "Linhagem & Glossário", "Governança"] as const;
type Tab = typeof TABS[number];

export default function MDMWorkbench({ dash, domains, duplicates, changes, lineage, glossary }: {
  dash: any; domains: any[]; duplicates: any[]; changes: any[]; lineage: any[]; glossary: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Plataforma · Governança de Dados</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Master Data Management (MDM)</h1>
        <p className="text-sm muted mt-0.5">O "DNA do ERP": fonte única da verdade, qualidade de dados, deduplicação, linhagem e glossário corporativo.</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Domínios & Qualidade" && <Dominios domains={domains} />}
      {tab === "Duplicidades (Match & Merge)" && <Duplicidades duplicates={duplicates} />}
      {tab === "Linhagem & Glossário" && <LinhagemGlossario lineage={lineage} glossary={glossary} />}
      {tab === "Governança" && (
        <CrudPanel table="mdm_change_requests" title="Solicitações de Mudança (governança)"
          fields={[
            { key: "domain_key", label: "Domínio", type: "select", options: DEDUP_DOMAINS, required: true },
            { key: "title", label: "Título", required: true },
            { key: "action", label: "Ação", type: "select", options: [["create","Criar"],["update","Alterar"],["inactivate","Inativar"],["reactivate","Reativar"]], default: "update" },
            { key: "status", label: "Status", type: "select", options: [["pending","Pendente"],["approved","Aprovada"],["rejected","Rejeitada"]], default: "pending" },
          ]}
          columns={[{ key: "title", label: "Solicitação" }, { key: "domain_key", label: "Domínio" }, { key: "action", label: "Ação" }, { key: "status", label: "Status" }]}
          rows={changes} emptyHint="Alterações em cadastros mestres passam por aprovação (integra com o BPM)." />
      )}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash }: { dash: any }) {
  const d = dash ?? {}; const bd: any[] = d.by_domain ?? [];
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <KPI label="Domínios governados" value={String(d.domains ?? 0)} />
        <KPI label="Qualidade média" value={`${d.avg_quality ?? 0}`} tone={scoreTone(Number(d.avg_quality))} hint="score 0-100" />
        <KPI label="Duplicados abertos" value={String(d.duplicates_open ?? 0)} tone={d.duplicates_open ? "var(--warning)" : undefined} />
        <KPI label="Mudanças pendentes" value={String(d.change_requests_pending ?? 0)} />
        <KPI label="Termos no glossário" value={String(d.glossary_terms ?? 0)} />
        <KPI label="Ligações de linhagem" value={String(d.lineage_links ?? 0)} />
      </div>
      <div className="card p-5">
        <div className="font-semibold mb-3">Qualidade por domínio</div>
        <div className="space-y-2">
          {bd.map((x) => (
            <div key={x.key} className="flex items-center gap-3">
              <div className="w-40 text-sm">{x.domain}</div>
              <div className="flex-1 h-3 rounded-full overflow-hidden" style={{ background: "var(--surface-3)" }}>
                <div className="h-full rounded-full" style={{ width: `${x.score ?? 0}%`, background: scoreTone(x.score) }} />
              </div>
              <div className="w-16 text-right text-sm font-bold tabular-nums" style={{ color: scoreTone(x.score) }}>{x.score ?? "—"}</div>
              <div className="w-20 text-right text-xs muted">{x.records ?? 0} reg.</div>
            </div>
          ))}
          {bd.length === 0 && <p className="text-sm muted">Nenhum domínio avaliado. Rode a avaliação de qualidade.</p>}
        </div>
      </div>
    </div>
  );
}

function Dominios({ domains }: { domains: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  const canAssess = ["products", "customers", "employees", "suppliers"];
  async function assess(key: string) {
    if (!supabase) return;
    setBusy(key);
    await supabase.rpc("assess_domain_quality", { p_company: COMPANY, p_domain: key });
    setBusy(null); router.refresh();
  }
  return (
    <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
      {domains.map((dom) => (
        <div key={dom.id} className="card p-4">
          <div className="flex items-center justify-between">
            <div className="font-semibold text-sm">{dom.name}</div>
            {dom.quality_score != null && <span className="text-lg font-bold tabular-nums" style={{ color: scoreTone(dom.quality_score) }}>{dom.quality_score}</span>}
          </div>
          <div className="text-xs muted mt-0.5"><code>{dom.source_table}</code> · {dom.records_count ?? 0} registros</div>
          <div className="text-xs muted mt-1">Owner: {dom.data_owner ?? "—"} · Steward: {dom.data_steward ?? "—"}</div>
          {dom.quality_score != null && (
            <div className="mt-2 h-2 rounded-full overflow-hidden" style={{ background: "var(--surface-3)" }}>
              <div className="h-full rounded-full" style={{ width: `${dom.quality_score}%`, background: scoreTone(dom.quality_score) }} />
            </div>
          )}
          {canAssess.includes(dom.domain_key) && <button onClick={() => assess(dom.domain_key)} disabled={busy === dom.domain_key} className="btn btn-sm w-full mt-3">{busy === dom.domain_key ? "Avaliando…" : "Avaliar qualidade"}</button>}
        </div>
      ))}
    </div>
  );
}

function Duplicidades({ duplicates }: { duplicates: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  async function detect(domain: string) {
    if (!supabase) return;
    setBusy(domain);
    await supabase.rpc("detect_duplicates", { p_company: COMPANY, p_domain: domain });
    setBusy(null); router.refresh();
  }
  async function merge(id: string, keep: string) {
    if (!supabase) return;
    setBusy(id);
    await supabase.rpc("merge_records", { p_duplicate: id, p_keep: keep });
    setBusy(null); router.refresh();
  }
  const pending = duplicates.filter((d) => d.status === "pending");
  return (
    <div className="space-y-3">
      <div className="card p-4 flex flex-wrap items-center gap-2">
        <span className="text-sm font-semibold mr-2">Detectar duplicados:</span>
        {DEDUP_DOMAINS.map(([k, l]) => (
          <button key={k} onClick={() => detect(k)} disabled={busy === k} className="btn btn-sm">{busy === k ? "…" : l}</button>
        ))}
      </div>
      {pending.length === 0 ? <p className="text-sm muted px-1">Nenhum candidato de duplicidade pendente. 🎉</p> : (
        <div className="space-y-2">
          {pending.map((d) => (
            <div key={d.id} className="card p-4">
              <div className="flex items-center gap-2 mb-2">
                <span className="badge badge-neutral">{d.domain_key}</span>
                <span className="badge badge-warning">{d.match_score}% match</span>
                <span className="text-xs muted">{d.reason}</span>
              </div>
              <div className="grid md:grid-cols-2 gap-3">
                <div className="surface-2 rounded-xl p-3 flex items-center justify-between" style={{ border: "1px solid var(--border)" }}>
                  <span className="text-sm">A: <strong>{d.label_a}</strong></span>
                  <button onClick={() => merge(d.id, "a")} disabled={busy === d.id} className="btn btn-primary btn-sm">Manter A</button>
                </div>
                <div className="surface-2 rounded-xl p-3 flex items-center justify-between" style={{ border: "1px solid var(--border)" }}>
                  <span className="text-sm">B: <strong>{d.label_b}</strong></span>
                  <button onClick={() => merge(d.id, "b")} disabled={busy === d.id} className="btn btn-primary btn-sm">Manter B</button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function LinhagemGlossario({ lineage, glossary }: { lineage: any[]; glossary: any[] }) {
  return (
    <div className="grid lg:grid-cols-2 gap-4">
      <div className="card p-4">
        <div className="font-semibold mb-3">Linhagem de Dados</div>
        <div className="space-y-2">
          {lineage.map((l) => (
            <div key={l.id} className="flex items-center gap-2 text-sm">
              <span className="badge badge-brand">{l.source_domain}</span>
              <span className="muted">→</span>
              <span className="font-medium">{l.target_module}</span>
              <span className="text-xs muted ml-auto">{l.description}</span>
            </div>
          ))}
          {lineage.length === 0 && <p className="text-sm muted">Sem linhagem registrada.</p>}
        </div>
      </div>
      <CrudPanel table="mdm_glossary" title="Glossário de Negócios"
        fields={[
          { key: "term", label: "Termo", required: true },
          { key: "definition", label: "Definição" },
          { key: "domain", label: "Domínio" },
          { key: "steward", label: "Steward" },
        ]}
        columns={[{ key: "term", label: "Termo" }, { key: "definition", label: "Definição" }, { key: "domain", label: "Domínio" }]}
        rows={glossary} emptyHint="Glossário corporativo (SKU, OTIF, EBITDA…)." />
    </div>
  );
}
