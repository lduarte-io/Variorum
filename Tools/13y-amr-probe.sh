#!/bin/zsh
# 13y deploy window — the amr refresh-survival probe (memo §5's named check).
# CONTENT-FREE by construction: prompts for the suite email + password
# interactively (never in the transcript, never in an argument), mints a
# THROWAWAY session, decodes the JWT's amr claim, refreshes the token,
# decodes again, prints ONLY the two amr claims + the verdict, and signs
# the throwaway session out. If the password timestamp BUMPS on refresh,
# the truncate re-auth guard is hollow — record and re-open #144(c)'s
# design at the checkpoint (the door has no production caller yet).
set -euo pipefail
source ~/dev/variorum/.env.supabase.local

printf "suite email: "; read EMAIL
printf "suite password (hidden): "; read -s PW; echo

amr_of() {
  python3 -c "
import sys, base64, json
part = sys.argv[1].split('.')[1]
part += '=' * (-len(part) % 4)
claims = json.loads(base64.urlsafe_b64decode(part))
print(json.dumps(claims.get('amr')))" "$1"
}

R1=$(curl -s "$VARIORUM_SUPABASE_URL/auth/v1/token?grant_type=password" \
  -H "apikey: $VARIORUM_SUPABASE_API_KEY" -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PW\"}")
unset PW
AT1=$(echo "$R1" | jq -r '.access_token // empty')
RT1=$(echo "$R1" | jq -r '.refresh_token // empty')
if [ -z "$AT1" ]; then
  echo "SIGN-IN FAILED: $(echo "$R1" | jq -r '.error_description // .msg // .error // "unknown"')"
  exit 1
fi
AMR1=$(amr_of "$AT1")

R2=$(curl -s "$VARIORUM_SUPABASE_URL/auth/v1/token?grant_type=refresh_token" \
  -H "apikey: $VARIORUM_SUPABASE_API_KEY" -H "Content-Type: application/json" \
  -d "{\"refresh_token\":\"$RT1\"}")
AT2=$(echo "$R2" | jq -r '.access_token // empty')
if [ -z "$AT2" ]; then
  echo "REFRESH FAILED: $(echo "$R2" | jq -r '.error_description // .msg // .error // "unknown"')"
  exit 1
fi
AMR2=$(amr_of "$AT2")

echo "amr before refresh: $AMR1"
echo "amr after  refresh: $AMR2"
if [ "$AMR1" = "$AMR2" ]; then
  echo "VERDICT: BYTE-IDENTICAL — the truncate guard's timestamp survives refresh."
else
  echo "VERDICT: CHANGED — record it; #144(c)'s fallback (auth.sessions.created_at) re-opens at the checkpoint."
fi

# Best-effort: retire the throwaway session.
curl -s -o /dev/null -X POST "$VARIORUM_SUPABASE_URL/auth/v1/logout" \
  -H "apikey: $VARIORUM_SUPABASE_API_KEY" -H "Authorization: Bearer $AT2" || true
echo "(throwaway session signed out)"
