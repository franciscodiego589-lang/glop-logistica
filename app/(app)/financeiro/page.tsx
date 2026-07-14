import { KpiCard } from "@/components/ui/KpiCard";
import { VitrineBanner } from "@/components/VitrineBanner";
import FinanceWorkbench from "@/components/financeiro/FinanceWorkbench";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";
const money = (n: number) => n.toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 });

type Kpis = { payable_open?: number; receivable_open?: number; payable_overdue?: number; receivable_overdue?: number; cash_position?: number; bank_accounts?: number };

export default async function FinanceiroPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  let kpis: Kpis = {};
  let payables: any[] = [], receivables: any[] = [], suppliers: any[] = [], customers: any[] = [], banks: any[] = [], costCenters: any[] = [];
  const adv: any = { fin: {}, forecast: [], consolidated: {}, treasury: [], statements: [], credit: [], dunning: [], allocations: [], budgets: [], intercompany: [] };

  if (supabase && company) {
    const [{ data: k }, pa, re, su, cu, ba, cc] = await Promise.all([
      supabase.rpc("finance_kpis", { p_company: company }),
      supabase.from("payables").select("id,code,description,supplier_id,amount,paid_amount,status,due_date,purchase_order_id").eq("company_id", company).is("deleted_at", null).order("due_date").limit(3000),
      supabase.from("receivables").select("id,code,description,customer_id,amount,received_amount,status,due_date,outbound_order_id").eq("company_id", company).is("deleted_at", null).order("due_date").limit(3000),
      supabase.from("suppliers").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(3000),
      supabase.from("customers").select("id,name").eq("company_id", company).is("deleted_at", null).order("name").limit(3000),
      supabase.from("bank_accounts").select("id,name,bank_name,account_type,agency,account_number,pix_key,current_balance").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
      supabase.from("cost_centers").select("id,code,name,cc_type,parent_id").eq("company_id", company).is("deleted_at", null).order("name").limit(1000),
    ]);
    kpis = (k as Kpis) ?? {};
    payables = pa.data ?? []; receivables = re.data ?? []; suppliers = su.data ?? []; customers = cu.data ?? []; banks = ba.data ?? []; costCenters = cc.data ?? [];

    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", company).single();
    const tenant = (comp as any)?.tenant_id;
    const [fd, fc, cs, tp, st, cr, du, al, bu, ic] = await Promise.all([
      supabase.rpc("finance_dashboard", { p_company: company }),
      supabase.rpc("forecast_cashflow", { p_company: company, p_days: 30 }),
      tenant ? supabase.rpc("consolidated_finance", { p_tenant: tenant }) : Promise.resolve({ data: {} } as any),
      supabase.from("treasury_positions").select("*").eq("company_id", company).is("deleted_at", null).order("maturity_date").limit(500),
      supabase.from("bank_statements").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
      supabase.from("customer_credit").select("*").eq("company_id", company).is("deleted_at", null).order("score").limit(1000),
      supabase.from("dunning_rules").select("*").eq("company_id", company).is("deleted_at", null).order("days_overdue").limit(200),
      supabase.from("allocation_rules").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
      supabase.from("financial_budgets").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
      supabase.from("intercompany_transactions").select("*").eq("company_id", company).is("deleted_at", null).order("occurred_at", { ascending: false }).limit(500),
    ]);
    adv.fin = fd.data ?? {}; adv.forecast = fc.data ?? []; adv.consolidated = cs.data ?? {};
    adv.treasury = tp.data ?? []; adv.statements = st.data ?? []; adv.credit = cr.data ?? [];
    adv.dunning = du.data ?? []; adv.allocations = al.data ?? []; adv.budgets = bu.data ?? []; adv.intercompany = ic.data ?? [];
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">💰</div>
        <div>
          <h1 className="text-xl font-bold">Financeiro / Tesouraria</h1>
          <p className="text-sm muted">Volume 11 · Contas a pagar/receber, bancos, fluxo de caixa</p>
        </div>
      </div>

      {!supabase && <VitrineBanner />}

      <div className="grid grid-cols-2 lg:grid-cols-5 gap-3">
        <KpiCard label="A pagar (aberto)" value={kpis.payable_open != null ? money(kpis.payable_open) : "—"} />
        <KpiCard label="A receber (aberto)" value={kpis.receivable_open != null ? money(kpis.receivable_open) : "—"} />
        <KpiCard label="Posição de caixa" value={kpis.cash_position != null ? money(kpis.cash_position) : "—"} accent />
        <KpiCard label="Vencido a pagar" value={kpis.payable_overdue != null ? money(kpis.payable_overdue) : "—"} />
        <KpiCard label="Vencido a receber" value={kpis.receivable_overdue != null ? money(kpis.receivable_overdue) : "—"} />
      </div>

      <FinanceWorkbench data={{ payables, receivables, suppliers, customers, banks, costCenters, cashPosition: kpis.cash_position ?? 0, ...adv }} />
    </div>
  );
}
