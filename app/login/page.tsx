"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    const supabase = createClient();
    if (!supabase) {
      setError("Banco ainda não conectado. Defina NEXT_PUBLIC_SUPABASE_URL e NEXT_PUBLIC_SUPABASE_ANON_KEY.");
      return;
    }
    setLoading(true);
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    setLoading(false);
    if (error) setError(error.message);
    else router.push("/");
  }

  return (
    <div className="min-h-screen grid place-items-center p-4">
      <div className="w-full max-w-sm card p-6">
        <div className="flex items-center gap-2 mb-6">
          <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center font-bold text-lg">L</div>
          <div>
            <div className="font-bold">ERP Logístico Mundial</div>
            <div className="text-xs muted">WMS · TMS · YMS · MRP · BI · LOGIA</div>
          </div>
        </div>
        <form onSubmit={onSubmit} className="space-y-3">
          <div>
            <label className="text-xs font-semibold muted">E-mail</label>
            <input value={email} onChange={(e) => setEmail(e.target.value)} type="email" required
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500"
              style={{ borderColor: "var(--border)" }} />
          </div>
          <div>
            <label className="text-xs font-semibold muted">Senha</label>
            <input value={password} onChange={(e) => setPassword(e.target.value)} type="password" required
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500"
              style={{ borderColor: "var(--border)" }} />
          </div>
          {error && <div className="text-sm text-red-500">{error}</div>}
          <button disabled={loading}
            className="w-full bg-brand-600 hover:bg-brand-700 text-white rounded-lg py-2.5 text-sm font-semibold disabled:opacity-60">
            {loading ? "Entrando…" : "Entrar"}
          </button>
        </form>
      </div>
    </div>
  );
}
