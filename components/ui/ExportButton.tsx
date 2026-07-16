"use client";

// Botão reutilizável de exportação CSV. Recebe as linhas e as colunas
// (chave + rótulo) e baixa um .csv — funciona em qualquer tabela do sistema.
export default function ExportButton({ rows, columns, filename = "export" }: {
  rows: any[];
  columns: { key: string; label: string; fmt?: (v: any, row: any) => string }[];
  filename?: string;
}) {
  function download() {
    if (!rows.length) return;
    const esc = (v: any) => {
      const s = v == null ? "" : String(v);
      return /[",;\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
    };
    const header = columns.map((c) => esc(c.label)).join(";");
    const lines = rows.map((r) => columns.map((c) => esc(c.fmt ? c.fmt(r[c.key], r) : r[c.key])).join(";"));
    const csv = "﻿" + [header, ...lines].join("\n"); // BOM p/ Excel PT-BR
    const url = URL.createObjectURL(new Blob([csv], { type: "text/csv;charset=utf-8" }));
    const a = document.createElement("a");
    a.href = url; a.download = `${filename}-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click(); URL.revokeObjectURL(url);
  }
  return (
    <button onClick={download} disabled={!rows.length} className="px-3 py-1.5 rounded-lg card text-sm font-semibold disabled:opacity-40" title="Exportar para CSV (abre no Excel)">
      ⬇️ CSV
    </button>
  );
}
