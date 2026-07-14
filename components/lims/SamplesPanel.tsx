"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { SAMPLE_STATUS, SAMPLE_TYPE, sampleTypeLabel } from "./shared";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const dt = (s: string | null) => s ? new Date(s).toLocaleDateString("pt-BR") : "—";

type Sample = { id: string; code: string | null; sample_type: string; status: string; product_id: string | null; lot_id: string | null; collector: string | null; collected_at: string | null; priority: string | null };

export default function SamplesPanel({ samples, products, lots, prodName }: {
  samples: Sample[]; products: any[]; lots: any[]; prodName: Record<string, string>;
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const lotLabel = useMemo(() => Object.fromEntries(lots.map((l) => [l.id, l.lot_number])), [lots]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [q, setQ] = useState("");
  const [f, setF] = useState({ code: "", sample_type: "raw_material", product_id: "", lot_id: "", collector: "", collected_at: "", priority: "normal" });

  const lotsForProduct = f.product_id ? lots.filter((l) => l.product_id === f.product_id) : lots;

  async function create() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { data, error } = await supabase.from("lab_samples").insert({
      tenant_id, company_id: COMPANY, status: "registered", sample_type: f.sample_type,
      code: f.code.trim() || null, product_id: f.product_id || null, lot_id: f.lot_id || null,
      collector: f.collector.trim() || null, priority: f.priority,
      collected_at: f.collected_at ? new Date(f.collected_at).toISOString() : new Date().toISOString(),
    }).select("id").single();
    setBusy(false);
    if (error) { setErr(error.message); return; }
    router.push(`/lims/amostra/${(data as any).id}`);
  }

  const filtered = useMemo(() => {
    const s = q.trim().toLowerCase();
    return s ? samples.filter((x) => (x.code ?? "").toLowerCase().includes(s) || (x.product_id ? (prodName[x.product_id] ?? "").toLowerCase().includes(s) : false)) : samples;
  }, [q, samples, prodName]);

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Amostras <span className="muted font-normal">({samples.length})</span></div>
        <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Buscar…"
          className="ml-auto border rounded-lg px-3 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500 w-44" style={{ borderColor: "var(--border)" }} />
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Nova amostra"}</button>
      </div>
      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Código</label>
              <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="AM-0001"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Tipo</label>
              <select value={f.sample_type} onChange={(e) => setF({ ...f, sample_type: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                {SAMPLE_TYPE.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Prioridade</label>
              <select value={f.priority} onChange={(e) => setF({ ...f, priority: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="low">Baixa</option><option value="normal">Normal</option><option value="high">Alta</option><option value="urgent">Urgente</option>
              </select></div>
            <div><label className="text-xs font-semibold muted">Produto</label>
              <select value={f.product_id} onChange={(e) => setF({ ...f, product_id: e.target.value, lot_id: "" })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{products.map((p) => <option key={p.id} value={p.id}>{p.sku ? p.sku + " · " : ""}{p.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Lote</label>
              <select value={f.lot_id} onChange={(e) => setF({ ...f, lot_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{lotsForProduct.map((l) => <option key={l.id} value={l.id}>{l.lot_number}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Coletor</label>
              <input value={f.collector} onChange={(e) => setF({ ...f, collector: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Criando…" : "Registrar e adicionar ensaios"}</button>
        </div>
      )}
      {samples.length === 0 ? (
        <p className="text-sm muted px-1">Nenhuma amostra ainda.</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Código</th><th className="px-3">Tipo</th><th className="px-3">Produto / lote</th><th className="px-3">Coleta</th><th className="px-3">Status</th><th></th></tr></thead>
            <tbody>
              {filtered.slice(0, 300).map((s) => (
                <tr key={s.id} className="border-b last:border-0 hover:bg-black/[.02] dark:hover:bg-white/[.03]" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-mono">{s.code ?? s.id.slice(0, 8)}</td>
                  <td className="px-3">{sampleTypeLabel(s.sample_type)}</td>
                  <td className="px-3 muted">{s.product_id ? prodName[s.product_id] ?? "—" : "—"}{s.lot_id ? " · " + (lotLabel[s.lot_id] ?? "") : ""}</td>
                  <td className="px-3">{dt(s.collected_at)}</td>
                  <td className="px-3"><span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${SAMPLE_STATUS[s.status]?.cls ?? ""}`}>{SAMPLE_STATUS[s.status]?.label ?? s.status}</span></td>
                  <td className="px-3 text-right"><Link href={`/lims/amostra/${s.id}`} className="text-xs text-brand-500 hover:underline">abrir →</Link></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
