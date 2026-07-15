"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const FEATURES = [
  { icon: "⌗", t: "WMS · Armazém", d: "Endereçamento, ondas, slotting com IA" },
  { icon: "🚚", t: "TMS · Transporte", d: "Fretes, rotas, OTIF e torre de controle" },
  { icon: "🌍", t: "Comex · GTM", d: "Importação, aduana e custo nacionalizado" },
  { icon: "✦", t: "LAIOS · IA Central", d: "13 agentes monitorando a operação 24/7" },
];

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [show, setShow] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    const supabase = createClient();
    if (!supabase) { setError("Banco ainda não conectado. Defina as variáveis NEXT_PUBLIC_SUPABASE_*."); return; }
    setLoading(true);
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    setLoading(false);
    if (error) setError(error.message === "Invalid login credentials" ? "E-mail ou senha incorretos." : error.message);
    else router.push("/");
  }

  return (
    <div className="min-h-screen grid lg:grid-cols-[1.05fr_1fr]">
      {/* Painel de marca */}
      <div className="relative hidden lg:flex flex-col justify-between overflow-hidden p-12 text-white"
        style={{ background: "linear-gradient(150deg, #1a336f 0%, #2144cc 45%, #2f56e6 100%)" }}>
        <div aria-hidden className="pointer-events-none absolute inset-0 opacity-40"
          style={{ background: "radial-gradient(600px 300px at 85% 10%, rgba(255,255,255,.25), transparent 60%), radial-gradient(700px 400px at 10% 100%, rgba(0,0,0,.35), transparent 55%)" }} />
        <div className="relative flex items-center gap-3">
          <div className="h-11 w-11 rounded-2xl grid place-items-center font-black text-xl shadow-lg"
            style={{ background: "rgba(255,255,255,.14)", backdropFilter: "blur(6px)" }}>◈</div>
          <div>
            <div className="font-extrabold text-lg leading-tight tracking-tight">GLOP</div>
            <div className="text-xs text-white/70">Supply Chain · WMS · TMS · YMS · Comex · IA</div>
          </div>
        </div>

        <div className="relative">
          <h1 className="text-4xl font-extrabold leading-[1.1] tracking-tight max-w-md">
            A plataforma que enxerga<br />sua operação inteira.
          </h1>
          <p className="mt-4 text-white/75 max-w-md leading-relaxed">
            Do recebimento à última milha, com um cérebro de inteligência artificial monitorando, prevendo e propondo decisões em tempo real.
          </p>
          <div className="mt-8 grid sm:grid-cols-2 gap-3 max-w-lg">
            {FEATURES.map((f) => (
              <div key={f.t} className="rounded-2xl p-3.5 flex items-start gap-3"
                style={{ background: "rgba(255,255,255,.08)", border: "1px solid rgba(255,255,255,.12)" }}>
                <span className="text-lg leading-none mt-0.5">{f.icon}</span>
                <div>
                  <div className="text-sm font-semibold">{f.t}</div>
                  <div className="text-xs text-white/65 leading-snug">{f.d}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="relative text-xs text-white/50">© {new Date().getFullYear()} GLOP · Multi-tenant · LGPD-ready</div>
      </div>

      {/* Formulário */}
      <div className="flex items-center justify-center p-6 sm:p-10">
        <div className="w-full max-w-sm animate-in">
          <div className="lg:hidden flex items-center gap-3 mb-8">
            <div className="h-11 w-11 rounded-2xl grid place-items-center font-black text-xl text-white"
              style={{ background: "linear-gradient(150deg,#2144cc,#2f56e6)" }}>◈</div>
            <div className="font-extrabold leading-tight">GLOP</div>
          </div>

          <h2 className="text-2xl font-extrabold tracking-tight">Bem-vindo de volta</h2>
          <p className="text-sm muted mt-1">Entre com suas credenciais para acessar o sistema.</p>

          <form onSubmit={onSubmit} className="mt-8 space-y-4">
            <div>
              <label className="label">E-mail</label>
              <input value={email} onChange={(e) => setEmail(e.target.value)} type="email" required autoFocus
                placeholder="voce@empresa.com" className="input" />
            </div>
            <div>
              <div className="flex items-center justify-between">
                <label className="label mb-0">Senha</label>
              </div>
              <div className="relative mt-1.5">
                <input value={password} onChange={(e) => setPassword(e.target.value)} type={show ? "text" : "password"} required
                  placeholder="••••••••" className="input pr-16" />
                <button type="button" onClick={() => setShow((s) => !s)}
                  className="absolute right-2 top-1/2 -translate-y-1/2 text-xs font-semibold muted px-2 py-1 rounded-md btn-ghost">
                  {show ? "ocultar" : "mostrar"}
                </button>
              </div>
            </div>

            {error && (
              <div className="text-sm rounded-xl px-3 py-2.5 flex items-center gap-2"
                style={{ background: "var(--danger-soft)", color: "var(--danger)" }}>
                <span>⚠</span>{error}
              </div>
            )}

            <button disabled={loading} className="btn btn-primary w-full h-11 text-sm">
              {loading ? "Entrando…" : "Entrar no sistema"}
            </button>
          </form>

          <p className="text-xs muted mt-8 text-center">
            Acesso protegido · Row-Level Security por empresa · Auditoria imutável
          </p>
        </div>
      </div>
    </div>
  );
}
