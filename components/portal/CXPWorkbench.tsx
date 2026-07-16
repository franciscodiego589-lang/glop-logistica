"use client";
import { Fragment, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const brl = (n: number) => (n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const TSTATUS: Record<string, string> = { open: "Aberto", in_progress: "Em andamento", waiting_customer: "Aguard. cliente", resolved: "Resolvido", closed: "Fechado" };
const TBADGE: Record<string, string> = { open: "badge-warning", in_progress: "badge-brand", waiting_customer: "badge-neutral", resolved: "badge-success", closed: "badge-neutral" };

const TABS = ["Painel", "Chamados", "RMA / Devoluções", "Usuários do Portal", "Documentos", "Base de Conhecimento"] as const;
type Tab = typeof TABS[number];

export default function CXPWorkbench({ dash, tickets, messages, rma, users, documents, articles, accounts }: {
  dash: any; tickets: any[]; messages: any[]; rma: any[]; users: any[]; documents: any[]; articles: any[]; accounts: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <div className="text-xs muted font-semibold uppercase tracking-wider">Fase 1 · Portal do Cliente Logístico</div>
          <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Portal do Cliente (CXP)</h1>
          <p className="text-sm muted mt-0.5">Timeline de entrega, tracking, chamados com SLA, RMA, documentos e comprovantes.</p>
        </div>
        <a href="/rastreio" target="_blank" className="btn btn-sm">Abrir rastreio público ↗</a>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>
      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Chamados" && <Chamados tickets={tickets} messages={messages} accounts={accounts} />}
      {tab === "RMA / Devoluções" && <RMA rma={rma} accounts={accounts} />}
      {tab === "Usuários do Portal" && <PortalUsers users={users} accounts={accounts} />}
      {tab === "Documentos" && (
        <CrudPanel table="customer_documents" title="Documentos do Cliente"
          fields={[
            { key: "account_id", label: "Cliente", type: "fk", fkTable: "crm_accounts", fkLabel: "name", required: true },
            { key: "doc_type", label: "Tipo", type: "select", options: [["invoice","Nota Fiscal"],["boleto","Boleto"],["contract","Contrato"],["coa","CoA (Certificado de Análise)"],["report","Laudo"],["order","Pedido"],["receipt","Comprovante"]], default: "invoice" },
            { key: "title", label: "Título", required: true },
            { key: "reference", label: "Referência (lote/NF)" },
            { key: "url", label: "Link do arquivo" },
            { key: "issued_at", label: "Emitido em", type: "date" },
          ]}
          columns={[
            { key: "title", label: "Documento" }, { key: "doc_type", label: "Tipo" },
            { key: "account_id", label: "Cliente" }, { key: "reference", label: "Ref." }, { key: "issued_at", label: "Emitido" },
          ]}
          rows={documents} emptyHint="Disponibilize NF-e, boletos, contratos e CoA por cliente." />
      )}
      {tab === "Base de Conhecimento" && (
        <CrudPanel table="knowledge_articles" title="Base de Conhecimento & Área Técnica"
          fields={[
            { key: "title", label: "Título", required: true },
            { key: "category", label: "Categoria" },
            { key: "article_type", label: "Tipo", type: "select", options: [["faq","FAQ"],["manual","Manual"],["spec","Ficha Técnica"],["fispq","FISPQ"],["video","Vídeo"],["training","Treinamento"]], default: "faq" },
            { key: "url", label: "Link" },
            { key: "content", label: "Conteúdo" },
            { key: "is_public", label: "Público?", type: "select", options: [["true","Sim"],["false","Interno"]], default: "true" },
          ]}
          columns={[
            { key: "title", label: "Artigo" }, { key: "category", label: "Categoria" },
            { key: "article_type", label: "Tipo" }, { key: "views", label: "Views" },
          ]}
          rows={articles} emptyHint="Manuais, fichas técnicas, FISPQ, vídeos, FAQs." />
      )}
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
      <KPI label="Chamados abertos" value={String(d.tickets_open ?? 0)} />
      <KPI label="SLA vencido" value={String(d.tickets_overdue ?? 0)} tone={d.tickets_overdue ? "var(--danger)" : undefined} />
      <KPI label="Tempo médio resolução" value={`${d.avg_resolution_h ?? 0}h`} />
      <KPI label="CSAT" value={String(d.csat ?? 0)} hint="satisfação (1-5)" />
      <KPI label="NPS" value={String(d.nps ?? 0)} tone="var(--brand)" />
      <KPI label="RMA em aberto" value={String(d.rma_open ?? 0)} tone={d.rma_open ? "var(--warning)" : undefined} />
      <KPI label="Usuários do portal" value={String(d.portal_users ?? 0)} />
      <KPI label="Documentos" value={String(d.documents ?? 0)} />
    </div>
  );
}

function Chamados({ tickets, messages, accounts }: { tickets: any[]; messages: any[]; accounts: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [expand, setExpand] = useState<string | null>(null);
  const [reply, setReply] = useState("");
  const [busy, setBusy] = useState<string | null>(null);
  const [f, setF] = useState({ account_id: "", subject: "", priority: "normal", body: "" });
  const acctName = (id: string) => accounts.find((a) => a.id === id)?.name ?? "—";

  async function create() {
    if (!supabase || !f.subject) return;
    setBusy("create");
    await supabase.rpc("open_ticket", { p_company: COMPANY, p_account: f.account_id || null, p_subject: f.subject, p_category: "general", p_priority: f.priority, p_body: f.body || null });
    setBusy(null); setOpen(false); setF({ account_id: "", subject: "", priority: "normal", body: "" }); router.refresh();
  }
  async function sendReply(id: string) {
    if (!supabase || !reply) return;
    setBusy(id);
    await supabase.rpc("reply_ticket", { p_ticket: id, p_body: reply, p_sender_type: "agent", p_new_status: null });
    setBusy(null); setReply(""); router.refresh();
  }
  async function resolve(id: string) {
    if (!supabase) return;
    setBusy(id);
    await supabase.rpc("resolve_ticket", { p_ticket: id, p_csat: null });
    setBusy(null); router.refresh();
  }
  const overdue = (t: any) => t.sla_due && new Date(t.sla_due) < new Date() && !["resolved", "closed"].includes(t.status);

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Chamados <span className="badge badge-neutral ml-1">{tickets.length}</span></div>
        <button onClick={() => setOpen((o) => !o)} className={`btn btn-sm ${open ? "" : "btn-primary"}`}>{open ? "Cancelar" : "+ Novo chamado"}</button>
      </div>
      {open && (
        <div className="card p-4 grid md:grid-cols-4 gap-3 items-end">
          <div><label className="label">Cliente</label><select value={f.account_id} onChange={(e) => setF((p) => ({ ...p, account_id: e.target.value }))} className="select"><option value="">—</option>{accounts.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}</select></div>
          <div className="md:col-span-2"><label className="label">Assunto</label><input value={f.subject} onChange={(e) => setF((p) => ({ ...p, subject: e.target.value }))} className="input" /></div>
          <div><label className="label">Prioridade</label><select value={f.priority} onChange={(e) => setF((p) => ({ ...p, priority: e.target.value }))} className="select"><option value="low">Baixa</option><option value="normal">Normal</option><option value="high">Alta</option><option value="urgent">Urgente</option></select></div>
          <div className="md:col-span-4"><textarea value={f.body} onChange={(e) => setF((p) => ({ ...p, body: e.target.value }))} className="input" style={{ height: 70, paddingTop: 8 }} placeholder="Descrição…" /></div>
          <button onClick={create} disabled={busy === "create" || !f.subject} className="btn btn-primary btn-sm">{busy === "create" ? "Abrindo…" : "Abrir chamado"}</button>
        </div>
      )}
      {tickets.length === 0 ? <p className="text-sm muted px-1">Nenhum chamado.</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead><tr><th>Nº</th><th>Assunto</th><th>Cliente</th><th>Prioridade</th><th>Status</th><th>SLA</th><th></th></tr></thead>
            <tbody>
              {tickets.map((t) => (
                <Fragment key={t.id}>
                  <tr>
                    <td className="tabular-nums font-semibold">#{t.ticket_number}</td>
                    <td>{t.subject}</td>
                    <td>{acctName(t.account_id)}</td>
                    <td className="capitalize text-xs">{t.priority}</td>
                    <td><span className={`badge ${TBADGE[t.status]}`}>{TSTATUS[t.status] ?? t.status}</span></td>
                    <td>{overdue(t) ? <span className="badge badge-danger">vencido</span> : t.sla_due ? <span className="text-xs muted">{new Date(t.sla_due).toLocaleDateString("pt-BR")}</span> : "—"}</td>
                    <td className="text-right"><button onClick={() => setExpand(expand === t.id ? null : t.id)} className="text-xs text-brand-600 hover:underline">abrir</button></td>
                  </tr>
                  {expand === t.id && (
                    <tr><td colSpan={7} className="surface-2"><div className="p-3 space-y-2">
                      {messages.filter((m) => m.ticket_id === t.id).map((m) => (
                        <div key={m.id} className={`text-sm flex ${m.sender_type === "customer" ? "" : "justify-end"}`}>
                          <div className="rounded-xl px-3 py-1.5 max-w-lg" style={{ background: m.sender_type === "customer" ? "var(--surface-3)" : "var(--brand-soft)" }}>
                            <div className="text-[10px] muted uppercase font-semibold">{m.sender_type === "customer" ? "Cliente" : "Atendente"}</div>{m.body}
                          </div>
                        </div>
                      ))}
                      {!["resolved", "closed"].includes(t.status) && (
                        <div className="flex gap-2 pt-1">
                          <input value={expand === t.id ? reply : ""} onChange={(e) => setReply(e.target.value)} className="input h-9 flex-1" placeholder="Responder…" />
                          <button onClick={() => sendReply(t.id)} disabled={busy === t.id} className="btn btn-primary btn-sm">Responder</button>
                          <button onClick={() => resolve(t.id)} disabled={busy === t.id} className="btn btn-sm">Resolver</button>
                        </div>
                      )}
                    </div></td></tr>
                  )}
                </Fragment>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function RMA({ rma, accounts }: { rma: any[]; accounts: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [f, setF] = useState({ account_id: "", rma_type: "return", reason: "" });
  const [busy, setBusy] = useState(false);
  const acctName = (id: string) => accounts.find((a) => a.id === id)?.name ?? "—";
  async function open() {
    if (!supabase || !f.reason) return;
    setBusy(true);
    await supabase.rpc("open_rma", { p_company: COMPANY, p_account: f.account_id || null, p_order: null, p_type: f.rma_type, p_reason: f.reason });
    setBusy(false); setF({ account_id: "", rma_type: "return", reason: "" }); router.refresh();
  }
  const TYPE: Record<string, string> = { return: "Devolução", exchange: "Troca", warranty: "Garantia", credit: "Crédito" };
  const RSTATUS: Record<string, string> = { requested: "Solicitado", approved: "Aprovado", rejected: "Recusado", in_transit: "Em trânsito", received: "Recebido", completed: "Concluído" };
  return (
    <div className="space-y-3">
      <div className="card p-4 grid md:grid-cols-4 gap-3 items-end">
        <div><label className="label">Cliente</label><select value={f.account_id} onChange={(e) => setF((p) => ({ ...p, account_id: e.target.value }))} className="select"><option value="">—</option>{accounts.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}</select></div>
        <div><label className="label">Tipo</label><select value={f.rma_type} onChange={(e) => setF((p) => ({ ...p, rma_type: e.target.value }))} className="select"><option value="return">Devolução</option><option value="exchange">Troca</option><option value="warranty">Garantia</option><option value="credit">Crédito</option></select></div>
        <div className="md:col-span-2"><label className="label">Motivo</label><input value={f.reason} onChange={(e) => setF((p) => ({ ...p, reason: e.target.value }))} className="input" /></div>
        <button onClick={open} disabled={busy || !f.reason} className="btn btn-primary btn-sm">Abrir RMA</button>
      </div>
      {rma.length === 0 ? <p className="text-sm muted px-1">Nenhuma solicitação de RMA.</p> : (
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Nº</th><th>Cliente</th><th>Tipo</th><th>Motivo</th><th>Status</th></tr></thead>
          <tbody>{rma.map((r) => (<tr key={r.id}><td className="tabular-nums font-semibold">#{r.rma_number}</td><td>{acctName(r.account_id)}</td><td>{TYPE[r.rma_type] ?? r.rma_type}</td><td>{r.reason}</td><td><span className="badge badge-warning">{RSTATUS[r.status] ?? r.status}</span></td></tr>))}</tbody>
        </table></div>
      )}
    </div>
  );
}

function PortalUsers({ users, accounts }: { users: any[]; accounts: any[] }) {
  const acctName = (id: string) => accounts.find((a) => a.id === id)?.name ?? "—";
  const [copied, setCopied] = useState<string | null>(null);
  return (
    <div className="space-y-3">
      <CrudPanel table="portal_users" title="Usuários do Portal"
        fields={[
          { key: "account_id", label: "Cliente", type: "fk", fkTable: "crm_accounts", fkLabel: "name", required: true },
          { key: "name", label: "Nome", required: true },
          { key: "email", label: "E-mail" },
          { key: "portal_role", label: "Perfil", type: "select", options: [["admin","Administrador"],["buyer","Comprador"],["finance","Financeiro"],["technical","Técnico"]], default: "buyer" },
        ]}
        columns={[
          { key: "name", label: "Usuário" }, { key: "account_id", label: "Cliente" },
          { key: "email", label: "E-mail" }, { key: "portal_role", label: "Perfil" },
        ]}
        rows={users} emptyHint="Cadastre usuários do cliente. Cada um recebe um código de acesso à área do cliente." />
      {users.length > 0 && (
        <div className="card p-4">
          <div className="font-semibold text-sm mb-2">Códigos de acesso (área do cliente)</div>
          <div className="space-y-1.5">
            {users.map((u) => (
              <div key={u.id} className="flex items-center gap-2 text-sm">
                <span className="flex-1">{u.name} · <span className="muted">{acctName(u.account_id)}</span></span>
                <span className="text-xs muted">🔒 token protegido (não exposto por segurança)</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
