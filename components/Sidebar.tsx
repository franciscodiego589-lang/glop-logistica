"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { NAV, NAV_GROUPS } from "@/lib/nav";

const href = (slug: string) => (slug === "dashboard" ? "/" : `/${slug}`);

export default function Sidebar() {
  const pathname = usePathname();
  return (
    <aside className="hidden md:flex w-[248px] shrink-0 flex-col text-[color:var(--sidebar-text)]"
      style={{ background: "var(--sidebar)" }}>
      {/* Marca */}
      <div className="px-4 py-4">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-xl grid place-items-center font-black text-lg text-white shadow-md shrink-0"
            style={{ background: "linear-gradient(150deg,#2f56e6,#1a336f)" }}>◈</div>
          <div className="min-w-0">
            <div className="font-bold leading-tight truncate text-white">GLOP</div>
            <div className="text-[11px]" style={{ color: "var(--sidebar-muted)" }}>Global Logistics Platform</div>
          </div>
        </div>
      </div>

      <div className="mx-4 h-px" style={{ background: "rgba(255,255,255,.07)" }} />

      {/* Navegação */}
      <nav className="flex-1 overflow-y-auto px-3 py-4 space-y-5">
        {NAV_GROUPS.map((group) => (
          <div key={group}>
            <div className="px-2.5 mb-1.5 text-[10px] uppercase tracking-[0.08em] font-bold" style={{ color: "var(--sidebar-muted)" }}>
              {group}
            </div>
            <div className="space-y-0.5">
              {NAV.filter((n) => n.group === group).map((n) => {
                const active = pathname === href(n.slug);
                return (
                  <Link key={n.slug} href={href(n.slug)} title={n.description}
                    className="group relative flex items-center gap-3 pl-3 pr-2.5 py-2 rounded-lg text-[13px] transition-colors"
                    style={active
                      ? { background: "linear-gradient(90deg, rgba(90,128,255,.22), rgba(90,128,255,.08))", color: "#fff" }
                      : { color: "var(--sidebar-text)" }}
                    onMouseEnter={(e) => { if (!active) e.currentTarget.style.background = "rgba(255,255,255,.05)"; }}
                    onMouseLeave={(e) => { if (!active) e.currentTarget.style.background = "transparent"; }}>
                    {active && <span className="absolute left-0 top-1.5 bottom-1.5 w-[3px] rounded-full" style={{ background: "#5a80ff" }} />}
                    <span className="w-5 text-center text-[15px] shrink-0"
                      style={{ color: active ? "#8badff" : "var(--sidebar-muted)" }}>{n.icon}</span>
                    <span className="truncate font-medium">{n.label}</span>
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </nav>

      <div className="mx-4 h-px" style={{ background: "rgba(255,255,255,.07)" }} />
      <div className="px-4 py-3 flex items-center gap-2 text-[11px]" style={{ color: "var(--sidebar-muted)" }}>
        <span className="dot" style={{ background: "#2fce88" }} />
        <span>Cérebro IA ativo · varre a cada 15 min</span>
      </div>
    </aside>
  );
}
