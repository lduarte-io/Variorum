#!/bin/zsh
# Tools/prod-reset-test-account.sh — reset ONE allowlisted production TEST account to its RESTING STATE: the account
# exists and keeps its auth user and its entitlement; it holds NO vault, NO `kp:` proof secret and NO rows (data, device
# cursors, purged-ids ledger, tenant seq, challenge nonces, write budget). Born at VX-623 (2026-10-27) under her
# STANDING RULING: "I want to give a standing ruling that the walk may reset its own allowlisted test accounts." —
# ONLY the walk's own allowlisted vxtest accounts; her own account can never pass; production stays read-only everywhere
# else (Tools/prod-read.sh) except at her hand. The run record: notes/plans/fixes/vx-623-walk-self-reset.md (D-1).
# A sibling of Tools/prod-read.sh and Tools/prod-confirm-test-user.sh, through the same Management-API endpoint and the
# same pinned production ref — and, like them, the guard here is the fence that makes a narrow allow rule safe.
#
#   Tools/prod-reset-test-account.sh <std|castle|del> [--dry-run] [--log <file>]
#   Tools/prod-reset-test-account.sh --self-test
#
# THE STATEMENT is ONE atomic data-modifying CTE mirroring account_purge() (the latest body — today
# Server/supabase/13_phase13i_wings.sql:851-917) MINUS the auth user and the entitlement: the 21 data tables, device_cursor,
# purged_row, sync_tenant_seq, key_proof_challenge, sync_write_budget, the vault's `kp:<id>` secret and the key_vault row.
# The `kp:` secret is INSIDE the atomic statement, not best-effort as in the purge: the purge's uuid dies with the account,
# so a dangling secret there authorizes nothing — but a reset KEEPS the uuid, and a secret left behind makes the next
# set-up's key_proof_enroll meet VARIORUM_KEY_PROOF_ALREADY_ENROLLED (12_phase13y_tenant_seq.sql:611-615) while every
# later proof is checked against the OLD master's kp2 — so the reset is all-or-nothing, and the after-read demands kp 0.
# The self-test pins the family to account_purge()'s own body, so a table the purge gains turns the self-test red.
#
# It REFUSES (exit 5 — nothing written) unless EVERY guard holds, in order:
#   R1  the account is std · castle · del, and the allowlist ~/.variorum/prod-test-accounts.env is a regular file (never a
#       link), mode 600, every listed email carries 'vxtest', and this account's email is PLAIN (matched whole — it is
#       spliced into a SELECT) and listed — first-run-walk.sh's G1/G2, VERBATIM (`guard_allowlist`; the self-test pins
#       the two functions byte-identical). The guard hands back the email it CHECKED, and that is the one value R3 uses —
#       the file is never re-read (the VX-623 ladder's round-1 check-to-use seam; pinned)
#   R2  the road's tools: Tools/prod-read.sh (every read goes through its SELECT-only fence) and .env.supabase.local
#   R3  the account's id is resolved by its own guarded email→id read: exactly ONE auth user, its email BYTE-EQUAL to the
#       email R1 checked, its id a lowercase UUID (the only value the statement splices)
#   R4  the before-read parses whole (every count present and an integer) — any doubt refuses
# Then: already at rest → nothing written (exit 0) · --dry-run → the plan and the before-read printed (exit 0) · else the
# one statement, then the after-read, ALWAYS (the after-read is the truth, whatever the write's answer said).
# Exit: 0 the account is at rest · 4 the reset did not reach the resting state (the statement refused — atomic, nothing
# written — or the after-read shows a family row, a lost auth user or a changed entitlement; both reads printed) ·
# 5 refused (a guard; nothing written). The before/after reads are printed and appended to the log (default
# App/Variorum/DerivedData/prod-reset/<UTC>-<account>.log, gitignored; --log names another).
# Quit (or sign out) any walk instance signed in to the account first: a signed-in app mints challenge rows on its own
# (sync_challenge needs no vault — 12_phase13y_tenant_seq.sql:526-534), so a reset under it ends not at rest (exit 4).
# The walk sequences this itself (Tools/WalkKit/first-run-walk.sh: the pre-step runs signed out, the cleanup leg after
# its own quit).

emulate -L zsh
setopt pipe_fail

SELF=${0:A}
REPO=${SELF:h:h}
ALLOW=$HOME/.variorum/prod-test-accounts.env
REF="qpzmroxogeufzizcuunl"   # production, pinned — this script writes nothing else
PRODREAD=$REPO/Tools/prod-read.sh

# THE FAMILY (account_purge()'s, 13_phase13i_wings.sql:856-861 + 890-901, minus entitlement and auth.users).
DATA_TABLES=(container block variant commit_point edge container_block wing shelf reading reading_section
  reading_post tag post_tag block_tag reference canvas_layout lens lens_choice block_comment setting purge_intent)
