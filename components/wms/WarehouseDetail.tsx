"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

type Zone = { id: string; code: string; name: string; zone_type: string; temperature_controlled: boolean };
type Loc = {
  id: string; code: string; location_type: string; status: string; zone_id: string | null;
  aisle: string | null; rack: string | null; level: string | null; position: string | null; is_pickable: boolean;
};

const ZONE_TYPES: [string, string][] = [
  ["receiving", "Recebimento"], ["storage", "Armazenagem"], ["picking", "Picking"],
  ["packing", "Packing"], ["shipping", "Expedição"], ["quarantine", "Quarentena"],
  ["returns", "Devoluções"], ["production", "Produção"], ["transit", "Trânsito"],
];
const STATUS: Record<string, { label: string; cls: string }> = {
  available: { label: "Disponível", cls: "bg-green-500/15 text-green-500" },
  blocked: { label: "Bloqueado", cls: "bg-red-500/15 text-red-500" },
  full: { label: "Lotado", cls: "bg-amber-500/15 text-amber-500" },
  maintenance: { label: "Manutenção", cls: "bg-slate-500/15 text-slate-400" },
};
const zoneTypeLabel = (t: string) => ZONE_TYPES.find(([v]) => v === t)?.[1] ?? t;

// Expande "A-D", "1-10" (range) ou "A,B,C" (lista) numa sequência de tokens.
function expand(spec: string): string[] {
  const s = spec.trim();
  if (!s) return [];
  if (s.includes(",")) return s.split(",").map((x) => x.trim()).filter(Boolean);
  const m = s.match(/^(.+?)\s*-\s*(.+)$/);
  if (m) {
    const [, a, b] = m;
    if (/^\d+$/.test(a) && /^\d+$/.test(b)) {
      const pad = Math.max(a.length, b.length);
      const lo = Math.min(+a, +b), hi = Math.max(+a, +b);
      return Array.from({ length: hi - lo + 1 }, (_, i) => String(lo + i).padStart(pad, "0"));
    }
    if (/^[A-Za-z]$/.test(a) && /^[A-Za-z]$/.test(b)) {
      const lo = a.toUpperCase().charCodeAt(0), hi = b.toUpperCase().charCodeAt(0);
      const [s0, s1] = [Math.min(lo, hi), Math.max(lo, hi)];
      return Array.from({ length: s1 - s0 + 1 }, (_, i) => String.fromCharCode(s0 + i));
    }
  }
  return [s];
}

export default function WarehouseDetail({
  warehouse, company, zones: zones0, locations: locs0,
}: { warehouse: any; company: string; zones: Zone[]; locations: Loc[] }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [tab, setTab] = useState<"bins" | "zones">("bins");
  const zoneName = useMemo(() => Object.fromEntries(zones0.map((z) => [z.id, z.code])), [zones0]);

  async function tenantId(): Promise<string | null> {
    if (!supabase) return null;
    const { data } = await supabase.from("companies").select("tenant_id").eq("id", company).single();
    return (data as any)?.tenant_id ?? null;
  }

  return (
    <div className="space-y-4 max-w-5xl">
      <div className="flex items-center gap-3 flex-wrap">
        <Link href="/wms" className="muted hover:underline text-sm">← WMS / Armazém</Link>
        <h1 className="text-xl font-bold">{warehouse.name}</h1>
        {warehouse.code && <span className="text-xs px-2 py-0.5 rounded-md bg-brand-500/15 text-brand-500 font-mono">{warehouse.code}</span>}
        <span className="ml-auto text-sm muted">{zones0.length} zonas · {locs0.length} bins</span>
      </div>

      <div className="flex gap-1">
        {(["bins", "zones"] as const).map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>
            {t === "bins" ? "Endereços (bins)" : "Zonas"}
          </button>
        ))}
      </div>

      {tab === "zones"
        ? <ZonesPanel supabase={supabase} company={company} warehouseId={warehouse.id} zones={zones0} getTenant={tenantId} onDone={() => router.refresh()} />
        : <BinsPanel supabase={supabase} company={company} warehouseId={warehouse.id} zones={zones0} zoneName={zoneName} locations={locs0} getTenant={tenantId} onDone={() => router.refresh()} />}
    </div>
  );
}

