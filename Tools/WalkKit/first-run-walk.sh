#!/bin/zsh
# Tools/WalkKit/first-run-walk.sh — VX-509's SCRIPTED FIRST-RUN WALK (VX-510 unit B1, D-B2; the run record
# notes/plans/fixes/vx-510-first-run-sync.md). The DEV-store Debug build on the PROD TEST ROAD (her rulings R-510-1/-6 —
# `VARIORUM_PROD_TEST_ROAD=1` + the allowlist this script hands it), ONE named test account, through: launch → the road armed → sign in → the
# twelve words' look (stashed, never read) → Settings ▸ Protection ▸ Turn on sync… → THE SHEET'S "Synced." (VX-507) → the
# row's "Synced ‹time›" with NO relaunch (VX-498) → the server checks through Tools/prod-read.sh (the vault row · the
# `kp:` secret · a device cursor · data rows). The release checklist row (Tools/Release/release.sh's HANDOFF) names it beside
# the headless gate FirstRunDrillTests.
#
#   Tools/WalkKit/first-run-walk.sh <std|castle|del> [--app <Debug Variorum.app>] [--dry-run]
#   Tools/WalkKit/first-run-walk.sh --self-test
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
#   G7  the dev slot is set aside (no variorum.sqlite in the Debug container's Variorum-dev): the slot's files go aside by
#       `mv` BEFORE the walk (the run record's ENVIRONMENT TRAPS) — never this script's act
#   G8  the road's tools: Tools/prod-read.sh + .env.supabase.local (present, never read here); the typing and stashing
#       helpers in ~/.variorum/bin (mode 700); cliclick
#   G9  this terminal's grants — Accessibility, Screen Recording, Automation for System Events — CHECKED, never prompted
#       (Tools/VisualWalk's vis-tcc; a consent dialog is the author's to answer)
#   --dry-run: the guards, then the plan; nothing launched.
#   --self-test: G1/G2 against temp FIXTURES (never her file) — each refusal shown firing; nothing else runs.
# Exit: 0 the walk PASSED (or the dry run's guards held) · 4 STOPPED at a step (its capture and reason printed; the app is
# left running for the walker to look — quit it by identity) · 5 refused (a guard; nothing launched).
#
# F-B1-1 (B), RULED (the run record): the sandboxed Debug app cannot read ~/.variorum, so THIS SCRIPT — outside the sandbox —
# reads the allowlist file (G2's checks: a regular file, mode 600, every entry 'vxtest') and HANDS its one key to the launch
# as `--env VARIORUM_PRODTEST_EMAILS=<the list>` beside the road's switch; the app reads only that value and keeps every guard
# of its own (exactly `1` asks, a walk project refuses, an empty list refuses, every entry marked, the admission per account
# at connect). The emails are no secret (they show in `ps eww`); the secrets beside them in the file are never handed.
#
# Written by implementer session B1 and dry-checked for its guards only — NEVER run against production by that session;
# its first live run is unit C's (LEG S's S4–S7), where the GUI steps' labels meet the real window for the first time.

emulate -L zsh
setopt pipe_fail

REPO=${0:A:h:h:h}
WK=$REPO/Tools/WalkKit
VW=$REPO/Tools/VisualWalk
ALLOW=$HOME/.variorum/prod-test-accounts.env
TYPE=$HOME/.variorum/bin/type-prod-test-secret
STASH=$HOME/.variorum/bin/stash-prod-test-words
DEBUG_ID=io.lduarte.Variorum.debug
SLOT="$HOME/Library/Containers/$DEBUG_ID/Data/Library/Application Support/Variorum-dev"
APP=$REPO/App/Variorum/DerivedData/vx510/Build/Products/Debug/Variorum.app
WORK=$REPO/App/Variorum/DerivedData/first-run-walk
BIN=$WORK/bin
GAP=2.6   # >= 2.5 s between guarded acts: a synthetic act resets HIDIdleTime (WalkKit's self-trip rule)

