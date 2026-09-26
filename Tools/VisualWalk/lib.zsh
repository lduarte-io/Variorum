# Tools/VisualWalk/lib.zsh — the harness's machinery (sourced by visual-walk.sh).
#
# Everything a scenario does goes through here: the per-step GUARD (WalkKit's
# guard.sh, consumed in place — one guard, one home), the ACTS (cliclick /
# System Events through WalkKit's click.sh / keys.sh), the PROBE (the app's
# DEBUG oracle endpoint, `VisualWalkProbe.swift`), the CAPTURES, and the
# ASSERTIONS that write the report. Assertions read MEASURED GEOMETRY from the
# probe — never pixels; the captures are evidence beside the numbers.

zmodload zsh/mathfunc
zmodload zsh/datetime

typeset -g VW_ROOT=${${(%):-%x}:A:h}
typeset -g REPO=${VW_ROOT:h:h}
typeset -g WK=$REPO/Tools/WalkKit
typeset -g VW_BIN=$VW_ROOT/bin
typeset -g DD=$REPO/App/Variorum/DerivedData/vis-walk
typeset -g APP=$DD/Build/Products/Debug/Variorum.app
typeset -g APP_PATTERN='DerivedData/vis-walk/Build/Products/Debug/Variorum.app/Contents/MacOS'
typeset -g PID= WID=
typeset -gi PROBE_ID=0
typeset -gA PV            # the last probe's values
typeset -g PV_LINE=
typeset -gA SNAP          # named snapshots: SNAP[<name>.<key>]
typeset -g RUN_DIR= SCN= SCN_DIR= VOICE=
typeset -ga SCN_ROWS      # the current scenario's assertion rows (TSV)
typeset -ga SCN_ACTS      # the current scenario's act log
typeset -g SCN_STATUS= SCN_NOTE=
typeset -ga RUN_SUMMARY   # one TSV row per scenario
typeset -gi RUN_FAILS=0 RUN_ERRORS=0 RUN_XPASS=0
typeset -g STEP_GAP=${VW_STEP_GAP:-2.6}   # >= 2.5 s: guard.sh fires on the walker's own input

vw_log() { print -r -- "[$(strftime %H:%M:%S $EPOCHSECONDS)] $*" | tee -a $RUN_DIR/run.log >&2 }

# --- Abort (the guard fired, or the harness cannot go on) -------------------------------------------
vw_abort() {
  vw_log "ABORT: $*"
  print -r -- "ABORTED: $*" >> $RUN_DIR/aborted
  [[ -n $SCN ]] && { SCN_STATUS=ERROR; SCN_NOTE="aborted: $*"; vw_scenario_end }
  vw_report
  vw_quit_app
  exit 4
}

# --- The app (its OWN dev-store Debug build, launched with the probe on) ----------------------------
vw_instances() { pgrep -fl 'Variorum.app/Contents/MacOS' }

vw_launch() {
  [[ -d $APP ]] || vw_abort "no Debug build at $APP (run with --build)"
  if pgrep -f '/Applications/Variorum.app/Contents/MacOS' >/dev/null; then vw_abort "her app is running — STOP"; fi
  if [[ -n $(vw_instances) ]]; then vw_abort "another Variorum instance is running: $(vw_instances | tr '\n' ' ')"; fi
  open -n --env VARIORUM_VISUAL_WALK=1 $APP
  local i
  for i in {1..40}; do PID=$(pgrep -f $APP_PATTERN | head -1); [[ -n $PID ]] && break; sleep 0.5; done
  [[ -n $PID ]] || vw_abort "the dev app did not start"
  for i in {1..40}; do
    vw_probe_raw && [[ ${PV[win]} != none && -n ${PV[win]} ]] && break
    sleep 0.5
  done
  [[ ${PV[win]} != none && -n ${PV[win]} ]] || vw_abort "the probe never answered (is the build DEBUG, launched with VARIORUM_VISUAL_WALK=1?)"
  sleep 2
  vw_window
  vw_log "launched pid $PID, window $WID (${WIN_X},${WIN_Y} ${WIN_W}x${WIN_H})"
}

