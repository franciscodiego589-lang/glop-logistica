"use client";
import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import NotificationBell from "@/components/NotificationBell";

export default function Topbar({ email }: { email?: string | null }) {
  const router = useRouter();
  const [dark, setDark] = useState(false);
  const [menu, setMenu] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => setDark(document.documentElement.classList.contains("dark")), []);
  useEffect(() => {
    const onClick = (e: MouseEvent) => { if (ref.current && !ref.current.contains(e.target as Node)) setMenu(false); };
    document.addEventListener("mousedown", onClick);
    return () => document.removeEventListener("mousedown", onClick);
  }, []);

  const toggle = () => {
    const el = document.documentElement;
    const next = !el.classList.contains("dark");
    el.classList.toggle("dark", next);
    localStorage.setItem("theme", next ? "dark" : "light");
    setDark(next);
  };
  async function logout() {
    const supabase = createClient();
    if (supabase) await supabase.auth.signOut();
    router.push("/login");
  }

  const initial = (email?.[0] ?? "U").toUpperCase();
  const name = email ? email.split("@")[0] : "Usuário";

  return (
    <header className="sticky top-0 z-20 h-16 px-4 sm:px-6 flex items-center gap-3 border-b"
      style={{ borderColor: "var(--border)", background: "color-mix(in srgb, var(--surface) 82%, transparent)", backdropFilter: "blur(10px)" }}>
      {/* Busca */}
      <div className="relative flex-1 max-w-xl">
        <span className="absolute left-3 top-1/2 -translate-y-1/2 muted text-sm pointer-events-none">⌕</span>
        <input placeholder="Pesquisa inteligente — produtos, pedidos, lotes, docas, NF…" readOnly
          onFocus={() => window.dispatchEvent(new Event("open-command-palette"))}
          onClick={() => window.dispatchEvent(new Event("open-command-palette"))}
          className="input h-10 pl-9 cursor-pointer" style={{ background: "var(--surface-2)" }} />
        <kbd className="hidden sm:block absolute right-2.5 top-1/2 -translate-y-1/2 text-[10px] font-semibold muted px-1.5 py-0.5 rounded border"
          style={{ borderColor: "var(--border)" }}>⌘K</kbd>
      </div>

      <div className="flex-1" />

      {/* Ações */}
      <NotificationBell />
      <button onClick={toggle} className="btn btn-ghost btn-sm h-10 w-10 !px-0" title="Alternar tema">
        <span className="text-base">{dark ? "☀" : "☾"}</span>
      </button>

      <div className="w-px h-7 mx-1" style={{ background: "var(--border)" }} />

      {/* Usuário */}
      <div className="relative" ref={ref}>
        <button onClick={() => setMenu((m) => !m)} className="flex items-center gap-2.5 pl-1 pr-2 py-1 rounded-xl btn-ghost">
          <span className="h-9 w-9 rounded-full grid place-items-center font-bold text-white text-sm shrink-0"
            style={{ background: "linear-gradient(150deg,#2f56e6,#1a336f)" }}>{initial}</span>
          <span className="hidden sm:block text-left leading-tight">
            <span className="block text-[13px] font-semibold capitalize">{name}</span>
            <span className="block text-[11px] muted">Superadmin</span>
          </span>
          <span className="muted text-xs hidden sm:block">▾</span>
        </button>

        {menu && (
          <div className="absolute right-0 mt-2 w-60 card p-1.5 animate-in" style={{ boxShadow: "var(--shadow-lg)" }}>
            <div className="px-3 py-2.5">
              <div className="text-sm font-semibold capitalize">{name}</div>
              <div className="text-xs muted truncate">{email ?? "—"}</div>
            </div>
            <div className="h-px my-1" style={{ background: "var(--border)" }} />
            <a href="/configuracoes" className="block px-3 py-2 rounded-lg text-sm btn-ghost">Configurações</a>
            <a href="/permissoes" className="block px-3 py-2 rounded-lg text-sm btn-ghost">Permissões & acessos</a>
            <div className="h-px my-1" style={{ background: "var(--border)" }} />
            <button onClick={logout} className="w-full text-left px-3 py-2 rounded-lg text-sm btn-ghost" style={{ color: "var(--danger)" }}>
              Sair da conta
            </button>
          </div>
        )}
      </div>
    </header>
  );
}
