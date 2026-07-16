"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { KpiCard } from "@/components/ui/KpiCard";

type Connector = {
  id: string;
  name: string | null;
  platform: string;
  producer_ref: string | null;
  status: string | null;
  categoria: string | null;
  metadata: Record<string, any> | null;
  last_event_at: string | null;
};

const TABS = ["Painel", "Plataformas", "Minhas lojas"] as const;
const dt = (s: any) => s ? new Date(s).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit" }) : "—";

// Slugs de plataforma minúsculos — batem com store_connectors.platform.
const PLATAFORMAS = [
  { key: "shopify", nome: "Shopify", icon: "🛍", desc: "Loja / e-commerce" },
  { key: "woocommerce", nome: "WooCommerce", icon: "🟣", desc: "WordPress / e-commerce" },
  { key: "nuvemshop", nome: "Nuvemshop", icon: "☁️", desc: "Loja / e-commerce" },
  { key: "tray", nome: "Tray", icon: "🟦", desc: "Loja / e-commerce" },
  { key: "vtex", nome: "VTEX", icon: "⬛", desc: "E-commerce enterprise" },
  { key: "loja_integrada", nome: "Loja Integrada", icon: "🟧", desc: "Loja / e-commerce" },
  { key: "wix", nome: "Wix", icon: "⚫", desc: "Sites / e-commerce" },
  { key: "magento", nome: "Magento", icon: "🟥", desc: "E-commerce" },
  { key: "yampi", nome: "Yampi", icon: "🟨", desc: "Checkout / loja" },
  { key: "cartpanda", nome: "CartPanda", icon: "🐼", desc: "Checkout / loja" },
  { key: "bagy", nome: "Bagy", icon: "🟩", desc: "Loja / e-commerce" },
  { key: "wbuy", nome: "Wbuy", icon: "🔷", desc: "Loja / e-commerce" },
  { key: "prestashop", nome: "PrestaShop", icon: "🟪", desc: "E-commerce" },
] as const;

