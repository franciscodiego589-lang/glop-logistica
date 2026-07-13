"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import ProductForm from "./ProductForm";
import RelationEditor from "./RelationEditor";

const SECTIONS = ["Dados", "Fornecedores", "Custos", "Tributos", "Mídias"] as const;

export default function ProductEditor({ product }: { product: any }) {
  const router = useRouter();
  const supabase = useMemo(() => createClient(), []);
  const [sec, setSec] = useState<(typeof SECTIONS)[number]>("Dados");
  const [confirming, setConfirming] = useState(false);
  const tenantId = product.tenant_id as string;
  const pid = product.id as string;

  async function softDelete() {
    if (!supabase) return;
    await supabase.from("products").update({ deleted_at: new Date().toISOString(), reason_deleted: "excluído na tela", active: false }).eq("id", pid);
    router.push("/produtos"); router.refresh();
  }

  return (
    <div className="space-y-4 max-w-4xl">
      <div className="flex items-center gap-3">
        <Link href="/produtos" className="muted hover:underline text-sm">← Cadastro Mestre</Link>
        <h1 className="text-xl font-bold">{product.name}</h1>
        <span className="text-xs px-2 py-0.5 rounded-md bg-brand-500/15 text-brand-500 font-mono">{product.sku ?? product.code ?? "—"}</span>
        <span className="ml-auto text-xs muted">Qualidade: <b>{Math.round(product.data_quality_score)}%</b></span>
      </div>

      <div className="flex gap-1 flex-wrap">
        {SECTIONS.map((s) => (
          <button key={s} onClick={() => setSec(s)}
            className={`px-3 py-1.5 rounded-lg text-sm ${sec === s ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{s}</button>
        ))}
      </div>

      {sec === "Dados" && <ProductForm productId={pid} initial={product} />}

      {sec === "Fornecedores" && (
        <RelationEditor title="Fornecedores do produto" table="product_suppliers" productId={pid} tenantId={tenantId}
          fields={[
            { key: "supplier_id", label: "Fornecedor", type: "fk", fkTable: "suppliers" },
            { key: "lead_time_days", label: "Lead time (d)", type: "number" },
            { key: "moq", label: "MOQ", type: "number" },
            { key: "last_price", label: "Último preço", type: "number" },
          ]}
          rowLabel={(r, m) => `${m.supplier_id?.[r.supplier_id] ?? "?"} · lead ${r.lead_time_days ?? "—"}d · MOQ ${r.moq ?? "—"} · R$ ${r.last_price ?? "—"}`} />
      )}

      {sec === "Custos" && (
        <RelationEditor title="Custos" table="product_costs" productId={pid} tenantId={tenantId}
          fields={[
            { key: "cost_kind", label: "Tipo", type: "select", options: [["average","Médio"],["last","Último"],["standard","Padrão"],["replacement","Reposição"],["import","Importação"],["freight","Frete"],["financial","Financeiro"]] },
            { key: "amount", label: "Valor (R$)", type: "number" },
            { key: "currency", label: "Moeda", type: "text", default: "BRL" },
          ]}
          rowLabel={(r) => `${r.cost_kind}: ${r.currency ?? "BRL"} ${r.amount}`} />
      )}

      {sec === "Tributos" && (
        <RelationEditor title="Tributação" table="product_taxes" productId={pid} tenantId={tenantId}
          fields={[
            { key: "tax_kind", label: "Imposto", type: "select", options: [["IPI","IPI"],["ICMS","ICMS"],["ICMS_ST","ICMS-ST"],["PIS","PIS"],["COFINS","COFINS"],["ISS","ISS"],["II","II"]] },
            { key: "rate", label: "Alíquota (%)", type: "number" },
            { key: "cst", label: "CST", type: "text" },
          ]}
          rowLabel={(r) => `${r.tax_kind}: ${r.rate ?? "—"}% ${r.cst ? "· CST " + r.cst : ""}`} />
      )}

      {sec === "Mídias" && (
        <RelationEditor title="Fotos e mídias" table="product_media" productId={pid} tenantId={tenantId}
          fields={[
            { key: "media_kind", label: "Tipo", type: "select", options: [["main","Principal"],["technical","Técnica"],["commercial","Comercial"],["packaging","Embalagem"],["pallet","Pallet"],["image360","360°"],["model3d","3D"],["video","Vídeo"],["manual","Manual PDF"]] },
            { key: "url", label: "URL", type: "text" },
            { key: "title", label: "Título", type: "text" },
          ]}
          rowLabel={(r) => `${r.media_kind}: ${r.title || r.url}`} />
      )}

      <div className="card p-4 border-red-500/30">
        <div className="font-semibold text-red-500 mb-1">Zona de risco</div>
        <p className="text-sm muted mb-3">Excluir faz soft delete (o produto some das listas mas o histórico é preservado, conforme a Constituição).</p>
        {!confirming ? (
          <button onClick={() => setConfirming(true)} className="px-4 py-2 rounded-lg border border-red-500/40 text-red-500 text-sm hover:bg-red-500/10">Excluir produto</button>
        ) : (
          <div className="flex gap-2">
            <button onClick={softDelete} className="px-4 py-2 rounded-lg bg-red-600 text-white text-sm font-semibold">Confirmar exclusão</button>
            <button onClick={() => setConfirming(false)} className="px-4 py-2 rounded-lg border text-sm" style={{ borderColor: "var(--border)" }}>Cancelar</button>
          </div>
        )}
      </div>
    </div>
  );
}
