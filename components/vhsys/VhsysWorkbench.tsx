"use client";
import { useState } from "react";
import { KpiCard } from "@/components/ui/KpiCard";

const TABS = ["Painel", "Saldos de Estoque", "Movimentos", "Locais de Estoque"] as const;
const dt = (s: any) => s ? new Date(s).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit" }) : "—";
const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const qty = (v: any) => Number(v ?? 0).toLocaleString("pt-BR");
const stBadge = (s: string) => {
  const x = String(s ?? "").toLowerCase();
  if (x.includes("erro") || x.includes("falha")) return "badge-danger";
  if (x.includes("ok") || x.includes("sincronizado") || x.includes("sucesso") || x.includes("enviado")) return "badge-success";
  if (x.includes("pendente")) return "badge-warning";
  return "badge-neutral";
};

export default function VhsysWorkbench({ saldos, movimentos, locais }: {
  saldos: any[]; movimentos: any[]; locais: any[];
}) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");

  const abaixoMinimo = saldos.filter((s) => Number(s.saldo_atual ?? 0) <= Number(s.estoque_minimo ?? 0)).length;
  const totalSaldo = saldos.reduce((acc, s) => acc + Number(s.saldo_atual ?? 0), 0);
  const entradas = movimentos.filter((m) => m.tipo === "Entrada").length;
  const saidas = movimentos.filter((m) => m.tipo === "Saida").length;
  const comErro = movimentos.filter((m) => m.erro || String(m.status ?? "").toLowerCase().includes("erro")).length;
  const locaisAtivos = locais.filter((l) => l.ativo).length;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🏬</div>
        <div>
          <h1 className="text-xl font-bold">Integração VHSYS</h1>
          <p className="text-sm muted">Saldos e movimentos de estoque sincronizados com o VHSYS, e os locais de estoque cadastrados.</p>
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
            <KpiCard label="Itens com saldo" value={saldos.length} icon="📦" accent />
            <KpiCard label="Saldo total" value={qty(totalSaldo)} icon="Σ" tone="brand" hint="soma do saldo atual" />
            <KpiCard label="Abaixo do mínimo" value={abaixoMinimo} icon="⚠" tone={abaixoMinimo ? "warning" : "neutral"} />
            <KpiCard label="Movimentos" value={movimentos.length} icon="🔁" />
            <KpiCard label="Entradas" value={entradas} icon="⬇" tone="success" />
            <KpiCard label="Saídas" value={saidas} icon="⬆" tone="neutral" />
            <KpiCard label="Movimentos com erro" value={comErro} icon="🛑" tone={comErro ? "danger" : "neutral"} />
            <KpiCard label="Locais ativos" value={locaisAtivos} icon="🏬" tone="brand" hint={`${locais.length} no total`} />
          </div>
          <div className="card p-4 text-sm muted">
            <b>Como funciona:</b> o VHSYS é a fonte do estoque. Os <b>saldos</b> são consultados/sincronizados por produto ou insumo, os <b>movimentos</b> (Entrada/Saída) são enviados ao VHSYS registrando cada baixa/reposição, e os <b>locais de estoque</b> refletem os depósitos cadastrados no VHSYS.
          </div>
        </div>
      )}

      {tab === "Saldos de Estoque" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Saldos por item <span className="badge badge-neutral ml-1">{saldos.length}</span></div>
          {saldos.length === 0 ? <p className="text-sm muted p-4">Nenhum saldo sincronizado ainda. Os saldos vêm da consulta ao estoque do VHSYS (produtos e insumos).</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Produto</th><th className="px-3">Código</th><th className="px-3">Tipo</th><th className="px-3 text-right">Saldo atual</th><th className="px-3 text-right">Estoque mín.</th><th className="px-3">Situação</th><th className="px-3">Última consulta</th></tr></thead>
              <tbody>{saldos.map((s) => {
                const baixo = Number(s.saldo_atual ?? 0) <= Number(s.estoque_minimo ?? 0);
                return (
                  <tr key={s.produto_vhsys_id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                    <td className="py-2 px-4 font-medium">{s.produto_nome ?? "—"}</td>
                    <td className="px-3 font-mono text-xs">{s.produto_codigo ?? "—"}</td>
                    <td className="px-3 text-xs">{s.tipo_item ?? "—"}</td>
                    <td className="px-3 text-right tabular-nums font-semibold">{qty(s.saldo_atual)}</td>
                    <td className="px-3 text-right tabular-nums">{qty(s.estoque_minimo)}</td>
                    <td className="px-3"><span className={`badge ${baixo ? "badge-warning" : "badge-success"}`}>{baixo ? "abaixo do mín." : "ok"}</span></td>
                    <td className="px-3 text-xs muted">{dt(s.ultima_consulta)}</td>
                  </tr>);
              })}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Movimentos" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Movimentos de estoque <span className="badge badge-neutral ml-1">{movimentos.length}</span></div>
          {movimentos.length === 0 ? <p className="text-sm muted p-4">Nenhum movimento. Cada Entrada/Saída de estoque enviada ao VHSYS é registrada aqui com o retorno da API.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Produto</th><th className="px-3">Tipo</th><th className="px-3 text-right">Qtd</th><th className="px-3 text-right">Vlr unit.</th><th className="px-3">Identificação</th><th className="px-3">Status</th><th className="px-3">Data</th></tr></thead>
              <tbody>{movimentos.map((m) => (
                <tr key={m.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-medium">{m.produto_nome ?? m.produto_vhsys_id ?? "—"}</td>
                  <td className="px-3"><span className={`badge ${m.tipo === "Entrada" ? "badge-success" : "badge-neutral"}`}>{m.tipo ?? "—"}</span></td>
                  <td className="px-3 text-right tabular-nums font-semibold">{qty(m.quantidade)}</td>
                  <td className="px-3 text-right tabular-nums">{m.valor_unitario != null ? money(m.valor_unitario) : "—"}</td>
                  <td className="px-3 text-xs">{m.identificacao ?? "—"}</td>
                  <td className="px-3"><span className={`badge ${stBadge(m.status)}`}>{m.status ?? "—"}</span>{m.erro && <span className="block text-[11px] text-red-500 mt-0.5">{String(m.erro).slice(0, 60)}</span>}</td>
                  <td className="px-3 text-xs muted">{dt(m.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Locais de Estoque" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Locais de estoque <span className="badge badge-neutral ml-1">{locais.length}</span></div>
          {locais.length === 0 ? <p className="text-sm muted p-4">Nenhum local de estoque sincronizado. Os locais refletem os depósitos cadastrados no VHSYS.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Local</th><th className="px-3">ID VHSYS</th><th className="px-3">Situação</th><th className="px-3">Observação</th><th className="px-3">Atualizado</th></tr></thead>
              <tbody>{locais.map((l) => (
                <tr key={l.id_local_estoque} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-medium">{l.nome ?? "—"}</td>
                  <td className="px-3 font-mono text-xs">{l.id_local_estoque ?? "—"}</td>
                  <td className="px-3"><span className={`badge ${l.ativo ? "badge-success" : "badge-neutral"}`}>{l.ativo ? "ativo" : "inativo"}</span></td>
                  <td className="px-3 text-xs muted">{String(l.observacao ?? "").slice(0, 60) || "—"}</td>
                  <td className="px-3 text-xs muted">{dt(l.updated_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}
    </div>
  );
}
