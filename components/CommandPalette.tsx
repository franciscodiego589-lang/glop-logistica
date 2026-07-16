"use client";
import { useEffect, useMemo, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { NAV } from "@/lib/nav";

// Busca/navegação global. Abre com Ctrl/Cmd+K (ou pelo campo de busca do topo,
// que dispara o evento "open-command-palette"). Filtra as 67 telas por nome/grupo/
// descrição, navega com ↑↓ + Enter, fecha com Esc.
export default function CommandPalette() {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [q, setQ] = useState("");
  const [i, setI] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k") { e.preventDefault(); setOpen((o) => !o); }
      if (e.key === "Escape") setOpen(false);
    }
    function onOpen() { setOpen(true); }
    window.addEventListener("keydown", onKey);
    window.addEventListener("open-command-palette", onOpen as any);
    return () => { window.removeEventListener("keydown", onKey); window.removeEventListener("open-command-palette", onOpen as any); };
  }, []);

  useEffect(() => { if (open) { setQ(""); setI(0); setTimeout(() => inputRef.current?.focus(), 20); } }, [open]);

  const results = useMemo(() => {
    const s = q.trim().toLowerCase();
    const list = NAV.filter((n) => !s || `${n.label} ${n.group} ${n.description}`.toLowerCase().includes(s));
    return list.slice(0, 40);
  }, [q]);

  useEffect(() => { if (i >= results.length) setI(0); }, [results.length, i]);

  function go(slug: string) { setOpen(false); router.push("/" + slug); }

  if (!open) return null;
  return (
    <div className="fixed inset-0 z-[100] flex items-start justify-center pt-[12vh] px-4" style={{ background: "rgba(0,0,0,.45)" }} onClick={() => setOpen(false)}>
      <div className="w-full max-w-xl rounded-2xl overflow-hidden shadow-2xl" style={{ background: "var(--surface-1)", border: "1px solid var(--border)" }} onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center gap-2 px-4 py-3 border-b" style={{ borderColor: "var(--border)" }}>
          <span className="muted">🔎</span>
          <input ref={inputRef} value={q}
            onChange={(e) => { setQ(e.target.value); setI(0); }}
            onKeyDown={(e) => {
              if (e.key === "ArrowDown") { e.preventDefault(); setI((v) => Math.min(v + 1, results.length - 1)); }
              if (e.key === "ArrowUp") { e.preventDefault(); setI((v) => Math.max(v - 1, 0)); }
              if (e.key === "Enter" && results[i]) { e.preventDefault(); go(results[i].slug); }
            }}
            placeholder="Buscar tela, módulo, função…" className="flex-1 bg-transparent outline-none text-sm py-1" />
          <kbd className="text-[10px] muted border rounded px-1.5 py-0.5" style={{ borderColor: "var(--border)" }}>Esc</kbd>
        </div>
        <div className="max-h-[52vh] overflow-y-auto py-1">
          {results.length === 0 ? <div className="px-4 py-6 text-sm muted text-center">Nada encontrado para “{q}”.</div> : results.map((n, idx) => (
            <button key={n.slug} onMouseEnter={() => setI(idx)} onClick={() => go(n.slug)}
              className={`w-full flex items-center gap-3 px-4 py-2 text-left ${idx === i ? "bg-brand-600 text-white" : "hover:bg-black/5 dark:hover:bg-white/5"}`}>
              <span className="text-base w-5 text-center">{n.icon}</span>
              <div className="flex-1 min-w-0">
                <div className="text-sm font-medium truncate">{n.label}</div>
                <div className={`text-[11px] truncate ${idx === i ? "text-white/80" : "muted"}`}>{n.group} · {n.description}</div>
              </div>
            </button>
          ))}
        </div>
        <div className="px-4 py-2 border-t text-[11px] muted flex gap-3" style={{ borderColor: "var(--border)" }}>
          <span>↑↓ navegar</span><span>↵ abrir</span><span>⌘/Ctrl K alternar</span>
        </div>
      </div>
    </div>
  );
}
