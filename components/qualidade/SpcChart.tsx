"use client";
import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

export default function SpcChart() {
  const supabase = useMemo(() => createClient(), []);
  const [params, setParams] = useState<string[]>([]);
  const [param, setParam] = useState("");
  const [stat, setStat] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!supabase) return;
    (async () => {
      const { data } = await supabase.rpc("spc_parameters", { p_company: COMPANY });
      const list = (data as string[]) ?? [];
      setParams(list);
      if (list.length && !param) setParam(list[0]);
    })();
    // eslint-disable-next-line
  }, [supabase]);

  useEffect(() => {
    if (!supabase || !param) return;
    setLoading(true);
    supabase.rpc("spc_analysis", { p_company: COMPANY, p_parameter: param, p_days: 90 }).then(({ data }) => {
      setStat(data); setLoading(false);
    });
  }, [supabase, param]);

  const cpk = stat?.cpk;
  const cpkColor = cpk == null ? "" : cpk >= 1.33 ? "text-green-500" : cpk >= 1 ? "text-amber-500" : "text-red-500";

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Controle Estatístico de Processo (CEP/SPC)</div>
        <select value={param} onChange={(e) => setParam(e.target.value)}
          className="ml-auto border rounded-lg px-3 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
          {params.length === 0 && <option value="">— sem leituras —</option>}
          {params.map((p) => <option key={p} value={p}>{p}</option>)}
        </select>
      </div>

      {params.length === 0 ? (
        <p className="text-sm muted">Nenhuma leitura de processo ainda. Registre parâmetros no módulo <b>MES / Chão de Fábrica → Processo</b> para ver as cartas de controle.</p>
      ) : loading ? (
        <p className="text-sm muted">Calculando…</p>
      ) : !stat || stat.n === 0 ? (
        <p className="text-sm muted">Sem dados para “{param}”.</p>
      ) : (
        <>
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="Amostras (n)" value={stat.n} />
            <KpiCard label="Média" value={stat.mean} />
            <div className={`card p-4`}>
              <div className="text-xs uppercase tracking-wide muted font-semibold">Cp</div>
              <div className="mt-2 text-2xl font-bold tabular-nums">{stat.cp ?? "—"}</div>
            </div>
            <div className="card p-4 ring-1 ring-brand-500/40">
              <div className="text-xs uppercase tracking-wide muted font-semibold">Cpk (capabilidade)</div>
              <div className={`mt-2 text-2xl font-bold tabular-nums ${cpkColor}`}>{stat.cpk ?? "—"}</div>
              <div className="mt-1 text-xs muted">{cpk == null ? "" : cpk >= 1.33 ? "Capaz" : cpk >= 1 ? "Marginal" : "Incapaz"}</div>
            </div>
          </div>
          <Chart stat={stat} />
        </>
      )}
    </div>
  );
}

function Chart({ stat }: { stat: any }) {
  const pts: { t: string; v: number }[] = stat.points ?? [];
  if (pts.length === 0) return null;
  const W = 900, H = 280, padX = 40, padY = 20;
  const vals = pts.map((p) => p.v);
  const lines = [stat.ucl, stat.lcl, stat.usl, stat.lsl, stat.mean].filter((x) => x != null) as number[];
  const lo = Math.min(...vals, ...lines), hi = Math.max(...vals, ...lines);
  const range = hi - lo || 1;
  const x = (i: number) => padX + (i / Math.max(pts.length - 1, 1)) * (W - 2 * padX);
  const y = (v: number) => padY + (1 - (v - lo) / range) * (H - 2 * padY);
  const path = pts.map((p, i) => `${i === 0 ? "M" : "L"} ${x(i).toFixed(1)} ${y(p.v).toFixed(1)}`).join(" ");
  const hline = (v: number | null, color: string, label: string, dash = "4 3") =>
    v == null ? null : (
      <g>
        <line x1={padX} x2={W - padX} y1={y(v)} y2={y(v)} stroke={color} strokeWidth="1" strokeDasharray={dash} />
        <text x={W - padX + 2} y={y(v) + 3} fontSize="9" fill={color}>{label}</text>
      </g>
    );
  return (
    <div className="card p-3 overflow-x-auto">
      <svg viewBox={`0 0 ${W} ${H}`} className="w-full" style={{ minWidth: 600 }}>
        {hline(stat.usl, "#ef4444", "USL")}
        {hline(stat.lsl, "#ef4444", "LSL")}
        {hline(stat.ucl, "#f59e0b", "UCL")}
        {hline(stat.lcl, "#f59e0b", "LCL")}
        {hline(stat.mean, "#3563e9", "x̄", "2 2")}
        <path d={path} fill="none" stroke="#3563e9" strokeWidth="1.5" />
        {pts.map((p, i) => {
          const oor = (stat.usl != null && p.v > stat.usl) || (stat.lsl != null && p.v < stat.lsl);
          return <circle key={i} cx={x(i)} cy={y(p.v)} r={oor ? 4 : 2.5} fill={oor ? "#ef4444" : "#3563e9"} />;
        })}
      </svg>
    </div>
  );
}