SERVER_TABLES=(device_cursor purged_row sync_tenant_seq key_proof_challenge sync_write_budget)
UUID_SHAPE='^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'

refuse() { print -u2 -r -- "prod-reset-test-account REFUSES: $*"; exit 5 }

# --- R1, VERBATIM from Tools/WalkKit/first-run-walk.sh (G1 + G2) — the self-test pins the twins byte-identical ---------
PLAIN_ADDRESS='^[a-z0-9._+-]+@[a-z0-9.-]+\.[a-z]+$'
plain_address() { [[ $1 =~ $PLAIN_ADDRESS ]] }
guard_allowlist() {
  local file=$1 account=$2
  case $account in std|castle|del) ;; *) print -r -- "unknown account '$account' (std | castle | del)"; return 1 ;; esac
  [[ -f $file && ! -L $file ]] || { print -r -- "no allowlist at $file (a regular file, never a link)"; return 1 }
  [[ $(stat -f %Lp $file) == 600 ]] || { print -r -- "the allowlist must be mode 600"; return 1 }
  local upper=${(U)account} email list entry
  list=$(set -a; source $file 2>/dev/null; set +a; print -r -- "${VARIORUM_PRODTEST_EMAILS:-}")
  email=$(set -a; source $file 2>/dev/null; set +a; eval "print -r -- \"\${VARIORUM_PRODTEST_${upper}_EMAIL:-}\"")
  [[ -n ${list// /} ]] || { print -r -- "the allowlist names no account"; return 1 }
  for entry in ${=list}; do
    [[ $entry == *vxtest* ]] || { print -r -- "an allowlist entry is not a plainly-test address"; return 1 }
  done
  [[ -n $email ]] || { print -r -- "no email for '$account' in the allowlist"; return 1 }
  [[ $email == *vxtest* ]] || { print -r -- "the $account account's email carries no 'vxtest' marker"; return 1 }
  plain_address "$email" || { print -r -- "the $account account's email is not a plain address (lowercase letters, digits, . _ + -, one @)"; return 1 }
  [[ " $list " == *" $email "* ]] || { print -r -- "the $account account's email is not on the allowlist"; return 1 }
  print -r -- "$email"
}
# --- end of the verbatim twin ---------------------------------------------------------------------------------------

# --- the statements (pure; the id is the ONLY splice, and only a UUID splices) --------------------------------------
# id_sql <email> — the R3 read (the email is PLAIN by R1, re-checked here at the splice).
id_sql() { plain_address "$1" || return 1; print -r -- "select id, email from auth.users where email = '$1'" }
# counts_sql <id> — the before/after read: every family member's count, plus what the reset KEEPS (entitlement, the auth
# user) and the vault's posture (mode, revision) for the log. A bare SELECT: Tools/prod-read.sh's fence accepts it (pinned).
counts_sql() {
  local id=$1 t cols=()
  [[ $id =~ $UUID_SHAPE ]] || return 1
  cols+=("(select count(*) from key_vault where user_id = '$id') as vault")
  cols+=("(select count(*) from vault.secrets where name = 'kp:$id') as kp")
  for t in $SERVER_TABLES; do cols+=("(select count(*) from $t where owner_id = '$id') as $t"); done
  for t in $DATA_TABLES; do cols+=("(select count(*) from $t where owner_id = '$id') as d_$t"); done
  cols+=("(select count(*) from entitlement where user_id = '$id') as entitlement")
  cols+=("(select count(*) from auth.users where id = '$id') as auth_user")
  cols+=("(select mode from key_vault where user_id = '$id') as vault_mode")
  cols+=("(select revision from key_vault where user_id = '$id') as vault_revision")
  print -r -- "select ${(j:, :)cols}"
}
# reset_sql <id> — THE ONE STATEMENT: every family delete as a data-modifying CTE (each runs exactly once, to completion,
# whether or not the outer SELECT reads it — one statement, one transaction: all or nothing), answering what each took.
reset_sql() {
  local id=$1 t ctes=() sum=() outs=()
  [[ $id =~ $UUID_SHAPE ]] || return 1
  for t in $DATA_TABLES; do ctes+=("d_$t as (delete from $t where owner_id = '$id' returning 1)"); sum+=("(select count(*) from d_$t)"); done
  for t in $SERVER_TABLES; do ctes+=("s_$t as (delete from $t where owner_id = '$id' returning 1)"); outs+=("(select count(*) from s_$t) as $t"); done
  ctes+=("s_kp as (delete from vault.secrets where name = 'kp:$id' returning 1)"); outs+=("(select count(*) from s_kp) as kp")
  ctes+=("s_vault as (delete from key_vault where user_id = '$id' returning 1)"); outs+=("(select count(*) from s_vault) as vault")
  print -r -- "with ${(j:, :)ctes} select ${(j: + :)sum} as data_rows, ${(j:, :)outs}"
}

# --- the readers (pure; python3 -I — JSON, never a grep). Never print a value from the answer but counts, the posture
#     and the id; an error answer is named by its class, never echoed (it may carry the statement's text). -------------
PY_LIB='
import json, re, sys
UUID = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")
def load(text, what):
    try:
        rows = json.loads(text)
    except Exception:
        sys.exit(print(what + " is not JSON") or 1)
    if not isinstance(rows, list):
        sys.exit(print(what + " was refused by the database (an error answer, not rows)") or 1)
    return rows
mode = sys.argv[1]
if mode == "resolve":                       # <json> <email> -> the id
    rows = load(sys.argv[2], "the account read")
    if len(rows) == 0: sys.exit(print("no production account has this address") or 1)
    if len(rows) != 1: sys.exit(print("the address resolves to %d auth users, not one" % len(rows)) or 1)
    r = rows[0]
    if not isinstance(r, dict) or not isinstance(r.get("email"), str) or r["email"] != sys.argv[3]:
        sys.exit(print("the resolved auth user\x27s email is not byte-equal to the allowlist\x27s entry") or 1)
    if not isinstance(r.get("id"), str) or not UUID.fullmatch(r["id"]):
        sys.exit(print("the resolved auth user\x27s id is not a lowercase UUID") or 1)
    print(r["id"])
elif mode == "counts":                      # <json> <keys…> -> one normalized "k=v …" line
    rows = load(sys.argv[2], "the account\x27s counts read")
    if len(rows) != 1 or not isinstance(rows[0], dict):
        sys.exit(print("the counts read answered %d rows, not one" % len(rows)) or 1)
    r, out = rows[0], []
    for k in sys.argv[3:]:
        v = r.get(k, "MISSING")
        if k == "vault_mode":
            if v is not None and not (isinstance(v, str) and re.fullmatch(r"[a-z]+", v)):
                sys.exit(print("the counts read carries no readable vault_mode") or 1)
            out.append("%s=%s" % (k, v if v is not None else "-"))
        elif k == "vault_revision":
            if v is not None and not (isinstance(v, int) and not isinstance(v, bool)):
                sys.exit(print("the counts read carries no readable vault_revision") or 1)
            out.append("%s=%s" % (k, v if v is not None else "-"))
        else:
            if not (isinstance(v, int) and not isinstance(v, bool)) or v < 0:
                sys.exit(print("the counts read carries no count for " + k) or 1)
            out.append("%s=%d" % (k, v))
    print(" ".join(out))
elif mode == "deleted":                     # <json> -> one line of what the statement took, or the refusal class
    rows = load(sys.argv[2], "the reset statement\x27s answer")
    if len(rows) != 1 or not isinstance(rows[0], dict): sys.exit(print("the reset statement answered no row") or 1)
    print(" ".join("%s=%s" % (k, rows[0][k]) for k in rows[0]))
'
py() { python3 -I -c "$PY_LIB" "$@" }
COUNT_KEYS=(vault kp $SERVER_TABLES ${DATA_TABLES/#/d_} entitlement auth_user vault_mode vault_revision)
kv() { local line=$1 key=$2 pair; for pair in ${=line}; do [[ ${pair%%=*} == $key ]] && { print -r -- ${pair#*=}; return 0 }; done; return 1 }
family_total() {  # <counts line> → the number of family rows (everything the reset deletes)
  local line=$1 k n=0
  for k in vault kp $SERVER_TABLES ${DATA_TABLES/#/d_}; do n=$(( n + $(kv $line $k) )); done
  print -r -- $n
}
at_rest() { [[ $(family_total $1) == 0 && $(kv $1 auth_user) == 1 ]] }   # <counts line>
summary() {  # <counts line> → one log line (counts and the posture only)
  local line=$1 t data=() d=0 v
  for t in $DATA_TABLES; do v=$(kv $line d_$t); (( v )) && data+=("$t $v"); d=$(( d + v )); done
  print -r -- "vault $(kv $line vault) (mode $(kv $line vault_mode), rev $(kv $line vault_revision)) · kp $(kv $line kp)" \
    "· cursors $(kv $line device_cursor) · purged $(kv $line purged_row) · seq $(kv $line sync_tenant_seq)" \
    "· challenges $(kv $line key_proof_challenge) · budget $(kv $line sync_write_budget)" \
    "· data $d${data:+ (${(j:, :)data})} · entitlement $(kv $line entitlement) · auth user $(kv $line auth_user)"
}
# after_verdict <before line> <after line> → 0 at rest with the auth user and the entitlement kept; else the reason, 1
after_verdict() {
  local b=$1 a=$2
  [[ $(kv $a auth_user) == 1 ]] || { print -r -- "the auth user is gone (auth user $(kv $a auth_user)) — the reset must never remove it"; return 1 }
  [[ $(kv $a entitlement) == $(kv $b entitlement) ]] || { print -r -- "the entitlement changed ($(kv $b entitlement) → $(kv $a entitlement)) — the reset never touches it"; return 1 }
  (( $(kv $a kp) == 0 )) || { print -r -- "the kp: proof secret survived — the next set-up's enrollment would meet ALREADY_ENROLLED against the old master"; return 1 }
  [[ $(family_total $a) == 0 ]] || { print -r -- "$(family_total $a) family row(s) remain"; return 1 }
  return 0
}

# --- the network (never reached by --self-test: the arm below replaces both with tripwires) -------------------------
prodread() { $PRODREAD "$1" }
prodwrite() {  # <one statement> → the Management API's answer; the token from .env.supabase.local, never in argv or printed
  ( cd $REPO || exit 1
    source ./.env.supabase.local 2>/dev/null || exit 1
    [[ -n ${SUPABASE_ACCESS_TOKEN:-} ]] || exit 1
    print -r -- "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" | curl -s -X POST \
      "https://api.supabase.com/v1/projects/$REF/database/query" -H @- -H "Content-Type: application/json" \
      --data-binary "$(python3 -I -c 'import json,sys; print(json.dumps({"query": sys.argv[1]}))' "$1")" )
}

# --- --self-test: every refusal over fixtures — never her file, never production ------------------------------------
if [[ ${1:-} == --self-test ]]; then
  prodread() { print -u2 "SELF-TEST reached the network (prodread)"; exit 99 }
  prodwrite() { print -u2 "SELF-TEST reached the network (prodwrite)"; exit 99 }
  T=$(mktemp -d)
  trap 'rm -rf $T' EXIT
  fails=0 cases=0
  ok()   { (( ++cases )); print -r -- "SELF-TEST $1  ok" }
  fail() { (( ++cases )); print -r -- "SELF-TEST $1  FAIL${2:+ ($2)}"; (( fails++ )) }
  check() { if eval "$2"; then ok "$1"; else fail "$1"; fi }   # <label> <zsh condition>

  # R1 — the walk's own G1/G2 fixtures, the same cases (first-run-walk.sh --self-test).
  okfile='VARIORUM_PRODTEST_EMAILS="a+vxtest-std@x.test b+vxtest-castle@x.test"
VARIORUM_PRODTEST_STD_EMAIL="a+vxtest-std@x.test"
VARIORUM_PRODTEST_CASTLE_EMAIL="b+vxtest-castle@x.test"
VARIORUM_PRODTEST_STD_PASSWORD="notasecret-vxtest0"'
  fixture() { print -r -- "$2" > $T/$1; chmod ${3:-600} $T/$1 }
  fixture good "$okfile"
  fixture open "$okfile" 644
  fixture unmarked 'VARIORUM_PRODTEST_EMAILS="a+vxtest-std@x.test her@x.test"
VARIORUM_PRODTEST_STD_EMAIL="a+vxtest-std@x.test"'
  fixture empty 'VARIORUM_PRODTEST_EMAILS=""
VARIORUM_PRODTEST_STD_EMAIL="a+vxtest-std@x.test"'
  fixture unlisted 'VARIORUM_PRODTEST_EMAILS="b+vxtest-castle@x.test"
VARIORUM_PRODTEST_STD_EMAIL="a+vxtest-std@x.test"'
  fixture quoted 'VARIORUM_PRODTEST_EMAILS="a+vxtest-std'\''x@x.test"
VARIORUM_PRODTEST_STD_EMAIL="a+vxtest-std'\''x@x.test"'
  fixture upper 'VARIORUM_PRODTEST_EMAILS="A+vxtest-std@X.test"
VARIORUM_PRODTEST_STD_EMAIL="A+vxtest-std@X.test"'
  fixture newline 'VARIORUM_PRODTEST_EMAILS="a+vxtest-std@x.test
'\''vxtest"
VARIORUM_PRODTEST_STD_EMAIL="a+vxtest-std@x.test
'\''vxtest"'
  fixture shaped 'VARIORUM_PRODTEST_EMAILS="someone08+vxtest-std@gmail.com"
VARIORUM_PRODTEST_STD_EMAIL="someone08+vxtest-std@gmail.com"'
  ln -s $T/good $T/link
  expect() {  # <label> <file> <account> <accept|refuse>
    local why rc got
    why=$(guard_allowlist $T/$2 $3); rc=$?
    got=accept; (( rc )) && got=refuse
    [[ $got == refuse ]] || why=   # (on accept the guard prints the checked email — never shown here)
    if [[ $got == $4 ]]; then ok "R1 $1: $got${why:+ ($why)}"; else fail "R1 $1: $got — expected $4"; fi
  }
  expect "a good file, std" good std accept
  expect "a good file, castle" good castle accept
  expect "an unknown account" good bogus refuse
  expect "mode 644" open std refuse
  expect "an unmarked entry" unmarked std refuse
  expect "an empty list" empty std refuse
  expect "the account not listed" unlisted std refuse
  expect "a link to a good file" link std refuse
  expect "no file" absent std refuse
  expect "a quote in the address" quoted std refuse
  expect "an uppercase address" upper std refuse
  expect "a newline in the address" newline std refuse
  expect "a plus-address with digits (the test accounts' shape)" shaped std accept
  # R1's twin: this file's guard and the walk's are the SAME text (a fix to one must be made to both).
  twin() { sed -n '/^guard_allowlist() {$/,/^}$/p' $1 }
  walk=$REPO/Tools/WalkKit/first-run-walk.sh
  check "R1 the guard is first-run-walk.sh's G1/G2, byte for byte" \
    '[[ -n $(twin $SELF) && $(twin $SELF) == $(twin $walk) ]]'
  check "R1 plain_address is the walk's, byte for byte" \
    '[[ -n $(grep -x "PLAIN_ADDRESS=.*" $SELF) && $(grep -x "PLAIN_ADDRESS=.*" $SELF) == $(grep -x "PLAIN_ADDRESS=.*" $walk) && $(grep -x "plain_address() .*" $SELF) == $(grep -x "plain_address() .*" $walk) ]]'
  # The ladder's round-1 finding 2 (the check-to-use seam): the email R3 splices and compares is the one R1 CHECKED —
  # guard_allowlist hands it back on accept, and the main path never re-reads the file.
  outside_reads() {  # <file> → how many lines source the allowlist outside guard_allowlist's body (and the walk's allowlist_value)
    awk '$0 == "guard_allowlist() {" { f = 1; next } f && $0 == "}" { f = 0; next } f { next } /^allowlist_value\(\) \{/ { next } { print }' $1 \
      | grep -c 'sour''ce \$'
  }
  check "R1 on accept prints exactly the CHECKED email (the one value R3 splices and compares)" \
    '[[ $(guard_allowlist $T/good std) == "a+vxtest-std@x.test" && $(guard_allowlist $T/good castle) == "b+vxtest-castle@x.test" ]]'
  check "R1 on a refusal prints the reason, never an address" \
    '[[ $(guard_allowlist $T/unmarked std) == "an allowlist entry is not a plainly-test address" ]]'
  check "R1 the allowlist is sourced only inside guard_allowlist — the main path never re-reads it" '[[ $(outside_reads $SELF) == 0 ]]'

  # R3 — the id read: exactly one auth user, its email byte-equal to the entry, a lowercase UUID.
  ID=0f3c2b1a-9d8e-4f7a-8b6c-5d4e3f2a1b0c
  E=a+vxtest-std@x.test
  resolve() { py resolve "$1" "$2" 2>/dev/null }
  check "R3 one auth user, its email equal → the id" '[[ $(resolve "[{\"id\":\"$ID\",\"email\":\"$E\"}]" $E) == $ID ]]'
  check "R3 the email differs by case → refuse" '! resolve "[{\"id\":\"$ID\",\"email\":\"A+vxtest-std@x.test\"}]" $E >/dev/null'
  check "R3 another address answered → refuse" '! resolve "[{\"id\":\"$ID\",\"email\":\"b+vxtest-castle@x.test\"}]" $E >/dev/null'
  check "R3 a trailing space in the answer → refuse" '! resolve "[{\"id\":\"$ID\",\"email\":\"$E \"}]" $E >/dev/null'
  check "R3 no auth user → refuse" '! resolve "[]" $E >/dev/null'
  check "R3 two auth users → refuse" '! resolve "[{\"id\":\"$ID\",\"email\":\"$E\"},{\"id\":\"$ID\",\"email\":\"$E\"}]" $E >/dev/null'
  check "R3 an id that is not a lowercase UUID → refuse" '! resolve "[{\"id\":\"0F3C2B1A-9D8E-4F7A-8B6C-5D4E3F2A1B0C\",\"email\":\"$E\"}]" $E >/dev/null'
  check "R3 an id carrying a quote → refuse" '! resolve "[{\"id\":\"$ID'\''x\",\"email\":\"$E\"}]" $E >/dev/null'
  check "R3 an error answer → refuse" '! resolve "{\"message\":\"Failed to run sql query\"}" $E >/dev/null'
  check "R3 not JSON → refuse" '! resolve "<html>502</html>" $E >/dev/null'
  check "R3 the address read refuses a non-plain address at the splice" '! id_sql "a+vxtest-std@x.test'\''; select 1" >/dev/null'

  # R4 — the counts read parses whole, or refuses.
  counts_json() {  # <overrides as k=v …> → a one-row JSON answer, every key 0 unless overridden
    python3 -I -c '
import json, sys
keys = sys.argv[1].split()
row = {k: 0 for k in keys}
row["auth_user"] = 1; row["entitlement"] = 1; row["vault_mode"] = None; row["vault_revision"] = None
for kv in sys.argv[2:]:
    k, v = kv.split("=", 1)
    row[k] = None if v == "null" else (v if not v.lstrip("-").isdigit() else int(v))
print(json.dumps([row]))' "${COUNT_KEYS[*]}" "$@"
  }
  parse() { py counts "$1" $COUNT_KEYS 2>/dev/null }
  rest=$(parse "$(counts_json)")
  check "R4 a clean account parses and is AT REST" '[[ -n $rest ]] && at_rest $rest'
  busy=$(parse "$(counts_json vault=1 vault_mode=standard vault_revision=3 kp=1 device_cursor=3 d_setting=3 d_container=1 sync_write_budget=1)")
  check "R4 a vault + rows parses and is NOT at rest" '[[ -n $busy ]] && ! at_rest $busy'
  check "R4 the summary says counts and posture only" \
    '[[ $(summary $busy) == "vault 1 (mode standard, rev 3) · kp 1 · cursors 3 · purged 0 · seq 0 · challenges 0 · budget 1 · data 4 (container 1, setting 3) · entitlement 1 · auth user 1" ]]'
  check "R4 a kp: secret alone is NOT at rest (the stale-secret trace)" 'kp=$(parse "$(counts_json kp=1)"); ! at_rest $kp'
  check "R4 challenge nonces alone are NOT at rest" 'c=$(parse "$(counts_json key_proof_challenge=2)"); ! at_rest $c'
  check "R4 a purge_intent row alone is NOT at rest" 'c=$(parse "$(counts_json d_purge_intent=1)"); ! at_rest $c'
  check "R4 no auth user is NOT at rest" 'c=$(parse "$(counts_json auth_user=0)"); ! at_rest $c'
  check "R4 a missing count → refuse" '! py counts "[{\"vault\":0}]" $COUNT_KEYS >/dev/null'
  check "R4 a count that is not an integer → refuse" '! parse "$(counts_json d_setting=x)" >/dev/null'
  check "R4 a boolean for a count → refuse" '! py counts "$(counts_json | sed "s/\"kp\": 0/\"kp\": true/")" $COUNT_KEYS >/dev/null'
  check "R4 an unreadable vault_mode → refuse" '! parse "$(counts_json vault_mode=St4nd)" >/dev/null'
  check "R4 two rows → refuse" '! py counts "[{},{}]" $COUNT_KEYS >/dev/null'
  check "R4 an error answer → refuse" '! py counts "{\"message\":\"x\"}" $COUNT_KEYS >/dev/null'

  # The after-read's verdict.
  check "AFTER at rest, auth user and entitlement kept → ok" 'after_verdict $busy $rest >/dev/null'
  check "AFTER the auth user gone → not ok" 'a=$(parse "$(counts_json auth_user=0)"); ! after_verdict $busy $a >/dev/null'
  check "AFTER the entitlement changed → not ok" 'a=$(parse "$(counts_json entitlement=0)"); ! after_verdict $busy $a >/dev/null'
  check "AFTER the kp: secret survived → not ok, named" 'a=$(parse "$(counts_json kp=1)"); [[ $(after_verdict $busy $a) == *"kp: proof secret survived"* ]]'
  check "AFTER a data row remains → not ok" 'a=$(parse "$(counts_json d_block=1)"); ! after_verdict $busy $a >/dev/null'

  # THE STATEMENT — one statement, every family delete once, never the auth user or the entitlement; the id the only splice.
  S=$(reset_sql $ID)
  occurrences() { local h=$1 n=$2; print -r -- $(( (${#h} - ${#${h//"$n"/}}) / ${#n} )) }   # <haystack> <needle>
  check "SQL the reset is ONE statement (no semicolon), a data-modifying CTE" '[[ $S != *";"* && $S == "with "* ]]'
  family=($DATA_TABLES $SERVER_TABLES)
  for t in $family; do
    check "SQL the reset deletes $t exactly once, by owner" \
      '[[ $(occurrences $S "delete from $t where owner_id = '"'"'$ID'"'"' returning 1)") == 1 ]]'
  done
  check "SQL the reset deletes the kp:<id> secret and the key_vault row, once each" \
    '[[ $(occurrences $S "delete from vault.secrets where name = '"'"'kp:$ID'"'"' returning 1)") == 1 && $(occurrences $S "delete from key_vault where user_id = '"'"'$ID'"'"' returning 1)") == 1 ]]'
  check "SQL the reset holds exactly ${#family}+2 deletes" '[[ $(occurrences $S "delete from ") == $(( ${#family} + 2 )) ]]'
  check "SQL the reset never names the auth user or the entitlement" '[[ $S != *auth.users* && $S != *entitlement* ]]'
  check "SQL the id is spliced exactly $(( ${#family} + 2 )) times, and no other quoted value" \
    '[[ $(occurrences $S "$ID") == $(( ${#family} + 2 )) && $(occurrences $S "'"'"'") == $(( 2 * (${#family} + 2) )) ]]'
  check "SQL a non-UUID id never builds a statement" '! reset_sql "x'"'"'; drop table key_vault" >/dev/null && ! counts_sql "$E" >/dev/null && ! reset_sql "${(U)ID}" >/dev/null'
  # The counts read passes Tools/prod-read.sh's OWN fence (its patterns read from the file — a drift there shows here).
  C=$(counts_sql $ID)
  rx=$(sed -n "s/.*grep -Eq '\\(.*\\)'.*/\\1/p" $PRODREAD | head -1)
  check "SQL the counts read is a bare SELECT that prod-read.sh's fence accepts (no ';', select first, no fenced word)" \
    '[[ -n $rx && $C != *";"* && $C == "select "* ]] && ! print -r -- ${(L)C} | grep -Eq "$rx"'

  # THE DRIFT PIN — the family IS account_purge()'s (the latest definition), minus entitlement and auth.users.
  purge_file=$(grep -l 'create or replace function account_purge()' $REPO/Server/supabase/[0-9]*.sql | sort | tail -1)
  purge=$(python3 -I - $purge_file "${DATA_TABLES[*]}" "${SERVER_TABLES[*]}" <<'PY'
import re, sys
text = open(sys.argv[1]).read()
start = text.rindex("create or replace function account_purge()")
body = text[start:text.index("$$;", text.index("as $$", start) + 5)]
data = re.findall(r"'([a-z_]+)'", re.search(r"data_tables constant text\[\] := array\[(.*?)\];", body, re.S).group(1))
owner = [t for t, c in re.findall(r"delete from ([a-z_.]+) where ([a-z_]+) = caller", body) if c == "owner_id"]
user = [t for t, c in re.findall(r"delete from ([a-z_.]+) where ([a-z_]+) = caller", body) if c == "user_id"]
ident = [t for t, c in re.findall(r"delete from ([a-z_.]+) where ([a-z_]+) = caller", body) if c == "id"]
secret = len(re.findall(r"delete from vault\.secrets where name = 'kp:' \|\| caller::text", body))
mine_data, mine_owner = sys.argv[2].split(), sys.argv[3].split()
print("data=" + ("same" if sorted(data) == sorted(mine_data) and len(data) == len(mine_data) == len(set(data))
                 else "DIFFERENT purge %s / reset %s" % (sorted(data), sorted(mine_data))))
print("owner=" + ("same" if sorted(owner) == sorted(mine_owner) else "DIFFERENT purge %s / reset %s" % (sorted(owner), sorted(mine_owner))))
print("user=" + ",".join(sorted(user)))
print("id=" + ",".join(sorted(ident)))
print("secret=%d" % secret)
PY
)
  check "DRIFT the latest account_purge() is found (${purge_file:t})" '[[ -n $purge_file && -n $purge ]]'
  check "DRIFT the 21 data tables are account_purge()'s data_tables, exactly" \
    '[[ ${${(f)purge}[1]} == "data=same" ]]'
  check "DRIFT the server tables are account_purge()'s owner deletes, exactly" '[[ ${${(f)purge}[2]} == "owner=same" ]]'
  check "DRIFT account_purge() deletes key_vault and entitlement by user_id — the reset keeps ONLY the entitlement" \
    '[[ ${${(f)purge}[3]} == "user=entitlement,key_vault" ]]'
  check "DRIFT account_purge() deletes auth.users by id — the reset keeps it" '[[ ${${(f)purge}[4]} == "id=auth.users" ]]'
  check "DRIFT account_purge() deletes the kp: secret — the reset does too (strictly)" '[[ ${${(f)purge}[5]} == "secret=1" ]]'
  check "DRIFT no maintenance file redefines account_purge()" \
    '! grep -l "create or replace function account_purge" $REPO/Server/supabase/maintenance/*.sql >/dev/null 2>&1'

  check "the network was never reached" 'true'   # (prodread/prodwrite are tripwires that exit 99)
  (( fails == 0 )) && { print "SELF-TEST: every guard fired as expected ($cases cases)"; exit 0 }
  print "SELF-TEST: $fails of $cases case(s) wrong"; exit 1
fi

# --- arguments ------------------------------------------------------------------------------------------------------
ACCOUNT= DRY= LOG=
while (( $# )); do
  case $1 in
    --dry-run) DRY=1 ;;
    --log) LOG=${2:?--log needs a file}; shift ;;
    -*) refuse "unknown option $1" ;;
    *) [[ -z $ACCOUNT ]] && ACCOUNT=$1 || refuse "one account only" ;;
  esac
  shift
done
[[ -n $ACCOUNT ]] || refuse "usage: prod-reset-test-account.sh <std|castle|del> [--dry-run] [--log <file>] | --self-test"
if [[ -z $LOG ]]; then mkdir -p $REPO/App/Variorum/DerivedData/prod-reset; LOG=$REPO/App/Variorum/DerivedData/prod-reset/$(date -u +%Y%m%dT%H%M%SZ)-$ACCOUNT.log; fi
say() { print -r -- "[$(date -u +%H:%M:%SZ)] prod-reset $ACCOUNT: $*" | tee -a $LOG }

# --- THE GUARDS (in order; each refusal exits 5 with nothing written) -----------------------------------------------
EMAIL=$(guard_allowlist $ALLOW $ACCOUNT) || refuse "R1 — $EMAIL"   # on accept: the CHECKED email — never a re-read of the file
[[ -x $PRODREAD && -f $REPO/.env.supabase.local ]] || refuse "R2 — Tools/prod-read.sh or .env.supabase.local is missing"
q=$(id_sql "$EMAIL") || { unset EMAIL; refuse "R3 — the '$ACCOUNT' email R1 checked failed the splice's plain-address re-check (a belt — R1 checks the same rule)" }
answer=$(prodread "$q") || { unset EMAIL; refuse "R3 — the account read failed (Tools/prod-read.sh)" }
UID_=$(py resolve "$answer" "$EMAIL"); rc=$?
unset EMAIL answer
(( rc == 0 )) || refuse "R3 — $UID_"
[[ $UID_ =~ $UUID_SHAPE ]] || refuse "R3 — the resolved id is not a UUID"
say "account id $UID_ (one auth user, its email the allowlist's entry)"
answer=$(prodread "$(counts_sql $UID_)") || refuse "R4 — the before-read failed (Tools/prod-read.sh)"
BEFORE=$(py counts "$answer" $COUNT_KEYS) || refuse "R4 — $BEFORE"
say "BEFORE: $(summary $BEFORE)"

if [[ -n $DRY ]]; then
  say "DRY RUN — every guard holds. The plan (nothing written): ONE statement deleting this account's ${#DATA_TABLES} data" \
    "tables, ${(j:, :)SERVER_TABLES}, its kp: proof secret and its key_vault row — never its auth user or entitlement" \
    "— then the after-read. $(at_rest $BEFORE && print -r -- 'It is ALREADY AT REST: a real run writes nothing.' || print -r -- "It holds $(family_total $BEFORE) family row(s): a real run resets them.")"
  exit 0
fi
if at_rest $BEFORE; then
  say "ALREADY AT REST — nothing written (log: $LOG)"
  exit 0
fi

# --- THE ONE WRITE, then the after-read (always) --------------------------------------------------------------------
say "RESET — one atomic statement over $(family_total $BEFORE) family row(s)"
answer=$(prodwrite "$(reset_sql $UID_)"); wrc=$?
took=$(py deleted "$answer"); drc=$?
unset answer
if (( wrc == 0 && drc == 0 )); then say "the statement took: $took"
else say "the statement did not land (${took:-the request failed}) — atomic: it wrote all or nothing; the after-read decides"; fi
answer=$(prodread "$(counts_sql $UID_)") || { say "the after-read failed — the account's state is UNKNOWN; read it with Tools/prod-read.sh"; exit 4 }
AFTER=$(py counts "$answer" $COUNT_KEYS) || { say "the after-read did not parse ($AFTER) — the state is UNKNOWN"; exit 4 }
say "AFTER: $(summary $AFTER)"
verdict=$(after_verdict $BEFORE $AFTER) || { say "NOT AT REST — $verdict"; exit 4 }
say "AT REST — the account exists, confirmed as it was, vaultless and rowless; its entitlement kept (log: $LOG)"
exit 0
