#!/bin/zsh
# Tools/prod-confirm-test-user.sh '<email>' — confirm ONE production TEST account's email, and nothing else.
# Born at VX-510 (2026-10-23), her ruling R-510-7: "can you confirm them in the dashboard via the PAT? i want you to
# be as capable as possible" — shaped as a narrow named road (R-510-3, the Tools/prod-read.sh precedent). The allow
# rule in .claude/settings.local.json names THIS script, so the guard here is the fence that makes that rule safe:
#   - the email must be on the local allowlist (~/.variorum/prod-test-accounts.env, VARIORUM_PRODTEST_EMAILS, mode 600)
#   - the email must carry the plainly-test marker "vxtest"
#   - the email must be plain (lowercase letters, digits, . _ + - and one @) — it is spliced into SQL
#   - the ONE statement sets email_confirmed_at on that row only while it is still NULL (a no-op otherwise)
# It never deletes, never touches another column, another user, or any table but auth.users. Ref pinned to production.
set -euo pipefail

EMAIL="${1:?usage: Tools/prod-confirm-test-user.sh '<test email>'}"
ALLOW_FILE="$HOME/.variorum/prod-test-accounts.env"

case "$EMAIL" in
  *vxtest*) ;;
  *) echo "REFUSED: not a plainly-test address (no 'vxtest' marker)" >&2; exit 2 ;;
esac
# O-L1-1 (VX-510 unit L1 — the ladder's F-R1-5 class, fixed here by the orchestrator): the shape is matched against
# the WHOLE value with zsh's =~ — never a line-wise grep, which passes a value whose first line is plain while a
# second line reaches the SQL splice below. first-run-walk.sh's plain_address is the same check.
PLAIN_ADDRESS='^[a-z0-9._+-]+@[a-z0-9.-]+\.[a-z]+$'
if [[ ! "$EMAIL" =~ $PLAIN_ADDRESS ]]; then
  echo "REFUSED: the address must be plain lowercase (letters, digits, . _ + -, one @)" >&2; exit 2
fi
[ -f "$ALLOW_FILE" ] || { echo "REFUSED: no allowlist at $ALLOW_FILE" >&2; exit 2; }
[ "$(stat -f %Lp "$ALLOW_FILE")" = "600" ] || { echo "REFUSED: the allowlist must be mode 600" >&2; exit 2; }
ALLOWED="$(set -a; source "$ALLOW_FILE"; set +a; print -r -- "${VARIORUM_PRODTEST_EMAILS:-}")"
# Membership by zsh's own whole-string substring — EMAIL is single-line by the check above; grep -F with a multi-line
# pattern treats each line as its own pattern (the same class).
if [[ " $ALLOWED " != *" $EMAIL "* ]]; then
  echo "REFUSED: $EMAIL is not on the allowlist" >&2; exit 2
fi

cd "$(dirname "$0")/.."
source .env.supabase.local
REF="qpzmroxogeufzizcuunl"  # production, pinned — this script writes nothing else

Q="update auth.users set email_confirmed_at = now() where email = '$EMAIL' and email_confirmed_at is null returning id, email, email_confirmed_at"
curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" \
  -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary "$(python3 -c 'import json,sys; print(json.dumps({"query": sys.argv[1]}))' "$Q")"
echo
