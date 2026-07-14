"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { RFQ_STATUS } from "./status";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

type Rfq = { id: string; code: string | null; status: string; due_date: string | null; notes: string | null };

export default function RfqPanel({ rfqs }: { rfqs: Rfq[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ code: "", due_date: "", notes: "" });

  async function create() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { error } = await supabase.from("rfqs").insert({
      tenant_id, company_id: COMPANY, status: "draft",
      code: f.code.trim() || null, due_date: f.due_date || null, notes: f.notes.trim() || null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setF({ code: "", due_date: "", notes: "" }); setOpen(false); router.refresh();
  }

  async function setStatus(id: string, status: string) {
    if (!supabase) return;
    await supabase.from("rfqs").update({ status }).eq("id", id);
    router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">RFQ / Cotações <span className="muted font-normal">({rfqs.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Nova RFQ"}</button>
      </div>

      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Código</label>
              <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="RFQ-0001"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Prazo de resposta</label>
              <input type="date" value={f.due_date} onChange={(e) => setF({ ...f, due_date: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Observações</label>
              <input value={f.notes} onChange={(e) => setF({ ...f, notes: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Salvando…" : "Criar RFQ"}</button>
        </div>
      )}

      {rfqs.length === 0 ? (
        <p className="text-sm muted px-1">Nenhuma RFQ ainda. Comparação de cotações e leilão reverso entram numa próxima etapa.</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Código</th><th className="px-3">Prazo</th><th className="px-3">Obs.</th><th className="px-3">Status</th></tr></thead>
            <tbody>
              {rfqs.map((r) => (
                <tr key={r.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-mono">{r.code ?? r.id.slice(0, 8)}</td>
                  <td className="px-3">{r.due_date ?? "—"}</td>
                  <td className="px-3 muted truncate max-w-xs">{r.notes ?? "—"}</td>
                  <td className="px-3">
                    <select value={r.status} onChange={(e) => setStatus(r.id, e.target.value)}
                      className={`text-xs px-2 py-0.5 rounded-md font-semibold bg-transparent outline-none ${RFQ_STATUS[r.status]?.cls ?? ""}`}>
                      {Object.entries(RFQ_STATUS).map(([v, o]) => <option key={v} value={v}>{o.label}</option>)}
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
