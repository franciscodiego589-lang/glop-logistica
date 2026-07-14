"use client";
import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

// Define o endereço-padrão de armazenagem (products.default_location_id).
export default function LocationPicker({ productId, current }: { productId: string; current: string | null }) {
  const supabase = useMemo(() => createClient(), []);
  const [locs, setLocs] = useState<{ id: string; code: string; warehouse: string }[]>([]);
  const [value, setValue] = useState(current ?? "");
  const [msg, setMsg] = useState<string | null>(null);

  useEffect(() => {
    if (!supabase) return;
    (async () => {
      const { data } = await supabase
        .from("storage_locations")
        .select("id, code, warehouses(name)")
        .eq("company_id", COMPANY).is("deleted_at", null).order("code").limit(500);
      setLocs((data ?? []).map((l: any) => ({ id: l.id, code: l.code, warehouse: l.warehouses?.name ?? "" })));
    })();
  }, [supabase]);

  async function save() {
    if (!supabase) return;
    const { error } = await supabase.from("products").update({ default_location_id: value || null }).eq("id", productId);
    setMsg(error ? error.message : "Localização salva ✓");
  }

  return (
    <div className="card p-4">
      <div className="font-semibold mb-2">Endereço-padrão de armazenagem</div>
      {locs.length === 0 ? (
        <p className="text-sm muted">Nenhuma posição cadastrada ainda. Cadastre bins no módulo <b>WMS / Armazém</b> para endereçar este produto.</p>
      ) : (
        <div className="flex gap-2 items-end max-w-lg">
          <div className="flex-1">
            <label className="text-xs font-semibold muted">Posição (bin)</label>
            <select value={value} onChange={(e) => setValue(e.target.value)}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="">— sem endereço —</option>
              {locs.map((l) => <option key={l.id} value={l.id}>{l.warehouse ? l.warehouse + " · " : ""}{l.code}</option>)}
            </select>
          </div>
          <button onClick={save} className="px-4 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold">Salvar</button>
        </div>
      )}
      {msg && <div className="text-sm text-green-500 mt-2">{msg}</div>}
    </div>
  );
}
