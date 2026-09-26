#!/bin/zsh
# pins/guard-order.zsh — HEADLESS pin for the per-step guard ORDER (U-VIS round 1, MAJOR-1).
# The rule (18l ENVIRONMENT TRAPS, hardened after the U0 ~01:37 incident): the AUTHOR checks (her app
# absent · HID idle) run BEFORE anything touches the GUI — activation included — and an
# author-at-the-machine refusal ABORTS; it is never retried with a re-activation.
# Nothing here touches the GUI: osascript / cliclick are shadowed by functions that append to a call
# log, WalkKit is a stub guard whose exit codes the cases set, the helpers are stubs.
# Exit 0 = every case holds; 1 = a case failed (each case prints PASS/FAIL with the call log).
emulate -L zsh
VW=${0:A:h:h}
T=$(mktemp -d /tmp/vw-guard-order.XXXXXX)
trap 'rm -rf $T' EXIT
mkdir -p $T/wk $T/bin $T/run
cat > $T/wk/guard.sh <<'G'
#!/bin/zsh
if [[ $1 == --author ]]; then print -r -- "guard --author" >> $VW_PIN_LOG; exit ${STUB_AUTHOR_RC:-0}; fi
print -r -- "guard $*" >> $VW_PIN_LOG; exit ${STUB_GUARD_RC:-0}
G
print '#!/bin/zsh\nexit 0' > $T/bin/vis-foreign
print '#!/bin/zsh\nprint "vis id=$1 key=1 fr=editor win=0.0,0.0,100.0,100.0"' > $T/bin/vis-probe
print '#!/bin/zsh\nprint "1 0 0 100 100"' > $T/bin/vis-win
print '#!/bin/zsh\nexit 0' > $T/bin/vis-ax
chmod +x $T/wk/guard.sh $T/bin/*

fails=0
run_case() {   # name author_rc guard_rc act… ; then the checks as a zsh expression over $log
  local name=$1 arc=$2 grc=$3; shift 3
  local act=$1; shift
  : > $T/log
  ( export VW_PIN_LOG=$T/log STUB_AUTHOR_RC=$arc STUB_GUARD_RC=$grc
    source $VW/lib.zsh
    WK=$T/wk VW_BIN=$T/bin RUN_DIR=$T/run STEP_GAP=0 PID=99999 WIN_X=0 WIN_Y=0 WIN_W=100 WIN_H=100
    osascript() { print -r -- "osascript $*" >> $VW_PIN_LOG }
    cliclick() { print -r -- "cliclick $*" >> $VW_PIN_LOG }
    sleep() { : }
    eval "$act" ) >/dev/null 2>&1
  print -r -- "status $?" >> $T/log
  local log; log=$(<$T/log)
  if eval "$1"; then print "PASS  $name"; else print "FAIL  $name"; print -r -- "      log: ${log//$'\n'/ | }"; (( fails++ )); fi
}
first_line() { print -r -- ${${(f)log}[1]} }
count() { print -r -- ${#${(M)${(f)log}:#$1*}} }

# 1. The author is at the machine: nothing may touch the GUI, and the run must stop (abort, exit 4).
for act in 'vw_click 10 10' 'vw_keys k "keystroke \"x\""' 'vw_scroll 10 10 1' 'vw_ax_press index' 'vw_resize 50 50'; do
  run_case "author present → no activation, abort ($act)" 4 4 "$act" \
    '[[ $(count "osascript") == 0 && $(count "cliclick") == 0 && $log == *"status 4"* ]]'
done
# 2. Author absent: the author check comes FIRST, then the activation, then the target guard, then the act.
run_case "order: author check → activate → target guard → click" 0 0 'vw_click 10 10' \
  '[[ $(first_line) == "guard --author" && $log == *"guard --author"*"osascript"*"guard 99999 10 10"*"cliclick c:10,10"* ]]'
# 3. A target refusal that is deterministic (point outside the window, 7; not on this Space, 6) aborts at
#    once — no retry, no second activation (N5).
run_case "point outside the window (7) → abort, no retry" 0 7 'vw_click 10 10' \
  '[[ $(count "osascript") == 1 && $(count "cliclick") == 0 && $log == *"status 4"* ]]'
# 4. Someone arrives between the author check and the target guard (the target guard says 4): abort,
#    never re-activate.
run_case "idle refusal from the target guard (4) → abort, no re-activation" 0 4 'vw_click 10 10' \
  '[[ $(count "osascript") == 1 && $(count "cliclick") == 0 && $log == *"status 4"* ]]'

print "guard-order pins: $fails failing"
(( fails == 0 ))
