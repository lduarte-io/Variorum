#!/bin/zsh
# Tools/VisualWalk/visual-walk.sh — the OPT-IN visual regression harness (18l U-VIS).
#
#   VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh [--build] [--voices terminal,study]
#                                                          [--only name,name] [--selftest] [--list]
#
# Drives its OWN dev-store Debug build (io.lduarte.Variorum.debug, launched with the DEBUG oracle
# endpoint on) through the seeded scenarios in scenarios.zsh, asserting MEASURED GEOMETRY read from
# the app itself; captures + a per-scenario PASS/FAIL report land in notes/plans/vis-walks/<date>/.
# Exit: 0 no FAIL / ERROR (XFAIL and XPASS are reported, never red — an XPASS is flagged loudly in the
# report: a known issue did not reproduce) · 1 a FAIL or ERROR · 4 aborted (a guard fired; nothing
# further was touched) · 5 refused (a precondition). README.md says what each scenario asserts.

emulate -L zsh
setopt pipe_fail
source ${0:A:h}/lib.zsh
source ${0:A:h}/scenarios.zsh

VW_VOICES=current VW_SELECTED= VW_SELFTEST= VW_BUILD=
while (( $# )); do
  case $1 in
    --build) VW_BUILD=1 ;;
    --voices) VW_VOICES=$2; shift ;;
    --only) VW_SELECTED=$2; shift ;;
    --selftest) VW_SELFTEST=1 ;;
    --list) for n in $SCN_ORDER selftest-red; do print "$n — ${SCN_TABLE[$n]}"; done; exit 0 ;;
    *) print -u2 "unknown argument: $1"; exit 5 ;;
  esac
  shift
done

refuse() { print -u2 "visual-walk REFUSES: $*"; exit 5 }

# --- Preconditions (loud; the harness drives the real GUI) ---------------------------------------------
[[ ${VARIORUM_VISUAL_WALK:-} == 1 ]] || refuse "set VARIORUM_VISUAL_WALK=1 — this drives the real window (opt-in only, never a default run)"
pgrep -f '/Applications/Variorum.app/Contents/MacOS' >/dev/null && refuse "her app is running — never drive the GUI while it lives"
[[ -z $(vw_instances) ]] || refuse "another Variorum instance is running (quit it first): $(vw_instances | tr '\n' ' ')"
command -v cliclick >/dev/null || refuse "cliclick is not installed"
mkdir -p $VW_BIN
for h in vis-probe vis-win vis-foreign vis-ax vis-tcc; do
  [[ $VW_BIN/$h -nt $VW_ROOT/helpers/$h.swift ]] || swiftc -O -o $VW_BIN/$h $VW_ROOT/helpers/$h.swift 2>/dev/null \
    || refuse "cannot compile helpers/$h.swift"
done
[[ $VW_BIN/walk-scroll -nt $WK/scroll.swift ]] || swiftc -O -o $VW_BIN/walk-scroll $WK/scroll.swift || refuse "cannot compile WalkKit's scroll.swift"
[[ $WK/wl2 -nt $WK/wl2.swift ]] || swiftc -O -o $WK/wl2 $WK/wl2.swift || refuse "cannot compile WalkKit's wl2 (guard.sh needs it)"
# The grants (checked, never prompted — MINOR-6): Accessibility, Screen Recording, and the Automation
# grant for System Events, which every act and every guard speaks to (launched first: a target must
# run to be asked; launching sends no Apple Event).
open -g -b com.apple.systemevents; sleep 1
tcc=$(vw_timeout 15 $VW_BIN/vis-tcc com.apple.systemevents)
[[ ${${(f)tcc}[1]} == "AX 1 SCREEN 1" ]] || refuse "this terminal lacks Accessibility / Screen Recording (${${(f)tcc}[1]}) — granting is the author's"
[[ $tcc == *"AE:com.apple.systemevents granted"* ]] || refuse "no standing Automation grant for System Events (${${(f)tcc}[2]:-the check timed out — a consent prompt pending?}) — the first act would mint a consent prompt; granting is the author's"
foreign=$($VW_BIN/vis-foreign 0)
[[ -n $foreign ]] && print -u2 "NOTE: system dialog(s) on screen — the harness will never click or type into them: $foreign"

