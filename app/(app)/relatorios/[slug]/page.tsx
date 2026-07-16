import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { VitrineBanner } from "@/components/VitrineBanner";
import ReportView from "@/components/relatorios/ReportView";
import PrintButton from "@/components/ui/PrintButton";
import { findRelatorio } from "@/lib/relatorios";

export const dynamic = "force-dynamic";

const PERIODOS = [7, 30, 90, 365];

export default async function RelatorioPage({ params, searchParams }: { params: { slug: string }; searchParams?: { dias?: string } }) {
  const r = findRelatorio(params.slug);
  if (!r) notFound();

  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  const dias = r!.periodo ? Math.max(Math.trunc(Number(searchParams?.dias ?? r!.diasPadrao)) || r!.diasPadrao, 1) : r!.diasPadrao;

  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-2xl font-extrabold">{r!.icon} {r!.title}</h1><VitrineBanner /></div>;
  }

  const { data, error } = await supabase.rpc(r!.rpc, { p_company: company, p_days: dias });
  const erro = !!error && data == null;

  return (
    <div className="space-y-4">
      <div className="flex items-end justify-between flex-wrap gap-2">
        <div>
          <Link href="/relatorios" className="text-xs font-semibold no-underline" style={{ color: "var(--brand)" }}>← Central de Relatórios</Link>
          <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">{r!.icon} {(data as any)?.titulo ?? r!.title}</h1>
          <p className="text-sm muted mt-0.5">{(data as any)?.periodo ?? r!.resumo}</p>
        </div>
        <div className="flex items-center gap-1.5 print-hide">
          {r!.periodo && PERIODOS.map((p) => (
            <Link key={p} href={`/relatorios/${r!.slug}?dias=${p}`} className={`px-3 py-1.5 rounded-lg text-xs font-semibold no-underline ${dias === p ? "bg-brand-600 text-white" : "border"}`} style={dias === p ? undefined : { borderColor: "var(--border)" }}>{p}d</Link>
          ))}
          <PrintButton />
        </div>
      </div>

      {erro ? (
        <div className="card p-6 text-center" style={{ borderLeft: "3px solid var(--danger)" }}>
          <div className="text-3xl mb-2">⚠️</div>
          <div className="font-bold">Não foi possível carregar o relatório</div>
          <p className="text-sm muted mt-1">Houve uma falha ao consultar os dados. Recarregue a página ou tente outro período.</p>
        </div>
      ) : data ? (
        <ReportView data={data} />
      ) : (
        <div className="card p-6 text-sm muted">Carregando…</div>
      )}
    </div>
  );
}
