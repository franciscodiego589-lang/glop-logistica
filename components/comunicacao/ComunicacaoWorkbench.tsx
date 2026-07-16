"use client";
import { useState } from "react";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const TABS = ["Painel", "E-mails enviados", "WhatsApp enviados", "Template E-mail", "Template WhatsApp", "Template Carteiro"] as const;
const dt = (s: any) => s ? new Date(s).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit" }) : "—";
const stBadge = (s: string) => {
  const x = String(s ?? "").toLowerCase();
  if (x.includes("erro") || x.includes("fail") || x.includes("falha")) return "badge-danger";
  if (x.includes("enviado") || x.includes("sent") || x.includes("deliver")) return "badge-success";
  if (x.includes("queued") || x.includes("fila") || x.includes("pendente") || x.includes("pending")) return "badge-warning";
  return "badge-neutral";
};

export default function ComunicacaoWorkbench({ emailLogs, whatsappLogs, emailTemplate, whatsappTemplate, carteiroTemplate }: {
  emailLogs: any[]; whatsappLogs: any[]; emailTemplate: any; whatsappTemplate: any; carteiroTemplate: any;
}) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");

  const isErr = (s: any) => String(s ?? "").toLowerCase().match(/erro|fail|falha/);
  const isOk = (s: any) => String(s ?? "").toLowerCase().match(/enviado|sent|deliver/);
  const emailErros = emailLogs.filter((e) => e.erro || isErr(e.status)).length;
  const emailOk = emailLogs.filter((e) => isOk(e.status)).length;
  const waErros = whatsappLogs.filter((w) => w.erro || isErr(w.status)).length;
  const waOk = whatsappLogs.filter((w) => w.enviado_at || isOk(w.status)).length;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">📣</div>
        <div>
          <h1 className="text-xl font-bold">Comunicação (Email/WhatsApp)</h1>
          <p className="text-sm muted">Logs de envio de e-mail (SendGrid) e WhatsApp de rastreio, mais os templates editáveis de mensagem.</p>
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
            <KpiCard label="E-mails enviados" value={emailLogs.length} icon="✉" accent />
            <KpiCard label="E-mails OK" value={emailOk} icon="✅" tone="success" />
            <KpiCard label="E-mails com erro" value={emailErros} icon="⚠" tone={emailErros ? "danger" : "neutral"} />
            <KpiCard label="WhatsApp enviados" value={whatsappLogs.length} icon="💬" tone="brand" />
            <KpiCard label="WhatsApp OK" value={waOk} icon="✅" tone="success" />
            <KpiCard label="WhatsApp com erro" value={waErros} icon="⚠" tone={waErros ? "danger" : "neutral"} />
            <KpiCard label="Template E-mail" value={emailTemplate ? "Config." : "Padrão"} icon="📝" tone={emailTemplate ? "success" : "neutral"} />
            <KpiCard label="Template WhatsApp" value={whatsappTemplate ? "Config." : "Padrão"} icon="📝" tone={whatsappTemplate ? "success" : "neutral"} />
          </div>
          <div className="card p-4 text-sm muted">
            <b>Como funciona:</b> quando um pedido é postado, o sistema dispara o <b>e-mail de rastreio</b> (SendGrid) e a <b>mensagem de WhatsApp</b> ao comprador, registrando cada envio nos logs (com status e erros). Os <b>templates</b> são editáveis com variáveis: <code>{"{{codigo}}"}</code>, <code>{"{{nome}}"}</code>, <code>{"{{link_rastreio}}"}</code> no e-mail e <code>{"{nome}"}</code>, <code>{"{plano}"}</code>, <code>{"{codigo_rastreio}"}</code> no WhatsApp.
          </div>
        </div>
      )}

      {tab === "E-mails enviados" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Log de e-mails (SendGrid) <span className="badge badge-neutral ml-1">{emailLogs.length}</span></div>
          {emailLogs.length === 0 ? <p className="text-sm muted p-4">Nenhum e-mail enviado ainda. Os e-mails de rastreio são disparados automaticamente ao postar o pedido.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Destinatário</th><th className="px-3">Rastreio</th><th className="px-3">Assunto</th><th className="px-3">Status</th><th className="px-3">Mensagem SendGrid</th><th className="px-3">Enviado</th></tr></thead>
              <tbody>{emailLogs.map((e) => (
                <tr key={e.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4"><div className="font-medium">{e.nome ?? "—"}</div><div className="text-[11px] muted">{e.email ?? "—"}</div></td>
                  <td className="px-3 font-mono text-xs">{e.codigo_rastreio ?? "—"}</td>
                  <td className="px-3 text-xs">{String(e.assunto ?? "—").slice(0, 40)}</td>
                  <td className="px-3"><span className={`badge ${stBadge(e.status)}`}>{e.status ?? "—"}</span>{e.erro && <span className="block text-[11px] text-red-500 mt-0.5">{String(e.erro).slice(0, 60)}</span>}</td>
                  <td className="px-3 font-mono text-[11px] muted">{String(e.sendgrid_message_id ?? "—").slice(0, 20)}</td>
                  <td className="px-3 text-xs muted">{dt(e.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "WhatsApp enviados" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Log de WhatsApp <span className="badge badge-neutral ml-1">{whatsappLogs.length}</span></div>
          {whatsappLogs.length === 0 ? <p className="text-sm muted p-4">Nenhuma mensagem enviada ainda. As mensagens de rastreio por WhatsApp são registradas aqui com seu status.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Destinatário</th><th className="px-3">Telefone</th><th className="px-3">Mensagem</th><th className="px-3">Status</th><th className="px-3">Enviado em</th><th className="px-3">Registrado</th></tr></thead>
              <tbody>{whatsappLogs.map((w) => (
                <tr key={w.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-medium">{w.nome ?? "—"}</td>
                  <td className="px-3 font-mono text-xs">{w.telefone ?? "—"}</td>
                  <td className="px-3 text-xs muted">{String(w.mensagem ?? "—").slice(0, 44)}</td>
                  <td className="px-3"><span className={`badge ${stBadge(w.status)}`}>{w.status ?? "—"}</span>{w.erro && <span className="block text-[11px] text-red-500 mt-0.5">{String(w.erro).slice(0, 60)}</span>}</td>
                  <td className="px-3 text-xs muted">{dt(w.enviado_at)}</td>
                  <td className="px-3 text-xs muted">{dt(w.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Template E-mail" && (
        <div className="space-y-3">
          <div className="card p-3 text-xs muted">📝 Template do e-mail de rastreio (SendGrid). Único por empresa. Variáveis: <code>{"{{codigo}}"}</code>, <code>{"{{nome}}"}</code>, <code>{"{{link_rastreio}}"}</code>.</div>
          <CrudPanel table="email_template_rastreio" title="Template de e-mail de rastreio" rows={emailTemplate ? [emailTemplate] : []}
            emptyHint="Crie o template do e-mail de rastreio (só um por empresa)."
            fields={[
              { key: "assunto", label: "Assunto", required: true, default: "Seu código de rastreio - Pedido {{codigo}}" },
              { key: "html", label: "HTML do e-mail", required: true },
            ]}
            columns={[
              { key: "assunto", label: "Assunto" },
              { key: "html", label: "HTML", fmt: (v) => String(v ?? "").replace(/<[^>]+>/g, " ").slice(0, 60) + "…" },
              { key: "updated_at", label: "Atualizado", fmt: (v) => dt(v) },
            ]} />
        </div>
      )}

      {tab === "Template WhatsApp" && (
        <div className="space-y-3">
          <div className="card p-3 text-xs muted">📝 Mensagem padrão de WhatsApp de rastreio. Única por empresa. Variáveis: <code>{"{nome}"}</code>, <code>{"{plano}"}</code>, <code>{"{codigo_rastreio}"}</code>.</div>
          <CrudPanel table="whatsapp_template" title="Template de WhatsApp (rastreio)" rows={whatsappTemplate ? [whatsappTemplate] : []}
            emptyHint="Crie a mensagem padrão de WhatsApp (só uma por empresa)."
            fields={[
              { key: "mensagem", label: "Mensagem", required: true },
            ]}
            columns={[
              { key: "mensagem", label: "Mensagem", fmt: (v) => String(v ?? "").slice(0, 80) + "…" },
              { key: "updated_at", label: "Atualizado", fmt: (v) => dt(v) },
            ]} />
        </div>
      )}

      {tab === "Template Carteiro" && (
        <div className="space-y-3">
          <div className="card p-3 text-xs muted">📮 Mensagem "carteiro" — variação da mensagem de WhatsApp usada no fluxo de entrega. Única por empresa.</div>
          <CrudPanel table="whatsapp_template_carteiro" title="Template de WhatsApp (carteiro)" rows={carteiroTemplate ? [carteiroTemplate] : []}
            emptyHint="Crie a mensagem do carteiro (só uma por empresa)."
            fields={[
              { key: "mensagem", label: "Mensagem", required: true },
            ]}
            columns={[
              { key: "mensagem", label: "Mensagem", fmt: (v) => String(v ?? "").slice(0, 80) + "…" },
              { key: "updated_at", label: "Atualizado", fmt: (v) => dt(v) },
            ]} />
        </div>
      )}
    </div>
  );
}
