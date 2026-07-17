import { EMPRESA } from "@/lib/empresa";

// Documento de impressão / PDF de um relatório — nível empresa grande.
// Renderiza o relatório INTEIRO (todos os KPIs, todas as barras, TODAS as linhas
// das tabelas — sem paginação), com papel timbrado e rodapé. Componente puro
// (sem hooks) → roda no servidor. Consome o contrato auto-descritivo dos RPCs rel_*.

function fmt(v: any, f?: string): string {
  if (v == null || v === "") return "—";
  if (f === "money") return "R$ " + Number(v).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  if (f === "int") return Number(v).toLocaleString("pt-BR");
  if (f === "pct") return Number(v).toLocaleString("pt-BR") + "%";
  if (f === "date") return new Date(v).toLocaleDateString("pt-BR");
  if (f === "datetime") return new Date(v).toLocaleString("pt-BR");
  return String(v);
}

const TONE: Record<string, string> = {
  success: "#0b7a3b", warning: "#b45309", danger: "#b91c1c", accent: "#1f5eff", brand: "#1f5eff", neutral: "#334155",
};

export default function ReportPrintDocument({
  data, titulo, subtitulo, geradoEm, numero,
}: { data: any; titulo: string; subtitulo?: string; geradoEm: string; numero: string }) {
  const kpis: any[] = data?.kpis ?? [];
  const secoes: any[] = data?.secoes ?? [];

  return (
    <div className="report-doc">
      {/* ── Papel timbrado ─────────────────────────────────────────────── */}
      <div className="rd-letterhead">
        <div className="rd-brandrow">
          <div className="rd-brand">
            <div className="rd-logo">{EMPRESA.sigla}</div>
            <div>
              <div className="rd-empresa">{EMPRESA.razaoSocial}</div>
              <div className="rd-empresa-sub">CNPJ {EMPRESA.cnpj} · {EMPRESA.email}</div>
            </div>
          </div>
          <div className="rd-meta">
            <div className="rd-meta-line"><span>Relatório nº</span><b>{numero}</b></div>
            <div className="rd-meta-line"><span>Emitido em</span><b>{geradoEm}</b></div>
            <div className="rd-meta-line"><span>Sistema</span><b>{EMPRESA.sistema}</b></div>
          </div>
        </div>
        <div className="rd-rule" />
        <h1 className="rd-title">{titulo}</h1>
        {subtitulo && <div className="rd-subtitle">{subtitulo}</div>}
      </div>

      {/* ── KPIs ───────────────────────────────────────────────────────── */}
      {kpis.length > 0 && (
        <div className="rd-kpis">
          {kpis.map((k, i) => (
            <div key={i} className="rd-kpi" style={{ borderTopColor: TONE[k.tone] ?? "#cbd5e1" }}>
              <div className="rd-kpi-label">{k.icon ? k.icon + " " : ""}{k.label}</div>
              <div className="rd-kpi-value" style={{ color: k.tone && k.tone !== "neutral" ? (TONE[k.tone] ?? undefined) : undefined }}>{fmt(k.valor, k.fmt)}</div>
            </div>
          ))}
        </div>
      )}

      {/* ── Seções ─────────────────────────────────────────────────────── */}
      {secoes.map((s, si) => {
        if (s.tipo === "bars") {
          const itens: any[] = s.itens ?? [];
          const max = Math.max(1, ...itens.map((x) => Number(x.n) || 0));
          return (
            <section key={si} className="rd-section">
              <h2 className="rd-section-title">{s.titulo}</h2>
              {itens.length === 0 ? <p className="rd-empty">Sem dados no período.</p> : (
                <div className="rd-bars">
                  {itens.map((x, xi) => (
                    <div key={xi} className="rd-bar-row">
                      <div className="rd-bar-head">
                        <span className="rd-bar-label">{x.label}</span>
                        <span className="rd-bar-num">{fmt(x.n, "int")}{x.valor != null ? " · " + fmt(x.valor, x.fmt) : ""}</span>
                      </div>
                      <div className="rd-bar-track"><div className="rd-bar-fill" style={{ width: `${(Number(x.n) / max) * 100}%` }} /></div>
                    </div>
                  ))}
                </div>
              )}
            </section>
          );
        }
        // tabela — TODAS as linhas (sem paginação)
        const colunas: any[] = s.colunas ?? [];
        const linhas: any[] = s.linhas ?? [];
        return (
          <section key={si} className="rd-section">
            <h2 className="rd-section-title">{s.titulo} <span className="rd-count">({linhas.length})</span></h2>
            {linhas.length === 0 ? <p className="rd-empty">Sem dados no período.</p> : (
              <table className="rd-table">
                <thead>
                  <tr>{colunas.map((c) => <th key={c.key} className={c.fmt === "money" || c.fmt === "int" || c.fmt === "pct" ? "num" : ""}>{c.label}</th>)}</tr>
                </thead>
                <tbody>
                  {linhas.map((row, ri) => (
                    <tr key={ri}>
                      {colunas.map((c) => (
                        <td key={c.key} className={c.fmt === "money" || c.fmt === "int" || c.fmt === "pct" ? "num" : ""}>
                          {fmt(row[c.key], c.fmt === "link" ? "text" : c.fmt)}
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </section>
        );
      })}

      {/* ── Rodapé do documento (fim) ──────────────────────────────────── */}
      <div className="rd-endnote">
        Documento gerado automaticamente pelo {EMPRESA.sistema} em {geradoEm}. Dados extraídos da base operacional da empresa.
        Uso interno / confidencial.
      </div>

      {/* ── Rodapé corrido (repete em cada página impressa) ────────────── */}
      <div className="report-running-footer">
        <span>{EMPRESA.razaoSocial} · CNPJ {EMPRESA.cnpj}</span>
        <span>{numero} · Confidencial · Gerado por {EMPRESA.sigla}</span>
      </div>
    </div>
  );
}
