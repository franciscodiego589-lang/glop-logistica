"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const brl = (n: number) => (n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const k = (n: number) => (n ?? 0).toLocaleString("pt-BR", { maximumFractionDigits: 0 });

const TABS = ["Painel","Pipeline","Leads","Clientes","Atividades","Propostas","Campanhas"] as const;
type Tab = typeof TABS[number];

export default function CRMWorkbench({ dash, forecast, stages, accounts, leads, opportunities, activities, proposals, campaigns }: {
  dash: any; forecast: any[]; stages: any[]; accounts: any[]; leads: any[]; opportunities: any[]; activities: any[]; proposals: any[]; campaigns: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Core Comercial</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">CRM & Vendas (ECSP)</h1>
        <p className="text-sm muted mt-0.5">Contas 360°, leads, pipeline visual, oportunidades e IA comercial — venda ganha lança direto no Financeiro.</p>
      </div>

      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} forecast={forecast} />}
      {tab === "Pipeline" && <Pipeline stages={stages} opportunities={opportunities} accounts={accounts} />}
      {tab === "Leads" && <Leads leads={leads} />}
      {tab === "Clientes" && (
        <CrudPanel table="crm_accounts" title="Clientes / Contas (visão 360°)"
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "account_type", label: "Tipo", type: "select", options: [["company","Empresa (PJ)"],["person","Pessoa (PF)"],["distributor","Distribuidor"],["clinic","Clínica"],["franchise","Franquia"],["reseller","Revendedor"],["marketplace","Marketplace"]], default: "company" },
            { key: "segment", label: "Segmento" }, { key: "classification", label: "Classificação (A/B/C)" },
            { key: "document", label: "CNPJ/CPF" }, { key: "email", label: "E-mail" }, { key: "phone", label: "Telefone" },
            { key: "city", label: "Cidade" }, { key: "state", label: "UF" },
            { key: "credit_limit", label: "Limite de crédito", type: "number" }, { key: "payment_terms", label: "Cond. pagamento" },
            { key: "owner", label: "Responsável" },
            { key: "health", label: "Saúde", type: "select", options: [["healthy","Saudável"],["neutral","Neutra"],["at_risk","Em risco"]], default: "healthy" },
            { key: "nps", label: "NPS (0-10)", type: "number" },
          ]}
          columns={[
            { key: "name", label: "Cliente" }, { key: "account_type", label: "Tipo" }, { key: "segment", label: "Segmento" },
            { key: "owner", label: "Responsável" }, { key: "health", label: "Saúde" }, { key: "nps", label: "NPS" },
          ]}
          rows={accounts} emptyHint="Cadastre clientes, distribuidores, clínicas, parceiros…" />
      )}
      {tab === "Atividades" && <Atividades activities={activities} accounts={accounts} />}
      {tab === "Propostas" && (
        <CrudPanel table="crm_proposals" title="Propostas Comerciais"
          fields={[
            { key: "account_id", label: "Cliente", type: "fk", fkTable: "crm_accounts", fkLabel: "name" },
            { key: "title", label: "Título", required: true },
            { key: "amount", label: "Valor", type: "number", required: true },
            { key: "status", label: "Status", type: "select", options: [["draft","Rascunho"],["sent","Enviada"],["accepted","Aceita"],["rejected","Recusada"]], default: "draft" },
            { key: "valid_until", label: "Válida até", type: "date" },
            { key: "version_label", label: "Versão" },
          ]}
          columns={[
            { key: "title", label: "Proposta" }, { key: "account_id", label: "Cliente" },
            { key: "amount", label: "Valor", fmt: (v) => brl(Number(v)) }, { key: "status", label: "Status" },
            { key: "valid_until", label: "Validade" },
          ]}
          rows={proposals} emptyHint="Gere propostas por cliente/oportunidade." />
      )}
      {tab === "Campanhas" && (
        <CrudPanel table="crm_campaigns" title="Campanhas"
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "channel", label: "Canal", type: "select", options: [["whatsapp","WhatsApp"],["instagram","Instagram"],["email","E-mail"],["sms","SMS"],["ads","Google/Meta Ads"],["event","Feira/Evento"]] },
            { key: "budget", label: "Orçamento", type: "number" },
            { key: "start_date", label: "Início", type: "date" }, { key: "end_date", label: "Fim", type: "date" },
            { key: "status", label: "Status", type: "select", options: [["planned","Planejada"],["running","Ativa"],["done","Encerrada"]], default: "planned" },
          ]}
          columns={[
            { key: "name", label: "Campanha" }, { key: "channel", label: "Canal" },
            { key: "budget", label: "Orçamento", fmt: (v) => v ? brl(Number(v)) : "—" },
            { key: "leads_generated", label: "Leads" }, { key: "status", label: "Status" },
          ]}
          rows={campaigns} emptyHint="Marketing, promoções, eventos, e-mail/WhatsApp." />
      )}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}

