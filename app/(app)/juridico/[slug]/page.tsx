import Link from "next/link";
import { notFound } from "next/navigation";
import LegalDocView from "@/components/legal/LegalDocView";
import PrintButton from "@/components/legal/PrintButton";
import { LEGAL_DOCS, findLegal } from "@/lib/legal";

export const dynamic = "force-static";
export function generateStaticParams() { return LEGAL_DOCS.map((d) => ({ slug: d.slug })); }

export default function LegalDocPage({ params }: { params: { slug: string } }) {
  const doc = findLegal(params.slug);
  if (!doc) notFound();
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-2 flex-wrap print-hide">
        <Link href="/juridico" className="text-sm font-semibold no-underline" style={{ color: "var(--brand)" }}>← Jurídico & Compliance</Link>
        <div className="flex items-center gap-2">
          {doc!.publicPath && <Link href={doc!.publicPath} className="px-2.5 py-1.5 rounded-lg border text-xs no-underline" style={{ borderColor: "var(--border)" }}>ver versão pública ↗</Link>}
          <PrintButton />
        </div>
      </div>
      <div className="card p-5 sm:p-7">
        <LegalDocView slug={params.slug} />
      </div>
    </div>
  );
}
