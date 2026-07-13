export function VitrineBanner() {
  return (
    <div className="card p-4 border-dashed" style={{ borderColor: "var(--border)" }}>
      <div className="flex items-start gap-3">
        <div className="text-xl">🔌</div>
        <div>
          <div className="font-semibold">Modo vitrine — banco ainda não conectado</div>
          <p className="text-sm muted mt-1 max-w-2xl">
            O schema completo (16 volumes) já existe em <code>supabase/migrations/</code>. Assim que o
            projeto Supabase for provisionado e as variáveis <code>NEXT_PUBLIC_SUPABASE_URL</code> /
            <code> NEXT_PUBLIC_SUPABASE_ANON_KEY</code> forem definidas, estas telas passam a ler dados reais
            (RPCs <code>executive_dashboard</code>, <code>inventory_kpis</code>, <code>control_tower_kpis</code>…).
          </p>
        </div>
      </div>
    </div>
  );
}
