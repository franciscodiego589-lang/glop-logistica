// Gera lib/legal-content.generated.ts a partir de content/legal/*.md
// Uso: node scripts/gen-legal-content.mjs
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const slugs = ["politica-privacidade", "termos-de-uso", "politica-cookies", "politica-seguranca", "dpa", "ropa-ripd"];

const map = {};
for (const s of slugs) {
  const p = join(root, "content", "legal", s + ".md");
  map[s] = existsSync(p) ? readFileSync(p, "utf8") : "";
}

const body =
  "// GERADO automaticamente a partir de content/legal/*.md — não editar à mão.\n" +
  "// Regenerar com: node scripts/gen-legal-content.mjs\n" +
  "export const LEGAL_CONTENT: Record<string, string> = " +
  JSON.stringify(map, null, 2) +
  ";\n";

writeFileSync(join(root, "lib", "legal-content.generated.ts"), body);
const sizes = slugs.map((s) => `${s}: ${map[s].length}`).join("  ·  ");
console.log("OK legal-content.generated.ts —", sizes);
