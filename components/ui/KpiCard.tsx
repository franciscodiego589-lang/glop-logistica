export function KpiCard({
  label, value, hint, accent = false, icon, tone = "brand",
}: {
  label: string; value: string | number; hint?: string; accent?: boolean;
  icon?: string; tone?: "brand" | "success" | "warning" | "danger" | "neutral";
}) {
  const toneVar: Record<string, string> = {
    brand: "var(--brand)", success: "var(--success)", warning: "var(--warning)", danger: "var(--danger)", neutral: "var(--muted)",
  };
  const soft: Record<string, string> = {
    brand: "var(--brand-soft)", success: "var(--success-soft)", warning: "var(--warning-soft)", danger: "var(--danger-soft)", neutral: "var(--surface-3)",
  };
  const c = toneVar[accent ? "warning" : tone];
  return (
    <div className="kpi card-hover relative overflow-hidden">
      <span className="absolute left-0 top-0 bottom-0 w-1" style={{ background: c }} />
      <div className="flex items-start justify-between gap-2">
        <div className="kpi-label">{label}</div>
        {icon && (
          <span className="h-8 w-8 rounded-lg grid place-items-center text-sm shrink-0"
            style={{ background: soft[accent ? "warning" : tone], color: c }}>{icon}</span>
        )}
      </div>
      <div className="kpi-value tabular-nums">{value}</div>
      {hint && <div className="mt-1 text-xs muted">{hint}</div>}
    </div>
  );
}
