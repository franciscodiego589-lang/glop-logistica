"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

export default function SignPanel({ documents, inspections }: { documents: any[]; inspections: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [evInsp, setEvInsp] = useState("");
  const pending = documents.filter((d) => d.status !== "approved" && d.status !== "obsolete");

  async function sign(table: string, id: string, meaning: string) {
    if (!supabase) return;
    setBusy(id); setErr(null); setMsg(null);
    const { error } = await supabase.rpc("sign_record", { p_table: table, p_id: id, p_meaning: meaning, p_reason: "Assinatura eletrônica na tela" });
    setBusy(null);
    if (error) { setErr(error.message); return; }
    setMsg("Assinado e efetivado ✓"); router.refresh();
  }

  async function uploadEvidence(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file || !supabase || !evInsp) { setErr("Selecione uma inspeção primeiro."); return; }
    setBusy("ev"); setErr(null); setMsg(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id;
    const safe = file.name.replace(/[^a-zA-Z0-9._-]/g, "_");
    const path = `${COMPANY}/${evInsp}/${Date.now()}-${safe}`;
    const { error: up } = await supabase.storage.from("quality").upload(path, file, { upsert: true });
    if (up) { setErr(up.message); setBusy(null); return; }
    const { data: pub } = supabase.storage.from("quality").getPublicUrl(path);
    const { error } = await supabase.from("quality_evidences").insert({
      tenant_id, company_id: COMPANY, entity_table: "quality_inspections", entity_id: evInsp,
      kind: "photo", url: pub.publicUrl, storage_path: path, title: file.name,
    });
    setBusy(null);
    if (error) { setErr(error.message); return; }
    setMsg("Evidência enviada ✓");
  }

  return (
    <div className="space-y-4">
      {msg && <div className="text-sm text-green-500">{msg}</div>}
      {err && <div className="text-sm text-red-500">{err}</div>}

      <div className="card p-4">
        <div className="font-semibold mb-2">Assinatura eletrônica — documentos pendentes ({pending.length})</div>
        <p className="text-xs muted mb-3">Assinar registra quem/quando (hash SHA-256) e efetiva a aprovação do documento — trilha para conformidade (21 CFR Part 11 / GMP).</p>
        {pending.length === 0 ? <p className="text-sm muted">Nenhum documento pendente de aprovação.</p> : (
          <div className="space-y-1.5">
            {pending.map((d) => (
              <div key={d.id} className="flex items-center gap-2 text-sm border rounded-lg px-3 py-2" style={{ borderColor: "var(--border)" }}>
                <span className="font-medium">{d.title}</span>
                <span className="text-xs muted">v{d.doc_version} · {d.status}</span>
                <button onClick={() => sign("quality_documents", d.id, "approval")} disabled={busy === d.id}
                  className="ml-auto text-xs px-3 py-1.5 rounded-lg bg-brand-600 hover:bg-brand-700 text-white font-semibold disabled:opacity-60">
                  {busy === d.id ? "Assinando…" : "Assinar & aprovar"}
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      <div className="card p-4">
        <div className="font-semibold mb-2">Evidências de inspeção (Storage)</div>
        <div className="flex flex-wrap gap-2 items-center">
          <select value={evInsp} onChange={(e) => setEvInsp(e.target.value)}
            className="border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500 min-w-64" style={{ borderColor: "var(--border)" }}>
            <option value="">— escolha a inspeção —</option>
            {inspections.map((i) => <option key={i.id} value={i.id}>{i.code ?? i.id.slice(0, 8)} · {i.inspection_type} · {i.result}</option>)}
          </select>
          <label className="inline-flex items-center gap-2 px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold cursor-pointer">
            {busy === "ev" ? "Enviando…" : "Anexar evidência"}
            <input type="file" accept="image/*,application/pdf" className="hidden" onChange={uploadEvidence} disabled={busy === "ev" || !evInsp} />
          </label>
        </div>
      </div>
    </div>
  );
}
