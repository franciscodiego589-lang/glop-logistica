"use client";
import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

export type RelField = {
  key: string;
  label: string;
  type?: "text" | "number" | "select" | "fk";
  options?: [string, string][];
  fkTable?: string;      // para type 'fk': tabela de origem (id, label)
  fkLabel?: string;      // coluna de rótulo (default 'name')
  default?: any;
};

export default function RelationEditor({
  title, table, productId, tenantId, fields, rowLabel,
}: {
  title: string;
  table: string;
  productId: string;
  tenantId: string | null;
  fields: RelField[];
  rowLabel: (row: any, fkMaps: Record<string, Record<string, string>>) => string;
}) {
  const supabase = useMemo(() => createClient(), []);
  const [rows, setRows] = useState<any[]>([]);
  const [fkMaps, setFkMaps] = useState<Record<string, Record<string, string>>>({});
  const [form, setForm] = useState<Record<string, any>>(() =>
    Object.fromEntries(fields.map((f) => [f.key, f.default ?? ""]))
  );
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  async function load() {
    if (!supabase) return;
    const { data } = await supabase.from(table).select("*").eq("product_id", productId).is("deleted_at", null).order("created_at");
    setRows(data ?? []);
    // carrega opções de FKs
    const maps: Record<string, Record<string, string>> = {};
    for (const f of fields.filter((x) => x.type === "fk" && x.fkTable)) {
      const { data: opts } = await supabase.from(f.fkTable!).select(`id,${f.fkLabel ?? "name"}`).eq("company_id", COMPANY).is("deleted_at", null).order(f.fkLabel ?? "name");
      maps[f.key] = Object.fromEntries((opts ?? []).map((o: any) => [o.id, o[f.fkLabel ?? "name"]]));
    }
    setFkMaps(maps);
  }
  useEffect(() => { load(); /* eslint-disable-next-line */ }, [productId]);

  async function add() {
    setErr(null);
    if (!supabase || !tenantId) { setErr("Empresa não resolvida."); return; }
    setBusy(true);
    const payload: Record<string, any> = { tenant_id: tenantId, company_id: COMPANY, product_id: productId };
    for (const f of fields) {
      const v = form[f.key];
      payload[f.key] = f.type === "number" ? (v === "" ? null : Number(v)) : (v === "" ? null : v);
    }
    const { error } = await supabase.from(table).insert(payload);
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setForm(Object.fromEntries(fields.map((f) => [f.key, f.default ?? ""])));
    load();
  }

  async function remove(id: string) {
    if (!supabase) return;
    await supabase.from(table).update({ deleted_at: new Date().toISOString(), reason_deleted: "removido na tela" }).eq("id", id);
    load();
  }

  return (
    <div className="card p-4">
      <div className="font-semibold mb-3">{title} <span className="muted font-normal">({rows.length})</span></div>
      <div className="space-y-1.5 mb-3">
        {rows.length === 0 && <div className="text-sm muted">Nenhum registro.</div>}
        {rows.map((r) => (
          <div key={r.id} className="flex items-center justify-between text-sm border rounded-lg px-3 py-2" style={{ borderColor: "var(--border)" }}>
            <span>{rowLabel(r, fkMaps)}</span>
            <button onClick={() => remove(r.id)} className="text-red-500 hover:underline text-xs">Remover</button>
          </div>
        ))}
      </div>
      <div className="grid md:grid-cols-3 gap-2 items-end">
        {fields.map((f) => (
          <div key={f.key}>
            <label className="text-xs font-semibold muted">{f.label}</label>
            {f.type === "select" || f.type === "fk" ? (
              <select value={form[f.key]} onChange={(e) => setForm((p) => ({ ...p, [f.key]: e.target.value }))}
                className="w-full mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>
                {f.type === "fk"
                  ? Object.entries(fkMaps[f.key] ?? {}).map(([id, name]) => <option key={id} value={id}>{name}</option>)
                  : (f.options ?? []).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
              </select>
            ) : (
              <input type={f.type === "number" ? "number" : "text"} value={form[f.key]} onChange={(e) => setForm((p) => ({ ...p, [f.key]: e.target.value }))}
                className="w-full mt-1 border rounded-lg px-2 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
            )}
          </div>
        ))}
        <button onClick={add} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold disabled:opacity-60">
          {busy ? "..." : "Adicionar"}
        </button>
      </div>
      {err && <div className="text-sm text-red-500 mt-2">{err}</div>}
    </div>
  );
}
