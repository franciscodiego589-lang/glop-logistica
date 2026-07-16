"use client";
export default function PrintButton({ label = "🖨️ Imprimir / PDF" }: { label?: string }) {
  return (
    <button onClick={() => window.print()} className="px-3 py-1.5 rounded-lg border text-xs font-semibold" style={{ borderColor: "var(--border)" }}>
      {label}
    </button>
  );
}
