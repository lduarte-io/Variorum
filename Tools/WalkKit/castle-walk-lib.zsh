# Tools/WalkKit/castle-walk-lib.zsh — the guarded primitives of VX-502 unit B's Castle-restore walk (the script of record
# is notes/plans/fixes/vx-502-walk-script.md). SOURCED by the walk session (`source Tools/WalkKit/castle-walk-lib.zsh`),
# never executed. Every primitive returns non-zero and prints "STOP: …" when its guard fails; the session then stops the leg
# and records it — it never retries around a Castle door (the record's constraints: 2–3 attempts, then STOP).
#
# THE TWO LANES (oct26coordinator's, binding): the DEV pair (~/.variorum/dev-castle.env) is typed ONLY by
# ~/.variorum/bin/type-dev-castle-secret into a PLAIN launch (no VARIORUM_* keys); the vxtest ACCOUNT's secrets are typed
# ONLY by ~/.variorum/bin/type-prod-test-secret castle <field> into a PROD-TEST-ROAD launch. Each helper refuses the other
# lane's launch. No value is ever printed, logged, captured or passed in argv by this file.
#
# Machinery facts carried (Tools/WalkKit/README.md, the VX-510 / VX-529 records): keys go through System Events (keys.sh),
# never cliclick kp:/t:; SwiftUI Settings controls and alerts answer AXPress (vis-ax … press), not synthetic clicks;
# guarded acts ≥ 2.5 s apart (a synthetic act resets HIDIdleTime); captures are WINDOW-scoped (every layer-0 window of
# the pid), never full-screen; instance checks are the coordinator's strict forms; a quit is identity-addressed, its outcome
# read, and the zero-instance check is ITS OWN step — never chained after a quit with || or ;.

emulate -L zsh 2>/dev/null
WK_REPO=${WK_REPO:-/Users/lillianduarte/dev/variorum-vx-502}
WK_EV=${WK_EV:-$WK_REPO/App/Variorum/DerivedData/vx502-walk-evidence}        # gitignored (DerivedData/); deleted at close
WK_BIN=$WK_EV/bin
WK_APP=${WK_APP:-$WK_REPO/App/Variorum/DerivedData/vx502-walk/Build/Products/Debug/Variorum.app}
WK_DEBUG_ID=io.lduarte.Variorum.debug
WK_SUPPORT="$HOME/Library/Containers/$WK_DEBUG_ID/Data/Library/Application Support"
WK_SLOT="$WK_SUPPORT/Variorum-dev"                                              # the slot FOLDER (top-level files = the library)
WK_ASIDE="$WK_SUPPORT/Variorum-dev-aside-vx502-asfound"                         # the as-found set, same volume (leg 2 B')
WK_PICKED="$HOME/Documents/Variorum/Backups"                                    # the dev build's picked backups folder
WK_PRODREAD=/Users/lillianduarte/dev/variorum/Tools/prod-read.sh                # main's checkout: its .env.supabase.local
WK_ALLOW=$HOME/.variorum/prod-test-accounts.env
WK_DEVHELP=$HOME/.variorum/bin/type-dev-castle-secret
WK_PRODHELP=$HOME/.variorum/bin/type-prod-test-secret
WK_GAP=2.6
WK_PID=${WK_PID:-}
WK_LEG=${WK_LEG:-W0}
WK_APPLOG=${WK_APPLOG:-}

# Each Bash call is a fresh shell: the session's facts (no secrets — a pid, a leg, a log path, the account's auth id)
# persist in $WK_EV/session.env and load when this file is sourced.
wk_save() { mkdir -p $WK_EV; print -r -- "WK_PID=${(q)WK_PID} WK_LEG=${(q)WK_LEG} WK_APPLOG=${(q)WK_APPLOG} WK_UID=${(q)WK_UID}" > $WK_EV/session.env }
wk_leg()  { WK_LEG=$1; wk_save; wk_log "— leg $1 begins" }
[[ -f $WK_EV/session.env ]] && source $WK_EV/session.env

wk_log()  { mkdir -p $WK_EV; print -r -- "[$(date -u +%H:%M:%SZ)] $WK_LEG: $*" | tee -a $WK_EV/walk.log }
wk_stop() { wk_log "STOP: $*"; print -u2 -r -- "STOP ($WK_LEG): $*"; return 1 }

