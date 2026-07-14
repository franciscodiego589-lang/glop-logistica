"use client";
import { useMemo, useState } from "react";

// Fatores para a unidade-base de cada dimensão (massa→mg, volume→mL)
const MASS: Record<string, number> = { kg: 1e6, g: 1e3, mg: 1, mcg: 1e-3 };
const VOL: Record<string, number> = { L: 1000, mL: 1 };

// UI (Unidade Internacional) depende da substância — fatores de referência usuais
const IU: Record<string, { label: string; perIU: number; unit: string; note: string }> = {
  vitA: { label: "Vitamina A (retinol)", perIU: 0.3, unit: "mcg", note: "1 UI = 0,3 mcg RAE" },
  vitD: { label: "Vitamina D", perIU: 0.025, unit: "mcg", note: "1 UI = 0,025 mcg (1 mcg = 40 UI)" },
  vitE: { label: "Vitamina E (d-alfa natural)", perIU: 0.67, unit: "mg", note: "1 UI = 0,67 mg (natural); 0,45 mg (sintética)" },
};

function fmt(n: number) {
  if (!isFinite(n)) return "—";
  return n.toLocaleString("pt-BR", { maximumFractionDigits: 6 });
}

export default function UnitConverter() {
  const [dim, setDim] = useState<"mass" | "vol">("mass");
  const [val, setVal] = useState("1");
  const [from, setFrom] = useState("g");
  const [to, setTo] = useState("mg");

  const table = dim === "mass" ? MASS : VOL;
  const units = Object.keys(table);
  const result = useMemo(() => {
    const v = Number(val);
    if (!isFinite(v) || !(table as any)[from] || !(table as any)[to]) return null;
    return v * table[from] / table[to];
  }, [val, from, to, dim]);

  // manter unidades válidas ao trocar de dimensão
  function switchDim(d: "mass" | "vol") {
    setDim(d);
    if (d === "mass") { setFrom("g"); setTo("mg"); } else { setFrom("L"); setTo("mL"); }
  }

  // ── IU ──
  const [subst, setSubst] = useState("vitD");
  const [iuVal, setIuVal] = useState("1000");
  const [iuMode, setIuMode] = useState<"iu2mass" | "mass2iu">("iu2mass");
  const iu = IU[subst]!;
  const iuResult = useMemo(() => {
    const v = Number(iuVal);
    if (!isFinite(v)) return null;
    return iuMode === "iu2mass" ? v * iu.perIU : v / iu.perIU;
  }, [iuVal, iuMode, subst]);

  return (
    <div className="space-y-4">
      <div className="card p-4 space-y-3">
        <div className="font-semibold">Conversor de unidades</div>
        <div className="flex gap-1">
          {(["mass", "vol"] as const).map((d) => (
            <button key={d} onClick={() => switchDim(d)}
              className={`px-3 py-1.5 rounded-lg text-sm ${dim === d ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>
              {d === "mass" ? "Massa (kg/g/mg/mcg)" : "Volume (L/mL)"}
            </button>
          ))}
        </div>
        <div className="grid md:grid-cols-4 gap-3 items-end">
          <div><label className="text-xs font-semibold muted">Valor</label>
            <input type="number" value={val} onChange={(e) => setVal(e.target.value)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          <div><label className="text-xs font-semibold muted">De</label>
            <select value={from} onChange={(e) => setFrom(e.target.value)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              {units.map((u) => <option key={u} value={u}>{u}</option>)}
            </select></div>
          <div><label className="text-xs font-semibold muted">Para</label>
            <select value={to} onChange={(e) => setTo(e.target.value)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              {units.map((u) => <option key={u} value={u}>{u}</option>)}
            </select></div>
          <div className="rounded-lg border p-2 ring-1 ring-brand-500/40" style={{ borderColor: "var(--border)" }}>
            <div className="text-xs muted">Resultado</div>
            <b className="tabular-nums">{result == null ? "—" : `${fmt(result)} ${to}`}</b>
          </div>
        </div>
      </div>

      <div className="card p-4 space-y-3">
        <div className="font-semibold">UI ↔ massa (vitaminas)</div>
        <p className="text-xs muted">A Unidade Internacional depende da substância. Fatores de referência — confira sempre a monografia do insumo.</p>
        <div className="grid md:grid-cols-4 gap-3 items-end">
          <div><label className="text-xs font-semibold muted">Substância</label>
            <select value={subst} onChange={(e) => setSubst(e.target.value)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              {Object.entries(IU).map(([k, v]) => <option key={k} value={k}>{v.label}</option>)}
            </select></div>
          <div><label className="text-xs font-semibold muted">Direção</label>
            <select value={iuMode} onChange={(e) => setIuMode(e.target.value as any)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="iu2mass">UI → {iu.unit}</option>
              <option value="mass2iu">{iu.unit} → UI</option>
            </select></div>
          <div><label className="text-xs font-semibold muted">{iuMode === "iu2mass" ? "UI" : iu.unit}</label>
            <input type="number" value={iuVal} onChange={(e) => setIuVal(e.target.value)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
          <div className="rounded-lg border p-2 ring-1 ring-brand-500/40" style={{ borderColor: "var(--border)" }}>
            <div className="text-xs muted">Resultado</div>
            <b className="tabular-nums">{iuResult == null ? "—" : `${fmt(iuResult)} ${iuMode === "iu2mass" ? iu.unit : "UI"}`}</b>
          </div>
        </div>
        <p className="text-xs muted">{iu.note}</p>
      </div>
    </div>
  );
}
