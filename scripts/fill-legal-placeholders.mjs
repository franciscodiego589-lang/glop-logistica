// Preenche os placeholders DA EMPRESA nos documentos jurídicos (content/legal/*.md).
// Mantém intactos os placeholders por-contrato ([PARTE], [CONTRATANTE], [CPF], nºs, etc.).
// Uso: node scripts/fill-legal-placeholders.mjs
import { readFileSync, writeFileSync, readdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const dir = join(root, "content", "legal");

// Dados oficiais (Receita/BrasilAPI) — CNPJ 55.836.075/0001-07
const RAZAO = "LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA";
const CNPJ = "55.836.075/0001-07";
const ENDERECO = "Rua Érico Veríssimo, s/nº, Quadra 05, Lote 10, Bairro Santa Cruz, Cuiabá/MT, CEP 78.068-190";
const CIDADE_UF = "Cuiabá/MT";
const EMAIL_DPO = "lemoncapsencapsulados@gmail.com";
const URL_SITE = "https://glop-logistica.netlify.app";
const DATA = "16 de julho de 2026";
const NOME_ENCARREGADO = "a ser designado pela administração"; // titular preencherá o nome com o advogado

// Ordem importa: strings mais específicas primeiro (evita colisão parcial).
const subs = [
  ["[ENDEREÇO COMPLETO]", ENDERECO],
  ["[ENDEREÇO]", ENDERECO],
  ["[E-MAIL DO DPO/ENCARREGADO]", EMAIL_DPO],
  ["[E-MAIL DO DPO]", EMAIL_DPO],
  ["[CIDADE/UF DA SEDE]", CIDADE_UF],
  ["[CIDADE/UF]", CIDADE_UF],
  ["[COMARCA/UF]", "Comarca de Cuiabá/MT"],
  ["[RAZÃO SOCIAL]", RAZAO],
  ["[CNPJ]", CNPJ],
  ["[URL DO SITE]", URL_SITE],
  ["[DATA]", DATA],
];
if (NOME_ENCARREGADO) subs.push(["[NOME DO ENCARREGADO]", NOME_ENCARREGADO]);

const replaceAll = (s, from, to) => s.split(from).join(to);

let totalFiles = 0, totalSubs = 0;
for (const f of readdirSync(dir).filter((f) => f.endsWith(".md"))) {
  const p = join(dir, f);
  let txt = readFileSync(p, "utf8");
  let n = 0;
  for (const [from, to] of subs) {
    const before = txt;
    txt = replaceAll(txt, from, to);
    if (txt !== before) n += (before.length - txt.length + (to.length - from.length)) >= 0 ? 1 : 1;
  }
  writeFileSync(p, txt);
  totalFiles++;
}
console.log(`OK — placeholders da empresa preenchidos em ${totalFiles} documentos.`);
console.log(NOME_ENCARREGADO ? "" : "ATENÇÃO: [NOME DO ENCARREGADO] permanece a preencher (informe o nome do DPO).");
