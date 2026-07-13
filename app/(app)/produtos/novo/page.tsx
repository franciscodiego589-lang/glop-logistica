"use client";
import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const TABS = ["Identificação", "Classificação", "Dimensões", "Tributação", "Estoque"] as const;
type Opt = { id: string; name: string };

export default function NovoProdutoPage() {
  const router = useRouter();
  const supabase = useMemo(() => createClient(), []);
  const [tab, setTab] = useState<(typeof TABS)[number]>("Identificação");
  const [cats, setCats] = useState<Opt[]>([]);
  const [brands, setBrands] = useState<Opt[]>([]);
  const [tenantId, setTenantId] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [f, setF] = useState<Record<string, any>>({
    name: "", sku: "", code: "", barcode: "", gtin: "", short_description: "",
    product_type: "finished_good", base_uom_code: "un",
    category_id: "", brand_id: "", model: "", segment: "", abc_class: "none", xyz_class: "none",
    ncm: "", cest: "", cfop_default: "", tax_origin: "",
    net_weight_g: "", gross_weight_g: "", length_mm: "", width_mm: "", height_mm: "", cubage_m3: "", stack_max: "",
    cost_price: "", sale_price: "", min_stock: "", max_stock: "", reorder_point: "", safety_stock: "", lead_time_days: "",
    requires_lot: false, requires_validity: false, requires_serial: false, is_perishable: false, is_hazardous: false,
  });
  const set = (k: string, v: any) => setF((p) => ({ ...p, [k]: v }));

  useEffect(() => {
    if (!supabase || !COMPANY) return;
    (async () => {
      const [{ data: c }, { data: b }, { data: comp }] = await Promise.all([
        supabase.from("product_categories").select("id,name").eq("company_id", COMPANY).is("deleted_at", null).order("name"),
        supabase.from("product_brands").select("id,name").eq("company_id", COMPANY).is("deleted_at", null).order("name"),
        supabase.from("companies").select("tenant_id").eq("id", COMPANY).single(),
      ]);
      setCats(c ?? []); setBrands(b ?? []); setTenantId((comp as any)?.tenant_id ?? null);
    })();
  }, [supabase]);

  const num = (v: any) => (v === "" || v == null ? null : Number(v));

  async function onSave() {
    setError(null);
    if (!supabase) { setError("Banco não conectado."); return; }
    if (!f.name.trim()) { setError("Nome é obrigatório."); setTab("Identificação"); return; }
    if (!tenantId) { setError("Empresa não resolvida."); return; }
    setSaving(true);
    const payload: Record<string, any> = {
      tenant_id: tenantId, company_id: COMPANY,
      name: f.name.trim(), sku: f.sku || null, code: f.code || null, barcode: f.barcode || null, gtin: f.gtin || null,
      short_description: f.short_description || null, product_type: f.product_type, base_uom_code: f.base_uom_code || "un",
      category_id: f.category_id || null, brand_id: f.brand_id || null, model: f.model || null, segment: f.segment || null,
      abc_class: f.abc_class, xyz_class: f.xyz_class,
      ncm: f.ncm || null, cest: f.cest || null, cfop_default: f.cfop_default || null, tax_origin: f.tax_origin || null,
      net_weight_g: num(f.net_weight_g), gross_weight_g: num(f.gross_weight_g),
      length_mm: num(f.length_mm), width_mm: num(f.width_mm), height_mm: num(f.height_mm),
      cubage_m3: num(f.cubage_m3), stack_max: num(f.stack_max),
      cost_price: num(f.cost_price), sale_price: num(f.sale_price),
      min_stock: num(f.min_stock) ?? 0, max_stock: num(f.max_stock), reorder_point: num(f.reorder_point),
      safety_stock: num(f.safety_stock), lead_time_days: num(f.lead_time_days),
      requires_lot: f.requires_lot, requires_validity: f.requires_validity, requires_serial: f.requires_serial,
      is_perishable: f.is_perishable, is_hazardous: f.is_hazardous,
    };
    const { error } = await supabase.from("products").insert(payload);
    setSaving(false);
    if (error) { setError(error.message); return; }
    router.push("/produtos");
    router.refresh();
  }

  return (
    <div className="space-y-4 max-w-4xl">
      <div className="flex items-center gap-3">
        <Link href="/produtos" className="muted hover:underline text-sm">← Cadastro Mestre</Link>
        <h1 className="text-xl font-bold">Novo produto</h1>
      </div>

      <div className="card">
        <div className="flex gap-1 p-2 border-b overflow-x-auto" style={{ borderColor: "var(--border)" }}>
          {TABS.map((t) => (
            <button key={t} onClick={() => setTab(t)}
              className={`px-3 py-1.5 rounded-lg text-sm whitespace-nowrap ${tab === t ? "bg-brand-600 text-white" : "hover:bg-black/5 dark:hover:bg-white/5"}`}>
              {t}
            </button>
          ))}
        </div>

        <div className="p-4">
          {tab === "Identificação" && (
            <Grid>
              <Field label="Nome *" span2><Input value={f.name} onChange={(v) => set("name", v)} /></Field>
              <Field label="SKU"><Input value={f.sku} onChange={(v) => set("sku", v)} /></Field>
              <Field label="Código interno"><Input value={f.code} onChange={(v) => set("code", v)} /></Field>
              <Field label="Código de barras"><Input value={f.barcode} onChange={(v) => set("barcode", v)} /></Field>
              <Field label="GTIN"><Input value={f.gtin} onChange={(v) => set("gtin", v)} /></Field>
              <Field label="Descrição curta" span2><Input value={f.short_description} onChange={(v) => set("short_description", v)} /></Field>
            </Grid>
          )}
          {tab === "Classificação" && (
            <Grid>
              <Field label="Tipo">
                <Select value={f.product_type} onChange={(v) => set("product_type", v)}
                  options={[["finished_good","Acabado"],["raw_material","Matéria-prima"],["component","Componente"],["packaging","Embalagem"],["consumable","Consumível"],["kit","Kit"],["service","Serviço"],["other","Outro"]]} />
              </Field>
              <Field label="Categoria"><Select value={f.category_id} onChange={(v) => set("category_id", v)} options={[["","—"], ...cats.map((c) => [c.id, c.name] as [string,string])]} /></Field>
              <Field label="Marca"><Select value={f.brand_id} onChange={(v) => set("brand_id", v)} options={[["","—"], ...brands.map((b) => [b.id, b.name] as [string,string])]} /></Field>
              <Field label="Modelo"><Input value={f.model} onChange={(v) => set("model", v)} /></Field>
              <Field label="Segmento"><Input value={f.segment} onChange={(v) => set("segment", v)} /></Field>
              <Field label="Curva ABC"><Select value={f.abc_class} onChange={(v) => set("abc_class", v)} options={[["none","—"],["A","A"],["B","B"],["C","C"]]} /></Field>
              <Field label="Curva XYZ"><Select value={f.xyz_class} onChange={(v) => set("xyz_class", v)} options={[["none","—"],["X","X"],["Y","Y"],["Z","Z"]]} /></Field>
            </Grid>
          )}
          {tab === "Dimensões" && (
            <Grid>
              <Field label="Peso líquido (g)"><Input type="number" value={f.net_weight_g} onChange={(v) => set("net_weight_g", v)} /></Field>
              <Field label="Peso bruto (g)"><Input type="number" value={f.gross_weight_g} onChange={(v) => set("gross_weight_g", v)} /></Field>
              <Field label="Comprimento (mm)"><Input type="number" value={f.length_mm} onChange={(v) => set("length_mm", v)} /></Field>
              <Field label="Largura (mm)"><Input type="number" value={f.width_mm} onChange={(v) => set("width_mm", v)} /></Field>
              <Field label="Altura (mm)"><Input type="number" value={f.height_mm} onChange={(v) => set("height_mm", v)} /></Field>
              <Field label="Cubagem (m³)"><Input type="number" value={f.cubage_m3} onChange={(v) => set("cubage_m3", v)} /></Field>
              <Field label="Empilhamento máx."><Input type="number" value={f.stack_max} onChange={(v) => set("stack_max", v)} /></Field>
            </Grid>
          )}
          {tab === "Tributação" && (
            <Grid>
              <Field label="NCM"><Input value={f.ncm} onChange={(v) => set("ncm", v)} /></Field>
              <Field label="CEST"><Input value={f.cest} onChange={(v) => set("cest", v)} /></Field>
              <Field label="CFOP padrão"><Input value={f.cfop_default} onChange={(v) => set("cfop_default", v)} /></Field>
              <Field label="Origem"><Input value={f.tax_origin} onChange={(v) => set("tax_origin", v)} /></Field>
            </Grid>
          )}
          {tab === "Estoque" && (
            <Grid>
              <Field label="Custo (R$)"><Input type="number" value={f.cost_price} onChange={(v) => set("cost_price", v)} /></Field>
              <Field label="Preço venda (R$)"><Input type="number" value={f.sale_price} onChange={(v) => set("sale_price", v)} /></Field>
              <Field label="Estoque mínimo"><Input type="number" value={f.min_stock} onChange={(v) => set("min_stock", v)} /></Field>
              <Field label="Estoque máximo"><Input type="number" value={f.max_stock} onChange={(v) => set("max_stock", v)} /></Field>
              <Field label="Ponto de pedido"><Input type="number" value={f.reorder_point} onChange={(v) => set("reorder_point", v)} /></Field>
              <Field label="Estoque de segurança"><Input type="number" value={f.safety_stock} onChange={(v) => set("safety_stock", v)} /></Field>
              <Field label="Lead time (dias)"><Input type="number" value={f.lead_time_days} onChange={(v) => set("lead_time_days", v)} /></Field>
              <Field label="Requisitos" span2>
                <div className="flex flex-wrap gap-3 text-sm">
                  <Check label="Controla lote" v={f.requires_lot} on={(v) => set("requires_lot", v)} />
                  <Check label="Controla validade" v={f.requires_validity} on={(v) => set("requires_validity", v)} />
                  <Check label="Controla série" v={f.requires_serial} on={(v) => set("requires_serial", v)} />
                  <Check label="Perecível" v={f.is_perishable} on={(v) => set("is_perishable", v)} />
                  <Check label="Perigoso" v={f.is_hazardous} on={(v) => set("is_hazardous", v)} />
                </div>
              </Field>
            </Grid>
          )}
        </div>

        <div className="p-4 border-t flex items-center gap-3" style={{ borderColor: "var(--border)" }}>
          {error && <div className="text-sm text-red-500">{error}</div>}
          <div className="ml-auto flex gap-2">
            <Link href="/produtos" className="px-4 py-2 rounded-lg border text-sm" style={{ borderColor: "var(--border)" }}>Cancelar</Link>
            <button onClick={onSave} disabled={saving} className="px-4 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold disabled:opacity-60">
              {saving ? "Salvando…" : "Salvar produto"}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function Grid({ children }: { children: React.ReactNode }) {
  return <div className="grid md:grid-cols-2 gap-4">{children}</div>;
}
function Field({ label, span2, children }: { label: string; span2?: boolean; children: React.ReactNode }) {
  return (
    <div className={span2 ? "md:col-span-2" : ""}>
      <label className="text-xs font-semibold muted">{label}</label>
      <div className="mt-1">{children}</div>
    </div>
  );
}
function Input({ value, onChange, type = "text" }: { value: any; onChange: (v: string) => void; type?: string }) {
  return (
    <input type={type} value={value} onChange={(e) => onChange(e.target.value)}
      className="w-full border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500"
      style={{ borderColor: "var(--border)" }} />
  );
}
function Select({ value, onChange, options }: { value: any; onChange: (v: string) => void; options: [string, string][] }) {
  return (
    <select value={value} onChange={(e) => onChange(e.target.value)}
      className="w-full border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500"
      style={{ borderColor: "var(--border)" }}>
      {options.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
    </select>
  );
}
function Check({ label, v, on }: { label: string; v: boolean; on: (v: boolean) => void }) {
  return (
    <label className="flex items-center gap-2 cursor-pointer">
      <input type="checkbox" checked={v} onChange={(e) => on(e.target.checked)} />
      {label}
    </label>
  );
}
