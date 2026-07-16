"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const TABS = ["Painel", "Integrações & Teste", "Chaves de API", "Nota Fiscal (NFe)", "Logs"] as const;
const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2 });
const dt = (s: any) => s ? new Date(s).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit" }) : "—";
const nfeBadge = (s: string) => {
  const x = String(s ?? "").toLowerCase();
  if (x.includes("autoriz") || x.includes("emitid")) return "badge-success";
  if (x.includes("erro") || x.includes("rejeit") || x.includes("denegad")) return "badge-danger";
  if (x.includes("cancel")) return "badge-neutral";
  return "badge-warning";
};

const PAGAMENTO = [
  { key: "monetizze", nome: "Monetizze", icon: "🛒", desc: "Checkout e vendas de infoproduto" },
  { key: "appmax", nome: "AppMax", icon: "🔀", desc: "Checkout + split de pagamento" },
  { key: "braip", nome: "Braip", icon: "🧾", desc: "Checkout e afiliados" },
  { key: "hotmart", nome: "Hotmart", icon: "🔥", desc: "Infoprodutos e assinaturas" },
  { key: "kiwify", nome: "Kiwify", icon: "🥝", desc: "Checkout de infoproduto" },
  { key: "mercadopago", nome: "Mercado Pago", icon: "💳", desc: "Gateway de pagamento (Pix/cartão)" },
  { key: "pagseguro", nome: "PagSeguro", icon: "🏦", desc: "Gateway de pagamento (Pix/cartão)" },
  { key: "stripe", nome: "Stripe", icon: "💠", desc: "Pagamentos internacionais" },
];
const LOGISTICA = [
  { key: "correios", nome: "Correios", icon: "📮", desc: "Prepostagem, etiqueta e rastreio (SRO)" },
  { key: "vhsys", nome: "VHSYS", icon: "🏬", desc: "Estoque e emissão de NF-e" },
  { key: "supabase", nome: "Banco de Dados", icon: "🗄", desc: "Backend do sistema" },
];
const PROVIDERS = [...PAGAMENTO, ...LOGISTICA];

