"use client";
import { useMemo, useState } from "react";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const TABS = ["Painel", "Produtos", "Locais", "Movimentos", "Baixa Automática", "Registros de Estoque"] as const;
const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2 });
const num = (v: any) => Number(v ?? 0).toLocaleString("pt-BR", { maximumFractionDigits: 3 });
const dt = (s: any) => s ? new Date(s).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit" }) : "—";
const TIPO_BADGE: Record<string, string> = { entrada: "badge-success", saida: "badge-danger", ajuste: "badge-warning", transferencia: "badge-neutral" };

export default function EstoqueLogisticoWorkbench({ produtos, locais, movimentos, baixaConfig, registros }: {
  produtos: any[]; locais: any[]; movimentos: any[]; baixaConfig: any[]; registros: any[];
}) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");

  const produtoNome = (id: any) => produtos.find((p) => p.id === id)?.nome ?? "—";
  const localNome = (id: any) => locais.find((l) => l.id === id)?.nome ?? "—";

  const produtosAtivos = produtos.filter((p) => p.ativo).length;
  const locaisAtivos = locais.filter((l) => l.ativo).length;
  const entradas = movimentos.filter((m) => m.tipo === "entrada").length;
  const saidas = movimentos.filter((m) => m.tipo === "saida").length;
  const baixasAtivas = baixaConfig.filter((b) => b.ativo).length;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">📦</div>
        <div>
          <h1 className="text-xl font-bold">Estoque Logístico</h1>
          <p className="text-sm muted">Produtos, locais de armazenagem, movimentos (entrada/saída/ajuste/transferência), baixa automática e registros de estoque com IA.</p>
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
            <KpiCard label="Produtos" value={produtos.length} icon="📦" accent hint={`${produtosAtivos} ativos`} />
            <KpiCard label="Locais de estoque" value={locais.length} icon="🏬" tone="brand" hint={`${locaisAtivos} ativos`} />
            <KpiCard label="Movimentos" value={movimentos.length} icon="🔁" />
            <KpiCard label="Entradas" value={entradas} icon="⬇" tone="success" />
            <KpiCard label="Saídas" value={saidas} icon="⬆" tone={saidas ? "danger" : "neutral"} />
            <KpiCard label="Baixa automática" value={baixasAtivas} icon="⚙" tone={baixasAtivas ? "success" : "neutral"} hint="produtores configurados" />
            <KpiCard label="Registros de estoque" value={registros.length} icon="🏷" />
          </div>
          <div className="card p-4 text-sm muted">
            <b>Como funciona:</b> cadastre os <b>produtos</b> (com estoque mínimo e custo) e os <b>locais</b> de armazenagem. Cada entrada, saída, ajuste ou transferência gera um <b>movimento</b> — o saldo por local é calculado a partir deles. A <b>baixa automática</b> abate o estoque a cada venda despachada, e os <b>registros de estoque</b> guardam a conferência (etiqueta/declaração) de cada objeto, com apoio de IA.
          </div>
        </div>
      )}

      {tab === "Produtos" && (
        <CrudPanel table="estoque_produtos" title="Produtos em estoque" rows={produtos}
          emptyHint="Cadastre os itens controlados: SKU, unidade, estoque mínimo e custo."
          fields={[
            { key: "produtor_id", label: "Produtor", type: "fk", fkTable: "produtores_integracao", fkLabel: "nome", required: true },
            { key: "nome", label: "Nome", required: true },
            { key: "codigo", label: "Código / SKU" },
            { key: "unidade", label: "Unidade", default: "UN" },
            { key: "categoria", label: "Categoria" },
            { key: "estoque_minimo", label: "Estoque mínimo", type: "number", default: "0" },
            { key: "valor_custo", label: "Valor de custo", type: "number" },
            { key: "observacao", label: "Observação" },
          ]}
          columns={[
            { key: "nome", label: "Nome" },
            { key: "codigo", label: "SKU" },
            { key: "unidade", label: "Un." },
            { key: "categoria", label: "Categoria" },
            { key: "estoque_minimo", label: "Mín.", fmt: (v) => num(v) },
            { key: "valor_custo", label: "Custo", fmt: (v) => (v == null ? "—" : money(v)) },
            { key: "produtor_id", label: "Produtor" },
            { key: "ativo", label: "Ativo", fmt: (v) => (v ? "sim" : "não") },
          ]} />
      )}

      {tab === "Locais" && (
        <CrudPanel table="estoque_locais" title="Locais de armazenagem" rows={locais}
          emptyHint="Cadastre depósitos, prateleiras ou centros de distribuição onde o estoque fica."
          fields={[
            { key: "produtor_id", label: "Produtor", type: "fk", fkTable: "produtores_integracao", fkLabel: "nome", required: true },
            { key: "nome", label: "Nome", required: true },
            { key: "descricao", label: "Descrição" },
          ]}
          columns={[
            { key: "nome", label: "Nome" },
            { key: "descricao", label: "Descrição" },
            { key: "produtor_id", label: "Produtor" },
            { key: "ativo", label: "Ativo", fmt: (v) => (v ? "sim" : "não") },
          ]} />
      )}

      {tab === "Movimentos" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Movimentos de estoque <span className="badge badge-neutral ml-1">{movimentos.length}</span></div>
          {movimentos.length === 0 ? <p className="text-sm muted p-4">Nenhum movimento ainda. Entradas, saídas, ajustes e transferências entram por aqui e formam o saldo de cada local.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Tipo</th><th className="px-3">Produto</th><th className="px-3 text-right">Qtd</th><th className="px-3 text-right">Vlr unit.</th><th className="px-3">Local</th><th className="px-3">Destino</th><th className="px-3">Identificação</th><th className="px-3">Data</th></tr></thead>
              <tbody>{movimentos.map((m) => (
                <tr key={m.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4"><span className={`badge ${TIPO_BADGE[m.tipo] ?? "badge-neutral"}`}>{m.tipo ?? "—"}</span></td>
                  <td className="px-3 text-xs">{produtoNome(m.produto_id)}</td>
                  <td className="px-3 text-right tabular-nums font-medium">{num(m.quantidade)}</td>
                  <td className="px-3 text-right tabular-nums">{m.valor_unitario == null ? "—" : money(m.valor_unitario)}</td>
                  <td className="px-3 text-xs">{localNome(m.local_id)}</td>
                  <td className="px-3 text-xs">{m.local_destino_id ? localNome(m.local_destino_id) : "—"}</td>
                  <td className="px-3 text-xs muted">{m.identificacao ?? "—"}</td>
                  <td className="px-3 text-xs muted">{dt(m.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Baixa Automática" && (
        <div className="space-y-3">
          <div className="card p-3 text-xs muted">⚙ Quando ligada, a baixa automática abate o estoque do local escolhido a cada venda despachada do produtor. Uma configuração por produtor.</div>
          <CrudPanel table="estoque_baixa_config" title="Configuração de baixa automática" rows={baixaConfig}
            emptyHint="Ligue a baixa automática por produtor e escolha o local de abatimento."
            fields={[
              { key: "produtor_id", label: "Produtor", type: "fk", fkTable: "produtores_integracao", fkLabel: "nome", required: true },
              { key: "local_id", label: "Local de baixa", type: "fk", fkTable: "estoque_locais", fkLabel: "nome" },
              { key: "observacao", label: "Observação" },
            ]}
            columns={[
              { key: "produtor_id", label: "Produtor" },
              { key: "local_id", label: "Local", fmt: (v) => (v ? localNome(v) : "—") },
              { key: "observacao", label: "Observação" },
              { key: "ativo", label: "Ativo", fmt: (v) => (v ? "sim" : "não") },
            ]} />
        </div>
      )}

      {tab === "Registros de Estoque" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Registros de estoque <span className="badge badge-neutral ml-1">{registros.length}</span></div>
          {registros.length === 0 ? <p className="text-sm muted p-4">Nenhum registro. Cada conferência de objeto (etiqueta/declaração) é lida pela IA e guardada aqui, ligada ao pedido.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Rastreio</th><th className="px-3">Cliente</th><th className="px-3">Produto</th><th className="px-3 text-right">Qtd</th><th className="px-3">Fotos</th><th className="px-3">Observação</th><th className="px-3">Data</th></tr></thead>
              <tbody>{registros.map((r) => (
                <tr key={r.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-mono text-xs">{r.codigo_rastreio ?? "—"}</td>
                  <td className="px-3 text-xs">{r.cliente_nome ?? "—"}</td>
                  <td className="px-3 text-xs">{r.produto_nome ?? "—"}</td>
                  <td className="px-3 text-right tabular-nums">{r.quantidade ?? "—"}</td>
                  <td className="px-3 text-xs">
                    {r.foto_etiqueta_url ? <a href={r.foto_etiqueta_url} target="_blank" rel="noreferrer" className="text-brand-600 hover:underline">etiqueta</a> : <span className="muted">—</span>}
                    {r.foto_declaracao_url ? <> · <a href={r.foto_declaracao_url} target="_blank" rel="noreferrer" className="text-brand-600 hover:underline">declaração</a></> : null}
                  </td>
                  <td className="px-3 text-xs muted">{String(r.observacao ?? "").slice(0, 44) || "—"}</td>
                  <td className="px-3 text-xs muted">{dt(r.created_at)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}
    </div>
  );
}
