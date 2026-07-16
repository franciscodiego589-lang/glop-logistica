"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { NAV, NAV_GROUPS } from "@/lib/nav";

const href = (slug: string) => (slug === "dashboard" ? "/" : `/${slug}`);
const PREF = "sidebar:collapsed"; // "1" = encolhido

export default function Sidebar() {
  const pathname = usePathname();
  const [collapsed, setCollapsed] = useState(false);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    setReady(true);
    try { setCollapsed(localStorage.getItem(PREF) === "1"); } catch {}
    const onStorage = (e: StorageEvent) => { if (e.key === PREF) setCollapsed(e.newValue === "1"); };
    window.addEventListener("storage", onStorage);
    return () => window.removeEventListener("storage", onStorage);
  }, []);

  function toggle() {
    const v = !collapsed; setCollapsed(v);
    try { localStorage.setItem(PREF, v ? "1" : "0"); } catch {}
  }

  return (
    <aside className={`hidden md:flex ${collapsed ? "w-[68px]" : "w-[248px]"} shrink-0 flex-col text-[color:var(--sidebar-text)] transition-[width] duration-200`}
      style={{ background: "var(--sidebar)" }}>
      {/* Marca + botão de encolher */}
      <div className={`py-4 ${collapsed ? "px-0" : "px-4"}`}>
        <div className={`flex items-center gap-3 ${collapsed ? "justify-center" : ""}`}>
          <div className="h-10 w-10 rounded-xl grid place-items-center font-black text-lg text-white shadow-md shrink-0"
            style={{ background: "linear-gradient(150deg,#2f56e6,#1a336f)" }}>◈</div>
          {!collapsed && (
            <div className="min-w-0 flex-1">
              <div className="font-bold leading-tight truncate text-white">GLOP</div>
              <div className="text-[11px]" style={{ color: "var(--sidebar-muted)" }}>Global Logistics Platform</div>
            </div>
          )}
          {!collapsed && (
            <button onClick={toggle} title="Encolher menu" aria-label="Encolher menu"
              className="h-7 w-7 grid place-items-center rounded-lg text-sm shrink-0 hover:bg-white/10"
              style={{ color: "var(--sidebar-muted)" }}>«</button>
          )}
        </div>
        {collapsed && (
          <button onClick={toggle} title="Expandir menu" aria-label="Expandir menu"
            className="mx-auto mt-3 h-7 w-7 grid place-items-center rounded-lg text-sm hover:bg-white/10"
            style={{ color: "var(--sidebar-muted)" }}>»</button>
        )}
      </div>

      <div className="mx-4 h-px" style={{ background: "rgba(255,255,255,.07)" }} />

      {/* Navegação */}
      <nav className={`flex-1 overflow-y-auto py-4 space-y-5 ${collapsed ? "px-2 overflow-x-hidden" : "px-3"}`}>
        {NAV_GROUPS.map((group) => (
          <div key={group}>
            {collapsed ? (
              <div className="mx-2 mb-1.5 h-px" style={{ background: "rgba(255,255,255,.07)" }} />
            ) : (
              <div className="px-2.5 mb-1.5 text-[10px] uppercase tracking-[0.08em] font-bold" style={{ color: "var(--sidebar-muted)" }}>
                {group}
              </div>
            )}
            <div className="space-y-0.5">
              {NAV.filter((n) => n.group === group).map((n) => {
                const active = pathname === href(n.slug);
                return (
                  <Link key={n.slug} href={href(n.slug)} title={collapsed ? `${n.label} — ${n.description}` : n.description}
                    className={`group relative flex items-center gap-3 py-2 rounded-lg text-[13px] transition-colors ${collapsed ? "justify-center px-0" : "pl-3 pr-2.5"}`}
                    style={active
                      ? { background: "linear-gradient(90deg, rgba(90,128,255,.22), rgba(90,128,255,.08))", color: "#fff" }
                      : { color: "var(--sidebar-text)" }}
                    onMouseEnter={(e) => { if (!active) e.currentTarget.style.background = "rgba(255,255,255,.05)"; }}
                    onMouseLeave={(e) => { if (!active) e.currentTarget.style.background = "transparent"; }}>
                    {active && <span className="absolute left-0 top-1.5 bottom-1.5 w-[3px] rounded-full" style={{ background: "#5a80ff" }} />}
                    <span className="w-5 text-center text-[15px] shrink-0"
                      style={{ color: active ? "#8badff" : "var(--sidebar-muted)" }}>{n.icon}</span>
                    {!collapsed && <span className="truncate font-medium">{n.label}</span>}
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </nav>

      <div className="mx-4 h-px" style={{ background: "rgba(255,255,255,.07)" }} />
      <div className={`py-3 flex items-center gap-2 text-[11px] ${collapsed ? "justify-center px-0" : "px-4"}`} style={{ color: "var(--sidebar-muted)" }} title="Cérebro IA ativo · varre a cada 15 min">
        <span className="dot" style={{ background: "#2fce88" }} />
        {!collapsed && <span>Cérebro IA ativo · varre a cada 15 min</span>}
      </div>
    </aside>
  );
}