export default function IntegracoesNfeWorkbench({ produtores, nfe, baixa, apiKeys, apiLogs, webhookLogs }: {
  produtores: any[]; nfe: any[]; baixa: any[]; apiKeys: any[]; apiLogs: any[]; webhookLogs: any[];
}) {
  const router = useRouter();
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const [tests, setTests] = useState<Record<string, any>>({});
  const [busy, setBusy] = useState("");
  const [novaChave, setNovaChave] = useState({ nome: "", escopos: "vendas:read,pedidos:read" });
  const [chaveGerada, setChaveGerada] = useState<string>("");

  const p = produtores[0] ?? {};
  const nfeAutorizadas = nfe.filter((n) => nfeBadge(n.status) === "badge-success").length;
  const nfeErro = nfe.filter((n) => nfeBadge(n.status) === "badge-danger").length;
  const intAtivas = useMemo(() => {
    let n = 0;
    if (p.has_monetizze || p.monetizze_ativa) n++;
    if (p.has_braip || p.braip_ativa) n++;
    if (p.has_vhsys) n++;
    if (p.sislog_ativa) n++;
    return n;
  }, [p]);

  async function testar(provider: string) {
    setBusy("test:" + provider);
    try {
      const res = await fetch("/api/integracoes/test", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ provider }) });
      const j = await res.json();
      setTests((t) => ({ ...t, [provider]: j }));
    } catch (e: any) { setTests((t) => ({ ...t, [provider]: { ok: false, message: "Erro de rede: " + e.message } })); }
    setBusy("");
  }
  async function testarTudo() { for (const pr of PROVIDERS) await testar(pr.key); }

  async function gerarChave() {
    if (!novaChave.nome.trim()) { alert("Dê um nome para a chave."); return; }
    setBusy("key"); setChaveGerada("");
    try {
      const res = await fetch("/api/integracoes/api-key", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ nome: novaChave.nome, escopos: novaChave.escopos.split(",").map((s) => s.trim()).filter(Boolean) }),
      });
      const j = await res.json();
      if (!res.ok) alert("🚫 " + (j.error ?? "Falha ao gerar")); else { setChaveGerada(j.key); setNovaChave({ nome: "", escopos: "vendas:read,pedidos:read" }); router.refresh(); }
    } catch (e: any) { alert("Erro: " + e.message); }
    setBusy("");
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🔌</div>
        <div>
          <h1 className="text-xl font-bold">Integrações (API) &amp; Nota Fiscal</h1>
          <p className="text-sm muted">Conexões com plataformas externas, teste de credenciais, chaves de API, logs e emissão de NF-e.</p>
        </div>
      </div>

      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-t-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <KpiCard label="Integrações ativas" value={intAtivas} icon="🔌" accent />
          <KpiCard label="NFe autorizadas" value={nfeAutorizadas} icon="🧾" tone="success" />
          <KpiCard label="NFe com erro" value={nfeErro} icon="⚠" tone={nfeErro ? "danger" : "neutral"} />
          <KpiCard label="Emissão de NFe" value={p.emissao_nfe_ativa ? "Ligada" : "Desligada"} icon="📄" tone={p.emissao_nfe_ativa ? "success" : "neutral"} />
          <KpiCard label="Chaves de API" value={apiKeys.filter((k) => k.ativo && !k.revoked_at).length} icon="🔑" hint={`${apiKeys.length} no total`} />
          <KpiCard label="Chamadas de API (logs)" value={apiLogs.length} icon="📊" />
          <KpiCard label="Webhooks recebidos" value={webhookLogs.length} icon="📥" />
          <KpiCard label="Config. de baixa (NFe)" value={baixa.length} icon="📦" />
        </div>
      )}

      {tab === "Integrações & Teste" && (
        <div className="space-y-3">
          <div className="flex items-center gap-2">
            <div className="text-sm muted flex-1">Clique em <b>Testar</b> para checar cada integração ao vivo (roda no servidor — sua chave não sai do backend).</div>
            <button onClick={testarTudo} disabled={busy.startsWith("test")} className="px-3 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-50">🔎 Testar todas</button>
          </div>
          {[{ t: "💳 Plataformas de Pagamento", list: PAGAMENTO }, { t: "🚚 Logística & Fiscal", list: LOGISTICA }].map((sec) => (
            <div key={sec.t}>
              <div className="text-xs font-semibold uppercase tracking-wide muted mb-1.5">{sec.t}</div>
              <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-3">
                {sec.list.map((pr) => {
                  const st = tests[pr.key];
                  const configurada = pr.key === "monetizze" ? p.has_monetizze : pr.key === "braip" ? p.has_braip : pr.key === "vhsys" ? p.has_vhsys : pr.key === "supabase" ? true : undefined;
                  return (
                    <div key={pr.key} className="card p-4">
                      <div className="flex items-center gap-2">
                        <span className="text-xl">{pr.icon}</span>
                        <div className="flex-1 min-w-0">
                          <div className="font-bold text-sm">{pr.nome}</div>
                          <div className="text-xs muted">{pr.desc}</div>
                        </div>
                        {configurada === true && <span className="badge badge-success">🔑</span>}
                        {configurada === false && <span className="badge badge-neutral">sem chave</span>}
                      </div>
                      <div className="flex items-center gap-2 mt-3 flex-wrap">
                        <button onClick={() => testar(pr.key)} disabled={busy === "test:" + pr.key} className="px-3 py-1.5 rounded-lg card text-sm font-semibold disabled:opacity-50">{busy === "test:" + pr.key ? "Testando…" : "🔎 Testar"}</button>
                        {st && (
                          <span className={`text-xs font-medium ${st.ok ? "text-emerald-600" : "text-red-500"}`}>
                            {st.ok ? "✅" : "🚨"} {st.message}{st.ms ? ` (${st.ms}ms)` : ""}
                          </span>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          ))}
          <div className="card p-3 text-xs muted">O teste confirma se a API da plataforma está <b>no ar</b> (e valida a chave da Monetizze quando configurada). Para <b>cadastrar</b> a chave da Monetizze use <b>Puxar Pedidos de Lojas</b>; o split da AppMax fica em <b>Coprodução &amp; Split</b>.</div>
        </div>
      )}

      {tab === "Chaves de API" && (
        <div className="space-y-3">
          <div className="card p-4 space-y-2">
            <div className="font-semibold text-sm">Gerar nova chave de API</div>
            <div className="flex flex-wrap items-end gap-2">
              <div className="flex-1 min-w-[180px]"><label className="text-xs muted">Nome</label><input value={novaChave.nome} onChange={(e) => setNovaChave({ ...novaChave, nome: e.target.value })} placeholder="ex.: Integração ERP externo" className="input w-full text-sm mt-0.5" /></div>
              <div className="flex-1 min-w-[180px]"><label className="text-xs muted">Escopos (vírgula)</label><input value={novaChave.escopos} onChange={(e) => setNovaChave({ ...novaChave, escopos: e.target.value })} className="input w-full text-sm mt-0.5 font-mono" /></div>
              <button onClick={gerarChave} disabled={busy === "key"} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-50">{busy === "key" ? "Gerando…" : "＋ Gerar chave"}</button>
            </div>
            {chaveGerada && (
              <div className="card p-3" style={{ background: "var(--surface-3)", borderColor: "var(--success)" }}>
                <div className="text-xs font-semibold text-emerald-600">✅ Chave gerada — copie agora, ela NÃO será exibida de novo:</div>
                <div className="font-mono text-xs mt-1 break-all select-all p-2 rounded" style={{ background: "var(--surface-2)" }}>{chaveGerada}</div>
              </div>
            )}
          </div>
          <div className="card p-0 overflow-x-auto">
            <div className="px-4 pt-3 font-semibold text-sm">Chaves ativas <span className="badge badge-neutral ml-1">{apiKeys.length}</span></div>
            {apiKeys.length === 0 ? <p className="text-sm muted p-4">Nenhuma chave gerada. Gere uma acima para permitir que sistemas externos consultem seus dados.</p> : (
              <table className="w-full text-sm mt-2">
                <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-4">Nome</th><th className="px-3">Prefixo</th><th className="px-3">Escopos</th><th className="px-3">Status</th><th className="px-3">Último uso</th><th className="px-3">Criada</th></tr></thead>
                <tbody>{apiKeys.map((k) => (
                  <tr key={k.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                    <td className="py-2 px-4 font-medium">{k.nome}</td>
                    <td className="px-3 font-mono text-xs">{k.key_prefix}…</td>
                    <td className="px-3 text-xs">{Array.isArray(k.escopos) ? k.escopos.join(", ") : k.escopos}</td>
                    <td className="px-3">{k.revoked_at ? <span className="badge badge-danger">revogada</span> : k.ativo ? <span className="badge badge-success">ativa</span> : <span className="badge badge-neutral">inativa</span>}</td>
                    <td className="px-3 text-xs muted">{dt(k.last_used_at)}</td>
                    <td className="px-3 text-xs muted">{dt(k.created_at)}</td>
                  </tr>))}</tbody>
              </table>
            )}
          </div>
        </div>
      )}

      {tab === "Nota Fiscal (NFe)" && (
        <div className="space-y-3">
          <div className="grid md:grid-cols-4 gap-3">
            <div className="card p-4 md:col-span-2">
              <div className="text-xs uppercase muted font-semibold">Configuração fiscal (emitente)</div>
              <div className="text-sm mt-1">{p.razao_social ?? "—"}</div>
              <div className="text-xs muted">CNPJ {p.cnpj ?? "—"} · IE {p.inscricao_estadual ?? "—"}</div>
              <div className="text-xs muted mt-1">CFOP {p.nfe_cfop ?? "—"} · {p.nfe_natureza ?? "natureza não definida"}</div>
              <div className="mt-1"><span className={`badge ${p.emissao_nfe_ativa ? "badge-success" : "badge-neutral"}`}>{p.emissao_nfe_ativa ? "emissão ligada" : "emissão desligada"}</span></div>
            </div>
            <KpiCard label="NFe autorizadas" value={nfeAutorizadas} tone="success" />
            <KpiCard label="NFe com erro" value={nfeErro} tone={nfeErro ? "danger" : "neutral"} />
          </div>

          <div className="card p-0 overflow-x-auto">
            <div className="px-4 pt-3 font-semibold text-sm">Emissões de NF-e <span className="badge badge-neutral ml-1">{nfe.length}</span></div>
            {nfe.length === 0 ? <p className="text-sm muted p-4">Nenhuma NF-e emitida ainda. As emissões acontecem via VHSYS quando a venda é paga (se a emissão estiver ligada).</p> : (
              <table className="w-full text-sm mt-2">
                <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-4">Produto</th><th className="px-3 text-right">Valor</th><th className="px-3">Status</th><th className="px-3">Chave / Protocolo</th><th className="px-3">Docs</th><th className="px-3">Emitida</th></tr></thead>
                <tbody>{nfe.map((n) => (
                  <tr key={n.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                    <td className="py-2 px-4 text-xs">{n.plano_nome ?? n.produto_nome ?? "—"}</td>
                    <td className="px-3 text-right tabular-nums">{money(n.valor)}</td>
                    <td className="px-3"><span className={`badge ${nfeBadge(n.status)}`}>{n.status ?? "—"}</span>{n.erro && <span className="block text-[11px] text-red-500 mt-0.5">{String(n.erro).slice(0, 50)}</span>}</td>
                    <td className="px-3 font-mono text-[11px] muted">{n.chave ? String(n.chave).slice(0, 18) + "…" : n.protocolo ?? "—"}</td>
                    <td className="px-3 text-xs">{n.danfe_url ? <a href={n.danfe_url} target="_blank" className="text-brand-600 underline">DANFE</a> : ""} {n.xml_url ? <a href={n.xml_url} target="_blank" className="text-brand-600 underline ml-1">XML</a> : ""}{!n.danfe_url && !n.xml_url ? "—" : ""}</td>
                    <td className="px-3 text-xs muted">{dt(n.emitida_at ?? n.created_at)}</td>
                  </tr>))}</tbody>
              </table>
            )}
          </div>

          <CrudPanel table="nfe_baixa_estoque_config" title="Baixa de estoque por produto (NFe → VHSYS)" rows={baixa}
            emptyHint="Vincula o produto da venda ao produto/local no VHSYS para dar baixa no estoque ao emitir a NFe."
            fields={[
              { key: "produto_codigo", label: "Código do produto (venda)", required: true },
              { key: "produto_descricao", label: "Descrição" },
              { key: "id_produto_vhsys", label: "ID produto VHSYS" },
              { key: "id_local_estoque", label: "ID local de estoque" },
              { key: "local_descricao", label: "Local (descrição)" },
              { key: "match_nome", label: "Casar por nome (contém)" },
            ]}
            columns={[
              { key: "produto_codigo", label: "Produto" }, { key: "id_produto_vhsys", label: "VHSYS" },
              { key: "local_descricao", label: "Local" }, { key: "ativo", label: "Ativo", fmt: (v) => (v ? "sim" : "não") },
            ]} />
        </div>
      )}

      {tab === "Logs" && (
        <div className="space-y-4">
          <div className="card p-0 overflow-x-auto">
            <div className="px-4 pt-3 font-semibold text-sm">Chamadas de API <span className="badge badge-neutral ml-1">{apiLogs.length}</span></div>
            {apiLogs.length === 0 ? <p className="text-sm muted p-4">Nenhuma chamada registrada.</p> : (
              <table className="w-full text-sm mt-2">
                <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-4">Tipo</th><th className="px-3">Ação</th><th className="px-3">Status</th><th className="px-3">HTTP</th><th className="px-3">Referência</th><th className="px-3 text-right">ms</th><th className="px-3">Quando</th></tr></thead>
                <tbody>{apiLogs.map((l) => (
                  <tr key={l.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                    <td className="py-2 px-4 text-xs">{l.tipo ?? "—"}</td><td className="px-3 text-xs">{l.acao ?? "—"}</td>
                    <td className="px-3"><span className={`badge ${String(l.status).toLowerCase().includes("erro") || (l.http_status >= 400) ? "badge-danger" : "badge-success"}`}>{l.status ?? l.http_status ?? "—"}</span></td>
                    <td className="px-3 text-xs">{l.http_status ?? "—"}</td><td className="px-3 text-xs">{l.referencia ?? l.codigo_rastreio ?? "—"}</td>
                    <td className="px-3 text-right tabular-nums text-xs">{l.duracao_ms ?? "—"}</td><td className="px-3 text-xs muted">{dt(l.created_at)}</td>
                  </tr>))}</tbody>
              </table>
            )}
          </div>
          <div className="card p-0 overflow-x-auto">
            <div className="px-4 pt-3 font-semibold text-sm">Webhooks recebidos <span className="badge badge-neutral ml-1">{webhookLogs.length}</span></div>
            {webhookLogs.length === 0 ? <p className="text-sm muted p-4">Nenhum webhook recebido.</p> : (
              <table className="w-full text-sm mt-2">
                <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-4">Venda</th><th className="px-3">Comprador</th><th className="px-3 text-right">Valor</th><th className="px-3">Status</th><th className="px-3">Origem</th><th className="px-3">Quando</th></tr></thead>
                <tbody>{webhookLogs.map((l) => (
                  <tr key={l.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                    <td className="py-2 px-4 font-medium">{l.codigo_venda ?? l.venda_id ?? "—"}</td><td className="px-3 text-xs">{l.comprador_nome ?? "—"}</td>
                    <td className="px-3 text-right tabular-nums">{money(l.valor)}</td>
                    <td className="px-3"><span className={`badge ${String(l.status).toLowerCase().includes("erro") || String(l.status).toLowerCase().includes("rejeit") ? "badge-danger" : "badge-success"}`}>{l.status ?? "—"}</span>{l.motivo && <span className="block text-[11px] muted">{String(l.motivo).slice(0, 40)}</span>}</td>
                    <td className="px-3 text-xs muted">{l.ip_origem ?? "—"}</td><td className="px-3 text-xs muted">{dt(l.created_at)}</td>
                  </tr>))}</tbody>
              </table>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
