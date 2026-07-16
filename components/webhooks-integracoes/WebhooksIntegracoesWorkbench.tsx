"use client";
import { useState } from "react";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const TABS = ["Painel", "Webhooks (Saída)", "Entregas", "Envios SisLógica", "Recebidos SisLógica", "Tokens SisLógica", "Logs de API", "Logs de Webhook"] as const;
const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const dt = (s: any) => s ? new Date(s).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit" }) : "—";
const httpBadge = (n: any) => {
  const x = Number(n);
  if (!x) return "badge-neutral";
  if (x >= 500) return "badge-danger";
  if (x >= 400) return "badge-warning";
  if (x >= 200 && x < 300) return "badge-success";
  return "badge-neutral";
};
const stBadge = (s: any) => {
  const x = String(s ?? "").toLowerCase();
  if (x.includes("erro") || x.includes("falha") || x.includes("recus") || x.includes("reject") || x.includes("invalid")) return "badge-danger";
  if (x.includes("ok") || x.includes("sucesso") || x.includes("success") || x.includes("aceito") || x.includes("processado")) return "badge-success";
  if (x.includes("pend") || x.includes("aguard") || x.includes("retry")) return "badge-warning";
  return "badge-neutral";
};

export default function WebhooksIntegracoesWorkbench({ webhooks, entregas, envios, recebidos, tokens, apiLogs, webhookLogs }: {
  webhooks: any[]; entregas: any[]; envios: any[]; recebidos: any[]; tokens: any[]; apiLogs: any[]; webhookLogs: any[];
}) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");

  const webhooksAtivos = webhooks.filter((w) => w.ativo).length;
  const entregasErro = entregas.filter((e) => e.erro || Number(e.status_http) >= 400).length;
  const enviosErro = envios.filter((e) => e.erro || Number(e.http_status) >= 400 || String(e.status ?? "").toLowerCase().includes("erro")).length;
  const recebidosPendentes = recebidos.filter((r) => !r.processado).length;
  const tokensAtivos = tokens.filter((t) => !t.revogado).length;
  const apiErros = apiLogs.filter((a) => Number(a.http_status) >= 400 || String(a.status ?? "").toLowerCase().includes("erro")).length;
  const webhookRecusados = webhookLogs.filter((w) => stBadge(w.status) === "badge-danger").length;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🔗</div>
        <div>
          <h1 className="text-xl font-bold">Webhooks &amp; Integrações</h1>
          <p className="text-sm muted">Webhooks de saída do produtor e suas entregas, logs SisLógica (envios/recebidos/tokens) e logs de API e de webhook das plataformas.</p>
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
            <KpiCard label="Webhooks configurados" value={webhooks.length} icon="🔗" accent hint={`${webhooksAtivos} ativos`} />
            <KpiCard label="Entregas de webhook" value={entregas.length} icon="📤" />
            <KpiCard label="Entregas com erro" value={entregasErro} icon="⚠" tone={entregasErro ? "danger" : "neutral"} />
            <KpiCard label="Envios SisLógica" value={envios.length} icon="🚚" />
            <KpiCard label="Envios com erro" value={enviosErro} icon="❌" tone={enviosErro ? "danger" : "neutral"} />
            <KpiCard label="Recebidos SisLógica" value={recebidos.length} icon="📥" hint={`${recebidosPendentes} não processados`} tone={recebidosPendentes ? "warning" : "neutral"} />
            <KpiCard label="Tokens SisLógica" value={tokens.length} icon="🔑" hint={`${tokensAtivos} ativos`} tone={tokensAtivos ? "success" : "neutral"} />
            <KpiCard label="Logs de API" value={apiLogs.length} icon="🧾" hint={`${apiErros} com erro`} tone={apiErros ? "warning" : "neutral"} />
            <KpiCard label="Logs de webhook" value={webhookLogs.length} icon="📡" hint={`${webhookRecusados} recusados`} tone={webhookRecusados ? "warning" : "neutral"} />
          </div>
          <div className="card p-4 text-sm muted">
            <b>Como funciona:</b> as plataformas de venda batem nos <b>webhooks recebidos</b> (registrados em <i>Logs de Webhook</i>), autenticados por <b>token</b>. O sistema chama as integrações (SisLógica, Correios, etc.) — cada chamada vira um <b>envio</b> ou <b>log de API</b>. E o produtor pode configurar <b>webhooks de saída</b> para ser notificado dos eventos; cada disparo vira uma <b>entrega</b> com status HTTP e tempo de resposta.
          </div>
        </div>
      )}

      {tab === "Webhooks (Saída)" && (
        <div className="space-y-3">
          <div className="card p-3 text-xs muted">🔗 Webhooks de saída configurados pelo produtor: quando um evento acontece (ex.: <code>venda.criada</code>), o GLOP dispara um POST para a URL cadastrada.</div>
          <CrudPanel table="produtor_webhooks" title="Webhooks de saída" rows={webhooks}
            emptyHint="Cadastre uma URL de destino para receber notificações de eventos."
            fields={[
              { key: "nome", label: "Nome", required: true },
              { key: "url", label: "URL de destino", required: true, placeholder: "https://..." },
              { key: "produtor_id", label: "Produtor", type: "fk", fkTable: "produtores_integracao", fkLabel: "nome" },
              { key: "user_id", label: "User ID (auth)", required: true, placeholder: "uuid do usuário" },
            ]}
            columns={[
              { key: "nome", label: "Nome" },
              { key: "url", label: "URL" },
              { key: "produtor_id", label: "Produtor" },
              { key: "eventos", label: "Eventos", fmt: (v) => Array.isArray(v) ? v.join(", ") : (v ?? "—") },
              { key: "ativo", label: "Ativo", fmt: (v) => (v ? "sim" : "não") },
            ]} />
        </div>
      )}

      {tab === "Entregas" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Entregas de webhook (disparos) <span className="badge badge-neutral ml-1">{entregas.length}</span></div>
          {entregas.length === 0 ? <p className="text-sm muted p-4">Nenhuma entrega ainda. Cada disparo de um webhook de saída registra aqui o evento, o status HTTP de resposta e o tempo.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Evento</th><th className="px-3">HTTP</th><th className="px-3 text-right">Duração</th><th className="px-3">Resposta</th><th className="px-3">Erro</th><th className="px-3">Data</th></tr></thead>
              <tbody>{entregas.map((e) => (
                <tr key={e.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 text-xs font-medium">{e.evento ?? "—"}</td>
                  <td className="px-3"><span className={`badge ${httpBadge(e.status_http)}`}>{e.status_http ?? "—"}</span></td>
                  <td className="px-3 text-right tabular-nums text-xs">{e.duracao_ms != null ? `${e.duracao_ms} ms` : "—"}</td>
                  <td className="px-3 text-xs muted">{String(e.resposta ?? "").slice(0, 40) || "—"}</td>
                  <td className="px-3 text-xs" style={{ color: e.erro ? "var(--danger)" : undefined }}>{String(e.erro ?? "").slice(0, 40) || "—"}</td>
                  <td className="px-3 text-xs muted">{dt(e.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Envios SisLógica" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Envios à SisLógica <span className="badge badge-neutral ml-1">{envios.length}</span></div>
          {envios.length === 0 ? <p className="text-sm muted p-4">Nenhum envio. Registra cada solicitação de envio enviada à SisLógica (id da solicitação, rastreio, status e payloads).</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Solicitação</th><th className="px-3">Rastreio</th><th className="px-3">Status</th><th className="px-3">HTTP</th><th className="px-3 text-right">Duração</th><th className="px-3">Erro</th><th className="px-3">Data</th></tr></thead>
              <tbody>{envios.map((e) => (
                <tr key={e.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-mono text-xs">{e.id_solicitacao_gerada ?? e.id_solicitacao_interno ?? "—"}</td>
                  <td className="px-3 font-mono text-xs">{e.codigo_rastreio ?? "—"}</td>
                  <td className="px-3"><span className={`badge ${stBadge(e.status)}`}>{e.status ?? "—"}</span></td>
                  <td className="px-3"><span className={`badge ${httpBadge(e.http_status)}`}>{e.http_status ?? "—"}</span></td>
                  <td className="px-3 text-right tabular-nums text-xs">{e.duracao_ms != null ? `${e.duracao_ms} ms` : "—"}</td>
                  <td className="px-3 text-xs" style={{ color: e.erro ? "var(--danger)" : undefined }}>{String(e.erro ?? "").slice(0, 40) || "—"}</td>
                  <td className="px-3 text-xs muted">{dt(e.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Recebidos SisLógica" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Webhooks recebidos da SisLógica <span className="badge badge-neutral ml-1">{recebidos.length}</span></div>
          {recebidos.length === 0 ? <p className="text-sm muted p-4">Nenhum webhook recebido. São os avisos de status que a SisLógica envia de volta (por solicitação/rastreio).</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Solicitação</th><th className="px-3">Interno</th><th className="px-3">Rastreio</th><th className="px-3">Status recebido</th><th className="px-3">Processado</th><th className="px-3">Data</th></tr></thead>
              <tbody>{recebidos.map((r) => (
                <tr key={r.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-mono text-xs">{r.id_solicitacao ?? "—"}</td>
                  <td className="px-3 font-mono text-xs">{r.id_solicitacao_interno ?? "—"}</td>
                  <td className="px-3 font-mono text-xs">{r.codigo_rastreio ?? "—"}</td>
                  <td className="px-3"><span className={`badge ${stBadge(r.status_recebido)}`}>{r.status_recebido ?? "—"}</span></td>
                  <td className="px-3">{r.processado ? <span className="badge badge-success">processado</span> : <span className="badge badge-warning">pendente</span>}</td>
                  <td className="px-3 text-xs muted">{dt(r.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Tokens SisLógica" && (
        <div className="space-y-3">
          <div className="card p-3 text-xs muted">🔑 Tokens que autenticam os webhooks recebidos da SisLógica. Revogue um token editando/excluindo o registro para invalidá-lo.</div>
          <CrudPanel table="sislogica_webhook_tokens" title="Tokens de webhook" rows={tokens}
            emptyHint="Gere um token para autenticar os webhooks recebidos da SisLógica."
            fields={[
              { key: "token", label: "Token (definido só na criação, nunca exibido)", required: true },
              { key: "descricao", label: "Descrição" },
            ]}
            columns={[
              { key: "descricao", label: "Descrição" },
              { key: "id", label: "Token", fmt: () => "•••••• (oculto)" },
              { key: "revogado", label: "Revogado", fmt: (v) => (v ? "sim" : "não") },
              { key: "ultimo_uso_em", label: "Último uso", fmt: (v) => dt(v) },
              { key: "created_at", label: "Criado", fmt: (v) => dt(v) },
            ]} />
        </div>
      )}

      {tab === "Logs de API" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Logs de chamadas de API <span className="badge badge-neutral ml-1">{apiLogs.length}</span></div>
          {apiLogs.length === 0 ? <p className="text-sm muted p-4">Nenhum log. Registro genérico das chamadas de integração feitas pelo sistema (tipo, ação, status HTTP e payloads).</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Tipo</th><th className="px-3">Ação</th><th className="px-3">Status</th><th className="px-3">HTTP</th><th className="px-3">Referência</th><th className="px-3">Mensagem</th><th className="px-3">Data</th></tr></thead>
              <tbody>{apiLogs.map((a) => (
                <tr key={a.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 text-xs font-medium">{a.tipo ?? "—"}</td>
                  <td className="px-3 text-xs">{a.acao ?? "—"}</td>
                  <td className="px-3"><span className={`badge ${stBadge(a.status)}`}>{a.status ?? "—"}</span></td>
                  <td className="px-3"><span className={`badge ${httpBadge(a.http_status)}`}>{a.http_status ?? "—"}</span></td>
                  <td className="px-3 font-mono text-[11px]">{a.referencia ?? a.codigo_rastreio ?? "—"}</td>
                  <td className="px-3 text-xs muted">{String(a.mensagem ?? "").slice(0, 44) || "—"}</td>
                  <td className="px-3 text-xs muted">{dt(a.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Logs de Webhook" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Logs de webhooks recebidos <span className="badge badge-neutral ml-1">{webhookLogs.length}</span></div>
          {webhookLogs.length === 0 ? <p className="text-sm muted p-4">Nenhum log. Cada webhook recebido das plataformas de venda registra aqui: status, motivo, comprador, valor e origem.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Status</th><th className="px-3">Motivo</th><th className="px-3">Venda</th><th className="px-3">Comprador</th><th className="px-3 text-right">Valor</th><th className="px-3">Produto/Plano</th><th className="px-3">IP</th><th className="px-3">Data</th></tr></thead>
              <tbody>{webhookLogs.map((w) => (
                <tr key={w.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4"><span className={`badge ${stBadge(w.status)}`}>{w.status ?? "—"}</span></td>
                  <td className="px-3 text-xs muted">{String(w.motivo ?? "").slice(0, 36) || "—"}</td>
                  <td className="px-3 font-mono text-xs">{w.codigo_venda ?? w.venda_id ?? "—"}</td>
                  <td className="px-3 text-xs">{w.comprador_nome ?? "—"}</td>
                  <td className="px-3 text-right tabular-nums">{w.valor != null ? money(w.valor) : "—"}</td>
                  <td className="px-3 text-xs">{w.produto_codigo ?? "—"}{w.plano_codigo ? ` / ${w.plano_codigo}` : ""}</td>
                  <td className="px-3 font-mono text-[11px] muted">{w.ip_origem ?? "—"}</td>
                  <td className="px-3 text-xs muted">{dt(w.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}
    </div>
  );
}
