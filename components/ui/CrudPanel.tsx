"use client";
import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

export type Field = {
  key: string;
  label: string;
  type?: "text" | "number" | "select" | "fk" | "date";
  options?: [string, string][];
  fkTable?: string;      // para type 'fk'
  fkLabel?: string;      // coluna de rótulo (default 'name')
  required?: boolean;
  placeholder?: string;
  default?: string;
};
export type Column = { key: string; label: string; fmt?: (v: any, row: any) => string };

// CRUD genérico para tabelas de negócio (padrão colunas + soft delete + FK).
export default function CrudPanel({
  table, title, fields, columns, rows, emptyHint,
}: {
  table: string; title: string; fields: Field[]; columns: Column[];
  rows: any[]; emptyHint?: string;
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [q, setQ] = useState("");
  const [fkMaps, setFkMaps] = useState<Record<string, [string, string][]>>({});
  const init = useMemo(() => Object.fromEntries(fields.map((f) => [f.key, f.default ?? ""])), [fields]);
  const [form, setForm] = useState<Record<string, string>>(init);

  useEffect(() => {
    if (!supabase) return;
    const fks = fields.filter((f) => f.type === "fk" && f.fkTable);
    if (fks.length === 0) return;
    (async () => {
      const out: Record<string, [string, string][]> = {};
      for (const f of fks) {
        const lbl = f.fkLabel ?? "name";
        const { data } = await supabase.from(f.fkTable!).select(`id, ${lbl}`)
          .eq("company_id", COMPANY).is("deleted_at", null).order(lbl).limit(1000);
        out[f.key] = (data ?? []).map((r: any) => [r.id, r[lbl]]);
      }
      setFkMaps(out);
    })();
  }, [supabase, fields]);

  const fkLabel = (key: string, id: any) =>
    id ? (fkMaps[key]?.find(([v]) => v === id)?.[1] ?? "—") : "—";

  async function create() {
    if (!supabase) return;
    for (const f of fields) if (f.required && !String(form[f.key] ?? "").trim()) { setErr(`Campo obrigatório: ${f.label}`); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const body: Record<string, any> = { tenant_id, company_id: COMPANY };
    for (const f of fields) {
      const raw = String(form[f.key] ?? "").trim();
      if (raw === "") { body[f.key] = f.type === "fk" ? null : null; continue; }
      body[f.key] = f.type === "number" ? Number(raw) : raw;
    }
    const { error } = await supabase.from(table).insert(body);
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setForm(init); setOpen(false); router.refresh();
  }

  async function remove(id: string) {
    if (!supabase) return;
    await supabase.from(table).update({ deleted_at: new Date().toISOString(), reason_deleted: "removido na tela", active: false }).eq("id", id);
    router.refresh();
  }

  const filtered = useMemo(() => {
    const s = q.trim().toLowerCase();
    if (!s) return rows;
    return rows.filter((r) => columns.some((c) => String(r[c.key] ?? "").toLowerCase().includes(s)));
  }, [q, rows, columns]);

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base">{title} <span className="badge badge-neutral align-middle ml-1">{rows.length}</span></div>
        <div className="relative ml-auto">
          <span className="absolute left-2.5 top-1/2 -translate-y-1/2 muted text-sm pointer-events-none">⌕</span>
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Buscar…"
            className="input h-9 pl-8 w-52" style={{ background: "var(--surface-2)" }} />
        </div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className={`btn btn-sm ${open ? "" : "btn-primary"}`}>{open ? "Cancelar" : "+ Novo"}</button>
      </div>

      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            {fields.map((f) => (
              <div key={f.key}>
                <label className="label">{f.label}{f.required ? " *" : ""}</label>
                {f.type === "select" ? (
                  <select value={form[f.key]} onChange={(e) => setForm((p) => ({ ...p, [f.key]: e.target.value }))} className="select">
                    <option value="">—</option>
                    {(f.options ?? []).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
                  </select>
                ) : f.type === "fk" ? (
                  <select value={form[f.key]} onChange={(e) => setForm((p) => ({ ...p, [f.key]: e.target.value }))} className="select">
                    <option value="">—</option>
                    {(fkMaps[f.key] ?? []).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
                  </select>
                ) : (
                  <input type={f.type === "number" ? "number" : f.type === "date" ? "date" : "text"}
                    value={form[f.key]} placeholder={f.placeholder}
                    onChange={(e) => setForm((p) => ({ ...p, [f.key]: e.target.value }))} className="input" />
                )}
              </div>
            ))}
          </div>
          {err && <div className="text-sm rounded-xl px-3 py-2" style={{ background: "var(--danger-soft)", color: "var(--danger)" }}>{err}</div>}
          <button onClick={create} disabled={busy} className="btn btn-primary btn-sm">{busy ? "Salvando…" : "Salvar"}</button>
        </div>
      )}

      {rows.length === 0 ? (
        <p className="text-sm muted px-1">{emptyHint ?? "Nenhum registro ainda."}</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead>
              <tr>
                {columns.map((c) => <th key={c.key}>{c.label}</th>)}
                <th></th>
              </tr>
            </thead>
            <tbody>
              {filtered.slice(0, 300).map((r) => (
                <tr key={r.id}>
                  {columns.map((c) => {
                    const isFk = fields.find((f) => f.key === c.key && f.type === "fk");
                    const val = isFk ? fkLabel(c.key, r[c.key]) : (c.fmt ? c.fmt(r[c.key], r) : (r[c.key] ?? "—"));
                    return <td key={c.key}>{String(val ?? "—")}</td>;
                  })}
                  <td className="text-right"><button onClick={() => remove(r.id)} className="text-xs font-semibold hover:underline" style={{ color: "var(--danger)" }}>excluir</button></td>
                </tr>
              ))}
            </tbody>
          </table>
          {filtered.length > 300 && <div className="text-xs muted p-3">Mostrando 300 de {filtered.length}.</div>}
        </div>
      )}
    </div>
  );
}
