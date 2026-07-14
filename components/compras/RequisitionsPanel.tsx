"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { REQ_STATUS } from "./status";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

type Req = {
  id: string; code: string | null; status: string; needed_by: string | null;
  justification: string | null; warehouse_id: string | null;
};
type Opt = { id: string; name?: string };

export default function RequisitionsPanel({ reqs, warehouses }: { reqs: Req[]; warehouses: Opt[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ code: "", needed_by: "", justification: "", warehouse_id: "" });

  async function create() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { error } = await supabase.from("purchase_requisitions").insert({
      tenant_id, company_id: COMPANY, status: "draft",
      code: f.code.trim() || null, needed_by: f.needed_by || null,
      justification: f.justification.trim() || null, warehouse_id: f.warehouse_id || null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setF({ code: "", needed_by: "", justification: "", warehouse_id: "" }); setOpen(false); router.refresh();
  }

  async function setStatus(id: string, status: string) {
    if (!supabase) return;
    const patch: Record<string, any> = { status };
    if (status === "approved") patch.approved_at = new Date().toISOString();
    await supabase.from("purchase_requisitions").update(patch).eq("id", id);
    router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Requisições de compra <span className="muted font-normal">({reqs.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Nova requisição"}</button>
      </div>

      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-4 gap-3">
            <div><label className="text-xs font-semibold muted">Código</label>
              <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="REQ-0001"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Necessário até</label>
              <input type="date" value={f.needed_by} onChange={(e) => setF({ ...f, needed_by: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Armazém</label>
              <select value={f.warehouse_id} onChange={(e) => setF({ ...f, warehouse_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{warehouses.map((w) => <option key={w.id} value={w.id}>{w.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Justificativa</label>
              <input value={f.justification} onChange={(e) => setF({ ...f, justification: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Salvando…" : "Criar requisição"}</button>
        </div>
      )}

      {reqs.length === 0 ? (
        <p className="text-sm muted px-1">Nenhuma requisição ainda.</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-3">Código</th><th className="px-3">Necessário até</th><th className="px-3">Justificativa</th><th className="px-3">Status</th>
              </tr>
            </thead>
            <tbody>
              {reqs.map((r) => (
                <tr key={r.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-mono">{r.code ?? r.id.slice(0, 8)}</td>
                  <td className="px-3">{r.needed_by ?? "—"}</td>
                  <td className="px-3 muted truncate max-w-xs">{r.justification ?? "—"}</td>
                  <td className="px-3">
                    <select value={r.status} onChange={(e) => setStatus(r.id, e.target.value)}
                      className={`text-xs px-2 py-0.5 rounded-md font-semibold bg-transparent outline-none ${REQ_STATUS[r.status]?.cls ?? ""}`}>
                      {Object.entries(REQ_STATUS).map(([v, o]) => <option key={v} value={v}>{o.label}</option>)}
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