function Painel({ dash, forecast }: { dash: any; forecast: any[] }) {
  const d = dash ?? {};
  const winRate = (d.won_count + d.lost_count) > 0 ? Math.round((d.won_count / (d.won_count + d.lost_count)) * 100) : 0;
  const maxF = Math.max(...forecast.map((f) => Number(f.pipeline)), 1);
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <KPI label="Clientes" value={String(d.accounts ?? 0)} />
        <KPI label="Leads abertos" value={String(d.leads_open ?? 0)} />
        <KPI label="Oportunidades abertas" value={String(d.opps_open ?? 0)} />
        <KPI label="Pipeline" value={`R$ ${k(Number(d.pipeline_value ?? 0))}`} tone="var(--brand)" />
        <KPI label="Pipeline ponderado" value={`R$ ${k(Number(d.weighted_pipeline ?? 0))}`} hint="valor × probabilidade" />
        <KPI label="Ganhos (ano)" value={`R$ ${k(Number(d.won_value_ytd ?? 0))}`} tone="var(--success)" hint={`${d.won_count ?? 0} negócios`} />
        <KPI label="Taxa de conversão" value={`${winRate}%`} />
        <KPI label="Ticket médio" value={`R$ ${k(Number(d.avg_ticket ?? 0))}`} />
      </div>
      {forecast.length > 0 && (
        <div className="card p-5">
          <div className="font-semibold mb-3">Forecast de vendas (pipeline por mês)</div>
          <div className="flex items-end gap-2 h-40">
            {forecast.map((f) => (
              <div key={f.month} className="flex-1 flex flex-col items-center justify-end gap-1" title={`${f.month}: pipeline R$ ${brl(Number(f.pipeline))} · ponderado R$ ${brl(Number(f.weighted))}`}>
                <div className="w-full rounded-t relative" style={{ height: `${(Number(f.pipeline) / maxF) * 100}%`, background: "var(--surface-3)", minHeight: 4 }}>
                  <div className="absolute bottom-0 left-0 right-0 rounded-t" style={{ height: `${(Number(f.weighted) / Number(f.pipeline || 1)) * 100}%`, background: "var(--brand)" }} />
                </div>
                <div className="text-[10px] muted">{f.month.slice(5)}</div>
              </div>
            ))}
          </div>
          <div className="text-xs muted mt-2">Barra clara = pipeline total · barra azul = ponderado pela probabilidade.</div>
        </div>
      )}
    </div>
  );
}

