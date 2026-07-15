"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const brl = (n: number) => (n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const METHODS: [string, string][] = [["linear","Linear"],["declining","Saldos decrescentes"],["units","Unidades produzidas"]];
const STATUS: [string, string][] = [["draft","Rascunho"],["active","Ativo"],["idle","Ocioso"],["maintenance","Em manutenção"],["disposed","Alienado"],["written_off","Baixado"]];

const TABS = ["Painel","Ativos","Depreciação","Reavaliar & Transferir","Seguros & Garantias","Inventário","Categorias"] as const;
type Tab = typeof TABS[number];

export default function AAWorkbench({ dash, categories, assets, depreciations, revaluations, transfers, insurances, inventory }: {
  dash: any; categories: any[]; assets: any[]; depreciations: any[]; revaluations: any[]; transfers: any[]; insurances: any[]; inventory: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  const assetOpts: [string, string][] = useMemo(() => assets.map((a) => [a.id, `${a.asset_code ?? "—"} · ${a.name}`]), [assets]);

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Núcleo Financeiro-Patrimonial</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Patrimônio & Ativos Fixos (AA)</h1>
        <p className="text-sm muted mt-0.5">Ciclo contábil dos ativos: depreciação (posta no GL), reavaliação, transferências, seguros e inventário patrimonial.</p>
      </div>

      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Ativos" && (
        <CrudPanel table="fixed_assets" title="Ativos Patrimoniais"
          fields={[
            { key: "asset_code", label: "Código patrimonial", placeholder: "PAT-0002" },
            { key: "name", label: "Descrição", required: true },
            { key: "category_id", label: "Categoria", type: "fk", fkTable: "asset_categories", fkLabel: "name", required: true },
            { key: "serial_number", label: "Nº de série" },
            { key: "manufacturer", label: "Fabricante" }, { key: "model", label: "Modelo" },
            { key: "acquisition_date", label: "Data de aquisição", type: "date" },
            { key: "acquisition_value", label: "Valor de aquisição", type: "number", required: true },
            { key: "residual_value", label: "Valor residual", type: "number" },
            { key: "useful_life_months", label: "Vida útil (meses)", type: "number" },
            { key: "depreciation_method", label: "Método", type: "select", options: METHODS },
            { key: "in_service_date", label: "Entrada em operação", type: "date" },
            { key: "cost_center_id", label: "Centro de custo", type: "fk", fkTable: "cost_centers", fkLabel: "name" },
            { key: "location", label: "Localização" }, { key: "responsible", label: "Responsável" },
            { key: "status", label: "Status", type: "select", options: STATUS, default: "active" },
            { key: "warranty_until", label: "Garantia até", type: "date" },
            { key: "insured_value", label: "Valor segurado", type: "number" },
          ]}
          columns={[
            { key: "asset_code", label: "Código" }, { key: "name", label: "Descrição" },
            { key: "category_id", label: "Categoria" },
            { key: "acquisition_value", label: "Aquisição", fmt: (v) => brl(Number(v)) },
            { key: "accumulated_depreciation", label: "Deprec.acum", fmt: (v) => brl(Number(v)) },
            { key: "status", label: "Status", fmt: (v) => STATUS.find(([k]) => k === v)?.[1] ?? v },
          ]}
          rows={assets} emptyHint="Cadastre máquinas, equipamentos, veículos, imóveis, intangíveis…" />
      )}
      {tab === "Depreciação" && <Depreciacao entries={depreciations} assets={assets} />}
      {tab === "Reavaliar & Transferir" && <RevalTransfer assetOpts={assetOpts} revaluations={revaluations} transfers={transfers} />}
      {tab === "Seguros & Garantias" && (
        <CrudPanel table="asset_insurances" title="Apólices de Seguro"
          fields={[
            { key: "asset_id", label: "Ativo", type: "fk", fkTable: "fixed_assets", fkLabel: "name" },
            { key: "policy_number", label: "Nº da apólice", required: true },
            { key: "insurer", label: "Seguradora", required: true },
            { key: "coverage", label: "Cobertura" },
            { key: "insured_value", label: "Valor segurado", type: "number" },
            { key: "deductible", label: "Franquia", type: "number" },
            { key: "valid_from", label: "Vigência início", type: "date" },
            { key: "valid_to", label: "Vigência fim", type: "date" },
            { key: "status", label: "Status", type: "select", options: [["active","Vigente"],["expired","Vencida"],["canceled","Cancelada"]], default: "active" },
          ]}
          columns={[
            { key: "policy_number", label: "Apólice" }, { key: "insurer", label: "Seguradora" },
            { key: "asset_id", label: "Ativo" },
            { key: "insured_value", label: "Valor segurado", fmt: (v) => v ? brl(Number(v)) : "—" },
            { key: "valid_to", label: "Vigência fim" }, { key: "status", label: "Status" },
          ]}
          rows={insurances} emptyHint="Cadastre apólices para monitorar cobertura e renovação." />
      )}
      {tab === "Inventário" && (
        <CrudPanel table="asset_inventory_counts" title="Inventário Patrimonial (físico × sistema)"
          fields={[
            { key: "asset_id", label: "Ativo", type: "fk", fkTable: "fixed_assets", fkLabel: "name", required: true },
            { key: "counted_at", label: "Data da contagem", type: "date" },
            { key: "found", label: "Localizado?", type: "select", options: [["true","Sim"],["false","Não — divergência"]], default: "true" },
            { key: "location_found", label: "Local encontrado" },
            { key: "condition", label: "Estado de conservação" },
            { key: "divergence", label: "Divergência" },
          ]}
          columns={[
            { key: "asset_id", label: "Ativo" }, { key: "counted_at", label: "Contagem" },
            { key: "found", label: "Localizado", fmt: (v) => v ? "Sim" : "Não" },
            { key: "location_found", label: "Local" }, { key: "divergence", label: "Divergência" },
          ]}
          rows={inventory} emptyHint="Registre contagens de inventário e divergências." />
      )}
      {tab === "Categorias" && (
        <CrudPanel table="asset_categories" title="Categorias Patrimoniais (política de depreciação)"
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "default_method", label: "Método padrão", type: "select", options: METHODS, default: "linear" },
            { key: "useful_life_months", label: "Vida útil (meses)", type: "number", default: "60" },
            { key: "residual_pct", label: "Residual %", type: "number", default: "0" },
            { key: "is_intangible", label: "Intangível?", type: "select", options: [["false","Não"],["true","Sim (amortização)"]], default: "false" },
          ]}
          columns={[
            { key: "name", label: "Categoria" },
            { key: "default_method", label: "Método", fmt: (v) => METHODS.find(([k]) => k === v)?.[1] ?? v },
            { key: "useful_life_months", label: "Vida útil (m)" },
            { key: "residual_pct", label: "Residual %" },
            { key: "is_intangible", label: "Intangível", fmt: (v) => v ? "Sim" : "—" },
          ]}
          rows={categories} emptyHint="Sem categorias." />
      )}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}

