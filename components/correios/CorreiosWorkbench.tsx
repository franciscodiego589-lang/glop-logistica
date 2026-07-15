"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (n: any) => (n == null ? "—" : Number(n).toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 2 }));

const TABS = ["Painel", "Simulador de Frete", "Objetos", "Auditoria de Fretes", "PLPs", "Contratos", "Serviços"] as const;

export default function CorreiosWorkbench({ dash, objects, divergences, plps, contracts, services }:
  { dash: any; objects: any[]; divergences: any[]; plps: any[]; contracts: any[]; services: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const svcName = useMemo(() => Object.fromEntries(services.map((s) => [s.id, s.name])), [services]);

  async function call(rpc: string, label: string) {
    if (!supabase) return;
    setBusy(rpc); setMsg(null);
    const { data, error } = await supabase.rpc(rpc, { p_company: COMPANY });
    setBusy(null);
    setMsg(error ? error.message : `${label}: ${data ?? 0}`);
    router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">📮</div>
        <div>
          <h1 className="text-xl font-bold">Correios Management System</h1>
          <p className="text-sm muted">Contratos · PLP · objetos · SRO · auditoria de fretes · SLA</p>
        </div>
        <div className="ml-auto flex gap-2">
          <button onClick={() => call("correios_insights", "Insights")} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>IA</button>
          <button onClick={() => call("audit_postal_freight", "Divergências")} disabled={!!busy} className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{busy === "audit_postal_freight" ? "Auditando…" : "⚡ Auditar fretes"}</button>
        </div>
      </div>
      {msg && <div className="text-sm text-brand-500 px-1">{msg}</div>}

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <KpiCard label="Aguardando postagem" value={dash?.awaiting_post ?? "—"} accent />
          <KpiCard label="Em trânsito" value={dash?.in_transit ?? "—"} />
          <KpiCard label="Entregues" value={dash?.delivered ?? "—"} />
          <KpiCard label="Devolvidos" value={dash?.returned ?? "—"} />
          <KpiCard label="Frete contratado" value={money(dash?.freight_contracted)} />
          <KpiCard label="Frete cobrado" value={money(dash?.freight_charged)} />
          <KpiCard label="Divergências (R$)" value={money(dash?.divergence_total)} hint="a contestar" />
          <KpiCard label="PLPs abertas" value={dash?.open_plps ?? "—"} />
        </div>
      )}

      {tab === "Simulador de Frete" && <FreightSimulator services={services} />}

      {tab === "Objetos" && (
        objects.length === 0 ? <p className="text-sm muted px-1">Nenhum objeto postal ainda.</p> : (
          <div className="card p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-3">Rastreio</th><th className="px-3">Serviço</th><th className="px-3">Destino</th><th className="px-3">Peso</th><th className="px-3">Frete</th><th className="px-3">Status</th>
              </tr></thead>
              <tbody>
                {objects.map((o) => (
                  <tr key={o.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                    <td className="py-2 px-3 font-mono text-xs">{o.tracking_code ?? o.id.slice(0, 8)}</td>
                    <td className="px-3">{o.service_id ? svcName[o.service_id] ?? "—" : "—"}</td>
                    <td className="px-3">{[o.dest_city, o.dest_uf].filter(Boolean).join("/") || o.dest_cep || "—"}</td>
                    <td className="px-3">{o.weight_g ? (o.weight_g / 1000).toFixed(2) + " kg" : "—"}</td>
                    <td className="px-3">{money(o.freight_charged ?? o.freight_contracted)}</td>
                    <td className="px-3">{o.status}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )
      )}

      {tab === "Auditoria de Fretes" && (
        <div className="space-y-2">
          <p className="text-sm muted">Compara frete contratado × cobrado e peso real × tarifado. Clique em “⚡ Auditar fretes” no topo.</p>
          {divergences.length === 0 ? <p className="text-sm muted px-1">Nenhuma divergência aberta.</p> : (
            <div className="card p-0 overflow-x-auto">
              <table className="w-full text-sm">
                <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                  <th className="py-2 px-3">Tipo</th><th className="px-3 text-right">Esperado</th><th className="px-3 text-right">Cobrado</th><th className="px-3 text-right">Diferença</th><th className="px-3">Obs</th>
                </tr></thead>
                <tbody>
                  {divergences.map((d) => (
                    <tr key={d.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                      <td className="py-2 px-3">{d.divergence_type}</td>
                      <td className="px-3 text-right">{d.divergence_type === "weight" ? d.expected_value + "g" : money(d.expected_value)}</td>
                      <td className="px-3 text-right">{d.divergence_type === "weight" ? d.charged_value + "g" : money(d.charged_value)}</td>
                      <td className="px-3 text-right text-red-500">{d.divergence_type === "weight" ? d.difference + "g" : money(d.difference)}</td>
                      <td className="px-3 muted">{d.notes}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}

      {tab === "PLPs" && (
        <CrudPanel table="plps" title="PLPs (Pré-Lista de Postagem)" rows={plps}
          emptyHint="Manifestos de postagem: agrupe objetos, feche e envie para coleta."
          fields={[
            { key: "code", label: "Código" },
            { key: "status", label: "Status", type: "select", options: [["open", "Aberta"], ["closed", "Fechada"], ["collected", "Coletada"], ["posted", "Postada"]], default: "open" },
            { key: "volumes", label: "Volumes", type: "number" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "status", label: "Status" }, { key: "volumes", label: "Volumes" }]} />
      )}

      {tab === "Contratos" && (
        <CrudPanel table="postal_contracts" title="Contratos & cartões de postagem" rows={contracts}
          emptyHint="Cadastre contratos, código administrativo e cartão de postagem."
          fields={[
            { key: "name", label: "Nome", required: true }, { key: "contract_number", label: "Nº contrato" },
            { key: "admin_code", label: "Cód. administrativo" }, { key: "posting_card", label: "Cartão de postagem" },
            { key: "valid_from", label: "Vigência início", type: "date" }, { key: "valid_to", label: "Vigência fim", type: "date" },
          ]}
          columns={[{ key: "name", label: "Nome" }, { key: "contract_number", label: "Contrato" }, { key: "posting_card", label: "Cartão" }]} />
      )}

      {tab === "Serviços" && (
        <CrudPanel table="postal_services" title="Serviços dos Correios" rows={services}
          emptyHint="SEDEX, PAC, SEDEX 10… com preço-base para o simulador."
          fields={[
            { key: "name", label: "Serviço", required: true }, { key: "code", label: "Código" },
            { key: "modality", label: "Modalidade", type: "select", options: [["express", "Expresso"], ["economic", "Econômico"], ["reverse", "Reversa"]], default: "express" },
            { key: "sla_days", label: "SLA (dias)", type: "number" },
            { key: "base_price", label: "Preço base", type: "number" }, { key: "price_per_kg", label: "Preço/kg", type: "number" },
          ]}
          columns={[{ key: "name", label: "Serviço" }, { key: "code", label: "Código" }, { key: "sla_days", label: "SLA" }, { key: "base_price", label: "Base", fmt: (v) => money(v) }]} />
      )}
    </div>
  );
}

function FreightSimulator({ services }: { services: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const [weight, setWeight] = useState("1000");
  const [declared, setDeclared] = useState("");
  const [rows, setRows] = useState<any[]>([]);
  const [busy, setBusy] = useState(false);

  async function simulate() {
    if (!supabase) return;
    setBusy(true);
    const { data } = await supabase.rpc("freight_simulator", { p_company: COMPANY, p_weight_g: Number(weight) || 0, p_declared: Number(declared) || 0 });
    setRows((data as any[]) ?? []); setBusy(false);
  }

  return (
    <div className="space-y-3 max-w-2xl">
      <div className="card p-4 flex flex-wrap gap-3 items-end">
        <div><label className="text-xs font-semibold muted">Peso (g)</label>
          <input type="number" value={weight} onChange={(e) => setWeight(e.target.value)} className="w-32 mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
        <div><label className="text-xs font-semibold muted">Valor declarado (R$)</label>
          <input type="number" value={declared} onChange={(e) => setDeclared(e.target.value)} className="w-36 mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
        <button onClick={simulate} disabled={busy || services.length === 0} className="px-4 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Simulando…" : "Simular"}</button>
      </div>
      {services.length === 0 && <p className="text-sm muted">Cadastre serviços (aba Serviços) para simular.</p>}
      {rows.length > 0 && (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Serviço</th><th className="px-3">SLA</th><th className="px-3 text-right">Preço</th></tr></thead>
            <tbody>
              {rows.map((r, i) => (
                <tr key={i} className={`border-b last:border-0 ${i === 0 ? "bg-green-500/5" : ""}`} style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-medium">{r.service}{i === 0 && <span className="ml-2 text-xs text-green-500">mais barato</span>}</td>
                  <td className="px-3">{r.sla_days ? r.sla_days + " dia(s)" : "—"}</td>
                  <td className="px-3 text-right font-semibold tabular-nums">{money(r.price)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
