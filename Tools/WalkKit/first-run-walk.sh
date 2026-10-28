#!/bin/zsh
# Tools/WalkKit/first-run-walk.sh — VX-509's SCRIPTED FIRST-RUN WALK (VX-510 unit B1, D-B2; the run record
# notes/plans/fixes/vx-510-first-run-sync.md), SELF-RESETTING with BOTH ARMS since VX-623 (her standing ruling, 2026-10-27:
# "I want to give a standing ruling that the walk may reset its own allowlisted test accounts."; the run record
# notes/plans/fixes/vx-623-walk-self-reset.md, D-1…D-7). The DEV-store Debug build on the PROD TEST ROAD (her rulings
# R-510-1/-6 — `VARIORUM_PROD_TEST_ROAD=1` + the allowlist this script hands it), ONE named test account:
#   THE SET-UP ARM: launch → the road armed → the PRE-STEP (the account reset to its resting state if it is not at rest —
#     Tools/prod-reset-test-account.sh) → sign in → the twelve words' look (stashed, never read) → Settings ▸ Protection ▸
#     Turn on sync… → THE SHEET'S "Synced." (VX-507) → the row's "Synced ‹time›" with NO relaunch (VX-498) → the server
#     checks through Tools/prod-read.sh (the vault row · the `kp:` secret · a device cursor · data rows).
#   THE JOIN ARM (VX-537): the set-up instance quit by identity → the walk's OWN library set aside → a fresh launch, a
#     fresh library → signed in (still, or now) → Settings ▸ Protection ▸ "Sync this library…" → the account's passphrase
#     → "Synced. Your account's writing is in this library now." → the row "Synced" → the server: device cursors +1, the
#     vault's mode and revision unchanged (a same-posture join changes no account lock).
#   THE END, after the last arm's PASS (its evidence logged FIRST): sign out (the Debug app's resting posture) → quit by
#     identity, zero instances → THE CLEANUP LEG (the account back to its resting state: exists, confirmed, vaultless,
#     rowless). A STOP never resets: a stopped walk's production state is the diagnosis — the next run's pre-step heals it.
# The release checklist row (Tools/Release/release.sh's HANDOFF, step 0) names it beside the headless gate FirstRunDrillTests.
#
#   Tools/WalkKit/first-run-walk.sh <std|castle|del> [--arm setup|join|both] [--app <Debug Variorum.app>] [--dry-run]
#   Tools/WalkKit/first-run-walk.sh --self-test
#     --arm both (DEFAULT — her Q2): set-up → join → the end. setup: set-up → the end. join: the join arm alone → the end —
#     it needs the account's Standard vault (the set-up arm's; e.g. after a `both` run that stopped in the join arm).
#
# It REFUSES (exit 5 — nothing launched, nothing read from production, nothing typed) unless EVERY guard holds, in order:
#   G1  the account is one the allowlist names: std · castle · del
#   G2  the allowlist ~/.variorum/prod-test-accounts.env: a regular file (never a link), mode 600, every listed email
#       carrying 'vxtest', this account's email PLAIN (Tools/prod-confirm-test-user.sh's shape, matched against the whole
#       value — P3 splices it into a SELECT; the ladder's F-R1-5) and listed — the guard Tools/prod-confirm-test-user.sh and
#       the typing helper keep (values are read in a subshell and never printed)
#   G3  no walk project in this environment (VARIORUM_WALK_PROJECT_URL / VARIORUM_WALK_ANON_KEY): the two roads are
#       exclusive (the app refuses the road with a walk project too)
#   G4  the app is a DEBUG build — bundle io.lduarte.Variorum.debug, a …/Debug/Variorum.app path — and never under
#       /Applications (her real-store daily drive is never launched, quit or typed into)
#   G5  ZERO Variorum instances, by path (her /Applications app or any dev instance): the walk launches its own
#   G6  the stage is HELD (Tools/stage status) — every GUI act and the dev store are the stage's
#   G7  the dev slot is set aside (no variorum.sqlite in the Debug container's Variorum-dev): the DEV STORE'S files go aside
#       by `mv` BEFORE the walk (the run record's ENVIRONMENT TRAPS — the coordinator's form, a whole-folder rename) — never
#       this script's act. Between the arms the walk sets aside ONLY its OWN library, and only when it can prove it: the
#       slot folder was ABSENT at G7 (so this run made it) and its key file names the library this run's set-up enrolled
#       (the app log's `road: turnOnSync — library <id>`); it is renamed WHOLE, same volume, beside the slot. Anything
#       else STOPS, naming the move for the walker (then `--arm join`).
#   G8  the road's tools: Tools/prod-read.sh + .env.supabase.local (present, never read here) + the reset helper
#       Tools/prod-reset-test-account.sh; the typing and stashing helpers in ~/.variorum/bin (mode 700); cliclick
#   G9  this terminal's grants — Accessibility, Screen Recording, Automation for System Events — CHECKED, never prompted
#       (Tools/VisualWalk's vis-tcc; a consent dialog is the author's to answer)
#   --dry-run: the guards, then the plan; nothing launched, nothing read from production.
#   --self-test: every pure guard against temp FIXTURES (never her file, never production, never the GUI) — each refusal
#       shown firing; nothing else runs.
# Every launch (P1, J3) is preceded by the WINDOW-FRAME GUARD (VX-622, D-4): the main window's frame-autosave key deleted
# from the dev domain, and after the launch its bounds asserted on screen before any act. Every capture (D-5) shoots EVERY
# window of the pid, window-scoped, and is withheld while the words guard says the twelve words could be on screen.
# Exit: 0 the walk PASSED (or the dry run's guards held) · 4 STOPPED at a step (its capture and reason printed; the app is
# left running for the walker to look — quit it by identity; production left as it stands) · 5 refused (a guard; nothing
# launched).
#
# F-B1-1 (B), RULED (the run record): the sandboxed Debug app cannot read ~/.variorum, so THIS SCRIPT — outside the sandbox —
# reads the allowlist file (G2's checks: a regular file, mode 600, every entry 'vxtest') and HANDS its one key to the launch
# as `--env VARIORUM_PRODTEST_EMAILS=<the list>` beside the road's switch; the app reads only that value and keeps every guard
# of its own (exactly `1` asks, a walk project refuses, an empty list refuses, every entry marked, the admission per account
# at connect). The emails are no secret (they show in `ps eww`); the secrets beside them in the file are never handed.
#
# Written by implementer session B1 and dry-checked for its guards only — NEVER run against production by that session;
# its first live run was unit C's (LEG S's S4–S7). VX-623 unit 1 wrote the arms, the reset legs and D-4/D-5 under the same
# rule: self-tested over fixtures, never run live by their author — their first live run is VX-623 UNIT 2's, under a held
# stage, where the join arm's and the end's labels (read from the CURRENT code, file:line in the run record) meet the window.

emulate -L zsh
setopt pipe_fail

REPO=${0:A:h:h:h}
WK=$REPO/Tools/WalkKit
VW=$REPO/Tools/VisualWalk
ALLOW=$HOME/.variorum/prod-test-accounts.env
TYPE=$HOME/.variorum/bin/type-prod-test-secret
STASH=$HOME/.variorum/bin/stash-prod-test-words
RESET=$REPO/Tools/prod-reset-test-account.sh
DEBUG_ID=io.lduarte.Variorum.debug
SLOT="$HOME/Library/Containers/$DEBUG_ID/Data/Library/Application Support/Variorum-dev"
APP=$REPO/App/Variorum/DerivedData/vx510/Build/Products/Debug/Variorum.app
WORK=$REPO/App/Variorum/DerivedData/first-run-walk
BIN=$WORK/bin
GAP=2.6   # >= 2.5 s between guarded acts: a synthetic act resets HIDIdleTime (WalkKit's self-trip rule)

# The labels the arms meet, from the CURRENT code (the run record lists each with its file:line).
NOT_YET="Sync isn't on for this library yet"                     # SyncStatusViews.notOnYetLabel
SETUP_LANDED="Synced. Your library is on your account now."      # ProtectionWords.firstRoundSetUpLanded
JOIN_DOOR="Sync this library…"                                   # ProtectionWords.joinSyncDoor
JOIN_FIELD="Your account's passphrase"                           # ProtectionWords.joinPassphraseField
JOIN_BUTTON="Sync this library"                                  # ProtectionWords.joinSyncButton
JOIN_NOTICE="Your twelve words are"                              # ProtectionWords.joinWordsNotShown(_:)'s lead
JOIN_LANDED="Synced. Your account's writing is in this library now."   # ProtectionWords.firstRoundJoinLanded