refuse() { print -u2 "first-run-walk REFUSES: $*"; exit 5 }

# --- G1 + G2, pure over a file (the self-test feeds it fixtures) ----------------------------------------------------
# plain_address <address> → 0 for a PLAIN address: Tools/prod-confirm-test-user.sh's shape (lowercase letters, digits,
# . _ + - and one @, a dotted lowercase domain), matched against the WHOLE value with zsh's =~ — never a line-wise grep,
# which passes a value whose FIRST line is plain (the ladder's F-R1-5: P3 splices the address into its SELECT).
PLAIN_ADDRESS='^[a-z0-9._+-]+@[a-z0-9.-]+\.[a-z]+$'
plain_address() { [[ $1 =~ $PLAIN_ADDRESS ]] }
# guard_allowlist <file> <account> → 0, or prints the refusal and returns 1. Values never printed.
# allowlist_value <file> → the file's one key (the list the launch is handed), read in a subshell; the other keys never.
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
  return 0
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

# --- --self-test: the allowlist guard's teeth, over fixtures only ----------------------------------------------------
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
  # D-5 (VX-623): every capture is withheld while the twelve words could be on screen — the words guard's teeth, over
  # strings (its --classify mode; the AX walk itself needs a live pid). Compiled into the temp folder, never the repo.
  sure() {  # <label> <zsh condition>
    if eval "$2"; then print -r -- "SELF-TEST $1  ok"; else print -r -- "SELF-TEST $1  FAIL"; fails=$((fails + 1)); fi
  }
  if swiftc -O -o $T/words-guard $WK/words-guard.swift 2>/dev/null; then
    wg() { $T/words-guard --classify "$1" >/dev/null }
    sure "D-5 the words guard withholds twelve lowercase words" '! wg "alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo lima"'
    sure "D-5 … spaced and padded the same" '! wg "  alpha  bravo charlie delta echo foxtrot golf hotel india juliet kilo lima "'
    sure "D-5 … the look's button (I've written them down)" '! wg "I'\''ve written them down"'
    sure "D-5 … the look's warning (These words won't be shown again.)" '! wg "These words won'\''t be shown again."'
    sure "D-5 … the look's reveal door (Show my twelve words)" '! wg "Show my twelve words"'
    sure "D-5 lets eleven words through" 'wg "alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo"'
    sure "D-5 lets thirteen words through" 'wg "alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo lima mike"'
    sure "D-5 lets the join's landed line through" 'wg "Synced. Your account'\''s writing is in this library now."'
    sure "D-5 lets the join's words notice through (it names no words)" \
      'wg "Your twelve words are a+vxtest-std@x.test'\''s twelve words. Your previous twelve words still open backups made with them. If you don'\''t have your account'\''s words written down, you can make new ones at any time."'
    sure "D-5 the guard refuses a pid it cannot read as withheld (fail-closed)" '! $T/words-guard notapid >/dev/null'
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
  (( fails == 0 )) && { print "SELF-TEST: every guard fired as expected"; exit 0 }
  print "SELF-TEST: $fails case(s) wrong"; exit 1
fi

# --- arguments --------------------------------------------------------------------------------------------------------
ACCOUNT= DRY=
while (( $# )); do
  case $1 in
    --app) APP=${2:?--app needs a path}; shift ;;
    --dry-run) DRY=1 ;;
    -*) refuse "unknown option $1" ;;
    *) [[ -z $ACCOUNT ]] && ACCOUNT=$1 || refuse "one account only" ;;
  esac
  shift
done
[[ -n $ACCOUNT ]] || refuse "usage: first-run-walk.sh <std|castle|del> [--app <Debug Variorum.app>] [--dry-run] | --self-test"

# --- THE GUARDS (in order; each refusal exits 5 with nothing launched) ------------------------------------------------
why=$(guard_allowlist $ALLOW $ACCOUNT) || refuse "G1/G2 — $why"
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
[[ ! -e $SLOT/variorum.sqlite ]] || refuse "G7 — the dev slot holds a library; set its top-level files aside by mv first (the run record's ENVIRONMENT TRAPS)"
[[ -x $REPO/Tools/prod-read.sh && -f $REPO/.env.supabase.local ]] || refuse "G8 — Tools/prod-read.sh or .env.supabase.local is missing"
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