if [[ -n $VW_BUILD ]]; then
  [[ -n ${VW_DD:-} ]] && refuse "--build builds THIS tree into the default folder; a VW_DD scratch build is made with build.sh --src <tree> --dd <dir>"
  $VW_ROOT/build.sh || refuse "the Debug build failed ($DD.build.log)"
fi
[[ -d $APP ]] || refuse "no Debug build at $APP — run with --build"

# The build under test must be THIS tree's (MINOR-3/4): stamped, and a VW_DD scratch build may differ
# only under App/ — its core is what opens the dev store.
typeset -g BUILD_STAMP=$(cat $DD/vis-walk.stamp 2>/dev/null) VW_SCRATCH=${VW_DD:+1}
verdict=$(vw_stamp_verdict "$BUILD_STAMP" "$(vw_tree_state $REPO)" ${VW_SCRATCH:-0}) || refuse "$verdict"

typeset -a run_list
if [[ -n $VW_SELFTEST ]]; then run_list=(selftest-red)
elif [[ -n $VW_SELECTED ]]; then run_list=(${(s:,:)VW_SELECTED})
else run_list=($SCN_ORDER); fi
for n in $run_list; do (( $+functions[scn_$n] )) || refuse "no scenario named $n (--list)"; done

# Author-free: 10 s without input (the command that launched us counts — so wait up to a minute).
for i in {1..12}; do
  idle=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}')
  (( idle >= 10 )) && break
  (( i == 1 )) && print -u2 "waiting for 10 s without input (HID idle ${idle}s) …"
  sleep 5
done
(( idle >= 10 )) || refuse "HID idle ${idle}s after a minute — someone is at the machine (the harness needs it author-free)"

# --- The run --------------------------------------------------------------------------------------------
RUN_DIR=$REPO/notes/plans/vis-walks/$(strftime %Y-%m-%d $EPOCHSECONDS)/$(strftime %H%M%S $EPOCHSECONDS)$([[ -n $VW_SELFTEST ]] && print -- -selftest)
mkdir -p $RUN_DIR
vw_selfcheck
# Ctrl-C is the author at the machine: stop, quit the app, name what is owed — touch nothing else.
trap 'vw_abort "interrupted (SIGINT) — the author is at the machine"' INT
trap 'vw_abort "terminated (SIGTERM)"' TERM
[[ -n $foreign ]] && print -r -- "System dialog(s) on screen at start (never touched): $foreign" > $RUN_DIR/foreign.txt
vw_log "run $RUN_DIR — voices: $VW_VOICES"


VOICE=setup; vw_launch
FOUND_VOICE=${PV[voice]}
print -r -- $FOUND_VOICE > $RUN_DIR/voice-found
typeset -a voices
[[ $VW_VOICES == current ]] && voices=($FOUND_VOICE) || voices=(${(s:,:)VW_VOICES})
vw_log "found voice: $FOUND_VOICE; passes: $voices"

for VOICE in $voices; do
  # A pass is a FRESH app run in its voice: every note's first open happens inside the pass (R-18l-1).
  vw_probe
  if [[ ${PV[voice]} != $VOICE ]]; then vw_set_voice $VOICE; fi
  vw_quit_app; sleep 2; vw_launch
  vw_probe
  [[ ${PV[voice]} == $VOICE ]] || vw_abort "the fresh launch speaks ${PV[voice]}, not $VOICE"
  for n in $run_list; do
    vw_scenario_begin $n
    scn_$n
    vw_scenario_end
    vw_report
  done
done

if [[ $VOICE != $FOUND_VOICE ]]; then
  VOICE=restore; vw_probe
  [[ ${PV[voice]} != $FOUND_VOICE ]] && vw_set_voice $FOUND_VOICE
  vw_log "voice restored to $FOUND_VOICE"
fi
vw_quit_app
vw_report
print -u2 "\nreport: $RUN_DIR/report.md"
column -t -s $'\t' $RUN_DIR/report.tsv >&2
(( RUN_FAILS + RUN_ERRORS )) && exit 1
exit 0
