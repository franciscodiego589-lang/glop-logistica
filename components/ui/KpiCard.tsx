export function KpiCard({
  label, value, hint, accent = false,
}: { label: string; value: string | number; hint?: string; accent?: boolean }) {
  return (
    <div className={`card p-4 ${accent ? "ring-1 ring-brand-500/40" : ""}`}>
      <div className="text-xs uppercase tracking-wide muted font-semibold">{label}</div>
      <div className="mt-2 text-2xl font-bold tabular-nums">{value}</div>
      {hint && <div className="mt-1 text-xs muted">{hint}</div>}
    </div>
  );
}