// ── Pipeline Kanban ─────────────────────────────────────────────────────────
function Pipeline({ stages, opportunities, accounts }: { stages: any[]; opportunities: any[]; accounts: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [f, setF] = useState({ title: "", account_id: "", amount: "", owner: "", expected_close: "" });
  const activeStages = useMemo(() => stages.filter((s) => !s.is_lost).sort((a, b) => a.order_index - b.order_index), [stages]);
  const firstStage = activeStages[0];
  const acctName = (id: string) => accounts.find((a) => a.id === id)?.name ?? "—";

  async function move(oppId: string, stageId: string) {
    if (!supabase) return;
    await supabase.rpc("move_opportunity", { p_opp: oppId, p_stage: stageId });
    router.refresh();
  }
  async function create() {
    if (!supabase || !f.title || !firstStage) return;
    setBusy(true);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    await supabase.from("crm_opportunities").insert({
      tenant_id: (comp as any)?.tenant_id, company_id: COMPANY, title: f.title, account_id: f.account_id || null,
      pipeline_id: firstStage.pipeline_id, stage_id: firstStage.id, probability: firstStage.probability,
      amount: Number(f.amount) || 0, owner: f.owner || null, expected_close: f.expected_close || null, status: "open",
    });
    setBusy(false); setOpen(false); setF({ title: "", account_id: "", amount: "", owner: "", expected_close: "" }); router.refresh();
  }

  const byStage = (sid: string) => opportunities.filter((o) => o.stage_id === sid && o.status === "open");
  const stageTotal = (sid: string) => byStage(sid).reduce((s, o) => s + Number(o.amount), 0);

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Pipeline de Vendas</div>
        <button onClick={() => setOpen((o) => !o)} className={`btn btn-sm ${open ? "" : "btn-primary"}`}>{open ? "Cancelar" : "+ Nova oportunidade"}</button>
      </div>
      {open && (
        <div className="card p-4 grid md:grid-cols-5 gap-3 items-end">
          <div className="md:col-span-2"><label className="label">Título</label><input value={f.title} onChange={(e) => setF((p) => ({ ...p, title: e.target.value }))} className="input" /></div>
          <div><label className="label">Cliente</label><select value={f.account_id} onChange={(e) => setF((p) => ({ ...p, account_id: e.target.value }))} className="select"><option value="">—</option>{accounts.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}</select></div>
          <div><label className="label">Valor</label><input type="number" value={f.amount} onChange={(e) => setF((p) => ({ ...p, amount: e.target.value }))} className="input" /></div>
          <div><label className="label">Previsão</label><input type="date" value={f.expected_close} onChange={(e) => setF((p) => ({ ...p, expected_close: e.target.value }))} className="input" /></div>
          <button onClick={create} disabled={busy || !f.title} className="btn btn-primary btn-sm md:col-span-5 md:w-40">{busy ? "Criando…" : "Criar oportunidade"}</button>
        </div>
      )}

      <div className="flex gap-3 overflow-x-auto pb-2">
        {activeStages.map((s) => {
          const opps = byStage(s.id);
          return (
            <div key={s.id} className="shrink-0 w-64">
              <div className="flex items-center justify-between px-1 mb-2">
                <div className="text-sm font-semibold">{s.name}</div>
                <span className="badge badge-neutral">{opps.length}</span>
              </div>
              <div className="text-xs muted px-1 mb-2 tabular-nums">R$ {k(stageTotal(s.id))} · {s.probability}%</div>
              <div className="space-y-2">
                {opps.map((o) => (
                  <div key={o.id} className="card p-3 card-hover">
                    <div className="font-medium text-sm leading-tight">{o.title}</div>
                    <div className="text-xs muted mt-1">{acctName(o.account_id)}</div>
                    <div className="text-sm font-bold tabular-nums mt-1">R$ {brl(Number(o.amount))}</div>
                    <select value="" onChange={(e) => e.target.value && move(o.id, e.target.value)}
                      className="select h-8 text-xs mt-2" style={{ background: "var(--surface-2)" }}>
                      <option value="">mover para…</option>
                      {stages.filter((st) => st.id !== o.stage_id).sort((a, b) => a.order_index - b.order_index).map((st) => (
                        <option key={st.id} value={st.id}>{st.is_won ? "✓ " : st.is_lost ? "✕ " : ""}{st.name}</option>
                      ))}
                    </select>
                  </div>
                ))}
                {opps.length === 0 && <div className="text-xs muted px-1 py-4 text-center rounded-xl" style={{ border: "1px dashed var(--border)" }}>vazio</div>}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function Leads({ leads }: { leads: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  async function convert(id: string) {
    if (!supabase) return;
    setBusy(id);
    await supabase.rpc("convert_lead", { p_lead: id });
    setBusy(null); router.refresh();
  }
  const badge = (s: string) => ({ new: "badge-brand", qualified: "badge-warning", converted: "badge-success", lost: "badge-danger" } as any)[s] ?? "badge-neutral";
  return (
    <div className="space-y-3">
      <CrudPanel table="crm_leads" title="Leads"
        fields={[
          { key: "name", label: "Nome", required: true },
          { key: "company_name", label: "Empresa" },
          { key: "source", label: "Origem", type: "select", options: [["Site","Site"],["Landing Page","Landing Page"],["WhatsApp","WhatsApp"],["Instagram","Instagram"],["Facebook","Facebook"],["LinkedIn","LinkedIn"],["Google Ads","Google Ads"],["Feira","Feira/Evento"],["Indicação","Indicação"],["Importação","Importação"]] },
          { key: "email", label: "E-mail" }, { key: "phone", label: "Telefone" },
          { key: "estimated_value", label: "Valor estimado", type: "number" },
          { key: "score", label: "Score", type: "number", default: "0" },
          { key: "owner", label: "Responsável" },
        ]}
        columns={[
          { key: "name", label: "Lead" }, { key: "company_name", label: "Empresa" }, { key: "source", label: "Origem" },
          { key: "estimated_value", label: "Valor est.", fmt: (v) => v ? brl(Number(v)) : "—" },
          { key: "status", label: "Status", fmt: (v) => v },
        ]}
        rows={leads} emptyHint="Capture leads de todos os canais." />

      <div className="card p-0 overflow-x-auto">
        <table className="tbl">
          <thead><tr><th>Lead</th><th>Origem</th><th className="text-right">Valor est.</th><th>Status</th><th></th></tr></thead>
          <tbody>
            {leads.map((l) => (
              <tr key={l.id}>
                <td><div className="font-medium">{l.name}</div><div className="text-xs muted">{l.company_name ?? "—"}</div></td>
                <td>{l.source ?? "—"}</td>
                <td className="text-right tabular-nums">{l.estimated_value ? brl(Number(l.estimated_value)) : "—"}</td>
                <td><span className={`badge ${badge(l.status)}`}>{l.status}</span></td>
                <td className="text-right">{l.status !== "converted" && l.status !== "lost" && <button onClick={() => convert(l.id)} disabled={busy === l.id} className="btn btn-primary btn-sm">{busy === l.id ? "…" : "Converter"}</button>}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function Atividades({ activities, accounts }: { activities: any[]; accounts: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  async function done(id: string) {
    if (!supabase) return;
    await supabase.from("crm_activities").update({ done: true, done_at: new Date().toISOString() }).eq("id", id);
    router.refresh();
  }
  const icon = (t: string) => ({ call: "📞", meeting: "🤝", whatsapp: "💬", email: "✉️", visit: "📍", task: "✔️" } as any)[t] ?? "•";
  return (
    <div className="space-y-3">
      <CrudPanel table="crm_activities" title="Atividades & Agenda"
        fields={[
          { key: "subject", label: "Assunto", required: true },
          { key: "activity_type", label: "Tipo", type: "select", options: [["task","Tarefa"],["call","Ligação"],["meeting","Reunião"],["whatsapp","WhatsApp"],["email","E-mail"],["visit","Visita"]], default: "task" },
          { key: "account_id", label: "Cliente", type: "fk", fkTable: "crm_accounts", fkLabel: "name" },
          { key: "due_at", label: "Quando", type: "date" },
          { key: "owner", label: "Responsável" },
          { key: "notes", label: "Notas" },
        ]}
        columns={[
          { key: "subject", label: "Assunto" }, { key: "activity_type", label: "Tipo" },
          { key: "account_id", label: "Cliente" }, { key: "due_at", label: "Quando" },
        ]}
        rows={activities} emptyHint="Registre ligações, reuniões, visitas e follow-ups." />
      {activities.filter((a) => !a.done).length > 0 && (
        <div className="card p-4">
          <div className="font-semibold text-sm mb-2">Pendentes</div>
          <div className="space-y-2">
            {activities.filter((a) => !a.done).map((a) => (
              <div key={a.id} className="flex items-center gap-3 text-sm">
                <span>{icon(a.activity_type)}</span>
                <span className="flex-1">{a.subject}</span>
                <span className="text-xs muted">{a.due_at ? new Date(a.due_at).toLocaleDateString("pt-BR") : "—"}</span>
                <button onClick={() => done(a.id)} className="btn btn-sm">concluir</button>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
