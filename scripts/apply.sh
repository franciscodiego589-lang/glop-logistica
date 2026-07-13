#!/usr/bin/env bash
# Aplica as 16 migrations no projeto Supabase via URL do banco (sem login/token).
# A senha NUNCA fica no repositório: passe pela variável de ambiente SUPABASE_DB_PASSWORD.
#
# Uso (região us-east-1, projeto ittbmqnwomhkxnvlqjvl):
#   SUPABASE_DB_PASSWORD='suaSenha' ./scripts/apply.sh
#
# Ou informe a URL completa você mesmo:
#   SUPABASE_DB_URL='postgresql://...' ./scripts/apply.sh
set -euo pipefail
cd "$(dirname "$0")/.."

REF="${SUPABASE_PROJECT_REF:-ittbmqnwomhkxnvlqjvl}"
REGION_HOST="${SUPABASE_POOLER_HOST:-aws-0-us-east-1.pooler.supabase.com}"

if [[ -z "${SUPABASE_DB_URL:-}" ]]; then
  : "${SUPABASE_DB_PASSWORD:?defina SUPABASE_DB_PASSWORD (ou SUPABASE_DB_URL)}"
  # URL-encode simples do '@' e alguns caracteres comuns na senha
  ENC=$(python3 -c "import urllib.parse,os;print(urllib.parse.quote(os.environ['SUPABASE_DB_PASSWORD'],safe=''))")
  SUPABASE_DB_URL="postgresql://postgres.${REF}:${ENC}@${REGION_HOST}:5432/postgres"
fi

echo "→ Aplicando as 16 migrations em ordem no projeto ${REF}…"
npx --yes supabase@latest db push --db-url "$SUPABASE_DB_URL"
echo "✓ Banco no ar. Confira no Table Editor do dashboard."
