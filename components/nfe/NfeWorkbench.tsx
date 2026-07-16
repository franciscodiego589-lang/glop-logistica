"use client";
import { useState } from "react";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const TABS = ["Painel", "Emissões", "Baixa de Estoque (Vhsys)"] as const;
const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2 });
const dt = (s: any) => s ? new Date(s).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit" }) : "—";
const stBadge = (s: string) => {
  const x = String(s ?? "").toLowerCase();
  if (x.includes("erro") || x.includes("rejeit") || x.includes("falha") || x.includes("cancel")) return "badge-danger";
  if (x.includes("emitida") || x.includes("autoriz") || x.includes("concluid")) return "badge-success";
  if (x.includes("process") || x.includes("enviad")) return "badge-neutral";
  return "badge-warning";
};

export default function NfeWorkbench({ emissoes, baixaConfig }: {
  emissoes: any[]; baixaConfig: any[];
}) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");

  const emitidas = emissoes.filter((e) => { const x = String(e.status ?? "").toLowerCase(); return x.includes("emitida") || x.includes("autoriz"); });
  const comErro = emissoes.filter((e) => e.erro || String(e.status ?? "").toLowerCase().includes("erro") || String(e.status ?? "").toLowerCase().includes("rejeit")).length;
  const pendentes = emissoes.filter((e) => String(e.status ?? "").toLowerCase().includes("pendente")).length;
  const valorEmitido = emitidas.reduce((s, e) => s + Number(e.valor ?? 0), 0);
  const configAtivas = baixaConfig.filter((c) => c.ativo).length;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🧾</div>
        <div>
          <h1 className="text-xl font-bold">NFe — Emissões</h1>
          <p className="text-sm muted">Emissões de Nota Fiscal eletrônica (via Vhsys), status/DANFE/XML e vínculo de baixa de estoque por produto.</p>
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
            <KpiCard label="Emissões" value={emissoes.length} icon="🧾" accent />
            <KpiCard label="Emitidas / autorizadas" value={emitidas.length} icon="✅" tone="success" />
            <KpiCard label="Com erro" value={comErro} icon="⚠" tone={comErro ? "danger" : "neutral"} />
            <KpiCard label="Pendentes" value={pendentes} icon="⏳" tone={pendentes ? "warning" : "neutral"} />
            <KpiCard label="Valor emitido" value={money(valorEmitido)} icon="💰" tone="brand" hint="somatório das emitidas" />
            <KpiCard label="Configs de baixa" value={baixaConfig.length} icon="📦" />
            <KpiCard label="Configs ativas" value={configAtivas} icon="🔗" tone={configAtivas ? "success" : "neutral"} />
          </div>
          <div className="card p-4 text-sm muted">
            <b>Como funciona:</b> cada venda elegível gera uma <b>emissão de NFe</b> na Vhsys — o sistema registra status, chave, protocolo, DANFE e XML. Falhas ficam com o <b>erro</b> e número de <b>tentativas</b>. Na aba <b>Baixa de Estoque</b> você vincula o produto ao <b>id do produto/local na Vhsys</b> para dar baixa automática de estoque na emissão.
          </div>
        </div>
      )}

      {tab === "Emissões" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Emissões de NFe <span className="badge badge-neutral ml-1">{emissoes.length}</span></div>
          {emissoes.length === 0 ? <p className="text-sm muted p-4">Nenhuma emissão ainda. As NFes são geradas automaticamente pelo fluxo de venda → Vhsys.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Status</th><th className="px-3">Produto</th><th className="px-3">Plano</th><th className="px-3 text-right">Valor</th><th className="px-3">Chave</th><th className="px-3">Amb.</th><th className="px-3 text-right">Tent.</th><th className="px-3">Docs</th><th className="px-3">Emitida</th><th className="px-3">Criada</th></tr></thead>
              <tbody>{emissoes.map((e) => (
                <tr key={e.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4"><span className={`badge ${stBadge(e.status)}`}>{e.status ?? "—"}</span>{e.erro && <span className="block text-[11px] text-red-500 mt-0.5">{String(e.erro).slice(0, 60)}</span>}</td>
                  <td className="px-3 text-xs">{e.produto_nome ?? e.produto_codigo ?? "—"}</td>
                  <td className="px-3 text-xs">{e.plano_nome ?? e.plano_codigo ?? "—"}</td>
                  <td className="px-3 text-right tabular-nums">{money(e.valor)}</td>
                  <td className="px-3 font-mono text-[11px]">{e.chave ? String(e.chave).slice(-12) : "—"}</td>
                  <td className="px-3 text-xs">{e.ambiente ?? "—"}</td>
                  <td className="px-3 text-right tabular-nums">{e.tentativas ?? 0}</td>
                  <td className="px-3 text-xs">
                    {e.danfe_url ? <a href={e.danfe_url} target="_blank" rel="noreferrer" className="hover:underline" style={{ color: "var(--brand)" }}>DANFE</a> : null}
                    {e.danfe_url && e.xml_url ? " · " : null}
                    {e.xml_url ? <a href={e.xml_url} target="_blank" rel="noreferrer" className="hover:underline" style={{ color: "var(--brand)" }}>XML</a> : null}
                    {!e.danfe_url && !e.xml_url ? "—" : null}
                  </td>
                  <td className="px-3 text-xs muted">{dt(e.emitida_at)}</td>
                  <td className="px-3 text-xs muted">{dt(e.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Baixa de Estoque (Vhsys)" && (
        <div className="space-y-3">
          <div className="card p-3 text-xs muted">📦 Vincule cada produto ao <b>id do produto e do local de estoque na Vhsys</b>. Na emissão da NFe, o estoque é baixado automaticamente no almoxarifado certo. Use <b>match por nome</b> para casar produtos sem código.</div>
          <CrudPanel table="nfe_baixa_estoque_config" title="Baixa de estoque (Vhsys)" rows={baixaConfig}
            emptyHint="Cadastre o vínculo produto → id Vhsys para baixar estoque na emissão da NFe."
            fields={[
              { key: "produtor_id", label: "Produtor", type: "fk", fkTable: "produtores_integracao", fkLabel: "nome", required: true },
              { key: "produto_codigo", label: "Código do produto" },
              { key: "produto_descricao", label: "Descrição do produto" },
              { key: "id_produto_vhsys", label: "ID produto Vhsys", required: true },
              { key: "id_local_estoque", label: "ID local de estoque (Vhsys)" },
              { key: "local_descricao", label: "Descrição do local" },
              { key: "match_nome", label: "Match por nome" },
              { key: "vincular_produto", label: "Vincular produto", type: "select", options: [["true", "Sim"], ["false", "Não"]], default: "true" },
              { key: "ativo", label: "Ativo", type: "select", options: [["true", "Sim"], ["false", "Não"]], default: "true" },
            ]}
            columns={[
              { key: "produto_descricao", label: "Produto" },
              { key: "produto_codigo", label: "Código" },
              { key: "id_produto_vhsys", label: "ID Vhsys" },
              { key: "local_descricao", label: "Local" },
              { key: "id_local_estoque", label: "ID Local" },
              { key: "ativo", label: "Ativo", fmt: (v) => (v ? "sim" : "não") },
            ]} />
        </div>
      )}
    </div>
  );
}