function Painel({ dash }: { dash: any }) {
  const d = dash ?? {};
  const byCat: Record<string, number> = d.by_category ?? {};
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
        <KPI label="Ativos" value={String(d.assets_count ?? 0)} />
        <KPI label="Valor bruto" value={`R$ ${brl(Number(d.gross_value ?? 0))}`} />
        <KPI label="Depreciação acumulada" value={`R$ ${brl(Number(d.accumulated_depreciation ?? 0))}`} tone="var(--warning)" />
        <KPI label="Valor líquido contábil" value={`R$ ${brl(Number(d.net_book_value ?? 0))}`} tone="var(--brand)" />
        <KPI label="Ativos ociosos" value={String(d.idle ?? 0)} tone={d.idle ? "var(--warning)" : undefined} />
        <KPI label="Sem seguro" value={String(d.uninsured ?? 0)} tone={d.uninsured ? "var(--danger)" : undefined} />
        <KPI label="Garantias a vencer (90d)" value={String(d.warranty_expiring ?? 0)} />
        <KPI label="100% depreciados em uso" value={String(d.fully_depreciated_active ?? 0)} />
      </div>
      <div className="card p-5">
        <div className="font-semibold mb-3">Ativos por categoria</div>
        {Object.keys(byCat).length === 0 ? <p className="text-sm muted">Sem ativos cadastrados.</p> : (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            {Object.entries(byCat).map(([k, v]) => (
              <div key={k} className="surface-2 rounded-xl p-3" style={{ border: "1px solid var(--border)" }}>
                <div className="text-xs muted font-semibold">{k}</div>
                <div className="text-lg font-bold tabular-nums mt-1">{v}</div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function Depreciacao({ entries, assets }: { entries: any[]; assets: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const now = new Date();
  const assetName = (id: string) => assets.find((a) => a.id === id)?.name ?? "—";
  async function run() {
    if (!supabase) return;
    setBusy(true); setMsg(null);
    const { data, error } = await supabase.rpc("run_depreciation", { p_company: COMPANY, p_year: now.getFullYear(), p_month: now.getMonth() + 1 });
    setBusy(false);
    if (error) { setMsg("Erro: " + error.message); return; }
    setMsg(`✓ ${data?.assets_depreciated ?? 0} ativo(s) · R$ ${brl(Number(data?.total_depreciation ?? 0))} depreciado(s)${data?.posted_to_gl ? " · postado no GL" : ""}`);
    router.refresh();
  }
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3 flex-wrap">
        <div className="font-semibold text-base mr-auto">Depreciação do período</div>
        {msg && <span className="text-xs muted">{msg}</span>}
        <button onClick={run} disabled={busy} className="btn btn-primary btn-sm">{busy ? "Depreciando…" : `Rodar depreciação ${now.getMonth() + 1}/${now.getFullYear()}`}</button>
      </div>
      <p className="text-xs muted">Calcula por método (linear/decrescente), atualiza a depreciação acumulada e <strong>posta automaticamente na Contabilidade</strong> (D Despesa de Depreciação / C Depreciação Acumulada). Idempotente por ativo/período.</p>
      {entries.length === 0 ? <p className="text-sm muted px-1">Nenhuma depreciação registrada ainda.</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead><tr><th>Ativo</th><th>Período</th><th>Método</th><th className="text-right">Depreciação</th><th className="text-right">Acumulada</th><th className="text-right">Valor contábil</th><th>GL</th></tr></thead>
            <tbody>
              {entries.map((e) => (
                <tr key={e.id}>
                  <td>{assetName(e.asset_id)}</td>
                  <td className="tabular-nums">{e.fiscal_year}/{String(e.fiscal_month).padStart(2, "0")}</td>
                  <td>{METHODS.find(([k]) => k === e.method)?.[1] ?? e.method}</td>
                  <td className="text-right tabular-nums">{brl(Number(e.amount))}</td>
                  <td className="text-right tabular-nums">{brl(Number(e.accumulated_after))}</td>
                  <td className="text-right tabular-nums font-medium">{brl(Number(e.book_value_after))}</td>
                  <td><span className={`badge ${e.posted ? "badge-success" : "badge-warning"}`}>{e.posted ? "postado" : "pendente"}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function RevalTransfer({ assetOpts, revaluations, transfers }: { assetOpts: [string, string][]; revaluations: any[]; transfers: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [rv, setRv] = useState({ asset: "", newNet: "", type: "revaluation_up", reason: "" });
  const [tr, setTr] = useState({ asset: "", location: "", responsible: "", reason: "" });
  const [busy, setBusy] = useState(false);
  async function revalue() {
    if (!supabase || !rv.asset || !(Number(rv.newNet) >= 0)) return;
    setBusy(true);
    await supabase.rpc("revalue_asset", { p_asset: rv.asset, p_new_net: Number(rv.newNet), p_type: rv.type, p_reason: rv.reason || null });
    setBusy(false); setRv({ asset: "", newNet: "", type: "revaluation_up", reason: "" }); router.refresh();
  }
  async function transfer() {
    if (!supabase || !tr.asset) return;
    setBusy(true);
    await supabase.rpc("transfer_asset", { p_asset: tr.asset, p_to_location: tr.location || null, p_to_responsible: tr.responsible || null, p_to_cost_center: null, p_reason: tr.reason || null });
    setBusy(false); setTr({ asset: "", location: "", responsible: "", reason: "" }); router.refresh();
  }
  const name = (id: string) => assetOpts.find(([v]) => v === id)?.[1] ?? "—";
  return (
    <div className="space-y-4">
      <div className="grid lg:grid-cols-2 gap-4">
        <div className="card p-4 space-y-3">
          <div className="font-semibold">Reavaliação / Impairment</div>
          <select value={rv.asset} onChange={(e) => setRv((p) => ({ ...p, asset: e.target.value }))} className="select"><option value="">— ativo —</option>{assetOpts.map(([v, l]) => <option key={v} value={v}>{l}</option>)}</select>
          <div className="grid grid-cols-2 gap-3">
            <div><label className="label">Novo valor líquido</label><input type="number" value={rv.newNet} onChange={(e) => setRv((p) => ({ ...p, newNet: e.target.value }))} className="input" /></div>
            <div><label className="label">Tipo</label><select value={rv.type} onChange={(e) => setRv((p) => ({ ...p, type: e.target.value }))} className="select">
              <option value="revaluation_up">Reavaliação (+)</option><option value="revaluation_down">Reavaliação (−)</option><option value="impairment">Impairment</option><option value="recovery">Recuperação</option></select></div>
          </div>
          <input value={rv.reason} onChange={(e) => setRv((p) => ({ ...p, reason: e.target.value }))} className="input" placeholder="Motivo / laudo" />
          <button onClick={revalue} disabled={busy || !rv.asset} className="btn btn-primary btn-sm">Registrar reavaliação</button>
        </div>
        <div className="card p-4 space-y-3">
          <div className="font-semibold">Transferência</div>
          <select value={tr.asset} onChange={(e) => setTr((p) => ({ ...p, asset: e.target.value }))} className="select"><option value="">— ativo —</option>{assetOpts.map(([v, l]) => <option key={v} value={v}>{l}</option>)}</select>
          <div className="grid grid-cols-2 gap-3">
            <div><label className="label">Nova localização</label><input value={tr.location} onChange={(e) => setTr((p) => ({ ...p, location: e.target.value }))} className="input" /></div>
            <div><label className="label">Novo responsável</label><input value={tr.responsible} onChange={(e) => setTr((p) => ({ ...p, responsible: e.target.value }))} className="input" /></div>
          </div>
          <input value={tr.reason} onChange={(e) => setTr((p) => ({ ...p, reason: e.target.value }))} className="input" placeholder="Motivo" />
          <button onClick={transfer} disabled={busy || !tr.asset} className="btn btn-primary btn-sm">Registrar transferência</button>
        </div>
      </div>

      <div className="grid lg:grid-cols-2 gap-4">
        <div>
          <div className="font-semibold text-sm mb-2">Histórico de reavaliações</div>
          {revaluations.length === 0 ? <p className="text-sm muted">—</p> : (
            <div className="card p-0 overflow-x-auto"><table className="tbl"><thead><tr><th>Ativo</th><th>Tipo</th><th className="text-right">Antes</th><th className="text-right">Depois</th><th className="text-right">Δ</th></tr></thead>
              <tbody>{revaluations.map((r) => (<tr key={r.id}><td>{name(r.asset_id)}</td><td>{r.reval_type}</td><td className="text-right tabular-nums">{brl(Number(r.old_net))}</td><td className="text-right tabular-nums">{brl(Number(r.new_net))}</td><td className="text-right tabular-nums font-medium" style={{ color: Number(r.delta) >= 0 ? "var(--success)" : "var(--danger)" }}>{brl(Number(r.delta))}</td></tr>))}</tbody></table></div>
          )}
        </div>
        <div>
          <div className="font-semibold text-sm mb-2">Histórico de transferências</div>
          {transfers.length === 0 ? <p className="text-sm muted">—</p> : (
            <div className="card p-0 overflow-x-auto"><table className="tbl"><thead><tr><th>Ativo</th><th>De</th><th>Para</th><th>Data</th></tr></thead>
              <tbody>{transfers.map((t) => (<tr key={t.id}><td>{name(t.asset_id)}</td><td className="muted text-xs">{t.from_location ?? "—"}</td><td className="text-xs">{t.to_location ?? "—"}</td><td className="tabular-nums">{t.transfer_date}</td></tr>))}</tbody></table></div>
          )}
        </div>
      </div>
    </div>
  );
}
