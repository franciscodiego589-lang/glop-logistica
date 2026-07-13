#!/usr/bin/env bash
# Aplica as 16 migrations no projeto Supabase novo (ERP Logístico).
# Uso:
#   1) Crie o projeto em https://supabase.com  (guarde o Project Ref e a DB password)
#   2) export SUPABASE_ACCESS_TOKEN=...   (gere em https://supabase.com/dashboard/account/tokens)
#   3) ./scripts/apply.sh <PROJECT_REF>
set -euo pipefail
REF="${1:?Passe o Project Ref: ./scripts/apply.sh <ref>}"
cd "$(dirname "$0")/.."

echo "→ Linkando projeto $REF (vai pedir a DB password)…"
npx --yes supabase@latest link --project-ref "$REF"

echo "→ Aplicando as 16 migrations em ordem…"
npx --yes supabase@latest db push

echo "✓ Banco no ar. Depois crie os buckets e rode bootstrap_organization (ver README)."
