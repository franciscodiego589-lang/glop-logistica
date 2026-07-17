"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { NAV, NAV_GROUP_META } from "@/lib/nav";

const href = (slug: string) => (slug === "dashboard" ? "/" : `/${slug}`);

// Navegação mobile: gaveta (drawer) que desliza da esquerda. No desktop (md+) o
// Sidebar normal aparece e isto fica escondido. Abre pelo botão ☰ do Topbar
// (evento 'toggle-mobile-nav'). Fecha ao navegar, no backdrop ou no X.
export default function MobileNav() {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  const [acc, setAcc] = useState<Record<string, boolean>>({});

  useEffect(() => {
    const toggle = () => setOpen((o) => !o);
    window.addEventListener("toggle-mobile-nav", toggle);
    return () => window.removeEventListener("toggle-mobile-nav", toggle);
  }, []);

  // fecha ao trocar de rota
  useEffect(() => { setOpen(false); }, [pathname]);
  // trava o scroll do body enquanto aberta
  useEffect(() => {
    document.body.style.overflow = open ? "hidden" : "";
    return () => { document.body.style.overflow = ""; };
  }, [open]);

  const activeGroup = NAV.find((n) => href(n.slug) === pathname)?.group;

  return (
    <div className={`md:hidden ${open ? "" : "pointer-events-none"}`} aria-hidden={!open}>
      {/* backdrop */}
      <div onClick={() => setOpen(false)}
        className={`fixed inset-0 z-40 transition-opacity duration-200 ${open ? "opacity-100" : "opacity-0"}`}
        style={{ background: "rgba(0,0,0,.55)" }} />
      {/* painel */}
      <aside className={`fixed left-0 top-0 z-50 h-full w-[84vw] max-w-[300px] flex flex-col text-[color:var(--sidebar-text)] shadow-2xl transition-transform duration-200 ${open ? "translate-x-0" : "-translate-x-full"}`}
        style={{ background: "var(--sidebar)" }}>
        <div className="py-4 px-4 flex items-center gap-3">
          <div className="h-10 w-10 rounded-xl grid place-items-center font-black text-lg text-white shadow-md shrink-0"
            style={{ background: "linear-gradient(150deg,#2f56e6,#1a336f)" }}>◈</div>
          <div className="min-w-0 flex-1">
            <div className="font-bold leading-tight truncate text-white">GLOP</div>
            <div className="text-[11px]" style={{ color: "var(--sidebar-muted)" }}>Global Logistics Platform</div>
          </div>
          <button onClick={() => setOpen(false)} aria-label="Fechar menu"
            className="h-9 w-9 grid place-items-center rounded-lg text-lg hover:bg-white/10" style={{ color: "var(--sidebar-muted)" }}>✕</button>
        </div>
        <div className="mx-4 h-px" style={{ background: "rgba(255,255,255,.07)" }} />
        <nav className="flex-1 overflow-y-auto py-3 px-2.5 space-y-0.5">
          {NAV_GROUP_META.map((g) => {
            const items = NAV.filter((n) => n.group === g.name);
            if (!items.length) return null;
            const isOpen = acc[g.name] ?? g.name === activeGroup;
            const hasActive = items.some((n) => href(n.slug) === pathname);
            return (
              <div key={g.name}>
                <button onClick={() => setAcc((a) => ({ ...a, [g.name]: !isOpen }))}
                  className="w-full flex items-center gap-3 pl-2.5 pr-2 py-3 rounded-lg"
                  style={hasActive ? { background: "linear-gradient(90deg, rgba(90,128,255,.22), rgba(90,128,255,.06))", color: "#fff" } : { color: "var(--sidebar-text)" }}>
                  <span className="w-5 text-center text-[16px] shrink-0">{g.icon}</span>
                  <span className="flex-1 text-left text-[14px] font-semibold truncate">{g.name}</span>
                  <span className="text-[10px] shrink-0" style={{ color: "var(--sidebar-muted)", transform: isOpen ? "rotate(90deg)" : "none" }}>▶</span>
                </button>
                {isOpen && (
                  <div className="mt-0.5 mb-1 ml-2 pl-2 space-y-0.5" style={{ borderLeft: "1px solid rgba(255,255,255,.07)" }}>
                    {items.map((n) => {
                      const active = href(n.slug) === pathname;
                      return (
                        <Link key={n.slug} href={href(n.slug)} onClick={() => setOpen(false)}
                          className="flex items-center gap-2.5 pl-2.5 pr-2 py-2.5 rounded-lg text-[13px]"
                          style={active ? { background: "linear-gradient(90deg, rgba(90,128,255,.28), rgba(90,128,255,.10))", color: "#fff" } : { color: "var(--sidebar-text)" }}>
                          <span className="w-4 text-center text-[13px] shrink-0" style={{ color: active ? "#8badff" : "var(--sidebar-muted)" }}>{n.icon}</span>
                          <span className="truncate">{n.label}</span>
                        </Link>
                      );
                    })}
                  </div>
                )}
              </div>
            );
          })}
        </nav>
      </aside>
    </div>
  );
}
