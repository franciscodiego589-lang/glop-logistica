import React from "react";

// Renderizador de markdown leve (sem dependência externa) para os documentos jurídicos.
// Suporta: #..###### títulos, > citação, --- linha, listas - / 1., tabelas |, e
// inline **negrito**, *itálico*, `código`, [texto](url).

function inline(text: string, kb: string): React.ReactNode[] {
  const out: React.ReactNode[] = [];
  const re = /(\*\*([^*]+)\*\*)|(`([^`]+)`)|(\[([^\]]+)\]\(([^)]+)\))|(\*([^*\n]+)\*)/g;
  let last = 0, i = 0, m: RegExpExecArray | null;
  while ((m = re.exec(text))) {
    if (m.index > last) out.push(text.slice(last, m.index));
    if (m[2] !== undefined) out.push(<strong key={kb + i}>{m[2]}</strong>);
    else if (m[4] !== undefined) out.push(<code key={kb + i} className="px-1 py-0.5 rounded text-[.85em] font-mono" style={{ background: "var(--surface-3)" }}>{m[4]}</code>);
    else if (m[6] !== undefined) out.push(<a key={kb + i} href={m[7]} className="underline" style={{ color: "var(--brand)" }}>{m[6]}</a>);
    else if (m[9] !== undefined) out.push(<em key={kb + i}>{m[9]}</em>);
    last = m.index + m[0].length; i++;
  }
  if (last < text.length) out.push(text.slice(last));
  return out;
}

const isSpecial = (l: string) =>
  /^\s*#{1,6}\s+/.test(l) || /^\s*---+\s*$/.test(l) || /^\s*>\s?/.test(l) ||
  /^\s*\d+\.\s+/.test(l) || /^\s*[-*]\s+/.test(l) || l.includes("|");

const cells = (row: string) => row.replace(/^\s*\|/, "").replace(/\|\s*$/, "").split("|").map((c) => c.trim());

export default function LegalMarkdown({ md }: { md: string }) {
  const lines = (md || "").replace(/\r\n/g, "\n").split("\n");
  const blocks: React.ReactNode[] = [];
  let i = 0, k = 0;

  while (i < lines.length) {
    const line = lines[i];
    if (!line.trim()) { i++; continue; }

    // linha horizontal
    if (/^\s*---+\s*$/.test(line)) { blocks.push(<hr key={k++} className="my-6" style={{ borderColor: "var(--border)" }} />); i++; continue; }

    // títulos
    const h = line.match(/^\s*(#{1,6})\s+(.*)$/);
    if (h) {
      const lvl = h[1].length, txt = h[2];
      const cls = lvl <= 1 ? "text-2xl font-extrabold mt-2 mb-1"
        : lvl === 2 ? "text-xl font-bold mt-7 mb-1 pb-1 border-b"
        : lvl === 3 ? "text-base font-bold mt-5 mb-0.5"
        : "text-sm font-semibold mt-3";
      const style = lvl === 2 ? { borderColor: "var(--border)" } : undefined;
      blocks.push(React.createElement(`h${Math.min(lvl, 6)}`, { key: k++, className: cls, style }, inline(txt, `h${k}-`)));
      i++; continue;
    }

    // citação (aviso de minuta etc.)
    if (/^\s*>\s?/.test(line)) {
      const buf: string[] = [];
      while (i < lines.length && /^\s*>\s?/.test(lines[i])) { buf.push(lines[i].replace(/^\s*>\s?/, "")); i++; }
      blocks.push(
        <blockquote key={k++} className="my-4 pl-3 py-2 rounded-r-lg text-sm" style={{ borderLeft: "3px solid var(--warning)", background: "var(--surface-2)" }}>
          {buf.map((b, j) => <p key={j} className={j ? "mt-1" : ""}>{inline(b, `q${k}-${j}-`)}</p>)}
        </blockquote>
      );
      continue;
    }

    // tabela: linha com | seguida de separadora |---|
    if (line.includes("|") && i + 1 < lines.length && /-/.test(lines[i + 1]) && /^\s*\|?[\s:|-]+\|?\s*$/.test(lines[i + 1])) {
      const header = cells(line);
      i += 2;
      const rows: string[][] = [];
      while (i < lines.length && lines[i].includes("|") && lines[i].trim()) { rows.push(cells(lines[i])); i++; }
      blocks.push(
        <div key={k++} className="my-4 overflow-x-auto">
          <table className="w-full text-sm border-collapse">
            <thead><tr>{header.map((c, j) => <th key={j} className="text-left font-semibold p-2 border" style={{ borderColor: "var(--border)", background: "var(--surface-2)" }}>{inline(c, `th${k}-${j}-`)}</th>)}</tr></thead>
            <tbody>{rows.map((r, ri) => <tr key={ri}>{header.map((_, ci) => <td key={ci} className="p-2 border align-top" style={{ borderColor: "var(--border)" }}>{inline(r[ci] ?? "", `td${k}-${ri}-${ci}-`)}</td>)}</tr>)}</tbody>
          </table>
        </div>
      );
      continue;
    }

    // lista ordenada
    if (/^\s*\d+\.\s+/.test(line)) {
      const items: string[] = [];
      while (i < lines.length && /^\s*\d+\.\s+/.test(lines[i])) { items.push(lines[i].replace(/^\s*\d+\.\s+/, "")); i++; }
      blocks.push(<ol key={k++} className="list-decimal pl-6 space-y-1 text-sm">{items.map((it, j) => <li key={j}>{inline(it, `ol${k}-${j}-`)}</li>)}</ol>);
      continue;
    }

    // lista não ordenada
    if (/^\s*[-*]\s+/.test(line)) {
      const items: string[] = [];
      while (i < lines.length && /^\s*[-*]\s+/.test(lines[i])) { items.push(lines[i].replace(/^\s*[-*]\s+/, "")); i++; }
      blocks.push(<ul key={k++} className="list-disc pl-6 space-y-1 text-sm">{items.map((it, j) => <li key={j}>{inline(it, `ul${k}-${j}-`)}</li>)}</ul>);
      continue;
    }

    // parágrafo
    const buf: string[] = [];
    while (i < lines.length && lines[i].trim() && !isSpecial(lines[i])) { buf.push(lines[i]); i++; }
    if (buf.length) blocks.push(<p key={k++} className="text-sm leading-relaxed" style={{ color: "var(--text)" }}>{inline(buf.join(" "), `p${k}-`)}</p>);
    else { i++; } // segurança contra loop
  }

  return <div className="legal-doc max-w-3xl">{blocks}</div>;
}
