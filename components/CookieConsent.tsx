"use client";
import { useEffect, useState } from "react";

// Banner de consentimento de cookies (LGPD). Registra a escolha do titular
// (todos / só essenciais) com data e versão no navegador. Aparece em todo o site
// até o usuário decidir; reabrível pelo evento "open-cookie-consent".
const KEY = "glop:cookie-consent";
const VERSAO = 1;

export default function CookieConsent() {
  const [show, setShow] = useState(false);

  useEffect(() => {
    try {
      const raw = localStorage.getItem(KEY);
      const c = raw ? JSON.parse(raw) : null;
      if (!c || c.v !== VERSAO) setShow(true);
    } catch { setShow(true); }
    const open = () => setShow(true);
    window.addEventListener("open-cookie-consent", open);
    return () => window.removeEventListener("open-cookie-consent", open);
  }, []);

  function decidir(choice: "all" | "essential") {
    try { localStorage.setItem(KEY, JSON.stringify({ v: VERSAO, choice, ts: new Date().toISOString() })); } catch {}
    setShow(false);
  }

  if (!show) return null;

  return (
    <div className="fixed inset-x-0 bottom-0 z-[60] p-3 sm:p-4 flex justify-center pointer-events-none">
      <div className="pointer-events-auto w-full max-w-3xl card p-4 shadow-lg" style={{ boxShadow: "var(--shadow-lg)", borderTop: "3px solid var(--brand)" }}>
        <div className="flex items-start gap-3">
          <span className="text-2xl leading-none">🍪</span>
          <div className="flex-1 min-w-0">
            <div className="font-bold text-sm">Cookies e privacidade</div>
            <p className="text-xs muted mt-1">
              Usamos cookies essenciais para o funcionamento da plataforma (login, preferências) e, com o seu consentimento,
              cookies adicionais. Você pode escolher abaixo. Saiba mais na{" "}
              <a href="/cookies" className="underline" style={{ color: "var(--brand)" }}>Política de Cookies</a> e na{" "}
              <a href="/privacidade" className="underline" style={{ color: "var(--brand)" }}>Política de Privacidade</a>.
            </p>
            <div className="flex flex-wrap gap-2 mt-3">
              <button onClick={() => decidir("all")} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold">Aceitar todos</button>
              <button onClick={() => decidir("essential")} className="px-4 py-2 rounded-lg border text-sm font-semibold" style={{ borderColor: "var(--border)" }}>Só essenciais</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
