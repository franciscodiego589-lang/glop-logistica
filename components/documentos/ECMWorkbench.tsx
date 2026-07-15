"use client";
import { Fragment, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const DSTATUS: Record<string, string> = { draft: "Rascunho", review: "Em revisão", approved: "Aprovado", signed: "Assinado", archived: "Arquivado", obsolete: "Obsoleto" };
const DBADGE: Record<string, string> = { draft: "badge-neutral", review: "badge-warning", approved: "badge-brand", signed: "badge-success", archived: "badge-neutral", obsolete: "badge-danger" };

const TABS = ["Painel", "Repositório", "Assinaturas", "Retenção", "Busca"] as const;
type Tab = typeof TABS[number];

export default function ECMWorkbench({ dash, folders, documents, versions, signatures, policies }: {
  dash: any; folders: any[]; documents: any[]; versions: any[]; signatures: any[]; policies: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Plataforma · Gestão Documental</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Documentos (ECM / GED)</h1>
        <p className="text-sm muted mt-0.5">Repositório corporativo: versionamento, check-in/out, assinaturas eletrônicas, retenção e busca por conteúdo.</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Repositório" && <Repositorio documents={documents} versions={versions} signatures={signatures} folders={folders} />}
      {tab === "Assinaturas" && <Assinaturas signatures={signatures} documents={documents} />}
      {tab === "Retenção" && (
        <CrudPanel table="retention_policies" title="Políticas de Retenção"
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "category", label: "Categoria" },
            { key: "retention_months", label: "Retenção (meses)", type: "number" },
            { key: "is_permanent", label: "Permanente?", type: "select", options: [["false","Não"],["true","Sim"]], default: "false" },
            { key: "legal_basis", label: "Base legal" },
            { key: "disposal_action", label: "Ação ao vencer", type: "select", options: [["review","Revisar"],["archive","Arquivar"],["dispose","Descartar"]], default: "review" },
          ]}
          columns={[{ key: "name", label: "Política" }, { key: "category", label: "Categoria" }, { key: "retention_months", label: "Meses" }, { key: "is_permanent", label: "Permanente", fmt: (v) => v ? "Sim" : "—" }, { key: "legal_basis", label: "Base legal" }]}
          rows={policies} emptyHint="Contratos, fiscais, CoA, POPs, prontuários (LGPD/ISO)." />
      )}
      {tab === "Busca" && <Busca />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash }: { dash: any }) {
  const d = dash ?? {}; const bc: Record<string, number> = d.by_category ?? {};
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <KPI label="Documentos" value={String(d.documents ?? 0)} />
        <KPI label="Assinados" value={String(d.signed ?? 0)} tone="var(--success)" />
        <KPI label="Assinaturas pendentes" value={String(d.pending_signatures ?? 0)} tone={d.pending_signatures ? "var(--warning)" : undefined} />
        <KPI label="Em edição (check-out)" value={String(d.checked_out ?? 0)} />
        <KPI label="Retenção vencendo" value={String(d.expiring_retention ?? 0)} tone={d.expiring_retention ? "var(--warning)" : undefined} />
        <KPI label="Vencidos" value={String(d.expired ?? 0)} tone={d.expired ? "var(--danger)" : undefined} />
        <KPI label="Pastas" value={String(d.folders ?? 0)} />
        <KPI label="Versões" value={String(d.versions ?? 0)} />
      </div>
      <div className="card p-5">
        <div className="font-semibold mb-3">Documentos por categoria</div>
        {Object.keys(bc).length === 0 ? <p className="text-sm muted">Sem documentos.</p> : (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            {Object.entries(bc).map(([cat, c]) => (<div key={cat} className="surface-2 rounded-xl p-3" style={{ border: "1px solid var(--border)" }}><div className="text-xs muted font-semibold uppercase">{cat}</div><div className="text-lg font-bold tabular-nums mt-1">{c}</div></div>))}
          </div>
        )}
      </div>
    </div>
  );
}

