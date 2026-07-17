"use client";
import { useEffect } from "react";
import Link from "next/link";

// Abre o diálogo de impressão automaticamente ao carregar o documento de PDF,
// e oferece uma barra (escondida na impressão) caso o navegador bloqueie o auto-print.
export default function AutoPrint({ voltarHref }: { voltarHref: string }) {
  useEffect(() => {
    const t = setTimeout(() => { try { window.print(); } catch {} }, 600);
    return () => clearTimeout(t);
  }, []);
  return (
    <div className="print-hide" style={{ position: "sticky", top: 0, zIndex: 40, display: "flex", gap: 8, justifyContent: "center", padding: "10px", background: "var(--surface-2)", borderBottom: "1px solid var(--border)" }}>
      <button onClick={() => window.print()} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">🖨️ Imprimir / Salvar PDF</button>
      <Link href={voltarHref} className="px-4 py-2 rounded-lg border text-sm font-semibold no-underline" style={{ borderColor: "var(--border)" }}>← Voltar ao relatório</Link>
    </div>
  );
}
