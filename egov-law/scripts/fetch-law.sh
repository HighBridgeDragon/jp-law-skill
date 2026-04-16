#!/bin/bash
set -e

# 法令本文取得 — GET /law_data/{law_id}
# Usage: bash scripts/fetch-law.sh <law_id> [elm]
# Example: bash scripts/fetch-law.sh 129AC0000000089 MainProvision-Article_709

LAW_ID="$1"
ELM="$2"

if [ -z "$LAW_ID" ]; then
  echo "Usage: bash scripts/fetch-law.sh <law_id> [elm]" >&2
  exit 1
fi

URL="https://laws.e-gov.go.jp/api/2/law_data/${LAW_ID}"
if [ -n "$ELM" ]; then
  URL="${URL}?elm=${ELM}"
fi

curl -s "$URL"
