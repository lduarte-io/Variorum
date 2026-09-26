#!/bin/zsh
# Tools/VisualWalk/visual-walk.sh — the OPT-IN visual regression harness (18l U-VIS).
#
#   VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh [--build] [--voices terminal,study]
#                                                          [--only name,name] [--selftest] [--list]
#
# Drives its OWN dev-store Debug build (io.lduarte.Variorum.debug, launched with the DEBUG oracle
# endpoint on) through the seeded scenarios in scenarios.zsh, asserting MEASURED GEOMETRY read from
# the app itself; captures + a per-scenario PASS/FAIL report land in notes/plans/vis-walks/<date>/.
# Exit: 0 all pass (XFAIL allowed) · 1 a FAIL or ERROR · 3 only XPASS (a known issue did not
# reproduce — re-examine its row) · 4 aborted (a guard fired; nothing further was touched) ·
# 5 refused (a precondition). README.md beside this file says what each scenario asserts.

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
tcc=$($VW_BIN/vis-tcc)
[[ $tcc == "AX 1 SCREEN 1" ]] || refuse "this terminal lacks Accessibility / Screen Recording ($tcc) — granting is the author's"
idle=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}')
(( idle >= 10 )) || refuse "HID idle ${idle}s — someone is at the machine (the harness needs it author-free)"
foreign=$($VW_BIN/vis-foreign 0)
[[ -n $foreign ]] && print -u2 "NOTE: system dialog(s) on screen — the harness will never click or type into them: $foreign"

if [[ -n $VW_BUILD ]]; then
  print -u2 "building the Debug app into $DD …"
  (cd $REPO/App/Variorum && xcodebuild -scheme Variorum -configuration Debug -destination 'platform=macOS' \
     -derivedDataPath $DD build > $DD.build.log 2>&1) || refuse "the Debug build failed ($DD.build.log)"
fi
[[ -d $APP ]] || refuse "no Debug build at $APP — run with --build"

# --- The run --------------------------------------------------------------------------------------------
RUN_DIR=$REPO/notes/plans/vis-walks/$(strftime %Y-%m-%d $EPOCHSECONDS)/$(strftime %H%M%S $EPOCHSECONDS)$([[ -n $VW_SELFTEST ]] && print -- -selftest)
mkdir -p $RUN_DIR
vw_selfcheck
[[ -n $foreign ]] && print -r -- "System dialog(s) on screen at start (never touched): $foreign" > $RUN_DIR/foreign.txt
vw_log "run $RUN_DIR — voices: $VW_VOICES"

typeset -a run_list
if [[ -n $VW_SELFTEST ]]; then run_list=(selftest-red)
elif [[ -n $VW_SELECTED ]]; then run_list=(${(s:,:)VW_SELECTED})
else run_list=($SCN_ORDER); fi
for n in $run_list; do (( $+functions[scn_$n] )) || refuse "no scenario named $n (--list)"; done

vw_set_voice() {   # terminal|study — Settings ▸ the design voice, by AXPress (no screen click)
  vw_keys "Settings…" "tell (first application process whose unix id is $PID) to click menu item \"Settings…\" of menu 1 of menu bar item 2 of menu bar 1"
  sleep 1.5
  vw_ax_press $1 AXRadioButton || vw_abort "the $1 voice control was not found in Settings"
  sleep 1.5
  vw_act_note "close Settings"
  osascript -e "tell application \"System Events\" to tell (first application process whose unix id is $PID) to click (first button whose subrole is \"AXCloseButton\") of window \"Variorum Dev Settings\"" >/dev/null 2>&1
  sleep 1
  vw_probe
  [[ ${PV[voice]} == $1 ]] || vw_abort "the voice did not become $1 (${PV[voice]})"
}

VOICE=setup; vw_launch
typeset -g FOUND_VOICE=${PV[voice]}
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
(( RUN_XPASS )) && exit 3
exit 0
