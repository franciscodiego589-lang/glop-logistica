"use client";
import { useState } from "react";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const TABS = ["Painel", "Planos", "Preços por Produto", "Tabela de Preços", "Regras de Produto", "Faixas de Frete", "Faixas de Peso"] as const;

const SIM_NAO: [string, string][] = [["true", "Sim"], ["false", "Não"]];
const ATIVO: [string, string][] = [["true", "Ativo"], ["false", "Inativo"]];
const PLATAFORMAS: [string, string][] = [["monetizze", "Monetizze"], ["kiwify", "Kiwify"], ["hotmart", "Hotmart"], ["appmax", "AppMax"], ["yampi", "Yampi"], ["braip", "Braip"], ["cartpanda", "CartPanda"], ["outra", "Outra"]];
const boolTxt = (v: any) => (v ? "sim" : "não");

export default function PlanosPrecosWorkbench({ planos, produtoPrecos, precos, regras, freteFaixas, pesoFaixas }: {
  planos: any[]; produtoPrecos: any[]; precos: any[]; regras: any[]; freteFaixas: any[]; pesoFaixas: any[];
}) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");

  const planosAtivos = planos.filter((p) => p.ativo).length;
  const prepostagemAuto = planos.filter((p) => p.gerar_prepostagem_auto).length;
  const regrasFallback = regras.filter((r) => r.is_fallback).length;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">💰</div>
        <div>
          <h1 className="text-xl font-bold">Planos &amp; Preços do Produtor</h1>
          <p className="text-sm muted">Planos por plataforma, tabelas de preço, regras de embalagem/prepostagem e faixas de frete/peso por produtor.</p>
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
            <KpiCard label="Planos" value={planos.length} icon="📦" accent hint={`${planosAtivos} ativos`} />
            <KpiCard label="Prepostagem automática" value={prepostagemAuto} icon="🤖" tone={prepostagemAuto ? "success" : "neutral"} hint="planos que geram PPN sozinhos" />
            <KpiCard label="Preços por produto" value={produtoPrecos.length} icon="🏷" />
            <KpiCard label="Tabela de preços (faixas)" value={precos.length} icon="📊" />
            <KpiCard label="Regras de produto" value={regras.length} icon="⚖" hint={`${regrasFallback} fallback`} />
            <KpiCard label="Faixas de frete" value={freteFaixas.length} icon="🚚" />
            <KpiCard label="Faixas de peso" value={pesoFaixas.length} icon="🪶" />
          </div>
          <div className="card p-4 text-sm muted">
            <b>Como funciona:</b> cada <b>produtor</b> tem <b>planos</b> (código da plataforma → regra de embalagem + geração de prepostagem), <b>preços</b> por código de produto e uma <b>tabela de preços</b> por faixa de quantidade. As <b>regras de produto</b> definem peso/dimensões usados na prepostagem dos Correios, e as <b>faixas de frete/peso</b> ajustam valor e peso total conforme a quantidade de itens da venda.
          </div>
        </div>
      )}

      {tab === "Planos" && (
        <CrudPanel table="produtor_planos" title="Planos do produtor" rows={planos}
          emptyHint="Cadastre o plano/código da plataforma e a regra de embalagem aplicada."
          fields={[
            { key: "produtor_id", label: "Produtor", type: "fk", fkTable: "produtores_integracao", fkLabel: "nome", required: true },
            { key: "plano_codigo", label: "Código do plano", required: true },
            { key: "plano_nome_amigavel", label: "Nome amigável" },
            { key: "plataforma", label: "Plataforma", type: "select", options: PLATAFORMAS, default: "monetizze" },
            { key: "regra_id", label: "Regra de produto", type: "fk", fkTable: "produto_regras", fkLabel: "nome" },
            { key: "unidades", label: "Unidades (frascos/itens)", type: "number", default: "1" },
            { key: "gerar_prepostagem_auto", label: "Gerar prepostagem auto", type: "select", options: SIM_NAO, default: "false" },
            { key: "atualizar_rastreio_auto", label: "Atualizar rastreio auto", type: "select", options: SIM_NAO, default: "false" },
            { key: "ativo", label: "Situação", type: "select", options: ATIVO, default: "true" },
          ]}
          columns={[
            { key: "plano_codigo", label: "Código" },
            { key: "plano_nome_amigavel", label: "Nome" },
            { key: "produtor_id", label: "Produtor" },
            { key: "plataforma", label: "Plataforma" },
            { key: "regra_id", label: "Regra" },
            { key: "unidades", label: "Unid." },
            { key: "gerar_prepostagem_auto", label: "Prepost. auto", fmt: (v) => boolTxt(v) },
            { key: "ativo", label: "Ativo", fmt: (v) => boolTxt(v) },
          ]} />
      )}

      {tab === "Preços por Produto" && (
        <CrudPanel table="produtor_produto_precos" title="Preços por produto (produtor)" rows={produtoPrecos}
          emptyHint="Preço unitário por código de produto de cada produtor."
          fields={[
            { key: "produtor_id", label: "Produtor", type: "fk", fkTable: "produtores_integracao", fkLabel: "nome", required: true },
            { key: "produto_codigo", label: "Código do produto", required: true },
            { key: "produto_nome", label: "Nome do produto" },
            { key: "valor_unitario", label: "Valor unitário", type: "number", required: true },
            { key: "ativo", label: "Situação", type: "select", options: ATIVO, default: "true" },
          ]}
          columns={[
            { key: "produto_codigo", label: "Código" },
            { key: "produto_nome", label: "Produto" },
            { key: "produtor_id", label: "Produtor" },
            { key: "valor_unitario", label: "Valor", fmt: (v) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2 }) },
            { key: "ativo", label: "Ativo", fmt: (v) => boolTxt(v) },
          ]} />
      )}

      {tab === "Tabela de Preços" && (
        <CrudPanel table="produto_precos" title="Tabela de preços por faixa" rows={precos}
          emptyHint="Preço unitário por faixa de quantidade (com link de pagamento Asaas opcional)."
          fields={[
            { key: "produtor_id", label: "Produtor", type: "fk", fkTable: "produtores_integracao", fkLabel: "nome", required: true },
            { key: "produto_nome", label: "Produto", required: true },
            { key: "quantidade_min", label: "Qtd. mínima", type: "number", default: "1", required: true },
            { key: "quantidade_max", label: "Qtd. máxima", type: "number", default: "1", required: true },
            { key: "preco_unitario", label: "Preço unitário", type: "number", required: true },
            { key: "link_asaas", label: "Link Asaas" },
            { key: "ativo", label: "Situação", type: "select", options: ATIVO, default: "true" },
          ]}
          columns={[
            { key: "produto_nome", label: "Produto" },
            { key: "produtor_id", label: "Produtor" },
            { key: "quantidade_min", label: "Qtd. mín." },
            { key: "quantidade_max", label: "Qtd. máx." },
            { key: "preco_unitario", label: "Preço", fmt: (v) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2 }) },
            { key: "ativo", label: "Ativo", fmt: (v) => boolTxt(v) },
          ]} />
      )}

      {tab === "Regras de Produto" && (
        <div className="space-y-3">
          <div className="card p-3 text-xs muted">⚖ Regra de embalagem usada na prepostagem: peso e dimensões por produto (palavras-chave casam o nome do item). A regra <b>fallback</b> vale quando nenhuma outra casa.</div>
          <CrudPanel table="produto_regras" title="Regras de produto" rows={regras}
            emptyHint="Defina peso/dimensões e palavras-chave para casar produtos na prepostagem."
            fields={[
              { key: "nome", label: "Nome da regra", required: true },
              { key: "peso_unitario_g", label: "Peso unitário (g)", type: "number", default: "0" },
              { key: "altura_cm", label: "Altura (cm)", type: "number", default: "2" },
              { key: "largura_cm", label: "Largura (cm)", type: "number", default: "11" },
              { key: "comprimento_cm", label: "Comprimento (cm)", type: "number", default: "16" },
              { key: "valor_declarado_padrao", label: "Valor declarado padrão", type: "number" },
              { key: "is_fallback", label: "Regra fallback", type: "select", options: SIM_NAO, default: "false" },
              { key: "enviar_sislogica", label: "Enviar p/ SisLogica", type: "select", options: SIM_NAO, default: "true" },
              { key: "ativo", label: "Situação", type: "select", options: ATIVO, default: "true" },
            ]}
            columns={[
              { key: "nome", label: "Regra" },
              { key: "peso_unitario_g", label: "Peso (g)" },
              { key: "altura_cm", label: "Alt." },
              { key: "largura_cm", label: "Larg." },
              { key: "comprimento_cm", label: "Comp." },
              { key: "is_fallback", label: "Fallback", fmt: (v) => boolTxt(v) },
              { key: "enviar_sislogica", label: "SisLogica", fmt: (v) => boolTxt(v) },
              { key: "ativo", label: "Ativo", fmt: (v) => boolTxt(v) },
            ]} />
        </div>
      )}

      {tab === "Faixas de Frete" && (
        <CrudPanel table="produtor_frete_faixas" title="Faixas de frete" rows={freteFaixas}
          emptyHint="Valor de frete conforme a faixa de quantidade de itens da venda."
          fields={[
            { key: "produtor_id", label: "Produtor", type: "fk", fkTable: "produtores_integracao", fkLabel: "nome", required: true },
            { key: "qtd_min", label: "Qtd. mínima", type: "number", required: true },
            { key: "qtd_max", label: "Qtd. máxima", type: "number", required: true },
            { key: "valor", label: "Valor do frete", type: "number", required: true },
            { key: "observacao", label: "Observação" },
            { key: "ativo", label: "Situação", type: "select", options: ATIVO, default: "true" },
          ]}
          columns={[
            { key: "produtor_id", label: "Produtor" },
            { key: "qtd_min", label: "Qtd. mín." },
            { key: "qtd_max", label: "Qtd. máx." },
            { key: "valor", label: "Frete", fmt: (v) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2 }) },
            { key: "observacao", label: "Observação" },
            { key: "ativo", label: "Ativo", fmt: (v) => boolTxt(v) },
          ]} />
      )}

      {tab === "Faixas de Peso" && (
        <CrudPanel table="produtor_peso_faixas" title="Faixas de peso" rows={pesoFaixas}
          emptyHint="Peso total conforme a faixa de quantidade de itens da venda."
          fields={[
            { key: "produtor_id", label: "Produtor", type: "fk", fkTable: "produtores_integracao", fkLabel: "nome", required: true },
            { key: "qtd_min", label: "Qtd. mínima", type: "number", required: true },
            { key: "qtd_max", label: "Qtd. máxima", type: "number", required: true },
            { key: "peso_total", label: "Peso total (kg)", type: "number", required: true },
            { key: "observacao", label: "Observação" },
            { key: "ativo", label: "Situação", type: "select", options: ATIVO, default: "true" },
          ]}
          columns={[
            { key: "produtor_id", label: "Produtor" },
            { key: "qtd_min", label: "Qtd. mín." },
            { key: "qtd_max", label: "Qtd. máx." },
            { key: "peso_total", label: "Peso total" },
            { key: "observacao", label: "Observação" },
            { key: "ativo", label: "Ativo", fmt: (v) => boolTxt(v) },
          ]} />
      )}
    </div>
  );
}