export default function EcommerceHubWorkbench({ connectors = [], pedidosPorLoja = {} }: {
  connectors?: Connector[]; pedidosPorLoja?: Record<string, number>;
}) {
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [tests, setTests] = useState<Record<string, any>>({});
  const [keys, setKeys] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState("");
  const [msg, setMsg] = useState<Record<string, string>>({});

  const connByPlatform = useMemo(() => new Set(connectors.map((c) => c.platform)), [connectors]);
  const comChave = useMemo(() => connectors.filter((c) => c.metadata?.key_set).length, [connectors]);
  const totalPedidos = useMemo(() => Object.values(pedidosPorLoja).reduce((a, b) => a + b, 0), [pedidosPorLoja]);
  const nomePlataforma = (k: string) => PLATAFORMAS.find((p) => p.key === k)?.nome ?? k;

  async function testar(provider: string) {
    setBusy("test:" + provider);
    try {
      const res = await fetch("/api/integracoes/test", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ provider }) });
      const j = await res.json();
      setTests((t) => ({ ...t, [provider]: j }));
    } catch (e: any) { setTests((t) => ({ ...t, [provider]: { ok: false, message: "Erro de rede: " + e.message } })); }
    setBusy("");
  }

  async function salvar(platform: string, nome: string) {
    const key = (keys[platform] ?? "").trim();
    if (!key) { setMsg((m) => ({ ...m, [platform]: "Cole a chave da API primeiro." })); return; }
    setBusy("save:" + platform); setMsg((m) => ({ ...m, [platform]: "" }));
    try {
      const res = await fetch("/api/integracoes/credencial", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ platform, categoria: "ecommerce", nome, key }),
      });
      const j = await res.json();
      if (!res.ok) setMsg((m) => ({ ...m, [platform]: "🚫 " + (j.error ?? "Falha ao salvar") }));
      else { setKeys((k) => ({ ...k, [platform]: "" })); setMsg((m) => ({ ...m, [platform]: "✅ " + (j.message ?? "Chave salva.") })); router.refresh(); }
    } catch (e: any) { setMsg((m) => ({ ...m, [platform]: "Erro: " + e.message })); }
    setBusy("");
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🛒</div>
        <div>
          <h1 className="text-xl font-bold">E-commerce — Lojas &amp; Chaves API</h1>
          <p className="text-sm muted">Suba a chave de API de qualquer e-commerce, teste a conexão e puxe os pedidos das suas lojas.</p>
        </div>
      </div>

      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-t-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="space-y-4">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="Lojas conectadas" value={connectors.length} icon="🏬" accent />
            <KpiCard label="Lojas com chave" value={comChave} icon="🔑" tone={comChave ? "success" : "neutral"} hint={`${connectors.length} no total`} />
            <KpiCard label="Pedidos importados" value={totalPedidos} icon="📦" tone="success" />
            <KpiCard label="Plataformas disponíveis" value={PLATAFORMAS.length} icon="🧩" />
          </div>

          <div className="card p-0 overflow-x-auto">
            <div className="px-4 pt-3 font-semibold text-sm">Pedidos por loja <span className="badge badge-neutral ml-1">{Object.keys(pedidosPorLoja).length}</span></div>
            {Object.keys(pedidosPorLoja).length === 0 ? <p className="text-sm muted p-4">Nenhum pedido importado ainda. Conecte uma loja em <b>Plataformas</b> e puxe os pedidos.</p> : (
              <table className="w-full text-sm mt-2">
                <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-4">Loja / Plataforma</th><th className="px-3 text-right">Pedidos</th></tr></thead>
                <tbody>{Object.entries(pedidosPorLoja).sort((a, b) => b[1] - a[1]).map(([plat, qtd]) => (
                  <tr key={plat} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                    <td className="py-2 px-4 font-medium">{nomePlataforma(plat)}</td>
                    <td className="px-3 text-right tabular-nums">{qtd}</td>
                  </tr>))}</tbody>
              </table>
            )}
          </div>
        </div>
      )}

      {tab === "Plataformas" && (
        <div className="space-y-3">
          <div className="card p-3 text-sm muted">Cole a chave da API da plataforma e clique <b>Salvar chave</b> (gravada só no servidor — nunca é exibida de volta). Use <b>Testar</b> para checar se a API está no ar. Depois, puxe os pedidos em <b>Minhas lojas</b>.</div>
          <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-3">
            {PLATAFORMAS.map((pr) => {
              const st = tests[pr.key];
              const conectada = connByPlatform.has(pr.key);
              const m = msg[pr.key];
              return (
                <div key={pr.key} className="card p-4 space-y-2.5">
                  <div className="flex items-center gap-2">
                    <span className="text-xl">{pr.icon}</span>
                    <div className="flex-1 min-w-0">
                      <div className="font-bold text-sm truncate">{pr.nome}</div>
                      <div className="text-xs muted truncate">{pr.desc}</div>
                    </div>
                    {conectada && <span className="badge badge-success">conectada</span>}
                  </div>
                  <input
                    type="password"
                    value={keys[pr.key] ?? ""}
                    onChange={(e) => setKeys((k) => ({ ...k, [pr.key]: e.target.value }))}
                    placeholder="Cole a chave da API"
                    className="input w-full text-sm font-mono"
                    autoComplete="off"
                  />
                  <div className="flex items-center gap-1.5 flex-wrap">
                    <button onClick={() => salvar(pr.key, pr.nome)} disabled={busy === "save:" + pr.key} className="px-2.5 py-1.5 rounded-lg bg-brand-600 text-white text-xs font-semibold disabled:opacity-50">{busy === "save:" + pr.key ? "Salvando…" : "💾 Salvar chave"}</button>
                    <button onClick={() => testar(pr.key)} disabled={busy === "test:" + pr.key} className="px-2.5 py-1.5 rounded-lg card text-xs font-semibold disabled:opacity-50">{busy === "test:" + pr.key ? "Testando…" : "🔎 Testar"}</button>
                  </div>
                  {st && <div className={`text-xs font-medium ${st.ok ? "text-emerald-600" : "text-red-500"}`}>{st.ok ? "✅" : "🚨"} {st.message}{st.ms ? ` (${st.ms}ms)` : ""}</div>}
                  {m && <div className={`text-xs font-medium ${m.startsWith("✅") ? "text-emerald-600" : "text-red-500"}`}>{m}</div>}
                </div>
              );
            })}
          </div>
        </div>
      )}

      {tab === "Minhas lojas" && (
        <div className="space-y-3">
          <div className="flex items-center gap-2">
            <div className="text-sm muted flex-1">Lojas conectadas nesta empresa. Cole/atualize a chave em <b>Plataformas</b>; para importar as vendas, use <b>Puxar Pedidos</b>.</div>
            <Link href="/integracoes-lojas" className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold no-underline whitespace-nowrap">⬇️ Puxar Pedidos</Link>
          </div>
          <div className="card p-0 overflow-x-auto">
            <div className="px-4 pt-3 font-semibold text-sm">Minhas lojas <span className="badge badge-neutral ml-1">{connectors.length}</span></div>
            {connectors.length === 0 ? <p className="text-sm muted p-4">Nenhuma loja conectada ainda. Vá em <b>Plataformas</b>, cole a chave de API e salve.</p> : (
              <table className="w-full text-sm mt-2">
                <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-4">Nome</th><th className="px-3">Plataforma</th><th className="px-3">Chave</th><th className="px-3">Status</th><th className="px-3">Último evento</th><th className="px-3"></th></tr></thead>
                <tbody>{connectors.map((c) => (
                  <tr key={c.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                    <td className="py-2 px-4 font-medium">{c.producer_ref ?? c.name ?? nomePlataforma(c.platform)}</td>
                    <td className="px-3 text-xs">{nomePlataforma(c.platform)}</td>
                    <td className="px-3">{c.metadata?.key_set ? <span className="badge badge-success">🔑 chave configurada</span> : <span className="badge badge-neutral">sem chave</span>}</td>
                    <td className="px-3">{c.status === "active" ? <span className="badge badge-success">ativa</span> : c.status === "error" ? <span className="badge badge-danger">erro</span> : <span className="badge badge-neutral">{c.status ?? "inativa"}</span>}</td>
                    <td className="px-3 text-xs muted">{dt(c.last_event_at)}</td>
                    <td className="px-3"><Link href="/integracoes-lojas" className="text-xs font-semibold" style={{ color: "var(--brand)" }}>puxar pedidos →</Link></td>
                  </tr>))}</tbody>
              </table>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
