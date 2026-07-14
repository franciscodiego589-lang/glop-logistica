"use client";
import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

type Fld = { key: string; label: string; type?: "text" | "select"; options?: [string, string][] };

export default function SimpleCrud({ table, fields, listCols }: { table: string; fields: Fld[]; listCols: string[] }) {
  const supabase = useMemo(() => createClient(), []);
  const [rows, setRows] = useState<any[]>([]);
  const [tenantId, setTenantId] = useState<string | null>(null);
  const [form, setForm] = useState<Record<string, any>>(() => Object.fromEntries(fields.map((f) => [f.key, ""])));
  const [err, setErr] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function load() {
    if (!supabase) return;
    const { data } = await supabase.from(table).select("*").eq("company_id", COMPANY).is("deleted_at", null).order("created_at", { ascending: false }).limit(200);
    setRows(data ?? []);
  }
  useEffect(() => {
    if (!supabase) return;
    (async () => {
      const { data: c } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
      setTenantId((c as any)?.tenant_id ?? null);
      load();
    })();
    // eslint-disable-next-line
  }, [table]);

  async function add() {
    setErr(null);
    if (!supabase || !tenantId) { setErr("Empresa não resolvida."); return; }
    const payload: Record<string, any> = { tenant_id: tenantId, company_id: COMPANY };
    for (const f of fields) payload[f.key] = form[f.key] || null;
    if (!payload[fields[0].key]) { setErr(`${fields[0].label} é obrigatório.`); return; }
    setBusy(true);
    const { error } = await supabase.from(table).insert(payload);
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setForm(Object.fromEntries(fields.map((f) => [f.key, ""])));
    load();
  }
  async function remove(id: string) {
    if (!supabase) return;
    await supabase.from(table).update({ deleted_at: new Date().toISOString(), reason_deleted: "removido" }).eq("id", id);
    load();
  }

  return (
    <div className="space-y-3">
      <div className="card p-4 grid md:grid-cols-4 gap-2 items-end">
        {fields.map((f) => (
          <div key={f.key} className={fields.length <= 2 ? "md:col-span-1" : ""}>
            <label className="text-xs font-semibold muted">{f.label}</label>
            {f.type === "select" ? (
              <select value={form[f.key]} onChange={(e) => setForm((p) => ({ ...p, [f.key]: e.target.value }))}
                className="w-full mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>
                {(f.options ?? []).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
              </select>
            ) : (
              <input value={form[f.key]} onChange={(e) => setForm((p) => ({ ...p, [f.key]: e.target.value }))}
                className="w-full mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
            )}
          </div>
        ))}
        <button onClick={add} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold disabled:opacity-60">{busy ? "..." : "Adicionar"}</button>
        {err && <div className="text-sm text-red-500 md:col-span-4">{err}</div>}
      </div>
      <div className="card overflow-hidden">
        <table className="w-full text-sm">
          <thead><tr className="text-left muted border-b" style={{ borderColor: "var(--border)" }}>
            {listCols.map((c) => <th key={c} className="px-4 py-2 font-semibold">{c}</th>)}
            <th className="px-4 py-2"></th>
          </tr></thead>
          <tbody>
            {rows.length === 0 && <tr><td colSpan={listCols.length + 1} className="px-4 py-8 text-center muted">Nenhum registro.</td></tr>}
            {rows.map((r) => (
              <tr key={r.id} className="border-b" style={{ borderColor: "var(--border)" }}>
                {listCols.map((c) => <td key={c} className="px-4 py-2">{String(r[c] ?? "—")}</td>)}
                <td className="px-4 py-2 text-right"><button onClick={() => remove(r.id)} className="text-red-500 hover:underline text-xs">Remover</button></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
