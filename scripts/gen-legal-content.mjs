// Gera lib/legal-content.generated.ts a partir de TODOS os content/legal/*.md
// Uso: node scripts/gen-legal-content.mjs
import { readFileSync, writeFileSync, readdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const dir = join(root, "content", "legal");

const map = {};
for (const f of readdirSync(dir).filter((f) => f.endsWith(".md")).sort()) {
  map[f.replace(/\.md$/, "")] = readFileSync(join(dir, f), "utf8");
}

const body =
  "// GERADO automaticamente a partir de content/legal/*.md — não editar à mão.\n" +
  "// Regenerar com: node scripts/gen-legal-content.mjs\n" +
  "export const LEGAL_CONTENT: Record<string, string> = " +
  JSON.stringify(map, null, 2) +
  ";\n";

writeFileSync(join(root, "lib", "legal-content.generated.ts"), body);
console.log("OK legal-content.generated.ts —", Object.keys(map).length, "documentos:", Object.keys(map).join(", "));
