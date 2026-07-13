"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { NAV, NAV_GROUPS } from "@/lib/nav";

const href = (slug: string) => (slug === "dashboard" ? "/" : `/${slug}`);

export default function Sidebar() {
  const pathname = usePathname();
  return (
    <aside className="hidden md:flex w-64 shrink-0 flex-col card m-3 mr-0 overflow-y-auto">
      <div className="px-5 py-5 border-b" style={{ borderColor: "var(--border)" }}>
        <div className="flex items-center gap-2">
          <div className="h-9 w-9 rounded-xl bg-brand-600 text-white grid place-items-center font-bold">L</div>
          <div>
            <div className="font-bold leading-tight">Logística</div>
            <div className="text-xs muted">ERP Mundial</div>
          </div>
        </div>
      </div>
      <nav className="p-3 space-y-4">
        {NAV_GROUPS.map((group) => (
          <div key={group}>
            <div className="px-2 mb-1 text-[11px] uppercase tracking-wider muted font-semibold">{group}</div>
            <div className="space-y-0.5">
              {NAV.filter((n) => n.group === group).map((n) => {
                const active = pathname === href(n.slug);
                return (
                  <Link
                    key={n.slug}
                    href={href(n.slug)}
                    className={`flex items-center gap-3 px-3 py-2 rounded-lg text-sm transition ${
                      active ? "bg-brand-600 text-white" : "hover:bg-black/5 dark:hover:bg-white/5"
                    }`}
                  >
                    <span className="w-5 text-center opacity-90">{n.icon}</span>
                    <span className="truncate">{n.label}</span>
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </nav>
    </aside>
  );
}
