"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Cotação Comparativa", "Conectores", "Operações", "Credenciais", "Logs"] as const;
const PROV_LABEL = (p: string) => ({ correios: "Correios", jadlog: "Jadlog", braspress: "Braspress", total_express: "Total Express", loggi: "Loggi", mercado_envios: "Mercado Envios", shopee_xpress: "Shopee Xpress", azul_cargo: "Azul Cargo", generic_rest: "REST genérico", generic_soap: "SOAP genérico", custom: "Custom" } as any)[p] ?? p;
const stColor = (s: string) => ({ active: "#16a34a", inactive: "#64748b", error: "#dc2626" } as any)[s] ?? "#64748b";

export default function CarrierHubWorkbench({ dash, connectors, operations, credentials, logs }: {
  dash: any; connectors: any[]; operations: any[]; credentials: any[]; logs: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState("");
  const [qForm, setQForm] = useState({ weight: "2", value: "100", zone: "capital" });
  const [quotes, setQuotes] = useState<any[] | null>(null);
  const d = dash ?? {};
  const opsByConn = useMemo(() => { const m: Record<string, number> = {}; for (const o of operations) if (o.enabled) m[o.connector_id] = (m[o.connector_id] ?? 0) + 1; return m; }, [operations]);
  const credByConn = useMemo(() => { const m: Record<string, any[]> = {}; for (const c of credentials) (m[c.connector_id] ??= []).push(c); return m; }, [credentials]);

  async function testConn(id: string) {
    if (!supabase) return; setBusy(id);
    const { data, error } = await supabase.rpc("test_connector", { p_company: COMPANY, p_connector: id });
    setBusy("");
    if (error) alert("Erro: " + error.message);
    else alert(data?.ready ? "✅ Conector pronto (URL + credenciais + operações)." : `⚠️ Ainda não pronto: URL=${data?.has_url ? "ok" : "falta"}, credenciais=${data?.credentials}, operações=${data?.operations}`);
    router.refresh();
  }
  async function runQuotes() {
    if (!supabase) return; setBusy("quote");
    const rs = await Promise.all(connectors.map(async (c) => {
      const { data } = await supabase.rpc("connector_quote", { p_company: COMPANY, p_connector: c.id, p_weight_kg: Number(qForm.weight), p_declared_value: Number(qForm.value), p_zone: qForm.zone });
      return { code: c.code, name: c.name, ...(data ?? {}) };
    }));
    setQuotes(rs.filter((r) => r.freight != null).sort((a, b) => a.freight - b.freight));
    setBusy("");
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🔌</div>
        <div>
          <h1 className="text-xl font-bold">Integrações de Transportadoras</h1>
          <p className="text-sm muted">Hub de API: Correios e qualquer transportadora · cotação · etiqueta · rastreio · credenciais · logs</p>
        </div>
      </div>

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="space-y-4">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="Conectores" value={d.connectors ?? 0} accent />
            <KpiCard label="Ativos" value={d.active ?? 0} />
            <KpiCard label="Com erro" value={d.error ?? 0} tone={d.error ? "danger" : undefined} />
            <KpiCard label="Operações mapeadas" value={d.operations ?? 0} />
            <KpiCard label="Chamadas hoje" value={d.calls_today ?? 0} />
            <KpiCard label="Falhas hoje" value={d.calls_failed_today ?? 0} tone={d.calls_failed_today ? "warning" : undefined} />
            <KpiCard label="Latência média" value={d.avg_latency_ms != null ? `${d.avg_latency_ms}ms` : "—"} />
          </div>
          <div className="card p-4">
            <div className="font-semibold text-sm mb-2">Por provedor</div>
            <div className="flex flex-wrap gap-2">
              {Object.entries(d.by_provider ?? {}).map(([k, v]) => <span key={k} className="badge badge-neutral">{PROV_LABEL(k)}: {String(v)}</span>)}
              {Object.keys(d.by_provider ?? {}).length === 0 && <span className="text-sm muted">Nenhum conector ainda — cadastre na aba Conectores.</span>}
            </div>
          </div>
          <div className="card p-3 text-xs muted">💡 A execução real das APIs (Correios, Jadlog, etc.) roda numa Edge Function <code>carrier-gateway</code> com as credenciais configuradas. Enquanto ela não é publicada, a cotação usa um estimador determinístico (marcado como "simulado") para você já comparar transportadoras.</div>
        </div>
      )}

      {tab === "Cotação Comparativa" && (
        <div className="space-y-4">
          <div className="card p-4 flex flex-wrap items-end gap-3">
            <div className="font-semibold text-sm w-full">📦 Cotar em todas as transportadoras de uma vez</div>
            <label className="text-xs muted">Peso (kg)<input type="number" step="0.1" value={qForm.weight} onChange={(e) => setQForm({ ...qForm, weight: e.target.value })} className="input block mt-0.5 w-24" /></label>
            <label className="text-xs muted">Valor (R$)<input type="number" value={qForm.value} onChange={(e) => setQForm({ ...qForm, value: e.target.value })} className="input block mt-0.5 w-28" /></label>
            <label className="text-xs muted">Zona<select value={qForm.zone} onChange={(e) => setQForm({ ...qForm, zone: e.target.value })} className="input block mt-0.5"><option value="capital">Capital</option><option value="interior">Interior</option><option value="outro_estado">Outro estado</option><option value="remoto">Remoto</option></select></label>
            <button onClick={runQuotes} disabled={busy === "quote"} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">{busy === "quote" ? "Cotando…" : "Cotar todas"}</button>
          </div>
          {quotes && (quotes.length === 0 ? <p className="text-sm muted px-1">Nenhum conector para cotar.</p> : (
            <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">#</th><th className="px-3">Transportadora</th><th className="px-3 text-right">Frete</th><th className="px-3 text-right">Prazo</th><th className="px-3"></th></tr></thead>
              <tbody>{quotes.map((q, i) => (
                <tr key={q.code} className="border-b last:border-0" style={{ borderColor: "var(--border)", background: i === 0 ? "rgba(22,163,74,.06)" : undefined }}>
                  <td className="py-2 px-3 font-bold">{i + 1}º</td>
                  <td className="px-3 font-medium">{q.name ?? q.code} {i === 0 && <span className="badge badge-success ml-1">mais barato</span>}</td>
                  <td className="px-3 text-right tabular-nums font-semibold">R$ {Number(q.freight).toLocaleString("pt-BR", { minimumFractionDigits: 2 })}</td>
                  <td className="px-3 text-right">{q.eta_days}d</td>
                  <td className="px-3 text-xs muted">{q.simulated ? "estimado" : "API"}</td>
                </tr>))}</tbody>
            </table></div>
          ))}
        </div>
      )}

      {tab === "Conectores" && (
        <div className="space-y-3">
          {connectors.map((c) => (
            <div key={c.id} className="card p-4" style={{ borderLeft: `3px solid ${stColor(c.status)}` }}>
              <div className="flex flex-wrap items-center gap-2">
                <span className="font-semibold text-sm">{c.name ?? c.code}</span>
                <span className="badge badge-neutral">{PROV_LABEL(c.provider)}</span>
                <span className="badge" style={{ background: stColor(c.status), color: "#fff" }}>{c.status}</span>
                <span className="text-xs muted">{c.environment} · auth: {c.auth_type}</span>
                <span className="text-xs muted ml-auto">{opsByConn[c.id] ?? 0} operações · {(credByConn[c.id] ?? []).filter((x: any) => x.key_value).length}/{(credByConn[c.id] ?? []).length} credenciais</span>
              </div>
              <div className="text-xs muted mt-1 font-mono">{c.base_url}</div>
              {c.last_error && <div className="text-xs mt-1" style={{ color: "var(--danger)" }}>último erro: {c.last_error}</div>}
              <button onClick={() => testConn(c.id)} disabled={busy === c.id} className="text-xs text-brand-600 hover:underline mt-2">🔍 testar prontidão</button>
            </div>
          ))}
          <CrudPanel table="carrier_connectors" title="Novo conector" rows={[]}
            emptyHint="Cadastre Correios ou qualquer transportadora/plataforma por API."
            fields={[
              { key: "code", label: "Código", required: true }, { key: "name", label: "Nome" },
              { key: "provider", label: "Provedor", type: "select", options: [["correios", "Correios"], ["jadlog", "Jadlog"], ["braspress", "Braspress"], ["total_express", "Total Express"], ["loggi", "Loggi"], ["mercado_envios", "Mercado Envios"], ["shopee_xpress", "Shopee Xpress"], ["azul_cargo", "Azul Cargo"], ["generic_rest", "REST genérico"], ["generic_soap", "SOAP genérico"], ["custom", "Custom"]], default: "generic_rest" },
              { key: "base_url", label: "Base URL" },
              { key: "auth_type", label: "Autenticação", type: "select", options: [["none", "Nenhuma"], ["apikey", "API Key"], ["bearer_token", "Bearer Token"], ["basic", "Basic"], ["oauth2", "OAuth2"], ["user_pass", "Usuário/Senha"], ["contract_card", "Contrato/Cartão (Correios)"]], default: "bearer_token" },
              { key: "environment", label: "Ambiente", type: "select", options: [["production", "Produção"], ["sandbox", "Sandbox"]], default: "production" },
            ]}
            columns={[]} />
        </div>
      )}

      {tab === "Operações" && (
        <CrudPanel table="connector_operations" title="Operações mapeadas" rows={operations}
          emptyHint="Mapeie cotação, etiqueta, rastreio, coleta, cancelamento por conector."
          fields={[
            { key: "connector_id", label: "Conector", type: "fk", fkTable: "carrier_connectors", fkLabel: "code", required: true },
            { key: "operation", label: "Operação", type: "select", options: [["quote", "Cotação"], ["ship", "Expedir"], ["label", "Etiqueta/PLP"], ["track", "Rastreio"], ["cancel", "Cancelar"], ["pickup", "Coleta"], ["status", "Status"], ["manifest", "Manifesto"]], default: "quote" },
            { key: "http_method", label: "Método", type: "select", options: [["GET", "GET"], ["POST", "POST"], ["PUT", "PUT"], ["PATCH", "PATCH"], ["DELETE", "DELETE"]], default: "POST" },
            { key: "path", label: "Caminho (path)" },
          ]}
          columns={[{ key: "operation", label: "Operação" }, { key: "http_method", label: "Método" }, { key: "path", label: "Path" }, { key: "enabled", label: "Ativa" }]} />
      )}

      {tab === "Credenciais" && (
        <CrudPanel table="connector_credentials" title="Credenciais (cofre)" rows={credentials.map((c) => ({ ...c, key_value: c.key_value ? "••••••" : "" }))}
          emptyHint="Chaves/tokens/usuário-senha/contrato por conector. Marque como secreto."
          fields={[
            { key: "connector_id", label: "Conector", type: "fk", fkTable: "carrier_connectors", fkLabel: "code", required: true },
            { key: "key_name", label: "Nome da chave", required: true }, { key: "key_value", label: "Valor" },
            { key: "is_secret", label: "Secreto", type: "select", options: [["true", "Sim"], ["false", "Não"]], default: "true" },
            { key: "valid_to", label: "Válida até", type: "date" },
          ]}
          columns={[{ key: "connector_id", label: "Conector" }, { key: "key_name", label: "Chave" }, { key: "key_value", label: "Valor" }, { key: "valid_to", label: "Válida até" }]} />
      )}

      {tab === "Logs" && (
        logs.length === 0 ? <p className="text-sm muted px-1">Sem chamadas registradas.</p> : (
          <div className="card p-0 overflow-x-auto"><table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Quando</th><th className="px-3">Operação</th><th className="px-3 text-center">HTTP</th><th className="px-3 text-right">Latência</th><th className="px-3">Resultado</th></tr></thead>
            <tbody>{logs.map((l) => (
              <tr key={l.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                <td className="py-2 px-3 text-xs">{String(l.requested_at ?? "").slice(0, 16).replace("T", " ")}</td>
                <td className="px-3">{l.operation}</td><td className="px-3 text-center tabular-nums">{l.http_status ?? "—"}</td>
                <td className="px-3 text-right tabular-nums">{l.latency_ms != null ? `${l.latency_ms}ms` : "—"}</td>
                <td className="px-3"><span className={`badge ${l.success ? "badge-success" : "badge-danger"}`}>{l.success ? "ok" : "falha"}</span></td>
              </tr>))}</tbody>
          </table></div>
        )
      )}
    </div>
  );
}
