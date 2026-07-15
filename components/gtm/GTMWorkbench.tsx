"use client";
import { useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import CrudPanel from "@/components/ui/CrudPanel";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const brl = (n: number) => (n ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });

const INCOTERMS: [string, string][] = ["EXW","FCA","FAS","FOB","CFR","CIF","CPT","CIP","DAP","DPU","DDP"].map((i) => [i, i]);
const DIRECTIONS: [string, string][] = [["import", "Importação"], ["export", "Exportação"]];
const STATUSES: [string, string][] = [["negotiation","Negociação"],["ordered","Pedido"],["shipped","Embarcado"],["in_transit","Em trânsito"],["customs","Aduana"],["cleared","Desembaraçado"],["delivered","Entregue"],["canceled","Cancelado"]];
const PARTNER_TYPES: [string, string][] = [["supplier","Fornecedor"],["customer","Cliente"],["trading","Trading"],["broker","Despachante"],["forwarder","Agente de Carga"],["carrier_sea","Armador"],["carrier_air","Cia. Aérea"],["bank","Banco"],["insurer","Seguradora"]];
const LOCATION_TYPES: [string, string][] = [["port","Porto"],["airport","Aeroporto"],["border","Fronteira"],["terminal","Terminal"],["bonded","Recinto Alfandegado"]];
const DOC_TYPES: [string, string][] = [["invoice","Commercial Invoice"],["proforma","Proforma"],["packing_list","Packing List"],["bl","BL (Marítimo)"],["awb","AWB (Aéreo)"],["ci","Certificado de Origem"],["phyto","Fitossanitário"],["msds","MSDS"],["insurance","Seguro"],["lpco","LPCO"],["di","DI"],["duimp","DUIMP"],["due","DU-E"],["dta","DTA"]];

const TABS = ["Painel","Simulador de Importação","Processos","Classificação NCM/HS","Parceiros","Locais (Portos/Aeroportos)","Documentos","Drawback"] as const;
type Tab = typeof TABS[number];

