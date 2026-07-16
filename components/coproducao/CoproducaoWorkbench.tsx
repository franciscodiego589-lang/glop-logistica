"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";
import { KpiCard } from "@/components/ui/KpiCard";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

const TABS = ["Painel", "Coprodutores", "Regras de Comissão", "Vendas & Comissões", "Repasses", "Split AppMax", "Configuração"] as const;
const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2 });
const dt = (s: any) => s ? new Date(s).toLocaleDateString("pt-BR") : "—";
const REPASSE_TONE: Record<string, string> = { pendente: "badge-warning", aprovado: "badge-neutral", pago: "badge-success", cancelado: "badge-neutral", estornado: "badge-danger", chargeback: "badge-danger", sem_coprodutor: "badge-neutral" };

export default function CoproducaoWorkbench({ coprodutores, regras, vendas, repasses, config, appmax }: {
  coprodutores: any[]; regras: any[]; vendas: any[]; repasses: any[]; config: any; appmax: any;
}) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Painel");
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState(false);

  // AUTOMAÇÃO: apura as comissões das vendas pelas regras (RPC coproducao_apurar).
  async function apurar() {
    if (!supabase) return; setBusy(true);
    const { data, error } = await supabase.rpc("coproducao_apurar", { p_company: COMPANY });
    setBusy(false);
    if (error) alert("🚫 " + error.message);
    else { const d = data as any; alert(`✅ Apuração concluída: ${d?.apurados ?? 0} comissão(ões) criada(s)${d?.sem_regra ? ` · ${d.sem_regra} venda(s) sem regra` : ""}.`); router.refresh(); }
  }

  // #1 GERAR REPASSE: fecha as comissões pendentes em lotes de repasse por coprodutor.
  async function gerarRepasse() {
    if (!supabase) return;
    if (!confirm("Gerar repasse agrupa TODAS as comissões pendentes (com valor) de cada coprodutor num lote fechado. Continuar?")) return;
    setBusy(true);
    const { data, error } = await supabase.rpc("coproducao_gerar_repasse", { p_company: COMPANY });
    setBusy(false);
    if (error) alert("🚫 " + error.message);
    else { const d = data as any; if ((d?.lotes ?? 0) === 0) alert("ℹ️ Nenhuma comissão pendente para repassar."); else { alert(`✅ ${d.lotes} lote(s) de repasse gerado(s) — ${money(d.total_repassar)} a repassar.`); setTab("Repasses"); router.refresh(); } }
  }

  const ativos = coprodutores.filter((c) => c.status === "ativo").length;
  const comissaoPendente = vendas.filter((v) => v.status_repasse === "pendente").reduce((s, v) => s + Number(v.valor_comissao ?? 0), 0);
  const aRepassar = repasses.filter((r) => ["aberto", "conferido", "aprovado"].includes(r.status)).reduce((s, r) => s + Number(r.total_liquido_repassar ?? 0), 0);

  const coprodutorNome = (id: string) => coprodutores.find((c) => c.id === id)?.nome ?? "—";

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">🤝</div>
        <div>
          <h1 className="text-xl font-bold">Coprodução &amp; Split</h1>
          <p className="text-sm muted">Coprodutores, regras de comissão, apuração de vendas, repasses e split de pagamento (AppMax).</p>
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
          <div className="card p-4 flex flex-wrap items-center gap-3" style={{ borderLeft: "3px solid var(--brand)" }}>
            <div className="flex-1 min-w-[240px]">
              <div className="font-bold text-sm">⚡ Apuração automática de comissão</div>
              <div className="text-xs muted">Varre as vendas, casa com as regras por produto e cria as comissões (comissão × empresa) sozinho. Idempotente — não duplica.</div>
            </div>
            <div className="flex flex-col gap-1.5">
              <button onClick={apurar} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-50">{busy ? "Apurando…" : "⚡ Apurar comissões agora"}</button>
              <button onClick={gerarRepasse} disabled={busy} className="px-4 py-2 rounded-lg border text-sm font-semibold disabled:opacity-50" style={{ borderColor: "var(--border)" }}>＋ Gerar repasse</button>
            </div>
          </div>
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            <KpiCard label="Coprodutores ativos" value={ativos} icon="🤝" accent />
            <KpiCard label="Regras de comissão" value={regras.length} icon="⚙" />
            <KpiCard label="Vendas apuradas" value={vendas.length} icon="🧾" />
            <KpiCard label="Comissão pendente" value={money(comissaoPendente)} icon="💸" tone={comissaoPendente ? "warning" : "neutral"} hint="vendas sem repasse" />
            <KpiCard label="A repassar (lotes)" value={money(aRepassar)} icon="📤" tone="brand" />
            <KpiCard label="Repasses" value={repasses.length} icon="📋" />
            <KpiCard label="Split AppMax" value={appmax ? (appmax.active ? "Ativo" : "Inativo") : "Não config."} icon="🔀" tone={appmax?.active ? "success" : "neutral"} />
            <KpiCard label="Módulo" value={config?.ativar_modulo ? "Ligado" : "Desligado"} icon="🎚" tone={config?.ativar_modulo ? "success" : "neutral"} hint={config?.modo_operacao ?? "—"} />
          </div>
          <div className="card p-4 text-sm muted">
            <b>Como funciona:</b> cadastre os <b>coprodutores</b> (com dados de repasse: PIX/banco), defina <b>regras de comissão</b> por produto/SKU/cupom, e o sistema apura cada <b>venda</b> calculando comissão × empresa. Os valores viram <b>repasses</b> por período. Com o <b>Split AppMax</b> configurado, o rateio pode acontecer direto no pagamento.
          </div>
        </div>
      )}

      {tab === "Coprodutores" && (
        <CrudPanel table="coprodutores" title="Coprodutores" rows={coprodutores}
          emptyHint="Cadastre quem recebe repasse: produtor parceiro, afiliado, sócio."
          fields={[
            { key: "nome", label: "Nome", required: true },
            { key: "tipo_pessoa", label: "Tipo", type: "select", options: [["pessoa_fisica", "Pessoa Física"], ["pessoa_juridica", "Pessoa Jurídica"]], default: "pessoa_fisica" },
            { key: "cpf_cnpj", label: "CPF/CNPJ" },
            { key: "email", label: "E-mail" }, { key: "telefone", label: "Telefone" },
            { key: "chave_pix", label: "Chave PIX" },
            { key: "banco", label: "Banco" }, { key: "agencia", label: "Agência" }, { key: "conta", label: "Conta" },
            { key: "tipo_conta", label: "Tipo de conta" },
            { key: "percentual_padrao", label: "% padrão", type: "number", default: "0" },
            { key: "status", label: "Status", type: "select", options: [["ativo", "Ativo"], ["inativo", "Inativo"]], default: "ativo" },
            { key: "observacoes", label: "Observações" },
          ]}
          columns={[
            { key: "nome", label: "Nome" }, { key: "tipo_pessoa", label: "Tipo" },
            { key: "cpf_cnpj", label: "CPF/CNPJ" }, { key: "percentual_padrao", label: "% padrão" },
            { key: "chave_pix", label: "PIX" }, { key: "status", label: "Status" },
          ]} />
      )}

      {tab === "Regras de Comissão" && (
        <CrudPanel table="coproducao_regras" title="Regras de comissão" rows={regras}
          emptyHint="Casa produto/SKU/cupom/UTM → aplica % de comissão e base de cálculo automaticamente."
          fields={[
            { key: "coprodutor_id", label: "Coprodutor", type: "fk", fkTable: "coprodutores", fkLabel: "nome", required: true },
            { key: "nome_regra", label: "Nome da regra", required: true },
            { key: "produto_nome", label: "Produto (nome)" }, { key: "sku", label: "SKU" },
            { key: "codigo_produto_appmax", label: "Cód. produto AppMax" },
            { key: "cupom", label: "Cupom" }, { key: "utm_source", label: "UTM source" }, { key: "utm_campaign", label: "UTM campaign" },
            { key: "percentual_comissao", label: "% comissão", type: "number", required: true },
            { key: "tipo_base_calculo", label: "Base de cálculo", type: "select", options: [["produtos_sem_frete", "Produtos sem frete"], ["produtos_sem_frete_sem_desconto", "Produtos sem frete/desconto"], ["valor_liquido_produtos", "Valor líquido dos produtos"]], default: "produtos_sem_frete" },
            { key: "frete_para", label: "Frete para", type: "select", options: [["empresa_principal", "Empresa principal"], ["dividir_proporcional", "Dividir proporcional"], ["ignorar", "Ignorar"]], default: "empresa_principal" },
            { key: "prioridade", label: "Prioridade", type: "number", default: "100" },
            { key: "status", label: "Status", type: "select", options: [["ativo", "Ativo"], ["inativo", "Inativo"]], default: "ativo" },
          ]}
          columns={[
            { key: "nome_regra", label: "Regra" },
            { key: "coprodutor_id", label: "Coprodutor", fmt: (v) => coprodutorNome(v) },
            { key: "produto_nome", label: "Produto" }, { key: "percentual_comissao", label: "%" },
            { key: "prioridade", label: "Prio." }, { key: "status", label: "Status" },
          ]} />
      )}

      {tab === "Vendas & Comissões" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 font-semibold text-sm">Vendas apuradas <span className="badge badge-neutral ml-1">{vendas.length}</span></div>
          {vendas.length === 0 ? <p className="text-sm muted p-4">Nenhuma venda apurada ainda. As vendas entram via integração (Yampi/AppMax) ou manual, e o sistema calcula a comissão pela regra que casar.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Venda</th><th className="px-3">Cliente</th><th className="px-3">Produto</th><th className="px-3">Coprodutor</th><th className="px-3 text-right">Total</th><th className="px-3 text-right">Comissão</th><th className="px-3">Repasse</th><th className="px-3">Data</th></tr></thead>
              <tbody>{vendas.map((v) => (
                <tr key={v.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-medium">{v.codigo_venda ?? "—"}</td>
                  <td className="px-3">{v.cliente_nome ?? "—"}</td>
                  <td className="px-3 text-xs">{v.produto_nome ?? "—"}</td>
                  <td className="px-3 text-xs">{coprodutorNome(v.coprodutor_id)}</td>
                  <td className="px-3 text-right tabular-nums">{money(v.valor_total)}</td>
                  <td className="px-3 text-right tabular-nums font-medium">{money(v.valor_comissao)}</td>
                  <td className="px-3"><span className={`badge ${REPASSE_TONE[v.status_repasse] ?? "badge-neutral"}`}>{v.status_repasse ?? "—"}</span></td>
                  <td className="px-3 text-xs muted">{dt(v.data_venda)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Repasses" && (
        <div className="card p-0 overflow-x-auto">
          <div className="px-4 pt-3 flex items-center justify-between flex-wrap gap-2">
            <span className="font-semibold text-sm">Repasses por período <span className="badge badge-neutral ml-1">{repasses.length}</span></span>
            <button onClick={gerarRepasse} disabled={busy} className="px-3 py-1.5 rounded-lg bg-brand-600 text-white text-xs font-semibold disabled:opacity-50">{busy ? "Gerando…" : "＋ Gerar repasse (fecha comissões pendentes)"}</button>
          </div>
          {repasses.length === 0 ? <p className="text-sm muted p-4">Nenhum repasse gerado. Um repasse agrupa as comissões de um coprodutor num período para pagamento.</p> : (
            <table className="w-full text-sm mt-2">
              <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}>
                <th className="py-2 px-4">Coprodutor</th><th className="px-3">Período</th><th className="px-3 text-right">Vendas</th><th className="px-3 text-right">Comissão</th><th className="px-3 text-right">Líquido a repassar</th><th className="px-3">Status</th><th className="px-3">Pago em</th></tr></thead>
              <tbody>{repasses.map((r) => (
                <tr key={r.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-4 font-medium">{coprodutorNome(r.coprodutor_id)}</td>
                  <td className="px-3 text-xs">{dt(r.periodo_inicio)} — {dt(r.periodo_fim)}</td>
                  <td className="px-3 text-right tabular-nums">{r.total_vendas ?? 0}</td>
                  <td className="px-3 text-right tabular-nums">{money(r.total_comissao)}</td>
                  <td className="px-3 text-right tabular-nums font-semibold">{money(r.total_liquido_repassar)}</td>
                  <td className="px-3"><span className={`badge ${r.status === "pago" ? "badge-success" : r.status === "cancelado" ? "badge-danger" : "badge-warning"}`}>{r.status ?? "—"}</span></td>
                  <td className="px-3 text-xs muted">{dt(r.data_pagamento)}</td>
                </tr>))}</tbody>
            </table>
          )}
        </div>
      )}

      {tab === "Split AppMax" && (
        <div className="space-y-3">
          <div className="card p-3 text-xs muted">🔀 Split real via API da AppMax: o valor da comissão do coprodutor é separado no ato do pagamento. Configure as credenciais e o recebedor da logística.</div>
          <CrudPanel table="appmax_split_config" title="Configuração do Split AppMax" rows={appmax ? [appmax] : []}
            emptyHint="Cadastre uma configuração (client_id/secret e recebedor)."
            fields={[
              { key: "environment", label: "Ambiente", type: "select", options: [["production", "Produção"], ["sandbox", "Sandbox"]], default: "production" },
              { key: "client_id", label: "Client ID" }, { key: "client_secret", label: "Client Secret" },
              { key: "app_id", label: "App ID" }, { key: "redirect_uri", label: "Redirect URI" },
              { key: "logistics_recipient_id", label: "Recebedor logística (ID)" },
              { key: "logistics_recipient_name", label: "Recebedor (nome)" },
              { key: "logistics_recipient_document", label: "Recebedor (documento)" },
              { key: "recipient_status", label: "Status do recebedor" },
            ]}
            columns={[
              { key: "environment", label: "Ambiente" }, { key: "client_id", label: "Client ID" },
              { key: "logistics_recipient_name", label: "Recebedor" }, { key: "recipient_status", label: "Status" },
              { key: "active", label: "Ativo", fmt: (v) => (v ? "sim" : "não") },
            ]} />
        </div>
      )}

      {tab === "Configuração" && (
        <div className="space-y-3">
          <div className="card p-3 text-xs muted">🎚 Regras gerais do módulo de coprodução. A configuração é única por empresa.</div>
          <CrudPanel table="coproducao_configuracoes" title="Configuração do módulo" rows={config ? [config] : []}
            emptyHint="Crie a configuração do módulo (só uma por empresa)."
            fields={[
              { key: "modo_operacao", label: "Modo de operação", type: "select", options: [["controle_interno", "Controle interno"], ["split_real_api", "Split real (API)"], ["hibrido", "Híbrido"]], default: "controle_interno" },
              { key: "base_calculo_padrao", label: "Base de cálculo padrão", type: "select", options: [["produtos_sem_frete", "Produtos sem frete"], ["produtos_sem_frete_sem_desconto", "Produtos sem frete/desconto"], ["valor_liquido_produtos", "Valor líquido"]], default: "produtos_sem_frete" },
              { key: "frete_padrao", label: "Frete padrão", type: "select", options: [["empresa_principal", "Empresa principal"], ["dividir_proporcional", "Dividir proporcional"], ["ignorar", "Ignorar"]], default: "empresa_principal" },
              { key: "status_minimo_para_gerar_comissao", label: "Status mínimo p/ gerar comissão", default: "pago" },
              { key: "prazo_liberacao_repasse_dias", label: "Prazo liberação (dias)", type: "number", default: "7" },
              { key: "sistema_conta_pagar", label: "Sistema de conta a pagar" },
            ]}
            columns={[
              { key: "modo_operacao", label: "Modo" }, { key: "base_calculo_padrao", label: "Base" },
              { key: "frete_padrao", label: "Frete" }, { key: "prazo_liberacao_repasse_dias", label: "Prazo (d)" },
              { key: "ativar_modulo", label: "Ativo", fmt: (v) => (v ? "sim" : "não") },
            ]} />
        </div>
      )}
    </div>
  );
}