# --- setup: the helpers compiled into the gitignored evidence bin; wl2 into Tools/WalkKit (gitignored — VX-536: guard.sh
#     calls it, and an ABSENT wl2 makes its on-this-Space check pass silently). Grants checked, never prompted.
wk_setup() {
  mkdir -p $WK_BIN || return 1
  local h
  for h in vis-ax vis-win vis-tcc vis-foreign; do
    [[ $WK_BIN/$h -nt $WK_REPO/Tools/VisualWalk/helpers/$h.swift ]] \
      || swiftc -O -o $WK_BIN/$h $WK_REPO/Tools/VisualWalk/helpers/$h.swift 2>/dev/null || { wk_stop "cannot compile $h"; return 1 }
  done
  [[ $WK_BIN/walk-cap -nt $WK_REPO/Tools/WalkKit/capture-windows.swift ]] \
    || swiftc -O -o $WK_BIN/walk-cap $WK_REPO/Tools/WalkKit/capture-windows.swift 2>/dev/null || { wk_stop "cannot compile walk-cap"; return 1 }
  [[ $WK_BIN/walk-scroll -nt $WK_REPO/Tools/WalkKit/scroll.swift ]] \
    || swiftc -O -o $WK_BIN/walk-scroll $WK_REPO/Tools/WalkKit/scroll.swift 2>/dev/null || { wk_stop "cannot compile walk-scroll"; return 1 }
  [[ $WK_REPO/Tools/WalkKit/wl2 -nt $WK_REPO/Tools/WalkKit/wl2.swift ]] \
    || swiftc -O -o $WK_REPO/Tools/WalkKit/wl2 $WK_REPO/Tools/WalkKit/wl2.swift 2>/dev/null || { wk_stop "cannot compile wl2"; return 1 }
  wk_words_guard_build || return 1
  local grants
  open -g -b com.apple.systemevents; sleep 1
  grants=$(perl -e 'alarm shift; exec @ARGV' 15 $WK_BIN/vis-tcc com.apple.systemevents) \
    || { wk_stop "the grants check failed or timed out (a consent prompt is the author's)"; return 1 }
  [[ ${grants%%$'\n'*} == "AX 1 SCREEN 1" && $grants == *"AE:com.apple.systemevents granted"* ]] \
    || { wk_stop "this terminal lacks a grant (${grants//$'\n'/ · }) — granting is the author's"; return 1 }
  [[ -x $WK_DEVHELP && $(stat -f %Lp $WK_DEVHELP) == 700 ]] || { wk_stop "$WK_DEVHELP missing or not mode 700"; return 1 }
  [[ -x $WK_PRODHELP && $(stat -f %Lp $WK_PRODHELP) == 700 ]] || { wk_stop "$WK_PRODHELP missing or not mode 700"; return 1 }
  [[ -x $WK_PRODREAD ]] || { wk_stop "no $WK_PRODREAD"; return 1 }
  [[ -d $WK_APP && $WK_APP == */Debug/Variorum.app && $WK_APP != /Applications/* ]] || { wk_stop "no Debug walk build at $WK_APP"; return 1 }
  [[ $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' $WK_APP/Contents/Info.plist 2>/dev/null) == $WK_DEBUG_ID ]] \
    || { wk_stop "$WK_APP is not the Debug build"; return 1 }
  wk_log "setup ok — helpers compiled, grants AX/SCREEN/System Events held, both typing helpers mode 700, the walk build present"
}

# The words guard: before EVERY capture, the pid's AX tree is read for words-shaped content — a static text or field
# value of exactly twelve lowercase words, or the words look's own markers. Withheld captures are logged, never taken.
# It prints only "ok" or "withheld (<class>)" — never the text.
wk_words_guard_build() {
  local src=$WK_BIN/words-guard.swift
  [[ -x $WK_BIN/words-guard && $WK_BIN/words-guard -nt ${(%):-%x} ]] && return 0
  cat > $src <<'SWIFT'
import ApplicationServices
import Foundation
let pid = pid_t(Int32(CommandLine.arguments[1])!)
func attr(_ e: AXUIElement, _ n: String) -> AnyObject? { var v: AnyObject?; return AXUIElementCopyAttributeValue(e, n as CFString, &v) == .success ? v : nil }
let twelve = try! NSRegularExpression(pattern: "^\\s*[a-z]+(\\s+[a-z]+){11}\\s*$")
let markers = ["i've written them down", "these words won't be shown again.", "show my twelve words"]
var queue: [AXUIElement] = (attr(AXUIElementCreateApplication(pid), kAXWindowsAttribute) as? [AXUIElement]) ?? []
var seen = 0
while !queue.isEmpty, seen < 30000 {
  let e = queue.removeFirst(); seen += 1
  for n in [kAXValueAttribute, kAXTitleAttribute, kAXDescriptionAttribute] {
    guard let s = attr(e, n) as? String else { continue }
    let l = s.lowercased()
    if twelve.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) != nil { print("withheld (a twelve-word string on screen)"); exit(1) }
    if markers.contains(where: { l.contains($0) }) { print("withheld (the words look is on screen)"); exit(1) }
  }
  queue += (attr(e, kAXChildrenAttribute) as? [AXUIElement]) ?? []
}
print("ok")
SWIFT
  swiftc -O -o $WK_BIN/words-guard $src 2>/dev/null || { wk_stop "cannot compile the words guard"; return 1 }
}

# --- instances (the coordinator's STRICT forms) -------------------------------------------------------------------------
wk_instances() { { pgrep -lx Variorum; pgrep -lf "MacOS/Variorum$" } 2>/dev/null | sort -u }
wk_zero() { [[ -z $(wk_instances) ]] || { wk_stop "a Variorum instance is running: $(wk_instances | tr '\n' ' ')"; return 1 } }

# --- inventories and fingerprints (names, inodes, sizes, short digests — never content) ---------------------------------
wk_inventory() {  # <dir> — every top-level FILE: name@inode size sha12
  local d=$1 f
  for f in ${d}/*(N.); do print -r -- "${f:t}@$(stat -f %i $f) $(stat -f %z $f) $(shasum -a 256 < $f | cut -c1-12)"; done | sort
}
wk_inodes() { local d=$1 f; for f in ${d}/*(N.); do print -r -- "${f:t}@$(stat -f %i $f)"; done | sort }
# The SEVEN persistent files (ruling 1): everything but the store's WAL/SHM, which rebuild at an open -- their check is
# presence and the store's consistency, never inode identity.
wk_persistent() { wk_inodes $1 | grep -vE '^variorum\.sqlite-(wal|shm)@' }
wk_persistent_e0() { [[ -f $WK_EV/slot-E0.txt ]] && awk '{print $1}' $WK_EV/slot-E0.txt | grep -vE '^variorum\.sqlite-(wal|shm)@' }
wk_keyfile_id() {  # <key file> → "<library8> key <fp8>" (the libraryID and the fingerprint prefix only)
  [[ -f $1 ]] || { print -r -- "no key file"; return 0 }
  python3 -I -c 'import json,sys;k=json.load(open(sys.argv[1]));print(k.get("libraryID","?")[:8],"key",k.get("fingerprint","?")[:8])' $1 2>/dev/null \
    || print -r -- "unreadable key file"
}
wk_hold() { local m=$WK_SLOT/variorum-restore-hold.json; [[ -f $m ]] && print -r -- "held (marker@$(stat -f %i $m) $(shasum -a 256 < $m | cut -c1-12))" || print -r -- "not held" }
wk_fp() { [[ -f $1 ]] && shasum -a 256 < $1 | cut -c1-16 || print -r -- "absent" }
wk_stage() { $WK_REPO/Tools/stage status 2>&1 | head -1 }

# --- production, SELECT-only (Tools/prod-read.sh from main's checkout) ---------------------------------------------------
WK_UID=${WK_UID:-}
wk_prodread() { $WK_PRODREAD "$1" }
wk_castle_uid() {  # the castle account's auth id, read once by its (plain, allowlisted) address; the address never printed
  local email row
  email=$(set -a; source $WK_ALLOW 2>/dev/null; set +a; print -r -- "${VARIORUM_PRODTEST_CASTLE_EMAIL:-}")
  [[ $email =~ '^[a-z0-9._+-]+@[a-z0-9.-]+\.[a-z]+$' && $email == *vxtest* ]] || { unset email; wk_stop "the castle address is not plain/marked"; return 1 }
  row=$(wk_prodread "select id, email_confirmed_at is not null as confirmed from auth.users where email = '$email'")
  unset email
  WK_UID=$(print -r -- $row | grep -o '"id":"[0-9a-f-]*"' | head -1 | cut -d'"' -f4)
  [[ -n $WK_UID ]] || { wk_stop "no production account for castle"; return 1 }
  [[ $row == *'"confirmed":true'* ]] || { wk_stop "the castle account is not confirmed"; return 1 }
  wk_save; wk_log "castle account id ${WK_UID[1,8]} (confirmed)"
}
wk_account() {  # one line: vault mode/revision/updated_at · cursors · live containers + newest
  [[ -n $WK_UID ]] || wk_castle_uid || return 1
  local v c n
  v=$(wk_prodread "select mode, revision, updated_at from key_vault where user_id = '$WK_UID'")
  c=$(wk_prodread "select count(*) as n from device_cursor where owner_id = '$WK_UID'")
  n=$(wk_prodread "select count(*) as n, max(created_at) as newest from container where owner_id = '$WK_UID' and deleted_at is null")
  print -r -- "vault ${v//[$'\n']/} · cursors ${c//[$'\n']/} · containers ${n//[$'\n']/}"
}

# --- the state line (the coordinator's condition (3)) — appended to the evidence log; the session copies it into the
#     record's LIVE STATUS and commits per leg ------------------------------------------------------------------------------
wk_state() {
  local line
  line="STATE ${1:-$WK_LEG} $(date -u +%Y-%m-%dT%H:%M:%SZ) | instances: $(wk_instances | wc -l | tr -d ' ')$( [[ -n $(wk_instances) ]] && print -r -- " ($(wk_instances | tr '\n' ' '))")"
  line+=" | slot files: $(wk_inodes $WK_SLOT | tr '\n' ' ')| slot library: $(wk_keyfile_id $WK_SLOT/variorum-library-keys.json) | $(wk_hold)"
  line+=" | as-found aside: $( [[ -d $WK_ASIDE ]] && print -r -- "$(ls -1 $WK_ASIDE | wc -l | tr -d ' ') files" || print -r -- none)"
  line+=" | Previous Libraries: $(ls -1 "$WK_SLOT/Previous Libraries" 2>/dev/null | tr '\n' ' ')"
  line+="| stage: $(wk_stage)"
  line+=" | files: dev-castle.env $(wk_fp $HOME/.variorum/dev-castle.env) · prod-test-accounts.env $(wk_fp $WK_ALLOW) · words-castle $(wk_fp $HOME/.variorum/prod-test-words-castle)"
  [[ ${2:-} == account ]] && line+=" | castle: $(wk_account)"
  mkdir -p $WK_EV; print -r -- $line | tee -a $WK_EV/state.log
}

# --- launches -------------------------------------------------------------------------------------------------------------
wk_find_pid() { local i; for i in {1..40}; do WK_PID=$(pgrep -f "$WK_APP/Contents/MacOS/Variorum$" | head -1); [[ -n $WK_PID ]] && return 0; sleep 0.5; done; return 1 }
wk_launch_plain() {  # the DEV lane: no VARIORUM_* key at all
  wk_zero || return 1
  $WK_REPO/Tools/WalkKit/guard.sh --author >/dev/null || { wk_stop "the author check failed before launch"; return 1 }
  WK_APPLOG=$WK_EV/app-$WK_LEG-$(date -u +%H%M%S).log
  open -n --env OS_ACTIVITY_DT_MODE=YES --stderr $WK_APPLOG $WK_APP
  wk_find_pid || { wk_stop "the walk build did not start"; return 1 }
  [[ $(ps eww -p $WK_PID | grep -c 'VARIORUM_') == 0 ]] || { wk_stop "the plain launch carries a VARIORUM_ key"; return 1 }
  wk_save; wk_log "plain launch pid $WK_PID (zero VARIORUM_ keys) — log ${WK_APPLOG:t}"
}
wk_launch_road() {   # the ACCOUNT lane: the prod test road + the handed allowlist (F-B1-1 (B)); never printed
  wk_zero || return 1
  $WK_REPO/Tools/WalkKit/guard.sh --author >/dev/null || { wk_stop "the author check failed before launch"; return 1 }
  [[ -f $WK_ALLOW && ! -L $WK_ALLOW && $(stat -f %Lp $WK_ALLOW) == 600 ]] || { wk_stop "the allowlist is not a regular mode-600 file"; return 1 }
  local list e
  list=$(set -a; source $WK_ALLOW 2>/dev/null; set +a; print -r -- "${VARIORUM_PRODTEST_EMAILS:-}")
  for e in ${=list}; do [[ $e == *vxtest* ]] || { unset list; wk_stop "an allowlist entry is unmarked"; return 1 }; done
  WK_APPLOG=$WK_EV/app-$WK_LEG-$(date -u +%H%M%S).log
  open -n --env VARIORUM_PROD_TEST_ROAD=1 --env VARIORUM_PRODTEST_EMAILS="$list" --env OS_ACTIVITY_DT_MODE=YES --stderr $WK_APPLOG $WK_APP
  unset list
  wk_find_pid || { wk_stop "the walk build did not start"; return 1 }
  local envline; envline=$(ps eww -p $WK_PID)
  [[ $envline == *"VARIORUM_PROD_TEST_ROAD=1"* && $envline == *"VARIORUM_PRODTEST_EMAILS="* && $envline != *"VARIORUM_WALK_PROJECT_URL="* ]] \
    || { unset envline; wk_stop "the road launch's environment is wrong"; return 1 }
  unset envline
  local i; for i in {1..60}; do grep -q "PROD TEST ROAD (VX-510): " $WK_APPLOG 2>/dev/null && break; sleep 1; done
  grep -q "PROD TEST ROAD (VX-510): ARMED" $WK_APPLOG || { wk_stop "the road did not arm: $(grep -o 'PROD TEST ROAD (VX-510): [A-Z]*' $WK_APPLOG | head -1)"; return 1 }
  wk_save; wk_log "road launch pid $WK_PID — PROD TEST ROAD ARMED — log ${WK_APPLOG:t}"
}
wk_quit() {  # identity-addressed (her app is a different bundle and is absent by the author check); the outcome READ
  local out
  out=$(osascript -e "tell application id \"$WK_DEBUG_ID\" to quit" 2>&1)
  wk_log "quit requested — ${out:-accepted}"
  local i; for i in {1..30}; do [[ -z $(wk_instances) ]] && { WK_PID=; wk_save; wk_log "zero instances"; return 0 }; sleep 1; done
  wk_stop "the walk instance did not quit (outcome: ${out:-none}); a sheet may hold ⌘Q — look, dismiss, quit once more; never chain a move after this"
}

# --- the GUI acts (author check first, then activate, then the act — U-VIS MAJOR-1's order) ---------------------------
wk_author()   { $WK_REPO/Tools/WalkKit/guard.sh --author >/dev/null || wk_stop "the author check failed (her app, or someone at the machine) — never retried" }
wk_activate() { osascript -e "tell application \"System Events\" to set frontmost of (first application process whose unix id is $WK_PID) to true" >/dev/null; sleep 0.4 }
wk_press() {  # <label> [role] — an AX press addressed to OUR pid
  wk_author || return 1; wk_activate; sleep $WK_GAP
  $WK_BIN/vis-ax $WK_PID "$1" ${2:--} press >/dev/null || { wk_stop "no control labelled '$1' on screen"; return 1 }
  wk_log "pressed '$1'"
}
wk_focus() {  # <label> [role] — click the field's centre (role default AXTextField; SecureField reports AXTextField too)
  wk_author || return 1; wk_activate
  local f; f=($($WK_BIN/vis-ax $WK_PID "$1" ${2:-AXTextField} 2>/dev/null)) || { wk_stop "no field labelled '$1' on screen"; return 1 }
  $WK_BIN/vis-foreign $WK_PID $(( ${f[1]%.*} + ${f[3]%.*} / 2 )) $(( ${f[2]%.*} + ${f[4]%.*} / 2 )) >/dev/null \
    || { wk_stop "a foreign window covers the field '$1' — the author's to answer"; return 1 }
  cliclick c:$(( ${f[1]%.*} + ${f[3]%.*} / 2 )),$(( ${f[2]%.*} + ${f[4]%.*} / 2 )); sleep $WK_GAP
  wk_log "focused '$1'"
}
wk_dev_secret()  { wk_author || return 1; wk_activate; $WK_DEVHELP "$1" >/dev/null  || { wk_stop "type-dev-castle-secret refused '$1'"; return 1 }; wk_log "typed the dev pair's $1 (never printed)"; sleep $WK_GAP }
wk_prod_secret() { wk_author || return 1; wk_activate; $WK_PRODHELP castle "$1" >/dev/null || { wk_stop "type-prod-test-secret refused castle '$1'"; return 1 }; wk_log "typed castle's $1 (never printed)"; sleep $WK_GAP }
wk_keys()  { $WK_REPO/Tools/WalkKit/keys.sh $WK_PID "$@" >/dev/null || { wk_stop "keys.sh refused (the guard)"; return 1 }; sleep $WK_GAP }
wk_type_text() { wk_keys "keystroke \"$1\"" }      # NON-secret text only (note bodies); secrets go through the helpers
wk_enter()     { wk_keys "key code 36" }           # SwiftUI onSubmit needs key code 36
wk_waitfor() { local i; for i in $(seq 1 ${2:-20}); do $WK_BIN/vis-ax $WK_PID "$1" >/dev/null 2>&1 && return 0; sleep 1; done; return 1 }
wk_waitfor_prefix() { local i; for i in $(seq 1 ${2:-20}); do VIS_AX_PREFIX=1 $WK_BIN/vis-ax $WK_PID "$1" >/dev/null 2>&1 && return 0; sleep 1; done; return 1 }
wk_capture() {  # <tag> — every layer-0 window of the pid, into its own folder; the words guard first
  local g dir
  g=$($WK_BIN/words-guard $WK_PID 2>/dev/null) || { wk_log "capture '$1' WITHHELD — $g"; return 0 }
  dir=$WK_EV/$(date -u +%H%M%S)-$WK_LEG-$1; mkdir -p $dir
  $WK_BIN/walk-cap $WK_PID $dir > $dir/windows.txt 2>&1
  wk_log "captured '$1' → ${dir:t} ($(tail -1 $dir/windows.txt))"
}
wk_road() { [[ -n $WK_APPLOG ]] && grep -E "road:|enroll:|make_mine:|change_passphrase:|enter_castle:|follow:|backup pair:|heal:" $WK_APPLOG | tail -${1:-8} }

# --- W0: the baselines BEFORE step 0 (ruling 3 -- E0) and the safe copy (ruling 2) --------------------------------------
wk_baseline_e0() {
  wk_zero || return 1
  mkdir -p $WK_EV
  [[ ! -e $WK_EV/prefs-E0.plist ]] || { wk_stop "prefs-E0 already exists -- a re-take is E0' (rename the old one first)"; return 1 }
  defaults export $WK_DEBUG_ID $WK_EV/prefs-E0.plist || { wk_stop "defaults export failed"; return 1 }
  wk_inventory $WK_SLOT > $WK_EV/slot-E0.txt
  { print -r -- "## Previous Libraries"; ls -1 "$WK_SLOT/Previous Libraries"; print -r -- "## Backups"; ls -1 $WK_SLOT/Backups
    print -r -- "## picked folder"; ls -1 $WK_PICKED 2>/dev/null } > $WK_EV/places-E0.txt
  [[ $(wk_persistent $WK_SLOT | wc -l | tr -d ' ') == 7 ]] || { wk_stop "the slot does not hold the seven persistent files"; return 1 }
  wk_log "E0 taken: prefs, the slot's $(wc -l < $WK_EV/slot-E0.txt | tr -d ' ') files, the places listing"
}
wk_safecopy() {  # the nine as-found files, at rest, into safety-copies/<UTC name>; every digest compared
  wk_zero || return 1
  local dest="$WK_SLOT/Backups/safety-copies/vx502-walk-asfound-$(date -u +%Y-%m-%dT%H%M%SZ)" f bad=0
  [[ ! -e $dest ]] || { wk_stop "${dest:t} exists"; return 1 }
  mkdir -p $dest || return 1
  for f in ${WK_SLOT}/*(N.); do cp -p $f $dest/ || { wk_stop "copy failed for ${f:t}"; return 1 }; done
  for f in ${WK_SLOT}/*(N.); do [[ $(shasum -a 256 < $f) == $(shasum -a 256 < $dest/${f:t}) ]] || bad=1; done
  (( bad == 0 )) || { wk_stop "a safe-copy digest differs"; return 1 }
  print -r -- $dest > $WK_EV/safecopy-path.txt
  wk_log "W0 safe copy: $(ls -1 $dest | wc -l | tr -d ' ') files, digests identical -> safety-copies/${dest:t}"
}

# --- the slot moves (zero instances proven FIRST, as their own step; never chained after a quit) -------------------------
wk_aside_asfound() {  # leg 2 (B'): every top-level FILE of the slot → $WK_ASIDE, same volume, inodes proven identical
  wk_zero || return 1
  [[ ! -e $WK_ASIDE ]] || { wk_stop "$WK_ASIDE already exists — never merge into it"; return 1 }
  local before after f
  before=$(wk_inodes $WK_SLOT); [[ -n $before ]] || { wk_stop "the slot holds no top-level files"; return 1 }
  print -r -- $before > $WK_EV/asfound-inodes.txt
  mkdir $WK_ASIDE || return 1
  for f in ${WK_SLOT}/*(N.); do mv -n $f $WK_ASIDE/ || { wk_stop "mv failed for ${f:t} — the set is PARTIAL; do not launch"; return 1 }; done
  after=$(wk_inodes $WK_ASIDE)
  [[ $after == $before ]] || { wk_stop "inodes differ after the aside"; return 1 }
  [[ -z $(wk_inodes $WK_SLOT) ]] || { wk_stop "the slot still holds files"; return 1 }
  [[ $(wk_persistent $WK_ASIDE) == $(wk_persistent_e0) ]] || { wk_stop "the seven persistent files' inodes differ from W0's list"; return 1 }
  wk_log "the as-found set aside WHOLE ($(print -r -- $before | wc -l | tr -d ' ') files, inodes identical) → ${WK_ASIDE:t}"
}
wk_aside_walklib() {  # <suffix> — whatever occupies the slot goes WHOLE into a NEW walk-owned folder (never merged)
  wk_zero || return 1
  local dest="$WK_SUPPORT/Variorum-dev-aside-vx502-$1" before after f
  [[ ! -e $dest ]] || { wk_stop "${dest:t} already exists — never merge into it"; return 1 }
  before=$(wk_inodes $WK_SLOT); mkdir $dest || return 1
  for f in ${WK_SLOT}/*(N.); do mv -n $f $dest/ || { wk_stop "mv failed for ${f:t}"; return 1 }; done
  after=$(wk_inodes $dest)
  [[ $after == $before && -z $(wk_inodes $WK_SLOT) ]] || { wk_stop "the walk set did not move whole"; return 1 }
  wk_log "the slot's walk library set aside WHOLE → ${dest:t}: $(wk_keyfile_id $dest/variorum-library-keys.json)"
}
wk_return_asfound() {  # leg 11: the as-found set back by a same-volume mv, inodes = the recorded list
  wk_zero || return 1
  [[ -z $(wk_inodes $WK_SLOT) ]] || { wk_stop "the slot is not empty — set its occupant aside first"; return 1 }
  local f
  for f in ${WK_ASIDE}/*(N.); do mv -n $f $WK_SLOT/ || { wk_stop "mv failed for ${f:t} — PARTIAL; do not launch"; return 1 }; done
  rmdir $WK_ASIDE || { wk_stop "the aside folder is not empty after the return"; return 1 }
  # The binding check (ruling 1): the SEVEN persistent files' inodes = W0's list; the WAL/SHM present as at the aside.
  [[ $(wk_persistent $WK_SLOT) == $(wk_persistent_e0) ]] || { wk_stop "the seven persistent files' inodes differ from W0's list"; return 1 }
  local w; for w in variorum.sqlite-wal variorum.sqlite-shm; do
    if grep -q "^$w@" $WK_EV/asfound-inodes.txt; then [[ -f $WK_SLOT/$w ]] || { wk_stop "$w was aside but is not back"; return 1 }; fi
  done
  wk_log "the as-found set returned WHOLE -- the seven persistent inodes = W0's; WAL/SHM present as at the aside"
}