export default function GTMWorkbench({ dash, processes, partners, locations, hs, docs, drawback }: {
  dash: any; processes: any[]; partners: any[]; locations: any[]; hs: any[]; docs: any[]; drawback: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  const partnerOpts: [string,string][] = useMemo(() => partners.map((p) => [p.id, `${p.name}${p.country ? " · "+p.country : ""}`]), [partners]);
  const locOpts: [string,string][] = useMemo(() => locations.map((l) => [l.id, `${l.name}${l.code ? " ("+l.code+")" : ""}`]), [locations]);

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-xl font-bold">Comércio Exterior (GTM)</h1>
        <p className="text-sm muted">Importação, exportação, aduana, Incoterms, classificação fiscal, drawback e simulação de custo nacionalizado.</p>
      </div>

      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>

      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Simulador de Importação" && <Simulador />}
      {tab === "Processos" && (
        <CrudPanel table="trade_processes" title="Processos de Importação / Exportação"
          fields={[
            { key: "direction", label: "Sentido", type: "select", options: DIRECTIONS, required: true, default: "import" },
            { key: "code", label: "Referência", required: true, placeholder: "IMP-2026-001" },
            { key: "incoterm", label: "Incoterm", type: "select", options: INCOTERMS },
            { key: "partner_id", label: "Parceiro", type: "fk", fkTable: "trade_partners" },
            { key: "origin_country", label: "País origem", placeholder: "CN" },
            { key: "dest_country", label: "País destino", placeholder: "BR" },
            { key: "location_id", label: "Porto/Aeroporto", type: "fk", fkTable: "trade_locations" },
            { key: "currency", label: "Moeda", default: "USD" },
            { key: "exchange_rate", label: "Câmbio", type: "number", placeholder: "5.40" },
            { key: "fob_value", label: "FOB", type: "number" },
            { key: "freight_value", label: "Frete", type: "number" },
            { key: "insurance_value", label: "Seguro", type: "number" },
            { key: "status", label: "Status", type: "select", options: STATUSES, default: "negotiation" },
            { key: "channel", label: "Canal", placeholder: "verde/amarelo/vermelho" },
            { key: "invoice_number", label: "Invoice nº" },
            { key: "di_number", label: "DI nº" },
            { key: "duimp_number", label: "DUIMP nº" },
            { key: "due_number", label: "DU-E nº" },
            { key: "bl_awb", label: "BL / AWB" },
            { key: "eta", label: "ETA", type: "date" },
          ]}
          columns={[
            { key: "code", label: "Ref." },
            { key: "direction", label: "Sentido", fmt: (v) => v === "import" ? "Importação" : "Exportação" },
            { key: "incoterm", label: "Incoterm" },
            { key: "partner_id", label: "Parceiro" },
            { key: "status", label: "Status", fmt: (v) => STATUSES.find(([k]) => k === v)?.[1] ?? v },
            { key: "fob_value", label: "FOB", fmt: (v) => v ? brl(v) : "—" },
            { key: "eta", label: "ETA" },
          ]}
          rows={processes} emptyHint="Nenhum processo. Crie uma importação ou exportação." />
      )}
      {tab === "Classificação NCM/HS" && (
        <CrudPanel table="hs_classifications" title="Classificação Fiscal (NCM / HS Code)"
          fields={[
            { key: "ncm", label: "NCM", required: true, placeholder: "8471.30.19" },
            { key: "hs_code", label: "HS Code", placeholder: "8471.30" },
            { key: "description", label: "Descrição", required: true },
            { key: "ii_pct", label: "II %", type: "number" },
            { key: "ipi_pct", label: "IPI %", type: "number" },
            { key: "pis_pct", label: "PIS %", type: "number", default: "2.1" },
            { key: "cofins_pct", label: "COFINS %", type: "number", default: "9.65" },
            { key: "icms_pct", label: "ICMS %", type: "number", default: "18" },
            { key: "ex_tarifario", label: "Ex-Tarifário" },
            { key: "notes", label: "Anuentes / restrições" },
          ]}
          columns={[
            { key: "ncm", label: "NCM" }, { key: "description", label: "Descrição" },
            { key: "ii_pct", label: "II%" }, { key: "ipi_pct", label: "IPI%" }, { key: "icms_pct", label: "ICMS%" },
            { key: "ex_tarifario", label: "Ex-Tarif." },
          ]}
          rows={hs} emptyHint="Cadastre NCMs e alíquotas para alimentar o simulador." />
      )}
      {tab === "Parceiros" && (
        <CrudPanel table="trade_partners" title="Parceiros Internacionais"
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "partner_type", label: "Tipo", type: "select", options: PARTNER_TYPES, required: true, default: "supplier" },
            { key: "country", label: "País", placeholder: "CN, US, DE…" },
            { key: "document", label: "Documento / Tax ID" },
            { key: "contact", label: "Contato" }, { key: "email", label: "E-mail" }, { key: "phone", label: "Telefone" },
          ]}
          columns={[
            { key: "name", label: "Nome" },
            { key: "partner_type", label: "Tipo", fmt: (v) => PARTNER_TYPES.find(([k]) => k === v)?.[1] ?? v },
            { key: "country", label: "País" }, { key: "document", label: "Tax ID" },
          ]}
          rows={partners} emptyHint="Fornecedores, tradings, despachantes, armadores, agentes de carga…" />
      )}
      {tab === "Locais (Portos/Aeroportos)" && (
        <CrudPanel table="trade_locations" title="Portos, Aeroportos, Fronteiras e Recintos"
          fields={[
            { key: "name", label: "Nome", required: true, placeholder: "Porto de Santos" },
            { key: "location_type", label: "Tipo", type: "select", options: LOCATION_TYPES, required: true, default: "port" },
            { key: "code", label: "Código", placeholder: "BRSSZ / GRU" },
            { key: "country", label: "País", placeholder: "BR" },
          ]}
          columns={[
            { key: "name", label: "Nome" },
            { key: "location_type", label: "Tipo", fmt: (v) => LOCATION_TYPES.find(([k]) => k === v)?.[1] ?? v },
            { key: "code", label: "Código" }, { key: "country", label: "País" },
          ]}
          rows={locations} emptyHint="Santos, Paranaguá, GRU, Rotterdam, Shanghai…" />
      )}
      {tab === "Documentos" && (
        <CrudPanel table="trade_documents" title="Documentos (Invoice, BL/AWB, DI, DU-E, certificados)"
          fields={[
            { key: "process_id", label: "Processo", type: "fk", fkTable: "trade_processes", fkLabel: "code", required: true },
            { key: "doc_type", label: "Tipo", type: "select", options: DOC_TYPES, required: true },
            { key: "number", label: "Número" },
            { key: "issued_at", label: "Emissão", type: "date" },
            { key: "status", label: "Status", type: "select", options: [["pending","Pendente"],["received","Recebido"],["validated","Validado"],["rejected","Rejeitado"]], default: "pending" },
            { key: "url", label: "Link" },
          ]}
          columns={[
            { key: "doc_type", label: "Tipo", fmt: (v) => DOC_TYPES.find(([k]) => k === v)?.[1] ?? v },
            { key: "number", label: "Número" }, { key: "process_id", label: "Processo" },
            { key: "issued_at", label: "Emissão" }, { key: "status", label: "Status" },
          ]}
          rows={docs} emptyHint="Anexe a documentação de cada processo." />
      )}
      {tab === "Drawback" && (
        <CrudPanel table="drawback_acts" title="Drawback — Atos Concessórios"
          fields={[
            { key: "act_number", label: "Nº do Ato", required: true },
            { key: "act_type", label: "Modalidade", type: "select", options: [["suspension","Suspensão"],["exemption","Isenção"],["restitution","Restituição"]], default: "suspension" },
            { key: "total_value", label: "Valor total", type: "number" },
            { key: "consumed_value", label: "Consumido", type: "number", default: "0" },
            { key: "balance", label: "Saldo", type: "number" },
            { key: "valid_to", label: "Validade", type: "date" },
            { key: "status", label: "Status", type: "select", options: [["active","Ativo"],["closed","Encerrado"],["expired","Vencido"]], default: "active" },
          ]}
          columns={[
            { key: "act_number", label: "Ato" }, { key: "act_type", label: "Modalidade" },
            { key: "total_value", label: "Total", fmt: (v) => v ? brl(v) : "—" },
            { key: "balance", label: "Saldo", fmt: (v) => v ? brl(v) : "—" },
            { key: "valid_to", label: "Validade" }, { key: "status", label: "Status" },
          ]}
          rows={drawback} emptyHint="Registre atos concessórios de drawback para monitorar saldo e prazo." />
      )}
    </div>
  );
}

