import ExportButton from "@/components/ui/ExportButton";

// Renderizador genérico de relatório. Consome o contrato dos RPCs rel_*:
// { titulo, periodo, kpis:[...], secoes:[{tipo:'bars'|'tabela', ...}] }
const TONE: Record<string, string> = {
  success: "var(--success)", warning: "var(--warning)", danger: "var(--danger)", accent: "var(--brand)", neutral: "var(--text)",
};

function fmt(v: any, f?: string): string {
  if (v == null || v === "") return "—";
  if (f === "money") return "R$ " + Number(v).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  if (f === "int") return Number(v).toLocaleString("pt-BR");
  if (f === "pct") return Number(v).toLocaleString("pt-BR") + "%";
  if (f === "date") return new Date(v).toLocaleDateString("pt-BR");
  if (f === "datetime") return new Date(v).toLocaleString("pt-BR");
  return String(v);
}

export default function ReportView({ data }: { data: any }) {
  const kpis: any[] = data?.kpis ?? [];
  const secoes: any[] = data?.secoes ?? [];

  return (
    <div className="space-y-4">
      {/* KPIs */}
      {kpis.length > 0 && (
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
          {kpis.map((k, i) => (
            <div key={i} className="card p-4" style={{ borderTop: `3px solid ${TONE[k.tone] ?? "var(--border)"}` }}>
              <div className="text-xs uppercase muted font-semibold flex items-center gap-1">{k.icon && <span>{k.icon}</span>}{k.label}</div>
              <div className="text-xl font-bold mt-1 tabular-nums" style={{ color: k.tone && k.tone !== "neutral" ? TONE[k.tone] : undefined }}>{fmt(k.valor, k.fmt)}</div>
            </div>
          ))}
        </div>
      )}

      {/* Seções */}
      <div className="grid lg:grid-cols-2 gap-3">
        {secoes.map((s, si) => {
          if (s.tipo === "bars") {
            const itens: any[] = s.itens ?? [];
            const max = Math.max(1, ...itens.map((x) => Number(x.n) || 0));
            return (
              <div key={si} className="card p-4">
                <div className="font-bold text-sm mb-3">{s.titulo}</div>
                {itens.length === 0 ? <p className="text-xs muted">Sem dados no período.</p> : (
                  <div className="space-y-2">
                    {itens.map((x, xi) => (
                      <div key={xi}>
                        <div className="flex justify-between text-xs mb-0.5">
                          <span className="truncate pr-2">{x.label}</span>
                          <span className="muted tabular-nums shrink-0">{fmt(x.n, "int")}{x.valor != null ? " · " + fmt(x.valor, x.fmt) : ""}</span>
                        </div>
                        <div className="h-1.5 rounded-full overflow-hidden" style={{ background: "var(--surface-3)" }}>
                          <div className="h-full rounded-full" style={{ width: `${(Number(x.n) / max) * 100}%`, background: "var(--brand)" }} />
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            );
          }
          // tabela
          const colunas: any[] = s.colunas ?? [];
          const linhas: any[] = s.linhas ?? [];
          return (
            <div key={si} className="card p-4 lg:col-span-2">
              <div className="flex items-center justify-between mb-3">
                <div className="font-bold text-sm">{s.titulo}</div>
                {linhas.length > 0 && <ExportButton rows={linhas} filename={(s.titulo || "relatorio").toLowerCase().replace(/\s+/g, "-")} columns={colunas.map((c) => ({ key: c.key, label: c.label, fmt: (v: any) => fmt(v, c.fmt) }))} />}
              </div>
              {linhas.length === 0 ? <p className="text-xs muted">Sem dados no período.</p> : (
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                      {colunas.map((c) => <th key={c.key} className={`py-2 px-3 ${c.fmt === "money" || c.fmt === "int" ? "text-right" : ""}`}>{c.label}</th>)}
                    </tr></thead>
                    <tbody>
                      {linhas.map((r, ri) => (
                        <tr key={ri} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                          {colunas.map((c) => <td key={c.key} className={`py-1.5 px-3 ${c.fmt === "money" || c.fmt === "int" ? "text-right tabular-nums" : ""}`}>
                        {c.fmt === "link" && r[c.hrefKey ?? "href"]
                          ? <a href={r[c.hrefKey ?? "href"]} className="font-semibold no-underline" style={{ color: "var(--brand)" }}>{fmt(r[c.key], "text")} →</a>
                          : fmt(r[c.key], c.fmt)}
                      </td>)}
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