vw_window() {
  local w; w=($($VW_BIN/vis-win $PID))
  [[ $w[1] == none ]] && vw_abort "the dev window is not on screen"
  WID=$w[1] WIN_X=$w[2] WIN_Y=$w[3] WIN_W=$w[4] WIN_H=$w[5]
}

vw_quit_app() {
  [[ -z $PID ]] && return
  kill -0 $PID 2>/dev/null || { PID=; return }
  # Quit by identity only when ours is the ONLY dev instance (the UNIT D/E rule), else by PID.
  if [[ $(pgrep -f 'Variorum.app/Contents/MacOS' | wc -l | tr -d ' ') == 1 ]]; then
    osascript -e 'with timeout of 20 seconds' -e 'tell application id "io.lduarte.Variorum.debug" to quit' -e 'end timeout' >/dev/null 2>&1
  else
    kill -TERM $PID
  fi
  local i; for i in {1..30}; do kill -0 $PID 2>/dev/null || break; sleep 0.5; done
  kill -0 $PID 2>/dev/null && { vw_log "quit did not finish — TERM by pid"; kill -TERM $PID; sleep 2 }
  vw_log "quit pid $PID; instances now: $(vw_instances | wc -l | tr -d ' ')"
  PID=
}

# --- The probe ---------------------------------------------------------------------------------------
vw_probe_raw() {   # [flags…] → PV / PV_LINE; non-zero on timeout
  (( PROBE_ID++ ))
  local out
  out=$(VIS_PROBE_TIMEOUT=${VIS_PROBE_TIMEOUT:-3} $VW_BIN/vis-probe $PROBE_ID "$@") || { PV=(); PV_LINE=$out; return 1 }
  PV_LINE=$out
  PV=()
  local tok
  for tok in ${(z)out}; do [[ $tok == *=* ]] && PV[${tok%%=*}]=${tok#*=}; done
  [[ -n $RUN_DIR ]] && print -r -- "$out" >> $RUN_DIR/probes.log
  return 0
}

vw_probe() { vw_probe_raw "$@" || vw_abort "probe timed out (${PV_LINE})" }

# Settle: probe until two consecutive answers agree (ids aside) — the app's hops,
# landings and TK2 settles have run. Only for probes that lay nothing out.
vw_settle() {   # [flags…]
  local prev= cur= i
  sleep ${VW_SETTLE_FIRST:-0.6}
  for i in {1..20}; do
    vw_probe "$@"
    cur=${PV_LINE#vis id=* }
    [[ $cur == $prev ]] && return 0
    prev=$cur
    sleep 0.35
  done
  vw_log "settle: still moving after 20 probes — using the last answer"
  return 0
}

vw_snap() { local k; for k in ${(k)PV}; do SNAP[$1.$k]=${PV[$k]}; done; SNAP[$1._line]=$PV_LINE }
vw_get() { print -r -- ${SNAP[$1.$2]} }

# rect "x,y,w,h" → the four numbers
vw_rect() { print -r -- ${(s:,:)1} }

# --- The acts (every GUI act: the step gap, then WalkKit's guard, then the act) ------------------------
vw_guarded() {   # <guard args…> — retries a transient guard (idle / focus) twice, never her app
  local rc tries=0
  while true; do
    $WK/guard.sh $PID "$@" >> $RUN_DIR/run.log 2>&1; rc=$?
    (( rc == 0 )) && return 0
    (( rc == 3 )) && vw_abort "guard: her app is running — STOP (no retry)"
    (( ++tries > 2 )) && vw_abort "guard refused $tries times (exit $rc — see run.log)"
    vw_log "guard exit $rc — waiting 5 s, then re-activating (try $tries)"
    sleep 5
    vw_activate
  done
}

vw_activate() {
  osascript -e "tell application \"System Events\" to set frontmost of (first application process whose unix id is $PID) to true" >/dev/null 2>&1
  sleep 0.4
}

vw_act_note() { SCN_ACTS+=("$*"); vw_log "act: $*" }

# The FOREIGN-DIALOG rule (added 2026-09-26 — a stale "Ghostty wants access to control Finder"
# consent prompt, left by an earlier walk's osascript, sat over the dev window; a walk click landed on
# it and it took keyboard focus, so a ⏎ would have pressed Allow — a TCC decision that is hers alone):
# never click a point a system dialog covers, and never type unless OUR window is key (the probe says).
vw_no_foreign_at() {   # x y
  local covering
  covering=$($VW_BIN/vis-foreign $PID $1 $2) && return 0
  vw_abort "a system dialog covers ($1,$2): $covering — never click it (it is the author's to answer)"
}

vw_our_window_is_key() {
  vw_probe
  [[ ${PV[key]} == 1 ]] && return 0
  vw_abort "our window is not key — a keystroke could reach another window (a system dialog?): $($VW_BIN/vis-foreign $PID | tr '\n' ';')"
}

vw_click() {   # x y [label]
  local x=${1%.*} y=${2%.*}
  vw_act_note "click ($x,$y) ${3:-}"
  sleep $STEP_GAP; vw_activate; vw_guarded $x $y
  vw_no_foreign_at $x $y
  vw_probe
  if [[ ${PV[key]} != 1 ]]; then
    # A click into a window that is not key can be swallowed by the activation (the WalkKit fact):
    # give our window key first, on its own titlebar, at a point no dialog covers.
    local ty=$(( WIN_Y + 18 ))
    vw_free_x $(( WIN_X + WIN_W - 420 )) $(( WIN_X + WIN_W - 120 )) $ty
    vw_log "our window is not key — refocusing on its titlebar ($FREE_X,$ty)"
    cliclick c:$FREE_X,$ty; sleep 0.6
  fi
  cliclick c:$x,$y
}

vw_keys() {    # label, then System Events statements
  local label=$1; shift
  vw_act_note "keys: $label"
  sleep $STEP_GAP; vw_activate; vw_guarded
  vw_our_window_is_key
  local -a args=(-e 'tell application "System Events"')
  local st; for st in "$@"; do args+=(-e "$st"); done
  args+=(-e 'end tell')
  osascript "${args[@]}" >/dev/null
}

# A control pressed by its accessibility LABEL (AXPress — no screen point, so no dialog can be hit;
# SwiftUI Settings controls answer only this). Guarded like every GUI act.
vw_ax_press() {  # label [role]
  vw_act_note "AX press: $1"
  sleep $STEP_GAP; vw_activate; vw_guarded
  $VW_BIN/vis-ax $PID "$1" ${2:--} press >> $RUN_DIR/run.log
}

vw_scroll() {  # x y lines (positive = down)
  local x=${1%.*} y=${2%.*}
  vw_act_note "scroll $3 lines at ($x,$y)"
  sleep $STEP_GAP; vw_activate; vw_guarded $x $y
  vw_no_foreign_at $x $y
  $VW_BIN/walk-scroll $x $y $3 >/dev/null
}

vw_resize() {  # width height — the non-live road (AX set size)
  vw_act_note "resize window to $1x$2"
  sleep $STEP_GAP; vw_activate; vw_guarded
  osascript -e "tell application \"System Events\" to set size of window 1 of (first application process whose unix id is $PID) to {$1, $2}" >/dev/null
  vw_window
}

vw_open_note() {   # title — ⌘K, type, ⏎ (the reliable navigation road)
  vw_keys "⌘K" 'keystroke "k" using command down'
  vw_keys "type: $1" "keystroke \"$1\""
  sleep 0.8
  vw_keys "⏎" 'key code 36'
  vw_settle
}

# FREE_X := an x in [lo, hi] that no system dialog covers at y (fractions tried in order). Sets a
# global rather than printing — an abort inside $(…) would end only the subshell, never the run.
typeset -g FREE_X=
vw_free_x() {   # lo hi y
  local f x
  for f in 0.3 0.5 0.7 0.85 0.15; do
    x=$(printf '%.0f' $(( $1 + ($2 - $1) * f )))
    $VW_BIN/vis-foreign $PID $x ${3%.*} >/dev/null && { FREE_X=$x; return 0 }
  done
  vw_abort "every click point on y=$3 between $1 and $2 is under a system dialog"
}

# --- Captures (evidence beside the numbers) ----------------------------------------------------------
vw_cap() {     # name
  vw_window
  screencapture -x -o -l $WID $SCN_DIR/$1.png 2>>$RUN_DIR/run.log || vw_log "capture $1 failed"
}

# --- Assertions --------------------------------------------------------------------------------------
# Every assertion is one row: status · label · measured · expected · tolerance · known.
# `known` names an OWNED KnownIssues row: a failure is then XFAIL (reported, not red), and a pass is
# XPASS (loud — the known issue did not reproduce; re-examine the row).
vw_row() {   # pass(0/1) label measured expected tol known
  local st
  if [[ -n $6 ]]; then st=$([[ $1 == 1 ]] && print XPASS || print XFAIL)
  else st=$([[ $1 == 1 ]] && print PASS || print FAIL); fi
  SCN_ROWS+=("$st	$2	$3	$4	$5	$6")
  vw_log "  $st  $2  measured=$3 expected=$4 tol=$5 ${6:+known=$6}"
}

vw_expect_near() {   # label measured expected tol [known]
  local m=$2 e=$3 t=$4
  if [[ -z $m || -z $e || $m == - || $e == - ]]; then vw_row 0 "$1" "${m:-∅}" "${e:-∅}" "$t" "$5"; return; fi
  local ok=0; (( abs(m - e) <= t )) && ok=1
  vw_row $ok "$1" "$m" "$e" "±$t" "$5"
}

vw_expect_eq() {     # label measured expected [known]
  local ok=0; [[ $2 == $3 ]] && ok=1
  vw_row $ok "$1" "${2:-∅}" "${3:-∅}" "=" "$4"
}

vw_expect_ne() {     # label measured forbidden [known]
  local ok=0; [[ $2 != $3 ]] && ok=1
  vw_row $ok "$1" "${2:-∅}" "≠$3" "≠" "$4"
}

vw_expect_between() { # label value lo hi [known]
  local v=$2 ok=0
  [[ -n $v ]] && (( v >= $3 && v <= $4 )) && ok=1
  vw_row $ok "$1" "${v:-∅}" "[$3, $4]" "∈" "$5"
}

vw_require() {       # condition-string message — a FIXTURE/harness precondition, not the product
  if ! eval "$1"; then
    SCN_NOTE="precondition failed: $2 (${PV_LINE})"
    vw_log "  ERROR  precondition: $2"
    SCN_STATUS=ERROR
    return 1
  fi
  return 0
}

# --- Scenario frame + report ------------------------------------------------------------------------
vw_scenario_begin() {   # name
  SCN=$1; SCN_DIR=$RUN_DIR/$VOICE/$SCN; mkdir -p $SCN_DIR
  SCN_ROWS=(); SCN_ACTS=(); SCN_STATUS=; SCN_NOTE=
  vw_log "=== scenario $SCN ($VOICE)"
}

vw_scenario_end() {
  local row st fails=0 xfail=0 xpass=0 passes=0
  for row in $SCN_ROWS; do
    st=${row%%	*}
    case $st in FAIL) (( fails++ ));; XFAIL) (( xfail++ ));; XPASS) (( xpass++ ));; PASS) (( passes++ ));; esac
  done
  if [[ $SCN_STATUS != ERROR ]]; then
    if (( fails )); then SCN_STATUS=FAIL
    elif (( xpass )); then SCN_STATUS=XPASS
    elif (( xfail )); then SCN_STATUS=XFAIL
    elif (( passes )); then SCN_STATUS=PASS
    else SCN_STATUS=ERROR; SCN_NOTE=${SCN_NOTE:-"no assertion ran"}; fi
  fi
  case $SCN_STATUS in FAIL) (( RUN_FAILS++ ));; ERROR) (( RUN_ERRORS++ ));; XPASS) (( RUN_XPASS++ ));; esac
  {
    print -r -- "### $SCN — $VOICE — **$SCN_STATUS**"
    print -r -- ""
    [[ -n ${SCN_TABLE[$SCN]} ]] && print -r -- "*${SCN_TABLE[$SCN]}*" && print -r -- ""
    [[ -n $SCN_NOTE ]] && print -r -- "Note: $SCN_NOTE" && print -r -- ""
    print -r -- "Acts: ${(j: → :)SCN_ACTS}"
    print -r -- ""
    print -r -- "| status | assertion | measured | expected | tol | known |"
    print -r -- "|---|---|---|---|---|---|"
    for row in $SCN_ROWS; do print -r -- "| ${row//	/ | } |"; done
    print -r -- ""
    print -r -- "Captures: $(cd $SCN_DIR && ls *.png 2>/dev/null | tr '\n' ' ')"
    print -r -- ""
  } >> $RUN_DIR/details.md
  RUN_SUMMARY+=("$SCN	$VOICE	$SCN_STATUS	${#SCN_ROWS}	$fails	$xfail	$xpass	$SCN_NOTE")
  vw_log "=== $SCN ($VOICE): $SCN_STATUS"
  SCN=
}