refuse() { print -u2 "first-run-walk REFUSES: $*"; exit 5 }

# --- G1 + G2, pure over a file (the self-test feeds it fixtures) ----------------------------------------------------
# plain_address <address> → 0 for a PLAIN address: Tools/prod-confirm-test-user.sh's shape (lowercase letters, digits,
# . _ + - and one @, a dotted lowercase domain), matched against the WHOLE value with zsh's =~ — never a line-wise grep,
# which passes a value whose FIRST line is plain (the ladder's F-R1-5: P3 splices the address into its SELECT).
PLAIN_ADDRESS='^[a-z0-9._+-]+@[a-z0-9.-]+\.[a-z]+$'
plain_address() { [[ $1 =~ $PLAIN_ADDRESS ]] }
# guard_allowlist <file> <account> → prints the account's CHECKED email and returns 0 — the ONE value a caller may use
#   (P3 splices it; the file is never re-read: the VX-623 ladder's round-1 check-to-use seam) — or prints the refusal and
#   returns 1. Captured by `$(…)`, never printed to the terminal (an email is no secret — it rides `ps eww` — but stays quiet).
# allowlist_value <file> → the file's one key (the list the launch is handed), read in a subshell; the other keys never.
# (Tools/prod-reset-test-account.sh carries this function VERBATIM — its self-test pins the two byte-identical.)
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
allowlist_value() { (set -a; source $1 2>/dev/null; set +a; print -r -- "${VARIORUM_PRODTEST_EMAILS:-}") }

