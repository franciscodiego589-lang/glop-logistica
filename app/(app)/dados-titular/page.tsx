"use client";
import { useState } from "react";

const money = (v: any) => "R$ " + Number(v ?? 0).toLocaleString("pt-BR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });

export default function DadosTitularPage() {
  const [tipo, setTipo] = useState<"doc" | "email">("doc");
  const [valor, setValor] = useState("");
  const [res, setRes] = useState<any>(null);
  const [busy, setBusy] = useState(false);

  async function buscar() {
    if (!valor.trim()) return;
    setBusy(true); setRes(null);
    try {
      const r = await fetch("/api/lgpd/export", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ [tipo]: valor.trim() }) });
      setRes(await r.json());
    } catch (e: any) { setRes({ error: e.message }); }
    setBusy(false);
  }

  function baixar() {
    if (!res) return;
    const url = URL.createObjectURL(new Blob([JSON.stringify(res, null, 2)], { type: "application/json" }));
    const a = document.createElement("a"); a.href = url; a.download = `dados-titular-${Date.now()}.json`; a.click(); URL.revokeObjectURL(url);
  }

  const pedidos = res?.pedidos ?? [];

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>GOVERNANÇA · LGPD · DIREITOS DO TITULAR</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Dados do Titular (LGPD)</h1>
        <p className="text-sm muted mt-0.5">Reúne todos os dados de um comprador (art. 18 — acesso/portabilidade) e exporta em arquivo.</p>
      </div>

      <div className="card p-4 flex flex-wrap items-end gap-2">
        <select value={tipo} onChange={(e) => setTipo(e.target.value as any)} className="input w-auto text-sm">
          <option value="doc">CPF/CNPJ</option><option value="email">E-mail</option>
        </select>
        <input value={valor} onChange={(e) => setValor(e.target.value)} onKeyDown={(e) => e.key === "Enter" && buscar()} placeholder={tipo === "doc" ? "CPF ou CNPJ do titular" : "e-mail do titular"} className="input flex-1 min-w-[240px] text-sm" />
        <button onClick={buscar} disabled={busy || !valor.trim()} className="px-4 py-2 rounded-lg bg-brand-600 text-white text-sm font-semibold disabled:opacity-50">{busy ? "Buscando…" : "Buscar dados"}</button>
        {res && !res.error && <button onClick={baixar} className="px-3 py-2 rounded-lg border text-sm font-semibold" style={{ borderColor: "var(--border)" }}>⬇️ Exportar JSON</button>}
      </div>

      {res?.error && <div className="card p-4 text-sm" style={{ color: "var(--danger)" }}>🚫 {res.error}</div>}

      {res && !res.error && (
        <>
          <div className="card p-4">
            <div className="font-bold text-sm mb-2">Titular</div>
            <div className="text-sm grid sm:grid-cols-2 gap-1">
              <div><span className="muted">Nome:</span> {res.titular?.nome ?? "—"}</div>
              <div><span className="muted">Documento:</span> {res.titular?.documento ?? "—"}</div>
              <div><span className="muted">E-mail:</span> {res.titular?.email ?? "—"}</div>
              <div><span className="muted">Telefone:</span> {res.titular?.telefone ?? "—"}</div>
            </div>
            <div className="text-xs muted mt-2">{res.total_pedidos} pedido(s) encontrado(s).</div>
          </div>

          {pedidos.length > 0 && (
            <div className="card p-0 overflow-x-auto">
              <div className="px-4 pt-3 font-semibold text-sm">Pedidos do titular</div>
              <table className="w-full text-sm mt-2">
                <thead><tr className="text-left muted text-xs uppercase border-b" style={{ borderColor: "var(--border)" }}><th className="py-2 px-4">Venda</th><th className="px-3">Produto</th><th className="px-3">Destino</th><th className="px-3 text-right">Valor</th><th className="px-3">Status</th><th className="px-3">Rastreio</th></tr></thead>
                <tbody>{pedidos.map((p: any, i: number) => (
                  <tr key={i} className="border-b last:border-0" style={{ borderColor: "var(--border)" }}>
                    <td className="py-2 px-4 font-medium">#{p.sale_number}</td>
                    <td className="px-3 text-xs">{p.product_name ?? "—"}</td>
                    <td className="px-3 text-xs">{p.dest_city ?? "—"}{p.dest_uf ? "/" + p.dest_uf : ""}</td>
                    <td className="px-3 text-right tabular-nums">{money(p.value)}</td>
                    <td className="px-3"><span className="badge badge-neutral">{p.state}</span></td>
                    <td className="px-3 text-xs font-mono">{p.tracking_code ?? "—"}</td>
                  </tr>))}</tbody>
              </table>
            </div>
          )}
          <p className="text-xs muted">Use este relatório para atender pedidos de acesso/portabilidade. Para exclusão/anonimização, registre o pedido e acione o Encarregado (ver módulo Jurídico).</p>
        </>
      )}
    </div>
  );
}
