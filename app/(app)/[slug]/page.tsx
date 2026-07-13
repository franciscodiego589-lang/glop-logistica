import { notFound } from "next/navigation";
import { findNav } from "@/lib/nav";
import { MODULE_DETAILS } from "@/lib/moduleDetails";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function ModulePage({ params }: { params: { slug: string } }) {
  const nav = findNav(params.slug);
  if (!nav || params.slug === "dashboard") notFound();
  const detail = MODULE_DETAILS[params.slug];
  const supabase = createClient();

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-xl bg-brand-600 text-white grid place-items-center text-lg">{nav.icon}</div>
        <div>
          <h1 className="text-xl font-bold">{nav.label}</h1>
          <p className="text-sm muted">Volume {String(nav.vol).padStart(2, "0")} · {nav.description}</p>
        </div>
        <div className="ml-auto flex gap-2">
          {["Novo", "Importar", "Exportar", "Analisar"].map((a) => (
            <button key={a} className="text-sm px-3 py-2 rounded-lg border hover:border-brand-500" style={{ borderColor: "var(--border)" }}>{a}</button>
          ))}
        </div>
      </div>

      {!supabase && <VitrineBanner />}

      <div className="grid md:grid-cols-2 gap-3">
        <div className="card p-4">
          <div className="font-semibold mb-2">O que este módulo entrega</div>
          <ul className="space-y-1.5 text-sm">
            {detail?.features.map((f) => (
              <li key={f} className="flex gap-2"><span className="text-brand-500">✓</span><span>{f}</span></li>
            ))}
          </ul>
        </div>
        <div className="card p-4">
          <div className="font-semibold mb-2">Sustentação no banco</div>
          <div className="text-xs uppercase muted font-semibold mb-1">Tabelas</div>
          <div className="flex flex-wrap gap-1.5 mb-3">
            {detail?.tables.map((t) => (
              <code key={t} className="text-xs px-2 py-1 rounded-md border" style={{ borderColor: "var(--border)" }}>{t}</code>
            ))}
          </div>
          {detail?.rpcs && (
            <>
              <div className="text-xs uppercase muted font-semibold mb-1">RPCs (regras de negócio)</div>
              <div className="flex flex-wrap gap-1.5">
                {detail.rpcs.map((r) => (
                  <code key={r} className="text-xs px-2 py-1 rounded-md border border-brand-500/40 text-brand-500">{r}()</code>
                ))}
              </div>
            </>
          )}
        </div>
      </div>

      <div className="card p-8 grid place-items-center text-center">
        <div className="max-w-md">
          <div className="text-3xl mb-2">{nav.icon}</div>
          <div className="font-semibold">Tela operacional pronta para dados</div>
          <p className="text-sm muted mt-1">
            A estrutura, permissões e automações deste módulo já existem no banco. As telas de listagem,
            cadastro e KPIs são renderizadas aqui assim que o Supabase estiver conectado.
          </p>
        </div>
      </div>
    </div>
  );
}
