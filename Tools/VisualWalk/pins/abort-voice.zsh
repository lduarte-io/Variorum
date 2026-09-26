#!/bin/zsh
# pins/abort-voice.zsh — HEADLESS pin for an abort in mid-pass (U-VIS round 1, MINOR-5): the dev store's
# voice is a synced setting the passes flip; an abort must NAME the voice it leaves (a Study store reds
# KnownIssues row 90's pins on the next Mac suite), restore it only when no author refusal caused the
# abort and the author checks pass now, and never touch the GUI when the author caused it.
emulate -L zsh
VW=${0:A:h:h}
T=$(mktemp -d /tmp/vw-abort-voice.XXXXXX)
trap 'rm -rf $T' EXIT
mkdir -p $T/wk $T/bin
print '#!/bin/zsh\nprint -r -- "guard $*" >> $VW_PIN_LOG\nexit ${STUB_AUTHOR_RC:-0}' > $T/wk/guard.sh
chmod +x $T/wk/guard.sh
fails=0
run_case() {   # name reason author_rc check
  : > $T/log; rm -rf $T/run; mkdir -p $T/run
  ( export VW_PIN_LOG=$T/log STUB_AUTHOR_RC=$3
    source $VW/lib.zsh
    WK=$T/wk VW_BIN=$T/bin RUN_DIR=$T/run PID=$$ FOUND_VOICE=terminal LAST_VOICE=study VOICE=study
    vw_set_voice() { print -r -- "SET VOICE $1" >> $VW_PIN_LOG }
    vw_quit_app() { print -r -- "QUIT" >> $VW_PIN_LOG }
    vw_abort "$2" ) >/dev/null 2>&1
  local log=$(<$T/log) aborted=$(<$T/run/aborted 2>/dev/null) report=$(<$T/run/report.md 2>/dev/null)
  if eval "$4"; then print "PASS  $1"; else print "FAIL  $1"; print -r -- "      aborted: ${aborted//$'\n'/ | }  log: ${log//$'\n'/ | }"; (( fails++ )); fi
}
run_case "an author refusal leaves the voice, names it, touches nothing" \
  "guard: someone is at the machine — STOP" 0 \
  '[[ $aborted == *"voice left at study (found terminal)"*"RESTORE OWED"*"row 90"* && $log != *"SET VOICE"* && $log == *QUIT* ]]'
run_case "Ctrl-C is the author: named, not restored" "interrupted (SIGINT) — the author is at the machine" 0 \
  '[[ $aborted == *"RESTORE OWED"* && $log != *"SET VOICE"* ]]'
run_case "a harness abort with the author away restores the voice" "probe timed out" 0 \
  '[[ $log == *"SET VOICE terminal"* && $aborted == *"RESTORED to terminal"* && $aborted != *"RESTORE OWED"* ]]'
run_case "a harness abort with the author PRESENT restores nothing" "probe timed out" 4 \
  '[[ $log != *"SET VOICE"* && $aborted == *"RESTORE OWED"* ]]'
run_case "the report carries the abort" "probe timed out" 4 '[[ $report == *"ABORTED"* ]]'
print "abort-voice pins: $fails failing"
(( fails == 0 ))
