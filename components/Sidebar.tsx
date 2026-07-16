"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { NAV, NAV_GROUP_META } from "@/lib/nav";

const href = (slug: string) => (slug === "dashboard" ? "/" : `/${slug}`);
const RAIL = "sidebar:collapsed";   // "1" = faixa só de ícones
const OPEN = "sidebar:groups";      // categorias abertas (accordion)

export default function Sidebar() {
  const pathname = usePathname();
  const [rail, setRail] = useState(false);
  const [open, setOpen] = useState<Record<string, boolean>>({});
  const [ready, setReady] = useState(false);

  const activeItem = NAV.find((n) => href(n.slug) === pathname);
  const activeGroup = activeItem?.group;

  // carrega preferências (rail + categorias abertas) e sincroniza entre abas
  useEffect(() => {
    setReady(true);
    try { setRail(localStorage.getItem(RAIL) === "1"); } catch {}
    let saved: Record<string, boolean> | null = null;
    try { saved = JSON.parse(localStorage.getItem(OPEN) || "null"); } catch {}
    setOpen(saved ?? (activeGroup ? { [activeGroup]: true } : { Início: true }));
    const onStorage = (e: StorageEvent) => {
      if (e.key === RAIL) setRail(e.newValue === "1");
      if (e.key === OPEN) { try { setOpen(JSON.parse(e.newValue || "{}")); } catch {} }
    };
    window.addEventListener("storage", onStorage);
    return () => window.removeEventListener("storage", onStorage);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // ao navegar, garante que a categoria da tela atual esteja aberta
  useEffect(() => {
    if (activeGroup) setOpen((o) => (o[activeGroup] ? o : { ...o, [activeGroup]: true }));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeGroup]);

  function persist(next: Record<string, boolean>) { try { localStorage.setItem(OPEN, JSON.stringify(next)); } catch {} }
  function toggleRail() { const v = !rail; setRail(v); try { localStorage.setItem(RAIL, v ? "1" : "0"); } catch {} }
  function toggleGroup(name: string) { setOpen((o) => { const n = { ...o, [name]: !o[name] }; persist(n); return n; }); }
  function openFromRail(name: string) {
    setRail(false); try { localStorage.setItem(RAIL, "0"); } catch {}
    setOpen((o) => { const n = { ...o, [name]: true }; persist(n); return n; });
  }

  return (
    <aside className={`hidden md:flex ${rail ? "w-[68px]" : "w-[264px]"} shrink-0 flex-col text-[color:var(--sidebar-text)] transition-[width] duration-200`}
      style={{ background: "var(--sidebar)" }}>
      {/* Marca + botão de encolher (rail) */}
      <div className={`py-4 ${rail ? "px-0" : "px-4"}`}>
        <div className={`flex items-center gap-3 ${rail ? "justify-center" : ""}`}>
          <div className="h-10 w-10 rounded-xl grid place-items-center font-black text-lg text-white shadow-md shrink-0"
            style={{ background: "linear-gradient(150deg,#2f56e6,#1a336f)" }}>◈</div>
          {!rail && (
            <div className="min-w-0 flex-1">
              <div className="font-bold leading-tight truncate text-white">GLOP</div>
              <div className="text-[11px]" style={{ color: "var(--sidebar-muted)" }}>Global Logistics Platform</div>
            </div>
          )}
          {!rail && (
            <button onClick={toggleRail} title="Encolher menu" aria-label="Encolher menu"
              className="h-7 w-7 grid place-items-center rounded-lg text-sm shrink-0 hover:bg-white/10" style={{ color: "var(--sidebar-muted)" }}>«</button>
          )}
        </div>
        {rail && (
          <button onClick={toggleRail} title="Expandir menu" aria-label="Expandir menu"
            className="mx-auto mt-3 h-7 w-7 grid place-items-center rounded-lg text-sm hover:bg-white/10" style={{ color: "var(--sidebar-muted)" }}>»</button>
        )}
      </div>

      <div className="mx-4 h-px" style={{ background: "rgba(255,255,255,.07)" }} />

      {/* Navegação */}
      <nav className={`flex-1 overflow-y-auto py-3 ${rail ? "px-2 overflow-x-hidden space-y-1" : "px-2.5 space-y-0.5"}`}>
        {rail
          ? NAV_GROUP_META.map((g) => {
              const items = NAV.filter((n) => n.group === g.name);
              if (!items.length) return null;
              const hasActive = items.some((n) => href(n.slug) === pathname);
              return (
                <button key={g.name} onClick={() => openFromRail(g.name)} title={g.name}
                  className="w-full flex justify-center py-2.5 rounded-lg text-[18px] hover:bg-white/5"
                  style={hasActive ? { background: "linear-gradient(90deg, rgba(90,128,255,.22), rgba(90,128,255,.08))" } : undefined}>
                  <span>{g.icon}</span>
                </button>
              );
            })
          : NAV_GROUP_META.map((g) => {
              const items = NAV.filter((n) => n.group === g.name);
              if (!items.length) return null;
              const isOpen = ready ? !!open[g.name] : g.name === (activeGroup ?? "Início");
              const hasActive = items.some((n) => href(n.slug) === pathname);
              return (
                <div key={g.name}>
                  {/* Cabeçalho da categoria (accordion) */}
                  <button onClick={() => toggleGroup(g.name)}
                    className="w-full flex items-center gap-3 pl-2.5 pr-2 py-2.5 rounded-lg transition-colors"
                    style={hasActive
                      ? { background: "linear-gradient(90deg, rgba(90,128,255,.22), rgba(90,128,255,.06))", color: "#fff" }
                      : { color: "var(--sidebar-text)" }}
                    onMouseEnter={(e) => { if (!hasActive) e.currentTarget.style.background = "rgba(255,255,255,.05)"; }}
                    onMouseLeave={(e) => { if (!hasActive) e.currentTarget.style.background = "transparent"; }}>
                    <span className="w-5 text-center text-[16px] shrink-0">{g.icon}</span>
                    <span className="flex-1 text-left text-[13.5px] font-semibold truncate">{g.name}</span>
                    <span className="text-[10px] shrink-0 transition-transform duration-200" style={{ color: "var(--sidebar-muted)", transform: isOpen ? "rotate(90deg)" : "none" }}>▶</span>
                  </button>

                  {/* Itens da categoria */}
                  {isOpen && (
                    <div className="mt-0.5 mb-1 ml-2 pl-2 space-y-0.5" style={{ borderLeft: "1px solid rgba(255,255,255,.07)" }}>
                      {items.map((n) => {
                        const active = href(n.slug) === pathname;
                        return (
                          <Link key={n.slug} href={href(n.slug)} title={n.description}
                            className="group relative flex items-center gap-2.5 pl-2.5 pr-2 py-1.5 rounded-lg text-[12.5px] transition-colors"
                            style={active
                              ? { background: "linear-gradient(90deg, rgba(90,128,255,.28), rgba(90,128,255,.10))", color: "#fff" }
                              : { color: "var(--sidebar-text)" }}
                            onMouseEnter={(e) => { if (!active) e.currentTarget.style.background = "rgba(255,255,255,.05)"; }}
                            onMouseLeave={(e) => { if (!active) e.currentTarget.style.background = "transparent"; }}>
                            {active && <span className="absolute left-0 top-1 bottom-1 w-[3px] rounded-full" style={{ background: "#5a80ff" }} />}
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

      <div className="mx-4 h-px" style={{ background: "rgba(255,255,255,.07)" }} />
      <div className={`py-3 flex items-center gap-2 text-[11px] ${rail ? "justify-center px-0" : "px-4"}`} style={{ color: "var(--sidebar-muted)" }} title="Cérebro IA ativo · varre a cada 15 min">
        <span className="dot" style={{ background: "#2fce88" }} />
        {!rail && <span>Cérebro IA ativo · varre a cada 15 min</span>}
      </div>
    </aside>
  );
}
