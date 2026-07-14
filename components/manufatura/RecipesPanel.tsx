"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const dt = (s: string | null) => s ? new Date(s).toLocaleString("pt-BR") : "—";
const STATUS: Record<string, { label: string; cls: string }> = {
  draft: { label: "Rascunho", cls: "bg-slate-500/15 text-slate-400" },
  approved: { label: "Aprovada", cls: "bg-green-500/15 text-green-500" },
  obsolete: { label: "Obsoleta", cls: "bg-red-500/15 text-red-500" },
};

type Bom = { id: string; product_id: string; name: string | null; status: string | null; version_label: string | null; approved_at: string | null; output_quantity: number };
type Rev = { id: string; bom_id: string; version_label: string | null; note: string | null; approved_at: string | null; components: any[] };

export default function RecipesPanel({ boms, prodName, revisionsByBom }: {
  boms: Bom[]; prodName: Record<string, string>; revisionsByBom: Record<string, Rev[]>;
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [expanded, setExpanded] = useState<string | null>(null);

  async function approve(id: string) {
    if (!supabase) return;
    setBusy(id); setMsg(null); setErr(null);
    const { error } = await supabase.rpc("approve_bom", { p_bom: id, p_note: null });
    setBusy(null);
    if (error) { setErr(error.message); return; }
    setMsg("Receita aprovada ✓ — revisão registrada no histórico.");
    router.refresh();
  }
  async function setObsolete(id: string) {
    if (!supabase) return;
    await supabase.from("bills_of_materials").update({ status: "obsolete" }).eq("id", id);
    router.refresh();
  }

  const pending = boms.filter((b) => (b.status ?? "draft") === "draft").length;

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Receitas / Fórmulas <span className="muted font-normal">({boms.length})</span></div>
        {pending > 0 && <span className="text-xs px-2 py-0.5 rounded-md bg-amber-500/15 text-amber-500 font-semibold">{pending} aguardando aprovação</span>}
        <Link href="/mrp" className="ml-auto text-sm text-brand-500 hover:underline">gerenciar estruturas (BOM) →</Link>
      </div>
      {msg && <div className="text-sm text-green-500">{msg}</div>}
      {err && <div className="text-sm text-red-500">{err}</div>}

      {boms.length === 0 ? (
        <p className="text-sm muted px-1">Nenhuma receita/BOM. Crie estruturas de produto em <Link href="/mrp" className="text-brand-500 hover:underline">MRP → Estruturas (BOM)</Link>.</p>
      ) : (
        <div className="space-y-2">
          {boms.map((b) => {
            const st = b.status ?? "draft";
            const revs = revisionsByBom[b.id] ?? [];
            return (
              <div key={b.id} className="card p-3">
                <div className="flex items-center gap-2 flex-wrap">
                  <div className="font-semibold text-sm">{prodName[b.product_id] ?? "—"}</div>
                  {b.name && <span className="text-xs muted">{b.name}</span>}
                  {b.version_label && <span className="text-xs px-1.5 py-0.5 rounded bg-brand-500/15 text-brand-500 font-mono">{b.version_label}</span>}
                  <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${STATUS[st]?.cls ?? ""}`}>{STATUS[st]?.label ?? st}</span>
                  <span className="text-xs muted">{b.approved_at ? "aprovada " + dt(b.approved_at) : ""}</span>
                  <div className="ml-auto flex gap-2">
                    <Link href={`/mrp/bom/${b.id}`} className="text-xs text-brand-500 hover:underline">componentes</Link>
                    {revs.length > 0 && <button onClick={() => setExpanded(expanded === b.id ? null : b.id)} className="text-xs text-brand-500 hover:underline">histórico ({revs.length})</button>}
                    {st !== "approved" && <button onClick={() => approve(b.id)} disabled={busy === b.id} className="text-xs px-2 py-1 rounded-md bg-green-600 text-white font-semibold disabled:opacity-60">{busy === b.id ? "…" : "Aprovar"}</button>}
                    {st === "approved" && <button onClick={() => setObsolete(b.id)} className="text-xs text-red-500 hover:underline">tornar obsoleta</button>}
                  </div>
                </div>
                {expanded === b.id && revs.length > 0 && (
                  <div className="mt-2 pt-2 border-t space-y-1" style={{ borderColor: "var(--border)" }}>
                    {revs.map((r) => (
                      <div key={r.id} className="text-xs flex gap-2">
                        <span className="font-mono text-brand-500">{r.version_label ?? "—"}</span>
                        <span className="muted">{dt(r.approved_at)}</span>
                        <span className="muted">· {(r.components?.length ?? 0)} componentes{r.note ? " · " + r.note : ""}</span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