vw_report() {
  local r=$RUN_DIR/report.md row
  {
    print -r -- "# Visual walk — $(basename $RUN_DIR)"
    print -r -- ""
    print -r -- "- tree: \`$(git -C $REPO rev-parse --short HEAD)\`$(git -C $REPO diff --quiet HEAD -- App || print ' (App/ has uncommitted changes)')"
    print -r -- "- macOS $(sw_vers -productVersion) ($(sw_vers -buildVersion)) · build \`${APP#$REPO/}\`"
    print -r -- "- voices: ${VW_VOICES:-current} · scenarios: ${VW_SELECTED:-all}${VW_SELFTEST:+ · SELF-TEST}"
    print -r -- "- result: **$(( RUN_FAILS + RUN_ERRORS )) failing** (FAIL $RUN_FAILS · ERROR $RUN_ERRORS) · XPASS $RUN_XPASS"
    [[ -f $RUN_DIR/aborted ]] && print -r -- "- **$(cat $RUN_DIR/aborted)**"
    print -r -- ""
    print -r -- "| scenario | voice | status | assertions | FAIL | XFAIL | XPASS | note |"
    print -r -- "|---|---|---|---|---|---|---|---|"
    for row in $RUN_SUMMARY; do print -r -- "| ${row//	/ | } |"; done
    print -r -- ""
    print -r -- "Status: PASS · FAIL (a regression — red) · XFAIL (an OWNED known issue reproduced, labelled) ·"
    print -r -- "XPASS (a known issue did NOT reproduce — re-examine its row) · ERROR (fixture/harness — red)."
    print -r -- ""
    print -r -- "## Details"
    print -r -- ""
    [[ -f $RUN_DIR/details.md ]] && cat $RUN_DIR/details.md
  } > $r
  print -l -- $RUN_SUMMARY > $RUN_DIR/report.tsv
}

# The comparator's own teeth, checked before any GUI act: a knowingly-wrong expectation must red.
vw_selfcheck() {
  local saved=("${SCN_ROWS[@]}")
  SCN_ROWS=()
  vw_expect_near "selfcheck: 10 vs 50" 10 50 1 >/dev/null 2>&1
  vw_expect_eq "selfcheck: a vs b" a b >/dev/null 2>&1
  local bad=0 row; for row in $SCN_ROWS; do [[ ${row%%	*} == FAIL ]] && (( bad++ )); done
  SCN_ROWS=("${saved[@]}")
  (( bad == 2 )) || { print "SELFCHECK: the comparator cannot red — refusing to run" >&2; exit 5 }
}
