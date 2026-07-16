"use client";
import { useEffect, useMemo, useRef, useState } from "react";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const NIVEL: Record<string, { dot: string; badge: string }> = {
  erro: { dot: "var(--danger)", badge: "badge-danger" },
  alerta: { dot: "var(--warning)", badge: "badge-warning" },
  info: { dot: "var(--brand)", badge: "badge-neutral" },
};

type Item = { chave: string; label: string; n: number; nivel: string; href: string };

// #3 Sino de notificações — lê alertas_resumo (RPC) e mostra o que precisa de atenção.
export default function NotificationBell() {
  const supabase = useMemo(() => createClient(), []);
  const [open, setOpen] = useState(false);
  const [itens, setItens] = useState<Item[]>([]);
  const [total, setTotal] = useState(0);
  const ref = useRef<HTMLDivElement>(null);

  async function load() {
    if (!supabase || !COMPANY) return;
    const { data } = await supabase.rpc("alertas_resumo", { p_company: COMPANY });
    const d = data as any;
    if (d) { setItens((d.itens ?? []).filter((i: Item) => i.n > 0)); setTotal(d.total ?? 0); }
  }

  useEffect(() => {
    load();
    const id = setInterval(load, 90_000); // atualiza a cada 1,5 min
    return () => clearInterval(id);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);
  useEffect(() => {
    const onClick = (e: MouseEvent) => { if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false); };
    document.addEventListener("mousedown", onClick);
    return () => document.removeEventListener("mousedown", onClick);
  }, []);

  return (
    <div className="relative" ref={ref}>
      <button onClick={() => { setOpen((o) => !o); if (!open) load(); }} className="btn btn-ghost btn-sm h-10 w-10 !px-0 relative" title="Notificações">
        <span className="text-base">🔔</span>
        {total > 0 && (
          <span className="absolute -top-0.5 -right-0.5 min-w-[16px] h-4 px-1 rounded-full text-[10px] font-bold text-white grid place-items-center" style={{ background: "var(--danger)" }}>
            {total > 99 ? "99+" : total}
          </span>
        )}
      </button>

      {open && (
        <div className="absolute right-0 mt-2 w-80 card p-1.5 animate-in z-30" style={{ boxShadow: "var(--shadow-lg)" }}>
          <div className="px-3 py-2 flex items-center justify-between">
            <span className="text-sm font-semibold">Notificações</span>
            <button onClick={load} className="text-xs muted hover:opacity-70">atualizar ↻</button>
          </div>
          <div className="h-px my-1" style={{ background: "var(--border)" }} />
          {itens.length === 0 ? (
            <div className="px-3 py-6 text-center text-sm muted">✅ Tudo em ordem. Nada fora do padrão.</div>
          ) : (
            itens.map((i) => {
              const nv = NIVEL[i.nivel] ?? NIVEL.info;
              return (
                <a key={i.chave} href={i.href} onClick={() => setOpen(false)} className="flex items-center gap-2.5 px-3 py-2 rounded-lg btn-ghost no-underline">
                  <span className="w-2 h-2 rounded-full shrink-0" style={{ background: nv.dot }} />
                  <span className="flex-1 text-sm">{i.label}</span>
                  <span className={`badge ${nv.badge}`}>{i.n}</span>
                </a>
              );
            })
          )}
          <div className="h-px my-1" style={{ background: "var(--border)" }} />
          <a href="/dashboard" onClick={() => setOpen(false)} className="block px-3 py-2 rounded-lg text-xs font-semibold text-center btn-ghost no-underline" style={{ color: "var(--brand)" }}>Ver painel completo →</a>
        </div>
      )}
    </div>
  );
}
