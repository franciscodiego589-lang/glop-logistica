"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Processos", "Documentos", "Recintos"] as const;
const stColor = (s: string) => ({ registered: "#64748b", in_analysis: "#6366f1", channel_assigned: "#6366f1", inspection: "#d97706", demand: "#d97706", retained: "#dc2626", released: "#16a34a", delivered: "#15803d", closed: "#0891b2", canceled: "#94a3b8" } as any)[s] ?? "#64748b";
const stLabel = (s: string) => ({ registered: "Registrado", in_analysis: "Em análise", channel_assigned: "Canal parametrizado", inspection: "Inspeção", demand: "Exigência", retained: "Retido", released: "Liberado", delivered: "Entregue", closed: "Encerrado", canceled: "Cancelado" } as any)[s] ?? s;
const chColor = (c: string) => ({ green: "#16a34a", yellow: "#eab308", red: "#dc2626", gray: "#64748b", none: "transparent" } as any)[c] ?? "transparent";
const evLabel = (e: string) => ({ arrival: "Chegada", registration: "Registro", channel_assigned: "Canal", inspection: "Inspeção", demand: "Exigência", retention: "Retenção", release: "Liberação", delivery: "Entrega", closure: "Encerramento" } as any)[e] ?? e;

export default function CMSWorkbench({ dash, processes, docs, inspections, zones, events }: {
  dash: any; processes: any[]; docs: any[]; inspections: any[]; zones: any[]; events: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState("");
  const [ch, setCh] = useState<Record<string, string>>({});
  const d = dash ?? {};
  const evByProc = useMemo(() => { const m: Record<string, any[]> = {}; for (const e of events) (m[e.customs_process_id] ??= []).push(e); return m; }, [events]);
  const docsByProc = useMemo(() => { const m: Record<string, any[]> = {}; for (const x of docs) (m[x.customs_process_id] ??= []).push(x); return m; }, [docs]);

  async function call(rpc: string, params: any, key: string) {
    if (!supabase) return; setBusy(key);
    const { error } = await supabase.rpc(rpc, params);
    setBusy("");
    if (error) { alert(error.message.includes("Não liberável") ? "🚫 " + error.message : "Erro: " + error.message); return; }
    router.refresh();
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🛃</div>
        <div>
          <h1 className="text-xl font-bold">Aduana — CMS</h1>
          <p className="text-sm muted">Desembaraço: processos · canais · documentação · inspeções · liberação · recintos alfandegados</p>
        </div>
      </div>

      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <KpiCard label="Processos" value={d.processes ?? 0} accent />
          <KpiCard label="Em desembaraço" value={d.registered ?? 0} />
          <KpiCard label="Em inspeção" value={d.in_inspection ?? 0} tone={d.in_inspection ? "warning" : undefined} />
          <KpiCard label="Retidos" value={d.retained ?? 0} tone={d.retained ? "danger" : undefined} />
          <KpiCard label="Liberados" value={d.released ?? 0} />
          <KpiCard label="Docs pendentes" value={d.docs_pending ?? 0} tone={d.docs_pending ? "warning" : undefined} />
          <KpiCard label="Desembaraço médio (dias)" value={d.avg_clearance_days ?? "—"} />
          <KpiCard label="Recintos" value={d.zones ?? 0} />
        </div>
      )}

      {tab === "Processos" && (
        <div className="space-y-3">
          {processes.length === 0 ? <p className="text-sm muted px-1">Nenhum processo aduaneiro.</p> : processes.map((p) => {
            const ev = (evByProc[p.id] ?? []).slice().sort((a: any, b: any) => String(a.event_at).localeCompare(String(b.event_at)));
            const pDocs = docsByProc[p.id] ?? [];
            return (
              <div key={p.id} className="card p-4" style={{ borderLeft: `3px solid ${stColor(p.status)}` }}>
                <div className="flex flex-wrap items-center gap-2">
                  <span className="font-semibold text-sm">{p.code}</span>
                  <span className="badge" style={{ background: stColor(p.status), color: "#fff" }}>{stLabel(p.status)}</span>
                  {p.channel !== "none" && <span className="badge" style={{ background: chColor(p.channel), color: "#fff" }}>canal {p.channel}</span>}
                  <span className="text-xs muted">{p.process_type} · {p.country ?? ""}</span>
                  <span className="text-xs muted ml-auto">{pDocs.filter((x: any) => x.status !== "approved" && x.mandatory).length} doc(s) obrig. pendente(s)</span>
                </div>
                {ev.length > 0 && (
                  <ol className="flex flex-wrap gap-2 mt-3">
                    {ev.map((e: any) => (
                      <li key={e.id} className="flex items-center gap-1 text-xs rounded-lg px-2 py-1 card">
                        <span className="h-2 w-2 rounded-full" style={{ background: "var(--brand)" }} />{evLabel(e.event_type)}
                        <span className="muted">{String(e.event_at ?? "").slice(5, 10)}</span>
                      </li>
                    ))}
                  </ol>
                )}
                <div className="flex flex-wrap items-end gap-2 mt-3">
                  <select value={ch[p.id] ?? "green"} onChange={(e) => setCh({ ...ch, [p.id]: e.target.value })} className="input w-auto text-xs">
                    <option value="green">🟢 Verde</option><option value="yellow">🟡 Amarelo</option><option value="red">🔴 Vermelho</option><option value="gray">⚫ Cinza</option>
                  </select>
                  <button onClick={() => call("set_customs_channel", { p_company: COMPANY, p_process: p.id, p_channel: ch[p.id] ?? "green" }, p.id + "c")} disabled={busy.startsWith(p.id)} className="px-3 py-2 rounded-lg card text-sm">parametrizar canal</button>
                  <button onClick={() => call("record_customs_inspection", { p_company: COMPANY, p_process: p.id, p_type: "physical", p_result: "approved", p_findings: "Conforme" }, p.id + "i")} disabled={busy.startsWith(p.id)} className="px-3 py-2 rounded-lg card text-sm">✓ inspeção OK</button>
                  <button onClick={() => call("release_customs_process", { p_company: COMPANY, p_process: p.id }, p.id + "r")} disabled={busy.startsWith(p.id) || p.status === "released"} className="px-3 py-2 rounded-lg bg-green-600 text-white text-sm font-semibold disabled:opacity-50">🛂 liberar desembaraço</button>
                </div>
              </div>
            );
          })}
          <CrudPanel table="customs_processes" title="Novo processo aduaneiro" rows={[]}
            emptyHint="Registre processos de importação/exportação/trânsito/regimes especiais."
            fields={[
              { key: "code", label: "Código", required: true },
              { key: "process_type", label: "Tipo", type: "select", options: [["import", "Importação"], ["export", "Exportação"], ["temp_admission", "Adm. Temporária"], ["temp_export", "Exp. Temporária"], ["transit", "Trânsito"], ["bonded_warehouse", "Entreposto"], ["drawback", "Drawback"], ["special_regime", "Regime especial"]], default: "import" },
              { key: "intl_shipment_id", label: "Embarque", type: "fk", fkTable: "intl_shipments", fkLabel: "code" },
              { key: "zone_id", label: "Recinto", type: "fk", fkTable: "customs_zones", fkLabel: "code" },
              { key: "country", label: "País" }, { key: "responsible", label: "Responsável" },
            ]}
            columns={[]} />
        </div>
      )}

      {tab === "Documentos" && (
        <CrudPanel table="customs_documents" title="Documentação aduaneira" rows={docs}
          emptyHint="B/L, AWB, packing list, invoice, certificados, licenças, autorizações, manifestos."
          fields={[
            { key: "customs_process_id", label: "Processo", type: "fk", fkTable: "customs_processes", fkLabel: "code", required: true },
            { key: "doc_type", label: "Tipo", type: "select", options: [["bl", "B/L"], ["awb", "AWB"], ["house_bl", "House B/L"], ["master_bl", "Master B/L"], ["packing_list", "Packing List"], ["commercial_invoice", "Commercial Invoice"], ["certificate", "Certificado"], ["license", "Licença"], ["authorization", "Autorização"], ["manifest", "Manifesto"], ["declaration", "Declaração"], ["complementary", "Complementar"], ["other", "Outro"]], default: "bl" },
            { key: "number", label: "Número" }, { key: "issuer", label: "Emissor" },
            { key: "mandatory", label: "Obrigatório", type: "select", options: [["false", "Não"], ["true", "Sim"]], default: "false" },
            { key: "status", label: "Status", type: "select", options: [["pending", "Pendente"], ["submitted", "Enviado"], ["approved", "Aprovado"], ["rejected", "Rejeitado"]], default: "pending" },
            { key: "valid_to", label: "Válido até", type: "date" },
          ]}
          columns={[{ key: "doc_type", label: "Tipo" }, { key: "number", label: "Número" }, { key: "mandatory", label: "Obrig." }, { key: "status", label: "Status" }]} />
      )}

      {tab === "Recintos" && (
        <CrudPanel table="customs_zones" title="Recintos alfandegados" rows={zones}
          emptyHint="Portos, aeroportos, portos secos, recintos alfandegados, terminais, EADI."
          fields={[
            { key: "code", label: "Código", required: true }, { key: "name", label: "Nome" },
            { key: "zone_type", label: "Tipo", type: "select", options: [["seaport", "Porto marítimo"], ["airport", "Aeroporto"], ["dry_port", "Porto seco"], ["bonded_warehouse", "Recinto alfandegado"], ["terminal", "Terminal"], ["eadi", "EADI"], ["intl_logistics_center", "Centro logístico intl."], ["border_post", "Posto de fronteira"]], default: "seaport" },
            { key: "country", label: "País" }, { key: "city", label: "Cidade" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "name", label: "Nome" }, { key: "zone_type", label: "Tipo" }, { key: "city", label: "Cidade" }]} />
      )}
    </div>
  );
}
