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
#
#   Tools/prod-confirm-test-user.sh --self-test   — the guard over fixtures (a temp allowlist, NEVER her file);
#                                                   the network is unreachable from it. F-R2-1 (VX-510 ladder round 2):
#                                                   the standing pin on O-L1-1's whole-value checks.
set -euo pipefail

# O-L1-1 (VX-510 unit L1 — the ladder's F-R1-5 class, fixed by the orchestrator): the shape is matched against the
# WHOLE value with zsh's =~ — never a line-wise grep, which passes a value whose first line is plain while a second
# line reaches the SQL splice below. first-run-walk.sh's plain_address is the same check.
PLAIN_ADDRESS='^[a-z0-9._+-]+@[a-z0-9.-]+\.[a-z]+$'

# guard <email> <allow_file> → 0, or a refusal on stderr and 2. The file's values are never printed.
guard() {
  local email=$1 file=$2
  case "$email" in
    *vxtest*) ;;
    *) echo "REFUSED: not a plainly-test address (no 'vxtest' marker)" >&2; return 2 ;;
  esac
  if [[ ! "$email" =~ $PLAIN_ADDRESS ]]; then
    echo "REFUSED: the address must be plain lowercase (letters, digits, . _ + -, one @)" >&2; return 2
  fi
  [ -f "$file" ] || { echo "REFUSED: no allowlist at $file" >&2; return 2; }
  [ "$(stat -f %Lp "$file")" = "600" ] || { echo "REFUSED: the allowlist must be mode 600" >&2; return 2; }
  local allowed
  allowed="$(set -a; source "$file"; set +a; print -r -- "${VARIORUM_PRODTEST_EMAILS:-}")"
  # Membership by zsh's own whole-string substring — the email is single-line by the check above; grep -F with a
  # multi-line pattern treats each line as its own pattern (the same class).
  if [[ " $allowed " != *" $email "* ]]; then
    echo "REFUSED: $email is not on the allowlist" >&2; return 2
  fi
  return 0
}

if [[ "${1:-}" == "--self-test" ]]; then
  # Fixtures only; the curl below is unreachable from this arm.
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  print -r -- 'VARIORUM_PRODTEST_EMAILS="good+vxtest-a@x.test good+vxtest-b@x.test"' > "$tmp/allow.env"
  chmod 600 "$tmp/allow.env"
  wrong=0
  expect() {
    local want=$1 email=$2 got
    if guard "$email" "$tmp/allow.env" 2>/dev/null; then got=accept; else got=refuse; fi
    [[ "$got" == "$want" ]] || { echo "SELF-TEST WRONG: $want expected for case '${3:-$email}' — got $got"; wrong=$((wrong + 1)); }
  }
  expect accept "good+vxtest-a@x.test" "a listed plain address"
  expect refuse "good+vxtest-a@x.test
'; select 1; --" "a multi-line value whose first line is plain (O-L1-1's shape)"
  expect refuse $'good+vxtest-a@x.test\n' "a trailing newline"
  expect refuse "GOOD+VXTEST-A@X.TEST" "uppercase"
  expect refuse "plain+vxtest@x.test" "plain shape, unlisted"
  expect refuse "someone@x.test" "no marker"
  if (( wrong )); then echo "SELF-TEST: $wrong case(s) wrong" >&2; exit 1; fi
  echo "SELF-TEST: every guard fired as expected"; exit 0
fi

EMAIL="${1:?usage: Tools/prod-confirm-test-user.sh '<test email>' | --self-test}"
ALLOW_FILE="$HOME/.variorum/prod-test-accounts.env"
guard "$EMAIL" "$ALLOW_FILE" || exit 2

cd "$(dirname "$0")/.."
source .env.supabase.local
REF="qpzmroxogeufzizcuunl"  # production, pinned — this script writes nothing else

Q="update auth.users set email_confirmed_at = now() where email = '$EMAIL' and email_confirmed_at is null returning id, email, email_confirmed_at"
curl -s -X POST "https://api.supabase.com/v1/projects/$REF/database/query" \
  -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary "$(python3 -c 'import json,sys; print(json.dumps({"query": sys.argv[1]}))' "$Q")"
echo
