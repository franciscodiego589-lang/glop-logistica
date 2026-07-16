"use client";
import { usePathname } from "next/navigation";
import Link from "next/link";
import { useEffect, useState } from "react";
import { getHelp } from "@/lib/help";

// Caixa de ajuda contextual ("Para que serve esta tela"), injetada no layout —
// aparece em TODA tela. Encolhível com preferência GLOBAL: encolher numa tela
// mantém encolhido em todas até reabrir (chave única no navegador).
const PREF = "help:open"; // global (1 = aberto, 0 = encolhido)

export default function HelpBar() {
  const pathname = usePathname() || "/";
  const slug = pathname.split("/").filter(Boolean)[0] ?? "dashboard";
  const [open, setOpen] = useState(true);
  const [ready, setReady] = useState(false);

  // lê a preferência global uma vez e acompanha mudanças feitas em outras abas
  useEffect(() => {
    setReady(true);
    try { setOpen(localStorage.getItem(PREF) !== "0"); } catch {}
    const onStorage = (e: StorageEvent) => { if (e.key === PREF) setOpen(e.newValue !== "0"); };
    const onPref = () => { try { setOpen(localStorage.getItem(PREF) !== "0"); } catch {} };
    window.addEventListener("storage", onStorage);
    window.addEventListener("help-pref-changed", onPref);
    return () => { window.removeEventListener("storage", onStorage); window.removeEventListener("help-pref-changed", onPref); };
  }, []);

  const help = getHelp(slug);
  if (!help || slug === "manual") return null;

  function toggle() {
    const v = !open; setOpen(v);
    try { localStorage.setItem(PREF, v ? "1" : "0"); } catch {}
    // avisa outras instâncias montadas nesta mesma aba
    window.dispatchEvent(new Event("help-pref-changed"));
  }

  return (
    <div className="card mb-4 p-0 overflow-hidden" style={{ borderLeft: "3px solid var(--brand)" }}>
      <button onClick={toggle} className="w-full flex items-center gap-2 px-4 py-2.5 text-left hover:bg-black/5 dark:hover:bg-white/5">
        <span>💡</span>
        <span className="font-semibold text-sm">Para que serve esta tela</span>
        <span className="ml-auto text-xs muted">{ready && open ? "ocultar ▾" : "mostrar ▸"}</span>
      </button>
      {ready && open && (
        <div className="px-4 pb-3 text-sm space-y-2" style={{ borderTop: "1px solid var(--border)" }}>
          <p className="muted mt-2">{help.resumo}</p>
          {help.itens && help.itens.length > 0 && (
            <ul className="list-disc pl-5 space-y-1 muted">
              {help.itens.map((it, i) => <li key={i}>{it}</li>)}
            </ul>
          )}
          {help.passos && help.passos.length > 0 && (
            <div className="pt-1">
              <div className="text-xs font-semibold mb-1">Passo a passo</div>
              <ol className="list-decimal pl-5 space-y-1 muted">
                {help.passos.map((p, i) => <li key={i}>{p}</li>)}
              </ol>
            </div>
          )}
          <div className="pt-1">
            <Link href="/manual" className="text-xs font-semibold" style={{ color: "var(--brand)" }}>📖 Ver o manual completo →</Link>
          </div>
        </div>
      )}
    </div>
  );
}