function KPI({ label, value, hint }: { label: string; value: string; hint?: string }) {
  return (
    <div className="card p-4">
      <div className="text-xs muted font-semibold uppercase">{label}</div>
      <div className="text-2xl font-bold mt-1">{value}</div>
      {hint && <div className="text-xs muted mt-0.5">{hint}</div>}
    </div>
  );
}

function Painel({ dash }: { dash: any }) {
  const d = dash ?? {};
  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
      <KPI label="Importações abertas" value={String(d.imports_open ?? 0)} />
      <KPI label="Exportações abertas" value={String(d.exports_open ?? 0)} />
      <KPI label="Na aduana" value={String(d.in_customs ?? 0)} hint="processos em desembaraço" />
      <KPI label="FOB em aberto" value={brl(Number(d.fob_open ?? 0))} />
      <KPI label="Parceiros" value={String(d.partners ?? 0)} />
      <KPI label="Portos/Aeroportos" value={String(d.locations ?? 0)} />
      <KPI label="Saldo drawback" value={brl(Number(d.drawback_balance ?? 0))} hint={`${d.drawback_expiring ?? 0} vencendo em 60d`} />
      <KPI label="Docs pendentes" value={String(d.pending_docs ?? 0)} />
    </div>
  );
}

function Simulador() {
  const supabase = useMemo(() => createClient(), []);
  const [f, setF] = useState({ fob: "100000", freight: "8000", insurance: "1000", ii: "16", ipi: "5", pis: "2.1", cofins: "9.65", icms: "18", expenses: "5000" });
  const [res, setRes] = useState<any>(null);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const set = (k: string) => (e: any) => setF((p) => ({ ...p, [k]: e.target.value }));

  async function run() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { data, error } = await supabase.rpc("import_cost_simulator", {
      p_company: COMPANY, p_fob: Number(f.fob) || 0, p_freight: Number(f.freight) || 0, p_insurance: Number(f.insurance) || 0,
      p_ii_pct: Number(f.ii) || 0, p_ipi_pct: Number(f.ipi) || 0, p_pis_pct: Number(f.pis) || 0,
      p_cofins_pct: Number(f.cofins) || 0, p_icms_pct: Number(f.icms) || 0, p_expenses: Number(f.expenses) || 0,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setRes(data);
  }

  const F = ({ k, label, suffix }: { k: keyof typeof f; label: string; suffix?: string }) => (
    <div>
      <label className="text-xs font-semibold muted">{label}{suffix ? ` (${suffix})` : ""}</label>
      <input type="number" value={f[k]} onChange={set(k)}
        className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
    </div>
  );

  const rows: [string, number, string?][] = res ? [
    ["Valor CIF (FOB + frete + seguro)", res.cif],
    ["II — Imposto de Importação", res.ii],
    ["IPI", res.ipi],
    ["PIS-Importação", res.pis],
    ["COFINS-Importação", res.cofins],
    ["ICMS (por dentro)", res.icms],
    ["Despesas aduaneiras", res.expenses],
  ] : [];

  return (
    <div className="grid lg:grid-cols-2 gap-4">
      <div className="card p-4 space-y-3">
        <div className="font-semibold">Parâmetros da operação</div>
        <div className="grid grid-cols-3 gap-3">
          <F k="fob" label="FOB" /><F k="freight" label="Frete" /><F k="insurance" label="Seguro" />
          <F k="ii" label="II" suffix="%" /><F k="ipi" label="IPI" suffix="%" /><F k="icms" label="ICMS" suffix="%" />
          <F k="pis" label="PIS" suffix="%" /><F k="cofins" label="COFINS" suffix="%" /><F k="expenses" label="Despesas" />
        </div>
        {err && <div className="text-sm text-red-500">{err}</div>}
        <button onClick={run} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Calculando…" : "Simular custo nacionalizado"}</button>
        <p className="text-xs muted">Valores na moeda dos parâmetros. ICMS calculado “por dentro”. Alíquotas conforme NCM — consulte a aba Classificação.</p>
      </div>

      <div className="card p-4">
        <div className="font-semibold mb-2">Resultado</div>
        {!res ? <p className="text-sm muted">Preencha e clique em simular.</p> : (
          <div className="space-y-1">
            {rows.map(([lbl, val]) => (
              <div key={lbl} className="flex justify-between text-sm py-1 border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                <span className="muted">{lbl}</span><span className="font-medium tabular-nums">{brl(Number(val))}</span>
              </div>
            ))}
            <div className="flex justify-between text-sm py-2 mt-1">
              <span className="font-semibold">Total de tributos</span><span className="font-semibold tabular-nums text-amber-600">{brl(Number(res.total_taxes))}</span>
            </div>
            <div className="flex justify-between items-baseline pt-2 border-t" style={{ borderColor: "var(--border)" }}>
              <span className="font-bold">Custo nacionalizado</span>
              <span className="text-xl font-bold tabular-nums text-brand-600">{brl(Number(res.landed_cost))}</span>
            </div>
            {res.markup_over_fob != null && <div className="text-xs muted text-right mt-1">+{res.markup_over_fob}% sobre o FOB</div>}
          </div>
        )}
      </div>
    </div>
  );
}
