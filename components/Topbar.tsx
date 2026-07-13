"use client";
import { useEffect, useState } from "react";

export default function Topbar() {
  const [dark, setDark] = useState(false);
  useEffect(() => setDark(document.documentElement.classList.contains("dark")), []);
  const toggle = () => {
    const el = document.documentElement;
    const next = !el.classList.contains("dark");
    el.classList.toggle("dark", next);
    localStorage.setItem("theme", next ? "dark" : "light");
    setDark(next);
  };
  return (
    <header className="card m-3 mb-0 px-4 py-3 flex items-center gap-3">
      <div className="flex-1">
        <input
          placeholder="Pesquisa inteligente — produtos, pedidos, lotes, docas…"
          className="w-full max-w-xl bg-transparent border rounded-lg px-3 py-2 text-sm outline-none focus:border-brand-500"
          style={{ borderColor: "var(--border)" }}
        />
      </div>
      <button onClick={toggle} className="h-9 w-9 rounded-lg border grid place-items-center" style={{ borderColor: "var(--border)" }} title="Alternar tema">
        {dark ? "☀" : "☾"}
      </button>
      <div className="h-9 w-9 rounded-full bg-brand-600 text-white grid place-items-center font-semibold">D</div>
    </header>
  );
}
