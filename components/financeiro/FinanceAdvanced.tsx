"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const money = (n: any) => (n == null ? "—" : Number(n).toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 }));

// ── Painel: KPIs EFP + forecast de caixa + IA de anomalias ──────────────────
export function FinancePanel({ fin, forecast }: { fin: any; forecast: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  async function runIA() {
    if (!supabase) return;
    setBusy(true); setMsg(null);
    const { data, error } = await supabase.rpc("detect_financial_anomalies", { p_company: COMPANY });
    setBusy(false);
    setMsg(error ? error.message : `IA analisou o financeiro: ${data ?? 0} anomalia(s)/duplicidade(s) detectada(s). Veja em LOGIA.`);
    router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="card p-3 flex items-center gap-3">
        <div className="text-sm"><b>✦ IA Financeira</b> <span className="muted">— detecta pagamentos duplicados e valores fora do padrão.</span></div>
        <button onClick={runIA} disabled={busy} className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white font-semibold disabled:opacity-60">
          {busy ? "Analisando…" : "Detectar anomalias"}
        </button>
      </div>
      {msg && <div className="text-sm text-brand-500 px-1">{msg}</div>}

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <KpiCard label="A receber (aberto)" value={money(fin?.ar_open)} />
        <KpiCard label="A pagar (aberto)" value={money(fin?.ap_open)} />
        <KpiCard label="Posição líquida" value={money(fin?.net_position)} accent />
        <KpiCard label="Vencido (receber)" value={money(fin?.ar_overdue)} />
        <KpiCard label="DSO (dias)" value={fin?.dso ?? "—"} hint="prazo médio de recebimento" />
        <KpiCard label="DPO (dias)" value={fin?.dpo ?? "—"} hint="prazo médio de pagamento" />
        <KpiCard label="Investimentos" value={money(fin?.investments)} />
        <KpiCard label="Dívida" value={money(fin?.debt)} />
      </div>

      <ForecastChart data={forecast} />
    </div>
  );
}

function ForecastChart({ data }: { data: any[] }) {
  if (!data || data.length === 0) return <p className="text-sm muted px-1">Sem títulos com vencimento nos próximos 30 dias para projetar o caixa.</p>;
  const W = 900, H = 220, padX = 46, padY = 16;
  const cum = data.map((d) => Number(d.cumulative));
  const lo = Math.min(0, ...cum), hi = Math.max(0, ...cum), range = hi - lo || 1;
  const x = (i: number) => padX + (i / Math.max(data.length - 1, 1)) * (W - 2 * padX);
  const y = (v: number) => padY + (1 - (v - lo) / range) * (H - 2 * padY);
  const path = data.map((d, i) => `${i === 0 ? "M" : "L"} ${x(i).toFixed(1)} ${y(Number(d.cumulative)).toFixed(1)}`).join(" ");
  const zeroY = y(0);
  return (
    <div className="card p-3">
      <div className="text-sm font-semibold mb-1">Projeção de caixa — 30 dias (acumulado AR − AP)</div>
      <div className="overflow-x-auto">
        <svg viewBox={`0 0 ${W} ${H}`} className="w-full" style={{ minWidth: 600 }}>
          <line x1={padX} x2={W - padX} y1={zeroY} y2={zeroY} stroke="#94a3b8" strokeWidth="1" strokeDasharray="3 3" />
          <path d={path} fill="none" stroke="#3563e9" strokeWidth="1.5" />
          {data.map((d, i) => (
            <circle key={i} cx={x(i)} cy={y(Number(d.cumulative))} r="2" fill={Number(d.cumulative) < 0 ? "#ef4444" : "#3563e9"} />
          ))}
          <text x={padX} y={zeroY - 3} fontSize="9" fill="#94a3b8">R$ 0</text>
        </svg>
      </div>
    </div>
  );
}

// ── Conciliação bancária ────────────────────────────────────────────────────
export function ReconcilePanel({ statements }: { statements: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);

  async function reconcile(id: string) {
    if (!supabase) return;
    setBusy(id); setMsg(null);
    const { data, error } = await supabase.rpc("reconcile_bank_statement", { p_statement: id });
    setBusy(null);
    setMsg(error ? error.message : `${data ?? 0} lançamento(s) conciliado(s) automaticamente ✓`);
    router.refresh();
  }

  return (
    <div className="space-y-2">
      <div className="font-semibold">Conciliação bancária <span className="muted font-normal">({statements.length})</span></div>
      <p className="text-xs muted">Importe extratos (OFX/CNAB) e concilie automaticamente contra contas a pagar/receber por valor ±data.</p>
      {msg && <div className="text-sm text-green-500">{msg}</div>}
      {statements.length === 0 ? <p className="text-sm muted">Nenhum extrato importado. (Importação de arquivo OFX entra na próxima etapa; a estrutura e a conciliação automática já existem.)</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
              <th className="py-2 px-3">Extrato</th><th className="px-3">Período</th><th className="px-3">Status</th><th className="px-3 text-right"></th>
            </tr></thead>
            <tbody>
              {statements.map((s) => (
                <tr key={s.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-mono">{s.code ?? s.id.slice(0, 8)}</td>
                  <td className="px-3">{[s.period_start, s.period_end].filter(Boolean).join(" → ") || "—"}</td>
                  <td className="px-3">{s.status}</td>
                  <td className="px-3 text-right"><button onClick={() => reconcile(s.id)} disabled={busy === s.id} className="text-xs text-brand-500 hover:underline">{busy === s.id ? "conciliando…" : "conciliar"}</button></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

// ── Crédito: lista + recalcular scores ──────────────────────────────────────
export function CreditPanel({ credit, customers }: { credit: any[]; customers: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const custName = useMemo(() => Object.fromEntries(customers.map((c) => [c.id, c.name])), [customers]);

  async function recalcAll() {
    if (!supabase) return;
    setBusy(true); setMsg(null);
    let n = 0;
    for (const c of customers.slice(0, 200)) {
      const { error } = await supabase.rpc("compute_credit_score", { p_customer: c.id });
      if (!error) n++;
    }
    setBusy(false); setMsg(`${n} cliente(s) reavaliado(s) ✓`); router.refresh();
  }

  return (
    <div className="space-y-2">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Gestão de crédito <span className="muted font-normal">({credit.length})</span></div>
        <button onClick={recalcAll} disabled={busy || customers.length === 0} className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white font-semibold disabled:opacity-60">
          {busy ? "Calculando…" : "Recalcular scores"}
        </button>
      </div>
      {msg && <div className="text-sm text-green-500">{msg}</div>}
      {credit.length === 0 ? <p className="text-sm muted">Sem scores ainda. Clique em “Recalcular scores” (usa o histórico de recebimentos).</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
              <th className="py-2 px-3">Cliente</th><th className="px-3">Score</th><th className="px-3">Limite</th><th className="px-3">Exposição</th><th className="px-3">Vencido</th><th className="px-3">Status</th>
            </tr></thead>
            <tbody>
              {credit.map((c) => (
                <tr key={c.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3">{custName[c.customer_id] ?? "—"}</td>
                  <td className="px-3"><span className={`font-semibold ${c.score >= 70 ? "text-green-500" : c.score >= 40 ? "text-amber-500" : "text-red-500"}`}>{c.score ?? "—"}</span></td>
                  <td className="px-3">{money(c.credit_limit)}</td>
                  <td className="px-3">{money(c.exposure)}</td>
                  <td className="px-3">{money(c.overdue_amount)}</td>
                  <td className="px-3">{c.blocked ? <span className="text-red-500">Bloqueado</span> : "OK"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

// ── Consolidado do grupo ────────────────────────────────────────────────────
export function ConsolidatedPanel({ c }: { c: any }) {
  return (
    <div className="space-y-3">
      <div className="font-semibold">Consolidação financeira do grupo</div>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <KpiCard label="Empresas" value={c?.companies ?? "—"} />
        <KpiCard label="A receber (grupo)" value={money(c?.ar_open)} accent />
        <KpiCard label="A pagar (grupo)" value={money(c?.ap_open)} />
        <KpiCard label="Posição líquida" value={money((c?.ar_open ?? 0) - (c?.ap_open ?? 0))} />
        <KpiCard label="Vencido a receber" value={money(c?.ar_overdue)} />
        <KpiCard label="Vencido a pagar" value={money(c?.ap_overdue)} />
        <KpiCard label="Intercompany pendente" value={c?.intercompany_pending ?? "—"} hint="a eliminar" />
      </div>
    </div>
  );
}
