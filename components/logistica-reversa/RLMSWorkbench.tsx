"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Painel", "Retornos", "Recalls", "Embalagens Retornáveis"] as const;
const ST_ORDER = ["requested", "authorized", "collection_scheduled", "collected", "received", "triaged", "dispositioned", "closed"];
const stColor = (s: string) => ({ requested: "#64748b", authorized: "#2563eb", rejected: "#dc2626", collection_scheduled: "#6366f1", collected: "#6366f1", received: "#d97706", triaged: "#0891b2", dispositioned: "#16a34a", closed: "#15803d" } as any)[s] ?? "#64748b";
const stLabel = (s: string) => ({ requested: "Solicitado", authorized: "Autorizado", rejected: "Negado", collection_scheduled: "Coleta agendada", collected: "Coletado", received: "Recebido", triaged: "Triado", dispositioned: "Destinado", closed: "Encerrado" } as any)[s] ?? s;
const CLASSES: [string, string][] = [["intact", "Íntegro"], ["damaged", "Avariado"], ["recoverable", "Recuperável"], ["recyclable", "Reciclável"], ["disposable", "Descartável"], ["warranty", "Garantia"], ["for_maintenance", "Manutenção"]];
const DISPS: [string, string][] = [["reintegrate", "Reintegrar ao estoque"], ["refurbish", "Recondicionar"], ["repair", "Reparar"], ["repackage", "Reembalar"], ["recycle", "Reciclar"], ["dispose", "Descartar"], ["scrap", "Sucatear"], ["return_to_supplier", "Devolver ao fornecedor"], ["reship", "Reexpedir"]];