/* ── ZONAS ─────────────────────────────────────────────────────────── */
function ZonesPanel({ supabase, company, warehouseId, zones, getTenant, onDone }: any) {
  const [f, setF] = useState({ code: "", name: "", zone_type: "storage", temp: false });
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  async function create() {
    if (!supabase || !f.code.trim() || !f.name.trim()) { setErr("Código e nome são obrigatórios."); return; }
    setBusy(true); setErr(null);
    const tenant_id = await getTenant();
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const { error } = await supabase.from("storage_zones").insert({
      tenant_id, company_id: company, warehouse_id: warehouseId,
      code: f.code.trim(), name: f.name.trim(), zone_type: f.zone_type, temperature_controlled: f.temp,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    setF({ code: "", name: "", zone_type: "storage", temp: false }); onDone();
  }
  async function remove(id: string) {
    if (!supabase) return;
    await supabase.from("storage_zones").update({ deleted_at: new Date().toISOString(), reason_deleted: "removida na tela" }).eq("id", id);
    onDone();
  }

  return (
    <div className="space-y-3">
      <div className="card p-4 grid md:grid-cols-4 gap-3 items-end">
        <div>
          <label className="text-xs font-semibold muted">Código *</label>
          <input value={f.code} onChange={(e) => setF({ ...f, code: e.target.value })} placeholder="Z-PICK"
            className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
        </div>
        <div>
          <label className="text-xs font-semibold muted">Nome *</label>
          <input value={f.name} onChange={(e) => setF({ ...f, name: e.target.value })} placeholder="Zona de Picking"
            className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
        </div>
        <div>
          <label className="text-xs font-semibold muted">Tipo</label>
          <select value={f.zone_type} onChange={(e) => setF({ ...f, zone_type: e.target.value })}
            className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
            {ZONE_TYPES.map(([v, l]) => <option key={v} value={v}>{l}</option>)}
          </select>
        </div>
        <div className="flex items-center gap-3">
          <label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={f.temp} onChange={(e) => setF({ ...f, temp: e.target.checked })} /> Refrigerada</label>
          <button onClick={create} disabled={busy} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">{busy ? "…" : "Criar"}</button>
        </div>
        {err && <div className="md:col-span-4 text-sm text-red-500">{err}</div>}
      </div>

      {zones.length === 0 ? (
        <p className="text-sm muted px-1">Nenhuma zona ainda. Crie zonas (recebimento, picking, expedição…) para organizar os endereços.</p>
      ) : (
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-2">
          {zones.map((z: Zone) => (
            <div key={z.id} className="card p-3 flex items-start gap-2">
              <div className="flex-1">
                <div className="font-semibold text-sm">{z.code} · {z.name}</div>
                <div className="text-xs muted">{zoneTypeLabel(z.zone_type)}{z.temperature_controlled ? " · ❄ refrigerada" : ""}</div>
              </div>
              <button onClick={() => remove(z.id)} className="text-xs text-red-500 hover:underline">excluir</button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

/* ── BINS ──────────────────────────────────────────────────────────── */
function BinsPanel({ supabase, company, warehouseId, zones, zoneName, locations, getTenant, onDone }: any) {
  const [gen, setGen] = useState({ aisles: "A-C", racks: "1-5", levels: "1-4", zone_id: "", sep: "-" });
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [q, setQ] = useState("");

  const preview = useMemo(() => {
    const A = expand(gen.aisles), R = expand(gen.racks), L = expand(gen.levels);
    const out: { code: string; aisle: string; rack: string; level: string }[] = [];
    for (const a of A) for (const r of R) for (const l of L) out.push({ code: [a, r, l].join(gen.sep), aisle: a, rack: r, level: l });
    return out;
  }, [gen]);

  const existing = useMemo(() => new Set(locations.map((l: Loc) => l.code.toLowerCase())), [locations]);
  const toCreate = preview.filter((p) => !existing.has(p.code.toLowerCase()));

  async function generate() {
    if (!supabase) return;
    if (toCreate.length === 0) { setErr("Nada a criar (todos os códigos já existem ou os campos estão vazios)."); return; }
    if (toCreate.length > 5000) { setErr(`Muitos bins de uma vez (${toCreate.length}). Reduza os intervalos (máx. 5000).`); return; }
    setBusy(true); setErr(null); setMsg(null);
    const tenant_id = await getTenant();
    if (!tenant_id) { setBusy(false); setErr("Empresa não resolvida."); return; }
    const baseSeq = locations.length;
    const rows = toCreate.map((p, i) => ({
      tenant_id, company_id: company, warehouse_id: warehouseId, zone_id: gen.zone_id || null,
      code: p.code, location_type: "bin", status: "available",
      aisle: p.aisle, rack: p.rack, level: p.level, pick_sequence: baseSeq + i + 1,
    }));
    // insere em lotes de 500
    let created = 0;
    for (let i = 0; i < rows.length; i += 500) {
      const { error } = await supabase.from("storage_locations").insert(rows.slice(i, i + 500));
      if (error) { setBusy(false); setErr(`${error.message} (criados ${created} antes da falha)`); onDone(); return; }
      created += Math.min(500, rows.length - i);
    }
    setBusy(false); setMsg(`${created} endereços criados ✓`); onDone();
  }

  async function setStatus(id: string, status: string) {
    if (!supabase) return;
    await supabase.from("storage_locations").update({ status }).eq("id", id);
    onDone();
  }
  async function remove(id: string) {
    if (!supabase) return;
    await supabase.from("storage_locations").update({ deleted_at: new Date().toISOString(), reason_deleted: "removido na tela" }).eq("id", id);
    onDone();
  }

  const filtered = useMemo(() => {
    const s = q.trim().toLowerCase();
    return s ? locations.filter((l: Loc) => l.code.toLowerCase().includes(s)) : locations;
  }, [q, locations]);

  return (
    <div className="space-y-4">
      {/* Gerador em massa */}
      <div className="card p-4 space-y-3">
        <div className="font-semibold">Gerador de endereços (bins)</div>
        <p className="text-xs muted">Use intervalos (<code>A-C</code>, <code>1-10</code>) ou listas (<code>A,B,C</code>). O código final vira <b>corredor{gen.sep}rack{gen.sep}nível</b>.</p>
        <div className="grid md:grid-cols-5 gap-3 items-end">
          <div>
            <label className="text-xs font-semibold muted">Corredores</label>
            <input value={gen.aisles} onChange={(e) => setGen({ ...gen, aisles: e.target.value })}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
          </div>
          <div>
            <label className="text-xs font-semibold muted">Racks</label>
            <input value={gen.racks} onChange={(e) => setGen({ ...gen, racks: e.target.value })}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
          </div>
          <div>
            <label className="text-xs font-semibold muted">Níveis</label>
            <input value={gen.levels} onChange={(e) => setGen({ ...gen, levels: e.target.value })}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
          </div>
          <div>
            <label className="text-xs font-semibold muted">Zona</label>
            <select value={gen.zone_id} onChange={(e) => setGen({ ...gen, zone_id: e.target.value })}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }}>
              <option value="">— sem zona —</option>
              {zones.map((z: Zone) => <option key={z.id} value={z.id}>{z.code}</option>)}
            </select>
          </div>
          <div>
            <label className="text-xs font-semibold muted">Separador</label>
            <input value={gen.sep} maxLength={1} onChange={(e) => setGen({ ...gen, sep: e.target.value || "-" })}
              className="w-full mt-1 border rounded-lg px-3 py-2 text-sm bg-transparent outline-none focus:border-brand-500" style={{ borderColor: "var(--border)" }} />
          </div>
        </div>
        <div className="flex items-center gap-3 flex-wrap">
          <button onClick={generate} disabled={busy || toCreate.length === 0}
            className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-60">
            {busy ? "Gerando…" : `Gerar ${toCreate.length} bins`}
          </button>
          <span className="text-xs muted">
            {preview.length} combinações · {preview.length - toCreate.length} já existem ·
            exemplos: {preview.slice(0, 4).map((p) => p.code).join(", ")}{preview.length > 4 ? "…" : ""}
          </span>
        </div>
        {msg && <div className="text-sm text-green-500">{msg}</div>}
        {err && <div className="text-sm text-red-500">{err}</div>}
      </div>

      {/* Lista de bins */}
      <div className="card p-4">
        <div className="flex items-center gap-3 mb-3">
          <div className="font-semibold">Endereços ({locations.length})</div>
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Buscar código…"
            className="ml-auto border rounded-lg px-3 py-1.5 text-sm bg-transparent outline-none focus:border-brand-500 w-48" style={{ borderColor: "var(--border)" }} />
        </div>
        {locations.length === 0 ? (
          <p className="text-sm muted">Nenhum endereço ainda. Use o gerador acima para criar os bins em massa.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left muted text-xs uppercase">
                  <th className="py-1.5 pr-3">Código</th><th className="pr-3">Zona</th><th className="pr-3">Status</th><th></th>
                </tr>
              </thead>
              <tbody>
                {filtered.slice(0, 300).map((l: Loc) => (
                  <tr key={l.id} className="border-t" style={{ borderColor: "var(--border)" }}>
                    <td className="py-1.5 pr-3 font-mono">{l.code}</td>
                    <td className="pr-3 muted">{l.zone_id ? zoneName[l.zone_id] ?? "—" : "—"}</td>
                    <td className="pr-3">
                      <select value={l.status} onChange={(e) => setStatus(l.id, e.target.value)}
                        className={`text-xs px-2 py-0.5 rounded-md font-semibold bg-transparent outline-none ${STATUS[l.status]?.cls ?? ""}`}>
                        {Object.entries(STATUS).map(([v, o]) => <option key={v} value={v}>{o.label}</option>)}
                      </select>
                    </td>
                    <td className="text-right"><button onClick={() => remove(l.id)} className="text-xs text-red-500 hover:underline">excluir</button></td>
                  </tr>
                ))}
              </tbody>
            </table>
            {filtered.length > 300 && <div className="text-xs muted mt-2">Mostrando 300 de {filtered.length}. Refine a busca.</div>}
          </div>
        )}
      </div>
    </div>
  );
}