RUN=$WORK/run-$(date -u +%Y%m%dT%H%M%SZ)-$ACCOUNT
if [[ -n $DRY ]]; then
  print "first-run-walk DRY RUN — every guard holds for '$ACCOUNT'. The plan (nothing launched):"
  print "  P1 launch $APP with VARIORUM_PROD_TEST_ROAD=1 + the handed VARIORUM_PRODTEST_EMAILS (open -n --env; stderr → $RUN/app.log)"
  print "  P2 ps eww: the road's switch and the handed list present, no walk project · the log: 'PROD TEST ROAD (VX-510): ARMED'"
  print "  P3 prod read: the account exists and is confirmed (auth.users by email → its id)"
  print "  P4 sign in (the row's Sign in… → Email/Password typed by type-prod-test-secret)"
  print "  P5 the row: 'Sync isn't on for this library yet' · Settings ▸ Protection ▸ Record your twelve words… → Copy → stash"
  print "  P6 Turn on sync… → the new passphrase twice + the words (typed by the helper) → Turn on sync"
  print "  P7 THE SHEET: 'Synced. Your library is on your account now.' (≤ 180 s) → Done · the row 'Synced ‹time›'"
  print "  P8 prod reads by the account's id: key_vault (mode) · vault.secrets kp:<id> · device_cursor · data rows (setting + container)"
  exit 0
fi

# --- THE WALK (live — unit C's; the stage held, the slot aside) -------------------------------------------------------
mkdir -p $RUN
STEP=start PID= WID=
log() { print -r -- "[$(date +%H:%M:%S)] $STEP: $*" | tee -a $RUN/walk.log }
window() { local w; w=($($BIN/vis-win $PID 2>/dev/null)); [[ ${w[1]:-none} != none ]] && WID=$w[1] }
capture() {  # <label> — D-5 (VX-537): EVERY on-screen window of the pid, each window-scoped (never the full screen), named
  # <time>-<step>-<label>-w<n>.png, the listing appended to captures.txt — and NOTHING while the words guard says the
  # twelve words could be on screen (a failed guard withholds too: fail-closed).
  local g pre
  [[ -n $PID ]] || return 0
  g=$($BIN/words-guard $PID 2>/dev/null) || { log "capture '$1' WITHHELD — ${g:-the words guard did not answer}"; return 0 }
  pre="$(date +%H%M%S)-$STEP-$1-"
  $BIN/walk-cap $PID $RUN $pre --every-layer >> $RUN/captures.txt 2>&1
  log "captured '$1' → ${pre}w*.png ($(tail -1 $RUN/captures.txt))"
}
stop() { log "STOPPED — $*"; capture stopped; print -u2 "first-run-walk STOPPED at $STEP: $* (the app is left running; captures in $RUN)"; exit 4 }
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