export default function RLMSWorkbench({ dash, returns, triage, dispositions, recalls, packaging }: {
  dash: any; returns: any[]; triage: any[]; dispositions: any[]; recalls: any[]; packaging: any[];
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [busy, setBusy] = useState("");
  const [cls, setCls] = useState<Record<string, string>>({});
  const [disp, setDisp] = useState<Record<string, string>>({});
  const d = dash ?? {};
  const triByRet = useMemo(() => { const m: Record<string, any[]> = {}; for (const t of triage) (m[t.rl_return_id] ??= []).push(t); return m; }, [triage]);

  async function act(fn: () => PromiseLike<any>, key: string) {
    if (!supabase) return; setBusy(key);
    const { error } = await fn(); setBusy("");
    if (error) alert("Erro: " + error.message); else router.refresh();
  }
  const authorize = (id: string, ok: boolean) => act(() => supabase!.rpc("authorize_return", { p_company: COMPANY, p_return: id, p_approve: ok, p_valid_days: 30 }), id);
  const advance = (id: string, stage: string) => act(() => supabase!.rpc("advance_return", { p_company: COMPANY, p_return: id, p_stage: stage }), id);
  const doTriage = (id: string) => act(() => supabase!.rpc("triage_return", { p_company: COMPANY, p_return: id, p_product: "item", p_class: cls[id] || "recoverable", p_qty: 1 }), id);
  const doDisp = (id: string) => act(() => supabase!.rpc("disposition_return", { p_company: COMPANY, p_return: id, p_product: "item", p_type: disp[id] || "reintegrate", p_qty: 1, p_value: null }), id);

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">↩️</div>
        <div>
          <h1 className="text-xl font-bold">Logística Reversa — RLMS</h1>
          <p className="text-sm muted">Ciclo reverso completo: autorização · coleta · triagem · destinação · recalls · embalagens retornáveis</p>
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
          <KpiCard label="Retornos" value={d.returns ?? 0} accent />
          <KpiCard label="Aguardando autorização" value={d.pending_auth ?? 0} tone={d.pending_auth ? "warning" : undefined} />
          <KpiCard label="Em processo" value={d.in_process ?? 0} />
          <KpiCard label="Aguardando destinação" value={d.awaiting_disposition ?? 0} />
          <div className="card p-4">
            <div className="text-xs uppercase tracking-wide muted font-semibold">Taxa de reaproveitamento</div>
            <div className="mt-2 text-2xl font-bold" style={{ color: "var(--success)" }}>{d.reuse_rate != null ? `${d.reuse_rate}%` : "—"}</div>
            <div className="text-[11px] muted mt-1">reciclagem {d.recycle_rate ?? 0}% · descarte {d.dispose_rate ?? 0}%</div>
          </div>
          <KpiCard label="Valor recuperado" value={d.value_recovered != null ? `R$ ${Number(d.value_recovered).toLocaleString("pt-BR")}` : "—"} />
          <KpiCard label="Recalls ativos" value={d.recalls_active ?? 0} tone={d.recalls_active ? "warning" : undefined} />
          <KpiCard label="Embalagens fora" value={d.packaging_out ?? 0} hint={`${d.packaging_lost ?? 0} perdidas`} />
        </div>
      )}

      {tab === "Retornos" && (
        <div className="space-y-3">
          {returns.length === 0 ? <p className="text-sm muted px-1">Nenhum retorno.</p> : returns.map((r) => {
            const tri = triByRet[r.id] ?? [];
            const idx = ST_ORDER.indexOf(r.status);
            return (
              <div key={r.id} className="card p-4" style={{ borderLeft: `3px solid ${stColor(r.status)}` }}>
                <div className="flex flex-wrap items-center gap-2">
                  <span className="font-semibold text-sm">{r.code}</span>
                  <span className="badge" style={{ background: stColor(r.status), color: "#fff" }}>{stLabel(r.status)}</span>
                  <span className="text-xs muted">{r.return_type} · {r.customer_ref ?? ""} · {r.reason ?? ""}</span>
                  {r.authorization_code && <span className="text-xs muted ml-auto">{r.authorization_code} (val. {r.valid_until})</span>}
                </div>
                {/* linha do ciclo */}
                <div className="flex items-center gap-1 mt-3 flex-wrap">
                  {ST_ORDER.slice(0, 8).map((st, i) => (
                    <span key={st} className="flex items-center gap-1">
                      <span className="h-2.5 w-2.5 rounded-full" style={{ background: r.status === "rejected" ? "#dc2626" : i <= idx ? stColor(r.status) : "var(--border)" }} title={stLabel(st)} />
                      {i < 7 && <span className="w-4 h-px" style={{ background: "var(--border)" }} />}
                    </span>
                  ))}
                </div>
                {tri.length > 0 && <div className="text-xs muted mt-2">Triagem: {tri.map((t: any) => `${t.quantity}× ${CLASSES.find(([k]) => k === t.classification)?.[1] ?? t.classification}`).join(", ")}</div>}
                {/* ações contextuais */}
                <div className="flex flex-wrap items-end gap-2 mt-3">
                  {r.status === "requested" && <>
                    <button onClick={() => authorize(r.id, true)} disabled={busy === r.id} className="px-3 py-2 rounded-lg bg-green-600 text-white text-sm font-semibold">✓ autorizar (RMA)</button>
                    <button onClick={() => authorize(r.id, false)} disabled={busy === r.id} className="px-3 py-2 rounded-lg card text-sm">✕ negar</button>
                  </>}
                  {r.status === "authorized" && <button onClick={() => advance(r.id, "collection_scheduled")} disabled={busy === r.id} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">📅 agendar coleta</button>}
                  {r.status === "collection_scheduled" && <button onClick={() => advance(r.id, "collected")} disabled={busy === r.id} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">🚚 coletado</button>}
                  {r.status === "collected" && <button onClick={() => advance(r.id, "received")} disabled={busy === r.id} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">📦 receber</button>}
                  {r.status === "received" && <>
                    <select value={cls[r.id] ?? "recoverable"} onChange={(e) => setCls({ ...cls, [r.id]: e.target.value })} className="input w-auto text-xs">{CLASSES.map(([k, l]) => <option key={k} value={k}>{l}</option>)}</select>
                    <button onClick={() => doTriage(r.id)} disabled={busy === r.id} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">🔍 triar</button>
                  </>}
                  {r.status === "triaged" && <>
                    <select value={disp[r.id] ?? "reintegrate"} onChange={(e) => setDisp({ ...disp, [r.id]: e.target.value })} className="input w-auto text-xs">{DISPS.map(([k, l]) => <option key={k} value={k}>{l}</option>)}</select>
                    <button onClick={() => doDisp(r.id)} disabled={busy === r.id} className="px-3 py-2 rounded-lg bg-green-600 text-white text-sm font-semibold">♻️ destinar</button>
                  </>}
                </div>
              </div>
            );
          })}
          <CrudPanel table="rl_returns" title="Novo retorno" rows={[]}
            emptyHint="Registre solicitações de devolução/troca/recall/garantia/avaria."
            fields={[
              { key: "code", label: "Código", required: true },
              { key: "return_type", label: "Tipo", type: "select", options: [["commercial", "Devolução comercial"], ["exchange", "Troca"], ["recall", "Recall"], ["warranty", "Garantia"], ["tech_assistance", "Assistência técnica"], ["damage", "Avaria"], ["operational_error", "Erro operacional"], ["packaging", "Embalagem"], ["pallet", "Palete"], ["container", "Container"], ["equipment", "Equipamento"]], default: "commercial" },
              { key: "customer_ref", label: "Cliente" }, { key: "reason", label: "Motivo" },
              { key: "priority", label: "Prioridade", type: "select", options: [["low", "Baixa"], ["normal", "Normal"], ["high", "Alta"], ["urgent", "Urgente"]], default: "normal" },
            ]}
            columns={[]} />
        </div>
      )}

      {tab === "Recalls" && (
        <CrudPanel table="rl_recalls" title="Campanhas de recall" rows={recalls}
          emptyHint="Campanhas de recall: produto, lote, unidades afetadas, coleta, prazo."
          fields={[
            { key: "code", label: "Código", required: true }, { key: "name", label: "Nome" },
            { key: "product_ref", label: "Produto" }, { key: "lot_ref", label: "Lote" },
            { key: "severity", label: "Severidade", type: "select", options: [["low", "Baixa"], ["medium", "Média"], ["high", "Alta"], ["critical", "Crítica"]], default: "medium" },
            { key: "affected_units", label: "Unidades afetadas", type: "number" }, { key: "collected_units", label: "Coletadas", type: "number" },
            { key: "status", label: "Status", type: "select", options: [["planned", "Planejado"], ["active", "Ativo"], ["collecting", "Coletando"], ["completed", "Concluído"], ["canceled", "Cancelado"]], default: "planned" },
            { key: "deadline", label: "Prazo", type: "date" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "name", label: "Nome" }, { key: "affected_units", label: "Afetadas" }, { key: "collected_units", label: "Coletadas" }, { key: "status", label: "Status" }]} />
      )}

      {tab === "Embalagens Retornáveis" && (
        <CrudPanel table="returnable_packaging" title="Embalagens retornáveis" rows={packaging}
          emptyHint="Paletes, caixas plásticas, containers retornáveis, gaiolas, racks — com depósito e retorno."
          fields={[
            { key: "code", label: "Código", required: true },
            { key: "packaging_type", label: "Tipo", type: "select", options: [["pallet", "Palete"], ["plastic_crate", "Caixa plástica"], ["returnable_container", "Container retornável"], ["barrel", "Barril"], ["basket", "Cesto"], ["cage", "Gaiola"], ["rack", "Rack"], ["special", "Especial"]], default: "pallet" },
            { key: "owner", label: "Propriedade", type: "select", options: [["own", "Própria"], ["customer", "Cliente"], ["supplier", "Fornecedor"], ["pool", "Pool"]], default: "own" },
            { key: "status", label: "Status", type: "select", options: [["available", "Disponível"], ["in_use", "Em uso"], ["returned", "Devolvida"], ["lost", "Perdida"], ["damaged", "Danificada"]], default: "available" },
            { key: "holder_ref", label: "Com quem" }, { key: "deposit_value", label: "Depósito R$", type: "number" }, { key: "due_back", label: "Devolver até", type: "date" },
          ]}
          columns={[{ key: "code", label: "Código" }, { key: "packaging_type", label: "Tipo" }, { key: "owner", label: "Prop." }, { key: "status", label: "Status" }, { key: "due_back", label: "Devolver até" }]} />
      )}
    </div>
  );
}
