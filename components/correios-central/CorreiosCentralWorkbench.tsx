"use client";
import { useMemo, useState } from "react";
import { KpiCard } from "@/components/ui/KpiCard";

const TABS = [
  "Painel",
  "Prepostagem",
  "Rastreio",
  "Conferência",
  "Correções de CEP",
  "Contratos & Remetente",
  "Config & Credenciais",
  "Logs",
] as const;

const dt = (s: any) => s ? new Date(s).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit" }) : "—";
const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2 });

const stBadge = (s: any) => {
  const x = String(s ?? "").toLowerCase();
  if (x.includes("erro") || x.includes("falha") || x.includes("rejeit")) return "badge-danger";
  if (x.includes("entregue") || x.includes("sucesso") || x.includes("ok")) return "badge-success";
  if (x.includes("postado") || x.includes("transito") || x.includes("trânsito") || x.includes("encaminhad")) return "badge-neutral";
  return "badge-warning";
};

export default function CorreiosCentralWorkbench({
  prepostagens, ppn, conferencias, cepLogs, contratos, remetente, apiLogs, autoLogs, connectors = [],
}: {
  prepostagens: any[]; ppn: any[]; conferencias: any[]; cepLogs: any[];
  contratos: any[]; remetente: any[]; apiLogs: any[]; autoLogs: any[]; connectors?: any[];
}) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");

  // Credenciais
  const [chave, setChave] = useState("");
  const [busy, setBusy] = useState("");
  const [salvo, setSalvo] = useState<string>("");
  const [teste, setTeste] = useState<any>(null);

  const conector = useMemo(() => connectors[0], [connectors]);
  const [configurada, setConfigurada] = useState<boolean>(!!conector?.metadata?.key_set);

  const comObjeto = useMemo(() => prepostagens.filter((p) => p.codigo_objeto).length, [prepostagens]);
  const comErro = useMemo(() => prepostagens.filter((p) => p.erro || stBadge(p.status) === "badge-danger").length, [prepostagens]);
  const rastreados = useMemo(() => ppn.filter((p) => p.ultimo_status || p.codigo_objeto).length, [ppn]);
  const cepCorrigidos = useMemo(() => cepLogs.filter((c) => c.cep_corrigido && c.cep_corrigido !== c.cep_original).length, [cepLogs]);
  const contratosAtivos = useMemo(() => contratos.filter((c) => c.ativo).length, [contratos]);

  async function salvarChave() {
    if (!chave.trim()) { alert("Cole a chave/credencial dos Correios."); return; }
    setBusy("save"); setSalvo("");
    try {
      const res = await fetch("/api/integracoes/credencial", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ platform: "correios", categoria: "logistica", nome: "Correios", key: chave }),
      });
      const j = await res.json().catch(() => ({}));
      if (!res.ok) { alert("🚫 " + (j.error ?? "Falha ao salvar")); }
      else { setChave(""); setConfigurada(true); setSalvo("Credencial salva com segurança (write-only)."); }
    } catch (e: any) { alert("Erro: " + e.message); }
    setBusy("");
  }

  async function testarConexao() {
    setBusy("test"); setTeste(null);
    try {
      const res = await fetch("/api/integracoes/test", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ provider: "correios" }),
      });
      const j = await res.json().catch(() => ({}));
      setTeste(j);
    } catch (e: any) { setTeste({ ok: false, message: "Erro de rede: " + e.message }); }
    setBusy("");
  }

  const th = "text-left muted text-xs uppercase border-b";
  const bstyle = { borderColor: "var(--border)" } as const;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">📮</div>
        <div>
          <h1 className="text-xl font-bold">Correios — Central Única</h1>
          <p className="text-sm muted">Todas as ferramentas dos Correios num só lugar: prepostagem, rastreio (SRO), conferência, correção de CEP, contratos, credenciais e logs.</p>
        </div>
      </div>

      <div className="flex gap-1 flex-wrap border-b" style={bstyle}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-t-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <KpiCard label="Prepostagens" value={prepostagens.length} icon="📮" accent />
          <KpiCard label="Objetos rastreados" value={rastreados} icon="📦" tone="success" />
          <KpiCard label="Com erro" value={comErro} icon="⚠" tone={comErro ? "danger" : "neutral"} />
          <KpiCard label="Correções de CEP" value={cepCorrigidos} icon="📍" tone={cepCorrigidos ? "warning" : "neutral"} />
          <KpiCard label="Com código de objeto" value={comObjeto} icon="🏷" />
          <KpiCard label="Conferências" value={conferencias.length} icon="✅" />
          <KpiCard label="Contratos" value={contratos.length} icon="📄" hint={`${contratosAtivos} ativos`} />
          <KpiCard label="Credencial API" value={configurada ? "Configurada" : "Pendente"} icon="🔑" tone={configurada ? "success" : "neutral"} />
        </div>
      )}

      {tab === "Prepostagem" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Prepostagens <span className="badge badge-neutral ml-1">{prepostagens.length}</span></div>
          {prepostagens.length === 0 ? <p className="text-sm muted p-4">Nenhuma prepostagem. Elas são geradas no fluxo de despacho (venda → Correios).</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className={th} style={bstyle}>
                <th className="py-2 px-4">Objeto</th><th className="px-3">Destinatário</th><th className="px-3">Cidade/UF</th><th className="px-3">Serviço</th><th className="px-3 text-right">Peso(g)</th><th className="px-3">Status</th><th className="px-3">Criado</th></tr></thead>
              <tbody>{prepostagens.map((p) => (
                <tr key={p.id} className="border-b last:border-0" style={bstyle}>
                  <td className="py-2 px-4 font-mono text-xs">{p.codigo_objeto ?? p.id_prepostagem ?? "—"}</td>
                  <td className="px-3">{p.destinatario_nome ?? "—"}</td>
                  <td className="px-3 text-xs">{p.destinatario_cidade ?? "—"}/{p.destinatario_estado ?? ""}</td>
                  <td className="px-3 text-xs">{p.servico_nome ?? p.servico_codigo ?? "—"}</td>
                  <td className="px-3 text-right tabular-nums">{p.peso_g ?? "—"}</td>
                  <td className="px-3"><span className={`badge ${stBadge(p.status)}`}>{p.status ?? "—"}</span>{p.erro && <span className="block text-[11px] text-red-500 mt-0.5">{String(p.erro).slice(0, 60)}</span>}</td>
                  <td className="px-3 text-xs muted">{dt(p.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Rastreio" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Rastreio de objetos (PPN / SRO) <span className="badge badge-neutral ml-1">{ppn.length}</span></div>
          {ppn.length === 0 ? <p className="text-sm muted p-4">Nenhum objeto rastreado. Sincroniza os objetos de pré-postagem nacional com o rastreio (SRO) dos Correios.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className={th} style={bstyle}>
                <th className="py-2 px-4">Código</th><th className="px-3">Destinatário</th><th className="px-3">Serviço</th><th className="px-3">Último status</th><th className="px-3">Local</th><th className="px-3">Postado</th><th className="px-3">Sincron.</th></tr></thead>
              <tbody>{ppn.map((p) => (
                <tr key={p.id} className="border-b last:border-0" style={bstyle}>
                  <td className="py-2 px-4 font-mono text-xs">{p.codigo_objeto ?? "—"}</td>
                  <td className="px-3">{p.destinatario_nome ?? "—"}</td>
                  <td className="px-3 text-xs">{p.servico_nome ?? p.servico_codigo ?? "—"}</td>
                  <td className="px-3"><span className={`badge ${stBadge(p.ultimo_status ?? p.status)}`}>{p.ultimo_status ?? p.status ?? "—"}</span></td>
                  <td className="px-3 text-xs">{p.ultimo_status_local ?? "—"}</td>
                  <td className="px-3 text-xs muted">{dt(p.data_postagem)}</td>
                  <td className="px-3 text-xs muted">{dt(p.ultima_sincronizacao ?? p.ultima_consulta_sro)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Conferência" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Conferências de postagem <span className="badge badge-neutral ml-1">{conferencias.length}</span></div>
          {conferencias.length === 0 ? <p className="text-sm muted p-4">Nenhuma conferência. Compara a planilha/PDF de postagem com o que foi realmente postado (postados × não encontrados).</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className={th} style={bstyle}>
                <th className="py-2 px-4">Planilha / PDF</th><th className="px-3 text-right">Total</th><th className="px-3 text-right">Postados</th><th className="px-3 text-right">Não encontrados</th><th className="px-3 text-right">Possíveis</th><th className="px-3">Data</th></tr></thead>
              <tbody>{conferencias.map((c) => (
                <tr key={c.id} className="border-b last:border-0" style={bstyle}>
                  <td className="py-2 px-4 text-xs">{c.planilha_nome ?? c.pdf_nome ?? "—"}</td>
                  <td className="px-3 text-right tabular-nums">{c.total_planilha ?? 0}</td>
                  <td className="px-3 text-right tabular-nums text-emerald-600">{c.total_postados ?? 0}</td>
                  <td className="px-3 text-right tabular-nums text-red-500">{c.total_nao_encontrados ?? 0}</td>
                  <td className="px-3 text-right tabular-nums">{c.total_possiveis ?? 0}</td>
                  <td className="px-3 text-xs muted">{dt(c.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Correções de CEP" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Correções de CEP <span className="badge badge-neutral ml-1">{cepLogs.length}</span></div>
          {cepLogs.length === 0 ? <p className="text-sm muted p-4">Nenhuma correção. Registra CEPs corrigidos automaticamente antes do despacho (evita devolução por endereço).</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className={th} style={bstyle}>
                <th className="py-2 px-4">CEP original</th><th className="px-3">CEP corrigido</th><th className="px-3">Destino</th><th className="px-3">Fonte</th><th className="px-3">SISLOG</th><th className="px-3">Observação</th><th className="px-3">Data</th></tr></thead>
              <tbody>{cepLogs.map((c) => (
                <tr key={c.id} className="border-b last:border-0" style={bstyle}>
                  <td className="py-2 px-4 font-mono text-xs">{c.cep_original ?? "—"}</td>
                  <td className="px-3 font-mono text-xs font-semibold">{c.cep_corrigido ?? "—"}</td>
                  <td className="px-3 text-xs muted">{String(c.destino ?? "").slice(0, 30) || "—"}</td>
                  <td className="px-3 text-xs">{c.fonte ?? "—"}</td>
                  <td className="px-3">{c.enviado_sislog ? <span className="badge badge-success">enviado</span> : <span className="badge badge-neutral">não</span>}</td>
                  <td className="px-3 text-xs muted">{String(c.observacao ?? "").slice(0, 40)}</td>
                  <td className="px-3 text-xs muted">{dt(c.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Contratos & Remetente" && (
        <div className="space-y-4">
          <div className="card p-0 overflow-x-auto">
            <div className="px-4 pt-3 font-semibold text-sm">Contratos logísticos <span className="badge badge-neutral ml-1">{contratos.length}</span></div>
            {contratos.length === 0 ? <p className="text-sm muted p-4">Nenhum contrato cadastrado. Contratos definem cartão de postagem, AGF e códigos administrativos usados nas prepostagens.</p> : (
              <table className="w-full text-sm mt-2">
                <thead><tr className={th} style={bstyle}>
                  <th className="py-2 px-4">Nome</th><th className="px-3">Transportadora</th><th className="px-3">AGF</th><th className="px-3">Cidade/UF</th><th className="px-3">Contrato</th><th className="px-3">Cartão postagem</th><th className="px-3">DR</th><th className="px-3">Ativo</th></tr></thead>
                <tbody>{contratos.map((c) => (
                  <tr key={c.id} className="border-b last:border-0" style={bstyle}>
                    <td className="py-2 px-4 font-medium">{c.nome ?? "—"}</td>
                    <td className="px-3 text-xs">{c.transportadora ?? "—"}</td>
                    <td className="px-3 text-xs">{c.agf_nome ?? "—"}</td>
                    <td className="px-3 text-xs">{c.cidade ?? "—"}/{c.uf ?? ""}</td>
                    <td className="px-3 font-mono text-xs">{c.codigo_contrato ?? "—"}</td>
                    <td className="px-3 font-mono text-xs">{c.cartao_postagem ?? "—"}</td>
                    <td className="px-3 text-xs">{c.numero_dr ?? "—"}</td>
                    <td className="px-3">{c.ativo ? <span className="badge badge-success">ativo</span> : <span className="badge badge-neutral">inativo</span>}</td>
                  </tr>))}</tbody>
              </table>
            )}
          </div>

          <div className="card p-4">
            <div className="font-semibold text-sm mb-2">Remetente padrão</div>
            {remetente.length === 0 ? <p className="text-sm muted">Nenhum remetente configurado. É o endereço/CNPJ de origem impresso nas etiquetas.</p> : (
              <div className="grid md:grid-cols-2 gap-x-6 gap-y-1 text-sm">
                {remetente.map((r) => (
                  <div key={r.id} className="contents">
                    <div><span className="muted text-xs">Nome:</span> {r.nome ?? "—"}</div>
                    <div><span className="muted text-xs">Documento:</span> {r.documento ?? "—"}</div>
                    <div><span className="muted text-xs">E-mail:</span> {r.email ?? "—"}</div>
                    <div><span className="muted text-xs">Telefone:</span> {r.telefone ?? "—"}</div>
                    <div><span className="muted text-xs">Endereço:</span> {[r.endereco, r.numero, r.bairro].filter(Boolean).join(", ") || "—"}</div>
                    <div><span className="muted text-xs">Cidade/UF:</span> {r.cidade ?? "—"}/{r.estado ?? ""} · CEP {r.cep ?? "—"}</div>
                    <div><span className="muted text-xs">Nº contrato:</span> {r.numero_contrato ?? "—"}</div>
                    <div><span className="muted text-xs">Cartão de postagem:</span> {r.numero_cartao_postagem ?? "—"}</div>
                    <div><span className="muted text-xs">DR:</span> {r.numero_dr ?? "—"} · Diretoria {r.codigo_diretoria ?? "—"}</div>
                    <div><span className="muted text-xs">Atualizado:</span> {dt(r.updated_at)}</div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}

      {tab === "Config & Credenciais" && (
        <div className="space-y-4 max-w-2xl">
          <div className="card p-4 space-y-3">
            <div className="flex items-center gap-2">
              <span className="text-xl">📮</span>
              <div className="flex-1">
                <div className="font-bold text-sm">Credencial da API dos Correios</div>
                <div className="text-xs muted">Cole a chave/credencial (usuário:senha, token ou base64). É salva no backend (write-only) — nunca retorna ao navegador.</div>
              </div>
              {configurada ? <span className="badge badge-success">🔑 configurada</span> : <span className="badge badge-neutral">sem chave</span>}
            </div>

            <div>
              <label className="text-xs muted">Chave / credencial dos Correios</label>
              <input
                type="password"
                value={chave}
                onChange={(e) => setChave(e.target.value)}
                placeholder="cole aqui a credencial dos Correios"
                className="input w-full text-sm mt-0.5 font-mono"
              />
            </div>

            <div className="flex items-center gap-2 flex-wrap">
              <button onClick={salvarChave} disabled={busy === "save"} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-50">{busy === "save" ? "Salvando…" : "💾 Salvar credencial"}</button>
              <button onClick={testarConexao} disabled={busy === "test"} className="px-4 py-2 rounded-lg card text-sm font-semibold disabled:opacity-50">{busy === "test" ? "Testando…" : "🔎 Testar conexão"}</button>
              {salvo && <span className="text-xs font-medium text-emerald-600">✅ {salvo}</span>}
            </div>

            {teste && (
              <div className="card p-3" style={{ background: "var(--surface-3)" }}>
                <span className={`text-sm font-medium ${teste.ok ? "text-emerald-600" : "text-red-500"}`}>
                  {teste.ok ? "✅" : "🚨"} {teste.message ?? (teste.ok ? "Conexão OK" : "Falha na conexão")}
                  {teste.code ? ` · HTTP ${teste.code}` : ""}{teste.ms ? ` · ${teste.ms}ms` : ""}
                </span>
              </div>
            )}
          </div>

          {conector && (
            <div className="card p-4 text-sm space-y-1">
              <div className="font-semibold">Conector registrado</div>
              <div className="text-xs muted">Código: <span className="font-mono">{conector.code ?? "—"}</span> · Categoria: {conector.categoria ?? "logistica"}</div>
              <div className="text-xs muted">Status: <span className={`badge ${conector.status === "active" ? "badge-success" : "badge-neutral"}`}>{conector.status ?? "—"}</span> · Último evento: {dt(conector.last_event_at)}</div>
            </div>
          )}
        </div>
      )}

      {tab === "Logs" && (
        <div className="space-y-4">
          <div className="card p-0 overflow-x-auto">
            <div className="px-4 pt-3 font-semibold text-sm">Chamadas à API dos Correios <span className="badge badge-neutral ml-1">{apiLogs.length}</span></div>
            {apiLogs.length === 0 ? <p className="text-sm muted p-4">Nenhuma chamada registrada.</p> : (
              <table className="w-full text-sm mt-2">
                <thead><tr className={th} style={bstyle}>
                  <th className="py-2 px-4">Prefixo</th><th className="px-3">Ação</th><th className="px-3">Status</th><th className="px-3">HTTP</th><th className="px-3">Rastreio</th><th className="px-3">Mensagem</th><th className="px-3 text-right">ms</th><th className="px-3">Quando</th></tr></thead>
                <tbody>{apiLogs.map((l) => (
                  <tr key={l.id} className="border-b last:border-0" style={bstyle}>
                    <td className="py-2 px-4 text-xs">{l.prefixo ?? "—"}</td>
                    <td className="px-3 text-xs">{l.acao ?? "—"}</td>
                    <td className="px-3"><span className={`badge ${(l.http_status && l.http_status >= 400) || stBadge(l.status) === "badge-danger" ? "badge-danger" : "badge-success"}`}>{l.status ?? "—"}</span></td>
                    <td className="px-3 text-xs">{l.http_status ?? "—"}</td>
                    <td className="px-3 font-mono text-[11px]">{l.codigo_rastreio ?? "—"}</td>
                    <td className="px-3 text-xs muted">{String(l.mensagem ?? "").slice(0, 44)}</td>
                    <td className="px-3 text-right tabular-nums text-xs">{l.duracao_ms ?? "—"}</td>
                    <td className="px-3 text-xs muted">{dt(l.created_at)}</td>
                  </tr>))}</tbody>
              </table>
            )}
          </div>

          <div className="card p-0 overflow-x-auto">
            <div className="px-4 pt-3 font-semibold text-sm">Prepostagem automática <span className="badge badge-neutral ml-1">{autoLogs.length}</span></div>
            {autoLogs.length === 0 ? <p className="text-sm muted p-4">Nenhum log. Registra cada etapa da geração automática de prepostagem por venda.</p> : (
              <table className="w-full text-sm mt-2">
                <thead><tr className={th} style={bstyle}>
                  <th className="py-2 px-4">Plataforma</th><th className="px-3">Plano</th><th className="px-3">Etapa</th><th className="px-3">Status</th><th className="px-3">Objeto</th><th className="px-3">Mensagem</th><th className="px-3">Data</th></tr></thead>
                <tbody>{autoLogs.map((l) => (
                  <tr key={l.id} className="border-b last:border-0" style={bstyle}>
                    <td className="py-2 px-4 text-xs">{l.plataforma ?? "—"}</td>
                    <td className="px-3 text-xs">{l.plano_codigo ?? "—"}</td>
                    <td className="px-3 text-xs">{l.etapa ?? "—"}</td>
                    <td className="px-3"><span className={`badge ${stBadge(l.status)}`}>{l.status ?? "—"}</span></td>
                    <td className="px-3 font-mono text-[11px]">{l.codigo_objeto ?? "—"}</td>
                    <td className="px-3 text-xs muted">{String(l.mensagem ?? "").slice(0, 44)}</td>
                    <td className="px-3 text-xs muted">{dt(l.created_at)}</td>
                  </tr>))}</tbody>
              </table>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
