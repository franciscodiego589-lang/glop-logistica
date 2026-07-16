import Link from "next/link";
import { LEGAL_DOCS } from "@/lib/legal";
import { LEGAL_CONTENT } from "@/lib/legal-content.generated";

export const dynamic = "force-static";

export default function JuridicoHubPage() {
  const publicos = LEGAL_DOCS.filter((d) => d.tipo === "publico");
  const internos = LEGAL_DOCS.filter((d) => d.tipo === "interno");

  const Card = ({ d }: { d: (typeof LEGAL_DOCS)[number] }) => {
    const pronto = (LEGAL_CONTENT[d.slug] || "").trim().length > 0;
    return (
      <div className="card p-4 flex flex-col">
        <div className="flex items-start gap-2">
          <span className="text-xl">{d.icon}</span>
          <div className="flex-1 min-w-0">
            <div className="font-bold text-sm">{d.title}</div>
            <div className="text-[11px] muted">Versão {d.versao}{pronto ? "" : " · em geração"}</div>
          </div>
          <span className={`badge ${d.tipo === "publico" ? "badge-success" : "badge-neutral"}`}>{d.tipo === "publico" ? "público" : "interno"}</span>
        </div>
        <p className="text-xs muted mt-2 flex-1">{d.resumo}</p>
        <div className="flex items-center gap-2 mt-3">
          <Link href={`/juridico/${d.slug}`} className="px-3 py-1.5 rounded-lg bg-brand-600 text-white text-xs font-semibold no-underline">Abrir documento →</Link>
          {d.publicPath && <Link href={d.publicPath} className="px-2.5 py-1.5 rounded-lg border text-xs no-underline" style={{ borderColor: "var(--border)" }} title="Link público (sem login)">link público ↗</Link>}
        </div>
      </div>
    );
  };

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs font-semibold tracking-wide" style={{ color: "var(--brand)" }}>GOVERNANÇA & COMPLIANCE · JURÍDICO</div>
        <h1 className="text-2xl font-extrabold tracking-tight mt-0.5">Jurídico & Compliance</h1>
        <p className="text-sm muted mt-0.5">Núcleo documental do GLOP: privacidade, termos, segurança e conformidade com a LGPD.</p>
      </div>

      <div className="card p-4 text-sm" style={{ borderLeft: "3px solid var(--warning)" }}>
        <b>⚠️ Minutas geradas por IA — pendentes de validação jurídica.</b>
        <p className="muted mt-1">Estes documentos são versões de trabalho de alta qualidade, adaptadas à arquitetura real do GLOP. Antes de publicar/assinar, submeta à revisão de um(a) advogado(a) habilitado(a) e preencha os campos entre [colchetes] (razão social, CNPJ, Encarregado/DPO, etc.). A legislação muda — revise periodicamente.</p>
      </div>

      <div>
        <div className="text-xs uppercase font-bold muted mb-2">Documentos públicos (comprador/cliente)</div>
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">{publicos.map((d) => <Card key={d.slug} d={d} />)}</div>
      </div>

      <div>
        <div className="text-xs uppercase font-bold muted mb-2">Documentos internos (empresa)</div>
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">{internos.map((d) => <Card key={d.slug} d={d} />)}</div>
      </div>

      <div className="card p-3 text-xs muted">
        💡 Os documentos <b>públicos</b> têm link sem login (ex.: <code className="font-mono">/privacidade</code>, <code className="font-mono">/termos</code>, <code className="font-mono">/cookies</code>) — use no rodapé do site, no checkout e nas comunicações ao comprador. Próximas levas: contratos (SaaS, transportador, marketplace…), políticas internas, SLA, códigos de ética/conduta e matriz de riscos.
      </div>
    </div>
  );
}
