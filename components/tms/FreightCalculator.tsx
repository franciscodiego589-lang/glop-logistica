"use client";
import { useMemo, useState } from "react";

type Rate = {
  id: string; carrier_id: string; origin_uf: string | null; dest_uf: string | null;
  weight_from_kg: number | null; weight_to_kg: number | null;
  price_per_kg: number | null; price_fixed: number | null;
  gris_percent: number | null; advalorem_percent: number | null; lead_time_days: number | null;
};
type Carrier = { id: string; name: string };

const money = (n: number) => n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
const UFS = "AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO".split(" ");

export default function FreightCalculator({ rates, carriers }: { rates: Rate[]; carriers: Carrier[] }) {
  const [carrier, setCarrier] = useState("");
  const [uf, setUf] = useState("");
  const [weight, setWeight] = useState("");
  const [value, setValue] = useState("");

  const result = useMemo(() => {
    const w = Number(weight) || 0, v = Number(value) || 0;
    if (!w) return null;
    // rates candidatas: mesma transportadora (se escolhida), UF destino compatível, faixa de peso
    const cands = rates.filter((r) => {
      if (carrier && r.carrier_id !== carrier) return false;
      if (uf && r.dest_uf && r.dest_uf.toUpperCase() !== uf) return false;
      const from = r.weight_from_kg ?? 0, to = r.weight_to_kg ?? Infinity;
      return w >= from && w <= to;
    });
    if (cands.length === 0) return { ok: false as const };
    // escolhe a mais barata pelo frete-peso estimado
    const priced = cands.map((r) => {
      const fretePeso = Math.max((r.price_fixed ?? 0), w * (r.price_per_kg ?? 0));
      const gris = v * ((r.gris_percent ?? 0) / 100);
      const adval = v * ((r.advalorem_percent ?? 0) / 100);
      const total = fretePeso + gris + adval;
      return { r, fretePeso, gris, adval, total };
    }).sort((a, b) => a.total - b.total);
    const best = priced[0];
    if (!best) return { ok: false as const };
    return { ok: true as const, best, all: priced };
  }, [rates, carrier, uf, weight, value]);

  return (
    <div className="space-y-3">
      <div className="card p-4 space-y-3">
        <div className="font-semibold">Calculadora de frete</div>
        <p className="text-xs muted">Compara as tabelas de frete cadastradas e escolhe a mais econômica para o peso e valor da carga.</p>
        <div className="grid md:grid-cols-4 gap-3">
          <div>
            <label className="text-xs font-semibold muted">Transportadora</label>
            <select value={carrier} onChange={(e) => setCarrier(e.target.value)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="">Todas (melhor preço)</option>
              {carriers.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select>
          </div>
          <div>
            <label className="text-xs font-semibold muted">UF destino</label>
            <select value={uf} onChange={(e) => setUf(e.target.value)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="">Qualquer</option>
              {UFS.map((u) => <option key={u} value={u}>{u}</option>)}
            </select>
          </div>
          <div>
            <label className="text-xs font-semibold muted">Peso (kg)</label>
            <input type="number" value={weight} onChange={(e) => setWeight(e.target.value)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
          </div>
          <div>
            <label className="text-xs font-semibold muted">Valor da carga (R$)</label>
            <input type="number" value={value} onChange={(e) => setValue(e.target.value)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
          </div>
        </div>
      </div>

      {result && !result.ok && (
        <div className="card p-4 text-sm muted">Nenhuma tabela de frete compatível. Cadastre tabelas na aba <b>Tabelas de Frete</b>.</div>
      )}
      {result && result.ok && (
        <div className="card p-4">
          <div className="flex items-baseline gap-3">
            <div className="text-2xl font-bold tabular-nums">{money(result.best.total)}</div>
            <div className="text-sm muted">melhor opção
              {result.best.r.lead_time_days != null && <> · {result.best.r.lead_time_days}d de prazo</>}</div>
          </div>
          <div className="mt-3 grid sm:grid-cols-3 gap-2 text-sm">
            <div className="rounded-lg border p-2" style={{ borderColor: "var(--border)" }}><div className="text-xs muted">Frete-peso</div><b className="tabular-nums">{money(result.best.fretePeso)}</b></div>
            <div className="rounded-lg border p-2" style={{ borderColor: "var(--border)" }}><div className="text-xs muted">GRIS</div><b className="tabular-nums">{money(result.best.gris)}</b></div>
            <div className="rounded-lg border p-2" style={{ borderColor: "var(--border)" }}><div className="text-xs muted">Ad valorem</div><b className="tabular-nums">{money(result.best.adval)}</b></div>
          </div>
          {result.all.length > 1 && (
            <div className="mt-3 text-xs muted">Outras: {result.all.slice(1, 4).map((p) => money(p.total)).join(" · ")}</div>
          )}
        </div>
      )}
    </div>
  );
}
