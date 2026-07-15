"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

const OP_LABEL: Record<string, string> = {
  customer_order: "Pedido de cliente", transfer: "Transferência", replenishment: "Reposição",
  supplier_pickup: "Coleta fornecedor", return: "Devolução", exchange: "Troca",
  toll_manufacturing: "Industrialização", export: "Exportação", import: "Importação",
};
const PRIO: Record<string, string> = { low: "Baixa", normal: "Normal", high: "Alta", urgent: "Urgente" };
const prioTone = (p: string) => ({ urgent: "var(--danger)", high: "var(--warning)", normal: "var(--muted)", low: "var(--muted)" } as any)[p];
const statusBadge = (s: string) => s === "blocked" ? "badge-danger" : s === "closed" ? "badge-success" : s === "canceled" ? "badge-neutral" : "badge-warning";

const TABS = ["Painel", "Ordens", "Fluxo (17 etapas)", "Eventos"] as const;
type Tab = typeof TABS[number];

export default function LOMWorkbench({ dash, orders, stages, events, products, warehouses, carriers }: {
  dash: any; orders: any[]; stages: any[]; events: any[]; products: any[]; warehouses: any[]; carriers: any[];
}) {
  const [tab, setTab] = useState<Tab>("Painel");
  const [sel, setSel] = useState<any | null>(null);
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Domínio 01 · Fluxo Operacional (Cap. 5)</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Gestão de Pedidos Logísticos (LOM)</h1>
        <p className="text-sm muted mt-0.5">Origem do fluxo mestre: demanda → validação → planejamento → reserva → … → entrega → encerramento. Cada transição publica um evento no barramento.</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>
      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Ordens" && <Ordens orders={orders} products={products} warehouses={warehouses} carriers={carriers} stages={stages} onSelect={setSel} sel={sel} />}
      {tab === "Fluxo (17 etapas)" && <Fluxo stages={stages} dash={dash} />}
      {tab === "Eventos" && <Eventos events={events} />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: { label: string; value: string; hint?: string; tone?: string }) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash }: { dash: any }) {
  const d = dash ?? {};
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <KPI label="Ordens (total)" value={String(d.total ?? 0)} hint={`${d.open ?? 0} abertas`} />
        <KPI label="Bloqueadas" value={String(d.blocked ?? 0)} tone={d.blocked ? "var(--danger)" : "var(--success)"} />
        <KPI label="SLA estourado" value={String(d.sla_breached ?? 0)} hint={`${d.sla_at_risk ?? 0} em risco (<6h)`} tone={d.sla_breached ? "var(--danger)" : undefined} />
        <KPI label="Lead time médio" value={`${d.avg_lead_hours ?? 0}h`} hint={`${d.closed ?? 0} encerradas`} tone="var(--success)" />
      </div>
      <div className="grid md:grid-cols-2 gap-4">
        <div className="card p-4">
          <div className="font-semibold mb-3">Ordens ativas por etapa</div>
          {(d.by_stage ?? []).length === 0 ? <p className="text-sm muted">Sem ordens ativas.</p> : (d.by_stage ?? []).map((s: any) => (
            <div key={s.stage} className="flex items-center gap-3 mb-2">
              <div className="w-40 text-sm truncate">{s.label}</div>
              <div className="flex-1 h-2.5 rounded-full overflow-hidden" style={{ background: "var(--surface-3)" }}>
                <div className="h-full rounded-full" style={{ width: `${Math.min(100, s.count * 12)}%`, background: "var(--brand-600, #2f56e6)" }} />
              </div>
              <div className="w-8 text-right text-sm tabular-nums font-semibold">{s.count}</div>
            </div>
          ))}
        </div>
        <div className="card p-4">
          <div className="font-semibold mb-3">Por tipo de operação</div>
          {(d.by_operation ?? []).length === 0 ? <p className="text-sm muted">—</p> : (d.by_operation ?? []).map((o: any) => (
            <div key={o.op} className="flex items-center justify-between py-1.5 border-b text-sm" style={{ borderColor: "var(--border)" }}>
              <span>{OP_LABEL[o.op] ?? o.op}</span><span className="tabular-nums font-semibold">{o.count}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function Ordens({ orders, products, warehouses, carriers, stages, onSelect, sel }: any) {
  const [creating, setCreating] = useState(false);
  const stageLabel = (k: string) => stages.find((s: any) => s.stage_key === k)?.label ?? k;
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="font-semibold text-base mr-auto">Ordens logísticas</div>
        <button onClick={() => setCreating(true)} className="btn btn-primary btn-sm">+ Nova demanda</button>
      </div>
      {creating && <CreateForm products={products} onClose={() => setCreating(false)} />}
      <div className="card p-0 overflow-x-auto">
        <table className="tbl">
          <thead><tr><th>Código</th><th>Operação</th><th>Destino</th><th>Prioridade</th><th>Etapa</th><th>Status</th><th>SLA</th><th></th></tr></thead>
          <tbody>
            {orders.length === 0 ? <tr><td colSpan={8} className="text-sm muted p-4 text-center">Nenhuma ordem. Crie a primeira demanda logística.</td></tr> :
              orders.map((o: any) => {
                const breached = o.sla_due_at && new Date(o.sla_due_at) < new Date() && o.status === "open";
                return (
                  <tr key={o.id} className="cursor-pointer" onClick={() => onSelect(o)}>
                    <td className="font-medium mono">{o.code}</td>
                    <td className="text-xs">{OP_LABEL[o.operation_type] ?? o.operation_type}</td>
                    <td className="text-xs muted">{o.destination ?? "—"}{o.dest_uf ? ` / ${o.dest_uf}` : ""}</td>
                    <td><span className="badge" style={{ background: prioTone(o.priority), color: o.priority === "normal" || o.priority === "low" ? undefined : "#fff" }}>{PRIO[o.priority] ?? o.priority}</span></td>
                    <td className="text-xs">{stageLabel(o.stage)}</td>
                    <td><span className={`badge ${statusBadge(o.status)}`}>{o.status}</span></td>
                    <td className="text-xs tabular-nums" style={{ color: breached ? "var(--danger)" : undefined }}>{o.sla_due_at ? new Date(o.sla_due_at).toLocaleDateString("pt-BR") : "—"}</td>
                    <td className="text-right text-xs text-brand-600">abrir ›</td>
                  </tr>
                );
              })}
          </tbody>
        </table>
      </div>
      {sel && <OrderDetail order={sel} stages={stages} warehouses={warehouses} carriers={carriers} onClose={() => onSelect(null)} />}
    </div>
  );
}

function CreateForm({ products, onClose }: { products: any[]; onClose: () => void }) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [op, setOp] = useState("customer_order");
  const [origin, setOrigin] = useState("");
  const [dest, setDest] = useState("");
  const [uf, setUf] = useState("");
  const [prio, setPrio] = useState("normal");
  const [sla, setSla] = useState("48");
  const [items, setItems] = useState<{ product_id: string; quantity: string }[]>([{ product_id: "", quantity: "1" }]);
  const [busy, setBusy] = useState(false);
  async function save() {
    if (!supabase) return;
    setBusy(true);
    const payload = items.filter((i) => i.product_id).map((i) => ({ product_id: i.product_id, quantity: Number(i.quantity) }));
    await supabase.rpc("create_logistics_order", {
      p_company: COMPANY, p_operation_type: op, p_origin: origin || null, p_destination: dest || null,
      p_priority: prio, p_sla_hours: sla ? Number(sla) : null, p_items: payload, p_dest_uf: uf || null, p_dest_zip: null,
    });
    setBusy(false); onClose(); router.refresh();
  }
  return (
    <div className="card p-4 space-y-3">
      <div className="font-semibold">Nova demanda logística</div>
      <div className="grid md:grid-cols-3 gap-3">
        <label className="text-sm">Operação<select className="select mt-1" value={op} onChange={(e) => setOp(e.target.value)}>{Object.entries(OP_LABEL).map(([k, v]) => <option key={k} value={k}>{v}</option>)}</select></label>
        <label className="text-sm">Prioridade<select className="select mt-1" value={prio} onChange={(e) => setPrio(e.target.value)}>{Object.entries(PRIO).map(([k, v]) => <option key={k} value={k}>{v}</option>)}</select></label>
        <label className="text-sm">SLA (horas)<input className="input mt-1" type="number" value={sla} onChange={(e) => setSla(e.target.value)} /></label>
        <label className="text-sm">Origem<input className="input mt-1" value={origin} onChange={(e) => setOrigin(e.target.value)} placeholder="CD / endereço origem" /></label>
        <label className="text-sm">Destino<input className="input mt-1" value={dest} onChange={(e) => setDest(e.target.value)} placeholder="Cidade / endereço destino" /></label>
        <label className="text-sm">UF destino<input className="input mt-1" value={uf} onChange={(e) => setUf(e.target.value.toUpperCase())} maxLength={2} /></label>
      </div>
      <div>
        <div className="text-sm font-medium mb-1">Itens</div>
        {items.map((it, idx) => (
          <div key={idx} className="flex gap-2 mb-1.5">
            <select className="select flex-1" value={it.product_id} onChange={(e) => setItems(items.map((x, i) => i === idx ? { ...x, product_id: e.target.value } : x))}>
              <option value="">— produto —</option>
              {products.map((p) => <option key={p.id} value={p.id}>{p.sku ? `[${p.sku}] ` : ""}{p.name}</option>)}
            </select>
            <input className="input w-24" type="number" value={it.quantity} onChange={(e) => setItems(items.map((x, i) => i === idx ? { ...x, quantity: e.target.value } : x))} />
            {items.length > 1 && <button onClick={() => setItems(items.filter((_, i) => i !== idx))} className="btn btn-sm">✕</button>}
          </div>
        ))}
        <button onClick={() => setItems([...items, { product_id: "", quantity: "1" }])} className="text-xs text-brand-600 hover:underline">+ item</button>
      </div>
      <div className="flex gap-2 justify-end">
        <button onClick={onClose} className="btn btn-sm">Cancelar</button>
        <button onClick={save} disabled={busy} className="btn btn-primary btn-sm">{busy ? "Criando…" : "Criar demanda"}</button>
      </div>
    </div>
  );
}

function OrderDetail({ order, stages, warehouses, carriers, onClose }: any) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [timeline, setTimeline] = useState<any[] | null>(null);
  const [busy, setBusy] = useState("");
  const [wh, setWh] = useState("");
  const [carrier, setCarrier] = useState("");
  async function loadTimeline() {
    if (!supabase) return;
    const { data } = await supabase.rpc("lom_order_timeline", { p_company: COMPANY, p_order: order.id });
    setTimeline(data ?? []);
  }
  useMemo(() => { loadTimeline(); }, [order.id]);
  async function run(fn: string, args: any, label: string) {
    if (!supabase) return;
    setBusy(label);
    const { error } = await supabase.rpc(fn, { p_company: COMPANY, ...args });
    setBusy("");
    if (error) { alert(error.message); return; }
    await loadTimeline(); router.refresh();
  }
  const nextStage = stages.find((s: any) => s.order_index > (stages.find((x: any) => x.stage_key === order.stage)?.order_index ?? 0) && !s.is_branch);
  return (
    <div className="fixed inset-0 z-40 flex justify-end" style={{ background: "rgba(0,0,0,.35)" }} onClick={onClose}>
      <div className="w-full max-w-lg h-full overflow-y-auto p-5 space-y-4" style={{ background: "var(--surface-1, #fff)" }} onClick={(e) => e.stopPropagation()}>
        <div className="flex items-start justify-between">
          <div>
            <div className="text-xs muted">{OP_LABEL[order.operation_type] ?? order.operation_type}</div>
            <h2 className="text-lg font-bold mono">{order.code}</h2>
            <div className="text-sm muted">{order.origin ?? "—"} → {order.destination ?? "—"}{order.dest_uf ? ` / ${order.dest_uf}` : ""}</div>
          </div>
          <button onClick={onClose} className="btn btn-sm">✕</button>
        </div>
        <div className="flex gap-2 flex-wrap items-center">
          <span className={`badge ${statusBadge(order.status)}`}>{order.status}</span>
          <span className="badge badge-neutral">{stages.find((s: any) => s.stage_key === order.stage)?.label ?? order.stage}</span>
          {order.sla_due_at && <span className="text-xs muted">SLA: {new Date(order.sla_due_at).toLocaleString("pt-BR")}</span>}
        </div>

        {order.status === "open" && (
          <div className="card p-3 space-y-2">
            <div className="text-sm font-semibold">Ações do fluxo</div>
            <div className="flex flex-wrap gap-2">
              {order.stage === "demand" && <button onClick={() => run("validate_logistics_order", { p_order: order.id }, "val")} disabled={!!busy} className="btn btn-primary btn-sm">Validar (ATP)</button>}
              {order.stage === "validated" && (
                <div className="flex flex-wrap gap-2 items-center w-full">
                  <select className="select flex-1" value={wh} onChange={(e) => setWh(e.target.value)}><option value="">CD…</option>{warehouses.map((w: any) => <option key={w.id} value={w.id}>{w.name}</option>)}</select>
                  <select className="select flex-1" value={carrier} onChange={(e) => setCarrier(e.target.value)}><option value="">Transportadora…</option>{carriers.map((c: any) => <option key={c.id} value={c.id}>{c.name}</option>)}</select>
                  <button onClick={() => run("plan_logistics_order", { p_order: order.id, p_warehouse: wh || null, p_carrier: carrier || null, p_eta: null }, "plan")} disabled={!!busy} className="btn btn-primary btn-sm">Planejar</button>
                </div>
              )}
              {order.stage === "planned" && <button onClick={() => run("allocate_logistics_order", { p_order: order.id }, "alloc")} disabled={!!busy} className="btn btn-primary btn-sm">Reservar estoque</button>}
              {!["demand", "validated", "planned", "closed"].includes(order.stage) && nextStage &&
                <button onClick={() => run("advance_logistics_order", { p_order: order.id, p_to_stage: null }, "adv")} disabled={!!busy} className="btn btn-primary btn-sm">Avançar → {nextStage.label}</button>}
              <button onClick={() => { const r = prompt("Motivo do bloqueio:"); if (r) run("hold_logistics_order", { p_order: order.id, p_reason: r }, "hold"); }} disabled={!!busy} className="btn btn-sm">Bloquear</button>
              <button onClick={() => { const r = prompt("Motivo do cancelamento:"); if (r) run("cancel_logistics_order", { p_order: order.id, p_reason: r }, "cancel"); }} disabled={!!busy} className="btn btn-sm" style={{ color: "var(--danger)" }}>Cancelar</button>
            </div>
          </div>
        )}

        <div>
          <div className="text-sm font-semibold mb-2">Linha do tempo (eventos)</div>
          {timeline === null ? <p className="text-sm muted">Carregando…</p> : timeline.length === 0 ? <p className="text-sm muted">Sem eventos.</p> : (
            <ol className="space-y-2">
              {timeline.map((e, i) => (
                <li key={i} className="flex gap-3 text-sm">
                  <div className="w-1.5 rounded-full mt-1" style={{ background: e.result === "blocked" ? "var(--danger)" : "var(--brand-600, #2f56e6)", minHeight: 28 }} />
                  <div>
                    <div className="font-medium">{e.to_stage} <span className="text-xs muted mono">{e.event_type}</span></div>
                    <div className="text-xs muted">{new Date(e.occurred_at).toLocaleString("pt-BR")}{e.notes ? ` · ${e.notes}` : ""}</div>
                  </div>
                </li>
              ))}
            </ol>
          )}
        </div>
      </div>
    </div>
  );
}

function Fluxo({ stages, dash }: { stages: any[]; dash: any }) {
  const counts: Record<string, number> = {};
  (dash?.by_stage ?? []).forEach((s: any) => { counts[s.stage] = s.count; });
  return (
    <div className="card p-4">
      <div className="font-semibold mb-1">Fluxo operacional — 17 etapas (Cap. 5 do Blueprint)</div>
      <p className="text-sm muted mb-4">Catálogo <code>logistics_stages</code> que dirige a máquina de estados. Cada transição publica <code>logistics_order.&lt;evento&gt;</code> no barramento.</p>
      <div className="space-y-1.5">
        {stages.map((s: any) => (
          <div key={s.stage_key} className={`flex items-center gap-3 p-2 rounded-lg ${s.is_branch ? "opacity-70" : ""}`} style={{ background: "var(--surface-2, transparent)" }}>
            <div className="w-7 h-7 rounded-full grid place-items-center text-xs font-bold text-white shrink-0" style={{ background: s.is_branch ? "var(--warning)" : "var(--brand-600, #2f56e6)" }}>{s.order_index}</div>
            <div className="flex-1">
              <div className="font-medium text-sm">{s.label}{s.is_branch ? " (ramo)" : ""}</div>
              <code className="text-[11px] muted">{s.event_type}</code>
            </div>
            <span className="badge badge-neutral">{s.domain}</span>
            {counts[s.stage_key] ? <span className="badge badge-warning">{counts[s.stage_key]} ativa(s)</span> : null}
          </div>
        ))}
      </div>
    </div>
  );
}

function Eventos({ events }: { events: any[] }) {
  return (
    <div className="space-y-3">
      <div className="font-semibold text-base">Barramento de eventos <span className="text-xs muted font-normal">(event_bus · contrato logistics_order.*)</span></div>
      {events.length === 0 ? <p className="text-sm muted">Nenhum evento publicado ainda. Crie e movimente uma ordem para ver o barramento em ação.</p> : (
        <div className="card p-0 overflow-x-auto">
          <table className="tbl">
            <thead><tr><th>Quando</th><th>Evento</th><th>Assinantes</th><th>Payload</th></tr></thead>
            <tbody>{events.map((e) => (
              <tr key={e.id}>
                <td className="text-xs tabular-nums whitespace-nowrap">{new Date(e.occurred_at).toLocaleString("pt-BR")}</td>
                <td><code className="text-xs">{e.event_type}</code></td>
                <td className="text-center tabular-nums text-xs">{e.subscribers_notified ?? 0}</td>
                <td className="text-xs muted mono truncate" style={{ maxWidth: 260 }}>{JSON.stringify(e.payload)}</td>
              </tr>
            ))}</tbody>
          </table>
        </div>
      )}
    </div>
  );
}