function Repositorio({ documents, versions, signatures, folders }: { documents: any[]; versions: any[]; signatures: any[]; folders: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [expand, setExpand] = useState<string | null>(null);
  const [busy, setBusy] = useState<string | null>(null);
  const [f, setF] = useState({ title: "", code: "", category: "pop", folder_id: "" });
  const folderName = (id: string) => folders.find((x) => x.id === id)?.name ?? "—";

  async function create() {
    if (!supabase || !f.title) return;
    setBusy("create");
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    await supabase.from("documents").insert({ tenant_id: (comp as any)?.tenant_id, company_id: COMPANY, title: f.title, code: f.code || null, category: f.category, folder_id: f.folder_id || null, status: "draft" });
    setBusy(null); setOpen(false); setF({ title: "", code: "", category: "pop", folder_id: "" }); router.refresh();
  }
  async function checkout(id: string) { if (!supabase) return; setBusy(id); await supabase.rpc("checkout_document", { p_document: id }); setBusy(null); router.refresh(); }
  async function checkin(id: string) { if (!supabase) return; const reason = prompt("Motivo da nova versão:") ?? "Nova versão"; setBusy(id); await supabase.rpc("checkin_document", { p_document: id, p_storage_path: null, p_reason: reason }); setBusy(null); router.refresh(); }
  async function requestSig(id: string) {
    if (!supabase) return;
    const name = prompt("Nome do signatário:"); if (!name) return;
    setBusy(id);
    await supabase.rpc("request_signatures", { p_document: id, p_signers: [{ name, email: "", order: 1 }] });
    setBusy(null); router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Documentos <span className="badge badge-neutral ml-1">{documents.length}</span></div>
        <button onClick={() => setOpen((o) => !o)} className={`btn btn-sm ${open ? "" : "btn-primary"}`}>{open ? "Cancelar" : "+ Novo documento"}</button>
      </div>
      {open && (
        <div className="card p-4 grid md:grid-cols-4 gap-3 items-end">
          <div className="md:col-span-2"><label className="label">Título</label><input value={f.title} onChange={(e) => setF((p) => ({ ...p, title: e.target.value }))} className="input" /></div>
          <div><label className="label">Código</label><input value={f.code} onChange={(e) => setF((p) => ({ ...p, code: e.target.value }))} className="input" placeholder="POP-002" /></div>
          <div><label className="label">Categoria</label><select value={f.category} onChange={(e) => setF((p) => ({ ...p, category: e.target.value }))} className="select"><option value="pop">POP</option><option value="coa">CoA/Laudo</option><option value="contract">Contrato</option><option value="fiscal">Fiscal</option><option value="technical">Ficha Técnica</option><option value="medical">Prontuário</option><option value="other">Outro</option></select></div>
          <div className="md:col-span-2"><label className="label">Pasta</label><select value={f.folder_id} onChange={(e) => setF((p) => ({ ...p, folder_id: e.target.value }))} className="select"><option value="">—</option>{folders.map((x) => <option key={x.id} value={x.id}>{x.path ?? x.name}</option>)}</select></div>
          <button onClick={create} disabled={busy === "create" || !f.title} className="btn btn-primary btn-sm">Criar</button>
        </div>
      )}
      {documents.length === 0 ? <p className="text-sm muted px-1">Nenhum documento.</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead><tr><th>Código</th><th>Título</th><th>Categoria</th><th>Pasta</th><th>Ver.</th><th>Status</th><th></th></tr></thead>
            <tbody>
              {documents.map((d) => (
                <Fragment key={d.id}>
                  <tr>
                    <td className="tabular-nums">{d.code ?? "—"}</td>
                    <td>{d.title}{d.checked_out_by && <span className="badge badge-warning ml-1">em edição</span>}</td>
                    <td className="uppercase text-xs muted">{d.category}</td>
                    <td className="text-xs muted">{folderName(d.folder_id)}</td>
                    <td className="tabular-nums">v{d.current_version}</td>
                    <td><span className={`badge ${DBADGE[d.status]}`}>{DSTATUS[d.status] ?? d.status}</span></td>
                    <td className="text-right whitespace-nowrap">
                      <button onClick={() => setExpand(expand === d.id ? null : d.id)} className="text-xs text-brand-600 hover:underline mr-2">ver</button>
                      {d.checked_out_by ? <button onClick={() => checkin(d.id)} disabled={busy === d.id} className="btn btn-sm mr-1">Check-in</button> : <button onClick={() => checkout(d.id)} disabled={busy === d.id} className="btn btn-sm mr-1">Check-out</button>}
                      {d.status !== "signed" && <button onClick={() => requestSig(d.id)} disabled={busy === d.id} className="text-xs font-semibold text-brand-600 hover:underline">assinar</button>}
                    </td>
                  </tr>
                  {expand === d.id && (
                    <tr><td colSpan={7} className="surface-2"><div className="p-3 grid md:grid-cols-2 gap-4">
                      <div>
                        <div className="text-xs font-semibold muted uppercase mb-1">Versões</div>
                        <div className="text-sm">v{d.current_version} (atual)</div>
                        {versions.filter((v) => v.document_id === d.id).map((v) => <div key={v.id} className="text-xs muted">v{v.version_no} · {v.change_reason ?? "—"} · {new Date(v.created_at).toLocaleDateString("pt-BR")}</div>)}
                      </div>
                      <div>
                        <div className="text-xs font-semibold muted uppercase mb-1">Assinaturas</div>
                        {signatures.filter((s) => s.document_id === d.id).length === 0 ? <div className="text-sm muted">—</div> : signatures.filter((s) => s.document_id === d.id).map((s) => (
                          <div key={s.id} className="text-sm flex items-center gap-2"><span className="flex-1">{s.signer_name}</span><span className={`badge ${s.status === "signed" ? "badge-success" : s.status === "rejected" ? "badge-danger" : "badge-warning"}`}>{s.status}</span></div>
                        ))}
                      </div>
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

function Assinaturas({ signatures, documents }: { signatures: any[]; documents: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  const docTitle = (id: string) => documents.find((d) => d.id === id)?.title ?? "—";
  const pending = signatures.filter((s) => s.status === "pending");
  async function sign(id: string, method: string) { if (!supabase) return; setBusy(id); await supabase.rpc("sign_document", { p_signature: id, p_method: method }); setBusy(null); router.refresh(); }
  if (pending.length === 0) return <p className="text-sm muted px-1">Nenhuma assinatura pendente.</p>;
  return (
    <div className="space-y-3">
      {pending.map((s) => (
        <div key={s.id} className="card p-4 flex items-center gap-3">
          <div className="flex-1"><div className="font-semibold text-sm">{docTitle(s.document_id)}</div><div className="text-xs muted">Signatário: {s.signer_name} · ordem {s.sign_order} · {s.method}</div></div>
          <button onClick={() => sign(s.id, "electronic")} disabled={busy === s.id} className="btn btn-sm" style={{ background: "var(--success)", color: "#fff", borderColor: "transparent" }}>Assinar (eletrônica)</button>
          <button onClick={() => sign(s.id, "digital")} disabled={busy === s.id} className="btn btn-sm">Certificado digital</button>
        </div>
      ))}
    </div>
  );
}

function Busca() {
  const supabase = useMemo(() => createClient(), []);
  const [q, setQ] = useState("");
  const [res, setRes] = useState<any[] | null>(null);
  const [busy, setBusy] = useState(false);
  async function search() {
    if (!supabase || !q) return;
    setBusy(true);
    const { data } = await supabase.rpc("search_documents", { p_company: COMPANY, p_query: q });
    setBusy(false); setRes(data ?? []);
  }
  return (
    <div className="space-y-3">
      <div className="flex gap-2 max-w-xl">
        <input value={q} onChange={(e) => setQ(e.target.value)} onKeyDown={(e) => e.key === "Enter" && search()} className="input" placeholder="Buscar por título ou conteúdo (OCR)…" />
        <button onClick={search} disabled={busy} className="btn btn-primary btn-sm">Buscar</button>
      </div>
      {res && (res.length === 0 ? <p className="text-sm muted">Nenhum documento encontrado.</p> : (
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Documento</th><th>Categoria</th><th>Versão</th><th>Status</th></tr></thead>
          <tbody>{res.map((d) => (<tr key={d.id}><td>{d.title}</td><td className="uppercase text-xs muted">{d.category}</td><td className="tabular-nums">v{d.version}</td><td><span className={`badge ${DBADGE[d.status]}`}>{DSTATUS[d.status] ?? d.status}</span></td></tr>))}</tbody>
        </table></div>
      ))}
    </div>
  );
}
