"use client";
export default function PrintButton() {
  return (
    <button onClick={() => window.print()} className="px-2.5 py-1.5 rounded-lg border text-xs font-semibold" style={{ borderColor: "var(--border)" }}>
      🖨️ Imprimir / PDF
    </button>
  );
}
