"use client";
import { useMemo, useState } from "react";
import { KpiCard } from "@/components/ui/KpiCard";

const TABS = ["Painel", "Envios", "Rastreamento", "Destinatários", "Carteiro Ausente", "Reenvios", "Cobranças de Reenvio"] as const;
const dt = (s: any) => s ? new Date(s).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit" }) : "—";
const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const stBadge = (s: string) => {
  const x = String(s ?? "").toLowerCase();
  if (x.includes("erro") || x.includes("falha") || x.includes("cancel") || x.includes("devolv")) return "badge-danger";
  if (x.includes("entregue") || x.includes("pago") || x.includes("enviado") || x.includes("conclu")) return "badge-success";
  if (x.includes("postado") || x.includes("transito") || x.includes("trânsito") || x.includes("encaminh")) return "badge-neutral";
  return "badge-warning";
};

export default function EnviosRastreamentoWorkbench({ envios, trackingEvents, clientes, notificacoes, reenvios, reenvioPagamentos, produtores }: {
  envios: any[]; trackingEvents: any[]; clientes: any[]; notificacoes: any[]; reenvios: any[]; reenvioPagamentos: any[]; produtores: any[];
}) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");

  const produtorNome = useMemo(() => {
    const m = new Map<string, string>();
    produtores.forEach((p) => m.set(p.id, p.nome));
    return (id: any) => (id ? (m.get(id) ?? "—") : "—");
  }, [produtores]);

  const entregues = envios.filter((e) => String(e.ultimo_status ?? "").toLowerCase().includes("entregue")).length;
  const notifErro = notificacoes.filter((n) => n.erro || String(n.status ?? "").toLowerCase().includes("erro")).length;
  const reenviosPendentes = reenvios.filter((r) => String(r.status ?? "").toLowerCase() === "pendente").length;
  const cobrancasPagas = reenvioPagamentos.filter((p) => String(p.status ?? "").toLowerCase() === "pago").reduce((s, p) => s + Number(p.preco_total ?? 0), 0);

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">📦</div>
        <div>
          <h1 className="text-xl font-bold">Envios &amp; Rastreamento</h1>
          <p className="text-sm muted">Remessas postadas e último status, eventos de rastreio (SRO/webhook), destinatários, avisos de carteiro ausente, reenvios e cobranças de reenvio.</p>
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
            <KpiCard label="Envios" value={envios.length} icon="📦" accent />
            <KpiCard label="Entregues" value={entregues} icon="✅" tone="success" />
            <KpiCard label="Eventos de rastreio" value={trackingEvents.length} icon="📍" />
            <KpiCard label="Destinatários" value={clientes.length} icon="👤" />
            <KpiCard label="Avisos carteiro ausente" value={notificacoes.length} icon="📨" tone={notifErro ? "warning" : "neutral"} hint={notifErro ? `${notifErro} com erro` : undefined} />
            <KpiCard label="Reenvios" value={reenvios.length} icon="🔁" tone={reenviosPendentes ? "warning" : "neutral"} hint={reenviosPendentes ? `${reenviosPendentes} pendentes` : undefined} />
            <KpiCard label="Cobranças de reenvio" value={reenvioPagamentos.length} icon="💳" />
            <KpiCard label="Reenvios pagos" value={money(cobrancasPagas)} icon="💰" tone="brand" />
          </div>
          <div className="card p-4 text-sm muted">
            <b>Como funciona:</b> os <b>envios</b> consolidam cada remessa postada com o último status. Os <b>eventos de rastreio</b> chegam por webhook/SRO dos Correios e alimentam a timeline. Quando o carteiro não encontra o cliente, geramos um <b>aviso de carteiro ausente</b> (WhatsApp/SMS). Se um objeto se perde ou é devolvido, abre-se um <b>reenvio</b>, que pode gerar uma <b>cobrança</b> (link Asaas) para o comprador.
          </div>
        </div>
      )}

      {tab === "Envios" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Envios <span className="badge badge-neutral ml-1">{envios.length}</span></div>
          {envios.length === 0 ? <p className="text-sm muted p-4">Nenhum envio ainda. As remessas são importadas dos PDFs/planilhas de postagem e consolidadas com o último status de rastreio.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Rastreio</th><th className="px-3">Destinatário</th><th className="px-3">CEP/UF</th><th className="px-3">Formato</th><th className="px-3 text-right">Peso</th><th className="px-3 text-right">Pago</th><th className="px-3">Último status</th><th className="px-3">Atualizado</th></tr></thead>
              <tbody>{envios.map((e) => (
                <tr key={e.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-mono text-xs">{e.codigo_rastreio ?? e.codigo_interno ?? "—"}</td>
                  <td className="px-3">{e.nome ?? "—"}</td>
                  <td className="px-3 text-xs">{e.cep ?? "—"}/{e.uf ?? ""}</td>
                  <td className="px-3 text-xs">{e.formato ?? "—"}</td>
                  <td className="px-3 text-right tabular-nums">{e.peso ?? "—"}</td>
                  <td className="px-3 text-right tabular-nums">{money(e.valor_pago)}</td>
                  <td className="px-3"><span className={`badge ${stBadge(e.ultimo_status)}`}>{e.ultimo_status ?? "—"}</span>{e.ultimo_status_local && <span className="block text-[11px] muted mt-0.5">{e.ultimo_status_local}</span>}</td>
                  <td className="px-3 text-xs muted">{dt(e.ultimo_status_data ?? e.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Rastreamento" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Eventos de rastreamento <span className="badge badge-neutral ml-1">{trackingEvents.length}</span></div>
          {trackingEvents.length === 0 ? <p className="text-sm muted p-4">Nenhum evento. Os eventos chegam por webhook/SRO dos Correios e formam a timeline de cada objeto.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Rastreio</th><th className="px-3">Status</th><th className="px-3">Descrição</th><th className="px-3">Local</th><th className="px-3">Produtor</th><th className="px-3">Origem</th><th className="px-3">Evento</th></tr></thead>
              <tbody>{trackingEvents.map((t) => (
                <tr key={t.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-mono text-xs">{t.codigo_rastreio ?? "—"}</td>
                  <td className="px-3"><span className={`badge ${stBadge(t.status)}`}>{t.status ?? "—"}</span></td>
                  <td className="px-3 text-xs">{String(t.descricao_evento ?? "—").slice(0, 48)}</td>
                  <td className="px-3 text-xs">{t.local_evento || [t.cidade_evento, t.uf_evento].filter(Boolean).join("/") || "—"}</td>
                  <td className="px-3 text-xs">{produtorNome(t.produtor_id)}</td>
                  <td className="px-3 text-xs muted">{t.origem ?? "—"}</td>
                  <td className="px-3 text-xs muted">{dt(t.data_evento ?? t.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Destinatários" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Destinatários (clientes de envio) <span className="badge badge-neutral ml-1">{clientes.length}</span></div>
          {clientes.length === 0 ? <p className="text-sm muted p-4">Nenhum destinatário. São importados das planilhas/CSV de envio e associados ao código de rastreio.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Nome</th><th className="px-3">CPF</th><th className="px-3">Rastreio</th><th className="px-3">CEP</th><th className="px-3">Plano</th><th className="px-3">Telefone</th><th className="px-3">Importado</th></tr></thead>
              <tbody>{clientes.map((c) => (
                <tr key={c.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-medium">{c.nome ?? "—"}</td>
                  <td className="px-3 text-xs">{c.cpf ?? "—"}</td>
                  <td className="px-3 font-mono text-xs">{c.codigo_rastreio ?? "—"}</td>
                  <td className="px-3 text-xs">{c.cep ?? "—"}</td>
                  <td className="px-3 text-xs">{c.nome_plano ?? "—"}</td>
                  <td className="px-3 text-xs">{c.telefone ?? "—"}</td>
                  <td className="px-3 text-xs muted">{dt(c.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Carteiro Ausente" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Avisos de carteiro ausente <span className="badge badge-neutral ml-1">{notificacoes.length}</span></div>
          {notificacoes.length === 0 ? <p className="text-sm muted p-4">Nenhum aviso. Quando o objeto registra tentativa/carteiro ausente, o sistema notifica o destinatário (WhatsApp/SMS) para reagendar a entrega.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Objeto</th><th className="px-3">Nome</th><th className="px-3">Telefone</th><th className="px-3">Evento</th><th className="px-3">Local</th><th className="px-3">Status</th><th className="px-3">Data</th></tr></thead>
              <tbody>{notificacoes.map((n) => (
                <tr key={n.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-mono text-xs">{n.codigo_objeto ?? "—"}</td>
                  <td className="px-3">{n.nome ?? "—"}</td>
                  <td className="px-3 text-xs">{n.telefone ?? "—"}</td>
                  <td className="px-3 text-xs">{String(n.evento_descricao ?? "—").slice(0, 40)}</td>
                  <td className="px-3 text-xs">{n.evento_local ?? "—"}</td>
                  <td className="px-3"><span className={`badge ${stBadge(n.status)}`}>{n.status ?? "—"}</span>{n.erro && <span className="block text-[11px] text-red-500 mt-0.5">{String(n.erro).slice(0, 50)}</span>}</td>
                  <td className="px-3 text-xs muted">{dt(n.evento_data ?? n.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Reenvios" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Reenvios <span className="badge badge-neutral ml-1">{reenvios.length}</span></div>
          {reenvios.length === 0 ? <p className="text-sm muted p-4">Nenhum reenvio. Um reenvio gera um novo objeto para uma venda cujo pacote se perdeu ou foi devolvido.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Comprador</th><th className="px-3">Produto</th><th className="px-3">Destino</th><th className="px-3">Obj. original</th><th className="px-3">Obj. novo</th><th className="px-3">Motivo</th><th className="px-3">Produtor</th><th className="px-3">Status</th><th className="px-3">Criado</th></tr></thead>
              <tbody>{reenvios.map((r) => (
                <tr key={r.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-medium">{r.comprador_nome ?? "—"}</td>
                  <td className="px-3 text-xs">{r.produto_nome ?? "—"}</td>
                  <td className="px-3 text-xs">{[r.destino_cidade, r.destino_uf].filter(Boolean).join("/") || "—"}</td>
                  <td className="px-3 font-mono text-[11px]">{r.codigo_objeto_original ?? "—"}</td>
                  <td className="px-3 font-mono text-[11px]">{r.codigo_objeto_novo ?? "—"}</td>
                  <td className="px-3 text-xs muted">{String(r.motivo ?? "—").slice(0, 32)}</td>
                  <td className="px-3 text-xs">{produtorNome(r.produtor_id)}</td>
                  <td className="px-3"><span className={`badge ${stBadge(r.status)}`}>{r.status ?? "—"}</span></td>
                  <td className="px-3 text-xs muted">{dt(r.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Cobranças de Reenvio" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Cobranças de reenvio (Asaas) <span className="badge badge-neutral ml-1">{reenvioPagamentos.length}</span></div>
          {reenvioPagamentos.length === 0 ? <p className="text-sm muted p-4">Nenhuma cobrança. Quando o reenvio é pago pelo comprador, geramos um link Asaas e acompanhamos o status do pagamento.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Comprador</th><th className="px-3">E-mail</th><th className="px-3">Produtor</th><th className="px-3 text-right">Qtd</th><th className="px-3 text-right">Valor</th><th className="px-3">E-mail enviado</th><th className="px-3">Status</th><th className="px-3">Criado</th></tr></thead>
              <tbody>{reenvioPagamentos.map((p) => (
                <tr key={p.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-medium">{p.comprador_nome ?? "—"}</td>
                  <td className="px-3 text-xs">{p.comprador_email ?? "—"}</td>
                  <td className="px-3 text-xs">{produtorNome(p.produtor_id)}</td>
                  <td className="px-3 text-right tabular-nums">{p.quantidade ?? 0}</td>
                  <td className="px-3 text-right tabular-nums font-semibold">{money(p.preco_total)}</td>
                  <td className="px-3">{p.email_enviado ? <span className="badge badge-success">enviado</span> : <span className="badge badge-neutral">não</span>}</td>
                  <td className="px-3"><span className={`badge ${stBadge(p.status)}`}>{p.status ?? "—"}</span></td>
                  <td className="px-3 text-xs muted">{dt(p.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}
    </div>
  );
}
