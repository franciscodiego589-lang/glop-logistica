"use client";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;
const slotColor = (s: string) => ({ free: "var(--success)", occupied: "var(--brand-600, #2f56e6)", blocked: "var(--danger)", reserved: "var(--warning)" } as any)[s] ?? "var(--muted)";
const prioTone = (p: string) => ({ emergency: "var(--danger)", high: "var(--warning)" } as any)[p];

const TABS = ["Painel", "Mapa Operacional", "Portaria (Check-in)", "Fila", "Containers", "Credenciais & Visitantes"] as const;
type Tab = typeof TABS[number];

export default function YMSGateWorkbench({ dash, map, passes, queue, gates, docks, creds, visitors, containers }: any) {
  const [tab, setTab] = useState<Tab>("Painel");
  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs muted font-semibold uppercase tracking-wider">Volume 37 · Domínio Logístico · Pátio</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Portaria & Pátio (YMS)</h1>
        <p className="text-sm muted mt-0.5">Do lado de fora do armazém: check-in na portaria → fila → vaga de pátio → doca → check-out. Cada passo publica evento.</p>
      </div>
      <div className="flex gap-1 flex-wrap border-b" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-2 text-sm font-semibold border-b-2 -mb-px ${tab === t ? "border-brand-600 text-brand-600" : "border-transparent muted hover:text-current"}`}>{t}</button>
        ))}
      </div>
      {tab === "Painel" && <Painel dash={dash} />}
      {tab === "Mapa Operacional" && <Mapa map={map} />}
      {tab === "Portaria (Check-in)" && <Portaria passes={passes} gates={gates} />}
      {tab === "Fila" && <Fila queue={queue} docks={docks} />}
      {tab === "Containers" && <Containers containers={containers} />}
      {tab === "Credenciais & Visitantes" && <CredsVis creds={creds} visitors={visitors} />}
    </div>
  );
}

function KPI({ label, value, hint, tone }: any) {
  return <div className="kpi"><div className="kpi-label">{label}</div><div className="kpi-value tabular-nums" style={{ color: tone }}>{value}</div>{hint && <div className="text-xs muted mt-0.5">{hint}</div>}</div>;
}
function Painel({ dash }: any) {
  const d = dash ?? {};
  const occ = d.slots_total ? Math.round((d.slots_occupied / d.slots_total) * 100) : 0;
  return (
    <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
      <KPI label="Veículos no pátio" value={String((d.in_yard ?? 0) + (d.at_dock ?? 0))} hint={`${d.at_dock ?? 0} em doca`} />
      <KPI label="Fila (aguardando)" value={String(d.queue_waiting ?? 0)} tone={Number(d.queue_waiting) >= 10 ? "var(--danger)" : undefined} />
      <KPI label="Ocupação do pátio" value={`${occ}%`} hint={`${d.slots_free ?? 0} vagas livres de ${d.slots_total ?? 0}`} tone={occ > 85 ? "var(--warning)" : "var(--success)"} />
      <KPI label="Permanência média" value={`${d.avg_dwell_min ?? 0} min`} hint={`${d.gates ?? 0} portarias · ${d.containers_in_yard ?? 0} containers`} />
    </div>
  );
}

function Mapa({ map }: any) {
  const slots = map?.slots ?? []; const queue = map?.queue ?? []; const gates = map?.gates ?? [];
  return (
    <div className="grid lg:grid-cols-3 gap-4">
      <div className="lg:col-span-2 card p-4">
        <div className="font-semibold mb-3">Mapa do pátio <span className="text-xs muted font-normal">· {slots.filter((s: any) => s.status === "occupied").length}/{slots.length} ocupadas</span></div>
        {slots.length === 0 ? <p className="text-sm muted">Sem vagas cadastradas.</p> : (
          <div className="grid gap-2" style={{ gridTemplateColumns: "repeat(auto-fill, minmax(84px, 1fr))" }}>
            {slots.map((s: any) => (
              <div key={s.code} className="rounded-lg p-2 text-white text-xs grid place-items-center text-center h-16" style={{ background: slotColor(s.status) }} title={s.plate ?? s.status}>
                <div className="font-bold">{s.code}</div>
                <div className="text-[10px] opacity-90 truncate w-full">{s.plate ?? s.status}</div>
              </div>
            ))}
          </div>
        )}
        <div className="flex gap-3 mt-3 text-xs muted">
          {[["free", "Livre"], ["occupied", "Ocupada"], ["reserved", "Reservada"], ["blocked", "Bloqueada"]].map(([k, l]) => (
            <span key={k} className="flex items-center gap-1"><span className="w-3 h-3 rounded" style={{ background: slotColor(k) }} />{l}</span>
          ))}
        </div>
      </div>
      <div className="space-y-4">
        <div className="card p-4">
          <div className="font-semibold mb-2">Portarias</div>
          {gates.length === 0 ? <p className="text-sm muted">—</p> : gates.map((g: any) => (
            <div key={g.name} className="flex items-center justify-between py-1 text-sm">
              <span>{g.name}</span><span className={`badge ${g.status === "open" ? "badge-success" : "badge-neutral"}`}>{g.status}</span>
            </div>
          ))}
        </div>
        <div className="card p-4">
          <div className="font-semibold mb-2">Fila ({queue.length})</div>
          {queue.length === 0 ? <p className="text-sm muted">Vazia.</p> : queue.slice(0, 12).map((q: any, i: number) => (
            <div key={i} className="flex items-center gap-2 py-1 text-sm">
              <span className="w-5 text-xs muted tabular-nums">{q.position}</span>
              <span className="mono flex-1">{q.plate}</span>
              {prioTone(q.priority) && <span className="badge" style={{ background: prioTone(q.priority), color: "#fff" }}>{q.priority}</span>}
              <span className="badge badge-neutral">{q.status}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function Portaria({ passes, gates }: any) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [f, setF] = useState({ gate: "", plate: "", driver: "", doc: "", carrier: "", cargo: "", dest: "", priority: "normal" });
  const [busy, setBusy] = useState("");
  async function checkin() {
    if (!supabase || !f.plate) return; setBusy("in");
    const { error } = await supabase.rpc("gate_check_in", {
      p_company: COMPANY, p_gate: f.gate || null, p_carrier: null, p_plate: f.plate, p_driver: f.driver || null,
      p_driver_doc: f.doc || null, p_order: null, p_cargo: f.cargo || null, p_destination: f.dest || null, p_priority: f.priority,
    });
    setBusy(""); if (error) { alert(error.message); return; }
    setF({ ...f, plate: "", driver: "", doc: "", cargo: "" }); router.refresh();
  }
  async function checkout(id: string) {
    if (!supabase) return; setBusy(id);
    const { error } = await supabase.rpc("gate_check_out", { p_company: COMPANY, p_pass: id });
    setBusy(""); if (error) { alert(error.message); return; } router.refresh();
  }
  const active = passes.filter((p: any) => p.status === "in_yard" || p.status === "at_dock");
  return (
    <div className="space-y-4">
      <div className="card p-4 space-y-3">
        <div className="font-semibold">Check-in de veículo</div>
        <div className="grid md:grid-cols-4 gap-2">
          <select className="select" value={f.gate} onChange={(e) => setF({ ...f, gate: e.target.value })}><option value="">Portaria…</option>{gates.map((g: any) => <option key={g.id} value={g.id}>{g.name}</option>)}</select>
          <input className="input" placeholder="Placa *" value={f.plate} onChange={(e) => setF({ ...f, plate: e.target.value.toUpperCase() })} />
          <input className="input" placeholder="Motorista" value={f.driver} onChange={(e) => setF({ ...f, driver: e.target.value })} />
          <input className="input" placeholder="Documento" value={f.doc} onChange={(e) => setF({ ...f, doc: e.target.value })} />
          <input className="input" placeholder="Carga" value={f.cargo} onChange={(e) => setF({ ...f, cargo: e.target.value })} />
          <input className="input" placeholder="Destino" value={f.dest} onChange={(e) => setF({ ...f, dest: e.target.value })} />
          <select className="select" value={f.priority} onChange={(e) => setF({ ...f, priority: e.target.value })}>{["low", "normal", "high", "emergency"].map((p) => <option key={p} value={p}>{p}</option>)}</select>
          <button onClick={checkin} disabled={busy === "in" || !f.plate} className="btn btn-primary">{busy === "in" ? "Registrando…" : "Check-in"}</button>
        </div>
      </div>
      <div className="card p-0 overflow-x-auto">
        <table className="tbl">
          <thead><tr><th>Passagem</th><th>Placa</th><th>Motorista</th><th>Carga</th><th>Entrada</th><th>Status</th><th></th></tr></thead>
          <tbody>
            {active.length === 0 ? <tr><td colSpan={7} className="text-sm muted p-4 text-center">Nenhum veículo no pátio.</td></tr> :
              active.map((p: any) => (
                <tr key={p.id}>
                  <td className="mono text-xs">{p.code}</td>
                  <td className="mono font-medium">{p.vehicle_plate}</td>
                  <td className="text-sm">{p.driver_name ?? "—"}</td>
                  <td className="text-xs muted">{p.cargo_description ?? "—"}</td>
                  <td className="text-xs tabular-nums">{new Date(p.check_in_at).toLocaleString("pt-BR")}</td>
                  <td><span className={`badge ${p.status === "at_dock" ? "badge-warning" : "badge-neutral"}`}>{p.status}</span></td>
                  <td className="text-right"><button onClick={() => checkout(p.id)} disabled={!!busy} className="btn btn-sm">Check-out</button></td>
                </tr>
              ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function Fila({ queue, docks }: any) {
  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const [dockSel, setDockSel] = useState<Record<string, string>>({});
  async function call(qid: string) {
    if (!supabase) return;
    const { error } = await supabase.rpc("call_to_dock", { p_company: COMPANY, p_queue: qid, p_dock: dockSel[qid] || null });
    if (error) { alert(error.message); return; } router.refresh();
  }
  return (
    <div className="card p-0 overflow-x-auto">
      <table className="tbl">
        <thead><tr><th>#</th><th>Placa</th><th>Prioridade</th><th>Status</th><th>Espera</th><th>Doca</th><th></th></tr></thead>
        <tbody>
          {queue.length === 0 ? <tr><td colSpan={7} className="text-sm muted p-4 text-center">Fila vazia.</td></tr> :
            queue.map((q: any) => (
              <tr key={q.id}>
                <td className="tabular-nums text-xs">{q.position}</td>
                <td className="mono font-medium">{q.vehicle_plate}</td>
                <td><span className="badge" style={{ background: prioTone(q.priority), color: prioTone(q.priority) ? "#fff" : undefined }}>{q.priority}</span></td>
                <td><span className="badge badge-neutral">{q.status}</span></td>
                <td className="text-xs tabular-nums">{Math.round((Date.now() - new Date(q.waited_since).getTime()) / 60000)} min</td>
                <td><select className="select" value={dockSel[q.id] ?? ""} onChange={(e) => setDockSel({ ...dockSel, [q.id]: e.target.value })}><option value="">doca…</option>{docks.map((d: any) => <option key={d.id} value={d.id}>{d.code ?? d.name}</option>)}</select></td>
                <td className="text-right">{q.status === "waiting" && <button onClick={() => call(q.id)} className="btn btn-primary btn-sm">Chamar p/ doca</button>}</td>
              </tr>
            ))}
        </tbody>
      </table>
    </div>
  );
}

function Containers({ containers }: any) {
  return (
    <div className="card p-0 overflow-x-auto">
      <table className="tbl">
        <thead><tr><th>Container</th><th>ISO</th><th>Lacre</th><th>Peso</th><th>Status</th><th>Entrada</th></tr></thead>
        <tbody>{containers.length === 0 ? <tr><td colSpan={6} className="text-sm muted p-4 text-center">Nenhum container no pátio.</td></tr> :
          containers.map((c: any) => (
            <tr key={c.id}><td className="mono font-medium">{c.container_number}</td><td className="text-xs">{c.iso_type ?? "—"}</td><td className="text-xs muted">{c.seal_number ?? "—"}</td><td className="tabular-nums text-xs">{c.weight_kg ?? "—"}</td><td><span className="badge badge-neutral">{c.status}</span></td><td className="text-xs tabular-nums">{c.entry_at ? new Date(c.entry_at).toLocaleDateString("pt-BR") : "—"}</td></tr>
          ))}</tbody>
      </table>
    </div>
  );
}

function CredsVis({ creds, visitors }: any) {
  return (
    <div className="grid lg:grid-cols-2 gap-4">
      <div>
        <div className="font-semibold text-sm mb-2">Credenciais de acesso</div>
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Tipo</th><th>Código</th><th>Portador</th><th>Status</th></tr></thead>
          <tbody>{creds.length === 0 ? <tr><td colSpan={4} className="text-xs muted p-3 text-center">—</td></tr> :
            creds.map((c: any) => (<tr key={c.id}><td className="text-xs uppercase">{c.credential_type}</td><td className="mono text-xs">{c.code}</td><td className="text-xs">{c.holder_name ?? "—"}</td><td><span className={`badge ${c.status === "active" ? "badge-success" : "badge-neutral"}`}>{c.status}</span></td></tr>))}</tbody>
        </table></div>
      </div>
      <div>
        <div className="font-semibold text-sm mb-2">Visitantes / Prestadores</div>
        <div className="card p-0 overflow-x-auto"><table className="tbl">
          <thead><tr><th>Nome</th><th>Tipo</th><th>Empresa</th><th>Status</th></tr></thead>
          <tbody>{visitors.length === 0 ? <tr><td colSpan={4} className="text-xs muted p-3 text-center">—</td></tr> :
            visitors.map((v: any) => (<tr key={v.id}><td className="text-sm">{v.name}</td><td className="text-xs">{v.visitor_type}</td><td className="text-xs muted">{v.company_name ?? "—"}</td><td><span className={`badge ${v.status === "inside" ? "badge-warning" : "badge-neutral"}`}>{v.status}</span></td></tr>))}</tbody>
        </table></div>
      </div>
    </div>
  );
}
