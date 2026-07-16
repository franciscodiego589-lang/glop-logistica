import LegalMarkdown from "./LegalMarkdown";
import { findLegal } from "@/lib/legal";
import { LEGAL_CONTENT } from "@/lib/legal-content.generated";

// Cabeçalho + corpo de um documento jurídico (usado nas telas internas e públicas).
export default function LegalDocView({ slug }: { slug: string }) {
  const doc = findLegal(slug);
  const md = (LEGAL_CONTENT[slug] || "").trim();
  if (!doc) return <p className="text-sm muted">Documento não encontrado.</p>;

  return (
    <article>
      <div className="mb-4">
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>
          DOCUMENTO JURÍDICO · {doc.tipo === "publico" ? "PÚBLICO" : "USO INTERNO"}
        </div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">{doc.icon} {doc.title}</h1>
        <div className="text-xs muted mt-1">Versão {doc.versao} · atualizado em {new Date(doc.atualizado).toLocaleDateString("pt-BR")}</div>
      </div>
      {md
        ? <LegalMarkdown md={md} />
        : <div className="card p-6 text-sm muted">Este documento está sendo gerado. Volte em instantes.</div>}
    </article>
  );
}
