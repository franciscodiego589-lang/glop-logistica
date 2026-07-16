"use client";
import { useState } from "react";
import { KpiCard } from "@/components/ui/KpiCard";

const TABS = ["Painel", "Prepostagens", "Rastreio (PPN)", "Conferência", "Correções de CEP", "Logs Automáticos"] as const;
const dt = (s: any) => s ? new Date(s).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit" }) : "—";
const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const stBadge = (s: string) => {
  const x = String(s ?? "").toLowerCase();
  if (x.includes("erro") || x.includes("falha")) return "badge-danger";
  if (x.includes("entregue")) return "badge-success";
  if (x.includes("postado") || x.includes("transito") || x.includes("trânsito")) return "badge-neutral";
  return "badge-warning";
};

export default function PrepostagemWorkbench({ prepostagens, ppn, conferencias, cepLogs, autoLogs }: {
  prepostagens: any[]; ppn: any[]; conferencias: any[]; cepLogs: any[]; autoLogs: any[];
}) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");

  const comObjeto = prepostagens.filter((p) => p.codigo_objeto).length;
  const comErro = prepostagens.filter((p) => p.erro || String(p.status ?? "").toLowerCase().includes("erro")).length;
  const cepCorrigidos = cepLogs.filter((c) => c.cep_corrigido && c.cep_corrigido !== c.cep_original).length;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">📮</div>
        <div>
          <h1 className="text-xl font-bold">Prepostagem Correios</h1>
          <p className="text-sm muted">Pré-postagens (PPN), rastreio dos objetos, conferência de postagem e correções de CEP.</p>
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
          <KpiCard label="Prepostagens" value={prepostagens.length} icon="📮" accent />
          <KpiCard label="Com código de objeto" value={comObjeto} icon="🏷" tone="success" />
          <KpiCard label="Com erro" value={comErro} icon="⚠" tone={comErro ? "danger" : "neutral"} />
          <KpiCard label="Objetos (PPN)" value={ppn.length} icon="📦" />
          <KpiCard label="Conferências" value={conferencias.length} icon="✅" />
          <KpiCard label="Correções de CEP" value={cepCorrigidos} icon="📍" tone={cepCorrigidos ? "warning" : "neutral"} />
          <KpiCard label="Logs automáticos" value={autoLogs.length} icon="🤖" />
        </div>
      )}

      {tab === "Prepostagens" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Prepostagens <span className="badge badge-neutral ml-1">{prepostagens.length}</span></div>
          {prepostagens.length === 0 ? <p className="text-sm muted p-4">Nenhuma prepostagem ainda. Elas são geradas no fluxo de despacho (Monetizze → Correios).</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Objeto</th><th className="px-3">Destinatário</th><th className="px-3">Cidade/UF</th><th className="px-3">Serviço</th><th className="px-3 text-right">Peso(g)</th><th className="px-3">Status</th><th className="px-3">Criado</th></tr></thead>
              <tbody>{prepostagens.map((p) => (
                <tr key={p.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
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

      {tab === "Rastreio (PPN)" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Objetos PPN — rastreio <span className="badge badge-neutral ml-1">{ppn.length}</span></div>
          {ppn.length === 0 ? <p className="text-sm muted p-4">Nenhum objeto PPN. Sincroniza os objetos de pré-postagem nacional dos Correios com o status/rastreio (SRO).</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Objeto</th><th className="px-3">Destinatário</th><th className="px-3">Serviço</th><th className="px-3">Último status</th><th className="px-3">Local</th><th className="px-3">Postado</th><th className="px-3">Sincron.</th></tr></thead>
              <tbody>{ppn.map((p) => (
                <tr key={p.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-mono text-xs">{p.codigo_objeto ?? "—"}</td>
                  <td className="px-3">{p.destinatario_nome ?? "—"}</td>
                  <td className="px-3 text-xs">{p.servico_nome ?? "—"}</td>
                  <td className="px-3"><span className={`badge ${stBadge(p.ultimo_status ?? p.status)}`}>{p.ultimo_status ?? p.status ?? "—"}</span></td>
                  <td className="px-3 text-xs">{p.ultimo_status_local ?? "—"}</td>
                  <td className="px-3 text-xs muted">{dt(p.data_postagem)}</td>
                  <td className="px-3 text-xs muted">{dt(p.ultima_sincronizacao)}</td>
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
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Planilha</th><th className="px-3 text-right">Total</th><th className="px-3 text-right">Postados</th><th className="px-3 text-right">Não encontrados</th><th className="px-3 text-right">Possíveis</th><th className="px-3">Data</th></tr></thead>
              <tbody>{conferencias.map((c) => (
                <tr key={c.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
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
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">CEP original</th><th className="px-3">CEP corrigido</th><th className="px-3">Fonte</th><th className="px-3">SISLOG</th><th className="px-3">Observação</th><th className="px-3">Data</th></tr></thead>
              <tbody>{cepLogs.map((c) => (
                <tr key={c.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-mono text-xs">{c.cep_original ?? "—"}</td>
                  <td className="px-3 font-mono text-xs font-semibold">{c.cep_corrigido ?? "—"}</td>
                  <td className="px-3 text-xs">{c.fonte ?? "—"}</td>
                  <td className="px-3">{c.enviado_sislog ? <span className="badge badge-success">enviado</span> : <span className="badge badge-neutral">não</span>}</td>
                  <td className="px-3 text-xs muted">{String(c.observacao ?? "").slice(0, 40)}</td>
                  <td className="px-3 text-xs muted">{dt(c.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Logs Automáticos" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Logs de prepostagem automática <span className="badge badge-neutral ml-1">{autoLogs.length}</span></div>
          {autoLogs.length === 0 ? <p className="text-sm muted p-4">Nenhum log. Registra cada etapa da geração automática de prepostagem por venda (plataforma, plano, etapa, status).</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Plataforma</th><th className="px-3">Plano</th><th className="px-3">Etapa</th><th className="px-3">Status</th><th className="px-3">Objeto</th><th className="px-3">Mensagem</th><th className="px-3">Data</th></tr></thead>
              <tbody>{autoLogs.map((l) => (
                <tr key={l.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
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
      )}
    </div>
  );
}
