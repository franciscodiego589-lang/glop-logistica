import Link from "next/link";
import LegalDocView from "./LegalDocView";
import { LEGAL_DOCS } from "@/lib/legal";

// Casca pública (sem login) para os documentos abertos ao comprador/cliente.
export default function PublicLegalShell({ slug }: { slug: string }) {
  const publicos = LEGAL_DOCS.filter((d) => d.tipo === "publico");
  const ano = new Date().getFullYear();
  return (
    <div className="min-h-screen" style={{ background: "var(--bg)" }}>
      <div className="max-w-3xl mx-auto px-5 py-8">
        <div className="flex items-center gap-2.5 mb-6">
          <div className="h-10 w-10 rounded-xl grid place-items-center font-bold text-lg text-white" style={{ background: "linear-gradient(150deg,#2f56e6,#1a336f)" }}>◈</div>
          <div><div className="font-bold">GLOP</div><div className="text-xs muted">Documentos legais</div></div>
        </div>

        <nav className="flex flex-wrap gap-2 mb-5">
          {publicos.map((d) => (
            <Link key={d.slug} href={d.publicPath!} className="px-3 py-1.5 rounded-lg border text-sm no-underline" style={{ borderColor: "var(--border)" }}>
              {d.icon} {d.short}
            </Link>
          ))}
        </nav>

        <div className="card p-5 sm:p-7">
          <LegalDocView slug={slug} />
        </div>

        <div className="text-center text-xs muted mt-6">
          © {ano} GLOP · <Link href="/rastreio" className="no-underline" style={{ color: "var(--brand)" }}>Rastrear pedido</Link>
        </div>
      </div>
    </div>
  );
}