# --- D-4 (VX-622): the WINDOW-FRAME GUARD, pure parts (the self-test feeds them fixtures) ----------------------------
# The key, traced at VX-623 unit 1: SwiftUI autosaves the main WindowGroup's frame as "NSWindow Frame <id>-AppWindow-<n>"
# in the dev defaults domain; the group's id is "variorum-main" (EditorCommands.mainWindowGroupID, EditorCommands.swift:1191;
# the group at VariorumApp.swift:62, its .defaultSize 1240×840 at :94). The probe found exactly one such key,
# "NSWindow Frame variorum-main-AppWindow-1" = "60 144 1240 940 0 0 1728 1084". Pre-launch, ONLY those keys are deleted, so
# the window comes up at its default size; nothing is restored (the dev store's frame is walk state, not hers).
FRAME_KEY='NSWindow Frame variorum-main-AppWindow-[0-9]+'
frame_keys() {  # <a plist on stdin> → the main window's frame-autosave keys, one per line (whole-key matches only)
  python3 -I -c 'import plistlib, re, sys
d = plistlib.loads(sys.stdin.buffer.read())
[print(k) for k in sorted(d) if re.fullmatch(sys.argv[1], k)]' "$FRAME_KEY"
}
# rect_inside <x y w h> <displays> → 0 when the window lies inside ONE display's visible frame (2 pt of slack) and is at
# least 640×400 — room for the footer row, on screen; else prints why and returns 1. Points, Quartz global (top-left
# origin): the window from vis-win, each display's visible frame (menu bar and Dock excluded) one "x y w h" per line.
rect_inside() {
  local -a r d; local line
  r=(${=1})
  (( ${#r} == 4 )) || { print -r -- "no window frame to check ('$1')"; return 1 }
  (( r[3] >= 640 && r[4] >= 400 )) || { print -r -- "the main window is ${r[3]}×${r[4]} — too small to hold the footer row"; return 1 }
  for line in ${(f)2}; do
    d=(${=line}); (( ${#d} == 4 )) || continue
    (( r[1] >= d[1] - 2 && r[2] >= d[2] - 2 && r[1] + r[3] <= d[1] + d[3] + 2 && r[2] + r[4] <= d[2] + d[4] + 2 )) && return 0
  done
  print -r -- "the main window (${r[*]}) lies outside every display's visible frame (${(j: · :)${(f)2}}) — its footer row may be off-screen"
  return 1
}

# --- D-2 / D-3 (VX-622, VX-537): the arms and the slot dance, pure parts (the self-test feeds them fixtures) ---------
arm_valid() { [[ $1 == (setup|join|both) ]] }
# turnon_library <app log> → the library the LAST "road: turnOnSync — library <id8> now names account …" line names
# (ProtectionAccountActs.swift:387-390), lowercased; nothing when there is none.
turnon_library() {
  [[ -f $1 ]] || return 1
  grep -o 'road: turnOnSync — library [0-9A-Fa-f]\{8\} now names account' "$1" | tail -1 | awk '{print tolower($5)}'
}
# keyfile_library <key file> → the first 8 characters of its libraryID (KeyFile.libraryID — KeyFile.swift:130; the file
# Names.keyFilename, Names.swift:114) — ONLY that field is read, never a wrap; nothing for a link or an unreadable file.
keyfile_library() {
  [[ -f $1 && ! -L $1 ]] || return 1
  python3 -I -c 'import json, sys
k = json.load(open(sys.argv[1]))
v = k.get("libraryID") if isinstance(k, dict) else None
print(v[:8].lower() if isinstance(v, str) else "")' "$1" 2>/dev/null
}
# aside_verdict <slot> <the slot at G7: absent|present> <the set-up's library from its log> <aside> → 0 when the slot is
# PROVABLY the walk's own (absent at G7 — so this run made it — and its key file names the library this run's set-up
# enrolled) and the aside name is free; else prints why and returns 1 (the walk then STOPS, naming the move).
aside_verdict() {
  local slot=$1 at_g7=$2 lib=$3 aside=$4 kf
  [[ $at_g7 == absent ]] || { print -r -- "the slot folder was there before this run (G7 found no library in it, but files this walk cannot prove its own)"; return 1 }
  [[ -d $slot && ! -L $slot ]] || { print -r -- "there is no slot folder to set aside"; return 1 }
  [[ $lib =~ '^[0-9a-f]{8}$' ]] || { print -r -- "the set-up arm's app log names no library (no 'road: turnOnSync — library …' line)"; return 1 }
  kf=$(keyfile_library "$slot/variorum-library-keys.json")
  [[ $kf == $lib ]] || { print -r -- "the slot's key file names library '${kf:-none}', not the set-up arm's $lib"; return 1 }
  [[ ! -e $aside && ! -L $aside ]] || { print -r -- "${aside:t} already exists — a walk never merges into a folder"; return 1 }
  return 0
}
# aside_own_slot <slot> <aside> → ONE same-volume rename of the WHOLE folder (its siblings' parent), proven a rename — the
# folder's inode unchanged, the slot gone — never a copy, never a merge.
aside_own_slot() {
  local ino
  ino=$(stat -f %i "$1" 2>/dev/null) || return 1
  [[ ${2:h} == ${1:h} ]] || return 1
  mv -n "$1" "$2" || return 1
  [[ ! -e $1 && -d $2 && $(stat -f %i "$2") == $ino ]]
}
# json_field <one-row JSON answer> <key> → the value, or nothing (an error answer, no row, two rows, not JSON)
json_field() {
  python3 -I -c 'import json, sys
try:
    r = json.loads(sys.argv[1])
    v = r[0].get(sys.argv[2]) if isinstance(r, list) and len(r) == 1 and isinstance(r[0], dict) else None
except Exception:
    v = None
print("" if v is None or isinstance(v, bool) else v)' "$1" "$2"
}
# join_ready <vault answer> → 0 when the account holds a STANDARD vault (the join arm walks the same-posture join; a Castle
# account's join would enter Castle and ask for a gate — never walked here); else why, 1.
join_ready() {
  local m; m=$(json_field "$1" mode)
  [[ -n $m ]] || { print -r -- "the account holds no vault — the set-up arm makes it (run --arm both)"; return 1 }
  [[ $m == standard ]] || { print -r -- "the account's vault is in '$m' — the join arm walks the same-posture Standard join only"; return 1 }
  return 0
}
# join_verdict <vault before> <cursors before> <vault after> <cursors after> → 0 when the join added exactly ONE device
# cursor (the fresh library's device) and left the vault's mode and revision where they were; else why, 1.
join_verdict() {
  local m0 r0 n0 m1 r1 n1
  m0=$(json_field "$1" mode) r0=$(json_field "$1" revision) n0=$(json_field "$2" n)
  m1=$(json_field "$3" mode) r1=$(json_field "$3" revision) n1=$(json_field "$4" n)
  [[ -n $m0 && $r0 == <-> && $n0 == <-> && -n $m1 && $r1 == <-> && $n1 == <-> ]] \
    || { print -r -- "a server read did not answer whole (the vault and the cursors, before and after)"; return 1 }
  [[ $m1 == $m0 ]] || { print -r -- "the account's mode moved ($m0 → $m1) — a same-posture join changes no account lock"; return 1 }
  (( r1 == r0 )) || { print -r -- "the vault revision moved ($r0 → $r1) — a same-posture join changes no account lock"; return 1 }
  (( n1 == n0 + 1 )) || { print -r -- "device cursors $n0 → $n1, not +1 (the fresh library's one device)"; return 1 }
  return 0
}
# helper_id <the reset helper's output> → the account id it resolved (its "account id <uuid>" line), or nothing
helper_id() { print -r -- "$1" | grep -o 'account id [0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}' | head -1 | cut -d' ' -f3 }

# --- --self-test: the guards' teeth, over fixtures only ---------------------------------------------------------------
if [[ ${1:-} == --self-test ]]; then
  T=$(mktemp -d)
  trap 'rm -rf $T' EXIT
  ok='VARIORUM_PRODTEST_EMAILS="a+vxtest-std@x.test b+vxtest-castle@x.test"
VARIORUM_PRODTEST_STD_EMAIL="a+vxtest-std@x.test"
VARIORUM_PRODTEST_CASTLE_EMAIL="b+vxtest-castle@x.test"
VARIORUM_PRODTEST_STD_PASSWORD="notasecret-vxtest0"'
  fixture() { print -r -- "$2" > $T/$1; chmod ${3:-600} $T/$1 }
  fixture good "$ok"
  fixture open "$ok" 644
  fixture unmarked 'VARIORUM_PRODTEST_EMAILS="a+vxtest-std@x.test her@x.test"
VARIORUM_PRODTEST_STD_EMAIL="a+vxtest-std@x.test"'
  fixture empty 'VARIORUM_PRODTEST_EMAILS=""
VARIORUM_PRODTEST_STD_EMAIL="a+vxtest-std@x.test"'
  fixture unlisted 'VARIORUM_PRODTEST_EMAILS="b+vxtest-castle@x.test"
VARIORUM_PRODTEST_STD_EMAIL="a+vxtest-std@x.test"'
  # The ladder's F-R1-5: addresses that are listed and marked but not PLAIN (P3 splices the address into its SELECT).
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
  fails=0
  SELF=${0:A}   # (read at the top level — inside a function $0 is the function's name)
  sure() {  # <label> <zsh condition>
    if eval "$2"; then print -r -- "SELF-TEST $1  ok"; else print -r -- "SELF-TEST $1  FAIL"; fails=$((fails + 1)); fi
  }
  expect() {  # <label> <file> <account> <accept|refuse>
    local why rc got
    why=$(guard_allowlist $T/$2 $3); rc=$?   # (the status read at once — never after another assignment)
    got=accept; (( rc )) && got=refuse
    [[ $got == refuse ]] || why=
    if [[ $got == $4 ]]; then print -r -- "SELF-TEST $1: $got${why:+ ($why)}  ok"
    else print -r -- "SELF-TEST $1: $got — expected $4  FAIL"; fails=$((fails + 1)); fi
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
  handed=$(allowlist_value $T/good)   # the value the launch is handed (fixture emails — fake, printable)
  if [[ $handed == "a+vxtest-std@x.test b+vxtest-castle@x.test" ]]; then print -r -- "SELF-TEST the handed value: the list key alone  ok"
  else print -r -- "SELF-TEST the handed value: '$handed'  FAIL"; fails=$((fails + 1)); fi
  [[ $handed != *notasecret* ]] || { print -r -- "SELF-TEST the handed value carries another key  FAIL"; fails=$((fails + 1)) }
  # The ladder's round-1 finding 2 (the check-to-use seam): the email P3 splices is the one G2 CHECKED — guard_allowlist
  # hands it back on accept, and the main path never re-reads the file (allowlist_value's launch list is the one other
  # read: never spliced, re-guarded by the app at connect — F-B1-1).
  outside_reads() {  # <file> → how many lines source the allowlist outside guard_allowlist's body and allowlist_value
    awk '$0 == "guard_allowlist() {" { f = 1; next } f && $0 == "}" { f = 0; next } f { next } /^allowlist_value\(\) \{/ { next } { print }' $1 \
      | grep -c 'sour''ce \$'
  }
  sure "G1/G2 on accept prints exactly the CHECKED email (the one value P3 splices)" \
    '[[ $(guard_allowlist $T/good std) == "a+vxtest-std@x.test" && $(guard_allowlist $T/good castle) == "b+vxtest-castle@x.test" ]]'
  sure "G1/G2 on a refusal prints the reason, never an address" \
    '[[ $(guard_allowlist $T/unmarked std) == "an allowlist entry is not a plainly-test address" ]]'
  sure "the allowlist is sourced only inside guard_allowlist and allowlist_value — the main path never re-reads it" \
    '[[ $(outside_reads $SELF) == 0 ]]'
  # D-5 (VX-623): every capture is withheld while the twelve words could be on screen — the words guard's teeth, over
  # strings (its --classify mode; the AX walk itself needs a live pid). Compiled into the temp folder, never the repo.
  if swiftc -O -o $T/words-guard $WK/words-guard.swift 2>/dev/null; then
    wg() { $T/words-guard --classify "$1" >/dev/null }
    sure "D-5 the words guard withholds twelve lowercase words" '! wg "alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo lima"'
    sure "D-5 … spaced and padded the same" '! wg "  alpha  bravo charlie delta echo foxtrot golf hotel india juliet kilo lima "'
    sure "D-5 … the look's button (I've written them down)" '! wg "I'\''ve written them down"'
    sure "D-5 … the look's warning (These words won't be shown again.)" '! wg "These words won'\''t be shown again."'
    sure "D-5 … the look's reveal door (Show my twelve words)" '! wg "Show my twelve words"'
    sure "D-5 lets eleven words through" 'wg "alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo"'
    sure "D-5 lets thirteen words through" 'wg "alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo lima mike"'
    sure "D-5 lets the join's landed line through" 'wg "$JOIN_LANDED"'
    sure "D-5 lets the join's words notice through (it names no words)" \
      'wg "Your twelve words are a+vxtest-std@x.test'\''s twelve words. Your previous twelve words still open backups made with them. If you don'\''t have your account'\''s words written down, you can make new ones at any time."'
    sure "D-5 a non-numeric argument → usage, withheld (exit 2)" '$T/words-guard notapid >/dev/null; (( $? == 2 ))'
    # The ladder's round-1 MAJOR: a pid whose AX tree cannot be read is WITHHELD (exit 1), never "ok" — a live non-GUI pid
    # (AXError -25204 at once, the hung app's code) and a reaped one; and the scan's own cap / cycle / mid-scan checks.
    sleep 60 & sleeper=$!
    sure "D-5 a live pid whose AX tree cannot be read (a backgrounded sleep) → withheld (exit 1)" \
      'wgout=$($T/words-guard $sleeper); wgrc=$?; (( wgrc == 1 )) && [[ $wgout == "withheld ("* ]]'
    kill $sleeper 2>/dev/null; wait $sleeper 2>/dev/null
    true & gone=$!; wait $gone 2>/dev/null
    sure "D-5 a reaped pid → withheld (exit 1)" 'wgout=$($T/words-guard $gone); wgrc=$?; (( wgrc == 1 )) && [[ $wgout == "withheld ("* ]]'
    sure "D-5 the guard's own --self-check (the scan over synthetic trees: cap · cycle · unreadable · deep words · clean)" \
      '$T/words-guard --self-check >/dev/null'
  else
    print -r -- "SELF-TEST D-5 the words guard compiles from Tools/WalkKit/words-guard.swift  FAIL"; fails=$((fails + 1))
  fi
  # D-4 (VX-622): only the main window's frame-autosave keys go; the bounds check holds the footer row on screen.
  python3 -I -c 'import plistlib, sys
keys = ["NSWindow Frame variorum-main-AppWindow-1", "NSWindow Frame variorum-main-AppWindow-2",
        "NSWindow Frame variorum-note-AppWindow-1", "NSSplitView Subview Frames variorum-main-AppWindow-1, SidebarNavigationSplitView",
        "NSWindow Frame com_apple_SwiftUI_Settings_window", "NSWindow Frame variorum-main-AppWindow-1x",
        "xNSWindow Frame variorum-main-AppWindow-1", "NSWindow Frame variorum-main", "appearanceChoice"]
sys.stdout.buffer.write(plistlib.dumps({k: "60 144 1240 940 0 0 1728 1084" for k in keys}))' > $T/prefs.plist
  got=$(frame_keys < $T/prefs.plist)
  sure "D-4 the frame guard picks exactly the main window's autosave keys" \
    '[[ $got == "NSWindow Frame variorum-main-AppWindow-1"$'\''\n'\''"NSWindow Frame variorum-main-AppWindow-2" ]]'
  sure "D-4 an empty domain yields no key" '[[ -z $(python3 -I -c "import plistlib,sys; sys.stdout.buffer.write(plistlib.dumps({}))" | frame_keys) ]]'
  one='0 33 1728 1084'; two='0 33 1728 1084'$'\n''1728 0 1920 1055'
  sure "D-4 the default window, centred on the Pro's display → holds the footer row" 'rect_inside "244 155 1240 840" $one >/dev/null'
  sure "D-4 the probe's autosaved frame (1240×940 high on the screen) → holds" 'rect_inside "60 33 1240 940" $one >/dev/null'
  sure "D-4 a window whose bottom runs past the visible frame → refused" '! rect_inside "60 300 1240 940" $one >/dev/null'
  sure "D-4 a window hanging off the left edge → refused" '! rect_inside "-400 100 1240 840" $one >/dev/null'
  sure "D-4 a window taller than the display → refused" '! rect_inside "0 33 1728 1200" $one >/dev/null'
  sure "D-4 a sliver of a window (600×300) → refused" '! rect_inside "100 100 600 300" $one >/dev/null'
  sure "D-4 a window wholly on a second display → holds" 'rect_inside "1900 100 1240 840" $two >/dev/null'
  sure "D-4 a window straddling two displays → refused" '! rect_inside "1200 100 1240 840" $two >/dev/null'
  sure "D-4 no display geometry → refused (fail-closed)" '! rect_inside "244 155 1240 840" "" >/dev/null'
  sure "D-4 no window frame → refused" '! rect_inside "" $one >/dev/null'
  # D-2 / D-3 (VX-622, VX-537): the arms, the provenance of the walk's own library, the join's evidence.
  sure "D-3 --arm takes setup, join, both" 'arm_valid setup && arm_valid join && arm_valid both'
  sure "D-3 --arm refuses anything else" '! arm_valid Both && ! arm_valid all && ! arm_valid "" && ! arm_valid "both "'
  *[removed for publication]*
*[removed for publication]*
[x] road: stopSyncingHere — library 22222222 now names no account" > $T/app.log
  print -r -- "[x] road: deleteAccountHere — library 2aa0214f now names no account" > $T/none.log
  sure "D-3 the set-up's library is the app log's LAST turnOnSync line, lowercased" '[[ $(turnon_library $T/app.log) == 6c51f3d0 ]]'
  sure "D-3 a log with no turnOnSync line names no library" '[[ -z $(turnon_library $T/none.log) ]]'
  mkslot() {  # <dir> <libraryID> — a fixture slot folder: a key file, a store stand-in, a Backups folder
    mkdir -p $1/Backups/x; print -r -- "{\"formatVersion\":3,\"libraryID\":\"$2\",\"fingerprint\":\"ab\"}" > $1/variorum-library-keys.json
    print -r -- store > $1/variorum.sqlite; print -r -- b > $1/Backups/x/b
  }
  mkslot $T/sup/Variorum-dev 6c51f3d0-1111-4222-8333-444455556666
  sure "D-3 the key file's libraryID is read (its first 8)" '[[ $(keyfile_library $T/sup/Variorum-dev/variorum-library-keys.json) == 6c51f3d0 ]]'
  print -r -- '{"libraryID": 7}' > $T/odd.json; print -r -- 'not json' > $T/bad.json; ln -s $T/sup/Variorum-dev/variorum-library-keys.json $T/kf-link
  sure "D-3 a key file with no string libraryID, an unreadable one, or a link → nothing" \
    '[[ -z $(keyfile_library $T/odd.json) && -z $(keyfile_library $T/bad.json) && -z $(keyfile_library $T/kf-link) ]]'
  A=$T/sup/Variorum-dev-walk-STAMP-setup
  sure "D-3 the walk's OWN library (absent at G7, its key file the set-up's) → set aside" 'aside_verdict $T/sup/Variorum-dev absent 6c51f3d0 $A >/dev/null'
  sure "D-3 a slot folder present at G7 → STOP (the walker's to move)" '! aside_verdict $T/sup/Variorum-dev present 6c51f3d0 $A >/dev/null'
  sure "D-3 the set-up's log names no library → STOP" '! aside_verdict $T/sup/Variorum-dev absent "" $A >/dev/null'
  sure "D-3 the key file names another library → STOP" '! aside_verdict $T/sup/Variorum-dev absent 11111111 $A >/dev/null'
  mkdir -p $T/sup/taken
  sure "D-3 the aside name already exists → STOP (never a merge)" '! aside_verdict $T/sup/Variorum-dev absent 6c51f3d0 $T/sup/taken >/dev/null'
  sure "D-3 no slot folder → STOP" '! aside_verdict $T/sup/nothing absent 6c51f3d0 $A >/dev/null'
  ln -s $T/sup/Variorum-dev $T/sup/slot-link
  sure "D-3 a slot that is a link → STOP" '! aside_verdict $T/sup/slot-link absent 6c51f3d0 $A >/dev/null'
  ino=$(stat -f %i $T/sup/Variorum-dev)
  sure "D-3 the aside is ONE whole-folder rename: the slot gone, the folder's inode and contents beside it" \
    'aside_own_slot $T/sup/Variorum-dev $A && [[ ! -e $T/sup/Variorum-dev && $(stat -f %i $A) == $ino && -f $A/variorum.sqlite && -f $A/Backups/x/b ]]'
  mkslot $T/sup/Variorum-dev 6c51f3d0-1111-4222-8333-444455556666
  sure "D-3 the rename refuses an aside on another folder (never leaves the slot's parent)" '! aside_own_slot $T/sup/Variorum-dev $T/elsewhere-setup && [[ -d $T/sup/Variorum-dev ]]'
  sure "D-3 the join needs a Standard vault: standard → ready" 'join_ready "[{\"mode\":\"standard\",\"revision\":1}]" >/dev/null'
  sure "D-3 … a Castle vault → STOP (never the Castle join's gate)" '! join_ready "[{\"mode\":\"castle\",\"revision\":16}]" >/dev/null'
  sure "D-3 … no vault (a reset account) → STOP" '! join_ready "[]" >/dev/null'
  sure "D-3 … an error answer → STOP" '! join_ready "{\"message\":\"x\"}" >/dev/null'
  V='[{"mode":"standard","revision":3}]'
  sure "D-3 the join's evidence: cursors +1, mode and revision unchanged → PASS" 'join_verdict $V "[{\"n\":3}]" $V "[{\"n\":4}]" >/dev/null'
  sure "D-3 … cursors unchanged → STOP" '! join_verdict $V "[{\"n\":3}]" $V "[{\"n\":3}]" >/dev/null'
  sure "D-3 … cursors +2 → STOP" '! join_verdict $V "[{\"n\":3}]" $V "[{\"n\":5}]" >/dev/null'
  sure "D-3 … the vault revision moved → STOP" '! join_verdict $V "[{\"n\":3}]" "[{\"mode\":\"standard\",\"revision\":4}]" "[{\"n\":4}]" >/dev/null'
  sure "D-3 … the mode moved → STOP" '! join_verdict $V "[{\"n\":3}]" "[{\"mode\":\"castle\",\"revision\":3}]" "[{\"n\":4}]" >/dev/null'
  sure "D-3 … a read that did not answer → STOP" '! join_verdict $V "[{\"n\":3}]" "[]" "[{\"n\":4}]" >/dev/null'
  sure "D-3 … a boolean where a number goes → STOP" '! join_verdict $V "[{\"n\":true}]" $V "[{\"n\":4}]" >/dev/null'
  sure "D-2 the reset helper's resolved id is read from its log line" \
    '[[ $(helper_id "[x] prod-reset std: account id 0f3c2b1a-9d8e-4f7a-8b6c-5d4e3f2a1b0c (one auth user)") == 0f3c2b1a-9d8e-4f7a-8b6c-5d4e3f2a1b0c ]]'
  sure "D-2 … and nothing when the helper refused before resolving" '[[ -z $(helper_id "prod-reset-test-account REFUSES: R1 — the allowlist must be mode 600") ]]'
  # The ladder's round-1 NIT 4: a missing option value refuses in the documented exit grammar (5, named) — never zsh's
  # own exit 1. The script runs as a FENCED subprocess: HOME at an empty temp dir (no allowlist can exist there, so even a
  # regressed parse refuses at G1/G2 before anything runs), `zsh -f` (no startup files), and curl · open · osascript ·
  # cliclick on PATH as shims that exit 99 (no network, no launch, no event).
  mkdir -p $T/nohome $T/shim
  for c in curl open osascript cliclick; do print -r -- '#!/bin/sh
exit 99' > $T/shim/$c; chmod +x $T/shim/$c; done
  sure "ARGS the fence holds: every shim shadows the real tool, and no allowlist exists under the fenced HOME" \
    '[[ $(PATH=$T/shim:$PATH whence -p curl) == $T/shim/curl && $(PATH=$T/shim:$PATH whence -p open) == $T/shim/open && $(PATH=$T/shim:$PATH whence -p osascript) == $T/shim/osascript && $(PATH=$T/shim:$PATH whence -p cliclick) == $T/shim/cliclick && ! -e $T/nohome/.variorum/prod-test-accounts.env ]]'
  argout=$(HOME=$T/nohome PATH=$T/shim:$PATH zsh -f $SELF std --app 2>&1); argrc=$?
  sure "ARGS a missing --app value → refused in the grammar (exit 5, named) — fenced" \
    '(( argrc == 5 )) && [[ $argout == *"REFUSES: --app needs a path"* ]]'
  (( fails == 0 )) && { print "SELF-TEST: every guard fired as expected"; exit 0 }
  print "SELF-TEST: $fails case(s) wrong"; exit 1
fi

# --- arguments --------------------------------------------------------------------------------------------------------
ACCOUNT= DRY= ARM=both
while (( $# )); do
  case $1 in
    --app) [[ -n ${2:-} ]] || refuse "--app needs a path"; APP=$2; shift ;;
    --arm) ARM=${2:-}; shift; arm_valid "$ARM" || refuse "--arm takes setup, join or both (got '$ARM')" ;;
    --dry-run) DRY=1 ;;
    -*) refuse "unknown option $1" ;;
    *) [[ -z $ACCOUNT ]] && ACCOUNT=$1 || refuse "one account only" ;;
  esac
  shift
done
[[ -n $ACCOUNT ]] || refuse "usage: first-run-walk.sh <std|castle|del> [--arm setup|join|both] [--app <Debug Variorum.app>] [--dry-run] | --self-test"

# --- THE GUARDS (in order; each refusal exits 5 with nothing launched) ------------------------------------------------
EMAIL=$(guard_allowlist $ALLOW $ACCOUNT) || refuse "G1/G2 — $EMAIL"   # on accept: the CHECKED email P3 splices
[[ -z ${VARIORUM_WALK_PROJECT_URL:-}${VARIORUM_WALK_ANON_KEY:-} ]] \
  || refuse "G3 — a walk project is set in this environment; the walk project and the prod test road are exclusive"
APP=${APP:A}
[[ $APP != /Applications/* ]] || refuse "G4 — $APP is under /Applications: her app is never launched by a walk"
[[ $APP == */Debug/Variorum.app && -d $APP ]] || refuse "G4 — no Debug build at $APP (build the walk's Debug app first)"
bundle=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' $APP/Contents/Info.plist 2>/dev/null)
[[ $bundle == $DEBUG_ID ]] || refuse "G4 — $APP is '$bundle', not the Debug build ($DEBUG_ID)"
running=$(pgrep -fl 'Variorum.app/Contents/MacOS')
[[ -z $running ]] || refuse "G5 — a Variorum instance is running (never quit hers; quit yours by identity first): ${running//$'\n'/ · }"
stage=$($REPO/Tools/stage status 2>/dev/null)
[[ $stage == "STAGE HELD by "* ]] || refuse "G6 — the stage is not held (${stage:-no answer}); claim it first: Tools/stage claim --who <you> --reason <why>"
[[ ! -e $SLOT/variorum.sqlite ]] || refuse "G7 — the dev slot holds a library; set it aside by mv first (the run record's ENVIRONMENT TRAPS)"
# The slot folder's state at G7 — the provenance the between-arms aside rests on (absent: whatever is in it later, this run made).
[[ -e $SLOT || -L $SLOT ]] && SLOT_AT_G7=present || SLOT_AT_G7=absent
[[ -x $REPO/Tools/prod-read.sh && -f $REPO/.env.supabase.local ]] || refuse "G8 — Tools/prod-read.sh or .env.supabase.local is missing"
[[ -x $RESET ]] || refuse "G8 — the reset helper Tools/prod-reset-test-account.sh is missing or not executable"
for helper in $TYPE $STASH; do
  [[ -x $helper && $(stat -f %Lp $helper) == 700 ]] || refuse "G8 — $helper is missing or not mode 700"
done
command -v cliclick >/dev/null || refuse "G8 — cliclick is not installed"
mkdir -p $BIN
for h in vis-ax vis-tcc vis-win; do
  [[ $BIN/$h -nt $VW/helpers/$h.swift ]] || swiftc -O -o $BIN/$h $VW/helpers/$h.swift 2>/dev/null \
    || refuse "G9 — cannot compile Tools/VisualWalk/helpers/$h.swift"
done
# D-5 (VX-623): the every-window capture (capture-windows.swift's listing road) and the words guard before it.
[[ $BIN/walk-cap -nt $WK/capture-windows.swift ]] || swiftc -O -o $BIN/walk-cap $WK/capture-windows.swift 2>/dev/null \
  || refuse "G9 — cannot compile Tools/WalkKit/capture-windows.swift"
[[ $BIN/words-guard -nt $WK/words-guard.swift ]] || swiftc -O -o $BIN/words-guard $WK/words-guard.swift 2>/dev/null \
  || refuse "G9 — cannot compile Tools/WalkKit/words-guard.swift"
open -g -b com.apple.systemevents; sleep 1
grants=$(perl -e 'alarm shift; exec @ARGV' 15 $BIN/vis-tcc com.apple.systemevents); rc=$?
(( rc == 142 )) && refuse "G9 — the grants check timed out (a consent prompt may be on screen — the author's to answer)"
[[ ${grants%%$'\n'*} == "AX 1 SCREEN 1" && $grants == *"AE:com.apple.systemevents granted"* ]] \
  || refuse "G9 — this terminal lacks a grant (${grants//$'\n'/ · }); granting is the author's"

STAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN=$WORK/run-$STAMP-$ACCOUNT
ASIDE="${SLOT}-walk-$STAMP-setup"
if [[ -n $DRY ]]; then
  print "first-run-walk DRY RUN — every guard holds for '$ACCOUNT', arm '$ARM' (the slot folder $SLOT_AT_G7 at G7). The plan (nothing launched):"
  print "  P1 the window-frame guard (the dev domain's 'NSWindow Frame variorum-main-AppWindow-<n>' deleted), then launch $APP with"
  print "     VARIORUM_PROD_TEST_ROAD=1 + the handed VARIORUM_PRODTEST_EMAILS (open -n --env; stderr → $RUN/app.log)"
  print "  P2 ps eww: the road's switch and the handed list present, no walk project · the log: 'PROD TEST ROAD (VX-510): ARMED'"
  print "     · the main window's bounds inside a display's visible frame (the footer row on screen)"
  print "  P3 prod read: the account exists and is confirmed (auth.users by email → its id)"
  if [[ $ARM != join ]]; then
    print "  P3r THE PRE-STEP: Tools/prod-reset-test-account.sh $ACCOUNT — resets the account to its resting state if it is not at rest"
    print "  P4 sign in (the row's Sign in… → Email/Password typed by type-prod-test-secret)"
    print "  P5 the row: '$NOT_YET' · Settings ▸ Protection ▸ Record your twelve words… → Copy → stash"
    print "  P6 Turn on sync… → the new passphrase twice + the words (typed by the helper) → Turn on sync"
    print "  P7 THE SHEET: '$SETUP_LANDED' (≤ 180 s) → Done · the row 'Synced ‹time›'"
    print "  P8 prod reads by the account's id: key_vault (mode, revision, proof) · vault.secrets kp:<id> · device_cursor · data rows"
  fi
  if [[ $ARM == both ]]; then
    print "  J1 quit the set-up instance by identity (Settings closed first) — zero instances, its own step"
    print "  J2 the walk's OWN library aside: $SLOT → ${ASIDE:t} (one whole-folder rename) — only if absent at G7"
    print "     and its key file names the set-up's library; else STOP naming the move (then --arm join)"
    print "  J3 the window-frame guard, then a fresh launch on the road (stderr → $RUN/app-join.log) → a fresh library"
    print "  J3b the road: the process's environment and the app's ARMED line · the main window's bounds (P2's checks)"
  fi
  if [[ $ARM != setup ]]; then
    print "  J4 the fresh library's row: '$NOT_YET' (signed in still, or signed in now)"
    print "  J5 prod reads: the account's vault (Standard) and its device cursors — the join's before"
    print "  J6 Settings ▸ Protection ▸ '$JOIN_DOOR' → '$JOIN_FIELD' (typed by the helper) → '$JOIN_BUTTON'"
    print "  J7 THE SHEET: the words notice's OK if shown → '$JOIN_LANDED' (≤ 180 s) → Done · the row 'Synced ‹time›'"
    print "  J8 prod reads: device cursors +1, the vault's mode and revision unchanged"
  fi
  print "  E1 sign out (Settings ▸ Protection ▸ Sign out… → Sign Out) · E2 quit by identity, zero instances"
  print "  E3 THE CLEANUP LEG: Tools/prod-reset-test-account.sh $ACCOUNT — the account back to its resting state"
  exit 0
fi

# --- THE WALK (live — the stage held, the slot aside) -------------------------------------------------------------------
mkdir -p $RUN
STEP=start PID= WID= APPLOG=
log() { print -r -- "[$(date +%H:%M:%S)] $STEP: $*" | tee -a $RUN/walk.log }
window() { local w; w=($($BIN/vis-win $PID 2>/dev/null)); [[ ${w[1]:-none} != none ]] && WID=$w[1] }
capture() {  # <label> — D-5 (VX-537): EVERY on-screen window of the pid, each window-scoped (never the full screen), named
  # <time>-<step>-<label>-w<n>.png, the listing appended to captures.txt — and NOTHING while the words guard says the
  # twelve words could be on screen, or that it could not read the pid's tree whole (any non-zero exit withholds:
  # fail-closed). Its "ok (<n> elements read)" rides the captured line, so every capture shows the guard read a real tree.
  local g pre
  [[ -n $PID ]] || return 0
  g=$($BIN/words-guard $PID 2>/dev/null) || { log "capture '$1' WITHHELD — ${g:-the words guard did not answer}"; return 0 }
  pre="$(date +%H%M%S)-$STEP-$1-"
  $BIN/walk-cap $PID $RUN $pre --every-layer >> $RUN/captures.txt 2>&1
  log "captured '$1' → ${pre}w*.png ($(tail -1 $RUN/captures.txt); the words guard: $g)"
}
stop() {  # never a reset after a STOP (the premise's fence 1): production is the diagnosis; the next run's pre-step heals it
  log "STOPPED — $*"; capture stopped
  print -u2 "first-run-walk STOPPED at $STEP: $* (${PID:+the app is left running — pid $PID; }production left as it stands — the next run's pre-step resets it; captures in $RUN)"
  exit 4
}
step() { STEP=$1; log "— $2" }
author() { $WK/guard.sh --author >/dev/null || stop "the author check failed (her app is running, or someone is at the machine) — never retried" }
activate() { osascript -e "tell application \"System Events\" to set frontmost of (first application process whose unix id is $PID) to true" >/dev/null; sleep 0.4 }
press() {  # <label> [role] — an accessibility press addressed to OUR pid, after the author check
  author; activate; sleep $GAP
  $BIN/vis-ax $PID "$1" ${2:--} press >/dev/null || stop "no control labelled '$1' on screen"
  log "pressed '$1'"
}
focus() {  # <label> [role] — click the field labelled <label> (its centre), so the helper types into it.
  # The role defaults to AXTextField (the first live run: a bare label match found a HEADING whose text equals the
  # words field's placeholder, the click landed on prose, and the words went into the still-focused Again field —
  # the confirm's button then sat disabled and AXPress on it "succeeded" as a no-op).
  author; activate
  local f; f=($($BIN/vis-ax $PID "$1" ${2:-AXTextField} 2>/dev/null)) || stop "no field labelled '$1' on screen"
  cliclick c:$(( ${f[1]%.*} + ${f[3]%.*} / 2 )),$(( ${f[2]%.*} + ${f[4]%.*} / 2 )); sleep $GAP
}
secret() {  # <field> — the helper types it (it re-checks the road, the frontmost build and the allowlist itself)
  author; activate
  $TYPE $ACCOUNT $1 >/dev/null || stop "the typing helper refused the '$1' field"
  log "typed the $1 (never printed)"; sleep $GAP
}
waitfor() {  # <label> <seconds> — until a control or text with that label is on screen
  local i
  for i in $(seq 1 $2); do $BIN/vis-ax $PID "$1" >/dev/null 2>&1 && return 0; sleep 1; done
  return 1
}
rowreads() {  # <prefix> <seconds> — the main window's footer row, read by VALUE through System Events:
  # vis-ax cannot reach this one static text (VX-621 — every sibling in the window resolves, this element
  # never does, on-screen or off), so the row assertion reads it the way that demonstrably works.
  local i
  for i in $(seq 1 $2); do
    osascript -e "tell application \"System Events\" to tell (first application process whose unix id is $PID) to get value of (first static text of group 1 of window \"Variorum Dev\" whose value begins with \"$1\")" >/dev/null 2>&1 && return 0
    sleep 1
  done
  return 1
}
prodread() { $REPO/Tools/prod-read.sh "$1" }
frame_reset() {  # D-4, PRE-LAUNCH (zero instances): delete the main window's frame-autosave key(s) from the dev domain
  local k left
  for k in ${(f)"$(defaults export $DEBUG_ID - 2>/dev/null | frame_keys)"}; do
    defaults delete $DEBUG_ID "$k" 2>/dev/null || stop "the window-frame guard could not delete the dev domain's '$k'"
    log "the window-frame guard: deleted the dev domain's '$k' — the main window comes up at its default size"
  done
  left=$(defaults export $DEBUG_ID - 2>/dev/null | frame_keys)
  [[ -z $left ]] || stop "the window-frame guard: the dev domain still holds '${left//$'\n'/ · }' after the delete"
}
displays() {  # each display's VISIBLE frame, Quartz global points ("x y w h" per line) — NSScreen read by JXA, no events
  osascript -l JavaScript -e 'ObjC.import("AppKit"); var s = $.NSScreen.screens, H = s.objectAtIndex(0).frame.size.height, out = []; for (var i = 0; i < s.count; i++) { var v = s.objectAtIndex(i).visibleFrame; out.push([v.origin.x, H - (v.origin.y + v.size.height), v.size.width, v.size.height].map(Math.round).join(" ")); } out.join("\n")' 2>/dev/null
}
frame_check() {  # D-4, POST-LAUNCH, before any act: the main window's bounds hold its footer row on screen
  local -a w; local why
  w=($($BIN/vis-win $PID 2>/dev/null))   # "<id> <x> <y> <w> <h>" — the pid's largest on-screen layer-0 window
  why=$(rect_inside "${w[2,5]}" "$(displays)") || { capture frame; stop "the window-frame guard: $why" }
  log "the window-frame guard: the main window ${w[2,5]} lies inside a display's visible frame — its footer row on screen"
}

# --- the legs, as functions (each arm composes them) -----------------------------------------------------------------
launch_on_road() {  # <app log> — P1 + P2: the window-frame guard, the launch, the road armed, the main window, its bounds
  APPLOG=$1
  step ${2:-P1} "launch the Debug build on the prod test road (the allowlist handed — F-B1-1 (B))"
  frame_reset
  author
  local LIST i road envline
  LIST=$(allowlist_value $ALLOW)   # G2 checked this file; never printed
  [[ -n ${LIST// /} ]] || stop "the allowlist's list is empty"
  open -n --env VARIORUM_PROD_TEST_ROAD=1 --env VARIORUM_PRODTEST_EMAILS="$LIST" --env OS_ACTIVITY_DT_MODE=YES \
    --stderr $APPLOG $APP
  unset LIST
  for i in {1..40}; do PID=$(pgrep -f "$APP/Contents/MacOS" | head -1); [[ -n $PID ]] && break; sleep 0.5; done
  [[ -n $PID ]] || stop "the Debug build did not start"
  log "pid $PID"

  step ${3:-P2} "the road: the process's environment and the app's own line"
  envline=$(ps eww -p $PID)
  [[ $envline == *"VARIORUM_PROD_TEST_ROAD=1"* ]] || stop "the launched process does not carry VARIORUM_PROD_TEST_ROAD=1"
  [[ $envline == *"VARIORUM_PRODTEST_EMAILS="* ]] || stop "the launched process does not carry the handed allowlist"
  [[ $envline != *"VARIORUM_WALK_PROJECT_URL="* ]] || stop "the launched process carries a walk project"
  unset envline   # never printed
  for i in {1..60}; do grep -q "PROD TEST ROAD (VX-510): " $APPLOG 2>/dev/null && break; sleep 1; done
  road=$(grep -o "PROD TEST ROAD (VX-510): [A-Z]*[^;]*" $APPLOG | head -1)
  [[ $road == *": ARMED"* ]] || stop "the road did not arm: ${road:-no road line in the app's log}"
  log "$road"
  WID=
  for i in {1..60}; do window && break; sleep 1; done
  [[ -n $WID ]] || stop "no main window"
  sleep 3; frame_check; capture launched
}
sign_in() {  # the row's Sign in… → the Account sheet → Email/Password by the helper → Sign In → its Sign out → Close
  press "Sign in…" AXButton
  waitfor "Email" 20 || stop "the Account sheet did not open"
  focus "Email"; secret email
  focus "Password"; secret password
  press "Sign In" AXButton
  waitfor "Sign out" 60 || { capture signin; stop "the sign-in did not land" }  # the sheet's own door (no ellipsis — Settings' spelling differs); found at the first live run
  capture signed-in
  press "Close" AXButton
}
close_settings() {  # best-effort, logged — so a relaunch restores no stale Settings window (VisualWalk's recipe, lib.zsh:402)
  author
  if osascript -e 'tell application "System Events"' -e "tell (first application process whose unix id is $PID)" \
      -e 'if exists window "Variorum Dev Settings" then click (first button whose subrole is "AXCloseButton") of window "Variorum Dev Settings"' \
      -e 'end tell' -e 'end tell' >/dev/null 2>&1; then log "Settings closed (if it was open)"
  else log "Settings: the close did not answer — a relaunch may restore it"; fi
  sleep $GAP
}
open_protection() {  # <door> — Settings ▸ Protection until <door> shows; ONE close-and-reopen when it doesn't (the open
  # pane's account section does not re-read an auth change — the VX-510 re-walk's O-RW-1, confirmed live)
  # Settings through the app menu's item (VisualWalk's road, lib.zsh:395 — ⌘, is swallowed by a focused editor, the
  # WalkKit README's 13u4 F2), ⌘, only when the menu does not answer.
  local try
  for try in 1 2; do
    author; activate
    osascript -e "tell application \"System Events\" to tell (first application process whose unix id is $PID) to click menu item \"Settings…\" of menu 1 of menu bar item 2 of menu bar 1" >/dev/null 2>&1 \
      || osascript -e 'tell application "System Events" to keystroke "," using command down' >/dev/null
    sleep $GAP
    press "Protection" AXButton
    waitfor "$1" 15 && return 0
    (( try == 1 )) && { log "'$1' is not on the Protection pane — closing Settings and reopening once (O-RW-1)"; close_settings }
  done
  capture protection; stop "no '$1' on Settings ▸ Protection, even after a reopen"
}
quit_walk_app() {  # by identity (the Debug bundle — her app is another id, and absent by every author check); OUR pid
  # proven gone, then ZERO instances by path, as its own step (never chained after the quit). Settings closed first.
  local out i left
  close_settings
  out=$(osascript -e "tell application id \"$DEBUG_ID\" to quit" 2>&1)
  log "quit requested by identity — ${out:-accepted}"
  for i in {1..30}; do kill -0 $PID 2>/dev/null || break; sleep 1; done
  kill -0 $PID 2>/dev/null && stop "the walk instance (pid $PID) did not quit (${out:-no answer}) — a sheet may hold ⌘Q: look, dismiss, quit by identity"
  left=$(pgrep -fl 'Variorum.app/Contents/MacOS')
  [[ -z $left ]] && PID= WID=
  [[ -z $left ]] || stop "after the quit a Variorum instance still runs: ${left//$'\n'/ · } — never quit hers; yours only by a proven PID"
  log "zero instances"
}
reset_account() {  # <leg: prestep|cleanup> — the guarded helper (D-1); its lines into this log; its id must be P3's
  local out rc hid l
  out=$($RESET $ACCOUNT --log $RUN/reset-$1.log 2>&1); rc=$?
  for l in ${(f)out}; do log "$l"; done
  (( rc == 0 )) || stop "the $1 reset did not reach the resting state (exit $rc) — the account stands as reset-$1.log says"
  hid=$(helper_id "$out")
  [[ $hid == $UID_ ]] || stop "the $1 reset resolved account '${hid:-none}', not P3's $UID_"
}
account_reads() {  # → "<vault answer>\n<cursors answer>" by the account's id (SELECTs only)
  print -r -- "$(prodread "select mode, revision from key_vault where user_id = '$UID_'")"
  print -r -- "$(prodread "select count(*) as n from device_cursor where owner_id = '$UID_'")"
}

# --- THE ARMS ------------------------------------------------------------------------------------------------------
log "arm '$ARM' · the slot folder $SLOT_AT_G7 at G7"
launch_on_road $RUN/app.log

step P3 "the account on production (exists, confirmed) — its id, read once"
# The email is the one G2 CHECKED (guard_allowlist handed it back) — the file is never re-read (the VX-623 ladder's round-1
# check-to-use seam). The plain-address re-check at the splice stays as a belt.
plain_address "$EMAIL" || { unset EMAIL; stop "the '$ACCOUNT' account's checked email failed the splice's plain-address re-check (a belt — G2 checks the same rule)" }
user=$(prodread "select id, email_confirmed_at is not null as confirmed from auth.users where email = '$EMAIL'")
unset EMAIL
UID_=$(print -r -- $user | grep -o '"id":"[0-9a-f-]*"' | head -1 | cut -d'"' -f4)
[[ -n $UID_ ]] || stop "no production account for '$ACCOUNT' — sign it up and confirm it first (Tools/prod-confirm-test-user.sh)"
[[ $user == *'"confirmed":true'* ]] || stop "the '$ACCOUNT' account is not confirmed yet (Tools/prod-confirm-test-user.sh)"
log "account id $UID_ (confirmed)"

if [[ $ARM != join ]]; then
  step P3r "THE PRE-STEP (D-2): the account reset to its resting state if it is not at rest — the set-up arm meets a vaultless account"
  reset_account prestep

  step P4 "sign in"
  sign_in

  step P5 "the row says not-yet; the twelve words' look (Settings ▸ Protection), copied and stashed"
  waitfor "$NOT_YET" 30 || { capture row; stop "the row does not read the not-yet line" }
  capture not-on-yet
  author; activate; osascript -e 'tell application "System Events" to keystroke "," using command down' >/dev/null; sleep $GAP
  press "Protection" AXButton
  press "Record your twelve words…" AXButton
  waitfor "Copy" 20 || stop "the words' look did not show its words"
  press "Copy" AXButton
  $STASH $ACCOUNT >/dev/null || stop "the words stash refused (never twelve words on the clipboard?)"
  log "the words stashed (never printed)"
  press "I've written them down" AXButton
  waitfor "Close" 5 && press "Close" AXButton

  step P6 "Turn on sync — the set-up arm: a new passphrase twice, the words"
  press "Turn on sync…" AXButton
  waitfor "New passphrase" 20 || stop "the set-up confirm did not open (is this the set-up arm?)"
  focus "New passphrase"; secret passphrase
  focus "Again"; secret passphrase
  focus "Your twelve words"; secret words
  capture confirm
  press "Turn on sync" AXButton

  step P7 "THE SHEET confirms the first round (VX-507), the row reads Synced with no relaunch (VX-498)"
  if ! waitfor "$SETUP_LANDED" 180; then
    capture sheet
    # The blocked line is "Sync hasn't run yet: <the row's sentence>." (ProtectionWords.firstRoundBlocked — :1053), so the
    # probe matches its PREFIX (an exact match never fired: this diagnosis was dead before VX-623).
    VIS_AX_PREFIX=1 waitfor "Sync hasn't run yet" 1 && stop "the sheet says the first round is blocked (its line is in the capture)"
    stop "the sheet never confirmed the first round — check the confirm sheet: a still-standing sheet with a disabled button means a field is empty or mistyped (capture every window, not the first)"
  fi
  capture synced-sheet
  press "Done" AXButton
  rowreads "Synced" 30 || { capture row; stop "the row does not read Synced" }
  capture synced-row
  pgrep -f "$APP/Contents/MacOS" | grep -qx $PID || stop "the process changed — this was meant to run with no relaunch"

  step P8 "the server, by the account's id (Tools/prod-read.sh — SELECTs only)"
  vault=$(prodread "select mode, revision, key_proof_hash is not null as proof from key_vault where user_id = '$UID_'")
  kp=$(prodread "select count(*) as n from vault.secrets where name = 'kp:$UID_'")
  cursors=$(prodread "select count(*) as n from device_cursor where owner_id = '$UID_'")
  # The push evidence is setting + container TOGETHER: an account-bound fresh store defers its seed behind
  # the first clean round (SampleLibraryWelcome's sync gate), so its first push carries setting rows only —
  # the "3 settings" VX-510's own hand-verification read. A seeded store counts containers too. (VX-621)
  rows=$(prodread "select (select count(*) from setting where owner_id = '$UID_') + (select count(*) from container where owner_id = '$UID_') as n")
  log "key_vault: $vault"; log "kp secret: $kp"; log "device cursors: $cursors"; log "data rows (setting + container): $rows"
  [[ $vault == *'"mode":'* && $vault == *'"proof":true'* ]] || stop "no vault row with its proof"
  [[ $kp == *'"n":1'* ]] || stop "no kp: secret — no round ever reached the key-proof enrollment"
  [[ $cursors == *'"n":'[1-9]* ]] || stop "no device cursor"
  [[ $rows == *'"n":'[1-9]* ]] || stop "no data rows on the server"
  log "the set-up arm PASSED — the sheet confirmed, the row Synced, the server holds the vault, the proof, a cursor and rows"
fi

if [[ $ARM == both ]]; then
  step J1 "the set-up instance quits by identity — zero instances, its own step"
  quit_walk_app

  step J2 "the walk's OWN library set aside — never the dev store's files (G7)"
  setup_lib=$(turnon_library $RUN/app.log)
  why=$(aside_verdict "$SLOT" $SLOT_AT_G7 "$setup_lib" "$ASIDE") \
    || stop "$why — so the set-up arm's library is the walker's to set aside: mv \"$SLOT\" \"$ASIDE\", then run: Tools/WalkKit/first-run-walk.sh $ACCOUNT --arm join"
  aside_own_slot "$SLOT" "$ASIDE" || stop "the rename of the slot folder to ${ASIDE:t} did not prove out — look before anything moves again"
  log "the set-up arm's library $setup_lib set aside WHOLE → ${ASIDE:t} (one rename; the slot folder was absent at G7, so this run made it)"

  launch_on_road $RUN/app-join.log J3 J3b   # the launch, then the road and the window's bounds (P1/P2's twins)
fi

if [[ $ARM != setup ]]; then
  step J4 "the fresh library's row — signed in still (the session outlives a library), or signed in now"
  joined= i=
  for i in {1..30}; do
    { waitfor "$NOT_YET" 1 || rowreads "$NOT_YET" 1 } && { joined=1; break }
    if waitfor "Sign in…" 1; then
      log "signed out — signing in"; sign_in
      { waitfor "$NOT_YET" 30 || rowreads "$NOT_YET" 1 } && { joined=1; break }
      capture row; stop "the row does not read the not-yet line after the sign-in"
    fi
  done
  [[ -n $joined ]] || { capture row; stop "the fresh library's row reads neither '$NOT_YET' nor Sign in…" }
  capture not-on-yet

  step J5 "the server before the join: the account's Standard vault and its device cursors"
  before=("${(@f)$(account_reads)}")
  log "key_vault before: ${before[1]}"; log "device cursors before: ${before[2]}"
  why=$(join_ready "${before[1]}") || stop "$why"

  step J6 "Sync this library — the join arm: the account's passphrase"
  open_protection "$JOIN_DOOR"
  press "$JOIN_DOOR" AXButton
  waitfor "$JOIN_FIELD" 20 || { capture confirm; stop "the join's confirm did not open (no '$JOIN_FIELD' field)" }
  focus "$JOIN_FIELD"; secret passphrase
  capture confirm
  press "$JOIN_BUTTON" AXButton

  step J7 "THE SHEET confirms the join's first round — the words notice's OK first when it shows"
  landed= noticed=
  for i in {1..180}; do
    $BIN/vis-ax $PID "$JOIN_LANDED" >/dev/null 2>&1 && { landed=1; break }
    if [[ -z $noticed ]] && VIS_AX_PREFIX=1 $BIN/vis-ax $PID "$JOIN_NOTICE" AXStaticText >/dev/null 2>&1; then
      capture words-notice
      press "OK" AXButton; noticed=1
      log "the words notice (the passphrase was typed, so the library's words are the account's now) — OK"
    fi
    sleep 1
  done
  if [[ -z $landed ]]; then
    capture sheet
    VIS_AX_PREFIX=1 waitfor "Sync hasn't run yet" 1 && stop "the sheet says the join's first round is blocked (its line is in the capture)"
    stop "the join never confirmed its first round — a refusal line under the confirm's fields (in the capture) means the passphrase did not open the account"
  fi
  capture synced-sheet
  press "Done" AXButton
  rowreads "Synced" 30 || { capture row; stop "the row does not read Synced after the join" }
  capture synced-row
  pgrep -f "$APP/Contents/MacOS" | grep -qx $PID || stop "the process changed — the join was meant to land with no relaunch"

  step J8 "the server after the join: cursors +1, the vault's mode and revision unchanged"
  after=("${(@f)$(account_reads)}")
  log "key_vault after: ${after[1]}"; log "device cursors after: ${after[2]}"
  why=$(join_verdict "${before[1]}" "${before[2]}" "${after[1]}" "${after[2]}") || stop "$why"
  log "the join arm PASSED — the sheet confirmed, the row Synced, one device cursor more, the account's lock unmoved"
fi

# --- THE END — the evidence above is logged; now the resting posture, then the account's resting state ------------
step E1 "sign the walk session out — the Debug app's resting posture"
open_protection "Sign out…"
press "Sign out…" AXButton
waitfor "Sign Out" 15 || { capture signout; stop "the sign-out confirm did not open" }
press "Sign Out" AXButton
waitfor "Sign in…" 30 || { capture signout; stop "the sign-out did not land (no 'Sign in…' anywhere)" }
capture signed-out

step E2 "quit the walk instance by identity — zero instances"
quit_walk_app

step E3 "THE CLEANUP LEG (D-2): the account back to its resting state — after a PASS, never after a STOP"
reset_account cleanup

STEP=done
log "PASSED — '$ACCOUNT', arm '$ARM'; signed out, quit, and the account at rest (exists, confirmed, vaultless, rowless)"
print "first-run-walk PASSED for '$ACCOUNT' (arm '$ARM'; captures and log: $RUN)."
print "The walk signed out, quit (zero instances), and reset the account to its resting state (reset-cleanup.log)."
print "The slot: $SLOT holds the walk's last library$( [[ $ARM == both ]] && print -r -- "; ${ASIDE:t} beside it holds the set-up arm's")."
print "Both are walk debris — the walker's restoration moves them into the walk debris home and returns the as-found set"
print "(the run record's ENVIRONMENT TRAPS — the held library is restored exactly as found; never Resume)."
exit 0
