"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { SAMPLE_STATUS, sampleTypeLabel, TEST_KIND } from "./shared";

type Test = { id: string; parameter: string; test_kind: string; result_value: number | null; result_text: string | null; unit: string | null; spec_min: number | null; spec_max: number | null; conforms: boolean | null; status: string };
type Spec = { id: string; parameter: string; test_kind: string; min_value: number | null; max_value: number | null; unit: string | null; method_id: string | null };

export default function SampleDetail({ sample, tests, methods, specs, lot }: {
  sample: any; tests: Test[]; methods: any[]; specs: Spec[]; lot: any | null;
}) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [t, setT] = useState({ specId: "", parameter: "", test_kind: "chemical", method_id: "", result_value: "", unit: "", spec_min: "", spec_max: "", analyst: "" });

  const st = sample.status as string;
  const code = sample.code ?? sample.id.slice(0, 8);
  const editable = st === "registered" || st === "in_analysis";
  const done = tests.filter((x) => x.result_value != null || x.result_text != null).length;
  const failing = tests.filter((x) => x.result_value != null && x.conforms === false).length;
  const canRelease = tests.length > 0 && done === tests.length && (st === "registered" || st === "in_analysis");

  function pickSpec(id: string) {
    const s = specs.find((x) => x.id === id);
    if (!s) { setT((p) => ({ ...p, specId: "" })); return; }
    setT((p) => ({ ...p, specId: id, parameter: s.parameter, test_kind: s.test_kind, method_id: s.method_id ?? "",
      unit: s.unit ?? "", spec_min: s.min_value != null ? String(s.min_value) : "", spec_max: s.max_value != null ? String(s.max_value) : "" }));
  }

  async function addTest() {
    if (!supabase) return;
    if (!t.parameter.trim()) { setErr("Informe o parâmetro."); return; }
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", sample.company_id).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    const { error } = await supabase.from("lab_tests").insert({
      tenant_id, company_id: sample.company_id, sample_id: sample.id,
      parameter: t.parameter.trim(), test_kind: t.test_kind, method_id: t.method_id || null, specification_id: t.specId || null,
      result_value: t.result_value !== "" ? Number(t.result_value) : null, unit: t.unit.trim() || null,
      spec_min: t.spec_min !== "" ? Number(t.spec_min) : null, spec_max: t.spec_max !== "" ? Number(t.spec_max) : null,
      analyst: t.analyst.trim() || null, tested_at: t.result_value !== "" ? new Date().toISOString() : null,
    });
    if (!error && st === "registered") await supabase.from("lab_samples").update({ status: "in_analysis" }).eq("id", sample.id);
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setT({ specId: "", parameter: "", test_kind: "chemical", method_id: "", result_value: "", unit: "", spec_min: "", spec_max: "", analyst: "" });
    router.refresh();
  }

  async function removeTest(id: string) {
    if (!supabase) return;
    await supabase.from("lab_tests").update({ deleted_at: new Date().toISOString(), reason_deleted: "removido" }).eq("id", id);
    router.refresh();
  }

  async function release() {
    if (!supabase) return;
    setBusy(true); setErr(null); setMsg(null);
    const { data, error } = await supabase.rpc("release_sample", { p_sample: sample.id });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setMsg(data === "approved"
      ? "Amostra APROVADA ✓" + (sample.lot_id ? " — lote liberado (quality_status = released)." : ".")
      : "Amostra REPROVADA ✗" + (sample.lot_id ? " — lote bloqueado (quality_status = blocked)." : "."));
    router.refresh();
  }

  return (
    <div className="space-y-4 max-w-5xl">
      <div className="flex items-center gap-3 flex-wrap">
        <Link href="/lims" className="muted hover:underline text-sm">← LIMS</Link>
        <h1 className="text-xl font-bold">Amostra {code}</h1>
        <span className={`text-xs px-2 py-0.5 rounded-md font-semibold ${SAMPLE_STATUS[st]?.cls ?? ""}`}>{SAMPLE_STATUS[st]?.label ?? st}</span>
        <span className="ml-auto text-sm muted">{sampleTypeLabel(sample.sample_type)}{lot ? ` · lote ${lot.lot_number} (${lot.quality_status})` : ""}</span>
      </div>

      <div className="card p-4">
        <div className="font-semibold mb-3">Ensaios ({tests.length}) · {done} com resultado{failing > 0 ? ` · ${failing} fora da especificação` : ""}</div>
        {editable && (
          <div className="space-y-2 mb-4 pb-4 border-b" style={{ borderColor: "var(--border)" }}>
            {specs.length > 0 && (
              <div className="max-w-md">
                <label className="text-xs font-semibold muted">Usar especificação do produto</label>
                <select value={t.specId} onChange={(e) => pickSpec(e.target.value)}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                  <option value="">— manual —</option>
                  {specs.map((s) => <option key={s.id} value={s.id}>{s.parameter} ({s.min_value ?? "—"}…{s.max_value ?? "—"} {s.unit ?? ""})</option>)}
                </select>
              </div>
            )}
            <div className="grid md:grid-cols-6 gap-2 items-end">
              <div className="md:col-span-2"><label className="text-xs font-semibold muted">Parâmetro</label>
                <input value={t.parameter} onChange={(e) => setT({ ...t, parameter: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div><label className="text-xs font-semibold muted">Resultado</label>
                <input type="number" value={t.result_value} onChange={(e) => setT({ ...t, result_value: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div><label className="text-xs font-semibold muted">Un.</label>
                <input value={t.unit} onChange={(e) => setT({ ...t, unit: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div><label className="text-xs font-semibold muted">Mín</label>
                <input type="number" value={t.spec_min} onChange={(e) => setT({ ...t, spec_min: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div className="flex gap-2 items-end">
                <div className="flex-1"><label className="text-xs font-semibold muted">Máx</label>
                  <input type="number" value={t.spec_max} onChange={(e) => setT({ ...t, spec_max: e.target.value })}
                    className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
                <button onClick={addTest} disabled={busy} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">+ Add</button>
              </div>
            </div>
          </div>
        )}
        {tests.length === 0 ? <p className="text-sm muted">Nenhum ensaio. Adicione os ensaios da amostra.</p> : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="text-left muted text-xs uppercase"><th className="py-1.5 pr-3">Parâmetro</th><th className="pr-3">Resultado</th><th className="pr-3">Especificação</th><th className="pr-3">Conforme</th><th></th></tr></thead>
              <tbody>
                {tests.map((x) => (
                  <tr key={x.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                    <td className="py-1.5 pr-3">{x.parameter}</td>
                    <td className="pr-3 tabular-nums">{x.result_value ?? x.result_text ?? "—"}{x.unit ? " " + x.unit : ""}</td>
                    <td className="pr-3 muted text-xs">{x.spec_min ?? "—"} … {x.spec_max ?? "—"}</td>
                    <td className="pr-3">{x.result_value == null ? <span className="muted text-xs">pendente</span> : x.conforms ? <span className="text-green-500 font-semibold">✓ conforme</span> : <span className="text-red-500 font-semibold">✗ fora</span>}</td>
                    <td className="text-right">{editable && <button onClick={() => removeTest(x.id)} className="text-xs text-red-500 hover:underline">excluir</button>}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <div className="card p-4 space-y-2">
        <div className="font-semibold">Liberação</div>
        <p className="text-xs muted">Avalia todos os ensaios contra a especificação. Se todos conformes → amostra aprovada e lote liberado; se algum fora → reprovada e lote bloqueado.</p>
        <button onClick={release} disabled={busy || !canRelease}
          className="px-4 py-2 rounded-lg bg-green-600 text-white text-sm font-semibold disabled:opacity-60">🧪 Avaliar e liberar amostra</button>
        {!canRelease && st !== "approved" && st !== "rejected" && <span className="text-xs muted ml-2">preencha o resultado de todos os ensaios para liberar</span>}
        {msg && <div className={`text-sm font-semibold ${msg.includes("REPROVADA") ? "text-red-500" : "text-green-500"}`}>{msg}</div>}
        {err && <div className="text-sm text-red-500">{err}</div>}
      </div>
    </div>
  );
}
