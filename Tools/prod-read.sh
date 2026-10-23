#!/bin/zsh
# Tools/prod-read.sh '<one SELECT>' — the read-only production query road.
# Born at the 0.10 window (2026-10-23), her word: "I want to add permissions so
# that it can read prod to see if they are added." The allow rule in
# .claude/settings.local.json names THIS script, so the SELECT-only guard here
# is the fence that makes that rule safe: one statement, a bare SELECT, no
# semicolons, no WITH (Postgres allows data-modifying CTEs), no mutating
# keyword anywhere. Anything else is REFUSED — a mutating act is her `!` road
# at her explicit word, never this script's.
set -euo pipefail

Q="${1:?usage: Tools/prod-read.sh 'select …'}"

case "$Q" in
  *";"*) echo "REFUSED: one statement, no semicolons" >&2; exit 2 ;;
esac

q="$(printf '%s' "$Q" | sed -e 's/^[[:space:]]*//' | tr '[:upper:]' '[:lower:]')"
case "$q" in
  select\ *) ;;
  *) echo "REFUSED: only a single SELECT runs here (no WITH — data-modifying CTEs exist)" >&2; exit 2 ;;
esac

if printf '%s' "$q" | grep -Eq '\b(insert|update|delete|truncate|drop|alter|grant|revoke|create|copy|call|do|vacuum|merge|set|lock)\b'; then
  echo "REFUSED: a mutating or ambiguous keyword appears in the text; reword the read, or use the ! road" >&2
  exit 2
fi

cd "$(dirname "$0")/.."
source .env.supabase.local
REF="qpzmroxogeufzizcuunl"  # production, pinned — this script reads nothing else

curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" \
  -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary "$(python3 -c 'import json,sys; print(json.dumps({"query": sys.argv[1]}))' "$Q")"
echo