step P1 "launch the Debug build on the prod test road (the allowlist handed — F-B1-1 (B))"
frame_reset
author
LIST=$(allowlist_value $ALLOW)   # G2 checked this file; never printed
[[ -n ${LIST// /} ]] || stop "the allowlist's list is empty"
open -n --env VARIORUM_PROD_TEST_ROAD=1 --env VARIORUM_PRODTEST_EMAILS="$LIST" --env OS_ACTIVITY_DT_MODE=YES \
  --stderr $RUN/app.log $APP
unset LIST
for i in {1..40}; do PID=$(pgrep -f "$APP/Contents/MacOS" | head -1); [[ -n $PID ]] && break; sleep 0.5; done
[[ -n $PID ]] || stop "the Debug build did not start"
log "pid $PID"

step P2 "the road: the process's environment and the app's own line"
envline=$(ps eww -p $PID)
[[ $envline == *"VARIORUM_PROD_TEST_ROAD=1"* ]] || stop "the launched process does not carry VARIORUM_PROD_TEST_ROAD=1"
[[ $envline == *"VARIORUM_PRODTEST_EMAILS="* ]] || stop "the launched process does not carry the handed allowlist"
[[ $envline != *"VARIORUM_WALK_PROJECT_URL="* ]] || stop "the launched process carries a walk project"
unset envline   # never printed
for i in {1..60}; do grep -q "PROD TEST ROAD (VX-510): " $RUN/app.log 2>/dev/null && break; sleep 1; done
road=$(grep -o "PROD TEST ROAD (VX-510): [A-Z]*[^;]*" $RUN/app.log | head -1)
[[ $road == *": ARMED"* ]] || stop "the road did not arm: ${road:-no road line in the app's log}"
log "$road"
for i in {1..60}; do window && break; sleep 1; done
[[ -n $WID ]] || stop "no main window"
sleep 3; frame_check; capture launched

step P3 "the account on production (exists, confirmed) — its id, read once"
EMAIL=$(set -a; source $ALLOW; set +a; eval "print -r -- \"\${VARIORUM_PRODTEST_${(U)ACCOUNT}_EMAIL}\"")
# Re-checked at the splice (the file is re-read here — G2's check is of an earlier read).
plain_address "$EMAIL" || { unset EMAIL; stop "the '$ACCOUNT' account's email is not a plain address (the allowlist changed since G2?)" }
user=$(prodread "select id, email_confirmed_at is not null as confirmed from auth.users where email = '$EMAIL'")
unset EMAIL
UID_=$(print -r -- $user | grep -o '"id":"[0-9a-f-]*"' | head -1 | cut -d'"' -f4)
[[ -n $UID_ ]] || stop "no production account for '$ACCOUNT' — sign it up and confirm it first (Tools/prod-confirm-test-user.sh)"
[[ $user == *'"confirmed":true'* ]] || stop "the '$ACCOUNT' account is not confirmed yet (Tools/prod-confirm-test-user.sh)"
log "account id $UID_ (confirmed)"

step P4 "sign in"
press "Sign in…" AXButton
waitfor "Email" 20 || stop "the Account sheet did not open"
focus "Email"; secret email
focus "Password"; secret password
press "Sign In" AXButton
waitfor "Sign out" 60 || { capture signin; stop "the sign-in did not land" }  # the sheet's own door (no ellipsis — Settings' spelling differs); found at the first live run
capture signed-in
press "Close" AXButton

step P5 "the row says not-yet; the twelve words' look (Settings ▸ Protection), copied and stashed"
waitfor "Sync isn't on for this library yet" 30 || { capture row; stop "the row does not read the not-yet line" }
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
if ! waitfor "Synced. Your library is on your account now." 180; then
  capture sheet
  waitfor "Sync hasn't run yet" 1 && stop "the sheet says the first round is blocked (its line is in the capture)"
  stop "the sheet never confirmed the first round — check the confirm sheet: a still-standing sheet with a disabled button means a field is empty or mistyped (capture every window, not the first)"
fi
capture synced-sheet
press "Done" AXButton
rowreads "Synced" 30 || { capture row; stop "the row does not read Synced" }
capture synced-row
pgrep -f "$APP/Contents/MacOS" | grep -qx $PID || stop "the process changed — this was meant to run with no relaunch"

step P8 "the server, by the account's id (Tools/prod-read.sh — SELECTs only)"
vault=$(prodread "select mode, key_proof_hash is not null as proof from key_vault where user_id = '$UID_'")
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

STEP=done
log "PASSED — '$ACCOUNT' first run: the sheet confirmed, the row Synced, the server holds the vault, the proof, a cursor and rows"
print "first-run-walk PASSED for '$ACCOUNT' (captures and log: $RUN). The app is still running: sign the session out and quit it"
print "by identity (osascript -e 'tell application id \"$DEBUG_ID\" to quit') — then the run record's close."
exit 0
