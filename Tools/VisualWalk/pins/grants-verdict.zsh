#!/bin/zsh
# pins/grants-verdict.zsh — HEADLESS pin for the grants precondition's DIAGNOSIS (U-VIS round 2,
# MINOR-R2-3): when the Automation check times out (a consent prompt pending — the case the check was
# written for), the refusal must name the TIMEOUT, not blame Accessibility / Screen Recording. The stub
# helpers are compiled Swift, because the real failure was Swift's pipe BUFFERING: a helper killed by the
# limit left no output at all. Nothing touches the GUI or asks TCC anything.
emulate -L zsh
VW=${0:A:h:h}
source $VW/lib.zsh
T=$(mktemp -d /tmp/vw-grants.XXXXXX); trap 'rm -rf $T' EXIT
VW_BIN=$T
fails=0
check() { if eval "$2"; then print "PASS  $1"; else print "FAIL  $1   got: $3"; (( fails++ )); fi }
stub() {   # name swift-body
  print -r -- "import Foundation
$2" > $T/$1.swift && swiftc -O -o $T/$1 $T/$1.swift 2>/dev/null
}
# The pending-prompt shape: the first line printed, then a block the limit kills.
stub hang 'print("AX 1 SCREEN 1"); sleep(30)'
# ...and the helper's own fix, the same shape LINE-buffered: its first line survives the kill.
stub hangflushed 'setvbuf(stdout, nil, _IOLBF, 0); print("AX 1 SCREEN 1"); sleep(30)'
stub ok 'print("AX 1 SCREEN 1"); print("AE:com.apple.systemevents granted")'
stub noax 'print("AX 0 SCREEN 1"); print("AE:com.apple.systemevents granted")'
stub denied 'print("AX 1 SCREEN 1"); print("AE:com.apple.systemevents denied")'

verdict() { cp $T/$1 $T/vis-tcc; VW_TCC_LIMIT=2 vw_grants_verdict }
out=$(verdict hang); rc=$?
check "a timed-out check names the TIMEOUT and the pending prompt" '(( rc != 0 )) && [[ $out == *"timed out"* && $out == *"consent prompt"* && $out != *"Accessibility"* ]]' "$out"
out=$(verdict hangflushed); rc=$?
check "a line-buffered helper's first answer survives the limit (vis-tcc's setvbuf)" '[[ $out == *"timed out"*"it had answered: AX 1 SCREEN 1"* ]]' "$out"
check "the real helper line-buffers" '[[ $(<$VW/helpers/vis-tcc.swift) == *"setvbuf(stdout, nil, _IOLBF, 0)"* ]]' "no setvbuf in helpers/vis-tcc.swift"
out=$(verdict ok); rc=$?
check "all three granted → launchable" '(( rc == 0 ))' "$out"
out=$(verdict noax); rc=$?
check "no Accessibility → names Accessibility" '(( rc != 0 )) && [[ $out == *"Accessibility"* ]]' "$out"
out=$(verdict denied); rc=$?
check "System Events denied → names System Events and the state" '(( rc != 0 )) && [[ $out == *"System Events"* && $out == *denied* ]]' "$out"
print "grants-verdict pins: $fails failing"
(( fails == 0 ))
