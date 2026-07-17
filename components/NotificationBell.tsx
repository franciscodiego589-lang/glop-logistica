"use client";
import { useEffect, useMemo, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const SEEN_KEY = "alertas:seen:" + (COMPANY ?? "");
const NOTIF_KEY = "alertas:notif";

const NIVEL: Record<string, { dot: string; badge: string; ord: number; nome: string }> = {
  erro: { dot: "var(--danger)", badge: "badge-danger", ord: 0, nome: "Erro" },
  alerta: { dot: "var(--warning)", badge: "badge-warning", ord: 1, nome: "Atenção" },
  info: { dot: "var(--brand)", badge: "badge-neutral", ord: 2, nome: "Info" },
};

type Item = { chave: string; label: string; n: number; nivel: string; href: string; hint?: string };
type Filtro = "tudo" | "erro" | "pend";

function relativo(ts: number | null): string {
  if (!ts) return "";
  const s = Math.max(0, Math.round((Date.now() - ts) / 1000));
  if (s < 45) return "agora mesmo";
  if (s < 90) return "há 1 min";
  if (s < 3600) return `há ${Math.round(s / 60)} min`;
  return `há ${Math.round(s / 3600)} h`;
}

// Sino de notificações (todo o sistema) — mais intuitivo:
//  • badge conta só o que é NOVO desde a última vez que você viu
//  • filtros por severidade, dica em cada item, clique cai na lista filtrada
//  • "marcar tudo como visto" + avisos opcionais no navegador
export default function NotificationBell() {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [itens, setItens] = useState<Item[]>([]);
  const [erro, setErro] = useState(false);
  const [geradoEm, setGeradoEm] = useState<number | null>(null);
  const [filtro, setFiltro] = useState<Filtro>("tudo");
  const [seen, setSeen] = useState<Record<string, number>>({});
  const [notif, setNotif] = useState(false);
  const [, setTick] = useState(0); // re-render do "atualizado há…"
  const ref = useRef<HTMLDivElement>(null);
  const seq = useRef(0);
  const mounted = useRef(true);
  const lastNotified = useRef(0);

  async function load() {
    if (!supabase || !COMPANY) return;
    const my = ++seq.current;
    const { data, error } = await supabase.rpc("alertas_resumo", { p_company: COMPANY });
    if (!mounted.current || my !== seq.current) return;
    if (error) { setErro(true); return; }
    setErro(false);
    const d = data as any;
    const its = ((d?.itens ?? []) as Item[]).filter((i) => i.n > 0);
    setItens(its);
    setGeradoEm(d?.gerado_em ? new Date(d.gerado_em).getTime() : Date.now());
  }

  useEffect(() => {
    mounted.current = true;
    try { setSeen(JSON.parse(localStorage.getItem(SEEN_KEY) || "{}")); } catch {}
    try { setNotif(localStorage.getItem(NOTIF_KEY) === "1"); } catch {}
    load();
    const id = setInterval(load, 60_000);      // atualiza a cada 1 min
    const t = setInterval(() => setTick((x) => x + 1), 20_000); // "há X min" vivo
    return () => { mounted.current = false; clearInterval(id); clearInterval(t); };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    const onClick = (e: MouseEvent) => { if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false); };
    document.addEventListener("mousedown", onClick);
    return () => document.removeEventListener("mousedown", onClick);
  }, []);

  // acionáveis = erro + alerta; "novos" = quanto passou do que já foi visto
  const acionaveis = itens.filter((i) => i.nivel === "erro" || i.nivel === "alerta");
  const novos = acionaveis.reduce((s, i) => s + Math.max(0, i.n - (seen[i.chave] ?? 0)), 0);
  const abertos = acionaveis.reduce((s, i) => s + i.n, 0);
  const temErro = itens.some((i) => i.nivel === "erro");

  // aviso no navegador quando aparecem NOVOS problemas (se ativado e permitido)
  useEffect(() => {
    if (!notif || novos <= lastNotified.current) { if (novos < lastNotified.current) lastNotified.current = novos; return; }
    if (typeof window !== "undefined" && "Notification" in window && Notification.permission === "granted") {
      try { new Notification("GLOP — novos alertas", { body: `${novos} item(ns) precisam de atenção.` }); } catch {}
    }
    lastNotified.current = novos;
  }, [novos, notif]);

  function persistSeen(next: Record<string, number>) { try { localStorage.setItem(SEEN_KEY, JSON.stringify(next)); } catch {} }
  function marcarVisto() {
    const next: Record<string, number> = {};
    for (const i of itens) next[i.chave] = i.n;
    setSeen(next); persistSeen(next); lastNotified.current = 0;
  }
  async function toggleNotif() {
    if (!notif && typeof Notification !== "undefined" && Notification.permission !== "granted") {
      try { const p = await Notification.requestPermission(); if (p !== "granted") return; } catch { return; }
    }
    const v = !notif; setNotif(v); try { localStorage.setItem(NOTIF_KEY, v ? "1" : "0"); } catch {}
  }
  function ir(href: string) { setOpen(false); router.push(href); }

  const mostrados = itens
    .filter((i) => (filtro === "tudo" ? true : filtro === "erro" ? i.nivel === "erro" : i.nivel !== "erro"))
    .sort((a, b) => (NIVEL[a.nivel]?.ord ?? 9) - (NIVEL[b.nivel]?.ord ?? 9) || b.n - a.n);

  const isNovo = (i: Item) => i.n > (seen[i.chave] ?? 0) && i.nivel !== "info";

  return (
    <div className="relative" ref={ref}>
      <button onClick={() => { setOpen((o) => !o); if (!open) load(); }} className="btn btn-ghost btn-sm h-10 w-10 !px-0 relative" title="Notificações">
        <span className="text-base">🔔</span>
        {novos > 0 ? (
          <span className="absolute -top-0.5 -right-0.5 min-w-[16px] h-4 px-1 rounded-full text-[10px] font-bold text-white grid place-items-center animate-pulse" style={{ background: "var(--danger)" }}>
            {novos > 99 ? "99+" : novos}
          </span>
        ) : abertos > 0 ? (
          <span className="absolute top-2 right-2 w-2 h-2 rounded-full" style={{ background: temErro ? "var(--danger)" : "var(--warning)" }} />
        ) : null}
      </button>

      {open && (
        <div className="fixed sm:absolute top-16 sm:top-auto right-2 sm:right-0 mt-0 sm:mt-2 w-[calc(100vw-1rem)] sm:w-[340px] card p-0 animate-in z-30 overflow-hidden" style={{ boxShadow: "var(--shadow-lg)" }}>
          {/* Cabeçalho */}
          <div className="px-3 py-2.5 flex items-center justify-between" style={{ borderBottom: "1px solid var(--border)" }}>
            <div>
              <div className="text-sm font-semibold">Notificações {abertos > 0 && <span className="muted font-normal">· {abertos} aberto(s)</span>}</div>
              <div className="text-[11px] muted">{erro ? "falha ao carregar" : geradoEm ? "atualizado " + relativo(geradoEm) : "carregando…"}</div>
            </div>
            <div className="flex items-center gap-1">
              <button onClick={load} title="Atualizar" className="h-9 w-9 grid place-items-center rounded-lg btn-ghost text-sm">↻</button>
              <button onClick={toggleNotif} title={notif ? "Avisos do navegador: ligados" : "Ativar avisos no navegador"} className="h-9 w-9 grid place-items-center rounded-lg btn-ghost text-sm">{notif ? "🔔" : "🔕"}</button>
            </div>
          </div>

          {/* Filtros */}
          {itens.length > 0 && !erro && (
            <div className="px-2 py-1.5 flex gap-1" style={{ borderBottom: "1px solid var(--border)" }}>
              {([["tudo", "Tudo"], ["erro", "Erros"], ["pend", "Pendências"]] as [Filtro, string][]).map(([k, lbl]) => (
                <button key={k} onClick={() => setFiltro(k)} className={`px-2.5 py-1 rounded-full text-xs font-semibold ${filtro === k ? "bg-brand-600 text-white" : "btn-ghost"}`}>{lbl}</button>
              ))}
              <button onClick={marcarVisto} className="ml-auto px-2 py-1 rounded-full text-xs font-semibold btn-ghost" style={{ color: "var(--brand)" }} title="Marcar tudo como visto">marcar visto ✓</button>
            </div>
          )}

          {/* Lista */}
          <div className="max-h-[52vh] overflow-y-auto">
            {erro ? (
              <div className="px-3 py-8 text-center text-sm">
                <div style={{ color: "var(--danger)" }}>⚠️ Não foi possível carregar os alertas.</div>
                <button onClick={load} className="mt-2 text-xs font-semibold" style={{ color: "var(--brand)" }}>tentar de novo ↻</button>
              </div>
            ) : mostrados.length === 0 ? (
              <div className="px-3 py-8 text-center text-sm muted">✅ {itens.length === 0 ? "Tudo em ordem. Nada fora do padrão." : "Nada neste filtro."}</div>
            ) : (
              mostrados.map((i) => {
                const nv = NIVEL[i.nivel] ?? NIVEL.info;
                return (
                  <button key={i.chave} onClick={() => ir(i.href)} className="w-full text-left flex items-start gap-2.5 px-3 py-2.5 btn-ghost" style={{ borderBottom: "1px solid var(--border)" }}>
                    <span className="w-2 h-2 rounded-full shrink-0 mt-1.5" style={{ background: nv.dot }} />
                    <span className="flex-1 min-w-0">
                      <span className="flex items-center gap-1.5">
                        <span className="text-sm font-medium truncate">{i.label}</span>
                        {isNovo(i) && <span className="text-[9px] font-bold px-1 rounded" style={{ background: "var(--danger)", color: "#fff" }}>NOVO</span>}
                      </span>
                      {i.hint && <span className="block text-[11px] muted leading-snug mt-0.5">{i.hint}</span>}
                    </span>
                    <span className={`badge ${nv.badge} shrink-0`}>{i.n}</span>
                  </button>
                );
              })
            )}
          </div>

          {/* Rodapé */}
          <a href="/dashboard" onClick={() => setOpen(false)} className="block px-3 py-2.5 text-xs font-semibold text-center btn-ghost no-underline" style={{ color: "var(--brand)", borderTop: "1px solid var(--border)" }}>Ver painel completo →</a>
        </div>
      )}
    </div>
  );
}
