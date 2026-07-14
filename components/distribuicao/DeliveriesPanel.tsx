"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

const DELIVERY_STATUS: Record<string, { label: string; cls: string }> = {
  pending: { label: "Pendente", cls: "bg-slate-500/15 text-slate-400" },
  out_for_delivery: { label: "Saiu p/ entrega", cls: "bg-amber-500/15 text-amber-500" },
  delivered: { label: "Entregue", cls: "bg-green-500/15 text-green-500" },
  failed: { label: "Falhou", cls: "bg-red-500/15 text-red-500" },
  returned: { label: "Devolvida", cls: "bg-red-500/15 text-red-500" },
  canceled: { label: "Cancelada", cls: "bg-slate-500/15 text-slate-400" },
};

type Delivery = { id: string; code: string | null; status: string; address: string | null; city: string | null; uf: string | null; scheduled_date: string | null; receiver_name: string | null; customer_id: string | null };

export default function DeliveriesPanel({ deliveries, customers }: { deliveries: Delivery[]; customers: any[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const custName = useMemo(() => Object.fromEntries(customers.map((c) => [c.id, c.name])), [customers]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [f, setF] = useState({ code: "", customer_id: "", address: "", city: "", uf: "", scheduled_date: "" });

  async function create() {
    if (!supabase) return;
    setBusy(true); setErr(null);
    const { data: comp } = await supabase.from("companies").select("tenant_id").eq("id", COMPANY).single();
    const tenant_id = (comp as any)?.tenant_id ?? null;
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { error } = await supabase.from("deliveries").insert({
      tenant_id, company_id: COMPANY, status: "pending",
      code: f.code.trim() || null, customer_id: f.customer_id || null,
      address: f.address.trim() || null, city: f.city.trim() || null, uf: f.uf.trim().toUpperCase() || null,
      scheduled_date: f.scheduled_date || null,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setF({ code: "", customer_id: "", address: "", city: "", uf: "", scheduled_date: "" }); setOpen(false); router.refresh();
  }

  async function setStatus(id: string, status: string) {
    if (!supabase) return;
    const patch: Record<string, any> = { status };
    if (status === "delivered") patch.delivered_at = new Date().toISOString();
    await supabase.from("deliveries").update(patch).eq("id", id);
    router.refresh();
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold">Entregas (last-mile) <span className="muted font-normal">({deliveries.length})</span></div>
        <button onClick={() => { setOpen((o) => !o); setErr(null); }}
          className="ml-auto text-sm px-3 py-2 rounded-lg bg-brand-600 text-white hover:bg-brand-700 font-semibold">{open ? "Cancelar" : "+ Nova entrega"}</button>
      </div>
      {open && (
        <div className="card p-4 space-y-3">
          <div className="grid md:grid-cols-3 gap-3">
            <div><label className="text-xs font-semibold muted">Código</label>
              <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="ENT-0001"
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div><label className="text-xs font-semibold muted">Cliente</label>
              <select value={f.customer_id} onChange={(e) => setF({ ...f, customer_id: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
                <option value="">—</option>{customers.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
              </select></div>
            <div><label className="text-xs font-semibold muted">Data agendada</label>
              <input type="date" value={f.scheduled_date} onChange={(e) => setF({ ...f, scheduled_date: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div className="md:col-span-2"><label className="text-xs font-semibold muted">Endereço</label>
              <input value={f.address} onChange={(e) => setF({ ...f, address: e.target.value })}
                className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            <div className="grid grid-cols-2 gap-2">
              <div><label className="text-xs font-semibold muted">Cidade</label>
                <input value={f.city} onChange={(e) => setF({ ...f, city: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
              <div><label className="text-xs font-semibold muted">UF</label>
                <input value={f.uf} maxLength={2} onChange={(e) => setF({ ...f, uf: e.target.value })}
                  className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} /></div>
            </div>
          </div>
          {err && <div className="text-sm text-red-500">{err}</div>}
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "Salvando…" : "Criar entrega"}</button>
        </div>
      )}
      {deliveries.length === 0 ? (
        <p className="text-sm muted px-1">Nenhuma entrega ainda.</p>
      ) : (
        <div className="card p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-3">Código</th><th className="px-3">Cliente</th><th className="px-3">Destino</th><th className="px-3">Agendada</th><th className="px-3">Status</th></tr></thead>
            <tbody>
              {deliveries.map((d) => (
                <tr key={d.id} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                  <td className="py-2 px-3 font-mono">{d.code ?? d.id.slice(0, 8)}</td>
                  <td className="px-3 muted">{d.customer_id ? custName[d.customer_id] ?? "—" : "—"}</td>
                  <td className="px-3">{[d.city, d.uf].filter(Boolean).join(" / ") || d.address || "—"}</td>
                  <td className="px-3">{d.scheduled_date ?? "—"}</td>
                  <td className="px-3">
                    <select value={d.status} onChange={(e) => setStatus(d.id, e.target.value)}
                      className={`text-xs px-2 py-0.5 rounded-md font-semibold bg-transparent outline-none ${DELIVERY_STATUS[d.status]?.cls ?? ""}`}>
                      {Object.entries(DELIVERY_STATUS).map(([v, o]) => <option key={v} value={v}>{o.label}</option>)}
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
