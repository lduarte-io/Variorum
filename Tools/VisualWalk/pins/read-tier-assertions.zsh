#!/bin/zsh
# pins/read-tier-assertions.zsh — HEADLESS pin for rule (c) on a read-tier click (U-VIS round 1,
# MINOR-1): the last-line click must RED when the caret lands on the wrong TEXT line — the pre-fix
# Read ▸ edit landing (line 0) — and on the blank line under the text (the pre-fix Index landing);
# the known re-wrap (S3) alone stays XFAIL. Planted probe answers; nothing touches the GUI.
emulate -L zsh
VW=${0:A:h:h}
source $VW/lib.zsh
source $VW/scenarios.zsh
T=$(mktemp -d /tmp/vw-read-tier.XXXXXX); trap 'rm -rf $T' EXIT
RUN_DIR=$T
fails=0
plant() { PV=(); local kv; for kv in "$@"; do PV[${kv%%=*}]=${kv#*=}; done }
statuses() { print -r -- ${(j: :)${SCN_ROWS%%	*}} }
check() { if eval "$2"; then print "PASS  $1"; else print "FAIL  $1   rows: $(statuses)"; (( fails++ )); fi }

# The click went at y=700 on the tier's last line of a 5-text-line block (its live box 684–701 on success).
SCN_ROWS=(); plant fr=pane nl=1 caretEnd=0 caretLine=0 caretTextLines=5 caretY0=620 caretY1=637
vw_assert_last_line_click Read▸edit 700 >/dev/null 2>&1
check "the pre-fix Read ▸ edit landing (line 0) REDS" '[[ " $(statuses) " == *" FAIL "* ]]'

SCN_ROWS=(); plant fr=pane nl=1 caretEnd=1 caretLine=5 caretTextLines=5 caretY0=705 caretY1=722
vw_assert_last_line_click Index 700 >/dev/null 2>&1
check "the pre-fix Index landing (the blank line under the text) REDS" '[[ " $(statuses) " == *" FAIL "* ]]'

SCN_ROWS=(); plant fr=pane nl=1 caretEnd=0 caretLine=4 caretTextLines=5 caretY0=670 caretY1=687
vw_assert_last_line_click Index 700 >/dev/null 2>&1
check "the right line, risen under the pointer (S3) → XFAIL only, never red" \
  '[[ " $(statuses) " != *" FAIL "* && " $(statuses) " == *" XFAIL "* ]]'

SCN_ROWS=(); plant fr=pane nl=1 caretEnd=0 caretLine=4 caretTextLines=6 caretY0=684 caretY1=701
vw_assert_last_line_click Index 700 >/dev/null 2>&1
check "the one extra line S3's marker wrap adds → still the clicked line" '[[ " $(statuses) " != *" FAIL "* ]]'

print "read-tier-assertions pins: $fails failing"
(( fails == 0 ))
